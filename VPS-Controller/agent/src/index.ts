import { api } from './api.js';
import { env } from './config.js';
import { listContainers } from './docker.js';
import { collectMetrics, collectSystemIdentity } from './metrics.js';
import { processActions } from './actions.js';

let stopped = false;

async function heartbeat(): Promise<void> {
  const identity = await collectSystemIdentity();
  await api.post('/api/agent/heartbeat', {
    serverId: env.SERVER_ID,
    agentId: env.AGENT_ID,
    hostname: identity.hostname,
    os: identity.os,
    kernel: identity.kernel,
    arch: identity.arch,
    agentVersion: env.AGENT_VERSION
  });
}

async function metrics(): Promise<void> {
  await api.post('/api/agent/metrics', {
    serverId: env.SERVER_ID,
    metric: await collectMetrics()
  });
}

async function containers(): Promise<void> {
  await api.post('/api/agent/containers', {
    serverId: env.SERVER_ID,
    containers: await listContainers()
  });
}

function schedule(name: string, fn: () => Promise<void>, intervalMs: number): void {
  const run = async () => {
    if (stopped) return;
    try {
      await fn();
    } catch (error) {
      console.error(`[${name}]`, error instanceof Error ? error.message : error);
    }
  };
  void run();
  const timer = setInterval(() => void run(), intervalMs);
  timer.unref();
}

console.log(`VPS Controller Agent ${env.AGENT_VERSION} — server=${env.SERVER_ID}`);

schedule('heartbeat', heartbeat, env.HEARTBEAT_INTERVAL_MS);
schedule('metrics', metrics, env.METRICS_INTERVAL_MS);
schedule('containers', containers, env.CONTAINERS_INTERVAL_MS);
schedule('actions', processActions, env.ACTIONS_INTERVAL_MS);

for (const signal of ['SIGINT', 'SIGTERM'] as const) {
  process.on(signal, () => {
    stopped = true;
    console.log(`Recebido ${signal}. Encerrando agente.`);
    process.exit(0);
  });
}
