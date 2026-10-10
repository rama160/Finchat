from pathlib import Path
import re
import xml.etree.ElementTree as ET
root=Path(__file__).resolve().parents[2]
app=root/'android/app'
for name in ['build.gradle.kts','build.gradle']:
    path=app/name
    if not path.exists(): continue
    text=path.read_text()
    text=text.replace('compileSdk = flutter.compileSdkVersion','compileSdk = 36').replace('targetSdk = flutter.targetSdkVersion','targetSdk = 36')
    text=text.replace('compileSdkVersion flutter.compileSdkVersion','compileSdkVersion 36').replace('targetSdkVersion flutter.targetSdkVersion','targetSdkVersion 36')
    path.write_text(text)
path=app/'src/main/AndroidManifest.xml'
ET.register_namespace('android','http://schemas.android.com/apk/res/android')
ET.register_namespace('tools','http://schemas.android.com/tools')
tree=ET.parse(path); manifest=tree.getroot(); a='{http://schemas.android.com/apk/res/android}';t='{http://schemas.android.com/tools}'
application=manifest.find('application');application.set(a+'usesCleartextTraffic','false')
for feature in ['android.hardware.camera','android.hardware.camera.autofocus','android.hardware.microphone']:
    item=next((x for x in manifest.findall('uses-feature') if x.get(a+'name')==feature),None)
    if item is None:item=ET.SubElement(manifest,'uses-feature',{a+'name':feature})
    item.set(a+'required','false')
# Native photo picker and Storage Access Framework do not require broad storage.
for permission in ['READ_MEDIA_IMAGES','READ_MEDIA_VIDEO','READ_EXTERNAL_STORAGE','WRITE_EXTERNAL_STORAGE','MANAGE_EXTERNAL_STORAGE','REQUEST_INSTALL_PACKAGES','ACCESS_FINE_LOCATION','ACCESS_COARSE_LOCATION']:
    name='android.permission.'+permission
    for item in list(manifest.findall('uses-permission')):
        if item.get(a+'name')==name: manifest.remove(item)
    ET.SubElement(manifest,'uses-permission',{a+'name':name,t+'node':'remove'})
for item in list(manifest.findall('uses-permission')):
    if item.get(a+'name')=='com.google.android.gms.permission.AD_ID':manifest.remove(item)
ET.SubElement(manifest,'uses-permission',{a+'name':'com.google.android.gms.permission.AD_ID',t+'node':'remove'})
tree.write(path,encoding='unicode',xml_declaration=True)
print('Play target API 36, minimum API 24, optional camera/mic, no broad storage or advertising permission.')
