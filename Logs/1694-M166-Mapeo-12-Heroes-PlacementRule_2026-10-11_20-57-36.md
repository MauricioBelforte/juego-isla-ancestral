# Log 1694: M166 mapeo 12 heroes PlacementRule (opcion A)

**Fecha:** 2026-10-11
**Hora:** 20:57
**Modelo:** atria-dawn-s3 (estratega del director)
**Plataforma:** Kilo Code

## Resumen

Ejecute el encargo del director (msg 188, opcion A aprobada): mapear los heroes M166 que faltaban
como `PlacementRule` de M17. Cierre: **12 heroes con mesh resuelto** (10 recetas nuevas + totem
preexistente + antorcha_mano ya cubierto por antorcha_ancestral), test headless **108 checks /
0 fallos / EXIT 0**. H12 queda definitivamente cerrado.

## Cambios Realizados

- **10 recetas `PlacementRule` nuevas** en `game/isla-ancestral/data/construccion/piezas/`:
  `monolito_glifos`, `altar_ritual`, `cofre_ancestral`, `concha_mar`, `bote_pesca`,
  `muelle_madera`, `palanca_madera`, `pico_piedra`, `hacha_piedra`, `lingote_metal`. Todas con
  `familia` + `es_mueble` + `mesh_path` -> `assets/3d/alta/<modulo>_<heroe>.glb` +
  `max_por_zona`. Total recetas M17: 36 -> 46.
- **Test headless nuevo** `tests/test_m166_heroes_placement.gd`: 108 checks / 0 fallos / EXIT 0
  (Godot 4.7.2 real). Valida para los 12 heroes: carga del `.tres`, `id` coincide, `mesh_path`
  termina en el GLB esperado, perfil `alta/`, `familia` no vacia, `es_mueble`, `altura > 0` y que
  el GLB existe en disco.
- **`05-Checklist.md` M166:** H12 ampliado con el mapeo; **Totales 111 [x] / 0 [ ] / 1 [?]**;
  Notas del Agente completas (lo que hice / lo que NO / intento fallido / recomendaciones).
- **`CHECKLIST-GLOBAL.md`:** fila 166 reescrita limpia (progreso 111/112) — aproveche para
  eliminar un fragmento corrupto residual (`|ta/`) de una edicion anterior de la misma fila.

## Hallazgos

- **`antorcha_ancestral.tres` ya usaba** `13-Herramientas_antorcha_mano.glb` → ese heroe ya estaba
  cubierto; NO se creo receta duplicada (12 finales, no 13).
- **2 heroes quedan fuera por diseño:** `puerta_templo` y `anillo_piedras_ritual` son
  escenograficos fijos del mundo (M25/M10), no construibles por el jugador → no llevan
  `PlacementRule`. Si el switch de graficos debe degradarlos, necesitan la capa B de AssetProfile
  sobre la ruta literal de `colocar_props_m25.gd`.
- **NO se agrego `variantes_disponibles` a las recetas**: la expansion del schema de
  `placement_rule.gd` esta delegada a Hy3 (regla 21.4 — M17 🔵, no pisar).
- **Bug de un edit anterior:** la fila 166 de CHECKLIST-GLOBAL tenia un fragmento corrupto `|ta/`
  (resto de una edicion de la sesion anterior). Corregido al reescribir la fila completa.

## Archivos Modificados/Creados

- Creados: `game/isla-ancestral/data/construccion/piezas/{monolito_glifos,altar_ritual,cofre_ancestral,concha_mar,bote_pesca,muelle_madera,palanca_madera,pico_piedra,hacha_piedra,lingote_metal}.tres`
- Creado: `game/isla-ancestral/tests/test_m166_heroes_placement.gd` (72 lineas)
- Modificado: `DOCUMENTACION/166-Variantes-Y-Perfil-De-Rendimiento/plan-actual/05-Checklist.md`
- Modificado: `CHECKLIST-GLOBAL.md` (fila 166)
- Creado: `Logs/1694-M166-Mapeo-12-Heroes-PlacementRule_2026-10-11_20-57-36.md` (este log)
- Modificado: `Logs/NUMEROS_DISPONIBLES.txt` (1694 consumido, cabeza -> 1695, 1306 restantes)

## Notas

- Sin commits ni push (trabajo de flota en curso).
- QA §21.8 pendiente por otro modelo (Hy3 o DeepSeek) — yo escribi el test.
- Deuda: F1 (autoload `AssetProfile` a 2 capas) delegada a Hy3 por el director.
