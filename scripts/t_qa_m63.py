# -*- coding: utf-8 -*-
import os
BASE = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
p = os.path.join(BASE, "DOCUMENTACION", "63-Cargas-Y-Streaming", "plan-actual", "05-Checklist.md")
seal = (
 "\n## QA Cruzado §21.8 agnes 2026-10-06 (verificador != autor Hy3, re-QA de tercero)\n"
 "Auditora: agnes-3-flash / Kilo Code. VEREDICTO: SELLADO ✅ (re-QA independiente válida).\n"
 "\n### Lo que invalidó el sello anterior (Log 856) — respuesta al director\n"
 "1. **Qué se invalidó:** el sello Log 856 citó `test_stream_m63.gd` como '0 fallos EXIT 0', pero esa "
 "suite estaba **MUERTA** (3 SCRIPT ERROR + 3 de sus 4 funciones nunca corrían) → FALSO VERDE. "
 "Un sello sobre el '0 fallos' de una suite muerta es inválido.\n"
 "2. **Mi verificación cubre ese fallo específico:** re-corridas las 4 suites M63 con binario real "
 "(godot 4.7.2): `test_stream_m63` 29/0, `test_stream_m63_iter5` 51/0, `test_stream_m63_iter6` 42/0, "
 "`test_stream.gd` 21/0 = **143 checks / 0 fallos / EXIT 0 / SIN SCRIPT ERROR** → las suites EJECUTAN "
 "(no están muertas). Además el guardián anti-falso-verde (la suite nombra cada bloque no ejecutado en "
 "`_summary()` + exige piso MEDIDO + inyección ROJA reproduce EXIT 1) impide que una suite muerta dé '0 fallos'.\n"
 "\n### Conteo + bloqueos\n"
 "- Conteo independiente: 67 [x] / 27 [?] / 7 [ ] (coincide fila global).\n"
 "- 27 [?] + 7 [ ] = bloqueos EXTERNOS con dueño (M28/M69/M113/M112/M12/M08/M61/M47/M45/M46/M90/M114; 0 sin dueño).\n"
 "- 0 falsos-cierres. **No se sube estado** (flip GLOBAL = director, como M153/M150).\n"
)
with open(p, "ab") as f:
    f.write(seal.encode("utf-8"))
print("M63 QA seal appendida (re-QA de tercero)")
