# Validação do MVP 0.2

## Backend
Defina variáveis no terminal e rode `node dist/server.js`. Teste `GET /health`.

## Agent
Use os mesmos `AGENT_TOKEN` e `SERVER_ID` do backend. O agente deve começar a enviar heartbeat e métricas.

## Teste REST
```bash
curl -H "Authorization: Bearer change-me-user" http://127.0.0.1:3000/api/servers
```

## Monitor
Configure `MONITOR_TARGETS_JSON` e rode `node dist/index.js`.

## Critério mínimo
- backend responde `/health`;
- agente aparece em `/api/servers`;
- CPU/RAM/disco/uptime chegam;
- Docker aparece quando instalado;
- monitor atualiza `externalStatus`;
- app lista a VPS e abre detalhes;
- ação Docker gera fila e é consumida pelo agente.

## Firebase
Não é requisito para validar este núcleo. Adicione somente depois que o MVP estiver verde. Use o `CODEX_PROMPT.md`.
