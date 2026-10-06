// Separate from the pilot gateway. Deployment requires Play Console, a billed
// Gemini project, a Publisher API service account, KV and a Durable Object.
import {catalog} from './plans.generated.mjs';
import {metered} from './meter.mjs';
export const PACKAGE = 'com.finchat.finchat';
export const PLANS = Object.freeze(Object.fromEntries(catalog.flatMap(p=>Object.entries(p.products).map(([cycle,id])=>[id,{tier:p.tier,limit:p.ai,cycle}]))));
const enc = new TextEncoder();
const b64 = bytes => btoa(String.fromCharCode(...new Uint8Array(bytes))).replaceAll('+','-').replaceAll('/','_').replace(/=+$/,'');
const unb64 = text => Uint8Array.from(atob(text.replaceAll('-','+').replaceAll('_','/')), c=>c.charCodeAt(0));
export const hash = async text => [...new Uint8Array(await crypto.subtle.digest('SHA-256',enc.encode(text)))].map(x=>x.toString(16).padStart(2,'0')).join('');
class Fault extends Error { constructor(status, message) { super(message); this.status=status; } }
const json = (value,status=200) => new Response(JSON.stringify(value),{status, headers:{'Content-Type':'application/json','Cache-Control':'no-store','X-Content-Type-Options':'nosniff'}});
export function evaluatePurchase(purchase, accountId, now=Date.now()) {
  if (!['SUBSCRIPTION_STATE_ACTIVE','SUBSCRIPTION_STATE_IN_GRACE_PERIOD','SUBSCRIPTION_STATE_CANCELED'].includes(purchase.subscriptionState)) throw new Fault(403,'subscription_inactive');
  if (purchase.externalAccountIdentifiers?.obfuscatedExternalAccountId !== accountId) throw new Fault(403,'account_mismatch');
  const valid = (purchase.lineItems ?? []).filter(x=>PLANS[x.productId] && x.offerDetails?.basePlanId === PLANS[x.productId].cycle && x.autoRenewingPlan && Number.isFinite(Date.parse(x.expiryTime)));
  if(valid.length===1 && Date.parse(valid[0].expiryTime)<=now)throw new Fault(403,'subscription_inactive');
  const lines = valid.filter(x=>Date.parse(x.expiryTime)>now);
  if (lines.length !== 1) throw new Fault(403,'invalid_product_or_expiry');
  const line=lines[0];
  return {active:true, accountId, tier:PLANS[line.productId].tier, limit:PLANS[line.productId].limit, productId:line.productId, expiresAt:line.expiryTime, startsAt: purchase.startTime ?? new Date(now - 86400000).toISOString(), basePlan:PLANS[line.productId].cycle, status:purchase.subscriptionState.replace('SUBSCRIPTION_STATE_','').replace('IN_GRACE_PERIOD','GRACE_PERIOD')};
}
let jwksCache, oauthCache;
async function identity(request, env, net) {
  const token = request.headers.get('Authorization')?.match(/^Bearer ([^ ]+)$/)?.[1];
  if (!token || !env.GOOGLE_CLIENT_ID) throw new Fault(401,'authentication_required');
  try {
    const parts=token.split('.'); if(parts.length!==3) throw Error();
    const header=JSON.parse(new TextDecoder().decode(unb64(parts[0]))), claims=JSON.parse(new TextDecoder().decode(unb64(parts[1])));
    if(header.alg!=='RS256' || !header.kid || !['accounts.google.com','https://accounts.google.com'].includes(claims.iss) || claims.aud!==env.GOOGLE_CLIENT_ID || typeof claims.sub!=='string' || !claims.sub || !Number.isFinite(claims.exp) || claims.exp*1000<=Date.now() || !Number.isFinite(claims.iat) || claims.iat*1000>Date.now()+60000) throw Error();
    if(!jwksCache || jwksCache.until<Date.now()) {
      const response=await net('https://www.googleapis.com/oauth2/v3/certs'); if(!response.ok) throw new Fault(503,'identity_unavailable');
      jwksCache={keys:(await response.json()).keys,until:Date.now()+300000};
    }
    const jwk=jwksCache.keys.find(x=>x.kid===header.kid); if(!jwk) { jwksCache=null; throw Error(); }
    const key=await crypto.subtle.importKey('jwk',jwk,{name:'RSASSA-PKCS1-v1_5',hash:'SHA-256'},false,['verify']);
    if(!await crypto.subtle.verify('RSASSA-PKCS1-v1_5',key,unb64(parts[2]),enc.encode(parts[0]+'.'+parts[1]))) throw Error();
    return await hash(claims.sub);
  } catch(error) { if(error instanceof Fault) throw error; throw new Fault(401,'invalid_identity'); }
}
async function publisherToken(env,net) {
  if(oauthCache?.until>Date.now() && oauthCache.client===env.PLAY_SERVICE_ACCOUNT_EMAIL) return oauthCache.token;
  if(!env.PLAY_SERVICE_ACCOUNT_EMAIL || !env.PLAY_SERVICE_ACCOUNT_PRIVATE_KEY) throw new Fault(503,'billing_not_configured');
  const seconds=Math.floor(Date.now()/1000);
  const head=b64(enc.encode(JSON.stringify({alg:'RS256',typ:'JWT'})));
  const claims=b64(enc.encode(JSON.stringify({iss:env.PLAY_SERVICE_ACCOUNT_EMAIL,scope:'https://www.googleapis.com/auth/androidpublisher',aud:'https://oauth2.googleapis.com/token',iat:seconds,exp:seconds+3600})));
  const pem=env.PLAY_SERVICE_ACCOUNT_PRIVATE_KEY.replace(/-----[^-]+-----|\s/g,'');
  const key=await crypto.subtle.importKey('pkcs8',unb64(pem),{name:'RSASSA-PKCS1-v1_5',hash:'SHA-256'},false,['sign']);
  const signature=b64(await crypto.subtle.sign('RSASSA-PKCS1-v1_5',key,enc.encode(head+'.'+claims)));
  const result=await net('https://oauth2.googleapis.com/token',{method:'POST',body:new URLSearchParams({grant_type:'urn:ietf:params:oauth:grant-type:jwt-bearer',assertion:head+'.'+claims+'.'+signature})});
  if(!result.ok) throw new Fault(503,'billing_authorization_unavailable');
  const data=await result.json(); if(!data.access_token) throw new Fault(503,'billing_authorization_unavailable');
  oauthCache={token:data.access_token,client:env.PLAY_SERVICE_ACCOUNT_EMAIL,until:Date.now()+Math.min(data.expires_in ?? 3600,3500)*1000}; return data.access_token;
}
export async function verifyPurchase(token,account,env,net=fetch) {
  if(typeof token!=='string' || !token || token.length>4096) throw new Fault(400,'invalid_purchase_token');
  const access=await publisherToken(env,net), headers={Authorization:'Bearer '+access,'Content-Type':'application/json'};
  const base='https://androidpublisher.googleapis.com/androidpublisher/v3/applications/'+PACKAGE+'/purchases/';
  const response=await net(base+'subscriptionsv2/tokens/'+encodeURIComponent(token),{headers});
  if(!response.ok) throw new Fault(response.status===404 || response.status===410 ? 403:503,'purchase_verification_failed');
  const purchase=await response.json(), entitlement=evaluatePurchase(purchase,account);
  if(!purchase.startTime || !Number.isFinite(Date.parse(purchase.startTime))) throw new Fault(503,'billing_anchor_missing');
  if(purchase.acknowledgementState!=='ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED') {
    const ack=await net(base+'subscriptions/'+entitlement.productId+'/tokens/'+encodeURIComponent(token)+':acknowledge',{method:'POST',headers,body:'{}'});
    if(!ack.ok) throw new Fault(503,'purchase_acknowledgement_failed');
  }
  return entitlement;
}
export class Quota {
  constructor(state) { this.state=state; }
  async fetch(request) {
    const input=await request.json();
    if(input.action==='token') {
      if(input.token) {
        await this.state.storage.put('purchase',input.token);
        if(Number.isFinite(input.until)) {await this.state.storage.put('purchaseUntil',input.until);await this.state.storage.setAlarm(input.until);}
      }
      return json({token:await this.state.storage.get('purchase') ?? null});
    }
    if(input.action==='capacity') {
      return this.state.blockConcurrencyWhile(async()=> {
        const slots=await this.state.storage.get('capacity') ?? {};
        for(const [id,at] of Object.entries(slots))if(at<Date.now())delete slots[id];
        if(input.release)delete slots[input.operationId];
        else {if(Object.keys(slots).length>=(input.priority?4:2))return json({error:'ai_busy'},429);slots[input.operationId]=Date.now()+45000;}
        await this.state.storage.put('capacity',slots);return json({ok:true});
      });
    }
    if(input.action==='summary')return json({meter:await this.state.storage.get('meter') ?? null});
    if(input.resource || ['state','settle','event'].includes(input.action))return metered(this.state,input);
    return this.state.blockConcurrencyWhile(async()=> {
      const key='usage:'+input.cycle, now=Date.now();
      const usage=await this.state.storage.get(key) ?? {count:0,minute:0,rate:0};
      if(input.action==='refund') { usage.count=Math.max(0,usage.count-1); await this.state.storage.put(key,usage); return json({ok:true}); }
      if(usage.minute!==Math.floor(now/60000)) {usage.minute=Math.floor(now/60000); usage.rate=0;}
      if(usage.count>=input.limit || usage.rate>=10) return json({error:'quota_reached'},429);
      usage.count++; usage.rate++; usage.until=input.until;
      await this.state.storage.put(key,usage);
      const all=await this.state.storage.list({prefix:'usage:'});
      for(const [old,value] of all) if(value.until && value.until<now) await this.state.storage.delete(old);
      await this.state.storage.setAlarm(Math.min(input.until, now+86400000));
      return json({used:usage.count,limit:input.limit});
    });
  }
  async alarm() {
    const purchaseUntil=await this.state.storage.get('purchaseUntil');
    if(purchaseUntil && purchaseUntil<=Date.now()) {await this.state.storage.delete('purchase');await this.state.storage.delete('purchaseUntil');}
    const meter=await this.state.storage.get('meter');if(meter && meter.end+30*86400000<Date.now())await this.state.storage.delete('meter');
    const all=await this.state.storage.list({prefix:'usage:'}); let next=meter?.end+30*86400000>Date.now()?meter.end+30*86400000:Infinity;
    for(const [key,value] of all) { if(value.until<Date.now()) await this.state.storage.delete(key); else next=Math.min(next,value.until); }
    if(purchaseUntil>Date.now())next=Math.min(next,purchaseUntil);
    if(Number.isFinite(next)) await this.state.storage.setAlarm(Math.min(next,Date.now()+86400000));
  }
}
async function readBody(request) {
  const reader=request.body?.getReader(); const chunks=[]; let size=0;
  if(reader) { while(true) { const {value,done}=await reader.read(); if(done) break;size+=value.length;if(size>20000) {await reader.cancel();throw new Fault(413,'payload_too_large');}chunks.push(value); } }
  const bytes=new Uint8Array(size);let offset=0;for(const chunk of chunks) {bytes.set(chunk,offset);offset+=chunk.length;}
  const text=new TextDecoder().decode(bytes);
  try {return JSON.parse(text);} catch {throw new Fault(400,'invalid_json');}
}
async function objectCall(env,account,input) {
  if(!env.QUOTA) throw new Fault(503,'quota_not_configured');
  return env.QUOTA.get(env.QUOTA.idFromName(account)).fetch('https://internal/',{method:'POST',body:JSON.stringify(input)});
}
async function accountEntitlement(request,account,env,net) {
  let token=request.headers.get('X-Play-Purchase-Token');
  if(!token)token=(await (await objectCall(env,account,{action:'token'})).json()).token;
  if(!token)return null;
  try {const entitlement=await verifyPurchase(token,account,env,net);await objectCall(env,account,{action:'token',token,until:Date.parse(entitlement.expiresAt)+30*86400000});return entitlement;}
  catch(error) {if(error instanceof Fault && error.status===403 && error.message==='subscription_inactive')return null;throw error;}
}
async function quota(env,account,entitlement,operationId,action) {
  return objectCall(env,account,{action:action==='refund'?'settle':action,resource:action==='reserve'?'ai':undefined,operationId,success:action==='refund'?false:true,entitlement});
}
const education = Object.freeze({budget:'Jelaskan konsep anggaran pribadi secara umum tanpa data individu.',emergency:'Jelaskan konsep dana darurat secara umum tanpa data individu.',saving:'Jelaskan kebiasaan menabung secara umum tanpa data individu.'});
async function gemini(prompt,env,net) {
  const base='https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite';
  const headers={'Content-Type':'application/json','x-goog-api-key':env.GEMINI_API_KEY};
  const contents=[{role:'user',parts:[{text:prompt}]}];
  const count=await net(base+':countTokens',{method:'POST',headers,signal:AbortSignal.timeout(10000),body:JSON.stringify({contents})});
  if(!count.ok) throw new Fault(503,'ai_unavailable');
  const tokens=(await count.json()).totalTokens;
  if(!Number.isFinite(tokens) || tokens<1) throw new Fault(503,'invalid_token_count');
  if(tokens>4096) throw new Fault(413,'input_token_limit');
  const answer=await net(base+':generateContent',{method:'POST',headers,signal:AbortSignal.timeout(25000),body:JSON.stringify({contents,generationConfig:{temperature:0.1,maxOutputTokens:768,thinkingConfig:{thinkingBudget:0}}})});
  if(!answer.ok) throw new Fault(503,'ai_unavailable');
  const data=await answer.json(); const text=data.candidates?.[0]?.content?.parts?.map(x=>x.text ?? '').join('').trim();
  if(!text) throw new Fault(503,'ai_no_answer'); return text;
}
export async function handle(request,env,net=fetch) {
  try {
    const path=new URL(request.url).pathname;
    if(path==='/health' && request.method==='GET') return json({service:'spenva-play',version:1});
    if(path==='/v1/admin/reports' && request.method==='GET') {
      if(!env.ADMIN_TOKEN || request.headers.get('Authorization')!=='Bearer '+env.ADMIN_TOKEN) throw new Fault(401,'admin_required');
      if(!env.FEEDBACK) throw new Fault(503,'reporting_not_configured');
      const page=await env.FEEDBACK.list({prefix:'report:',cursor:new URL(request.url).searchParams.get('cursor') ?? undefined,limit:50});
      const reports=await Promise.all(page.keys.map(async key=>({id:key.name,report:await env.FEEDBACK.get(key.name,'json')})));
      reports.sort((a,b)=>Number(b.report?.priority===true)-Number(a.report?.priority===true));
      return json({reports,cursor:page.list_complete?null:page.cursor});
    }
    if(request.method!=='POST') throw new Fault(404,'not_found');
    const account=await identity(request,env,net);
    if(path==='/v1/feedback') {
      if(!env.FEEDBACK) throw new Fault(503,'reporting_not_configured');
      const body=await readBody(request);
      if(typeof body.reason!=='string' || !body.reason.trim() || body.reason.length>500 || (body.question!=null && (typeof body.question!=='string'||body.question.length>5000)) || (body.answer!=null && (typeof body.answer!=='string'||body.answer.length>10000))) throw new Fault(400,'invalid_report');
      const key='report:'+account+':'+crypto.randomUUID();
      const member=env.QUOTA ? await accountEntitlement(request,account,env,net) : null;
      const priority=catalog.find(p=>p.tier===member?.tier)?.priority===true;
      await env.FEEDBACK.put(key,JSON.stringify({priority,tier:member?.tier ?? 'free',reason:body.reason,question:body.question,answer:body.answer,createdAt:new Date().toISOString()}),{expirationTtl:30*86400});
      return json({received:true},201);
    }
    if(path==='/v1/delete-self') {
      if(!env.FEEDBACK) throw new Fault(503,'reporting_not_configured');
      const keys=[]; let cursor;
      do {const page=await env.FEEDBACK.list({prefix:'report:'+account+':',cursor}); keys.push(...page.keys.map(x=>x.name)); cursor=page.list_complete?null:page.cursor;} while(cursor);
      for(const key of keys) await env.FEEDBACK.delete(key);
      return json({deleted:true,quotaRetention:'current_subscription_end_plus_30_days'});
    }
    if(path==='/v1/purchases/verify') {
      const body=await readBody(request); const entitlement=await verifyPurchase(body.purchaseToken,account,env,net);await objectCall(env,account,{action:'token',token:body.purchaseToken,until:Date.parse(entitlement.expiresAt)+30*86400000});return json(entitlement);
    }
    if(path.startsWith('/v1/quota/')) {
      const action=path.split('/').at(-1),body=await readBody(request);
      if(!['state','reserve','settle','event'].includes(action))throw new Fault(404,'not_found');
      if(body.resource==='ai')throw new Fault(403,'ai_server_only');
      const entitlement=await accountEntitlement(request,account,env,net);
      const result=await objectCall(env,account,{action,entitlement,resource:body.resource,operationId:body.operationId,success:body.success,event:body.event,count:body.count});
      if(action==='state' && result.ok)return json({...await result.json(),personalAiEnabled:env.PAID_AI_CONFIRMED==='true',educationAiEnabled:env.UNPAID_EDUCATION_ENABLED==='true',entitlement});
      return result;
    }
    if(path==='/v1/ai/chat') {
      const body=await readBody(request);
      const paid=env.PAID_AI_CONFIRMED==='true';
      if(!env.GEMINI_API_KEY || (!paid && (env.UNPAID_EDUCATION_ENABLED!=='true' || !Object.hasOwn(education,body.topic) || body.messages!=null)))throw new Fault(503,'ai_unavailable');
      if(paid && (!Array.isArray(body.messages) || body.messages.length!==1 || body.messages[0]?.role!=='user' || typeof body.messages[0].text!=='string' || body.messages[0].text.length>10000))throw new Fault(400,'invalid_prompt');
      const entitlement=await accountEntitlement(request,account,env,net);
      const prompt=paid?body.messages[0].text:education[body.topic];
      const token=crypto.randomUUID().replaceAll('-','');
      const reservation=await quota(env,account,entitlement,token,'reserve'); if(!reservation.ok) return reservation;
      if(body.purpose==='category_fallback')await objectCall(env,account,{action:'event',event:'fallback',entitlement});
      try {
        const priority=catalog.find(p=>p.tier===entitlement?.tier)?.priority===true;
        const capacity=await objectCall(env,'global-ai-capacity',{action:'capacity',operationId:token,priority});
        if(!capacity.ok)throw new Fault(429,'ai_busy');
        try {const level=catalog.find(p=>p.tier===entitlement?.tier)?.aiLevel==='advanced' ? "Berikan analisis terstruktur, alasan dan langkah praktis berdasarkan data yang tersedia. Jangan mengarang." : "Berikan jawaban ringkas dan praktis. Jangan mengarang.";
          const text=await gemini(level+"\n"+prompt,env,net);await quota(env,account,entitlement,token,'settle');return json({text});}
        finally {await objectCall(env,'global-ai-capacity',{action:'capacity',operationId:token,release:true});}
      }
      catch(error) {
        await quota(env,account,entitlement,token,'refund');
        await objectCall(env,account,{action:'event',event:error?.name==='TimeoutError'?'timeout':error?.status===429?'rate_limit':'ai_error',entitlement});
        throw error;
      }
    }
    throw new Fault(404,'not_found');
  } catch(error) { return json({error:error instanceof Fault ? error.message:'service_unavailable'},error instanceof Fault ? error.status:503); }
}
export default {fetch(request, env) { return handle(request, env); }};
