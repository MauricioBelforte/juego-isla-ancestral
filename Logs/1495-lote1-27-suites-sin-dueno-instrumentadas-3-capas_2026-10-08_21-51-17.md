# Log 1495 - LOTE 1: instrumentacion anti-falso-verde (3 capas) de 27 suites SIN-DUENO

**Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
**Fecha:** 2026-10-08 21:51
**Canal:** responde al mensaje 98 del director (atria-Dawn-Preview)
**Pool log:** 1495 (reservado con `scripts/reservar_log.py --reservar`; cabeza previa medida = 1495)
**Pool canal:** 99 (reservado con `scripts/reservar_mensaje.py`; cabeza previa medida = 99)

---

## 1. Encargo (msg 98, sec.6)

Instrumentar con la "receta de 3 capas" las suites SIN-DUENO del barrido 96, con pisos
**MEDIDOS**, SIN cambiar logica ni aserciones, y verificar en **RUNTIME** (no estatico)
que cada suite sigue en 0 fallos. Prohibido commit/push (el director centraliza). No
tocar `quality.yml` ni `CHECKLIST-GLOBAL.md`. Las 4 NO-APLICA quedan EXCLUIDAS.

## 2. Alcance real

- **SIN-DUENO = 29 suites** = 27 VIVA-SILENCIOSA (instrumentables, **1168 checks reales**)
  + 2 NO-APLICA (`test_bug106_verify.gd` M15, `test_diag_m38_atria.gd` M38; sin `_check()`).
- **Instrumentadas: las 27.** NO tocadas: las 2 NO-APLICA del lote (la receta no aplica) ni
  las otras 2 NO-APLICA ajenas al lote (`test_catalogo_m39_m15.gd`, `test_distribucion.gd`).

## 3. Metodo (solo instrumentacion; cero cambio de logica ni aserciones)

Receta de 3 capas aplicada a cada suite (patron ya aceptado en M155, canal 97):

1. `_fin(nombre)` por bloque: marca el bloque como ejecutado.
2. `CHECKS_MINIMOS` = piso **MEDIDO** (el conteo real del barrido 96; nunca estimado).
3. `_summary()` diferido (`call_deferred("_summary")` en `_init()`): (a) NOMBRA cada bloque
   que no se ejecuto (posible `SCRIPT ERROR`), (b) exige `_checks >= CHECKS_MINIMOS`,
   (c) imprime `=== Resumen M##: N checks, F fallos ===`, (d) `quit(1 if _fallos>0 else 0)`.
   Ademas: `_checks += 1` como primera linea de `_check()`.

Inyeccion quirurgica (idempotente, por insercion dirigida). Casos especiales:
- `test_consumidores_tiempo.gd`: usaba `fallos`/`ok` (no `_fallos`/`_checks`); su `_fin()`
  previo (early-exit) se remapeo a `_summary()`; contador agregado a `_check(nombre, cond)`.
- `test_combat_m164_atria.gd`: ya tenia guardian `_fin` con Dictionary; `_summary()` ahora
  llama a `_verificar_guardian()` (verifica bloques y aporta 4 de los 81 checks).
- `test_herramientas.gd`: driver es `_init()` (sin `call_deferred` previo) -> se inserto
  `call_deferred("_summary")` al inicio de `_init()`.

## 4. Pisos medidos (27 suites) y verificacion en runtime

Corrida real (Godot 4.7.2 headless, `--script res://<suite>`, 27/27):

| # | Suite | Mod | Piso (CHECKS_MINIMOS) | checks runtime | fallos | EXIT |
|---|---|---|---|---|---|---|
| 1 | `test_accesibilidad_manager.gd` | M58 | 39 | 39 | 0 | 0 |
| 2 | `test_anti_softlock_m66.gd` | M66 | 19 | 19 | 0 | 0 |
| 3 | `test_barter.gd` | M38 | 18 | 18 | 0 | 0 |
| 4 | `test_clima.gd` | M32 | 29 | 29 | 0 | 0 |
| 5 | `test_combat_m164_atria.gd` | M164 | 81 | 81 | 0 | 0 |
| 6 | `test_consumidores_tiempo.gd` | M29 | 12 | 12 | 0 | 0 |
| 7 | `test_estacion_iter5.gd` | M15 | 10 | 10 | 0 | 0 |
| 8 | `test_event_manager_pure.gd` | M74 | 31 | 31 | 0 | 0 |
| 9 | `test_fallbacks_m66.gd` | M66 | 8 | 8 | 0 | 0 |
| 10 | `test_fauna.gd` | M36 | 58 | 58 | 0 | 0 |
| 11 | `test_gates_m118.gd` | M118 | 25 | 25 | 0 | 0 |
| 12 | `test_herramientas.gd` | M13 | 334 | 334 | 0 | 0 |
| 13 | `test_herramientas_iter4.gd` | M13 | 28 | 28 | 0 | 0 |
| 14 | `test_historia.gd` | M22 | 41 | 41 | 0 | 0 |
| 15 | `test_inventario.gd` | M14 | 68 | 68 | 0 | 0 |
| 16 | `test_inventario_iter5.gd` | M14 | 70 | 70 | 0 | 0 |
| 17 | `test_iter4_brechas.gd` | M38 | 20 | 20 | 0 | 0 |
| 18 | `test_m15_iter6_atria.gd` | M15 | 14 | 14 | 0 | 0 |
| 19 | `test_m38_economia_smoke.gd` | M38 | 7 | 7 | 0 | 0 |
| 20 | `test_mudanzas.gd` | M19 | 40 | 40 | 0 | 0 |
| 21 | `test_progresion.gd` | M71 | 83 | 83 | 0 | 0 |
| 22 | `test_recurso_nodo.gd` | M15 | 14 | 14 | 0 | 0 |
| 23 | `test_recursos.gd` | M15 | 23 | 23 | 0 | 0 |
| 24 | `test_recursos_persistencia.gd` | M15 | 23 | 23 | 0 | 0 |
| 25 | `test_recursos_spawner_runtime.gd` | M15 | 27 | 27 | 0 | 0 |
| 26 | `test_reloj_localizacion.gd` | M30 | 6 | 6 | 0 | 0 |
| 27 | `test_vehiculos.gd` | M67 | 40 | 40 | 0 | 0 |

**Resultado: 27/27 OK, 1168/1168 checks (== piso medido en cada suite), 0 fallos,
EXIT 0, 0 `SCRIPT ERROR`, 0 Parse/Compile Error.** El total 1168 calza EXACTO con el
total SIN-DUENO del Log 1490 -> confirma que no se altero la logica ni el conteo.

## 5. Prueba del guardian EN ROJO (por inyeccion) y restauracion

Sobre suites de prueba (patron rojo2.py), sin dejar rastro en el repo:
- **P1 (piso + 1):** `CHECKS_MINIMOS` a N+1 -> `rc=1` con
  `[FAIL] solo N checks ejecutados (minimo N+1)`. Prueba que el piso no es vacuo.
- **P2 (aborto en runtime, NO error de parseo):** se inserto un aborto real de runtime
  (`var _wb_arr: Array = []; _wb_arr[0] = 1`) tras un ancla -> `rc=1` NOMBRANDO cada bloque
  que no termino Y marcando la caida del conteo. Prueba la capa 1 (bloques) + capa 2 (piso).
- **Restauracion byte-exacta:** sha256 de los 27 sin cambio tras la prueba; **CONTROL rc=0**.

Nota (trampa AU evitada): una inyeccion de error de PARSEO NO sirve de prueba (el gateway
sale antes de que corra el `_summary()` diferido). Por eso P2 inyecta un aborto de RUNTIME.

## 6. EOL / BOM

27 archivos: **0 con BOM, 0 con U+FFFD**. CRLF preservado donde el original lo tenia:
`test_gates_m118.gd` (CRLF=107) y `test_progresion.gd` (CRLF=440); el resto LF. Sin drift.

## 7. Commit / push

**NO commitie ni pushee nada** (regla del msg 98 sec.6; el director centraliza).
El director ya centralizo el commit **`eb3de84`** ("Se procesaron reportes de la flota y
se aplicaron flips de auditoria BUG-070", 2026-10-08 21:47:40), que incluye las 27 suites
instrumentadas de este lote, y registro la huella de push (seccion 4.3) en el Log 1494
(rango `ab7afc8..eb3de84`). HEAD contiene la version final (0 artefactos de inyeccion roja,
worktree limpio para las 27). No toque `quality.yml` ni `CHECKLIST-GLOBAL.md`.

## 8. Excepciones

- 2 NO-APLICA del lote SIN-DUENO (`test_bug106_verify.gd`, `test_diag_m38_atria.gd`): sin
  `_check()`, la receta no aplica. NO instrumentadas, NO inventadas. Quedan para revision
  manual del dueno/director.
- 0 suites con no-determinismo; 0 suites con `SCRIPT ERROR`; 0 excepciones de piso.
