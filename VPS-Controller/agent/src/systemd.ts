import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { env } from './config.js';

const execFileAsync = promisify(execFile);

export async function serviceAction(
  type: 'start' | 'stop' | 'restart',
  service: string
): Promise<string> {
  if (!env.allowedServices.has(service)) {
    throw new Error(`Serviço não autorizado: ${service}`);
  }

  const command = env.useSudo ? 'sudo' : 'systemctl';
  const args = env.useSudo ? ['systemctl', type, service] : [type, service];

  const { stdout, stderr } = await execFileAsync(command, args, {
    timeout: 30_000,
    maxBuffer: 1024 * 1024
  });

  return (stdout || stderr || `service.${type} executado em ${service}`).trim();
}
