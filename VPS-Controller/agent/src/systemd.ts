import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { config } from './config.js';

const run = promisify(execFile);

export async function serviceAction(op: 'start' | 'stop' | 'restart', name: string) {
  if (!config.allowedServices.has(name)) throw new Error(`serviço não autorizado: ${name}`);
  const cmd = config.sudo ? 'sudo' : 'systemctl';
  const args = config.sudo ? ['systemctl', op, name] : [op, name];
  const { stdout, stderr } = await run(cmd, args, { timeout: 30000, maxBuffer: 1024 * 1024 });
  return (stdout || stderr || `systemctl ${op} ok`).trim();
}

export async function serviceLogs(name: string, lines = 100): Promise<string> {
  if (!/^[a-zA-Z0-9_.-]+$/.test(name)) {
    throw new Error('Nome de serviço inválido');
  }
  const cmd = config.sudo ? 'sudo' : 'journalctl';
  const args = config.sudo
    ? ['journalctl', '-u', name, '-n', String(lines), '--no-pager']
    : ['-u', name, '-n', String(lines), '--no-pager'];
  try {
    const { stdout, stderr } = await run(cmd, args, { timeout: 15000, maxBuffer: 4 * 1024 * 1024 });
    return (stdout || stderr || 'Nenhum log encontrado para este serviço.').trim();
  } catch (e: any) {
    return `Erro ao ler journalctl para ${name}: ${e.message || e}`;
  }
}

