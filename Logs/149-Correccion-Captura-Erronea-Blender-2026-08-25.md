# Log 149: Correccion captura erronea (imagen de Blender etiquetada como Godot)

**Fecha:** 2026-08-25
**Modelo:** ox-alpha
**Plataforma:** Cline

## Resumen
El usuario detectó que la "captura histórica de Godot" era en realidad la captura de Blender (esfera naranja de la prueba V5). Se investigó el origen, se corrigió la ubicación de los archivos y se documentó el error con honestidad total.

## Origen del error
En una sesión previa se ejecutó `Copy-Item "tools/mcp/blender-mcp/captura_esfera.png" → "tools/mcp/godot-mcp/scripts-prueba/cap_godot.png"` para "recrear" el archivo borrado, sin verificar que fuera una captura real de Godot. Esa copia fue luego movida a `capturas/52-Particulas-Y-VFX/` como si fuera evidencia del polen.

## Cambios Realizados
- Eliminada la copia mal etiquetada `capturas/52-Particulas-Y-VFX/cap_52_2026-08-24_validacion-polen.png`.
- La imagen original de Blender se reubicó según la convención: `blender-mcp/capturas/154-Vision-Del-Agente/cap_154_2026-08-24_prueba-esfera-v5.png`.
- Agregada entrada de corrección al registro de verificación V4 en `06-GUIA-DE-CONEXION-VISION.md`, aclarando que **no existe captura automatizada de Godot** y que la validación de M52 fue exclusivamente humana (confirmación en vivo del usuario).
- Aclarado en `52-Particulas-Y-VFX/plan-actual/04-Codigo.md` que el análisis de píxeles previo (si se hizo sobre `cap_godot.png`) analizó la imagen de Blender y debe considerarse inválido.

## Lección aprendida
- Nunca recrear un archivo de evidencia copiando otro sin verificar su procedencia: una captura mal etiquetada contamina la trazabilidad de QA.
- La carpeta de capturas de un módulo solo debe contener capturas generadas por la herramienta del propio componente.

## Archivos Modificados/Creados
- `tools/mcp/godot-mcp/capturas/52-Particulas-Y-VFX/` (eliminado archivo incorrecto)
- `tools/mcp/blender-mcp/capturas/154-Vision-Del-Agente/cap_154_2026-08-24_prueba-esfera-v5.png` (reubicado)
- `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md`
- `DOCUMENTACION/52-Particulas-Y-VFX/plan-actual/04-Codigo.md`
- `Logs/ULTIMO_NUMERO.txt` (148 → 149)
