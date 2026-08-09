import http, { type IncomingMessage, type ServerResponse } from 'node:http';
import { createHash } from 'node:crypto';
import { URL } from 'node:url';
import type { Duplex } from 'node:stream';
import { config } from './config.js';
import { Store } from './store.js';
import type { ActionType, ContainerSnapshot, MetricSnapshot } from './types.js';

const store = new Store(config.dataFile);
await store.init();
const cooldown = new Map<string, number>();
const wsClients = new Set<Duplex>();

function json(res: ServerResponse, status: number, body: unknown): void {
  const data = JSON.stringify(body);
  res.writeHead(status, {
    'content-type': 'application/json; charset=utf-8',
    'content-length': Buffer.byteLength(data),
    'access-control-allow-origin': '*',
    'access-control-allow-headers': 'authorization,content-type,x-agent-token,x-monitor-token',
    'access-control-allow-methods': 'GET,POST,OPTIONS',
  });
  res.end(data);
}

async function body(req: IncomingMessage): Promise<Record<string, unknown>> {
  const chunks: Buffer[] = [];
  let size = 0;
  for await (const chunk of req) {
    const value = Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk);
    size += value.length;
    if (size > 1024 * 1024) throw new Error('payload_too_large');
    chunks.push(value);
  }
  if (chunks.length === 0) return {};
  return JSON.parse(Buffer.concat(chunks).toString('utf8')) as Record<string, unknown>;
}

function bearer(req: IncomingMessage): string { return (req.headers.authorization || '').replace(/^Bearer\s+/i, ''); }
function agent(req: IncomingMessage): boolean { return req.headers['x-agent-token'] === config.agentToken; }
function monitor(req: IncomingMessage): boolean { return req.headers['x-monitor-token'] === config.monitorToken; }
function validTarget(value: unknown): value is string { return typeof value === 'string' && value.length > 0 && value.length <= 255 && /^[a-zA-Z0-9_.:@/-]+$/.test(value); }

function frame(value: string): Buffer {
  const payload = Buffer.from(value);
  if (payload.length < 126) return Buffer.concat([Buffer.from([0x81, payload.length]), payload]);
  if (payload.length < 65536) {
    const header = Buffer.alloc(4);
    header[0] = 0x81;
    header[1] = 126;
    header.writeUInt16BE(payload.length, 2);
    return Buffer.concat([header, payload]);
  }
  const header = Buffer.alloc(10);
  header[0] = 0x81;
  header[1] = 127;
  header.writeBigUInt64BE(BigInt(payload.length), 2);
  return Buffer.concat([header, payload]);
}

function broadcast(event: string, payload: unknown): void {
  const message = frame(JSON.stringify({ event, payload }));
  for (const socket of wsClients) {
    try { socket.write(message); } catch { wsClients.delete(socket); }
  }
}

async function fire(serverId: string, type: string, message: string, severity: 'warning' | 'critical'): Promise<void> {
  const key = `${serverId}:${type}`;
  const now = Date.now();
  if (now - (cooldown.get(key) || 0) < 300_000) return;
  cooldown.set(key, now);
  await store.alert(serverId, type, message, severity);
}

async function evaluateMetric(serverId: string, metric: MetricSnapshot): Promise<void> {
  if (metric.cpuPercent >= config.cpuThreshold) await fire(serverId, 'CPU elevada', `CPU em ${metric.cpuPercent.toFixed(1)}%`, 'warning');
  if (metric.ram.usedPercent >= config.ramThreshold) await fire(serverId, 'RAM elevada', `RAM em ${metric.ram.usedPercent.toFixed(1)}%`, 'warning');
  const disk = metric.disks.find(item => item.usedPercent >= config.diskThreshold);
  if (disk) await fire(serverId, 'Disco elevado', `${disk.mount} em ${disk.usedPercent.toFixed(1)}%`, 'critical');
}

const server = http.createServer(async (req, res) => {
  try {
    if (req.method === 'OPTIONS') return json(res, 204, {});
    const url = new URL(req.url || '/', `http://${req.headers.host || 'localhost'}`);
    const path = url.pathname;
    if (req.method === 'GET' && path === '/health') return json(res, 200, { status: 'ok', version: '0.2.0', timestamp: new Date().toISOString() });
    if (path.startsWith('/api/agent/') && !agent(req)) return json(res, 401, { error: 'invalid_agent_token' });
    if (path.startsWith('/api/monitor/') && !monitor(req)) return json(res, 401, { error: 'invalid_monitor_token' });
    if (path.startsWith('/api/') && !path.startsWith('/api/agent/') && !path.startsWith('/api/monitor/') && bearer(req) !== config.userToken) return json(res, 401, { error: 'unauthorized' });

    if (req.method === 'POST' && path === '/api/agent/heartbeat') {
      const input = await body(req) as any;
      if (!input.serverId || !input.agentId) return json(res, 400, { error: 'invalid_payload' });
      const serverRecord = await store.heartbeat(input);
      broadcast('server.updated', serverRecord);
      return json(res, 200, { ok: true, server: serverRecord });
    }
    if (req.method === 'POST' && path === '/api/agent/metrics') {
      const input = await body(req) as { serverId?: string; metric?: MetricSnapshot };
      if (!input.serverId || !input.metric) return json(res, 400, { error: 'invalid_payload' });
      await evaluateMetric(input.serverId, input.metric);
      const serverRecord = await store.metric(input.serverId, input.metric);
      broadcast('server.metric', { serverId: input.serverId, metric: input.metric });
      return json(res, 200, { ok: true, server: serverRecord });
    }
    if (req.method === 'POST' && path === '/api/agent/containers') {
      const input = await body(req) as { serverId?: string; containers?: ContainerSnapshot[] };
      if (!input.serverId || !Array.isArray(input.containers)) return json(res, 400, { error: 'invalid_payload' });
      const stopped = input.containers.find(item => !['running', 'created', 'restarting'].includes(item.state.toLowerCase()));
      if (stopped) await fire(input.serverId, 'Container parado', `${stopped.name}: ${stopped.status}`, 'critical');
      return json(res, 200, { ok: true, server: await store.containers(input.serverId, input.containers) });
    }
    if (req.method === 'GET' && path === '/api/agent/actions') {
      const serverId = url.searchParams.get('serverId');
      if (!serverId) return json(res, 400, { error: 'serverId_required' });
      return json(res, 200, { actions: await store.pullActions(serverId) });
    }
    const agentResult = path.match(/^\/api\/agent\/actions\/([^/]+)\/result$/);
    if (req.method === 'POST' && agentResult) {
      const input = await body(req) as { success?: boolean; result?: string };
      const action = await store.finishAction(agentResult[1]!, input.success === true, String(input.result ?? ''));
      if (!action) return json(res, 404, { error: 'action_not_found' });
      broadcast('action.updated', action);
      return json(res, 200, { ok: true, action });
    }
    if (req.method === 'POST' && path === '/api/monitor/status') {
      const input = await body(req) as { serverId?: string; online?: boolean; latencyMs?: number };
      if (!input.serverId || typeof input.online !== 'boolean') return json(res, 400, { error: 'invalid_payload' });
      if (!input.online) await fire(input.serverId, 'VPS offline', 'Monitor externo não conseguiu acessar o endpoint.', 'critical');
      const serverRecord = await store.monitor(input.serverId, input.online, input.latencyMs);
      broadcast('server.monitor', { serverId: input.serverId, online: input.online, latencyMs: input.latencyMs });
      return json(res, 200, { ok: true, server: serverRecord });
    }
    if (req.method === 'GET' && path === '/api/servers') return json(res, 200, { servers: store.listServers() });
    let match = path.match(/^\/api\/servers\/([^/]+)$/);
    if (req.method === 'GET' && match) { const item = store.getServer(decodeURIComponent(match[1]!)); return item ? json(res, 200, { server: item }) : json(res, 404, { error: 'server_not_found' }); }
    match = path.match(/^\/api\/servers\/([^/]+)\/history$/);
    if (req.method === 'GET' && match) { const limit = Math.min(5000, Math.max(1, Number(url.searchParams.get('limit') || 720))); return json(res, 200, { history: store.history(decodeURIComponent(match[1]!), limit) }); }
    match = path.match(/^\/api\/servers\/([^/]+)\/actions$/);
    if (req.method === 'POST' && match) {
      const input = await body(req) as { type?: ActionType; target?: unknown };
      const allowed = ['docker.start', 'docker.stop', 'docker.restart', 'service.start', 'service.stop', 'service.restart'];
      if (!input.type || !allowed.includes(input.type) || !validTarget(input.target)) return json(res, 400, { error: 'invalid_action' });
      const action = await store.addAction(decodeURIComponent(match[1]!), input.type, input.target);
      broadcast('action.created', action);
      return json(res, 202, { action });
    }
    if (req.method === 'GET' && path === '/api/alerts') return json(res, 200, { alerts: store.alerts() });
    return json(res, 404, { error: 'not_found' });
  } catch (error) {
    console.error(error);
    return json(res, error instanceof Error && error.message === 'payload_too_large' ? 413 : 500, { error: 'internal_error' });
  }
});

server.on('upgrade', (req, socket) => {
  try {
    const url = new URL(req.url || '/', `http://${req.headers.host || 'localhost'}`);
    if (url.pathname !== '/ws' || url.searchParams.get('token') !== config.userToken) { socket.write('HTTP/1.1 401 Unauthorized\r\n\r\n'); socket.destroy(); return; }
    const key = req.headers['sec-websocket-key'];
    if (typeof key !== 'string') { socket.destroy(); return; }
    const accept = createHash('sha1').update(`${key}258EAFA5-E914-47DA-95CA-C5AB0DC85B11`).digest('base64');
    socket.write(`HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: ${accept}\r\n\r\n`);
    wsClients.add(socket);
    socket.write(frame(JSON.stringify({ event: 'connected', payload: { ok: true } })));
    socket.on('data', data => { if ((data[0]! & 0x0f) === 0x8) { wsClients.delete(socket); socket.end(); } });
    socket.on('close', () => wsClients.delete(socket));
    socket.on('error', () => wsClients.delete(socket));
  } catch { socket.destroy(); }
});

server.listen(config.port, config.host, () => console.log(`VPS Controller backend http://${config.host}:${config.port}`));
setInterval(async () => { for (const item of await store.stale(config.staleSeconds * 1000)) { await fire(item.id, 'Agente offline', 'Heartbeat do agente expirou.', 'warning'); broadcast('server.updated', item); } }, 15_000).unref();
