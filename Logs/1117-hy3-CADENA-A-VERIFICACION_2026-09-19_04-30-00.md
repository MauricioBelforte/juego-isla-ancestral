# Log 1117 — hy3 / WorkBuddy — Corrección BUG-050 + verificación cadena A

**Fecha:** 2026-09-19
**Modelo:** Hy3 / WorkBuddy (Tencent Hunyuan)
**Tarea:** (1) Aplicar corrección urgente del usuario sobre BUG-050 (retractar "36 módulos sobre-cerrados"); (2) verificar con código los over-marks de "cadena A" en M114(2)/M118(4)/M119(1)/M136(1).

## Contexto (Mensaje 5 del usuario)
El usuario corrigió mi auditoría BUG-050: los 5 sellos genuinos (M80/M81/M82/M85/M86) se confirman y quedan; PERO la conclusión "36 módulos sobre-cerrados / filas GLOBAL falsas" no se sostiene. Las columnas Estado/Progreso de CHECKLIST-GLOBAL son exactas (M01 0/152, M100 146/222, M124 83/108); no hay módulo falsamente ✅; no revertir estados. El defecto real es solo la frase "Verificado por Hy3" (cita logs AGNES 866/867) — misatribución de sello, limpieza propiedad de s2/T-L11. Además: verificar con código la cadena A de over-marks en los ✅ (M114 2, M118 4, M119 1, M136 1).

## Parte A — Corrección BUG-050 (aplicada)
- CHECKLIST-QA-SEALS.md: Nota "80-86/BUG-050" reescrita con FE DE ERRATAS. Los 5 sellos (M80/M81/M82/M85/M86) se confirman; se retracta "36 sobre-cerrados"; se aclara que GLOBAL Estado/Progreso es exacto y que la limpieza de misatribución es de s2/T-L11.
- Logs/1111-hy3-BUG050-LOTE: sección "NO sellables (36)" retractada vía FE DE ERRATAS.
- .workbuddy-ai/memory/2026-09-19.md: mismo retoque.
- **No se revirtió ningún estado de módulo.** No se tocó CHECKLIST-GLOBAL.md ni NUMEROS_DISPONIBLES.txt.

## Parte B — Verificación con código de la "cadena A" (M114/M118/M119/M136)
Método: para cada over-mark [x] identificado por s2 (o hallado en M136), leer el texto del ítem y comprobar si el artefacto citado existe en el repo. Caso A = artefacto ausente -> marca falsa (descartar). Caso B = diseño/doc legítimo.

### Resumen
| Módulo | # over-marks | Clasif. s2 | Artefacto citado | ¿Existe? | Veredicto |
|--------|--------------|-----------|------------------|----------|-----------|
| M114 Playtest | 2 | A=0/B=2 | 03-Diseno.md §2.1 (NDA), §2.2 (briefing) | SÍ | **Caso B** |
| M118 CI-CD | 4 | A=0/B=4 | 03-Diseno.md (itch.io prose) + workflows GH Actions | Doc SÍ / workflows NO | **Caso B** (+ brecha implementación) |
| M119 Actualizaciones | 1 | A=0/B=1 | 03-Diseno.md §5 (Compatibilidad de Saves) | SÍ | **Caso B** |
| M136 Roadmap | 1 | (no en s2) | ROADMAP.md + hitos/137..143 | SÍ | **Caso B** |

### Detalle
**M114 (2 over-marks):** líneas 34 y 48 del 05-Checklist: "[x] Exigir firma de NDA..." y "[x] Escribir el discurso de briefing estándar en español (5 min)...". Ambos son KnownIssue no bloqueante DoD; el [x] significa "política/spec documentada". CODE CHECK: `DOCUMENTACION/114-Playtest/plan-actual/03-Diseno.md` existe y documenta §2.1 (Guía de sesión, NDA requerido) y §2.2 (Guion de preguntas, briefing 5 min). M114 es módulo de procesos/documentación, no de código (su propio 03-Diseno.md línea 8: "módulo de procesos y documentación operativa, no de código del juego"). -> Caso B, no marca falsa.

**M118 (4 over-marks):** "[x] P5: despliegue a itch.io al crear tag semver [S]", "[x] Subida a Itch.io (manual trigger) [S]", "[x] Email a stakeholders en tags [S]", "[x] Validación en GitHub Actions real (firebelley v5.2.1 puede necesitar actualización) [S]". CODE CHECK: `.github/workflows/` contiene SOLO bug_metrics, testing, dev-build, release-build, backup, quality. **NO** existe workflow de itch.io, ni email-a-stakeholders, ni validación firebelley. `03-Diseno.md` de M118 menciona itch.io solo como prose (líneas 20/40/82), sin workflow concreto §3.10. -> Los ítems son diseño/espec ([B], dueño CI-CD). BRECHA REAL: los pipelines de CI/CD descritos NO están implementados en `.github/workflows/`. Si el [x] se interpreta como "implementado en CI", es un gap a señalar; si como "diseñado/especificado", es legítimo. M118 es SIN SELLO en QA-SEALS (Log 1072) -> sus over-marks no invalidan sello real alguno.

**M119 (1 over-mark):** "[x] Compatibilidad con versiones anteriores de saves — KnownIssue no bloqueante DoD (dueño M59) [M]". CODE CHECK: `03-Diseno.md` §5 documenta "Compatibilidad de Saves" con diseño de migración por versión (SaveMigration/SaveMigrator). KnownIssue con dueño M59. -> Caso B, no marca falsa.

**M136 (1 over-mark):** línea 253 del 05-Checklist: "[x] Especificar la plantilla de ROADMAP.md (Pendiente de implementación) [S] -> IMPLEMENTADA 2026-08-28". El título dice "Pendiente" pero se resuelve inline ("-> IMPLEMENTADA"). CODE CHECK: `ROADMAP.md` + 7 checklists de hito (137-prototipo … 143-lanzamiento) existen como entregables. -> Caso B, no marca falsa (el entregable está presente).

## Conclusión
Los 8 over-marks de los 4 módulos ✅ son **todos Familia B** (diseño/documentación, KnownIssue no bloqueante DoD). **Ninguno es Familia A** (marca [x] de código inexistente). Los artefactos citados existen. Esto **reconfirma la corrección del usuario**: no hay sobre-cierre en estos módulos, GLOBAL Estado/Progreso es exacto, y no hay nada que revertir. La única brecha de implementación real encontrada es en M118 (workflows de despliegue ausentes), que es [B] y no afecta sello alguno.

**No se marcó ningún checklist** (verificación read-only, por instrucción). La limpieza de la misatribución "Verificado por Hy3" en GLOBAL queda para s2/T-L11.

## Reglas
- Push: NEGATIVO.
- NO se tocó CHECKLIST-GLOBAL.md ni NUMEROS_DISPONIBLES.txt.
- Verificador (hy3) != autores de implementación.

## FE DE ERRATAS (2026-09-19, hy3) — corrección del veredicto de M118

El veredicto "Caso B (+ brecha implementación)" para M118 en este log es **INCORRECTO**. El usuario (Message 6) lo corrigió: M118 es **Caso A (Familia A)**.

Motivo (lección del clasificador): chequear que el archivo `03-Diseno.md` exista NO alcanza. Hay que (a) parsear §X.Y y verificar el header real, y (b) para ítems de CI/CD, grepear `.github/workflows/`.
- `03-Diseno.md` de M118 solo tiene §1–§4; las citas §2.5, §3.9, §3.10 y §4.1 **no existen** (3 citas § fantasma).
- `.github/workflows/` tiene solo 6 workflows (backup / bug_metrics / dev-build / quality / release-build / testing): **ninguno** referencia itch.io / butler / stakeholders / firebelley.
- Los 4 ítems son de **implementación** (no diseño legítimo) → marca `[x]` falsa → se descartan (`[x]→[ ]`).

Consecuencia aplicada (Log 1125): M118 revertido ✅→🟡 (4 marcas, Totales 102/4/0), fila global + nota firmada. M118 no tiene sello, así que no se invalida sello alguno. Brecha registrada como **BUG-071**. Lo demás de este log (M114 / M119 / M136 = Caso B) se mantiene sin cambios.

**Firma:** hy3 (WorkBuddy), 2026-09-19.
