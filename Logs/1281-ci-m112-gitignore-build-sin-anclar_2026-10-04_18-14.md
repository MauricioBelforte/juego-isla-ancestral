# Log 1281: CI job 5 (M112) arreglado - gitignore build/ sin anclar

**Fecha:** 2026-10-04
**Hora:** 18:14
**Modelo:** atria-dawn-s2
**Plataforma:** Kilo Code

## Resumen

Quinto y ultimo job de los 5 rojos del encargo del director (canal 10): **Run Test Suite (M112 Integration)**. Diagnosticado y arreglado. Era un falso positivo por un patron de `.gitignore` mal escrito.

## Cambios Realizados

### Job 5/5: Run Test Suite (M112) - ARREGLADO

El job moria con:

```
ERROR: Attempt to open script 'res://scripts/build/test_instalador_m116.gd' resulted in error 'File not found'.
   at: load_source_code (modules/gdscript/gdscript.cpp:1139)
ERROR: Can't load script: scripts/build/test_instalador_m116.gd
   at: start (main/main.cpp:4366)
```

Lo mismo con `test_build_m117.gd`. Pero ambos archivos SI existen en el arbol local. Causa: **no estaban versionados**.

Diagnostico:
- `git ls-files` -> 0 archivos en `game/isla-ancestral/scripts/build/`.
- `git check-ignore -v` -> `.gitignore:21:build/` matchea `game/isla-ancestral/scripts/build/test_build_m117.gd`.
- El patron `build/` (sin barra inicial) matchea **cualquier** carpeta `build/` del arbol, no solo la de la raiz. Atrapaba 3 carpetas:
  - `build/` (raiz) -> correcto, es la salida de builds (40 MB, `build/web`).
  - `game/isla-ancestral/scripts/build/` -> **INCORRECTO**: 6 archivos .gd de codigo del juego, incluyendo los tests M116/M117 y el autoload `BuildConfigManager`.
  - `game/isla-ancestral/data/build/` -> **INCORRECTO**: `build_targets.json` (483 bytes), leido por `BuildConfigManager` (referenciado en build_config_manager.gd L6/L13/L27).
- En CI (checkout limpio) esos archivos no existen -> "File not found" -> exit 1 -> job rojo.
- Confirmado que no es un problema del addon voxel: sus errores de GDExtension son ruido (el .so linux SI esta en la carpeta bin/, solo que la carpeta `addons/` entera esta ignorada por L16, esa regla si es intencional).

Fix: anclar los patrones a la raiz:

```
/build/
/Builds/
```

Verificacion:
- `git check-ignore build/web` -> `.gitignore:27:/build/` (la raiz sigue ignorada).
- `git check-ignore game/isla-ancestral/scripts/build/test_instalador_m116.gd` -> ya NO ignorado.
- `git check-ignore game/isla-ancestral/data/build/build_targets.json` -> ya NO ignorado.
- `tools/mcp/godot-mcp/build` sigue ignorado por `.gitignore:83:tools/mcp/godot-mcp/` (no se ve afectado).
- Ambas suites corren con el binario real `C:\Temp\godot\godot472.exe --headless --path game/isla-ancestral --script ...`:
  - `test_instalador_m116.gd` -> EXIT 0
  - `test_build_m117.gd` -> EXIT 0

Se versionan los 6 archivos .gd de `scripts/build/` + `build_targets.json`. Los `.uid` siguen ignorados por la regla `*.uid` (L13), que es correcta.

Nota sobre el auditor M62: el "DETECTOR CIEGO - 1 autoloads sin archivo resoluble: BuildConfigManager" del Log 1275 era **este mismo bug**: el autoload estaba en `project.godot` pero su script no se versionaba por el patron sin anclar. Con este fix, `BuildConfigManager` si existe en CI (aunque su falta de archivo resoluble tambien se debe a que `addons/` ignora dependencias; el script en si ahora si llega).

### Estado final de los 5 jobs

| Job | Estado | Nota |
|---|---|---|
| UTF-8 sin BOM | OK arreglado | Log 1275 |
| Legal Tooling (M127) | OK arreglado | Log 1274 |
| GDScript Linter | no tocar | gate BUG-091 duro por diseno |
| Architecture Guard (M62) | report-only | delegado a mimo por el director (canal 15) |
| Run Test Suite (M112) | OK arreglado | este log |

## Archivos Modificados/Creados

- `.gitignore` (patrones `build/` -> `/build/`, `Builds/` -> `/Builds/` anclados)
- `game/isla-ancestral/scripts/build/build_config_manager.gd`
- `game/isla-ancestral/scripts/build/build_validator.gd`
- `game/isla-ancestral/scripts/build/test_build_m117.gd`
- `game/isla-ancestral/scripts/build/test_instalador_m116.gd`
- `game/isla-ancestral/scripts/build/validador_instalador.gd`
- `game/isla-ancestral/data/build/build_targets.json`
- `Logs/1281-ci-m112-gitignore-build-sin-anclar_2026-10-04_18-14.md` (este log)
- `Logs/NUMEROS_DISPONIBLES.txt` (1281 consumido; nueva cabeza 1282)

## Huella de push (AGENTS.md seccion 4.3)

Se completa tras el push.
