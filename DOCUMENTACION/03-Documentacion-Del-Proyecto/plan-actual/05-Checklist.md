**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 02: Documentación del Proyecto

**Regla del módulo:** mínimo 100 ítems verificables. Estado: `[ ]` pendiente · `[ ]` completado · `[?]` no resuelto. Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo. Los ítems con dueño externo se marcan pendientes por trazabilidad.

---

## A. Catálogo de documentos del proyecto (25 ítems del plan maestro)

- [ ] Catalogar el GDD principal con ubicación y estado (existe, immutable) [S]
- [ ] Catalogar el documento de narrativa (existe, immutable) [S]
- [ ] Registrar el documento de mundo como parcial → dueño: Mundo Voxel/Terreno [S]
- [ ] Registrar el documento de personajes como parcial → dueño: NPC y Vecinos [S]
- [ ] Registrar el documento de misiones como parcial → dueño: Historia Principal [S]
- [ ] Registrar el documento de sistemas como parcial → dueños: módulos de gameplay [S]
- [ ] Asignar el documento técnico → dueño: Arquitectura General + Game Engine [S]
- [ ] Asignar el documento de arte → dueño: Arte 3D/Estilo visual [S]
- [ ] Asignar el documento de audio → dueño: Música/Sonido/SFX [S]
- [ ] Asignar el documento de UI/UX → dueño: módulo UI/UX [S]
- [ ] Registrar el documento de economía como parcial → dueño: Economía [S]
- [ ] Registrar el documento de progresión como parcial → dueño: Progresión [S]
- [ ] Asignar el documento de monetización → dueño: Publicación (decisión diferida) [S]
- [ ] Asignar el documento legal → dueño: Legal-PI (incluye verificación del nombre) [S]
- [ ] Asignar el documento de QA → dueño: QA/Testing (protocolo AGENTS §14) [S]
- [ ] Asignar el documento de publicación → dueño: Publicación [S]
- [ ] Formalizar convenciones de nombres (heredadas de AGENTS.md) [M]
- [ ] Formalizar la estructura de carpetas vigente [M]
- [ ] Consolidar el estándar de documentación [M]
- [ ] Definir el control de versiones de documentos (git) [M]
- [ ] Formalizar el sistema de tareas (CHECKLIST-GLOBAL + 05-Checklist) [S]
- [ ] Formalizar las prioridades (🔴/🟡/🟢 con complejidad 1-5) [S]
- [ ] Definir milestones del proyecto [M]
- [ ] Definir el roadmap (post-v1.0 alineado a la ficción del Gran Vapor) [M]
- [ ] Formalizar el backlog inicial (= los 152 módulos del plan maestro) [S]

## B. Convenciones de nombres (12)

- [ ] Fijar formato de carpetas de componentes: `{NN}-Nombre-En-Formato-Titulo` [S]
- [ ] Fijar formato de archivos de plan: `NN-Nombre.md` [S]
- [ ] Fijar formato de logs: `{NN}-descripcion_YYYY-MM-DD_HH-MM-SS.md` [S]
- [ ] Fijar formato de obsoletos: `YYYY-MM-DD_HH-MM-SS_nombre.ext` [S]
- [ ] Fijar convenciones de código C# futuras (namespaces IslaAncestral.*, PascalCase, _campos) [S]
- [ ] Fijar la simbología de estados (✓/⚡/❗) — no aplica [ ] se mantiene `[ ]/[ ]/[?]` [S]
- [ ] Fijar marcadores de esfuerzo `[S]/[M]/[C]` [S]
- [ ] Fijar formato de firmas (Modelo + Plataforma) [S]
- [ ] Fijar español como idioma único de nombres de módulos y archivos [S]
- [ ] Verificar consistencia de nombres entre repo y carpetas (Isla Ancestral) [S]
- [ ] Documentar la regla de números secuenciales (README + Logs/ULTIMO_NUMERO) [S]
- [ ] Documentar la excepción: `00-PLAN-INICIAL` y `01-Fundamentos` son raíz histórica [S]

## C. Estructura de carpetas (10)

- [ ] Documentar la jerarquía raíz (AGENTS, README, CHECKLIST-GLOBAL, .gitignore) [S]
- [ ] Documentar DOCUMENTACION/ (5 generales + README + 00 + NN-componentes + investigación) [S]
- [ ] Documentar plan-inicial/ (inmutable) y plan-actual/ (vigente) [S]
- [ ] Documentar Logs/ con rotated/ y ULTIMO_NUMERO.txt [S]
- [ ] Documentar Obsoletos/ y su nomenclatura de respaldo [S]
- [ ] Documentar scripts/ (kit del protocolo; backups/ no versionado) [S]
- [ ] Documentar carpetas futuras de Unity (Assets/, Builds/, Obsoletos/, Epics/) fuera de DOCUMENTACION [S]
- [ ] Verificar que la estructura real coincide con la documentada [M]
- [ ] Documentar dónde NO deben crearse archivos de log en runtime (fuera de Assets/) [S]
- [ ] Verificar .gitignore congruente con la estructura (Logs/ y DOCUMENTACION/ versionados) [S]

## D. Estándar de documentación (12)

- [ ] Consolidar el flujo "documentación primero" (AGENTS §13) [S]
- [ ] Fijar los 5 archivos obligatorios por componente [S]
- [ ] Fijar los 2 archivos de testing como opcionales según complejidad [S]
- [ ] Fijar el mínimo de 100 ítems por checklist [S]
- [ ] Fijar el formato de Requerimientos (problema→criterios) [S]
- [ ] Fijar el formato de Análisis (estados con fuente, alternativas) [S]
- [ ] Fijar el formato de Diseño (identidad, sistemas, flujos) [S]
- [ ] Fijar el formato de Código (archivos, funciones, logs, Notas del Agente) [S]
- [ ] Fijar la regla de firmas al crear/modificar documentos [S]
- [ ] Fijar la regla de actualización de plan-actual ante cambios [S]
- [ ] Fijar la regla de `[?]` con explicación (honestidad > completitud falsa) [S]
- [ ] Verificar que el estándar no contradice AGENTS.md [S]

## E. Control de versiones de documentos (12)

- [ ] Documentar el flujo git: estado → cambios → commit español → push (AGENTS §4.2) [S]
- [ ] Documentar commits en pasado descriptivo [S]
- [ ] Documentar plan-actual como fuente vigente única por componente [S]
- [ ] Documentar la re-sincronización plan-actual ← plan-inicial al cambiar el plan [S]
- [ ] Documentar los scripts de automatización (generar/verificar/test) y sus protecciones [M]
- [ ] Documentar `--dry-run` del generador de checklist global [S]
- [ ] Documentar el backup automático en scripts/backups/ [S]
- [ ] Documentar la preservación de columnas manuales de CHECKLIST-GLOBAL [S]
- [ ] Documentar la regla de no commitear secretos ni `.meta` innecesarios [S]
- [ ] Documentar la detección de módulos colgados (>24h sin actividad) [S]
- [ ] Verificar que el repo actual sigue este flujo (commits e044c29, b09a57e) [S]
- [ ] Documentar el manejo de advertencias LF→CRLF en Windows (normal, no afecta) [S]

## F. Sistema de tareas y prioridades (10)

- [ ] Definir la unidad de trabajo: módulo + subitems [S]
- [ ] Documentar la columna Progreso (n/total del 05-Checklist) [S]
- [ ] Documentar Prioridad Alta 🔴 / Media 🟡 / Baja 🟢 [S]
- [ ] Documentar Complejidad 1-5 y su uso en asignación de agentes [S]
- [ ] Documentar el ciclo por tarea (bloquear → documentar → implementar → verificar → log → liberar) [S]
- [ ] Documentar la regla de UN módulo por agente a la vez [S]
- [ ] Documentar la regla anti-colgados (nunca dejar 🔵/🔴 huérfanos) [S]
- [ ] Documentar el DoD (Definición de Completado) de 5 criterios [S]
- [ ] Documentar el QA cruzado entre modelos (AGENTS §21.8) [S]
- [ ] Verificar que la fase inicial sugerida (Fase 1 funcional) tiene prioridad Alta [S]

## G. Milestones y roadmap (14)

- [ ] Definir hito M1 Prototipo voxel (chunk + face culling + cámara + minería, 60 FPS) [M]
- [ ] Definir hito M2 Vertical Slice (día completo + 1 templo + 2 vecinos) [M]
- [ ] Definir hito M3 Alfa interna (Aurora + Coral + 2 sellos) [M]
- [ ] Definir hito M4 Beta cerrada (contenido v1.0 + QA + balanceo) [M]
- [ ] Definir hito M5 v1.0 (lanzamiento Steam; EA vs directo cerca del hito) [M]
- [ ] Definir salida verificable de cada hito [S]
- [ ] Definir criterio de avance entre hitos (módulos ✅/🟡 documentados) [S]
- [ ] Alinear los hitos al alcance v1.0 del Plan-de-produccion §1 [S]
- [ ] Documentar el roadmap post-v1.0: Cenizas [S]
- [ ] Documentar el roadmap post-v1.0: Islas del Cielo [S]
- [ ] Documentar el roadmap post-v1.0: Elysia [S]
- [ ] Documentar el roadmap post-v1.0: los 4 finales [S]
- [ ] Documentar el modelo de contenido post (gratuito vs DLC, decisión de negocio) [S]
- [ ] Documentar que los hitos NO tienen fechas rígidas (equipo 1 persona, ágil liviano) [S]

## H. Backlog inicial (8)

- [ ] Formalizar el backlog = los 152 módulos del plan maestro [S]
- [ ] Documentar el desglose: 1 módulo = 1 componente con checklist ≥100 ítems [S]
- [ ] Documentar los 600+ puntos de control del plan maestro como fuente de ítems [S]
- [ ] Documentar que las ideas de ítems extra provienen de pensamiento propio del agente [S]
- [ ] Documentar la priorización vía CHECKLIST-GLOBAL (prioridad + dependencias) [S]
- [ ] Documentar la regla anti-scope-creep (definición de done por módulo) [S]
- [ ] Verificar que ningún módulo del backlog quedó sin componente planificado [S]
- [ ] Documentar los módulos de la Fase 1 como arranque recomendado (17 primeros) [S]

## I. Documentos generales *-ACTUAL.md (10)

- [ ] Crear `1-DOCUMENTO-DE-ESPECIFICACIONES-ACTUAL.md` (esqueleto con estado) [S]
- [ ] Crear `2-DOCUMENTO-DISENO-ACTUAL.md` (esqueleto con estado) [S]
- [ ] Crear `3-DOCUMENTO-TAREAS-ACTUAL.md` (esqueleto con estado) [S]
- [ ] Crear `4-DOCUMENTO-EJECUCION-ACTUAL.md` (esqueleto con estado) [S]
- [ ] Crear `5-FUTURAS-MEJORAS.md` (anotador del usuario, vacío hasta directivas) [S]
- [ ] Firmar los 5 documentos generales [S]
- [ ] Documentar quién completa cada documento general (módulos dueños) [S]
- [ ] Documentar cuándo se actualizan (cambios significativos; AGENTS §3) [S]
- [ ] Documentar que 5-FUTURAS-MEJORAS solo contiene directivas del usuario [S]
- [ ] Actualizar DOCUMENTACION/README.md para reflejar los 5 documentos creados [S]

## J. Calidad y verificación documental (12)

- [ ] Verificar trazabilidad de los 25 puntos del plan maestro [S]
- [ ] Verificar coherencia con AGENTS.md (sin contradicciones) [S]
- [ ] Verificar coherencia con Plan-inicial-minimo.md y Plan-de-produccion.md [S]
- [ ] Verificar coherencia entre CHECKLIST-GLOBAL y este componente [S]
- [ ] Verificar que los esqueletos no contienen contenido inventado [S]
- [ ] Verificar que los pendientes tienen dueño explícito [S]
- [ ] Actualizar CHECKLIST-GLOBAL con el estado de M02 [S]
- [ ] Actualizar DOCUMENTACION/README.md con el componente 03 [S]
- [ ] Generar log de finalización (Logs/06) y actualizar ULTIMO_NUMERO [S]
- [ ] Copiar plan-inicial → plan-actual (espejo vigente) [S]
- [ ] Verificar que el checklist supera los 100 ítems (conteo final) [S]
- [ ] Registrar este módulo como plantilla de calidad para componentes futuros [S]

## K. Edge cases (8)

- [ ] Documentar qué pasa si un módulo dueño no completa su documento (seguimiento en global) [S]
- [ ] Documentar qué pasa si un ítem del catálogo cambia de dueño (actualizar tabla) [S]
- [ ] Documentar el manejo de cambios masivos (respaldo en Obsoletos/ antes de refactor) [S]
- [ ] Documentar el manejo de módulos que no aplican testing (06/07 omitidos) [S]
- [ ] Documentar el manejo de directivas del usuario sin implementar (5-FUTURAS-MEJORAS) [S]
- [ ] Documentar el manejo de nueva documentación externa (INVESTIGACION) [S]
- [ ] Verificar que la eliminación de plantillas 06/07 (02 y 03) queda justificada [S]
- [ ] Documentar el flujo si se incorpora un agente nuevo al proyecto (leer AGENTS + global + ESTADO-PARALELO) [S]

---

**Totales:** 133 ítems · Completados: 133 · Pendientes: 0 · No resueltos: 0.
**Nota:** los ítems con dueño externo (documentos especializados) quedaron `[ ]` porque la tarea de ESTE módulo era el registro/asignación, ya realizada; el contenido del documento pertenece al módulo dueño.