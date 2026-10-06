"""Validate real bundle contents, bundletool dumps and public launch blockers."""
import argparse,json,struct,zipfile,xml.etree.ElementTree as ET
from pathlib import Path

def elf_alignments(data):
    if data[:4]!=b'\x7fELF': raise ValueError('Native library is not ELF')
    if data[4]!=2: return [] # 32-bit ABI is outside the 64-bit 16KB requirement.
    order='<' if data[5]==1 else '>'
    offset=struct.unpack_from(order+'Q',data,32)[0]; size,count=struct.unpack_from(order+'HH',data,54)
    return [struct.unpack_from(order+'Q',data,offset+i*size+48)[0] for i in range(count) if struct.unpack_from(order+'I',data,offset+i*size)[0]==1]

def check_manifest(xml):
    root=ET.fromstring(xml);a='{http://schemas.android.com/apk/res/android}'
    assert root.get('package')=='com.finchat.finchat','Application ID changed'
    assert root.get(a+'versionCode')=='17','Unexpected version code'
    sdk=root.find('uses-sdk');assert int(sdk.get(a+'targetSdkVersion'))>=36,'Target SDK below 36'
    assert int(sdk.get(a+'minSdkVersion'))==24,'Unexpected minimum SDK'
    app=root.find('application');assert app.get(a+'debuggable','false')=='false','Debuggable release'
    assert app.get(a+'usesCleartextTraffic')=='false','Cleartext traffic allowed'
    blocked={'MANAGE_EXTERNAL_STORAGE','READ_MEDIA_IMAGES','READ_MEDIA_VIDEO','READ_EXTERNAL_STORAGE','WRITE_EXTERNAL_STORAGE','REQUEST_INSTALL_PACKAGES','ACCESS_FINE_LOCATION','ACCESS_COARSE_LOCATION','AD_ID'}
    for element in root.findall('uses-permission'):
        assert element.get(a+'name','').split('.')[-1] not in blocked,'Unexpected broad permission'

def blockers(profile):
    missing=[]
    for key in ['publisher','support_email','privacy_url','deletion_url']:
        if not profile.get(key): missing.append(key)
    for key in ['privacy_url','deletion_url']:
        if profile.get(key) and not profile[key].startswith('https://'):missing.append(key+'_must_be_https')
    if profile.get('billing_endpoint'):
        for key in ['play_products_verified','paid_ai_confirmed','billing_server_verified','reporting_verified']:
            if profile.get(key) is not True:missing.append(key)
    for key in ['play_console_account','app_signing_oauth_verified','data_safety_reviewed','store_screenshots_reviewed','closed_test_completed_if_required']:
        if profile.get(key) is not True:missing.append(key)
    return missing

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--bundle',required=True);parser.add_argument('--manifest',required=True);parser.add_argument('--config',required=True);parser.add_argument('--profile',required=True);parser.add_argument('--output',required=True);parser.add_argument('--require-publication',action='store_true');args=parser.parse_args()
    check_manifest(Path(args.manifest).read_text())
    assert 'PAGE_ALIGNMENT_16K' in Path(args.config).read_text(),'AAB missing 16KB zip alignment'
    libraries=[]
    with zipfile.ZipFile(args.bundle) as archive:
        for name in archive.namelist():
            if '/lib/' in name and name.endswith('.so'):
                alignments=elf_alignments(archive.read(name));assert all(x>=16384 for x in alignments),f'16KB ELF alignment failed: {name}'
                libraries.append({'library':name,'load_alignments':alignments})
    assert libraries,'No native libraries checked'
    profile=json.loads(Path(args.profile).read_text()); missing=blockers(profile)
    Path(args.output).write_text(json.dumps({'bundle':args.bundle,'native_libraries':libraries,'technical_checks':'passed','publication_ready':not missing,'publication_blockers':missing},indent=2))
    print(f'Native and manifest checks passed; {len(missing)} publication requirements remain.')
    if args.require_publication and missing:raise SystemExit('Publication blocked: '+', '.join(missing))
