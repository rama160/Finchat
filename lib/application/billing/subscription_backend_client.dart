import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/billing/subscription_models.dart';

typedef IdTokenProvider=Future<String?> Function();

class BackendEntitlement {
  const BackendEntitlement({required this.tier,required this.status,this.expiryTime,this.autoRenew=false});
  final SubscriptionTier tier; final SubscriptionStatus status; final DateTime? expiryTime; final bool autoRenew;
  bool get hasPaidAccess=>tier!=SubscriptionTier.free&&(status==SubscriptionStatus.active||status==SubscriptionStatus.gracePeriod||status==SubscriptionStatus.canceled);
}
class SubscriptionBackendClient {
  SubscriptionBackendClient({required this.baseUri,required this.idTokenProvider,http.Client? client}):_client=client??http.Client();
  final Uri baseUri; final IdTokenProvider idTokenProvider; final http.Client _client;
  Future<Map<String,String>> _headers() async {
    final token=await idTokenProvider(); if(token==null||token.isEmpty) throw StateError('Google sign-in diperlukan.');
    return {'Authorization':'Bearer '+token,'Content-Type':'application/json'};
  }
  Future<BackendEntitlement> status() async {
    final r=await _client.get(baseUri.resolve('/v1/subscription/status'),headers:await _headers());
    if(r.statusCode!=200) throw StateError('Gagal memeriksa status langganan.');
    return _parse(jsonDecode(r.body) as Map<String,dynamic>);
  }
  Future<BackendEntitlement> verify(String purchaseToken) async {
    final r=await _client.post(baseUri.resolve('/v1/subscription/verify'),headers:await _headers(),body:jsonEncode({'purchaseToken':purchaseToken}));
    if(r.statusCode!=200) throw StateError('Pembelian belum dapat diverifikasi.');
    return _parse(jsonDecode(r.body) as Map<String,dynamic>);
  }
  BackendEntitlement _parse(Map<String,dynamic> j){
    final plan=(j['plan']??'FREE').toString().toLowerCase();
    final tier=SubscriptionTier.values.firstWhere((v)=>v.name==plan,orElse:()=>SubscriptionTier.free);
    final raw=(j['status']??'EXPIRED').toString().toLowerCase();
    final status=switch(raw){'active'=>SubscriptionStatus.active,'pending'=>SubscriptionStatus.pending,'grace_period'=>SubscriptionStatus.gracePeriod,
      'on_hold'=>SubscriptionStatus.onHold,'paused'=>SubscriptionStatus.paused,'canceled'=>SubscriptionStatus.canceled,'revoked'=>SubscriptionStatus.revoked,_=>SubscriptionStatus.expired};
    return BackendEntitlement(tier:tier,status:status,expiryTime:DateTime.tryParse((j['expiryTime']??'').toString()),autoRenew:j['autoRenew']==true);
  }
}
