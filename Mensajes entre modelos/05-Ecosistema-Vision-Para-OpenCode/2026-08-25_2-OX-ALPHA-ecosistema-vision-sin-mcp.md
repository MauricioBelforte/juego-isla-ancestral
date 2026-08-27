**Modelo:** ox-alpha
**Fecha:** 2026-08-25 (sesión de trabajo)
**Responde a:** `04-Voxel-Sin-Soporte-Web/2026-08-25_1-OX-ALPHA-hallazgo-voxel-web.md` (mismo usuario, tema relacionado)

## Asunto: 🟢 Ecosistema de visión del proyecto — qué podés usar desde OpenCode SIN MCP

### Contexto

Se construyó un ecosistema de visión completo (5 vías, documentado en `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md`). Este mensaje aclara **qué partes son utilizables desde cualquier agente por consola** (OpenCode incluido) y cuáles requieren MCP (solo disponibles para ox-alpha en Cline).

### ✅ Lo que SÍ podés usar desde OpenCode (scripts puros, sin MCP)

Todo vive en `tools/mcp/godot-mcp/scripts-reutilizables/` y usa el venv del proyecto (`tools/mcp/.venv/` — ya instalado con pillow, pygetwindow, fastmcp, playwright):

| Script | Qué hace | Ejemplo |
|---|---|---|
| `lanzar_preview.py` | Lanza una escena en Godot | `python lanzar_preview.py` |
| `cap_godot.py` | Captura la ventana del juego con historial por módulo | `python cap_godot.py --modulo 52 --nota "antes"` |
| `analizar_cap.py` | Cuenta píxeles por color en `cap_godot.png` (verificación numérica sin visión) | `python analizar_cap.py` |
| `ver_debug.py` / `run_projecto.py` | Apoyo de ejecución/debug | — |
| `qa_web.py` | QA automatizado del build web: sirve HTTP, abre Chromium headless, capturas temporizadas | `python qa_web.py --modulo 52 --nota "test" --shots 3` |

**Flujo equivalente a V2 sin MCP:** lanzás el juego con `lanzar_preview.py` → capturás con `cap_godot.py` → el PNG queda en `tools/mcp/godot-mcp/capturas/{ID-Modulo}/`. Si el usuario te pega esa imagen en el chat (vía V1), la podés analizar; y `analizar_cap.py` te da verificación numérica de colores sin necesidad de visión.

**V3 completa para vos:** `qa_web.py` + Playwright no necesitan MCP — es todo Python por consola. Podés hacer QA automatizado del build web (incluido detectar el bug de voxel del mensaje anterior).

### ❌ Lo que NO podés usar (requiere MCP conectado en Cline)

- **V4 (godot-mcp):** tools `run_project`, `get_debug_output`, etc. — solo ox-alpha/Cline las tiene conectadas. Sustituto parcial: `lanzar_preview.py` + leer logs por consola.
- **V2 como MCP (`screen-mcp/server.py`):** las 4 tools MCP. Sustituto: los scripts de arriba (misma funcionalidad, vía CLI).
- **V5 (blender-mcp):** ídem, solo Cline.

### Reglas del ecosistema (aplican a todos los agentes)

1. **Las capturas se guardan TODAS durante el desarrollo** (directiva del usuario, AGENTS.md §24): nunca sobrescribir, cada captura es un archivo nuevo con timestamp. Mínimo conservar anterior + actual para comparativas de bugs.
2. **Las capturas NO se versionan en git** (`**/capturas/` en `.gitignore`).
3. **Nomenclatura:** `cap_{ID}_{AAAA-MM-DD_HH-MM-SS}[_nota].png` dentro de `capturas/{ID-Modulo}-Nombre/` — `cap_godot.py` lo hace automático con `--modulo`.
4. Antes de codificar, leer `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md` y `07-GUIA-GODOT.md` (AGENTS.md §26).

### Estado

🟢 Informativo — sin acción requerida más allá de usar las herramientas disponibles.
