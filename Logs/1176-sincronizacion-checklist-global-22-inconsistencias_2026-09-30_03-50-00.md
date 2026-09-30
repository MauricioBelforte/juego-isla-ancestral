# Log 1176: Sincronizacion de CHECKLIST-GLOBAL con los checklists reales (22 inconsistencias)

**Fecha:** 2026-09-30
**Hora:** 03:50
**Modelo:** atria-dawn-s2
**Plataforma:** Kilo Code

## Resumen

Sesion de auditoria posterior al MERGE-FINAL del coordinador (atria-dawn-preview,
Log 1171). `scripts/verificar_checklist.py` detectaba 22 inconsistencias entre la
columna Progreso de CHECKLIST-GLOBAL.md y los `05-Checklist.md` reales. Se
sincronizaron las 22 filas al valor real y se verificar EOL, mojibake y staging.

## Cambios Realizados

1. **Selftest obligatorio (AGENTS.md 21.9):** `python scripts/test_scripts.py`
   -> **10 PASS, 0 FAIL** (la version actual del script trae 10 tests, no 8).
2. **Dry-run de `generar_checklist_global.py`:** 45 cambios propuestos. Se
   detectaron DOS efectos destructivos del modo escritura:
   - Normaliza 220 `\r\r\n` -> `\r\n` (defecto M-06: re-encode masivo de EOL,
     diff de 490 lineas).
   - `inferir_estado` sube 12 modulos `Liberado (iter. ...)` a `En curso`
     (bloqueos fantasma sin agente, prohibido por 21.4.5) y degrada 9 sellos
     `Completado (P-36)` / `Re-verificado` / `Verificado` a estados planos.
3. **Revision de los 7 casos sospechosos (GLOBAL > checklist)** leyendo cada
   `05-Checklist.md` real + historial git. En TODOS el checklist real es la
   fuente de verdad (ver detalle en "Decisiones sobre los 7 casos").
4. **Restauracion desde HEAD** y sincronizacion quirurgica con
   `scripts/editar_crlf.py` (guard anti-M-03): 22 reemplazos por ID de modulo,
   solo la columna Progreso. EOL CRLF + CR-doble preservado byte-exacto.
5. **Commit local** (push negativo, solo CHECKLIST-GLOBAL.md en staging).

## Decisiones sobre los 7 casos (GLOBAL miente)

| Modulo | GLOBAL | Real (checklist) | Evidencia |
|---|---|---|---|
| 72-Sistema-De-Logros | 87/185 | **1/185** | commit e261ced revertio 189 [x] a [ ] (auditoria anti-inflacion agnes-2.5-flash); el propio archivo lleva nota de drift atria-dawn-preview 2026-09-20: "Conteo real: 1 [x] / 184 [ ]. Las marcas no se tocaron" |
| 131-Creditos | 87/99 | **83/94** | re-marcado por mimo v2.5 (2026-09-20) contra codigo real (credits_manager.gd 323 lineas); linea Totales del archivo: "94 items, 83 [x], 9 [?], 2 [ ]" |
| 93-Balance | 134/134 | **131/134** | conteo propio: 131 [x], 3 [ ] |
| 167-Isla-Raiz | 114/114 | **113/114** | conteo propio: 113 [x], 1 [ ] |
| 85-Modelos-3D-Legal | 100/100 | **99/100** | conteo propio: 99 [x], 1 [ ] |
| 94-Retencion-Sin-FOMO | 135/135 | **138/138** | conteo propio: 138 [x]; el total crecio de 135 a 138 (GLOBAL quedo corto) |
| 131 totales | 99 total | **94 total** | el checklist real tiene 94 items (mismica de 131 reducida en la iteracion mimo v2.5) |

Los 15 casos restantes (GLOBAL < checklist, drift a favor): 09, 103, 107, 115,
12, 126, 128, 149, 150, 156, 160, 25, 31, 39, 54, 64 — sync directa.

## Archivos Modificados/Creados

- `CHECKLIST-GLOBAL.md` — 22 lineas (columna Progreso), commit 16b2583
- `Logs/1176-sincronizacion-checklist-global-22-inconsistencias_2026-09-30_03-50-00.md` (este log)
- `Logs/NUMEROS_DISPONIBLES.txt` — consumido el numero 1176 (primer linea del pool)

## Verificaciones

- `test_scripts.py` -> 10 PASS, 0 FAIL
- `verificar_checklist.py` -> **0 inconsistencias de progreso**; 62 avisos de
  "bloqueo colgado" (ruido de parseo conocido: la columna "Ultima actividad"
  tiene prosa en vez de fecha; no era tarea de esta sesion tocarla)
- `diagnosticar_mojibake.py` -> LIMPIO (0 SUCIO, 0 IRREVERSIBLE)
- EOL: CRLF=231, CR-doble=220 — identico a HEAD (sin re-encode)
- Staging del commit: SOLO CHECKLIST-GLOBAL.md (trampa 70/114 desactivada)

## Lo que NO se hizo (honestidad)

- **No se corri el modo escritura de `generar_checklist_global.py`** porque su
  dry-run era incoherente con el protocolo (M-06 + bloqueos fantasma). Si el
  coordinador quiere ademas la recategorizacion de estados, hay que arreglar
  `inferir_estado` (respetar "Liberado" y no crear En curso huerfanos) y
  re-correr.
- **No se tocaron** los 05-Checklist.md (fuente de verdad), ni la columna
  Estado / Ultima actividad / Notas de CHECKLIST-GLOBAL, ni los ~60 avisos de
  bloqueo colgado.
- **No se hizo push** (commit local unicamente, 16b2583).

## Cosas raras encontradas (para el coordinador)

1. En el working tree habia (y hay) archivos sucios ajenos: 4 `villagers/*.tres`
   + `narrative_sound.gd` + `mercedes_lince.tres` (sin seguimiento) y
   `Logs/NUMEROS_DISPONIBLES.txt` ya modificado (M) antes de mi sesion — no los
   toque ni los comitee. Confirmar de quien son.
2. **9 sellos Completado en contradiccion con el conteo** (el script los
   degradaba): 103, 106, 122, 14, 29 (tienen `[?]`), 36, 65, 85, 93, 168 (tienen
   `[ ]`). Segun el DoD 21.6 no deberian ser Completado — pero degradarlos a
   mano borraba sellos de QA con contexto ("Completado (P-36)", "Verificado").
   Se dejo intacto; decision del coordinador.
3. `115-Hardware` dice "Liberado (iter. agnes)" adelante de "deepseek-v4-flash"
   en Agente actual — ambiguo.
4. `131-Creditos`: el merge f74de58 dejo el checklist sin acentos
   ("Creditos", "espanol") — de-acentuacion ASCII por mimo v2.5, no mojibake
   (diagnosticar_mojibake da limpio). Cosmetico.
5. En la fila de M62 las "Notas" de atria-dawn mencionan que "3 celdas basura
   insertadas (agnes-2.5-flash / fecha / Reclamado)" fueron removidas y la
   estructura volvio a 10 columnas — la fila M156 parece tener un campo
   desplazado (Estado dice "glm-5.3-flash"?). No toque, pero M156 quizas tenga
   la columna Estado contaminada con un nombre de modelo.
