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
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 14),
          _Group(
            title: 'Conexão',
            children: [
              const ListTile(
                leading: Icon(Icons.link_outlined),
                title: Text('Endpoint da API'),
                subtitle: Text(AppConfig.apiBaseUrl),
              ),
              const ListTile(
                leading:
                    Icon(Icons.verified_user_outlined, color: AppColors.online),
                title: Text('Sessão autenticada'),
                subtitle: Text('Token protegido no dispositivo'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Group(
            title: 'Ajuda',
            children: [
              ListTile(
                leading: const Icon(Icons.menu_book_outlined,
                    color: AppColors.accentBright),
                title: const Text('Manual do Usuário'),
                subtitle: const Text('Aprenda a usar o VPS Controller'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const UserManualScreen())),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Group(
            title: 'Sobre',
            children: const [
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('VPS Controller'),
                subtitle: Text('Versão 0.2.0'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.accentBright),
              title: const Text('Sair'),
              subtitle: const Text('Remover a sessão deste dispositivo'),
              onTap: onLogout,
            ),
          ),
        ],
      );
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 7),
            child: Text(title.toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: AppColors.muted, letterSpacing: 1.2)),
          ),
          Card(child: Column(children: children)),
        ],
      );
}
