"""Read-only AIO audit. Never execute an installer or connect to a vehicle.

Only whitelisted sed expressions are run, on bytes supplied through stdin.
Shell branches, options, device services and uninstall scripts are not executed.
"""
import argparse,collections,csv,fnmatch,hashlib,json,pathlib,re,shlex,subprocess,tarfile

VARIABLES={'STAGE_WIFI':'/jci/scripts/stage_wifi.sh','ADDITIONAL_APPS_JSON':'/jci/opera/opera_dir/userjs/additionalApps.json','AIO_APP_DIR':'/jci/gui/apps','MZD_APP_DIR':'/tmp/mnt/resources/aio/mzd-casdk/apps','NEW_BKUP_DIR':'/tmp/mnt/resources/dev/org_files'}
def expand(value):
    for key,replace in VARIABLES.items():value=value.replace('${'+key+'}',replace).replace('$'+key,replace)
    return value
def canonical(path):
    path=path.lstrip('/')
    for old,new in [('resources/','tmp/mnt/resources/'),('data_persist/','tmp/mnt/data_persist/'),('data/','tmp/mnt/data/'),('mnt/','tmp/mnt/'),('var/','tmp/var/')]:
        if path.startswith(old):return new+path[len(old):]
    return path
def sha(data):return hashlib.sha256(data).hexdigest()
def safe_sed(expr):
    # No branching, file I/O or command execution. Compound scripts are skipped.
    if '\n' in expr or '\r' in expr:return False
    if expr.startswith('s') and len(expr)>2:
        delim=expr[1];ends=[];escaped=False
        for i,ch in enumerate(expr[2:],2):
            if escaped:escaped=False;continue
            if ch=='\\':escaped=True;continue
            if ch==delim:ends.append(i)
        return len(ends)==2 and re.fullmatch(r'[gIp0-9]*',expr[ends[-1]+1:]) is not None
    # Addressed d / a / i / c commands, including their literal append text.
    address=r'/(?:\\.|[^/])*/'
    return re.match(r'^'+address+r'(?:,'+address+r')?\s*(?:d$|[aic]\\)',expr) is not None
def statements(text,command):
    lines=text.splitlines();i=0
    while i<len(lines):
        start=i;line=lines[i].strip();i+=1
        if not re.match(r'^'+command+r'\s',line):continue
        for _ in range(80):
            try:tokens=shlex.split(line,comments=True,posix=True);break
            except ValueError:
                if i>=len(lines):tokens=[];break
                line+='\n'+lines[i];i+=1
        else:tokens=[]
        # Avoid interpreting any following shell control operator as an argument.
        for op in ['&&','||',';','&','>','>>','2>&1']:
            if op in tokens:tokens=tokens[:tokens.index(op)]
        yield start+1,line,tokens
def sed_commands(text):
    for line,raw,tokens in statements(text,'sed'):
        args=tokens[1:];exprs=[];paths=[];i=0
        while i<len(args):
            t=args[i];i+=1
            if t=='-i' or t.startswith('-i'):continue
            if t in ['-e','--expression']:
                if i<len(args):exprs.append(args[i]);i+=1
            elif t.startswith('-'):continue
            elif not exprs:exprs.append(t)
            else:paths.append(t)
        yield {'line':line,'raw':raw,'expressions':[expand(e) for e in exprs],'targets':[expand(p) for p in paths]}

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--repo',type=pathlib.Path,required=True)
    p.add_argument('--tweaks',type=pathlib.Path,required=True)
    p.add_argument('--backup',type=pathlib.Path,required=True)
    p.add_argument('--output',type=pathlib.Path,required=True)
    p.add_argument('--fixtures',type=pathlib.Path,required=True)
    p.add_argument('--sed',default=r'C:/Program Files/Git/usr/bin/sed.exe')
    a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True);a.fixtures.mkdir(parents=True,exist_ok=True)
    tree=subprocess.check_output(['git','ls-tree','-r','HEAD','app/files/tweaks'],cwd=a.repo).decode().splitlines()
    blobs={line.split('\t',1)[1]:line.split()[2] for line in tree}
    commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=a.repo).decode().strip()
    contents={};metadata={}
    print('Reading local archives (no vehicle access)...',flush=True)
    for archive in sorted(a.backup.glob('0[23456]_*.tar.gz')):
        with tarfile.open(archive,'r|gz') as t:
            for m in t:
                name=m.name.lstrip('./')
                metadata[name]={'type':str(m.type),'size':m.size,'link':m.linkname}
                wanted=name.startswith(('jci/gui/','jci/scripts/','jci/settings/configurations/')) or name in ['jci/sm/sm.conf','jci/opera/opera_home/opera.ini','etc/profile','jci/version.ini']
                if wanted and m.isfile() and m.size<8*1024*1024 and name not in contents:
                    data=t.extractfile(m).read();contents[name]=data
    # Only local, non-sensitive firmware bytes used for JS syntax checks.
    for name,data in contents.items():
        if name.endswith(('.js','.css')):
            dest=a.fixtures/pathlib.Path(*pathlib.PurePosixPath(name).parts)
            dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(data)
    probes=[];inventory=[];copies=[];syntax=[]
    for source in sorted(a.tweaks.iterdir()):
        if not source.is_file() or source.suffix not in ['.txt','.sh']:continue
        data=source.read_bytes();text=data.decode('utf-8',errors='replace')
        blob=hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()
        assert blobs.get('app/files/tweaks/'+source.name)==blob,'Fork source mismatch: '+source.name
        row={'script':source.name,'source_blob_sha':blob,'source_sha256':sha(data),'lines':len(text.splitlines()),'backup_calls':[],'restore_calls':[],'version_checks':[],'sed_probes':[],'copy_commands':[]}
        for i,line in enumerate(text.splitlines(),1):
            clean=line.strip()
            if not clean or clean.startswith('#'):continue
            for call,key in [('backup_org','backup_calls'),('restore_org','restore_calls')]:
                match=re.search(r'\b'+call+r'\s+([^;&|]+)',clean)
                if match:row[key].append({'line':i,'argument':match.group(1).strip()})
            if re.search(r'\b(COMPAT_GROUP|CMU_VER|CMU_SW_VER)\b',clean) and re.match(r'^(?:if|elif|\|\|)',clean):row['version_checks'].append({'line':i,'condition':clean})
        for command in sed_commands(text):
            for target in command['targets']:
                record={'script':source.name,'line':command['line'],'target':target,'expressions':command['expressions']}
                name=canonical(target)
                if '$' in target or not target.startswith('/'):record['result']='unresolved_target'
                elif '$' in ''.join(command['expressions']):record['result']='requires_option_expansion'
                elif not command['expressions'] or not all(safe_sed(e) for e in command['expressions']):record['result']='not_executed_expression_not_whitelisted'
                elif name not in contents:record['result']='target_not_in_text_fixture'
                else:
                    original=contents[name]
                    # Passing quoted regexes to MSYS sed as Windows argv can
                    # alter escaping. A script file preserves exact bytes.
                    expression_file=a.fixtures/'.probe-expression.sed'
                    expression_file.write_bytes(('\n'.join(command['expressions'])+'\n').encode('utf-8'))
                    args=[a.sed,'-b','-f',expression_file.resolve().as_posix()]
                    try:
                        r=subprocess.run(args,input=original,capture_output=True,timeout=5)
                        record.update(result='error' if r.returncode else ('changes_pristine_file' if r.stdout!=original else 'no_change_on_pristine_file'),exit_code=r.returncode,before_sha256=sha(original),after_sha256=sha(r.stdout),stderr=r.stderr.decode(errors='replace')[:500])
                        if r.returncode==0 and original!=r.stdout and name.endswith('.js'):
                            file=f'{source.stem}__L{command["line"]}__'+pathlib.PurePosixPath(name).name
                            (a.fixtures/file).write_bytes(r.stdout)
                            syntax.append({'fixture':file,'script':source.name,'line':command['line'],'target':target})
                    except subprocess.TimeoutExpired:record['result']='probe_timeout'
                row['sed_probes'].append(len(probes));probes.append(record)
        for line,raw,tokens in statements(text,'cp'):
            args=[x for x in tokens[1:] if not x.startswith('-')]
            if len(args)<2:continue
            dest=expand(args[-1]);sources=args[:-1]
            item={'script':source.name,'line':line,'sources':sources,'destination':dest,'overwrites':[]}
            if '$' not in dest and dest.startswith('/'):
                for original in sources:
                    expanded=expand(original)
                    if expanded.startswith('${MYDIR}/'):
                        relative=expanded[len('${MYDIR}/'):]
                    elif expanded.startswith('$MYDIR/'):relative=expanded[len('$MYDIR/'):]
                    else:continue
                    if '$' in relative:continue
                    matches=list(a.tweaks.glob(relative))
                    for match in matches:
                        if match.is_dir():pairs=[(f,pathlib.PurePosixPath(dest)/match.name/pathlib.PurePosixPath(f.relative_to(match).as_posix())) for f in match.rglob('*') if f.is_file()]
                        else:
                            is_dir=dest.endswith('/') or metadata.get(canonical(dest),{}).get('type')=="b'5'"
                            pairs=[(match,pathlib.PurePosixPath(dest)/match.name if is_dir else pathlib.PurePosixPath(dest))]
                        for f,target in pairs:
                            target=str(target);name=canonical(target)
                            if name not in metadata:continue
                            replacement=f.read_bytes();info={'target':target,'source':f.relative_to(a.tweaks).as_posix(),'bytes':len(replacement),'replacement_sha256':sha(replacement),'oem_size':metadata[name]['size']}
                            if name in contents:
                                old=contents[name];info['same_as_oem']=old==replacement
                                if name.endswith('.js'):
                                    pattern=rb'prototype\.([A-Za-z_$][\w$]*)\s*=\s*function'
                                    lost=sorted(set(re.findall(pattern,old))-set(re.findall(pattern,replacement)))
                                    info['oem_methods_removed']=[v.decode() for v in lost]
                            item['overwrites'].append(info)
            row['copy_commands'].append(len(copies));copies.append(item)
        inventory.append(row)
    summary={'firmware':'74.00.324A EU','fork_commit':commit,'script_count':len(inventory),'scripts_match_fork':True,'vehicle_access':False,'full_installers_executed':False,'sed_engine':'GNU sed, Git for Windows; stdin/stdout only; restricted expressions','method_limitations':['Only direct sed/cp statements are parsed; dynamic commands and shell branches are not executed.','Every sed command is probed independently on pristine firmware bytes, not on a complete installed state.','No-change can be an expected already-installed/cleanup/alternate-branch case.','GNU sed and modern JavaScript parsing do not prove BusyBox/Opera runtime compatibility.','Copy analysis covers locally available, statically resolvable payload paths only.','No patch is approved for use on the vehicle by this audit.'],'probe_counts':dict(collections.Counter(r['result'] for r in probes))}
    for name,value in [('summary.json',summary),('script-inventory.json',inventory),('sed-probes.json',probes),('copy-overwrites.json',copies)]:
        (a.output/name).write_text(json.dumps(value,indent=2,ensure_ascii=False),encoding='utf-8',newline='\n')
    (a.fixtures/'syntax-cases.json').write_text(json.dumps(syntax,indent=2),encoding='utf-8')
    print(json.dumps(summary,indent=2),flush=True)
    print('Copy commands:',len(copies),'overwritten existing files:',sum(len(c['overwrites']) for c in copies),flush=True)

if __name__=='__main__':main()
