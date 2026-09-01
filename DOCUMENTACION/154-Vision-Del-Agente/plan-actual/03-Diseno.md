**Modelo:** stealth/ox-alpha
**Plataforma:** Cline

# 03-Diseno.md — Módulo 154: Visión del Agente

## 1. Arquitectura general

```
┌─────────────────────────────────────────────────────────────────┐
│                        AGENTE (LLM + Visión)                     │
│   Analiza imágenes · Ajusta código GDScript · Itera diseño       │
└──────┬──────────────┬──────────────┬──────────────┬─────────────┘
       │ V1           │ V2           │ V3           │ V4 ⭐
       │ (chat)       │ (MCP screen) │ (Playwright) │ (godot-mcp)
       ▼              ▼              ▼              ▼
┌────────────┐ ┌─────────────┐ ┌─────────────┐ ┌──────────────────┐
│ Usuario    │ │ MCP Server  │ │ Godot Web   │ │ Godot Editor     │
│ pega PNG   │ │ Python      │ │ Export      │ │ (plugin bridge)  │
│ en chat    │ │ ImageGrab   │ │ HTML5+WASM  │ │ run_scene /      │
│            │ │ → base64    │ │ http.server │ │ get_errors /     │
│            │ │             │ │ Playwright  │ │ capture_viewport │
└────────────┘ └─────────────┘ └─────────────┘ └──────────────────┘
```

## 2. Diseño por vía

### V1 — Capturas en el chat (validación artística)

```
Flujo: Agente genera/ajusta código → Usuario renderiza y captura 
→ Usuario pega imagen en chat → Agente analiza (visión integrada) 
→ Agente propone ajustes → repetir
```
- Sin componentes nuevos. Protocolo documentado en `04-Codigo.md`.
- Resolución recomendada: la nativa del editor; 1 imagen por mensaje.

### V2 — MCP custom de captura de pantalla (`screenshot-mcp`)

```
scripts/mcp/screenshot_mcp.py   ← servidor MCP (stdio, Python)
  tools:
    capture_screen()            ← pantalla completa → PNG base64
    capture_window(title: str)  ← ventana por título (pygetwindow) → base64
    save_capture(path: str)     ← guarda copia en disco para historial
```
- Configuración en `cline_mcp_settings.json`:
```json
{
  "mcpServers": {
    "screenshot": {
      "command": "python",
      "args": ["scripts/mcp/screenshot_mcp.py"],
      "disabled": false,
      "alwaysAllow": ["capture_screen", "capture_window"]
    }
  }
}
```
- Dependencias: `pillow`, `pygetwindow`, `mcp` (SDK oficial de Python).

### V3 — Export web + Playwright (QA automatizado)

```
Pipeline:
1. godot --headless --export-release "Web" builds/web/index.html
2. python -m http.server 8080 --directory builds/web
3. Skill webapp-testing:
   - browser_navigate → http://localhost:8080
   - esperar carga WASM (networkidle + timeout)
   - browser_take_screenshot → analizar
   - browser_click / browser_press_key → interactuar
4. Capturas versionadas en Logs/screenshots/ para regresión visual
```
- Integración con M118: job de CI puede ejecutar este pipeline y fallar si una captura difiere del baseline (regresión visual).

### V4 — godot-mcp comunitario ⭐ ESTÁNDAR FUNDAMENTAL

```
Arquitectura de conexión:
┌──────────────┐   stdio/MCP   ┌──────────────┐   TCP/HTTP   ┌──────────────┐
│ Cline        │ ◄───────────► │ godot-mcp    │ ◄──────────► │ Plugin Godot │
│ (agente)     │               │ server       │              │ (bridge.gd)  │
└──────────────┘               └──────────────┘              └──────────────┘

Tools esperadas (según implementación comunitaria):
  run_scene(path)          ← ejecuta escena en el editor
  stop_scene()             ← detiene ejecución
  get_errors()             ← errores/warnings de consola (integra M103)
  capture_viewport()       ← screenshot del viewport 3D/2D → imagen
  read_console(n)          ← últimas n líneas de output
  inspect_node(path)       ← propiedades de un nodo del árbol
```

**Guía de instalación (Windows):**
1. Clonar el proyecto godot-mcp elegido (verificar soporte Godot 4.x en su README).
2. Instalar dependencias (`npm install` o `pip install` según implementación).
3. Copiar el plugin bridge a `res://addons/godot_mcp/` y habilitarlo en Project Settings.
4. Registrar el servidor en `cline_mcp_settings.json` con `command`/`args` correspondientes.
5. Verificación: pedir al agente `get_errors()` con el editor abierto → debe devolver la consola real.
6. Documentar la versión exacta instalada en este archivo (sección Notas del Agente).

**Regla de uso obligatoria:** toda sesión que involucre trabajo visual (personajes, escenas, UI) debe iniciar verificando que V4 está operativo; si no lo está, activar fallback V2 e informar al usuario.

### V5 — Blender + blender-mcp: diseño detallado ⭐ (vía de diseño de assets)

#### Arquitectura de conexión

```
┌──────────────┐   stdio/MCP   ┌────────────────┐   Socket TCP   ┌───────────────────┐
│ Cline        │ ◄───────────► │ blender-mcp    │ ◄────────────► │ Addon Blender     │
│ (agente)     │               │ server (Python)│   puerto 9876  │ (addon.py, bpy)   │
└──────────────┘               └────────────────┘                └───────────────────┘
                                                                      │
                                                              Blender 4.x abierto
                                                              con el addon habilitado
```

#### Guía de instalación (Windows)

1. **Instalar Blender 4.x LTS** desde blender.org (gratis, open source — cumple NFR2).
2. **Descargar `blender-mcp`** (github.com/ahujasid/blender-mcp): contiene el servidor Python y el addon.
3. **Instalar el addon en Blender:** Edit → Preferences → Add-ons → Install → seleccionar `addon.py` del repo → habilitar "Blender MCP".
4. **Iniciar la conexión:** en el panel N de Blender (pestaña "BlenderMCP") → "Connect to Claude" → esto levanta el socket en el puerto 9876.
5. **Registrar el servidor en Cline** (`cline_mcp_settings.json`):
```json
{
  "mcpServers": {
    "blender": {
      "command": "uvx",
      "args": ["blender-mcp"],
      "disabled": false
    }
  }
}
```
   (alternativa sin uvx: `"command": "python", "args": ["-m", "blender_mcp"]` tras `pip install blender-mcp`)
6. **Verificación:** pedir al agente `get_scene_info` con Blender abierto → debe devolver la estructura real de la escena.

#### Tools disponibles vía blender-mcp

| Tool | Qué hace | Uso en Isla Ancestral |
|---|---|---|
| `get_scene_info` | Estructura completa de la escena | Saber qué hay antes de tocar nada |
| `get_object_info(name)` | Detalle de un objeto (mesh, materiales, transform) | Inspeccionar un personaje |
| `get_viewport_screenshot` | Imagen base64 del viewport 3D | **LOS OJOS**: ver el modelo en cada iteración |
| `execute_blender_code(code)` | Ejecuta Python `bpy` arbitrario | Modelar, iluminar, animar, exportar |

#### Lo que el agente puede hacer con ojos (capacidades al detalle)

1. **Modelado procedural de personajes voxel:** crear cubos unitarios (`bpy.ops.mesh.primitive_cube_add`), duplicarlos en grilla, aplicar colores por cara/material — un personaje voxel es una lista de `(x,y,z,color)` ejecutable como script.
2. **Materiales y paletas:** crear Principled BSDF por color de paleta, asignar por slot; ajustar roughness/metallic para look cozy.
3. **Iluminación de estudio estandarizada:** script de 3 puntos (key/fill/rim) + fondo neutro — idéntico para todas las iteraciones, garantiza comparabilidad.
4. **Cámara fija:** encuadre documentado (ej. 3/4 frontal, distancia 3m, lente 50mm).
5. **VER el resultado:** `get_viewport_screenshot` tras forzar shading Material Preview (script incluido abajo) → el agente analiza la imagen con su visión integrada.
6. **Render de alta calidad:** configurar EEVEE (rápido) o Cycles (fidelidad), renderizar a PNG en `Logs/screenshots/`.
7. **Rigging básico:** armature + bones vía bpy para poses de prueba.
8. **Animación de prueba:** keyframes simples (idle bobbing, wave) para validar silueta en movimiento.
9. **Variantes paramétricas:** mismo script con distinta semilla/paleta → N variantes de NPC en una pasada.
10. **Export a Godot:** `bpy.ops.export_scene.gltf(filepath="assets/personaje.glb", export_format='GLB')` → import directo en Godot 4.x.
11. **Importar MagicaVoxel `.vox`:** con importer addon, integrando el flujo voxel existente del proyecto.
12. **Inspección reversa:** abrir un .glb/.blend existente, `get_scene_info`, y entender su estructura antes de modificarlo.

#### Script de seguridad estándar (antes de cada captura)

```python
# Forzar shading Material Preview + encuadre (ejecutar vía execute_blender_code)
import bpy
for area in bpy.context.screen.areas:
    if area.type == 'VIEW_3D':
        for space in area.spaces:
            if space.type == 'VIEW_3D':
                space.shading.type = 'MATERIAL'   # ver colores reales
# Guardar respaldo antes de cambios destructivos
bpy.ops.wm.save_as_mainfile(filepath="//backups/pre_iteracion.blend", copy=True)
```

#### Protocolo de iteración V5 (específico)

1. `get_scene_info` → entender estado actual.
2. Respaldo automático (.blend copy).
3. `execute_blender_code` con cambio ATÓMICO pequeño (un ajuste por vez).
4. Script de shading Material Preview.
5. `get_viewport_screenshot` → analizar imagen ANTES de proponer el siguiente cambio.
6. Repetir (máx. 5 iteraciones autónomas) → export `.glb` cuando el usuario apruebe.

#### Integración con el pipeline del proyecto

```
Blender (V5: diseño iterativo con ojos)
   │  export glTF (.glb)
   ▼
assets/models/  →  Godot 4.x (import nativo glTF)
   │
   ▼
V4 godot-mcp: capture_viewport del personaje DENTRO del juego
   │
   ▼
V1: aprobación estética final del usuario
```

## 3. Matriz de decisión: qué vía usar

| Escenario | Vía primaria | Fallback |
|---|---|---|
| Diseño iterativo de personajes voxel (modelado) | **V5 (Blender viewport screenshot)** | V2 → V1 |
| Diseño iterativo dentro del juego (escenas, UI) | V4 (capture_viewport de escena preview) | V2 → V1 |
| QA visual de UI/menús | V4 | V3 (interacción automatizada) |
| Regresión visual en CI | V3 | — (no aplica en CI sin display) |
| Validación estética final (dirección de arte) | V1 (decisión del usuario) | — |
| Verificar errores tras cambio de código | V4 (get_errors) | execute_command (consola) |
| El agente necesita ver algo fuera del juego | V2 | V1 |
| Generar variantes paramétricas de NPCs | V5 (batch bpy + screenshots muestrales) | — |

## 4. Protocolo de iteración visual (aplica a todas las vías)

1. **Generar:** el agente escribe/ajusta el código (escena, script, material).
2. **Renderizar:** se ejecuta la escena (V4: `run_scene`; V3: recarga web; V2/V1: usuario).
3. **Capturar:** 1 sola imagen por iteración, resolución ≤1280x720 (preserva contexto).
4. **Analizar:** el agente describe lo observado ANTES de proponer cambios (verificable).
5. **Ajustar:** cambios mínimos y medibles ("subir saturación paleta 10%", no "mejorar colores").
6. **Repetir:** máximo 5 iteraciones autónomas antes de escalar al usuario (V1).

## 5. QA

- Test V1: pegar imagen de prueba en chat → el agente describe correctamente elementos conocidos.
- Test V2: `capture_window("Godot Engine")` devuelve PNG legible con el viewport visible.
- Test V3: export web carga en <30s; screenshot muestra la escena inicial; un click mueve al personaje.
- Test V4: `run_scene` lanza la escena; `get_errors()` refleja un error inducido; `capture_viewport()` devuelve imagen del render.
- Test de fallback: deshabilitar V4 → el flujo de personaje funciona igual vía V2.
- Test de contexto: 5 iteraciones seguidas no exceden presupuesto razonable de tokens.

## 6. Escena de preview de personaje

```
# Estructura de preview_personaje.tscn
Node3D (PreviewRoot)
├── Camera3D (fija, encuadre documentado)
│   └── Position3D (target: slot del modelo)
├── DirectionalLight3D (key light, 45° arriba)
├── DirectionalLight3D (fill light, -30° lateral, intensidad 0.3)
├── DirectionalLight3D (rim light, detrás, intensidad 0.5)
├── WorldEnvironment (fondo gris medio #808080, ambient light bajo)
└── Slot (Node3D vacío, modelo voxel se instancia aquí)
```

**Uso:** el agente instancia un modelo voxel en el Slot, renderiza con V4, captura screenshot, y compara con referencia.

**Scripts necesarios:**
- `scripts/preview/preview_personaje.gd` — gestiona Slot, cámara, iluminación
- `scripts/preview/captura_preview.gd` — captura directa a Logs/screenshots/

## 7. Plan de QA detallado

| Test | Vía | Criterio de éxito | Herramienta |
|------|-----|-------------------|-------------|
| V1 imagen | Chat | Agent identified elements correctly | Manual |
| V2 capture_window | MCP screen | PNG readable, viewport visible | screen-mcp |
| V3 export web | Playwright | Load <30s, screenshot shows scene | webapp-testing |
| V3 interacción | Playwright | Click/key moves character | webapp-testing |
| V4 run_scene | godot-mcp | Scene launches without errors | godot-mcp |
| V4 get_errors | godot-mcp | Error reflected correctly | godot-mcp |
| V4 capture_viewport | godot-mcp | Render image returned | godot-mcp |
| Fallback | V2 | Flow works with V4 disabled | screen-mcp |
| Contexto | All | 5 iterations within token budget | Manual |
| Privacidad | All | No capture leaves local machine | Manual |