# Log 2220: M17 — suite de reglas declarativas por pieza contra el catálogo real (+5 ítems)

**Fecha:** 2026-10-27
**Hora:** 21:40
**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)

## Resumen

Tanda del riel **M17 (P3)**. El validador de M17 es **declarativo** (lee `PlacementRule`), pero las
suites que ya existían probaban las reglas con **recetas sintéticas**. Esta tanda añade una suite que
las prueba contra el **catálogo real** (`res://data/construccion/piezas/`, 46 recetas `.tres`
cargadas por `BuildCatalogDB`), que es el dato que el jugador realmente toca.

Suite NUEVA `res://tests/test_m17_reglas_pieza.gd` → **40 checks, 0 fallos, EXIT 0** (Godot 4.7.2
headless), cableada en `.github/workflows/quality.yml` (M118).

Ítems cerrados (+5 `[x]`, M17 de 126/175 → **135/175**; pendientes 48 → 39):
**G137** (puerta exige pared contigua) · **G138** (ventana exige pared contigua de al menos 1 celda) ·
**G141** (camino solo sobre césped/arena) · **G145** (ruina M25 / parcela NPC no colocables ni
demolidas) · **F121** (la validación se re-ejecuta con cada rotación).

## Cambios Realizados

### Suite nueva

`game/isla-ancestral/tests/test_m17_reglas_pieza.gd` — **40 checks, 0 fallos, EXIT 0**.

| Item | Checks | Evidencia (texto literal) |
|---|---|---|
| G137 | 7 | "receta puerta 'puerta_madera' tiene requiere_pared == true" · "receta puerta 'puerta_piedra' tiene requiere_pared == true" · "puerta 'puerta_madera' SIN pared contigua -> REQUIERE_PARED" · "puerta 'puerta_madera' CON pared contigua -> sin REQUIERE_PARED" (idem `puerta_piedra`) |
| G138 | 7 | "receta ventana 'ventana_marco' tiene requiere_pared == true" · "receta ventana 'ventana_arco' tiene requiere_pared == true" · "ventana 'ventana_marco' SIN pared contigua -> REQUIERE_PARED" · "ventana 'ventana_marco' CON pared contigua -> sin REQUIERE_PARED" (idem `ventana_arco`; con **una sola** celda contigua `pared`) |
| G141 | 13 | "camino 'camino_cesped' superficie_ok == ['terreno'] (sin piso/techo/pared/agua/aire)" (idem `camino_arena`, `camino_piedra`) · "camino 'camino_cesped' sobre 'roca' (fuera de superficie_ok) -> SIN_SOPORTE" · "camino 'camino_cesped' sobre 'terreno' (en superficie_ok) -> ok" |
| G145 | 8 | "preset PARCELA_NPC == PROTEGIDA" · "preset RUINA == PROTEGIDA" · "zona PROTEGIDA -> ZONA_PROTEGIDA para cualquier receta" · "colocar receta deconstruible=false -> ok (manager permite colocar)" · "demoler receta deconstruible=false -> NO_DECONSTRUIBLE" · "demoler pieza NORMAL (deconstruible=true) -> ok" |
| F121 | 5 | "preview rotacion 0 -> cache=false (primera evaluacion)" · "preview misma celda/rot/receta -> cache=true (cache hit)" · "preview rotacion 1 (cambia huella) -> cache=false (recalculo real)" · "la rotacion 1 cambia las celdas afectadas (2x1 -> huella en Z)" · "el contador de recalculos del preview sube con el cambio de rotacion" |
| Control catálogo | 3 | "catalogo carga recursiva res://data/construccion/piezas (46 recetas)" · "catalogo valido (sin problemas de schema): ok == true" · "12 familias canonicas PRESENTES (RF12 bloque J)" |

### Mecanismos verificados

- `PlacementRule.requiere_pared` (`scripts/construccion/placement_rule.gd` L49) — flag declarativo en
  los `.tres` (2 puertas + 2 ventanas = `true`).
- Regla 4 del validador (`scripts/construccion/construccion_validator.gd` L89-92) →
  `tiene_pared_contigua()` (L209-215) sobre los 4 vecinos horizontales.
- Regla 3 (soporte) → `contar_soportes()` (L146-154) contra la whitelist `PlacementRule.superficie_ok`
  (L43): el camino solo acepta `terreno`; la roca no está en la lista → 0 soportes → `SIN_SOPORTE`.
- Regla 1 (zona) → `ZonasPermisos.PARCELA_NPC` / `.RUINA` = `Permiso.PROTEGIDA`
  (`scripts/construccion/zonas_permisos.gd` L28-30) → `ZONA_PROTEGIDA` antes que cualquier otra regla.
- Guard de demolición (`scripts/construccion/build_manager.gd` L493-496): `deconstruible == false` →
  `Motivo.NO_DECONSTRUIBLE`; control con `deconstruible == true` demuele normal.
- Cache del preview (`scripts/construccion/build_preview.gd` L46): se invalida al cambiar
  `(celda, rotacion, receta_id)`; `evaluar()` toma la rotación viva del manager (L39-40).

### Documentación

- `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md` → +5 `[x]` con cita de checks nombrados;
  Totales normalizados a **135 [x] / 39 [ ] / 1 [?] = 175** (la última línea de Totales manda; las
  previas quedan como historial).
- `DOCUMENTACION/17-Construccion/plan-actual/04-Codigo.md` → nueva §7 "Tanda P3-3" con el detalle
  técnico, los checks por ítem y la deuda restante; firma renovada.
- `CHECKLIST-GLOBAL.md` → fila 17 sincronizada a **135/175** (agente `minimax-m3-1-flash`, actividad
  `2026-10-27 21:40`) + nota con la evidencia.
- `.github/workflows/quality.yml` → suite M17 nueva cableada en el job `test-suite` (lane M17).

### Deuda que queda (anotada en los propios ítems, no tapada)

- **G145 — data:** el catálogo M17 tiene **0 recetas con `deconstruible == false`** (check explícito en
  la suite). El GUARD del sistema está implementado y verificado con una receta sintética; las piezas
  de ruina (M25) y de evento (M73) todavía no existen como recetas. Deuda de **data**, no de código.
- **G139 escalera** ("no bloquea la circulación"): no hay implementación en el validador lógico → `[ ]`.
- **M "Raycast 1/frame + cache de celda"**: la cache de celda existe, pero el raycast vive en la capa
  de input/UI, fuera del riel headless → `[ ]`.

## Archivos Modificados/Creados

**Creados:**
- `game/isla-ancestral/tests/test_m17_reglas_pieza.gd`
- `Logs/2220-M17-REGLAS-DECLARATIVAS-POR-PIEZA-SUITE-NUEVA_2026-10-27_21-40-00.md` (este)

**Modificados:**
- `.github/workflows/quality.yml`
- `DOCUMENTACION/17-Construccion/plan-actual/04-Codigo.md`
- `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md`
- `CHECKLIST-GLOBAL.md`

## Notas

- **No se tocó ningún `.gd` de `scripts/construccion/`**: la tanda es puramente de cobertura y
  documentación (la suite nueva es aditiva), así que no hay riesgo de regresión en las 3 suites de M17
  que ya corren en CI.
- **No auto-sello** (§21.8/§21.23): el QA de M17 lo hacen Hy3, agnes-3-flash o Nemotron. Este log
  documenta el trabajo; el sello formal no me corresponde.
