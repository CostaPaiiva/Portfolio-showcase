import 'package:flutter/material.dart';
import '../models/manual_section.dart';

const userManualSections = <ManualSection>[
  ManualSection(
    title: 'Entenda sua VPS',
    icon: Icons.account_tree_outlined,
    paragraphs: [
      'A VPS é a máquina principal. Dentro dela ficam o VPS Controller, seus serviços e os containers Docker.',
      'PostgreSQL, Redis e Portainer não são outras VPS: são serviços ou containers executados dentro da máquina principal.',
      'Visão conceitual: VPS → VPS Controller (Backend + Agent) → Docker (aplicações e serviços).',
    ],
  ),
  ManualSection(
    title: 'Primeiros passos',
    icon: Icons.route_outlined,
    paragraphs: [
      'O VPS Controller é um aplicativo privado para monitorar e administrar sua VPS com segurança. O celular não executa comandos diretamente no Linux.',
      'O fluxo é: celular → Tailscale → Backend → Agent → VPS Linux → Docker ou systemd. O aplicativo envia uma solicitação, o Backend valida e o Agent executa somente ações permitidas.',
    ],
  ),
  ManualSection(
    title: 'Tela inicial',
    icon: Icons.home_outlined,
    paragraphs: [
      'A tela Início resume o estado da vps-producao-01. Ela mostra os dados mais recentes fornecidos pela API e permite solicitar uma nova atualização.',
      'Online significa que há comunicação recente conforme os critérios do aplicativo. Offline significa que não houve comunicação no período esperado; isso não revela sozinho a causa.',
    ],
    bullets: [
      'Hostname: nome interno da máquina Linux.',
      'CPU: uso atual do processador.',
      'RAM: memória utilizada pelo sistema.',
      'Disco: armazenamento utilizado e disponível.',
      'Uptime: tempo desde a última inicialização.',
      'Rede: interfaces e informações de rede disponíveis.',
      'Containers e alertas: resumos retornados pela API.',
    ],
  ),
  ManualSection(
    title: 'CPU e memória RAM',
    icon: Icons.memory_outlined,
    paragraphs: [
      'CPU representa o uso do processador. Um pico rápido pode ser normal; uso alto por muito tempo pode indicar carga, processo pesado ou sobrecarga.',
      'RAM é a memória temporária usada pelo Linux e pelos serviços. O Linux também usa memória para cache, portanto um percentual isolado não confirma um problema.',
    ],
    bullets: [
      'Observe a duração e a tendência do uso, não apenas um valor.',
      'Quando houver alerta, verifique qual recurso gerou o aviso antes de agir.',
    ],
  ),
  ManualSection(
    title: 'Disco',
    icon: Icons.storage_outlined,
    paragraphs: [
      'O disco mostra quanto armazenamento está ocupado. Logs, imagens Docker, bancos de dados e backups podem aumentar esse consumo.',
    ],
    bullets: [
      'Acompanhe o crescimento do uso.',
      'Evite que o armazenamento chegue perto de 100%.',
      'O aplicativo não possui função de limpeza automática.',
    ],
  ),
  ManualSection(
    title: 'Docker e containers',
    icon: Icons.view_list_outlined,
    paragraphs: [
      'Docker executa aplicações isoladas chamadas containers. A lista do aplicativo é dinâmica: os nomes e estados vêm da API, não de uma lista fixa.',
      'RUNNING significa executando; STOPPED ou EXITED significa parado; RESTARTING significa que o container está tentando iniciar novamente.',
    ],
    bullets: [
      'Cada container pode apresentar nome, status e as informações disponíveis pela API.',
      'Os botões Start, Stop e Restart enviam uma ação ao Backend; o aplicativo não acessa o Docker diretamente.',
    ],
  ),
  ManualSection(
    title: 'Containers',
    icon: Icons.widgets_outlined,
    paragraphs: [
      'Um container é um ambiente isolado onde uma aplicação ou serviço pode rodar. O nome real, a imagem, o status e as portas exibidos são os dados retornados pela API.',
      'A quantidade de containers do dashboard e da tela Docker não é fixa. Ela muda conforme o ambiente monitorado.',
    ],
  ),
  ManualSection(
    title: 'Rede',
    icon: Icons.lan_outlined,
    paragraphs: [
      'A tela Sistema mostra as interfaces e as métricas de rede que o Agent conseguiu coletar. Ausência de um dado significa que ele não foi fornecido pela API, não que a interface não exista.',
    ],
  ),
  ManualSection(
    title: 'Start, Stop e Restart',
    icon: Icons.restart_alt_outlined,
    paragraphs: [
      'Start inicia um container parado. Use-o quando souber por que o serviço está parado.',
      'Restart para e inicia novamente um container. Pode ajudar quando um serviço está travado, mas causa uma breve interrupção.',
      'Stop encerra um container e é uma ação de risco. Parar um serviço pode deixar sites, APIs ou bancos indisponíveis.',
    ],
    warning:
        'Antes de Stop ou Restart, confirme a ação e verifique quais serviços dependem do recurso. Nunca use Stop como primeira solução para qualquer problema.',
  ),
  ManualSection(
    title: 'Start',
    icon: Icons.play_arrow_outlined,
    paragraphs: [
      'Start solicita a inicialização de um container parado. Use a ação somente depois de entender por que o serviço está parado.'
    ],
  ),
  ManualSection(
    title: 'Stop',
    icon: Icons.stop_outlined,
    paragraphs: [
      'Stop encerra o container. A confirmação existe porque a ação pode interromper sites, APIs, bancos ou filas que dependam dele.'
    ],
    warning: 'Parar um serviço de produção pode causar indisponibilidade.',
  ),
  ManualSection(
    title: 'Restart',
    icon: Icons.restart_alt_outlined,
    paragraphs: [
      'Restart para e inicia novamente o container. É uma ação administrativa e causa uma pequena interrupção.'
    ],
  ),
  ManualSection(
    title: 'PostgreSQL, Redis e Portainer',
    icon: Icons.dns_outlined,
    paragraphs: [
      'PostgreSQL é um banco de dados que pode aparecer como container dentro da VPS. Ele não é outra VPS. O destaque PostgreSQL é apenas uma identificação visual pelo nome quando possível.',
      'Redis pode ser usado para cache, sessões, filas ou dados temporários. Portainer é uma ferramenta visual independente para gerenciamento Docker.',
    ],
    bullets: [
      'RUNNING indica que o container está executando, mas não prova que o banco está saudável.',
      'O aplicativo não inventa tabelas, queries, conexões, backups, tamanho de banco ou métricas internas.',
      'Se PostgreSQL ou Redis parar, aplicações dependentes podem apresentar erros.',
    ],
  ),
  ManualSection(
    title: 'Sistema e serviços',
    icon: Icons.settings_system_daydream_outlined,
    paragraphs: [
      'A tela Sistema reúne hostname, sistema operacional, kernel, arquitetura, CPU, RAM, disco, uptime, interfaces de rede e métricas disponíveis pela API.',
      'systemd é o gerenciador de serviços do Linux. Quando essa integração estiver disponível, o Agent aceita apenas serviços presentes em uma allowlist explícita.',
    ],
    bullets: [
      'As ações possíveis são Start, Stop e Restart para recursos autorizados.',
      'O aplicativo não controla serviços arbitrariamente nem oferece um terminal.',
    ],
  ),
  ManualSection(
    title: 'Alertas',
    icon: Icons.notifications_active_outlined,
    paragraphs: [
      'Alertas são avisos sobre condições retornadas pelo sistema, não necessariamente falhas críticas. Podem existir alertas de CPU, RAM, disco, servidor offline, Agent offline e outras categorias fornecidas pela API.',
      'Antes de executar uma ação, confira qual recurso gerou o alerta, há quanto tempo ele existe, se o problema continua e quais serviços dependem dele.',
    ],
  ),
  ManualSection(
    title: 'Rede e Tailscale',
    icon: Icons.vpn_lock_outlined,
    paragraphs: [
      'Tailscale cria uma rede privada entre o celular e a VPS. O VPS Controller usa essa rede para evitar que o painel administrativo fique publicamente acessível pela Internet.',
      'Se não houver conexão, verifique a Internet do celular, o Tailscale, o estado da VPS e tente atualizar novamente. O aplicativo não altera configurações do Tailscale.',
    ],
  ),
  ManualSection(
    title: 'Backend e Agent',
    icon: Icons.hub_outlined,
    paragraphs: [
      'O Backend recebe solicitações do aplicativo, valida a autenticação e encaminha ações. O Agent roda na VPS, coleta métricas, descobre containers e consulta ações pendentes.',
      'Se o Agent estiver offline, as métricas podem deixar de ser atualizadas mesmo que a VPS continue ligada. O aplicativo também pode ficar sem resposta se Backend, rede ou Tailscale estiverem indisponíveis.',
    ],
  ),
  ManualSection(
    title: 'Atualizar e status offline',
    icon: Icons.sync_outlined,
    paragraphs: [
      'Atualizar solicita os dados mais recentes disponíveis. Essa ação não reinicia, para, inicia nem modifica a VPS.',
      'Uma VPS offline pode estar desligada, reiniciando, sem Internet, com Tailscale desconectado, Backend parado, Agent parado ou com um problema temporário de rede. O status não identifica automaticamente a causa.',
    ],
  ),
  ManualSection(
    title: 'Segurança',
    icon: Icons.shield_outlined,
    paragraphs: [
      'A senha e o token de sessão são confidenciais. Não compartilhe credenciais, não coloque senhas em prints ou mensagens e nunca publique tokens, credenciais ou arquivos .env no GitHub.',
      'Start, Stop e Restart são ações administrativas. O sistema usa validações e allowlists; não existe shell arbitrário no aplicativo.',
    ],
    warning:
        'Nunca pare PostgreSQL, Backend, Redis ou outro serviço de produção apenas para testar o aplicativo.',
  ),
  ManualSection(
    title: 'Login e problemas de conexão',
    icon: Icons.login_outlined,
    paragraphs: [
      'Na primeira utilização, informe seu usuário e senha. O aplicativo envia essas credenciais ao Backend, guarda somente o token de sessão no armazenamento seguro do dispositivo e valida a sessão ao abrir. No Logout, o token salvo é removido.',
      'Se não conseguir conectar: verifique a Internet, abra o Tailscale, confirme que ele está conectado, volte ao VPS Controller e toque em Atualizar ou tente novamente.',
    ],
  ),
  ManualSection(
    title: 'Perguntas frequentes',
    icon: Icons.help_outline,
    paragraphs: [
      'O VPS Controller substitui SSH? Não. Ele facilita monitoramento e ações recorrentes; administração avançada continua sendo feita por SSH.',
      'Fechar o aplicativo, perder a Internet do celular ou desconectar o Tailscale não para a VPS. Apenas o painel perde a comunicação temporariamente.',
      'Não é necessário manter o aplicativo aberto para Backend e Agent continuarem executando na VPS.',
      'PostgreSQL normalmente é um serviço ou container dentro da VPS, não outra VPS.',
    ],
  ),
  ManualSection(
    title: 'Glossário',
    icon: Icons.menu_book_outlined,
    paragraphs: [
      'VPS: servidor virtual privado. CPU: processador. RAM: memória temporária. Disco: armazenamento. Uptime: tempo desde a inicialização.',
      'Docker: plataforma de containers. Container: ambiente isolado para uma aplicação. PostgreSQL: banco relacional. Redis: serviço de cache e dados em memória. Portainer: painel visual para Docker.',
      'Backend: servidor que processa solicitações. Agent: programa instalado na VPS. API: meio de comunicação com o Backend. WebSocket: conexão para atualizações em tempo real. Token: credencial secreta.',
    ],
  ),
];
