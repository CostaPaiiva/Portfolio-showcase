import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { dirname } from 'node:path';
import { randomUUID } from 'node:crypto';
import type { ActionType, AlertRecord, ContainerSnapshot, MetricSnapshot, RemoteAction, ServerRecord, State } from './types.js';
const empty=():State=>({servers:{},history:{},actions:{},alerts:[]});
export class Store{
 private state:State=empty(); private saving=Promise.resolve();
 constructor(private file:string){}
 async init(){try{this.state=JSON.parse(await readFile(this.file,'utf8')) as State;}catch{await mkdir(dirname(this.file),{recursive:true}); await this.save();}}
 private save(){this.saving=this.saving.then(()=>writeFile(this.file,JSON.stringify(this.state,null,2),'utf8'));return this.saving;}
 listServers(){return Object.values(this.state.servers).sort((a,b)=>a.id.localeCompare(b.id));}
 getServer(id:string){return this.state.servers[id];}
 async heartbeat(x:{serverId:string;agentId:string;hostname:string;os:string;kernel:string;arch:string;agentVersion:string}){const now=new Date().toISOString(),p=this.state.servers[x.serverId]; const s:ServerRecord={id:x.serverId,agentId:x.agentId,hostname:x.hostname,os:x.os,kernel:x.kernel,arch:x.arch,agentVersion:x.agentVersion,agentStatus:'online',externalStatus:p?.externalStatus??'unknown',lastHeartbeatAt:now,lastMonitorAt:p?.lastMonitorAt,monitorLatencyMs:p?.monitorLatencyMs,metric:p?.metric,containers:p?.containers??[],updatedAt:now}; this.state.servers[x.serverId]=s; await this.save(); return s;}
 async metric(id:string,m:MetricSnapshot){const now=new Date().toISOString(),p=this.state.servers[id]??{id,agentStatus:'unknown' as const,externalStatus:'unknown' as const,containers:[],updatedAt:now}; const s={...p,metric:m,updatedAt:now}; this.state.servers[id]=s; const h=this.state.history[id]??[]; h.push(m); if(h.length>17280)h.splice(0,h.length-17280); this.state.history[id]=h; await this.save(); return s;}
 async containers(id:string,c:ContainerSnapshot[]){const now=new Date().toISOString(),p=this.state.servers[id]??{id,agentStatus:'unknown' as const,externalStatus:'unknown' as const,containers:[],updatedAt:now}; const s={...p,containers:c,updatedAt:now}; this.state.servers[id]=s; await this.save(); return s;}
 async monitor(id:string,online:boolean,latencyMs?:number){const now=new Date().toISOString(),p=this.state.servers[id]??{id,agentStatus:'unknown' as const,externalStatus:'unknown' as const,containers:[],updatedAt:now}; const s:ServerRecord={...p,externalStatus:online?'online':'offline',lastMonitorAt:now,monitorLatencyMs:latencyMs,updatedAt:now};this.state.servers[id]=s;await this.save();return s;}
 history(id:string,limit:number){return (this.state.history[id]??[]).slice(-limit);}
 async addAction(serverId:string,type:ActionType,target:string){const a:RemoteAction={id:randomUUID(),serverId,type,target,createdAt:new Date().toISOString(),status:'pending'};this.state.actions[a.id]=a;await this.save();return a;}
 async pullActions(serverId:string){const a=Object.values(this.state.actions).filter(x=>x.serverId===serverId&&x.status==='pending').slice(0,10);for(const x of a)x.status='running';if(a.length)await this.save();return a;}
 async finishAction(id:string,success:boolean,result:string){const a=this.state.actions[id];if(!a)return; a.status=success?'success':'failed';a.result=result.slice(0,4000);a.completedAt=new Date().toISOString();await this.save();return a;}
 async alert(serverId:string,type:string,message:string,severity:'warning'|'critical'){const a:AlertRecord={id:randomUUID(),serverId,type,message,severity,createdAt:new Date().toISOString(),status:'open'};this.state.alerts.unshift(a);this.state.alerts=this.state.alerts.slice(0,1000);await this.save();return a;}
 alerts(){return this.state.alerts;}
 async stale(ms:number){const now=Date.now(),out:ServerRecord[]=[];for(const s of Object.values(this.state.servers)){if(s.lastHeartbeatAt&&now-new Date(s.lastHeartbeatAt).getTime()>ms&&s.agentStatus!=='offline'){s.agentStatus='offline';s.updatedAt=new Date().toISOString();out.push(s);}}if(out.length)await this.save();return out;}
}
