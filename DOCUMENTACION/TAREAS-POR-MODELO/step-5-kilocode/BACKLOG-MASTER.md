# Backlog Master — step-5-kilocode

> **Estado:** ⚪ A la espera de asignación (backlog limpio, revisado 2026-10-13 ~19:30, msg 280 del director) — funcional directo, prioridad del director
> **Sesión:** `ses_ee2159967ffeZWsqhZj75LT4xF`
> **Rol:** Auditoría anti-inflación + QA §21.8 con sondas rojas. **El ejecutor más fiable de la flota.**

## Identidad

- **Modelo:** step-5-kilocode
- **Plataforma:** Kilo Code (canal `Mensajes entre modelos/step-5-kilocode/`)
- **Alta en la guía:** 2026-10-10, sección §21.17 de `10-GUIA-COMPARATIVA-MODELOS.md`
- **Regla de entrega:** **NUNCA por Agent Manager** (el reply falla). Siempre por canal con
  `python scripts/reservar_mensaje.py step-5-kilocode "<tema>" --emisor step-5-kilocode`

## Historial verificado (18 entregas consecutivas sin error)

| Encargo | Resultado | Verificado por |
|---|---|---|
| Triaje E-12d M110-Debug-Menu (5 bloques, 89 ítems) | **0 errores de conteo**, 90 `[?]` → 0 | s3 (QA §21.8, 115 checks 0 fallos) |
| QA §21.8 M24-Templos-Y-Puzzles | 126/1/1, 14 ítems muestreados, 3 suites binario real → **SELLADO** | director msg 32 + s3 (re-corrió `test_puzzles.gd`, 0 fallos) |
| BUG E-10 (M50 spawner leak) | cerrado; refutó su propia hipótesis con instrumentación | s3 re-verificación |
| BUG E-11, E-12b/c | cerrados | s3 |
| BUG-034 bloque 1 (19 filas sellos Hy3) | 19 VÁLIDAS / 6 DÉBILES / 0 INVÁLIDAS | msg 35 |
| BUG-034 bloque 2 | **EN CURSO** (54+26 filas, sub-bloques ~18-20) | — |

**Comportamiento clave:** honestidad que se auto-regula (ofrió bajar su propio `[x]` en L268),
corrige al director con evidencia (midió el archivo antes de aceptar el encargo), distingue
inflación de drift (M24 L229).

## Tareas

### Cerradas (historial previo)

- [x] **BUG-034 bloque 2** (CERRADO 2026-10-13, msg 255: 83 filas auditadas, 0 violaciones §21.8.4; el registro de hy3 está sano) — 54+26 filas de sellos §21.8 de Hy3 en `CHECKLIST-QA-SEALS.md`.
      Sub-bloques de ~18-20. ⚠️ Hy3 verificó módulos que él mismo implementó → marcar cada
      violación de la regla de independencia §21.8.4. (Delegada por el director, msg 36.)

### En cola (delegadas)

- [x] **S1 — Auditoría anti-inflación de M48-Animacion** (CERRADO 2026-10-13, msg 256: M48 honesto en 9/123, 9/9 [x] respaldados en disco, 2 suites verdes 8/0 y 12/0, 0 inflación. NOTA: la advertencia de que el núcleo no existía era del LOTE 9 de BUG-070, previo a mi Fase 1 del Log 1603) (delegada, director msg 159). Prioridad 1
      de la flota. M48 declara 9/123 pero el LOTE 9 de BUG-070 verificó que su núcleo **no existe
      en disco** (`validate_animation.gd`, `jugador_lib.tres`, `npc_humanoide_lib.tres`, 0 hits).
      Método E-12d: contar → verificar artefacto contra disco → clasificar binario. **READ-ONLY
      absoluto** (el director aplica los flips). Entra al terminar BUG-034 sub-bloque 2C. M48
      subido a 🔴 en `CHECKLIST-GLOBAL.md`.

### Pendientes (sugeridos por s3, sin delegar)

- [x] **S2 — QA §21.8 de M53-UI-UX** (CERRADO 2026-10-12, msg 242: 143→144/165, 17 ítems muestreados, 4 suites verdes, BUG-133 resuelto; 1 ítem inflado detectado y 2 falsos negativos) (cuello de botella #1: 11 módulos lo esperan, 🟡 139/165).
      Independencia ✓ (lo trabajaron Hy4 y glm-5.3-flash, ambos inactivos).
- [x] **S4 — Barrido de inflación en módulos ⬜/🟢 sin tocar** (CERRADO 2026-10-12, msg 246: M01/M02/M98/M99 barridos, 2 drift de Totales, M99 violaba DoD y fue bajado de ✅) (M01 0/152, M02 0/172, M98, M99).
      Su precisión de conteo los dejaría honestos de una pasada.

### Cerradas jornada 2026-10-12/13 (msg 273–280, aceptadas por el director en msg 279 y cerradas en msg 280)

- [x] **R5 — Rename de identidad stepfun-step-5-preview → step-5-kilocode** (CERRADO 2026-10-13, msg 274: barrido de 572 archivos / 1735 hits, 0 residuos; canal y carpeta de tareas movidos con `git mv`; 275 mensajes renombrados conservando prefijos numéricos) — commits del rename + firma actualizada en 44 logs propios.
- [x] **R6 — Barrido de inflación §21.8.2.b en 7 módulos del lote M137–M144** (CERRADO 2026-10-13, msg 276: 92 `[x]` muestreados contra disco, 1 ítem inflado detectado —Integrar precios desde curvas.json, archivo inexistente— y 1 parcial —anti-stuck sin teleport/waypoint—; M139 degradado a `[?]` con Log 1807; M137/M138/M140/M142/M143/M144 quedaron 🟢 sin inflación).
- [x] **R7 — Línea Totales de M122-... (checklist)** (CERRADO 2026-10-13, msg 278: línea `264 items · Completados: 254 · Pendientes: 0 · No resueltos: 10` agregada, commit `347454b`).
- [x] **R8 — Fix de `reservar_mensaje.py` (numeración + plantilla en cuerpo)** (CERRADO 2026-10-13, msg 278: bug de ruta larga en Windows que rompía `max()` corregido —commit `54bff2e`— y bloque `PLANTILLA RESERVADA` quitado del cuerpo generado, ahora solo en consola —commit `0c1475b`).
- [x] **R9 — Fix de `verificar_pool_numeros.py` + cierre de colisiones 95/96 + fuga de pool 171** (CERRADO 2026-10-13, msg 278: lista hardcodeada de 7 canales reemplazada por descubrimiento dinámico de `Mensajes entre modelos/`, commits `3dcad62` y `f062fac`).
- [x] **R10 — Cierre de jornada y espera de nueva asignación** (CERRADO 2026-10-13, msg 280: informe final enviado, director confirmó los 4 encargos y ordenó limpieza del backlog propio; este documento es el resultado de esa limpieza).
- [x] **R13 — Auditoría de `[?]` con Patrón D, 10 bloques (M27, M74, M34, M11)** (CERRADO 2026-10-13 21:15, msg del director 16:35 + reenvío de s3 185 + cierre msg 2032: **230 `[?]` auditados, 2 promociones**). Detalle por módulo: M27 66→1 promo (es_flotante) commits `337b5f2`/`f9e7d2a` Totales 127/192 · M74 59→1 promo (M154) commit `b9ba71e` Totales 227/285 + hallazgo 3 duck-typing roto · M34 54→0 promos commit `fdea098` Totales 99/154→153 + 3 stubs reales · M11 51→0 promos commit `89de8d8` + 3 ítems desactualizados. Logs 1819/1821/1823/1824. Informes 2029/2030/2031/2032.
- [x] **R14 — Msg 500 del director: 3 encargos** (CERRADO 2026-10-13 23:30, informe 501 + log 1829): (1) fix mojibake acotado a los 2 SUCIOS de houses (`house_interior.gd` 6 marcadores, `test_m18_sistemas_s2.gd` 3) — commit `ebd13ba`, UTF-8 sin BOM sin drift de líneas; (2) reescritura con cita de discrepancia y promoción de los 3 ítems desactualizados de M11 (sprint FACTOR, InteractionService→interaction_manager 4 m, AnimationPlayer 3 clips) — commit `0e0f521`, M11 pasa a 75/123; (3) deuda de duck-typing de M74 documentada en la sección 5 de `04-Codigo.md` con dueños asignados (M20/M71/M37) — commit `863fb5b`.
- [x] **R12 — Higiene de líneas Totales M15/M16** (CERRADO 2026-10-13, msg 281 del director: drift +10 (M15: 162→172) y +1 (M16: 154→155) corregidos solo en la línea Totales, marcas de agnes intactas; commit `528cfac` con pathspec explícito).
- [x] **R15 — Corrección de numeración de mensajes de la flota (pedido directo del fundador)** (CERRADO 2026-10-14): 8 canales corregidos — step-5-kilocode (496/497/498/499 → 296/290/288/286, canal re-numerado completo 280→327 con pool reconstruido), atria-dawn (200/199 → 92/93 + nombres sin fecha normalizados), DeepSeek (499/500 → 232/233), Hy3 (498 → 199), agnes (16 archivos 500-512 → 395-410 en orden cronológico, 0 duplicados, referencias verificadas), Step-5-WorkBuddy (19/20 duplicados → 19-22), mimo (499 duplicado → 197/198/199 + fuga del pool). 14 pools reconstruidos contiguos. Causa raíz documentada: bug del regex año-como-número en `reservar_mensaje.py` + reserva manual del director. Informes 201, 295, 300, 302, 322 al director.
- [x] **R11 — Verificar commits de atria (M04 iter4+5, M35 lote 3)** (CERRADO 2026-10-14: el director confirmó en su msg 285 que los lotes ya estaban commiteados y pusheados a origin — mi verificación inicial fue anterior al commit; frente cerrado sin acción pendiente).

## Límites (regla de independencia §21.8)

- **No puede verificar módulos que él mismo triaje.** Si hace el triaje, la QA la hace otro (s3 o
  Hy3).
- **Sin evidencia de arquitectura visual / escenas 3D.** Su nicho es auditoría y verificación.
- **Sin evidencia de implementación nueva.** Hizo triaje y QA, no codeó módulos desde cero.

## Reglas del protocolo

1. `AGENTS.md` (raíz) — la regla maestra.
2. Trabajás desde este backlog. NO vayas a `CHECKLIST-GLOBAL.md` a buscar trabajo.
3. Marcado: `[ ]` pendiente · `[→]` en progreso · `[x]` completado · `[?]` no resuelto.
4. Al completar, marcar los TRES lugares: este backlog + `05-Checklist.md` del módulo +
   `CHECKLIST-GLOBAL.md`.
5. **Un `[?]` vale más que un `[x]` falso.** Sin excepciones.

## Registro de logs reservados

- [x] Log creado: **1768** — BUG-098, 2 archivos con parseo roto corregidos (renumerado desde 1690 el 2026-10-12 por colisión de número, orden del director mimo msg 215; el 1690 original quedó para Ling 3.1 Flash).
- [x] Log creado: **1807** — M139, 2 ítems degradados a `[?]` por evidencia (`Integrar precios desde curvas.json`: archivo inexistente; `Implementar anti-stuck con teleport a waypoint`: sin teleport ni waypoint en disco).
- [x] Log creado: **1815** — Limpieza del backlog propio (msg 280 del director): conteo regex antes/después, alta de las 6 tareas cerradas R5–R10 de la jornada 2026-10-12/13 y corrección del residuo de firma `stepfun-step-5-Preview` en el Log 1729.
- [x] Log creado: **1817** — Commits de atria verificados (PENDIENTES de commit), Totales M15/M12 corregidos (commit `528cfac`) y auditoría M27 b1 (0 promociones, 10 `[?]` anotados). Incluye hallazgo de mojibake en `.gd` del juego.
- [x] Log creado: **1819** — M27 auditada completa (66 `[?]`: 1 promo es_flotante), inventario de mojibake (2 SUCIOS reales en `houses/`) y corrección del falso positivo de mojibake del informe anterior.
- [x] Log creado: **1821** — M74 auditada completa (59 `[?]`: 1 promo M154); hallazgo de 3 consumidores de recompensa con duck-typing roto/dormido (M20/M71/M37).
- [x] Log creado: **1823** — M34 auditada completa (54 `[?]`: 0 promos); 3 stubs reales de M34 identificados (es_agua_pescable, spot_apunta_desde, marcador visual) + Totales 84/69→99/54.
- [x] Log creado: **1824** — M11 auditada completa (51 `[?]`: 0 promos); 3 ítems desactualizados detectados (sprint sí existe, InteractionService sí tiene equivalente M70, AnimationPlayer sí existe con 3 clips) + deuda real (sin data/player/, PlayerEnergy sin cablear).
- [x] Log creado: **1829** — Msg 500: fix mojibake houses (2 archivos, 0 marcadores restantes), reescritura de 3 ítems M11 con promoción (75/123) y deuda duck-typing M74 documentada para dueños.
