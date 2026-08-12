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
const numberValue = (name: string, fallback: number) => {
  const value = Number(process.env[name]);
  return Number.isFinite(value) ? value : fallback;
};

export const config = {
  host: process.env.HOST || '0.0.0.0',
  port: numberValue('PORT', 3000),
  dataFile: process.env.DATA_FILE || './data/state.json',
  adminUsername: process.env.ADMIN_USERNAME || '',
  adminPasswordHash: process.env.ADMIN_PASSWORD_HASH || '',
  jwtSecret: process.env.JWT_SECRET || '',
  sessionTtlSeconds: numberValue('SESSION_TTL_SECONDS', 86_400),
  agentToken: process.env.AGENT_TOKEN || 'change-me-agent',
  monitorToken: process.env.MONITOR_TOKEN || 'change-me-monitor',
  cpuThreshold: numberValue('ALERT_CPU_PERCENT', 90),
  ramThreshold: numberValue('ALERT_RAM_PERCENT', 90),
  diskThreshold: numberValue('ALERT_DISK_PERCENT', 90),
  staleSeconds: numberValue('AGENT_STALE_SECONDS', 60),
};
