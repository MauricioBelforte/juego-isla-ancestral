import os, io, shutil, datetime
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
g = os.path.join(root, "CHECKLIST-GLOBAL.md")
L = open(g, encoding="utf-8-sig", errors="ignore").read().splitlines(keepends=True)

NOTE = (" · **27oct DS (Log 2211):** M48 Fase 2 implementada (4 archivos en "
        "`scripts/animacion/validacion/`: animation_validator.gd + import_animation_defaults.gd "
        "+ validate_animation_cli.gd + test_validacion_m48.gd), suite 50/0 x3 + gate headless "
        "exit 0 + 4 sondas EN ROJO. §21.8.2.b re-remuestreo: 0 .gd ausente -> M48 RE-ELIGIBLE. "
        "Progreso 43/123->113/123 (medido 05 cuerpo). Fila 48 DUPLICADA (L150 step-5 legacy + L151 "
        "deepseek) — dedup pendiente del fundador.")

changed = []
for idx, l in enumerate(L):
    if not l.lstrip().startswith("| 48 |"):
        continue
    if "| 43/123 |" not in l:
        continue
    newl = l.replace("| 43/123 |", "| 113/123 |", 1)
    if "deepseek-v4-flash-vision-exp" in newl:
        stripped = newl.rstrip("\n").rstrip()
        if stripped.endswith("|"):
            newl = stripped[:-1] + " " + NOTE + " |\n"
        else:
            newl = newl.rstrip("\n") + " " + NOTE + "\n"
    L[idx] = newl
    changed.append(idx + 1)

print("Filas 48 editadas:", changed)
bdir = os.path.join(root, "Obsoletos")
os.makedirs(bdir, exist_ok=True)
ts = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
bk = os.path.join(bdir, "CHECKLIST-GLOBAL-m48-sync-%s.md" % ts)
shutil.copyfile(g, bk)
print("backup ->", os.path.relpath(bk, root))
with io.open(g, "w", encoding="utf-8", newline="\n") as f:
    f.write("".join(L))

L2 = open(g, encoding="utf-8-sig", errors="ignore").read().splitlines()
for i, l in enumerate(L2):
    if l.lstrip().startswith("| 48 |"):
        print("post L%d: 113/123=%s  nota=%s" % (i + 1, "113/123" in l, "Log 2211" in l))
