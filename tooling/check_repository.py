"""Validate one coherent source tree: metadata, imports, docs, assets and inventory."""
from pathlib import Path
import json
import re
import subprocess
import sys
from urllib.parse import unquote
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tooling'))
from sync_metadata import outputs, version

def check():
    for path, expected in outputs().items():
        assert (ROOT / path).read_text() == expected, f'Stale generated metadata: {path}'
    subprocess.run([sys.executable, str(ROOT / 'tooling/play/generate_subscription.py'), '--check'], check=True)
    files = set(subprocess.check_output(['git', 'ls-files'], cwd=ROOT, text=True).splitlines())
    manifest = set((ROOT / 'tooling/repository_manifest.txt').read_text().splitlines())
    assert files == manifest, f'Inventory drift: missing={sorted(files-manifest)} stale={sorted(manifest-files)}'
    assert all((ROOT / p).is_file() for p in files), 'Tracked file missing from checkout; stage deletions'
    assert not any('__pycache__' in p or p.endswith(('.pyc', '.jks', '.keystore')) or p.startswith(('build/', '.dart_tool/')) for p in files), 'Output/credentials tracked'
    assert 'set "BRANCH=main"' in (ROOT / 'UPDATE_GITHUB.bat').read_text(), 'Uploader does not target the everyday source'
    for name in files:
        path = ROOT / name
        if path.suffix == '.dart':
            for uri in re.findall(r"(?:import|export|part) ['\"]([^'\"]+)", path.read_text()):
                if uri.startswith('package:finchat/'):
                    target = ROOT / 'lib' / uri.removeprefix('package:finchat/')
                elif ':' in uri: continue
                else: target = path.parent / uri
                assert target.is_file(), f'Broken Dart import in {name}: {uri}'
        if path.suffix == '.md':
            text = path.read_text()
            for uri in re.findall(r'\]\(([^)]+)\)', text):
                if ':' in uri or uri.startswith('#'): continue
                target = path.parent / unquote(uri.split('#')[0])
                assert target.exists(), f'Broken documentation link in {name}: {uri}'
            if name not in {'CHANGELOG.md', 'docs/history/README.md'}:
                assert f'**Versi sumber: {version()}**' in text, f'Documentation version not aligned: {name}'
        if path.suffix == '.json': json.loads(path.read_text())
    assert 'pubspec.lock' in files, 'Resolved application dependencies must be tracked'
    yaml = (ROOT / 'pubspec.yaml').read_text()
    for asset in re.findall(r'^\s*- (assets/[^\s]+)', yaml, re.M) + re.findall(r'asset: (assets/[^\s]+)', yaml):
        assert (ROOT / asset).exists(), f'Missing bundled asset: {asset}'
    assert 'String.fromCharCodes(bytes)' not in (ROOT / 'lib/presentation/screens/backup_screen.dart').read_text(), 'Invalid UTF-8 import'
    print(f'Source, imports, assets, docs and {len(files)} tracked paths are consistent ({version()}).')
if __name__ == '__main__': check()
