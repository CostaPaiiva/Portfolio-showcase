import 'package:flutter/material.dart';
import '../core/app_config.dart';
import '../core/app_theme.dart';
import '../models/server.dart';
import '../services/api_service.dart';

class SystemScreen extends StatefulWidget {
  const SystemScreen({super.key, required this.api});
  final ApiService api;

  @override
  State<SystemScreen> createState() => _SystemScreenState();
}

class _SystemScreenState extends State<SystemScreen> {
  ServerInfo? server;
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    try {
      final value = await widget.api.getServer(AppConfig.primaryServerId);
      if (mounted) {
        setState(() {
          server = value;
          loading = false;
          error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = '$e';
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return _ErrorState(message: error!, onRetry: refresh);

    final item = server!;
    final metric = item.metric;
    final isOnline = item.agentStatus.toLowerCase() == 'online';

    return RefreshIndicator(
      onRefresh: refresh,
      color: AppColors.accentBright,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          // Banner de Identificação do Servidor
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E2228), Color(0xFF16191E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
                            color: AppColors.accentBright.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.memory_rounded,
                            size: 20,
                            color: AppColors.accentBright,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'HARDWARE & KERNEL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.4,
                                color: AppColors.muted,
                              ),
                            ),
                            Text(
                              item.hostname ?? item.id,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isOnline ? AppColors.online : AppColors.accentBright)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (isOnline ? AppColors.online : AppColors.accentBright)
                              .withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 7,
                            color: isOnline ? AppColors.online : AppColors.accentBright,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isOnline ? 'ONLINE' : 'OFFLINE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isOnline ? AppColors.online : AppColors.accentBright,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SpecsGrid(server: item),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (metric == null) ...[
            const _EmptyMetrics(),
          ] else ...[
            // Visão de Recursos em Cartões Elegantes
            Row(
              children: [
                Expanded(
                  child: _MiniMetricCard(
                    title: 'CPU Instantânea',
                    value: '${metric.cpuPercent.toStringAsFixed(1)}%',
                    icon: Icons.speed_rounded,
                    color: metric.cpuPercent > 85
                        ? AppColors.accentBright
                        : AppColors.online,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniMetricCard(
                    title: 'Memória Usada',
                    value: '${metric.ram.usedPercent.toStringAsFixed(1)}%',
                    icon: Icons.developer_board_rounded,
                    color: metric.ram.usedPercent > 85
                        ? AppColors.warning
                        : AppColors.text,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (metric.loadAverage.isNotEmpty)
              _LoadAverageCard(loads: metric.loadAverage),

            if (metric.disks.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discos & Partições',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '${metric.disks.length} partição(ões)',
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final disk in metric.disks)
                _DiskItemCard(disk: disk, bytes: _bytes),
            ],

            if (metric.networks.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Interfaces de Rede',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '${metric.networks.length} interface(s)',
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final network in metric.networks)
                _NetworkItemCard(network: network, rate: _rate, bytes: _bytes),
            ],
          ],
        ],
      ),
    );
  }

  String _bytes(int value) {
    if (value < 1024) return '$value B';
    if (value < 1024 * 1024) return '${(value / 1024).toStringAsFixed(1)} KB';
    if (value < 1024 * 1024 * 1024) {
      return '${(value / 1048576).toStringAsFixed(1)} MB';
    }
    return '${(value / 1073741824).toStringAsFixed(1)} GB';
  }

  String _rate(double value) {
    if (value < 1024) return '${value.toStringAsFixed(0)} B/s';
    if (value < 1024 * 1024) return '${(value / 1024).toStringAsFixed(1)} KB/s';
    return '${(value / 1048576).toStringAsFixed(1)} MB/s';
  }
}

class _SpecsGrid extends StatelessWidget {
  const _SpecsGrid({required this.server});
  final ServerInfo server;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        children: [
          _SpecLine(
            label: 'Sistema Operacional',
            value: server.os ?? 'Linux',
            icon: Icons.computer_rounded,
          ),
          Divider(color: Colors.white.withValues(alpha: 0.05), height: 16),
          _SpecLine(
            label: 'Kernel Linux',
            value: server.kernel ?? 'Não informado',
            icon: Icons.terminal_rounded,
          ),
          Divider(color: Colors.white.withValues(alpha: 0.05), height: 16),
          _SpecLine(
            label: 'Arquitetura',
            value: server.arch ?? 'x86_64',
            icon: Icons.settings_suggest_rounded,
          ),
        ],
      ),
    );
  }
}

class _SpecLine extends StatelessWidget {
  const _SpecLine({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label, value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.muted),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.muted),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}

class _MiniMetricCard extends StatelessWidget {
  const _MiniMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title, value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadAverageCard extends StatelessWidget {
  const _LoadAverageCard({required this.loads});
  final List<double> loads;

  @override
  Widget build(BuildContext context) {
    final l1 = loads.isNotEmpty ? loads[0].toStringAsFixed(2) : '-';
    final l5 = loads.length > 1 ? loads[1].toStringAsFixed(2) : '-';
    final l15 = loads.length > 2 ? loads[2].toStringAsFixed(2) : '-';

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
          const Row(
            children: [
              Icon(Icons.query_stats_rounded, size: 18, color: AppColors.accentBright),
              SizedBox(width: 8),
              Text(
                'Carga Média do Sistema (Load Average)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _LoadValue(label: '1 minuto', value: l1),
              _LoadValue(label: '5 minutos', value: l5),
              _LoadValue(label: '15 minutos', value: l15),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadValue extends StatelessWidget {
  const _LoadValue({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _DiskItemCard extends StatelessWidget {
  const _DiskItemCard({required this.disk, required this.bytes});
  final DiskMetric disk;
  final String Function(int) bytes;

  @override
  Widget build(BuildContext context) {
    final critical = disk.usedPercent >= 90;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: critical
              ? AppColors.accentBright.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.storage_rounded,
                size: 18,
                color: critical ? AppColors.accentBright : AppColors.accent,
              ),
              const SizedBox(width: 8),
              Text(
                disk.mount,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${disk.usedPercent.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: critical ? AppColors.accentBright : AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${bytes(disk.usedBytes)} usados de ${bytes(disk.sizeBytes)}',
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: (disk.usedPercent.clamp(0, 100) / 100).toDouble(),
              backgroundColor: Colors.white12,
              color: critical ? AppColors.accentBright : AppColors.online,
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkItemCard extends StatelessWidget {
  const _NetworkItemCard({
    required this.network,
    required this.rate,
    required this.bytes,
  });

  final NetworkMetric network;
  final String Function(double) rate;
  final String Function(int) bytes;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
              const Icon(Icons.lan_rounded, size: 18, color: AppColors.online),
              const SizedBox(width: 8),
              Text(
                network.interfaceName,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Ativa',
                  style: TextStyle(fontSize: 11, color: AppColors.online),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.arrow_downward_rounded, size: 16, color: AppColors.online),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Download', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                        Text(
                          rate(network.rxBytesPerSec),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.arrow_upward_rounded, size: 16, color: AppColors.accentBright),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Upload', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                        Text(
                          rate(network.txBytesPerSec),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyMetrics extends StatelessWidget {
  const _EmptyMetrics();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Icon(Icons.query_stats_rounded, color: AppColors.muted, size: 36),
            SizedBox(height: 10),
            Text('Aguardando métricas do Agent...'),
          ],
        ),
      );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, color: AppColors.accentBright, size: 44),
              const SizedBox(height: 12),
              const Text('VPS Indisponível', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
}
