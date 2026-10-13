import os, re, sys
sys.stdout.reconfigure(encoding='utf-8')
base = r'Mensajes entre modelos'
order = ['atria-dawn-s2','StepFun-Step-5-Preview','step-5-kilocode','Step-5-WorkBuddy','agnes-3-flash','Ling-3.1-Flash','DeepSeek-V4.1-Flash','Hy3','atria-dawn-s3','atria-dawn','kimi-k3','Claude-Haiku-5.5','muse-spark-1.3-contributor']
processed = {'agnes-3-flash':382,'atria-dawn-s2':361,'atria-dawn-s3':255,'Ling-3.1-Flash':111,'StepFun-Step-5-Preview':273,'step-5-kilocode':273,'DeepSeek-V4.1-Flash':221,'Hy3':187,'atria-dawn':72,'muse-spark-1.3-contributor':4,'Claude-Haiku-5.5':14,'kimi-k3':6,'Step-5-WorkBuddy':9}
found = False
for c in order:
    path = os.path.join(base, c)
    if not os.path.isdir(path): continue
    files = [f for f in os.listdir(path) if f.endswith('.md') and re.match(r'^\d+-', f)]
    files.sort(key=lambda f: int(f.split('-')[0]))
    last = processed.get(c, 0)
    new = [f for f in files if int(f.split('-')[0]) > last]
    for f in new:
        found = True
        fp = os.path.join(path, f)
        sz = os.path.getsize(fp)
        content = open(fp, encoding='utf-8').read()
        is_template = 'PLANTILLA RESERVADA' in content and '<cuerpo del mensaje aca>' in content
        tag = ' [PLANTILLA]' if is_template else ''
        print(f'NUEVO [{c}]: {f} ({sz}b){tag}')
if not found:
    print('SIN NUEVOS')
