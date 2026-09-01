# Log 159: Instalacion y Verificacion V3 Export Web + Playwright

**Fecha:** 2026-08-25
**Hora:** 21:25
**Modelo:** ox-alpha
**Plataforma:** Cline

## Resumen
Se instaló y verificó la vía V3 (export web + Playwright): el juego ahora puede exportarse a HTML5 y automatizarse su QA visual en Chromium headless. Con esta vía, las 5 vías de visión del proyecto están operativas.

## Cambios Realizados
- Plantillas de export de Godot 4.7.2 descargadas (~1.2 GB, release oficial) e instaladas en `%APPDATA%\Godot\export_templates\4.7.2.stable\`.
- `export_presets.cfg` creado con preset "Web" (sin threads, canvas resize, export a `build/web/`).
- Export headless ejecutado con éxito: `build/web/` generado (index.html, wasm, pck). Warning preexistente de `test_terrain.gd` (parse error) documentado — no bloquea.
- `qa_web.py` creado en `scripts-reutilizables/`: sirve HTTP local, abre el juego en Chromium headless (Playwright), saca N capturas temporizadas y reporta errores JS.
- Verificación end-to-end: el juego bootea en el navegador, escena principal con UI visible, 0 errores JS. Limitación conocida: FPS label en 0 por render por software (SwiftShader).
- `.gitignore`: agregado `build/` (builds no se versionan).
- Guía de visión: sección V3 actualizada a "INSTALADA Y VERIFICADA" con instrucciones y registro.

## Hallazgos técnicos
- La ruta `D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe` es una CARPETA; el exe real está dentro (por eso fallaban Start-Process y CreateProcess con "Acceso denegado").
- En export headless la ruta de salida debe ser ABSOLUTA (las relativas fallan).

## Archivos Modificados/Creados
- `%APPDATA%\Godot\export_templates\4.7.2.stable\` (plantillas)
- `game/isla-ancestral/export_presets.cfg` (nuevo)
- `build/web/` (build generado, fuera de git)
- `tools/mcp/godot-mcp/scripts-reutilizables/qa_web.py` (nuevo)
- `tools/mcp/godot-mcp/capturas/52-QA-WEB/` (2 capturas de verificación)
- `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md` (sección V3)
- `.gitignore` (`build/`)
