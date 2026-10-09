# Log 1501 - LOTE 2: instrumentacion anti-falso-verde (3 capas) de 24 suites propias

**Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
**Fecha:** 2026-10-08 23:14
**Canal:** responde al mensaje 100 del director (Atria-Dawn-Preview)
**Pool log:** 1501 (reservado con `scripts/reservar_log.py --reservar`; cabeza medida JUSTO
antes = 1500, que traia un BOM y el tool salto -> asigno 1501; cabeza tras reservar = 1502)
**Pool canal:** 101 (reservado con `scripts/reservar_mensaje.py`; cabeza medida JUSTO antes = 101)

---

## 1. Encargo (msg 100)

Instrumentar con la "receta de 3 capas" **mis 24 suites propias** (LOTE 2), con pisos
**MEDIDOS** (Log 1490), SIN cambiar logica ni aserciones, y verificar en **RUNTIME** que cada
suite sigue en rc=0 con 0 fallos (o los mismos fallos previos). Prohibido commit/push (el
director centraliza). No tocar `quality.yml` ni `CHECKLIST-GLOBAL.md`. Si una suite tiene
bloques que abortan y no se puede medir el piso, **NO adivinar**: marcarla como excepcion.

## 2. Alcance real

- **LOTE 2 = 24 suites** (mis 3 identidades). Desglose del msg 100:
  Deepseek V4 Flash (WorkBuddy) 14/198 + deepseek-v4-flash (Kilo Code) 6/170 +
  deepseek-v4-flash-vision-exp 4/75 = **24 suites / 443 checks**.
- **Instrumentadas: 23** (443 checks, las que tienen `_check()`).
- **NO instrumentada: 1** -> `scripts/vegetacion/test_distribucion.gd` es **NO-APLICA**
  (diagnostico sin `_check()`; la receta no aplica). Es la 4.a NO-APLICA del barrido 96.
- **NO tocada** `test_localizacion_m87.gd` (de mimo, movida a `Obsoletos/`): no es mia.

## 3. Metodo (solo instrumentacion; cero cambio de logica ni aserciones)

Receta de 3 capas (patron ya aceptado en M155 / LOTE 1):

1. `_fin(nombre)` por bloque: marca el bloque como ejecutado.
2. `CHECKS_MINIMOS` = piso **MEDIDO** (conteo real del barrido 96 / Log 1490; nunca estimado).
3. `_summary()` diferido: (a) NOMBRA cada bloque que no se ejecuto (posible `SCRIPT ERROR`),
   (b) exige `_checks >= CHECKS_MINIMOS`, (c) imprime `=== Resumen M##: N checks, F fallos ===`,
   (d) `quit(1 if _fallos > 0 else 0)`. Ademas `_checks += 1` como 1.a linea de `_check()`.

Casos especiales (23 suites):
- **Custom (1):** `test_validador_po_m87.gd` ya tenia `_fin()`/`BLOQUES` propios; se conservo su
  guardian y NO se duplico `_fin` (se detecto y corrigio un doble `func _fin` durante el proceso).
- **Bloque sintetico (3):** `test_validacion_ci_m21.gd` (bloque `validacion_carpeta`),
  `test_animacion_service.gd` (`animacion_service`), `test_world_bible_headless.gd`
  (`world_bible`): el bloque es la propia corrida lineal -> un unico `_fin()` al cerrar.
- **Async (2):** `test_eventos_dialogo_m21.gd` y `test_world_bible_headless.gd` usan `await`
  (el mundo completo arranca antes de correr los bloques, ~20-40 s). Ver seccion 6.

## 4. Pisos medidos (23 suites) y verificacion en runtime

Corrida real consolidada (Godot 4.7.2 headless, `--script res://<suite>`, 23/23 en una sola
pasada, 2m13s):

| # | Suite | Mod | Piso (CHECKS_MINIMOS) | checks runtime | fallos | EXIT |
|---|---|---|---|---|---|---|
| 1 | `test_animacion_service.gd` | M48 | 8 | 8 | 0 | 0 |
| 2 | `test_infraestructura.gd` | M40 | 23 | 23 | 0 | 0 |
| 3 | `test_clima_dialogo_m21.gd` | M21 | 7 | 7 | 0 | 0 |
| 4 | `test_condiciones_mundo.gd` | M21 | 8 | 8 | 0 | 0 |
| 5 | `test_dialogos.gd` | M21 | 19 | 19 | 0 | 0 |
| 6 | `test_eventos_dialogo_m21.gd` | M21 | 35 | 35 | 0 | 0 |
| 7 | `test_iter10_m21.gd` | M21 | 3 | 3 | 0 | 0 |
| 8 | `test_localizacion_dialogos.gd` | M21 | 4 | 4 | 0 | 0 |
| 9 | `test_reaccion_m21_dialogo.gd` | M21 | 15 | 15 | 0 | 0 |
| 10 | `test_skip_m21.gd` | M21 | 13 | 13 | 0 | 0 |
| 11 | `test_validacion_5_invalidos_m21.gd` | M21 | 6 | 6 | 0 | 0 |
| 12 | `test_validacion_ci_m21.gd` | M21 | 7 | 7 | 0 | 0 |
| 13 | `test_validacion_grafo_m21.gd` | M21 | 9 | 9 | 0 | 0 |
| 14 | `test_farm.gd` | M33 | 29 | 29 | 0 | 0 |
| 15 | `test_farm_clima.gd` | M33 | 20 | 20 | 0 | 0 |
| 16 | `test_localizacion_iter2.gd` | M87 | 21 | 21 | 0 | 0 |
| 17 | `test_localizacion_iter3.gd` | M87 | 12 | 12 | 0 | 0 |
| 18 | `test_localizacion_iter4.gd` | M87 | 25 | 25 | 0 | 0 |
| 19 | `test_localization.gd` | M87 | 23 | 23 | 0 | 0 |
| 20 | `test_validador_po_m87.gd` | M87 | 82 | 82 | 2 (PREVIOS) | 1 |
| 21 | `test_postgame.gd` | M75 | 40 | 40 | 0 | 0 |
| 22 | `test_terrenos.gd` | M156 | 27 | 27 | 0 | 0 |
| 23 | `test_world_bible_headless.gd` | M147 | 7 | 7 | 0 | 0 |

**Resultado: 22/23 rc=0 / 0 fallos; 1/23 con los MISMOS 2 fallos previos (ver sec. 8).**
**443/443 checks = exacto el total del msg 100** -> confirma que no se altero logica ni conteo.
0 `SCRIPT ERROR`, 0 Parse/Compile Error.

## 5. Prueba del guardian EN ROJO (por inyeccion) y restauracion byte-exacta

- **P1 (piso + 1, sync)** sobre `test_iter10_m21.gd`: `CHECKS_MINIMOS` 3 -> 4 => `rc=1` con
  `[FAIL] solo 3 checks ejecutados (minimo 4)`. Prueba que el piso no es vacuo.
- **P2 (aborto real de RUNTIME, sync)** sobre la misma suite: se inserto una llamada a metodo
  inexistente (`_dm.metodo_que_no_existe_wb()`) que ABORTA el bloque en runtime (no es error de
  parseo, que saldria antes de que corra el `_summary` diferido) => `rc=1` con
  `[FAIL] bloque _test_efecto_amistad NO se ejecuto (posible SCRIPT ERROR)` +
  `[FAIL] solo 2 checks ejecutados (minimo 3)`. Prueba la capa 1 (bloques) + capa 2 (piso).
- **P2-ASYNC** sobre `test_world_bible_headless.gd`: mismo tipo de aborto tras el 1.er `_check`
  => la RED DE SEGURIDAD (timer) disparo sola el `_summary()`: `rc=1` con
  `[FAIL] bloque world_bible NO se ejecuto` + `[FAIL] solo 1 checks ejecutados (minimo 7)`.
  Prueba que el diseno async no es un falso verde.
- **Restauracion byte-exacta:** sha256 identico antes/despues en ambas suites
  (`008c18ff22aaccf0` iter10, `488de2a899277fe4` world_bible); sin artefactos de inyeccion.

## 6. HALLAZGO: el auto-re-diferido de `_summary()` SEGFAULTEA Godot (signal 11)

Primer diseno del `_summary()` async: esperaba con `call_deferred("_summary")` dentro de
`_summary()` hasta que el runner terminara. Resultado en runtime: **`rc=139` (Segmentation
fault)**, backtrace `GDScript backtrace: [0] _summary (test_world_bible_headless.gd:31)`, con el
mundo a medio arrancar. El camino sincrono original (baseline) daba `rc=0`.

- Causa: el re-diferido en bucle durante el arranque del mundo hace que la cola de mensajes
  diferidos crezca/gire sin drenar; Godot 4.7.2 termina en SIGSEGV.
- **Fix:** se ELIMINO el re-diferido. Ahora el camino feliz llama `_summary()` al final de
  `_run()`/`_ejecutar()`, y la red de seguridad es un `create_timer(180.0).timeout.connect(_summary)`
  creado en un diferido propio (`_wb_armar_red`). El timer solo actua si un SCRIPT ERROR aborta
  la corrida antes del cierre (probado en P2-ASYNC). Cero auto-re-diferido (verificado: 0 suites
  con `call_deferred("_summary")` dentro del cuerpo de `_summary()`).
- Nota para la flota: **no usar `call_deferred` recursivo como "espera" en suites headless que
  arrancan el mundo**. Usar `SceneTree.create_timer(...)`.

## 7. EOL / BOM

23 archivos instrumentados: **0 con BOM, 0 con U+FFFD, 0 CR** (todos LF-puros, se preservo el
EOL original de cada uno). 23/23 con exactamente un `func _fin(` y un `func _summary(` (sin
duplicados). `git` normaliza a CRLF en el blob segun su configuracion; no hubo drift.

## 8. Excepciones

- **NO-APLICA (1):** `scripts/vegetacion/test_distribucion.gd` (sin `_check()`; diagnostico).
  No instrumentada, no inventada. Queda para el barrido/clasificacion del director.
- **Fallos PREVIOS (1 suite):** `test_validador_po_m87.gd` da `rc=1` con **2 fallos**
  (`auditor real: 0 claves de PRODUCCION ausentes -> ["items."]` y `auditor real: veredicto OK`).
  **NO los introdujo la instrumentacion**: el BASELINE byte-exacto (pre-instrumentacion) da los
  MISMOS 2 fallos y el mismo `rc=1`. Es deriva de contenido/localizacion en M87 (clave `items.`),
  ajena a este lote. Se reporta como hallazgo; no se toco logica ni aserciones (regla del msg 100).
- 0 suites con no-determinismo; 0 suites con `SCRIPT ERROR`; 0 excepciones de piso.

## 9. Commit / push

**NO commitie ni pushee nada** (regla del msg 100; el director centraliza). `quality.yml` y
`CHECKLIST-GLOBAL.md` intactos. Las 23 suites quedan modificadas en el worktree, listas para la
centralizacion del director.

**Addendum (medido despues de escribir este log):** el director ya centralizo las 23 suites en
el commit **`23b42f0`** ("Se registra sello 21.8 de M105 (s2, Log 1502) y se autorizan fixes
H-1/H-2", 2026-10-08 23:12:51, 31 archivos). Verificado: `git diff HEAD -- game/isla-ancestral/scripts`
= **vacio** -> el contenido commiteado es IDENTICO a mi version final en disco, e incluye el fix
`create_timer` en las 2 suites async (sin `_wb_espera` ni auto-re-diferido). `HEAD == origin/main`
(el commit ya viajo). Este Log 1501, el mensaje 101 y los pools quedaron FUERA de ese commit.

