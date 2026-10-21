import pathlib, subprocess, ast
base=pathlib.Path(__file__).resolve().parent
out=sorted(base.glob('mcu_backup_*'))[-1]/'console_analysis'
out.mkdir(exist_ok=True)
module=ast.parse((base/'download_mcu.py').read_text())
ssh=next(ast.literal_eval(n.value) for n in module.body if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='SSH' for t in n.targets))
commands={
 'terminal_strings':"strings /usr/bin/terminal",
 'console_startup':"cat /usr/bin/rungetty; cat /usr/bin/runlogin; ls -la /etc; grep -R -n -E 'terminal|rungetty|ttymxc|cttyhack|jci-systemDialog' /etc/init /etc/init.d /jci/scripts /jci/sm /jci/gui/apps/test* /jci/gui/common 2>/dev/null",
 'terminal_process':"for p in 9952 9960 9749; do echo PROCESS:$p; cat /proc/$p/cmdline; echo; ls -l /proc/$p/fd; done; netstat -lnt; ls -la /tmp/mnt/resources",
}
for name,command in commands.items():
    with (out/(name+'.txt')).open('wb') as f, (out/(name+'.stderr.txt')).open('wb') as e:
        p=subprocess.run(ssh+[command],stdout=f,stderr=e,timeout=180)
    print(name,p.returncode,flush=True)
with (out/'terminal.armv7.elf').open('wb') as f:
    subprocess.run(ssh+['cat /usr/bin/terminal'],stdout=f,check=True,timeout=90)
