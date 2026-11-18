# -*- coding: utf-8 -*-
import io, os, re
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

def contar(ruta):
    t = io.open(ruta, encoding="utf-8").read()
    x = len(re.findall(r"^- \[x\]", t, re.M))
    p = len(re.findall(r"^- \[ \]", t, re.M))
    q = len(re.findall(r"^- \[\?\]", t, re.M))
    return x, p, q

# 1. Drift 38-Economia y 73-Coleccionables
for mod, carp in [("38-Economia", "38-Economia"), ("73-Coleccionables", "73-Coleccionables")]:
    p = os.path.join(root, "DOCUMENTACION", carp, "plan-actual", "05-Checklist.md")
    if os.path.exists(p):
        x, pe, q = contar(p)
        print(mod, "05-Checklist real: [x]=", x, " [ ]=", pe, " [?]=", q, " total=", x+pe+q)
    else:
        print(mod, "NO EXISTE:", p)

# 2. Filas globales 38 y 73
cg = io.open(os.path.join(root, "CHECKLIST-GLOBAL.md"), encoding="utf-8").read()
for linea in cg.splitlines():
    if re.match(r"^\| (38|73|139|148|48|115|127) \|", linea):
        print("GLOBAL:", linea[:150])

# 3. Autoload CruceroManager + manager en disco
pg = io.open(os.path.join(root, "game", "isla-ancestral", "project.godot"), encoding="utf-8", errors="replace").read()
m = re.search(r"\[autoload\](.*?)(?:\[|$)", pg, re.S)
print("AUTOLOADS:", m.group(1).strip() if m else "SIN SECCION")
cm = os.path.join(root, "game", "isla-ancestral", "scripts", "crucero", "crucero_manager.gd")
print("crucero_manager.gd existe:", os.path.exists(cm), "| bytes:", os.path.getsize(cm) if os.path.exists(cm) else 0)
cp = os.path.join(root, "game", "isla-ancestral", "scripts", "crucero", "crucero_pasaje.gd")
print("crucero_pasaje.gd existe:", os.path.exists(cp), "| bytes:", os.path.getsize(cp) if os.path.exists(cp) else 0)

# 4. IDs duplicados en CHECKLIST-GLOBAL (conteo de filas por ID)
ids = {}
for linea in cg.splitlines():
    mm = re.match(r"^\| (\d+) \|", linea)
    if mm:
        ids.setdefault(mm.group(1), []).append(linea[:100])
for i in ["48", "115", "127", "139", "148"]:
    print("ID", i, "filas:", len(ids.get(i, [])))
    for f in ids.get(i, []):
        print("   ", f)
