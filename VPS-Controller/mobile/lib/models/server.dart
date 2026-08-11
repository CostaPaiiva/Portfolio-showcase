class RamMetric {
  final double usedPercent;
  final int totalBytes, usedBytes;
  const RamMetric(this.usedPercent, this.totalBytes, this.usedBytes);
  factory RamMetric.fromJson(Map<String, dynamic> j) => RamMetric(
      (j['usedPercent'] as num?)?.toDouble() ?? 0,
      (j['totalBytes'] as num?)?.toInt() ?? 0,
      (j['usedBytes'] as num?)?.toInt() ?? 0);
}

class DiskMetric {
  final String mount;
  final double usedPercent;
  final int sizeBytes, usedBytes;
  const DiskMetric(
      this.mount, this.usedPercent, this.sizeBytes, this.usedBytes);
  factory DiskMetric.fromJson(Map<String, dynamic> j) => DiskMetric(
      j['mount']?.toString() ?? '?',
      (j['usedPercent'] as num?)?.toDouble() ?? 0,
      (j['sizeBytes'] as num?)?.toInt() ?? 0,
      (j['usedBytes'] as num?)?.toInt() ?? 0);
}

class ServerMetric {
  final double cpuPercent;
  final RamMetric ram;
  final List<DiskMetric> disks;
  final int uptimeSeconds;
  const ServerMetric(this.cpuPercent, this.ram, this.disks, this.uptimeSeconds);
  factory ServerMetric.fromJson(Map<String, dynamic> j) => ServerMetric(
      (j['cpuPercent'] as num?)?.toDouble() ?? 0,
      RamMetric.fromJson(Map<String, dynamic>.from((j['ram'] as Map?) ?? {})),
      ((j['disks'] as List?) ?? [])
          .map((e) => DiskMetric.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      (j['uptimeSeconds'] as num?)?.toInt() ?? 0);
}

class ContainerInfo {
  final String id, name, image, state, status;
  const ContainerInfo(this.id, this.name, this.image, this.state, this.status);
  factory ContainerInfo.fromJson(Map<String, dynamic> j) => ContainerInfo(
      j['id']?.toString() ?? '',
      j['name']?.toString() ?? '',
      j['image']?.toString() ?? '',
      j['state']?.toString() ?? '',
      j['status']?.toString() ?? '');
}

class ServerInfo {
  final String id, agentStatus, externalStatus;
  final String? hostname, os, kernel, arch, lastHeartbeatAt;
  final ServerMetric? metric;
  final List<ContainerInfo> containers;
  const ServerInfo(
      {required this.id,
      required this.agentStatus,
      required this.externalStatus,
      this.hostname,
      this.os,
      this.kernel,
      this.arch,
      this.lastHeartbeatAt,
      this.metric,
      required this.containers});
  factory ServerInfo.fromJson(Map<String, dynamic> j) => ServerInfo(
      id: j['id']?.toString() ?? '',
      agentStatus: j['agentStatus']?.toString() ?? 'unknown',
      externalStatus: j['externalStatus']?.toString() ?? 'unknown',
      hostname: j['hostname']?.toString(),
      os: j['os']?.toString(),
      kernel: j['kernel']?.toString(),
      arch: j['arch']?.toString(),
      lastHeartbeatAt: j['lastHeartbeatAt']?.toString(),
      metric: j['metric'] is Map
          ? ServerMetric.fromJson(Map<String, dynamic>.from(j['metric'] as Map))
          : null,
      containers: ((j['containers'] as List?) ?? [])
          .map((e) =>
              ContainerInfo.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList());
}
