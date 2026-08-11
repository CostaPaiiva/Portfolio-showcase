import 'package:flutter/material.dart';
import '../core/app_config.dart';
import '../models/alert.dart';
import '../models/server.dart';
import '../services/api_service.dart';
import '../widgets/metric_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.api});
  final ApiService api;
  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  ServerInfo? server;
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
    if (mounted && server == null) setState(() => loading = true);
    try {
      final result = await Future.wait([
        widget.api.getServer(AppConfig.primaryServerId),
        widget.api.alerts()
      ]);
      if (mounted)
        setState(() {
          server = result[0] as ServerInfo;
          alerts = (result[1] as List<AlertInfo>)
              .where((item) => item.serverId == AppConfig.primaryServerId)
              .toList();
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

  String _bytes(int value) {
    if (value < 1024) return '$value B';
    if (value < 1024 * 1024) return '${(value / 1024).toStringAsFixed(1)} KB';
    if (value < 1024 * 1024 * 1024)
      return '${(value / 1048576).toStringAsFixed(1)} MB';
    return '${(value / 1073741824).toStringAsFixed(1)} GB';
  }

  String _uptime(int seconds) =>
      '${seconds ~/ 86400}d ${(seconds % 86400) ~/ 3600}h ${(seconds % 3600) ~/ 60}m';

  @override
  Widget build(BuildContext context) {
    if (loading && server == null)
      return const Center(child: CircularProgressIndicator());
    if (error != null && server == null)
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(error!),
        const SizedBox(height: 12),
        FilledButton(onPressed: refresh, child: const Text('Tentar novamente'))
      ]));
    final current = server!;
    final metric = current.metric;
    final running = current.containers
        .where((item) => item.state.toLowerCase() == 'running')
        .length;
    return RefreshIndicator(
        onRefresh: refresh,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Row(children: [
            Icon(Icons.circle,
                size: 13,
                color: current.agentStatus == 'online'
                    ? Colors.green
                    : Colors.red),
            const SizedBox(width: 8),
            Text(current.agentStatus == 'online' ? 'Online' : 'Offline',
                style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            IconButton(onPressed: refresh, icon: const Icon(Icons.refresh))
          ]),
          Text(current.hostname ?? current.id,
              style: Theme.of(context).textTheme.headlineSmall),
          Text(
              '${current.os ?? 'Sistema não informado'} • ${current.arch ?? 'Arquitetura não informada'}'),
          if (metric != null) ...[
            const SizedBox(height: 16),
            MetricCard(
                title: 'CPU',
                value: '${metric.cpuPercent.toStringAsFixed(1)}%',
                percent: metric.cpuPercent),
            const SizedBox(height: 8),
            MetricCard(
                title: 'RAM',
                value: '${metric.ram.usedPercent.toStringAsFixed(1)}%',
                percent: metric.ram.usedPercent,
                subtitle:
                    '${_bytes(metric.ram.usedBytes)} / ${_bytes(metric.ram.totalBytes)}'),
            if (metric.disks.isNotEmpty) ...[
              const SizedBox(height: 8),
              MetricCard(
                  title: 'Disco ${metric.disks.first.mount}',
                  value:
                      '${metric.disks.first.usedPercent.toStringAsFixed(1)}%',
                  percent: metric.disks.first.usedPercent,
                  subtitle:
                      '${_bytes(metric.disks.first.usedBytes)} / ${_bytes(metric.disks.first.sizeBytes)}')
            ],
            const SizedBox(height: 12),
            Text('Uptime: ${_uptime(metric.uptimeSeconds)}'),
            Text('Rede: ${metric.networks.length} interface(s)'),
          ],
          const SizedBox(height: 16),
          Text('Docker', style: Theme.of(context).textTheme.titleLarge),
          Text(
              '${current.containers.length} containers • $running rodando • ${current.containers.length - running} parados'),
          const SizedBox(height: 16),
          Text('Alertas ativos', style: Theme.of(context).textTheme.titleLarge),
          Text(
              '${alerts.where((item) => item.status == 'open').length} alerta(s)'),
        ]));
  }
}
