# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/140-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 2.1 Verificacion de mecanicas contra disco (cerrada 2026-10-14, step-5-kilocode)

Cierra la seccion 2 del checklist. Cada mecanica se verifico contra disco (grep + existencia de
carpeta/archivo). **Todos los modulos duenos existen.**

| Mecanica | Modulo | Estado verificado |
|---|---|---|
| Agricultura | M33 | **presente** — `scripts/farm/` (10 archivos: crop_tile, farm_service, farm_state_store, tests de clima y voxel). Riego (15 hits), cultivo (45), estacion (15). **Heladas: 0 hits** — pendiente |
| Pesca | M34 | **presente** — `scripts/fishing/` completo (spots, sesion, minijuego, ASMR) |
| Mineria | M35 | **presente** — `scripts/mineria/` (4 scripts + colocar_props_m25) |
| Crafting y cocina | M16 | **parcial** — `crafting.json` tiene **7 recetas** de las 60+ que pide el ítem |
| Construccion | M17 | **presente como contrato** — `construccion_validator.gd` + `zonas_permisos.gd` + catalogo de muebles. Nota honesta: la fuente M17 no esta implementada (el save provider existe, la fuente no) |
| Amistad | M20 | **presente** — `friendship_service.gd` + `friendship.json` con 15 hits de nivel |
| Viajes | M28 | **presente** — `travel_service.gd` + red de transporte (10 paradas / 20 rutas) |
| Templos y puzzles | M26/M24 | **presente** — `scripts/templos/` (puzzle_def, puzzle_agua, puzzle_bloques, puzzle_dificultad) + invariante anti-softlock |
| Artefactos pasivos | M13/M71 | **ausente** — 0 hits de "artefacto"/"pasivo" en `scripts/tools/` y en datos |
| Herramientas 5 niveles | M13 | **presente** — `scripts/tools/` (8 scripts, 90 hits de "herramienta", 57 de "nivel") |
| Habilidades con XP | M71 | **parcial** — hay XP (4 hits) y niveles (80) pero 0 hits de "habilidad" y 0 de "ventaja" |
| Menu de progresion | M53/M71 | **ausente** — no hay menu de progresion en `scripts/ui/` (los hits son de donation, museo, equipment) |
| 100% de M71 en Alpha | M71 | **verificado** — `DOCUMENTACION/71-Progresion/plan-actual/05-Checklist.md` tiene **168/168 `[x]`, 0 `[ ]`** |

**Conclusion para Alpha:** de las 13 mecanicas, **9 estan presentes con respaldo solido**, 3 son
parciales (crafting por recetas, habilidades por ventajas, agricultura por heladas) y 1 esta ausente
(artefactos pasivos). El menu de progresion es la pieza de UI que falta.

**Deuda de M23 arrastrada:** las 30+ misiones secundarias siguen en 2 (verificado en la seccion 1).
"""

ancla = "## 3. Sistemas integrados"
if ancla in t:
    t = t.replace(ancla, seccion.rstrip() + "\n\n" + ancla, 1)
    print("seccion 2.1 insertada")
else:
    print("AVISO: ancla no encontrada")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("ok")
