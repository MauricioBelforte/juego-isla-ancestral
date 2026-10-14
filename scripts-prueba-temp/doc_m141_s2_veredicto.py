# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/141-Beta/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 2.9 Veredicto del muestreo §21.8.2.b de la sección 2 (2026-10-14, step-5-kilocode)

La sección 2 (Historia completa) quedó 14/14 `[x]` (trabajo de agnes-3-flash sobre `m141_spec.md`,
verificado: el archivo existe en `DOCUMENTACION/141-Beta/plan-actual/m141_spec.md`, 1501 B, commit
`81759a0`, y sus líneas 18-26 respaldan uno a uno los 14 ítems). Muestreo contra disco:

| Ítem muestrado | Veredicto | Evidencia |
|---|---|---|
| Hook `HistoriaMaster` → `EpílogoDisponible` | ✅ defendible | `postgame_manager.gd` L26/L163 + `test_historias.gd` L136/L141 |
| Créditos de cierre | ✅ defendible | `scripts/legal/credits_manager.gd` (autoload M131) + `data/legal/creditos.json` (7 entradas) — promovido por falso negativo del QA |
| Transición Sello6 → Acto3 → epílogo | 🟡 parcial | `postgame_manager.gd` existe; la cadena completa es de Beta |
| CI sin strings TODO/placeholder en diálogos | 🟡 parcial | no hay gate de CI específico para diálogos (los hits son del addon GdUnit y un comentario de M48); queda como criterio de la spec |
| 3 rutas de sellos validadas | 🟡 parcial | 0 hits de "ruta de sello" en scripts; el diseño está en M140 §1.4 y la spec §2 |

Veredicto: 3 de 5 defendibles, 2 parciales (los parciales son de Beta, fase no construida). No hay
ítem inflado nuevo; la sección queda validada con los matices anotados.

**Hallazgo de coherencia:** la spec §6 compromete **ES/EN/PT 100%**, es decir 3 idiomas. Eso confirma
que la deuda del único `[ ]` del módulo ("los 6 idiomas objetivo de M87") es real: en disco hay
exactamente 3 (`data/localizacion/strings_es.json`, `strings_en.json`, `strings_pt.json`).
"""

ancla = "### 2.8 Cierre de los 3"
if ancla in t:
    # insertar despues de 2.8
    idx = t.find(ancla)
    fin = t.find("## 3. ", idx)
    t = t[:fin] + seccion.rstrip() + "\n\n" + t[fin:]
    print("seccion 2.9 insertada")
else:
    t = t.rstrip("\n") + "\n\n" + seccion
    print("seccion 2.9 insertada al final")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("ok")
