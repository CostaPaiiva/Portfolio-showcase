import { GoogleGenAI, Type, type FunctionDeclaration } from '@google/genai';
import { config } from './config.js';
import type { Store } from './store.js';
import type { ActionType } from './types.js';

let aiClient: GoogleGenAI | null = null;

function getAIClient() {
  if (!config.geminiApiKey) return null;
  if (!aiClient) {
    aiClient = new GoogleGenAI({ apiKey: config.geminiApiKey });
  }
  return aiClient;
}

const toolsDeclarations: FunctionDeclaration[] = [
  {
    name: 'list_servers',
    description: 'Lista todos os servidores/VPS cadastrados e seu status atual (online/offline, CPU, RAM, etc).',
    parameters: {
      type: Type.OBJECT,
      properties: {},
    },
  },
  {
    name: 'get_server_details',
    description: 'Obtém detalhes completos de uma VPS específica, incluindo métricas, containers e SO.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        serverId: { type: Type.STRING, description: 'ID do servidor (ex: server-01)' },
      },
      required: ['serverId'],
    },
  },
  {
    name: 'list_containers',
    description: 'Lista os containers Docker que estão rodando ou parados em um servidor.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        serverId: { type: Type.STRING, description: 'ID do servidor (ex: server-01)' },
      },
      required: ['serverId'],
    },
  },
  {
    name: 'execute_docker_action',
    description: 'Executa start, stop ou restart em um container Docker de uma VPS.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        serverId: { type: Type.STRING, description: 'ID do servidor' },
        action: {
          type: Type.STRING,
          description: 'Ação a ser executada',
          enum: ['docker.start', 'docker.stop', 'docker.restart'],
        },
        containerName: { type: Type.STRING, description: 'Nome ou ID do container Docker' },
      },
      required: ['serverId', 'action', 'containerName'],
    },
  },
  {
    name: 'execute_service_action',
    description: 'Executa start, stop ou restart em um serviço systemd autorizado da VPS.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        serverId: { type: Type.STRING, description: 'ID do servidor' },
        action: {
          type: Type.STRING,
          description: 'Ação a ser executada',
          enum: ['service.start', 'service.stop', 'service.restart'],
        },
        serviceName: { type: Type.STRING, description: 'Nome do serviço systemd (ex: caddy, nginx)' },
      },
      required: ['serverId', 'action', 'serviceName'],
    },
  },
  {
    name: 'create_folder',
    description: 'Cria uma pasta ou diretório na VPS (incluindo subpastas recursivamente).',
    parameters: {
      type: Type.OBJECT,
      properties: {
        serverId: { type: Type.STRING, description: 'ID do servidor (ex: server-01)' },
        folderPath: { type: Type.STRING, description: 'Caminho absoluto ou relativo da pasta a ser criada' },
      },
      required: ['serverId', 'folderPath'],
    },
  },
  {
    name: 'delete_folder',
    description: 'Exclui uma pasta ou diretório na VPS e todo seu conteúdo.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        serverId: { type: Type.STRING, description: 'ID do servidor' },
        folderPath: { type: Type.STRING, description: 'Caminho absoluto ou relativo da pasta a excluir' },
      },
      required: ['serverId', 'folderPath'],
    },
  },
  {
    name: 'write_file',
    description: 'Cria ou edita um arquivo/documento de texto na VPS com o conteúdo especificado.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        serverId: { type: Type.STRING, description: 'ID do servidor' },
        filePath: { type: Type.STRING, description: 'Caminho do arquivo (ex: /app/config.json, /root/test.txt)' },
        content: { type: Type.STRING, description: 'Conteúdo textual a ser gravado no arquivo' },
      },
      required: ['serverId', 'filePath', 'content'],
    },
  },
  {
    name: 'delete_file',
    description: 'Exclui um arquivo/documento específico na VPS.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        serverId: { type: Type.STRING, description: 'ID do servidor' },
        filePath: { type: Type.STRING, description: 'Caminho do arquivo a ser excluído' },
      },
      required: ['serverId', 'filePath'],
    },
  },
  {
    name: 'read_file',
    description: 'Lê o conteúdo completo de um arquivo ou documento de texto na VPS (ex: logs, .env, docker-compose.yml).',
    parameters: {
      type: Type.OBJECT,
      properties: {
        serverId: { type: Type.STRING, description: 'ID do servidor' },
        filePath: { type: Type.STRING, description: 'Caminho absoluto ou relativo do arquivo a ser lido' },
      },
      required: ['serverId', 'filePath'],
    },
  },
  {
    name: 'list_directory',
    description: 'Lista os arquivos e subpastas de um diretório na VPS.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        serverId: { type: Type.STRING, description: 'ID do servidor' },
        directoryPath: { type: Type.STRING, description: 'Caminho da pasta a listar' },
      },
      required: ['serverId', 'directoryPath'],
    },
  },
  {
    name: 'get_docker_logs',
    description: 'Obtém as últimas linhas de logs de um container Docker para diagnóstico.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        serverId: { type: Type.STRING, description: 'ID do servidor' },
        containerName: { type: Type.STRING, description: 'Nome ou ID do container Docker' },
        lines: { type: Type.INTEGER, description: 'Quantidade de linhas de log (padrão: 100)' },
      },
      required: ['serverId', 'containerName'],
    },
  },
  {
    name: 'execute_shell_command',
    description: 'Executa qualquer comando no terminal Linux da VPS (estilo Antigravity / SysAdmin total) como df -h, free -m, ps aux, docker-compose up -d, curl, etc.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        serverId: { type: Type.STRING, description: 'ID do servidor' },
        command: { type: Type.STRING, description: 'Comando bash a ser executado no terminal' },
      },
      required: ['serverId', 'command'],
    },
  },
  {
    name: 'get_active_alerts',
    description: 'Lista todos os alertas e notificações recentes de falha, uso de memória ou CPU das VPSs.',
    parameters: {
      type: Type.OBJECT,
      properties: {},
    },
  },
];

export interface ChatMessage {
  role: 'user' | 'model' | 'system';
  content: string;
}

export async function processAIChat(
  messages: ChatMessage[],
  store: Store,
  onActionCreated?: (action: any) => void
): Promise<string> {
  const client = getAIClient();
  if (!client) {
    return 'Chave de API do Gemini não configurada no backend (GEMINI_API_KEY).';
  }

  const systemInstruction = `Você é o Copiloto SysAdmin inteligente do VPS Controller (estilo Antigravity / Claude Code / DevOps Autônomo).
Seu objetivo é ajudar o usuário Thiago Paiva a monitorar, diagnosticar, operar e resolver qualquer problema em suas VPSs Linux, containers Docker, serviços systemd e Sistema de Arquivos.
Você TEM AUTORIZAÇÃO TOTAL e SUPERPODERES para:
1. Executar comandos no terminal Linux (execute_shell_command) - diagnosticar disco, memória, processos, git, curl, docker-compose, etc.
2. Ler e inspecionar logs de containers Docker (get_docker_logs).
3. Ler arquivos e documentos de configuração (read_file) e listar diretórios (list_directory).
4. Criar, editar e excluir arquivos (write_file, delete_file) e pastas (create_folder, delete_folder).
5. Iniciar, parar ou reiniciar containers Docker e serviços systemd.
6. Consultar servidores, status de containers, alertas e métricas de hardware em tempo real.

Comportamento esperado:
- Aja com máxima competência técnica como um engenheiro DevOps sênior.
- Quando o usuário relatar um problema ou pedir uma ação, use proativamente suas ferramentas para investigar logs, checar processos, ler configs ou executar comandos bash necessários.
- Seja direto, claro, seguro e responda sempre em Português do Brasil.`;

  const contents = messages.map(msg => ({
    role: msg.role === 'user' ? 'user' : 'model',
    parts: [{ text: msg.content }],
  }));

  try {
    const response = await client.models.generateContent({
      model: 'gemini-2.5-flash',
      contents,
      config: {
        systemInstruction,
        tools: [{ functionDeclarations: toolsDeclarations }],
      },
    });

    const candidate = response.candidates?.[0];
    const functionCalls = candidate?.content?.parts?.filter(p => p.functionCall).map(p => p.functionCall);

    if (!functionCalls || functionCalls.length === 0) {
      return response.text || 'Entendido.';
    }

    const functionResponses: any[] = [];
    for (const call of functionCalls) {
      if (!call) continue;
      const { name, args } = call;
      let result: any = { error: 'unknown_tool' };

      if (name === 'list_servers') {
        result = store.listServers();
      } else if (name === 'get_server_details') {
        const sid = String(args?.serverId || '');
        result = store.getServer(sid) || { error: 'servidor_nao_encontrado' };
      } else if (name === 'list_containers') {
        const sid = String(args?.serverId || '');
        const server = store.getServer(sid);
        result = server?.containers || [];
      } else if (name === 'get_active_alerts') {
        result = store.alerts();
      } else if (name === 'execute_docker_action' || name === 'execute_service_action') {
        const sid = String(args?.serverId || '');
        const act = String(args?.action || '') as ActionType;
        const target = String(args?.containerName || args?.serviceName || '');
        const actionRecord = await store.addAction(sid, act, target);
        if (onActionCreated) onActionCreated(actionRecord);
        result = {
          success: true,
          message: `Ação ${act} para '${target}' enviada com sucesso para a fila da VPS ${sid}.`,
          action: actionRecord,
        };
      } else if (name === 'create_folder') {
        const sid = String(args?.serverId || '');
        const target = JSON.stringify({ path: String(args?.folderPath || '') });
        const actionRecord = await store.addAction(sid, 'file.create_folder', target);
        if (onActionCreated) onActionCreated(actionRecord);
        result = {
          success: true,
          message: `Comando para criar diretório '${args?.folderPath}' enviado para a VPS.`,
          action: actionRecord,
        };
      } else if (name === 'delete_folder') {
        const sid = String(args?.serverId || '');
        const target = JSON.stringify({ path: String(args?.folderPath || '') });
        const actionRecord = await store.addAction(sid, 'file.delete_folder', target);
        if (onActionCreated) onActionCreated(actionRecord);
        result = {
          success: true,
          message: `Comando para excluir diretório '${args?.folderPath}' enviado para a VPS.`,
          action: actionRecord,
        };
      } else if (name === 'write_file') {
        const sid = String(args?.serverId || '');
        const target = JSON.stringify({ path: String(args?.filePath || ''), content: String(args?.content || '') });
        const actionRecord = await store.addAction(sid, 'file.write_file', target);
        if (onActionCreated) onActionCreated(actionRecord);
        result = {
          success: true,
          message: `Comando para salvar arquivo '${args?.filePath}' enviado para a VPS.`,
          action: actionRecord,
        };
      } else if (name === 'delete_file') {
        const sid = String(args?.serverId || '');
        const target = JSON.stringify({ path: String(args?.filePath || '') });
        const actionRecord = await store.addAction(sid, 'file.delete_file', target);
        if (onActionCreated) onActionCreated(actionRecord);
        result = {
          success: true,
          message: `Comando para excluir arquivo '${args?.filePath}' enviado para a VPS.`,
          action: actionRecord,
        };
      } else if (name === 'read_file') {
        const sid = String(args?.serverId || '');
        const target = JSON.stringify({ path: String(args?.filePath || '') });
        const actionRecord = await store.addAction(sid, 'file.read_file', target);
        if (onActionCreated) onActionCreated(actionRecord);
        result = {
          success: true,
          message: `Solicitação para ler arquivo '${args?.filePath}' enviada para a VPS.`,
          action: actionRecord,
        };
      } else if (name === 'list_directory') {
        const sid = String(args?.serverId || '');
        const target = JSON.stringify({ path: String(args?.directoryPath || '') });
        const actionRecord = await store.addAction(sid, 'file.list_directory', target);
        if (onActionCreated) onActionCreated(actionRecord);
        result = {
          success: true,
          message: `Solicitação para listar diretório '${args?.directoryPath}' enviada para a VPS.`,
          action: actionRecord,
        };
      } else if (name === 'get_docker_logs') {
        const sid = String(args?.serverId || '');
        const target = JSON.stringify({
          containerName: String(args?.containerName || ''),
          lines: Number(args?.lines || 100),
        });
        const actionRecord = await store.addAction(sid, 'docker.logs', target);
        if (onActionCreated) onActionCreated(actionRecord);
        result = {
          success: true,
          message: `Solicitação de logs do container '${args?.containerName}' enviada para a VPS.`,
          action: actionRecord,
        };
      } else if (name === 'execute_shell_command') {
        const sid = String(args?.serverId || '');
        const target = JSON.stringify({ command: String(args?.command || '') });
        const actionRecord = await store.addAction(sid, 'shell.execute', target);
        if (onActionCreated) onActionCreated(actionRecord);
        result = {
          success: true,
          message: `Comando bash '${args?.command}' enviado para execução no terminal da VPS.`,
          action: actionRecord,
        };
      }

      functionResponses.push({
        functionResponse: {
          name,
          response: { output: result },
        },
      });
    }

    const secondResponse = await client.models.generateContent({
      model: 'gemini-2.5-flash',
      contents: [
        ...contents,
        candidate?.content!,
        {
          role: 'user',
          parts: functionResponses,
        },
      ],
      config: {
        systemInstruction,
      },
    });

    return secondResponse.text || 'Ação processada com sucesso.';
  } catch (err: any) {
    console.error('Erro no processAIChat:', err);
    return `Desculpe, ocorreu um erro ao processar sua solicitação: ${err?.message || err}`;
  }
}
