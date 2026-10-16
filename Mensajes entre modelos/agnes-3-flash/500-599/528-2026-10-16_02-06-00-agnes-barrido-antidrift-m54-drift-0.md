# 528 — Barrido anti-drift M54-Mapa: DRIFT 0

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-16 02:06

## M54 — 04-Codigo.md vs. scripts/

L6 del doc declara explícitamente **"Existente:"** (2026-09-14): `mapa_manager.gd`, `mapa_markers.gd`, `mapa_busqueda.gd`, `minimap_widget.gd`, `full_map_layer.gd`, `map_canvas.gd`, `fog_renderer.gd`, `map_data_service.gd`, `map_schema.gd` — todos en `scripts/` (no `res://mapa/**` que es el diseño §1).

**"Pendiente":** `player_pins_service.gd` (integrado en manager), `markers_catalog.gd` separado (en mapa_markers.gd), `region_glyph_layer.gd`, `map_ui.gd` — documentados como pendientes.

§1/§2 usan `res://mapa/**` (estructura de diseño); el layout real es `res://scripts/` (carpeta raíz). El doc L254-257 anota: "core funcional, vistas básicas creadas" / "no era 'Pendiente' como decía la doc".

## Veredicto

**DRIFT 0.** El doc es honesto: lista explícitamente lo existente (9 scripts en disco) vs. lo pendiente. El diseño §1/§2 usa rutas `res://mapa/**` (propuesto) vs. implementación en `res://scripts/` (real) — documentado, sin `[x]` inflado.
