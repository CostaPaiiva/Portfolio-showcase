import { api } from './api.js';
import { env } from './config.js';
import { dockerAction } from './docker.js';
import { serviceAction } from './systemd.js';

interface Action {
  id: string;
  serverId: string;
  type:
    | 'docker.start'
    | 'docker.stop'
    | 'docker.restart'
    | 'service.start'
    | 'service.stop'
    | 'service.restart';
  target: string;
}

export async function processActions(): Promise<void> {
  const response = await api.get<{ actions: Action[] }>('/api/agent/actions', {
    params: { serverId: env.SERVER_ID }
  });

  for (const action of response.data.actions) {
    let success = false;
    let result = '';
    try {
      const [family, operation] = action.type.split('.') as ['docker' | 'service', 'start' | 'stop' | 'restart'];
      if (family === 'docker') result = await dockerAction(operation, action.target);
      else result = await serviceAction(operation, action.target);
      success = true;
    } catch (error) {
      result = error instanceof Error ? error.message : String(error);
    }

    await api.post(`/api/agent/actions/${encodeURIComponent(action.id)}/result`, {
      success,
      result
    });
  }
}
