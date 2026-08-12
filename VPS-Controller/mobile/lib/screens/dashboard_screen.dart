import 'package:flutter/material.dart';
import '../core/app_config.dart';
import '../core/app_theme.dart';
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
        widget.api.alerts(),
      ]);
      if (mounted) {
        setState(() {
          server = result[0] as ServerInfo;
          alerts = (result[1] as List<AlertInfo>)
              .where((item) => item.serverId == AppConfig.primaryServerId)
              .toList();
          error = null;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = '$e';
          loading = false;
        });
      }
    } finally {
      _requestActive = false;
    }
  }

  String _bytes(int value) {
    if (value < 1024) return '$value B';
    if (value < 1024 * 1024) return '${(value / 1024).toStringAsFixed(1)} KB';
    if (value < 1024 * 1024 * 1024) {
      return '${(value / 1048576).toStringAsFixed(1)} MB';
    }
    return '${(value / 1073741824).toStringAsFixed(1)} GB';
  }

  String _uptime(int seconds) =>
      '${seconds ~/ 86400}d ${(seconds % 86400) ~/ 3600}h ${(seconds % 3600) ~/ 60}m';

  String _rate(double value) {
    if (value < 1024) return '${value.toStringAsFixed(0)} B/s';
    if (value < 1024 * 1024) return '${(value / 1024).toStringAsFixed(1)} KB/s';
    return '${(value / 1048576).toStringAsFixed(1)} MB/s';
  }

  @override
  Widget build(BuildContext context) {
    if (loading && server == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null && server == null) {
      return _ErrorState(
          message: 'VPS indisponível', details: error!, onRetry: refresh);
    }

    final current = server!;
    final metric = current.metric;
    final running = current.containers
        .where((item) => item.state.toLowerCase() == 'running')
        .length;
    final activeAlerts = alerts.where((item) => item.status == 'open').length;
    final online = current.agentStatus.toLowerCase() == 'online';

    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          Text('VPS CONTROLLER',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.accentBright,
                    letterSpacing: 1.8,
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(AppConfig.primaryServerId,
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              Icon(Icons.circle,
                  size: 11,
                  color: online ? AppColors.online : AppColors.accentBright),
              const SizedBox(width: 7),
              Text(online ? 'ONLINE' : 'OFFLINE',
                  style: TextStyle(
                    color: online ? AppColors.online : AppColors.accentBright,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
                  )),
            ],
          ),
          const SizedBox(height: 16),
          _ServerHero(server: current, online: online, onRefresh: refresh),
          const SizedBox(height: 12),
          _ConnectionOverview(
            agentOnline: online,
            externalStatus: current.externalStatus,
            lastHeartbeatAt: current.lastHeartbeatAt,
          ),
          if (metric != null) ...[
            const SizedBox(height: 18),
            Text('Recursos', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth >= 620 ? 4 : 2;
              final width =
                  (constraints.maxWidth - (columns - 1) * 10) / columns;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                      width: width,
                      child: MetricCard(
                          title: 'CPU',
                          value: '${metric.cpuPercent.toStringAsFixed(1)}%',
                          percent: metric.cpuPercent,
                          icon: Icons.memory_outlined)),
                  SizedBox(
                      width: width,
                      child: MetricCard(
                          title: 'RAM',
                          value:
                              '${metric.ram.usedPercent.toStringAsFixed(1)}%',
                          percent: metric.ram.usedPercent,
                          subtitle:
                              '${_bytes(metric.ram.usedBytes)} / ${_bytes(metric.ram.totalBytes)}',
                          icon: Icons.sd_storage_outlined)),
                  if (metric.disks.isNotEmpty)
                    SizedBox(
                        width: width,
                        child: MetricCard(
                            title: 'Disco ${metric.disks.first.mount}',
                            value:
                                '${_bytes(metric.disks.first.usedBytes)} / ${_bytes(metric.disks.first.sizeBytes)}',
                            percent: metric.disks.first.usedPercent,
                            subtitle:
                                '${metric.disks.first.usedPercent.toStringAsFixed(1)}% usado',
                            icon: Icons.storage_outlined)),
                  SizedBox(
                      width: width,
                      child: MetricCard(
                          title: 'Uptime',
                          value: _uptime(metric.uptimeSeconds),
                          percent: 0,
                          icon: Icons.schedule_outlined)),
                ],
              );
            }),
          ],
          const SizedBox(height: 18),
          if (metric != null && metric.networks.isNotEmpty) ...[
            _NetworkSummary(networks: metric.networks, rate: _rate),
            const SizedBox(height: 12),
          ],
          _SummaryCard(
            icon: Icons.dns_outlined,
            title: 'Docker',
            value: '${current.containers.length} containers',
            detail:
                '$running rodando • ${current.containers.length - running} parados',
          ),
          const SizedBox(height: 10),
          _SummaryCard(
            icon: Icons.notifications_none_outlined,
            title: 'Alertas ativos',
            value: '$activeAlerts',
            detail: activeAlerts == 1
                ? 'Alerta requer atenção'
                : 'Alertas requerem atenção',
            critical: activeAlerts > 0,
          ),
        ],
      ),
    );
  }
}

class _ServerHero extends StatelessWidget {
  const _ServerHero(
      {required this.server, required this.online, required this.onRefresh});
  final ServerInfo server;
  final bool online;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.dns_outlined,
                  color: AppColors.accentBright, size: 27),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(server.hostname ?? server.id,
                      style: Theme.of(context).textTheme.titleLarge)),
              IconButton(
                  onPressed: onRefresh,
                  tooltip: 'Atualizar',
                  icon: const Icon(Icons.refresh)),
            ]),
            const Divider(height: 22),
            Text(server.os ?? 'Sistema não informado',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 4),
            Text(
                "${server.arch ?? 'Arquitetura não informada'} • ${server.kernel ?? 'Kernel não informado'}",
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Row(children: [
              Icon(
                  online ? Icons.shield_outlined : Icons.warning_amber_outlined,
                  color: online ? AppColors.online : AppColors.accentBright,
                  size: 18),
              const SizedBox(width: 7),
              Text(online ? 'Comunicação normal' : 'Sem comunicação recente'),
            ]),
          ]),
        ),
      );
}

class _ConnectionOverview extends StatelessWidget {
  const _ConnectionOverview({
    required this.agentOnline,
    required this.externalStatus,
    required this.lastHeartbeatAt,
  });

  final bool agentOnline;
  final String externalStatus;
  final String? lastHeartbeatAt;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Wrap(
            spacing: 18,
            runSpacing: 10,
            children: [
              _StatusItem(
                icon: Icons.smart_toy_outlined,
                label: 'Agent',
                value: agentOnline ? 'Online' : 'Offline',
                color: agentOnline ? AppColors.online : AppColors.accentBright,
              ),
              _StatusItem(
                icon: Icons.public_outlined,
                label: 'Monitor',
                value: externalStatus == 'online' ? 'Online' : externalStatus,
                color: externalStatus == 'online'
                    ? AppColors.online
                    : AppColors.muted,
              ),
              _StatusItem(
                icon: Icons.access_time_outlined,
                label: 'Último heartbeat',
                value: _timeLabel(lastHeartbeatAt),
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      );

  String _timeLabel(String? value) {
    if (value == null) return 'Não informado';
    final date = DateTime.tryParse(value)?.toLocal();
    if (date == null) return 'Não informado';
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return 'Hoje às $hour:$minute';
  }
}

class _StatusItem extends StatelessWidget {
  const _StatusItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.muted)),
              Text(value,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      );
}

class _NetworkSummary extends StatelessWidget {
  const _NetworkSummary({required this.networks, required this.rate});
  final List<NetworkMetric> networks;
  final String Function(double) rate;

  @override
  Widget build(BuildContext context) {
    final rx =
        networks.fold<double>(0, (total, item) => total + item.rxBytesPerSec);
    final tx =
        networks.fold<double>(0, (total, item) => total + item.txBytesPerSec);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.lan_outlined,
                color: AppColors.accentBright, size: 20),
            const SizedBox(width: 8),
            Text('Rede', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Text('${networks.length} interface(s)',
                style: Theme.of(context).textTheme.bodySmall),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: _TrafficValue(
                    icon: Icons.arrow_downward,
                    label: 'Recebendo',
                    value: rate(rx))),
            Expanded(
                child: _TrafficValue(
                    icon: Icons.arrow_upward,
                    label: 'Enviando',
                    value: rate(tx))),
          ]),
        ]),
      ),
    );
  }
}

class _TrafficValue extends StatelessWidget {
  const _TrafficValue(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: AppColors.accent, size: 18),
        const SizedBox(width: 7),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ]),
      ]);
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard(
      {required this.icon,
      required this.title,
      required this.value,
      required this.detail,
      this.critical = false});
  final IconData icon;
  final String title, value, detail;
  final bool critical;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          leading: Icon(icon,
              color: critical ? AppColors.accentBright : AppColors.accent),
          title: Text(title),
          subtitle: Text(detail),
          trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
        ),
      );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState(
      {required this.message, required this.details, required this.onRetry});
  final String message, details;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.cloud_off_outlined,
                    color: AppColors.accentBright, size: 42),
                const SizedBox(height: 12),
                Text(message, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text(
                    'Verifique sua conexão, o Tailscale e se a VPS está online.',
                    textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text(details,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 18),
                FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente')),
              ]),
            ),
          ),
        ),
      );
}
