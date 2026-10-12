# Validasi runtime dan build saat ini

**Versi sumber: 0.3.6+21**

Runtime, aset, dependency lock dan workflow diuji sebelum integrasi pada `570ef1a1c7597393e0e84786539f4fa12f84a350`, lalu seluruh workflow dijalankan ulang dan lulus dari **main** commit `678f08da89e9b39b170376032387d6c46a95dafc` (10 Oktober 2026). Commit final sesudahnya merapikan catatan bukti/audit serta memperluas daftar cleanup eksplisit BAT agar file usang dari overlay ZIP tidak masuk kembali; tidak mengganti runtime, dependensi atau workflow build. Daftar cleanup 28 path diperiksa statis, semuanya memang tidak ada pada source current; file lain tidak dihapus. Eksekusi BAT native Windows belum diuji. Integrasi ke sumber utama **main** melalui [PR #4](https://github.com/rama160/Finchat/pull/4). Gunakan main untuk ZIP/build harian. Hasil +19 dan branch lama bukan sertifikasi versi ini.

## Validasi versi 0.3.6+21

Perubahan +21 hanya versi rilis dan metadata dari pubspec; runtime fitur, dependency lock, signing dan schema tetap. Bukti +20 di bawah adalah riwayat dan tidak mengesahkan bundle +21. CI PR #6 harus menjalankan analyzer, Flutter tests, backend/tooling, native integration serta signed AAB/16 KB sebelum digunakan untuk Closed Testing.

## Verifikasi backend dan Alpha — 12 Oktober 2026

Runtime PR #5: `2d5dad92d9d44974e90d798c27ef1433222bfe75`. Source tetap 0.3.5+20; signing, application ID, schema SQLite, katalog harga dan kuota Production tidak diubah. Catatan 10 Oktober di bawah adalah bukti historis sebelum perubahan Alpha.

- Audit seluruh 205 tracked paths: metadata/generated/import/link/inventory konsisten; tidak ditemukan file byte-identical, conflict marker atau output/keystore tracked.
- Backend lokal: **49 tes lulus**, mencakup Google JWT signature/issuer/audience/expiry, kuota, feedback/deletion, admin-only grant, pencabutan Alpha, isolasi Google subject Production, operasi malformed dan penyelesaian reservasi yang dibuat sebelum Alpha. Tooling Android 3 dan bundle validator 5 lulus.
- Live Worker: `/health` 200 JSON `{service: spenva-play, version: 1}`; POST quota/state tanpa token 401 `authentication_required`, token invalid 401 `invalid_identity`; admin/testing-access tanpa izin 401 `admin_required`; feedback dan quota/reserve tanpa token 401. Respons JSON sesuai parser error Flutter.
- Deploy perbaikan Worker berhasil: deployment `08eed9cbedd04dfdb225082d831a2ae9`, 12 Oktober 2026 14:44 UTC. Binding QUOTA tetap namespace yang sama; FEEDBACK dan secret ADMIN_TOKEN dipertahankan dan diperiksa ulang. Personal AI dan education AI tetap false.
- CI final source `03fe5168df6b2f042eb37096e982b654700fa7b1`: [Flutter](https://github.com/rama160/Finchat/actions/runs/38265331669) dan [Play AAB + native integration](https://github.com/rama160/Finchat/actions/runs/38265328375) semuanya **success**. Analyzer No issues found; signed AAB 75.2 MB, signature dan 16 KB validation lulus. [AAB + laporan](https://github.com/rama160/Finchat/actions/runs/38265328375/artifacts/11754842319). PR #5 merged ke main `0c0b64754e6d8d0047f3542fc0c2430a245f8b58`; remote main dibaca ulang, seluruh tree byte-identical dengan source PR yang diuji, pubspec/AppConstants tetap 0.3.5+20. Pembaruan catatan bukti ini hanya dokumentasi, tidak mengganti runtime atau konfigurasi build.
- **Belum diverifikasi live:** login Google sah, reserve/settle dengan akun tester, read-after-write Durable Object/KV dan grant Alpha akun nyata. Koneksi Cloudflare mengonfirmasi keberadaan secret, tetapi tidak menyediakan nilainya atau Google ID token/subject tester. Jangan memakai email sebagai `hash(sub)`, token mock, atau mengganti secret agar tes tampak lulus. Aktivasi membutuhkan operator dengan ADMIN_TOKEN dan account ID SHA-256 dari Google subject yang terverifikasi, lalu uji `/v1/quota/state` dengan login Google asli. Jangan kirim token/secret ke chat atau repository.
- Grant endpoint: POST `/v1/admin/testing-access`, admin bearer, body `{account: <64 hex SHA-256 Google sub>, enabled: true}`; pencabutan memakai `enabled: false`. State tester mengembalikan `testingAccess.enabled/localInput`; user lain tetap false. Voice/OCR/PDF tester tidak memotong kuota; cloud AI tetap kebijakan server. Tidak ada aktivasi pembelian subscription atau publikasi Play.

## Hasil executable

| Pemeriksaan | Hasil | Bukti |
|---|---|---|
| Source/generated metadata, import/link, JSON/asset dan manifest inventory | 205 tracked paths konsisten | Lokal dan semua workflow CI |
| Flutter 3.47.7 / enforced lock / analyzer | No issues found | [Flutter Test](https://github.com/rama160/Finchat/actions/runs/38011960209) |
| Flutter unit/widget/regression | 149 lulus, 2 conditional skips | Run Flutter di atas; diulang pada APK dan Play |
| Profil Play / quota | 11 lulus, 1 distribution-specific skip | [Prepare Play](https://github.com/rama160/Finchat/actions/runs/38011960173) |
| Screenshot actual app | Capture test lulus; 4 opaque PNG 1080×1920; sign-in/chat/report/calendar diperiksa visual | [Screenshot review pack](https://github.com/rama160/Finchat/actions/runs/38011960173/artifacts/11654565393) |
| Native Linux integration | 1 lulus: login offline, tiga transaksi termasuk gaji, database, laporan dan navigasi | Job integration pada run Prepare Play |
| Backend simulated tests | 46 lulus | Lokal dan job Prepare Play |
| Python Android template / bundle validator | 3 / 5 lulus | Lokal dan job Prepare Play |
| Play overlay | Idempotent; feature manifest tidak ganda | Lokal; bundle real diverifikasi CI |
| Signed APK pilot | Build/upload sukses, 93.8 MB | [APK run](https://github.com/rama160/Finchat/actions/runs/38011960144) |
| Signed AAB / manifest / native / ZIP 16 KB | Lulus; 12 native libraries diperiksa | Run Prepare Play; validation.json dan zipalign.txt di paket |

Dua skip pada suite normal adalah skenario bersyarat profil distribusi/capture; profile Play dan capture dijalankan terpisah. Native integration membuktikan runner Linux, bukan plugin HP Android. Source/metadata checks tidak menggantikan tes perilaku.

## Paket dan kecocokan versi

[Unduh APK pilot 0.3.5+20](https://github.com/rama160/Finchat/actions/runs/38011960144/artifacts/11654117263). APK sebenarnya berukuran **93835728 bytes**, SHA-256 `338d21e4cd2217f74d353a5e51880918d19ecdbe0ebd07fde2823942067620b9`. Manifest APK diekstrak dari binary Android XML dan dibaca ulang: package `com.finchat.finchat`, versionName `0.3.5`, versionCode `20`, min24/target36, debuggable false. Ini sama dengan pubspec dan versi Pengaturan `0.3.5+20`.

[Unduh paket AAB Play + APK validasi + laporan](https://github.com/rama160/Finchat/actions/runs/38011960173/artifacts/11654571013). AAB **75174096 bytes**, SHA-256 `46263dec78abe3189a06dcf921b58564f398616931f98f9c1574bb7718157075`. Universal APK untuk validasi Play **94104785 bytes**; berbeda dari APK pilot karena define distribusi. Bundletool manifest juga versionName0.3.5/versionCode20, package sama, min24/target36. `jarsigner`, ELF alignments, PAGE_ALIGNMENT_16K dan universal APK `zipalign -P 16` lulus. Lockfile dalam artifact byte-identical dengan repository.

Permanent upload certificate SHA-1 tetap `CA:AA:59:2F:EC:CA:7C:8B:8B:16:C0:83:30:7D:43:A3:25:76:2E:10` pada APK dan AAB. Artifact GitHub berakhir 8 Januari 2027; setelah itu rebuild dari source commit/main. Hash di atas adalah file APK/AAB di dalam arsip, bukan hash ZIP artifact.

Ketiga workflow main selesai **success** pada source commit di atas; artifact berasal dari main. Workflow main tersedia pada [Build Android APK](https://github.com/rama160/Finchat/actions/workflows/build_android.yml?query=branch%3Amain) dan [Prepare Play](https://github.com/rama160/Finchat/actions/workflows/play_store.yml?query=branch%3Amain). Source yang digabung harus cocok dengan tree PR; Remote main setelah merge dibaca ulang: pubspec `0.3.5+20`, AppConstants `0.3.5+20`; commit integrasi `678f08da89e9b39b170376032387d6c46a95dafc` mempunyai tree `2fd2156f23e0cd18a6b03e48cbc0bf3553e82b22`, sama persis dengan source/dokumentasi hasil audit.

## Batas hasil

Tidak ada deploy backend, aktivasi subscription/personal AI, pembelian nyata atau publikasi Console dalam audit ini. validation.json menyatakan technical_checks passed dan publication_ready false dengan **9 blocker**, persis [LAUNCH](LAUNCH.md). Provider/Gateway live, Google OAuth dari distribusi Play, Drive remote, real billing dan plugin kamera/mikrofon/picker/PDF/IME tetap memerlukan acceptance perangkat/layanan eksternal. Harga/kuota tidak diubah.

Regresi +20 mencakup build-only update, kategori initial/repair tanpa mengubah nama tersimpan, edit restored transaction yang mempertahankan FK history, stale Drive account setelah logout, invalid backup mappings/history ditolak sebelum delete. Suite lain tetap memverifikasi input/parser/nominal, laporan/periode/PDF, root navigation/logout, backup UTF-8/legacy/rollback dan kuota.

Flutter lokal tidak diinisialisasi ulang setelah automatic review sebelumnya memblokir percobaan metadata-service; analyze/test/build dijalankan melalui CI. Riwayat versi lama tersedia pada [indeks arsip](../history/README.md).
