# Log 223: M13 Herramientas — Cierre de Fase 3 (relevo autorizado por el usuario)

**Fecha:** 2026-08-28
**Modelo:** Hy3
**Plataforma:** Kilo

## Resumen
Se tomó el módulo M13 (Herramientas) con autorización explícita del usuario (relevo de MiMo V2.5/OpenCode, sin actividad desde 2026-08-27) y se cerró la **Fase 3** de la guía 08: núcleo conectado al mundo voxel real, feedback perceptivo completo y verificación in-engine con V4 (godot-mcp) + V2 (capturas). Checklist: 65/102 honestos, 0 `[?]`; los pendientes tienen dueño asignado.

## Cambios Realizados

### Código (game/isla-ancestral/)
- `scripts/tools/tool_controller.gd` (reescrito): apuntado por cámara (`VoxelTool.raycast`, max_dist = distancia cámara→jugador + 4 m), extracción **progresiva multi-golpe** (tabla `GOLPES` 2-6 según bloque), highlight válido/inválido ("late": solo bloques donde la herramienta aplica; amarillo al 60% de progreso), cooldown por `velocidad_efectiva()`, área 3×3 desde T3, gating por categoría de bloque (pico→piedra/minerales, pala→tierra, hacha→madera, azada→césped/tierra), roca madre/agua inválidos, señales snake_case para feedback, drops por `BlockType` (IDs 18-25 corregidos).
- `scripts/tools/tool_feedback.gd` (nuevo): feedback desacoplado — sonidos sintetizados por material (AudioStreamWAV runtime con parciales+ruido+envolvente; M65 dará assets finales) y pool de partículas GPUParticles3D one-shot con color por material.
- `scripts/tools/test_herramientas.gd` (nuevo): test headless — catálogo 9×4 (36 combos), durabilidad cozy (nunca negativa), umbral reparación 20%, serialización round-trip, acciones por tipo, mapeo block→item, tabla de golpes. **Resultado: 0 fallos.**
- `scripts/player/player.gd`: herramientas iniciales de cobre auto-equipadas (5; adquisición real → M14/M16), hotbar HUD M57 (6 slots con nombre+durabilidad, activo resaltado, colores por estado, parpadeo <20% con aviso REPARAR, etiqueta equipada), fallback de mano mutuamente excluyente con ToolController, E/Q por polling en el controller (evita handlers duplicados §9.29), scroll reservado a la cámara (§9.25), HUD montado en el CanvasLayer `UI` de la escena.
- `scripts/main_island.gd`: library de bloques alineada a `BlockType` (placeholders IDs 18-25) — corrige renderizado/extracción de nieve/grava/musgo/barro (antes sin modelo).

### Bugs corregidos (heredados latentes)
- `VoxelTerrain.get_voxel()` **no existe** en esta versión de Voxel Tools → lectura por `VoxelTool.get_voxel(pos)` con canal TYPE. Documentado en 07-GUIA-GODOT §9.40 (verificado con dump de `get_method_list()`).
- El hotbar HUD anterior mostraba ítems del inventario, no herramientas; nadie equipaba herramientas al arrancar (E/Q siempre caían al fallback de mano).

### Verificación (V4 + V2)
- `check-only` limpio en los 4 scripts; test headless 0 fallos.
- Runtime vía `run_project` + `get_debug_output`: 0 SCRIPT ERROR de M13.
- Autotest in-engine end-to-end: 4 golpes con cooldown, extracción de dirt a los 2 golpes (`Extraído bloque 1 en (22,3,63)`), drop `dirt` → Inventario M14 (`1/24 slots`), durabilidad 110→107.
- Captura in-engine oficial (`get_viewport().get_texture()`): HUD completo (hotbar + etiqueta equipada + reloj M30). Hallazgo: `PrintWindow`/capturas del SO pueden omitir capas UI recientes — documentado en 06-GUIA-DE-CONEXION-VISION.

## Hallazgos (fuera de alcance, para sus dueños)
- Spawn del jugador (20,15,64) cae al agua (flota sobre el bloque de agua); el spec de M09 decía (20,8,64) → revisar en M09/M11.
- `[SAVE] Slot fuera de rango: -1` en SaveManager (M59) en cada arranque — preexistente.

## Documentación actualizada
- `DOCUMENTACION/13-Herramientas/plan-actual/05-Checklist.md`: 65/102 marcados con evidencia; pendientes con dueño; Notas del Agente; firma Hy3.
- `DOCUMENTACION/13-Herramientas/plan-actual/04-Codigo.md`: implementación real, contratos vigentes, Notas del Agente (cierre Fase 3); firma Hy3.
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`: 5 ítems F3 de M13 → [x]; fila de reserva → 🟡 liberado.
- `CHECKLIST-GLOBAL.md`: fila M13 → 🟡 (núcleo implementado) 65/102.
- `Mensajes entre modelos/ESTADO-PARALELO.md`: fila M13 → liberado con resumen.
- `DOCUMENTACION/07-GUIA-GODOT.md`: §9.40 nuevo + firma.
- `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md`: confirmación del caso PrintWindow/UI stale (2026-08-28).
- Capturas: `tools/mcp/godot-mcp/capturas/13-Herramientas/cap_13_2026-08-28_*` (5 nuevas, incluida la in-engine oficial).

## Estado final
- **Puerta F3 cumplida:** el jugador puede moverse, mirar, apuntar y usar una herramienta sobre un bloque válido (pipeline verificado end-to-end).
- M13 liberado como 🟡 (núcleo implementado; integraciones con dueños en M16/M17/M33/M35/M46/M59/M45/M65/M53/M22/M71/M12).
