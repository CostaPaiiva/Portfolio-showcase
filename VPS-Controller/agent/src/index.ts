import { config } from './config.js';import { api } from './api.js';import { identity,metrics } from './metrics.js';import { containers } from './docker.js';import { actions } from './actions.js';
async function beat(){const i=await identity();await api('/api/agent/heartbeat',{method:'POST',body:JSON.stringify({serverId:config.serverId,agentId:config.agentId,...i,agentVersion:config.version})});}
async function met(){await api('/api/agent/metrics',{method:'POST',body:JSON.stringify({serverId:config.serverId,metric:await metrics()})});}
async function cont(){await api('/api/agent/containers',{method:'POST',body:JSON.stringify({serverId:config.serverId,containers:await containers()})});}
function loop(name:string,fn:()=>Promise<void>,ms:number){const run=async()=>{try{await fn();}catch(e){console.error(`[${name}]`,e instanceof Error?e.message:e);}};void run();setInterval(()=>void run(),ms);}
console.log(`VPS Controller Agent ${config.version} server=${config.serverId}`);loop('heartbeat',beat,config.heartbeatMs);loop('metrics',met,config.metricsMs);loop('containers',cont,config.containersMs);loop('actions',actions,config.actionsMs);
