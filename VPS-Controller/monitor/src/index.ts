import { existsSync, readFileSync } from 'node:fs';
import process from 'node:process';

type Target = { serverId: string; name: string; url: string };

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
const backend = process.env.BACKEND_URL || 'http://127.0.0.1:3000';
const token = process.env.MONITOR_TOKEN || 'change-me-monitor';
const interval = Math.max(5000, Number(process.env.CHECK_INTERVAL_MS || 30000));
const timeout = Math.max(1000, Number(process.env.REQUEST_TIMEOUT_MS || 5000));
let targets: Target[] = [];

try {
  targets = JSON.parse(process.env.MONITOR_TARGETS_JSON || '[]') as Target[];
} catch {
  throw new Error('MONITOR_TARGETS_JSON inválido');
}

async function report(payload: unknown): Promise<void> {
  const response = await fetch(`${backend}/api/monitor/status`, {
    method: 'POST',
    headers: { 'content-type': 'application/json', 'x-monitor-token': token },
    body: JSON.stringify(payload),
    signal: AbortSignal.timeout(timeout),
  });
  if (!response.ok) throw new Error(`backend ${response.status}: ${await response.text()}`);
}

async function check(target: Target): Promise<void> {
  const started = performance.now();
  try {
    const response = await fetch(target.url, {
      redirect: 'follow',
      signal: AbortSignal.timeout(timeout),
    });
    const latencyMs = Math.round(performance.now() - started);
    const online = response.status >= 200 && response.status < 500;
    await report({ serverId: target.serverId, online, latencyMs, statusCode: response.status });
    console.log(`${target.name}: ${online ? 'ONLINE' : 'OFFLINE'} ${response.status} ${latencyMs}ms`);
  } catch (error) {
    const latencyMs = Math.round(performance.now() - started);
    try {
      await report({
        serverId: target.serverId,
        online: false,
        latencyMs,
        error: error instanceof Error ? error.message : String(error),
      });
    } catch (reportError) {
      console.error('report:', reportError);
    }
    console.log(`${target.name}: OFFLINE ${latencyMs}ms`);
  }
}

async function run(): Promise<void> {
  await Promise.allSettled(targets.map(check));
}

console.log(`Monitor externo ${targets.length} alvo(s)`);
void run();
setInterval(() => void run(), interval);
