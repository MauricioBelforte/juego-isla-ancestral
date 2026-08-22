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
| `assets/blender/personajes/` | ⬜ Pendiente | Archivos .blend de trabajo + exports .glb para Godot (V5) |
| `scripts/blender/setup_estudio.py` | ⬜ Pendiente | Script bpy reutilizable: luz 3 puntos + cámara fija + fondo neutro (V5) |
| `scripts/blender/personaje_voxel.py` | ⬜ Pendiente | Generador paramétrico de personajes voxel desde lista (x,y,z,color) (V5) |
| `addons_blender/blender_mcp_addon.py` | ⬜ Instalar en Blender | Addon del repo blender-mcp que levanta el socket 9876 (V5) |
| `cline_mcp_settings.json` → servidor "blender" | ⬜ Pendiente | Registro del servidor blender-mcp (V5) |
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

### V5 — blender-mcp: tools y snippets clave

**Tools del servidor (repo ahujasid/blender-mcp):**

```
get_scene_info()                    → {objects: [{name, type, ...}]}
get_object_info(name)               → {mesh, materials, location, rotation, scale}
get_viewport_screenshot(max_size)   → {mime: "image/png", data: base64}   ← LOS OJOS
execute_blender_code(code)          → {result, error?}                    ← LAS MANOS
get_polyhaven_status()              → estado de integración PolyHaven (assets gratis)
```

**Snippet: personaje voxel mínimo ejecutable vía execute_blender_code**

```python
import bpy

# Limpiar escena por defecto
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)

PALETA = {"piel": (0.95, 0.80, 0.65), "camisa": (0.30, 0.55, 0.85),
          "pantalon": (0.25, 0.25, 0.30), "pelo": (0.35, 0.20, 0.10)}

def crear_material(nombre):
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*PALETA[nombre], 1.0)
    bsdf.inputs["Roughness"].default_value = 0.8   # look cozy mate
    return m

def voxel(x, y, z, color_nombre):
    mat = bpy.data.materials.get(color_nombre) or crear_material(color_nombre)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x, y, z))
    obj = bpy.context.active_object
    obj.data.materials.append(mat)

# Cuerpo simple 2x2x3 (ejemplo — el diseño real vendrá de iteración con screenshots)
for z in range(3):                       # torso
    for x in range(2):
        for y in range(1):
            voxel(x - 0.5, y - 0.5, z + 0.5, "camisa")
bpy.ops.wm.save_as_mainfile(filepath="//personaje_v01.blend")
```

**Snippet: export a Godot**

```python
import bpy
bpy.ops.export_scene.gltf(
    filepath="D:/.../juego-isla-ancestral/assets/models/personajes/npc_01.glb",
    export_format='GLB', export_apply=True)
```

## 3. Integración con otros módulos

| Módulo | Integración |
|---|---|
| M45 Arte 3D / M46 Arte 2D | Iteración visual de assets vía capture_viewport; **V5 Blender como herramienta DCC principal de modelado** |
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
8. ⬜ Instalar Blender 4.x LTS + addon blender-mcp y verificar conexión (socket 9876).
9. ⬜ Registrar servidor "blender" en cline_mcp_settings.json.
10. ⬜ Crear scripts/blender/setup_estudio.py (luz 3 puntos + cámara + fondo neutro).
11. ⬜ Crear scripts/blender/personaje_voxel.py (generador paramétrico).
12. ⬜ Iterar primer personaje NPC completo con screenshots hasta aprobación del usuario.
13. ⬜ Exportar el personaje aprobado a .glb e importarlo en Godot.

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

---

## Notas del Agente (actualización V5 — Blender)

**Modelo:** stealth/ox-alpha
**Plataforma:** Cline
**Fecha:** 2026-08-22 04:20:00
**Estado:** Completado (documentación V5 agregada a plan-actual)

### Lo que hice en esta actualización
- Agregué la **Vía V5 (Blender + blender-mcp)** al módulo 154 según directiva del usuario ("si lo hiciéramos en Blender es más fácil usar el MCP" — confirmado: SÍ).
- Documenté la guía de instalación completa (Blender 4.x LTS + addon + socket 9876 + registro en Cline).
- Detallé las 4 tools del servidor (`get_scene_info`, `get_object_info`, `get_viewport_screenshot`, `execute_blender_code`) y sus usos.
- Escribí 12 capacidades concretas del agente con ojos en Blender (modelado voxel procedural, materiales, iluminación de estudio, renders EEVEE/Cycles, rigging básico, variantes paramétricas, export glTF→Godot, import .vox).
- Incluí snippets ejecutables: generador de personaje voxel mínimo y export glTF.
- Definí el protocolo de iteración V5 (respaldo .blend → cambio atómico → shading Material Preview → screenshot → análisis).
- Actualicé la matriz de decisión: V5 es la vía primaria para diseño de personajes en modelado; V4 sigue siendo fundamental para verificación dentro del juego.
- Actualicé RF8/RF9, decisión D6, riesgos nuevos (script que cuelga Blender, shading incorrecto) y pendientes operativos 8-13.

### Por qué V5 dentro del 154 y no un módulo nuevo
La visión vía Blender es conceptualmente otra "vía de ojos" del agente — misma naturaleza que V1-V4. Crear un módulo separado habría fragmentado la matriz de decisión y el protocolo común. El usuario autorizó explícitamente esta opción ("si podés manejarlo dentro del 154 hacelo").

### Lo que NO pude hacer (honestidad obligatoria)
- No instalé Blender ni blender-mcp: requiere descargas e instalación en el sistema del usuario (Blender ~300MB, addon, uvx/pip). Queda como pendiente operativo 8-9.
- No verifiqué la conexión real del socket 9876 ni probé get_viewport_screenshot: requiere Blender corriendo.
- No creé los scripts setup_estudio.py / personaje_voxel.py como archivos reales: los snippets están diseñados aquí; su materialización corresponde a la primera sesión de trabajo V5.

### Recomendaciones para el próximo agente
1. Instalar primero Blender LTS y el addon; probar `get_scene_info` antes que nada (verificación mínima).
2. La primera sesión V5 ideal: generar el NPC más simple posible, capturar, y mostrarle al usuario el flujo completo end-to-end.
3. Cuidado con execute_blender_code: siempre respaldar .blend antes (el snippet de seguridad está en 03-Diseno.md).
4. El viewport debe estar en Material Preview para que los screenshots muestren colores reales.
5. Coordinar con M45 (Arte 3D): V5 convierte a Blender en la herramienta DCC recomendada del proyecto.
