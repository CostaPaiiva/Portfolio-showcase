import 'package:flutter/material.dart';
import '../models/alert.dart';
import '../services/api_service.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key, required this.api});
  final ApiService api;

  @override
  Widget build(BuildContext context) => FutureBuilder<List<AlertInfo>>(
        future: api.alerts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) return const Center(child: Text('Nenhum alerta.'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [for (final alert in snapshot.data!) Card(child: ListTile(
              leading: Icon(alert.severity == 'critical' ? Icons.error : Icons.warning_amber,
                  color: alert.severity == 'critical' ? Colors.red : Colors.amber),
              title: Text(alert.type),
              subtitle: Text('${alert.serverId}\n${alert.message}'),
            ))],
          );
        },
      );
}
