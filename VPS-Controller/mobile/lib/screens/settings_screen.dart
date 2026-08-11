import 'package:flutter/material.dart';
import '../core/app_config.dart';
import 'user_manual_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.onLogout});
  final VoidCallback onLogout;
  @override
  Widget build(BuildContext context) => ListView(
        children: [
          const ListTile(
              leading: Icon(Icons.link),
              title: Text('Backend'),
              subtitle: Text(AppConfig.apiBaseUrl)),
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('Manual do Usuário'),
            subtitle: const Text('Aprenda a usar o VPS Controller'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UserManualScreen())),
          ),
          ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: onLogout)
        ],
      );
}
