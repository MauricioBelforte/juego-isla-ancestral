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

- `data/historias/secundarias.json`: **51 cadenas** (faro, invernadero, epilogo-plaza,
  secretta-luciernagas, panadera, carpintero, tejedora, pescador, guarda, alquimista,
  jardines, cofradia, molino, biblioteca-quemada, observatorio, estacion, puente,
  relicto, gema, carta, llave, farol, brujula, molinera, pescadores, guardas,
  regalo-favorito, sentadilla-pesca, paseos, ficcion, ayuda-vecino,
  cartas-amistad, mapa-secreto, cristal-oculto, diario-antiguo, pergamino-mistico,
  mascara-ceremonial, ruta-del-mercader, cargamento-de-telas, secreto-del-yunque,
  registro-del-faro, catalogo-perdido, mediciones-de-la-isla, mapa-de-las-plantas,
  cartas-estelares, templo-de-las-24-marcas, templo-de-los-25-engranajes,
  templo-de-las-26-mareas, ruinas-del-barrizal, ruinas-del-manantial,
  ruinas-del-acantilado) de las ~89 slots del catálogo de 03-Diseno. Creció 4 -> 10
  (iter. 5, vecinos) -> 13 (iter. 6, lugares) -> 17 (iter. 7, ruinas) -> 23
  (iter. 8, objetos) -> 26 (iter. 9, familias) -> 32 (iter. 10, amistad) -> 37
  (iter. 11, secretas) -> 40 (iter. 12, comerciantes) -> 51 (iter. 13, puzzles +
  investigación). `cadena-biblioteca` vive en el
  fichero de ejemplos (merge por id).
- `data/historias/cadenas_ejemplo.json` (3 cadenas: faro, biblioteca, postgame-plaza):
  **INTEGRADO** en la iter. 3 (Log 2083) vía `RUTA_CATALOGO_EJEMPLOS` con merge por id
  (GO del director, msg 151). Resultado medido: +1 añadida (`cadena-biblioteca`),
  1 conflicto (`cadena-faro`, gana la variante del principal), 1 rechazada
  (`cadena-postgame-plaza`, tipo de paso `"construir"` desconocido). Catálogo vivo: 5
  en iter. 3 -> **14** en iter. 6 (13 del principal + 1 de ejemplos) -> **18** en
  iter. 7 (17 del principal + 1 de ejemplos) -> **24** en iter. 8 (23 del principal
  + 1 de ejemplos) -> **27** en iter. 9 (26 + 1) -> **33** en iter. 10 (32 + 1) ->
  **38** en iter. 11 (37 + 1) -> **41** en iter. 12 (40 + 1) -> **52** en iter. 13
  (51 + 1).
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
  **Iter. 11**: degrada IGUAL para las 5 secretas —
  `not diary.esta_registrada("mision_cadena-mapa-secreto")` (idem cristal-oculto /
  diario-antiguo / pergamino-mistico / mascara-ceremonial) y las recompensas apuntan a
  `capitulo-mapa-secreto` / `capitulo-cristal-oculto` / `capitulo-diario-antiguo` /
  `capitulo-pergamino-mistico` / `capitulo-mascara-ceremonial`, ausentes del catálogo M55.
  **Iter. 12**: degrada IGUAL para las 3 de comerciantes —
  `not diary.esta_registrada("mision_cadena-ruta-del-mercader")` (idem
  cargamento-de-telas / secreto-del-yunque) y las recompensas apuntan a
  `capitulo-ruta-del-mercader` / `capitulo-cargamento-de-telas` /
  `capitulo-secreto-del-yunque`, ausentes del catálogo M55. Reportado; dueño M55.
  **Iter. 13**: degrada IGUAL para las 11 de puzzles + investigación —
  `not diary.esta_registrada("mision_cadena-registro-del-faro")` (idem las otras 10)
  y las recompensas apuntan a `capitulo-registro-del-faro` /
  `capitulo-catalogo-perdido` / `capitulo-mediciones-de-la-isla` /
  `capitulo-mapa-de-las-plantas` / `capitulo-cartas-estelares` /
  `capitulo-templo-de-las-24-marcas` / `capitulo-templo-de-los-25-engranajes` /
  `capitulo-templo-de-las-26-mareas` / `capitulo-ruinas-del-barrizal` /
  `capitulo-ruinas-del-manantial` / `capitulo-ruinas-del-acantilado`, ausentes del
  catálogo M55. Reportado; dueño M55 (mismo patrón desde cadena-biblioteca en H).
- Consecuencias aplicadas por cadenas del principal (51 únicas sobre 51 cadenas):
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
  `correspondencia_retomada`, `sendero_secreto_revelado`,
  `cristal_oculto_recuperado`, `autor_del_diario_identificado`,
  `versos_antiguos_descifrados`, `mascara_ceremonial_restaurada`,
  `ruta_comercial_reabierta`, `telas_reunidas`,
  `tecnica_del_yunque_recuperada`, `registro_del_faro_recuperado`,
  `catalogo_perdido_devuelto`, `mediciones_de_la_isla_recuperadas`,
  `mapa_de_plantas_dibujado`, `cartas_estelares_descifradas`,
  `templo_de_las_24_marcas_abierto`, `templo_de_los_25_engranajes_abierto`,
  `templo_de_las_26_mareas_abierto`, `ruinas_del_barrizal_leidas`,
  `ruinas_del_manantial_leidas`, `ruinas_del_acantilado_leidas`.
  (Corrección de decreto: el flag real en datos es
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
rojo TRECE veces (iter. 2; iter. 3; las dos de iter. 4 — aborto de runtime en el bloque
I y regresión de datos con prefijo re-inyectado; iter. 5 en el bloque J; iter. 6 en el
bloque K; iter. 7 en el bloque L; iter. 8 en el bloque M; iter. 9 en el bloque N;
iter. 10 en el bloque O; iter. 11 en el bloque P; iter. 12 en el bloque Q; iter. 13 en
el bloque R; todas EXIT 1 nombrando el bloque o la clave). Estado actual:
suite en **456 checks / 0 fallos / EXIT 0 x3**, catálogo vivo 51 cadenas (52 con el
merge de ejemplos), y
regresiones M22 (41/0) · M71 (83/0 y 37/0 en flujo-XP; 8/2 en la reproducción del
BUG-143, previa) · M59 (43/0 con 9 bloques, 4/0 en backup-rotate-return, 7/0 en
backup-rotations y 0 fallos en autosave) · M55 (0 fallos en diario y persistencia)
medidas el 2026-10-22 en las iters. 8, 9, 10 y 13.
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

## 8. Iter. 11 — cadenas secretas ocultas (Log 2134, 2026-10-22)

- 5 cadenas nuevas en `data/historias/secundarias.json` (32 -> 37) del cluster Secretas
  del 03-Diseno L38: mapa secreto, cristal oculto, diario antiguo, pergamino mistico y
  mascara ceremonial. NPC REALES de data/villagers/ (nico_gato, vera_ardilla, sofia_buho,
  teo_conejo, luna_zorra) y objetos REALES de data/items/ (OBJ-SEC-002, OBJ-SEC-003,
  OBJ-SEC-005, OBJ-ART-002, OBJ-ART-004), verificados por campo id dentro del .tres.
  Las 5 nacen `oculta:true` (misma regla que cadena-secretta-luciernagas).
- Suite: bloque P (35 checks) al FINAL de `_run()`; piso 316 -> **351 checks / 0 fallos /
  EXIT 0 x3** con el binario real. Guardián EN ROJO por inyección de runtime sobre el
  bloque P: EXIT 1, «el bloque P NO se ejecuto» + «solo 317 checks (minimo 351)», 2 fallos.
- Regresiones medidas tras la tanda: M22 41/0 · M71 83/0 · M59 rotate 43/0 (9 bloques) +
  backup_rotate_return 4/0 + backup_rotations 7/0 · M55 diario 0 fallos + persistencia 0
  fallos. Todas EXIT 0, 0 SCRIPT ERROR.
- Flip con cita: «Crear 5 cadenas secretas ocultas» (L56) [ ] -> [x]. M23 = 63 [x] /
  40 [ ] / 2 [?] = 105 por prefijo de línea. Las DOS líneas de totales sincronizadas.
  El ítem «Documentar historias estacionales y secretas» (L58) sigue [ ] (compuesto:
  las estacionales son de M32, 0 en disco).
- Hallazgo (dueno M55): el puente M23->M55 degrada en silencio para las 5 nuevas
  (`mision_cadena-*` ausentes del catálogo M55; `capitulo-*` también). No se inventa
  contenido de M55.

## 9. Iter. 12 — historias de comerciantes (Log 2135, 2026-10-22)

- 3 cadenas nuevas en `data/historias/secundarias.json` (37 -> 40) del cluster
  Comerciantes del 03-Diseno L36: ruta del mercader, cargamento de telas y secreto
  del yunque. NPC REALES de data/villagers/ (mercedes_lince **mercader** — el rol
  real del dato en disco —, olivia_nutria sastra, ramon_tejon herrero) y objetos
  REALES de data/items/ (OBJ-ITE-052 «Moneda de oro», OBJ-ITE-010 «Tela»,
  OBJ-TAL-002 «Yunque»), verificados por campo id dentro del .tres. Integración
  con M37 excluida por orden del director (msg 181). Las 3 nacen visibles
  (`oculta:false`): rutas de trueque que se descubren hablando, a diferencia de
  las secretas del bloque P. Verificación de colisiones antes de escribir:
  ids/consecuencias/diarios/refs/lugares = 0 sobre las 37 previas.
- Suite: bloque Q (28 checks) al FINAL de `_run()`; piso 351 -> **379 checks /
  0 fallos / EXIT 0 x3** con el binario real. Guardián EN ROJO por inyección de
  runtime sobre el bloque Q: EXIT 1, «el bloque Q NO se ejecuto» + «solo 352
  checks (minimo 379)», 2 fallos; sonda borrada y sha256 restaurado byte-exacto.
- Regresiones medidas tras la tanda: M22 `test_historia.gd` 41/0 · M71 83/0 ·
  M59 rotate 43/0 (9 bloques) + backup_rotate_return 4/0 + backup_rotations 7/0 ·
  M55 diario 0 fallos + persistencia 0 fallos. Todas EXIT 0, 0 SCRIPT ERROR.
- Flips con cita: «Crear las historias de 3 comerciantes» (L47) y «Documentar
  historias de familias y comerciantes» (L48, compuesta: §Iter. 9 + §Iter. 12)
  [ ] -> [x]. M23 = 65 [x] / 38 [ ] / 2 [?] = 105 por prefijo de línea. Las DOS
  líneas de totales sincronizadas. «Integrar con M37 (comerciantes)» (L152) sigue
  [ ] con su dueño externo.
- Hallazgo (dueno M55): el puente M23->M55 degrada en silencio para las 3 nuevas
  (`mision_cadena-*` ausentes del catálogo M55; `capitulo-*` también). No se
  inventa contenido de M55.
- Reparación de deriva documental de la iter. 11: la sec. 5 de este documento y el
  veredicto seguían en 32 cadenas / 316 checks / DIEZ rojos; sincronizados a
  40 (41 vivo) / 379 / DOCE con las notas de puente de iters. 11 y 12.

## 10. Iter. 13 — clusters Puzzles e Investigación (Log 2137, 2026-10-22)

Tanda consolidada por orden del director (msg 183): clusters Puzzles (6, 03-Diseno
L46: templos 24/25/26 + ruinas del barrizal/manantial/acantilado) e Investigación
(5, L45: faro, biblioteca, geodesia, mapas + cartas estelares como extensión
declarada del núcleo). 11 cadenas nuevas en `data/historias/secundarias.json`
(40 -> 51; 52 con la de ejemplos en carga).

- Investigación (5): `cadena-registro-del-faro` (vera_ardilla farera +
  OBJ-LUZ-012 «Linterna», puzzle alturas-de-la-luz, lugar faro),
  `cadena-catalogo-perdido` (sofia_buho bibliotecaria + OBJ-EST-006 «Vitrina»,
  signos-en-los-margenes, biblioteca), `cadena-mediciones-de-la-isla`
  (pablo_pato ceramista + OBJ-REL-002 «Reloj de péndulo», sombras-del-mediodia,
  observatorio), `cadena-mapa-de-las-plantas` (teo_conejo herbolario +
  OBJ-HER-015 «Lupa», tinta-de-hojas, jardines) y `cadena-cartas-estelares`
  (sofia_buho + OBJ-LUZ-008 «Lámpara de cristal», reloj-de-estrellas,
  observatorio).
- Puzzles (6): `cadena-templo-de-las-24-marcas` (pablo_pato + OBJ-TAL-004 «Rueda
  de alfarero», sellos-de-arcilla, templo_24), `cadena-templo-de-los-25-engranajes`
  (bruno_sapo carpintero + OBJ-HER-018 «Sierra», mecanismo-escondido, templo_25),
  `cadena-templo-de-las-26-mareas` (luna_zorra artesana + OBJ-PLA-004 «Orquídea»,
  tintes-del-templo, templo_26), `cadena-ruinas-del-barrizal` (catalina_oso
  cocinera + OBJ-ITE-021 «Pan», ofrenda-de-la-ruina, barrizal),
  `cadena-ruinas-del-manantial` (teo_conejo + OBJ-NAT-024 «seta»,
  raices-en-la-piedra, manantial) y `cadena-ruinas-del-acantilado`
  (vera_ardilla + OBJ-LUZ-004 «Veladora», eco-de-las-ruinas, acantilado).
- NPC REALES de `data/villagers/` (7, cada uno con su rol en disco) y objetos
  REALES de `data/items/` por campo id dentro del .tres (11, ninguno reutilizado
  de cadenas previas). Las 11 nacen visibles (`oculta:false`). Colisiones
  verificadas ANTES de escribir: ids/consecuencias/diarios/refs de puzzle = 0
  sobre las 40 previas; lugares = 4 nuevos (templo_24/25/26, biblioteca) + 6
  reutilizados por diseño (faro, jardines, observatorio, barrizal, manantial,
  acantilado). Consecuencias peladas únicas 51/51 en disco (52/52 sobre la carga);
  11 capítulos de diario únicos. JSON: +396/-0, puramente aditivo.
- Suite: bloque R `_test_puzzles_investigacion()` (77 checks) al FINAL de
  `_run()`; BLOQUES A-R; conteos de A/I actualizados (41 -> 52 cargadas,
  principal 40 -> 51). Piso 379 -> **456 checks / 0 fallos / EXIT 0 x3** con el
  binario real, 0 SCRIPT ERROR. Endurecimiento: la unicidad de flags pasó a
  medirse sobre la carga REAL (52 consecuencias sobre 52 cadenas) en lugar de una
  lista transcrita a mano, que podía omitir un flag y dar un falso verde.
- Guardián EN ROJO por inyección de runtime (`Node` null -> `free()`) al inicio
  del bloque R: EXIT 1, «el bloque R NO se ejecuto (posible SCRIPT ERROR que
  aborto la funcion)» + «solo 380 checks ejecutados (minimo 456)»; sonda borrada
  en la misma operación, sha256 restaurado byte-exacto. Re-ejecutada en el cierre
  de la tanda (corrida original interrumpida por el límite de frecuencia de la
  API): mismo resultado.
- Regresiones medidas tras la tanda: M55 `test_diario.gd` 0 fallos +
  `test_diario_persist.gd` 0 fallos · M59 `test_autosave_m59.gd` 0 fallos · M71
  `test_bug_reevaluar_m71_hy3.gd` 8/2 (los 2 fallos son la reproducción del
  BUG-143 conocida, previa a la tanda). `validate_quest_chains.gd` no se pudo
  medir: cuelga en modo `--script` headless (SceneTree sin `quit()`, condición
  previa ajena a la tanda).
- Flips con cita: L85 (crear 5 misiones de investigación), L87 (documentar
  amistad e investigación, compuesta: §Iter. 10 + §Iter. 13), L91 (crear 6
  misiones de puzzles) y L93 (documentar misiones de puzzles) [ ] -> [x]. M23 =
  **69 [x] / 34 [ ] / 2 [?] = 105** por prefijo de línea; las DOS líneas de
  totales sincronizadas.
- Hallazgo (dueño M55): el puente M23->M55 degrada en silencio para las 11 nuevas
  (`mision_cadena-*` y `capitulo-*` ausentes del catálogo M55). No se inventa
  contenido de M55.

## 10. Iter. 14 — consecuencias con respaldo + sincronización de cola (Log 2163, 2026-10-23)

- Bloque S `_test_consecuencias()` nuevo (21 checks) al final de `_run()`.
  Suite: **477 checks / 0 fallos / EXIT 0 x2** (binario real
  `Godot_v4.7.2-stable_win64_console.exe --headless`, 0 SCRIPT ERROR).
- **Corrida 1 EN ROJO (3 fallos, EXIT 1) y fue instructiva**, no un accidente:
  - checks 1 y 2 fallaron con 8/4 en lugar de 7/5: la medición de cobertura
    previa (hecha por herramienta externa sobre `secundarias.json` solamente)
    ignoraba el catálogo de ejemplos, donde `cadena-biblioteca` aplica
    `biblioteca_iluminada`. El universo correcto son los DOS catálogos.
  - el negativo de `taller_abierto` falló con 1 hit:
    `res://scripts/historias/test_historias.gd` — el guardián se auto-pisaba
    porque su propio archivo nombra el token en la lista de las 12.
  Corregido el universo y acotado el negativo a `res://data`; corrida 2 en
  VERDE (477/0).
- Guardián EN ROJO por inyección de runtime: `var _v: Variant =
  get_node_or_null("WorldState")` -> `var _sonda: Dictionary = _v` al inicio del
  bloque S. EXIT 1 con «el bloque S NO se ejecuto (posible SCRIPT ERROR que
  aborto la funcion)» + «solo 457 checks ejecutados (minimo 477)» (2 fallos).
  Primera versión de la sonda: asignación directa `Node` -> `Dictionary` =
  error de PARSE (el archivo no compilaba: falso rojo que no prueba nada); la
  inyección válida pasa por un `Variant` intermedio. Sonda borrada, 0 archivos
  `*sonda*` en `scripts/historias/`.
- Regresiones: la tanda no cambia código de producción (0 archivos .gd de
  producción editados), solo el archivo de test y documentación. Suite propia
  477/0 x2.
- Flips con cita: L108 («jardín florecido») y L111 («cofradía activa») [ ] ->
  [x], respaldo = flag aplicado por cadena-jardines / cadena-cofradia a
  WorldState (M21) vía `secondary_stories_service.gd` L232-236, verificado
  end-to-end en el bloque S. L109 («taller abierto») queda [ ] con la medición
  del vacío (0 cadenas + 0 hits del token en res://data) y la guarda del bloque.
  M23 = **71 [x] / 32 [ ] / 2 [?] = 105**; las dos líneas de totales
  sincronizadas (L170 arrastraba 63/40/2 de la iter. 11).
- Sincronización de la COLA ACTIVA del BACKLOG-MASTER: 2 ítems que ya estaban
  [x] en el módulo desde la iter. 12 (comerciantes; documentar familias y
  comerciantes) marcados [x] en la cola con cita.

## Iter. 15 (Log 2166) — cluster Exploración: 8 cadenas, bloque T, 543 checks

**Contexto de cierre (2026-10-24):** la tanda fue ejecutada por una corrida
previa que quedó cortada antes de cerrar (el CRON preservó el avance parcial en
8225b5b: JSON 51 -> 59 cadenas, bloque T en la suite, 2 flips en el 05). Esta
vuelta NO rehizo la tanda: la re-verificó íntegra (un verde no se hereda) y
reparó los entregables (Log 2166 ocupando el número consumido por la corrida
cortada; cita 2164 -> 2166 en 04-Codigo; esta sección; registro en 06 y
BACKLOG).

- Suite `res://scripts/historias/test_historias.gd` (binario real):
  **543 checks / 0 fallos / EXIT 0 x3**, 0 SCRIPT ERROR en las 3 corridas.
  Piso 477 -> 543 MEDIDO en verde. Bloque T `_test_exploracion()` (66 checks)
  al FINAL de `_run()`.
- Guardián EN ROJO por inyección de runtime sobre el bloque T (medido en el
  cierre): `var _v: Variant = [1, 2, 3]` -> `var _boom: Dictionary = _v` al
  inicio de `_test_exploracion()`. **EXIT 1, 478 checks, 2 fallos**: «[FAIL] el
  bloque T NO se ejecuto (posible SCRIPT ERROR que aborto la funcion)» +
  «[FAIL] solo 478 checks ejecutados (minimo 543)». Sonda borrada en la misma
  invocación, `git status scripts/historias/` vacío, suite intacta por sha256
  (bec8fcae...).
- Verificación independiente de realidad: 8 NPC contra `data/villagers/` por
  campo `id` (14 en disco) y 8 objetos contra `data/items/` por campo `id`
  (300 en disco): **16/16 REALES** (finneas_zorro/OBJ-HER-016,
  teo_conejo/OBJ-NAT-027, sofia_buho/OBJ-REL-004, aria_ciervo/OBJ-LUZ-015,
  catalina_oso/OBJ-LUZ-013, olivia_nutria/OBJ-ITE-009, nico_gato/OBJ-HER-004,
  ramon_tejon/OBJ-ITE-013). 0 consecuencias duplicadas sobre las 59 cadenas.
- Regresiones (binario real): M59 rotate 43/0 (9 bloques) +
  backup_rotate_return 4/0 + backup_rotations 7/0; M71 flujo XP 37/0; M55
  diario perf 26/0 + persistencia 0 fallos. M71 `test_bug_reevaluar_m71_hy3`
  8 checks / 2 fallos / EXIT 1 = **BUG-143 preexistente** ([ ] Abierto en
  11-BUGS.md L265, dueño M71): no es regresión de esta tanda (no toca código
  de producción de M71).
- Flips con cita: L64 («Crear 8 misiones de exploración») y L65 («Documentar
  cadenas y misiones de exploración») [ ] -> [x]. M23 = **73 [x] / 30 [ ] /
  2 [?] = 105** (prefijo de línea); las dos líneas de totales sincronizadas.
  DRIFT reportado al director: fila 23 del GLOBAL en 71/105 (sync de la
  iter. 14) vs 73/105 en disco.
- Hallazgo (dueño M55, no tocado): el puente M23 -> M55 degrada en silencio
  para las 8 nuevas (0 entradas `mision_cadena-*` en el catálogo de M55);
  mismo residual de las iteraciones 3/6-14, verificado por el check del puente
  en el bloque T.

## Iter. 16 (Log 2169) — cluster Construcción: 3 cadenas nuevas re-verificadas, bloque U, 580 checks

- **Estado de entrada medido:** `secundarias.json` con 62 cadenas (3 de
  construcción nuevas, mtime 04:04:54, sin log ni mensaje — corrida cortada;
  barridas por el CRON en f6a07c6). Con el dato nuevo la suite quedó **ROJA:
  6 fallos / 543 checks / EXIT 1** (medido 05:13 con el binario real): los 6
  eran asserts de conteo que esperaban 59/60 (carga 60, principal crudo 59,
  runtime 60, unicidad global 60, cobertura de las 12 consecuencias 8/4).
- **Reparación + verificación:** los 6 asserts reparados (62/63, 9/3) y bloque
  U `_test_construccion()` NUEVO. Suite **580 checks / 0 fallos / EXIT 0 x3**,
  0 SCRIPT ERROR. Piso 543 -> **580 MEDIDO en verde**.
- **Guardián EN ROJO:** inyección de runtime `Variant` -> `Dictionary` sobre un
  entero al inicio del bloque U: **EXIT 1, 544 checks, 2 fallos** («el bloque U
  NO se ejecuto (posible SCRIPT ERROR que aborto la funcion)» + «solo 544
  checks ejecutados (minimo 580)»). Sonda borrada en la misma invocación y
  suite restaurada byte-exacta (LF puro, sin BOM).
- **Verificación independiente de realidad:** 3 NPC contra `data/villagers/`
  (bruno_sapo, nico_gato, pablo_pato) y 3 objetos contra `data/items/` por
  campo `id` (OBJ-ITE-002 "Piedra", gravel "Grava", OBJ-ITE-001 "Madera"):
  **6/6 REALES**. 0 consecuencias duplicadas sobre las 63 cadenas cargadas.
- **Corrección de cobertura (03-Diseno L53):** las 12 consecuencias pasan de
  8 con respaldo / 4 sin respaldo a **9 / 3**: `kiosko_abierto` ahora lo aplica
  `cadena-construccion-kiosko`. Sin respaldo quedan `taller_abierto` (guarda
  del ítem L109), `camino_al_faro_despejado` y `puerto_ampliado`.
- **Regresiones (binario real):** M59 backup_rotations 7/0 +
  backup_rotate_return 4/0 + slots/perfiles 41/0 + carga NPC/misiones 63/0;
  M71 flujo XP 37/0; M55 diario perf 26/0 + persistencia 0 fallos.
- **Flips con cita:** L69 («Crear 6 misiones de construcción: puentes,
  cofradía, plaza, senderos, kiosko, jardín») [ ] -> [x] con los 6 temas
  respaldados por cadena en disco. M23 = **74 [x] / 29 [ ] / 2 [?] = 105**
  (prefijo de línea); las dos líneas de totales sincronizadas. L70 sigue [ ]
  con dueño M28 y L73 (compuesta con agricultura) no se flippa por la mitad.
- **Hallazgo (dueño M55, no tocado):** el puente M23 -> M55 degrada en silencio
  para las 3 nuevas (0 entradas `mision_cadena-*`); mismo residual de las
  iteraciones 3/6-15, verificado por el check del puente en el bloque U.


## Iter. 17 — Agricultura (Log 2172, 2026-10-24, Step-5-WorkBuddy)

- **Suite `test_historias.gd` (bloque V `_test_agricultura()` NUEVO, +44
  checks):** **624 checks / 0 fallos / EXIT 0 x3**, 0 SCRIPT ERROR (binario
  real, 3 corridas headless). Piso 580 -> **624 MEDIDO en verde**.
- **Guardián EN ROJO por inyección de runtime** al inicio del bloque V
  (subscript dinamico `get_cadena(...)["titulo"]` -> `Dictionary`):
  **EXIT 1, 581 checks, 2 fallos** («el bloque V NO se ejecuto (posible
  SCRIPT ERROR que aborto la funcion)» + «solo 581 checks ejecutados
  (minimo 624)»). Sonda borrada y suite restaurada byte-exacta
  (sha256 e385a9646f2dce939d7895d2631a36de35a879fc81f05d9fb57dbbbafb140119).
  NOTA de método: la 1a version de la sonda (literal String -> Dictionary)
  fue **PARSE ERROR estatico** — el script no compila y muere entero, no
  aborta una funcion: no prueba el guardian. Rehecha con valor dinamico.
- **Dato verificado en disco:** `secundarias.json` 62 -> 67 cadenas (+75/-0
  aditivo); 5/5 NPC REALES (`data/villagers/*.tres`) y 5/5 objetos REALES
  (`data/items/*.tres` por campo id); 0 colisiones de id/consecuencia/
  capitulo con las 62 previas; 68 consecuencias globales distintas.
- **Regresiones (binario real):** M59 carga idempotente 28/0, autosave 0
  fallos, fecha/diario/cola 45/0; M71 flujo XP 37/0; M55 diario perf 26/0.
- **Flips con cita:** L71 (crear 5 misiones de agricultura) y L73
  (documentar construccion + agricultura) [ ] -> [x]. M23 = **76 [x] /
  27 [ ] / 2 [?] = 105** (prefijo de linea); linea de totales sincronizada.
- **Hallazgo ajeno (reportado, no tocado):** el id de objeto
  `semilla_antigua`, usado por cadenas previas de los clusters
  Investigacion/Secretas, **no existe** en `data/items/` (0 coincidencias
  por campo id): cita de item sin respaldo en disco (misma familia que
  `molino_funcionado` de la iter. 8). Mis 5 objetos fueron verificados
  reales antes de escribir las cadenas.

## Iter. 18 — Pesca (4) + Colección (6) (Log 2173, 2026-10-24, Step-5-WorkBuddy)

- **Cierre de tanda ejecutada por corrida cortada** (familia It. 10/15/17): el
  dato y la suite ya estaban en disco (`secundarias.json` 67 -> 77 cadenas,
  bloque W en la suite, flips L77/L78/L80 del 05). Esta corrida RE-VERIFICO
  integra (un verde no se hereda) y reparo los entregables de cierre: esta
  seccion, el espejo de la COLA ACTIVA del BACKLOG-MASTER (items 152/153/155),
  la cabecera del 05 (iter. 17 y 18 faltaban) y el msg 213 a la directora.
- **Suite `test_historias.gd` (bloque W `_test_pesca_coleccion()`):**
  **691 checks / 0 fallos / EXIT 0 x3**, 0 SCRIPT ERROR (binario real,
  re-corrida hoy, no heredada). Piso **691 MEDIDO en verde**.
- **Guardián EN ROJO por inyeccion de RUNTIME sobre el bloque W**
  (re-ejecutado HOY por este agente, no heredado): subscript dinamico
  `get_cadena("cadena-pesca-trofeos")["oculta"]` -> Variant -> llamada a
  metodo inexistente: EXIT 1, «el bloque W NO se ejecuto (posible SCRIPT
  ERROR que aborto la funcion)» + «solo 625 checks ejecutados (minimo 691)»,
  2 fallos. Sonda borrada y suite restaurada byte-exacta (sha256
  baa223ed684c852126b98e5c9add9c55006d50a66389f4d5cf0c23f002924c7d,
  verificado identico al previo).
- **Dato verificado en disco (independiente):** 77 cadenas totales; las 10
  nuevas con **10/10 NPC REALES** (`data/villagers/*.tres`, 14 medidos:
  finneas_zorro, sofia_buho x2, teo_conejo x2, luna_zorra, olivia_nutria,
  ramon_tejon) y **10/10 objetos REALES** (`data/items/*.tres` por campo id,
  300 medidos: OBJ-HER-011, OBJ-ART-002, OBJ-HER-010, OBJ-LUZ-012, OBJ-CUA-010,
  OBJ-ART-001, OBJ-ART-005, mineral_cobre, OBJ-ITE-023, OBJ-PLA-004);
  77/77 consecuencias, 76/76 capitulos y 77/77 titulos unicos (la colision de
  titulo de `cadena-coleccion-sellos` con `cadena-cofradia` de iter. 6 la
  detecto y corrigio la corrida original: «Los Sellos de los Oficios»).
- **Regresiones (binario real, medidas HOY):** M59 carga idempotente 28/0,
  slots/perfiles 41/0, carga NPC/misiones 63/0, fecha/diario/cola 45/0;
  M71 test_progresion 83/0; M55 diario perf 26/0 + persistencia 0 fallos.
- **Flips con cita:** L77 «Crear 4 misiones de pesca», L78 «Crear 6 misiones
  de coleccion` y L80 «Documentar misiones de pesca y coleccion` `[ ]` ->
  `[x]`. M23 = **79 [x] / 24 [ ] / 2 [?] = 105** (prefijo de linea; Totales
  sincronizado). Ofrecidos a revertir.
- **Trampa propia de la re-verificacion:** mi 1er extractor de realidad leyo
  campos inexistentes (`npc`/`objeto` en la raiz de la cadena) y publico 10
  FALTA falsas; el schema real los lleva en `pasos` (misma familia que el
  extractor de la iter. 15). Corregido antes de publicar.
## Iter. 19 — Postgame (Log 2176, 2026-10-24, Step-5-WorkBuddy)

- **Alcance:** L129/L132/L133/L134 del 05-Checklist; 3 cadenas nuevas
  (`data/historias/secundarias.json` 77 -> 80; +45/-0 contra HEAD, aditivo,
  formato preservado). Las 3 nacen `postgame:true`; `cadena-epilogo-guardian`
  además `oculta:true` (final secreto). Con `cadena-epilogo-plaza` previa
  quedan las 4 de postgame del 03-Diseno L47.
- **Suite:** bloque X `_test_postgame_cluster()` (+50 checks).
  **742 checks / 0 fallos / EXIT 0 x3**, 0 SCRIPT ERROR (binario real).
  Piso **742 MEDIDO en verde** (691 -> 742).
- **Guardián EN ROJO por inyección de RUNTIME sobre el bloque X**: subscript
  dinámico `get_cadena("cadena-memorial-sello")["oculta"]` -> Variant bool ->
  llamada a método inexistente: EXIT 1, «el bloque X NO se ejecuto (posible
  SCRIPT ERROR que aborto la funcion)» + «solo 692 checks ejecutados (minimo
  742)», 2 fallos. Sonda borrada y suite restaurada byte-exacta (sha256
  441778340f742b9f3c16e42880c62c33aa9001efdff17fe8b5866cdb5fb391ec).
- **Fallo propio de la 1a corrida (corregido):** el gate de disponibles se
  midió con el estado que dejaba el bloque F (final «secreto» ya elegido) ->
  2 de las 3 expuestas y 1 fallo. Reescrito con limpieza previa del estado.
- **Dato verificado en disco (independiente):** 80 cadenas totales; las 3
  nuevas con **NPC REALES** (`data/villagers/*.tres`, profesión medida:
  ramon_tejon herrero, aria_ciervo trovadora, pablo_pato ceramista,
  catalina_oso cocinera, nico_gato guardabosques) y **objetos REALES**
  (`data/items/*.tres` por campo id, 300 medidos: piedra_caliza, clay,
  fragmento_ancestral); 0 colisiones de id/flag/capitulo con las 77 previas.
- **Regresiones (binario real):** M59 slots/perfiles 41/0, carga idempotente
  28/0, carga NPC/misiones 63/0, fecha/diario/cola 45/0; M71 test_progresion
  83/0; M55 diario perf 26/0 + persistencia 0 fallos.
- **Flips con cita:** L129, L132, L133 y L134 `[ ]` -> `[x]`. M23 = **83 [x] /
  20 [ ] / 2 [?] = 105** (prefijo de línea; Totales sincronizado). Ofrecidos
  a revertir.

## Iter. 22 — L159 «Diseñar test E2E de 10 cadenas completas» (2026-10-25, DeepSeek-V4.1-Flash, Log 2196)

- **Alcance:** L159 del 05-Checklist. Hasta ahora los bloques H-Y corrían 2-3
  cadenas end-to-end por cluster (J=2, K=3, L=4, M=6, N=2, O=6, P=2, Q=2,
  T=3, U=2, V=2, W=2, X=2); ninguna corrida cubría DIEZ cadenas completas.
- **Entregado:** bloque Z `_test_e2e_diez()` en `scripts/historias/test_historias.gd`
  (+119 checks) con driver GENÉRICO: la evidencia de cada paso se lee del DATO
  declarado (`npc`/`lugar`/`ref`/`objeto`), no de una lista paralela escrita a
  mano. Por cadena: visibilidad previa → iniciar → pasos en el orden declarado
  → completada → no activa → consecuencias en M21 → sale de `cadenas_disponibles`
  → no se re-inicia → capítulo declarado → puente de diario contra el catálogo
  M55 leído en disco.
- **Muestra (10, una por cluster):** `cadena-faro` (principal),
  `cadena-biblioteca` (merge de ejemplos), `cadena-panadera` (vecinos),
  `cadena-jardines` (lugares), `cadena-molinera` (familias),
  `cadena-regalo-favorito` (amistad), `cadena-mapa-secreto` (secretas, oculta),
  `cadena-ruta-del-mercader` (comerciantes), `cadena-templo-de-las-24-marcas`
  (puzzles), `cadena-pesca-nocturna` (pesca/colección).
- **Suite:** **869 checks / 0 fallos / EXIT 0 x3**, 0 SCRIPT ERROR (binario
  real 4.7.2). Piso **869 MEDIDO en verde** (750 → 869). Total de pasos
  ejercitados: **39** (9 cadenas de 4 pasos + la mergeada de 3).
- **Guardián EN ROJO, dos modos, sobre el bloque Z:** (a) aborto por error de
  RUNTIME con subscript dinámico (`sonda_z[3]`) → `SCRIPT ERROR` +
  «[FAIL] el bloque Z NO se ejecuto» + 751 checks / 1 fallo / EXIT 1;
  (b) aserción falsa sobre la excepción medida → 869 checks / 1 fallo / EXIT 1.
  Archivo restaurado **byte-exacto** tras cada sonda (sha256 `6637c114…`, estado previo al ajuste del piso; el archivo FINAL con el piso 869 es `d2fbb906…`).
- **Anti-falso-verde aplicado:** los 10 flags de consecuencia se **apagan antes**
  de correr, así el check prueba que la cadena los aplicó y no que ya venían
  puestos de un bloque previo (varios sí venían: `jardin_florecido`,
  `biblioteca_iluminada`, `banco_plaza_reparado`).
- **Hallazgo medido (dato de M23, NO corregido sin orden):**
  `data/historias/cadenas_ejemplo.json` → `cadena-biblioteca` declara
  `recompensa.diario = "capitulo-biblioteca"`, **fuera** del esquema
  `mision_<cadena_id>` que la iter. 21 normalizó en `secundarias.json`
  (79 valores). No es regresión de esa tanda: el archivo de ejemplos quedó
  fuera de su alcance. Consecuencia práctica: la entrada tampoco existe en el
  catálogo de M55 (`data/diario/diario_catalog.json`), así que degrada en
  silencio igual que las otras 77. Queda **fijado con guarda** en el bloque Z
  (el check falla si el dato cambia en silencio). Renombrarlo es decisión del
  director.
- **Flips:** L159 `[ ]` → `[x]` **PROPUESTO con cita** (no aplicado: los aplica
  el director). Conteo del checklist **sin cambios**: 86 [x] / 17 [ ] / 2 [?] = 105.
- **Regresiones:** suite M23 869/0/EXIT 0 x3; M33 farm 6 suites
  29/20/42/27/39/35 = **192 checks / 0 fallos / EXIT 0** (verificación del
  revert, orden 1 del msg 406).
