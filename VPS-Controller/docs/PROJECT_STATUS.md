# Status do projeto

## Implementado neste ZIP

- [x] Monorepo.
- [x] Backend Fastify.
- [x] Health check.
- [x] Autenticação de usuário com Firebase opcional + token de desenvolvimento.
- [x] Autenticação de agente.
- [x] Autenticação de monitor.
- [x] Store persistente JSON para MVP.
- [x] Heartbeat.
- [x] CPU.
- [x] RAM.
- [x] Disco.
- [x] Uptime.
- [x] Rede.
- [x] Docker inventory.
- [x] Métricas básicas de containers.
- [x] Docker start/stop/restart.
- [x] systemd start/stop/restart por allowlist.
- [x] Fila de ações.
- [x] WebSocket.
- [x] Histórico de métricas.
- [x] Alertas básicos.
- [x] FCM quando Firebase Admin está configurado.
- [x] Monitor HTTP externo.
- [x] Flutter: login, dashboard, detalhes, alertas, configurações.
- [x] Dockerfiles.
- [x] docker-compose.
- [x] systemd unit template.
- [x] CI básico.
- [x] Testes básicos do backend.

## Para o Codex finalizar/hardening

- [ ] Gerar wrappers Android/iOS com Flutter local.
- [ ] Configurar FlutterFire e Firebase reais.
- [ ] Persistência Firestore/PostgreSQL em produção.
- [ ] Refresh/stream robusto de FCM tokens.
- [ ] Ticket WebSocket seguro por usuário.
- [ ] Rate limiting.
- [ ] RBAC completo.
- [ ] Rotação/revogação individual de tokens de agentes.
- [ ] Dashboard de gráficos históricos com `fl_chart`.
- [ ] Logs Docker paginados/streaming.
- [ ] Nginx, PostgreSQL, Redis e n8n avançados.
- [ ] TLS/reverse proxy de produção.
- [ ] Testes de integração e e2e.
- [ ] Observabilidade do próprio backend.
- [ ] Migração de thresholds para configuração por servidor/usuário.
