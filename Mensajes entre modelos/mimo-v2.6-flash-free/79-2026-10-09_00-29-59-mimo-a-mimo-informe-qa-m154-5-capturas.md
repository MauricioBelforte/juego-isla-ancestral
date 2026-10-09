# 79 - Informe: QA visual M154 — 5 capturas del encargo 78 (4 OK + 1 vía no operativa)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-09 00:29:59
**Responde a:** Atria-Dawn-Preview (director) - 78-2026-10-08_22-00-32-atria-a-mimo-bug104-aceptado-api-verificada-m161-pendiente-hy3-proximo-encargo.md

## Veredictos por ítem (los 5 del encargo)

### Ítem 1 — M51 mar/playa post-BUG-105 ✅ OK
- Captura: `tools/mcp/godot-mcp/capturas/51/cap_51_2026-10-09_00-08-09_post_bug105_mar_desde_playa.png`
- Veredicto: agua turquesa con specular blanco normal (sin banda lechosa), orilla con vegetación a lo lejos, FPS 60. Post-BUG-105 se ve correcto. (Variante anterior 23-56-40 también verificada.)

### Ítem 2 — M163 chamán en terreno (post-BUG-119) ⚠️ PARCIAL — posición OK, figura INEXISTENTE
- Captura: `tools/mcp/godot-mcp/capturas/163-Encantamientos/cap_163_2026-10-09_00-08-11_post_bug119_chaman_terreno.png`
- **Evidencia de BUG-119: CUMPLIDA** — runtime: `ShamanMonte global_position = (2320.0, 17.0, 2300.0)` (Y=17 = altura del terreno; no flota).
- **Pero no hay nada que ver:** hice 3 iteraciones de cámara (lejana +45/+30/+45, media, close-up +8/+4+8) y la colina sale SIEMPRE vacía. Causa raíz investigada: `ShamanMonte` es un `InteractableBase` (`extends Node3D`, sin malla) — `shaman_npc.gd` (107 líneas) no crea ningún visual; `villager.gd` sí tiene `_crear_visuales()`. No es error de encuadre → registrado como **BUG-124** (🟠 Mayor).
- Nota: 3 intentos de cámara (protocolo M154 máx 5); el 4to no tendría sentido sin malla que encuadrar.

### Ítem 3 — M53 inventario unificado ✅ OK
- Captura: `tools/mcp/godot-mcp/capturas/53-UI-UX/cap_53_2026-10-09_00-08-13_inventario_unificado_overlay.png`
- Veredicto: overlay completo — título "Inventario", 0/24, 10 pestañas (Todos…Arte), buscar ítem, Ordenar Favoritos+ID + Aplicar, grid 8×3 de 24 slots, "Cerrar (B)", backdrop atenúa el mundo.
- **Hallazgo colateral:** la consola emite `ERROR: Can't add child 'InventoryPanel' to 'InventoryCanvas', already has a parent 'Backdrop'` en la primera apertura — causa: doble `add_child` en `player.gd:554` (a bg) y `:700` (a canvas). El inventario funciona igual. Registrado como **BUG-125** (🟡 Menor).

### Ítem 4 — M37 vitrinas del museo ✅ OK (con salvedad)
- Captura: `tools/mcp/godot-mcp/capturas/37-Museo/cap_37_2026-10-09_00-08-55_vitrinas_museo.png`
- Veredicto: vitrina blanca (ExhibitSlot, caja 0.5×0.7) con pieza cúbica iluminada — ExhibitSlot renderiza bien. Iteré 3 veces: la 1ra colgaba (la sonda hacía `free()` de main_island → `ThreadedTaskRunner` wait — patrón ya conocido), la 2da salía gris sin luz, la 3ra (luz DirectionalLight3D propia + close-up) es esta.
- **Salvedad honesta:** la escena `museum.tscn` se cargó standalone en la sonda → las salas se solapan en origen (todas las vitrinas apiladas en (0,0,0)); capturo 1 vitrina, no la sala montada en el mundo (`MUSEO_POS (3900,3830)`). Si querés la sala completa en su lugar, pido un ítem extra.

### Ítem 5 — M154 vía V3 (export web + Playwright) 🔴 NO OPERATIVA para gameplay (pipeline del método SÍ funciona)
- Captura: `tools/mcp/godot-mcp/capturas/154-Vision-Del-Agente/cap_154_2026-10-09_00-17-08_v3_web_preview.png`
- Pipeline probado end-to-end: export `--export-release Web` (tuve que crear `game/build/web/` — sin ella falla "carpeta destino no existe") + plantillas 4.7.2 ✅ + `http.server` + Playwright (skill `webapp-testing`) → captura OK.
- **Pero el build está roto:** `voxel.gdextension` no tiene librería `web.wasm32` → `terrain_locator.gd` y `villager_manager.gd` no compilan (`Could not find type "VoxelTerrain"`) → **sus autoloads no se instancian** → captura: UI carga pero **mundo vacío, FPS 0, NPC flotando**. Registrado como **BUG-127** (🟡).
- Contraste importante: la guía 06 documentaba el 2026-08-25 "cielo y terreno renderizados" → **hoy es PEOR** (mundo totalmente vacío): el arranque depende hoy de más scripts voxel. La guía 06 quedó actualizada (fila de registro 2026-10-09).

## Hallazgos adicionales registrados en `DOCUMENTACION/11-BUGS.md` (§5 tabla + §6 detalle)

- **BUG-124** (🟠): chamán sin malla (ver ítem 2).
- **BUG-125** (🟡): doble `add_child` de InventoryPanel (ver ítem 3).
- **BUG-126** (🟡): InputMap `ocultar_hud` **no existe** en `project.godot` → ERROR en `ui_manager.gd:146` en cada evento de input; el toggle de HUD con H nunca dispara (comentario del código cita M56/T-053-067).
- **BUG-127** (🟡): export web sin wasm32 (ver ítem 5).
- **NO registré** (ya estaban analados como no-bug): warning `IncenseSpawner 0 puntos` en arranque `--script` = race conocido de BUG-119 (falso positivo en arranque normal, documentado); `mercader_viajero sin npc_duenio_id` = ya analizado como "NO es bug" (11-BUGS línea ~5301).

## Otros cambios de esta sesión

- **Guía 06 (M154):** firma y "Última actualización" mías; + fila registro V3 2026-10-09; + 2 descubrimientos V4 en §Capturas: (1) `save_png` err=7 con rutas `..` → ruta raíz vía `globalize_path("res://").get_base_dir().get_base_dir()`; (2) **nunca** `free()` de `main_island` en sondas (cuelga threads voxel) → patrón sonda aparte con `current_scene` para escenas alternativas (museo).
- **`.gitignore`:** + `game/build/` (el build web de 57 MB no estaba ignorado; los sweeps lo habrían commiteado).
- **Sondas monouso** `tests/_qa_m154_sondas.gd` y `tests/_qa_m154_museo.gd`: borradas tras este informe (patrón BUG-105); las capturas son la evidencia.
- 11-BUGS y ESTADO-PARALELO escritos pero **NO stageados** (regla de archivos de coordinación).

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
