import os from 'node:os';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { readFile } from 'node:fs/promises';

const run = promisify(execFile);
const sleep = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

function cpuTimes() {
  return os.cpus().reduce(
    (acc, cpu) => {
      acc.idle += cpu.times.idle;
      acc.total += Object.values(cpu.times).reduce((sum, value) => sum + value, 0);
      return acc;
    },
    { idle: 0, total: 0 },
  );
}

async function cpuPercent() {
  const before = cpuTimes();
  await sleep(250);
  const after = cpuTimes();
  const total = after.total - before.total;
  const idle = after.idle - before.idle;
  return total > 0 ? Math.max(0, Math.min(100, (1 - idle / total) * 100)) : 0;
}

async function disks() {
  if (process.platform === 'win32') return [];
  try {
    const { stdout } = await run('df', ['-Pk']);
    return stdout
      .trim()
      .split('\n')
      .slice(1)
      .map(line => line.trim().split(/\s+/))
      .filter(parts => parts.length >= 6)
      .map(parts => ({
        fs: parts[0] || '',
        sizeBytes: Number(parts[1] || 0) * 1024,
        usedBytes: Number(parts[2] || 0) * 1024,
        availableBytes: Number(parts[3] || 0) * 1024,
        usedPercent: Number((parts[4] || '0').replace('%', '')),
        mount: parts.slice(5).join(' '),
      }));
  } catch {
    return [];
  }
}

let previousNetwork:
  | { timestamp: number; map: Map<string, { rx: number; tx: number }> }
  | undefined;

async function networks() {
  if (process.platform !== 'linux') return [];
  try {
    const text = await readFile('/proc/net/dev', 'utf8');
    const now = Date.now();
    const current = new Map<string, { rx: number; tx: number }>();
    const output = [];

    for (const line of text.split('\n').slice(2)) {
      const [namePart, data] = line.split(':');
      if (!data) continue;
      const name = namePart?.trim() || '';
      const values = data.trim().split(/\s+/);
      const rx = Number(values[0] || 0);
      const tx = Number(values[8] || 0);
      current.set(name, { rx, tx });

      const old = previousNetwork?.map.get(name);
      const seconds = previousNetwork
        ? Math.max(0.001, (now - previousNetwork.timestamp) / 1000)
        : 1;

      output.push({
        interface: name,
        rxBytes: rx,
        txBytes: tx,
        rxBytesPerSec: old ? Math.max(0, (rx - old.rx) / seconds) : 0,
        txBytesPerSec: old ? Math.max(0, (tx - old.tx) / seconds) : 0,
      });
    }

    previousNetwork = { timestamp: now, map: current };
    return output;
  } catch {
    return [];
  }
}

async function swap() {
  if (process.platform === 'win32') return { total: 0, used: 0 };
  try {
    const { stdout } = await run('free', ['-b']);
    const line = stdout.split('\n').find(item => item.trim().startsWith('Swap:'));
    if (!line) return { total: 0, used: 0 };
    const values = line.trim().split(/\s+/);
    return {
      total: Number(values[1] || 0),
      used: Number(values[2] || 0),
    };
  } catch {
    return { total: 0, used: 0 };
  }
}

export async function identity() {
  return {
    hostname: os.hostname(),
    os: `${os.type()} ${os.release()}`,
    kernel: os.release(),
    arch: os.arch(),
  };
}

export async function metrics() {
  const [cpu, diskList, networkList, swapInfo] = await Promise.all([
    cpuPercent(),
    disks(),
    networks(),
    swap(),
  ]);
  const total = os.totalmem();
  const free = os.freemem();
  const used = total - free;

  return {
    timestamp: new Date().toISOString(),
    cpuPercent: cpu,
    loadAverage: os.loadavg(),
    ram: {
      totalBytes: total,
      usedBytes: used,
      availableBytes: free,
      usedPercent: total ? (used / total) * 100 : 0,
      swapTotalBytes: swapInfo.total,
      swapUsedBytes: swapInfo.used,
    },
    disks: diskList,
    uptimeSeconds: os.uptime(),
    networks: networkList,
  };
}
