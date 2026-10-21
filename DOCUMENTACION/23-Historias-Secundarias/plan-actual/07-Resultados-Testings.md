# 07 — Resultados de Testings — M23: Historias Secundarias

**Modelo:** Step-5-WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-21 (iter. 2, Log 2082; iter. 3, Log 2083)

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

## 5. Estado del catálogo (medido, no estimado)

- `data/historias/secundarias.json`: **4 cadenas** (faro, invernadero, epilogo-plaza,
  secretta-luciernagas) de las ~89 slots del catálogo de 03-Diseno.
- `data/historias/cadenas_ejemplo.json` (3 cadenas: faro, biblioteca, postgame-plaza):
  **INTEGRADO** en la iter. 3 (Log 2083) vía `RUTA_CATALOGO_EJEMPLOS` con merge por id
  (GO del director, msg 151). Resultado medido: +1 añadida (`cadena-biblioteca`),
  1 conflicto (`cadena-faro`, gana la variante del principal), 1 rechazada
  (`cadena-postgame-plaza`, tipo de paso `"construir"` desconocido). Catálogo vivo: 5.
- Capítulos `capitulo-*` en el catálogo M55 (`data/diario/diario_catalog.json`): **0**
  → las recompensas `diario` de las cadenas apuntan a entradas inexistentes (el
  registro efectivo es `mision_{cadena_id}`). MEDIDO iter. 3: existen
  `mision_cadena-faro` y `mision_cadena-invernadero`, NO `mision_cadena-biblioteca` →
  el puente M23→M55 degrada en silencio para la mergeada (contenido de M55).
- Consecuencias en disco: `faro_encendido`, `plaza_decorada`, `invernadero_abierto`,
  `luciernagas_vueltas` existen; `molino_funcionando` **no** (el `[x]` del checklist
  fue degradado a `[?]` por el director el 2026-10-21, msg 151);
  `jardin_florecido` / `taller_abierto` / `cofradia_activa` no existen.
- Diferencia de esquema medida: el archivo de ejemplos usa claves de consecuencia
  `estado_mundo.*` (la mergeada aplica `flag_estado_mundo.biblioteca_iluminada`)
  vs flags pelados del principal. Reportado; no normalizado sin orden.

## 6. Veredicto

Núcleo de M23 **verificado** con binario real y guarda anti-falso-verde demostrada en
rojo (dos inyecciones: iter. 2 y iter. 3). Iter. 3: catálogo de ejemplos integrado con
merge por id, validado y corrido end-to-end; pendientes = contenido narrativo y dueños
externos (M22/M24/M28/M32/M36/M37/M68), documentados como `[ ]` honestos en
`05-Checklist.md`. Decisiones abiertas para el director: tipo de paso `"construir"`,
entrada `mision_cadena-biblioteca` en M55, normalización de claves `estado_mundo.*`.
