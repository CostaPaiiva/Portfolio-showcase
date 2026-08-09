import type { FastifyReply, FastifyRequest } from 'fastify';
import { env } from './config.js';
import { verifyUserToken } from './firebase.js';
import { createHash, timingSafeEqual } from 'node:crypto';
import type { JsonStore } from './store.js';

export const userIdOf = (request: FastifyRequest): string => (request as FastifyRequest & { userId?: string }).userId ?? '';
export const roleOf = (request: FastifyRequest): string => (request as FastifyRequest & { role?: string }).role ?? 'user';

export async function requireUser(request: FastifyRequest, reply: FastifyReply): Promise<void> {
  const auth = request.headers.authorization;
  const token = auth?.startsWith('Bearer ') ? auth.slice(7) : '';

  if (env.NODE_ENV !== 'production' && token === env.DEV_USER_TOKEN) {
    (request as FastifyRequest & { userId?: string }).userId = 'dev-user';
    return;
  }

  if (!token) {
    await reply.code(401).send({ error: 'unauthorized' });
    return;
  }

  try {
    const user = await verifyUserToken(token);
    if (!user) {
      await reply.code(401).send({ error: 'firebase_not_configured' });
      return;
    }
    (request as FastifyRequest & { userId?: string; role?: string }).userId = user.uid;
    (request as FastifyRequest & { role?: string }).role = user.role ?? 'user';
  } catch {
    await reply.code(401).send({ error: 'invalid_token' });
  }
}

export function agentAuth(store: JsonStore) {
  return async (request: FastifyRequest, reply: FastifyReply): Promise<void> => {
    const token = String(request.headers['x-agent-token'] ?? '');
    const body = (request.body ?? {}) as { serverId?: string; agentId?: string };
    const agentId = String(request.headers['x-agent-id'] ?? body.agentId ?? '');
    const serverId = String(request.headers['x-server-id'] ?? body.serverId ?? (request.query as { serverId?: string })?.serverId ?? '');
    if (!token || !agentId || !serverId) return void await reply.code(401).send({ error: 'agent_identity_required' });
    const credential = await store.getAgent(agentId);
    const digest = createHash('sha256').update(token).digest('hex');
    const valid = credential && credential.status === 'active' && credential.serverId === serverId && credential.tokenHash.length === digest.length && timingSafeEqual(Buffer.from(credential.tokenHash), Buffer.from(digest));
    if (!valid && (env.NODE_ENV === 'production' || token !== env.AGENT_SHARED_TOKEN)) return void await reply.code(401).send({ error: 'invalid_agent_token' });
    (request as FastifyRequest & { agentId?: string; serverId?: string }).agentId = agentId;
    (request as FastifyRequest & { serverId?: string }).serverId = serverId;
    if (credential) await store.touchAgent(agentId);
  };
}

export const requireAgent = async (_request: FastifyRequest, reply: FastifyReply): Promise<void> => { await reply.code(401).send({ error: 'agent_auth_not_configured' }); };

export async function requireMonitor(request: FastifyRequest, reply: FastifyReply): Promise<void> {
  if (request.headers['x-monitor-token'] !== env.MONITOR_TOKEN) {
    await reply.code(401).send({ error: 'invalid_monitor_token' });
  }
}
