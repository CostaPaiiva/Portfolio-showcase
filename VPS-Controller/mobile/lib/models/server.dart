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
  final List<double> loadAverage;
  final List<NetworkMetric> networks;
  const ServerMetric(this.cpuPercent, this.ram, this.disks, this.uptimeSeconds,
      this.loadAverage, this.networks);
  factory ServerMetric.fromJson(Map<String, dynamic> j) => ServerMetric(
      (j['cpuPercent'] as num?)?.toDouble() ?? 0,
      RamMetric.fromJson(Map<String, dynamic>.from((j['ram'] as Map?) ?? {})),
      ((j['disks'] as List?) ?? [])
          .map((e) => DiskMetric.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      (j['uptimeSeconds'] as num?)?.toInt() ?? 0,
      ((j['loadAverage'] as List?) ?? const [])
          .whereType<num>()
          .map((item) => item.toDouble())
          .toList(),
      ((j['networks'] as List?) ?? const [])
          .map((item) =>
              NetworkMetric.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList());
}

class NetworkMetric {
  final String interfaceName;
  final int rxBytes;
  final int txBytes;
  final double rxBytesPerSec;
  final double txBytesPerSec;
  const NetworkMetric(this.interfaceName, this.rxBytes, this.txBytes,
      this.rxBytesPerSec, this.txBytesPerSec);
  factory NetworkMetric.fromJson(Map<String, dynamic> j) => NetworkMetric(
      j['interface']?.toString() ?? '?',
      (j['rxBytes'] as num?)?.toInt() ?? 0,
      (j['txBytes'] as num?)?.toInt() ?? 0,
      (j['rxBytesPerSec'] as num?)?.toDouble() ?? 0,
      (j['txBytesPerSec'] as num?)?.toDouble() ?? 0);
}

class ContainerInfo {
  final String id, name, image, state, status;
  final List<String> ports;
  final double? cpuPercent;
  final int? memoryBytes;
  const ContainerInfo(this.id, this.name, this.image, this.state, this.status,
      this.ports, this.cpuPercent, this.memoryBytes);
  factory ContainerInfo.fromJson(Map<String, dynamic> j) => ContainerInfo(
      j['id']?.toString() ?? '',
      j['name']?.toString() ?? '',
      j['image']?.toString() ?? '',
      j['state']?.toString() ?? '',
      j['status']?.toString() ?? '',
      ((j['ports'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(),
      (j['cpuPercent'] as num?)?.toDouble(),
      (j['memoryBytes'] as num?)?.toInt());
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
