import 'dotenv/config';
import { z } from 'zod';

const schema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  HOST: z.string().default('0.0.0.0'),
  PORT: z.coerce.number().int().positive().default(3000),
  CORS_ORIGINS: z.string().default('http://localhost:3000'),
  DATA_FILE: z.string().default('./data/state.json'),
  DEV_USER_TOKEN: z.string().default('change-me-user'),
  WS_TOKEN: z.string().default('change-me-ws'),
  AGENT_SHARED_TOKEN: z.string().min(8).default('change-me-agent'),
  MONITOR_TOKEN: z.string().min(8).default('change-me-monitor'),
  FIREBASE_PROJECT_ID: z.string().optional(),
  FIREBASE_CLIENT_EMAIL: z.string().optional(),
  FIREBASE_PRIVATE_KEY: z.string().optional(),
  ALERT_CPU_PERCENT: z.coerce.number().min(1).max(100).default(90),
  ALERT_RAM_PERCENT: z.coerce.number().min(1).max(100).default(90),
  ALERT_DISK_PERCENT: z.coerce.number().min(1).max(100).default(90),
  ALERT_COOLDOWN_SECONDS: z.coerce.number().int().positive().default(300)
});

export const env = schema.parse(process.env);
