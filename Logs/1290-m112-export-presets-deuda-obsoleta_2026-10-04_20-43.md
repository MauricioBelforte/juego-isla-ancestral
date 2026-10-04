# Log 1290: M112 - export_presets.cfg versionado + DEUDA_CONOCIDA obsoleta borrada

**Fecha:** 2026-10-04
**Hora:** 20:43
**Modelo:** atria-dawn-s2
**Plataforma:** Kilo Code

## Resumen

El job M112 volvio a fallar despues de mi fix del `.gitignore` (Log 1281): al quedar versionados los tests M116/M117, el gate llego mas lejos y encontro 3 fallos nuevos. 2 eran el mismo patron `.gitignore` (arreglados); el tercero es un falso positivo de entorno CI (reportado). Ademas, mi fix del Log 1281 dejo obsoleta una entrada del validador de workflows, que apago otro job.

## Cambios Realizados

### 1. Job Protocolo y Workflows: DEUDA_CONOCIDA obsoleta (MI fix lo rompio)

El validador `scripts/validar_workflows.py` lleva una lista `DEUDA_CONOCIDA` de scripts citados por workflows pero no versionados. Mi Log 1281 versiono `test_instalador_m116.gd` y `test_build_m117.gd` (fix del patron `build/`), asi que esas 2 entradas quedaron obsoletas y el validador las marco como error:

```
❌ DEUDA_OBSOLETA en DEUDA_CONOCIDA: `scripts/build/test_build_m117.gd` (dueno M117) YA esta versionada
❌ DEUDA_OBSOLETA en DEUDA_CONOCIDA: `scripts/build/test_instalador_m116.gd` (dueno M116) YA esta versionada
```

Fix: borradas las 2 entradas de `DEUDA_CONOCIDA` (queda vacia). El propio comentario del archivo lo instruia: "Al resolver una, hay que borrar su linea" (mismo escenario que M64, documentado por DeepSeek-V4.1-Flash en el commit `97c2440`). Anote el motivo en el comentario.

Verificado: `--selftest` 6/6 OK, validacion real EXIT 0 ("6 workflow(s) validos").

### 2. M116 + M112: export_presets.cfg sin versionar

Ambas suites fallaban en CI por la misma causa:

```
[M116] [ERROR] V6: no se pudo leer export_presets.cfg -> pipeline de distribucion INCOHERENTE
[M117] [FAIL] export_presets.cfg leido (>=1 preset) presets=[]
```

El archivo SI existe localmente (4 presets: Web, Windows, ...) pero `game/isla-ancestral/.gitignore:4` tenia `/export_presets.cfg`, el patron estandar que recomienda GitHub para Godot. En CI no llega.

Fix: removida la linea del `.gitignore` del juego (anotado el motivo). Verificado que el archivo es configuracion de export limpia, sin rutas locales ni secretos.

Verificado localmente con el binario real:
- `test_instalador_m116.gd` -> **15 checks, 0 fallos** ("TEST M116 OK - todos los checks pasaron")
- `test_build_m117.gd` -> **14 checks, 0 fallos**

### 3. M103 frame-budget: falso positivo de entorno CI (NO arreglado, reportado)

```
[FALLO] el eco a consola explica al menos el 80% del coste de escribir
        << con eco=12181 us  sin eco=5780 us (queda el 47.5%)
```

El check mide que el `print` a consola explique >=80% del coste de una escritura. En CI NO pasa, y la razon es el entorno: el propio log de la suite lo dice ("el coste de la consola depende del DESTINO de stdout: tuberia ~35x mas cara que archivo"). En CI stdout es una tuberia capturada por GitHub Actions, que encarece el eco relativamente al disco. En mi maquina local la proporcion da distinta.

Es un falso positivo por entorno, no un bug de codigo. **No lo toco**: es decision del dueno de M103 (relajar el umbral, o comparar contra una constante en vez de contra la tuberia).

### 4. GDScript Linter: cascada voxel (NO arreglado, reportado)

El linter en CI sigue con errores, y **todos** son de voxel:

- `addons/` esta ignorado por `.gitignore:16` (intencional: "se instalan via AssetLib").
- En CI no hay `libvoxel.linux.editor.x86_64.so` -> `VoxelTerrain`, `VoxelTool`, `VoxelBuffer`, `VoxelViewer`, `VoxelBlockyLibrary`, `VoxelBlockyModelEmpty`... no resuelven.
- `terrain_locator.gd` (un **autoload**) no compila -> "Failed to create an autoload" -> cascada a "Could not resolve script" sobre los tests de `tests/unit/...` (12 contados por el gate).

Localmente da 0 porque tengo el `.dll` de Windows. Esto **no es codigo del proyecto**: es que CI no tiene el addon. Opciones para el director:
1. Versionar el addon voxel (binarios multiplataforma incluidos).
2. Instalarlo en CI antes de correr (AssetLib o script).
3. Aceptar que el linter lleva voxel-cascada y mirar solo el conteo del gate.

No decido: es infraestructura de CI. Reportado en el canal 20.

## Estado de los jobs (run `37241844386`, mi commit `3819cea`)

| Job | Estado | Nota |
|---|---|---|
| UTF-8 sin BOM | OK | Log 1275 |
| Legal Tooling (M127) | OK | Log 1274 |
| Protocolo y Workflows | OK arreglado | este log (DEUDA obsoleta) |
| Run Test Suite (M112) | parcial | M116+M117 arreglados; M103 falso positivo CI |
| GDScript Linter | pendiente | cascada voxel, decision del director |
| Architecture Guard (M62) | OK | mimo lo fixeo (confirmado en run posterior) |

## Archivos Modificados/Creados

- `scripts/validar_workflows.py` (DEUDA_CONOCIDA: 2 entradas obsoletas borradas + nota)
- `game/isla-ancestral/.gitignore` (removido `/export_presets.cfg`)
- `game/isla-ancestral/export_presets.cfg` (ahora versionado)
- `Logs/1290-m112-export-presets-deuda-obsoleta_2026-10-04_20-43.md` (este log)
- `Logs/NUMEROS_DISPONIBLES.txt` (1290 consumido; nueva cabeza 1291)

## Huella de push (AGENTS.md seccion 4.3)

Push principal: `a1b51a3..de303d7` (main -> main), 2026-10-04 20:44, atria-dawn-s2 / Kilo Code. Commit `de303d7` "Se arreglaron M116/M112: export_presets.cfg versionado + DEUDA obsoleta borrada". Sin conflictos ni catch-ups.
