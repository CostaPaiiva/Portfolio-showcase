import si from 'systeminformation';

const safePercent = (value: number): number => Math.max(0, Math.min(100, Number.isFinite(value) ? value : 0));

export async function collectSystemIdentity() {
  const [os, time] = await Promise.all([si.osInfo(), si.time()]);
  return {
    hostname: os.hostname || 'unknown',
    os: `${os.distro || os.platform} ${os.release || ''}`.trim(),
    kernel: os.kernel || 'unknown',
    arch: os.arch || process.arch,
    uptimeSeconds: time.uptime
  };
}

export async function collectMetrics() {
  const [load, mem, disks, time, networks] = await Promise.all([
    si.currentLoad(),
    si.mem(),
    si.fsSize(),
    si.time(),
    si.networkStats()
  ]);

  return {
    timestamp: new Date().toISOString(),
    cpuPercent: safePercent(load.currentLoad),
    loadAverage: [
      Number(load.avgLoad || 0),
      Number((load as any).currentLoadUser || 0),
      Number((load as any).currentLoadSystem || 0)
    ].slice(0, 3),
    ram: {
      totalBytes: mem.total,
      usedBytes: mem.used,
      availableBytes: mem.available,
      usedPercent: safePercent(mem.total > 0 ? (mem.used / mem.total) * 100 : 0),
      swapTotalBytes: mem.swaptotal,
      swapUsedBytes: mem.swapused
    },
    disks: disks.map(d => ({
      fs: d.fs,
      mount: d.mount,
      sizeBytes: d.size,
      usedBytes: d.used,
      availableBytes: Math.max(0, d.size - d.used),
      usedPercent: safePercent(d.use)
    })),
    uptimeSeconds: time.uptime,
    networks: networks.map(n => ({
      interface: n.iface,
      rxBytes: Math.max(0, n.rx_bytes),
      txBytes: Math.max(0, n.tx_bytes),
      rxBytesPerSec: Math.max(0, n.rx_sec),
      txBytesPerSec: Math.max(0, n.tx_sec)
    }))
  };
}
