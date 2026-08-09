# Setup

## Requisitos

- Node.js 22+
- npm 10+
- Flutter estável para o aplicativo
- Docker opcional
- Ubuntu 24.04 para instalação do agente em produção

## 1. Backend

```bash
cd backend
cp .env.example .env
npm install
npm run dev
```

Teste:

```bash
curl http://localhost:3000/health
```

## 2. Agente

Configure `agent/.env`:

- `SERVER_ID`
- `AGENT_ID`
- `AGENT_TOKEN`
- `BACKEND_URL`

Depois:

```bash
cd agent
npm install
npm run dev
```

## 3. Monitor externo

Configure `MONITOR_TARGETS_JSON`, por exemplo:

```json
[
  {
    "serverId": "server-01",
    "name": "Produção",
    "url": "https://example.com/health"
  }
]
```

Depois:

```bash
cd monitor
npm install
npm run dev
```

## 4. Flutter

Como o gerador Flutter não faz parte deste pacote, gere os wrappers nativos:

```bash
cd mobile
flutter create . --platforms=android,ios
flutter pub get
```

Execute em emulador Android:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:3000 \
  --dart-define=WS_URL=ws://10.0.2.2:3000/ws \
  --dart-define=DEV_USER_TOKEN=change-me-user
```

## Firebase

Para Firebase Authentication e FCM:

1. crie um projeto Firebase;
2. configure o app Flutter com FlutterFire CLI;
3. configure as variáveis Firebase Admin no backend;
4. nunca faça commit de chaves privadas.

Sem Firebase, o MVP pode rodar em modo desenvolvimento com `DEV_USER_TOKEN`.

## Agente como systemd

Veja `docker/vps-controller-agent.service`.

Copie para `/etc/systemd/system/`, ajuste usuário/caminho e rode:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now vps-controller-agent
```
