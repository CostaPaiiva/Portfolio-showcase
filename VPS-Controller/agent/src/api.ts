import axios from 'axios';
import { env } from './config.js';

export const api = axios.create({
  baseURL: env.BACKEND_URL,
  timeout: 10_000,
  headers: {
    'x-agent-token': env.AGENT_TOKEN,
    'content-type': 'application/json'
  }
});
