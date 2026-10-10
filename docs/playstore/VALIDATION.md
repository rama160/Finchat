# Validasi runtime dan build saat ini

**Versi sumber: 0.3.5+20**

Source saat ini 0.3.5+20 sedang menjalani CI audit. Jangan memakai hasil +19 sebagai sertifikasi +20. Setelah sukses, bagian ini harus diganti dengan SHA/run/artifact yang tepat, lalu main diverifikasi ulang.

Lokal: Node backend, Python template/bundle/metadata dan source/link/inventory checks. Flutter lokal tidak dijalankan karena auto-review sebelumnya memblokir initialization yang mencoba metadata-service. GitHub CI adalah jalur analyze/test/build yang independen.

Hasil terdahulu tersedia pada [arsip commit](../history/README.md); perubahan current memerlukan analyze, normal tests, Play-profile tests, native Linux integration, signed APK dan AAB/16KB. Uji provider/Google/Drive/billing/plugin HP tetap acceptance eksternal. Sembilan blocker publikasi ada di [LAUNCH](LAUNCH.md).
