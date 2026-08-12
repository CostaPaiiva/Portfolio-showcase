import 'package:flutter/material.dart';
import '../core/app_config.dart';
import '../core/app_theme.dart';
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
          title: Text(operation == 'stop'
              ? 'Parar container?'
              : 'Reiniciar container?'),
          content: Text(operation == 'stop'
              ? 'Parar ${container.name} pode deixar aplicações ou serviços indisponíveis.'
              : 'Tem certeza que deseja reiniciar ${container.name}?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                    operation == 'stop' ? 'Parar container' : 'Reiniciar')),
          ],
        ),
      );
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
      return _ErrorState(message: error!, onRetry: refresh);
    final containers = server!.containers;
    final running = containers
        .where((item) => item.state.toLowerCase() == 'running')
        .length;
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
                  Text('DOCKER',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.accentBright,
                          letterSpacing: 1.8,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Containers da VPS',
                      style: Theme.of(context).textTheme.headlineSmall),
                ])),
            IconButton(
                onPressed: refresh,
                tooltip: 'Atualizar',
                icon: const Icon(Icons.refresh)),
          ]),
          const SizedBox(height: 14),
          _DockerOverview(
              total: containers.length,
              running: running,
              stopped: containers.length - running),
          const SizedBox(height: 18),
          Row(children: [
            Text('Seus containers',
                style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            Text('$running online',
                style: const TextStyle(
                    color: AppColors.online, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 10),
          if (containers.isEmpty)
            const Card(
                child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Column(children: [
                      Icon(Icons.inbox_outlined,
                          color: AppColors.muted, size: 38),
                      SizedBox(height: 10),
                      Text('Nenhum container retornado pela API.'),
                      SizedBox(height: 4),
                      Text('Atualize a tela ou verifique o Agent.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.muted))
                    ])))
          else
            for (final container in containers)
              _containerCard(context, container),
        ],
      ),
    );
  }

  Widget _containerCard(BuildContext context, ContainerInfo container) {
    final running = container.state.toLowerCase() == 'running';
    final postgres = container.name.toLowerCase().contains('postgres');
    final busy = _busy.contains(container.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        running ? AppColors.online : AppColors.accentBright)),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(container.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(_statusLabel(container.state),
                      style: TextStyle(
                          color: running ? AppColors.online : AppColors.muted,
                          fontWeight: FontWeight.w600)),
                ])),
            if (postgres)
              const Chip(
                  avatar: Icon(Icons.storage_outlined, size: 16),
                  label: Text('PostgreSQL')),
          ]),
          const SizedBox(height: 12),
          Text(container.image,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall),
          if (container.ports.isNotEmpty ||
              container.cpuPercent != null ||
              container.memoryBytes != null) ...[
            const SizedBox(height: 11),
            Wrap(spacing: 8, runSpacing: 8, children: [
              if (container.ports.isNotEmpty)
                _InfoChip(
                    icon: Icons.swap_vert,
                    text: '${container.ports.length} porta(s)'),
              if (container.cpuPercent != null)
                _InfoChip(
                    icon: Icons.memory_outlined,
                    text: 'CPU ${container.cpuPercent!.toStringAsFixed(1)}%'),
              if (container.memoryBytes != null)
                _InfoChip(
                    icon: Icons.sd_storage_outlined,
                    text: 'RAM ${_bytes(container.memoryBytes!)}'),
            ]),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: OutlinedButton.icon(
                    icon: const Icon(Icons.play_arrow, size: 18),
                    onPressed: busy || running
                        ? null
                        : () => _action(container, 'start'),
                    label: const Text('Start'))),
            const SizedBox(width: 8),
            Expanded(
                child: OutlinedButton.icon(
                    icon: const Icon(Icons.stop_outlined, size: 18),
                    onPressed: busy || !running
                        ? null
                        : () => _action(container, 'stop'),
                    label: const Text('Stop'))),
            const SizedBox(width: 8),
            Expanded(
                child: OutlinedButton.icon(
                    icon: busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.restart_alt, size: 18),
                    onPressed:
                        busy ? null : () => _action(container, 'restart'),
                    label: const Text('Restart'))),
          ]),
        ]),
      ),
    );
  }

  String _statusLabel(String state) {
    final normalized = state.toLowerCase();
    if (normalized == 'running') return 'Running • em execução';
    if (normalized == 'restarting') return 'Restarting • reiniciando';
    if (normalized == 'exited' || normalized == 'stopped')
      return 'Stopped • parado';
    return state.isEmpty ? 'Status não informado' : state;
  }

  String _bytes(int value) {
    if (value < 1024) return '$value B';
    if (value < 1024 * 1024) return '${(value / 1024).toStringAsFixed(1)} KB';
    return '${(value / 1048576).toStringAsFixed(1)} MB';
  }
}

class _DockerOverview extends StatelessWidget {
  const _DockerOverview(
      {required this.total, required this.running, required this.stopped});
  final int total, running, stopped;

  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            _Count(
                label: 'Total',
                value: total.toString(),
                icon: Icons.widgets_outlined,
                color: AppColors.accent),
            _Count(
                label: 'Online',
                value: running.toString(),
                icon: Icons.play_circle_outline,
                color: AppColors.online),
            _Count(
                label: 'Parados',
                value: stopped.toString(),
                icon: Icons.pause_circle_outline,
                color: AppColors.muted),
          ])));
}

class _Count extends StatelessWidget {
  const _Count(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});
  final String label, value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
          child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 5),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.muted)),
      ]));
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
            color: AppColors.cardLight, borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: AppColors.muted),
          const SizedBox(width: 5),
          Text(text, style: Theme.of(context).textTheme.bodySmall)
        ]),
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
          child: Card(
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.cloud_off_outlined,
                        color: AppColors.accentBright, size: 40),
                    const SizedBox(height: 12),
                    const Text('Docker indisponível',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente')),
                  ])))));
}
