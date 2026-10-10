# Kontrak AI dan jawaban lokal

**Versi sumber: 0.3.5+20**

AI adalah jalur read-only opsional. Jawaban angka selalu berangkat dari ReportService/SQLite. FinancialQaService menjawab lokal total, saldo, jumlah transaksi, kategori terbesar, kata kunci/nota dan saran hemat sederhana. Constraint yang tidak didukung tidak boleh diam-diam dibuang lalu diberi total global.

Pilot endpoint yang dipertahankan: `https://finchat-ai-gateway.finchat-ai-gateway.workers.dev/v1/ai/chat`. Payload memakai `messages` dengan role/text, bukan endpoint OpenAI standar. Authorization adalah Google ID token singkat; key Gemini hanya di server. HTTP/network/status failure memberi pesan yang sesuai dan tidak menggagalkan local capture. Provider tidak dianggap live hanya karena tes mock lulus.

Play tidak fallback ke pilot. Endpoint berasal dari SPENVA_BILLING_ENDPOINT; state/kuota/provider diperiksa sebelum request; consent cloud dan konfirmasi usia18+ dibutuhkan. Personal AI default nonaktif. Edukasi jika diaktifkan hanya menerima fixed topic budget/emergency/saving tanpa teks mentah atau transaksi.

QA personal mengirim pertanyaan, total periode dan maksimal25 cuplikan transaksi; menyebutkan bahwa cuplikan tidak lengkap. Payload maksimal20KB, prompt10K karakter; response JSON harus memiliki text, body dibatasi1MB dan output20K karakter. Client timeout65 detik. Angka respons dinormalisasi rupiah, tetapi model tidak dianggap sumber total.

Category suggestion hanya category_id yang tersedia dan confidence finite0–1. Provider exception/invalid category/low confidence kembali ke kategori lokal. Text/OCR normal diselesaikan lokal; voice ambiguous hanya dapat meminta fallback setelah konfigurasi state mengizinkan. Legacy AiSecureConfigService dipertahankan sebagai kontrak injection/test, bukan toggle yang menonaktifkan jalur production default.

Pelaporan jawaban adalah tindakan eksplisit pengguna; alasan wajib, salinan Q/A hanya dengan checkbox. Retensi dan data safety mengikuti [SUBSCRIPTION](playstore/SUBSCRIPTION.md) dan [DATA_SAFETY](playstore/DATA_SAFETY.md). Uji Gateway/token/provider live harus dicatat terpisah dari suite unit.
