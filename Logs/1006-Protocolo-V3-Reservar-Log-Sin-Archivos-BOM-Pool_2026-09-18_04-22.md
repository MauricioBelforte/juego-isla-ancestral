# Log 1006: Protocolo v3 — `reservar_log.py` deja de crear archivos y el pool recupera su primer número

**Fecha:** 2026-09-18
**Hora:** 04:22
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Reserva:** 1006 (consumida del pool; v3 no usa archivo de reserva)
**Módulo:** Protocolo-V3 (transversal / infraestructura de numeración)

## Resumen

Cierre de la alineación con el **protocolo v3 consolidado por el dueño** (commits `2ac8b4b` y
`b65c30b`). Al terminar M52 iter. 6 dejé una **contradicción**: mi commit `f4d009c` volvió a
añadir `Logs/ULTIMO_NUMERO.txt` y `Logs/reservas/1005-…txt`, exactamente los artefactos que
`2ac8b4b` acababa de retirar. Este log lo corrige y, en el camino, aparecen **dos defectos
reales** que nadie había medido.

**1. `scripts/reservar_log.py` ya no crea ningún archivo.** `--reservar` consume la primera
línea de `Logs/NUMEROS_DISPONIBLES.txt` y la imprime; el número es el único *claim*. Se retiran
`ULTIMO_NUMERO.txt`, `Logs/reservas/` y la constante `ULTIMO`. `--estado` sigue detectando
conflictos **reales** (reserva doble, colisión, reservado+escrito, doble asignador) pero **ya no
falla** solo porque existan reservas heredadas sueltas del mecanismo retirado.

**2. BUG REAL: el pool tenía BOM y eso hacía invisible su primer número.** El blob commiteado de
`Logs/NUMEROS_DISPONIBLES.txt` empezaba con `EF BB BF`. Consecuencia medida:

```
lineas no vacias      : 496
parseables con isdigit: 495      <- el BOM hacía ilegible la PRIMERA
primera linea repr    : b'\xef\xbb\xbf1004\r'
```

`b'\xef\xbb\xbf1004\r'.strip().isdigit()` es `False`, así que `consumir_primero_del_pool()`
**nunca veía el 1004**: el pool informaba "495 libres (primero=1006)" teniendo 496 líneas, y el
1004 quedaba como un número fantasma que nadie podía consumir ni detectar. Es también una
violación de la **sección 28 (UTF-8 sin BOM)** y el gate de CI `scripts/verificar_bom.py`
**estaba en rojo por este único archivo**:

```
Archivos con BOM: 1
  Logs/NUMEROS_DISPONIBLES.txt
```

El BOM **no lo introduje yo**: ya estaba en `2ac8b4b` y `5f4e003` (verificado con
`git show <rev>:Logs/NUMEROS_DISPONIBLES.txt`). Mi commit `f4d009c` lo arrastró sin verlo.

**3. El asignador es ahora inmune al BOM**: lo detecta, lo denuncia en `--estado` (contando como
problema) y **se autocura** al consumir (al reescribir el pool el BOM desaparece).

**Resultado:** 6 gates duros de CI en verde, el gate de BOM **pasa de rojo a verde**, y la sonda
del asignador da **26 checks / 7 bloques / 0 fallos**, con su guardián **probado por inyección**.

## Incidente: `Logs/` desapareció del árbol de trabajo (967 archivos)

Durante este trabajo, `Logs/` **desapareció por completo del árbol de trabajo** y volvió a
desaparecer una segunda vez. Medido con `git status --porcelain`: **967 entradas ` D`, todas bajo
`Logs/`**, mientras el índice seguía teniendo los archivos.

Diagnóstico (descartado por medición, no por intuición):

| Hipótesis | Comprobación | Resultado |
|---|---|---|
| `.gitignore` ignora `Logs/` | `git check-ignore -q` (exit code, trampa 66) | rc=1 → **no** ignorado |
| Sparse-checkout | `git config --get core.sparseCheckout` + `.git/info/` | **no** configurado |
| Hook de git | `ls .git/hooks/` sin `.sample` | **vacío** |
| `core.fsmonitor` | `git config --list` | **no** configurado |
| Proceso que borra en bucle | canario + muestreo a 0.25 s durante 15 s | **no** reaparece: sobrevive |
| Ficheros movidos a otro sitio | barrido del árbol buscando `NUMEROS_DISPONIBLES` | solo `.kilo/worktrees/phase-judge/` (otro worktree) |

**Causa real: un commit ajeno.** El `HEAD` **se movió** durante la sesión:

```
c8774f8 Restaurar NUMEROS_DISPONIBLES.txt (borrado accidental)   <- otro agente
b65c30b Actualizar refs ULTIMO_NUMERO → NUMEROS_DISPONIBLES ...  <- otro agente
f4d009c M52 Particulas y VFX — iter. 6 ...                        <- yo
```

`b65c30b` **borró `Logs/NUMEROS_DISPONIBLES.txt` (496 líneas)** — de ahí el "borrado accidental"
que `c8774f8` repara — además de `Logs/ULTIMO_NUMERO.txt` y `Logs/reservas/1005-…txt`. La
desaparición de los 967 archivos del árbol fue el estado intermedio de esa operación ajena, no un
proceso hostil ni un fallo mío.

**Remediación aplicada:** `git restore --source=HEAD --staged --worktree -- Logs` → **967
entradas, 0 borrados**. Contenido íntegro (todo estaba en `HEAD`).

**Pérdida real y honesta:** los archivos **no versionados** bajo `Logs/` no son recuperables
desde git. Se perdieron tres, todos ajenos o de usar y tirar:

- `Logs/_t39a.txt`, `Logs/_t39b.txt` (temporales de otro agente),
- `Logs/reservas/1004-glm-5.3-flash-M39.txt` (reserva heredada de glm; el 1004 ya estaba
  reclamado por él y su log aún no existe).

## Cambios

| Archivo | Cambio |
|---|---|
| `scripts/reservar_log.py` | Reescrito a v3: consume el pool, no crea archivos, `--estado` sin falsos conflictos, inmune al BOM. +139 / −71 vs `HEAD` |
| `Logs/NUMEROS_DISPONIBLES.txt` | BOM eliminado; línea `1004` (ya reclamada por glm) retirada → **495 líneas, 1006→1500**, todas parseables, ascendentes, sin duplicados |
| `tools/logs/test_reservar_log_pool.py` | **Nuevo.** Sonda aislada (árbol temporal): 7 bloques, **26 checks**, piso 22 |
| `tools/logs/probar_guardian_reservar_log.py` | **Nuevo.** Prueba la sonda por inyección y restaura el archivo verificando sha256 |

## Verificación

**Sonda del asignador** (`tools/logs/test_reservar_log_pool.py`) — exit leído del proceso:

```
bloques ejecutados : 7/7 ['A', 'B', 'C', 'D', 'E', 'F', 'G']
checks             : 26 (piso 22)
fallos             : 0
RESULTADO: OK                                    rc=0
```

Bloques: A consume el primero y preserva EOL · B **no crea archivos** (el núcleo del cambio) ·
C sin pool cae a `max+1` y lo declara · D inyección: doble asignador detectado · E reserva
heredada sola = aviso, no conflicto · F no regresión de las guardas previas · G **inyección de
BOM: el primer número sigue visible**.

**Guardián probado por inyección** (un guardián que no falla ante una regresión es un falso
verde). Se mutó `cmd_reservar` para que volviera a crear `Logs/reservas/NNN-inyectado.txt`:

```
fallos detectados: 1
   [FALLO] NO crea Logs/reservas/ (mecanismo retirado en 2ac8b4b)
GUARDIAN OK: la sonda FALLA ante la regresion inyectada (no es falso verde)
sha restaurado: 9a8c101d9530878c -> IDENTICO
```

**Gates de CI** (exit code del proceso, trampa 75 — nunca a través de un pipe):

| Gate | rc |
|---|---|
| `tools/legal/insert_copyright_headers.py --check` | 0 |
| `tools/legal/timestamp_seal.py --cadena` | 0 |
| `tools/legal/scan_orphan_code.py --check` | 0 |
| `tools/legal/validate_asset_metadata.py --check` | 0 |
| `tools/legal/audit_dependencies.py --check` | 0 |
| `tools/legal/registros_db.py --check` | 0 |
| `tools/vfx/gen_vfx_catalog.py --check` | 0 |
| `scripts/verificar_bom.py` | **1 → 0** (rojo a verde con este arreglo) |

**`--estado` final:** `494 libres (primero=1007)` · `963 numeros` · **Sin conflictos** · rc=0.

## Riesgo residual (honesto, no eliminable desde aquí)

Tomar la primera línea del pool es un **read-modify-write sobre un archivo compartido**. Dos
procesos pueden leer la misma primera línea y borrarla los dos. `AGENTS.md` §6.1.d afirma que la
colisión es *"imposible"* y que *"la línea en blanco resultante se detecta"*. **Medido el
2026-09-18 eso no se sostiene**: hubo dos colisiones reales (1001 con hy3 y 1002 con un commit ya
cerrado) y **no apareció ninguna línea en blanco**, porque ambos procesos reescriben el archivo
entero. La única detección posible es **a posteriori**: `--estado` marca `DOBLE ASIGNADOR` cuando
un número sigue en el pool teniendo ya un log.

**Propuesta para el dueño (no aplicada unilateralmente):** corregir §6.1.d de `AGENTS.md` para
sustituir "imposible" por el riesgo real y su mitigación (`--reservar` en una sola operación,
verificar con `--estado` al cerrar el ciclo).

## Pendiente

- **Gate de CI para la sonda**: `quality.yml` tiene modificaciones ajenas en vuelo (gates de
  M83/M126 de agnes-3-flash) → no lo toco en este commit para no arrastrar trabajo ajeno
  (trampa 70). Queda añadir `python tools/logs/test_reservar_log_pool.py` como paso de CI.
- **Corrección de `AGENTS.md` §6.1.d** (propuesta arriba).
- `Logs/qa_m09_2026-09-11.txt` sigue siendo el único archivo no-`NNN-` de `Logs/` además del pool;
  es ajeno a este trabajo.
- Los **10 ítems `[ ]` de M52** con dueño externo y el **QA cruzado §21.8 de M52 iter. 6** siguen
  pendientes (ver Log 1005).
