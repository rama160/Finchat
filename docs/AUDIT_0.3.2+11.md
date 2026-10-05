## Hasil CI GitHub — 5 Oktober 2026

- Workflow: https://github.com/rama160/Finchat/actions/runs/37281161336 — SUCCESS.
- Commit kode teruji: d40976563b27c55395672c9428ef2c49ae4ea9cf, branch codex/finchat-input-navigation-audit.
- Flutter stable 3.47.6: pub get lulus; analyze No issues found; **84 tests passed**; release APK berhasil (91.8 MB).
- APK: https://github.com/rama160/Finchat/actions/runs/37281161336/artifacts/11332107826 (finchat-audit-release-apk).
- Signing memakai permanent FinChat release keystore; Google server client ID diberikan dari secret build. Tidak ada perubahan secrets.
- Perbaikan hasil CI: RootBackButtonDispatcher, callback void pada setState laporan, null-safe SQL acknowledgement; fixture tes widget memakai SQLite FFI tanpa isolate, runAsync untuk membuka DB, frame pump dan snackbar wait.
- Main dan tiga workflow lama tidak diubah. Workflow tambahan untuk validasi hanya aktif pada branch audit. Kamera/mic/OAuth/Gateway/Drive langsung pada Android masih membutuhkan QA perangkat; CI tidak membuktikan konektivitas layanan terdeploy.

# Pembaruan verifikasi GitHub — 5 Oktober 2026

Workflow FinChat Audit Validation: https://github.com/rama160/Finchat/actions/runs/37281161336

Commit kode: d40976563b27c55395672c9428ef2c49ae4ea9cf. Pub get, analyze (No issues found), seluruh 84 flutter test, konfigurasi Android dan signing lulus. Build APK release lulus (91.8 MB), menggunakan permanent keystore; artifact 11332107826 tersedia. Main tetap pada baseline 91252bddf4a4eadaa99dafe095f72c2e04a4bab1. Tiga workflow lama tetap identik; workflow validasi tambahan hanya dipicu di branch audit.

Temuan CI tambahan: RootBackButtonDispatcher diperlukan untuk system Back pada RouterConfig; ReportScreen setState harus memakai callback void saat menetapkan Future; SQL cloud acknowledgement tidak boleh mengirim null sebagai whereArg. Ketiganya sudah diperbaiki. Tes widget memakai SQLite FFI tanpa isolate, database dibuka melalui runAsync, memompa frame setelah mengubah teks, menunggu snackbar dan menggulir ke submenu sebelum menekan tombol.

Catatan audit awal di bawah merupakan riwayat sebelum CI dan tidak menggantikan hasil verifikasi terbaru di atas.

# Audit dan perbaikan FinChat 0.3.2+11 — 5 Oktober 2026

## Sumber dan batas verifikasi

Audit terhadap `rama160/Finchat`, main commit `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`. Semua blob kode, workflow, dan dokumentasi cocok dengan paket 0.3.2+10. Perbedaan BAT hanya line endings. Kontrak AI diperiksa langsung pada `rama160/AI-Gateway` (`types.ts`, `validation.ts`, `gemini.ts`, `router.ts`). Tidak ada Flutter/Dart SDK di lingkungan lokal; pemasangan SDK diblokir akses jaringan. Hasil analyze/test/build versi ini harus diisi dari CI, bukan diasumsikan.

Log CI baseline: Flutter Test run `37245576604`, job `111562693997`: **72 passed, 1 failed**. Analyze baseline lulus. Tes singleton database gagal karena `sqfliteFfiInit()` tidak memasang global factory. Ini bukti baseline, bukan hasil patch ini.

## Temuan dan perbaikan

| Masalah | Temuan | Perbaikan |
|---|---|---|
| Tombol kembali keluar dari submenu | Navigator tidak menggunakan navigatorKey RouterDelegate dan RouterConfig tidak memiliki root back dispatcher | Hubungkan key dan RootBackButtonDispatcher pada RouterConfig; PopScope Laporan mengembalikan tab Input; submenu memakai stack Navigator yang sama |
| CI databaseFactory not initialized | setUpAll hanya sqfliteFfiInit | Pasang databaseFactoryFfi secara eksplisit; isolasi database tes ke direktori sementara |
| database_closed pada perangkat | Baseline terbaru sudah memiliki shared DB dan protected close | Pertahankan perbaikan produksi; layar baru memakai singleton yang sama; jangan menutup shared DB |
| AI tidak tersedia | Null menutupi auth, kuota, HTTP, timeout; request panjang melampaui kontrak | Pesan diagnostik aman; batas 10.000 karakter/20.000 byte; cuplikan 25 transaksi, total dihitung dari seluruh periode; timeout 65 detik untuk enam upaya model Gateway |
| Kategori AI tidak dikenali | Gemini bisa membungkus JSON dengan markdown | Lepas fence sebelum decode; daftar ID kategori aktual dari SQLite dikirim hanya saat fallback; validasi kategori tetap melalui repository lokal |
| Pertanyaan memuat nominal tersimpan sebagai transaksi | Routing mendahulukan nominal | Pertanyaan eksplisit didahulukan sebelum deteksi transaksi |
| Tanya AI terpisah | Chat membuka layar Tanya Keuangan | Pertanyaan dan jawaban tampil di chat yang sama; hapus menu Tanya AI dari Pengaturan |
| Input kamera/lampiran gagal diam-diam | Picker berada di luar try/catch OCR | Tangani error picker/read; cegah picker paralel; tombol kamera langsung; lampiran galeri/file tetap review OCR |
| Voice cancel memicu transcript lama | Callback stopped saat cancel sebelum transcript dibersihkan | Bersihkan transcript sebelum cancel; abaikan final result dari sesi yang dibatalkan; satu consume pending; batalkan microphone saat ganti tab/dispose |
| Tampilan input | Field kotak + tombol terpisah | Field putih rounded, emoji, paperclip, kamera, tombol biru mic/send/stop, preview transcript |
| Edit/hapus menghabiskan ruang | Ikon di setiap row | Hapus ikon row; swipe kanan edit, kiri hapus tetap memakai handler repository dan category learning |
| Centang cloud tidak memiliki bukti | sync_status belum dikonfirmasi setelah upload | Satu centang SQLite; dua centang biru setelah upload sukses, hanya versi row dalam snapshot yang seluruh field datanya masih cocok (termasuk edit pada milidetik yang sama); field null memakai IS NULL tanpa parameter null |
| Laporan di app bar | Akses via route | Bottom navigation Input/Laporan; detail, pie, count, insight, drill-down dan PDF dipertahankan |
| Filter tanggal | Selector/tab terpisah | Header hijau, panah sebelumnya/berikutnya, dropdown tanggal/rentang/bulan+tahun; satu model shared; bulan otomatis untuk rentang persis tanggal 1 sampai akhir bulan |
| Pie/detail memotong data | Pie hanya 8 kategori; detail hanya 30 group | Tampilkan seluruh kategori/group agar proporsi dan rincian sesuai total |
| Versi pengaturan tertinggal | appVersion 0.3.2+5 vs pubspec +10 | Keduanya 0.3.2+11 |

## Invarian dan dampak data

SQLite tetap source of truth. Tidak ada perubahan schema/version database, parser nominal, login/email user key, OAuth client ID, migrasi legacy, OCR preprocessing, API pembayaran, atau tiga workflow GitHub Actions. `sync_status` memakai kolom yang sudah ada; `backed_up` berarti backup snapshot Google Drive berhasil, bukan sinkronisasi dua arah atau database Claude. Tidak ada integrasi penyimpanan Claude dalam repo.

Input default menampilkan semua tanggal agar transaksi lama tetap terlihat. Filter memengaruhi daftar dan periode pertanyaan. Kata hari ini/kemarin/minggu ini/bulan ini/bulan lalu mengganti periode pertanyaan secara eksplisit. Tanggal pencatatan transaksi baru tetap hari ini seperti baseline; tanggal transaksi dapat dikoreksi dengan swipe edit. Percakapan Q&A tersimpan selama layar Input aktif, belum memiliki tabel riwayat chat permanen.

AI kategori tetap fallback; kegagalan AI tidak membatalkan transaksi lokal. Jawaban angka umum tetap dihitung lokal. Cuplikan AI diberi label tidak lengkap dan tidak boleh digunakan untuk mengarang rincian di luar cuplikan. Kesehatan Gateway terdeploy, secrets, kesamaan audience Google client ID, kuota/model aktual dan izin Android belum dibuktikan oleh tes lokal.

## Tes regresi

Tambahan: `selected_period_test.dart`, `input_intent_test.dart`, `gateway_contract_test.dart`, `cloud_acknowledgement_test.dart`, `navigation_back_test.dart`. Tes database baseline diperbaiki; integration shell mengikuti tombol mic/send dinamis. Pemeriksaan lokal lulus: hash bagian yang dipertahankan termasuk ketiga workflow, gate workflow, pemeriksaan delimiter Dart konservatif (bukan compiler), fixture konfigurasi Android Groovy/Kotlin beserta idempotensi dan permissions, manifest paket, kesamaan versi. Tes Flutter baru belum dieksekusi. Wajib CI: pub get, analyze, full flutter test, release APK. Device QA tetap wajib untuk microphone/camera/file provider/OCR/Google/Drive.

## Matriks penerimaan perangkat

1. Pasang sebagai update dengan signing key yang sama; jangan uninstall; pastikan transaksi lama tetap ada.
2. Teks `nasi 25rb dan bensin 50k`: dua transaksi, satu centang; swipe kanan edit, kiri hapus; ulangi kategori terkoreksi untuk learning.
3. Mic: izin, preview transcript, stop otomatis/manual, simpan tepat sekali; batalkan/ganti tab tanpa transaksi duplikat.
4. Kamera langsung dan attachment galeri/file: izin, cancel, OCR review, koreksi, simpan; tidak ada database_closed setelah buka/tutup submenu.
5. Pertanyaan saldo/pemasukan/pengeluaran/jumlah lokal tetap bekerja offline; pertanyaan `Apakah anggaran 2 juta cukup?` tidak menjadi transaksi.
6. Pertanyaan analitis online dengan Google: jawaban di Input. Akun email lokal: instruksi masuk Google. Error quota/auth/network jelas; tidak membocorkan token.
7. Laporan bottom nav: harian, range inklusif, bulan+tahun, seluruh pie/category/count/detail, PDF.
8. Pilih 1–31 Oktober: label Oktober 2026; pilih 5–5 Oktober: Senin, 05 Oktober 2026; 1–30 Oktober tetap rentang.
9. Android Back: backup→pengaturan→input; laporan→input; keyboard/dialog ditutup terlebih dahulu.
10. Aktifkan automatic Drive backup; setelah upload sukses dua centang. Offline/failed upload tetap satu centang. Edit saat upload tidak boleh menerima konfirmasi versi lama.

## Workflow audit

`flutter_test.yml`: push main/develop dan PR; `build_android.yml`: push main/manual; `release.yml`: manual. Ketiganya menjalankan analyze/test; build/release memakai configurator Android yang sama. Tidak ada perubahan workflow. Release memerlukan permanent signing secrets. Rilis publik menggunakan semantic tag v0.3.2 sesuai pubspec; bump build +11 memungkinkan update Android dengan key yang sama. Main tidak diubah. Percobaan membuat branch untuk CI ditolak GitHub integration dengan HTTP 403 Resource not accessible by integration; tidak ada PR dibuat.

## Penerapan paket

1. Ekstrak ZIP, gunakan isi folder Finchat-main sebagai isi repository lokal (termasuk .github).
2. Jalankan UPDATE_GITHUB.bat seperti workflow yang sudah digunakan. Script dan workflow tetap dipertahankan.
3. Pantau Flutter Test serta Build Android APK. Versi ini belum dikompilasi/dijalankan dalam lingkungan penyusun.
4. Setelah CI hijau, unduh app-release.apk dan pasang sebagai update dengan key yang sama; jalankan matriks di atas.
5. Bila AI menghasilkan pesan auth/configuration, periksa Google server client ID di aplikasi vs GOOGLE_SERVER_CLIENT_ID pada Worker. Gemini secret saja belum cukup untuk autentikasi Gateway.

Tidak ada push/merge ke main, deployment Worker, atau perubahan secrets dilakukan oleh audit ini. Perbaikan diunggah ke branch codex/finchat-input-navigation-audit untuk validasi CI.
