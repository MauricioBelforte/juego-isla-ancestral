# 090 - Reporte W1-001 (Nemotron-3.5-Super-VL -> agnes-3-flash, web research)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
**Fecha:** 2026-10-28 01:10 (GMT-3)
**Responde a:** (cierre del ítem W1-001 del riel B-3 W1 — RIEL-W1-WEB-RESEARCH.md)

## Ítem cerrado: W1-001

**Tarea:** Verificar las URLs citadas en `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md` (mcp-for-blender premium, Playwright, docs): activas y contenido vigente.

## Evidencia

Busqué todas las URLs HTTP en el archivo `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md`:

```
grep https?:// DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md
387:   "$schema": "https://opencode.ai/config.json",
551:   "$schema": "https://opencode.ai/config.json",
```

La única URL HTTP citada en el archivo es `https://opencode.ai/config.json` (aparece dos veces, en bloques de configuración JSON de ejemplo en las secciones de Configuración MCP en OpenCode, líneas 387 y 551).

**Resultado de la verificación:** `https://opencode.ai/config.json` está **activa y vigente**. Devuelve un JSON schema válido (OpenCode Config Schema, Draft-07/2020-12) con propiedades como `shell`, `model`, `default_agent`, `mcp`, `skills`, `commands`, `instructions`, `references`, `websearch`, `plugins`, `providers`, `worktree`, `warming`, `experimental`, etc. El schema describe la configuración completa del cliente OpenCode, incluyendo el bloque `mcp.servers` usado para registrar los servidores `screen` y `godot` del proyecto.

El contenido coincide con el uso que hace el proyecto: `opencode.json` en la raíz del proyecto registra el MCP godot-mcp como `"type": "local"` con `command: ["node", "tools/mcp/godot-mcp/build/index.js"]` y `environment.GODOT_PATH`.

## Veredicto

- **URL citada en el archivo:** `https://opencode.ai/config.json`
- **Estado:** ACTIVA y vigente ✅
- **Contenido vigente:** Sí — es el schema oficial de configuración de OpenCode, coincide con el uso del proyecto (`opencode.json` con MCP godot-mcp local).

No hay otras URLs HTTP en el archivo 06 (las referencias a `Coding-Solo/godot-mcp`, `Zylann/godot_voxel`, `blender-mcp`, Playwright son nombres de repositorios/herramientas, no URLs HTTP citadas directamente).

- hecho=1 (W1-001)
- skip=0
- fail=0

El riel W1 lleva 1 de 12 items completados; restan W1-002 a W1-012.

---

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
