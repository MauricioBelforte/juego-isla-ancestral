# 08 — Diagnóstico del índice maestro (Patrón D) — iter. 8

**Módulo:** 01-Fundamentos-Del-Proyecto
**Modelo:** DeepSeek-V4.1-Flash (WorkBuddy)
**Fecha:** 2026-10-23
**Log:** 2160
**Herramienta:** `scripts/auditar_indice_m01.py` (nueva, esta iteración)
**Estado del módulo al escribir:** 26 `[x]` / 126 `[ ]` / 0 `[?]` = 152 (sin cambios)

---

## 1. Encargo y premisa

Tarea 1 de mi cola activa (`BACKLOG-MASTER.md`): *"M01-Fundamentos (26/152): diagnóstico Patrón D de
los 126 restantes y mapa de lotes"*.

**La premisa estaba vencida.** Ese diagnóstico ya se hizo dos veces, y las dos están en este mismo
checklist:

- iter. 6 — 2026-10-14, sección *"Auditoria del indice maestro (2026-10-14)"* del `05-Checklist.md`.
- iter. 7 — 2026-10-15, Log **1858**, sección *"Auditoria del indice maestro (2026-10-15)"*.

Las dos concluyeron lo mismo: **0 candidatos nuevos**, M01 bloqueado porque depende de que otros
módulos cierren. Repetir el diagnóstico con el mismo método habría dado el mismo resultado por
construcción. Lo que **sí** hacía falta es un **refresco medido**: entre la iter. 7 y hoy pasaron
**8 días** y el repo cerró decenas de módulos. Este documento es ese refresco (iter. 8), con la
medición hecha hoy contra disco.

## 2. Método

Criterio, el mismo documentado por las iters. 6 y 7 (no se inventó uno nuevo):

> un ítem del índice se flipea a `[x]` si su **checklist propia está 100 % cerrada**
> (0 `[ ]` y 0 `[?]`) **y** su fila de `CHECKLIST-GLOBAL.md` está en estado `✅`.

Medición:

1. **Conteo por prefijo de línea** (`^\s*-\s+\[([ x?→])\]`), nunca por substring — regla del proyecto.
2. **Mapeo `M##` → carpeta `{##+1}`** (desplazamiento +1 ya documentado en el `05-Checklist.md` y en
   la fila 01 del GLOBAL). Se verificó caso por caso: los 152 ítems resolvieron carpeta y los títulos
   coinciden (p. ej. `M04` "Lenguaje y Programación" → `05-Lenguaje-Y-Programacion`).
3. **Cruce contra el verificador oficial**: `scripts/verificar_checklist.py` (exit 1, **42
   inconsistencias** preexistentes). Los 6 candidatos **no** aparecen entre esas 42: su progreso
   GLOBAL coincide exacto con su checklist. El conteo propio y el del verificador dan idéntico
   `[x]`/`[?]`/`[ ]` en los 6.
4. **Guarda de ceguera** (`exit 3`): el auditor aborta si no lee 152 ítems, si no lee filas del
   GLOBAL o si no resuelve ninguna carpeta. Probado: con `INDICE` inexistente devuelve 3.

## 3. Estado medido del índice

- Marcas por prefijo: **26 `[x]` / 126 `[ ]` / 0 `[?]` = 152**. Coincide con `**Totales:**` y con la
  fila 01 del GLOBAL (`26/152`).
- De los 26 `[x]`: **20 siguen siendo válidos** y **6 quedaron stale** (§5).
- **6 candidatos nuevos** a flip (§4) — la iter. 7 había medido **0**.
- Suma de las 152 checklists propias: **19.476 `[x]` / 993 `[?]` / 1.586 `[ ]` = 22.055**.

Comparación con la iter. 7 (2026-10-15, Log 1858):

| métrica | iter. 7 | iter. 8 (hoy) | delta |
|---|---|---|---|
| `[x]` | 17.485 | 19.476 | **+1.991** |
| `[?]` | 970 | 993 | +23 |
| `[ ]` | 3.508 | 1.586 | **−1.922** |
| total | 21.963 | 22.055 | +92 |

Lectura: en 8 días se cerraron **1.922 ítems pendientes** en el conjunto de los 152 módulos. El
bloqueo de M01 se está deshaciendo, pero por trabajo ajeno.

## 4. Candidatos nuevos a flip (6)

Los seis cumplen el criterio completo: checklist propia cerrada **y** GLOBAL `✅` con progreso
idéntico.

| Ítem índice | Carpeta real | Checklist (x/?/[]) | GLOBAL | Evidencia de QA en la fila |
|---|---|---|---|---|
| **M05** | `06-Control-De-Versiones` | 100/0/0 | `✅ Completado` 100/100 | agnes-3-flash 2026-10-15 (Log 1240) + re-verify Hy3 Log 1290 |
| **M18** | `19-NPC-Y-Vecinos` | 128/0/0 | `✅ Completado` 128/128 | agnes-3-flash 2026-10-15 (msg 463, §21.8.2.b) |
| **M21** | `22-Historia-Principal` | 91/0/0 | `✅ Completado` 91/91 | agnes-3-flash 2026-10-15 (msg 465, §21.8.2.b) |
| **M89** | `90-Configuracion-Grafica` | 249/0/0 | `✅ Completado` 249/249 | (nota de la fila **stale**, ver aviso) |
| **M99** | `100-Community-Management` | 220/0/0 | `✅ Completado` 220/220 | agnes-3-flash 2026-10-15 (msg 467, §21.8.2.b) |
| **M113** | `114-Playtest` | 196/0/0 | `✅ Completado` 196/196 | agnes-3-flash 2026-10-22 (veredicto 966: 0/5 muestras, 0 `[ ]`) |

**Avisos que el director tiene que pesar antes de aplicar:**

- **M18 y M21** eran justamente los dos que la iter. 7 midió como *"cerradas pero GLOBAL NO `[OK]`"*.
  Su GLOBAL pasó a `✅` después del 15-10: el flip ya no está bloqueado. `M99` estaba en 🟡 y hoy
  también es `✅`.
- **M89 → `90-Configuracion-Grafica`** es el módulo que en el resto de los canales se llama **M90**, y
  **está en mi lista de NO TOCAR**. El flip propuesto es sobre el **ítem del índice de M01**, no toca
  un solo archivo del módulo. Si el director prefiere no mezclar, este queda último.
- La nota de la fila 90 dice *"96 `[ ]` restantes = implementación de efectos"* mientras su progreso
  es `249/249` y su checklist mide 0 `[ ]`. **La nota está stale**; el ✅ sí está respaldado por disco
  (medido por mí el 2026-10-22, Log 2142: 249/0/0 y suites `test_graphics_config*.gd` 85/0 y 57/0).
- **M113 → `114-Playtest`**: la misma fila arrastra la nota *"PENDIENTE DE VERIFICACIÓN CRUZADA"* del
  2026-08, contradicha por el sello agnes del 2026-10-22 que está al final de la misma celda.

## 5. `[x]` del índice que quedaron STALE (6)

Estos seis están marcados `[x]` en el índice pero **hoy no cumplen el criterio**. Tres por regresión
real del módulo, tres por una celda del GLOBAL que no refleja el disco.

| Ítem índice | Carpeta real | Checklist | GLOBAL | Causa medida |
|---|---|---|---|---|
| **M31** | `32-Clima` | 119/0/**2** | 🟡 119/121 | Sello **DENEGADO** 2026-10-15 (agnes-3-flash, msg 483): muestreo 8 `[x]` → 2 fallas (L23 RF5, L26 RF8) degradados a `[?]` |
| **M77** | `78-Legal-Propiedad-Intelectual` | 156/0/**1** | 🟡 156/157 | 1 ítem degradado después del re-sello del 2026-10-07 (Log 1444) |
| **M112** | `113-Pruebas-De-Stress` | 131/0/**1** | 🟡 131/132 | Degradación del auditor de citas en **P5b** (mi propia corrida, msg 370) → `132/132 ✅` pasó a `131/132 🟡` |
| **M101** | `102-Bug-Tracking` | 142/0/0 | 🔵 **En curso** 142/142 | Cerrada en disco; la celda `Estado` nunca se movió de "En curso (DS-WB normalizando)" |
| **M115** | `116-Instalador` | **199**/0/0 | fila **corrupta**: progreso `192/192` | La fila perdió el nombre del módulo (§6) y el progreso quedó en 192 |
| **M124** | `125-Terminos-De-Servicio` | 105/0/0 | 🟡 105/105 | La nota de la fila dice literalmente *"Veredicto ✅ Completado (re-verify independiente válido)"* pero la celda quedó en 🟡 |

**Propuesta:** revertir `M31`, `M77` y `M112` a `[ ]` (el módulo ya no está cerrado; la marca miente
aunque no sea culpa de quien la puso). Para `M101`, `M115` y `M124` **no** propongo revertir: el
módulo está cerrado y lo que falta es corregir la fila del GLOBAL. Si el director corrige esas tres
filas, los tres pasan a candidatos y el índice subiría a **26 + 6 + 3 − 3 = 32/152**.

## 6. Hallazgo estructural: 8 filas del GLOBAL perdieron el nombre del módulo

Barrido de las **168** filas de datos de `CHECKLIST-GLOBAL.md`: **8 filas** tienen la celda *Módulo*
ocupada por `✅` en vez del nombre, y todo lo demás corrido una celda a la izquierda (el `Estado`
quedó con el texto del progreso, el `Progreso` con otro número, y la nota se derramó a la última
columna). **Siguen teniendo 11 celdas**, así que ni el verificador ni un conteo de celdas las
detectan.

| Línea | id | Celda Módulo | Celda Estado | Celda Progreso |
|---|---|---|---|---|
| L33 | 09 | `✅` | `108/113` | `100/105` |
| L50 | 112 | `✅` | `223/227` | `221/225` |
| L55 | 116 | `✅` | `196/196` | `192/192` |
| L57 | 118 | `✅` | `110/110` | `106/106` |
| L63 | 123 | `✅` | `123/125` | `106/108` |
| L89 | 144 | `✅` | `103/105` | `99/105` |
| L174 | 70 | `✅` | `198/198` | `139/198` |
| L203 | 99 | `✅` | `169/169` | `155/169` |

Verificado que **no es un artefacto de mi worktree**: `git status --porcelain CHECKLIST-GLOBAL.md`
sale vacío → las 8 filas están así en `HEAD`. Es un defecto preexistente y ajeno; **no lo toqué**
(archivo protegido).

Consecuencia práctica: en esas 8 filas el `Estado` que lee cualquier herramienta es un número, no un
emoji. Cuatro de ellas (70, 99, 116, 118) son justamente módulos **cerrados** (§7), así que el
defecto es lo único que impide flipearlos.

## 7. La palanca real de M01: 15 cerradas con GLOBAL no-OK

De los 126 `[ ]` del índice, **15 no son trabajo pendiente**: son módulos cuya checklist propia está
100 % cerrada (0 `[ ]` y 0 `[?]`) y que solo esperan que su fila del GLOBAL diga `✅`.

| Ítem | Carpeta | `[x]` | Estado actual de la fila | Bloqueo |
|---|---|---|---|---|
| M04 | `05-Lenguaje-Y-Programacion` | 103 | 🟡 Con dudas | Progreso stale: GLOBAL `99/103` vs disco `103/103` |
| M35 | `36-Fauna` | 228 | 🟡 Completado (texto mixto) | Estado contradictorio; GLOBAL `227/228` |
| M69 | `70-Interacciones` | 198 | fila corrupta | §6 |
| M94 | `95-Monetizacion` | 115 | 🟡 Con dudas | — |
| M98 | `99-Marketing` | 169 | fila corrupta | §6 |
| M101 | `102-Bug-Tracking` | 142 | 🔵 En curso | Celda Estado stale |
| M115 | `116-Instalador` | 199 | fila corrupta | §6 |
| M117 | `118-CI-CD` | 113 | fila corrupta | §6 |
| M118 | `119-Actualizaciones` | 124 | 🟡 QA-drift-doc | — |
| M124 | `125-Terminos-De-Servicio` | 105 | 🟡 Con dudas | Nota dice ✅ |
| M125 | `126-Marketing-Legal` | 101 | 🟡 Con dudas | — |
| M141 | `142-Release-Candidate` | 129 | 🟢 Disponible | — |
| M142 | `143-Lanzamiento` | 111 | 🟢 Disponible | — |
| M149 | `150-Diseno-Sonoro-Narrativo` | 150 | 🟡 (deuda implementación) | Deuda declarada |
| M152 | `153-Objetivo-Final` | 130 | 🟡 (deuda externa delegada) | Deuda declarada |

De estas 15, **5 se destraban solo corrigiendo la fila** (M04 progreso stale, M69/M98/M115/M117 filas
corruptas) y **2 más** corrigiendo la celda `Estado` (M101, M124). Las otras 8 tienen deuda real
declarada y no son candidatas.

## 8. Mapa de lotes de los 126 restantes

| Lote | Definición | Módulos | Trabajo que implica |
|---|---|---|---|
| **A** | 0 `[ ]` pero `[?]` > 0 | **61** | Resolver `[?]` ajenos. No es trabajo de M01 |
| **B** | 1 a 5 `[ ]` | **9** | Cierre corto de otro módulo |
| **C** | 6 a 20 `[ ]` | **13** | Tanda media de otro módulo |
| **D** | más de 20 `[ ]` | **28** | Módulo abierto, no cerca |
| **E** | sin checklist propia | **0** | — |
| **F** | cerrada, GLOBAL no-OK | **15** | **La única palanca de M01** (§7) |
| — | ya `[x]` válidos | 20 | — |
| — | candidatos nuevos | 6 | §4 |

61 + 9 + 13 + 28 + 0 + 15 + 20 + 6 = **152**.

Lote **B** (el más barato si el director quiere mover el índice rápido):

| Ítem | Carpeta | x / ? / `[ ]` |
|---|---|---|
| M03 | `04-Game-Engine` | 126 / 0 / 2 |
| M64 | `65-Animales-IA` | 89 / 0 / 1 |
| M75 | `76-Multijugador` | 129 / 0 / 1 |
| M106 | `107-Backups` | 177 / 0 / 5 |
| M14 | `15-Recursos` | 205 / 10 / 4 |
| M59 | `60-Datos-Y-Serializacion` | 189 / 4 / 3 |
| M61 | `62-Memoria` | 145 / 4 / 1 |
| M65 | `66-Anti-Softlock` | 110 / 5 / 2 |
| M138 | `139-Pre-Alpha` | 139 / 2 / 1 |

`M106` → `107-Backups` es mío y está a **5 `[ ]`**: los 5 pasos de Google Cloud (L204-208) que
documenté en `03-Diseno.md` §5.1 esta misma semana. Su ejecución depende del fundador (su cuenta
Google), no de código.

## 9. Límites de este diagnóstico

- **Mide marcas, no re-verifica contenido.** El criterio de las iters. 6/7 es "checklist cerrada Y
  GLOBAL `✅`". Que un ítem esté `[x]` no prueba que su artefacto exista: eso es el QA de cada módulo.
  Por eso los 6 candidatos se proponen **con la evidencia de QA que ya declara su propia fila**, y no
  como un aval mío.
- **No flipeé nada.** El `05-Checklist.md` de M01 y `CHECKLIST-GLOBAL.md` quedan intactos: los flips
  los aplica el director (regla del proyecto).
- **No toqué las 42 inconsistencias** que reporta `verificar_checklist.py`: son ajenas y
  preexistentes. El desglose completo está en `out/_m01_verif.txt` de esta corrida.

## 10. Pedidos al director

1. **Aplicar los 6 flips** de §4 (M05, M18, M21, M89, M99, M113) → índice **32/152**.
2. **Revertir 3 `[x]` stale** de §5 (M31, M77, M112) → quedan 29 `[x]` + 3 candidatos condicionados.
3. **Corregir las 8 filas corruptas** de §6 (ids 09, 70, 99, 112, 116, 118, 123, 144): recuperar el
   nombre del módulo y realinear las celdas. Con eso M69, M98, M115 y M117 pasan a candidatos.
4. **Corregir la celda `Estado`** de M101 (`102-Bug-Tracking`, 🔵 → ✅) y M124
   (`125-Terminos-De-Servicio`, 🟡 → ✅): ambas tienen el cierre y el sello en la propia nota.
5. **Decidir sobre M89** (`90-Configuracion-Grafica`): está en mi lista de NO TOCAR; el flip es del
   ítem del índice, no del módulo.
6. **Reposición de cola**: la tarea 1 de mi cola activa quedó agotada con este refresco (iters 6, 7 y
   8). Las tareas 2-4 del bloque A son el mismo diagnóstico con otro nombre; pido que se reemplacen.
