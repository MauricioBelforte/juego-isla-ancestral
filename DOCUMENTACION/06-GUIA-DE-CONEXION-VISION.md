# 06 — Guía de Conexión de Visión del Agente (M154)

**Modelo:** Hy3
**Plataforma:** Kilo
**Fecha de creación:** 2026-08-24
**Última actualización:** 2026-09-02 (reconciliado estado V3: marcada 🟡 Operativa limitada — ver sección V3; el resto de vías sin cambios)
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
| V2 | MCP custom de pantalla | 🟢 **Operativa** | Fallback universal (PIL/ImageGrab) | **2026-08-25** |
| V3 | Export web + Playwright | 🟡 Operativa (limitada) | QA automatizado / regresión visual (escenas sin voxel) | 2026-08-25 |
| V4 | godot-mcp | 🟢 **Operativa** | Verificación dentro del juego (**FUNDAMENTAL**) | **2026-08-24** |
| V5 | Blender + blender-mcp | 🟢 **Operativa** | Diseño/modelado de assets 3D con visión | **2026-08-24** |

## Conexión desde GitHub Copilot en VS Code

VS Code y GitHub Copilot no leen `opencode.json` ni `cline_mcp_settings.json`. Para compartir servidores MCP con Copilot se usa la configuración de workspace `.vscode/mcp.json`, cuya clave raíz es `servers`.

Este proyecto ya incluye esa configuración con dos servidores locales:

- `screen`: V2, captura de pantalla/ventana y devuelve imágenes al chat.
- `godot`: V4, ejecuta Godot y devuelve información, logs, errores y estado del proyecto.

### Activación en cualquier proyecto

1. Abrir el proyecto en VS Code y revisar `.vscode/mcp.json`.
2. Ejecutar `MCP: List Servers` desde la paleta de comandos.
3. Iniciar `screen` y `godot`; la primera vez VS Code solicita confiar en cada servidor.
4. En el chat, usar `Configure Tools` y habilitar las tools del servidor.
5. Si se modificó `mcp.json`, ejecutar `MCP: Reset Cached Tools` o `Developer: Reload Window` y volver a iniciar los servidores.
6. Para validar visión, pedir `screen.list_windows` y luego `screen.capture_window` sobre la ventana de Godot.

### Configuración portable mínima

```json
{
  "servers": {
    "screen": {
      "type": "stdio",
      "command": "${workspaceFolder}/tools/mcp/.venv/Scripts/python.exe",
      "args": ["${workspaceFolder}/tools/mcp/screen-mcp/server.py"]
    },
    "godot": {
      "type": "stdio",
      "command": "node",
      "args": ["${workspaceFolder}/tools/mcp/godot-mcp/build/index.js"],
      "env": {
        "GODOT_PATH": "D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64.exe"
      }
    }
  }
}
```

La configuración de Cline conserva otra forma (`mcpServers`) y no debe copiarse literalmente a VS Code. El servidor `screen` necesita el entorno virtual del proyecto; si no existe, recrearlo con `python -m venv tools/mcp/.venv` y `pip install -r tools/mcp/requirements.txt`. En Windows, el sandbox de MCP no está disponible, así que solo deben registrarse servidores revisados.

### Estado de esta conexión

- **2026-08-25 — GitHub Copilot / VS Code:** configuración workspace creada en `.vscode/mcp.json`; JSON válido; ejecutables `screen-mcp` y `godot-mcp` presentes; `godot-mcp/build/index.js` válido con `node --check`.
- **2026-08-25 — Verificación interactiva completada:** Copilot ejecutó `screen.list_windows` y `screen.capture_screen`; el servidor descubrió 4 tools y la captura fue recibida correctamente.
- **2026-08-25 — Godot MCP verificado desde Copilot:** `godot.get_project_info` respondió con `isla-ancestral`, Godot `4.7.2.stable.official.ed1daf0bf`, 11 escenas, 43 scripts y 16 assets.
- **V5 Blender:** no se registra aquí como servidor Copilot porque el addon depende de una sesión activa de Blender y su socket 9876 no estaba escuchando durante esta verificación. El procedimiento V5 existente sigue siendo válido cuando Blender esté abierto y conectado.

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
- **2026-08-24** — **Visión real confirmada**: creada `EsferaPrueba` con material naranja vía `execute_code` (bpy), capturada con `get_viewport_screenshot` (⚠️ requiere parámetro `filepath`, método "offscreen", sin `max_resolution`) y analizada por el agente: esfera naranja visible correctamente junto al cubo default. Flujo completo crear → pintar → capturar → VER → validar operativo. Script de prueba: `tools/mcp/blender-mcp/scripts-prueba/prueba_esfera.py`.
- **2026-08-28 — WorkBuddy AI:** registrado el server `blender` en `~/.workbuddy-ai/mcp.json` con `uvx blender-mcp`. Smoke stdio OK: `initialize` → `serverInfo {"name":"BlenderMCP","version":"1.29.1"}`. Sin Blender abierto el server arranca aunque falla el connect a `localhost:9876` (`WinError 10061`) — **esperado**.
- **2026-08-28 — Inventario verificado:** Blender **4.2** instalado en `D:\Archivos de programa\Blender Foundation\Blender 4.2\blender.exe`. Addon ya instalado en `%APPDATA%\Blender Foundation\Blender\4.2\scripts\addons\addon.py` y **byte-idéntico** (md5 `a8eb45e84801206d72a799d59a26ac72`, 148.890 bytes) al `tools/mcp/blender-mcp/addon.py` del proyecto → no hace falta reinstalarlo.
- **2026-08-28 — Verificada desde Kilo** por **Hy3**: Blender abierto con addon conectado (puerto 9876 escuchando); `get_scene_info` vía socket directo (`bpy_cliente.py`) → `success` con 10 objetos (`SM_Estrella_Mar`, `SOL`, `CAM_Orbital`, ...). En Kilo no hay cliente MCP registrado para Blender: usar **Opción B (socket directo)**.
- **2026-09-02 — Verificada desde Kilo Code** por **GLM 5.3 (z-ai)**: puerto 9876 ABIERTO; `get_scene_info` vía `bpy_cliente.py` → `success` con 9 objetos (set del espantapájaros M33); captura offscreen 1200×639 generada OK (`cap_154_2026-09-02_05-40-32_prueba-kilo-glm53.png`). ⚠️ **E-10 aplicado:** este modelo NO acepta imágenes en el chat (la lectura del PNG devuelve "this model does not support image input"), así que la revisión visual queda para el usuario (V1) o un modelo multimodal; el QA de este agente es **numérico** (`verificar_bounds.py`, huella E-50, tris reales E-33).

### Checklist V5 desde WorkBuddy (estado 2026-08-28)

| Paso | Estado |
|------|--------|
| Blender 4.2 instalado | ✅ `D:\Archivos de programa\Blender Foundation\Blender 4.2\blender.exe` |
| Addon instalado y coincide con el del proyecto | ✅ md5 idéntico |
| Server MCP `blender` registrado | ✅ `uvx blender-mcp` en `~/.workbuddy-ai/mcp.json` |
| **Blender abierto** | ⬜ requiere acción del usuario |
| **Addon conectado (socket 9876)** | ⬜ panel `N` → BlenderMCP → "Connect to MCP server" |
| **Nueva sesión de chat** (para que cargue el server) | ⬜ pendiente |

---

## V1 — Capturas en chat (OPERATIVA, sin instalación)

La vía más simple y universal: el usuario pega screenshots en el chat y el agente los analiza con su visión integrada.

**Cuándo usarla:** validación estética final, cuando las vías automáticas no alcanzan o el usuario quiere dar feedback visual directo.

**Cómo pedirla:** solicitar al usuario una captura de la vista específica (viewport de Blender, escena del juego, UI) y esperar la imagen en el chat.

---

## V2 — MCP custom de pantalla ⭐ (INSTALADA Y VERIFICADA — 2026-08-25)

Servidor MCP propio (`fastmcp`, transporte stdio) que captura la pantalla o cualquier ventana y **devuelve la imagen directamente al agente** para análisis visual. Es el fallback universal: funciona con Godot, Blender, el editor, o cualquier app.

### Ubicación y requisitos

- Código: `tools/mcp/screen-mcp/server.py`
- **Entorno virtual del proyecto (2026-08-25):** `tools/mcp/.venv/` — aísla las dependencias Python del proyecto para no generar conflictos con otros proyectos. Intérprete: `tools/mcp/.venv/Scripts/python.exe`. Dependencias congeladas en `tools/mcp/requirements.txt`.
  - Recrear desde cero: `python -m venv tools/mcp/.venv` → `tools/mcp/.venv/Scripts/python.exe -m pip install -r tools/mcp/requirements.txt`
  - Requisitos base: `fastmcp`, `pillow`, `pygetwindow` (verificados: fastmcp 3.4.7, pillow 12.3.0, Python 3.13)
- La carpeta `.venv/` está excluida de git (patrón `.venv/` en `.gitignore`).

### Tools que expone

| Tool | Qué hace |
|------|----------|
| `list_windows()` | Lista ventanas visibles con título y posición (para elegir cuál capturar) |
| `capture_screen()` | Captura pantalla completa → devuelve la imagen al agente |
| `capture_window(title)` | Captura la primera ventana cuyo título contenga `title` (activa y recorta su bounding box) |
| `save_capture(path)` | Guarda la última captura en disco (para historial en `capturas/{ID-Modulo}/`) |

### Configuración MCP (Cline)

```json
"screen": {
  "command": "<ruta-proyecto>/tools/mcp/.venv/Scripts/python.exe",
  "args": ["<ruta-proyecto>/tools/mcp/screen-mcp/server.py"],
  "disabled": false,
  "alwaysAllow": ["list_windows", "capture_screen", "capture_window", "save_capture"]
}
```

⚠️ Tras editar `cline_mcp_settings.json`, **reconectar el servidor MCP en Cline** (botón de reconexión del panel MCP) para que las tools aparezcan disponibles.

⚠️ **Ojo con el archivo de config correcto (descubierto 2026-08-25):** en esta instalación de Cline el archivo que se lee es `C:\Users\<user>\.cline\data\settings\cline_mcp_settings.json` — NO el de `AppData\Roaming\Code\User\globalStorage\saoudrizwan.claude-dev\settings\`. Editar el equivocado hace que el servidor nunca aparezca en el panel (estaba vacío con `{"mcpServers": {}}` y parecía que la config no funcionaba).

### Registro de verificación

| Fecha | Verificación | Resultado |
|-------|-------------|-----------|
| 2026-08-25 | `list_windows()` + captura de prueba | ✅ 6 ventanas listadas; captura PNG válida |
| 2026-08-25 | Servidor conectado en Cline (panel verde) + test end-to-end | ✅ `capture_window('isla-ancestral')` capturó el juego real (FPS 59, polen visible); `save_capture()` guardó en `capturas/52-Particulas-Y-VFX/` |
| 2026-08-25 | Bug corregido en `capture_window` | `win.activate()` lanzaba `PyGetWindowException` (error Windows 18) cuando el foco estaba bloqueado → ahora tolerante: captura igualmente por coordenadas |

### Cuándo usar V2 vs otras vías

- **V2** → capturar cualquier ventana/pantalla sin scripts sueltos; ideal cuando V4 no expone la captura (ej: viewport del juego Godot corriendo) o la app objetivo no tiene MCP propio.
- **V4** → control y logs del juego Godot (complementario: V4 lanza, V2 captura).
- **V5** → assets 3D en Blender (tiene screenshot nativo).
- Para historial por módulo: combinar con `save_capture()` hacia `tools/mcp/godot-mcp/capturas/{ID-Modulo}/` o usar `scripts-reutilizables/cap_godot.py`.

### Registro de verificación

- **2026-08-25** — Verificada por **ox-alpha (Cline)**: `list_windows()` → 6 ventanas; captura de ventana/pantalla generó PNG válido (490 KB) analizado visualmente por el agente; `save_capture()` escribió en disco correctamente. Registrada en `cline_mcp_settings.json` como servidor `screen`.

---

## V3 — Export web + Playwright ⭐ (INSTALADA Y VERIFICADA — 2026-08-25)

Exportar el proyecto a HTML5 y automatizar el QA visual con **Playwright** (skill `webapp-testing` disponible en Cline).

**Uso:** regresión visual automatizada, capturas del juego en distintos estados, sin depender del escritorio ni de ventanas.

### Componentes instalados

| Componente | Ubicación |
|-----------|-----------|
| Plantillas de export Godot 4.7.2 | `%APPDATA%\Godot\export_templates\4.7.2.stable\` (descargadas del release oficial, ~1.2 GB) |
| Preset de export Web | `game/isla-ancestral/export_presets.cfg` (preset "Web", sin threads, canvas resize) |
| Build web generado | `build/web/` (index.html + wasm + pck) — **excluido de git** (`build/` en `.gitignore`) |
| Script de QA | `tools/mcp/godot-mcp/scripts-reutilizables/qa_web.py` |

### Cómo usar

```bash
# 1. Exportar (tras cambios de código):
python -c "import subprocess; subprocess.run([r'D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe','--headless','--path','game/isla-ancestral','--export-release','Web',r'<RUTA-ABSOLUTA>\build\web\index.html'])"
# ⚠️ usar RUTA ABSOLUTA de salida (las relativas fallan en headless)

# 2. QA automatizado (sirve HTTP local + Chromium headless + capturas):
python tools/mcp/godot-mcp/scripts-reutilizables/qa_web.py --modulo 52 --nota "polen" --shots 3 --intervalo 4
# → capturas en tools/mcp/godot-mcp/capturas/{modulo}-QA-WEB/
```

### Registro de verificación

| Fecha | Verificación | Resultado |
|-------|-------------|-----------|
| 2026-08-25 | Plantillas instaladas + export headless | ✅ `build/web/` generado (EXIT 0); warning preexistente de `test_terrain.gd` (parse error, no bloquea) |
| 2026-08-25 | `qa_web.py` end-to-end | ✅ Juego bootea en Chromium headless: escena principal con UI de controles visible, cielo y terreno renderizados, **0 errores JS** |
| 2026-08-25 | Limitación conocida | ⚠️ Label `FPS: 0` en headless (render por software SwiftShader); los FPS reales se validan con V4/V2, V3 es para UI/lógica/regresión visual |
| 2026-08-25 | Interacción con Playwright (`scripts-prueba/prueba_qa_interactivo.py`) | ⚠️ **Hallazgo crítico**: la cámara NO responde a WASD en el build web. Causa raíz: `zylann.voxel` GDExtension no soporta `web.wasm32` → `VoxelTerrain`/`VoxelMesherBlocky` no existen → `main_island.gd` falla al parsear y toda su lógica (movimiento incluido) muere. El juego renderiza (cielo/terreno/UI) porque son nodos independientes, pero el gameplay está roto en web |

### ⚠️ Limitación estructural del build web (2026-08-25)

**El addon `zylann.voxel` no tiene build para `web.wasm32`.** Consecuencias:
- Todo script que referencie tipos `Voxel*` falla al parsear en web (aunque compile bien en desktop)
- El gameplay dependiente de `main_isla.gd` (u otros scripts voxel-dependientes) queda inoperante en el build web
- **Opciones a futuro:** (a) excluir scripts voxel del export web con versiones alternativas, (b) reemplazar el terreno voxel por malla estática para web, (c) aceptar que V3 solo sirve para escenas sin voxel (ej: `preview_particles.tscn`)
- V3 sigue siendo plenamente útil para QA de escenas que no dependan del addon voxel

### Cuándo usar V3 vs otras vías

- **V3** → QA automatizado repetible, regresión visual, probar interacciones (clicks/teclas vía Playwright), no requiere ventana visible.
- **V4+V2** → rendimiento real (FPS) y look exacto del render nativo.

---

## V4 — godot-mcp ⭐ (INSTALADA Y VERIFICADA — 2026-08-24)

MCP que controla el editor del motor del juego directamente (abrir escenas, ejecutar el juego, **capturar y leer todo el output de Godot — logs, errores y warnings en tiempo real**). Es la vía **fundamental** para validar gameplay visual in-game.

### Qué es

Servidor MCP (repositorio `Coding-Solo/godot-mcp`, 5.3k ⭐) que invoca los comandos CLI de Godot y un script GDScript empaquetado (`godot_operations.gd`) para operaciones complejas (crear escenas, agregar nodos).

### Instalación (realizada 2026-08-24)

1. Requisitos: **Node.js** (para `npm`) y **Godot 4.x**.
2. Clonar el repo (copia local):
   ```
   tools/mcp/godot-mcp/
   ```
3. Compilar:
   ```
   cd tools/mcp/godot-mcp
   npm install
   npm run build   → genera build/index.js (y copia godot_operations.gd a build/scripts)
   ```

### Configuración MCP (Cline)

En `cline_mcp_settings.json`:

```json
{
  "mcpServers": {
    "godot": {
      "command": "node",
      "args": ["<ruta>/tools/mcp/godot-mcp/build/index.js"],
      "env": {
        "GODOT_PATH": "<ruta_al_ejecutable_de_godot>",
        "DEBUG": "true"
      },
      "disabled": false,
      "alwaysAllow": ["get_godot_version", "list_projects", "get_project_info", "get_debug_output"]
    }
  }
}
```

- `GODOT_PATH` → ruta al `.exe` de Godot (usado: `D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe`)
- Alternativa portable: en lugar de `node` + ruta a `build/index.js`, se puede usar `"command": "npx", "args": ["@coding-solo/godot-mcp"]` (usa el paquete publicado).

### Configuración MCP (OpenCode) — 2026-08-24

En `opencode.json` en la raíz del proyecto:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "godot": {
      "type": "local",
      "command": ["node", "tools/mcp/godot-mcp/build/index.js"],
      "environment": {
        "GODOT_PATH": "D:\\ISLA ANCESTRAL\\Godot_v4.7.2-stable_win64.exe\\Godot_v4.7.2-stable_win64.exe"
      },
      "enabled": true,
      "timeout": 30000
    }
  }
}
```

**Notas para OpenCode:**
- El archivo `opencode.json` va en la **raíz del proyecto** (junto a `AGENTS.md`).
- `command` es un **array** (no string como en Cline).
- `environment` es el equivalente a `env` en Cline.
- `timeout: 30000` (30 s) para dar tiempo a Godot a responder.
- Después de crear/modificar `opencode.json`, **reiniciar OpenCode** para que detecte el MCP.

### Verificación rápida (scripts)

Con Godot instalado y un proyecto local, probar contra el servidor por el protocolo MCP (stdio). Un helper útil está en `tools/mcp/godot-mcp/scripts-prueba/prueba_godot.py` (envía `get_godot_version` y `get_project_info`):

- `get_godot_version` → devuelve la versión (ej: `4.7.2.stable.official.ed1faf0bf`)
- `get_project_info` con `project_path` → devuelve nombre, Godot version y estructura del proyecto (escenas/scripts/assets)

### Herramientas (tools) que expone

| Tool | Qué hace |
|------|----------|
| `get_godot_version` | Versión del motor |
| `list_projects` | Lista proyectos Godot conocidos |
| `get_project_info` | Info y estructura de un proyecto (`project_path`) |
| `launch_editor` | Abre el editor Godot con un proyecto |
| `run_project` | Ejecuta el proyecto (scene game) |
| `stop_project` | Detiene la ejecución |
| `get_debug_output` | **Lee el output de Godot (logs, errores, warnings)** — clave del QA |
| `create_scene` / `add_node` / `save_scene` | Manipular escenas y nodos |
| `get_uid` / `update_project_uids` | Gestión de UIDs |

### Workflow de captura de viewport (limitación conocida + procedimiento)

⚠️ **Limitación clave:** godot-mcp **NO expone** una tool tipo `get_viewport_screenshot` (a diferencia de blender-mcp con V5). Para "ver" lo que corre dentro del juego se usa un **workflow híbrido**: el MCP lanza/controla el juego, y la captura se hace por fuera con Python.

**Procedimiento paso a paso:**

> 📁 Los scripts reutilizables viven en `tools/mcp/godot-mcp/scripts-reutilizables/`; los esporádicos de prueba en `scripts-prueba/` (ver convención en AGENTS.md §24).

1. **Lanzar la escena objetivo** — dos opciones:
   - Vía MCP: tool `run_project` con `projectPath` (siempre explícito, no tiene default) y `scene`.
   - Vía script directo: `python tools/mcp/godot-mcp/scripts-reutilizables/lanzar_preview.py` (usa `subprocess.Popen` con `--path` y `--scene`).
2. **Esperar a que la ventana del juego esté visible** (~2-5 s; si hay carga de assets, esperar el log correspondiente vía `get_debug_output`).
3. **Capturar la ventana con historial por módulo** — `scripts-reutilizables/cap_godot.py --modulo {ID} [--nota "..."]`:
   - Busca la ventana Godot/juego con `pygetwindow`, la activa y recorta su bounding box.
   - Guarda en `tools/mcp/godot-mcp/capturas/{ID-Modulo}/cap_{ID}_{fecha}_{hora}.png` → **nunca sobrescribe**: conserva el historial completo del módulo (mínimo anterior + actual para comparativas antes/después al documentar bugs).
4. **Analizar los píxeles** con `analizar_cap.py`: cuenta píxeles por color dominante (polen amarillo, piso verde, cielo celeste) para verificar que el efecto se renderizó sin necesidad de visión directa.
5. **Alternativa todo-en-uno:** `lanzar_y_capturar.py` lanza el juego, espera 3 s y captura pantalla completa (`ImageGrab.grab()` sin bbox).

**Requisitos de los scripts:** `pip install pillow pygetwindow pyautogui`.

**Cuándo usar cada vía:**
- Validación visual final / estética → **V1** (el usuario mira y confirma, como se hizo con M52).
- QA automatizado / regresión → este workflow de captura + análisis de píxeles.
- Assets 3D en Blender → **V5** (sí tiene `get_viewport_screenshot` nativo).

### Registro de verificación

- **2026-08-24** — Verificada por **ox-alpha (Cline)**: `get_godot_version` → 4.7.2.stable; `get_project_info` → `isla-ancestral` (2 escenas, 4 scripts, 16 assets) en Godot 4.7.2. Flujo crear escenas y leer logs disponible.
- **2026-08-24** — Verificación visual humana confirmada: escena `preview_particles.tscn` (M52) ejecutada en vivo vía lanzamiento directo de Godot; el usuario vio partículas amarillas emergiendo desde abajo (tipo chispas/fuegos artificiales). V4 usada como soporte del flujo (lanzamiento + logs); la captura automatizada de viewport queda pendiente (godot-mcp no expone screenshot de viewport — ver notas). Script reproducible: `tools/mcp/godot-mcp/scripts-reutilizables/lanzar_preview.py`.
- **2026-08-25** — Reorganización por **ox-alpha (Cline)**: los scripts auxiliares se dividieron en `scripts-prueba/` (esporádicos) y `scripts-reutilizables/` (herramientas estables), y las capturas ahora se guardan con historial por módulo en `tools/mcp/godot-mcp/capturas/{ID-Modulo}/` mediante `cap_godot.py --modulo {ID}` (nunca sobrescribe; mínimo anterior + actual para comparar antes/después). Convención completa en AGENTS.md §24.
- **2026-08-25** — ⚠️ **Corrección de error detectado**: se descubrió que el archivo `cap_godot.png` histórico **no era una captura de Godot** sino una copia de la captura de Blender (esfera naranja V5) que fue copiada por error a godot-mcp en una sesión previa. Se eliminó la copia mal etiquetada de `capturas/52-Particulas-Y-VFX/` y la imagen original se reubicó en `blender-mcp/capturas/154-Vision-Del-Agente/cap_154_2026-08-24_prueba-esfera-v5.png`. **Consecuencia honesta: hasta ese momento NO existía ninguna captura automatizada del viewport de Godot**; la validación visual de M52 fue exclusivamente humana. Cualquier "análisis de píxeles" previo hecho sobre `cap_godot.png` analizó la imagen de Blender, no el juego — debe considerarse inválido.
- **2026-08-25** — ✅ **Primera captura automatizada real de Godot**: generada con `cap_godot.py --modulo 52` sobre la ventana "isla-ancestral (DEBUG)" en ejecución. Verificada visualmente por el agente: cielo procedural, piso verde, label FPS: 59 y partículas amarillas del emisor de polen visibles. Archivo: `godot-mcp/capturas/52-Particulas-Y-VFX/cap_52_2026-08-24_21-19-22_polen-validacion.png`. Observación: las partículas se renderizan como cuadrados amarillos pixelados (textura default sin sprite suave) — punto de mejora estética para M52. El workflow de captura queda validado end-to-end.
- **2026-08-24** — Configuración en **OpenCode** realizada por **MiMo V2.5**: creado `opencode.json` en raíz del proyecto con MCP godot-mcp configurado como `"type": "local"`.
- **2026-08-24** — ✅ **Verificación MCP OpenCode completada** por **MiMo V2.5**: `get_debug_output` → "No active Godot process" (esperado, sin proyecto corriendo). `run_project` → proyecto `game/isla-ancestral/` ejecutado correctamente: Godot 4.7.2, D3D12, AMD Radeon Graphics, "Isla Ancestral — Estilo Animal Crossing", sin errores. `stop_project` → detenido correctamente. **MCP godot-mcp completamente funcional en OpenCode.**
- **2026-08-25** — ✅ **Verificación MCP OpenCode completada** por **MiMo V2.5**: `get_debug_output` → "No active Godot process". `run_project` → "Isla Ancestral — Isla Raíz", WorldManager inicializado (semilla: 42, radio: 64), sin errores. `stop_project` → detenido correctamente. **MCP funcional para run/stop/debug output.**
- **2026-08-28** — ✅ **Verificada desde Kilo** por **Hy3**: Kilo expone las tools de godot-mcp **nativamente** en el chat (sin `mcp.json` ni configuración): `get_godot_version` → `4.7.2.stable.official.ed1daf0bf`; `get_project_info` → `isla-ancestral` (15 escenas, 101 scripts, 16 assets). Ver sección "Conexión desde Kilo".

### Dependencia para su uso completo

- Requiere que exista un **proyecto Godot con `project.godot`** (ya existe: `game/isla-ancestral/`).
- `run_project` / capturas in-game pueden requerir que el proyecto esté cerrado antes de abrirlo desde el MCP (evitar conflictos de "proyecto ya abierto").

---

## Descubrimientos y Mejores Prácticas para V4 (godot-mcp en OpenCode)

> 📝 **Esta sección resume hallazgos prácticos de sesiones reales. Otros agentes DEBEN leerla antes de usar V4.**

### 1. Workflow correcto de captura de pantalla del juego

El MCP de Godot **NO tiene tool de screenshot**. Para capturar la ventana del juego:

1. **Cerrar el editor Godot primero** (si está abierto). Si no, `run_project` puede fallar o la ventana del juego queda detrás.
2. **Ejecutar `run_project`** vía MCP → Godot inicia el juego en ventana separada.
3. **Esperar 4-5 segundos** (`time.sleep(4)`) para que la ventana cargue.
4. **Usar Win32 API** para activar y capturar la ventana:
   ```python
   import ctypes
   from PIL import ImageGrab
   
   user32 = ctypes.windll.user32
   hwnd = user32.FindWindowW(None, "isla-ancestral (DEBUG)")
   user32.SetForegroundWindow(hwnd)
   import time; time.sleep(0.5)
   screenshot = ImageGrab.grab(bbox=bbox)
   ```
5. **El nombre de la ventana** puede cambiar: "isla-ancestral (DEBUG)" al correr, "isla-ancestral (DEBUG) — Godot Engine v4.7.2.stable.official" al editar.

### 2. Errores comunes al codificar con VoxelBlockyModelCube

| Error | Causa | Solución |
|-------|-------|----------|
| `Nonexistent function 'set_material'` | `VoxelBlockyModelCube` no tiene `set_material()` | Solo usar `set_name()`. Colores por material override en el mesher. |
| `Cannot infer the type of "x"` | `clamp()` u otras funciones retornan tipo ambiguado | Declarar tipo explícito: `var x: float = expr` |
| `Invalid type in argument 'target_position'` | Se pasó Transform3D en vez de Vector3 | Usar `Vector3(0, 0, -5)` directamente |

### 3. Cómo generar terreno con Voxel Tools (lección aprendida)

**NO usar `VoxelTool.do_point()` para generar terreno** — no genera geometría visible. Para generación procedural:

```gdscript
# ✅ Forma correcta: VoxelGeneratorScript
extends VoxelGeneratorScript

func _generate_block(pos: Vector3i, out_buffer: VoxelBuffer) -> void:
    var block = IslandGenerator.new().generate_block(pos)
    out_buffer.set_voxel(block["type"], pos.x, pos.y, pos.z, VoxelBuffer.CHANNEL_TYPE)
```

**O alternativa manual** (funcional pero menos eficiente):
```gdscript
# do_point() devuelve VOID (corregido 2026-08-25, ver 07-GUIA-GODOT §9.12)
var tool = terrain.get_voxel_tool()
tool.value = 1
tool.do_point(pos)
# Verificación posterior con get_voxel:
if terrain.get_voxel(pos) == -1:
    print("Posición inválida: ", pos)
```

### 4. Configuración mínima de VoxelTerrain para que funcione

```gdscript
# Nodos necesarios en la escena:
# - VoxelTerrain (con VoxelMesherBlocky como mesher)
# - VoxelBlockyLibrary (con modelos de bloques)
# - VoxelStreamScript (para lectura/escritura)

var terrain = VoxelTerrain.new()
var mesher = VoxelMesherBlocky.new()
var library = BlockCatalog.new().build_voxel_library()
mesher.set_library(library)
terrain.set mesher(mesher)
terrain.set_stream(VoxelStreamScript.new())  # Requerido para que funcione
```

### 5. Configuración MCP en OpenCode

```json
// opencode.json en raíz del proyecto
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "godot": {
      "type": "local",
      "command": ["node", "tools/mcp/godot-mcp/build/index.js"],
      "environment": {
        "GODOT_PATH": "D:\\ISLA ANCESTRAL\\Godot_v4.7.2-stable_win64.exe\\Godot_v4.7.2-stable_win64.exe"
      },
      "enabled": true,
      "timeout": 30000
    }
  }
}
```

**Diferencia con Cline:** `command` es un array (no string), `environment` reemplaza a `env`.

### 6. Configuración correcta de VoxelTerrain (verificada 2026-08-25)

**Regla de oro:** VoxelTerrain SIEMPRE debe ser hijo DIRECTO del root Node3D. NO anidar bajo otros nodos.

```
# ✅ Correcto
Root (Node3D)
├── VoxelTerrain  ← hijo directo
├── Camera3D
│   └── VoxelViewer
└── DirectionalLight3D

# ❌ Incorrecto
Root (Node3D)
└── WorldManager (Node3D)
    └── VoxelTerrain  ← NO FUNCIONA
```

**Setup mínimo funcional (verificado):**
1. VoxelTerrain como hijo directo del root
2. Camera3D estática (sin script) posicionada sobre el terreno
3. VoxelViewer como hijo de Camera3D con view_distance=256
4. StandardMaterial3D con vertex_color_use_as_albedo=true
5. VoxelMesherBlocky con VoxelBlockyLibrary (2+ modelos: air + block)
6. VoxelGeneratorNoise2D con channel=TYPE y FastNoiseLite

---

> 📖 **Regla de AGENTS.md (sección 26):** Antes de usar visión, leer esta guía. Cualquier descubrimiento sobre cómo usar el MCP de Godot (V4) — errores, trucos, limitaciones, mejores prácticas, outputs inesperados — DEBE documentarse aquí. Esta guía es la memoria colectiva del conocimiento adquirido.

## Notas para el agente que lea esto

1. **No reinventar:** si V5 está operativa, usala para todo lo 3D antes de pedir capturas manuales.
2. **Actualizar esta guía:** si instalás V2, V3 o V4, documentá acá la instalación, el método de conexión y un ejemplo, y actualizá la tabla de estado. También documentá cualquier descubrimiento durante el uso de V4 (godot-mcp): errores, trucos, herramientas inesperadas, limitaciones encontradas.
3. **Registrar verificaciones:** cada verificación exitosa de una vía debe quedar en el registro correspondiente con fecha, modelo y plataforma.
4. **Firmar los cambios:** esta guía lleva firma del último agente que la modificó (regla de AGENTS.md, sección 3).
5. **Checklist previo al usar V4 (godot-mcp):** antes de invocar cualquier herramienta de Godot MCP, verificar que V4 esté 🟢 operativa y que el proyecto Godot (`game/isla-ancestral/`) esté cerrado si se usarán `run_project` / `launch_editor` (para evitar conflictos de proyecto ya abierto).

## Descubrimiento sobre capturas del juego (2026-08-26 — GLM, Cline — caso M30)

- ⚠️ **La herramienta MCP `capture_window` puede devolver frames cacheados/stale** de la ventana del juego: dos capturas seguidas resultaron byte-idénticas (mismo MD5) aunque el juego corría. Otra ventana encima (ej: Configuración de Windows) agrava el problema.
- ⚠️ **`ImageGrab.grab(bbox=...)` (V2) captura lo visible en pantalla**, no la ventana: si el juego está tapado, captura la ventana de encima (dio "cielo" blanco = ventana de Configuración).
- ✅ **Método confiable #1 (recomendado, in-engine):** desde GDScript, `get_viewport().get_texture().get_image().save_png(ruta)` — captura el frame real renderizado a resolución del proyecto (1152×648), independiente de la ventana del SO. Con esto se validó M30 (reloj 08:00 → 09:00 en vivo, `cap_30_*_inengine.png`).
- ✅ **Método confiable #2 (SO):** `PrintWindow(hwnd, dc, PW_RENDERFULLCONTENT)` vía ctypes — captura el HWND aunque esté tapado. Script: `tools/mcp/godot-mcp/scripts-reutilizables/cap_printwindow.py` (uso: `python cap_printwindow.py "(DEBUG)" salida.png`).
- ⚠️ **Ventana SO ≠ viewport lógico (DPI 125%):** `--resolution 1152x648` por CLI NO redimensionó la ventana; `SetWindowPos` sí, pero el render interno queda a la resolución del proyecto. Para capturas fiel al render, usar el método #1.
- ⚠️ **Previews por CLI:** los autoloads con `change_scene_to_file` pueden pisar la escena pedida (ver 07-GUIA-GODOT §9.25). Bootstrap corregido para respetar la escena CLI.
- ⚠️ **Confirmado 2026-08-28 (Hy3, Kilo — caso M13):** `cap_printwindow.py` (método #2) puede devolver el frame del mundo 3D **sin las capas de UI creadas por código** (hotbar HUD invisible en 4 capturas del SO mientras la captura in-engine lo mostraba completo). Regla práctica: para validar **UI** usar SIEMPRE el método #1 (in-engine); reservar #2 para el mundo 3D.

## Conexión desde WorkBuddy AI (2026-08-28)

`opencode.json` y `.vscode/mcp.json` no aplican a WorkBuddy: este cliente lee `~/.workbuddy-ai/mcp.json` con clave raíz `mcpServers`. Por eso los servidores `screen` y `godot`, aunque ya estaban operativos para Cline/Copilot/OpenCode, **no estaban disponibles en WorkBuddy** hasta ahora.

### Configuración creada

`C:\Users\Maury-New\.workbuddy-ai/mcp.json`:

```json
{
  "mcpServers": {
    "screen": {
      "command": "C:\\Users\\Maury-New\\AppData\\Local\\Programs\\Python\\Python313\\python.exe",
      "args": [
        "D:\\Escritorio\\PORTFOLIO\\Proyectos para GitHub\\PROYECTOS OPENCODE\\juego-isla-ancestral\\tools\\mcp\\screen-mcp\\server.py"
      ],
      "env": { "PYTHONIOENCODING": "utf-8", "PYTHONUNBUFFERED": "1" }
    },
    "godot": {
      "command": "C:\\Users\\Maury-New\\.workbuddy-ai\\binaries\\node\\versions\\22.22.2-1\\node.exe",
      "args": [
        "D:\\Escritorio\\PORTFOLIO\\Proyectos para GitHub\\PROYECTOS OPENCODE\\juego-isla-ancestral\\tools\\mcp\\godot-mcp\\build\\index.js"
      ],
      "env": { "GODOT_PATH": "D:\\ISLA ANCESTRAL\\Godot_v4.7.2-stable_win64.exe\\Godot_v4.7.2-stable_win64.exe" }
    }
  }
}
```

Notas:
- `screen` reusa el **Python del sistema** que ya tiene `fastmcp 3.4.7 / pillow 12.3.0 / PyGetWindow 0.0.9` instaladas (el venv `tools/mcp/.venv` del proyecto es opcional en WorkBuddy porque no hay riesgo de choque con otros proyectos del usuario en este host).
- `godot` usa el **node administrado** de WorkBuddy (22.22.2-1) y `GODOT_PATH` apunta al `.exe` que ya usaba `opencode.json`.
- **V5 Blender (agregado el 2026-08-28 a las 14:49):** sí se registró, vía `uvx blender-mcp`. ⚠️ **Corrección a lo dicho antes:** el server-side **no necesita instalación previa** — `uvx` lo descarga y cachea solo en el primer arranque. Lo único que faltaba era `uv`, que ya está en `C:\Users\Maury-New\.local\bin\uvx.exe`.

```json
"blender": {
  "command": "C:\\Users\\Maury-New\\.local\\bin\\uvx.exe",
  "args": ["blender-mcp"],
  "disabled": false
}
```

- **V5 depende de que Blender esté abierto y conectado:** el server arranca igual, pero al iniciar intenta conectar a `localhost:9876` y, si Blender no está, loguea `Failed to connect to Blender: [WinError 10061]` y sigue. Las tools solo responden cuando el addon está conectado.

### Verificación end-to-end (2026-08-28)

- JSON parseado: ✅ todas las rutas de `command`/`args`/`GODOT_PATH` existen.
- Smoke stdio de `godot-mcp`: ✅ `initialize` → protocolVersion `2024-11-05`, serverInfo `godot-mcp`, logs `[SERVER] Using Godot at: ...Godot_v4.7.2-stable_win64.exe`. Sin warnings de fallback.
- Smoke stdio de `screen-mcp`: ✅ `initialize` + `tools/list` → 4 tools (`list_windows`, `capture_screen`, `capture_window`, `save_capture`).
- `tools/call list_windows` → ✅ 11 ventanas reales (incluye Godot Engine + WorkBuddy AI + VS Code).
- Captura real de la ventana `Godot Engine`: ✅ `ImageGrab.grab(bbox=…)` 1550×838 → PNG en `tools/mcp/godot-mcp/capturas/prueba_vision_workbuddy.png` (240 KB) — **leída y visualizada por el agente** (se ve VS Code con el checklist M08-Implementación en la columna central y el panel Cline a la derecha). Visión operativa de extremo a extremo.

### Activación en la sesión de WorkBuddy

Tras crear/editar `~/.workbuddy-ai/mcp.json` el cliente **no activa los servers solo**; hay que:
1. Abrir la pantalla de **Conectores / MCP** del IDE.
2. Localizar los servers nuevos (`screen`, `godot`) en estado *pendiente de confianza*.
3. Pulsar **Confiar** en cada uno para que arranquen.
4. Si ya estaba abierta la sesión: recargar la ventana del IDE para que registre los servers.

Después, las tools `mcp__screen__*` y `mcp__godot__*` quedan disponibles en el chat con la misma semántica documentada en V2 y V4.

### ⚠️ Descubrimiento clave: "Confiar + habilitar" NO basta en la sesión en curso (2026-08-28)

Verificado por inspección de logs y procesos tras pulsar Confiar y activar ambos servers:

- `mcp-approvals.json` registró los dos servers (`screen` 14:22:48, `godot` 14:22:49) y WorkBuddy **reescribió `mcp.json`** agregando `"disabled": false` a cada uno → la config fue leída y aceptada.
- Sin embargo **no se spawnó ningún proceso hijo**: con psutil no apareció ningún `python.exe` del sistema corriendo `screen-mcp/server.py` ni ningún `node.exe` corriendo `godot-mcp/build/index.js`.
- En `daemon.log`, el `launch-spec resolved` de la sesión sigue reportando **`"mcpCount":1`** (solo el server built-in) y el mismo `fingerprint` antes y después del toggle → **la sesión de chat en curso resuelve su set de MCPs al arrancar y no lo re-resuelve en caliente**.
- `mcp-apps-diag.log` → `catalog.refresh scanned=0 acceptedCount=0` (los servers stdio locales no entran al catálogo de MCP Apps; solo figuran ahí los remotos tipo `custom-mcp:ardot` / `custom-mcp:netdrive`).

**Consecuencia práctica:** para que las tools aparezcan hay que **abrir una sesión/conversación nueva** (o reiniciar la app). No sirve recargar la ventana ni re-toguear dentro de la misma conversación. Es el equivalente WorkBuddy del "reconectar el servidor MCP" que ya estaba documentado para Cline.

### Cómo diagnosticar si un MCP de WorkBuddy está realmente levantado

1. **Procesos:** `psutil.process_iter` filtrando `python.exe` / `node.exe` y buscando la ruta del script en `cmdline`.
   - ⚠️ **Falso positivo a evitar:** existen procesos `tools/mcp/.venv/Scripts/python.exe … screen-mcp/server.py` creados por **otros clientes** (Cline / VS Code) a las 12:42. Si se ven con el `.venv`, son de otro cliente, no de WorkBuddy (WorkBuddy usa el Python del sistema según `mcp.json`).
   - `wmic.exe` está **bloqueado** por la política de seguridad del entorno; usar psutil en el venv administrado (`~/.workbuddy-ai/binaries/python/envs/default`).
2. **Logs:** `~/.workbuddy-ai/logs/daemon.log` → buscar `launch-spec resolved` y leer `"mcpCount"`. `mcp-apps-diag.log` y `main.log` (`mcp:toggle`) confirman aprobación y toggle.
3. **Estado real:** `~/.workbuddy-ai/mcp-approvals.json` (aprobaciones con timestamp) y la reescritura de `mcp.json` con `"disabled": false`.

**Firma:** MiniMax-M3 · WorkBuddy AI · Windows · 2026-08-28.

---

## Conexión desde Kilo (2026-08-28)

Kilo (plataforma del agente Hy3 en este proyecto) tiene las tools de **godot-mcp integradas de fábrica**: NO requiere `opencode.json`, `.vscode/mcp.json` ni `cline_mcp_settings.json`.

### Estado verificado (2026-08-28)

| Vía | Cómo se usa en Kilo | Verificación |
|-----|---------------------|--------------|
| V4 godot-mcp | **Nativa**: tools `godot_*` disponibles en el chat (`get_godot_version`, `get_project_info`, `run_project`, `stop_project`, `get_debug_output`, `create_scene`, `add_node`, `save_scene`, `get_uid`, etc.) | ✅ `get_godot_version` → `4.7.2.stable`; `get_project_info` → 15 escenas / 101 scripts |
| V5 blender-mcp | **Socket directo (Opción B)**: `python tools/mcp/blender-mcp/scripts-reutilizables/bpy_cliente.py <comando>` (get_scene_info, execute_code, get_viewport_screenshot) | ✅ `get_scene_info` → success, 10 objetos |
| V2 pantalla | **Scripts de consola** (sin MCP): `cap_godot.py`, `cap_printwindow.py`, `lanzar_preview.py` de `tools/mcp/godot-mcp/scripts-reutilizables/` | Misma semántica que en OpenCode (patrón ya documentado); no re-verificada desde Kilo |
| V1 | Igual que cualquier plataforma: el usuario pega capturas en el chat | 🟢 |
| V3 | Igual que en OpenCode: export web + `qa_web.py` por consola | ⬜ no verificada desde Kilo |

Notas:
- En Kilo NO hay tools MCP nativas para Blender ni para pantalla: V5 se usa por socket TCP 9876 (requiere Blender abierto con el addon conectado en cada sesión) y V2 por scripts Python directos.
- El flujo híbrido de V4 sigue aplicando: godot-mcp no expone screenshot de viewport, así que lanzar/leer logs con las tools nativas y capturar por script (`cap_godot.py` / `cap_printwindow.py` / método in-engine).
- Las tools Godot nativas de Kilo piden `projectPath` explícito: usar `game/isla-ancestral` (relativo a la raíz del repo).
- **2026-09-02 (GLM 5.3, z-ai):** V4 y V5 re-verificadas desde Kilo Code (Godot 4.7.2 + socket 9876 vivo con el set M33 en escena). ⚠️ E-10: GLM 5.3 free NO acepta imágenes en el chat — la aprobación visual E-13/E-37 debe hacerla el usuario (V1) o un modelo multimodal; este agente entrega QA numérico completo.

**Firma:** Hy3 · Kilo · Windows · 2026-08-28. (Re-verificación GLM 5.3: ver registro V5 2026-09-02.)

---

## Arquitectura general de las 5 vías

```
┌─────────────────────────────────────────────────────────┐
│                    AGENTE (LLM)                         │
│  Ve imágenes en el chat (V1) o recibe screenshots       │
│  de tools MCP/scripts (V2-V5)                           │
└──────────┬──────────────────────────────────────────────┘
           │
    ┌──────┴──────┬──────────────┬──────────────┬─────────┐
    │             │              │              │         │
  ┌─▼─┐       ┌──▼──┐       ┌──▼──┐       ┌──▼──┐  ┌──▼──┐
  │V1 │       │ V2  │       │ V3  │       │ V4  │  │ V5  │
  │Chat│       │MCP  │       │Web  │       │MCP  │  │Blnd │
  │    │       │pant.│       │+PW  │       │Godot│  │ MCP │
  └─┬──┘       └──┬──┘       └──┬──┘       └──┬──┘  └──┬──┘
    │             │              │              │         │
    │        Python PIL     Playwright      Plugin     Addon
    │        + pygetwindow  + http.server   Godot      Blender
    │                                        │         │
    │                                   ┌────▼────┐ ┌──▼───┐
    │                                   │ Editor  │ │3D    │
    │                                   │ Godot   │ │Viewpt│
    │                                   └─────────┘ └──────┘
    │
  Usuario pega screenshot en el chat
```

## Matriz de decisión: qué vía usar según escenario

| Escenario | Vía recomendada | Por qué |
|-----------|----------------|---------|
| Validación estética final del usuario | **V1** | El usuario ve la imagen y opina directamente |
| Verificación de UI/menús | **V2** | Captura rápida de ventana Godot |
| QA automatizado/regresión visual | **V3** | Playwright ejecuta y captura automáticamente |
| Verificar dentro del juego (gameplay, terreno, cámara) | **V4** | Controla el editor Godot, ejecuta el juego |
| Diseño/modelado de assets 3D | **V5** | Blender MCP da acceso al viewport 3D |
| Sin MCP disponible (fallback universal) | **V2** | Funciona con solo Python + Pillow |
| Plataforma sin Godot MCP nativo | **V2 + scripts** | Misma semántica, scripts Python directos |
| Build web para QA visual | **V3** | Export + Playwright en headless |

## Protocolo de iteración visual (6 pasos)

1. **Capturar** → usar la vía disponible (V2-V5) o pedir al usuario (V1)
2. **Analizar** → el agente examina la imagen (UX, posición, errores visuales)
3. **Proponer** → sugerir cambios concretos (código, diseño, posición)
4. **Implementar** → editar scripts/configuración
5. **Re-capturar** → verificar el cambio con otra captura
6. **Repetir** → máximo 5 iteraciones autónomas; si no se resuelve, escalar al usuario

## Límites de iteración

- **Máximo 5 iteraciones autónomas** antes de pedir confirmación al usuario
- **Resolución máxima:** 1280x720 (preservar contexto del chat)
- **Formato:** PNG para UI, WebP para assets (comprimir)
- **Convención de nombres:** `logs/screenshots/{modulo}_{version}_{timestamp}.png`

**Firma:** MiMo V2.5 · OpenCode · 2026-08-31.

