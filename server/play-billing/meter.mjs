import {catalog} from './plans.generated.mjs';
export const planFor = tier => catalog.find(p=>p.tier===tier) ?? catalog[0];
const response=(body,status=200)=>Response.json(body,{status});
function addMonth(anchor,n) {
  const a=new Date(anchor), year=a.getUTCFullYear(), month=a.getUTCMonth()+n;
  const last=new Date(Date.UTC(year,month+1,0)).getUTCDate();
  return Date.UTC(year,month,Math.min(a.getUTCDate(),last),a.getUTCHours(),a.getUTCMinutes(),a.getUTCSeconds());
}
export function monthlyPeriod(entitlement,now=Date.now()) {
  if(!entitlement?.active) {const d=new Date(now);return {start:Date.UTC(d.getUTCFullYear(),d.getUTCMonth(),1),end:Date.UTC(d.getUTCFullYear(),d.getUTCMonth()+1,1)};}
  const expiry=Date.parse(entitlement.expiresAt), anchor=Date.parse(entitlement.startsAt);
  if(!Number.isFinite(anchor) || anchor>now || !Number.isFinite(expiry)) throw Error('invalid_billing_anchor');
  const a=new Date(anchor),d=new Date(now);let n=(d.getUTCFullYear()-a.getUTCFullYear())*12+d.getUTCMonth()-a.getUTCMonth();
  if(addMonth(anchor,n)>now)n--;
  return {start:addMonth(anchor,n),end:Math.min(addMonth(anchor,n+1),expiry)};
}
export async function metered(state,input,now=Date.now()) {
  return state.blockConcurrencyWhile(async()=> {
    const plan=planFor(input.entitlement?.tier), period=monthlyPeriod(input.entitlement,now);
    let ledger=await state.storage.get('meter');
    if(!ledger || now>=ledger.end) ledger={...period,used:{voice:0,ocr:0,ai:0,pdf:0},pending:{},events:{}};
    else if(ledger.start!==period.start || ledger.end!==period.end) {
      // Upgrade/downgrade never clears current usage; carry it to the new window.
      ledger.start=period.start;ledger.end=period.end;
    }
    // Expire abandoned reservations without refunding credits already consumed.
    for(const [key,value] of Object.entries(ledger.pending))if(value.at<now-86400000)delete ledger.pending[key];
    const limits={voice:plan.voice,ocr:plan.ocr,ai:plan.ai,pdf:plan.pdf};
    const snapshot=()=>({tier:plan.tier,plan_id:plan.id,subscription_status:input.entitlement?.status ?? 'FREE',billing_period_start:new Date(ledger.start).toISOString(),billing_period_end:new Date(ledger.end).toISOString(),used:ledger.used,limits,voice_used:ledger.used.voice,ocr_used:ledger.used.ocr,ai_used:ledger.used.ai,events:ledger.events});
    if(input.action==='state') {await state.storage.put('meter',ledger);await state.storage.setAlarm(ledger.end+30*86400000);return response(snapshot());}
    if(input.action==='event') {
      if(!['local_success','cloud_success','fallback','ai_error','timeout','rate_limit'].includes(input.event))return response({error:'invalid_event'},400);
      const count=input.count ?? 1;
      if(!Number.isInteger(count) || count<1 || count>1000)return response({error:'invalid_event_count'},400);
      ledger.events[input.event]=(ledger.events[input.event]??0)+count;
    } else if(input.action==='settle') {
      const reservation=ledger.pending[input.operationId];
      if(reservation) {
        if(input.success===false)ledger.used[reservation.resource]=Math.max(0,ledger.used[reservation.resource]-1);
        delete ledger.pending[input.operationId];
      }
    } else if(input.action==='reserve') {
      if(!Object.hasOwn(limits,input.resource) || typeof input.operationId!=='string' || !/^[a-zA-Z0-9_-]{8,100}$/.test(input.operationId))return response({error:'invalid_resource_or_operation'},400);
      if(ledger.pending[input.operationId])return response({error:'operation_already_reserved'},409);
      const limit=limits[input.resource];
      if(limit!==null && ledger.used[input.resource]>=limit) {ledger.events.rate_limit=(ledger.events.rate_limit??0)+1;await state.storage.put('meter',ledger);return response({error:'quota_reached',...snapshot()},429);}
      if(Object.keys(ledger.pending).length>=100)return response({error:'too_many_pending_operations'},429);
      ledger.used[input.resource]++;
      if(input.resource==='ai') {
        ledger.events.ai_requests=(ledger.events.ai_requests??0)+1;
        ledger.events.ai_by_plan ??= {};
        ledger.events.ai_by_plan[plan.id]=(ledger.events.ai_by_plan[plan.id]??0)+1;
      }
      ledger.pending[input.operationId]={resource:input.resource,at:now};
    } else return response({error:'invalid_action'},400);
    // Unsettled operations remain counted (reinstall/crash cannot grant new credits).
    for(const [key,value] of Object.entries(ledger.pending))if(value.at<now-86400000)delete ledger.pending[key];
    await state.storage.put('meter',ledger);await state.storage.setAlarm(ledger.end+30*86400000);
    return response(snapshot());
  });
}
