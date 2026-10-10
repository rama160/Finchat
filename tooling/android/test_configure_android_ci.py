"""Exercise generated Android templates without an SDK or signing credentials."""
import importlib.util
from pathlib import Path
import tempfile
import unittest
import xml.etree.ElementTree as ET
spec=importlib.util.spec_from_file_location('configure',Path(__file__).with_name('configure_android_ci.py'))
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
class AndroidConfiguration(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup)
        root=Path(self.temp.name)
        module.GROOVY=root/'build.gradle';module.KOTLIN=root/'build.gradle.kts';module.MANIFEST=root/'AndroidManifest.xml'
    def test_existing_queries_receive_speech_without_losing_existing_intents(self):
        module.MANIFEST.write_text('<manifest xmlns:android="http://schemas.android.com/apk/res/android"><application android:label="finchat"/><queries><intent><action android:name="android.intent.action.PROCESS_TEXT"/></intent></queries></manifest>')
        module.configure_manifest();first=module.MANIFEST.read_text();module.configure_manifest()
        self.assertEqual(first,module.MANIFEST.read_text())
        root=ET.fromstring(first);a='{http://schemas.android.com/apk/res/android}'
        self.assertEqual(len(root.findall('queries')),1)
        self.assertEqual({n.get(a+'name') for n in root.findall('queries/intent/action')},{'android.intent.action.PROCESS_TEXT','android.speech.RecognitionService'})
        self.assertEqual(root.find('application').get(a+'label'),'Spenva')
        self.assertEqual(root.find('application').get(a+'allowBackup'),'false')
    def test_kotlin_plugins_precede_property_initialization_and_configuration_is_idempotent(self):
        module.KOTLIN.write_text('plugins {\n    id("com.android.application")\n}\nandroid {\n    defaultConfig { minSdk = flutter.minSdkVersion }\n    buildTypes {\n        release {\n            signingConfig = signingConfigs.getByName("debug")\n        }\n    }\n}\n')
        module.configure_gradle();first=module.KOTLIN.read_text();module.configure_gradle()
        self.assertEqual(first,module.KOTLIN.read_text())
        self.assertLess(first.index('plugins {'),first.index('val keystoreProperties'))
        self.assertIn('minSdk = 24',first)
        self.assertIn('signingConfigs.getByName("release")',first)
    def test_groovy_template_keeps_one_release_signing_block(self):
        module.GROOVY.write_text('plugins {\n    id "com.android.application"\n}\nandroid {\n    defaultConfig { minSdkVersion flutter.minSdkVersion }\n    buildTypes {\n        release {\n            signingConfig signingConfigs.debug\n        }\n    }\n}\n')
        module.configure_gradle();first=module.GROOVY.read_text();module.configure_gradle()
        self.assertEqual(first,module.GROOVY.read_text());self.assertIn('minSdkVersion 24',first)
        self.assertEqual(first.count('signingConfigs {'),1)
        self.assertLess(first.index('plugins {'),first.index('def keystoreProperties'))
if __name__=='__main__':unittest.main()
