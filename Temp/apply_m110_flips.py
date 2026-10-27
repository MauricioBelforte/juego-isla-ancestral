import os, re, io
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
doc = os.path.join(root, "DOCUMENTACION")
d = [x for x in os.listdir(doc) if x.startswith("110-")][0]
p = os.path.join(doc, d, "plan-actual", "05-Checklist.md")
L = open(p, encoding="utf-8-sig", errors="ignore").read().splitlines(keepends=True)

# The 7 persistence items (exact line texts, verified at 06:00)
flips = {
    "save_config() [S]": "save_config() [S] — flip 27oct agnes (DS#430 M110 persistencia: debug_menu.gd RUTA_ESTADO user:// + test 75/0)",
    "reset_config() [S]": "reset_config() [S] — flip 27oct agnes (DS#430 M110 persistencia: reset defaults + borrar archivo + estado limpio)",
    "Guardar posición y tamaño [S]": "Guardar posición y tamaño [S] — flip 27oct agnes (DS#430: set/get_geometria serializa posición+tamaño)",
    "Guardar visibilidad de paneles [S]": "Guardar visibilidad de paneles [S] — flip 27oct agnes (DS#430: set/get_panel_visible + paneles_visibles)",
    "Guardar estado de toggles [S]": "Guardar estado de toggles [S] — flip 27oct agnes (DS#430: 6 toggle_* marcan _marcar_sucio; guardan al EXIT/WM_CLOSE)",
    "Guardar filtros de consola [S]": "Guardar filtros de consola [S] — flip 27oct agnes (DS#430: _console_entrades paralela + set_filtros_consola persiste preferencia)",
    "Guardar configuración al cerrar [S]": "Guardar configuración al cerrar [S] — flip 27oct agnes (DS#430: _notification(EXIT_TREE|WM_CLOSE_REQUEST) guarda solo si _estado_sucio)",
}

done = []
for i, l in enumerate(L):
    stripped = l.lstrip()
    if not stripped.startswith("- [ ]"):
        continue
    for key in flips:
        if key in l and l.lstrip().startswith("- [ ]"):
            old = l
            newl = l.replace("- [ ]", "- [x]", 1)
            # append note
            core = key  # the label
            base = old.rstrip("\n")
            # rebuild: - [x] <rest> + note
            rest = base[len("- [ ]"):]
            newl = "- [x]" + rest
            # add note if not already present
            if "flip 27oct" not in newl:
                note = flips[key].split(" — ", 1)[1] if " — " in flips[key] else ""
                newl = newl.rstrip("\n")
                nl = "\n" if old.endswith("\n") else ""
                newl = newl + " — " + note + nl
            L[i] = newl
            done.append((i + 1, key))
            break

# update Totales line (L311)
for i, l in enumerate(L):
    if "**Totales:**" in l and "225" in l:
        L[i] = "**Totales:** 225 ítems · [x] Completados: 179 · [?] No resueltos (con dueño): 0 · Pendientes: 46. (sync agnes 27oct: +7 M110 persistencia DS#430; el 150/75 previo era STALE contra el cuerpo 172/53.)\n"
        print("Totales actualizada en L%d" % (i + 1))
        break

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("".join(L))

print("Flips aplicados:", [k for _, k in done])

# verify
import collections
L2 = open(p, encoding="utf-8-sig", errors="ignore").read().splitlines()
cc = collections.Counter()
for l in L2:
    m = re.match(r"^\s*-\s*\[(.)\]", l)
    if m:
        cc[m.group(1)] += 1
print("M110 post: x=%d [ ]=%d [?]=%d total=%d" % (cc.get("x", 0), cc.get(" ", 0), cc.get("?", 0), sum(cc.values())))

# GLOBAL M110 row 150/225 -> 179/225 + note
g = os.path.join(root, "CHECKLIST-GLOBAL.md")
GL = open(g, encoding="utf-8-sig", errors="ignore").read().splitlines(keepends=True)
for i, l in enumerate(GL):
    if re.match(r"^\|\s*110\s*\|", l):
        newl = l.replace("150/225", "179/225", 1)
        # add note
        if "DS#430" not in newl:
            newl = newl.rstrip("\n").rstrip("|")
            if newl.endswith("|"):
                newl = newl[:-1] + " · **27oct DS#430 (Log):** M110 persistencia 7 items seccion N (debug_menu.gd + test 75/0). Progreso 150/225->179/225 (medido 05 cuerpo). | \n"
            else:
                newl = newl + " · **27oct DS#430:** M110 persistencia 7 items seccion N. Progreso 150/225->179/225. |\n"
        GL[i] = newl
        print("GLOBAL M110 fila actualizada L%d" % (i + 1))
        break
with io.open(g, "w", encoding="utf-8", newline="\n") as f:
    f.write("".join(GL))
print("GLOBAL M110 syncada")
