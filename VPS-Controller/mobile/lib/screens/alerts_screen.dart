import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/alert.dart';
import '../services/api_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key, required this.api});
  final ApiService api;

  @override
  State<AlertsScreen> createState() => AlertsScreenState();
}

class AlertsScreenState extends State<AlertsScreen> {
  List<AlertInfo> alerts = [];
  String? error;
  bool loading = true;
  bool _requestActive = false;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    if (_requestActive) return;
    _requestActive = true;
    if (mounted && alerts.isEmpty) setState(() => loading = true);
    try {
      final value = await widget.api.alerts();
      if (mounted)
        setState(() {
          alerts = value;
          error = null;
          loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          error = '$e';
          loading = false;
        });
    } finally {
      _requestActive = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading && alerts.isEmpty)
      return const Center(child: CircularProgressIndicator());
    if (error != null && alerts.isEmpty)
      return _Error(message: error!, onRetry: refresh);
    final active = alerts.where((item) => item.status == 'open').length;
    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('ALERTAS',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.accentBright,
                          letterSpacing: 1.8,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('$active ativos',
                      style: Theme.of(context).textTheme.headlineSmall),
                ])),
            IconButton(
                onPressed: refresh,
                tooltip: 'Atualizar',
                icon: const Icon(Icons.refresh)),
          ]),
          const SizedBox(height: 14),
          if (alerts.isEmpty)
            const Card(
                child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Column(children: [
                      Icon(Icons.check_circle_outline,
                          color: AppColors.online, size: 38),
                      SizedBox(height: 10),
                      Text('Nenhum alerta ativo.')
                    ])))
          else
            for (final alert in alerts) _AlertCard(alert: alert),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});
  final AlertInfo alert;

  @override
  Widget build(BuildContext context) {
    final critical = alert.severity == 'critical';
    final open = alert.status == 'open';
    final color = open
        ? (critical ? AppColors.accentBright : AppColors.warning)
        : AppColors.muted;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Icon(
            open
                ? (critical
                    ? Icons.error_outline
                    : Icons.warning_amber_outlined)
                : Icons.check_circle_outline,
            color: color),
        title: Text(alert.type),
        subtitle: Text('${alert.serverId}\n${alert.message}'),
        isThreeLine: true,
        trailing: Icon(Icons.circle, size: 9, color: color),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off_outlined,
                color: AppColors.accentBright, size: 40),
            const SizedBox(height: 12),
            const Text('Não foi possível carregar os alertas'),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'))
          ])));
}
