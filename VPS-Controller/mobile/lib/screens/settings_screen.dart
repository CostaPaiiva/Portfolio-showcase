import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_config.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.link),
          title: const Text('Backend'),
          subtitle: const Text(AppConfig.apiBaseUrl),
        ),
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('Segurança'),
          subtitle: const Text('Firebase em produção; token de desenvolvimento local.'),
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Sair'),
          onTap: () => context.read<AuthService>().signOut(),
        ),
      ],
    );
  }
}
