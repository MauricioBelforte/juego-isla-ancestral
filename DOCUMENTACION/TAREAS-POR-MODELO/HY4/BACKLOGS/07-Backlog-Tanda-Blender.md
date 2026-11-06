# Hy4 — TANDA BLENDER (4nov, agnes-3-flash #05)

**Fuente:** agnes-3-flash #05 (4nov 23:01)
**Modelo:** Hy4 preview (Tencent Hunyuan)
**Plataforma:** WorkBuddy
**Estado:** [→] En progreso

## T-01: 4 vehículos M67 (Poly Haven + template_asset.py + generar_variante_headless.py)
- [ ] T-01a: **Barco** (Barquita de Aurora, ~5m, agua) — Poly Haven model or custom lowpoly
- [ ] T-01b: **Dirigible** (Globo del Viento, ~12m, aire)
- [ ] T-01c: **Submarino** (Perla Ancestral, ~8m, subagua)
- [ ] T-01d: **Locomotora** (Gran Vapor M68, ~15m, riel)
- Data source: `game/isla-ancestral/data/vehiculos/vehicles.json`
- Reference: `tools/mcp/blender-mcp/template_asset.py` + `generar_variante_headless.py`
- Poly Haven for reference models if available (search before generating)

## T-02: M157 Transporte (asset + integración)
- [ ] Create M157 transport asset (lowpoly, 3 variants ALTA/MEDIA/BAJA)
- [ ] Export GLB + .glb.import
- [ ] Integrate in scene (terrain locator, z_min=0.045)
- Reference: M157 documentation in `DOCUMENTACION/157-Transporte/`

## T-03: HUD elements (iconos/assets UI 3D)
- [ ] Create 3D icons for HUD (vehicles, collectibles, UI elements)
- [ ] Export to Godot format
- Reference: existing HUD assets in `game/isla-ancestral/assets/ui/`

## T-04: B-15-02 (pendiente from B5 reaudit)
- [ ] Complete B-15-02 pending items from previous backlog
- [ ] Reference: `BACKLOGS/05-Backlog-B1-B6.md` section B5

## 6 Pendientes Adicionales
- [ ] quality.yml GO: request to director (encoding-guard suite integration)
- [ ] 29 scripts M36/M50: decision on relocation (requires M36/M50 owner)
- [ ] B6: 662 rutas desactualizadas + 28 módulos ✅ citando artefactos ausentes
- [ ] H-1: autoloads localización duplicados (project.godot)
- [ ] 12 colisiones numeración heredadas (1290..2120)
- [ ] 20 .py en game/ (congelados por guardia)

## Contexto Flota (4nov)
- Flota: agnes (directora) + Nemotron (boot/doc) + Hy3 (gate-2) + Hy4 (Blender) + DS-OC (pools/chase) + GLM (supervisor)
- Blender MCP: protocolo 5 (addon actualizado pendiente `uvx mcp-for-blender install-addon`)
- Poly Haven: activo para assets (buscar antes de generar)
- Regla: reportar por vehículo (T-01a/b/c/d separado), no batch

## Reglas
- No tocar: `AGENTS.md`, `CHECKLIST-GLOBAL.md`, `quality.yml`, `project.godot`, `05-Checklist` ajenos
- No hacer: QA §21.8, sellos, flips ajenos, push
- UTF-8 §28 obligatorio
- z_min = 0.045 para todos los assets

**Total: 4 tareas principales + 6 pendientes = 10 items. Prioridad: T-01 (4 vehículos) → T-02 → T-03 → T-04 → pendientes.**

**Firma:** agnes-3-flash (Sapiens AI) / Kilo Code — 2026-11-04 23:01
