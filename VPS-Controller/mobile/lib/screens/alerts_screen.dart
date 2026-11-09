import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/alert.dart';
import '../services/api_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key, required this.api});
  final ApiService api;

  @override
  State<AlertsScreen> createState() => AlertsScreenState();
}

class AlertsScreenState extends State<AlertsScreen> {
  List<AlertInfo> alerts = [];
  String? error;
  bool loading = true;
  bool _requestActive = false;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    if (_requestActive) return;
    _requestActive = true;
    if (mounted && alerts.isEmpty) setState(() => loading = true);
    try {
      final value = await widget.api.alerts();
      if (mounted) {
        setState(() {
          alerts = value;
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
    } finally {
      _requestActive = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading && alerts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null && alerts.isEmpty) {
      return _ErrorState(message: error!, onRetry: refresh);
    }

    final activeAlerts = alerts.where((item) => item.status == 'open').toList();
    final resolvedAlerts = alerts.where((item) => item.status != 'open').toList();

    return RefreshIndicator(
      onRefresh: refresh,
      color: AppColors.accentBright,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          // Banner de Status dos Alertas
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E2228),
                  activeAlerts.isNotEmpty ? const Color(0xFF2E1719) : const Color(0xFF182A22),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: (activeAlerts.isNotEmpty ? AppColors.accentBright : AppColors.online)
                    .withValues(alpha: 0.25),
              ),
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (activeAlerts.isNotEmpty ? AppColors.accentBright : AppColors.online)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    activeAlerts.isNotEmpty
                        ? Icons.warning_rounded
                        : Icons.check_circle_rounded,
                    color: activeAlerts.isNotEmpty ? AppColors.accentBright : AppColors.online,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeAlerts.isNotEmpty
                            ? '${activeAlerts.length} ALERTA(S) ATIVO(S)'
                            : 'SISTEMA ESTÁVEL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: activeAlerts.isNotEmpty ? AppColors.accentBright : AppColors.online,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        activeAlerts.isNotEmpty
                            ? 'Atenção necessária em incidentes da VPS'
                            : 'Nenhum incidente crítico detectado',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Seção de Alertas Abertos
          if (activeAlerts.isNotEmpty) ...[
            Text(
              'Incidentes Pendentes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            for (final alert in activeAlerts) _AlertCard(alert: alert),
            const SizedBox(height: 20),
          ],

          // Seção de Alertas Resolvidos
          if (resolvedAlerts.isNotEmpty) ...[
            Text(
              'Histórico Resolvido',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            for (final alert in resolvedAlerts) _AlertCard(alert: alert),
          ],

          if (alerts.isEmpty)
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
                    Icons.shield_rounded,
                    size: 44,
                    color: AppColors.online,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Tudo limpo!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Nenhum alerta recente registrado no servidor.',
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});
  final AlertInfo alert;

  @override
  Widget build(BuildContext context) {
    final isOpen = alert.status == 'open';
    final isCritical = alert.severity.toLowerCase() == 'critical';

    final Color badgeColor = isOpen
        ? (isCritical ? AppColors.accentBright : AppColors.warning)
        : AppColors.muted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOpen ? badgeColor.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isOpen
                  ? (isCritical ? Icons.error_outline_rounded : Icons.warning_amber_rounded)
                  : Icons.check_circle_outline_rounded,
              color: badgeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      alert.type,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isOpen ? (isCritical ? 'CRÍTICO' : 'AVISO') : 'RESOLVIDO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Servidor: ${alert.serverId}',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 6),
                Text(
                  alert.message,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    color: isOpen ? AppColors.text : AppColors.muted,
                  ),
                ),
              ],
            ),
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
                'Falha ao carregar alertas',
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
