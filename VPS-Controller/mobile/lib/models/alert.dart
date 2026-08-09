class AlertInfo {
  final String id;
  final String serverId;
  final String type;
  final String message;
  final String severity;
  final String status;
  final DateTime createdAt;

  const AlertInfo({
    required this.id,
    required this.serverId,
    required this.type,
    required this.message,
    required this.severity,
    required this.status,
    required this.createdAt,
  });

  factory AlertInfo.fromJson(Map<String, dynamic> json) => AlertInfo(
        id: json['id']?.toString() ?? '',
        serverId: json['serverId']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        severity: json['severity']?.toString() ?? 'warning',
        status: json['status']?.toString() ?? 'open',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );
}
