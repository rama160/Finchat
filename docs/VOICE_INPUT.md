# Input suara

**Versi sumber: 0.3.5+20**

SpeechToTextProvider mengadaptasi speech_to_text ke kontrak SpeechRecognitionProvider. VoiceInputService mengelola initialize/listen/stop/cancel, generation callback dan transcript buffer. TranscriptBuffer mempertahankan partial/final/cumulative/segmented text tanpa mengulang transaksi.

Normalisasi kata nominal dan angka voice berada pada satu file `lib/domain/parsing/spoken_money_normalizer.dart`; fungsi normalizeSpokenMoney dan normalizeVoiceTransactions dipakai sesuai input. Parser nominal umum tetap MoneyAmountParser. Voice tidak menulis SQLite sendiri.

Halaman Input meminta locale id_ID, listen60 detik dan pause5 detik; platform dapat menghentikan lebih cepat. Stop menunggu final500ms, final settle400ms. Cancel/empty/error tidak menyimpan transaksi; teks valid masuk batch lokal. Pertanyaan dari ucapan mengikuti QA dengan periode ucapan.

Manifest membutuhkan RECORD_AUDIO dan query android.speech.RecognitionService; kamera/mikrofon bukan syarat instalasi. Bluetooth permissions dipertahankan untuk speech service. Pengenal suara perangkat dapat memakai jaringan: jangan menjanjikan seluruh voice offline.

Pilot tidak menggunakan quota server. Play reserve Voice sebelum sesi, settle sukses sekali setelah pemrosesan; gagal/cancel mengembalikan reservation sesuai ledger. Jika backend belum aktif, Voice Play belum tersedia tetapi teks tetap berjalan.

Uji fake callback/multi transaksi tersedia dalam suite. Tes mikrofon fisik, locale terpasang, denied permission, segmented speech dan keyboard/IME tetap acceptance perangkat.
