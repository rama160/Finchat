# FinChat uses ML Kit Latin text recognition for Indonesian receipt OCR.
# google_mlkit_text_recognition references optional non-Latin language modules
# (Chinese, Devanagari, Japanese and Korean) even when they are not bundled.
# Do not fail R8 on those optional references. If FinChat later enables one
# of these scripts, add the corresponding ML Kit dependency instead.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
