import io, os, re, subprocess, datetime, json, random
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
res = subprocess.run(["git","status","--porcelain"],cwd=root,capture_output=True,text=True)
now = datetime.datetime.now()
stable = []
for line in res.stdout.splitlines():
    line = line.strip()
    if not line: continue
    path = line[3:]
    fp = os.path.join(root,path)
    try: m = os.path.getmtime(fp)
    except: m = now.timestamp()
    age = (now-datetime.datetime.fromtimestamp(m)).total_seconds()//60
    if age >= 15: stable.append(path)
print("ESTABLES:",len(stable))
for p in stable: subprocess.run(["git","add","-A","--",p],cwd=root)
ts = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
msg = f"""Se preservaron avances de la jornada 28oct (post-12c0657)

- M61: 3 flips T189-61 medibilidad [x] (GLOBAL 118->146/148) + medición/medicion_runtime/validate_budget/test_m61 + Log 2232/2235.
- Nemotron D1/G2/I1: RIEL-GATE2-SONDA-CORE.md + RIEL-INVESTIGACION-AUTONOMIA.md + RIEL-D1-DOC-INTERRUPCION-38min.md (herencia Hy3->Nemotron).
- Logs 2230/2233 + estado_director.json + CHECKLIST-GLOBAL backup m61-sync + acuses de canal (DeepSeek/GLM/Hy3/Ling) + scripts-prueba convertir_markdown_m110.py.

Firma: agnes-3-flash (Sapiens AI) / Kilo Code — {ts}"""
subprocess.run(["git","commit","-m",msg],cwd=root,capture_output=True,text=True)
head = subprocess.run(["git","log","-1","--oneline"],cwd=root,capture_output=True,text=True).stdout.strip()
print("HASH:",head[:40])
