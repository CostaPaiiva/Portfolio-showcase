# PROMPT PARA CODEX — FINALIZAR VPS CONTROLLER

Você está trabalhando no repositório existente **VPS Controller — Server Management**.

NÃO recrie o projeto do zero.

Primeiro inspecione todos os arquivos existentes e leia:

- `README.md`
- `docs/ARCHITECTURE.md`
- `docs/SETUP.md`
- `docs/SECURITY.md`
- `docs/PROJECT_STATUS.md`

O repositório já contém:

- Flutter em `mobile/`
- Fastify + TypeScript em `backend/`
- agente Node.js/TypeScript em `agent/`
- monitor externo em `monitor/`
- Docker/deploy em `docker/`
- CI em `.github/`

## OBJETIVO

Transformar o MVP existente em uma versão pronta para produção, preservando a arquitetura e as funcionalidades que já existem.

Não remova recursos funcionando sem necessidade.

## REGRA PRINCIPAL

Trabalhe diretamente nos arquivos do repositório, fazendo commits lógicos e pequenos.

Antes de alterar algo:

1. leia o código atual;
2. rode typecheck/testes existentes;
3. identifique erros reais;
4. corrija primeiro o que impede build;
5. somente depois implemente recursos faltantes.

## PRIORIDADE 1 — FAZER TUDO COMPILAR

### Backend

Execute:

```bash
cd backend
npm install
npm run typecheck
npm test
npm run build
```

Corrija todos os erros.

### Agent

Execute:

```bash
cd agent
npm install
npm run typecheck
npm run build
```

Corrija todos os erros.

### Monitor

Execute:

```bash
cd monitor
npm install
npm run typecheck
npm run build
```

Corrija todos os erros.

### Flutter

Se os diretórios nativos ainda não existirem:

```bash
cd mobile
flutter create . --platforms=android,ios
flutter pub get
flutter analyze
flutter test
```

Preserve o conteúdo atual de `lib/`.

Corrija todos os erros.

## PRIORIDADE 2 — FIREBASE REAL

Configurar corretamente:

- Firebase Authentication
- Firebase Admin
- Firebase Cloud Messaging
- FlutterFire

Não colocar credenciais reais no Git.

Criar/atualizar `.env.example`.

O app deve:

- cadastrar usuário
- fazer login
- recuperar senha
- manter sessão
- obter Firebase ID Token
- enviar token para backend
- registrar token FCM

O backend deve validar Firebase ID Token em produção.

Eliminar dependência de `DEV_USER_TOKEN` em produção.

## PRIORIDADE 3 — PERSISTÊNCIA DE PRODUÇÃO

O adapter JSON atual é para MVP.

Crie uma abstração de repository/store.

Implementar Firestore como persistência principal de produção para:

- users
- servers
- metrics agregadas
- alerts
- events
- audit
- device tokens
- agent credentials metadata

Manter adapter local para desenvolvimento/testes.

Não armazenar tokens/segredos em texto puro quando puder evitar.

## PRIORIDADE 4 — AUTENTICAÇÃO DO AGENTE

O MVP usa token compartilhado.

Migrar para credenciais individuais:

- serverId
- agentId
- agent token individual

No backend armazenar somente hash do token quando possível.

Implementar:

- criação/registro de agente
- revogação
- rotação
- lastUsedAt
- status

Nunca permitir que um agente envie dados em nome de outro servidor.

## PRIORIDADE 5 — WEBSOCKET SEGURO

Remover token global de WebSocket em produção.

Implementar endpoint autenticado para gerar ticket WebSocket curto.

Fluxo:

1. Flutter autenticado chama API.
2. Backend gera ticket curto e temporário.
3. Flutter conecta ao `/ws?ticket=...`.
4. Ticket expira rapidamente e não pode ser reutilizado.
5. Usuário recebe apenas eventos dos servidores aos quais tem acesso.

Implementar reconexão com exponential backoff.

## PRIORIDADE 6 — RBAC

Criar papéis:

- user
- admin
- super_admin

Preparar:

- viewer
- operator

Permissões mínimas:

- visualizar servidor
- visualizar métricas
- visualizar logs
- executar ações Docker
- executar ações systemd
- administrar agentes

Toda ação administrativa precisa de auditoria.

## PRIORIDADE 7 — RATE LIMITING E HARDENING

Adicionar rate limiting.

Aplicar limites mais rígidos em:

- login-sensitive endpoints
- criação de ações
- registro de agentes
- WebSocket tickets

Adicionar:

- security headers
- validação Zod
- limites de payload
- CORS por allowlist
- request IDs
- logs estruturados
- redaction de secrets

## PRIORIDADE 8 — MÉTRICAS

Melhorar histórico.

Implementar downsampling:

- amostras de 1 minuto para 24h
- 5 minutos para 7 dias
- 1 hora para 30/90 dias

Não gravar cada amostra bruta indefinidamente.

Criar endpoints de histórico:

- CPU
- RAM
- disco
- rede

## PRIORIDADE 9 — FLUTTER

Melhorar UI mantendo tema Dark profissional.

Implementar telas reais:

- Splash
- Login
- Recuperar senha
- Dashboard
- Servidores
- Adicionar VPS
- Detalhes VPS
- CPU
- RAM
- Disco
- Rede
- Containers
- Detalhe container
- Logs
- Serviços
- Alertas
- Histórico
- Configurações
- Segurança
- Sobre

Usar `fl_chart` para:

- CPU
- RAM
- disco
- rede

Adicionar:

- estados de loading
- erro
- vazio
- pull-to-refresh
- reconexão
- snackbars
- confirmações para ações críticas

Não criar interface excessivamente carregada.

## PRIORIDADE 10 — DOCKER

O agente já usa Dockerode.

Completar:

- list
- stats
- start
- stop
- restart
- logs paginados/streaming

Não aceitar comandos shell.

Validar container por ID existente.

Toda ação deve ser auditada.

## PRIORIDADE 11 — SYSTEMD

Manter allowlist.

Nunca aceitar nome arbitrário sem validação.

Completar:

- status
- start
- stop
- restart

Documentar configuração `sudoers` mínima.

Não rodar permanentemente como root se puder evitar.

## PRIORIDADE 12 — ALERTAS

Transformar thresholds globais em configuração por servidor.

Suportar:

- CPU alta por duração
- RAM alta por duração
- disco alto
- agente offline
- monitor externo offline
- container parado
- serviço parado
- SSL vencendo

Evitar spam.

Implementar:

- cooldown
- deduplicação
- open
- acknowledged
- resolved

Enviar FCM.

## PRIORIDADE 13 — MONITOR EXTERNO

Completar monitor para:

- HTTP/HTTPS
- status code
- latência
- SSL expiration
- DNS

O monitor deve ficar fora da VPS monitorada.

Implementar retries moderados para reduzir falso positivo.

## PRIORIDADE 14 — LOGS

Implementar logs Docker seguros.

Requisitos:

- tail limitado
- paginação ou streaming
- pesquisa simples
- não carregar arquivo infinito
- limite de tamanho de resposta

Preparar Nginx logs somente leitura.

## PRIORIDADE 15 — RECURSOS FUTUROS

Depois do núcleo estar estável, preparar módulos para:

- Nginx
- PostgreSQL
- MySQL
- Redis
- n8n

Não implementar terminal root arbitrário.

## TESTES

Adicionar testes de:

- autenticação
- agent auth
- validação
- métricas
- alertas
- action allowlist
- Docker actions
- systemd allowlist
- WebSocket ticket
- RBAC

Criar testes de integração do backend.

## CI

Atualizar GitHub Actions para validar:

- backend
- agent
- monitor
- Flutter analyze/test

## DOCKER/DEPLOY

Garantir que:

```bash
docker compose build
docker compose up -d
```

funcione.

Adicionar healthchecks.

Preparar reverse proxy HTTPS.

Nunca incluir certificado/chave real.

## DOCUMENTAÇÃO

Atualizar README e docs durante o trabalho.

Criar instruções claras para:

- Windows 10/11 PowerShell
- Ubuntu 24.04
- Firebase
- backend
- agent
- monitor
- Flutter
- Docker
- systemd
- sudoers
- produção

## SEGURANÇA ABSOLUTA

NUNCA implementar:

```text
exec(req.body.command)
```

NUNCA aceitar shell arbitrário.

NUNCA colocar secrets no Git.

NUNCA dar `NOPASSWD: ALL`.

NUNCA expor Docker socket sem explicar o risco.

## CRITÉRIO DE CONCLUSÃO

Considere o projeto pronto quando:

1. todos os projetos compilarem;
2. todos os testes passarem;
3. Flutter conseguir logar;
4. agente registrar heartbeat;
5. CPU/RAM/disco/rede aparecerem no app;
6. containers aparecerem;
7. start/stop/restart funcionarem com confirmação;
8. systemd funcionar apenas na allowlist;
9. monitor externo detectar indisponibilidade;
10. alertas aparecerem no app e via FCM;
11. histórico e gráficos funcionarem;
12. multi-VPS funcionar;
13. auditoria funcionar;
14. autenticação e RBAC estiverem aplicados;
15. nenhum segredo estiver versionado;
16. documentação permitir instalar tudo do zero.

Ao encontrar TODOs ou gaps, implemente-os sem apagar a base existente.

Faça alterações de forma incremental e preserve compatibilidade sempre que possível.
