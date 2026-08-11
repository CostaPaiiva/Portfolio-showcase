import 'package:flutter/material.dart';
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
      if (mounted)
        setState(() {
          alerts = value;
          error = null;
          loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          error = '$e';
          loading = false;
        });
    } finally {
      _requestActive = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading && alerts.isEmpty)
      return const Center(child: CircularProgressIndicator());
    if (error != null && alerts.isEmpty)
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(error!),
        const SizedBox(height: 12),
        FilledButton(onPressed: refresh, child: const Text('Tentar novamente'))
      ]));
    return RefreshIndicator(
        onRefresh: refresh,
        child: alerts.isEmpty
            ? ListView(children: const [
                SizedBox(height: 160),
                Center(child: Text('Nenhum alerta.'))
              ])
            : ListView(padding: const EdgeInsets.all(16), children: [
                for (final alert in alerts)
                  Card(
                      child: ListTile(
                    leading: Icon(
                        alert.severity == 'critical'
                            ? Icons.error
                            : Icons.warning_amber,
                        color: alert.severity == 'critical'
                            ? Colors.red
                            : Colors.amber),
                    title: Text(alert.type),
                    subtitle: Text('${alert.serverId}\n${alert.message}'),
                  )),
              ]));
  }
}
