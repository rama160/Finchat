from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ANDROID = ROOT / 'android'
APP = ANDROID / 'app'
GROOVY = APP / 'build.gradle'
KOTLIN = APP / 'build.gradle.kts'
MANIFEST = APP / 'src' / 'main' / 'AndroidManifest.xml'
RULES_SOURCE = ROOT / 'tooling' / 'android' / 'proguard-rules.pro'
RULES_TARGET = APP / 'proguard-rules.pro'


def configure_gradle() -> None:
    if GROOVY.exists():
        text = GROOVY.read_text(encoding='utf-8')
        text = text.replace('minSdk = flutter.minSdkVersion', 'minSdk = 23')
        text = text.replace('minSdkVersion flutter.minSdkVersion', 'minSdkVersion 23')
        if 'proguard-rules.pro' not in text:
            marker = 'release {'
            replacement = "release {\n            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'"
            if marker not in text:
                raise SystemExit('Could not locate release build type in android/app/build.gradle')
            text = text.replace(marker, replacement, 1)
        GROOVY.write_text(text, encoding='utf-8')
        return

    if KOTLIN.exists():
        text = KOTLIN.read_text(encoding='utf-8')
        text = text.replace('minSdk = flutter.minSdkVersion', 'minSdk = 23')
        if 'proguard-rules.pro' not in text:
            marker = 'release {'
            replacement = 'release {\n            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")'
            if marker not in text:
                raise SystemExit('Could not locate release build type in android/app/build.gradle.kts')
            text = text.replace(marker, replacement, 1)
        KOTLIN.write_text(text, encoding='utf-8')
        return

    raise SystemExit('Neither android/app/build.gradle nor build.gradle.kts exists')


def configure_manifest() -> None:
    if not MANIFEST.exists():
        raise SystemExit('android/app/src/main/AndroidManifest.xml does not exist')
    text = MANIFEST.read_text(encoding='utf-8')

    permissions = [
        '<uses-permission android:name="android.permission.INTERNET"/>',
        '<uses-permission android:name="android.permission.CAMERA"/>',
        '<uses-permission android:name="android.permission.RECORD_AUDIO"/>',
        '<uses-permission android:name="android.permission.BLUETOOTH"/>',
        '<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>',
        '<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>',
    ]
    for permission in permissions:
        if permission not in text:
            text = text.replace('\n    <application', f'\n    {permission}\n    <application', 1)

    speech_query = '''<queries>
        <intent>
            <action android:name="android.speech.RecognitionService" />
        </intent>
    </queries>'''
    if '<queries>' not in text:
        text = text.replace('\n    <application', f'\n    {speech_query}\n    <application', 1)

    if 'android:allowBackup=' not in text:
        text = text.replace('<application', '<application android:allowBackup="false"', 1)

    MANIFEST.write_text(text, encoding='utf-8')


def main() -> None:
    if not RULES_SOURCE.exists():
        raise SystemExit('tooling/android/proguard-rules.pro is missing')
    RULES_TARGET.write_text(RULES_SOURCE.read_text(encoding='utf-8'), encoding='utf-8')
    configure_gradle()
    configure_manifest()
    print('Android CI configuration applied successfully.')


if __name__ == '__main__':
    main()
