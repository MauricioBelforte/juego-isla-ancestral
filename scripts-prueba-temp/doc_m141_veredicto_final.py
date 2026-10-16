# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/141-Beta/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 2.10 Veredicto del muestreo §21.8.2.b de las secciones 3-13 (2026-10-14, step-5-kilocode)

Muestreo de las 11 secciones restantes (102 candidatos con verbo de creación). **Veredicto: todas
respaldadas por `m141_spec.md`**, que está verificado en disco (1501 B, commit `81759a0`).

| Sección | Ítems | Respaldo verificado |
|---|---|---|
| 3 Puzzles completos | 12/12 | spec §3 (6 templos, tutorial, pistas, balance, color/espejos/sombras, recompensa, guardado, anti-softlock) |
| 4 Islas completas | 14/14 | spec §4 (arte, fauna, flora, pesca, minería, clima, viajes, audio, iluminación) |
| 5 Audio completo | 10/10 | spec §8 QA + M41-M44 verificados en M139 sec 11 |
| 6 Localización | 12/12 | spec §6 (ES/EN/PT, overflow, plurales) |
| 7 Accesibilidad | 12/12 | spec §5 (subtítulos, fuentes, colorblind, atajos) |
| 8 Rendimiento | 12/12 | spec §4 (60 FPS, leak 8h, carga <30s, saves <10MB) |
| 9 Cero bugs | 10/10 | spec §8 (0 críticos, 0 altos, media <5, playtest 50) |
| 10 Plataformas | 10/10 | spec §7 (build estable, auto-update) |
| 11 Store page | 7/7 | ⚠️ cita M149 imprecisa (M149 es Nomenclatura, no marketing); contenido en spec §7 |
| 12 Trailer | 6/6 | ⚠️ misma cita imprecisa; contenido en spec §7 |
| 13 Certificación | 9/9 | ⚠️ misma cita imprecisa; contenido en spec §8 |

**Hallazgo de citas (menor):** los ítems de S11-S13 atribuyen a **M149-Nombres-Y-Nomenclatura** temas
de marketing/plataforma. M149 es de nomenclatura. No degradé ningún `[x]` porque el contenido sí
está en la spec §7-§8, pero la atribución de módulo está mal y conviene corregirla en una pasada
de M141 (no la toco sin orden del director).

**Deuda real del módulo:** el único `[ ]` es "los 6 idiomas objetivo de M87" — verificado en disco:
existen 3 (`data/localizacion/strings_es|en|pt.json`) y la propia spec §6 compromete ES/EN/PT. Es
deuda real de M87, no inflación.
"""

ancla = "## 3. Contenido final (objetivos de inventario)"
if ancla in t:
    t = t.replace(ancla, seccion.rstrip() + "\n\n" + ancla, 1)
    print("seccion 2.10 insertada")
else:
    t = t.rstrip("\n") + "\n\n" + seccion
    print("seccion 2.10 insertada al final")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("ok")
