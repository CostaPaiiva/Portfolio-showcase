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
      if (mounted)
        setState(() {
          server = value;
          loading = false;
          error = null;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          error = '$e';
          loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return _Error(message: error!, onRetry: refresh);
    final item = server!;
    final metric = item.metric;
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
                  Text('SISTEMA',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.accentBright,
                          letterSpacing: 1.8,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(item.hostname ?? item.id,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 3),
                  Text('Inventário e métricas da VPS',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.muted)),
                ])),
            IconButton(
                onPressed: refresh,
                tooltip: 'Atualizar',
                icon: const Icon(Icons.refresh)),
          ]),
          const SizedBox(height: 16),
          _HostCard(server: item),
          if (metric == null) ...[
            const SizedBox(height: 12),
            const _EmptyMetrics(),
          ] else ...[
            const SizedBox(height: 12),
            _ResourceOverview(metric: metric, bytes: _bytes, uptime: _uptime),
            if (metric.loadAverage.isNotEmpty) ...[
              const SizedBox(height: 12),
              _LoadCard(loads: metric.loadAverage),
            ],
            if (metric.disks.isNotEmpty) ...[
              const SizedBox(height: 12),
              _SectionTitle(
                  title: 'Armazenamento',
                  subtitle: '${metric.disks.length} volume(s) reportado(s)'),
              const SizedBox(height: 8),
              for (final disk in metric.disks) ...[
                _DiskCard(disk: disk, bytes: _bytes),
                const SizedBox(height: 10),
              ],
            ],
            if (metric.networks.isNotEmpty) ...[
              const SizedBox(height: 4),
              _SectionTitle(
                  title: 'Interfaces de rede',
                  subtitle: 'Tráfego instantâneo reportado pelo Agent'),
              const SizedBox(height: 8),
              for (final network in metric.networks) ...[
                _NetworkCard(network: network, rate: _rate, bytes: _bytes),
                const SizedBox(height: 10),
              ],
            ],
          ],
        ],
      ),
    );
  }

  String _bytes(int value) {
    if (value < 1024) return '$value B';
    if (value < 1024 * 1024) return '${(value / 1024).toStringAsFixed(1)} KB';
    if (value < 1024 * 1024 * 1024)
      return '${(value / 1048576).toStringAsFixed(1)} MB';
    return '${(value / 1073741824).toStringAsFixed(1)} GB';
  }

  String _rate(double value) {
    if (value < 1024) return '${value.toStringAsFixed(0)} B/s';
    if (value < 1024 * 1024) return '${(value / 1024).toStringAsFixed(1)} KB/s';
    return '${(value / 1048576).toStringAsFixed(1)} MB/s';
  }

  String _uptime(int seconds) =>
      '${seconds ~/ 86400}d ${(seconds % 86400) ~/ 3600}h ${(seconds % 3600) ~/ 60}m';
}

class _HostCard extends StatelessWidget {
  const _HostCard({required this.server});
  final ServerInfo server;

  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.computer_outlined,
                  color: AppColors.accentBright),
              const SizedBox(width: 8),
              Text('Identificação do host',
                  style: Theme.of(context).textTheme.titleMedium)
            ]),
            const SizedBox(height: 12),
            _DetailRow(
                label: 'Sistema operacional',
                value: server.os ?? 'Não informado'),
            _DetailRow(
                label: 'Kernel', value: server.kernel ?? 'Não informado'),
            _DetailRow(
                label: 'Arquitetura', value: server.arch ?? 'Não informado'),
            _DetailRow(label: 'ID monitorado', value: server.id),
          ])));
}

class _ResourceOverview extends StatelessWidget {
  const _ResourceOverview(
      {required this.metric, required this.bytes, required this.uptime});
  final ServerMetric metric;
  final String Function(int) bytes;
  final String Function(int) uptime;

  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.monitor_heart_outlined,
                  color: AppColors.accentBright),
              const SizedBox(width: 8),
              Text('Resumo de recursos',
                  style: Theme.of(context).textTheme.titleMedium)
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                  child: _ResourceValue(
                      label: 'CPU',
                      value: '${metric.cpuPercent.toStringAsFixed(1)}%',
                      icon: Icons.memory_outlined)),
              Expanded(
                  child: _ResourceValue(
                      label: 'RAM',
                      value: '${metric.ram.usedPercent.toStringAsFixed(1)}%',
                      icon: Icons.sd_storage_outlined)),
              Expanded(
                  child: _ResourceValue(
                      label: 'Uptime',
                      value: uptime(metric.uptimeSeconds),
                      icon: Icons.schedule_outlined)),
            ]),
            const SizedBox(height: 14),
            Text(
                '${bytes(metric.ram.usedBytes)} de ${bytes(metric.ram.totalBytes)} de RAM em uso',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.muted)),
          ])));
}

class _ResourceValue extends StatelessWidget {
  const _ResourceValue(
      {required this.label, required this.value, required this.icon});
  final String label, value;
  final IconData icon;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: AppColors.muted, size: 19),
        const SizedBox(height: 7),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.muted))
      ]);
}

class _LoadCard extends StatelessWidget {
  const _LoadCard({required this.loads});
  final List<double> loads;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.speed_outlined, color: AppColors.accentBright),
              const SizedBox(width: 8),
              Text('Carga do sistema',
                  style: Theme.of(context).textTheme.titleMedium)
            ]),
            const SizedBox(height: 5),
            Text('Média de carga fornecida pelo sistema operacional.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.muted)),
            const SizedBox(height: 13),
            Row(children: [
              for (var i = 0; i < loads.length && i < 3; i++)
                Expanded(
                    child: _ResourceValue(
                        label: ['1 min', '5 min', '15 min'][i],
                        value: loads[i].toStringAsFixed(2),
                        icon: Icons.timeline_outlined))
            ]),
          ])));
}

class _DiskCard extends StatelessWidget {
  const _DiskCard({required this.disk, required this.bytes});
  final DiskMetric disk;
  final String Function(int) bytes;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.storage_outlined, color: AppColors.accentBright),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(disk.mount,
                      style: Theme.of(context).textTheme.titleMedium)),
              Text('${disk.usedPercent.toStringAsFixed(1)}%',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700))
            ]),
            const SizedBox(height: 10),
            ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                    value: (disk.usedPercent.clamp(0, 100) / 100).toDouble(),
                    minHeight: 6,
                    backgroundColor: Colors.white12,
                    color: disk.usedPercent >= 90
                        ? AppColors.accentBright
                        : AppColors.accent)),
            const SizedBox(height: 10),
            Text('${bytes(disk.usedBytes)} usados de ${bytes(disk.sizeBytes)}',
                style: Theme.of(context).textTheme.bodyMedium),
          ])));
}

class _NetworkCard extends StatelessWidget {
  const _NetworkCard(
      {required this.network, required this.rate, required this.bytes});
  final NetworkMetric network;
  final String Function(double) rate;
  final String Function(int) bytes;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.lan_outlined, color: AppColors.accentBright),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(network.interfaceName,
                      style: Theme.of(context).textTheme.titleMedium)),
              Text('Interface',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.muted))
            ]),
            const SizedBox(height: 13),
            Row(children: [
              Expanded(
                  child: _DetailMetric(
                      icon: Icons.arrow_downward,
                      label: 'Recebendo',
                      value: rate(network.rxBytesPerSec))),
              Expanded(
                  child: _DetailMetric(
                      icon: Icons.arrow_upward,
                      label: 'Enviando',
                      value: rate(network.txBytesPerSec)))
            ]),
            const SizedBox(height: 12),
            Text(
                'Total: RX ${bytes(network.rxBytes)} • TX ${bytes(network.txBytes)}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.muted)),
          ])));
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 7),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.muted)),
          Text(value, style: Theme.of(context).textTheme.titleSmall)
        ])
      ]);
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.muted))),
        const SizedBox(width: 14),
        Flexible(child: Text(value, textAlign: TextAlign.right))
      ]));
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});
  final String title, subtitle;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 2),
        Text(subtitle,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.muted))
      ]);
}

class _EmptyMetrics extends StatelessWidget {
  const _EmptyMetrics();
  @override
  Widget build(BuildContext context) => const Card(
      child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(children: [
            Icon(Icons.query_stats_outlined, color: AppColors.muted, size: 36),
            SizedBox(height: 10),
            Text('Métricas ainda não foram recebidas do Agent.'),
            SizedBox(height: 4),
            Text('Atualize a tela após confirmar que o Agent está online.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted))
          ])));
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
            Text('VPS indisponível',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'))
          ])));
}
