# INVENTARIO-RAIZ — Inventario de archivos y carpetas de la raíz del proyecto (M03)

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-10-23
**Estado:** [x] completado

---

## Archivos de la raíz

| Archivo | Tipo | Propósito |
|---------|------|-----------|
| `AGENTS.md` | Markdown | Reglas globales para la IA (metodología multiagente, protocolo, convenciones). Lectura obligatoria antes de cualquier tarea. |
| `CHECKLIST-GLOBAL.md` | Markdown | Tablero de resumen de todos los módulos (1 fila = 1 módulo). Fuente de verdad del estado global. |
| `README.md` | Markdown | Descripción del proyecto (pendiente de completar). |
| `kilo.json` | JSON | Configuración de Kilo Code (MCPs, agents, commands). |
| `.gitignore` | Texto | Exclusiones de git (Library/, Temp/, obj/, capturas/, etc.). |

## Carpetas de la raíz

| Carpeta | Propósito |
|---------|-----------|
| `DOCUMENTACION/` | Documentación del proyecto (specs, diseño, tareas, ejecución, guías). Ver `DOCUMENTACION/README.md`. |
| `Logs/` | Logs de ejecución del juego y logs de cambios de agentes. Incluye `NUMEROS_DISPONIBLES.txt` (pool de números para logs). |
| `Mensajes entre modelos/` | Comunicación entre modelos LLM (canales por modelo, temas, resueltos). Ver `GUIA-COMUNICACION.md`. |
| `Obsoletos/` | Respaldos de archivos obsoletos (versiones antiguas de documentos). |
| `scripts/` | Scripts de automatización (generar_checklist_global.py, verificar_checklist.py, test_scripts.py, fix_encoding.py, etc.). |
| `tools/` | Herramientas auxiliares (mcp/godot-mcp para capturas, scripts de prueba/reutilizables). |
| `.claude/` | Skills de desarrollo reutilizables (SKILL.md por tema: Godot, Blender, etc.). |
| `.kilo/` | Configuración de Kilo Code (commands, agents). |
| `game/` | Proyecto Godot (isla-ancestral). Contiene scenes, scripts, assets, data. |
| `Obsoletos/` | Respaldos de archivos obsoletos. |
| `DOCUMENTACION/00-PLAN-INICIAL/` | Documentación original del proyecto (no modificar). |
| `DOCUMENTACION/GUIA-GODOT/` | Guía de codificación en Godot 4.x (errores comunes, convenciones, checklist). |
| `DOCUMENTACION/GUIA-BLENDER/` | Guía de modelado en Blender (bpy, exportación). |
| `DOCUMENTACION/TAREAS-POR-MODELO/` | Backlogs personales de cada modelo (BACKLOG-MASTER.md por modelo). |

## Carpetas de desarrollo (game/)

| Carpeta | Propósito |
|---------|-----------|
| `game/isla-ancestral/` | Proyecto Godot principal. |
| `game/isla-ancestral/data/` | Datos del juego (balance, monetizacion, backup, multijugador). |
| `game/isla-ancestral/scripts/` | Scripts GDScript del juego. |
| `game/isla-ancestral/scenes/` | Escenas del juego. |
| `game/isla-ancestral/assets/` | Assets del juego (modelos, texturas, audio). |

## Notas
- La carpeta `DOCUMENTACION/` es la fuente de verdad de la documentación. Ver `DOCUMENTACION/README.md` para la estructura.
- La carpeta `Mensajes entre modelos/` es el canal de comunicación entre agentes. Ver `GUIA-COMUNICACION.md`.
- La carpeta `tools/mcp/godot-mcp/capturas/` contiene capturas de pantalla por módulo (no versionadas en git).