import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alert.dart';
import '../services/api_service.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AlertInfo>>(
      future: context.read<ApiService>().listAlerts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          if (snapshot.hasError) return Center(child: Text('Erro: ${snapshot.error}'));
          return const Center(child: CircularProgressIndicator());
        }
        final alerts = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: alerts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, index) {
            final a = alerts[index];
            return Card(
              child: ListTile(
                leading: Icon(
                  a.severity == 'critical' ? Icons.error : Icons.warning_amber,
                  color: a.severity == 'critical' ? Colors.red : Colors.amber,
                ),
                title: Text(a.type),
                subtitle: Text('${a.serverId}\n${a.message}\n${a.createdAt.toLocal()}'),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
