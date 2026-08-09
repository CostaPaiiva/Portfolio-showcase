# Arquitetura

## Componentes

### Mobile
O Flutter consome a API REST e abre WebSocket para atualização em tempo real.

### Backend
É o ponto central. Recebe heartbeat, métricas, containers, resultados de ações e status do monitor externo. Também mantém fila de ações remotas.

### Agent
Executa dentro da VPS monitorada. Coleta métricas e consulta periodicamente ações pendentes. Nunca recebe comando shell arbitrário.

### Monitor
Executa fora da VPS monitorada e verifica endpoints HTTP.

## Fluxos

### Métricas
`Agent -> POST /api/agent/metrics -> store -> WebSocket -> Mobile`

### Heartbeat
`Agent -> POST /api/agent/heartbeat -> store -> WebSocket -> Mobile`

### Ação Docker/systemd
`Mobile -> POST /api/servers/:id/actions -> fila -> Agent -> execução permitida -> resultado -> Backend`

### Disponibilidade externa
`Monitor -> GET target -> POST /api/monitor/status -> Backend -> alerta`

## Persistência do MVP

O backend usa um arquivo JSON local (`backend/data/state.json`) para deixar o pacote executável sem infraestrutura adicional.

O próximo passo recomendado para produção é substituir o adapter por Firestore/PostgreSQL sem alterar os contratos HTTP.

## Autenticação

- Usuário: Firebase ID Token quando Firebase Admin está configurado.
- Desenvolvimento: `DEV_USER_TOKEN`.
- Agente: `x-agent-token`.
- Monitor: `x-monitor-token`.
- WebSocket de desenvolvimento: `?token=WS_TOKEN`.

Em produção, substitua o token simples de WebSocket por um ticket curto emitido após autenticação do usuário.
