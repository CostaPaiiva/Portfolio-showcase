# Status — MVP 0.2 corrigido

## Verificado neste pacote

- [x] Backend TypeScript compila e passa typecheck.
- [x] Agent TypeScript compila e passa typecheck.
- [x] Monitor TypeScript compila e passa typecheck.
- [x] Backend inicia sem dependências de runtime.
- [x] `GET /health` responde.
- [x] Agent envia heartbeat.
- [x] Agent envia CPU, RAM, disco, uptime e rede.
- [x] Backend persiste estado JSON.
- [x] Monitor externo atualiza `externalStatus`.
- [x] Fila de ações é criada e consumida pelo Agent.
- [x] Falha de Docker ausente é reportada sem derrubar o Agent.
- [x] Alertas básicos de CPU/RAM/disco/offline existem.
- [x] Flutter foi reduzido para depender apenas do Flutter SDK no núcleo.

## Não validado neste ambiente

- [ ] `flutter analyze` e build Android/iOS: o ambiente de geração não possui Flutter/Dart instalado.
- [ ] Docker real: o ambiente de geração não possui Docker CLI/daemon.
- [ ] systemd real: deve ser testado na VPS Ubuntu.

## Próxima fase no Codex

- Firebase Authentication/FCM/Firestore.
- WebSocket autenticado.
- RBAC.
- Rate limiting e hardening.
- Gráficos históricos.
- Logs Docker.
- Configuração individual de agentes/tokens.
- Testes Flutter e Android reais.
