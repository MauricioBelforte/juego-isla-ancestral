# Log 225: Auditoría de objetos pesados y actualización de .gitignore

**Fecha:** 2026-08-29
**Modelo:** Hy3
**Plataforma:** Kilo

## Resumen
Auditoría de peso del repo (untracked + tracked) solicitada por el usuario tras la instalación de dependencias por otros módulos. Se identificaron los objetos pesados y se añadieron al `.gitignore` los que correspondía.

## Diagnóstico

| Objeto | Peso | Estado git | Acción |
|---|---|---|---|
| `tools/mcp/blender-mcp/**/capturas/` (renders PNG del agente Blender) | 298,7 MB (344 PNG) | YA ignorado por `**/capturas/` | Ninguna (verificado con check-ignore) |
| `game/isla-ancestral/addons/zylann.voxel/bin/` (binarios multiplataforma) | 100,2 MB | YA ignorado | Ninguna (check-ignore OK; solo 18 archivos del addon están trackeados) |
| `tools/mcp/.venv/` (entorno Python de MCPs) | 121,3 MB | YA ignorado (`.venv/`) | Ninguna |
| `build/web/` (export web) | 38,1 MB | YA ignorado (`build/`) | Ninguna |
| `tools/mcp/godot-mcp/node_modules/` | 29,6 MB | YA ignorado (repo embebido) | Ninguna |
| `*.blend1` (backups automáticos de Blender) | 23,9 MB (21 archivos) | NO ignorado | **AÑADIDO `*.blend1`** |
| `.blend` (assets fuente lowpoly) | 47,6 MB (43 archivos) | NO ignorado | Se dejan versionables (son la fuente de los assets del juego; decisión de política pendiente del usuario si quisiera excluirlos) |
| `game/isla-ancestral/addons/gdUnit4/` (instalado por M112) | 1,1 MB | NO ignorado a propósito | Se deja versionable: los tests de M112 lo necesitan en cualquier máquina |
| `.workbuddy-ai/` (estado de herramienta de agente) | ~0 MB | NO ignorado | **AÑADIDO `.workbuddy-ai/`** |
| `.claude/` (skills del protocolo + settings de hooks M111) | 7,2 MB | Versionable (§27) | Ninguna |
| `docs/` (docs de calidad/desarrolladores de M111) | ~0 MB | Versionable | Ninguna |
| `game/isla-ancestral/.godot/` | 4,0 MB | YA ignorado | Ninguna |

## Cambios Realizados
- `.gitignore`: añadidas reglas `*.blend1` (backups automáticos del editor Blender) y `.workbuddy-ai/` (estado local de herramienta de agente).
- Verificado con `git check-ignore` que los 298 MB de PNG de blender-mcp y los 100 MB del bin de zylann.voxel nunca entran al repo.

## Notas
- El "módulo que instaló cosas" fue M112 (ox-alpha): GdUnit4 v6.2.1, pero pesa solo 1,1 MB y debe versionarse.
- El mayor riesgo de peso futuro son los `.blend` (47,6 MB y creciendo con cada modelo): si el usuario prefiere excluirlos, bastaría añadir `*.blend` al .gitignore (hoy quedan versionables por ser los assets fuente).

## Archivos Modificados/Creados
- `.gitignore` (reglas `*.blend1` y `.workbuddy-ai/`)
- `Logs/225-auditoria-pesados-gitignore_2026-08-29_00-30-00.md` (este log)
- `Logs/ULTIMO_NUMERO.txt` → 225
