import Docker from 'dockerode';

const docker = new Docker();

function portsOf(ports: Docker.Port[]): string[] {
  return ports.map(p => {
    const publicPart = p.PublicPort ? `${p.IP || '0.0.0.0'}:${p.PublicPort}->` : '';
    return `${publicPart}${p.PrivatePort}/${p.Type}`;
  });
}

export async function listContainers() {
  try {
    const list = await docker.listContainers({ all: true });
    const output = [];

    for (const item of list) {
      let cpuPercent: number | undefined;
      let memoryBytes: number | undefined;

      if (item.State === 'running') {
        try {
          const stats = await docker.getContainer(item.Id).stats({ stream: false });
          const cpuDelta = stats.cpu_stats.cpu_usage.total_usage - stats.precpu_stats.cpu_usage.total_usage;
          const systemDelta = stats.cpu_stats.system_cpu_usage - stats.precpu_stats.system_cpu_usage;
          const cpuCount = stats.cpu_stats.online_cpus || stats.cpu_stats.cpu_usage.percpu_usage?.length || 1;
          cpuPercent = systemDelta > 0 ? (cpuDelta / systemDelta) * cpuCount * 100 : 0;
          memoryBytes = stats.memory_stats.usage || 0;
        } catch {
          // Container can disappear between list and stats.
        }
      }

      output.push({
        id: item.Id,
        name: (item.Names[0] || item.Id.slice(0, 12)).replace(/^\//, ''),
        image: item.Image,
        state: item.State,
        status: item.Status,
        createdAt: new Date(item.Created * 1000).toISOString(),
        ports: portsOf(item.Ports),
        cpuPercent,
        memoryBytes
      });
    }

    return output;
  } catch {
    return [];
  }
}

export async function dockerAction(type: 'start' | 'stop' | 'restart', target: string): Promise<string> {
  const container = docker.getContainer(target);
  if (type === 'start') await container.start();
  if (type === 'stop') await container.stop({ t: 10 });
  if (type === 'restart') await container.restart({ t: 10 });
  return `docker.${type} executado em ${target}`;
}
