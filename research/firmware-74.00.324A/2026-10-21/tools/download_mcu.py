import subprocess, pathlib, datetime, json, hashlib, tarfile, time

BASE = pathlib.Path(__file__).resolve().parent
OUT = BASE / ('mcu_backup_' + datetime.datetime.now().strftime('%Y%m%d_%H%M%S'))
OUT.mkdir()
SSH = ['ssh','-p','2222','-i',r'PATH_TO_PRIVATE_KEY','-o','IdentitiesOnly=yes','-o','HostKeyAlgorithms=+ssh-rsa','-o','PubkeyAcceptedAlgorithms=+ssh-rsa','-o','BatchMode=yes','-o','ConnectTimeout=15','-o','ServerAliveInterval=15','-o','ServerAliveCountMax=3','cmu@192.0.2.1']
manifest = {'created':datetime.datetime.now().isoformat(), 'host':'192.0.2.1:2222', 'archives':[], 'note':'Read-only file acquisition. Live files may change. No flash writes or raw block reads.'}
def save_manifest():
    (OUT/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
def snapshot(name, command):
    with (OUT/(name+'.txt')).open('wb') as f, (OUT/(name+'.stderr.txt')).open('wb') as e:
        p=subprocess.run(SSH+[command],stdout=f,stderr=e,timeout=120)
    print(name, 'exit',p.returncode,flush=True)
def archive(name,command):
    print('START',name,flush=True)
    part=OUT/(name+'.tar.gz.partial')
    with part.open('wb') as f, (OUT/(name+'.stderr.txt')).open('wb') as e:
        p=subprocess.run(SSH+[command],stdout=f,stderr=e)
    result={'name':name,'remote_command':command,'ssh_exit':p.returncode,'bytes':part.stat().st_size}
    try:
        count=0; size=0
        with tarfile.open(part,'r:gz') as t, (OUT/(name+'.files.tsv')).open('w',encoding='utf-8') as index:
            index.write('type\tsize\tpath\tlink_target\n')
            for m in t:
                count+=1; size+=m.size
                index.write(f'{m.type!r}\t{m.size}\t{m.name}\t{m.linkname}\n')
        # Consume the complete gzip stream to verify its CRC, including tar padding.
        import gzip
        with gzip.open(part,'rb') as g:
            while g.read(1024*1024): pass
        result.update(valid_archive=True,members=count,uncompressed_file_bytes=size)
        final=part.with_suffix('')
        part.rename(final)
        h=hashlib.sha256()
        with final.open('rb') as f:
            for block in iter(lambda:f.read(1024*1024),b''): h.update(block)
        result['sha256']=h.hexdigest()
    except Exception as ex:
        result.update(valid_archive=False,error=str(ex))
    manifest['archives'].append(result); save_manifest()
    print('DONE',json.dumps(result),flush=True)

save_manifest()
print('OUTPUT',OUT,flush=True)
snapshot('00_system', 'date; uptime; uname -a; id; cat /proc/cmdline; cat /proc/mounts; cat /proc/partitions; cat /proc/mtd; df -k; ps; cat /jci/version.ini; ls -la /dev; ls -la /tmp/mnt')
archive('01_aio_console_priority', 'cd / && tar -czf - jci/gui jci/scripts jci/sm jci/opera jci/testapp jci/tools jci/version.ini etc config usr/bin/terminal usr/bin/rungetty usr/bin/runlogin')
archive('02_jci_complete', 'cd / && tar -czf - jci')
archive('03_root_system', 'cd / && tar -czf - bin bootchart config config-mfg etc home lib sbin usr data data_persist media mnt resources root var')
archive('04_persistent_data', 'cd / && tar -czf - tmp/mnt/data tmp/mnt/data_persist')
archive('05_resources', 'cd / && tar -czf - tmp/mnt/resources')
archive('06_runtime', 'cd / && tar -czf - --exclude=tmp/mnt tmp')
snapshot('07_inventory', 'find /jci /etc /config /config-mfg /bin /sbin /lib /usr /home /tmp -type f -exec ls -ln {} \\;')
snapshot('08_diagnostics', 'dmesg; netstat -lnt; cat /proc/meminfo; cat /proc/cpuinfo; cat /proc/tty/drivers; cat /proc/tty/driver/IMX-uart; ls -la /sys/class/tty; ls -la /sys/class/block')
print('FINISHED',OUT,flush=True)
