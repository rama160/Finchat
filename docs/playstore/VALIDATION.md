# Validasi runtime dan build saat ini

**Versi sumber: 0.3.5+20**

Runtime, aset, dependency lock dan workflow yang diuji: commit `570ef1a1c7597393e0e84786539f4fa12f84a350` (10 Oktober 2026). Commit dokumentasi sesudahnya hanya merapikan catatan bukti/audit; tidak mengganti runtime, dependensi atau workflow. Integrasi ke sumber utama **main** melalui [PR #4](https://github.com/rama160/Finchat/pull/4). Gunakan main untuk ZIP/build harian. Hasil +19 dan branch lama bukan sertifikasi versi ini.

## Hasil executable

| Pemeriksaan | Hasil | Bukti |
|---|---|---|
| Source/generated metadata, import/link, JSON/asset dan manifest inventory | 205 tracked paths konsisten | Lokal dan semua workflow CI |
| Flutter 3.47.7 / enforced lock / analyzer | No issues found | [Flutter Test](https://github.com/rama160/Finchat/actions/runs/38011225800) |
| Flutter unit/widget/regression | 149 lulus, 2 conditional skips | Run Flutter di atas; diulang pada APK dan Play |
| Profil Play / quota | 11 lulus, 1 distribution-specific skip | [Prepare Play](https://github.com/rama160/Finchat/actions/runs/38011225837) |
| Screenshot actual app | Capture test lulus; 4 opaque PNG 1080×1920; sign-in/chat/report/calendar diperiksa visual | [Screenshot review pack](https://github.com/rama160/Finchat/actions/runs/38011225837/artifacts/11654210067) |
| Native Linux integration | 1 lulus: login offline, tiga transaksi termasuk gaji, database, laporan dan navigasi | Job integration pada run Prepare Play |
| Backend simulated tests | 46 lulus | Lokal dan job Prepare Play |
| Python Android template / bundle validator | 3 / 5 lulus | Lokal dan job Prepare Play |
| Play overlay | Idempotent; feature manifest tidak ganda | Lokal; bundle real diverifikasi CI |
| Signed APK pilot | Build/upload sukses, 93.8 MB | [APK run](https://github.com/rama160/Finchat/actions/runs/38011222394) |
| Signed AAB / manifest / native / ZIP 16 KB | Lulus; 12 native libraries diperiksa | Run Prepare Play; validation.json dan zipalign.txt di paket |

Dua skip pada suite normal adalah skenario bersyarat profil distribusi/capture; profile Play dan capture dijalankan terpisah. Native integration membuktikan runner Linux, bukan plugin HP Android. Source/metadata checks tidak menggantikan tes perilaku.

## Paket dan kecocokan versi

[Unduh APK pilot 0.3.5+20](https://github.com/rama160/Finchat/actions/runs/38011222394/artifacts/11654325339). APK sebenarnya berukuran **93835728 bytes**, SHA-256 `08788dfd8913fe5858b68f781928e5e3418078fd112885d212f334197729bb97`. Manifest APK diekstrak dari binary Android XML dan dibaca ulang: package `com.finchat.finchat`, versionName `0.3.5`, versionCode `20`, min24/target36, debuggable false. Ini sama dengan pubspec dan versi Pengaturan `0.3.5+20`.

[Unduh paket AAB Play + APK validasi + laporan](https://github.com/rama160/Finchat/actions/runs/38011225837/artifacts/11653916199). AAB **75174096 bytes**, SHA-256 `46263dec78abe3189a06dcf921b58564f398616931f98f9c1574bb7718157075`. Universal APK untuk validasi Play **94104785 bytes**; berbeda dari APK pilot karena define distribusi. Bundletool manifest juga versionName0.3.5/versionCode20, package sama, min24/target36. `jarsigner`, ELF alignments, PAGE_ALIGNMENT_16K dan universal APK `zipalign -P 16` lulus. Lockfile dalam artifact byte-identical dengan repository.

Permanent upload certificate SHA-1 tetap `CA:AA:59:2F:EC:CA:7C:8B:8B:16:C0:83:30:7D:43:A3:25:76:2E:10` pada APK dan AAB. Artifact GitHub berakhir 8 Januari 2027; setelah itu rebuild dari source commit/main. Hash di atas adalah file APK/AAB di dalam arsip, bukan hash ZIP artifact.

Workflow main tersedia pada [Build Android APK](https://github.com/rama160/Finchat/actions/workflows/build_android.yml?query=branch%3Amain) dan [Prepare Play](https://github.com/rama160/Finchat/actions/workflows/play_store.yml?query=branch%3Amain). Source yang digabung harus cocok dengan tree PR; versi remote main dibaca ulang setelah merge.

## Batas hasil

Tidak ada deploy backend, aktivasi subscription/personal AI, pembelian nyata atau publikasi Console dalam audit ini. validation.json menyatakan technical_checks passed dan publication_ready false dengan **9 blocker**, persis [LAUNCH](LAUNCH.md). Provider/Gateway live, Google OAuth dari distribusi Play, Drive remote, real billing dan plugin kamera/mikrofon/picker/PDF/IME tetap memerlukan acceptance perangkat/layanan eksternal. Harga/kuota tidak diubah.

Regresi +20 mencakup build-only update, kategori initial/repair tanpa mengubah nama tersimpan, edit restored transaction yang mempertahankan FK history, stale Drive account setelah logout, invalid backup mappings/history ditolak sebelum delete. Suite lain tetap memverifikasi input/parser/nominal, laporan/periode/PDF, root navigation/logout, backup UTF-8/legacy/rollback dan kuota.

Flutter lokal tidak diinisialisasi ulang setelah automatic review sebelumnya memblokir percobaan metadata-service; analyze/test/build dijalankan melalui CI. Riwayat versi lama tersedia pada [indeks arsip](../history/README.md).
