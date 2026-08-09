import 'dart:async';
import 'package:flutter/material.dart';
import '../models/server.dart';
import '../services/api_service.dart';
import 'server_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.api});
  final ApiService api;
  @override State<DashboardScreen> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardScreen> {
  List<ServerInfo> servers = [];
  String? error;
  bool loading = true;
  Timer? timer;
  @override void initState() { super.initState(); load(); timer = Timer.periodic(const Duration(seconds: 5), (_) => load(silent: true)); }
  @override void dispose() { timer?.cancel(); super.dispose(); }
  Future<void> load({bool silent = false}) async {
    if (!silent && mounted) setState(() => loading = true);
    try { final result = await widget.api.listServers(); if (mounted) setState(() { servers = result; error = null; loading = false; }); }
    catch (e) { if (mounted) setState(() { error = '$e'; loading = false; }); }
  }
  @override Widget build(BuildContext context) {
    if (loading && servers.isEmpty) return const Center(child: CircularProgressIndicator());
    if (error != null && servers.isEmpty) return Center(child: Text(error!));
    final online = servers.where((s) => s.agentStatus == 'online' || s.externalStatus == 'online').length;
    return RefreshIndicator(onRefresh: load, child: ListView(padding: const EdgeInsets.all(16), children: [
      Text('Visão geral', style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 12),
      Wrap(spacing: 10, runSpacing: 10, children: [_Stat('Servidores', '${servers.length}'), _Stat('Online', '$online'), _Stat('Offline', '${servers.length - online}')]),
      const SizedBox(height: 24),
      for (final server in servers) Card(child: ListTile(
        leading: Icon(Icons.circle, size: 12, color: server.agentStatus == 'online' || server.externalStatus == 'online' ? Colors.green : Colors.red),
        title: Text(server.hostname ?? server.id),
        subtitle: Text('CPU ${server.metric?.cpuPercent.toStringAsFixed(0) ?? '-'}% • RAM ${server.metric?.ram.usedPercent.toStringAsFixed(0) ?? '-'}%'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServerDetailScreen(api: widget.api, serverId: server.id))),
      )),
      if (servers.isEmpty) const Padding(padding: EdgeInsets.only(top: 80), child: Center(child: Text('Nenhuma VPS conectada.'))),
    ]));
  }
}
class _Stat extends StatelessWidget { const _Stat(this.label, this.value); final String label, value; @override Widget build(BuildContext context) => SizedBox(width: 150, child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label), Text(value, style: Theme.of(context).textTheme.headlineSmall)])))); }
