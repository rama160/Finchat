"""Fail CI when release metadata or the source inventory drifts."""
from pathlib import Path
import re
import subprocess
ROOT=Path(__file__).resolve().parents[1]
version=re.search(r'^version:\s*["\']?([^"\'\s]+)',(ROOT/'pubspec.yaml').read_text(),re.M).group(1)
constants=(ROOT/'lib/core/constants/app_constants.dart').read_text()
assert f"appVersion = '{version}'" in constants,'Settings version differs from pubspec'
release=(ROOT/'.github/workflows/release.yml').read_text()
assert f"default: 'v{version.split('+')[0]}'" in release,'Release default tag differs from source'
files=set(subprocess.check_output(['git','ls-files'],cwd=ROOT,text=True).splitlines())
manifest=set((ROOT/'tooling/repository_manifest.txt').read_text().splitlines())
assert files==manifest,f'Inventory drift: missing={sorted(files-manifest)} stale={sorted(manifest-files)}'
assert not any('__pycache__' in p or p.endswith(('.pyc','.jks','.keystore')) or p.startswith(('build/','.dart_tool/')) for p in files),'Generated output or credentials tracked'
assert 'String.fromCharCodes(bytes)' not in (ROOT/'lib/presentation/screens/backup_screen.dart').read_text(),'Incorrect JSON byte decoding'
print(f'Repository metadata and {len(files)} tracked files are consistent ({version}).')
