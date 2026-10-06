# SPENVA — Play Console Release Checklist

## Store identity
- App name: Spenva
- Category: Finance
- Distribution price: Free
- Business model: Freemium + Google Play subscriptions
- Primary language: Indonesian (id-ID)
- Short description: Catat pemasukan dan pengeluaran lewat teks, suara, atau foto struk dengan mudah.

## Subscription catalog
Create 3 subscription products, each with 2 auto-renewing base plans:
- spenva_plus: monthly Rp15.000; yearly Rp149.000
- spenva_pro: monthly Rp39.000; yearly Rp349.000
- spenva_max: monthly Rp89.000; yearly Rp799.000
Do not create Free as a Play product. Do not create offers/free trials for launch baseline.

## Required Play/Cloud setup
1. Payments profile ready.
2. Google Play Developer API enabled.
3. Service account granted minimum Play Console API permission required to verify/acknowledge subscriptions.
4. Pub/Sub topic configured for Real-time Developer Notifications.
5. Authenticated Pub/Sub push subscription points to /v1/google-play/rtdn.
6. Internal testing track created; license testers added.
7. Production upload key / Play App Signing recorded.
8. Google OAuth Android client contains the SHA-1 certificates actually used by test and Play builds.

## App content
Prepare and review: Privacy Policy, Data Safety, App Access, Ads declaration, Target Audience (recommended 18+), Content Rating, Financial Features Declaration, account/data deletion path.

## Subscription policy
Settings/account must provide an easy path to Google Play Subscription Center. Cancellation does not immediately remove paid access when the paid period remains. Backend state comes from purchases.subscriptionsv2.get, with RTDN used as a refresh trigger.

## Store assets
Final icon; feature graphic; screenshots for text entry, Voice, receipt scan, transaction result, reports, AI Q&A, Drive backup, subscription/paywall.

## Release gates
flutter analyze; flutter test; AAB release build; internal-track install; purchase each base plan; restore; renewal; cancel; grace period; on-hold; expiration; refund/revoke; reinstall; second-device login; offline core workflow.
