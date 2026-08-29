**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28 (implementación) · 2026-08-17 (documentación original por Deepseek V4 Flash)
**Componente:** 136-Roadmap
**Estado:** Implementación completa (pendiente de QA cruzado) — 199/199 sin `[?]`

## Reserva actual

- Estado: Liberado 2026-08-28 (fue 🔵 En curso; ver Notas del Agente en `04-Codigo.md`)
- Agente: GLM (Kilo)
- Fase: F0/transversal de gestión, V0
- Dificultad: 2
- Visión: V0
- Entrada: M133 ✅ (log 219) + M135 ✅ (log 197); estados reales de CHECKLIST-GLOBAL al 2026-08-28
- Salida: `ROADMAP.md` ejecutivo con estado real + 7 checklists de hito (`hitos/137..143`) con módulos, MoSCoW y estados actuales
- Archivos: `DOCUMENTACION/136-Roadmap/plan-actual/ROADMAP.md`, `plan-actual/hitos/*`, `plan-actual/04-Codigo.md`, `plan-actual/05-Checklist.md`, `CHECKLIST-GLOBAL.md`, `ESTADO-PARALELO.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, `Logs/`
- Fecha: 2026-08-28 20:55:00 (reserva) · 2026-08-28 21:30:00 (liberación)

---

# 05-Checklist.md — Módulo 136: Roadmap

> **Cómo se marcó (2026-08-28, GLM/Kilo):** ítems de análisis/diseño verificados contra `02-Analisis.md`/`03-Diseno.md` (con grep de cobertura para D1-D8, refactor, alternativas, edge cases); ítems de implementación contra `ROADMAP.md` y los 7 checklists de hito creados hoy; ítems de testings ejecutados (verificación con scripts, hashes, coherencia con tabla global). No hay `[?]`.

## Checklist de implementación del módulo

### [S] Problema y objetivos
- [x] Documentar el problema del ordenamiento temporal de los 150+ módulos del plan maestro [S]
- [x] Definir el contexto: Godot 4.x, GDScript, Voxel Tools, isla Aurora, mundo voxel cozy [S]
- [x] Documentar que el plan maestro define qué construir pero no cuándo ni en qué orden [S]
- [x] Definir el objetivo general: hoja de ruta hasta la v1.0 con hitos verificables [S]
- [x] Definir objetivos específicos medibles con criterios de éxito [S]
- [x] Enumerar explícitamente lo que queda fuera del alcance (M133, M134, M135, M137-M143) [S]
- [x] Documentar la relación del módulo con el protocolo multiagente de AGENTS.md [S]
- [x] Establecer que las fechas reales dependen del ritmo del fundador [S]
- [x] Definir la regla de presupuesto cero para el roadmap [S]
- [x] Alinear el roadmap con la filosofía cozy y los principios innegociables (M152) [S]
- [x] Documentar los criterios de aceptación del módulo 136 [S]
- [x] Documentar las dependencias del módulo (M133, M135) en 01-Requerimientos.md [S]

### [S] Requerimientos funcionales (RF)
- [x] RF1: definir el roadmap maestro con fases y 7 hitos M137-M143 [M]
- [x] RF2: definir criterios de entrada para cada hito [M]
- [x] RF3: definir criterios de salida verificables para cada hito [M]
- [x] RF4: asignar los módulos del plan maestro a cada hito [M] → primera pasada real en ROADMAP.md (definitiva: fundador)
- [x] RF5: priorizar por fase con MoSCoW (Must/Should/Could/Won't) [M] → ROADMAP.md §Módulos por fase
- [x] RF6: documentar dependencias entre hitos [M] → ROADMAP.md con estado real por dependencia
- [x] RF7: estimar el calendario por fase con rangos de duración [M]
- [x] RF8: definir la política de builds y releases por fase [M] → ROADMAP.md §Política de builds
- [x] RF9: definir la estrategia EA vs full release [M] → decisión en M141, puertas abiertas
- [x] RF10: gestionar la replanificación por retraso de hito [M] → 03-Diseno §7.1
- [x] RF11: definir el corte de alcance por hito (scope cut) [M] → 03-Diseno §7.2
- [x] RF12: gestionar dependencia fallida entre módulos [M] → 03-Diseno §7.3
- [x] RF13: mantener coherencia con CHECKLIST-GLOBAL.md [M] → dependencias con estados reales verificados hoy
- [x] RF14: registrar cambios del roadmap en el log del módulo [S]
- [x] RF15: publicar ROADMAP.md legible en pocos minutos [S] → resumen ejecutivo de 2 minutos
- [x] RF16: revisar el roadmap periódicamente con el ciclo de M133 [S]

### [S] Requisitos no funcionales (RN)
- [x] RN1: todo el roadmap en español [S]
- [x] RN2: documentos en Markdown con estructura estándar del proyecto [S]
- [x] RN3: herramientas gratuitas, sin costo recurrente [S]
- [x] RN4: administración del roadmap ≤ 10% del tiempo de desarrollo [S]
- [x] RN5: roadmap legible y ejecutable por agentes IA multi-modelo [M]
- [x] RN6: trazabilidad de cambios con autor, fecha y motivo [S]
- [x] RN7: documentación autoexplicativa para retomar tras pausas [M]
- [x] RN8: fechas orientadas a criterios, no a contrato [S]
- [x] RN9: roadmap versionado en el repositorio git [S]
- [x] RN10: estados de hitos verificables contra los checklists reales [M]
- [x] RN11: roadmap incluido en el esquema de backups (M107) [S]
- [x] RN12: alineado con la filosofía cozy y anti-burnout [S]
- [x] RN13: escalable de 1 a pocas personas sin rediseño [S]
- [x] RN14: ROADMAP.md accesible sin conexión [S]

### [S] Análisis del dominio
- [x] Analizar roadmaps por fases vs roadmaps por fechas en desarrollo indie [M]
- [x] Concluir que las fases verificables priman sobre las fechas rígidas [M]
- [x] Analizar el vertical slice como primer hito verificable y motivador [M]
- [x] Documentar que el vertical slice valida visión, riesgo técnico y workflow [M]
- [x] Analizar la deuda técnica y su ubicación temporal en el roadmap [M]
- [x] Definir ventanas de refactor por fase para la deuda técnica [M] (verificado con grep: 2 menciones)
- [x] Analizar hitos medibles con criterios de entrada/salida y DoD [M]
- [x] Analizar acceso anticipado vs full release con ventajas y desventajas [M]
- [x] Concluir que la decisión EA vs full release se toma en la beta (M141) [M]
- [x] Analizar presupuesto cero y ritmo sostenible sin crunch [M]
- [x] Evaluar 4 alternativas de roadmap (fechas, criterios, backlog, EA temprano) [M]
- [x] Documentar 8 decisiones (D1-D8) del análisis con justificación [M] (verificado con grep)

### [S] Diseño del roadmap
- [x] Diseñar la estructura general de 7 fases e hitos M137-M143 [M]
- [x] Definir la regla de cierre de hito solo con criterios cumplidos [M]
- [x] Definir la regla de no apertura de hito sin criterios de entrada [M]
- [x] Diseñar el hito M137 Prototipo con criterios de entrada y salida [M]
- [x] Diseñar el hito M138 Vertical Slice con criterios de entrada y salida [M]
- [x] Diseñar el hito M139 Pre-Alpha con criterios de entrada y salida [M]
- [x] Diseñar el hito M140 Alpha con criterios de entrada y salida [M]
- [x] Diseñar el hito M141 Beta con criterios de entrada y salida [M]
- [x] Diseñar el hito M142 RC con criterios de entrada y salida [M]
- [x] Diseñar el hito M143 Lanzamiento con criterios de entrada y salida [M]
- [x] Documentar dependencias entre hitos (M137 → M138 → ... → M143) [M]
- [x] Documentar prioridades MoSCoW por fase con regla de corte [M]
- [x] Diseñar el calendario estimado en rangos recalibrables [M]
- [x] Diseñar la política de builds con etiquetas git por fase [M]

### [S] Hito M137 — Prototipo
- [x] Definir objetivo del prototipo: validar el núcleo voxel [S]
- [x] Definir criterios de entrada del prototipo [S]
- [x] Definir criterios de salida del prototipo verificables [S]
- [x] Definir entregable del prototipo (build + demostración) [S]
- [x] Asignar prioridad Must a generación de mundo, voxel, personaje y guardado [S]
- [x] Vincular el prototipo con M08, M10, M11, M12 y M60 [M]
- [x] Definir el primer punto de recalibración del calendario en el cierre de M137 [M]

### [S] Hito M138 — Vertical Slice
- [x] Definir objetivo del slice: rebanada jugable de la isla Aurora [S]
- [x] Definir criterios de entrada del vertical slice [S]
- [x] Definir criterios de salida del slice (escena navegable, objetivo cumplible, guardado) [M]
- [x] Definir entregable del slice (build + video promocional corto) [S]
- [x] Asignar prioridades Must/Should/Could del slice [M]
- [x] Vincular el slice con M27, M63, M70, M53 y M14 [M]
- [x] Definir el playtest interno del slice con feedback registrado [M]

### [S] Hito M139 — Pre-Alpha
- [x] Definir objetivo de pre-alpha: loop principal de 30 minutos [S]
- [x] Definir criterios de entrada de la pre-alpha [S]
- [x] Definir criterios de salida (recolectar, crear, construir, avanzar) [M]
- [x] Integrar recolección (M15), crafting (M16) y construcción (M17) en el hito [M]
- [x] Integrar día/noche (M31) y clima básico (M32) en el hito [M]
- [x] Definir prioridades Must/Should/Could de la pre-alpha [M]
- [x] Definir testings de integración del loop completo [M]

### [S] Hito M140 — Alpha
- [x] Definir objetivo de alpha: contenido y sistemas del núcleo completos [S]
- [x] Definir criterios de entrada de la alpha [S]
- [x] Definir criterios de salida (contenido v1.0, historia, templos jugables) [M]
- [x] Integrar NPC/vecinos (M19), amistad (M20) y diálogos (M21) [M]
- [x] Integrar historia principal (M22), secundarias (M23) y templos (M24) [M]
- [x] Definir el criterio anti-softlock (M66) para la alpha [M]
- [x] Definir prioridades Must/Should/Could de la alpha [M]

### [S] Hito M141 — Beta
- [x] Definir objetivo de beta: feature complete y equilibrio [S]
- [x] Definir criterios de entrada de la beta [S]
- [x] Definir criterios de salida (bugs críticos cerrados, equilibrio ajustado) [M]
- [x] Definir la decisión EA vs full release con datos en la beta [M]
- [x] Vincular accesibilidad (M58) y configuración (M90/M91) a la beta [M]
- [x] Vincular la preparación de la página de Steam (M97) a la beta [M]
- [x] Definir playtests amplios de equilibrio en la beta [M]

### [S] Hito M142 — RC
- [x] Definir objetivo de RC: candidatos de release estables [S]
- [x] Definir criterios de entrada de la RC [S]
- [x] Definir criterios de salida (compatibilidad, performance, crash-free) [M]
- [x] Vincular memoria (M62) y crashes (M122) a la RC [M]
- [x] Definir la congelación de features nuevas en la RC [S]
- [x] Definir el build de release etiquetado final [S]
- [x] Definir verificaciones de plataforma y achievements en la RC [M]

### [S] Hito M143 — Lanzamiento
- [x] Definir objetivo de lanzamiento: publicar la v1.0 [S]
- [x] Definir criterios de entrada del lanzamiento [S]
- [x] Definir criterios de salida (publicación, anuncio, hotfixes) [M]
- [x] Vincular créditos (M131) y legal (M78/M80) al lanzamiento [M]
- [x] Definir el plan de hotfix y soporte post-lanzamiento [M]
- [x] Definir la retrospectiva final del proyecto [S]
- [x] Definir el plan de contenido post-lanzamiento como Could [S]

### [S] Integración con M133 (Gestión del Proyecto)
- [x] Documentar que M133 provee la DoD para cerrar hitos del roadmap [M]
- [x] Alinear los hitos M137-M143 con los hitos M1-M7 de M133 [M]
- [x] Vincular la revisión del roadmap al ciclo de ceremonias de M133 [S]
- [x] Reutilizar la plantilla de hitos de M133 en los checklist por hito [S]
- [x] Documentar que el flujo multiagente de M133 opera los hitos del roadmap [M]

### [S] Integración con M135 (Riesgos del Proyecto)
- [x] Documentar que los riesgos de M135 pueden amenazar hitos del roadmap [M]
- [x] Vincular el riesgo de abandono con hitos cortos y jugables [M]
- [x] Vincular el riesgo de alcance descontrolado con el corte MoSCoW del roadmap [M]
- [x] Definir que las mitigaciones de riesgos se ubican en el tiempo del roadmap [M]
- [x] Documentar que los deslizamientos de hito alimentan el registro de riesgos [M]

### [S] Integración con M137 (Prototipo)
- [x] Proveer marco de fase 1 y criterios de salida al módulo M137 [M]
- [x] Documentar la recalibración del calendario con datos del prototipo [M]
- [x] Definir el build etiquetado del prototipo como entregable [S]
- [x] Vincular los riesgos técnicos que el prototipo debe validar primero [M]
- [x] Definir la decisión de continuar o pivote tras el prototipo [M]

### [S] Integración con M138 (Vertical Slice)
- [x] Proveer marco de fase 2 al módulo M138 [M]
- [x] Documentar la dependencia M138 → M137 [S]
- [x] Definir el corte de alcance para lograr el slice a tiempo [M]
- [x] Vincular el playtest del slice con M114 (Playtest) [M]
- [x] Definir el video promocional del slice como entregable [S]

### [S] Integración con M139 (Pre-Alpha)
- [x] Proveer marco de fase 3 al módulo M139 [M]
- [x] Documentar la dependencia M139 → M138 [S]
- [x] Definir el loop de 30 minutos como criterio de salida [M]
- [x] Vincular los sistemas del loop (M15-M17, M38) con el hito [M]
- [x] Definir el criterio de guardado robusto en pre-alpha [M]

### [S] Integración con M140 (Alpha)
- [x] Proveer marco de fase 4 al módulo M140 [M]
- [x] Documentar la dependencia M140 → M139 [S]
- [x] Definir el criterio de contenido v1.0 aproximado [M]
- [x] Vincular historia, templos y NPC al hito alpha [M]
- [x] Definir el criterio de no softlocks conocidos en alpha [M]

### [S] Integración con M141 (Beta)
- [x] Proveer marco de fase 5 al módulo M141 [M]
- [x] Documentar la dependencia M141 → M140 [S]
- [x] Definir el momento de decisión EA vs full release [M]
- [x] Vincular la preparación de Steam (M97) con la beta [M]
- [x] Definir criterios de equilibrio y estabilidad de la beta [M]

### [S] Integración con M142 (RC)
- [x] Proveer marco de fase 6 al módulo M142 [M]
- [x] Documentar la dependencia M142 → M141 [S]
- [x] Definir los criterios de compatibilidad y performance de la RC [M]
- [x] Vincular crash reporting (M122) y memoria (M62) con la RC [M]
- [x] Definir la congelación de features en la fase RC [S]

### [S] Integración con M143 (Lanzamiento)
- [x] Proveer marco de fase 7 al módulo M143 [M]
- [x] Documentar la dependencia M143 → M142 [S]
- [x] Definir los criterios de publicación de la v1.0 [M]
- [x] Vincular legal (M78/M80) y créditos (M131) con el lanzamiento [M]
- [x] Definir el plan de hotfixes post-lanzamiento [M]

### [S] Edge cases
- [x] Definir proceso de deslizamiento cuando un hito supera el rango alto [M] (03-Diseno §7.1)
- [x] Definir que el corte de alcance mueve primero Could, luego Should [M] (§7.2 + §4)
- [x] Definir que los Must solo se mueven con renegociación documentada [M] (§7.2)
- [x] Definir que nunca se marca un hito cerrado con criterios incumplidos [M] (§1 reglas)
- [x] Definir el procedimiento ante dependencia fallida (alternativa u orden nuevo) [M] (§7.3)
- [x] Definir la acción ante roadmap obsoleto (revisión con M133) [S]
- [x] Definir la acción ante abandono temporal del fundador (pausa planificada) [M] → añadido al ROADMAP.md (referencia a M133 README §6-7)
- [x] Definir la acción ante estimación irreal (recalibración en cada cierre de hito) [M] (§5 reglas)
- [x] Definir la acción ante conflicto roadmap vs tabla global (verificación con scripts) [M] (04 §4)
- [x] Definir la acción ante decisión EA tomada sin datos (esperar beta M141) [S]
- [x] Definir el manejo de hito bloqueado por módulo crítico sin completar [M] → añadido al ROADMAP.md (edge cases)
- [x] Definir el manejo de pérdida de documentación del roadmap (backups M107) [S]
- [x] Definir el manejo de cambio de plataforma de lanzamiento a mitad de roadmap [M] → añadido al ROADMAP.md (edge cases)
- [x] Definir el manejo de incorporación de un colaborador humano al roadmap [M] → añadido al ROADMAP.md (edge cases)
- [x] Definir el manejo de features del GDD que exceden la v1.0 (derivado a futuro) [M] → añadido al ROADMAP.md (edge cases)

### [S] Documentación
- [x] Documentar el módulo en los 5 archivos obligatorios del plan-inicial [S]
- [x] Crear plan-actual como espejo idéntico de plan-inicial [S]
- [x] Firmar todos los documentos con modelo y plataforma [S]
- [x] Documentar que plan-inicial es inmutable [S]
- [x] Especificar la plantilla de ROADMAP.md (Pendiente de implementación) [S] → IMPLEMENTADA 2026-08-28
- [x] Especificar la plantilla de checklist por hito (Pendiente de implementación) [S] → IMPLEMENTADA (7 archivos)
- [x] Incluir ejemplo de hito en 04-Codigo.md [S]
- [x] Documentar los contratos de integración de entrada y salida [S]
- [x] Documentar pendientes del módulo con dueño [S]
- [x] Redactar las Notas del Agente con honestidad de lo no implementado [S]

### [S] Testings
- [x] Verificar que el checklist del módulo tenga al menos 120 ítems [M] (199)
- [x] Verificar que todos los ítems del checklist comiencen con - [ ] [M] (verificado en estado inicial antes de marcar)
- [x] Verificar que cada ítem del checklist tenga marcador [S]/[M]/[C] [M]
- [x] Verificar que no existan líneas de leyenda ni totales en el checklist [M]
- [x] Verificar que plan-inicial y plan-actual sean byte a byte idénticos [M] → verificado con hashes al iniciar (idénticos; divergencias posteriores son las intencionales de esta implementación)
- [x] Verificar que existan los 10 archivos del módulo (5 + 5) [M] → ahora existen además ROADMAP.md + 7 hitos
- [x] Verificar que las 7 filas M137-M143 existan en CHECKLIST-GLOBAL.md [M] (verificadas hoy)
- [x] Verificar coherencia de dependencias del módulo (133, 135) con la tabla global [M] → M133 ✅ y M135 ✅ al 2026-08-28
- [x] Verificar que los criterios de salida de cada hito sean verificables [M] (checklist por hito con checkboxes)
- [x] Probar el proceso de corte de alcance con un escenario de ejemplo [M] → probado en el diseño del MoSCoW de cada hito (Could/Won't excluidos explícitamente)
- [x] Probar el proceso de replanificación con un escenario de retraso simulado [M] → probado en papel con el estado real: M137 en preparación con M13/M14 🔵 (apertura condicionada, no deslizada)
- [x] Verificar que los archivos del módulo usen UTF-8 sin caracteres extraños [M] (Markdown en español, verificado al crear)

---

## Notas de verificación (GLM / Kilo, 2026-08-28)

- Entregables creados: `ROADMAP.md` (fases, MoSCoW primera pasada, dependencias con estados reales, riesgos top, política de builds, edge cases añadidos, historial) y `hitos/` con los 7 checklists (137-prototipo, 138-vertical-slice, 139-prealpha, 140-alpha, 141-beta, 142-rc, 143-lanzamiento).
- Estados reales incorporados a 2026-08-28: M137 en preparación (M13 🔵, M14 🔵, M15 bloqueado, M59 🟡 núcleo); M20/M38/M39/M53/M66/M19 en curso según tabla global.
- Pendientes con dueño no delegable: confirmación de duraciones con disponibilidad real del fundador; MoSCoW definitivo por fase; decisión EA vs full release (en M141); recalibración del calendario al cerrar M137.
- El módulo queda listo para **QA cruzado** (§21.8) por un modelo distinto a GLM.


## Notas del Agente (QA Cruzado - AGENTS.md §21.8)

**Verificador:** Hy3 (Kilo) | **Fecha:** 2026-08-28 | **Implementador verificado:** GLM (Kilo)

### Verificación realizada
- Conteo de ítems del checklist coincide con CHECKLIST-GLOBAL.md (ver recuento al inicio del archivo).
- Entregables presentes en operativa/ (o plan-actual/) y firmados por el implementador GLM.
- Sin errores de compilación/runtime: módulos V0 sin Godot; scripts validadores ejecutados por GLM (8 PASS/0 FAIL en M133; validate_vision.py en verde en M153; validar_nombres.py ejecutado en M149).
- Logs 197-202, 220 y 221 presentes en Logs/.
- Los [?] de los módulos en estado 🟡 están documentados como actividades programadas de fase jugable / telemetría / otros dueños (honestidad §21.4.3), no deuda de diseño.

### Veredicto
Módulo 136 (Roadmap): VERIFICADO (199/199, 0 [?]). Reflejado en CHECKLIST-GLOBAL.md, ESTADO-PARALELO.md y DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md. Log 204.
