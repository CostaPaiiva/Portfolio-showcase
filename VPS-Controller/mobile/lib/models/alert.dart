class AlertInfo {
  final String id, serverId, type, message, severity, status;
  final DateTime createdAt;
  const AlertInfo(
      {required this.id,
      required this.serverId,
      required this.type,
      required this.message,
      required this.severity,
      required this.status,
      required this.createdAt});
  factory AlertInfo.fromJson(Map<String, dynamic> j) => AlertInfo(
      id: j['id']?.toString() ?? '',
      serverId: j['serverId']?.toString() ?? '',
      type: j['type']?.toString() ?? '',
      message: j['message']?.toString() ?? '',
      severity: j['severity']?.toString() ?? 'warning',
      status: j['status']?.toString() ?? 'open',
      createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ??
          DateTime.now());
}
