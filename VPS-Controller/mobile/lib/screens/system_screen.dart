import 'package:flutter/material.dart';
import '../core/app_config.dart';
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
    if (error != null) return Center(child: Text(error!));
    final s = server!;
    final m = s.metric;
    return RefreshIndicator(
        onRefresh: refresh,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Text(s.hostname ?? s.id,
              style: Theme.of(context).textTheme.headlineSmall),
          _row('Sistema operacional', s.os),
          _row('Kernel', s.kernel),
          _row('Arquitetura', s.arch),
          if (m != null) ...[
            _row('CPU', '${m.cpuPercent.toStringAsFixed(1)}%'),
            _row('RAM', '${m.ram.usedPercent.toStringAsFixed(1)}%'),
            _row('Uptime', '${m.uptimeSeconds} segundos'),
            const SizedBox(height: 12),
            Text('Discos', style: Theme.of(context).textTheme.titleLarge),
            for (final disk in m.disks)
              _row(disk.mount, '${disk.usedPercent.toStringAsFixed(1)}% usado'),
            const SizedBox(height: 12),
            Text('Interfaces de rede',
                style: Theme.of(context).textTheme.titleLarge),
            for (final network in m.networks)
              _row(network.interfaceName,
                  'RX ${network.rxBytesPerSec.toStringAsFixed(1)} B/s • TX ${network.txBytesPerSec.toStringAsFixed(1)} B/s')
          ]
        ]));
  }

  Widget _row(String label, String? value) => ListTile(
      dense: true,
      title: Text(label),
      trailing: Text(value ?? 'Não informado'));
}
