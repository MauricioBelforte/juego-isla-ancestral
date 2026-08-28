# 09 — Guía Blender

**Modelo:** GLM
**Plataforma:** Cline
**Fecha:** 2026-08-27

> **Propósito:** Guía de referencia obligatoria para modelar assets con Blender vía scripting (bpy), análoga a `07-GUIA-GODOT.md`. Documenta errores comunes, convenciones, la conexión MCP (V5) y el registro de errores. **Todo agente que modele assets DEBE leerla antes de empezar** y agregar aquí cada descubrimiento nuevo (regla AGENTS.md §26 aplicada a Blender).

---

## 1. Conexión con Blender (V5)

La vía V5 usa Blender en modo servidor + un cliente Python de la venv del proyecto. **No requiere addon de terceros**: Blender corre headless con un socket que ejecuta código `bpy` enviado por el cliente.

| Pieza | Ruta (`tools/mcp/blender-mcp/scripts-reutilizables/`) | Función |
|---|---|---|
| Servidor | `arrancar_servidor_mcp.py` | Arranca Blender 4.2 headless, socket `127.0.0.1:9876` |
| Cliente | `bpy_cliente.py` | `blender_command('execute_code', {'code': ...})` |
| Captura | `cap_blender.py` | Screenshot offscreen del viewport → PNG en `capturas/` |
| Ejemplo | `crear_palmera_lowpoly.py` | Asset reutilizable completo |

### Flujo estándar (PowerShell)

```powershell
# 1) Arrancar servidor (si el puerto 9876 no está escuchando)
& 'D:\Archivos de programa\Blender Foundation\Blender 4.2\blender.exe' -b --python tools/mcp/blender-mcp/scripts-reutilizables/arrancar_servidor_mcp.py &

# 2) Ejecutar un script dentro de Blender
& 'tools/mcp/.venv/Scripts/python.exe' -c "import sys, json; sys.path.insert(0, r'tools/mcp/blender-mcp/scripts-reutilizables'); from bpy_cliente import blender_command; code = open(r'<SCRIPT>.py', encoding='utf-8').read(); print(json.dumps(blender_command('execute_code', {'code': code})))"

# 3) Capturar resultado (SIEMPRE, timestamp nuevo — nunca sobrescribir)
& 'tools/mcp/.venv/Scripts/python.exe' 'tools/mcp/blender-mcp/scripts-reutilizables/cap_blender.py' "tools/mcp/blender-mcp/capturas/{ID-Modulo}-Nombre/cap_{ID}_{AAAA-MM-DD_HH-MM-SS}_nota.png"
```

### Reglas
- Verificar puerto 9876 antes de enviar código.
- Capturas en `capturas/{ID-Modulo}-Nombre/` con timestamp; conservar la anterior como comparativa (AGENTS.md §24).
- Los `.blend` se guardan en `tools/mcp/blender-mcp/trabajos/`.
