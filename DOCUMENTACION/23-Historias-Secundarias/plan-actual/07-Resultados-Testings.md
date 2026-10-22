# 07 — Resultados de Testings — M23: Historias Secundarias

**Modelo:** Step-5-WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-21 a 2026-10-22 (iter. 2, Log 2082; iter. 3, Log 2083; iter. 4, Log 2085; iter. 5, Log 2107; iter. 6, Log 2117)

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

## 5. Estado del catálogo (medido, no estimado)

- `data/historias/secundarias.json`: **13 cadenas** (faro, invernadero, epilogo-plaza,
  secretta-luciernagas, panadera, carpintero, tejedora, pescador, guarda, alquimista,
  jardines, cofradia, molino) de las ~89 slots del catálogo de 03-Diseno. Creció
  4 -> 10 (iter. 5, vecinos) -> 13 (iter. 6, lugares). `cadena-biblioteca` vive en el
  fichero de ejemplos (merge por id).
- `data/historias/cadenas_ejemplo.json` (3 cadenas: faro, biblioteca, postgame-plaza):
  **INTEGRADO** en la iter. 3 (Log 2083) vía `RUTA_CATALOGO_EJEMPLOS` con merge por id
  (GO del director, msg 151). Resultado medido: +1 añadida (`cadena-biblioteca`),
  1 conflicto (`cadena-faro`, gana la variante del principal), 1 rechazada
  (`cadena-postgame-plaza`, tipo de paso `"construir"` desconocido). Catálogo vivo: 5
  en iter. 3 -> **14** en iter. 6 (13 del principal + 1 de ejemplos).
- Capítulos `capitulo-*` en el catálogo M55 (`data/diario/diario_catalog.json`): **0**
  → las recompensas `diario` de las cadenas apuntan a entradas inexistentes (el
  registro efectivo es `mision_{cadena_id}`). MEDIDO iter. 3: existen
  `mision_cadena-faro` y `mision_cadena-invernadero`, NO `mision_cadena-biblioteca` →
  el puente M23→M55 degrada en silencio para la mergeada (contenido de M55).
  **Iter. 6**: el puente degrada IGUAL para las 3 cadenas nuevas —
  `not diary.esta_registrada("mision_cadena-jardines")` (idem cofradia/molino), y las
  recompensas apuntan a `capitulo-jardines` / `capitulo-cofradia` / `capitulo-molino`,
  ausentes del catálogo M55 (0 entradas `capitulo-*`). Reportado; dueño M55.
- Consecuencias aplicadas por cadenas del principal (13 únicas sobre 13 cadenas):
  `faro_encendido`, `invernadero_abierto`, `plaza_decorada`, `luciernagas_vueltas`,
  `pan_fiesta_horneado`, `banco_plaza_reparado`, `manto_niebla_terminado`,
  `red_pescador_reparada`, `sendero_bosque_senalizado`, `jarabe_lunar_listo`,
  `jardin_florecido`, `cofradia_activa`, `molino_funcionando`.
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
rojo SIETE veces (iter. 2; iter. 3; las dos de iter. 4 — aborto de runtime en el bloque
I y regresión de datos con prefijo re-inyectado; iter. 5 en el bloque J; iter. 6 en el
bloque K; todas EXIT 1 nombrando el bloque o la clave). Estado actual: suite en
**129 checks / 0 fallos / EXIT 0 x4**, catálogo vivo 14 cadenas, y regresiones
M22 (41/0) · M71 (83/0 y 37/0) · M59 (43/0 y 7/0) · M55 (0 fallos) medidas el
2026-10-22.
Pendientes = contenido narrativo y dueños externos (M22/M17/M24/M28/M32/M36/M37/M68),
documentados como `[ ]` honestos en `05-Checklist.md`. Decisiones abiertas para el
director: tipo de paso `"construir"` (rechazo PERSISTENTE por msg 153; dueños M22/M17),
entrada `mision_cadena-biblioteca` en M55, y la `condicion` prefijada del principal si
quiere extenderse el GO de normalización.
