class RamMetric {
  final double usedPercent;
  final int totalBytes;
  final int usedBytes;

  const RamMetric({
    required this.usedPercent,
    required this.totalBytes,
    required this.usedBytes,
  });

  factory RamMetric.fromJson(Map<String, dynamic> json) => RamMetric(
        usedPercent: (json['usedPercent'] as num?)?.toDouble() ?? 0,
        totalBytes: (json['totalBytes'] as num?)?.toInt() ?? 0,
        usedBytes: (json['usedBytes'] as num?)?.toInt() ?? 0,
      );
}

class DiskMetric {
  final String mount;
  final double usedPercent;
  final int sizeBytes;
  final int usedBytes;

  const DiskMetric({
    required this.mount,
    required this.usedPercent,
    required this.sizeBytes,
    required this.usedBytes,
  });

  factory DiskMetric.fromJson(Map<String, dynamic> json) => DiskMetric(
        mount: json['mount']?.toString() ?? '?',
        usedPercent: (json['usedPercent'] as num?)?.toDouble() ?? 0,
        sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
        usedBytes: (json['usedBytes'] as num?)?.toInt() ?? 0,
      );
}

class ServerMetric {
  final double cpuPercent;
  final RamMetric ram;
  final List<DiskMetric> disks;
  final int uptimeSeconds;

  const ServerMetric({
    required this.cpuPercent,
    required this.ram,
    required this.disks,
    required this.uptimeSeconds,
  });

  factory ServerMetric.fromJson(Map<String, dynamic> json) => ServerMetric(
        cpuPercent: (json['cpuPercent'] as num?)?.toDouble() ?? 0,
        ram: RamMetric.fromJson((json['ram'] as Map?)?.cast<String, dynamic>() ?? {}),
        disks: ((json['disks'] as List?) ?? const [])
            .map((e) => DiskMetric.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        uptimeSeconds: (json['uptimeSeconds'] as num?)?.toInt() ?? 0,
      );
}

class ContainerInfo {
  final String id;
  final String name;
  final String image;
  final String state;
  final String status;
  final double? cpuPercent;
  final int? memoryBytes;

  const ContainerInfo({
    required this.id,
    required this.name,
    required this.image,
    required this.state,
    required this.status,
    this.cpuPercent,
    this.memoryBytes,
  });

  factory ContainerInfo.fromJson(Map<String, dynamic> json) => ContainerInfo(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        image: json['image']?.toString() ?? '',
        state: json['state']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        cpuPercent: (json['cpuPercent'] as num?)?.toDouble(),
        memoryBytes: (json['memoryBytes'] as num?)?.toInt(),
      );
}

class ServerInfo {
  final String id;
  final String? hostname;
  final String agentStatus;
  final String externalStatus;
  final String? os;
  final String? kernel;
  final String? arch;
  final String? lastHeartbeatAt;
  final ServerMetric? metric;
  final List<ContainerInfo> containers;

  const ServerInfo({
    required this.id,
    required this.hostname,
    required this.agentStatus,
    required this.externalStatus,
    required this.os,
    required this.kernel,
    required this.arch,
    required this.lastHeartbeatAt,
    required this.metric,
    required this.containers,
  });

  factory ServerInfo.fromJson(Map<String, dynamic> json) => ServerInfo(
        id: json['id']?.toString() ?? '',
        hostname: json['hostname']?.toString(),
        agentStatus: json['agentStatus']?.toString() ?? 'unknown',
        externalStatus: json['externalStatus']?.toString() ?? 'unknown',
        os: json['os']?.toString(),
        kernel: json['kernel']?.toString(),
        arch: json['arch']?.toString(),
        lastHeartbeatAt: json['lastHeartbeatAt']?.toString(),
        metric: json['metric'] is Map
            ? ServerMetric.fromJson((json['metric'] as Map).cast<String, dynamic>())
            : null,
        containers: ((json['containers'] as List?) ?? const [])
            .map((e) => ContainerInfo.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
}
