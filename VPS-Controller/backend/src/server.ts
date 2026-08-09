import http, { type IncomingMessage, type ServerResponse } from 'node:http';
import { URL } from 'node:url';
import { config } from './config.js';
import { Store } from './store.js';
import type { ActionType, ContainerSnapshot, MetricSnapshot } from './types.js';

const store=new Store(config.dataFile); await store.init();
const cooldown=new Map<string,number>();
function json(res:ServerResponse,status:number,body:unknown){const data=JSON.stringify(body);res.writeHead(status,{'content-type':'application/json; charset=utf-8','content-length':Buffer.byteLength(data),'access-control-allow-origin':'*','access-control-allow-headers':'authorization,content-type,x-agent-token,x-monitor-token','access-control-allow-methods':'GET,POST,OPTIONS'});res.end(data);}
async function body(req:IncomingMessage){const chunks:Buffer[]=[];let size=0;for await(const c of req){const b=Buffer.isBuffer(c)?c:Buffer.from(c);size+=b.length;if(size>1024*1024)throw new Error('payload_too_large');chunks.push(b);}if(!chunks.length)return{};return JSON.parse(Buffer.concat(chunks).toString('utf8')) as Record<string,unknown>;}
function bearer(req:IncomingMessage){return (req.headers.authorization||'').replace(/^Bearer\s+/i,'');}
function agent(req:IncomingMessage){return req.headers['x-agent-token']===config.agentToken;}
function monitor(req:IncomingMessage){return req.headers['x-monitor-token']===config.monitorToken;}
function validTarget(v:unknown){return typeof v==='string'&&v.length>0&&v.length<=255&&/^[a-zA-Z0-9_.:@/-]+$/.test(v);}
async function fire(serverId:string,type:string,message:string,severity:'warning'|'critical'){const k=`${serverId}:${type}`,now=Date.now();if(now-(cooldown.get(k)||0)<300_000)return;cooldown.set(k,now);await store.alert(serverId,type,message,severity);}
async function evaluateMetric(id:string,m:MetricSnapshot){if(m.cpuPercent>=config.cpuThreshold)await fire(id,'CPU elevada',`CPU em ${m.cpuPercent.toFixed(1)}%`,'warning');if(m.ram.usedPercent>=config.ramThreshold)await fire(id,'RAM elevada',`RAM em ${m.ram.usedPercent.toFixed(1)}%`,'warning');const d=m.disks.find(x=>x.usedPercent>=config.diskThreshold);if(d)await fire(id,'Disco elevado',`${d.mount} em ${d.usedPercent.toFixed(1)}%`,'critical');}

const server=http.createServer(async(req,res)=>{try{
 if(req.method==='OPTIONS')return json(res,204,{});
 const u=new URL(req.url||'/',`http://${req.headers.host||'localhost'}`), path=u.pathname;
 if(req.method==='GET'&&path==='/health')return json(res,200,{status:'ok',version:'0.2.0',timestamp:new Date().toISOString()});
 if(path.startsWith('/api/agent/')&&!agent(req))return json(res,401,{error:'invalid_agent_token'});
 if(path.startsWith('/api/monitor/')&&!monitor(req))return json(res,401,{error:'invalid_monitor_token'});
 if(path.startsWith('/api/')&&!path.startsWith('/api/agent/')&&!path.startsWith('/api/monitor/')&&bearer(req)!==config.userToken)return json(res,401,{error:'unauthorized'});

 if(req.method==='POST'&&path==='/api/agent/heartbeat'){const x=await body(req) as any;if(!x.serverId||!x.agentId)return json(res,400,{error:'invalid_payload'});return json(res,200,{ok:true,server:await store.heartbeat(x)});}
 if(req.method==='POST'&&path==='/api/agent/metrics'){const x=await body(req) as {serverId?:string;metric?:MetricSnapshot};if(!x.serverId||!x.metric)return json(res,400,{error:'invalid_payload'});await evaluateMetric(x.serverId,x.metric);return json(res,200,{ok:true,server:await store.metric(x.serverId,x.metric)});}
 if(req.method==='POST'&&path==='/api/agent/containers'){const x=await body(req) as {serverId?:string;containers?:ContainerSnapshot[]};if(!x.serverId||!Array.isArray(x.containers))return json(res,400,{error:'invalid_payload'});const stopped=x.containers.find(c=>!['running','created','restarting'].includes(c.state.toLowerCase()));if(stopped)await fire(x.serverId,'Container parado',`${stopped.name}: ${stopped.status}`,'critical');return json(res,200,{ok:true,server:await store.containers(x.serverId,x.containers)});}
 if(req.method==='GET'&&path==='/api/agent/actions'){const id=u.searchParams.get('serverId');if(!id)return json(res,400,{error:'serverId_required'});return json(res,200,{actions:await store.pullActions(id)});}
 let m=path.match(/^\/api\/agent\/actions\/([^/]+)\/result$/);if(req.method==='POST'&&m){const x=await body(req) as {success?:boolean;result?:string};const a=await store.finishAction(m[1]!,x.success===true,String(x.result??''));return a?json(res,200,{ok:true,action:a}):json(res,404,{error:'action_not_found'});}
 if(req.method==='POST'&&path==='/api/monitor/status'){const x=await body(req) as {serverId?:string;online?:boolean;latencyMs?:number};if(!x.serverId||typeof x.online!=='boolean')return json(res,400,{error:'invalid_payload'});if(!x.online)await fire(x.serverId,'VPS offline','Monitor externo não conseguiu acessar o endpoint.','critical');return json(res,200,{ok:true,server:await store.monitor(x.serverId,x.online,x.latencyMs)});}
 if(req.method==='GET'&&path==='/api/servers')return json(res,200,{servers:store.listServers()});
 m=path.match(/^\/api\/servers\/([^/]+)$/);if(req.method==='GET'&&m){const s=store.getServer(decodeURIComponent(m[1]!));return s?json(res,200,{server:s}):json(res,404,{error:'server_not_found'});}
 m=path.match(/^\/api\/servers\/([^/]+)\/history$/);if(req.method==='GET'&&m){const limit=Math.min(5000,Math.max(1,Number(u.searchParams.get('limit')||720)));return json(res,200,{history:store.history(decodeURIComponent(m[1]!),limit)});}
 m=path.match(/^\/api\/servers\/([^/]+)\/actions$/);if(req.method==='GET'&&m){const serverId=decodeURIComponent(m[1]!);const state=JSON.parse(await (await import('node:fs/promises')).readFile(config.dataFile,'utf8')) as any;const actions=Object.values(state.actions||{}).filter((a:any)=>a.serverId===serverId).sort((a:any,b:any)=>String(b.createdAt).localeCompare(String(a.createdAt))).slice(0,100);return json(res,200,{actions});}
 m=path.match(/^\/api\/servers\/([^/]+)\/actions$/);if(req.method==='POST'&&m){const x=await body(req) as {type?:ActionType;target?:unknown};const allowed=['docker.start','docker.stop','docker.restart','service.start','service.stop','service.restart'];if(!x.type||!allowed.includes(x.type)||!validTarget(x.target))return json(res,400,{error:'invalid_action'});return json(res,202,{action:await store.addAction(decodeURIComponent(m[1]!),x.type,x.target as string)});}
 if(req.method==='GET'&&path==='/api/alerts')return json(res,200,{alerts:store.alerts()});
 return json(res,404,{error:'not_found'});
 }catch(e){console.error(e);return json(res,e instanceof Error&&e.message==='payload_too_large'?413:500,{error:'internal_error'});}});
server.listen(config.port,config.host,()=>console.log(`VPS Controller backend http://${config.host}:${config.port}`));
setInterval(async()=>{for(const s of await store.stale(config.staleSeconds*1000))await fire(s.id,'Agente offline','Heartbeat do agente expirou.','warning');},15000).unref();
