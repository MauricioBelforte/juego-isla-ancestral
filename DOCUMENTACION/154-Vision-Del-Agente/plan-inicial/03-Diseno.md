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

## 3. Matriz de decisión: qué vía usar

| Escenario | Vía primaria | Fallback |
|---|---|---|
| Diseño iterativo de personajes voxel | V4 (capture_viewport de escena preview) | V2 → V1 |
| QA visual de UI/menús | V4 | V3 (interacción automatizada) |
| Regresión visual en CI | V3 | — (no aplica en CI sin display) |
| Validación estética final (dirección de arte) | V1 (decisión del usuario) | — |
| Verificar errores tras cambio de código | V4 (get_errors) | execute_command (consola) |
| El agente necesita ver algo fuera del juego | V2 | V1 |

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