// Separate from the pilot gateway. Deployment requires Play Console, a billed
// Gemini project, a Publisher API service account, KV and a Durable Object.
export const PACKAGE = 'com.finchat.finchat';
export const PLANS = Object.freeze({finchat_basic_monthly: {tier:'basic',limit:100}, finchat_pro_monthly:{tier:'pro',limit:300}, finchat_unlimited_monthly:{tier:'unlimited',limit:1000}});
const enc = new TextEncoder();
const b64 = bytes => btoa(String.fromCharCode(...new Uint8Array(bytes))).replaceAll('+','-').replaceAll('/','_').replace(/=+$/,'');
const unb64 = text => Uint8Array.from(atob(text.replaceAll('-','+').replaceAll('_','/')), c=>c.charCodeAt(0));
export const hash = async text => [...new Uint8Array(await crypto.subtle.digest('SHA-256',enc.encode(text)))].map(x=>x.toString(16).padStart(2,'0')).join('');
class Fault extends Error { constructor(status, message) { super(message); this.status=status; } }
const json = (value,status=200) => new Response(JSON.stringify(value),{status, headers:{'Content-Type':'application/json','Cache-Control':'no-store','X-Content-Type-Options':'nosniff'}});
export function evaluatePurchase(purchase, accountId, now=Date.now()) {
  if (!['SUBSCRIPTION_STATE_ACTIVE','SUBSCRIPTION_STATE_IN_GRACE_PERIOD','SUBSCRIPTION_STATE_CANCELED'].includes(purchase.subscriptionState)) throw new Fault(403,'subscription_inactive');
  if (purchase.externalAccountIdentifiers?.obfuscatedExternalAccountId !== accountId) throw new Fault(403,'account_mismatch');
  const lines = (purchase.lineItems ?? []).filter(x=>PLANS[x.productId] && x.offerDetails?.basePlanId === 'monthly' && x.autoRenewingPlan && Date.parse(x.expiryTime)>now);
  if (lines.length !== 1) throw new Fault(403,'invalid_product_or_expiry');
  const line=lines[0];
  return {active:true, accountId, tier:PLANS[line.productId].tier, limit:PLANS[line.productId].limit, productId:line.productId, expiresAt:line.expiryTime};
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
    const all=await this.state.storage.list({prefix:'usage:'}); let next=Infinity;
    for(const [key,value] of all) { if(value.until<Date.now()) await this.state.storage.delete(key); else next=Math.min(next,value.until); }
    if(Number.isFinite(next)) await this.state.storage.setAlarm(Math.min(next,Date.now()+86400000));
  }
}
async function readBody(request) {
  const text=await request.text(); if(enc.encode(text).length>20000) throw new Fault(413,'payload_too_large');
  try {return JSON.parse(text);} catch {throw new Fault(400,'invalid_json');}
}
async function quota(env, account, entitlement, token, action) {
  if(!env.QUOTA) throw new Fault(503,'quota_not_configured');
  const cycle=await hash(token+'|'+entitlement.expiresAt);
  return env.QUOTA.get(env.QUOTA.idFromName(account)).fetch('https://internal/',{method:'POST',body:JSON.stringify({cycle,action,limit:entitlement.limit,until:Date.parse(entitlement.expiresAt)+30*86400000})});
}
async function gemini(prompt,env,net) {
  const base='https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite';
  const headers={'Content-Type':'application/json','x-goog-api-key':env.GEMINI_API_KEY};
  const contents=[{role:'user',parts:[{text:prompt}]}];
  const count=await net(base+':countTokens',{method:'POST',headers,body:JSON.stringify({contents})});
  if(!count.ok) throw new Fault(503,'ai_unavailable');
  if((await count.json()).totalTokens>4096) throw new Fault(413,'input_token_limit');
  const answer=await net(base+':generateContent',{method:'POST',headers,body:JSON.stringify({contents,generationConfig:{temperature:0.1,maxOutputTokens:768,thinkingConfig:{thinkingBudget:0}}})});
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
      return json({reports,cursor:page.list_complete?null:page.cursor});
    }
    if(request.method!=='POST') throw new Fault(404,'not_found');
    const account=await identity(request,env,net);
    if(path==='/v1/feedback') {
      if(!env.FEEDBACK) throw new Fault(503,'reporting_not_configured');
      const body=await readBody(request);
      if(typeof body.reason!=='string' || !body.reason.trim() || body.reason.length>500 || (body.question!=null && (typeof body.question!=='string'||body.question.length>5000)) || (body.answer!=null && (typeof body.answer!=='string'||body.answer.length>10000))) throw new Fault(400,'invalid_report');
      const key='report:'+account+':'+crypto.randomUUID();
      await env.FEEDBACK.put(key,JSON.stringify({reason:body.reason,question:body.question,answer:body.answer,createdAt:new Date().toISOString()}),{expirationTtl:30*86400});
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
      const body=await readBody(request); return json(await verifyPurchase(body.purchaseToken,account,env,net));
    }
    if(path==='/v1/ai/chat') {
      if(env.PAID_AI_CONFIRMED!=='true' || !env.GEMINI_API_KEY) throw new Fault(503,'paid_ai_not_configured');
      const token=request.headers.get('X-Play-Purchase-Token'); const entitlement=await verifyPurchase(token,account,env,net);
      const body=await readBody(request); if(!Array.isArray(body.messages) || body.messages.length!==1 || body.messages[0]?.role!=='user' || typeof body.messages[0].text!=='string' || body.messages[0].text.length>10000) throw new Fault(400,'invalid_prompt');
      const reservation=await quota(env,account,entitlement,token,'reserve'); if(!reservation.ok) return reservation;
      try { return json({text:await gemini(body.messages[0].text,env,net)}); }
      catch(error) { await quota(env,account,entitlement,token,'refund'); throw error; }
    }
    throw new Fault(404,'not_found');
  } catch(error) { return json({error:error instanceof Fault ? error.message:'service_unavailable'},error instanceof Fault ? error.status:503); }
}
export default {fetch:handle};
