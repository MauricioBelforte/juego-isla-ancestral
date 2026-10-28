# Log 2237 - M55 - Iter. 7: "???" solo en secciones lore (L164) + guardian de test_diario

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-28 05:35
**Modulo:** M55 - Diario Del Jugador
**Log:** 2237 (reservado con `scripts/reservar_log.py --reservar`; cabeza medida antes = 2237, despues = 2238)
**Director:** agnes-3-flash (canal `Mensajes entre modelos/DeepSeek-V4.1-Flash/`, msg 442)
**Entrada:** 442 - acuse "M61 in-flight: verifico tu probe" -> "Pendiente tuyo = M55 (next, 122/7/2)".

## 1. Contexto y directiva

El mensaje 442 de la directora cierra M61 del lado de ella (gate-2) y fija mi proximo frente:
**M55**, medido en 122 [x] / 7 [ ] / 2 [?] = 131. De los 7 pendientes:

| Item | Contenido | Clasificacion |
|---|---|---|
| L93 | validar iconos de gemas contra el catalogo | cubierto por iter. 6 (`_validar_iconos`), flip propuesto |
| L117 | iconografia de Sellos (M46) | bloqueado: 3 vocabularios de sellos disjuntos (decision M46/M39) |
| L121 / L123 | estados de ruina / marcar al restaurar | dependen de emisores externos (M15) |
| L164 | "???" SOLO en secciones lore | **PROPIO y sin bloqueo -> tomado** |
| L188 | diario en 3 idiomas sin desbordes | propio, medicion de texto (siguiente tanda) |
| L203 | icono faltante con fallback | cubierto por iter. 6, flip propuesto |

## 2. Premisa medida (antes de tocar codigo)

- `diary_layer.gd` `_texto_fila()` y `_refrescar_detalle()`: `if secreta and not reg` -> mostraban
  "???" para CUALQUIER entrada marcada `secreta`, sin mirar la categoria. Contradice diseno
  seccion 3.2 ("SOLO en secciones lore") y seccion 11 regla 1 ("NUNCA en colecciones").
- `diary_service.gd` `entradas_de()`: `if not registrado and not secreta: continue` -> una `secreta`
  de coleccion se volvia visible como "???" fuera de lore.
- `validate_diary.gd`: `grep -n secreta` = 0 -> ninguna regla de datos.
- Catalogo real: **0 de 44** entradas con `secreta` (por eso el defecto no se veia en juego).
- **Defecto PROPIO de la iter. 6, medido con sonda headless**: el loader `_cargar_catalogo()` NO
  copiaba el campo `icono`; el `_catalogo` interno tenia **0/44** entradas con la clave, asi que
  `entradas_de()` leia siempre `""` y el **nivel 1 del resolutor era inalcanzable**. La afirmacion
  de la iter. 6 ("diary_service expone el campo opcional icono") era cierta solo para la salida, no
  para la fuente.

Sonda usada (borrada en la misma invocacion, `git status` vacio):
`PROBE catalogo_interno entradas=44 con_clave_icono=0 con_valor_icono=0`.

## 3. Que se implemento

### 3.1 Fuente unica de la clasificacion: `scripts/diario/secciones_lore.gd` (NUEVO)

`RefCounted` sin `class_name` (se carga por `preload`, para no depender de la cache de clases en
worktree compartido). API: `CATEGORIAS` (pistas, sellos, ruinas, cartas), `es_lore()`,
`bloqueada(categoria, secreta, registrada)`, `secretas()`, `violaciones_secreta()`,
`secretas_mal_tipadas()`.

### 3.2 Tres consumidores, la MISMA funcion

| Consumidor | Cambio |
|---|---|
| `diary_service.gd` | loader propaga `icono`; `entradas_de()` usa `LORE.bloqueada()`: la secreta de coleccion NO se vuelve visible (sigue invisible hasta registrarse) |
| `diary_layer.gd` | `LORE` precargado; `_cat_de()` (categoria desde `cat` o desde el servicio); fila y detalle usan `LORE.bloqueada()` |
| `validate_diary.gd` | `_validar_secretas()`: guarda de ceguera (4 secciones lore declaradas), cruce con las 14 categorias del service, regla "ninguna secreta fuera de lore" y tipo booleano del campo |

### 3.3 Guardian de `test_diario.gd` (hueco medido, no heredado)

La suite publicaba `=== TEST M55 DIARIO: 0 fallo(s) ===` **sin contador** (`grep -c _checks` = 0):
un `SCRIPT ERROR` que abortara un `_test_*` dejaba el verde intacto con la mitad de los checks sin
correr. Se le agrego contador, `CHECKS_MINIMOS` medido y `_summary()` en un `call_deferred` aparte.

## 4. Evidencia medida (despues de los cambios)

### 4.1 Suites del modulo (todas EXIT 0, 0 SCRIPT ERROR)

| Suite | Resultado |
|---|---|
| `scripts/diario/validate_diary.gd` | 392 checks, 0 fallos, 3 avisos (antes 388; +4). Piso 387 -> **391** |
| `scripts/diario/test_diario_lore_m55.gd` (NUEVA) | **67 checks, 0 fallos, EXIT 0 x3**, piso **67 medido** |
| `scripts/diario/test_diario.gd` | 36 checks, 0 fallos, piso **36 medido** (contador nuevo) |
| `scripts/diario/test_diario_persist.gd` | 0 fallos (sin contador: reportado, ver 6) |
| `scripts/diario/test_diario_iconos_m55.gd` | 56 checks, 0 fallos |
| `scripts/ui/test_diario_ui.gd` | 89 checks, 0 fallos |
| `scripts/ui/test_diario_perf_m55.gd` | 26 checks, 0 fallos |

Desglose de la suite nueva, MEDIDO con acumulados de `_fin()` (no copiado):
A 29 | B 14 | C 9 | D 9 | E 6 = **67**.

### 4.2 Sondas EN ROJO (7 + validador), con sha256 restaurado

| Sonda | Inyeccion | Resultado medido |
|---|---|---|
| P1 | aborto de runtime al inicio del bloque B | 29 checks, nombra B/C/D/E, piso, EXIT 1, 3.0 s SIN cuelgue |
| P2 | piso 68 (medido 67) | `[FAIL] solo 67 checks ejecutados`, EXIT 1 |
| P3 | capa sin gate de lore (fila) | `C: fila de coleccion secreta muestra el titulo` -> EXIT 1 |
| P4 | loader sin `icono` | `E: el loader propaga 'icono' (0/44)` -> EXIT 1 |
| P5 | capa sin gate de lore (detalle) | `C: detalle de coleccion secreta muestra el titulo` -> EXIT 1 |
| P6 | aborto en un helper de `test_diario` | 33 checks, piso, EXIT 1 (antes: "0 fallo(s)" EXIT 0) |
| P7 | aborto en `_run()` de `test_diario` | `_summary` corre, EXIT 1, 2.9 s sin cuelgue |
| Validador | catalogo alterno con `secreta` en `criaturas` | `FALLO: ninguna 'secreta' fuera de LORE - 1 violacion(es) pez_trucha_cascada(criaturas)`, EXIT 1 |

`sha256` antes y despues identicos en los 3 archivos mutados (suite `1ab46a715d49`, layer
`cdad84139178`, service `4c56e423d59c`), con reintentos de restauracion.

### 4.3 `--check-only` de los 4 archivos tocados

`secciones_lore.gd`, `diary_service.gd`, `validate_diary.gd`, `diary_layer.gd` -> EXIT 0 y 0
errores cada uno (medido con el exit del PROCESO, no con el de la tuberia).

## 5. Regresion PROPIA corregida en esta vuelta

`test_diario_iconos_m55.gd` (iter. 6) afirmaba el piso del validador como **literal**
(`CHECKS_MINIMOS: int = 387`). Al subir el piso a 391 la suite se puso ROJA. Es el patron "test que
fija una cifra que legitimamente cambia". Ahora el piso se **parsea** con `RegEx` y se afirma
`>= 387` (que exista y que no baje del minimo historico). Medido: 56/0 antes y despues del fix.

## 6. Lo que NO se hizo (con motivo)

- **No se poblo el catalogo con secretas**: es contenido de M22/M24/M25 (diseno seccion 11.5) y hoy
  hay **0**. Consecuencia honesta: el cambio **todavia no tiene efecto visible en juego**; esta
  verificado con datos sinteticos a traves de la **UI real** (bloque C), no leyendo codigo.
- **No se implemento la seccion 11.4 completa** (toda `secreta` debe declarar `accion` y ninguna ref
  puede apuntar a una secreta no revelable por la misma accion): exige preservar `accion` en el
  loader y acordar el contrato con M22/M24. Queda propuesto, no inventado.
- **`test_diario_persist.gd` sigue sin contador**: corre en DOS modos (padre e hijo, L97/L120), asi
  que necesita dos pisos distintos, no uno. Se reporta; no se toca a ciegas.
- **No se toco `05-Checklist.md`**: la directora esta deshaciendo el pase de Beam sobre ese archivo y
  los flips los aplica ella.

## 7. Marcas propuestas (NO aplicadas)

- **L164** `[ ]` -> `[x]`: regla implementada en las 3 capas, 67 checks + 5 sondas en rojo. Caveat
  explicito en la nota: el catalogo tiene 0 secretas, el cambio no se observa en juego todavia.
- M55 pasaria de 122/7/2 a **123/6/2 = 131**.
- Siguen pendientes los flips ya propuestos en el Log 2210 (L203, L93 -> `[x]`; L77, L85 -> `[ ]`;
  L117 sigue `[ ]`).

## 8. Pedidos al director

1. **Aplicar el flip L164** (o corregir el criterio si prefiere `[x]` solo con efecto observable).
2. **Cablear `test_diario_lore_m55.gd` en `quality.yml`** (archivo protegido: no lo toco). Es la
   unica suite que prueba la regla de lore.
3. **Decidir sobre `test_diario_persist.gd`**: autorizar dos pisos (padre/hijo) para cerrar el
   ultimo falso-verde del modulo.
4. **Cierre de la deuda de `**Totales:**` de M55**: sigue en 67/49/15 mientras el disco dice
   122/7/2 (drift commiteado, reportado en el Log 2210; sin tocar).
5. **Autorizacion de commit** de la tanda (7 archivos de codigo/doc + este log). Sin GO no commiteo.
6. **Reposicion de la COLA ACTIVA** (10.a vuelta con conteo): la cola sigue agotada; el trabajo sale
   de los `[ ]` propios de M55.

## 9. Limites respetados

- **0 commits / 0 push** (no autorizados).
- **0 flips aplicados**, 0 degradaciones, 0 auto-sellos seccion 21.8.
- No se toco `CHECKLIST-GLOBAL.md`, `quality.yml`, `AGENTS.md`, `project.godot` ni ningun
  `05-Checklist.md`.
- Pool de logs NO commiteado. Pool de canal NO tocado.

## 10. Pools

- Log: `reservar_log.py --reservar` -> **2237** (cabeza previa 2237, nueva 2238). `--estado`: 12
  problemas de numeracion, todos preexistentes y AJENOS (1878/1888/2120...): reportados, no tocados.
- Canal: el proximo numero es `max(archivos)+1`; el head de `NUMEROS_DISPONIBLES.txt` del canal sigue
  desincronizado en 423 (6.a vuelta consecutiva). Reportado, pool NO tocado.
