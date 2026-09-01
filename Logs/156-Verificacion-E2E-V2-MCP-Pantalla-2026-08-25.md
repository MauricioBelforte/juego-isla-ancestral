# Log 156: Verificacion End-to-End V2 MCP Pantalla y Correccion de Config

**Fecha:** 2026-08-25
**Hora:** 21:25
**Modelo:** ox-alpha
**Plataforma:** Cline

## Resumen
Se verificó la vía V2 (MCP de pantalla) de punta a punta con el servidor conectado en Cline: captura real del juego Godot corriendo (preview de partículas M52, FPS 59, polen visible), guardado en el historial del módulo. Se corrigieron dos problemas descubiertos durante la verificación.

## Cambios Realizados
- **Config MCP corregida:** el servidor `screen` estaba configurado en el archivo equivocado (`AppData\Roaming\...`). El archivo real que lee Cline es `C:\Users\<user>\.cline\data\settings\cline_mcp_settings.json` (estaba vacío). Se escribió la config ahí, apuntando al intérprete del venv.
- **Bug corregido en `server.py`:** `capture_window` fallaba con `PyGetWindowException` (error Windows 18) al intentar activar la ventana si el foco estaba bloqueado. Ahora `restore()`/`activate()` son tolerantes y la captura se hace igualmente por coordenadas.
- **Test end-to-end:** `lanzar_preview.py` → Godot corriendo → `capture_window('isla-ancestral')` → imagen verificada visualmente (ventana del juego real, FPS 59, polen amarillo suave) → `save_capture()` al historial del módulo.
- **Guía de visión actualizada:** config con venv, advertencia sobre el archivo de config correcto, y tabla de registro de verificación de V2.

## Archivos Modificados/Creados
- `C:\Users\Maury-New\.cline\data\settings\cline_mcp_settings.json` (config real del servidor `screen`)
- `tools/mcp/screen-mcp/server.py` (bug de activación corregido)
- `tools/mcp/godot-mcp/capturas/52-Particulas-Y-VFX/cap_52_test-v2-mcp.png` (captura de verificación)
- `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md` (sección V2 actualizada)
