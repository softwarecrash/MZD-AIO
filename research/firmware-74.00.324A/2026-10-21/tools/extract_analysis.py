import pathlib,tarfile,gzip
base=pathlib.Path(__file__).resolve().parent
out=sorted(base.glob('mcu_backup_*'))[-1]
dest=out/'analysis_files'
files=list(out.glob('01_*.tar.gz')) or list(out.glob('01_*.partial'))
count=0
try:
    with tarfile.open(files[0],'r|gz') as t:
        for m in t:
            p=pathlib.PurePosixPath(m.name)
            if not m.isfile() or p.is_absolute() or '..' in p.parts or any(':' in s for s in p.parts): continue
            if p.suffix.lower() not in ['.js','.json','.xml','.conf','.ini','.sh','.css','.html','.txt'] and not m.name.startswith(('jci/scripts/','etc/','config/')): continue
            if m.size>10*1024*1024: continue
            target=dest/pathlib.Path(*p.parts)
            try: data=t.extractfile(m).read()
            except (EOFError,OSError): break
            if len(data)!=m.size: break
            target.parent.mkdir(parents=True,exist_ok=True); target.write_bytes(data); count+=1
except (EOFError,OSError,tarfile.ReadError) as e: print(type(e).__name__,str(e))
print('Extracted',count,'regular analysis files to',dest)
