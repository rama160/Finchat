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
