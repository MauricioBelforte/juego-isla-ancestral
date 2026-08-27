# Log 154: Entorno virtual para dependencias Python de tools/mcp

**Fecha:** 2026-08-25
**Modelo:** ox-alpha
**Plataforma:** Cline

## Resumen
Por directiva del usuario se creó un entorno virtual (`tools/mcp/.venv/`) para aislar las dependencias Python de las herramientas MCP del proyecto, evitando conflictos con otros proyectos de la máquina.

## Cambios Realizados
- Creado `tools/mcp/.venv/` (Python 3.13) e instaladas dentro: fastmcp 3.4.7, pillow 12.3.0, pygetwindow.
- Verificado que `screen-mcp/server.py` funciona con el intérprete del venv (6 ventanas listadas).
- Generado `tools/mcp/requirements.txt` (pip freeze, 72 paquetes) para reproducibilidad.
- Actualizado `cline_mcp_settings.json`: el servidor `screen` ahora usa `tools/mcp/.venv/Scripts/python.exe` en lugar del Python global.
- Actualizada la sección V2 de `06-GUIA-DE-CONEXION-VISION.md` con instrucciones de recreación del venv.
- La carpeta ya estaba excluida de git (patrón `.venv/` en `.gitignore`).

## Archivos Modificados/Creados
- `tools/mcp/.venv/` (creado)
- `tools/mcp/requirements.txt` (creado)
- `cline_mcp_settings.json`
- `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md`
- `Logs/ULTIMO_NUMERO.txt` (153 → 154)
