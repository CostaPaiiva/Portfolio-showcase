# Segurança

## Princípios

- Nunca executar shell arbitrário recebido pela rede.
- Containers são controlados por ID validado pelo Docker Engine.
- Serviços systemd só podem ser controlados quando constam em `ALLOWED_SERVICES`.
- Tokens devem ser longos, aleatórios e exclusivos em produção.
- HTTPS é obrigatório em produção.
- Não versionar `.env`, service account, certificados ou chaves.

## systemd

Se o agente não rodar como root, crie regras `sudoers` mínimas e explícitas somente para os serviços que ele realmente deve administrar.

Evite:

```text
ALL=(ALL) NOPASSWD: ALL
```

## WebSocket

O token por query string incluído no MVP serve para desenvolvimento. Em produção, implemente ticket WebSocket curto, de uso único ou curta expiração.

## Docker socket

Acesso ao Docker socket equivale a privilégio elevado no host. Restrinja o usuário/grupo do agente e trate a VPS como ambiente administrativo.

## Rate limit

Antes de expor a API em produção, adicione plugin de rate limiting por usuário/IP e regras específicas em rotas de ação.
