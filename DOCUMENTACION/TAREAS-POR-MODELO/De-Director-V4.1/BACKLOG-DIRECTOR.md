# BACKLOG DEL DIRECTOR — De-Director V4.1

**Modelo:** De-Director V4.1 (DeepSeek V4.1 Flash)
**Plataforma:** OpenCode
**Fecha:** 2026-10-15
**Rol:** Director (pasamanos: leer → clasificar → reenviar → responder; sellos §21.8 y flips de marca)
**Historial:** migrado desde `TAREAS-POR-MODELO/mimo-v2.6-flash-free/` al asumir el 2026-10-15 (tercera directiva del fundador). Las tareas de abajo son de la etapa mimo (2026-10-14); las no marcadas quedan como referencia histórica — la cola vigente está al final.

> Este backlog es la cola de trabajo del DIRECTOR. Los backlogs de ejecución
> (step-5, agnes, etc.) viven en sus propias carpetas.

## Tareas de estratega (prioridad alta)

- [ ] **T-E01:** Actualizar `ESTADO-PARALELO.md` con los roles redistribuidos post-atria
- [ ] **T-E02:** Responder a step-5 362 (evaluación flota) y agnes 429 (propuesta redistribución) confirmando la decisión
- [ ] **T-E03:** Asignar M141-Beta QA cruzado a agnes (146/147, sin QA desde que s2 cerró)
- [ ] **T-E04:** Verificar estado de WorkBuddy (M04 iter 10, llevaba sin reportar)
- [ ] **T-E05:** Verificar estado de DeepSeek (M05 95/103, M01 26/152)
- [ ] **T-E06:** Asignar siguiente módulo a step-5-kilocode (M141 secciones restantes, o Módulo nuevo)
- [ ] **T-E07:** Asignar siguiente módulo a agnes (M148 b7-b12, o verificación de M141)
- [ ] **T-E08:** Decidir si Hy3 toma QA de algún módulo ✅ sin sello (hay ~75 sin verificar según s3)
- [ ] **T-E09:** Crear plan de QA cruzado para los módulos cerrados hoy (M139, M140, M141, M148)
- [ ] **T-E10:** Documentar decisión de redistribución en `AGENTS.md` §31 (rol de director actualizado)

## Tareas de director (prioridad media)

- [ ] **T-D01:** Flip M141 146/147 en CHECKLIST-GLOBAL (ya hecho, verificar)
- [ ] **T-D02:** Flip M148 95/117 en CHECKLIST-GLOBAL (ya hecho, verificar)
- [ ] **T-D03:** Verificar que ESTADO-PARALELO no tenga módulos 🔵 colgados >24h
- [ ] **T-D04:** Revisar si Hy4 está disponible para tareas puntuales de modelado 3D
- [ ] **T-D05:** Actualizar §31 AGENTS.md: mimo ahora absorbe rol de estratega (s3)

## Cola de delegación (actualizada 2026-10-14 20:55)

| Prioridad | Modelo | Módulo | Estado | Siguiente acción |
|---|---|---|---|---|
| 1 | step-5-kilocode | M141-Beta | 146/147 | Secciones restantes, o módulo nuevo |
| 2 | agnes | M148-Lore | 95/117 | b7-b12 pendientes, o QA de M141 |
| 3 | agnes | — | libre | QA cruzada M141 (146/147) |
| 4 | Step-5-WorkBuddy | M04 | 116/128 | Verificar si sigue activa |
| 5 | DeepSeek | M05 | 95/103 | 8 [ ] restantes |
| 6 | DeepSeek | M01 | 26/152 | Continuar barrido |
| 7 | Hy3 | QA módulos ✅ | — | Solo si agnes está ocupada |

## Módulos cerrados hoy (no reasignar)

| Módulo | Cierre | Responsable | QA pendiente |
|---|---|---|---|
| M139-Pre-Alpha | 133/142 | step-5 | ✅ s2 (sello válido) |
| M140-Alpha | 100/124 | step-5 | ⏳ pendiente |
| M137-Prototipo | 8/131 (ref) | step-5 | N/A (diseño ref) |
| M141-Beta | 146/147 | step-5 | ⏳ pendiente |
| M148-Lore | 95/117 | agnes | ⏳ pendiente (parcial) |
| M70-Interacciones | 109/198 | agnes | ⏳ pendiente |
| M48-Animación | 22/123 | agnes | ⏳ pendiente |
| M15-Recursos | 190/219 | agnes | ⏳ pendiente |

## Cola vigente — De-Director V4.1 (desde 2026-10-15)

- [x] **T-I01:** Cambio de identidad del director: carpeta `De-Director-V4.1/` + IDENTITY.md, migración del tooling, actualización de `AGENTS.md` (§10.2/§10.3/§30.1/§30.5/§31), `GUIA-COMUNICACION.md` y `ESTADO-PARALELO.md`. Log reservado: **1872**.
- [ ] **T-I02:** Responder a agnes 487 (M11 antidrift): refrescar las notas obsoletas de `11-*/plan-actual/04-Codigo.md` + arreglar la fila 45 malformada de `CHECKLIST-GLOBAL.md`.
- [ ] **T-I03:** Seguimiento de la flota: M91 resto (step-5), M87+i18n (Ling), QA M114 + M39 (agnes), M141+M52 (Hy3), M94 (Step-5-WorkBuddy).
- [ ] **T-I04:** Anuncio a la flota del cambio de director — pendiente de confirmación del fundador (¿lo mando yo por los canales o lo hace él?).
- [ ] **T-I05:** Elevar al fundador las preguntas abiertas: política DoD (M89/M88/M99), audición de los 52 WAV, CI rojo (`quality.yml`, M118).

**Firma (histórica):** mimo-v2.6-flash-free (Director) / opencode — 2026-10-14 20:55

**Firma (vigente):** De-Director V4.1 (DeepSeek V4.1 Flash) / OpenCode — 2026-10-15
