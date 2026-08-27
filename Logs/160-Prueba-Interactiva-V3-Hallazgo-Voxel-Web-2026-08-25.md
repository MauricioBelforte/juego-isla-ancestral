# Log 160: Prueba interactiva V3 — hallazgo voxel sin soporte web

**Fecha:** 2026-08-25
**Modelo:** ox-alpha
**Plataforma:** Cline

## Resumen
Se probó V3 con interacción real (Playwright presiona WASD en el build web) y captura antes/después. Las capturas son idénticas: la cámara no se movió. La consola reveló la causa raíz: el addon `zylann.voxel` no soporta `web.wasm32`, lo que rompe el parseo de `main_isla.gd` y mata el gameplay en web.

## Cambios Realizados
- Creado `tools/mcp/godot-mcp/scripts-prueba/prueba_qa_interactivo.py`: sirve build web, abre Chromium headless, captura estado inicial, presiona W (2s) y A (1.5s) con capturas intermedias, vuelca consola JS.
- Verificación visual de capturas: idénticas (solo cielo/terreno/UI, sin movimiento).
- Diagnóstico en consola: `No GDExtension library found for current OS and architecture (web.wasm32)` → `VoxelTerrain` inexistente → parse error en `main_isla.gd`.
- Documentado hallazgo + opciones de resolución en `06-GUIA-DE-CONEXION-VISION.md` (sección V3).

## Archivos Modificados/Creados
- `tools/mcp/godot-mcp/scripts-prueba/prueba_qa_interactivo.py` (nuevo)
- `tools/mcp/godot-mcp/capturas/52-QA-WEB/cap_web_interact_0_inicial.png`
- `tools/mcp/godot-mcp/capturas/52-QA-WEB/cap_web_interact_1_w2s.png`
- `tools/mcp/godot-mcp/capturas/52-QA-WEB/cap_web_interact_2_a15s.png`
- `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md` (registro V3 + limitación estructural)
