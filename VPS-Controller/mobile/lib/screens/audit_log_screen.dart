import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/api_service.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key, required this.api, this.serverId});
  final ApiService api;
  final String? serverId;

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  List<Map<String, dynamic>> _actions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadActions();
  }

  Future<void> _loadActions() async {
    setState(() => _loading = true);
    try {
      final res = await widget.api.getActions(serverId: widget.serverId);
      if (mounted) {
        setState(() {
          _actions = res;
          _error = null;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '$e';
          _loading = false;
        });
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return AppColors.online;
      case 'failed':
        return AppColors.accentBright;
      case 'running':
        return const Color(0xFF63B3ED);
      case 'pending':
      default:
        return Colors.amberAccent;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Icons.check_circle_outline_rounded;
      case 'failed':
        return Icons.error_outline_rounded;
      case 'running':
        return Icons.sync_rounded;
      case 'pending':
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auditoria & Ações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Atualizar',
            onPressed: _loadActions,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _actions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _actions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 48, color: AppColors.accentBright),
              const SizedBox(height: 12),
              Text('Erro ao carregar log de ações', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(_error!, style: const TextStyle(color: Colors.white54, fontSize: 13), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: _loadActions, child: const Text('Tentar novamente')),
            ],
          ),
        ),
      );
    }

    if (_actions.isEmpty) {
      return const Center(
        child: Text('Nenhuma ação operacional registrada ainda.', style: TextStyle(color: Colors.white54)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadActions,
      color: AppColors.accentBright,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _actions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final action = _actions[index];
          final type = action['type']?.toString() ?? 'ação';
          final target = action['target']?.toString() ?? '';
          final status = action['status']?.toString() ?? 'pending';
          final createdAt = action['createdAt']?.toString() ?? '';
          final result = action['result']?.toString();
          final statusColor = _getStatusColor(status);

          return Card(
            child: ExpansionTile(
              leading: Icon(_getStatusIcon(status), color: statusColor, size: 24),
              title: Text(
                type,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 3),
                  Text(
                    'Alvo: $target',
                    style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(createdAt),
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              children: [
                if (result != null && result.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14171C),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: SelectableText(
                        result,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5, color: Colors.white70),
                      ),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text('Sem detalhes adicionais da execução.', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
