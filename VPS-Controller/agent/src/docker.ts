import { execFile } from 'node:child_process';
import { promisify } from 'node:util';

const run = promisify(execFile);

export async function containers() {
  try {
    const { stdout } = await run(
      'docker',
      ['ps', '-a', '--no-trunc', '--format', '{{json .}}'],
      { timeout: 10_000, maxBuffer: 4 * 1024 * 1024 },
    );

    return stdout
      .split('\n')
      .filter(Boolean)
      .map(line => {
        const item = JSON.parse(line) as Record<string, unknown>;
        return {
          id: String(item.ID || ''),
          name: String(item.Names || ''),
          image: String(item.Image || ''),
          state: String(item.State || ''),
          status: String(item.Status || ''),
          ports: String(item.Ports || '')
            .split(',')
            .map(value => value.trim())
            .filter(Boolean),
        };
      });
  } catch {
    return [];
  }
}

export async function dockerLogs(containerName: string, lines = 100): Promise<string> {
  if (!/^[a-zA-Z0-9_.:-]+$/.test(containerName)) {
    throw new Error('Nome de container inválido');
  }
  try {
    const { stdout, stderr } = await run('docker', ['logs', '--tail', String(lines), containerName], {
      timeout: 15_000,
      maxBuffer: 4 * 1024 * 1024,
    });
    return (stdout || stderr || 'Nenhum log retornado pelo container.').trim();
  } catch (e: any) {
    return `Erro ao obter logs de ${containerName}: ${e.message || e}`;
  }
}
export async function dockerAction(
  operation: 'start' | 'stop' | 'restart',
  target: string,
) {
  if (!/^[a-zA-Z0-9_.:-]+$/.test(target)) {
    throw new Error('container inválido');
  }

  const args =
    operation === 'stop'
      ? [operation, '--time', '10', target]
      : operation === 'restart'
        ? [operation, '--time', '10', target]
        : [operation, target];

  const { stdout, stderr } = await run('docker', args, {
    timeout: 30_000,
    maxBuffer: 1024 * 1024,
  });

  return (stdout || stderr || `docker ${operation} ok`).trim();
}
