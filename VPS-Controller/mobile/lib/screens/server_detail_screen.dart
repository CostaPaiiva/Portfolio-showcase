import 'package:flutter/material.dart';
import '../models/server.dart';
import '../services/api_service.dart';
import '../widgets/metric_card.dart';

class ServerDetailScreen extends StatefulWidget {
  const ServerDetailScreen({super.key, required this.api, required this.serverId});
  final ApiService api;
  final String serverId;
  @override State<ServerDetailScreen> createState() => _ServerDetailState();
}

class _ServerDetailState extends State<ServerDetailScreen> {
  ServerInfo? server;
  String? error;

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try { final value = await widget.api.getServer(widget.serverId); if (mounted) setState(() => server = value); }
    catch (e) { if (mounted) setState(() => error = '$e'); }
  }
  String _gb(int bytes) => '${(bytes / 1073741824).toStringAsFixed(1)} GB';

  @override
  Widget build(BuildContext context) {
    if (error != null) return Scaffold(appBar: AppBar(), body: Center(child: Text(error!)));
    if (server == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final metric = server!.metric;
    return Scaffold(appBar: AppBar(title: Text(server!.hostname ?? server!.id)), body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('${server!.os ?? ''} • ${server!.kernel ?? ''}'),
        if (metric != null) ...[
          const SizedBox(height: 16),
          MetricCard(title: 'CPU', value: '${metric.cpuPercent.toStringAsFixed(1)}%', percent: metric.cpuPercent),
          const SizedBox(height: 8),
          MetricCard(title: 'RAM', value: '${metric.ram.usedPercent.toStringAsFixed(1)}%', percent: metric.ram.usedPercent,
              subtitle: '${_gb(metric.ram.usedBytes)} / ${_gb(metric.ram.totalBytes)}'),
        ],
        const SizedBox(height: 22),
        Text('Containers', style: Theme.of(context).textTheme.titleLarge),
        for (final container in server!.containers) Card(child: ListTile(
          leading: Icon(Icons.circle, size: 12, color: container.state == 'running' ? Colors.green : Colors.red),
          title: Text(container.name), subtitle: Text('${container.image}\n${container.status}'), isThreeLine: true,
        )),
      ],
    ));
  }
}
