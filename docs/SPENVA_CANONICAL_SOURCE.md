> Current source status: **0.3.4+19**, 9 October 2026 UTC. See [SPENVA_CANONICAL_SOURCE.md](SPENVA_CANONICAL_SOURCE.md) and the current detailed audit. Older version/build statements below are historical evidence and do not verify this patch.

# SPENVA CANONICAL SOURCE — 0.3.4+19

## Otoritas sumber
Branch integrasi resmi: `spenva-source-of-truth`.
Basis runtime sebelumnya: 0.3.4+18. Patch audit +19 dibangun dari canonical commit `da61888d8151ee5bff52cea2a4cff846da8d5aa1`; CI baru wajib sebelum klaim terverifikasi. Branch `main`, `codex/gateway-recovery-validation`, `spenva-production-readiness`, dan `spenva-privacy-play-policy` adalah riwayat/branch pendahulu dan tidak boleh dipakai sebagai sumber rilis baru tanpa rekonsiliasi ke branch ini.

## Identitas produk
Nama: Spenva. Application ID Android: `com.finchat.finchat`. Database: `finchat.db`, schema 1. Arsitektur local-first: SQLite sumber kebenaran transaksi; parser/perhitungan lokal didahulukan; AI hanya fallback/fitur online. Google Drive appDataFolder digunakan untuk backup pilihan pengguna.

## Paket final
Nama yang terlihat pengguna hanya: Free, Plus, Pro, Max. Istilah Basic/Unlimited tidak boleh muncul pada UI, listing atau dokumentasi produk. Jika nama legacy masih ada pada enum internal, itu hanya kompatibilitas implementasi dan tidak boleh dianggap nama produk.

Free: Rp0; Voice 10/bulan; Scan 5/bulan; AI 5/bulan; PDF 1/bulan; backup manual.
Plus: Rp15.000/bulan atau Rp149.000/tahun; Voice 100; Scan 100; AI 50; PDF tanpa batas; backup otomatis.
Pro: Rp39.000/bulan atau Rp349.000/tahun; Voice 500; Scan 500; AI 200; PDF tanpa batas; backup otomatis; PALING DIREKOMENDASIKAN.
Max: Rp89.000/bulan atau Rp799.000/tahun; Voice 1.500; Scan 1.500; AI 500; PDF tanpa batas; backup otomatis.

Teks, transaksi, kategori, local learning dan laporan dasar tidak dibatasi. Voice dan AI adalah kuota terpisah. Kamera dan lampiran memakai kuota Scan yang sama.

## Pembayaran
Distribusi Play hanya menggunakan Google Play Billing untuk barang digital. QRIS, GoPay, transfer bank, kartu langsung dan e-wallet eksternal bukan metode checkout aplikasi produksi. Subscription belum boleh dinyatakan live sebelum produk Play, backend verification, service account, endpoint, lifecycle tests dan closed testing selesai.

## Privasi dan Data Safety
Deklarasi Console harus mengikuti perilaku build final, bukan dependency semata. Receipt OCR diproses pada perangkat pada baseline. Voice menggunakan speech recognizer platform dan dapat menggunakan jaringan. Financial data utama lokal; backup Drive dan AI adalah jalur off-device yang harus dinyatakan sesuai perilaku aktif. Tidak ada iklan/analytics SDK pada baseline ini. Penghapusan tersedia dari menu Privasi dan data; halaman web publik harus menyediakan penghapusan akun+data dan data-only.

## Signing dan Play
AAB Play wajib berasal dari `.github/workflows/play_store.yml`, yang mewajibkan permanent upload key. Workflow yang membuat ephemeral CI key tidak boleh digunakan untuk artefak upload Play. Setelah upload pertama, daftarkan SHA-1 app-signing certificate Play untuk Android OAuth `com.finchat.finchat` dan pertahankan upload key dengan aman.

## Gate rilis
Belum boleh disebut production-ready sampai: seluruh CI branch canonical hijau; AAB signed/16KB validator hijau; privacy/deletion URL canonical aktif; Data Safety direkonsiliasi; OAuth Play-distributed diuji; Google login/Drive/Voice/OCR/PDF/navigation diuji dari build Play; subscription lifecycle diuji bila diaktifkan; minimal closed-test requirement akun Play terpenuhi; pre-launch report ditinjau.

## Aturan dokumentasi
`Ai start here.md`, README, PRD, ARCHITECTURE, IMPLEMENTATION_STATUS, LAUNCH, DATA_SAFETY, SUBSCRIPTION, PLANS dan VALIDATION harus menunjuk dokumen ini sebagai status canonical. Catatan versi lama boleh dipertahankan sebagai history tetapi tidak boleh dibaca sebagai current truth.
