# Log 1182 -- M105: re-verificacion independiente de los guardianes (6 sondas) + piso para iter7

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-02 04:12
**Modulo:** M105 (Telemetria de Gameplay)
**Tipo:** re-verificacion + hardening (NO sella QA 21.8)
**Reserva:** numero 1182 (protocolo v3, AGENTS.md 6.1.a)

---

## 1. Que se pidio y que se hizo

Directiva: "arranca con lo que puedas y sea tu fuerte". Mi fuerte es la
verificacion headless. M105 es mi modulo y es 100% headless. Se re-midio su
estado en vez de heredar el sello previo (trampa 119: un `OK` no se hereda, se
cuenta).

La reserva anterior decia "re-verificacion selectiva cerrada 2026-09-16 (Log
926). Retomable." Esta pasada re-mide la evidencia y cierra un hueco.

## 2. Las 4 suites, x3 cada una (MEDIDO)

Comando: `godot --headless --path game/isla-ancestral --script res://scripts/telemetry/<t>.gd`

| suite | checks | fallos | exit | SCRIPT ERROR | piso CHECKS_MINIMOS |
|---|---|---|---|---|---|
| test_telemetry | 16 | 0 | 0 | 0 | 16 |
| test_telemetria_iter5 | 10 | 0 | 0 | 0 | 10 |
| test_telemetria_iter6 | 11 | 0 | 0 | 0 | 11 |
| test_telemetria_iter7 | 27 | 0 | 0 | 0 | 27 (NUEVO) |

Total 64 checks, 0 fallos, 0 SCRIPT ERROR. Determinista en las 3 corridas.

## 3. Hallazgo 1 -- iter7 NO tenia piso de chequeos (cerrado)

iter7 solo tenia el guardian de BLOQUES (`_fin()`). Ese guardian NOMBRA un
bloque que no llama `_fin()`, pero NO detecta un bloque que llega a su `_fin()`
saltandose checks en silencio (p. ej. un bucle sobre 0 items). base/iter5/iter6
SI tenian piso; iter7 no.

Fix aplicado a `test_telemetria_iter7.gd` (+12 lineas, 2 hunks):
- `const CHECKS_MINIMOS := 27` (medido en verde x3, no estimado).
- En `_resumen()`: si `_checks < CHECKS_MINIMOS` -> `_fallos += 1` + `[FAIL]`.

Tras el cambio: iter7 x3 = 27/0, exit 0, 0 SCRIPT ERROR, 0 bloques faltantes.

## 4. Hallazgo 2 -- el comentario de CI decia "10 bloques"; son 12

`.github/workflows/quality.yml` afirmaba "iter7 = 27 checks, 10 bloques con
marcador _fin()". El array `BLOQUES` de iter7 tiene **12** entradas (autoload,
constantes, metrica_house, metrica_puzzle, metrica_seal, metrica_viaje,
complete_puzzle_ruta, session_duration, optout, senales, sin_pii, limpieza).
Corregido a 12. Tambien se anadio "iter7 27" a la lista de pisos del comentario.

Cambio SOLO en comentarios (verificado: +8/-4, 0 lineas no-comentario). El
validador `scripts/validar_workflows.py` da `OK quality.yml` tras el cambio.

## 5. Los guardianes, re-probados en ROJO (6 sondas)

El sello previo afirmaba "4 sondas" pero no dejo artefacto re-ejecutable. Se
re-midio con 6 sondas independientes (copia temporal del .gd, inyeccion, correr,
borrar). Las 6 dieron exit 1:

| sonda | inyeccion | resultado medido |
|---|---|---|
| A | asercion falsa al final (base) | `17 checks, 1 fallos`, exit 1 |
| B | `return` tras el 1er check (aborta `_ejecutar`) | `NO llego al final` + `solo 1 checks (minimo 16)`, exit 1 |
| C | `CHECKS_MINIMOS` 16 a 17 (base) | `solo 16 checks (minimo 17)`, exit 1 |
| D | `return` tras el bloque autoload (iter7) | nombra 11 bloques faltantes, exit 1 |
| E | suprimir `_fin("limpieza")` (iter7) | nombra `["limpieza"]` con 27 checks igual corriendo, exit 1 |
| F | `CHECKS_MINIMOS` 27 a 28 (iter7, piso nuevo) | `solo 27 checks (minimo 28)`, exit 1 |

La sonda E es la mas fuerte: un solo bloque sin cerrar se detecta aunque los 27
checks pasen. La F prueba que el piso NUEVO de iter7 tambien falla en rojo.

Cero restos: los ficheros `_probe_*` y sus `.uid` se borraron; `git status` del
directorio `scripts/telemetry/` solo muestra el .gd modificado.

## 6. Cruces

- Contador oficial `scripts/verificar_checklist.py`:
  `105-Telemetria-De-Gameplay: [x] 120 / [ ] 0 / [?] 45`. Identico a mi conteo
  por prefijo de linea (`^\s*-\s+\[[ x?]\]`). Sin inflacion.
- CI: el bloque M105 de `quality.yml` cablea las 4 suites con `|| FAIL=1`.
- Citas: `03-Diseno.md` solo tiene sec. 1-6; las 2 citas a sec. 3.4/3.5 quedan
  marcadas como FALSAS (reparadas en iter. 7). 0 citas vivas a secciones
  inexistentes.
- API: spot-check de 14 simbolos citados en la checklist
  (`establecer_opt_in`, `_cargar_opt_in`, `_persistir_opt_in`, `enter_zone`,
  `exit_zone`, `_evaluar_zona_ignorada`, `_duracion_sesion_seg`,
  `PUZZLE_ABANDONO_SEGUNDOS`, `ZONA_IGNORADA_SEGUNDOS`, `enviar_evento`,
  `_iniciar_sesion`, `_finalizar_sesion`, `METRIC_SESSION_DURATION`, `signal`)
  -> los 14 presentes en `telemetry_director.gd`.

## 7. Hallazgo ajeno (reportar, NO tocar -- sec. 21.4)

`scripts/validar_workflows.py` falla con exit 1 por 5 entradas OBSOLETAS en su
propio `DEUDA_CONOCIDA` (dueno M64): los 5 scripts `scripts/ia_npc/test_*_m64.gd`
YA estan versionados (en `game/isla-ancestral/scripts/ia_npc/`) -> el validador
pide borrar sus entradas. Es PREEXISTENTE (no lo causa mi cambio de comentarios;
es independiente de `quality.yml`). El fix es borrar 5 lineas del dict, pero es
de M64 / del coordinador. No lo toco.

## 8. Alcance -- lo que esta pasada NO hace

NO sella sec. 21.8: el verificador == autor. El sello QA cruzado sigue pendiente
de un verificador externo. Los 45 `[?]` no se tocaron.

## 9. Archivos tocados

- `game/isla-ancestral/scripts/telemetry/test_telemetria_iter7.gd` (+12 lineas)
- `.github/workflows/quality.yml` (comentario del bloque M105, +8/-4)
- `DOCUMENTACION/105-Telemetria-De-Gameplay/plan-actual/05-Checklist.md`
  (nueva seccion "Re-verificacion independiente 2026-10-02", 0 marcas nuevas)
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md`
- este log

## 10. Commit / push

Pendiente de registrar tras el commit (ver seccion anadida al final del push).

**Totales:** 4 suites x3 = 64 checks / 0 fallos / 0 SCRIPT ERROR / 6 sondas en
rojo / 2 hallazgos cerrados (piso iter7, comentario CI) / 1 hallazgo ajeno
reportado (M64) / 0 marcas de checklist alteradas.
