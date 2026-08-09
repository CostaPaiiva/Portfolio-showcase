import 'dotenv/config';
import axios from 'axios';
import { z } from 'zod';

const targetSchema = z.array(z.object({
  serverId: z.string().min(1),
  name: z.string().min(1),
  url: z.string().url()
}));

const backendUrl = process.env.BACKEND_URL || 'http://127.0.0.1:3000';
const monitorToken = process.env.MONITOR_TOKEN || '';
const intervalMs = Number(process.env.CHECK_INTERVAL_MS || 30000);
const timeoutMs = Number(process.env.REQUEST_TIMEOUT_MS || 5000);

if (monitorToken.length < 8) throw new Error('MONITOR_TOKEN inválido');

const targets = targetSchema.parse(JSON.parse(process.env.MONITOR_TARGETS_JSON || '[]'));

async function report(payload: object): Promise<void> {
  await axios.post(`${backendUrl}/api/monitor/status`, payload, {
    timeout: timeoutMs,
    headers: { 'x-monitor-token': monitorToken }
  });
}

async function checkTarget(target: z.infer<typeof targetSchema>[number]): Promise<void> {
  const started = performance.now();
  try {
    const response = await axios.get(target.url, {
      timeout: timeoutMs,
      validateStatus: () => true
    });
    const latencyMs = Math.round(performance.now() - started);
    const online = response.status >= 200 && response.status < 500;
    await report({
      serverId: target.serverId,
      online,
      latencyMs,
      statusCode: response.status
    });
    console.log(`${target.name}: ${online ? 'ONLINE' : 'OFFLINE'} ${response.status} ${latencyMs}ms`);
  } catch (error) {
    const latencyMs = Math.round(performance.now() - started);
    await report({
      serverId: target.serverId,
      online: false,
      latencyMs,
      error: error instanceof Error ? error.message : String(error)
    });
    console.log(`${target.name}: OFFLINE ${latencyMs}ms`);
  }
}

async function run(): Promise<void> {
  await Promise.allSettled(targets.map(checkTarget));
}

void run();
setInterval(() => void run(), Math.max(5000, intervalMs)).unref();
console.log(`Monitor externo iniciado com ${targets.length} alvo(s).`);
