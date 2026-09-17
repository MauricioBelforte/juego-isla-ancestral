# Log 944: QA cruzado M09 Terreno y Geografia (segundo QA — revierte ✅ a 🟡)

**Fecha:** 2026-09-16
**Hora:** 22:52
**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code

## Resumen

Segundo QA cruzado (§21.8) sobre el módulo 09 (Terreno y Geografia), que estaba
`✅ Completado por Deepseek V4 Flash` (ya con un QA previo de Hy3, Log 848). El
modulo revierte a `🟡 Con dudas`: el diseno es genuino y completo, pero la seccion F
del checklist afirma integraciones que **materialmente no existen**.

## Cambios Realizados

- `05-Checklist.md` (M09): 7 items flipeados a `[?]`:
  - F1-F5: "consumido por M10/M50/M61/M71-M74/M66" — **falsos**: no existe
    `data/biomes/`, `data/formations/` ni `data/poi/`; ningun `.tres`/`.json` de
    recetas; la clase `FormationRecipe` no existe; busqueda en todo `scripts/` de
    `data/biomes|data/formations|formation_|biome_resonance|poi_faro` → 0 refs.
    Los consumidores reales usan `IslandDefinition.BIOMAS` de M27 y el ruido propio
    de M10 (`island_generator.gd:205`).
  - H.8: "Mapa de Aurora con 8 POI" — 03-Diseno §5 lista 7.
  - A17: "sin scripts propios" — stale (BUG-030); `terreno_horizonte.gd` (360 l.)
    es de M09.
  - Totales: 105/105 → 98 [x] / 7 [?] / 0 [ ].
  - Se agrego seccion "I. QA Cruzado" con veredicto, evidencia y recomendaciones.
- `04-Codigo.md` (M09): se agrego seccion "6. QA Cruzado — Notas del Agente
  (atria-dawn)". Historial previo (Deepseek V4 Flash, MiMo V2.5) intacto.
- `CHECKLIST-GLOBAL.md` fila 09: `✅ Completado 105/105` → `🟡 Con dudas 98/105`,
  ultima actividad 2026-09-16 22:50, nota de QA agregada (no se piso la firma ni
  el QA de Hy3 del Log 848).

## Hallazgos positivos (lo que SI esta bien)

- 03-Diseno.md es sustancioso y verificable: 16 formaciones con parametros
  (grieta 10-30 m / -40, cascada solo con salto >= 8 m, playa 5-10 bloques al
  2-3 %), tabla de 13 biomas con altura/material/decoracion/islas, 5 reglas de
  transicion, erosion, legibilidad, anti-softlock.
- La regla AGENTS.md "nunca crear un IslandGenerator propio con radio hardcodeado"
  **se cumple y esta validada automaticamente**: `world_generator.gd:23` crea la
  instancia unica (static var), `TerrainLocator` posiciona contra el VoxelTerrain
  real, y `validador_isla_raiz.gd:87-88` comprueba que villager/player no
  instancian clones.
- `test_terrenos.gd` (M156): 0 fallos. Boot headless del proyecto: arranca
  completo; unico ERROR es "9 resources still in use at exit" (teardown).

## Correccion a mi propio analisis (honestidad)

En un primer momento flipee H.12 (DoD) argumentando "M09 no tiene codigo". Era
informacion incompleta: `terreno_horizonte.gd` (360 l., glm-5.3-flash, Logs 751-795)
es un entregable runtime real, verificado con test manual del usuario (impostor
visible a 1300 m). **Reverti ese flip** y lo deje [x] con aclaracion. La deuda real
es el catalogo de recetas consumible, no "el codigo de M09". Queda documentado en
la seccion I del checklist y en la seccion 6 de 04-Codigo.md.

## Hallazgo adicional (transversal M09/M156)

`class_name TerrainData` **duplicado**: `scripts/terrain/terrain_data.gd` (legacy,
enum-based) y `scripts/terrenos/terrain_data.gd` (M156, int-based). La carpeta
`terrain/` es legacy pero `terrain_data.gd` nunca fue renombrado. El boot no emitio
error visible, pero la resolucion es orden-dependiente y
`terrain_data_provider.gd` hace `... as TerrainData` sobre resources de
`res://resources/terrain/` → cast ambiguo. Recomendacion: renombrar a
`LegacyTerrainData` o borrar la carpeta.

## Archivos Modificados/Creados

- `DOCUMENTACION/09-Terreno-Y-Geografia/plan-actual/05-Checklist.md` (flips + seccion I)
- `DOCUMENTACION/09-Terreno-Y-Geografia/plan-actual/04-Codigo.md` (seccion 6 QA)
- `CHECKLIST-GLOBAL.md` (fila 09)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (liberacion M09)
- `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn/BACKLOG-MASTER.md` (iter 5)
- `Logs/944-QA-M09-Terreno-Geografia_2026-09-16_22-52.md` (este log)

## Recomendaciones para el proximo agente

1. Decidir el destino de M09: (a) crear los `.tres` de recetas + `FormationRecipe` y
   cablear consumo, o (b) aceptar que es diseno puro y reescribir la seccion F como
   "contrato propuesto para" (no "consumido por").
2. Corregir `04-Codigo.md §2` (lista paths inexistentes) o crear los archivos.
3. Renombrar la clase legacy `scripts/terrain/terrain_data.gd`.
4. Aclarar si el mapa de Aurora tiene 7 u 8 POI.
5. Convertir `test_terrain.gd` (M156) en headless (SceneTree) para que entre en la
   suite de regression.
