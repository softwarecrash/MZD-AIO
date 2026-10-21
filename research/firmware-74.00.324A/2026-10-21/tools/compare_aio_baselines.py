import pathlib,difflib,csv,hashlib
base=pathlib.Path(__file__).resolve().parent
out=sorted(base.glob('mcu_backup_*'))[-1]
files=out/'analysis_files'
refs=base/'aio_reference/app/files/tweaks/config_org/v70'
dest=out/'aio_v70_comparison';dest.mkdir(exist_ok=True)
rows=[]
for ref in sorted(refs.glob('*.org')):
    if ref.name.endswith('.ivf.org'):continue
    name=ref.name[:-4]
    candidates=[p for p in files.rglob(name) if p.is_file()]
    if name=='Common.js': candidates=[files/'jci/gui/common/js/Common.js']
    for actual in candidates:
        old=ref.read_bytes();new=actual.read_bytes()
        relative=actual.relative_to(files).as_posix()
        rows.append([relative,ref.name,len(old),len(new),'identical' if old==new else 'different',hashlib.sha256(new).hexdigest()])
        diff=''.join(difflib.unified_diff(old.decode('utf-8',errors='replace').splitlines(True),new.decode('utf-8',errors='replace').splitlines(True),fromfile='AIO_v70/'+ref.name,tofile='CMU_74.00.324A/'+relative))
        (dest/(relative.replace('/','__')+'.diff')).write_text(diff,encoding='utf-8')
with (dest/'comparison.tsv').open('w',newline='',encoding='utf-8') as f:
    w=csv.writer(f,delimiter='\t');w.writerow(['device_path','aio_v70_baseline','baseline_bytes','device_bytes','comparison','device_sha256']);w.writerows(rows)
print('Compared',len(rows),'files;',sum(r[4]=='different' for r in rows),'differ from AIO bundled v70 baseline.')
