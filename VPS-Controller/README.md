# VPS Controller — Server Management

Monorepo de um MVP para monitorar e administrar VPS pelo celular.

## Componentes

- `mobile/` — app Flutter.
- `backend/` — API Fastify + WebSocket + autenticação opcional Firebase.
- `agent/` — agente Node.js/TypeScript instalado em cada VPS.
- `monitor/` — monitor externo de disponibilidade.
- `docker/` — templates de deploy.
- `docs/` — arquitetura, instalação, segurança e status do projeto.

## O que já existe neste pacote

- Heartbeat do agente.
- Métricas de CPU, RAM, disco, uptime e rede.
- Inventário e métricas básicas de containers Docker.
- Ações controladas: start/stop/restart de containers.
- Ações systemd por allowlist.
- API REST para servidores, histórico, alertas e ações.
- WebSocket para atualização em tempo real.
- Monitor externo HTTP.
- Alertas básicos de CPU, RAM, disco, container e indisponibilidade.
- Preparação para Firebase Authentication e FCM.
- App Flutter com login, dashboard, detalhe de servidor, alertas e configurações.
- Dockerfiles, Compose, exemplos de `.env` e unit systemd.
- Testes básicos do backend.

## Importante

Este pacote não contém credenciais reais. Em produção:

1. configure Firebase;
2. use HTTPS;
3. use tokens longos e exclusivos;
4. não exponha o agente diretamente à internet;
5. rode o agente com permissões mínimas;
6. configure `sudoers` estritamente para serviços systemd autorizados.

Leia:

- `docs/SETUP.md`
- `docs/ARCHITECTURE.md`
- `docs/SECURITY.md`
- `docs/PROJECT_STATUS.md`

## Desenvolvimento rápido

### Backend

```powershell
cd backend
Copy-Item .env.example .env
npm install
npm run dev
```

### Agente

```powershell
cd agent
Copy-Item .env.example .env
npm install
npm run dev
```

### Monitor externo

```powershell
cd monitor
Copy-Item .env.example .env
npm install
npm run dev
```

### Flutter

A pasta `mobile/` contém o código-fonte e o `pubspec.yaml`. Em uma máquina com Flutter:

```powershell
cd mobile
flutter create . --platforms=android,ios
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000 --dart-define=WS_URL=ws://10.0.2.2:3000/ws --dart-define=DEV_USER_TOKEN=change-me-user
```

O comando `flutter create .` gera apenas os arquivos nativos que dependem da instalação local do Flutter.

## Fluxo

```text
VPS -> Agent -> Backend -> WebSocket/API -> Flutter
                     -> FCM

Monitor externo -> Backend -> alertas
```
