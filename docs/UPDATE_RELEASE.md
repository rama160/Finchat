> **Play Store preparation — 0.3.3+17 (6 Oktober 2026)**
> Free mempertahankan fungsi lokal yang sudah berjalan. Empat tier disiapkan melalui Google Play Billing; AI Play memerlukan verifikasi server, provider berbayar dan persetujuan18+. Application ID/database/OAuth/Drive tetap. Workflow Play terpisah menyiapkan AAB; publikasi dan pembelian belum aktif karena Play Console, identitas/kontak publik serta konfigurasi produk/provider belum tersedia. Panduan dan status aktual: [docs/playstore/LAUNCH.md](playstore/LAUNCH.md), [paket](playstore/PLANS.md), [data](playstore/DATA_SAFETY.md). Catatan di bawah mempertahankan riwayat pilot, bukan klaim bahwa pembayaran sudah live.

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

## Current device follow-up requirements — 0.3.2+13

- Scan struk kamera/lampiran tetap lokal: nama barang dan harga pada baris/kolom berbeda digabung berdasarkan posisi OCR, lalu item harus melalui review sebelum disimpan. Contoh Mahkota Mart berisi tiga item dengan total Rp69.059; total/tunai/kembali tidak menjadi transaksi.
- Pemberitahuan simpan berada dalam layout di atas composer, termasuk saat keyboard terbuka.
- Swipe hapus selalu meminta konfirmasi; Batal tidak menghapus. Edit kategori menerima teks bebas atau pilihan kategori, menyimpan kategori baru, dan mempelajari koreksi per pengguna.
- Filter satu hari menampilkan grafik dua bar: hari sebelumnya dan tanggal yang dipilih. Total/pie/PDF tetap hanya periode terpilih; rentang/bulan menggunakan grafik harian sesuai rentangnya.
- Pertanyaan “berapa total pengeluaran dengan kata acara, buat dalam bentuk nota” dijawab lokal dengan hanya deskripsi yang cocok; jawaban dan pertanyaan tetap terpisah.
- Perbaikan Gateway disediakan terpisah: HTTP503 live belum dinyatakan selesai sebelum source Gateway diterapkan dan permintaan autentikasi/provider nyata berhasil. Tidak mengubah schema, lifecycle database, kontrak penyimpanan, OAuth IDs, rahasia atau tiga workflow asli.

# Update & Release Guide

## Release source

FinChat uses GitHub Releases as the canonical public release source for the update checker.

Repository: `rama160/Finchat`

The application asks GitHub for the latest published release. Draft and prerelease versions are not used by the latest-release endpoint.

## App version

Keep these values aligned:
- `pubspec.yaml` → `version: major.minor.patch+build`
- `lib/core/constants/app_constants.dart` → `appVersion`
- GitHub Release tag → `vmajor.minor.patch`

The build number is local to the Flutter package; update comparison currently uses `major.minor.patch`.

## Release workflow

GitHub Actions:
1. checkout;
2. install Flutter stable;
3. `flutter pub get`;
4. `flutter analyze`;
5. `flutter test`;
6. create Android platform if missing;
7. apply Android security/speech configuration;
8. `flutter build apk --release`;
9. publish APK to GitHub Release.

## In-app update behavior

Settings → Periksa pembaruan:
- no newer release → show current version;
- newer release → show release version and open the GitHub release page;
- network/API failure → show an error without changing local data.

The checker does not silently install an APK.

## Data safety

Application updates must never delete the SQLite database. If a future release changes the schema, increment `FinChatDatabaseSchema.version` and add an explicit non-destructive `onUpgrade` migration.

Before a production release that changes schema:
- test upgrade from the previous release database;
- test backup before upgrade;
- test restore after upgrade;
- test rollback/recovery procedure where applicable.

## Current limitation

Direct in-app APK installation is intentionally deferred. Distribution strategy (GitHub APK, Play Store, or managed enterprise distribution) must be chosen before implementing installation-specific code.
