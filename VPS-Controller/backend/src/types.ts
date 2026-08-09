export type ServerStatus = 'online' | 'offline' | 'unknown';
export type AgentStatus = 'online' | 'offline' | 'unknown';

export interface DiskMetric {
  fs: string;
  mount: string;
  sizeBytes: number;
  usedBytes: number;
  availableBytes: number;
  usedPercent: number;
}

export interface NetworkMetric {
  interface: string;
  rxBytes: number;
  txBytes: number;
  rxBytesPerSec: number;
  txBytesPerSec: number;
}

export interface MetricSnapshot {
  timestamp: string;
  cpuPercent: number;
  loadAverage: number[];
  ram: {
    totalBytes: number;
    usedBytes: number;
    availableBytes: number;
    usedPercent: number;
    swapTotalBytes: number;
    swapUsedBytes: number;
  };
  disks: DiskMetric[];
  uptimeSeconds: number;
  networks: NetworkMetric[];
}

export interface ContainerSnapshot {
  id: string;
  name: string;
  image: string;
  state: string;
  status: string;
  createdAt?: string;
  ports: string[];
  cpuPercent?: number;
  memoryBytes?: number;
}

export interface ServerRecord {
  id: string;
  agentId?: string;
  hostname?: string;
  os?: string;
  kernel?: string;
  arch?: string;
  agentVersion?: string;
  agentStatus: AgentStatus;
  externalStatus: ServerStatus;
  lastHeartbeatAt?: string;
  lastMonitorAt?: string;
  monitorLatencyMs?: number;
  metric?: MetricSnapshot;
  containers: ContainerSnapshot[];
  updatedAt: string;
}

export type ActionType =
  | 'docker.start'
  | 'docker.stop'
  | 'docker.restart'
  | 'service.start'
  | 'service.stop'
  | 'service.restart';

export interface RemoteAction {
  id: string;
  serverId: string;
  type: ActionType;
  target: string;
  createdAt: string;
  status: 'pending' | 'running' | 'success' | 'failed';
  result?: string;
  completedAt?: string;
}

export interface AlertRecord {
  id: string;
  serverId: string;
  type: string;
  message: string;
  severity: 'warning' | 'critical';
  createdAt: string;
  status: 'open' | 'acknowledged' | 'resolved';
}

export interface PersistedState {
  servers: Record<string, ServerRecord>;
  history: Record<string, MetricSnapshot[]>;
  actions: Record<string, RemoteAction>;
  alerts: AlertRecord[];
  deviceTokens: string[];
}
