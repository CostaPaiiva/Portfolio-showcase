import { z } from 'zod';

export const heartbeatSchema = z.object({
  serverId: z.string().min(1).max(120),
  agentId: z.string().min(1).max(120),
  hostname: z.string().min(1).max(255),
  os: z.string().min(1).max(255),
  kernel: z.string().min(1).max(255),
  arch: z.string().min(1).max(100),
  agentVersion: z.string().min(1).max(50)
});

const diskSchema = z.object({
  fs: z.string(),
  mount: z.string(),
  sizeBytes: z.number().nonnegative(),
  usedBytes: z.number().nonnegative(),
  availableBytes: z.number().nonnegative(),
  usedPercent: z.number().min(0).max(100)
});

const networkSchema = z.object({
  interface: z.string(),
  rxBytes: z.number().nonnegative(),
  txBytes: z.number().nonnegative(),
  rxBytesPerSec: z.number().nonnegative(),
  txBytesPerSec: z.number().nonnegative()
});

export const metricSchema = z.object({
  serverId: z.string().min(1),
  metric: z.object({
    timestamp: z.string().datetime(),
    cpuPercent: z.number().min(0).max(100),
    loadAverage: z.array(z.number()).max(3),
    ram: z.object({
      totalBytes: z.number().nonnegative(),
      usedBytes: z.number().nonnegative(),
      availableBytes: z.number().nonnegative(),
      usedPercent: z.number().min(0).max(100),
      swapTotalBytes: z.number().nonnegative(),
      swapUsedBytes: z.number().nonnegative()
    }),
    disks: z.array(diskSchema),
    uptimeSeconds: z.number().nonnegative(),
    networks: z.array(networkSchema)
  })
});

export const containersSchema = z.object({
  serverId: z.string().min(1),
  containers: z.array(z.object({
    id: z.string(),
    name: z.string(),
    image: z.string(),
    state: z.string(),
    status: z.string(),
    createdAt: z.string().optional(),
    ports: z.array(z.string()),
    cpuPercent: z.number().optional(),
    memoryBytes: z.number().optional()
  }))
});

export const monitorStatusSchema = z.object({
  serverId: z.string().min(1),
  online: z.boolean(),
  latencyMs: z.number().nonnegative().optional(),
  statusCode: z.number().int().optional(),
  error: z.string().max(1000).optional()
});

export const actionSchema = z.object({
  type: z.enum([
    'docker.start',
    'docker.stop',
    'docker.restart',
    'service.start',
    'service.stop',
    'service.restart'
  ]),
  target: z.string().min(1).max(255).regex(/^[a-zA-Z0-9_.:@/-]+$/)
});

export const actionResultSchema = z.object({
  success: z.boolean(),
  result: z.string().max(4000)
});

export const deviceTokenSchema = z.object({
  token: z.string().min(20).max(4096)
});
