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
