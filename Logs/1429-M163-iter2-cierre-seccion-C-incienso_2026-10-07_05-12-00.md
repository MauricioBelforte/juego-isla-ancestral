# Log 1429: M163 iter. 2 — cierre de la sección C (Incienso)

**Fecha:** 2026-10-07
**Hora:** 05:12
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Cerrada la **sección C (Incienso, 15 ítems)** de `163-Sistema-De-Encantamientos`
(iter. 2 asignada en msg 51, plan aprobado con **opción A autorizada** en msg 53).
Resultado: **14 [x] con cita + 1 [?] con dueño** → totales del módulo
**49 [x] / 5 [?] / 70 [ ] = 124**. Meta aprobada "48 [x] + hasta 2 [?]"
**superada**: C12 (estacionalidad M29) cableó y quedó `[x]`.

Suites: `test_incienso.gd` **67 checks / 0 fallos / exit 0** con
`CHECKS_MINIMOS` **medido = 67**; regresión `test_enchantment.gd` **58/0 exit 0**.
**2 sondas rojas** con EXIT=1 verificado y restauración byte-exacta.
Runtime real headless: `[M163] IncenseSpawner: 6 puntos en montaña (0 fallas de
altura, centro (2320.0, 2300.0))` — la condición 3 del director (terreno trabado
→ `[?]`) **no se activó**.

## Cambios Realizados

1. **`incense_cultivation.gd` (Resource, nuevo)** — ciclo de cultivo: 3 días
   (`DIAS_COSECHA` sobre `GameTime.dia_absoluto()`), rendimiento 2–4
   (`RENDIMIENTO_MIN/MAX` con RNG diario `rng_diario("m163_incienso")` o rng
   inyectable), guards: doble plantado → `false` y cosecha antes de tiempo → `0`;
   renewable (limpia el lote al cosechar).
2. **`incense_point.gd` (nuevo, hereda InteractableBase)** — planta de montaña de
   la cadena E: nace plantado en `_ready`, `categoria = &"cosecha"` (existe en
   `categorias_interaccion.tres`), prompt dinámico ("Cosechar incienso" /
   "faltan N d" / "agotado"), `interactuar()` cosecha 2–4 al `Inventario`
   (`incense` o `incense_rare`) y pasa a `NO_DISPONIBLE` con `dia_agotado`;
   `renovar(dia)` a los 3 días.
3. **`incense_spawner.gd` (Node3D, nuevo)** — spawnea 6 puntos con seed fija 163
   alrededor de la montaña: centro = `MundoRaiz.CENTRO - (240, 260)` (misma
   fórmula que `_crear_shaman`), alturas **solo** vía
   `TerrainLocator.get_height` (sin radio/centro de isla hardcodeado — check
   anti-P39 en la suite leyendo el fuente); `_on_dia_cambio` renueva agotados
   (C8) y `_on_estacion_cambio` renueva + garantiza un punto raro (C3/C12,
   cableado a M29 **sin tocar M29**). Locator/centro inyectables para tests.
4. **Items M14**: `data/items/incense.tres` (cat. ITEMS=11, `stack_max = 99`,
   `precio_venta = 5`) y `data/items/incense_rare.tres` (rareza RARO, precio 20),
   auto-cargados por `ItemDatabase`.
5. **`main_island.gd` — OPCIÓN A AUTORIZADA (msg 53, solo lo pedido)**:
   - L25 (en `_ready`, tras `_crear_shaman()`): `+` 1 línea → `_crear_incense_spawner()`.
   - Fin del archivo (tras L420 `_crear_shaman`): `+` 9 líneas → función
     `_crear_incense_spawner()` (load + new + name + add_child + print, patrón
     idéntico a `_crear_farm_controller`).
   - `_crear_shaman()` **intacto**. Dicho diff es exactamente el que autorizaste.
6. **`test_incienso.gd` (nuevo)** — 67 checks: A items (15), B unit del cultivo
   (16, incluye las 2 sondas), C punto vía cadena E con patrón M70
   (`_evaluar_y_seleccionar` manual), D spawner con `MockLocator` (inyección,
   sin-hardcode, renovación, estacionalidad, cosecha de raro E2E).
7. **`GUIA-GODOT/01` §34** (26): hallazgos nuevos — class_name recién creado no
   registra hasta `--editor --quit`; `--script` con error de carga ejecuta el
   juego normal (distinto de §30.1). + 2 filas en la tabla rápida + firma.
8. **`05-Checklist.md`**: sección C completa (14 [x] con cita + `[?]` L80 con
   dueño M19), bloque "Progreso — Sección C", "Notas del Agente (iter. 2)",
   Reserva actualizada, totales 49/70/5.

### Sondas rojas (msg 53, obligatorias)

| # | Mutación | Resultado | Restauración |
|---|----------|-----------|--------------|
| 1 | guard de cosecha antes de tiempo (`if not listo(...)` → `if false:`) | **EXIT=1** — 3 [FAIL] (B7/B8/B16), Resumen 64/3 | byte-exacta → verde 67/0 |
| 2 | guard de doble plantado (`if plantado:` → `if false:`) | **EXIT=1** — 1 [FAIL] (B2), Resumen 66/1 | byte-exacta → verde 67/0 |

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/enchantment/incense_cultivation.gd` (nuevo)
- `game/isla-ancestral/scripts/enchantment/incense_point.gd` (nuevo)
- `game/isla-ancestral/scripts/enchantment/incense_spawner.gd` (nuevo)
- `game/isla-ancestral/scripts/enchantment/test_incienso.gd` (nuevo)
- `game/isla-ancestral/data/items/incense.tres` (nuevo)
- `game/isla-ancestral/data/items/incense_rare.tres` (nuevo)
- `game/isla-ancestral/scripts/main_island.gd` (2 ediciones autorizadas, ver arriba)
- `DOCUMENTACION/163-Sistema-De-Encantamientos/plan-actual/05-Checklist.md`
- `DOCUMENTACION/GUIA-GODOT/01-gdscript-errores-comunes.md` (§34)
- `Logs/NUMEROS_DISPONIBLES.txt` (−1429)
