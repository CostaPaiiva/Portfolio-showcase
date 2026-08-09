# VPS Controller — Server Management (MVP 0.2)

Pacote corrigido com núcleo simples e testável.

## Componentes
- `backend/`: API REST Node.js/TypeScript, persistência JSON e alertas.
- `agent/`: coleta CPU, RAM, disco, rede, uptime e Docker; executa apenas ações pré-definidas.
- `monitor/`: health checker externo HTTP/HTTPS.
- `mobile/`: Flutter Android/iOS usando apenas Flutter SDK no núcleo.

## Por que esta versão é mais estável
Backend, agent e monitor **não possuem dependências de runtime**. O Flutter não exige Firebase/Dio/Provider para compilar o MVP. Firebase, FCM, Firestore, WebSocket seguro e gráficos ficam para a etapa de produção no Codex.

## Validação rápida
Copie `.env.example` para `.env` ou exporte as variáveis. O Node não carrega `.env` automaticamente nesta versão; scripts `setup.ps1` ajudam a iniciar no Windows.

### Compilar Node
Em cada pasta `backend`, `agent` e `monitor`:
```bash
npm install
npm run typecheck
npm run build
```

Os diretórios `dist/` já são incluídos no ZIP corrigido, então em produção o runtime pode iniciar com `node dist/server.js`/`node dist/index.js` sem dependências npm.

### Flutter
```bash
cd mobile
flutter create . --platforms=android,ios --project-name vps_controller
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000 --dart-define=USER_TOKEN=change-me-user
```

Leia `docs/VALIDATION.md`.
