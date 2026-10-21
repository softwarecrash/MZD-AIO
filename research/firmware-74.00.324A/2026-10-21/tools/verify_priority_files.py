import ast,pathlib,subprocess,tarfile,hashlib,json
base=pathlib.Path(__file__).resolve().parent;out=sorted(base.glob('mcu_backup_*'))[-1]
module=ast.parse((base/'download_mcu.py').read_text())
ssh=next(ast.literal_eval(n.value) for n in module.body if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='SSH' for t in n.targets))
paths=['/jci/gui/common/js/Common.js','/jci/gui/apps/system/js/systemApp.js','/jci/scripts/systemHooks.sh','/jci/scripts/run-terminal.sh','/jci/sm/sm.conf','/jci/opera/opera_home/opera.ini','/usr/bin/terminal','/etc/profile','/jci/version.ini']
p=subprocess.run(ssh+['md5sum '+' '.join(paths)],capture_output=True,timeout=90)
(out/'priority_remote_md5.txt').write_bytes(p.stdout)
(out/'priority_remote_md5.stderr.txt').write_bytes(p.stderr)
if p.returncode:raise SystemExit('Remote md5sum failed: '+str(p.returncode))
remote={line.split(None,1)[1].strip():line.split(None,1)[0] for line in p.stdout.decode().splitlines()}
results=[]
with tarfile.open(out/'01_aio_console_priority.tar.gz','r:gz') as t:
    for path in paths:
        data=t.extractfile(path[1:]).read(); value=hashlib.md5(data).hexdigest()
        results.append({'path':path,'matches_remote':value==remote[path],'md5':value,'sha256':hashlib.sha256(data).hexdigest()})
(out/'priority_verification.json').write_text(json.dumps(results,indent=2),encoding='utf-8')
print('Remote vs archive MD5:',sum(r['matches_remote'] for r in results),'/',len(results),'match; local SHA-256 also recorded')
