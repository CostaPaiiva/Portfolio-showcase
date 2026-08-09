import Fastify from 'fastify';
import cors from '@fastify/cors';
import websocket from '@fastify/websocket';
import { env } from './config.js';
import { requireAgent, requireMonitor, requireUser } from './auth.js';
import { JsonStore } from './store.js';
import { AlertEngine } from './alerts.js';
import {
  actionResultSchema,
  actionSchema,
  containersSchema,
  deviceTokenSchema,
  heartbeatSchema,
  metricSchema,
  monitorStatusSchema
} from './schemas.js';

const app = Fastify({ logger: true });
await app.register(cors, { origin: true });
await app.register(websocket);

const store = new JsonStore(env.DATA_FILE);
await store.init();
const alerts = new AlertEngine(store);

const sockets = new Set<any>();

function broadcast(event: string, payload: unknown): void {
  const message = JSON.stringify({ event, payload });
  for (const socket of sockets) {
    try {
      if (socket.readyState === 1) socket.send(message);
    } catch {
      sockets.delete(socket);
    }
  }
}

app.get('/health', async () => ({
  status: 'ok',
  timestamp: new Date().toISOString(),
  version: '0.1.0'
}));

app.get('/ws', { websocket: true }, (socket, request) => {
  const url = new URL(request.url, 'http://localhost');
  if (url.searchParams.get('token') !== env.WS_TOKEN) {
    socket.close(1008, 'unauthorized');
    return;
  }
  sockets.add(socket);
  socket.send(JSON.stringify({ event: 'connected', payload: { ok: true } }));
  socket.on('close', () => sockets.delete(socket));
});

app.post('/api/agent/heartbeat', { preHandler: requireAgent }, async (request, reply) => {
  const parsed = heartbeatSchema.safeParse(request.body);
  if (!parsed.success) return reply.code(400).send({ error: 'invalid_payload', details: parsed.error.flatten() });
  const server = await store.heartbeat(parsed.data);
  broadcast('server.updated', server);
  return { ok: true, server };
});

app.post('/api/agent/metrics', { preHandler: requireAgent }, async (request, reply) => {
  const parsed = metricSchema.safeParse(request.body);
  if (!parsed.success) return reply.code(400).send({ error: 'invalid_payload', details: parsed.error.flatten() });
  const server = await store.addMetric(parsed.data.serverId, parsed.data.metric);
  await alerts.evaluateMetric(parsed.data.serverId, parsed.data.metric);
  broadcast('server.metric', { serverId: parsed.data.serverId, metric: parsed.data.metric });
  return { ok: true, server };
});

app.post('/api/agent/containers', { preHandler: requireAgent }, async (request, reply) => {
  const parsed = containersSchema.safeParse(request.body);
  if (!parsed.success) return reply.code(400).send({ error: 'invalid_payload', details: parsed.error.flatten() });
  const server = await store.updateContainers(parsed.data.serverId, parsed.data.containers);
  await alerts.evaluateContainers(parsed.data.serverId, parsed.data.containers);
  broadcast('server.containers', { serverId: parsed.data.serverId, containers: parsed.data.containers });
  return { ok: true, server };
});

app.get('/api/agent/actions', { preHandler: requireAgent }, async (request, reply) => {
  const serverId = String((request.query as { serverId?: string }).serverId ?? '');
  if (!serverId) return reply.code(400).send({ error: 'serverId_required' });
  return { actions: await store.pullPendingActions(serverId) };
});

app.post('/api/agent/actions/:id/result', { preHandler: requireAgent }, async (request, reply) => {
  const parsed = actionResultSchema.safeParse(request.body);
  if (!parsed.success) return reply.code(400).send({ error: 'invalid_payload' });
  const id = (request.params as { id: string }).id;
  const action = await store.completeAction(id, parsed.data.success, parsed.data.result);
  if (!action) return reply.code(404).send({ error: 'action_not_found' });
  broadcast('action.updated', action);
  return { ok: true, action };
});

app.post('/api/monitor/status', { preHandler: requireMonitor }, async (request, reply) => {
  const parsed = monitorStatusSchema.safeParse(request.body);
  if (!parsed.success) return reply.code(400).send({ error: 'invalid_payload' });
  const server = await store.monitorStatus(parsed.data.serverId, parsed.data.online, parsed.data.latencyMs);
  if (!parsed.data.online) await alerts.externalOffline(parsed.data.serverId);
  broadcast('server.monitor', { serverId: parsed.data.serverId, ...parsed.data });
  return { ok: true, server };
});

app.get('/api/servers', { preHandler: requireUser }, async () => ({
  servers: store.listServers()
}));

app.get('/api/servers/:id', { preHandler: requireUser }, async (request, reply) => {
  const id = (request.params as { id: string }).id;
  const server = store.getServer(id);
  if (!server) return reply.code(404).send({ error: 'server_not_found' });
  return { server };
});

app.get('/api/servers/:id/history', { preHandler: requireUser }, async (request) => {
  const id = (request.params as { id: string }).id;
  const limitRaw = Number((request.query as { limit?: string }).limit ?? '720');
  const limit = Number.isFinite(limitRaw) ? Math.min(5000, Math.max(1, limitRaw)) : 720;
  return { history: store.history(id, limit) };
});

app.get('/api/servers/:id/actions', { preHandler: requireUser }, async (request) => {
  const id = (request.params as { id: string }).id;
  return { actions: store.listActions(id) };
});

app.post('/api/servers/:id/actions', { preHandler: requireUser }, async (request, reply) => {
  const parsed = actionSchema.safeParse(request.body);
  if (!parsed.success) return reply.code(400).send({ error: 'invalid_payload', details: parsed.error.flatten() });
  const serverId = (request.params as { id: string }).id;
  const action = await store.enqueueAction(serverId, parsed.data.type, parsed.data.target);
  broadcast('action.created', action);
  return reply.code(202).send({ action });
});

app.get('/api/alerts', { preHandler: requireUser }, async (request) => {
  const serverId = (request.query as { serverId?: string }).serverId;
  return { alerts: store.listAlerts(serverId) };
});

app.post('/api/devices', { preHandler: requireUser }, async (request, reply) => {
  const parsed = deviceTokenSchema.safeParse(request.body);
  if (!parsed.success) return reply.code(400).send({ error: 'invalid_payload' });
  await store.addDeviceToken(parsed.data.token);
  return { ok: true };
});

app.setErrorHandler((error, _request, reply) => {
  app.log.error(error);
  reply.code(500).send({ error: 'internal_error' });
});

setInterval(async () => {
  const stale = await store.markStaleAgents(60_000);
  for (const server of stale) {
    await alerts.agentOffline(server.id);
    broadcast('server.updated', server);
  }
}, 15_000).unref();

await app.listen({ host: env.HOST, port: env.PORT });
