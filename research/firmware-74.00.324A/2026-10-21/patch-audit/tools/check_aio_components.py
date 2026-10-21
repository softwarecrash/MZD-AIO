"""Check selected patch components offline; never run complete tweak scripts."""
import pathlib,json,re,subprocess,hashlib,shlex
from audit_aio_patches import sed_commands,safe_sed

import argparse
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--fixtures',type=pathlib.Path,required=True)
p.add_argument('--tweaks',type=pathlib.Path,required=True)
p.add_argument('--output',type=pathlib.Path,required=True)
p.add_argument('--sed',default='C:/Program Files/Git/usr/bin/sed.exe')
p.add_argument('--bash',default='C:/Program Files/Git/bin/bash.exe')
args=p.parse_args()
FIX=args.fixtures.resolve(); SRC=args.tweaks.resolve(); OUT=args.output.resolve()
OUT.mkdir(parents=True,exist_ok=True)
SED=args.sed; BASH=args.bash
def run_sed(expr,data):
    assert safe_sed(expr)
    p=FIX/'.component-expression.sed';p.write_bytes((expr+'\n').encode())
    result=subprocess.run([SED,'-b','-f',p.as_posix()],input=data,capture_output=True,check=True)
    return result.stdout
def expressions(name,target):
    return [expr for c in sed_commands((SRC/name).read_text()) if target in c['targets'] for expr in c['expressions']]
tests=[];syntax=[]
def component(label,install,uninstall,target,guard=None,select=None):
    original=(FIX/target.lstrip('/')).read_bytes()
    exprs=expressions(install,target)
    if select:exprs=[e for e in exprs if select(e)]
    def apply(data):
        if guard and guard.encode() in data:return data
        for expr in exprs:data=run_sed(expr,data)
        return data
    first=apply(original);second=apply(first)
    record={'component':label,'install_script':install,'target':target,'expressions':exprs,'scope':'selected text component only; branches modelled explicitly; not full installer','changed':first!=original,'idempotent_in_model':second==first,'before_sha256':hashlib.sha256(original).hexdigest(),'after_sha256':hashlib.sha256(first).hexdigest()}
    if uninstall:
        restored=first
        for expr in expressions(uninstall,target):
            if safe_sed(expr):restored=run_sed(expr,restored)
        record.update(uninstall_script=uninstall,text_round_trip_exact=restored==original)
    name=label+'.js';(FIX/name).write_bytes(first)
    syntax.append({'fixture':name,'script':install,'target':target})
    tests.append(record)
component('touchscreen-common','01_touchscreen-i.txt','01_touchscreen-u.txt','/jci/gui/common/js/Common.js',guard='//"Global.AtSpeed')
component('list-beep','07_listbeep-i.txt','07_listbeep-u.txt','/jci/gui/common/controls/List2/js/List2Ctrl.js')
component('shorter-delay','07_shorterdelay-i.txt','07_shorterdelay-u.txt','/jci/gui/common/controls/List2/js/List2Ctrl.js')
component('system-beep','08_sysbeep-i.txt',None,'/jci/gui/common/js/Common.js',guard='No More Beeps',select=lambda e:'"system"' in e)
component('reconnect-message','00_reconnectmsg-i.txt',None,'/jci/gui/apps/system/js/systemApp.js',guard='Disable_Reconnect_Msg')
component('diag-settle','12_diag-i.txt',None,'/jci/gui/apps/diag/js/diagApp.js',guard='"settleTime" : 1000,')
component('diag-hold','12_diag-i.txt',None,'/jci/gui/common/controls/StatusBar/js/StatusBarCtrl.js',guard='"holdTimeout" : 1000,')
component('diag-entry','12_diag-i.txt',None,'/jci/gui/common/js/Common.js',guard='// Sumire Racing')
(OUT/'component-checks.json').write_text(json.dumps(tests,indent=2),encoding='utf-8',newline='\n')
(FIX/'component-syntax-cases.json').write_text(json.dumps(syntax,indent=2),encoding='utf-8')
source=(SRC/'00_start.txt').read_text()
function=re.search(r'^compatibility_check\(\)\n\{.*?^\}',source,re.M|re.S).group()
assert not any(t in function for t in ['rm ','cp ','mount ','reboot','eval ','exec '])
versions=[]
for version in ['70.00.100','70.00.360','70.00.361','74.00.324']:
    fixture=FIX/'.version.ini';fixture.write_text('JCI_SW_VER="MAZ_CMU-150_'+version+'"\n',encoding='utf-8',newline='\n')
    body=function.replace('/jci/version.ini',shlex.quote(fixture.as_posix()))
    isolated='get_cmu_ver() { echo '+version.split('.')[0]+'; }\n'+body+'\ncompatibility_check\n'
    script=FIX/'.version-check.sh';script.write_text(isolated,encoding='utf-8',newline='\n')
    r=subprocess.run([BASH,'--noprofile','--norc',script.as_posix()],capture_output=True,text=True,check=True)
    versions.append({'firmware':version,'compatibility_group':int(r.stdout.strip()),'test':'only original compatibility_check function; local synthetic version.ini; no installer execution'})
(OUT/'version-checks.json').write_text(json.dumps(versions,indent=2),encoding='utf-8',newline='\n')
print('Version groups:',[(x['firmware'],x['compatibility_group']) for x in versions])
for t in tests:print(t['component'],'changed',t['changed'],'idempotent',t['idempotent_in_model'],'roundtrip',t.get('text_round_trip_exact','not tested'))
