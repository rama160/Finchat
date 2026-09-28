# Multi-user AI dan Monetization Foundation

## Status pilot

Fondasi multi-user dan monetisasi sudah dibuat, tetapi monetisasi sengaja **OFF** sampai FinChat selesai diuji oleh beberapa pengguna.

Feature flags:

- `MonetizationConfig.enabled = false`
- `MonetizationConfig.subscriptionsEnabled = false`
- `MonetizationConfig.paymentsEnabled = false`

Tidak ada user yang ditagih oleh build pilot ini.

## Empat tier

1. Free
2. Basic
3. Pro
4. Unlimited

Keempat tier sudah memiliki model, ID, dan price-product placeholder. Hanya Free yang enabled pada pilot. Harga dan kuota belum diputuskan di source code agar tidak mengunci keputusan bisnis terlalu dini.

## Payment foundation

Payment method model sudah mencakup:

- QRIS
- GoPay
- Transfer Bank
- Kartu
- E-Wallet lainnya

`PaymentGateway` adalah kontrak provider. Credential payment tidak boleh ditanam di APK. Implementasi provider nantinya harus berada di backend.

## Arsitektur target

```text
FinChat Android
      |
      | HTTPS + Google ID token
      v
FinChat Backend / AI Gateway
      |
      +--> verify Google identity
      +--> resolve subscription tier
      +--> enforce usage limits
      +--> call Gemini API with server-side secret
      +--> call payment provider when enabled
```

## Subscription provider

Untuk Android, subscription digital perlu dipilih dengan mempertimbangkan Google Play Billing dan kebijakan distribusi aplikasi. Provider pembayaran eksternal seperti Xendit dapat menjadi backend payment option untuk skenario yang sesuai, tetapi integrasi produksi belum diaktifkan.

Jangan mengaktifkan pembayaran hanya dengan menyalakan feature flag. Sebelum production perlu diselesaikan: backend entitlement, webhook verification, idempotency, refund/cancel handling, invoice/status, Play Store policy review bila distribusi melalui Google Play, dan keamanan credential.
