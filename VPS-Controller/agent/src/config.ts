import 'dotenv/config';
import { z } from 'zod';

const schema = z.object({
  BACKEND_URL: z.string().url(),
  SERVER_ID: z.string().min(1),
  AGENT_ID: z.string().min(1),
  AGENT_TOKEN: z.string().min(8),
  AGENT_VERSION: z.string().default('0.1.0'),
  METRICS_INTERVAL_MS: z.coerce.number().int().min(1000).default(5000),
  HEARTBEAT_INTERVAL_MS: z.coerce.number().int().min(5000).default(15000),
  CONTAINERS_INTERVAL_MS: z.coerce.number().int().min(5000).default(15000),
  ACTIONS_INTERVAL_MS: z.coerce.number().int().min(1000).default(3000),
  ALLOWED_SERVICES: z.string().default(''),
  SYSTEMD_USE_SUDO: z.enum(['true', 'false']).default('false')
});

const raw = schema.parse(process.env);
export const env = {
  ...raw,
  allowedServices: new Set(raw.ALLOWED_SERVICES.split(',').map(s => s.trim()).filter(Boolean)),
  useSudo: raw.SYSTEMD_USE_SUDO === 'true'
};
