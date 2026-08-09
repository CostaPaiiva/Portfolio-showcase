import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { dirname } from 'node:path';
import { randomUUID } from 'node:crypto';
import type {
  AlertRecord,
  ContainerSnapshot,
  MetricSnapshot,
  PersistedState,
  RemoteAction,
  ServerRecord,
  ActionType
  , AgentCredential
} from './types.js';

const emptyState = (): PersistedState => ({
  servers: {},
  history: {},
  actions: {},
  alerts: [],
  deviceTokens: [],
  agentCredentials: {}
});

export class JsonStore {
  private state: PersistedState = emptyState();
  private saveChain: Promise<void> = Promise.resolve();

  constructor(private readonly filePath: string) {}

  async init(): Promise<void> {
    try {
      const raw = await readFile(this.filePath, 'utf8');
      this.state = JSON.parse(raw) as PersistedState;
      this.state.agentCredentials ??= {};
    } catch {
      await mkdir(dirname(this.filePath), { recursive: true });
      await this.persist();
    }
  }

  async registerAgent(serverId: string, agentId: string, tokenHash: string): Promise<AgentCredential> {
    const credential: AgentCredential = { serverId, agentId, tokenHash, createdAt: new Date().toISOString(), status: 'active' };
    this.state.agentCredentials ??= {};
    this.state.agentCredentials[agentId] = credential;
    await this.persist();
    return credential;
  }

  async getAgent(agentId: string): Promise<AgentCredential | undefined> { return this.state.agentCredentials?.[agentId]; }

  async touchAgent(agentId: string): Promise<void> {
    const credential = this.state.agentCredentials?.[agentId];
    if (credential) { credential.lastUsedAt = new Date().toISOString(); await this.persist(); }
  }

  async revokeAgent(agentId: string): Promise<boolean> {
    const credential = this.state.agentCredentials?.[agentId];
    if (!credential) return false;
    credential.status = 'revoked'; credential.revokedAt = new Date().toISOString(); await this.persist(); return true;
  }

  private persist(): Promise<void> {
    this.saveChain = this.saveChain.then(async () => {
      await mkdir(dirname(this.filePath), { recursive: true });
      await writeFile(this.filePath, JSON.stringify(this.state, null, 2), 'utf8');
    });
    return this.saveChain;
  }

  listServers(): ServerRecord[] {
    return Object.values(this.state.servers).sort((a, b) => a.id.localeCompare(b.id));
  }

  getServer(id: string): ServerRecord | undefined {
    return this.state.servers[id];
  }

  async heartbeat(input: {
    serverId: string;
    agentId: string;
    hostname: string;
    os: string;
    kernel: string;
    arch: string;
    agentVersion: string;
  }): Promise<ServerRecord> {
    const now = new Date().toISOString();
    const previous = this.state.servers[input.serverId];
    const record: ServerRecord = {
      id: input.serverId,
      agentId: input.agentId,
      hostname: input.hostname,
      os: input.os,
      kernel: input.kernel,
      arch: input.arch,
      agentVersion: input.agentVersion,
      agentStatus: 'online',
      externalStatus: previous?.externalStatus ?? 'unknown',
      lastHeartbeatAt: now,
      lastMonitorAt: previous?.lastMonitorAt,
      monitorLatencyMs: previous?.monitorLatencyMs,
      metric: previous?.metric,
      containers: previous?.containers ?? [],
      updatedAt: now
    };
    this.state.servers[input.serverId] = record;
    await this.persist();
    return record;
  }

  async addMetric(serverId: string, metric: MetricSnapshot): Promise<ServerRecord> {
    const now = new Date().toISOString();
    const previous = this.state.servers[serverId] ?? {
      id: serverId,
      agentStatus: 'unknown',
      externalStatus: 'unknown',
      containers: [],
      updatedAt: now
    };
    const record = { ...previous, metric, updatedAt: now };
    this.state.servers[serverId] = record;

    const history = this.state.history[serverId] ?? [];
    history.push(metric);
    // Keep bounded, time-bucketed history: 1m/24h, 5m/7d, 1h/90d.
    const sorted = [...history].sort((a, b) => a.timestamp.localeCompare(b.timestamp));
    const cutoff = Date.now() - 90 * 24 * 60 * 60 * 1000;
    const buckets = new Map<string, MetricSnapshot>();
    for (const sample of sorted) {
      const time = new Date(sample.timestamp).getTime();
      if (time < cutoff) continue;
      const age = Date.now() - time;
      const bucketMs = age <= 24 * 60 * 60 * 1000 ? 60_000 : age <= 7 * 24 * 60 * 60 * 1000 ? 300_000 : 3_600_000;
      buckets.set(String(Math.floor(time / bucketMs)), sample);
    }
    this.state.history[serverId] = [...buckets.values()].sort((a, b) => a.timestamp.localeCompare(b.timestamp));
    await this.persist();
    return record;
  }

  async updateContainers(serverId: string, containers: ContainerSnapshot[]): Promise<ServerRecord> {
    const now = new Date().toISOString();
    const previous = this.state.servers[serverId] ?? {
      id: serverId,
      agentStatus: 'unknown',
      externalStatus: 'unknown',
      containers: [],
      updatedAt: now
    };
    const record = { ...previous, containers, updatedAt: now };
    this.state.servers[serverId] = record;
    await this.persist();
    return record;
  }

  async monitorStatus(serverId: string, online: boolean, latencyMs?: number): Promise<ServerRecord> {
    const now = new Date().toISOString();
    const previous = this.state.servers[serverId] ?? {
      id: serverId,
      agentStatus: 'unknown',
      externalStatus: 'unknown',
      containers: [],
      updatedAt: now
    };
    const record: ServerRecord = {
      ...previous,
      externalStatus: online ? 'online' : 'offline',
      lastMonitorAt: now,
      monitorLatencyMs: latencyMs,
      updatedAt: now
    };
    this.state.servers[serverId] = record;
    await this.persist();
    return record;
  }

  history(serverId: string, limit = 720): MetricSnapshot[] {
    const all = this.state.history[serverId] ?? [];
    return all.slice(Math.max(0, all.length - limit));
  }

  async enqueueAction(serverId: string, type: ActionType, target: string): Promise<RemoteAction> {
    const action: RemoteAction = {
      id: randomUUID(),
      serverId,
      type,
      target,
      createdAt: new Date().toISOString(),
      status: 'pending'
    };
    this.state.actions[action.id] = action;
    await this.persist();
    return action;
  }

  async pullPendingActions(serverId: string): Promise<RemoteAction[]> {
    const items = Object.values(this.state.actions)
      .filter(a => a.serverId === serverId && a.status === 'pending')
      .sort((a, b) => a.createdAt.localeCompare(b.createdAt))
      .slice(0, 10);

    for (const action of items) {
      action.status = 'running';
    }
    if (items.length) await this.persist();
    return items;
  }

  async completeAction(id: string, success: boolean, result: string): Promise<RemoteAction | undefined> {
    const action = this.state.actions[id];
    if (!action) return undefined;
    action.status = success ? 'success' : 'failed';
    action.result = result.slice(0, 4000);
    action.completedAt = new Date().toISOString();
    await this.persist();
    return action;
  }

  listActions(serverId: string): RemoteAction[] {
    return Object.values(this.state.actions)
      .filter(a => a.serverId === serverId)
      .sort((a, b) => b.createdAt.localeCompare(a.createdAt))
      .slice(0, 100);
  }

  async createAlert(serverId: string, type: string, message: string, severity: 'warning' | 'critical'): Promise<AlertRecord> {
    const alert: AlertRecord = {
      id: randomUUID(),
      serverId,
      type,
      message,
      severity,
      createdAt: new Date().toISOString(),
      status: 'open'
    };
    this.state.alerts.unshift(alert);
    this.state.alerts = this.state.alerts.slice(0, 1000);
    await this.persist();
    return alert;
  }

  listAlerts(serverId?: string): AlertRecord[] {
    return serverId ? this.state.alerts.filter(a => a.serverId === serverId) : this.state.alerts;
  }

  async addDeviceToken(token: string): Promise<void> {
    if (!this.state.deviceTokens.includes(token)) {
      this.state.deviceTokens.push(token);
      await this.persist();
    }
  }

  deviceTokens(): string[] {
    return [...this.state.deviceTokens];
  }

  async markStaleAgents(staleAfterMs: number): Promise<ServerRecord[]> {
    const now = Date.now();
    const changed: ServerRecord[] = [];
    for (const server of Object.values(this.state.servers)) {
      if (!server.lastHeartbeatAt) continue;
      if (now - new Date(server.lastHeartbeatAt).getTime() > staleAfterMs && server.agentStatus !== 'offline') {
        server.agentStatus = 'offline';
        server.updatedAt = new Date().toISOString();
        changed.push(server);
      }
    }
    if (changed.length) await this.persist();
    return changed;
  }
}
