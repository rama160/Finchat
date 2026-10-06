import test from 'node:test';
import assert from 'node:assert/strict';
import {evaluatePurchase,verifyPurchase,handle,hash,Quota,PLANS} from './worker.mjs';
const now=Date.now(), future=new Date(now+86400000).toISOString();
const purchase=(patch={})=>({subscriptionState:'SUBSCRIPTION_STATE_ACTIVE',externalAccountIdentifiers:{obfuscatedExternalAccountId:'account'},startTime:new Date(now-86400000).toISOString(),acknowledgementState:'ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED',lineItems:[{productId:'finchat_pro_monthly',offerDetails:{basePlanId:'monthly'},autoRenewingPlan:{autoRenewEnabled:true},expiryTime:future}],...patch});
for(const state of ['SUBSCRIPTION_STATE_ACTIVE','SUBSCRIPTION_STATE_IN_GRACE_PERIOD','SUBSCRIPTION_STATE_CANCELED']) test('allows paid access until expiry: '+state,()=>assert.equal(evaluatePurchase(purchase({subscriptionState:state}),'account',now).tier,'pro'));
for(const state of ['SUBSCRIPTION_STATE_EXPIRED','SUBSCRIPTION_STATE_ON_HOLD','SUBSCRIPTION_STATE_PAUSED','SUBSCRIPTION_STATE_PENDING']) test('denies '+state,()=>assert.throws(()=>evaluatePurchase(purchase({subscriptionState:state}),'account',now)));
test('rejects wrong account, product, base plan, expired entitlement',()=> {
  assert.throws(()=>evaluatePurchase(purchase(),'other',now));
  for(const patch of [{productId:'attacker'},{offerDetails:{basePlanId:'invalid'}},{expiryTime:new Date(now-1).toISOString()},{autoRenewingPlan:undefined}]) assert.throws(()=>evaluatePurchase(purchase({lineItems:[{...purchase().lineItems[0],...patch}]}),'account',now));
});
test('four-tier catalog has explicit AI limits',()=>assert.deepEqual(Object.values(PLANS).map(x=>x.limit),[50,50,200,200,500,500]));
const keys=await crypto.subtle.generateKey({name:'RSASSA-PKCS1-v1_5',modulusLength:2048,publicExponent:new Uint8Array([1,0,1]),hash:'SHA-256'},true,['sign','verify']);
const jwk=await crypto.subtle.exportKey('jwk',keys.publicKey); jwk.kid='test-key';
const privateKey=Buffer.from(await crypto.subtle.exportKey('pkcs8',keys.privateKey)).toString('base64');
const env={GOOGLE_CLIENT_ID:'client',PLAY_SERVICE_ACCOUNT_EMAIL:'service@example.invalid',PLAY_SERVICE_ACCOUNT_PRIVATE_KEY:'-----BEGIN PRIVATE KEY-----\n'+privateKey+'\n-----END PRIVATE KEY-----'};
const account=await hash('subject');
async function jwt(patch={}) {
  const head=Buffer.from(JSON.stringify({alg:'RS256',kid:'test-key'})).toString('base64url');
  const claims=Buffer.from(JSON.stringify({iss:'https://accounts.google.com',aud:'client',sub:'subject',iat:Math.floor(Date.now()/1000),exp:Math.floor(Date.now()/1000)+3600,...patch})).toString('base64url');
  const sig=Buffer.from(await crypto.subtle.sign('RSASSA-PKCS1-v1_5',keys.privateKey,Buffer.from(head+'.'+claims))).toString('base64url'); return head+'.'+claims+'.'+sig;
}
function network(data=purchase({externalAccountIdentifiers:{obfuscatedExternalAccountId:account}}), calls=[]) {
  return async(url, options={})=> {
    calls.push({url,options});
    if(url.endsWith('/certs'))return Response.json({keys:[jwk]});
    if(url==='https://oauth2.googleapis.com/token')return Response.json({access_token:'publisher-secret',expires_in:3600});
    if(url.includes('subscriptionsv2'))return Response.json(data);
    if(url.endsWith(':acknowledge'))return new Response(null,{status:204});
    if(url.endsWith(':countTokens'))return Response.json({totalTokens:100});
    if(url.endsWith(':generateContent'))return Response.json({candidates:[{content:{parts:[{text:'Jawaban'}]}}]});
    throw Error('Unexpected network call '+url);
  };
}
const request=async(path,body={},patch={})=>new Request('https://test'+path,{method:'POST',headers:{Authorization:'Bearer '+await jwt(patch),'Content-Type':'application/json','X-Play-Purchase-Token':'purchase-token'},body:JSON.stringify(body)});
test('server acknowledges only matching verified purchase',async()=> {
  const calls=[]; await verifyPurchase('token',account,env,network(purchase({externalAccountIdentifiers:{obfuscatedExternalAccountId:account},acknowledgementState:'ACKNOWLEDGEMENT_STATE_PENDING'}),calls));
  assert.equal(calls.filter(x=>x.url.endsWith(':acknowledge')).length,1);
  const rejected=[]; await assert.rejects(verifyPurchase('token','other',env,network(purchase(),rejected)));
  assert.equal(rejected.filter(x=>x.url.endsWith(':acknowledge')).length,0);
});
test('forged/expired/wrong audience identity denied before Publisher request',async()=> {
  for(const patch of [{aud:'attacker'},{exp:0},{iss:'invalid'},{iat:Math.floor(Date.now()/1000)+1000}]) {
    const calls=[]; const response=await handle(await request('/v1/purchases/verify',{purchaseToken:'token'},patch),env,network(undefined,calls));
    assert.equal(response.status,401); assert.equal(calls.filter(x=>x.url.includes('subscriptionsv2')).length,0);
  }
});
test('Play AI fails closed when billed provider is not configured',async()=>assert.equal((await handle(await request('/v1/ai/chat'),env,network())).status,503));
test('expired subscription falls back to free AI allowance',async()=> {
  const calls=[]; const response=await handle(await request('/v1/ai/chat',{messages:[{role:'user',text:'Question'}]}),{...env,PAID_AI_CONFIRMED:'true',GEMINI_API_KEY:'paid',QUOTA:fakeQuota().binding},network(purchase({subscriptionState:'SUBSCRIPTION_STATE_EXPIRED',externalAccountIdentifiers:{obfuscatedExternalAccountId:account}}),calls));
  assert.equal(response.status,200); assert.equal(calls.filter(x=>x.url.endsWith(':generateContent')).length,1);
});
function fakeQuota() {
  const values=new Map(); const state={storage:{get:async key=>structuredClone(values.get(key)),put:async(key,value)=>values.set(key,structuredClone(value)),list:async()=>new Map(values),delete:async key=>values.delete(key),setAlarm:async()=>{}},blockConcurrencyWhile:fn=>fn()};
  const instance=new Quota(state); return {values,instance,binding:{idFromName:x=>x,get:()=>({fetch:(url,opts)=>instance.fetch(new Request(url,opts))})}};
}
test('quota enforces cap, refunds failures and retains separate billing cycles',async()=> {
  const {instance,values}=fakeQuota();
  const call=(action,cycle='cycle')=>instance.fetch(new Request('https://internal',{method:'POST',body:JSON.stringify({action,cycle,limit:2,until:now+86400000})}));
  assert.equal((await call('reserve')).status,200);assert.equal((await call('reserve')).status,200);assert.equal((await call('reserve')).status,429);
  await call('refund');assert.equal(values.get('usage:cycle').count,1);assert.equal((await call('reserve','next-period')).status,200);
});
test('AI bounded model/output and refund on upstream error',async()=> {
  const quota=fakeQuota(), calls=[]; const options={...env,PAID_AI_CONFIRMED:'true',GEMINI_API_KEY:'paid',QUOTA:quota.binding};
  const net=network(undefined,calls); const body={messages:[{role:'user',text:'Question'}]};
  const response=await handle(await request('/v1/ai/chat',body),options,net); assert.equal(response.status,200);
  const generation=calls.find(x=>x.url.endsWith(':generateContent'));assert.match(generation.url,/gemini-2.5-flash-lite/); assert.equal(JSON.parse(generation.options.body).generationConfig.maxOutputTokens,768);
  const fail=async(url,opts)=>url.endsWith(':generateContent')?new Response(null,{status:503}):net(url,opts);
  assert.equal((await handle(await request('/v1/ai/chat',body),options,fail)).status,503);
  assert.equal(quota.values.get('meter').used.ai,1);
});
test('feedback is stored, requires real backend, deletion preserves other users',async()=> {
  const values=new Map([['report:other:one','other']]);
  const feedback={put:async(key,value)=>values.set(key,value),list:async({prefix})=>({keys:[...values.keys()].filter(x=>x.startsWith(prefix)).map(name=>({name})),list_complete:true}),delete:async key=>values.delete(key)};
  assert.equal((await handle(await request('/v1/feedback',{reason:'Wrong answer'}),{...env,FEEDBACK:feedback},network())).status,201);
  assert.equal(values.size,2); assert.equal((await handle(await request('/v1/delete-self'),{...env,FEEDBACK:feedback},network())).status,200);assert.equal(values.size,1);assert.ok(values.has('report:other:one'));
  assert.equal((await handle(await request('/v1/feedback',{reason:'Wrong answer'}),env,network())).status,503);
});
test('malformed or oversized input token counts prevent generation and refund quota',async()=> {
  for(const tokens of [undefined,5000]) {
    const quota=fakeQuota(),calls=[];const net=network(undefined,calls);
    const bounded=async(url,options)=>url.endsWith(':countTokens')?Response.json({totalTokens:tokens}):net(url,options);
    const response=await handle(await request('/v1/ai/chat',{messages:[{role:'user',text:'Question'}]}),{...env,PAID_AI_CONFIRMED:'true',GEMINI_API_KEY:'paid',QUOTA:quota.binding},bounded);
    assert.equal(response.status,tokens===undefined?503:413);assert.equal(quota.values.get('meter').used.ai,0);assert.equal(calls.filter(x=>x.url.endsWith(':generateContent')).length,0);
  }
});
async function freeRequest(path,body={}) {
 const r=await request(path,body);r.headers.delete('X-Play-Purchase-Token');return r;
}
test('signed Free quota ignores forged client plan and denies reserving server AI directly',async()=>{
 const q=fakeQuota(),options={...env,QUOTA:q.binding};
 const state=await handle(await freeRequest('/v1/quota/state',{tier:'unlimited',limit:999999}),options,network());
 assert.equal(state.status,200);const data=await state.json();assert.equal(data.plan_id,'free');assert.equal(data.limits.voice,10);assert.equal(data.personalAiEnabled,false);
 const denial=await handle(await freeRequest('/v1/quota/reserve',{resource:'ai',operationId:'forged_ai_id'}),options,network());assert.equal(denial.status,403);
});
test('verified server purchase survives reinstall without a device purchase token',async()=>{
 const q=fakeQuota(),options={...env,QUOTA:q.binding};
 assert.equal((await handle(await request('/v1/purchases/verify',{purchaseToken:'valid-token'}),options,network())).status,200);
 const state=await handle(await freeRequest('/v1/quota/state'),options,network());assert.equal((await state.json()).plan_id,'pro');
});
test('unpaid education sends fixed general topic only and refuses raw messages before provider call',async()=>{
 const q=fakeQuota(),calls=[],options={...env,QUOTA:q.binding,GEMINI_API_KEY:'free',PAID_AI_CONFIRMED:'false',UNPAID_EDUCATION_ENABLED:'true'};
 const net=network(undefined,calls);
 const accepted=await handle(await freeRequest('/v1/ai/chat',{topic:'budget',prompt:'private salary 1000000'}),options,net);
 assert.equal(accepted.status,200);
 const sent=calls.filter(c=>c.url.endsWith(':generateContent'));assert.equal(sent.length,1);assert.ok(!sent[0].options.body.includes('private salary'));assert.ok(sent[0].options.body.includes('konsep anggaran'));
 assert.equal((await handle(await freeRequest('/v1/ai/chat',{topic:'budget',messages:[{role:'user',text:'private salary'}]}),options,net)).status,503);
 assert.equal((await handle(await freeRequest('/v1/ai/chat',{topic:'not_allowed'}),options,net)).status,503);
 assert.equal(calls.filter(c=>c.url.endsWith(':generateContent')).length,1);
 assert.equal(q.values.get('meter').used.ai,1);
});
test('priority capacity reserves paid slots and releases them after completion',async()=>{
 const {instance}=fakeQuota();const call=(id,priority=false,release=false)=>instance.fetch(new Request('https://internal',{method:'POST',body:JSON.stringify({action:'capacity',operationId:id,priority,release})}));
 assert.equal((await call('standard1')).status,200);assert.equal((await call('standard2')).status,200);
 assert.equal((await call('standard3')).status,429);assert.equal((await call('premium3',true)).status,200);assert.equal((await call('premium4',true)).status,200);assert.equal((await call('premium5',true)).status,429);
 await call('standard1',false,true);await call('standard2',false,true);await call('premium3',true,true);assert.equal((await call('standard-new')).status,200);
});
test('AI fallback attempts/errors/timeouts are monitored separately from refunded credits',async()=>{
 const q=fakeQuota(),options={...env,QUOTA:q.binding,GEMINI_API_KEY:'paid',PAID_AI_CONFIRMED:'true'},net=network();
 const failed=async(url,opts)=>{if(url.endsWith(':generateContent'))throw new DOMException('Timeout','TimeoutError');return net(url,opts);};
 const result=await handle(await request('/v1/ai/chat',{purpose:'category_fallback',messages:[{role:'user',text:'categorize transaction'}]}),options,failed);
 assert.equal(result.status,503);const ledger=q.values.get('meter');assert.equal(ledger.used.ai,0);assert.equal(ledger.events.ai_requests,1);assert.equal(ledger.events.ai_by_plan.pro,1);assert.equal(ledger.events.fallback,1);assert.equal(ledger.events.timeout,1);
});
test('active purchase past paid expiry returns Free state without extra premium access',async()=>{
 const q=fakeQuota(),p=purchase({externalAccountIdentifiers:{obfuscatedExternalAccountId:account},lineItems:[{...purchase().lineItems[0],expiryTime:new Date(now-1).toISOString()}]});
 const response=await handle(await request('/v1/quota/state'),{...env,QUOTA:q.binding},network(p));assert.equal(response.status,200);assert.equal((await response.json()).plan_id,'free');
});
