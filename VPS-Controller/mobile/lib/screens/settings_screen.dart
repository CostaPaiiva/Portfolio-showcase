import 'package:flutter/material.dart';
import '../core/app_config.dart';
import '../core/app_theme.dart';
import 'user_manual_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.onLogout});
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          Text('AJUSTES',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.accentBright,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Conexão, segurança e informações do aplicativo',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.muted)),
          const SizedBox(height: 16),
          _ConnectionCard(),
          const SizedBox(height: 16),
          _Group(title: 'Segurança', children: const [
            _SettingTile(
                icon: Icons.verified_user_outlined,
                iconColor: AppColors.online,
                title: 'Sessão autenticada',
                subtitle: 'O token de sessão está protegido no dispositivo.'),
            Divider(height: 1),
            _SettingTile(
                icon: Icons.password_outlined,
                title: 'Credenciais',
                subtitle: 'A senha não é armazenada pelo aplicativo.'),
          ]),
          const SizedBox(height: 14),
          _Group(title: 'Ajuda', children: [
            _SettingTile(
                icon: Icons.menu_book_outlined,
                iconColor: AppColors.accentBright,
                title: 'Manual do Usuário',
                subtitle: 'Entenda métricas, alertas, Docker e ações.',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const UserManualScreen()))),
          ]),
          const SizedBox(height: 14),
          _Group(title: 'Sobre', children: const [
            _SettingTile(
                icon: Icons.info_outline,
                title: 'VPS Controller',
                subtitle: 'Versão 0.2.0'),
            Divider(height: 1),
            _SettingTile(
                icon: Icons.sync_outlined,
                title: 'Atualizações em tempo real',
                subtitle:
                    'A aplicação recebe eventos quando o Backend os disponibiliza.'),
          ]),
          const SizedBox(height: 16),
          Card(
              child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  leading:
                      const Icon(Icons.logout, color: AppColors.accentBright),
                  title: const Text('Sair'),
                  subtitle:
                      const Text('Remover a sessão segura deste dispositivo'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: onLogout)),
        ],
      );
}

class _ConnectionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.hub_outlined, color: AppColors.accentBright),
              const SizedBox(width: 8),
              Text('Conexão configurada',
                  style: Theme.of(context).textTheme.titleMedium)
            ]),
            const SizedBox(height: 6),
            Text(
                'O aplicativo usa os endereços definidos na instalação. O status real da VPS aparece em Início.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.muted)),
            const SizedBox(height: 16),
            _Endpoint(
                label: 'API REST',
                value: AppConfig.apiBaseUrl,
                icon: Icons.link_outlined),
            const SizedBox(height: 12),
            _Endpoint(
                label: 'WebSocket',
                value: AppConfig.wsUrl,
                icon: Icons.sensors_outlined),
          ])));
}

class _Endpoint extends StatelessWidget {
  const _Endpoint(
      {required this.label, required this.value, required this.icon});
  final String label, value;
  final IconData icon;
  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: AppColors.muted),
        const SizedBox(width: 9),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.muted)),
          const SizedBox(height: 2),
          SelectableText(value, style: Theme.of(context).textTheme.bodyMedium)
        ]))
      ]);
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 7),
            child: Text(title.toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: AppColors.muted, letterSpacing: 1.2))),
        Card(child: Column(children: children))
      ]);
}

class _SettingTile extends StatelessWidget {
  const _SettingTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      this.iconColor,
      this.trailing,
      this.onTap});
  final IconData icon;
  final String title, subtitle;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Icon(icon, color: iconColor ?? AppColors.muted),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap);
}
