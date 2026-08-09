import { existsSync, readFileSync } from 'node:fs';
import process from 'node:process';

function loadDotEnv(): void {
  if (!existsSync('.env')) return;
  for (const rawLine of readFileSync('.env', 'utf8').split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line || line.startsWith('#')) continue;
    const index = line.indexOf('=');
    if (index < 1) continue;
    const key = line.slice(0, index).trim();
    let value = line.slice(index + 1).trim();
    if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    }
    if (process.env[key] === undefined) process.env[key] = value;
  }
}

loadDotEnv();
const numberValue = (key: string, fallback: number) => {
  const value = Number(process.env[key]);
  return Number.isFinite(value) ? value : fallback;
};

export const config = {
  backendUrl: process.env.BACKEND_URL || 'http://127.0.0.1:3000',
  serverId: process.env.SERVER_ID || 'server-01',
  agentId: process.env.AGENT_ID || 'agent-01',
  token: process.env.AGENT_TOKEN || 'change-me-agent',
  version: process.env.AGENT_VERSION || '0.2.0',
  metricsMs: numberValue('METRICS_INTERVAL_MS', 5000),
  heartbeatMs: numberValue('HEARTBEAT_INTERVAL_MS', 15000),
  containersMs: numberValue('CONTAINERS_INTERVAL_MS', 15000),
  actionsMs: numberValue('ACTIONS_INTERVAL_MS', 3000),
  allowedServices: new Set((process.env.ALLOWED_SERVICES || '').split(',').map(x => x.trim()).filter(Boolean)),
  sudo: process.env.SYSTEMD_USE_SUDO === 'true',
};
