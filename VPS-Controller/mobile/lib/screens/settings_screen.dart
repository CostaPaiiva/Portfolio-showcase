import 'package:flutter/material.dart';
import '../core/app_config.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.onLogout});
  final VoidCallback onLogout;
  @override
  Widget build(BuildContext c) => ListView(children: [
        const ListTile(
            leading: Icon(Icons.link),
            title: Text('Backend'),
            subtitle: Text(AppConfig.apiBaseUrl)),
        ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: onLogout)
      ]);
}
