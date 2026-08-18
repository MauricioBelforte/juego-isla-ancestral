**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 101: QA General

## ID del Módulo

- **Código:** M101 (plan maestro: QA General — aseguramiento de calidad del juego)
- **Carpeta:** `DOCUMENTACION/101-QA-General/`
- **Dependencias:** M110 (Debug Menu, ya documentado). Se integra con: M102 (Bug Tracking, ya documentado), M112 (Testing Automático, ya documentado), M114 (Playtest) y los hitos M137-M141 (Prototipo, Vertical Slice, Pre-Alpha, Alpha, Beta).
- **Carácter:** Módulo de proceso y herramientas de QA manual del juego. Define los pasos de QA, los checklists de regresión por área, las sesiones de prueba por hito, el reporte de bugs (vía M102), la coordinación con playtesting (M114) y los criterios de calidad/release (DoD de QA). El motor del juego es **Godot 4.x**, el lenguaje es **GDScript** (no Unity, no C#).

## 1. Problema

El proyecto "Isla Ancestral" es un juego de mundo voxel cozy (isla Aurora) con calidad técnica obligatoria y un protocolo multiagente que exige verificación post-tarea (sección 12 del AGENTS.md: 0 errores en consola, sin excepciones en runtime, flujo completo validado). Con más de 140 módulos documentados y un pipeline de múltiples agentes, el riesgo de regresiones es alto y no existe aún un procedimiento estandarizado de QA manual: qué probar, cómo probarlo, cómo documentarlo, cuándo una build está lista para avanzar de hito. Los bugs reportados de forma ad-hoc terminan incompletos (sin pasos de reproducción, sin versión, sin logs), los cambios a un sistema rompen silenciosamente otros módulos, y no hay criterios objetivos de release entre hitos. Se necesita un procedimiento de QA manual sistematizado, reproducible por cualquier agente o tester humano, alineado con M102 (bug tracking), M110 (debug menu), M112 (tests automatizados) y M114 (playtesting).

## 2. Objetivo

Definir el sistema de aseguramiento de calidad manual del juego: un checklist maestro de QA por área del juego (regresión por sistema), plantillas de sesión de QA por hito (M137-M141), un procedimiento estándar de reporte de bugs enlazado a M102 (GitHub Issues), criterios de release (DoD de QA) para cada hito, coordinación con M114 (playtesting) y guías de smoke test por build. El resultado es que cualquier agente o tester pueda ejecutar una sesión de QA completa, documentar hallazgos de forma consistente y determinar objetivamente si una build es apta para pasar al siguiente hito.

## 3. Alcance

### Incluye

- Checklist maestro de QA manual por área del juego (mundo voxel, jugador, herramientas, inventario, crafting, construcción, NPCs, diálogos, historia, puzzles, islas, tiempo/clima, agricultura, pesca, minería, fauna, economía, audio, UI, accesibilidad, rendimiento/memoria, IA, anti-softlock, tutorial, configuración).
- Plantilla de sesión de QA (`QA-SESSION.md`) con datos de build, alcance, resultados por ítem y conclusión.
- Sesiones de prueba definidas para los hitos M137 (Prototipo), M138 (Vertical Slice), M139 (Pre-Alpha), M140 (Alpha) y M141 (Beta).
- Procedimiento de regresión: qué correr y cuándo (por cambio, por build, por hito).
- Procedimiento de reporte de bugs enlazado a M102 (plantilla de issue, severidades, categorías, pasos de reproducción, adjuntos: logs M103, screenshot, extractos del debug menu M110).
- Criterios de release (DoD de QA) por hito y para release final (M142 Release Candidate).
- Guía de smoke tests rápidos por build (menos de 15 minutos).
- Coordinación con M114 (playtesting): qué sesiones son de QA interna y cuáles de playtesting externo, y cómo fluyen los hallazgos entre ambas.
- Documentación de todo el proceso en las carpetas del módulo.

### Excluye

- La implementación del sistema de bug tracking en sí (pertenece a M102; aquí solo se define el flujo de uso desde QA).
- La suite de testing automatizado y el framework (pertenece a M112; el QA manual la complementa y se apoya en ella para regresión).
- La infraestructura de CI/CD (M118) y el crash reporting (M122); solo se referencian como fuentes de evidencia en reportes.
- El diseño del debug menu (pertenece a M110; QA lo usa como herramienta).
- La ejecución del playtesting con jugadores reales (pertenece a M114; aquí se definen los criterios de entrada/salida de cada sesión).
- La corrección de bugs encontrados: QA documenta y clasifica; la corrección la hace el agente dueño del módulo afectado.
- Calidad visual/artística subjetiva (se valida por criterios de M02/M45 en playtesting, no como bloqueo de QA técnica).

## 4. Restricciones

- **Motor y lenguaje:** Godot 4.x + GDScript únicamente. Prohibido aplicar procedimientos de QA de Unity.
- **Fuente de verdad de bugs:** GitHub Issues de M102 (único canal de reporte; nada de reportes en chats o archivos sueltos).
- **Sesiones con build etiquetada:** toda sesión de QA corre sobre una build identificable (commit hash, versión, fecha) y se registra en `QA-SESSION.md`.
- **Tiempo:** el smoke test de una build no debe superar los 15 minutos; una sesión de regresión completa de un área no debe superar las 2 horas.
- **Determinismo:** los resultados deben ser reproducibles; se registra semilla del mundo (M10), versión de Godot y opciones de configuración usadas.
- **Evidencia:** todo bug reportado incluye pasos de reproducción, resultado esperado, resultado obtenido, severidad y contexto (logs M103, screenshot, estado del debug menu M110).
- **DoD de QA:** un módulo no pasa a release si su checklist de área tiene ítems `[ ]` o bugs abiertos de severidad crítica/alta sin resolver.
- **Regla del 24h:** no se inicia una sesión nueva con bugs críticos abiertos de sesiones anteriores sin justificación documentada (evita acumulación).

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Checklist maestro por área | Checklist de QA manual por cada área del juego (25+ áreas), con ítems verificables, en `QA-CHECKLIST.md` |
| RF2 | Plantilla de sesión de QA | Plantilla `QA-SESSION.md` con build, alcance, resultados por ítem, bugs encontrados y conclusión |
| RF3 | Sesiones por hito M137-M141 | Sesiones de prueba definidas y documentadas para Prototipo, Vertical Slice, Pre-Alpha, Alpha y Beta |
| RF4 | Procedimiento de regresión | Guía de cuándo y cómo correr regresión por área (por cambio, por build, por hito) |
| RF5 | Reporte de bugs | Procedimiento de reporte enlazado a M102: plantilla de issue con pasos de reproducción, severidades y evidencias |
| RF6 | Smoke test por build | Guía de smoke test rápido (< 15 min) para validar una build antes de QA completo |
| RF7 | Criterios de release (DoD de QA) | Criterios objetivos para considerar una build apta para avanzar de hito (M137→M142) |
| RF8 | Coordinación con playtesting (M114) | Definición de qué sesiones corresponden a QA interna y cuáles a M114, y cómo fluyen los hallazgos |
| RF9 | Uso del debug menu (M110) | Procedimientos de QA que usan M110 (teletransporte, dar objetos, fijar tiempo/clima) para acelerar pruebas |
| RF10 | Feedback con tests automáticos (M112) | Regla de cuándo un bug de regresión detectado manualmente debe convertirse en test automático en M112 |
| RF11 | Registro de métricas de calidad | Registro de bugs abiertos/cerrados por área y por hito, para informar a M133 (Gestión del Proyecto) |
| RF12 | Guía de QA para agentes del protocolo | Guía breve para que cualquier agente ejecute la verificación post-tarea (sección 12 del AGENTS.md) con criterios de QA |

## 6. Requisitos No Funcionales

- Los checklists y plantillas del módulo se escriben en Markdown (igual que la documentación del proyecto) y viven en `DOCUMENTACION/101-QA-General/plan-actual/`.
- Todo documento del módulo lleva la firma del agente que lo modificó (estándar de AGENTS.md).
- Los reportes de bugs usan exclusivamente el canal de M102 (GitHub Issues) — no se mantienen listas duplicadas de bugs.
- Los criterios de severidad y categorías de bugs se toman de M102 tal cual (no se redefinen).
- Las sesiones de QA se documentan en archivos Markdown versionados en git (trazabilidad completa).
- El proceso de QA debe poder ejecutarlo un humano sin conocimientos de código (pasos descriptivos), y también un agente del protocolo multiagente.
- Las evidencias de bugs (screenshots, extractos de logs) se adjuntan a los issues de M102, no al código.
- Cada hito (M137-M141) tiene una sesión de QA con criterios de entrada y salida propios, alineados con su checklist del plan maestro.
- El módulo no introduce código runtime del juego: todo el contenido es proceso y plantillas de documentación (la única integración de código posible es read-only con el debug menu de M110).

## 7. Criterios de Aceptación

1. Checklist maestro de QA por área creado y cubriendo todas las áreas funcionales del juego (25+ áreas).
2. Plantilla de sesión de QA y plantilla de reporte de bug (integrada a M102) creadas y probadas en al menos una sesión ficticia.
3. Sesiones de QA definidas para los hitos M137, M138, M139, M140 y M141 con criterios de entrada/salida.
4. Procedimiento de regresión documentado y aplicable por cualquier agente (post-cambio, post-build, post-hito).
5. Criterios de release (DoD de QA) definidos y consistentes con el protocolo multiagente (sección 21.6 del AGENTS.md).
6. Guía de smoke test (< 15 min) documentada y verificable.
7. Coordinación con M114 (playtesting) y con M112 (tests automáticos) documentada.
8. Guía de QA para agentes (verificación post-tarea) escrita y alineada con la sección 12 del AGENTS.md.
9. Checklist del módulo (05-Checklist.md) con 125+ ítems completados.