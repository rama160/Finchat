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
        text = GROOVY.read_text(encoding="utf-8")
        text = text.replace("minSdk = flutter.minSdkVersion", "minSdk = 23")
        text = text.replace("minSdkVersion flutter.minSdkVersion", "minSdkVersion 23")
        if "keystorePropertiesFile" not in text:
            preamble = """def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file("key.properties")
if (!keystorePropertiesFile.exists()) {
    throw new GradleException("Missing android/key.properties; configure GitHub keystore secrets")
}
keystoreProperties.load(new FileInputStream(keystorePropertiesFile))

"""
            text = preamble + text
        if "signingConfigs {" not in text:
            marker = "    buildTypes {"
            signing = """    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }

"""
            if marker not in text:
                raise SystemExit("Could not locate buildTypes in android/app/build.gradle")
            text = text.replace(marker, signing + marker, 1)
        if "proguard-rules.pro" not in text:
            bt_pos = text.find("buildTypes {")
            rel_pos = text.find("release {", bt_pos)
            if rel_pos < 0:
                raise SystemExit("Could not locate release build type for ProGuard")
            insert_at = rel_pos + len("release {")
            text = text[:insert_at] + "\n            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'" + text[insert_at:]
        text = text.replace("signingConfig = signingConfigs.debug", "signingConfig = signingConfigs.release")
        text = text.replace("signingConfig signingConfigs.debug", "signingConfig signingConfigs.release")
        bt = text.find("buildTypes {")
        rel = text.find("release {", bt)
        if rel < 0:
            raise SystemExit("Could not locate release build type")
        end = text.find("\n        }", rel)
        block = text[rel:end if end >= 0 else len(text)]
        if "signingConfig" not in block:
            pos = rel + len("release {")
            text = text[:pos] + "\n            signingConfig signingConfigs.release" + text[pos:]
        GROOVY.write_text(text, encoding="utf-8")
        return

    if KOTLIN.exists():
        text = KOTLIN.read_text(encoding="utf-8")
        text = text.replace("minSdk = flutter.minSdkVersion", "minSdk = 23")
        if "keystorePropertiesFile" not in text:
            preamble = """import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (!keystorePropertiesFile.exists()) {
    throw GradleException("Missing android/key.properties; configure GitHub keystore secrets")
}
keystoreProperties.load(FileInputStream(keystorePropertiesFile))

"""
            text = preamble + text
        if "signingConfigs {" not in text:
            marker = "    buildTypes {"
            signing = """    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

"""
            if marker not in text:
                raise SystemExit("Could not locate buildTypes in android/app/build.gradle.kts")
            text = text.replace(marker, signing + marker, 1)
        if "proguard-rules.pro" not in text:
            bt_pos = text.find("buildTypes {")
            rel_pos = text.find("release {", bt_pos)
            if rel_pos < 0:
                raise SystemExit("Could not locate release build type for ProGuard")
            insert_at = rel_pos + len("release {")
            text = text[:insert_at] + '\n            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")' + text[insert_at:]
        text = text.replace('signingConfig = signingConfigs.getByName("debug")', 'signingConfig = signingConfigs.getByName("release")')
        bt = text.find("buildTypes {")
        rel = text.find("release {", bt)
        if rel < 0:
            raise SystemExit("Could not locate release build type")
        end = text.find("\n        }", rel)
        block = text[rel:end if end >= 0 else len(text)]
        if "signingConfig" not in block:
            pos = rel + len("release {")
            text = text[:pos] + '\n            signingConfig = signingConfigs.getByName("release")' + text[pos:]
        KOTLIN.write_text(text, encoding="utf-8")
        return

    raise SystemExit("Neither android/app/build.gradle nor build.gradle.kts exists")

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
