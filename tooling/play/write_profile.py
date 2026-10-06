from pathlib import Path
import json,os
out=Path('build/play');out.mkdir(parents=True,exist_ok=True)
keys=['SPENVA_PUBLISHER','SPENVA_SUPPORT_EMAIL','SPENVA_PRIVACY_URL','SPENVA_DELETION_URL','SPENVA_BILLING_ENDPOINT']
defines={key:os.getenv(key,'').strip() for key in keys};defines['FINCHAT_DISTRIBUTION']='play'
(out/'defines.json').write_text(json.dumps(defines,indent=2))
profile=json.loads(Path('docs/playstore/publication-profile.json').read_text())
for key in keys:profile[key.removeprefix('SPENVA_').lower()]=defines[key]
(out/'publication-profile.json').write_text(json.dumps(profile,indent=2))
print('Public build configuration written; publication gate remains separate.')
