> **Verifikasi +18 selesai:** runtime `7bfd653d6dfe3a893c1c2252a1f345f48f5a9122`; Flutter 134 lulus, backend 46 lulus, validator 5 lulus, suite Play 11 lulus dan integrasi Linux 1 lulus. Signed AAB 75.1 MB lolos pemeriksaan 16 KB. [CI](https://github.com/rama160/Finchat/actions/runs/37464173519), [AAB/APK](https://github.com/rama160/Finchat/actions/runs/37464173519/artifacts/11413279142). Pembelian dan deployment subscription belum aktif. Detail hasil: [VALIDATION.md](docs/playstore/VALIDATION.md).

> **Subscription baseline 0.3.4+18 — 6 Oktober 2026**
> Paket/harga/kuota baru dari instruksi pengguna menggantikan penawaran +17: Free/Plus/Pro/Max, bulanan/tahunan, kuota Voice/Scan/AI terpisah dan serverpersisten. Implementasi dan batas aktivasi: [SUBSCRIPTION.md](docs/playstore/SUBSCRIPTION.md). Pembelian/server belum live. Gemini unpaid tidak menerima catatan pribadi; tidak ada paidtierotomatis. Riwayat di bawah dipertahankan.

> **Play Store preparation — 0.3.3+17 (6 Oktober 2026)**
> Free mempertahankan fungsi lokal yang sudah berjalan. Empat tier disiapkan melalui Google Play Billing; AI Play memerlukan verifikasi server, provider berbayar dan persetujuan18+. Application ID/database/OAuth/Drive tetap. Workflow Play terpisah menyiapkan AAB; publikasi dan pembelian belum aktif karena Play Console, identitas/kontak publik serta konfigurasi produk/provider belum tersedia. Panduan dan status aktual: [docs/playstore/LAUNCH.md](docs/playstore/LAUNCH.md), [paket](docs/playstore/PLANS.md), [data](docs/playstore/DATA_SAFETY.md). Catatan di bawah mempertahankan riwayat pilot, bukan klaim bahwa pembayaran sudah live.

## Verified GitHub CI — Spenva 0.3.2+16 (6 Oktober 2026)

- Kode/aset teruji pada commit `b85997e29533040e483036cabf3153dca6a8a548`, branch `codex/finchat-input-navigation-audit`. Commit dokumentasi setelahnya tidak mengubah runtime/aset.
- Flutter 3.47.6; analyze **No issues found** dan **120 tests passed** pada kedua workflow: https://github.com/rama160/Finchat/actions/runs/37410578014 dan https://github.com/rama160/Finchat/actions/runs/37410573458 .
- Signed release APK **92.8MB**, version APK/Pengaturan `0.3.2+16`, launcher Spenva: https://github.com/rama160/Finchat/actions/runs/37410573458/artifacts/11389451246 .
- Permanent FinChat keystore; SHA-1 sertifikat `CA:AA:59:2F:EC:CA:7C:8B:8B:16:C0:83:30:7D:43:A3:25:76:2E:10`, sama dengan APK +15. Pasang sebagai pembaruan tanpa uninstall/hapus data.
- ZIP artifact SHA-256 `c817655ea2d9797df8cc1bacc979d3f7d5a3f9097de0ca39f5a3503d9460245f`; ukuran ZIP 42834013 bytes. Ini hash arsip artifact, bukan hash APK di dalamnya.
- Regresi baru: kategori gaji yang hilang setelah restore ditambahkan tanpa mengganti kategori/mapping pengguna; gaji 5000000 tersimpan sebagai income; nominal 100/160000/567765/100000000 dan Rp .567.678; Input kosong tanpa Halo; composing range tetap ada tanpa underline; pertanyaan tanpa Semua tanggal; kartu full-width dengan jutaan/teks besar; Saldo; PDF dari ikon download tetap simpan/bagikan.
- Logo mark/header/sign in/Android terpisah mengikuti outline bentuk dan wordmark referensi. Foreground adaptive memakai aset monogram yang sama dengan referensi ikon. Semua aset/font tetap dibundel/offline.
- Manifest cocok dengan **173 file** remote. Tiga workflow asli, UPDATE_GITHUB.bat, database/schema/lifecycle, repository transaksi, MoneyAmountParser, autentikasi Google, gateway dan format backup byte-identical terhadap +15. Main tetap `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`.
- Source ZIP: https://github.com/rama160/Finchat/archive/refs/heads/codex/finchat-input-navigation-audit.zip . PR: https://github.com/rama160/Finchat/pull/1 .
- GitHub membuktikan tes dan build, bukan pengujian perangkat fisik. Uji ulang logo/layout, IME asli dan pemasukan setelah restore di HP dengan APK +16. Header ini menggantikan status pending pada catatan implementasi +16.

## Spenva 0.3.2+16 — perbaikan hasil uji HP (6 Oktober 2026)

- Perbaikan formatter digit: tidak lagi menyisipkan titik di awal angka 3/6/9 digit. Semua tampilan, jawaban AI/lokal dan PDF memakai `Rp 567.765`; jawaban provider seperti `Rp .567.678` dinormalisasi.
- Logo mark/header/sign in/launcher menggunakan outline bentuk dan wordmark dari referensi pengguna; tidak menggunakan font pengganti atau gambar pratinjau penuh. Aset terpisah dibundel offline, termasuk foreground adaptive Android.
- Input kosong benar-benar kosong (tanpa ikon dompet, Halo/email atau petunjuk lama). Header sapaan lokal tetap. Composer tidak menggambar underline composing IME, tetap menjaga range/fokus/keyboard; koreksi otomatis/saran/ejaan dimatikan pada kotak input.
- Kartu pemasukan/pengeluaran memakai lebar penuh dan tinggi mengikuti isi, tanpa ellipsis. Selisih periode menjadi Saldo. Tombol Ekspor PDF bawah dihapus; ikon download atas tetap membuka simpan ke perangkat/bagikan PDF.
- Pertanyaan tanpa periode eksplisit langsung dijawab tanpa awalan Semua tanggal. Tanggal/rentang eksplisit tetap dipakai untuk data dan label jawaban.
- Kategori standar memakai nama umum (Makanan dan minuman, Tagihan, Kesehatan, Transportasi, Kebutuhan rumah tangga, Hiburan, Lainnya); ID dan data lama tidak diubah. Kategori impor per-item disembunyikan dari pilihan, kategori buatan pengguna dan pembelajaran tetap dipertahankan.
- Setelah restore parsial, repository kategori menambahkan standar yang hilang dengan insert-ignore tanpa mengganti data/kategori yang sudah ada. Ini menutup kegagalan foreign-key saat gaji pertama setelah backup yang tidak memuat kategori gaji. Input gaji/upah tetap pemasukan; nominal gaji tanpa Rp seperti `gaji 5000000` kini diproses lokal.
- Application ID, database/schema, autentikasi, gateway, format backup, MoneyAmountParser, repository transaksi dan tiga workflow asli dipertahankan. Versi APK/Pengaturan 0.3.2+16.
- Verifikasi GitHub analyze/test/build berhasil: 120 tes lulus dan APK signed 92.8MB (lihat bukti di atas). Pengujian IME/mikrofon dan pemasangan APK masih perlu di HP.

## Verified GitHub CI — Spenva 0.3.2+15 (6 Oktober 2026)

- Runtime/test commit `0b9d9b0ca738f4c28a3847581920c07b9d08c933`, branch `codex/finchat-input-navigation-audit`. Dokumen final sesudah commit ini tidak mengubah kode/aset yang diuji.
- Flutter 3.47.6, analyze No issues found, **119 tests passed** pada kedua workflow: https://github.com/rama160/Finchat/actions/runs/37401893802 dan https://github.com/rama160/Finchat/actions/runs/37401889047 .
- Signed release APK **92.6MB**, permanent FinChat release keystore, label launcher Spenva, versi aplikasi/Pengaturan `0.3.2+15`: https://github.com/rama160/Finchat/actions/runs/37401889047/artifacts/11385802047 .
- Hash SHA-256 ZIP artifact `fd700715fc5794c9b803eaef53a1e2ad7c1a30a048916c2c38e43e7254ab16b8`; ini hash arsip artifact, bukan hash APK di dalamnya.
- Regresi: composer 360 px/teks 1,6× dengan keyboard, fokus/rect/draft yang stabil saat kirim; timeline campuran; SQLite gaji 5 juta; dua transaksi suara pada callback frasa/cumulative/final; Drive authorization `promptIfUnauthorized=false` dan 0 authenticate/lightweight calls; sign in 320 px/teks 1,8×; nominal jutaan dan simpan/bagikan PDF.
- Semua aset/logo, subset font Latin/simbol DejaVu beserta lisensi, dekorasi dan animasi singkat native Flutter dibundel. Tidak memakai gambar pratinjau sebagai halaman aplikasi atau aset/font yang diambil dari internet saat berjalan.
- Main tetap `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`. Tiga workflow asli, UPDATE_GITHUB.bat, database/schema/lifecycle, parser nominal, repository transaksi, kunci sesi dan format/file Drive byte-identical terhadap baseline. Application ID/OAuth/Gateway dipertahankan. Manifest cocok dengan seluruh **170 file** remote.
- Source: https://github.com/rama160/Finchat/archive/refs/heads/codex/finchat-input-navigation-audit.zip . PR: https://github.com/rama160/Finchat/pull/1 .
- **Retest HP:** microphone/segmen ucapan nyata, IME, dialog Google native dan system save picker/lokasi PDF. Bila token Drive tidak tersedia tanpa UI, backup otomatis dilewati sampai pengguna memberi otorisasi lewat menu Backup; data lokal tetap utuh. CI membuktikan kontrak dan layout simulasi, bukan pengujian perangkat fisik.
- Pasang APK sebagai pembaruan aplikasi lama dengan application ID dan signing yang sama; tidak perlu menghapus aplikasi/data. Bagian ini menggantikan status pending pada patch +15 di bawah.

## Spenva device follow-up — 0.3.2+15 (6 Oktober 2026)

- Nama yang tampil menjadi Spenva; application ID `com.finchat.finchat`, nama package Dart, schema/database `finchat.db`, kunci session, backup format/file Drive, Google OAuth, endpoint Gateway dan workflow asli dipertahankan.
- Aset logo sign in/header/launcher terpisah; source SVG berupa outline dan PNG dibundel. Font DejaVu Sans + lisensi, dekorasi dan animasi singkat native Flutter dibundel/offline. Halaman aplikasi dibangun dari widget, bukan gambar pratinjau. Sapaan mengikuti jam lokal perangkat dan nama depan displayName; tanpa nama tidak memakai email sebagai nama.
- Sign in baru mempertahankan Google dan email lokal. Mode offline tanpa email menggunakan `offline@finchat.local`; email lokal lama tetap dapat dimasukkan untuk membuka datanya. Tidak menghapus/migrasi data saat rebranding.
- Rupiah terpusat: `Rp 15.000`, tanpa titik setelah Rp, termasuk respons AI dan PDF. Saldo negatif `-Rp 15.000`.
- Suara mempertahankan hipotesis transaksi lengkap saat Android hanya mengirim frasa terakhir, menggabungkan final/cumulative tanpa duplikasi dan menunggu 400 ms agar final tidak langsung dikonsumsi. Nominal jelas tetap diproses lokal dalam satu batch. Mic Android masih memerlukan retest perangkat.
- Kata pemasukan: gaji/gajian/upah/honor/bonus/komisi/THR/dividen/insentif/hasil penjualan/uang masuk. Bayar upah tetap pengeluaran. MoneyAmountParser dan repository transaksi tidak diubah; tes gaji 5 juta mencakup penyimpanan SQLite dari composer.
- Backup otomatis tidak memanggil authenticate atau attemptLightweightAuthentication. authorizationForScopes hanya mengambil token tanpa UI; bila perlu otorisasi, backup dilewati sampai pengguna menghubungkan Drive lewat tombol yang tersedia. Google lightweight authentication tetap hanya pada jalur AI yang diminta pengguna, bukan backup otomatis.
- Ringkasan laporan adaptif: dua kartu seimbang pada lebar yang cukup, kartu penuh pada layar kecil/teks besar, tanpa ellipsis nominal. Caption dan insight memakai kalimat natural dari data terpilih, tidak mengulang statistik satu hari sebagai pola panjang.
- Kalender tanpa chip Tanggal/Rentang/Bulan/Tahun; pemilih bulan di atas tahun. Klik satu hari lalu Pilih untuk tanggal tunggal; klik hari kedua untuk rentang, klik berikutnya memulai rentang baru. Sebulan penuh/Setahun penuh mempertahankan kemampuan periode penuh. Range sebulan/setahun otomatis dinormalisasi seperti sebelumnya.
- PDF menawarkan Simpan ke perangkat melalui Android file picker atau Bagikan PDF melalui printing. PDF generator, detail/filter dan pemulihan backup tetap berfungsi.
- Status verifikasi: analyze bersih, 119 tes lulus dan signed APK berhasil. Bukti final ada di atas; uji HP tetap diperlukan untuk speech, IME asli, dialog Google dan lokasi penyimpanan Android.

## Verified GitHub CI — 0.3.2+14 (5 Oktober 2026)

- Runtime/test commit `f36a3c11f0bd581e0a4d50f4d9d5d1b20959aa86`, branch `codex/finchat-input-navigation-audit`. Dokumen verifikasi sesudah commit ini tidak mengubah runtime.
- Audit https://github.com/rama160/Finchat/actions/runs/37329235611 dan workflow Flutter asli https://github.com/rama160/Finchat/actions/runs/37329255297 berhasil: Flutter 3.47.6, analyze No issues found, **111 tests passed** pada kedua workflow.
- Signed release APK **92.3 MB**, menggunakan permanent FinChat release keystore: https://github.com/rama160/Finchat/actions/runs/37329235611/artifacts/11353523044 . Versi pubspec dan Pengaturan sama-sama `0.3.2+14`.
- ZIP artifact SHA-256 `c8a394280e1099888345c81a26f3dcdc4803e2387d11f96a69ca6d50f1b2a224`; ini hash arsip artifact, bukan hash APK di dalamnya.
- Regresi: fokus/keyboard/posisi composer, draft berikutnya, timeline campuran, kalender hari/rentang/bulan/tahun termasuk mempertahankan filter saat dibuka kembali, periode pertanyaan, insight/ringkasan grafik, suara multi transaksi tanpa AI, serta batch kategori struk sekali baca.
- Manifest uploader mencakup seluruh 153 file tracked termasuk helper, test dan workflow audit baru. Tiga workflow asli, schema/lifecycle database, repository transaksi, money parser dan OAuth/secrets dipertahankan. Main tetap `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`.
- Gateway 0.1.1 sudah diverifikasi terpisah HTTP200/622 ms: https://github.com/rama160/AI-Gateway/actions/runs/37316536289 . Catatan lama HTTP403/belum deploy di bawah adalah riwayat, bukan status terkini.
- **Uji HP masih diperlukan:** IME asli saat kirim, microphone multi transaksi, kamera/attach OCR dan pengukuran latency struk. Tes batch membuktikan satu pembacaan pemetaan kategori, bukan peningkatan waktu OCR pada perangkat.
- Bagian ini menggantikan status verifikasi tertunda dan hasil versi lama di bawah.

## Device UX follow-up — 0.3.2+14 (5 Oktober 2026)

- Chat: transaksi dan Q&A tersusun berdasarkan waktu dalam satu timeline; pesan baru muncul paling bawah. Input dan status memiliki tinggi tetap, fokus/keyboard dipertahankan saat kirim, dan draft berikutnya tidak dikosongkan setelah proses sebelumnya selesai.
- Halaman Input tidak memiliki filter tanggal. Periode pertanyaan dibaca dari teks (hari/rentang/bulan/tahun); tanpa periode eksplisit, pertanyaan memakai seluruh riwayat. Daftar transaksi harian tetap reset tampilan saat berganti hari tanpa menghapus database.
- Header filter Laporan tetap sama; klik langsung membuka kalender Minggu–Sabtu dengan pilihan tanggal, rentang, bulan dan tahun. Satu bulan/tahun lengkap dikenali otomatis.
- Keterangan grafik berada di bawah grafik dan merangkum data, bukan fungsi. Total, pie, PDF dan insight tetap mengikuti periode; grafik satu hari tetap membandingkan dengan hari sebelumnya.
- Insight: arus kas, rata-rata belanja termasuk hari nol, puncak belanja, perubahan harian dan transaksi berulang/ukuran transaksi. Tidak menyimpulkan kondisi pendapatan keseluruhan saat pemasukan belum tercatat.
- Suara: sesi dictation, nominal kata/angka dan harga tanpa pemisah diproses lokal sebagai multi transaksi. Batas durasi/pause tetap dapat dibatasi Android; kualitas mic harus diuji di HP.
- Struk: satu batch category learning, tanpa parse ulang tiap produk, recognizer dipakai ulang selama layar hidup; resize kamera mengikuti batas OCR dan file sementara tidak memakai fsync. Review dan koreksi kategori tetap wajib. Tidak ada klaim pengurangan latency HP sebelum pengukuran perangkat.
- Schema, lifecycle database, money parser, transaction repository, OAuth/secrets, endpoint Gateway dan workflow asli dipertahankan.
- Status verifikasi patch ini: analyze bersih, 111 tes lulus dan signed APK berhasil; bukti final ada di atas. Tes regresi mencakup keyboard/fokus/posisi input, draft berikutnya, urutan chat, kalender, scope pertanyaan, insight, multi suara dan batch struk.
- Gateway terpisah telah diperbarui ke 0.1.1 dan live provider berhasil HTTP200/622 ms, endpoint probe dihapus. Bukti https://github.com/rama160/AI-Gateway/actions/runs/37316536289 . Catatan lama “belum deploy/HTTP403” di bawah adalah riwayat dan sudah digantikan hasil Gateway terbaru.

## Verified GitHub CI — 0.3.2+13 (5 Oktober 2026)

- Tested code commit `02ea7a394e0af7afaedc85db5f44bf1ccef4aec3`, branch `codex/finchat-input-navigation-audit`.
- Run https://github.com/rama160/Finchat/actions/runs/37301937885 — success. Flutter stable 3.47.6: dependency resolution passed; analyze No issues found; **100 tests passed**; signed release APK **92.2 MB** built.
- APK: https://github.com/rama160/Finchat/actions/runs/37301937885/artifacts/11341239451 . Signing keystore and Google server client ID retained; no secrets changed.
- Regressions: Mahkota separate/noisy/column OCR and plain prices; exact keyword nota with zero AI calls; persistent typed categories and learning; inline save status; delete cancellation/confirmation; two-day comparison across year boundary; existing speech/token/Drive/storage/navigation tests.
- Gateway recovery snapshot: https://github.com/rama160/Finchat/actions/runs/37302216708 — npm ci, typecheck, lint, **17 tests** and Wrangler dry-run passed. Full corrected backend plus exact tested lockfile is included in the ZIP's separate AI-Gateway folder.
- GitHub write to rama160/AI-Gateway was rejected HTTP403 Resource not accessible by integration. No Gateway repo update or Cloudflare deployment occurred; live HTTP503 is not claimed resolved. Its main remains b7769af739b1550667c5a75e524d3d62e8f8a324.
- Finchat main remains 91252bddf4a4eadaa99dafe095f72c2e04a4bab1. Original three workflows, SQLite schema/lifecycle, money parser and transaction repository are byte-identical. Temporary backend snapshot validation is isolated in `codex/gateway-recovery-validation`; source ZIP retains the original workflow files.
- First run stopped on a redundant assertion warning, corrected. Second run exposed duplicate IDs caused by the test's frozen clock; its second input now advances the clock. Final suite and signed build passed. No product transaction-ID contract change.
- **Device/live gate open:** actual camera/attach OCR quality, Google/Gemini/Drive and report chart on Android must be retested. The fixture yields three products/Rp69.059; it is not a claim of real-device OCR success.
- This section supersedes older “verification pending” entries below. Final docs-only follow-up does not alter tested application code.

## Device receipt follow-up — 0.3.2+13 (5 Oktober 2026)

- Receipt parser joins product names with quantity/price rows, restores OCR column reading order from image coordinates, and excludes payment/header/footer rows. Mahkota Mart fixture: 3 items, Rp69.059; no payment or change recorded.
- Save success appears inline above the composer. Swipe delete requires explicit Hapus confirmation; Batal preserves data.
- Category edit accepts typed names and existing choices, persists custom categories without schema migration, and reuses the existing per-user correction learning.
- Single-day chart compares the previous day and selected day. Summary, pie and PDF retain the selected period only; date ranges/months retain daily buckets.
- Exact question “berapa total pengeluaran dengan kata acara, buat dalam bentuk nota” is answered locally from matching descriptions; it no longer requires Gateway.
- AI 503 remains an upstream operational issue until a corrected Gateway is deployed and tested against the real provider. Android OCR quality/camera/attach still requires device validation.
- Verification pending GitHub analyze/tests/signed APK. Original workflows, schema, database lifecycle, money parser and transaction repository retained.

## Verified GitHub CI — 0.3.2+12 (5 Oktober 2026)

- Tested code commit: `93ccf38c8a7d5e8be9e386d86321dd8f9bbaee8f`, branch `codex/finchat-input-navigation-audit`.
- Run https://github.com/rama160/Finchat/actions/runs/37293049436 — completed / success.
- Flutter stable 3.47.6: dependency resolution passed; `flutter analyze` No issues found; **94 tests passed**; release APK **92.0 MB** built successfully.
- APK artifact: https://github.com/rama160/Finchat/actions/runs/37293049436/artifacts/11337048743 (`finchat-audit-release-apk`). Permanent release keystore and build Google server client ID retained; no secrets changed.
- Regression coverage includes final-vs-partial speech callbacks, word/numeric amounts, local multi-item capture with zero AI calls, scoped nota and local saving tips, active token reuse/expiry/concurrent restoration/logout, daily view rollover preserving SQLite, daily expense zero buckets/total reconciliation, user error messages and existing Back navigation.
- First iteration had 86 passing / 1 failing word-number regression (hundred arithmetic), corrected. Second iteration passed 92 tests and signed build; final iteration adds daily-reset/error-message regressions and passes 94 tests and signed build.
- Main remains `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`; three original workflows, schema, database lifecycle and transaction repository unchanged. Docs-only follow-up uses `[skip ci]` and does not change tested code.
- **Device gate remains open:** actual receipt OCR/camera/attach, microphone recognition quality, live Google/Gateway token refresh and Drive must be tried on Android. CI and keep-rule mitigation do not prove the obfuscated native OCR NPE is resolved on the user's device.

## Follow-up regression coverage

- Android stopped/notListening status no longer submits an unfinished voice transcript; final nominal is required. Regression tests reproduce partial "nasi" arriving before final "nasi 10 ribu".
- Google ID-token session tests cover cached-login reuse, expiry/malformed tokens, single restoration for concurrent calls, sign-out and late restoration rejection. Cache remains in memory and no Google token is written to documentation/storage/logs.
- New widget regression verifies next-day resume hides previous-day items without deleting SQLite history.
- Initial device-patch CI: analyze passed, 86 passed/1 failed (word-number hundred arithmetic); corrected and re-run. Final results are recorded at the top of this document.

## Device follow-up — 0.3.2+12 (5 Oktober 2026)

- Capture teks/suara/struk kini menggunakan parser dan mapping lokal tanpa HTTP AI per item; mapping dibaca sekali per input. AI Q&A tetap tersedia sebagai fallback.
- Normalisasi nominal suara mendukung "nasi sepuluh ribu" serta "nasi 10 ribu".
- Provider AI menggunakan akun Google hasil authenticate yang diingat coordinator sebelum mencoba restorasi lightweight; JWT kedaluwarsa tidak digunakan dan cache dibersihkan saat sign-out.
- Pertanyaan nota dengan kata kunci menghitung dan merinci hanya deskripsi yang cocok; saran hemat dasar dapat dijawab lokal. Kendala yang belum didukung tidak diam-diam dijawab sebagai total keseluruhan.
- Input default hari ini; midnight/resume mengatur ulang tampilan harian dan Q&A tanpa menghapus data SQLite. Pertanyaan dan jawaban memakai bubble terpisah.
- Laporan mempertahankan total berdasarkan periode dan pie chart; bagian jumlah/detail transaksi di bawah chart diganti grafik pengeluaran harian. Hari tanpa pengeluaran bernilai nol; rentang/bulan mengikuti filter.
- Preprocessing gambar dipindahkan ke isolate. Error OCR tidak menampilkan stack trace di layar; cleanup recognizer tidak menimpa hasil. Keep rules native ML Kit/component registrar diperkuat untuk release.
- Tidak ada perubahan schema, database lifecycle, Drive backup, endpoint Gateway, secrets, atau tiga workflow asli. Perubahan login terbatas pada penyimpanan akun aktif, bukan alur pemilihan akun.
- Status: source patch teruji pada CI 37293049436; lihat hasil terbaru di atas. OCR native dan AI live perlu tes perangkat. Screenshot stack trace terobfuscate tidak cukup untuk memastikan akar NPE; keep rules adalah mitigasi release, bukan klaim hasil perangkat.

# AI START HERE — FINCHAT

## Hasil CI GitHub — 5 Oktober 2026

- Workflow: https://github.com/rama160/Finchat/actions/runs/37281161336 — SUCCESS.
- Commit kode teruji: d40976563b27c55395672c9428ef2c49ae4ea9cf, branch codex/finchat-input-navigation-audit.
- Flutter stable 3.47.6: pub get lulus; analyze No issues found; **84 tests passed**; release APK berhasil (91.8 MB).
- APK: https://github.com/rama160/Finchat/actions/runs/37281161336/artifacts/11332107826 (finchat-audit-release-apk).
- Signing memakai permanent FinChat release keystore; Google server client ID diberikan dari secret build. Tidak ada perubahan secrets.
- Perbaikan hasil CI: RootBackButtonDispatcher, callback void pada setState laporan, null-safe SQL acknowledgement; fixture tes widget memakai SQLite FFI tanpa isolate, runAsync untuk membuka DB, frame pump dan snackbar wait.
- Main dan tiga workflow lama tidak diubah. Workflow tambahan untuk validasi hanya aktif pada branch audit. Kamera/mic/OAuth/Gateway/Drive langsung pada Android masih membutuhkan QA perangkat; CI tidak membuktikan konektivitas layanan terdeploy.


## Current patch — 0.3.2+11 (2026-10-05)

Authoritative current audit: `docs/AUDIT_0.3.2+11.md`. Fixes RouterDelegate navigatorKey/system Back, CI FFI factory setup, integrated local/AI questions, money-in-question routing, guarded camera/file pickers, voice cancel callbacks, Google Drive snapshot acknowledgements, bottom navigation reports and shared smart period filter. Transaction cards use gestures only; white rounded composer includes emoji/attachment/camera/mic/send.

SQLite schema and existing workflows unchanged. Source is matched to main commit `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`. Flutter SDK unavailable locally; CI and real Android device acceptance are required. Baseline CI had 72 passed / 1 failed (global FFI factory test setup); do not describe the baseline result as verification of this patch.


## Current continuation point — Bugfix package 0.3.2+10

Read this file first, then:
1. `docs/FULL_REPOSITORY_AUDIT.md`
2. `docs/FINCHAT_MASTER_CONTEXT.md`
3. `docs/PRD.md`
4. `docs/ARCHITECTURE.md`
5. `docs/PHASES.md`
6. `docs/AI_CONTRACT.md`
7. `docs/IMPLEMENTATION_STATUS.md`
8. `CHANGELOG.md`
9. actual source code

## Current truth

- Technical work exists through Phase 12 hardening.
- This package fixes two device-reported runtime regressions without changing the established product workflow: `DatabaseException(error database_closed)` during text/voice/receipt transaction capture, and AI Gateway fallback being disabled by the legacy local `ai.enabled` gate.
- Production `FinChatDatabase()` instances now share one application database handle; screen-level `dispose()` calls no longer close that shared production connection. Custom database factory/path instances remain isolated for tests.
- The database open path is serialized and reopens a handle if the cached handle is no longer open.
- The AI provider is Gateway-first in production. It reuses the existing `GoogleSignInCoordinator` session configuration to obtain the logged-in Google ID token, then calls the Cloudflare Gateway. Gemini API credentials remain server-side. The legacy local AI enable switch is retained only when an `AiSecureConfigService` is explicitly injected, preserving existing test/config contracts.
- Google Sign-In and restore/migration behavior are intentionally left unchanged.
- Flutter/Dart SDK is not available in the artifact workspace, so local analyze/test/APK build is not claimed. A GitHub Actions run exposed analyzer-only issues in the AI provider/test fixture; those issues are fixed in 0.3.2+7. GitHub Actions remains the canonical verification environment.
- Real Android-device acceptance is still required for camera, microphone, OCR quality, Google Sign-In/OAuth, Google Drive and Gateway/AI behavior.

## Non-negotiable product rules

- Offline-first; SQLite is the source of truth.
- Local parser/category history first; AI only as fallback/support.
- AI never writes directly to SQLite.
- Text/voice transactions save immediately when recognized.
- Saved transactions expose swipe right to edit and swipe left to delete; no edit/delete buttons on transaction rows.
- User category corrections must be learned locally.
- Receipt images are preprocessed/compressed before OCR and reviewed before persistence.
- Common financial questions are answered from application-computed local report data before AI fallback.
- Automatic Drive backup requires one-time Google authorization; once enabled it is attempted on app load/data changes and must not block transaction capture.
- Every meaningful change updates changelog/status/audit documentation.
- Never force-push automatically.

## 0.3.2+8 analyzer follow-up

GitHub Actions reported two analyzer errors remaining in `lib/data/ai/openai_compatible_ai_provider.dart` after 0.3.2+7. They are fixed in this package:

- The optional `idTokenProvider` callback is now assigned through an initialized private final field in the constructor, removing `final_not_initialized_constructor`.
- `_chat()` copies the nullable callback into a local `tokenProvider` before invocation, so the non-null branch is promoted and `unchecked_use_of_nullable_value` is removed.
- No production workflow or business logic was changed.
- The Gateway endpoint, Google Sign-In coordinator, database lifecycle fix, restore flow, OCR, voice, transaction parsing, reports, backup, and GitHub workflow remain unchanged.


- Fixed `prefer_initializing_formals` in `OpenAiCompatibleAiProvider` without changing the public constructor argument `idTokenProvider` or Gateway behavior.
- Removed the unnecessary non-null assertion when invoking the injected ID-token provider.
- Rewrote the Gateway JSON test fixture with `jsonEncode()` so analyzer no longer reports unnecessary string escapes.
- No database, authentication, restore/migration, transaction, OCR, voice, report, backup, Gateway endpoint, or GitHub workflow logic was changed.

## Exact next gate

1. Run `UPDATE_GITHUB.bat` from the package root.
2. Confirm GitHub Actions passes `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --release`.
3. Fix any CI issue against this exact package without reverting the audit goals.
4. Perform the device acceptance matrix in `docs/FULL_REPOSITORY_AUDIT.md` and `docs/PHASE_12_HARDENING_MATRIX.md`.

## Handoff requirement

At the end of each patch, record current version, changed files, exact issue, exact fix, schema/data impact, tests/CI result, device result, and any remaining PRD gap.

### 0.3.2+9 analyzer follow-up
The CI analyzer reported two remaining errors in `openai_compatible_ai_provider.dart`. The constructor now uses an initializing formal for `_idTokenProvider`, and token-provider invocation uses explicit nullable-flow promotion. No existing workflow or business logic was changed.

### 0.3.2+10 database test follow-up
GitHub Actions reported one failing test after the analyzer fixes: `test/data_database_test.dart` failed with `Bad state: databaseFactory not initialized`. The cause was eager initialization of the static production `FinChatDatabase` singleton, which evaluated the global `databaseFactory` before `sqflite_common_ffi` test setup ran.

Fix: `FinChatDatabase._shared` is now a lazy getter backed by `_sharedInstance`. The global `databaseFactory` is therefore not read until the first production `FinChatDatabase()` call. This preserves the established production shared-connection behavior and `close()` protection, while allowing `setUpAll(sqfliteFfiInit)` to initialize the FFI factory first. No schema, business logic, restore flow, Google Sign-In, OCR, voice, AI Gateway, or GitHub workflow was changed.

Verification status: source-level fix prepared from CI failure. Run the canonical GitHub Actions sequence again: `flutter analyze`, `flutter test`, then release APK build.
