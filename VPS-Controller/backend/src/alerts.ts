import { env } from './config.js';
import { sendPush } from './firebase.js';
import type { ContainerSnapshot, MetricSnapshot } from './types.js';
import { JsonStore } from './store.js';

export class AlertEngine {
  private cooldown = new Map<string, number>();

  constructor(private readonly store: JsonStore) {}

  private canFire(key: string): boolean {
    const now = Date.now();
    const last = this.cooldown.get(key) ?? 0;
    if (now - last < env.ALERT_COOLDOWN_SECONDS * 1000) return false;
    this.cooldown.set(key, now);
    return true;
  }

  private async fire(serverId: string, type: string, message: string, severity: 'warning' | 'critical'): Promise<void> {
    const key = `${serverId}:${type}`;
    if (!this.canFire(key)) return;
    await this.store.createAlert(serverId, type, message, severity);
    try {
      await sendPush(this.store.deviceTokens(), `VPS Controller — ${type}`, message);
    } catch {
      // Push failure must not break metric ingestion.
    }
  }

  async evaluateMetric(serverId: string, metric: MetricSnapshot): Promise<void> {
    if (metric.cpuPercent >= env.ALERT_CPU_PERCENT) {
      await this.fire(serverId, 'CPU elevada', `CPU em ${metric.cpuPercent.toFixed(1)}%`, 'warning');
    }
    if (metric.ram.usedPercent >= env.ALERT_RAM_PERCENT) {
      await this.fire(serverId, 'RAM elevada', `RAM em ${metric.ram.usedPercent.toFixed(1)}%`, 'warning');
    }
    const criticalDisk = metric.disks.find(d => d.usedPercent >= env.ALERT_DISK_PERCENT);
    if (criticalDisk) {
      await this.fire(serverId, 'Disco elevado', `${criticalDisk.mount} em ${criticalDisk.usedPercent.toFixed(1)}%`, 'critical');
    }
  }

  async evaluateContainers(serverId: string, containers: ContainerSnapshot[]): Promise<void> {
    const stopped = containers.find(c => !['running', 'created', 'restarting'].includes(c.state.toLowerCase()));
    if (stopped) {
      await this.fire(serverId, 'Container parado', `${stopped.name}: ${stopped.status}`, 'critical');
    }
  }

  async externalOffline(serverId: string): Promise<void> {
    await this.fire(serverId, 'VPS offline', 'Monitor externo não conseguiu acessar o endpoint.', 'critical');
  }

  async agentOffline(serverId: string): Promise<void> {
    await this.fire(serverId, 'Agente offline', 'Heartbeat do agente expirou.', 'warning');
  }
}
