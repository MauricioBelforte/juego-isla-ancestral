# -*- coding: utf-8 -*-
"""QA documental §21.8 para modulos ✅ sin sello de verificador.

Para cada modulo verifica:
  1. Conteo real de [x]/[?]/[ ] en 05-Checklist.md (regex estricta)
  2. Total declarado en el propio archivo vs conteo real
  3. Rutas mencionadas en 04-Codigo.md existen en el arbol
  4. Firma y Notas del Agente presentes
"""
import io, os, re, sys

ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
MODULOS = {
    "M07":  ("07-Arquitectura-General", "Documentacion"),
    "M133": ("133-Gestion-Del-Proyecto", "Documentacion"),
    "M134": ("134-Presupuesto", "Documentacion"),
    "M135": ("135-Riesgos-Del-Proyecto", "Documentacion"),
    "M136": ("136-Roadmap", "Documentacion"),
}

ITEM = re.compile(r"^\s*-\s+\[([ x?])\]")
# rutas tipo scripts/..., game/..., scenes/..., *.gd, *.tscn, *.tres, *.py
RUTA = re.compile(r"`((?:scripts|game|scenes|tools|assets|addons|\.claude)/[^\s`'\"<>|)]+)`")

def run(root, rep):
    ok_total = True
    for mid, (carp, _) in MODULOS.items():
        pa = os.path.join(ROOT, "DOCUMENTACION", carp, "plan-actual")
        ch = os.path.join(pa, "05-Checklist.md")
        cod = os.path.join(pa, "04-Codigo.md")
        rep.write("\n" + "=" * 70 + "\n%s  (%s)\n" % (mid, carp) + "=" * 70 + "\n")
        if not os.path.exists(ch):
            rep.write("FALTA 05-Checklist.md\n")
            continue
        with io.open(ch, encoding="utf-8") as f:
            lineas = f.readlines()
        x = q = p = 0
        for l in lineas:
            m = ITEM.match(l)
            if m:
                if m.group(1) == "x":
                    x += 1
                elif m.group(1) == "?":
                    q += 1
                else:
                    p += 1
        total = x + q + p
        rep.write("items: %d | [x]=%d [?]=%d [ ]=%d\n" % (total, x, q, p))
        # total declarado en el archivo
        decl = None
        for l in lineas:
            dm = re.search(r"(\d+)\s*(?:/|de\s+)\s*(\d+)", l)
            if dm and int(dm.group(2)) >= total * 0.5:
                decl = (int(dm.group(1)), int(dm.group(2)))
        if decl:
            rep.write("total declarado en texto: %s/%s -> %s\n" % (
                decl[0], decl[1], "OK" if decl[1] == total else "DESCUADRE"))
        if q:
            rep.write("ALERTA: hay %d [?] -> no puede ser ✅\n" % q)
            ok_total = False
        if p:
            rep.write("ALERTA: hay %d [ ] -> no puede ser ✅\n" % p)
            ok_total = False
        if total < 100:
            rep.write("ALERTA: menos de 100 items (regla minima)\n")
        # 04-Codigo.md: rutas existen? (probar ROOT y game/isla-ancestral/)
        if os.path.exists(cod):
            with io.open(cod, encoding="utf-8") as f:
                txt = f.read()
            rutas = set(RUTA.findall(txt))
            faltan = []
            for r in sorted(rutas):
                if os.path.exists(os.path.join(ROOT, r)):
                    continue
                if os.path.exists(os.path.join(ROOT, "game", "isla-ancestral", r)):
                    continue
                faltan.append(r)
            rep.write("04-Codigo.md: %d rutas citadas, %d NO existen\n" % (len(rutas), len(faltan)))
            for r in faltan[:8]:
                rep.write("   FALTA: %s\n" % r)
            if faltan:
                ok_total = False
            if "**Modelo:**" not in txt:
                rep.write("   ALERTA: 04-Codigo.md sin firma\n")
        else:
            rep.write("FALTA 04-Codigo.md\n")
        # firma y notas en el checklist
        if "**Modelo:**" not in "".join(lineas):
            rep.write("ALERTA: 05-Checklist.md sin firma\n")
        if "Notas del Agente" not in "".join(lineas):
            rep.write("AVISO: sin seccion 'Notas del Agente'\n")
    rep.write("\n=== RESUMEN: %s\n" % ("PENDIENTE DE SELLO" if not ok_total else "ver pass abajo"))
    return ok_total

rep_p = os.path.join(ROOT, "DOCUMENTACION", "TAREAS-POR-MODELO", "atria-dawn-s2", "qa_documental.txt")
with io.open(rep_p, "w", encoding="utf-8", newline="\n") as rep:
    run(ROOT, rep)
print("reporte:", rep_p)
