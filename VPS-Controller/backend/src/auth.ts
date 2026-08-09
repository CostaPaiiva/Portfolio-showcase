import type { FastifyReply, FastifyRequest } from 'fastify';
import { env } from './config.js';
import { verifyUserToken } from './firebase.js';

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
    (request as FastifyRequest & { userId?: string }).userId = user.uid;
  } catch {
    await reply.code(401).send({ error: 'invalid_token' });
  }
}

export async function requireAgent(request: FastifyRequest, reply: FastifyReply): Promise<void> {
  if (request.headers['x-agent-token'] !== env.AGENT_SHARED_TOKEN) {
    await reply.code(401).send({ error: 'invalid_agent_token' });
  }
}

export async function requireMonitor(request: FastifyRequest, reply: FastifyReply): Promise<void> {
  if (request.headers['x-monitor-token'] !== env.MONITOR_TOKEN) {
    await reply.code(401).send({ error: 'invalid_monitor_token' });
  }
}
