# 07 — Resultados de Testings — M23: Historias Secundarias

**Modelo:** Step-5-WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-21 a 2026-10-22 (iter. 2, Log 2082; iter. 3, Log 2083; iter. 4, Log 2085; iter. 5, Log 2107; iter. 6, Log 2117; iter. 7, Log 2125); iter. 8, Log 2127)

Binario real: `D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe`
(`--headless --path game/isla-ancestral --script res://...`). Ninguna cifra de este
documento es heredada: todo se midió en esta iteración.

## 1. Suite principal endurecida — `test_historias.gd`

| Corrida | Checks | Fallos | EXIT | SCRIPT ERROR |
|---|---|---|---|---|
| 1 | 40 | 0 | 0 | 0 |
| 2 | 40 | 0 | 0 | 0 |
| 3 | 40 | 0 | 0 | 0 |

Salida: `=== TEST M23 HISTORIAS: 0 fallo(s) (40 checks) ===`

Incluye el bloque F extendido: los 4 finales de M22 (`final_principal`,
`final_regresar`, `final_guardian`, `final_secreto` de
`data/historia/historia_principal.json`), cada uno con verificación de bloqueo sin
final y apertura con final.

### Iter. 3 (Log 2083) — merge de `cadenas_ejemplo.json` + bloque H

| Corrida | Checks | Fallos | EXIT | SCRIPT ERROR |
|---|---|---|---|---|
| 1 | 59 | 0 | 0 | 0 |
| 2 | 59 | 0 | 0 | 0 |
| 3 | 59 | 0 | 0 | 0 |

Salida: `=== TEST M23 HISTORIAS: 0 fallo(s) (59 checks) ===`

Carga medida: `[M23] Cadenas cargadas: 5 (ejemplos: añadidas 1, conflictos 1,
rechazadas 1)` — `+cadena-biblioteca`; conflicto `cadena-faro` resuelto a favor del
principal; `cadena-postgame-plaza` rechazada por tipo de paso `"construir"`
desconocido. El bloque H corre `cadena-biblioteca` end-to-end (hablar bibliotecaria /
explorar biblioteca / entregar tomo_antiguo / completada).

### Iter. 4 (Log 2085) — esquema normalizado + bloque I

| Corrida | Checks | Fallos | EXIT | SCRIPT ERROR |
|---|---|---|---|---|
| 1 | 70 | 0 | 0 | 0 |
| 2 | 70 | 0 | 0 | 0 |
| 3 | 70 | 0 | 0 | 0 |

El bloque I afirma que AMBAS cargas (crudas y mergeadas) quedan en el mismo esquema de
flags pelados y que los flags compartidos tienen el mismo deletreo.

### Iter. 5 (Log 2107) — 6 historias de vecinos + bloque J

| Corrida | Checks | Fallos | EXIT | SCRIPT ERROR |
|---|---|---|---|---|
| 1 | 98 | 0 | 0 | 0 |

Asserts existentes actualizados por el contenido nuevo (A: 5 -> 11 cadenas cargadas;
I: principal 4 -> 10, cargadas 5 -> 11). El bloque J corre end-to-end DOS cadenas
(`cadena-carpintero` con `madera_roble` real del inventario y `cadena-alquimista` con
objeto narrativo sembrado).

### Iter. 6 (Log 2117) — 3 historias de lugares + bloque K

| Corrida | Checks | Fallos | EXIT | SCRIPT ERROR |
|---|---|---|---|---|
| 1 | 129 | 0 | 0 | 0 |
| 2 | 129 | 0 | 0 | 0 |
| 3 | 129 | 0 | 0 | 0 |
| 4 | 129 | 0 | 0 | 0 |

Salida: `=== TEST M23 HISTORIAS: 0 fallo(s) (129 checks) ===`

Carga medida: catálogo vivo **14** (13 del principal + 1 de ejemplos). El bloque K corre
las 3 cadenas nuevas end-to-end (hablar con npc REAL / explorar lugar / entregar item
REAL / puzzle) y mide las consecuencias `jardin_florecido`, `cofradia_activa` y
`molino_funcionando` aplicadas a WorldState (M21).

### Iter. 8 (Log 2127) — 6 historias de objetos legendarios + bloque M

| Corrida | Checks | Fallos | EXIT | SCRIPT ERROR |
|---|---|---|---|---|
| 1 | 227 | 0 | 0 | 0 |
| 2 | 227 | 0 | 0 | 0 |
| 3 | 227 | 0 | 0 | 0 |

Salida: `=== TEST M23 HISTORIAS: 0 fallo(s) (227 checks) ===`

Carga medida: catálogo vivo **24** (23 del principal + 1 de ejemplos). El bloque M corre
las 6 cadenas nuevas end-to-end (hablar con npc REAL / explorar lugar / entregar item
REAL o narrativo sembrado / puzzle) y mide las consecuencias `relicto_devuelto`,
`gema_devuelta`, `receta_heredada`, `llave_encontrada`, `patrulla_nocturna` y
`brujula_calibrada` aplicadas a WorldState (M21).

Asserts existentes actualizados por el contenido nuevo (A: merge 18 -> 24 y principal
17 -> 23; I: principal 17 -> 23, cargadas 18 -> 24).

Guardián EN ROJO por inyección de runtime sobre el bloque M (asignación tipada
`Variant` -> `Dictionary` sobre `cadenas_count()`): EXIT 1 con «el bloque M NO se
ejecuto» y «solo 170 checks (mínimo 227)», 2 fallos. Sonda borrada; sha256 del
original verificado; 0 sondas residuales.

### Iter. 9 (Log 2129) — 3 historias de familias + bloque N

| Corrida | Checks | Fallos | EXIT | SCRIPT ERROR |
|---|---|---|---|---|
| 1 | 258 | 0 | 0 | 0 |
| 2 | 258 | 0 | 0 | 0 |
| 3 | 258 | 0 | 0 | 0 |

Salida: `=== TEST M23 HISTORIAS: 0 fallo(s) (258 checks) ===`

Carga medida: catálogo vivo **27** (26 del principal + 1 de ejemplos). El bloque N corre
las 3 cadenas nuevas end-to-end (hablar con npc REAL / explorar lugar / entregar item
REAL / puzzle) y mide las consecuencias `molienda_familiar_restaurada`,
`red_del_abuelo_reparada` y `vigilia_de_los_guardas` aplicadas a WorldState (M21).

Asserts existentes actualizados por el contenido nuevo (A: merge 24 -> 27 y principal
23 -> 26; I: principal 23 -> 26, cargadas 24 -> 27).

Guardián EN ROJO por inyección de runtime sobre el bloque N (asignación tipada
`Variant` con `Array` -> `Dictionary`): EXIT 1 con «el bloque N NO se ejecuto» y «solo
228 checks (mínimo 258)», 2 fallos. Sonda borrada; sha256 del original verificado;
0 sondas residuales.

## 2. Guardián anti-falso-verde probado EN ROJO

Inyección de runtime (`var _n: Node = null; _n.free()` tras el bloque B), sonda
temporal dentro del proyecto, ejecutada y **borrada en la misma operación**
(0 sondas residuales):

```
SCRIPT ERROR: Invalid call. Nonexistent function 'free' in base 'Nil'.
[FAIL] el bloque C NO se ejecuto (posible SCRIPT ERROR que aborto la funcion)
[FAIL] el bloque D NO se ejecuto ...
[FAIL] el bloque E NO se ejecuto ...
[FAIL] el bloque F NO se ejecuto ...
[FAIL] el bloque G NO se ejecuto ...
[FAIL] solo 11 checks ejecutados (minimo 40): posible aborto silencioso
=== TEST M23 HISTORIAS: 6 fallo(s) (11 checks) ===   -> EXIT 1 (proceso TERMINA, no cuelga)
```

Iter. 3 (abort de runtime a mitad del bloque H, el bloque nuevo):

```
[FAIL] el bloque H NO se ejecuto (posible SCRIPT ERROR que aborto la funcion)
[FAIL] solo 47 checks ejecutados (minimo 59): posible aborto silencioso
=== TEST M23 HISTORIAS: 2 fallo(s) (47 checks) ===   -> EXIT 1
```

Sonda borrada en la misma operación; 0 sondas residuales.

Iter. 4 — dos inyecciones, ambas EXIT 1: (a) aborto de runtime a mitad del bloque I,
nombrando «el bloque I NO se ejecuto»; (b) regresión de datos con el prefijo
`estado_mundo.` re-inyectado en `cadenas_ejemplo.json`, nombrando la clave fuera de
esquema. El verde se restauró tras revertir cada inyección.

Iter. 5 — aborto de runtime al inicio del bloque J: EXIT 1 con «el bloque J NO se
ejecuto» y «solo 71 checks (mínimo 98)». La PRIMERA versión de la inyección
(`null.metodo()`) fue PARSE ERROR estático y NO probaba el guardián (trampa de la
familia del falso verde); se rehizo como abort de runtime real.

Iter. 6 — aborto de runtime al inicio del bloque K, con asignación tipada
`Variant` -> `Dictionary` (la primera versión, Dictionary -> Dictionary, no abortaba):

```
[FAIL] el bloque K NO se ejecuto (posible SCRIPT ERROR que aborto la funcion)
[FAIL] solo 99 checks ejecutados (minimo 129): posible aborto silencioso
=== TEST M23 HISTORIAS: 2 fallo(s) (99 checks) ===   -> EXIT 1
```

Sonda borrada en la misma operación; sha256 del original verificado; 0 sondas
residuales.

Iter. 10 (Log 2131) — aborto de runtime al inicio del bloque O, con asignación tipada
`Variant` con `Array` -> `Dictionary`:

```
[FAIL] el bloque O NO se ejecuto (posible SCRIPT ERROR que aborto la funcion)
[FAIL] solo 259 checks ejecutados (minimo 316): posible aborto silencioso
=== TEST M23 HISTORIAS: 2 fallo(s) (259 checks) ===   -> EXIT 1
```

Sonda borrada en la misma operación; sha256 del original verificado; 0 sondas
residuales. Las inyecciones de iter. 7 (bloque L, «solo 130 checks (mínimo 169)»),
iter. 8 (bloque M, «solo 170 checks (mínimo 227)») e iter. 9 (bloque N, «solo 228
checks (mínimo 258)») están registradas en `06-Plan-Testings.md` y en los Logs
2125/2127/2129.

## 3. Un rojo propio encontrado por el endurecimiento (y corregido)

La primera versión del bloque F (postgame x4) resetea el estado de M23 con
`restore_save_data({})` en cada iteración; el bloque G capturaba el snapshot
después y afirmaba un id fijo (`cadena-faro`) que ya no estaba completada →
**1 fallo real** («round-trip restaura completadas»). El bloque G se reescribió para
verificar **todas** las completadas del snapshot (más fuerte e independiente del
orden de los bloques). Lección: cambiar un bloque puede invalidar la premisa de otro.

## 4. Regresiones de integración

| Suite | Resultado |
|---|---|
| `scripts/historia/test_historia.gd` (M22) | 41 checks / 0 fallos / EXIT 0 / 0 SCRIPT ERROR |
| `scripts/diario/test_diario.gd` (M55) | 0 fallos / EXIT 0 / 0 SCRIPT ERROR |
| `scripts/progresion/test_progresion.gd` (M71) | 83 checks / 0 fallos / EXIT 0 / 0 SCRIPT ERROR |
| `scripts/saving/validate_save.gd` (M59) | 16 checks / 0 fallos / «VALIDACIÓN OK» / EXIT 0 / 0 SCRIPT ERROR |

(Corridas con el mismo binario el 2026-10-21; detalle completo en el Log 2082.)

Iter. 3 (Log 2083, mismo binario):

| Suite | Resultado |
|---|---|
| `scripts/diario/test_diario.gd` (M55) | 0 fallos / EXIT 0 |
| `scripts/diario/test_diario_persist.gd` (M55) | 0 fallos / EXIT 0 |
| `scripts/saving/qa_m59_payload_sections.gd` (M59) | RESULTADO=OK (payload con 50 secciones de proveedores reales) |

Iter. 5 (Log 2107, mismo binario):

| Suite | Resultado |
|---|---|
| `scripts/historia/test_historia.gd` (M22) | 41 checks / 0 fallos / EXIT 0 |
| `scripts/progresion/test_progresion.gd` (M71) | 83 checks / 0 fallos / EXIT 0 |
| `scripts/diario/test_diario.gd` (M55) | 0 fallos / EXIT 0 |
| `scripts/diario/test_diario_persist.gd` (M55) | 0 fallos / EXIT 0 |
| `scripts/saving/validate_save.gd` (M59) | 16 checks / 0 fallos / EXIT 0 |

Iter. 6 (Log 2117, mismo binario, corridas del 2026-10-22):

| Suite | Resultado |
|---|---|
| `scripts/historia/test_historia.gd` (M22) | 41 checks / 0 fallos / EXIT 0 |
| `scripts/progresion/test_progresion.gd` (M71) | 83 checks / 0 fallos / EXIT 0 |
| `scripts/progresion/test_flujo_xp_recompensa_m71_hy3.gd` (M71) | 37 checks / 0 fallos / EXIT 0 |
| `scripts/saving/test_rotate_m59.gd` (M59) | 43 checks / 0 fallos / 9 bloques cerrados / EXIT 0 |
| `scripts/saving/test_backup_rotations.gd` (M59) | 7 checks / 0 fallos / EXIT 0 |
| `scripts/diario/test_diario.gd` (M55) | 0 fallos / EXIT 0 |

Iter. 8 (Log 2127, mismo binario, corridas del 2026-10-22):

| Suite | Resultado |
|---|---|
| `scripts/historia/test_historia.gd` (M22) | 41 checks / 0 fallos / EXIT 0 |
| `scripts/progresion/test_progresion.gd` (M71) | 83 checks / 0 fallos / EXIT 0 |
| `scripts/saving/test_rotate_m59.gd` (M59) | 43 checks / 0 fallos / 9 bloques cerrados / EXIT 0 |
| `scripts/saving/test_backup_rotate_return.gd` (M59) | 4 checks / 0 fallos / EXIT 0 |
| `scripts/saving/test_backup_rotations.gd` (M59) | 7 checks / 0 fallos / EXIT 0 |
| `scripts/diario/test_diario.gd` (M55) | 0 fallos / EXIT 0 |

Iter. 10 (Log 2131, mismo binario, corridas del 2026-10-22):

| Suite | Resultado |
|---|---|
| `scripts/historia/test_historia.gd` (M22) | 41 checks / 0 fallos / EXIT 0 |
| `scripts/progresion/test_progresion.gd` (M71) | 83 checks / 0 fallos / EXIT 0 |
| `scripts/saving/test_rotate_m59.gd` (M59) | 43 checks / 0 fallos / 9 bloques cerrados / EXIT 0 |
| `scripts/saving/test_backup_rotate_return.gd` (M59) | 4 checks / 0 fallos / EXIT 0 |
| `scripts/saving/test_backup_rotations.gd` (M59) | 7 checks / 0 fallos / EXIT 0 |
| `scripts/diario/test_diario.gd` (M55) | 0 fallos / EXIT 0 |

## 5. Estado del catálogo (medido, no estimado)

- `data/historias/secundarias.json`: **32 cadenas** (faro, invernadero, epilogo-plaza,
  secretta-luciernagas, panadera, carpintero, tejedora, pescador, guarda, alquimista,
  jardines, cofradia, molino, biblioteca-quemada, observatorio, estacion, puente,
  relicto, gema, carta, llave, farol, brujula, molinera, pescadores, guardas,
  regalo-favorito, sentadilla-pesca, paseos, ficcion, ayuda-vecino,
  cartas-amistad) de las ~89 slots del catálogo de 03-Diseno. Creció 4 -> 10
  (iter. 5, vecinos) -> 13 (iter. 6, lugares) -> 17 (iter. 7, ruinas) -> 23
  (iter. 8, objetos) -> 26 (iter. 9, familias) -> 32 (iter. 10, amistad). `cadena-biblioteca` vive en el
  fichero de ejemplos (merge por id).
- `data/historias/cadenas_ejemplo.json` (3 cadenas: faro, biblioteca, postgame-plaza):
  **INTEGRADO** en la iter. 3 (Log 2083) vía `RUTA_CATALOGO_EJEMPLOS` con merge por id
  (GO del director, msg 151). Resultado medido: +1 añadida (`cadena-biblioteca`),
  1 conflicto (`cadena-faro`, gana la variante del principal), 1 rechazada
  (`cadena-postgame-plaza`, tipo de paso `"construir"` desconocido). Catálogo vivo: 5
  en iter. 3 -> **14** en iter. 6 (13 del principal + 1 de ejemplos) -> **18** en
  iter. 7 (17 del principal + 1 de ejemplos) -> **24** en iter. 8 (23 del principal
  + 1 de ejemplos) -> **27** en iter. 9 (26 + 1) -> **33** en iter. 10 (32 + 1).
- Capítulos `capitulo-*` en el catálogo M55 (`data/diario/diario_catalog.json`): **0**
  → las recompensas `diario` de las cadenas apuntan a entradas inexistentes (el
  registro efectivo es `mision_{cadena_id}`). MEDIDO iter. 3: existen
  `mision_cadena-faro` y `mision_cadena-invernadero`, NO `mision_cadena-biblioteca` →
  el puente M23→M55 degrada en silencio para la mergeada (contenido de M55).
  **Iter. 6**: el puente degrada IGUAL para las 3 cadenas nuevas —
  `not diary.esta_registrada("mision_cadena-jardines")` (idem cofradia/molino), y las
  recompensas apuntan a `capitulo-jardines` / `capitulo-cofradia` / `capitulo-molino`,
  ausentes del catálogo M55 (0 entradas `capitulo-*`). Reportado; dueño M55.
  **Iter. 7**: degrada IGUAL para las 4 de ruinas —
  `not diary.esta_registrada("mision_cadena-puente")` (idem biblioteca-quemada /
  observatorio / estacion), y las recompensas apuntan a `capitulo-biblioteca-quemada` /
  `capitulo-observatorio` / `capitulo-estacion` / `capitulo-puente`, también ausentes
  del catálogo M55. Reportado; dueño M55.
  **Iter. 8**: degrada IGUAL para las 6 de objetos —
  `not diary.esta_registrada("mision_cadena-brujula")` (idem relicto / gema /
  carta / llave / farol), y las recompensas apuntan a `capitulo-relicto` /
  `capitulo-gema` / `capitulo-carta` / `capitulo-llave` / `capitulo-farol` /
  `capitulo-brujula`, también ausentes del catálogo M55. Reportado; dueño M55.
  **Iter. 9**: degrada IGUAL para las 3 de familias —
  `not diary.esta_registrada("mision_cadena-guardas")` (idem molinera /
  pescadores) y las recompensas apuntan a `capitulo-molinera` /
  `capitulo-pescadores` / `capitulo-guardas`, ausentes del catálogo M55.
  **Iter. 10**: degrada IGUAL para las 6 de amistad —
  `not diary.esta_registrada("mision_cadena-regalo-favorito")` (idem
  sentadilla-pesca / paseos / ficcion / ayuda-vecino / cartas-amistad) y las
  recompensas apuntan a `capitulo-regalo-favorito` /
  `capitulo-sentadilla-pesca` / `capitulo-paseos` / `capitulo-ficcion` /
  `capitulo-ayuda-vecino` / `capitulo-cartas-amistad`, ausentes del catálogo M55.
  Reportado en ambas; dueño M55 (mismo patrón desde cadena-biblioteca en H).
- Consecuencias aplicadas por cadenas del principal (32 únicas sobre 32 cadenas):
  `faro_encendido`, `invernadero_abierto`, `plaza_decorada`, `luciernagas_vueltas`,
  `pan_fiesta_horneado`, `banco_plaza_reparado`, `manto_niebla_terminado`,
  `red_pescador_reparada`, `sendero_bosque_senalado`, `jarabe_lunar_listo`,
  `jardin_florecido`, `cofradia_activa`, `molino_funcionando`,
  `biblioteca_quemada_rescatada`, `observatorio_alineado`, `estacion_reparada`,
  `puente_cruzable`, `relicto_devuelto`, `gema_devuelta`, `receta_heredada`,
  `llave_encontrada`, `patrulla_nocturna`, `brujula_calibrada`,
  `molienda_familiar_restaurada`, `red_del_abuelo_reparada`,
  `vigilia_de_los_guardas`, `regalo_favorito_entregado`,
  `sentadilla_de_pesca_amistosa`, `paseo_con_amiga`,
  `historia_de_ficcion_escrita`, `puesto_de_mercedes_ordenado`,
  `correspondencia_retomada`. (Corrección de decreto: el flag real en datos es
  `sendero_bosque_senalado`, sin z; la lista previa de este documento y del bloque K
  de la suite decía `senalizado`.)
  **`molino_funcionando` RE RESPALDADA en iter. 6**: tenía 0 cadenas que la aplicaran
  desde el Log 2082 (degradada a `[?]` por el director, msg 151); `cadena-molino` la
  aplica de punta a punta (bloque K mide `ws_has("molino_funcionando")`).
- Diferencia de esquema: **RESUELTA en iter. 4** (Log 2085, GO del director msg 153). El
  archivo de ejemplos usaba claves `estado_mundo.*` mientras el motor aplica la clave de
  `consecuencia` LITERAL a WorldState y el principal usaba flags pelados. Normalizado
  data-only en `cadenas_ejemplo.json` (5 claves peladas: `faro_apagado`,
  `biblioteca_abierta`, `faro_encendido`, `biblioteca_iluminada`, `plaza_decorada`).
  Bloque I de `test_historias.gd` afirma ahora que AMBAS cargas (crudas y mergeadas)
  quedan en el mismo esquema y que los flags compartidos tienen el mismo deletreo.
  Residual fuera del GO: la `condicion` de `cadena-faro` p1 en el principal
  (`secundarias.json`) sigue con prefijo; es declarativa (0 consumidores) y se reportó.

## 6. Veredicto

Núcleo de M23 **verificado** con binario real y guarda anti-falso-verde demostrada en
rojo DIEZ veces (iter. 2; iter. 3; las dos de iter. 4 — aborto de runtime en el bloque
I y regresión de datos con prefijo re-inyectado; iter. 5 en el bloque J; iter. 6 en el
bloque K; iter. 7 en el bloque L; iter. 8 en el bloque M; iter. 9 en el bloque N;
iter. 10 en el bloque O; todas EXIT 1 nombrando el bloque o la clave). Estado actual:
suite en **316 checks / 0 fallos / EXIT 0 x3**, catálogo vivo 32 cadenas, y
regresiones M22 (41/0) · M71 (83/0 y 37/0 en flujo-XP) · M59 (43/0 con 9 bloques,
4/0 en backup-rotate-return y 7/0 en backup-rotations) · M55 (0 fallos) medidas el
2026-10-22 en las iters. 8, 9 y 10.
Pendientes = contenido narrativo y dueños externos (M22/M17/M24/M28/M32/M36/M37/M68),
documentados como `[ ]` honestos en `05-Checklist.md`. Decisiones abiertas para el
director: tipo de paso `"construir"` (rechazo PERSISTENTE por msg 153; dueños M22/M17),
entrada `mision_cadena-biblioteca` en M55, y la `condicion` prefijada del principal si
quiere extenderse el GO de normalización.


## 7. Iter. 10 — cluster Amistad (Log 2131, 2026-10-22)

- 6 cadenas nuevas en `data/historias/secundarias.json` (26 -> 32) del cluster Amistad
  del 03-Diseno L44: regalo favorito, sentadilla de pesca, paseos, ficción, ayuda a un
  vecino y cartas de amistad (la 6.a es extensión declarada del cluster: el 02-Analisis
  L25 nombra 5 temas y pide 6 misiones). NPC REALES de data/villagers/ (olivia_nutria,
  finneas_zorro, sofia_buho, aria_ciervo, mercedes_lince, luna_zorra) y objetos REALES
  de data/items/ (OBJ-ROP-005, OBJ-ITE-036, OBJ-NAT-022, OBJ-NAT-023, OBJ-ITE-035,
  OBJ-NAT-004), verificados por campo id dentro del .tres.
- Suite: bloque O (58 checks) al FINAL de `_run()`; piso 258 -> **316 checks / 0 fallos /
  EXIT 0 x3** con el binario real. Guardián EN ROJO por inyección de runtime sobre el
  bloque O: EXIT 1, «el bloque O NO se ejecuto» + «solo 259 checks (minimo 316)».
- Regresiones medidas en la corrida de cierre (mismo binario): M22 41/0 · M71 83/0 ·
  M59 rotate 43/0 (9 bloques) + backup_rotate_return 4/0 + backup_rotations 7/0 ·
  M55 0 fallos. Todas EXIT 0, 0 SCRIPT ERROR.
- Flip con cita: «Crear 6 misiones de amistad (regalo, pesca, paseos, ficción)» (L84)
  [ ] -> [x]. M23 = 62 [x] / 41 [ ] / 2 [?] = 105 por prefijo de línea.
- Hallazgo (dueno M55): el puente M23->M55 degrada en silencio para las 6 nuevas
  (`mision_cadena-*` ausentes del catálogo M55; `capitulo-*` también). No se inventa
  contenido de M55.
- Nota: la corrida que ejecutó la tanda se cortó antes de escribir este registro, el
  Log 2131 y el reporte al director; la corrida de cierre del mismo día re-verificó la
  suite (x3), el guardián (en rojo) y las regresiones, y escribió lo faltante. Las
  cifras de esta sección están medidas, no heredadas.
