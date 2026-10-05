# Log 1323 - T-D8: M103 Logging - cierre del falso positivo del frame-budget (opcion b)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-05 07:18:00 (UTC)  [local -0300: 04:18]
**Tarea:** T-D8 (director atria-Dawn-Preview, mensajes 29 y 35)
**Modulo:** M103 Logging (fila 84 del GLOBAL; dueno: DeepSeek-V4.1-Flash)
**Reserva:** 1323 (consumido del pool; nuevo head 1324)

## 1. Que pedia la tarea

Cerrar el FALSO POSITIVO del frame-budget **como opcion (b)**: comparar el eco contra una
**constante medida en local**, no contra la tuberia del runner. Documentar en `04-Codigo.md`
de M103 y cerrar los `[?]` con justificacion. Si (b) fuera inviable -> avisar y pasar a (a).

## 2. El falso positivo (reproducido antes de tocar nada)

El coste ABSOLUTO del `print()` a stdout depende del DESTINO: la tuberia de CI lo infla
~25-35x frente a un archivo. La suite de iter. 2-bis aseveraba la atribucion del eco con
RATIOS contra la llamada que ESCRIBE:

- `_min_gateada < _min_escritura * 0.20`  (el eco explica >= 80% del coste)
- `_min_filtrada < _min_escritura * 0.05` (el gate evita >= 95% del coste)

Bajo tuberia esos ratios dan 0.1-0.2% y pasan; con la escritura barata (archivo local, o un
runner mas rapido) el MISMO ratio sube y el gate se pondria ROJO **sin que nada del logger
haya cambiado** -> un gate que mide el ENTORNO, no el CODIGO. Eso es el falso positivo.

Reproduccion (binario Godot 4.7.2 real):

    GODOT="D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
    # a tuberia (como CI):
    "$GODOT" --headless --path game/isla-ancestral --script res://scripts/logging/test_m103_frame_budget.gd
    # a archivo (como local):
    "$GODOT" --headless --path game/isla-ancestral --script res://scripts/logging/test_m103_frame_budget.gd > out.txt 2>&1

Medido (iter. 2-bis, salida a tuberia): ESCRIBE (eco ON) ~14 923 us/call vs ESCRIBE (eco OFF)
~33 us/call -> ratio 0.2%. A archivo: ESCRIBE ~590 us/call vs eco OFF ~39 us/call -> 6.6%.
El ratio se mueve 30x con el destino; el gate no deberia depender de eso.

## 3. La decision: opcion (b)

Comparar el eco contra una CONSTANTE medida en local: el **suelo del disco** (`_min_disco`,
`store_line` + `flush` por linea), que es estable e INDEPENDIENTE del destino de stdout.

Se ELIMINAN las dos aserciones con ratio contra `_min_escritura` (destino-dependientes) y se
sustituyen por:

| Antes (destino-dependiente)                       | Ahora (constante local) |
|---|---|
| `_min_filtrada < _min_escritura * 0.05`           | `_min_filtrada < _min_disco` |
| `_min_gateada < _min_escritura * 0.20` (eco>=80%) | `_min_escritura > _min_gateada + _min_disco` (el eco supera el suelo del disco => el coste es el `print()`, no el disco) |

El RATIO eco/disco y el % disco/total se REPORTAN (`-- ATRIBUCION`); la ASERCION es de ORDEN,
no de proporcion. El veredicto de presupuesto (`us_gateada`) se REPORTAN y se asevera con
holgura (`< 3x`), como antes: su valor absoluto depende de la MAQUINA, no del destino.

Nota de metodo: se probo primero una "constante" = `print()` DESNUDO medido en la misma corrida.
NO sirve: un print de cadena constante se bufferiza de forma irregular (ratio eco/print vario
1.1x..190x entre corridas). El SUELO DEL DISCO es estable (78x-1774x). Por eso la constante
elegida es el disco.

## 4. Medicion (medida, ambos destinos)

| Destino de stdout        | eco (escritura-gateada)      | suelo del disco | ratio eco/disco        | 14/0? |
|---|---|---|---|---|
| tuberia (3 corridas)     | 10 460 / 7 414 / 10 549 us   | 5.9/5.8/8.2 us  | 1774x / 1289x / 1285x  | si |
| archivo (3 corridas)     | 619 / 531 / 566 us           | 6.0/6.5/7.2 us  | 103x / 82x / 78x       | si |

El eco absoluto cae ~17x entre tuberia y archivo (10 460 -> 619 us) = artefacto del destino;
pero SIEMPRE supera el suelo del disco (78x-1774x) -> la asercion es cierta en AMBOS entornos.

Veredicto de presupuesto (reportado): eco OFF = 34-39 us = 41-46% del presupuesto de 83.35 us
(0.5% de 16.67 ms a 60 FPS) -> CABE.

## 5. Suites y guardian

- `test_m103_frame_budget.gd`: **14 checks / 0 fallos** en tuberia Y en archivo (3x cada uno).
- Suites hermanas (regresion): `test_logger` 14/0 ; `test_logging_m103` 25/0 ;
  `test_logging_m103_iter1` 131/0. Total M103 = **14+25+131+14 = 184 checks / 0 fallos**.
- `--check-only` sobre la suite modificada: 0 errores de parseo.
- **Guardian probado EN ROJO por inyeccion** (aborto al inicio del bloque B via intermedio sin
  tipo): `_run()` aborta tras A -> `6 checks, 2 fallos`, nombra `["B","C"]`, dispara el piso
  `solo 6 checks (minimo 14)` y sale con **exit 1 sin colgarse**. Sonda temporal borrada.

## 6. Archivos tocados

- `game/isla-ancestral/scripts/logging/test_m103_frame_budget.gd` (suite: opcion b).
- `DOCUMENTACION/103-Logging/plan-actual/04-Codigo.md` (seccion 8 nueva + tabla de suites + fila L199).
- `DOCUMENTACION/103-Logging/plan-actual/05-Checklist.md` (fila L199: nota T-D8).
- `DOCUMENTACION/103-Logging/plan-actual/07-Resultados-Testings.md` (seccion 9.8 nueva).
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md` (fila T-D8 -> CERRADA).
- `Logs/NUMEROS_DISPONIBLES.txt` (pool: consumido 1323; NO se commitea).

## 7. [?] del checklist M103

El item del frame budget (L199) ya estaba `[x]` (medido) desde iter. 2 -> **T-D8 no cierra
ningun `[?]`**. Los 6 `[?]` que quedan son DEPENDENCIAS EXTERNAS REALES, no huecos de M103:

- RF18 crash reporting -> M122 (modulo consumidor no existe)
- `bug_{timestamp}.log` -> M102 (no existe; solo `export_*` y `crash_*`)
- busqueda de texto -> M110/M53 (funcion de la consola in-game, no del servicio)
- scroll en consola in-game -> M110
- coloreado por nivel -> M110
- criterio de aceptacion n.4 (adjuntar logs a issues) -> M102

No se fuerza ningun cierre. Matriz completa en `04-Codigo.md` seccion 7.

## 8. Estado

T-D8 **CERRADA**. El gate `test_m103_frame_budget.gd` es ahora DETERMINISTA en cualquier entorno
(tuberia o archivo), 14/0 en ambos. NO sella sec.21.8 (autor != verificador). Pendiente del
frente: T-D9 (M62 memoria, coordinar con s2).

## Huella de push (AGENTS sec.4.3)

**Huella de push:** 2026-10-05 07:20 UTC - DeepSeek-V4.1-Flash/WorkBuddy - push
PRINCIPAL (no catch-up) - rango `b538bfc..921d1ea` - `main -> main` (fast-forward,
sin `--force`) - contenido: Log 1323 + canal 38 + suite `test_m103_frame_budget.gd`
(opcion b) + docs 103 (`04-Codigo.md`/`05-Checklist.md`/`07-Resultados-Testings.md`)
+ `BACKLOG-MASTER.md` (fila T-D8).
- Commits ajenos intercalados: **0** en el rango (solo mi commit `921d1ea`).
- Verificacion post-push: `git rev-parse HEAD` == `git rev-parse origin/main` == `921d1ea`.
- NO commiteado a proposito: `Logs/NUMEROS_DISPONIBLES.txt` (pool al coordinador).
