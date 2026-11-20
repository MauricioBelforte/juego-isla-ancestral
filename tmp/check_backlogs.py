import os, re, glob

base = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\DOCUMENTACION\TAREAS-POR-MODELO\HY4 Flash\BACKLOGS"
for b in [42,43,46,47,48,49,50,51,52,53]:
    files = [f for f in os.listdir(base) if f.startswith(f"{b}-")]
    if not files:
        print(f"b{b}: NO FILE")
        continue
    fpath = os.path.join(base, files[0])
    text = open(fpath, encoding="utf-8").read()
    x = len(re.findall(r"\[x\]", text))
    space = len(re.findall(r"\[ \]", text))
    q = len(re.findall(r"\[\?\]", text))
    print(f"b{b} ({files[0]}): [x]={x} [ ]={space} [?]={q}")
PYEOF