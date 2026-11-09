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
      if (mounted) {
        setState(() {
          server = value;
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
    }
  }

  Future<void> _action(ContainerInfo container, String operation) async {
    if (_busy.contains(container.id)) return;
    if (operation != 'start') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            operation == 'stop' ? 'Parar container?' : 'Reiniciar container?',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            operation == 'stop'
                ? 'Parar "${container.name}" pode indisponibilizar a aplicação correspondente.'
                : 'Tem certeza que deseja reiniciar o container "${container.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                    operation == 'stop' ? AppColors.accentBright : AppColors.accent,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(operation == 'stop' ? 'Parar' : 'Reiniciar'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _busy.add(container.id));
    try {
      await widget.api
          .action(AppConfig.primaryServerId, 'docker.$operation', container.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ação "$operation" enviada para ${container.name}'),
            backgroundColor: AppColors.cardLight,
          ),
        );
      }
      await refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: AppColors.accentBright,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy.remove(container.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading && server == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null && server == null) {
      return _ErrorState(message: error!, onRetry: refresh);
    }

    final containers = server!.containers;
    final running = containers
        .where((item) => item.state.toLowerCase() == 'running')
        .length;
    final stopped = containers.length - running;

    return RefreshIndicator(
      onRefresh: refresh,
      color: AppColors.accentBright,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          // Banner de Contadores com Design Moderno
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E2228), Color(0xFF191D24)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                _HeaderStat(
                  icon: Icons.layers_rounded,
                  label: 'Total',
                  value: '${containers.length}',
                  color: AppColors.text,
                ),
                Container(
                  width: 1,
                  height: 38,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                _HeaderStat(
                  icon: Icons.play_circle_fill_rounded,
                  label: 'Em Execução',
                  value: '$running',
                  color: AppColors.online,
                ),
                Container(
                  width: 1,
                  height: 38,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                _HeaderStat(
                  icon: Icons.pause_circle_filled_rounded,
                  label: 'Parados',
                  value: '$stopped',
                  color: stopped > 0 ? AppColors.warning : AppColors.muted,
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Containers Ativos',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '$running online',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.online,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (containers.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    size: 42,
                    color: AppColors.muted,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Nenhum container Docker encontrado.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            )
          else
            for (final item in containers)
              _ContainerCard(
                container: item,
                busy: _busy.contains(item.id),
                onAction: (op) => _action(item, op),
              ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}

class _ContainerCard extends StatelessWidget {
  const _ContainerCard({
    required this.container,
    required this.busy,
    required this.onAction,
  });

  final ContainerInfo container;
  final bool busy;
  final void Function(String) onAction;

  String _cleanName(String raw) =>
      raw.startsWith('/') ? raw.substring(1) : raw;

  @override
  Widget build(BuildContext context) {
    final running = container.state.toLowerCase() == 'running';
    final statusColor = running ? AppColors.online : AppColors.accentBright;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: running
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.accentBright.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.widgets_rounded, size: 18, color: statusColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _cleanName(container.name),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      container.image,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 7, color: statusColor),
                    const SizedBox(width: 5),
                    Text(
                      running ? 'ONLINE' : 'PARADO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            container.status,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: BorderSide(
                      color: running
                          ? AppColors.accentBright.withValues(alpha: 0.4)
                          : AppColors.online.withValues(alpha: 0.4),
                    ),
                  ),
                  icon: busy
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          running ? Icons.stop_rounded : Icons.play_arrow_rounded,
                          size: 16,
                          color: running ? AppColors.accentBright : AppColors.online,
                        ),
                  label: Text(
                    running ? 'Parar' : 'Iniciar',
                    style: TextStyle(
                      color: running ? AppColors.accentBright : AppColors.online,
                      fontSize: 13,
                    ),
                  ),
                  onPressed: busy ? null : () => onAction(running ? 'stop' : 'start'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: busy
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Reiniciar', style: TextStyle(fontSize: 13)),
                  onPressed: busy ? null : () => onAction('restart'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
              const Icon(
                Icons.cloud_off_rounded,
                color: AppColors.accentBright,
                size: 44,
              ),
              const SizedBox(height: 12),
              const Text(
                'Docker Indisponível',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
