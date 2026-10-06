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
- Status verifikasi: menunggu GitHub analyze/tests/signed APK. Uji HP tetap diperlukan untuk speech, IME asli, dialog Google dan lokasi penyimpanan Android.

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

## Perubahan produk terbaru — 0.3.2+14

Chat tersusun berdasarkan waktu dengan pesan terbaru di bawah, composer/keyboard stabil, filter Input digantikan periode dalam pertanyaan. Laporan mempertahankan header filter; klik langsung menampilkan kalender dengan tanggal/rentang/bulan/tahun. Ringkasan grafik ditempatkan di bawah dan berisi angka/data periode. Insight mencakup arus kas, pola harian, perubahan, dan pengeluaran berulang. Input suara mendukung multi transaksi lokal; pemrosesan struk menghindari query/parse berulang dan tetap melalui review. Referensi audit: AUDIT_0.3.2+14.md.

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

## Verified GitHub CI — 0.3.2+12 (5 Oktober 2026)

- Tested code commit: `93ccf38c8a7d5e8be9e386d86321dd8f9bbaee8f`, branch `codex/finchat-input-navigation-audit`.
- Run https://github.com/rama160/Finchat/actions/runs/37293049436 — completed / success.
- Flutter stable 3.47.6: dependency resolution passed; `flutter analyze` No issues found; **94 tests passed**; release APK **92.0 MB** built successfully.
- APK artifact: https://github.com/rama160/Finchat/actions/runs/37293049436/artifacts/11337048743 (`finchat-audit-release-apk`). Permanent release keystore and build Google server client ID retained; no secrets changed.
- Regression coverage includes final-vs-partial speech callbacks, word/numeric amounts, local multi-item capture with zero AI calls, scoped nota and local saving tips, active token reuse/expiry/concurrent restoration/logout, daily view rollover preserving SQLite, daily expense zero buckets/total reconciliation, user error messages and existing Back navigation.
- First iteration had 86 passing / 1 failing word-number regression (hundred arithmetic), corrected. Second iteration passed 92 tests and signed build; final iteration adds daily-reset/error-message regressions and passes 94 tests and signed build.
- Main remains `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`; three original workflows, schema, database lifecycle and transaction repository unchanged. Docs-only follow-up uses `[skip ci]` and does not change tested code.
- **Device gate remains open:** actual receipt OCR/camera/attach, microphone recognition quality, live Google/Gateway token refresh and Drive must be tried on Android. CI and keep-rule mitigation do not prove the obfuscated native OCR NPE is resolved on the user's device.

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

# FinChat PRD

## Tujuan
Menyediakan aplikasi keuangan pribadi yang mudah digunakan, offline-first, dengan chat sebagai cara utama memasukkan dan menanyakan data keuangan.

## Functional requirements
- Login dan session persistence.
- Input transaksi melalui text, voice, attachment, camera.
- Satu input dapat menghasilkan beberapa transaksi.
- Edit tanggal, nominal, tipe, dan kategori.
- Parser lokal sebelum AI.
- AI fallback hanya saat parser lokal tidak cukup.
- Pembelajaran kategori dari koreksi user.
- Receipt preprocessing sebelum OCR.
- Reports income/expense dan detail transaksi.
- Pie chart expense per category dan jumlah transaksi.
- Chart/insight tambahan.
- Settings.
- Local storage.
- Offline backup/restore.
- Automatic Google Drive backup/restore setelah email dikonfigurasi.
- Update aplikasi tanpa kehilangan data.
- GitHub Actions untuk analyze/test/build.

## Acceptance baseline Phase 2
- Flutter project dapat dianalisis dan dites oleh GitHub Actions.
- Build Android tidak membutuhkan Flutter di komputer user.
- Uploader Windows tidak menghapus history remote.
- Divergent initial history ditangani dengan merge aman atau berhenti pada conflict.

## Phase 10 acceptance

- Session remains available after application restart unless the user logs out or the session is invalid.
- Settings exposes the application version and an update-check action.
- Update checking uses a provider abstraction and does not write to the local database.
- A newer GitHub Release can be opened by the user for download.
- Update checks do not silently install or overwrite application data.

## Product-completion rule

A technical phase may be marked as a baseline when its contracts/services/tests pass, but the original product acceptance criteria remain open until the corresponding UI/device/end-to-end behavior is implemented. See `docs/ROADMAP_AUDIT.md`.


## Phase 12 production-hardening acceptance
- Transaction writes are validated and multi-transaction saves are atomic.
- Invalid backup structures are rejected before destructive restore.
- AI configuration and network behavior fail safely.
- UI operation failures are surfaced without crashing the application.
- Release metadata is versioned without embedding signing credentials.
- Final acceptance requires CI plus one complete Android device QA cycle.

## Perbaikan produk 5 Oktober 2026

- Input bersama untuk transaksi pengeluaran/pemasukan dan pertanyaan lokal/AI; jawaban tampil di chat.
- Composer putih membulat dengan emoji, attachment, kamera langsung dan tombol biru mic/send/stop.
- Edit transaksi melalui swipe kanan, hapus melalui swipe kiri; ikon edit/hapus di row dihilangkan.
- Satu centang membuktikan penyimpanan SQLite; dua centang setelah backup Google Drive berhasil untuk versi transaksi tersebut.
- Laporan berada di bottom navigation dengan income/expense/saldo/count, pie kategori, detail, insight dan PDF.
- Filter hijau memiliki panah dan dropdown tanggal, rentang, bulan/tahun. Rentang satu hari menjadi tanggal; satu bulan lengkap menjadi bulan secara otomatis.
- System Back kembali ke submenu/halaman sebelumnya; dari tab Laporan kembali ke Input.
- Keberhasilan AI terdeploy dan plugin Android harus dikonfirmasi melalui CI dan QA perangkat, sesuai `AUDIT_0.3.2+11.md`.
