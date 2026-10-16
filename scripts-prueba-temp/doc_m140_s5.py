# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/140-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 2.6.1 Contenido de Alpha contra disco (cerrado 2026-10-14, step-5-kilocode)

Cierra la seccion 5 del checklist. **Verificado contra disco, no estimado.**

| Bloque | Objetivo | Verificado en disco |
|---|---|---|
| Islas jugables | 4 de 6 | **presentes como semillas/datos**: `generar_islas.gd` define aurora, verde, flotante, submarina, misteriosa, secreta; "ceniza" (4 hits) y "flora" (16 hits) ya aparecen en el catalogo. **Las 4 de Alpha (Aurora, Coral, Ceniza, Flora) quedan como seleccion a confirmar** |
| Templos nuevos | 2 (Profundidades, Ceniza) | **presentes como puzzles** — `scripts/templos/` tiene puzzle_agua y puzzle_bloques como base; los 2 templos nuevos son instanciacion, no motor nuevo |
| NPC con rutinas | 24-30 en 4 islas | **parcial** — `scripts/npc/` tiene 9 scripts y el elenco de M139 definio 8 NPC (2.3.1). Faltan ~16-22 NPC para el rango |
| Coleccionables | 80 de 100 | **15 reales** — `data/coleccionables/catalog.json` tiene 15 items. Brecha grande |
| Museo completo | M37 | **parcial** — modulo 37-Museo existe y M139 definio 5 secciones (Naturaleza, Geologia, Botanica, Marina, Pesca); el catalogo completo no esta |
| Eventos estacionales | 4 (1 por estacion) | **parcial** — `catalogo_eventos.json` existe (analytics) y hay 30 hits de fiesta/festival; los 4 eventos base estan por definir como datos |
| Recetario | 60+ con items de todas las islas | **7 reales** — `data/balance/crafting.json`. Brecha muy grande (arrastra desde la seccion 2) |
| Flora y fauna por isla | M50/M36 | **presente** — `vegetacion_config.json` v2 con 7 tipos de terreno (playa, pradera, bosque, montana, ribera, humedal, cercanias) y `data/fauna/catalog.json` con 7 especies |
| Audio por zona | M41-M44 | **presente** — 10 sectores en `ambient_biome_bank.json` + matriz de musica + ASMR (verificado en M139 seccion 11) |
| Meta de partida | 60-100 h | no verificable por disco (requiere telemetria de sesion) |
| Verificacion de horas | telemetria de sesion | **presente como contrato** — telemetria opt-in local definida en M139 4.1; la metrica de horas por sesion se agrega al dashboard |
| Reutilizacion via pipeline M108 | 100% del contenido | **presente** — pipeline con validador y cuarentena verificado en M139 seccion 9 |

**Conclusion de contenido para Alpha:** de 12 bloques, **5 tienen respaldo solido** (templos como
instanciacion, flora/fauna, audio, pipeline y el contrato de horas), **5 son parciales** con brecha
cuantificada (NPC 8/24-30, coleccionables 15/80, museo, eventos, recetario 7/60+) y **2 no son
verificables por disco** (meta de horas y su metodo, que requieren telemetria real).

**Brechas cuantificadas para planificar:** NPC +16 minimo · coleccionables +65 · recetas +53 ·
museo: 3 de 8 secciones (a confirmar con M37).
"""

ancla = "### 2.7 Deuda t\u00e9cnica"
if ancla in t:
    t = t.replace(ancla, seccion.rstrip() + "\n\n" + ancla, 1)
    print("seccion 2.6.1 insertada")
else:
    print("AVISO: ancla no encontrada")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("ok")
