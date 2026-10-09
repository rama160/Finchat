from pathlib import Path
import xml.etree.ElementTree as ET
import shutil

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
        text = text.replace("minSdk = flutter.minSdkVersion", "minSdk = 24")
        text = text.replace("minSdkVersion flutter.minSdkVersion", "minSdkVersion 24")
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
        text = text.replace("minSdk = flutter.minSdkVersion", "minSdk = 24")
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
            imports, properties = preamble.split("val keystoreProperties =", 1)
            # Gradle requires plugins {} before ordinary executable statements.
            plugin_start = text.find("plugins {")
            plugin_end = text.find("}", plugin_start)
            if plugin_start < 0 or plugin_end < 0:
                raise SystemExit("Could not locate Kotlin plugins block")
            text = imports + text[:plugin_end + 1] + "\n\nval keystoreProperties =" + properties + text[plugin_end + 1:]
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
    android_ns = 'http://schemas.android.com/apk/res/android'
    ET.register_namespace('android', android_ns)
    name_key = f'{{{android_ns}}}name'
    tree = ET.parse(MANIFEST)
    root = tree.getroot()
    existing = {node.get(name_key) for node in root.findall('uses-permission')}
    for permission in ['INTERNET', 'CAMERA', 'RECORD_AUDIO', 'BLUETOOTH', 'BLUETOOTH_ADMIN', 'BLUETOOTH_CONNECT']:
        name = f'android.permission.{permission}'
        if name not in existing:
            attrs = {name_key: name}
            if permission in ['BLUETOOTH', 'BLUETOOTH_ADMIN']:
                attrs[f'{{{android_ns}}}maxSdkVersion'] = '30'
            root.insert(0, ET.Element('uses-permission', attrs))
    # Camera/microphone are optional input methods, not install prerequisites.
    for feature in ['android.hardware.camera', 'android.hardware.microphone']:
        if not any(node.get(name_key) == feature for node in root.findall('uses-feature')):
            root.insert(0, ET.Element('uses-feature', {name_key: feature, f'{{{android_ns}}}required': 'false'}))
    queries = root.find('queries')
    if queries is None:
        queries = ET.SubElement(root, 'queries')
    speech_action = 'android.speech.RecognitionService'
    if not any(node.get(name_key) == speech_action for node in queries.findall('intent/action')):
        intent = ET.SubElement(queries, 'intent')
        ET.SubElement(intent, 'action', {name_key: speech_action})
    application = root.find('application')
    if application is None:
        raise SystemExit('Android manifest application element is missing')
    application.set(f'{{{android_ns}}}allowBackup', 'false')
    application.set(f'{{{android_ns}}}label', 'Spenva')
    ET.indent(tree, space='    ')
    tree.write(MANIFEST, encoding='unicode')



def configure_branding() -> None:
    icon = ROOT / 'assets' / 'brand' / 'android_icon.png'
    if not icon.exists():
        raise SystemExit('Bundled Spenva Android icon is missing')
    res = APP / 'src' / 'main' / 'res'
    for density in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']:
        target = res / f'mipmap-{density}'
        target.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(icon, target / 'ic_launcher.png')
    values = res / 'values'
    values.mkdir(parents=True, exist_ok=True)
    (values / 'spenva_colors.xml').write_text('<resources><color name="spenva_background">#555D91</color></resources>')
    drawable = res / 'drawable'
    drawable.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(ROOT / 'assets' / 'brand' / 'android_foreground.png', drawable / 'spenva_foreground.png')
    (drawable / 'spenva_foreground.xml').unlink(missing_ok=True)
    adaptive = res / 'mipmap-anydpi-v26'
    adaptive.mkdir(parents=True, exist_ok=True)
    (adaptive / 'ic_launcher.xml').write_text('<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android"><background android:drawable="@color/spenva_background"/><foreground android:drawable="@drawable/spenva_foreground"/></adaptive-icon>')


def main() -> None:
    if not RULES_SOURCE.exists():
        raise SystemExit('tooling/android/proguard-rules.pro is missing')
    RULES_TARGET.write_text(RULES_SOURCE.read_text(encoding='utf-8'), encoding='utf-8')
    configure_gradle()
    configure_manifest()
    configure_branding()
    print('Android CI configuration applied successfully.')


if __name__ == '__main__':
    main()
