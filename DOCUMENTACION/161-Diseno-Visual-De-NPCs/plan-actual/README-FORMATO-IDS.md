# README — Formato de IDs y estructura del catálogo M161 (Diseño Visual de NPCs)

**Módulo:** 161-Diseño-Visual-De-NPCs · **Dueño actual:** agnes-3-flash (reserva §21.3, #752) · **Últ. actualización:** 2026-10-21

## 1. Ubicación de los datos
- **23 diseños** en `game/isla-ancestral/data/npc_visuals/` (subcarpetas por isla):
  - `AUR/` (Isla Aurora) — 5 diseños: `NPC-AUR-001..005`
  - `CEN/` (Isla Ceniza) — 5 diseños: `NPC-CEN-001..005`
  - `COR/` (Isla Coral) — 5 diseños: `NPC-COR-001..005`
  - `RIZ/` (Isla Raíz) — 8 diseños: `NPC-RIZ-001..008`
- **Autoload:** `scripts/data/npc_visual_database.gd` (`NPCVisualDatabase`, carga `res://data/npc_visuals/` recursivo).
- **Modelo de datos:** `scripts/data/npc_visual_data.gd` (`NPCVisualData`), `scripts/data/ropa_data.gd` (`RopaData`), `scripts/data/accesorio_data.gd` (`AccesorioData`).
- **Validadores headless:** `tests/unit/data/test_npc_visual_database.gd` (suite 356 checks) + `tools/npc_visual_check.gd` (23/0 fallos).

## 2. Formato del `npc_id`
`NPC-<ISLA>-<NNN>-<rol>` — donde:
- `ISLA` ∈ {RIZ, COR, CEN, AUR} (prefijo de 3 letras, verificado por `npc_visual_check.gd` contra el set de islas).
- `NNN` = secuencia 001..008 (3 dígitos con ceros a la izquierda).
- `<rol>` = nombre legible del diseño (ej. `NPC-RIZ-001-mayor`).
- El campo `npc_id` del `.tres` guarda `NPC-<ISLA>-<NNN>` (sin el rol); el **nombre de archivo** incluye el rol (`NPC-<ISLA>-<NNN>-<rol>.tres`).

## 3. Campos clave de `NPCVisualData`
`npc_id` · `nombre` · `isla` · `piel` (código SK-xx, §1 03-Diseno) · `cabello` (HR-xx, §2) · `ojos` (EY-xx, §3) · `complexion` · `herramienta_derecha`/`_izquierda` (id M159 `OBJ-XXX-NNN` o `""`) · `retrato_path` (M46, aún vacío) · `sombrero`/`torso`/`piernas`/`pies` (`RopaData` con `color_principal`/`secundario` HEX) · `accesorios` (`AccesorioData`) · `variantes_estacionales` (dict, aún `{}` — RF6, owner M45/M46 + iter 2).

## 4. Cross-checks (verificados contra disco, agnes 2026-10-21)
- **Herramientas → M159:** 7/7 refs de `herramienta_derecha` resuelven en `data/items/` (`OBJ-ART-005`, `OBJ-HER-001/004/006`, `OBJ-TAL-002`).
- **IDs vs M19:** M19 (`data/villagers/`) = 14 NPCs nombrados; M161 = 23 diseños por rol. **Sets distintos** (ver hallazgo scoping, agnes #755).

## 5. Cómo agregar un nuevo NPC
1. Crear `data/npc_visuals/<ISLA>/NPC-<ISLA>-<NNN>-<rol>.tres` (clonando uno de la isla) con `npc_id` único + `isla` válida.
2. Completar rasgos (piel/cabello/ojos con códigos de 03-Diseno §1-3) + ropa (`RopaData` con HEX válidos) + herramienta M159 si aplica.
3. Correr `godot --headless --path game/isla-ancestral -s res://tools/npc_visual_check.gd` (debe dar 0 fallos, +1 diseño) y `... -s res://tests/unit/data/test_npc_visual_database.gd` (0 fallos).
4. Si agrega una isla nueva, actualizar el set de islas validas en `npc_visual_check.gd` + la tabla §8 de 03-Diseno.

**Modelo:** agnes-3-flash (Sapiens AI) · **Plataforma:** Kilo Code · **Fecha:** 2026-10-21
