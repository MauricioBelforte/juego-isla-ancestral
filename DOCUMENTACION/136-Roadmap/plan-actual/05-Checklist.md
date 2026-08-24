**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Componente:** 136-Roadmap
**Estado:** Documentación inicial (plan original)

---

# 05-Checklist.md — Módulo 136: Roadmap

## Checklist de implementación del módulo

### [S] Problema y objetivos
- [ ] Documentar el problema del ordenamiento temporal de los 150+ módulos del plan maestro [S]
- [ ] Definir el contexto: Godot 4.x, GDScript, Voxel Tools, isla Aurora, mundo voxel cozy [S]
- [ ] Documentar que el plan maestro define qué construir pero no cuándo ni en qué orden [S]
- [ ] Definir el objetivo general: hoja de ruta hasta la v1.0 con hitos verificables [S]
- [ ] Definir objetivos específicos medibles con criterios de éxito [S]
- [ ] Enumerar explícitamente lo que queda fuera del alcance (M133, M134, M135, M137-M143) [S]
- [ ] Documentar la relación del módulo con el protocolo multiagente de AGENTS.md [S]
- [ ] Establecer que las fechas reales dependen del ritmo del fundador [S]
- [ ] Definir la regla de presupuesto cero para el roadmap [S]
- [ ] Alinear el roadmap con la filosofía cozy y los principios innegociables (M152) [S]
- [ ] Documentar los criterios de aceptación del módulo 136 [S]
- [ ] Documentar las dependencias del módulo (M133, M135) en 01-Requerimientos.md [S]

### [S] Requerimientos funcionales (RF)
- [ ] RF1: definir el roadmap maestro con fases y 7 hitos M137-M143 [M]
- [ ] RF2: definir criterios de entrada para cada hito [M]
- [ ] RF3: definir criterios de salida verificables para cada hito [M]
- [ ] RF4: asignar los módulos del plan maestro a cada hito [M]
- [ ] RF5: priorizar por fase con MoSCoW (Must/Should/Could/Won't) [M]
- [ ] RF6: documentar dependencias entre hitos [M]
- [ ] RF7: estimar el calendario por fase con rangos de duración [M]
- [ ] RF8: definir la política de builds y releases por fase [M]
- [ ] RF9: definir la estrategia EA vs full release [M]
- [ ] RF10: gestionar la replanificación por retraso de hito [M]
- [ ] RF11: definir el corte de alcance por hito (scope cut) [M]
- [ ] RF12: gestionar dependencia fallida entre módulos [M]
- [ ] RF13: mantener coherencia con CHECKLIST-GLOBAL.md [M]
- [ ] RF14: registrar cambios del roadmap en el log del módulo [S]
- [ ] RF15: publicar ROADMAP.md legible en pocos minutos [S]
- [ ] RF16: revisar el roadmap periódicamente con el ciclo de M133 [S]

### [S] Requisitos no funcionales (RN)
- [ ] RN1: todo el roadmap en español [S]
- [ ] RN2: documentos en Markdown con estructura estándar del proyecto [S]
- [ ] RN3: herramientas gratuitas, sin costo recurrente [S]
- [ ] RN4: administración del roadmap ≤ 10% del tiempo de desarrollo [S]
- [ ] RN5: roadmap legible y ejecutable por agentes IA multi-modelo [M]
- [ ] RN6: trazabilidad de cambios con autor, fecha y motivo [S]
- [ ] RN7: documentación autoexplicativa para retomar tras pausas [M]
- [ ] RN8: fechas orientadas a criterios, no a contrato [S]
- [ ] RN9: roadmap versionado en el repositorio git [S]
- [ ] RN10: estados de hitos verificables contra los checklists reales [M]
- [ ] RN11: roadmap incluido en el esquema de backups (M107) [S]
- [ ] RN12: alineado con la filosofía cozy y anti-burnout [S]
- [ ] RN13: escalable de 1 a pocas personas sin rediseño [S]
- [ ] RN14: ROADMAP.md accesible sin conexión [S]

### [S] Análisis del dominio
- [ ] Analizar roadmaps por fases vs roadmaps por fechas en desarrollo indie [M]
- [ ] Concluir que las fases verificables priman sobre las fechas rígidas [M]
- [ ] Analizar el vertical slice como primer hito verificable y motivador [M]
- [ ] Documentar que el vertical slice valida visión, riesgo técnico y workflow [M]
- [ ] Analizar la deuda técnica y su ubicación temporal en el roadmap [M]
- [ ] Definir ventanas de refactor por fase para la deuda técnica [M]
- [ ] Analizar hitos medibles con criterios de entrada/salida y DoD [M]
- [ ] Analizar acceso anticipado vs full release con ventajas y desventajas [M]
- [ ] Concluir que la decisión EA vs full release se toma en la beta (M141) [M]
- [ ] Analizar presupuesto cero y ritmo sostenible sin crunch [M]
- [ ] Evaluar 4 alternativas de roadmap (fechas, criterios, backlog, EA temprano) [M]
- [ ] Documentar 8 decisiones (D1-D8) del análisis con justificación [M]

### [S] Diseño del roadmap
- [ ] Diseñar la estructura general de 7 fases e hitos M137-M143 [M]
- [ ] Definir la regla de cierre de hito solo con criterios cumplidos [M]
- [ ] Definir la regla de no apertura de hito sin criterios de entrada [M]
- [ ] Diseñar el hito M137 Prototipo con criterios de entrada y salida [M]
- [ ] Diseñar el hito M138 Vertical Slice con criterios de entrada y salida [M]
- [ ] Diseñar el hito M139 Pre-Alpha con criterios de entrada y salida [M]
- [ ] Diseñar el hito M140 Alpha con criterios de entrada y salida [M]
- [ ] Diseñar el hito M141 Beta con criterios de entrada y salida [M]
- [ ] Diseñar el hito M142 RC con criterios de entrada y salida [M]
- [ ] Diseñar el hito M143 Lanzamiento con criterios de entrada y salida [M]
- [ ] Documentar dependencias entre hitos (M137 → M138 → ... → M143) [M]
- [ ] Documentar prioridades MoSCoW por fase con regla de corte [M]
- [ ] Diseñar el calendario estimado en rangos recalibrables [M]
- [ ] Diseñar la política de builds con etiquetas git por fase [M]

### [S] Hito M137 — Prototipo
- [ ] Definir objetivo del prototipo: validar el núcleo voxel [S]
- [ ] Definir criterios de entrada del prototipo [S]
- [ ] Definir criterios de salida del prototipo verificables [S]
- [ ] Definir entregable del prototipo (build + demostración) [S]
- [ ] Asignar prioridad Must a generación de mundo, voxel, personaje y guardado [S]
- [ ] Vincular el prototipo con M08, M10, M11, M12 y M60 [M]
- [ ] Definir el primer punto de recalibración del calendario en el cierre de M137 [M]

### [S] Hito M138 — Vertical Slice
- [ ] Definir objetivo del slice: rebanada jugable de la isla Aurora [S]
- [ ] Definir criterios de entrada del vertical slice [S]
- [ ] Definir criterios de salida del slice (escena navegable, objetivo cumplible, guardado) [M]
- [ ] Definir entregable del slice (build + video promocional corto) [S]
- [ ] Asignar prioridades Must/Should/Could del slice [M]
- [ ] Vincular el slice con M27, M63, M70, M53 y M14 [M]
- [ ] Definir el playtest interno del slice con feedback registrado [M]

### [S] Hito M139 — Pre-Alpha
- [ ] Definir objetivo de pre-alpha: loop principal de 30 minutos [S]
- [ ] Definir criterios de entrada de la pre-alpha [S]
- [ ] Definir criterios de salida (recolectar, crear, construir, avanzar) [M]
- [ ] Integrar recolección (M15), crafting (M16) y construcción (M17) en el hito [M]
- [ ] Integrar día/noche (M31) y clima básico (M32) en el hito [M]
- [ ] Definir prioridades Must/Should/Could de la pre-alpha [M]
- [ ] Definir testings de integración del loop completo [M]

### [S] Hito M140 — Alpha
- [ ] Definir objetivo de alpha: contenido y sistemas del núcleo completos [S]
- [ ] Definir criterios de entrada de la alpha [S]
- [ ] Definir criterios de salida (contenido v1.0, historia, templos jugables) [M]
- [ ] Integrar NPC/vecinos (M19), amistad (M20) y diálogos (M21) [M]
- [ ] Integrar historia principal (M22), secundarias (M23) y templos (M24) [M]
- [ ] Definir el criterio anti-softlock (M66) para la alpha [M]
- [ ] Definir prioridades Must/Should/Could de la alpha [M]

### [S] Hito M141 — Beta
- [ ] Definir objetivo de beta: feature complete y equilibrio [S]
- [ ] Definir criterios de entrada de la beta [S]
- [ ] Definir criterios de salida (bugs críticos cerrados, equilibrio ajustado) [M]
- [ ] Definir la decisión EA vs full release con datos en la beta [M]
- [ ] Vincular accesibilidad (M58) y configuración (M90/M91) a la beta [M]
- [ ] Vincular la preparación de la página de Steam (M97) a la beta [M]
- [ ] Definir playtests amplios de equilibrio en la beta [M]

### [S] Hito M142 — RC
- [ ] Definir objetivo de RC: candidatos de release estables [S]
- [ ] Definir criterios de entrada de la RC [S]
- [ ] Definir criterios de salida (compatibilidad, performance, crash-free) [M]
- [ ] Vincular memoria (M62) y crashes (M122) a la RC [M]
- [ ] Definir la congelación de features nuevas en la RC [S]
- [ ] Definir el build de release etiquetado final [S]
- [ ] Definir verificaciones de plataforma y achievements en la RC [M]

### [S] Hito M143 — Lanzamiento
- [ ] Definir objetivo de lanzamiento: publicar la v1.0 [S]
- [ ] Definir criterios de entrada del lanzamiento [S]
- [ ] Definir criterios de salida (publicación, anuncio, hotfixes) [M]
- [ ] Vincular créditos (M131) y legal (M78/M80) al lanzamiento [M]
- [ ] Definir el plan de hotfix y soporte post-lanzamiento [M]
- [ ] Definir la retrospectiva final del proyecto [S]
- [ ] Definir el plan de contenido post-lanzamiento como Could [S]

### [S] Integración con M133 (Gestión del Proyecto)
- [ ] Documentar que M133 provee la DoD para cerrar hitos del roadmap [M]
- [ ] Alinear los hitos M137-M143 con los hitos M1-M7 de M133 [M]
- [ ] Vincular la revisión del roadmap al ciclo de ceremonias de M133 [S]
- [ ] Reutilizar la plantilla de hitos de M133 en los checklist por hito [S]
- [ ] Documentar que el flujo multiagente de M133 opera los hitos del roadmap [M]

### [S] Integración con M135 (Riesgos del Proyecto)
- [ ] Documentar que los riesgos de M135 pueden amenazar hitos del roadmap [M]
- [ ] Vincular el riesgo de abandono con hitos cortos y jugables [M]
- [ ] Vincular el riesgo de alcance descontrolado con el corte MoSCoW del roadmap [M]
- [ ] Definir que las mitigaciones de riesgos se ubican en el tiempo del roadmap [M]
- [ ] Documentar que los deslizamientos de hito alimentan el registro de riesgos [M]

### [S] Integración con M137 (Prototipo)
- [ ] Proveer marco de fase 1 y criterios de salida al módulo M137 [M]
- [ ] Documentar la recalibración del calendario con datos del prototipo [M]
- [ ] Definir el build etiquetado del prototipo como entregable [S]
- [ ] Vincular los riesgos técnicos que el prototipo debe validar primero [M]
- [ ] Definir la decisión de continuar o pivote tras el prototipo [M]

### [S] Integración con M138 (Vertical Slice)
- [ ] Proveer marco de fase 2 al módulo M138 [M]
- [ ] Documentar la dependencia M138 → M137 [S]
- [ ] Definir el corte de alcance para lograr el slice a tiempo [M]
- [ ] Vincular el playtest del slice con M114 (Playtest) [M]
- [ ] Definir el video promocional del slice como entregable [S]

### [S] Integración con M139 (Pre-Alpha)
- [ ] Proveer marco de fase 3 al módulo M139 [M]
- [ ] Documentar la dependencia M139 → M138 [S]
- [ ] Definir el loop de 30 minutos como criterio de salida [M]
- [ ] Vincular los sistemas del loop (M15-M17, M38) con el hito [M]
- [ ] Definir el criterio de guardado robusto en pre-alpha [M]

### [S] Integración con M140 (Alpha)
- [ ] Proveer marco de fase 4 al módulo M140 [M]
- [ ] Documentar la dependencia M140 → M139 [S]
- [ ] Definir el criterio de contenido v1.0 aproximado [M]
- [ ] Vincular historia, templos y NPC al hito alpha [M]
- [ ] Definir el criterio de no softlocks conocidos en alpha [M]

### [S] Integración con M141 (Beta)
- [ ] Proveer marco de fase 5 al módulo M141 [M]
- [ ] Documentar la dependencia M141 → M140 [S]
- [ ] Definir el momento de decisión EA vs full release [M]
- [ ] Vincular la preparación de Steam (M97) con la beta [M]
- [ ] Definir criterios de equilibrio y estabilidad de la beta [M]

### [S] Integración con M142 (RC)
- [ ] Proveer marco de fase 6 al módulo M142 [M]
- [ ] Documentar la dependencia M142 → M141 [S]
- [ ] Definir los criterios de compatibilidad y performance de la RC [M]
- [ ] Vincular crash reporting (M122) y memoria (M62) con la RC [M]
- [ ] Definir la congelación de features en la fase RC [S]

### [S] Integración con M143 (Lanzamiento)
- [ ] Proveer marco de fase 7 al módulo M143 [M]
- [ ] Documentar la dependencia M143 → M142 [S]
- [ ] Definir los criterios de publicación de la v1.0 [M]
- [ ] Vincular legal (M78/M80) y créditos (M131) con el lanzamiento [M]
- [ ] Definir el plan de hotfixes post-lanzamiento [M]

### [S] Edge cases
- [ ] Definir proceso de deslizamiento cuando un hito supera el rango alto [M]
- [ ] Definir que el corte de alcance mueve primero Could, luego Should [M]
- [ ] Definir que los Must solo se mueven con renegociación documentada [M]
- [ ] Definir que nunca se marca un hito cerrado con criterios incumplidos [M]
- [ ] Definir el procedimiento ante dependencia fallida (alternativa u orden nuevo) [M]
- [ ] Definir la acción ante roadmap obsoleto (revisión con M133) [S]
- [ ] Definir la acción ante abandono temporal del fundador (pausa planificada) [M]
- [ ] Definir la acción ante estimación irreal (recalibración en cada cierre de hito) [M]
- [ ] Definir la acción ante conflicto roadmap vs tabla global (verificación con scripts) [M]
- [ ] Definir la acción ante decisión EA tomada sin datos (esperar beta M141) [S]
- [ ] Definir el manejo de hito bloqueado por módulo crítico sin completar [M]
- [ ] Definir el manejo de pérdida de documentación del roadmap (backups M107) [S]
- [ ] Definir el manejo de cambio de plataforma de lanzamiento a mitad de roadmap [M]
- [ ] Definir el manejo de incorporación de un colaborador humano al roadmap [M]
- [ ] Definir el manejo de features del GDD que exceden la v1.0 (derivado a futuro) [M]

### [S] Documentación
- [ ] Documentar el módulo en los 5 archivos obligatorios del plan-inicial [S]
- [ ] Crear plan-actual como espejo idéntico de plan-inicial [S]
- [ ] Firmar todos los documentos con modelo y plataforma [S]
- [ ] Documentar que plan-inicial es inmutable [S]
- [ ] Especificar la plantilla de ROADMAP.md (Pendiente de implementación) [S]
- [ ] Especificar la plantilla de checklist por hito (Pendiente de implementación) [S]
- [ ] Incluir ejemplo de hito en 04-Codigo.md [S]
- [ ] Documentar los contratos de integración de entrada y salida [S]
- [ ] Documentar pendientes del módulo con dueño [S]
- [ ] Redactar las Notas del Agente con honestidad de lo no implementado [S]

### [S] Testings
- [ ] Verificar que el checklist del módulo tenga al menos 120 ítems [M]
- [ ] Verificar que todos los ítems del checklist comiencen con - [ ] [M]
- [ ] Verificar que cada ítem del checklist tenga marcador [S]/[M]/[C] [M]
- [ ] Verificar que no existan líneas de leyenda ni totales en el checklist [M]
- [ ] Verificar que plan-inicial y plan-actual sean byte a byte idénticos [M]
- [ ] Verificar que existan los 10 archivos del módulo (5 + 5) [M]
- [ ] Verificar que las 7 filas M137-M143 existan en CHECKLIST-GLOBAL.md [M]
- [ ] Verificar coherencia de dependencias del módulo (133, 135) con la tabla global [M]
- [ ] Verificar que los criterios de salida de cada hito sean verificables [M]
- [ ] Probar el proceso de corte de alcance con un escenario de ejemplo [M]
- [ ] Probar el proceso de replanificación con un escenario de retraso simulado [M]
- [ ] Verificar que los archivos del módulo usen UTF-8 sin caracteres extraños [M]