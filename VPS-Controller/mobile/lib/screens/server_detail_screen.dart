import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/server.dart';
import '../services/api_service.dart';
import '../widgets/metric_card.dart';

class ServerDetailScreen extends StatefulWidget {
  const ServerDetailScreen({super.key, required this.serverId});
  final String serverId;

  @override
  State<ServerDetailScreen> createState() => _ServerDetailScreenState();
}

class _ServerDetailScreenState extends State<ServerDetailScreen> {
  late Future<ServerInfo> future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    future = context.read<ApiService>().getServer(widget.serverId);
  }

  String bytes(int value) {
    final gb = value / 1024 / 1024 / 1024;
    return '${gb.toStringAsFixed(1)} GB';
  }

  String uptime(int seconds) {
    final d = Duration(seconds: seconds);
    return '${d.inDays}d ${d.inHours.remainder(24)}h ${d.inMinutes.remainder(60)}m';
  }

  Future<void> action(String type, String target) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar ação'),
        content: Text('$type em $target?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<ApiService>().sendAction(
          serverId: widget.serverId,
          type: type,
          target: target,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ação enviada para o agente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.serverId)),
      body: FutureBuilder<ServerInfo>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) return Center(child: Text('Erro: ${snapshot.error}'));
            return const Center(child: CircularProgressIndicator());
          }
          final server = snapshot.data!;
          final metric = server.metric;
          final rootDisk = metric?.disks.isNotEmpty == true ? metric!.disks.first : null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                server.hostname ?? server.id,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text('${server.os ?? ''} • ${server.kernel ?? ''} • ${server.arch ?? ''}'),
              const SizedBox(height: 18),
              if (metric != null) ...[
                MetricCard(
                  title: 'CPU',
                  value: '${metric.cpuPercent.toStringAsFixed(1)}%',
                  percent: metric.cpuPercent,
                  subtitle: 'Uptime ${uptime(metric.uptimeSeconds)}',
                ),
                const SizedBox(height: 12),
                MetricCard(
                  title: 'RAM',
                  value: '${metric.ram.usedPercent.toStringAsFixed(1)}%',
                  percent: metric.ram.usedPercent,
                  subtitle: '${bytes(metric.ram.usedBytes)} / ${bytes(metric.ram.totalBytes)}',
                ),
                if (rootDisk != null) ...[
                  const SizedBox(height: 12),
                  MetricCard(
                    title: 'Disco ${rootDisk.mount}',
                    value: '${rootDisk.usedPercent.toStringAsFixed(1)}%',
                    percent: rootDisk.usedPercent,
                    subtitle: '${bytes(rootDisk.usedBytes)} / ${bytes(rootDisk.sizeBytes)}',
                  ),
                ],
              ],
              const SizedBox(height: 24),
              Text('Containers', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final c in server.containers)
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.circle,
                      size: 12,
                      color: c.state == 'running' ? Colors.green : Colors.red,
                    ),
                    title: Text(c.name),
                    subtitle: Text('${c.image}\n${c.status}'),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) => action('docker.$value', c.id),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'start', child: Text('Start')),
                        PopupMenuItem(value: 'restart', child: Text('Restart')),
                        PopupMenuItem(value: 'stop', child: Text('Stop')),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
