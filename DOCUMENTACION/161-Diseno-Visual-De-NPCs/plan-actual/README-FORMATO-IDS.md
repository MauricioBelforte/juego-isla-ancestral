# README — Formato de IDs y estructura del catálogo M161 (Diseño Visual de NPCs)

**Módulo:** 161-Diseño-Visual-De-NPCs · **Dueño actual:** agnes-3-flash (reserva §21.3, #752) · **Últ. actualización:** 2026-10-21

Este archivo documenta el formato de los 23 diseños visuales de NPC y cómo consumirlo. Es el artefacto que habilita los ítems de M161 ("guía/README del formato de IDs y su uso") — el módulo aporta los DISEÑOS (palette/proporciones/herramienta M159); que otros módulos los consuman es deuda de integración (§21.4).

## 1. Ubicación de los datos

- **23 diseños** en `game/isla-ancestral/data/npc_visuals/` (subcarpetas por isla):
  - `AUR/` (Isla Aurora) — 5 diseños: `NPC-AUR-001..005`
  - `CEN/` (Isla Cenote) — 5 diseños: `NPC-CEN-001..005`
  - `COR/` (Isla Corazón) — 5 diseños: `NPC-COR-001..005`
  - `RIZ/` (Isla Ríz) — 8 diseños: `NPC-RIZ-001..008`
- **Config:** `data/npc_visuals/npc_needs_config.tres` (M161 propio, no es diseño de NPC).
- **Autoload:** `scripts/data/npc_visual_database.gd` → `NpcVisualDatabase` (singleton, carga recursiva).

## 2. Estructura de un diseño (`NPCVisualData`)

Cada `.tres` de diseño es un `Resource` de clase `NPCVisualData`:

| Campo | Tipo | Ejemplo `NPC-RIZ-001` (anciana recolectora) |
|---|---|---|
| `npc_id` | String | `"NPC-RIZ-001"` (único, formato `NPC-{ISLA}-{NNN}`) |
| `isla` | String | `"RIZ"` |
| `rol` / `profesion` | String | `"colector"` / `"colector de bayas"` |
| `piel` / `cabello` / `ojos` | Color | paletas §3/§4/§5 de `03-Diseno.md` |
| `proporcion_cabeza` | float | 0.38 (regla §6.3: 0.35–0.40) |
| `altura` | float | 1.55 (rango 1.40–1.95) |
| `herramienta_derecha` | String | ID M159 del catálogo (`tal_002` = M159-52) |
| `accesorio` / `accesorios` | Dictionary | `{"cabeza": "sombrero_de_paja"}` |
| `color_acento` | Color | color de acento del diseño |
| `modelo_3d` | Resource (null) | ⏳ owner M45 |
| `retrato_path` | String (vacío) | ⏳ owner M46 |
| `variantes_estacionales` | Dictionary | 4 estaciones, paletas `03-Diseno` §9.4 (RF6 iter 2) |

## 3. Formato del ID

`NPC-{ISLA}-{NNN}` donde ISLA ∈ {AUR, CEN, COR, RIZ} y NNN = 001..0NN. La herramienta de referencia (`herramienta_derecha`) usa el **ID M159 del catálogo** (no el nombre), p. ej. `her_001` (guantelete de jade / M159-05, 7×), `art_005` (arco de caoba / M159-16, 4×), `her_004` (cuchillo de sílex), `her_006` (red), `tal_002` (molino / M159-52, 3×).

## 4. Cómo consumirlo (para M19/M155/M160/otros)

- **Leer diseño por ID:** `NpcVisualDatabase.get(npc_id)` → `NPCVisualData` (ej. `get("NPC-RIZ-001")`).
- **Filtrar por isla:** `NpcVisualDatabase.filter_por_isla("RIZ")` → los 8 diseños de RIZ.
- **Validar un diseño:** `NpcVisualDatabase.validar(d)` → true si `npc_id`/`isla`/`rol`/`piel` no vacíos + HEX válidos.
- **Validar el banco completo:** `NpcVisualDatabase.validar_banco()` → todos los diseños validan.

Los módulos consumidores (M19 villagers nombrados, M155 vestimenta, M160 ubicaciones, M27, M29, M39) **deben** llamar a `NpcVisualDatabase` para obtener el diseño visual; M161 aporta los datos, el consumo es deuda de integración (§21.4, ver "Notas de Integración" en `04-Codigo.md`).

## 5. Estado y pendientes

- ✅ 23 diseños + autoload + test suite (356/0) + validador (23/0).
- ⏳ `modelo_3d`/`retrato_path` → owner M45/M46 (los 2 `[?]` de M161, externo).
- ⏳ `variantes_estacionales` (92 archivos) → RF6 iter 2 (paletas §9.4 ya en los 23).
- ⏳ Integración M19 (14 NPCs nombrados vs 23 diseños) → decisión del fundador (#759: 2 módulos separados).

**Firma:** agnes-3-flash (Sapiens AI) / Kilo Code.
