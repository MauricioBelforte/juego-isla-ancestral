**Modelo:** stealth/ox-alpha
**Plataforma:** Cline

# 04-Codigo.md — Módulo 154: Visión del Agente

## 1. Archivos previstos

| Archivo | Estado | Descripción |
|---|---|---|
| `scripts/mcp/screenshot_mcp.py` | ⬜ Pendiente | Servidor MCP V2: captura de pantalla/ventana (PIL + pygetwindow + SDK mcp) |
| `cline_mcp_settings.json` (global Cline) | ⬜ Pendiente | Registro de servidores MCP: `screenshot` (V2) y `godot-mcp` (V4) |
| `addons/godot_mcp/` (en proyecto Godot, cuando exista) | ⬜ Pendiente | Plugin bridge de godot-mcp comunitario (V4) |
| `builds/web/` | ⬜ Pendiente | Output del export HTML5 para la vía V3 |
| `Logs/screenshots/` | ⬜ Pendiente | Historial de capturas para regresión visual |
| `DOCUMENTACION/154-Vision-Del-Agente/` | ✅ Hecho | Este módulo documental |

## 2. API pública prevista

### V2 — screenshot_mcp.py (esqueleto)

```python
# scripts/mcp/screenshot_mcp.py
from mcp.server.fastmcp import FastMCP
from PIL import ImageGrab
import base64, io

mcp = FastMCP("screenshot")

@mcp.tool()
def capture_screen() -> dict:
    """Captura la pantalla completa y devuelve PNG base64."""
    img = ImageGrab.grab()
    img.thumbnail((1280, 720))          # NFR: preservar contexto del agente
    buf = io.BytesIO(); img.save(buf, "PNG")
    return {"mime": "image/png",
            "data": base64.b64encode(buf.getvalue()).decode()}

@mcp.tool()
def capture_window(title: str) -> dict:
    """Captura la ventana cuyo título contenga `title` (ej: 'Godot Engine')."""
    import pygetwindow as gw
    wins = gw.getWindowsWithTitle(title)
    if not wins:
        return {"error": f"No se encontró ventana con título '{title}'"}
    w = wins[0]
    img = ImageGrab.grab(bbox=(w.left, w.top, w.right, w.bottom))
    img.thumbnail((1280, 720))
    buf = io.BytesIO(); img.save(buf, "PNG")
    return {"mime": "image/png",
            "data": base64.b64encode(buf.getvalue()).decode()}

if __name__ == "__main__":
    mcp.run(transport="stdio")
```

### V4 — Tools esperadas de godot-mcp (contrato)

```
run_scene(scene_path: str) → {status, pid}
stop_scene()               → {status}
get_errors()               → {errors: [...], warnings: [...]}   # integra M103/M122
read_console(lines: int)   → {output: str}
capture_viewport()         → {mime: "image/png", data: base64}  # integra este módulo
inspect_node(node_path: str) → {properties: {...}}
```

## 3. Integración con otros módulos

| Módulo | Integración |
|---|---|
| M45 Arte 3D / M46 Arte 2D | Iteración visual de assets vía capture_viewport |
| M48 Animación | Verificación de frames clave en movimiento |
| M53 UI-UX / M89 Menús | QA visual de layouts; V3 permite interacción automatizada |
| M61 Rendimiento | Capturas junto a métricas del profiler para correlacionar |
| M103 Logging / M122 Crash Reporting | get_errors() alimenta el flujo de detección temprana |
| M110 Debug Menu | Escenas de debug como puntos de captura estandarizados |
| M112 Testing / M118 CI-CD | Regresión visual automatizada en pipeline |

## 4. Pendientes de implementación

1. ⬜ Implementar `scripts/mcp/screenshot_mcp.py` (V2) y probarlo con ventana de Godot.
2. ⬜ Evaluar e instalar un godot-mcp comunitario compatible con Godot 4.x (V4) — **prioridad fundamental según directiva del usuario**.
3. ⬜ Configurar `cline_mcp_settings.json` con ambos servidores.
4. ⬜ Crear escena de preview de personaje (`preview_personaje.tscn`) como punto de captura estandarizado para iteración de diseño.
5. ⬜ Definir preset de export Web en el proyecto Godot (V3).
6. ⬜ Crear carpeta `Logs/screenshots/` con convención de nombres `YYYY-MM-DD_HH-MM-SS_via_descripcion.png`.
7. ⬜ Documentar versión exacta de godot-mcp instalada y su commit.

## Notas del Agente

**Modelo:** stealth/ox-alpha
**Plataforma:** Cline
**Fecha:** 2026-08-22 04:00:00
**Estado:** Completado (documentación inicial)

### Lo que hice
- Documenté las 4 vías de visión del agente (chat, MCP screen, web+Playwright, godot-mcp) como alternativas complementarias, según directiva del usuario.
- Destaqué V4 (godot-mcp comunitario) como **estándar fundamental permanente**, con guía de instalación y contrato de tools esperadas.
- Definí matriz de decisión por escenario y protocolo de iteración visual acotado en contexto.
- Escribí el esqueleto completo del servidor MCP de captura de pantalla (V2), listo para implementarse.
- Registré integraciones con módulos existentes (M45, M48, M53, M61, M103, M110, M112, M118).

### Lo que NO pude hacer (honestidad obligatoria)
- No instalé ni verifiqué ningún godot-mcp real: requiere decidir cuál proyecto comunitario usar y probar compatibilidad con la versión de Godot del proyecto (que aún no tiene carpeta de proyecto Godot creada). Queda como `[?]`→pendiente operativo.
- No implementé `screenshot_mcp.py`: el esqueleto está diseñado pero su ejecución requiere instalar dependencias Python (`pillow`, `pygetwindow`, `mcp`) en el entorno del usuario.
- No creé la escena de preview de personaje: depende de que exista el proyecto Godot base (M04 pendiente de instalación).

### Recomendaciones para el próximo agente
1. **Primera acción:** verificar qué versión exacta de Godot se va a usar (M04) ANTES de elegir godot-mcp; la compatibilidad es el riesgo principal.
2. Candidatos comunitarios a evaluar para V4: buscar "godot-mcp" y "mcp-godot" en GitHub; priorizar los que expongan `capture_viewport` y `get_errors`.
3. Para V2, probar primero `capture_window("Godot Engine")` manualmente antes de registrar el servidor en Cline.
4. La escena `preview_personaje.tscn` debería mostrar el modelo voxel sobre fondo neutro con luz de 3 puntos — facilita comparaciones entre iteraciones.
5. Considerar agregar un ítem a M5-FUTURAS-MEJORAS si el usuario quiere regresión visual automática en CI desde el inicio.