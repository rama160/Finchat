import test from 'node:test';
import assert from 'node:assert/strict';
import {metered,monthlyPeriod,planFor} from './meter.mjs';
import {evaluatePurchase,PLANS} from './worker.mjs';
const now=Date.UTC(2026,9,6),base={active:true,tier:'basic',status:'ACTIVE',startsAt:'2026-10-01T00:00:00Z',expiresAt:'2027-10-01T00:00:00Z',basePlan:'yearly'};
function fixture(values=new Map()) {
 let queue=Promise.resolve();
 const state={storage:{get:async k=>structuredClone(values.get(k)),put:async(k,v)=>values.set(k,structuredClone(v)),setAlarm:async()=>{}},blockConcurrencyWhile:fn=>{const run=queue.then(fn);queue=run.catch(()=>{});return run;}};
 let id=0;
 return {values,run:(action,resource='voice',entitlement=null,time=now,extra={})=>metered(state,{action,resource,entitlement,operationId:'operation_'+(++id),...extra},time)};
}
test('source has 6 paid products and exact final quota/price matrix',()=>{
 assert.equal(Object.keys(PLANS).length,6);
 assert.deepEqual(['free','basic','pro','unlimited'].map(t=>{const p=planFor(t);return [p.monthly,p.yearly,p.voice,p.ocr,p.ai];}),[[0,0,10,5,5],[15000,149000,100,100,50],[39000,349000,500,500,200],[89000,799000,1500,1500,500]]);
});
for(const tier of ['free','basic','pro','unlimited'])test(tier+' voice/scan cap independent from AI',async()=>{
 const f=fixture(),ent=tier==='free'?null:{...base,tier}; const p=planFor(tier);
 for(let i=0;i<p.voice;i++){await f.run('reserve','voice',ent,now,{operationId:'v_'+String(i).padStart(8,'0')});await f.run('settle','voice',ent,now,{operationId:'v_'+String(i).padStart(8,'0'),success:true});}
 assert.equal((await f.run('reserve','voice',ent)).status,429);
 assert.equal((await f.run('reserve','ocr',ent)).status,200);assert.equal(f.values.get('meter').used.ai,0);
});
test('camera and attach use shared scan count, cancellation/failure refunds once',async()=>{
 const f=fixture();for(let i=0;i<5;i++)await f.run('reserve','ocr',null,now,{operationId:'scan_'+String(i).padStart(8,'0')});
 assert.equal((await f.run('reserve','ocr')).status,429);
 await f.run('settle','ocr',null,now,{operationId:'scan_00000000',success:false});await f.run('settle','ocr',null,now,{operationId:'scan_00000000',success:false});assert.equal(f.values.get('meter').used.ocr,4);
});
test('one successful local voice uses no AI; cloud voice uses both balances',async()=>{
 const f=fixture();await f.run('reserve','voice');await f.run('reserve','voice');await f.run('reserve','ai');
 assert.deepEqual(f.values.get('meter').used,{voice:2,ocr:0,ai:1,pdf:0});
});
test('atomic concurrent reservations do not exceed free voice cap',async()=>{
 const f=fixture();const results=await Promise.all(Array.from({length:20},()=>f.run('reserve')));assert.equal(results.filter(x=>x.ok).length,10);assert.equal(f.values.get('meter').used.voice,10);
});
test('logout/reinstall/restore reopen same server ledger without reset',async()=>{
 const f=fixture();await f.run('reserve');const restored=fixture(f.values);const state=await(await restored.run('state')).json();assert.equal(state.voice_used,1);
});
test('yearly plans refill monthly, end-of-month anchor and leap day remain correct',()=>{
 const ent={...base,startsAt:'2024-01-31T00:00:00Z',expiresAt:'2027-01-31T00:00:00Z'};
 const period=monthlyPeriod(ent,Date.UTC(2024,1,29));assert.equal(period.start,Date.UTC(2024,1,29));assert.equal(period.end,Date.UTC(2024,2,31));
});
test('month resets only at boundary; upgrades/downngrades retain usage',async()=>{
 const f=fixture();await f.run('reserve');await f.run('reserve','voice',base);await f.run('reserve','voice',{...base,tier:'pro'});await f.run('state','voice',null);assert.equal(f.values.get('meter').used.voice,3);
 await f.run('state','voice',null,Date.UTC(2026,10,1));assert.equal(f.values.get('meter').used.voice,0);
});
test('Free PDF one per month, paid PDF unlimited, basic usage retained on upgrade',async()=>{
 const f=fixture();await f.run('reserve','pdf');assert.equal((await f.run('reserve','pdf')).status,429);assert.equal((await f.run('reserve','pdf',base)).status,200);
});
test('invalid resource and duplicate pending operation cannot increase count',async()=>{
 const f=fixture();assert.equal((await f.run('reserve','unknown')).status,400);await f.run('reserve','voice',null,now,{operationId:'fixed_operation'});assert.equal((await f.run('reserve','voice',null,now,{operationId:'fixed_operation'})).status,409);assert.equal(f.values.get('meter').used.voice,1);
});
test('all monthly/yearly verified products preserve cancel/grace state until expiry',()=>{
 for(const [productId,offer] of Object.entries(PLANS))for(const status of ['ACTIVE','CANCELED','IN_GRACE_PERIOD']){
  const p={startTime:base.startsAt,subscriptionState:'SUBSCRIPTION_STATE_'+status,externalAccountIdentifiers:{obfuscatedExternalAccountId:'u'},lineItems:[{productId,offerDetails:{basePlanId:offer.cycle},autoRenewingPlan:{},expiryTime:base.expiresAt}]};const ent=evaluatePurchase(p,'u',now);assert.equal(ent.basePlan,offer.cycle);assert.equal(ent.active,true);
 }
});
test('Free-to-paid upgrade does not refill again at the old calendar boundary',async()=>{
 const f=fixture();await f.run('reserve');
 const ent={...base,startsAt:'2026-10-06T00:00:00Z'};
 await f.run('state','voice',ent);assert.equal(f.values.get('meter').end,Date.UTC(2026,10,6));
 await f.run('state','voice',ent,Date.UTC(2026,10,1));assert.equal(f.values.get('meter').used.voice,1);
 await f.run('state','voice',ent,Date.UTC(2026,10,6));assert.equal(f.values.get('meter').used.voice,0);
});
test('abandoned unlimited PDF operations expire without locking next reservations',async()=>{
 const f=fixture();for(let i=0;i<100;i++)await f.run('reserve','pdf',base);
 assert.equal((await f.run('reserve','pdf',base)).status,429);
 assert.equal((await f.run('reserve','pdf',base,now+86400001)).status,200);
 assert.equal(f.values.get('meter').used.pdf,101);
});
test('completion counters measure transactions in mixed batches and reject invalid event counts',async()=>{
 const f=fixture();await f.run('event','voice',null,now,{event:'local_success',count:3});await f.run('event','voice',null,now,{event:'cloud_success',count:1});
 assert.equal(f.values.get('meter').events.local_success,3);assert.equal(f.values.get('meter').events.cloud_success,1);assert.equal(f.values.get('meter').used.ai,0);
 assert.equal((await f.run('event','voice',null,now,{event:'local_success',count:-1})).status,400);
});
