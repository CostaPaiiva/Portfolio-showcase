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
    final s = server!;
    final m = s.metric;
    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          Text('SISTEMA',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.accentBright,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(s.hostname ?? s.id,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          _InfoCard(
              title: 'Identificação',
              icon: Icons.computer_outlined,
              rows: [
                _InfoRow('Sistema operacional', s.os),
                _InfoRow('Kernel', s.kernel),
                _InfoRow('Arquitetura', s.arch),
              ]),
          if (m != null) ...[
            const SizedBox(height: 12),
            _InfoCard(title: 'Recursos', icon: Icons.tune_outlined, rows: [
              _InfoRow('CPU', '${m.cpuPercent.toStringAsFixed(1)}%'),
              _InfoRow('RAM', '${m.ram.usedPercent.toStringAsFixed(1)}%'),
              _InfoRow('Uptime', _uptime(m.uptimeSeconds)),
            ]),
            if (m.disks.isNotEmpty) ...[
              const SizedBox(height: 12),
              _InfoCard(title: 'Discos', icon: Icons.storage_outlined, rows: [
                for (final disk in m.disks)
                  _InfoRow(disk.mount,
                      '${disk.usedPercent.toStringAsFixed(1)}% usado'),
              ]),
            ],
            if (m.networks.isNotEmpty) ...[
              const SizedBox(height: 12),
              _InfoCard(
                  title: 'Interfaces de rede',
                  icon: Icons.lan_outlined,
                  rows: [
                    for (final network in m.networks)
                      _InfoRow(network.interfaceName,
                          'RX ${network.rxBytesPerSec.toStringAsFixed(1)} B/s • TX ${network.txBytesPerSec.toStringAsFixed(1)} B/s'),
                  ]),
            ],
          ],
        ],
      ),
    );
  }

  String _uptime(int seconds) =>
      '${seconds ~/ 86400}d ${(seconds % 86400) ~/ 3600}h ${(seconds % 3600) ~/ 60}m';
}

class _InfoCard extends StatelessWidget {
  const _InfoCard(
      {required this.title, required this.icon, required this.rows});
  final String title;
  final IconData icon;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(icon, color: AppColors.accentBright, size: 20),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium)
            ]),
            const SizedBox(height: 7),
            for (final row in rows)
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(row.label),
                  trailing: Text(row.value ?? 'Não informado',
                      style: const TextStyle(color: AppColors.muted))),
          ]),
        ),
      );
}

class _InfoRow {
  const _InfoRow(this.label, this.value);
  final String label;
  final String? value;
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
