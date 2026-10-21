import pathlib,re,tarfile,hashlib,csv,json
base=pathlib.Path(__file__).resolve().parent
out=sorted(base.glob('mcu_backup_*'))[-1]
refs=base/'aio_reference/app/files/tweaks'
targets={}
for p in refs.glob('*.txt'):
    for line_no,line in enumerate(p.read_text(encoding='utf-8',errors='replace').splitlines(),1):
        for match in re.finditer(r'(?<![A-Za-z0-9_])(/(?:jci|etc|config|usr|bin|sbin|lib|data|tmp/mnt/resources)/[A-Za-z0-9_./+*-]+)',line):
            name=match.group(1).rstrip('/')
            targets.setdefault(name,set()).add(f'{p.name}:{line_no}')
found={}
for archive in sorted(out.glob('0[123]_*.tar.gz')):
    with tarfile.open(archive,'r:gz') as t:
        for m in t:
            name='/'+m.name.lstrip('./')
            if name not in targets: continue
            info={'archive':archive.name,'size':m.size,'kind':str(m.type),'sha256':''}
            if m.isfile():
                h=hashlib.sha256(); f=t.extractfile(m)
                for chunk in iter(lambda:f.read(1024*1024),b''):h.update(chunk)
                info['sha256']=h.hexdigest()
            found[name]=info
with (out/'aio_target_inventory.tsv').open('w',newline='',encoding='utf-8') as f:
    w=csv.writer(f,delimiter='\t'); w.writerow(['device_path','acquisition','archive','size','sha256','aio_references'])
    for name in sorted(targets):
        row=found.get(name,{})
        w.writerow([name,'acquired' if row else 'not_in_completed_archives',row.get('archive',''),row.get('size',''),row.get('sha256',''),'; '.join(sorted(targets[name]))])
print('AIO literal target references:',len(targets),'already acquired:',len(found))
print('References include directories, wildcards, optional additions and backup paths; missing entries do not alone indicate a failed download.')
