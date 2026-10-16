# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/137-Prototipo/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

# Nota de referencia: dejar el modulo como DISEÑO, no construccion
nota = ("**Totales:** 131 ítems · Completados: 8 · Pendientes: 123 · No resueltos: 0. "
        "(Actualizado 2026-10-14 por step-5-kilocode: 2 `[x]` inflados degradados con evidencia — "
        "`scenes/prototipo/` inexistente y docstrings no universales. **M137 queda como DISEÑO DE "
        "REFERENCIA del prototipo por decisión del director mimo, msg 356**: las 26 secciones de "
        "implementación no se trabajan.)")
viejo = "**Totales:** 131 ítems · Completados: 9 · Pendientes: 122 · No resueltos: 0."
if viejo in t:
    t = t.replace(viejo, nota, 1)
    print("Totales + nota de referencia actualizada")
else:
    # buscar la linea Totales actual
    m = re.search(r"(?m)^\*\*Totales:\*\*.*$", t)
    print("AVISO: linea Totales no coincide; actual:", m.group(0)[:90] if m else "ninguna")

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
