import { api } from './api.js';
import { config } from './config.js';
import { dockerAction } from './docker.js';
import { serviceAction } from './systemd.js';
import { fileAction } from './files.js';

type A = {
  id: string;
  type: string;
  target: string;
};

export async function actions() {
  const x = (await api(
    `/api/agent/actions?serverId=${encodeURIComponent(config.serverId)}`
  )) as { actions: A[] };

  for (const a of x.actions) {
    let success = false;
    let result = '';

    try {
      const parts = a.type.split('.');
      const family = parts[0];
      const op = parts[1];

      if (family === 'docker') {
        result = await dockerAction(op as 'start' | 'stop' | 'restart', a.target);
      } else if (family === 'service') {
        result = await serviceAction(op as 'start' | 'stop' | 'restart', a.target);
      } else if (family === 'file') {
        result = await fileAction(
          op as 'create_folder' | 'delete_folder' | 'write_file' | 'delete_file',
          a.target
        );
      } else {
        throw new Error(`Tipo de ação desconhecido: ${a.type}`);
      }

      success = true;
    } catch (e) {
      result = e instanceof Error ? e.message : String(e);
    }

    await api(`/api/agent/actions/${encodeURIComponent(a.id)}/result`, {
      method: 'POST',
      body: JSON.stringify({ success, result }),
    });
  }
}
