import os, re, time, sys

base = r'Mensajes entre modelos'
order = ['atria-dawn','atria-dawn-s2','StepFun-Step-5-Preview','agnes-3-flash','Ling-3.1-Flash','DeepSeek-V4.1-Flash','Hy3','atria-dawn-s3','kimi-k3','Claude-Haiku-5.5']
processed = {
    'agnes-3-flash':259,
    'atria-dawn-s2':249,
    'atria-dawn-s3':182,
    'Ling-3.1-Flash':41,
    'StepFun-Step-5-Preview':127,
    'DeepSeek-V4.1-Flash':164,
    'Hy3':157,
    'atria-dawn':16,
    'muse-spark-1.3-contributor':2,
    'Claude-Haiku-5.5':11,
    'kimi-k3':4
}

ronda = 0
while True:
    ronda += 1
    found = False
    for c in order:
        path = os.path.join(base, c)
        if not os.path.isdir(path): continue
        files = [f for f in os.listdir(path) if f.endswith('.md') and re.match(r'^\d+-', f)]
        files.sort(key=lambda f: int(f.split('-')[0]))
        last = processed.get(c, 0)
        new = [f for f in files if int(f.split('-')[0]) > last]
        if new:
            found = True
            ts = time.strftime('%H:%M:%S')
            print(f'=== NUEVOS [{c}] ronda {ronda} {ts} ===')
            for f in new:
                fp = os.path.join(path,f)
                sz = os.path.getsize(fp)
                with open(fp, encoding='utf-8') as fh:
                    content = fh.read()
                is_template = 'PLANTILLA RESERVADA' in content and '<cuerpo del mensaje aca>' in content
                tag = ' [PLANTILLA]' if is_template else ''
                print(f'  {f} ({sz}b){tag}')
                if not is_template:
                    # print header + first 500 chars
                    lines = content.split('\n')[:15]
                    for l in lines:
                        print(f'  | {l[:120]}')
    if not found:
        ts = time.strftime('%H:%M:%S')
        print(f'[{ts}] ronda {ronda}: SIN NUEVOS')
    sys.stdout.flush()
    time.sleep(45)
