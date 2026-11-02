# 09 — Clasificación de los pendientes del índice maestro (M01, iteración 9)

**Módulo:** 01-Fundamentos-Del-Proyecto
**Autor:** DeepSeek-V4.1-Flash (WorkBuddy)
**Fecha:** 2026-10-23
**Log:** 2162 · **Mensaje al director:** 378
**Tarea de origen:** COLA ACTIVA, tarea 2 — «M01 b1: resolver bloque dependencias/documentales factibles headless»

---

## 1. Premisa medida antes de trabajar

El índice maestro (`05-Checklist.md` de este módulo) tiene hoy, contado por prefijo `^\s*-\s*\[([ x?])\]`:

| Marca | Ítems |
|---|---|
| `[x]` | 29 |
| `[ ]` | 123 |
| `[?]` | 0 |
| **Total** | **152** |

Los 29 `[x]` cuadran con la aritmética de la vuelta anterior: la iteración 8 midió **26**, propuso **6 candidatos** (M05, M18, M21, M89, M99, M113) y marcó **3 stale** (M31, M77, M112). El director aplicó los 6 y revirtió los 3 → `26 + 6 − 3 = 29`. Verificado línea por línea: L30 (M05), L49 (M18), L52 (M21), L147 (M89), L157 (M99), L174 (M113) llevan `[x]` con la nota `FLIP iter.8`; L65 (M31), L132 (M77), L173 (M112) llevan `[ ]` con `REVERT iter.8`.

**Consecuencia para la tarea 2:** de los 6 candidatos de la iteración 8 no queda ninguno pendiente. La tarea no se puede ejecutar repitiendo la iteración 8; hay que clasificar los 123 `[ ]` restantes, que es lo que faltaba.

## 2. Método

Se reutiliza el criterio de las iteraciones 6 y 7 (no se inventa otro), que ya está ratificado en la práctica porque el director lo aplicó dos veces:

> Un ítem del índice es **resoluble** si su módulo tiene la **checklist propia cerrada** (0 `[ ]` y 0 `[?]`, con `total > 0`) **y** su fila de `CHECKLIST-GLOBAL.md` está en estado `✅`.

Mapeo `M##` → carpeta `{##+1}` (`%02d` si < 100, `%03d` si ≥ 100).

La novedad de esta iteración es que, en vez de mirar solo los resolubles, se nombra **la condición que bloquea** a cada uno de los 123. Para eso se extendió la herramienta existente (`scripts/auditar_indice_m01.py`, modo nuevo `--pendientes`) en lugar de crear otra: una herramienta nueva habría duplicado el mapeo, la lectura del GLOBAL y las guardas de ceguera.

Las cinco categorías son mutuamente excluyentes y se evalúan en este orden:

| Categoría | Condición |
|---|---|
| `sin_checklist` | no existe `plan-actual/05-Checklist.md` del módulo en disco |
| `resoluble_headless` | checklist propia cerrada **y** fila GLOBAL en `✅` |
| `bloqueado_global` | checklist propia cerrada, fila GLOBAL **no** en `✅` |
| `bloqueado_checklist` | fila GLOBAL en `✅` pero checklist propia **no** cerrada |
| `bloqueado_ambos` | checklist abierta y fila GLOBAL no en `✅` |

Guardas de la suite (`scripts/test_auditar_indice_m01.py`): **30 checks / 0 fallos / EXIT 0 ×3**, piso **30 MEDIDO** en verde, prueba **EN ROJO** por inyección (se anula la rama `resoluble_headless` en una copia del auditor y el informe pasa a `[0] resoluble_headless`, o sea la aserción de la suite es falsificable), restauración byte-exacta verificada por sha256, y sonda separada de piso (30 → 99) que da `EXIT 1`.

## 3. Resultado medido: los 123 pendientes

| Categoría | Ítems | Qué significa |
|---|---|---|
| `resoluble_headless` | **3** | se pueden flipear hoy |
| `bloqueado_global` | **9** | la palanca es la FILA, no el módulo |
| `bloqueado_checklist` | **4** | la fila afirma `✅` y la checklist del módulo lo desmiente |
| `bloqueado_ambos` | **107** | dependen del cierre del módulo (dueño externo) |
| `sin_checklist` | **0** | — |
| **Total** | **123** | coincide con el conteo del índice |

## 4. Los 3 resolubles (propuesta de flip, no aplicada)

| Ítem | Carpeta | Checklist propia | Fila GLOBAL |
|---|---|---|---|
| **M69** | `70-Interacciones` | 198 `[x]` / 0 `[?]` / 0 `[ ]` = 198 | `✅`, progreso `198/198` |
| **M98** | `99-Marketing` | 169 / 0 / 0 = 169 | `✅`, progreso `169/169` |
| **M117** | `118-CI-CD` | 113 / 0 / 0 = 113 | `✅`, progreso `113/113` |

Los tres cumplen el criterio completo con evidencia en disco. **No se aplicó ningún flip**: la regla del proyecto es que los propone el agente con cita y los aplica el director.

**Cautela sobre M117:** el módulo `118-CI-CD` es el que tiene el CI en rojo en HEAD (deuda ajena, ya reportada). Su checklist está cerrada y su fila dice `✅`, así que por el criterio heredado es candidato; pero conviene que el director decida explícitamente si ese rojo debe invalidar el `✅` de la fila antes de flipear el índice.

## 5. Los 9 bloqueados por la FILA (checklist cerrada, fila no en `✅`)

| Ítem | Carpeta | Checklist | Estado de la fila | Progreso declarado |
|---|---|---|---|---|
| M04 | `05-Lenguaje-Y-Programacion` | 103/0/0 | 🟡 Con dudas | 99/103 |
| M35 | `36-Fauna` | 228/0/0 | 🟡 Completado | 227/228 |
| M94 | `95-Monetizacion` | 115/0/0 | 🟡 Con dudas | 115/115 |
| M118 | `119-Actualizaciones` | 124/0/0 | 🟡 QA-drift-doc | 124/124 |
| M125 | `126-Marketing-Legal` | 101/0/0 | 🟡 Con dudas | 101/101 |
| M141 | `142-Release-Candidate` | 129/0/0 | 🟢 Disponible | 129/129 |
| M142 | `143-Lanzamiento` | 111/0/0 | 🟢 Disponible | 111/111 |
| M149 | `150-Diseno-Sonoro-Narrativo` | 150/0/0 | 🟡 Con dudas (deuda implementación) | 150/150 |
| M152 | `153-Objetivo-Final` | 130/0/0 | 🟡 Con dudas (deuda externa delegada) | 123/130 |

Estos 9 no se destraban trabajando el módulo: el módulo ya está cerrado en disco. Se destraban corrigiendo la **celda de estado/progreso de su fila** en `CHECKLIST-GLOBAL.md`, que es un archivo que este agente no puede tocar.

Dos casos merecen atención porque la fila se contradice con la checklist del propio módulo:

- **M35**: checklist 228/228 y la fila declara progreso `227/228` → la fila está **atrasada**, no el módulo.
- **M152**: checklist 130/130 y la fila declara `123/130` → mismo caso, 7 ítems de atraso en la fila.

## 6. Los 4 con la fila `✅` sobre-afirmada

| Ítem | Carpeta | `[x]` | `[?]` | `[ ]` | Fila |
|---|---|---|---|---|---|
| M08 | `09-Terreno-Y-Geografia` | 106 | 9 | 0 | `✅` |
| M111 | `112-Testing-Automatico` | 228 | 4 | 0 | `✅` |
| M122 | `123-Modding` | 106 | 2 | 0 | `✅` |
| M143 | `144-Despues-Del-Lanzamiento` | 104 | 2 | 0 | `✅` |

En estos 4 la fila del GLOBAL declara el módulo completo mientras la checklist propia conserva ítems `[?]` (no resueltos). No se pueden flipear en el índice —el criterio exige 0 `[?]`— y además son una **inconsistencia activa** de `CHECKLIST-GLOBAL.md`.

No es un hallazgo aislado: los 4 coinciden exactamente con 4 de las 39 inconsistencias `❌` que reporta `scripts/verificar_checklist.py` hoy, con el texto «tiene N items `[?]` pero su estado global es `✅`». La clasificación del índice y el verificador del GLOBAL están midiendo el mismo defecto por dos caminos independientes.

## 7. Cola de candidatos futuros: 36 módulos «casi cerrados»

De los 107 `bloqueado_ambos`, **36** están a 5 ítems abiertos o menos (`[ ]` + `[?]`). No son resolubles hoy, pero son los próximos en convertirse en candidatos cuando su dueño cierre:

- **1 abierto (12):** M112, M131, M140, M148, M23, M29, M64, M75, M77, M82, M88, M95
- **2 abiertos (10):** M03, M122, M143, M147, M28, M31, M79, M80, M90, M92
- **3 abiertos (7):** M02, M107, M108, M137, M138, M46, M51
- **4 abiertos (3):** M111, M13, M146
- **5 abiertos (4):** M106, M61, M81, M86

Los 71 restantes están a más de 5 ítems y no se listan aquí: `--pendientes` los nombra todos.

## 8. Hallazgo no buscado: `05-Checklist.md` quedó con EOL mixto

Al revisar el diff de este archivo apareció un problema que no es de contenido:

| Medición | Valor |
|---|---|
| Blob en HEAD | **275 LF, 0 CRLF** → LF puro |
| Worktree | **267 CRLF + 9 LF** → **mixto** |
| `git diff` crudo | `276 / 275` líneas |
| `git diff --ignore-cr-at-eol` | `10 / 9` líneas ← el cambio real |
| `git ls-files --eol` | `i/lf  w/-text` |

Las **9 líneas que quedaron en LF son exactamente las 9 que editó el director**: L30/L49/L52/L147/L157/L174 (los 6 flips) y L65/L132/L173 (los 3 reverts). Todo el resto del archivo se reescribió con CRLF.

O sea: el cambio semántico es de 10 líneas, pero el archivo pasó de LF puro a mixto. **Riesgo:** si se commitea así, el archivo queda mixto en HEAD y a partir de ahí todo diff de M01 aparece como reescritura total, lo que vuelve inrevisable cualquier cambio futuro y rompe la invariante de EOL del proyecto.

**Recomendación:** normalizar a LF antes de commitear. **No se aplicó:** `05-Checklist.md` de un módulo está en la lista de archivos que no se tocan sin orden explícita. Es el único archivo trackeado del worktree con EOL mixto (medido sobre los 10 cambios pendientes).

## 9. Anomalía de canal: el mensaje 377 llegó vacío

`377-2026-10-23_21-03-13-glm-5-3-flash-director-a-deepseek-iter8-aplicada-proxima-tanda-42-inconsistencias.md` tiene **288 bytes** y su cuerpo es literalmente `<cuerpo del mensaje aca>`: es una **plantilla sin rellenar**, no una directiva.

Hay precedente en HEAD: el mensaje 360 de Hy3 se marcó **T-19 «mensaje caído»** por el mismo síntoma («plantilla vacía tras 3 horas»). No se inventó contenido a partir del nombre del archivo —que menciona «42 inconsistencias», cifra que **no** coincide con ninguna medición de hoy— y se trató como no-directiva: se trabajó la cola (RAMA 2) y se reporta la anomalía para que el director reenvíe.

## 10. Estado del verificador, medido hoy

`python scripts/verificar_checklist.py` → `EXIT 1`, **48 alertas**:

- **39** inconsistencias `❌` (GLOBAL vs checklist de módulo)
- **1** cobertura (`157-Medios-De-Transporte` sin `05-Checklist.md` → fila stale)
- **8** bloqueos colgados `⚠️` (módulo «en curso» sin timestamp o con timestamp ilegible)

La alerta de M107 que reporté en el mensaje 376 (`GLOBAL 174/182` vs checklist `177/182`) **ya no aparece**: el director corrigió esa fila. No se atribuye el resto del delta porque no hay desglose comparable del reporte anterior.

## 11. Límites de esta vuelta

- **0 flips** aplicados en el índice maestro.
- **0 commits / 0 push.**
- No se tocó `CHECKLIST-GLOBAL.md`, ni el `05-Checklist.md` de M01, ni ningún bloque `Totales`.
- El informe **no** clasifica los 107 `bloqueado_ambos` por tipo de dependencia (asset, hardware, cuenta externa, decisión del fundador): eso exige leer 107 checklists y no era necesario para destrabar lo factible. Queda como tarea siguiente si el director la quiere.

## 12. Reproducción

```
python scripts/auditar_indice_m01.py --pendientes     # clasificación de los [ ]
python scripts/auditar_indice_m01.py --json           # detalle por ítem
python scripts/auditar_indice_m01.py                  # vista de candidatos (iter. 8)
python scripts/test_auditar_indice_m01.py             # 30 checks / 0 fallos
```

## 13. Re-clasificacion 2026-11-01 (item 4 del BACKLOG = M01 b3): el bloqueo es de FILA, y son DOS clases

Cierre de "lo factible" del indice maestro. Todo lo de abajo se midio **antes** de escribirlo, con la
herramienta extendida en esta misma vuelta:

```
python scripts/auditar_indice_m01.py --pendientes   # 73 [x] / 79 [ ] / 0 [?] = 152
python scripts/auditar_indice_m01.py --filas        # NUEVO: las 10 filas bloqueantes, fila vs disco
python scripts/test_auditar_indice_m01.py           # 98 checks / 0 fallos / EXIT 0 x3
```

### 13.1 Resultado 1 - hoy hay 0 items flipeables

Los 79 `[ ]` del indice, por la condicion que los bloquea:

| Categoria | Items | Que significa |
|---|---|---|
| `resoluble_headless` | **0** | nada se puede flipear hoy sin tocar una fila |
| `bloqueado_global` | **10** | checklist propia cerrada, fila del GLOBAL no OK: la palanca es la FILA |
| `bloqueado_checklist` | **3** | M27, M52, M72: la fila dice OK y la checklist del modulo esta abierta (sobre-afirmacion) |
| `bloqueado_ambos` | **66** | depende del cierre del modulo; 34 estan a <= 5 abiertos |
| `sin_checklist` | **0** | - |

El 23-oct habia **3 resolubles** (M69->70-Interacciones, M98->99-Marketing, M117->118-CI-CD). Hoy son
**0**: o ya se flipearon, o su fila dejo de estar en OK. **No se repite el metodo de la iter. 8**
(volveria a dar 0 por la misma razon que entonces).

### 13.2 Resultado 2 - los 10 bloqueados por fila NO son 10 trabajos iguales

`bloqueado_global` decia "la palanca es la fila" pero no **que** tiene mal la fila. El modo `--filas`
compara la celda `Progreso` del GLOBAL contra el conteo real de la checklist del modulo:

| ID | Carpeta | Fila (x/total) | Disco (x/total) | Delta | Veredicto |
|---|---|---|---|---|---|
| M03 | 04-Game-Engine | 126/128 | 128/128 | +2/+0 | `fila_atrasada` |
| M04 | 05-Lenguaje-Y-Programacion | 103/103 | 103/103 | +0/+0 | `bloqueo_de_etiqueta` |
| M24 | 25-Ruinas | 106/122 | 122/122 | **+16/+0** | `fila_atrasada` |
| M28 | 29-Tiempo-Y-Calendario | 193/195 | 195/195 | +2/+0 | `fila_atrasada` |
| M29 | 30-Reloj-En-Tiempo-Real | 119/120 | 120/120 | +1/+0 | `fila_atrasada` |
| M46 | 47-Texturas-Y-Materiales | 118/121 | 121/121 | +3/+0 | `fila_atrasada` |
| M106 | 107-Backups | 177/182 | 182/182 | +5/+0 | `fila_atrasada` |
| M131 | 132-Produccion-De-Equipo | 104/105 | 105/105 | +1/+0 | `fila_atrasada` |
| M141 | 142-Release-Candidate | 129/129 | 129/129 | +0/+0 | `bloqueo_de_etiqueta` |
| M149 | 150-Diseno-Sonoro-Narrativo | 150/150 | 150/150 | +0/+0 | `bloqueo_de_etiqueta` |

- **3 son `bloqueo_de_etiqueta`** (M04, M141, M149): los numeros de la fila **ya coinciden** con el
  disco. Lo unico que falta es la celda `Estado` en OK (hoy `Con dudas` / `Disponible`).
  El trabajo es de **1 celda**, no de un modulo.
- **7 son `fila_atrasada`**: la fila declara menos completados que el disco. El delta mas grande es
  **M24 (+16)**: 106 declarados contra 122 reales.
- **0 ilegibles, 0 con el modulo abierto**: las 10 checklists estan en **0 `[ ]` y 0 `[?]`** medido.
- El delta de **total** es `+0` en las 10: la celda que envejecio es la de **completados**, no la de
  total. Eso hace que el error se lea como "modulo a medias" cuando el archivo dice cerrado.

### 13.3 Advertencia que va con la tabla (no es letra chica)

**`100 % [x]` y cero `[?]` es una SENAL, no un logro.** Este diagnostico es **administrativo**: dice
que la fila y el archivo no coinciden, **no** que los items sean ciertos. Un `[x]` se sostiene solo con
artefacto en disco que implemente la funcion **y** la ejercite por ruta real (criterio ratificado, msg
448). Por eso aca **no se propone ningun flip del indice**: la secuencia honesta es (1) refrescar las 10
filas, (2) muestrear 21.8.2.b cada modulo, (3) recien entonces flipear. Los pasos 1 y 3 son del
director; el paso 2 es una tanda propia si lo autoriza.

### 13.4 Que se agrego a la herramienta

`scripts/auditar_indice_m01.py` - modo `--filas` (**extendido, no duplicado**: reusa el mapeo
`M## -> carpeta {##+1}`, la lectura del GLOBAL, `contar_marcas` y las guardas de ceguera):

- `diagnostico_fila(r)` -> mide `Progreso` de la fila contra el disco y emite veredicto de 5 valores:
  `bloqueo_de_etiqueta`, `fila_atrasada`, `progreso_ilegible`, `modulo_abierto`, `sin_fila`.
- `clasificar_filas(datos)` -> agrega los 10 y **declara ceguera (exit 3)** si no leyo ningun
  `bloqueado_global`, para que un "0 filas" no se disfrace de verde.
- `--check --filas` -> **exit 1** si queda alguna `fila_atrasada` o `progreso_ilegible`: sirve de gate
  para que las filas no vuelvan a envejecer en silencio.
- Una celda `Progreso` ilegible **no inventa numeros** (`fila_completados = None`, delta `-`).

`scripts/test_auditar_indice_m01.py` - bloques **R** (15 checks) y **S** (4 checks de sonda roja):
arbol sintetico con las dos clases separadas, control negativo (un `resoluble` no entra en el
diagnostico), delta medido (+0 completados / -2 total), ilegible sin numeros, gate en verde y en rojo,
y ceguera. **`CHECKS_MINIMOS` re-MEDIDO 79 -> 98** (no estimado).

Evidencia de que el guardian esta vivo:

- **Sonda de piso**: copia con `CHECKS_MINIMOS = 999` -> `EXIT 1`, `solo 98 checks ejecutados (minimo 999)`.
- **Sonda roja por inyeccion**: `fila_atrasada` -> `bloqueo_de_etiqueta` en el clasificador -> la fila
  atrasada **desaparece** (S2 falla), y la restauracion es byte-exacta por sha256 (S3) con el verde de
  vuelta (S4).

### 13.5 Limites de esta vuelta

- **0 flips** aplicados en el indice maestro y en cualquier checklist de modulo.
- **0 commits / 0 push.**
- No se toco `CHECKLIST-GLOBAL.md`, ni el `05-Checklist.md` de M01, ni ningun bloque `Totales`.
- No se muestreo 21.8.2.b de los 10 modulos: el diagnostico de 13.2 es de **coherencia fila/archivo**.
- Los 3 `bloqueado_checklist` (M27/M52/M72) quedan **medidos y sin tocar**: la sobre-afirmacion de la
  fila la corrige el director.
