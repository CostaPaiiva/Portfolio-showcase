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
    final runningContainers = current.containers
        .where((item) => item.state.toLowerCase() == 'running')
        .length;
    final totalContainers = current.containers.length;
    final activeAlerts = alerts.where((item) => item.status == 'open').length;
    final online = current.agentStatus.toLowerCase() == 'online';
    final primaryDisk = metric != null && metric.disks.isNotEmpty ? metric.disks.first : null;
    final loadAvg = metric != null && metric.loadAverage.isNotEmpty ? metric.loadAverage.first : 0.0;

    return RefreshIndicator(
      onRefresh: refresh,
      color: AppColors.accentBright,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          // Header Moderno com Card Gradiente
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E2228),
                  online ? const Color(0xFF182A22) : const Color(0xFF2D181A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (online ? AppColors.online : AppColors.accentBright)
                    .withValues(alpha: 0.25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.dns_rounded,
                            size: 20,
                            color: online ? AppColors.online : AppColors.accentBright,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'VPS PRINCIPAL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: AppColors.muted,
                              ),
                            ),
                            Text(
                              AppConfig.primaryServerId,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: (online ? AppColors.online : AppColors.accentBright)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (online ? AppColors.online : AppColors.accentBright)
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: online ? AppColors.online : AppColors.accentBright,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            online ? 'ONLINE' : 'OFFLINE',
                            style: TextStyle(
                              color: online ? AppColors.online : AppColors.accentBright,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _QuickStat(
                      icon: Icons.layers_rounded,
                      label: 'Containers',
                      value: '$runningContainers/$totalContainers',
                      color: AppColors.text,
                    ),
                    const SizedBox(width: 16),
                    _QuickStat(
                      icon: Icons.timer_outlined,
                      label: 'Uptime',
                      value: metric != null ? _uptime(metric.uptimeSeconds) : '--',
                      color: AppColors.text,
                    ),
                    const SizedBox(width: 16),
                    _QuickStat(
                      icon: Icons.warning_amber_rounded,
                      label: 'Alertas',
                      value: '$activeAlerts',
                      color: activeAlerts > 0 ? AppColors.accentBright : AppColors.online,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Seção de Recursos
          if (metric != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Métricas em Tempo Real',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Text(
                  'Atualizado ao vivo',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.online,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            MetricCard(
              title: 'Uso de CPU',
              value: '${metric.cpuPercent.toStringAsFixed(1)}%',
              percent: metric.cpuPercent,
              subtitle: 'Carga média: ${loadAvg.toStringAsFixed(2)}',
              icon: Icons.speed_rounded,
            ),
            const SizedBox(height: 10),
            MetricCard(
              title: 'Memória RAM',
              value: '${metric.ram.usedPercent.toStringAsFixed(1)}%',
              percent: metric.ram.usedPercent,
              subtitle:
                  '${_bytes(metric.ram.usedBytes)} usados de ${_bytes(metric.ram.totalBytes)}',
              icon: Icons.memory_rounded,
            ),
            if (primaryDisk != null) ...[
              const SizedBox(height: 10),
              MetricCard(
                title: 'Armazenamento (${primaryDisk.mount})',
                value: '${primaryDisk.usedPercent.toStringAsFixed(1)}%',
                percent: primaryDisk.usedPercent,
                subtitle:
                    '${_bytes(primaryDisk.usedBytes)} usados de ${_bytes(primaryDisk.sizeBytes)}',
                icon: Icons.storage_rounded,
              ),
            ],
            const SizedBox(height: 16),
            _NetworkSummary(networks: metric.networks, rate: _rate),
          ],
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.muted),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.swap_vert_rounded,
                  color: AppColors.accentBright,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Tráfego de Rede',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Text(
                '${networks.length} interface(s)',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _TrafficValue(
                  icon: Icons.arrow_downward_rounded,
                  label: 'Download / RX',
                  value: rate(rx),
                  color: AppColors.online,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TrafficValue(
                  icon: Icons.arrow_upward_rounded,
                  label: 'Upload / TX',
                  value: rate(tx),
                  color: AppColors.accentBright,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrafficValue extends StatelessWidget {
  const _TrafficValue({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ],
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
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  color: AppColors.accentBright,
                  size: 48,
                ),
                const SizedBox(height: 14),
                Text(
                  message,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Verifique sua conexão, o Tailscale e se a VPS está online.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      );
}
