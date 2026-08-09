import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/server.dart';
import '../services/api_service.dart';
import '../services/live_service.dart';
import 'server_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<ServerInfo>> future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    future = context.read<ApiService>().listServers();
  }

  Future<void> reload() async {
    setState(() => future = context.read<ApiService>().listServers());
    await future;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LiveService>().generation;
    Future.microtask(() {
      if (mounted) setState(() => future = context.read<ApiService>().listServers());
    });

    return RefreshIndicator(
      onRefresh: reload,
      child: FutureBuilder<List<ServerInfo>>(
        future: future,
        builder: (context, snapshot) {
          final servers = snapshot.data ?? const <ServerInfo>[];
          if (snapshot.connectionState == ConnectionState.waiting && servers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError && servers.isEmpty) {
            return ListView(
              children: [
                const SizedBox(height: 120),
                Center(child: Text('Erro: ${snapshot.error}')),
              ],
            );
          }

          final online = servers.where((s) => s.externalStatus == 'online' || s.agentStatus == 'online').length;
          final offline = servers.length - online;
          final avgCpu = servers.isEmpty
              ? 0.0
              : servers.map((s) => s.metric?.cpuPercent ?? 0).reduce((a, b) => a + b) / servers.length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Visão geral', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _Stat(label: 'Servidores', value: '${servers.length}'),
                  _Stat(label: 'Online', value: '$online'),
                  _Stat(label: 'Offline', value: '$offline'),
                  _Stat(label: 'CPU média', value: '${avgCpu.toStringAsFixed(0)}%'),
                ],
              ),
              const SizedBox(height: 24),
              Text('Servidores', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              for (final server in servers)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.circle,
                        size: 14,
                        color: (server.externalStatus == 'online' || server.agentStatus == 'online')
                            ? Colors.green
                            : Colors.red,
                      ),
                      title: Text(server.hostname ?? server.id),
                      subtitle: Text(
                        'CPU ${server.metric?.cpuPercent.toStringAsFixed(0) ?? '-'}% • '
                        'RAM ${server.metric?.ram.usedPercent.toStringAsFixed(0) ?? '-'}%',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ServerDetailScreen(serverId: server.id),
                        ),
                      ),
                    ),
                  ),
                ),
              if (servers.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: Text('Nenhuma VPS enviou heartbeat ainda.'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              const SizedBox(height: 6),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}
