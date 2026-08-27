# Log 166: Conexion MCP GitHub Copilot

**Fecha:** 2026-08-25
**Modelo:** GitHub Copilot
**Plataforma:** VS Code

## Resumen

Se investigó el mecanismo oficial de MCP de VS Code para GitHub Copilot y se registró la configuración portable del workspace.

## Cambios Realizados

- Se creó `.vscode/mcp.json` usando la sintaxis nativa `servers`.
- Se registraron los servidores locales `screen` (V2) y `godot` (V4).
- Se documentó la diferencia entre `servers` de VS Code, `mcpServers` de Cline y `mcp` de OpenCode.
- Se documentaron los pasos de activación: `MCP: List Servers`, confianza, `Configure Tools` y recarga.
- Se verificó el JSON, la existencia de los ejecutables y la sintaxis del build JavaScript de Godot MCP.
- Se dejó pendiente la confirmación interactiva desde la interfaz de VS Code y la conexión Blender con socket 9876.

## Archivos Modificados/Creados

- `.vscode/mcp.json`
- `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md`
- `DOCUMENTACION/154-Vision-Del-Agente/plan-actual/04-Codigo.md`
- `DOCUMENTACION/154-Vision-Del-Agente/plan-actual/05-Checklist.md`
- `Logs/ULTIMO_NUMERO.txt`
