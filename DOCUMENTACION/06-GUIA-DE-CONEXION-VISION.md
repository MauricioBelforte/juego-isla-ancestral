# 06 — Guía de Conexión de Visión del Agente (M154)

**Modelo:** ox-alpha
**Plataforma:** Cline
**Fecha de creación:** 2026-08-24
**Estado:** Viva — se actualiza cada vez que una vía nueva se instala o verifica

> 📍 **Ubicación:** este archivo vive en la **raíz de `DOCUMENTACION/`** (archivo 06, después de `5-FUTURAS-MEJORAS.md`) para que todos los agentes lo encuentren de inmediato. El módulo dueño es `154-Vision-Del-Agente/`; referencias oficiales en `AGENTS.md` (sección 25) y en el `plan-actual/` del M154.

---

## Propósito de esta guía

> ⚠️ **LEER ESTO PRIMERO (obligatorio para cualquier agente):**

Esta es la **guía maestra de "ojos" del proyecto**. Explica **todas las vías disponibles** para que un agente de CUALQUIER plataforma (Cline, Claude, Gemini, DeepSeek, GPT, Antigravity, etc.) pueda **ver** lo que está diseñando/codificando visualmente en Blender, en el juego, o en pantalla.

**Antes de empezar cualquier tarea visual** (modelado 3D, UI, escenas, iluminación, assets, personajes), un agente DEBE:

1. Leer esta guía completa.
2. Verificar qué vías están **operativas** (tabla de estado abajo).
3. Usar la vía disponible que corresponda. Si **ninguna** está operativa, solicitar al usuario su instalación ANTES de proceder (regla del AGENTS.md, sección 25).

Esta guía se actualiza cada vez que se instala o verifica una vía nueva. **Si instalás una vía nueva, documentala acá.**

---

## Tabla de estado de las vías

| Vía | Nombre | Estado | Uso principal | Verificada |
|-----|--------|--------|---------------|------------|
| V1 | Capturas en chat | 🟢 Operativa | Validación estética final (el usuario pega screenshots) | 2026-08-22 |
| V2 | MCP custom de pantalla | ⬜ No instalada | Fallback universal (PIL/ImageGrab) | — |
| V3 | Export web + Playwright | ⬜ No instalada | QA automatizado / regresión visual | — |
| V4 | godot-mcp | ⬜ No instalada | Verificación dentro del juego (FUNDAMENTAL) | — |
| V5 | Blender + blender-mcp | 🟢 **Operativa** | Diseño/modelado de assets 3D con visión | **2026-08-24** |

---

## V5 — Blender + blender-mcp ⭐ (INSTALADA Y VERIFICADA)

### Qué es

Un addon de Blender que abre un **servidor socket en el puerto 9876** dentro de Blender. Cualquier agente puede conectarse por TCP y enviar comandos JSON-RPC para **crear, modificar e inspeccionar objetos**, y pedir **capturas del viewport** para "ver" lo que hace.

### Instalación (ya realizada — solo referirsi si hay que reinstalar)

1. Descargar el addon del repositorio `blender-mcp`. Copia local en:
   ```
   tools/mcp/blender-mcp/addon.py
   ```
2. Abrir **Blender** (versión usada y verificada: **4.2.3 LTS**)
3. Menú `Edit` → `Preferences` → `Add-ons`
4. ⚠️ **En Blender 4.2+ el botón "Install..." ya no está fijo**: clic en la **flecha desplegable (˅)** de la esquina superior derecha (junto a "Enabled Only") → **"Install from Disk..."**
5. Seleccionar `tools/mcp/blender-mcp/addon.py`
6. Habilitar el checkbox **"Blender MCP"** → guardar preferencias (menú hamburger → Save Preferences)
7. **Reiniciar Blender** (los paneles de addons nuevos a veces no cargan sin reinicio)

### Conexión (⚠️ HAY QUE HACERLO EN CADA SESIÓN DE BLENDER)

El socket **NO persiste** entre sesiones. Cada vez que se abre Blender:

1. En el viewport 3D presionar **`N`** para abrir la barra lateral derecha
2. Ir a la pestaña **"BlenderMCP"**
3. Clic en **"Connect to MCP server"** (en algunas versiones dice "Connect to Claude" — es el mismo botón, conecta cualquier cliente MCP)
4. El panel cambia a estado conectado y el socket queda escuchando en el puerto **9876**

### Cómo se conecta el agente

**Opción A — Cliente MCP registrado (Cline y similares):**

El servidor ya está registrado en la configuración MCP de Cline:

```json
{
  "mcpServers": {
    "blender": {
      "command": "C:\\Users\\<USUARIO>\\.local\\bin\\uvx.exe",
      "args": ["blender-mcp"],
      "disabled": false
    }
  }
}
```

Ubicación del archivo: `%APPDATA%\Code\User\globalStorage\saoudrizwan.claude-dev\settings\cline_mcp_settings.json`

Después de registrar o modificar: **recargar VS Code** (Ctrl+Shift+P → "Reload Window") para que el cliente MCP se conecte.

**Opción B — Socket directo (cualquier agente, sin cliente MCP):**

El protocolo es JSON por TCP al puerto 9876. Ejemplo en Python:

```python
import json, socket

def blender_command(type_, params=None):
    s = socket.create_connection(("localhost", 9876), timeout=30)
    s.send(json.dumps({"type": type_, "params": params or {}}).encode())
    data = b""
    s.settimeout(30)
    try:
        while True:
            chunk = s.recv(65536)
            if not chunk:
                break
            data += chunk
            try:
                json.loads(data.decode())  # respuesta completa
                break
            except Exception:
                pass
    finally:
        s.close()
    return json.loads(data.decode())

# Ejemplo: obtener info de la escena
print(blender_command("get_scene_info"))
```

### Verificación rápida (checklist de conexión)

1. ¿Blender está abierto? → si no, pedir al usuario que lo abra
2. ¿El puerto 9876 está escuchando? → `Test-NetConnection -ComputerName localhost -Port 9876` en PowerShell, o `socket.create_connection(("localhost", 9876))` en Python
3. Si falla → pedir al usuario: panel `N` → BlenderMCP → "Connect to MCP server"
4. Probar `get_scene_info` → debe devolver `{"status": "success", ...}` con los objetos de la escena

### Comandos útiles

| Comando | Qué hace |
|---------|----------|
| `get_scene_info` | Lista objetos de la escena (nombre, tipo, posición) |
| `get_object_info` | Detalle de un objeto (vértices, materiales, modificadores) |
| `get_viewport_screenshot` | Captura del viewport → **así "ve" el agente** |
| `execute_code` | Ejecuta código `bpy` arbitrario (crear/editar meshes, materiales, etc.) |
| Comandos de PolyHaven / Hyper3D / Sketchfab | Assets externos (requieren flags habilitados en el panel) |

### Protocolo de iteración visual (regla del M154)

Al trabajar con visión: **capturar → analizar → ajustar**, máximo **5 iteraciones autónomas** antes de consultar al usuario.

### Registro de verificación

- **2026-08-24** — Verificada por **ox-alpha (Cline)**: `get_scene_info` respondió `success` con 3 objetos (Cube, Light, Camera) y 2 materiales en Blender 4.2.3 LTS.
- **2026-08-24** — **Visión real confirmada**: creada `EsferaPrueba` con material naranja vía `execute_code` (bpy), capturada con `get_viewport_screenshot` (⚠️ requiere parámetro `filepath`, método "offscreen", sin `max_resolution`) y analizada por el agente: esfera naranja visible correctamente junto al cubo default. Flujo completo crear → pintar → capturar → VER → validar operativo. Script de prueba: `tools/mcp/blender-mcp/prueba_esfera.py`.

---

## V1 — Capturas en chat (OPERATIVA, sin instalación)

La vía más simple y universal: el usuario pega screenshots en el chat y el agente los analiza con su visión integrada.

**Cuándo usarla:** validación estética final, cuando las vías automáticas no alcanzan o el usuario quiere dar feedback visual directo.

**Cómo pedirla:** solicitar al usuario una captura de la vista específica (viewport de Blender, escena del juego, UI) y esperar la imagen en el chat.

---

## V2 — MCP custom de pantalla (NO INSTALADA — pendiente)

Fallback universal: un pequeño servidor MCP propio que use **PIL/ImageGrab** (Python) para capturar la pantalla completa o una ventana y devolverla como imagen al agente.

**Para instalarla (cuando corresponda):**
- Script Python con `PIL.ImageGrab.grab()` + envoltorio MCP (FastMCP)
- Útil cuando ni Blender ni el juego exponen capturas directas

---

## V3 — Export web + Playwright (NO INSTALADA — pendiente)

Exportar el proyecto a HTML5 (Godot web o similar) y automatizar el QA visual con **Playwright** (skill `webapp-testing` disponible en Cline).

**Uso previsto:** regresión visual automatizada, capturas de escenas del juego en distintos estados.

---

## V4 — godot-mcp (NO INSTALADA — FUNDAMENTAL para el juego)

MCP que controla el editor del motor del juego directamente (abrir escenas, ejecutar el juego, capturar pantalla in-game).

**Uso previsto:** verificación visual **dentro del juego** — es la vía crítica para validar gameplay visual (iluminación in-game, UI en runtime, efectos). Instalar cuando el proyecto tenga una escena jugable mínima.

---

## Notas para el agente que lea esto

1. **No reinventar:** si V5 está operativa, usala para todo lo 3D antes de pedir capturas manuales.
2. **Actualizar esta guía:** si instalás V2, V3 o V4, documentá acá la instalación, el método de conexión y un ejemplo, y actualizá la tabla de estado.
3. **Registrar verificaciones:** cada verificación exitosa de una vía debe quedar en el registro correspondiente con fecha, modelo y plataforma.
4. **Firmar los cambios:** esta guía lleva firma del último agente que la modificó (regla de AGENTS.md, sección 3).

