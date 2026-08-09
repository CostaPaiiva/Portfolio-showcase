# Arquitetura — MVP 0.2

## Núcleo atual

```text
Flutter (polling REST)
        |
        v
Backend Node.js/TypeScript
   |             ^
   |             |
   v             |
JSON state    Agent na VPS
                 |
                 +-- CPU/RAM/disco/rede/uptime
                 +-- Docker list/start/stop/restart
                 +-- systemd por allowlist

Monitor externo --------> Backend
```

O núcleo foi deliberadamente deixado sem dependências de runtime nos componentes Node para reduzir problemas de instalação.

## Evolução de produção

Adicionar via Codex somente depois do núcleo passar em todos os testes locais:

- Firebase Authentication e FCM.
- Firestore/PostgreSQL.
- WebSocket autenticado com ticket curto.
- RBAC.
- Métricas agregadas.
- Logs Docker seguros.
- TLS/reverse proxy.
