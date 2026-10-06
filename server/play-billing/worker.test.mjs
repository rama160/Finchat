import test from 'node:test';
import assert from 'node:assert/strict';
import {evaluatePurchase,verifyPurchase,handle,hash,Quota,PLANS} from './worker.mjs';
const now=Date.now(), future=new Date(now+86400000).toISOString();
const purchase=(patch={})=>({subscriptionState:'SUBSCRIPTION_STATE_ACTIVE',externalAccountIdentifiers:{obfuscatedExternalAccountId:'account'},acknowledgementState:'ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED',lineItems:[{productId:'finchat_pro_monthly',offerDetails:{basePlanId:'monthly'},autoRenewingPlan:{autoRenewEnabled:true},expiryTime:future}],...patch});
for(const state of ['SUBSCRIPTION_STATE_ACTIVE','SUBSCRIPTION_STATE_IN_GRACE_PERIOD','SUBSCRIPTION_STATE_CANCELED']) test('allows paid access until expiry: '+state,()=>assert.equal(evaluatePurchase(purchase({subscriptionState:state}),'account',now).tier,'pro'));
for(const state of ['SUBSCRIPTION_STATE_EXPIRED','SUBSCRIPTION_STATE_ON_HOLD','SUBSCRIPTION_STATE_PAUSED','SUBSCRIPTION_STATE_PENDING']) test('denies '+state,()=>assert.throws(()=>evaluatePurchase(purchase({subscriptionState:state}),'account',now)));
test('rejects wrong account, product, base plan, expired entitlement',()=> {
  assert.throws(()=>evaluatePurchase(purchase(),'other',now));
  for(const patch of [{productId:'attacker'},{offerDetails:{basePlanId:'annual'}},{expiryTime:new Date(now-1).toISOString()},{autoRenewingPlan:undefined}]) assert.throws(()=>evaluatePurchase(purchase({lineItems:[{...purchase().lineItems[0],...patch}]}),'account',now));
});
test('four-tier catalog has explicit AI limits',()=>assert.deepEqual(Object.values(PLANS).map(x=>x.limit),[100,300,1000]));
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
test('inactive subscription never calls Gemini',async()=> {
  const calls=[]; const response=await handle(await request('/v1/ai/chat',{messages:[{role:'user',text:'Question'}]}),{...env,PAID_AI_CONFIRMED:'true',GEMINI_API_KEY:'paid'},network(purchase({subscriptionState:'SUBSCRIPTION_STATE_EXPIRED',externalAccountIdentifiers:{obfuscatedExternalAccountId:account}}),calls));
  assert.equal(response.status,403); assert.equal(calls.filter(x=>x.url.includes('generativelanguage')).length,0);
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
  assert.equal([...quota.values.values()][0].count,1);
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
    assert.equal(response.status,tokens===undefined?503:413);assert.equal([...quota.values.values()][0].count,0);assert.equal(calls.filter(x=>x.url.endsWith(':generateContent')).length,0);
  }
});
