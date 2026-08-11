import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/live_service.dart';
import 'alerts_screen.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell(
      {super.key,
      required this.api,
      required this.live,
      required this.onLogout});
  final ApiService api;
  final LiveService live;
  final VoidCallback onLogout;
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _dashboardKey = GlobalKey<DashboardScreenState>();
  final _alertsKey = GlobalKey<AlertsScreenState>();
  Timer? _liveRefreshTimer;
  int index = 0;

  @override
  void initState() {
    super.initState();
    widget.live.addListener(_onLiveEvent);
  }

  void _onLiveEvent() {
    if (!mounted || _liveRefreshTimer != null) return;
    _liveRefreshTimer = Timer(const Duration(seconds: 1), () {
      _liveRefreshTimer = null;
      if (mounted) {
        _dashboardKey.currentState?.refresh();
        _alertsKey.currentState?.refresh();
      }
    });
  }

  @override
  void dispose() {
    _liveRefreshTimer?.cancel();
    widget.live.removeListener(_onLiveEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title =
        ['Dashboard', 'Servidores', 'Alertas', 'Configurações'][index];
    final body = index < 2
        ? DashboardScreen(key: _dashboardKey, api: widget.api)
        : index == 2
            ? AlertsScreen(key: _alertsKey, api: widget.api)
            : SettingsScreen(onLogout: widget.onLogout);
    return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) => setState(() => index = value),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
            NavigationDestination(
                icon: Icon(Icons.dns_outlined), label: 'Servidores'),
            NavigationDestination(
                icon: Icon(Icons.notifications_outlined), label: 'Alertas'),
            NavigationDestination(
                icon: Icon(Icons.settings_outlined), label: 'Config.'),
          ],
        ));
  }
}
