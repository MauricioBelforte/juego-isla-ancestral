# Log 148: Reorganizacion scripts-prueba/reutilizables e historial de capturas por modulo

**Fecha:** 2026-08-25
**Modelo:** ox-alpha
**Plataforma:** Cline

## Resumen
Se reorganizaron los scripts auxiliares en dos carpetas según su naturaleza (`scripts-prueba/` para esporádicos, `scripts-reutilizables/` para herramientas estables) y se implementó un sistema de historial de capturas organizado por módulo, garantizando comparativas antes/después para documentar bugs.

## Cambios Realizados
- Creada `tools/mcp/godot-mcp/scripts-reutilizables/` y `tools/mcp/blender-mcp/scripts-reutilizables/`.
- Movidos (copiar → verificar → eliminar, sin pérdidas) a reutilizables: `cap_godot.py`, `lanzar_preview.py`, `lanzar_y_capturar.py`, `ver_debug.py`, `run_projecto.py`, `analizar_cap.py`.
- Dejados en `scripts-prueba/` solo los esporádicos: `prueba_godot.py` (godot-mcp) y `prueba_esfera.py` (blender-mcp).
- Mejorado `cap_godot.py`: parámetro `--modulo {ID}` (+ `--nota` opcional), guarda cada captura con timestamp en `capturas/{ID-Modulo}-Nombre/cap_{ID}_{fecha}_{hora}.png`, nunca sobrescribe, reporta el tamaño del historial y avisa cuando hay comparativa anterior+actual.
- Creada estructura `tools/mcp/godot-mcp/capturas/52-Particulas-Y-VFX/`; la captura histórica del polen se movió allí como `cap_52_2026-08-24_validacion-polen.png`.
- Actualizada la convención en AGENTS.md §24 (2 carpetas + capturas por módulo).
- Actualizado el workflow de captura y el registro de verificación en `06-GUIA-DE-CONEXION-VISION.md`; corregidas referencias en M52 (`04-Codigo.md`, `05-Checklist.md`).

## Archivos Modificados/Creados
- `AGENTS.md`
- `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md`
- `DOCUMENTACION/52-Particulas-Y-VFX/plan-actual/04-Codigo.md`
- `DOCUMENTACION/52-Particulas-Y-VFX/plan-actual/05-Checklist.md`
- `tools/mcp/godot-mcp/scripts-reutilizables/*` (6 scripts)
- `tools/mcp/godot-mcp/capturas/52-Particulas-Y-VFX/cap_52_2026-08-24_validacion-polen.png`
- `Logs/ULTIMO_NUMERO.txt` (147 → 148)
