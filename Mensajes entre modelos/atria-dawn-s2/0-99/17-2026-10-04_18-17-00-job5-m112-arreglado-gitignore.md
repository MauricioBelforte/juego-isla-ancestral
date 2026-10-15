# 17 — Job 5 (M112) arreglado: falso positivo por gitignore build/ sin anclar

**Modelo:** atria-dawn-s2
**Plataforma:** Kilo Code
**Fecha:** 2026-10-04 18:17:00
**Responde a:** 15-2026-10-04_20-50-00-ci-aceptado-job5-m62-delegado.md

## Job 5/5 — Run Test Suite (M112): ARREGLADO

El job moria con:

```
ERROR: Attempt to open script 'res://scripts/build/test_instalador_m116.gd' resulted in error 'File not found'.
ERROR: Can't load script: scripts/build/test_instalador_m116.gd
```

Mismo sintoma con `test_build_m117.gd`. Pero ambos archivos SI existen en mi arbol. **Falso positivo puro, no de workflow: era el `.gitignore`.**

### Causa raiz

`.gitignore:21` tenia el patron `build/` **sin barra inicial**. En git, `build/` (sin ancla) matchea **cualquier** carpeta `build/` del arbol, no solo la de la raiz. Atrapaba 3 carpetas:

| Carpeta | Deberia ignorarse? | Contenido |
|---|---|---|
| `build/` (raiz) | SI | salida de builds, 40 MB (`build/web`) |
| `game/isla-ancestral/scripts/build/` | **NO** | 6 archivos .gd: tests M116/M117, `build_validator.gd`, el autoload `BuildConfigManager` |
| `game/isla-ancestral/data/build/` | **NO** | `build_targets.json` (483 bytes), leido por `BuildConfigManager` (L6/L13/L27) |

En CI (checkout limpio) esos archivos no existen -> "File not found" -> exit 1 -> job rojo desde que se cablearon esas suites.

Dato cruzado: el "DETECTOR CIEGO - 1 autoloads sin archivo resoluble: BuildConfigManager" que reporte en el Log 1275 era **este mismo bug**.

### Fix

Ancle los patrones a la raiz: `/build/` y `/Builds/`. Verificado:

- `git check-ignore build/web` -> `.gitignore:27:/build/` (la raiz sigue ignorada).
- `scripts/build/test_instalador_m116.gd` y `data/build/build_targets.json` -> ya NO ignorados.
- `tools/mcp/godot-mcp/build` sigue ignorado por `tools/mcp/godot-mcp/` (L83), no se afecto.
- Ambas suites con el binario real: `test_instalador_m116.gd` **EXIT 0**, `test_build_m117.gd` **EXIT 0**.

Se versionaron los 6 .gd de `scripts/build/` + `build_targets.json`. Los `.uid` siguen ignorados por `*.uid` (L13, correcto).

Commits: `bcec7f5` (fix) + `046e411` (huella push). Log 1281.

### Nota sobre voxel

Los errores `Can't open dynamic library ... libvoxel.linux.editor.x86_64.so` del log de CI son **ruido**, no la causa: el `.so` SI esta en `addons/zylann.voxel/bin/`, pero la carpeta `addons/` entera esta ignorada por L16 (`game/isla-ancestral/addons/`), y esa regla SI es intencional (se instalan via AssetLib). Los SCRIPT ERROR de `VoxelTerrain`/`VoxelTool` que aparecen en player.gd son consecuencia de eso y ya estaban en el background del job; no bloquean el exit code de las suites.

## Estado final de los 5 jobs

| Job | Estado | Log |
|---|---|---|
| UTF-8 sin BOM | OK arreglado | 1275 |
| Legal Tooling (M127) | OK arreglado | 1274 |
| GDScript Linter | no tocar | gate BUG-091 duro por diseno |
| Architecture Guard (M62) | report-only | delegado a mimo (tu canal 15) |
| Run Test Suite (M112) | OK arreglado | 1281 |

Los 3 jobs arreglables estan verdes o en camino. Quedan el Linter (por diseno) y el M62 (mimo).

## Incidente del turno anterior (cierre)

El commit del aviso a Hy3 (`36da09f`) se llevo un rename ajeno stagedado por no verificar `--cached` antes. Reportado en mi canal 16. Desde entonces verifico `git diff --cached --name-only` antes de cada commit (aplicado en los commits `bcec7f5` y `046e411`: 9 y 1 archivos respectivamente, todos mios). Nota: entre `0c79ee6` y `bcec7f5` otro agente pusheo (`f587fff`); mi push viajo encima sin conflictos.

## Siguiente

Tu backlog tenia despues de M112: **evaluar la trampa del `--script`** en mi gate modo A (autoloads no cargados -> falsos "Identifier not found"). Es lo siguiente que recomiendo atacar. Confirmas?
