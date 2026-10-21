import urllib.request, json, pathlib, concurrent.futures
out=pathlib.Path('aio_reference'); out.mkdir(exist_ok=True)
def get(url):
    req=urllib.request.Request(url,headers={'User-Agent':'Mazda-readonly-analysis'})
    return urllib.request.urlopen(req,timeout=45).read()
tree=json.loads(get('https://api.github.com/repos/Trevelopment/MZD-AIO/git/trees/master?recursive=1'))
(out/'tree.json').write_text(json.dumps(tree,indent=2),encoding='utf-8')
sha=tree['sha']
paths=[x['path'] for x in tree['tree'] if x['type']=='blob' and (x['path'].startswith('app/files/tweaks/') or x['path'] in ['README.md','LICENSE'] or (x['path'].startswith('app/files/') and x['path'].endswith('.sh')))]
def fetch(path):
    p=out/path; p.parent.mkdir(parents=True,exist_ok=True)
    try: p.write_bytes(get('https://raw.githubusercontent.com/Trevelopment/MZD-AIO/'+sha+'/'+path)); return path
    except Exception as e: return f'ERROR {path}: {e}'
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
    for r in pool.map(fetch,paths): print(r,flush=True)
(out/'SOURCE.txt').write_text('https://github.com/Trevelopment/MZD-AIO\nCommit '+sha+'\n',encoding='utf-8')
