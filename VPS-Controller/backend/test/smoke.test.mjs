import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { Store } from '../dist/store.js';

test('store persists heartbeat, metrics and actions', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'vps-controller-'));
  try {
    const store = new Store(join(dir, 'state.json'));
    await store.init();
    const heartbeat = await store.heartbeat({ serverId: 's1', agentId: 'a1', hostname: 'host', os: 'Linux', kernel: '6', arch: 'x64', agentVersion: 'test' });
    assert.equal(heartbeat.agentStatus, 'online');
    const metric = { timestamp: new Date().toISOString(), cpuPercent: 12, loadAverage: [0.1], ram: { totalBytes: 100, usedBytes: 40, availableBytes: 60, usedPercent: 40, swapTotalBytes: 0, swapUsedBytes: 0 }, disks: [], uptimeSeconds: 10, networks: [] };
    await store.metric('s1', metric);
    assert.equal(store.getServer('s1')?.metric?.cpuPercent, 12);
    const action = await store.addAction('s1', 'docker.start', 'container-1');
    assert.equal((await store.pullActions('s1'))[0]?.id, action.id);
    assert.equal((await store.finishAction(action.id, false, 'Docker unavailable'))?.status, 'failed');
  } finally { await rm(dir, { recursive: true, force: true }); }
});
