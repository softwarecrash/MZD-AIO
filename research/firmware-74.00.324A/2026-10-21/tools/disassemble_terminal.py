from elftools.elf.elffile import ELFFile
from capstone import Cs,CS_ARCH_ARM,CS_MODE_ARM,CS_MODE_THUMB
import pathlib,struct
out=sorted(pathlib.Path('.').glob('mcu_backup_*'))[-1]/'console_analysis'
with (out/'terminal.armv7.elf').open('rb') as f:
    e=ELFFile(f); dyn=e.get_section_by_name('.dynsym'); rel=e.get_section_by_name('.rel.plt'); plt=e.get_section_by_name('.plt')
    symbols={}
    for i,r in enumerate(rel.iter_relocations()):
        s=dyn.get_symbol(r['r_info_sym']); symbols[plt['sh_addr']+20+i*12]=s.name
    code=e.get_section_by_name('.text'); data=code.data(); addr=code['sh_addr']
    md=Cs(CS_ARCH_ARM,CS_MODE_ARM); ins=list(md.disasm(data,addr))
    with (out/'terminal_disassembly.txt').open('w') as log:
        for n,x in enumerate(ins):
            if x.mnemonic in ['bl','blx']:
                try: target=int(x.op_str.lstrip('#'),16)
                except ValueError: continue
                if symbols.get(target) in ['execl','getenv','parse_options']:
                    log.write('\nCALL '+symbols[target]+'\n')
                    for z in ins[max(0,n-16):n+8]: log.write(f'{z.address:08x}: {z.mnemonic} {z.op_str}\n')
    ro=e.get_section_by_name('.rodata'); raw=ro.data(); raddr=ro['sh_addr']
    with (out/'terminal_option_structures.txt').open('w') as log:
        for text in [b'fullscreen\0',b'shell\0']:
            value=raddr+raw.index(text); needle=struct.pack('<I',value)
            log.write(f'{text!r} string VA {value:#x}\n')
            for sec in e.iter_sections():
                if sec['sh_type']=='SHT_NOBITS':continue
                b=sec.data(); start=0
                while True:
                    idx=b.find(needle,start)
                    if idx<0:break
                    lo=max(0,idx-4); chunk=b[lo:idx+12]
                    log.write(f"{sec.name} VA {sec['sh_addr']+lo:#x}: {chunk.hex()}\n")
                    start=idx+1
print((out/'terminal_disassembly.txt').read_text())
print((out/'terminal_option_structures.txt').read_text())
