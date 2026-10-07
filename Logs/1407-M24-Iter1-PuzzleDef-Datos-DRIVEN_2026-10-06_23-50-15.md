# Log 1407 - M24: iter. 1 - framework datos-driven + validador de unicidad + familia presion

**Fecha:** 2026-10-06 23:50 (local -0300; UTC 2026-10-07 02:50)
**Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
**Modulo:** M24-Templos-Y-Puzzles
**Plan:** aprobado por el director (canal DeepSeek/64, mensaje 64). Claim de agnes-2.5-flash liberado.
**Mensaje de canal:** 65 (deepseek-a-atria)

## 1. Alcance ejecutado (aprobado tal cual)

Iter. 1 = framework datos-driven (interprete) + validador de unicidad REAL + familia presion.
Cero acoplamiento externo (presion no necesita M13/M43/M29).

## 2. Codigo nuevo

- `game/isla-ancestral/scripts/templos/puzzle_def.gd` (NUEVO, class_name PuzzleDef, RefCounted+static):
  `cargar`, `ids_emisores`, `ids_objetivo`, `reglas_def`, `umbral_peso_de`, `completado_por`,
  `soluciones_minimas`, `solucion_minima`, `validar_def`, `a_puzzle_room`.
- `game/isla-ancestral/scripts/templos/test_puzzle_datos.gd` (NUEVO, extends SceneTree, 6 bloques A-F).
- `game/isla-ancestral/data/templos/puzzles/presion/presion_01.json` y `presion_02.json` (NUEVOS).
  Formato: {id, familia, schema_version, emisores:[{id,tipo,etiqueta,umbral_peso}], reglas:[{emisores,receptor}], objetivo:[ids]}.

## 3. Ediciones ADITIVAS (nada renombrado ni quitado)

- `scripts/templos/puzzle_room.gd`: campo `objetivo`, `vector_objetivo()`, `distancia_objetivo()`,
  `estado_igual_objetivo()`, `esta_a_casi_solucion()` (Hamming-1).
- `scripts/templos/puzzle_emisor.gd`: `umbral_peso` + `umbral_peso_export` + `recibir_peso(peso)`.

## 4. Semantica decidida con el director (riesgo 5.2) - documentada

T = conjunto objetivo DECLARADO en datos; se completa con S == T (no "todas las reglas").
Solucion = conjunto M que activa el receptor objetivo (satisface >=1 regla); MINIMA si ningun
subconjunto propio la activa. Justo = exactamente 1 solucion minima y == T. Receptor unico exigido.
Documentado en `DOCUMENTACION/24-Templos-Y-Puzzles/plan-actual/03-Diseno.md` (seccion nueva, firma mia).

## 5. Evidencia MEDIDA

- Test `test_puzzle_datos.gd`: **42 checks, 0 fallos, EXIT 0 x3** (desglose por bloque: A=6 B=8 C=9 D=8 E=7 F=4; suma 42 = total). `CHECKS_MINIMOS = 42` MEDIDO en verde (no estimado).
- 0 SCRIPT ERROR en las 3 corridas verdes.
- Guardian anti-falso-verde probado **EN ROJO** por 3 inyecciones (runtime, no parse):
  - P1 aborto al inicio de `_run()` -> EXIT 1, nombra los 6 bloques + piso: `0 checks, 7 fallos`.
  - P2 aborto dentro del helper del bloque C -> EXIT 1, piso: `33 checks, 1 fallos` (el helper aborta, `_fin("C")` igual corre: lo caza el PISO, no el marcador).
  - P3 se quita la llamada al bloque C -> EXIT 1, piso: `33 checks, 1 fallos`.
  - Temporales `_tmp_probe_p1/p2/p3.gd` creados en `scripts/templos/` y BORRADOS (verificado `ls | grep _tmp` = vacio).
- Detector de ambiguedad probado **EN ROJO** por inyeccion: `soluciones_minimas` forzado a `return 1`
  -> EXIT 1 con EXACTAMENTE los 2 checks de ambiguedad en rojo (`42 checks, 2 fallos`); archivo
  restaurado byte-exacto (sha256 `773e429c66a165c3` igual antes/despues).
- Regresiones (toque `puzzle_room.gd`/`puzzle_emisor.gd`): `test_puzzles.gd` 0 fallos EXIT 0;
  `test_templo_headless.gd` 4/0 EXIT 0; `test_templo_m26.gd` 92/0 EXIT 0.
- `--check-only` sobre puzzle_def/puzzle_room/puzzle_emisor/test_puzzle_datos: EXIT 0 los 4.
- Cache de clases regenerada con `--import` (PuzzleDef registrado) antes de medir.

## 6. Higiene de bytes

- Archivos nuevos: UTF-8 sin BOM, LF, 0 FFFD, 0 NUL (medido por bytes).
- `05-Checklist.md`: editado con `scripts/editar_crlf.py` (preserva EOL). Post: CRLF=242, LF=3, BOM=False, NUL=0.
- `03-Diseno.md` LF (92 lineas); `04-Codigo.md` CRLF (82 lineas). EOL preservado en ambos.

## 7. Conteo MEDIDO del checklist (34/128)

- Flips a [x]: 32 (validador 1 solucion), 34 (ejecucion datos-driven), 75 (placas umbral de peso), 76 (peso estatico/dinamico).
- 144 (validacion en Editor): `[x]` -> `[?]`, dueno "alcance futuro (EditorPlugin)" (no existe plugin; era sobre-cierre, Log 1402).
- 145-148 quedan `[x]` CON respaldo real medible (145/146 = detector de ambiguedad + tests; 147 = detector de emisor huerfano/inexistente; 148 = `esta_a_casi_solucion()`).
- Conteo: **34 [x] / 1 [?] / 93 [ ] = 128**. `**Totales:**` actualizado a 34/93/1.

## 8. No tocado / pendiente

- NO se toco `CHECKLIST-GLOBAL.md` (el director aplica el progreso con este reporte; la fila 24 sigue diciendo 31/128 -> se pedira el flip a 34/128).
- NO se toco `quality.yml`: el gate del test nuevo es aditivo (modo A, BUG-091) pero el director exige visto bueno de s2 (dueno del workflow). Se le manda solicitud (canal s2); sin su OK el test corre manual.
- NO se toco `interaction_manager.gd` (cuarentena BUG-117), ni `service_registry.gd`/`bootstrap.gd`, ni M154.
- Sin push. Commit local selectivo (sin mezclar con el working tree ajeno).

## 9. Archivos

- Nuevos: `game/isla-ancestral/scripts/templos/puzzle_def.gd`, `game/isla-ancestral/scripts/templos/test_puzzle_datos.gd`,
  `game/isla-ancestral/data/templos/puzzles/presion/presion_01.json`, `.../presion_02.json`.
- Modificados: `game/isla-ancestral/scripts/templos/puzzle_room.gd`, `.../puzzle_emisor.gd`,
  `DOCUMENTACION/24-Templos-Y-Puzzles/plan-actual/03-Diseno.md`, `.../04-Codigo.md`, `.../05-Checklist.md`.
