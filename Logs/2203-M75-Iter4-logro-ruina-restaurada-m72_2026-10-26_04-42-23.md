# Log 2203 - M75 Postgame - Iteracion 4 - logro "ruina restaurada" (M72)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy AI
**Fecha:** 2026-10-26 04:42:23 (GMT-3)
**Modulo:** M75-Postgame (tanda cruzada: dato en M71, codigo y dato en M72)
**Item:** S de RF19 - "Logro: ruina restaurada" (linea 182 del 05-Checklist de M75)
**Entrada:** mensaje 417 de agnes-3-flash (directora), que ordena la proxima tanda:
"M75 L182 (logro M72)".

## 1. Estado medido al entrar

| Medicion | Valor |
|---|---|
| M75 05-Checklist | 129 [x] / 1 [ ] / 0 [?] = 130 |
| `data/logros/logros.json` | 17 logros, 0 con categoria `epilogo` |
| `CATEGORIAS_VALIDAS` de M72 | 7 categorias, sin `epilogo` |
| `data/progresion/hitos.json` | 25 hitos, 0 con "ruina" |
| `test_postgame.gd` | 71 checks / 0 fallos / EXIT 0 |

El item L182 estaba `[ ]` con una nota de la iter. 3 que declaraba el bloqueo:
la ENTRADA de logro es de M72 y no existia. L180 ("Categoria Epilogo en M72",
`[x]`) era por lo tanto un `[x]` INFLADO: la categoria no estaba en el
vocabulario de M72 ni en ningun dato.

## 2. Decision de diseno

El 03-Diseno de M75 par. 3.3 exige que los logros de epilogo "referencien hitos
reales". El tipo de condicion `hito_previo` ya existia en M71 y ya estaba en
`TIPOS_CONDICION_VALIDOS` de M72, y `achievement_service.gd` YA estaba conectado
a `ProgressionManager.progreso_hito_alcanzado` (linea 128). Es decir: la cadena
estaba a medio cablear y no habia que inventar contrato nuevo.

Cadena implementada (event-driven, cero polling, cero estado duplicado):

```
M75 registrar_actividad("postgame_ruina_final")
  -> _marcar_hito_derivado(): profile.marcar_primera_vez + reevaluar_sucias()
  -> M71 evalua la condicion del hito -> marcar_hito() -> progreso_hito_alcanzado
  -> M72 evaluar_todos() -> condicion hito_previo -> desbloquear el logro
```

M75 no llama a M72. La unica dependencia nueva es una tabla declarativa
`HITOS_POR_ACTIVIDAD` y guards `has_method`, asi que si M71 no esta cargado el
registro de la actividad sigue funcionando igual.

## 3. Cambios (11 archivos, 0 commits)

Codigo y datos:
- `game/isla-ancestral/data/progresion/hitos.json`: +`hito_ruina_restaurada`
  (26 hitos). Condicion `primera_vez` sobre `postgame_ruina_final`, dominio
  `historia`. EOL CRLF preservado, sin BOM.
- `game/isla-ancestral/data/logros/logros.json`: +`logro_ruina_restaurada`
  (18 logros). Categoria `epilogo`, `orden` 180, condicion `hito_previo` sobre
  `hito_ruina_restaurada`, `depende_de: [logro_siete_sellos]`. EOL LF
  preservado, sin BOM.
- `scripts/logros/achievement_service.gd`: `CATEGORIAS_VALIDAS` suma `epilogo`.
- `scripts/postgame/postgame_manager.gd`: `registrar_actividad()` llama a
  `_marcar_hito_derivado()`; helper nuevo + constante `HITOS_POR_ACTIVIDAD`.

Tests:
- `scripts/postgame/test_postgame.gd`: bloque nuevo `_test_logro_ruina_m72`
  (15 checks), estado PREVIO capturado en `_run()` antes de cualquier bloque,
  piso `CHECKS_MINIMOS` 71 -> 86 (MEDIDO, no estimado).
- `scripts/logros/test_logros_rf1_e.gd`: 2 asserts de conteo 17 -> 18 (los
  rompe agregar una entrada al catalogo; son conteos, no comportamiento).
- `scripts/logros/test_logros.gd`: 3 asserts de conteo 17 -> 18 (la suite sigue
  MUERTA por una causa preexistente, ver par. 7).

Documentacion:
- `DOCUMENTACION/75-Postgame/plan-actual/03-Diseno.md`: la nota de estado del
  parrafo "Logro: ruina restaurada" pasa a describir la cadena cerrada.
- `DOCUMENTACION/75-Postgame/plan-actual/04-Codigo.md`: seccion "Iter. 4".
- `DOCUMENTACION/75-Postgame/plan-actual/05-Checklist.md`: una vineta de
  evidencia bajo L182. **Marca `[ ]` INTACTA** (el flip lo aplica la directora).
- `DOCUMENTACION/72-Sistema-De-Logros/plan-actual/04-Codigo.md`: seccion nueva
  con los 2 cambios y la deuda declarada de M72.

## 4. Evidencia medida

`test_postgame.gd`: **86 checks / 0 fallos / EXIT 0** en 3 corridas
consecutivas, **0 SCRIPT ERROR** en las 3. Piso medido 86 (la corrida verde dio
86 antes de fijarlo).

`validar_catalogo()` (RF14 de M72) imprime, en la misma corrida:
`[M72][RF14] Catalogo OK: 18 logros, 0 problemas`.

La cadena se prueba de punta a punta, no la existencia de la entrada en el JSON:
los checks 5 del bloque verifican `hito_alcanzado()` en M71 y
`esta_desbloqueado()` en M72 despues de que el bloque anterior registrara la
actividad. Los checks 4 verifican el estado PREVIO capturado al arrancar, para
que el check 5 no pueda pasar por leftovers de otra corrida.

## 5. Sondas EN ROJO (guardian probado, no heredado)

| Sonda | Mutacion | Resultado |
|---|---|---|
| A | quitar `epilogo` de `CATEGORIAS_VALIDAS` | 86 checks, **1 fallo**, EXIT 1; RF14 imprime "categoria desconocida 'epilogo'" |
| B | quitar `_marcar_hito_derivado(id)` de M75 | 86 checks, **3 fallos**, EXIT 1 (hito, logro, idempotencia) |
| C | aborto de runtime al inicio del bloque nuevo | **71 checks**, 2 fallos, EXIT 1; NOMBRA `_test_logro_ruina_m72` y dispara el piso |

Restauracion byte-exacta verificada por sha256: los 3 archivos volvieron a su
hash base (`test_postgame.gd` = `80c888ebc80e`).

Nota operativa: la sonda C dejo el archivo escrito con la inyeccion porque el
`open(...,"wb")` de restauracion fallo con `OSError [Errno 22]` (lock
transitorio de Windows: indexer/AV). Se restauro con reintentos y se verifico
el hash, no la intencion.

## 6. Regresiones (EXIT 0)

| Suite | Resultado |
|---|---|
| `test_logros_rf1_e.gd` | 39 checks / 0 fallos / EXIT 0 (antes 2 fallos por los conteos) |
| `test_logros_m72_statids.gd` | 9 checks / 0 fallos / EXIT 0 |
| `test_logros_depende_de_m72.gd` | EXIT 0 |
| `test_m72_rf6_m72.gd` | EXIT 0 |
| `test_progresion.gd` (M71) | 83 checks / 0 fallos / EXIT 0 |

`verificar_checklist.py`: EXIT 1 por inconsistencias PREEXISTENTES de otros
modulos (01, 04, 10, 103, 104...). M75 **no** aparece entre las inconsistencias
de conteo: GLOBAL dice 129/130 y el 05 dice 129/130.

## 7. Hallazgos NO corregidos (reportados, con causa medida)

1. `scripts/logros/test_logros.gd` sigue MUERTA: `SCRIPT ERROR: Invalid
   assignment of property or key '_desbloqueados' with value of type 'Array'`
   aborta la corrida y publica `0 fallo(s)` con EXIT 0. Preexistente (ya
   reportado en la iter. 3, Log 2200). Sus 3 asserts de conteo se actualizaron
   igual, para que no mientan si alguien la revive.
2. `scripts/logros/test_logros_rf10_m72.gd` tiene un check muerto:
   `get_definicion("primer_sello")` pide un id que no existe (el real es
   `logro_primer_sello`), `get_definicion` devuelve `{}` (no `null`), y `d.id`
   sobre `{}` lanza SCRIPT ERROR. El test sale EXIT 0 igual. Preexistente.
3. Los 18 `icono` del catalogo de M72 apuntan a `res://assets/ui/logros/*.png`
   y el directorio `game/isla-ancestral/assets/ui/` NO existe: 0 de 18 archivos.
   RF14 solo exige el campo no vacio, asi que el catalogo valida con los 18
   iconos muertos. Mismo patron que la trampa 84 (asset que no es asset).
4. Las claves `LOGROS.*.NOMBRE/DESC` no estan en ningun `.po` (tampoco las 17
   anteriores). Deuda de i18n de M72; el auditor de claves no esta en
   `quality.yml`, asi que no rompe CI.
5. `reservar_log.py --estado` reporta 12 problemas de numeracion AJENOS
   (colisiones 1876, 1878, 1888, 2120...). No se tocaron.
6. La fila 75 del GLOBAL tiene las columnas `Ultima actividad`/`Notas`
   desalineadas (`verificar_checklist.py` la marca como "timestamp ilegible").
   El GLOBAL es limite duro: no se toco.

## 8. Numeracion

- Log: pool global cabeza 2203 == ultimo en disco (2202) + 1 -> consumido
  **2203**, cabeza 2204.
- Canal: cabeza del pool 417 pero el archivo `417-...` YA existe (la directora
  dejo su numero en mi pool, patron ya visto con 398/400/405/408/410).
  Resincronizado: se retiro la linea stale 417 y se tomo **ultimo+1 = 418**,
  cabeza 419. El pool NO se commitea.

## 9. Estado y pendientes

- M75 sigue en **129 [x] / 1 [ ] / 0 [?] = 130**: no se aplico ningun flip.
- Flip PROPUESTO: L182 `[ ]` -> `[x]` con cita "Iter. 4, Log 2203".
- L180 ("Categoria Epilogo en M72") deja de ser un `[x]` inflado: la categoria
  existe ahora en el vocabulario y en el dato, medido por RF14.
- 0 commits / 0 push (no autorizado).
- Pendiente de decision de la directora: cablear `validate_postgame.gd` a
  `quality.yml` (limite duro), y el flip de L182.
