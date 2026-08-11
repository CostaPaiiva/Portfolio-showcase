import 'package:flutter/material.dart';
import '../core/app_config.dart';
import '../models/server.dart';
import '../services/api_service.dart';

class DockerScreen extends StatefulWidget {
  const DockerScreen({super.key, required this.api});
  final ApiService api;
  @override
  State<DockerScreen> createState() => _DockerScreenState();
}

class _DockerScreenState extends State<DockerScreen> {
  ServerInfo? server;
  String? error;
  bool loading = true;
  final Set<String> _busy = {};

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    if (mounted && server == null) setState(() => loading = true);
    try {
      final value = await widget.api.getServer(AppConfig.primaryServerId);
      if (mounted)
        setState(() {
          server = value;
          error = null;
          loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          error = '$e';
          loading = false;
        });
    }
  }

  Future<void> _action(ContainerInfo container, String operation) async {
    if (_busy.contains(container.id)) return;
    if (operation != 'start') {
      final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                  title: Text(
                      '${operation == 'stop' ? 'Parar' : 'Reiniciar'} container?'),
                  content: Text(container.name),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar')),
                    FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Confirmar'))
                  ]));
      if (confirmed != true) return;
    }
    setState(() => _busy.add(container.id));
    try {
      await widget.api
          .action(AppConfig.primaryServerId, 'docker.$operation', container.id);
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Ação enviada.')));
      await refresh();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _busy.remove(container.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading && server == null)
      return const Center(child: CircularProgressIndicator());
    if (error != null && server == null)
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(error!),
        FilledButton(onPressed: refresh, child: const Text('Tentar novamente'))
      ]));
    final containers = server!.containers;
    return RefreshIndicator(
        onRefresh: refresh,
        child: ListView(padding: const EdgeInsets.all(12), children: [
          Row(children: [
            Text('${containers.length} containers',
                style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            IconButton(onPressed: refresh, icon: const Icon(Icons.refresh))
          ]),
          if (containers.isEmpty)
            const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                    child: Text('Nenhum container retornado pela API.'))),
          for (final container in containers)
            _containerCard(context, container),
        ]));
  }

  Widget _containerCard(BuildContext context, ContainerInfo container) {
    final running = container.state.toLowerCase() == 'running';
    final postgres = container.name.toLowerCase().contains('postgres');
    final busy = _busy.contains(container.id);
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.circle,
                    size: 12, color: running ? Colors.green : Colors.red),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(container.name,
                        style: Theme.of(context).textTheme.titleMedium)),
                if (postgres) const Chip(label: Text('PostgreSQL'))
              ]),
              Text(container.status),
              Text(container.image),
              if (container.ports.isNotEmpty)
                Text('Portas: ${container.ports.join(', ')}'),
              if (container.cpuPercent != null)
                Text('CPU: ${container.cpuPercent!.toStringAsFixed(1)}%'),
              if (container.memoryBytes != null)
                Text('RAM: ${container.memoryBytes} bytes'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: busy || running
                            ? null
                            : () => _action(container, 'start'),
                        child: const Text('Start'))),
                const SizedBox(width: 8),
                Expanded(
                    child: OutlinedButton(
                        onPressed: busy || !running
                            ? null
                            : () => _action(container, 'stop'),
                        child: const Text('Stop'))),
                const SizedBox(width: 8),
                Expanded(
                    child: OutlinedButton(
                        onPressed:
                            busy ? null : () => _action(container, 'restart'),
                        child: busy
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Restart')))
              ]),
            ])));
  }
}
