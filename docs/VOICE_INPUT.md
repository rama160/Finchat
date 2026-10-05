## Current voice capture — 0.3.2+14

Halaman Input menerima satu atau beberapa transaksi suara. Dictation menghasilkan teks final, lalu normalisasi nominal kata/angka masuk ke pipeline lokal yang sama dengan teks. Input yang valid dipetakan kategorinya sebagai satu batch dan disimpan melalui repository; tidak memanggil AI untuk nominal lokal yang sudah jelas. Pertanyaan mengikuti jalur Q&A dan membaca periode dari ucapan. Speech provider sendiri tetap tidak menulis SQLite.

111 tes lulus pada commit `f36a3c11f0bd581e0a4d50f4d9d5d1b20959aa86`, termasuk multi transaksi tanpa AI dan partial/final speech. Android dapat membatasi durasi dan jeda sesi; microphone/perilaku platform masih memerlukan pengujian HP. Catatan Phase 6 di bawah adalah rancangan historis; jalur capture terbaru ini menjadi acuan saat berbeda.

# Phase 6 — Voice Input

## Scope

Voice input converts a short spoken transaction into text. The recognized text is not a transaction by itself. It must enter the existing transaction pipeline:

Voice → speech-to-text → text → normalize → local parser → category engine → validation → AI fallback → review → repository → SQLite.

The speech layer must not write to SQLite and must not bypass the existing parser or validation layers.

## Provider

The first platform adapter uses `speech_to_text`. The domain/application layers depend only on the local `SpeechRecognitionProvider` contract, so the provider can be replaced later without changing transaction logic.

The package is intended for short intermittent speech, which matches transaction-entry commands rather than continuous dictation. See the package documentation for platform support and current limitations.

## Indonesian locale

The application may request `id_ID` when starting a voice session. The final recognition language must still depend on the speech locales installed on the device.

## Android permissions

The Android application needs microphone access and the speech recognition service query required by modern Android targets. The CI Android build generates the platform folder when it is missing; the build workflow therefore patches the generated manifest with the required permissions and recognition-service query.

## Session rules

- initialize once per application/provider instance;
- show listening state to the user;
- accept partial text for preview;
- use final text as the transaction-input candidate;
- allow stop and cancel;
- speech errors do not create transactions;
- empty recognition results do not create transactions.

## CI boundary

Unit tests use a fake speech provider. GitHub Actions does not need a microphone or emulator to verify the domain/application behavior. Real microphone recognition remains a device-level verification step.
