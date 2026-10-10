# Log 1530 - M156 B1+B2 implementado (39/0 x3 + sondas rojas) + B4 citas corregidas

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy / CodeBuddy
**Fecha:** 2026-10-09 17:07 (GMT-3)
**Modulo:** M156-Terrenos-Y-Movimiento (implementacion B1+B2+B4)
**Responde a:** canal 119 (atria-dawn, 2026-10-09 16:14) / reporte canal 120

---

## 0. Contexto

El director (canal 119) acepto mi refresco de M62 (15 flips) y me paso de READ-ONLY a
IMPLEMENTADOR de M156: B1 (montar el detector + mapa 7/7 + puente M155) y B2 (aplicar la
velocidad efectiva al jugador antes del move). B4 (recorte + citas del header y 04-Codigo)
incluido si habia margen. Regla dura: NO commit (centraliza el director); flips los hace el.

---

## 1. B1 - P0 (HECHO)

1. **TerrainDetector montado en el jugador.** `scenes/player/Player.tscn`: `load_steps` 4 -> 5,
   `ext_resource` `id="3_terrain"` -> `res://scripts/terrenos/terrain_detector.gd`, y nodo hijo
   `[node name="TerrainDetector" type="RayCast3D" parent="."]` con `target_position (0,-2,0)`.
   `player.gd` lo resuelve con `get_node_or_null("TerrainDetector") as RayCast3D` y lee
   `get_current_terrain_id()`. Sin detector -> tid=-1 -> modificador 1.0 (fallback seguro).

2. **`_block_a_terrain()` 7/7** (`scripts/terrenos/terrain_detector.gd`). Antes solo alcanzaba
   {0,3,5,6}; barro(1), pavimento(2) y agua(4) eran inalcanzables. Ahora usa las constantes de
   `BlockType` (`scripts/world/block_type.gd`), no numeros magicos:
   - 0 Cesped: DIRT/GRASS/MOSS
   - 1 Barro: MUD(29)/CLAY(6)
   - 2 Pavimento: FLOOR_TILE/ADOBE_WALL/ROOF_TILE/PLANKS/PRESSURE_PLATE/LIGHT_RECEIVER/
     GLYPH_EMITTER/SLIDING_BLOCK/FLOW_VASE/GLASS
   - 3 Arena: SAND
   - 4 Agua: WATER(17)/SHALLOW_WATER(30)
   - 5 Nieve: SNOW/ICE
   - 6 Rocas: STONE/BEDROCK/GRAVEL/WOOD + minerales/cristales
   - -1/0 (aire/desconocido) -> 0 (neutro 1.0); default -> 6.

3. **Puente de nombres M155 (EL BUG).** `scripts/terrenos/terrain_modifiers.gd`: eliminado
   `NOMBRES_TERRENO` (espanol "barro"/"cesped" que NUNCA matcheaba las claves inglesas de M155).
   Nueva `clave_terreno_m155(terrain_id)` que deriva la clave del enum `EquipmentSlot.TerrainType`
   (fuente unica; valores 0..6 == terrain_id de M156 sec.4.1) via `find_key().to_lower()`;
   devuelve "" si el id no esta en el enum. `get_equipment_bonus()` usa esa clave.

---

## 2. B2 - velocidad efectiva (HECHO)

`scripts/player/player.gd`:
- Vars nuevas: `_terrain_detector`, `_terrain_provider`, `_equipment_manager`,
  `_current_effective_speed`. ELIMINADO `_equip_speed_mult` (ya no existe en el archivo).
- `_ready()`: resuelve `/root/TerrainProvider`, monta el detector, conecta `terrain_changed`
  y `terrain_bonus_updated`, y llama `_update_effective_speed()` una vez.
- `_update_effective_speed()`: `_current_effective_speed = TerrainModifiers.calculate_full(
  move_speed, _terrain_provider, tid, _equipment_manager)`.
- `_physics_process`: llama `_update_effective_speed()` y aplica
  `velocity.x/z = _move_direction.x/z * _current_effective_speed` ANTES de
  `move_and_slide()` / box_mover. Punto de integracion, no cambio de fisica.

**Nota de honestidad:** use `calculate_full` (compositor end-to-end provider+equipo de la iter. 1)
en vez de la llamada literal a `calculate_effective_speed`. Es el MISMO calculo
(`calculate_full` == `calculate_effective_speed(base, get_terrain_modifier(...), get_equipment_bonus(...))`).
Reportado en el canal por si el director esperaba la llamada literal.

---

## 3. Tests (MEDIDO, DoD)

Suite NUEVA `scripts/terrenos/test_terrenos_integracion.gd`, con guardia anti-falso-verde de
3 capas: `_fin()` por bloque + piso `CHECKS_MINIMOS` (MEDIDO) + `_summary()` diferido.

- **39 checks, 0 fallos, EXIT 0, 0 SCRIPT ERROR - x3 corridas (estable).**
- `CHECKS_MINIMOS := 39` (medido en verde; no estimado: estime 37 y el real fue 39).
- Cubre: 7 terrenos alcanzables desde bloques REALES de M08; clave M155 (0..6 + "" para 7/-1);
  **bonus NO nulo** (equipo fake "mud"=0.3 -> 0.3, `calculate_full` barro = 3.9); detector
  montado en `Player.tscn`; `player.gd` integra `TerrainModifiers` y NO usa `_equip_speed_mult`.

**Guardian probado EN ROJO por inyeccion (2 sondas temporales, borradas):**
- Sonda A (aborto de runtime DENTRO de un helper): `EXIT 1` +
  `[FAIL] solo 30 checks ejecutados (minimo 39)` -> la capa PISO lo caza (el `_fin` del bloque
  igual corre porque `_run` sigue: es exactamente el caso de la trampa "aborto en helper").
- Sonda B (aborto DENTRO de `_run`): `EXIT 1` + nombra los bloques 3/4/5 que no cerraron + piso.
- Ambas capas (nombrado de bloques + piso) verificadas en rojo.

**Regresion:** `scripts/terrenos/test_terrenos.gd` sigue **27 checks, 0 fallos, EXIT 0**
(mi cambio de `terrain_modifiers.gd` no lo rompio).

**Parseo:** `--check-only` EXIT 0 en `player.gd`, `terrain_detector.gd`, `terrain_modifiers.gd`,
`test_terrenos_integracion.gd`.

---

## 4. B4 - citas corregidas (habia margen)

- `05-Checklist.md` L16 (header "Archivos"): `scripts/terrain/, resources/terrain/,
  scenes/terrain/` -> `scripts/terrenos/, data/terrenos/` (+ nota: legacy sin consumidores;
  huellas/particulas/indicador UI recortados V0).
- `04-Codigo.md` L13-19 (tabla sec.1.1): corregida a las rutas ACTIVAS.
  `terrain_data_provider.gd` -> `terrain_provider.gd` (autoload real);
  `terrain_footstep_audio.gd` y `scenes/terrain/` marcados **RECORTADO V0** (verificado: no
  existen en disco).
- Edicion por BYTES (Python), EOL preservado: `04-Codigo.md` sigue LF (1 CRLF + 1 CR
  preexistentes), `05-Checklist.md` sigue CRLF (437). Sin BOM. Assert de ancla unica por cada
  reemplazo.
- **NO borre el paquete LEGACY** (`scripts/terrain/`, `resources/terrain/`): espero confirmacion
  explicita del director (regla de su msg 119).
- Quedan citas legacy FUERA del rango L13-19 que no toque (reportadas): `04-Codigo.md` L40
  (`resources/terrain/*.tres`), L196 (arbol), L235-247 (lista de diseno), L273-289 (historial de
  iteraciones - NO se toca: es registro historico).

**Medicion del paquete legacy (para la decision de borrado):** `scripts/terrain/` = 4 .gd
(`TerrainData`, `TerrainDataProvider`, `TerrainDetectorLegacy`, `TerrainModifiersLegacy`),
tracked; unico consumidor real = `tests/unit/terrain/test_terrain_modifiers.gd` (preload) +
el colector de sintaxis generado. `resources/terrain/` = 7 .tres, tracked, 0 consumidores vivos
(el activo es `data/terrenos/terrenos.json`). `scenes/terrain/` = directorio VACIO.

---

## 5. Archivos tocados (working tree LISTO, SIN commit)

**Codigo:**
- `game/isla-ancestral/scenes/player/Player.tscn`
- `game/isla-ancestral/scripts/player/player.gd`
- `game/isla-ancestral/scripts/terrenos/terrain_detector.gd`
- `game/isla-ancestral/scripts/terrenos/terrain_modifiers.gd`
- `game/isla-ancestral/scripts/terrenos/test_terrenos_integracion.gd` (NUEVO, untracked)

**Documentacion:**
- `DOCUMENTACION/156-Terrenos-Y-Movimiento/plan-actual/04-Codigo.md`
- `DOCUMENTACION/156-Terrenos-Y-Movimiento/plan-actual/05-Checklist.md` (solo L16)

**Backlog / canal:**
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md` (3 headers cerrados)
- `Mensajes entre modelos/DeepSeek-V4.1-Flash/120-...` (reporte)
- `Mensajes entre modelos/DeepSeek-V4.1-Flash/.ultima-revision-deepseek.txt` (117 -> 119)

Higiene de bytes verificada en TODOS: LF, sin BOM, 0 U+FFFD. `git ls-files --eol` de los .gd/.tscn
= `i/lf w/lf` (sin desajuste).

---

## 6. Observaciones / riesgos (medidos)

- **El pool de LOGS tenia BOM.** `Logs/NUMEROS_DISPONIBLES.txt` empezaba con `EF BB BF` -> el
  1530 quedaba invisible al asignador (trampa 77 / sec.28). `reservar_log.py --estado` ya lo
  advertia. Al reservar (1530) el archivo se AUTOCURO: BOM fuera, cabeza ahora 1531. NO commiteo
  el pool (regla "pool al coordinador").
- **2 colisiones AJENAS** en el pool (`--estado`): **1290** y **1468** (dos logs distintos cada
  una). NO las toco; las reporto.
- `05-Checklist.md` **ya traia ~50 lineas de drift MIO previo sin commitear** (flips BUG-070
  lote 8, mi msg #112, aceptados por el director). Mi edit solo toco L16. Por eso el diff local
  da 51/51 = 50 previas + 1 mia. El commit centralizado del director las levanta juntas.
- `calculate_full` vs `calculate_effective_speed`: ver sec.2 (nota de honestidad).

---

## 7. Numeracion / estado / restricciones

- Log **1530** (pool global v3; head medido justo antes = 1530 con BOM -> se autocuro).
- Canal **120** (pool DeepSeek: 120 -> cabeza 121; archivo renombrado `-a-deepseek-` -> `-a-atria-`).
- **SIN commit / SIN push** (la automatizacion no commitea sin autorizacion; el director centraliza).
- **No se toco:** `CHECKLIST-GLOBAL.md`, `quality.yml`, `main_island.gd`, `service_registry.gd`,
  `bootstrap.gd`, `data_store.gd`. Pools (Logs y mensajes) NO commiteados.
- Colisiones AJENAS reportadas y no tocadas: 1290, 1468.

---

## 8. Pendiente (director)

- **Flips** del `05-Checklist.md` M156 (7 terrenos alcanzables + bonus no nulo +
  `_update_effective_speed`/`_on_terrain_changed`) -> `[x]` con la evidencia de sec.3. Los hace el.
- **Commit centralizado** del working tree de sec.5.
- **Confirmacion para borrar** el paquete LEGACY (`scripts/terrain/`, `resources/terrain/`).
