import 'package:flutter/material.dart';
import 'alerts_screen.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      DashboardScreen(),
      DashboardScreen(),
      AlertsScreen(),
      SettingsScreen(),
    ];
    const titles = ['Dashboard', 'Servidores', 'Alertas', 'Configurações'];

    return Scaffold(
      appBar: AppBar(title: Text(titles[index])),
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.dns_outlined), label: 'Servidores'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), label: 'Alertas'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Config.'),
        ],
      ),
    );
  }
}
