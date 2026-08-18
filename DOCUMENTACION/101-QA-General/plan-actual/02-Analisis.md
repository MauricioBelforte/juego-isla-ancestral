**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 101: QA General

## 1. Carácter del Componente

Módulo de **proceso y herramientas de QA manual** para Godot 4.x + GDScript. Es el puente entre la ejecución de código (que hacen otros módulos) y la garantía de calidad: define qué se prueba, cómo, quién, con qué evidencia y cuándo una build es apta para el siguiente hito. No implementa gameplay ni infraestructura: produce checklists, plantillas, guías y procedimientos, y se apoya en M102 (reportes), M110 (debug menu), M112 (tests automáticos) y M114 (playtesting).

## 2. Análisis del Dominio

### 2.1 Tipos de QA aplicables al proyecto

| Tipo | Descripción | Dónde vive | Responsable |
|---|---|---|---|
| QA manual exploratorio | Navegación libre por el juego buscando bugs sin guion | Sesiones de hito (M137-M141) | Tester humano o agente |
| QA manual guiado (checklist) | Recorrido sistemático de un área con ítems verificables | `QA-CHECKLIST.md` por área | Cualquier agente (sección 12 AGENTS.md) |
| Regresión | Re-ejecución de checklists de áreas afectadas por un cambio | Sesiones post-cambio/post-build | Agente que modificó + verificador (21.8) |
| Smoke test | Prueba rápida (<15 min) de una build para decidir si merece QA completo | `QA-SMOKE` dentro de la sesión | Cualquier agente |
| Playtesting | Sesiones con jugadores reales externos (diversión, claridad, balance) | Módulo M114 | Equipo de juego (M114) |
| QA automatizado | Unit/integration tests, cobertura | Módulo M112 | Pipeline CI (M118) |

**Análisis:** el QA manual guiado es la columna vertebral: los agentes del protocolo multiagente modifican código constantemente y la sección 12 del AGENTS.md exige verificación post-tarea. Un checklist por área permite que cualquier agente (sin experiencia en el área) ejecute la verificación con pasos concretos. El QA exploratorio queda reservado para las sesiones de hito, donde se busca lo que los checklists no cubren. El smoke test es la puerta de entrada: evita invertir horas de QA en builds rotas.

### 2.2 Regresión: cuándo y qué correr

**Contexto:** con más de 140 módulos documentados y dependencias cruzadas (ver CHECKLIST-GLOBAL), un cambio en M14 (Inventario) puede afectar M15, M16, M17, M33, M38 y M70. El mayor riesgo del proyecto no es el bug nuevo sino la regresión silenciosa.

**Análisis:**
- **Regla de dependencias:** al modificar un módulo, correr regresión sobre los módulos que dependen de él (columna Dependencias del CHECKLIST-GLOBAL).
- **Regla de estabilidad:** los flujos estables (sección 16 del AGENTS.md) se prueban en cada sesión de regresión completa; nunca se editan sin QA posterior.
- **Regla de conversión:** todo bug de regresión reproducible manualmente se deriva a un test automático en M112 (issue en M102 con la orden de conversión), de modo que la próxima vez lo detecte el CI.
- **Frecuencia:** post-cambio (áreas afectadas), post-build (smoke + áreas del cambio), post-hito (regresión completa de todas las áreas).

### 2.3 Checklist por sistema: cómo construir ítems verificables

**Análisis:** la lección de los 600+ puntos del plan inicial es que un checklist útil tiene ítems accionables, no descriptivos. Un ítem de QA debe ser: **verificable** (se puede responder sí/no), **específico** (nombra la pantalla/acción/estado), **con estado esperado** (qué debería ocurrir) y **eficiente** (cada ítem de 1-2 minutos). Patrones usados:

- Entrada → acción → salida esperada: "Abriendo el inventario con X items, se muestra la grilla de 30 slots sin solapamientos".
- Estados límite: inventario lleno, moneda en 0, salud mínima, noche profunda.
- Estados de borde de datos: items duplicados, ids vacíos, fechas límite del calendario (M29), chunks frontera (M08).
- Estados de persistencia: guardar/cargar en cada sistema crítico (M59 pendiente; la regla se define ahora).

### 2.4 Smoke tests: qué constituye una build mínimamente sana

**Análisis:** el smoke test debe ser el filtro más barato. Criterios: el juego arranca sin errores en consola, el menú principal responde, una partida nueva genera mundo sin excepciones, el jugador se mueve/interactúa/recolecta un recurso, se puede guardar y cargar, y el debug menu (M110) abre y cumple una función (ej: teletransporte). Si cualquiera de estos 7 pasos falla, la build se rechaza sin QA completo. La integración con M110 acelera los pasos (teletransporte a zonas, dar items sin grindear).

### 2.5 Sesiones por hito (M137-M141): madurez creciente del QA

**Análisis:** cada hito tiene una expectativa distinta de calidad y un checklist de área distinto:

| Hito | Qué se prueba | Nivel de QA | Criterio de salida clave |
|---|---|---|---|
| M137 Prototipo | Core vertical: mundo voxel, movimiento, herramienta básica, inventario mínimo | Para sistemas disponibles: checklist de sus áreas + smoke | No hay bugs bloqueantes en el core; el loop básico es jugable |
| M138 Vertical Slice | Sección representativa del juego completo (un templo, un vecino, una actividad) | QA completo de la slice + regresión de core | La slice se completa de inicio a fin sin workarounds |
| M139 Pre-Alpha | Todos los sistemas base integrados (sin polish artístico) | Regresión completa por áreas (todas) | 0 bugs críticos/altos abiertos; suite M112 en verde |
| M140 Alpha | Juego completo feature-complete | Regresión completa + sesiones exploratorias + primera tanda M114 | Feature-complete estable; 100% de áreas con checklist verde |
| M141 Beta | Contenido y balance completos, solo bugs de calidad | QA de cierre + M114 masivo + revisión de M142 (RC) | 0 bugs críticos; altos ≤ umbral definido; crash rate nulo (M122) |

**Decisión:** las sesiones se documentan con la misma plantilla `QA-SESSION.md` (uniformidad), pero cada hito tiene un `hito-checklist` propio en `QA-CHECKLIST.md` que referencia las áreas que ese hito debe cubrir. Esto evita duplicar el checklist maestro por hito.

### 2.6 Cómo documentar bugs (enlace con M102)

**Análisis:** M102 (Bug Tracking, ya documentado por Devin) define GitHub Issues con plantilla, categorías y severidades. QA no redefinirá eso: el módulo 101 define **el flujo de uso** desde la perspectiva del tester:

1. Todo hallazgo se convierte en issue de M102 con la plantilla oficial (pasos de reproducción, esperado, obtenido, build, entorno).
2. El QA adjunta evidencia: screenshot/video, extracto del log (M103), estado de diagnóstico exportado por el debug menu (RF20 de M110), y si aplica, crash ID de M122.
3. Severidad según M102 (crítica/alta/media/baja): bloquea o no el hito según los criterios de release (RF7).
4. Un bug no reproducible se reporta igual pero marcado `NO REPRODUCIDO` con las condiciones del entorno, semilla y pasos intentados; se re-intenta en la siguiente sesión (edge case documentado en el checklist).
5. La deduplicación (¿es el mismo bug que otro?) la hace el dueño de M102 o el agente en curso; QA reporta siempre, aunque sospeche duplicado.

### 2.7 QA manual vs automatizado (relación con M112)

**Decisión:** modelo **híbrido con reglas claras**. El autómata (M112) cubre lógica pura, serialización y flujos deterministas (rápido, barato, en cada commit vía M118). El manual cubre lo que el autómata no puede: sensación, timing, input real, fluidez de cámara, UI visual, sonido, acceso, confort cozy y casos no deterministas. Regla de oro: **todo lo que el manual detecte como reproducible y automatizable, pasa a M112** (RF10). El manual jamás se elimina: el autómata detecta regresiones de código, no problemas de diseño.

### 2.8 Calidad como definición de completado (DoD de QA)

**Análisis:** el protocolo multiagente (sección 21.6 del AGENTS.md) exige DoD por subitem y QA cruzado (21.8). El módulo 101 agrega el **DoD de QA por build/hito**: una build cumple su DoD de QA cuando (a) pasó el smoke test, (b) los checklists de las áreas incluidas en el hito están 100% `[x]`, (c) no hay bugs críticos abiertos, (d) los altos abiertos están en la lista de prioridad del hito siguiente con dueño asignado, (e) la suite de M112 corre en verde sobre la misma build, y (f) la sesión quedó documentada con firma y fecha. Sin (a)-(f), la build no avanza de hito.

## 3. Alternativas Consideradas

| Alternativa | Evaluación | Decisión |
|---|---|---|
| A1: Solo QA automatizado (M112) | No cubre sensación, UI, audio, cozy, input real; el proyecto exige calidad percibida | Rechazada: el manual es insustituible |
| A2: Solo QA manual | Lentísimo para 140+ módulos; regresiones se escapan; no hay gate en CI | Rechazada: se hibrida con A1/M112 |
| A3: Bugs en un spreadsheet/archivo | Sin trazabilidad, sin plantillas, fuera del PAT de git; M102 ya existe | Rechazada: fuente de verdad única = M102 |
| A4: Checklists monstruosos por hito | Duplicación masiva, desactualización, ítems genéricos inverificables | Rechazada: checklist maestro por área + referencias por hito |
| A5: Un único checklist global gigante | Inmanejable en una sesión; el tester no sabe por dónde empezar | Rechazada: por área, con smoke test de entrada |
| A6: Plantilla de sesión ad-hoc por tester | Resultados no comparables entre sesiones, sin firma, sin build identificada | Rechazada: plantilla única `QA-SESSION.md` obligatoria |

**Decisión final:** proceso de QA manual guiado por área, con plantillas únicas, smoke test de entrada, regresión por dependencias, conversión a M112 de lo automatizable, reporte solo por M102 y DoD de QA por hito. Todo en Markdown versionado con firma del agente.

## 4. Riesgos del Enfoque y Mitigaciones

| Riesgo | Mitigación |
|---|---|
| Checklists se desactualizan al evolucionar los módulos | Los checklists referencian el plan-actual de cada módulo; se actualizan en cada sesión de hito (ítem del checklist de documentación) |
| QA manual ejecutado por agentes con distinta capacidad de visión | Los ítems deben ser verificables por logs/estado interno (M103/M110) además de visualmente (nota en la guía del módulo) |
| Bugs críticos se acumulan entre hitos | Regla del 24h: no avanzar con críticos abiertos; los criterios de release los bloquean |
| Sesiones de hito se saltan por presión de calendario | El DoD de QA del hito es obligatorio en el protocolo (sección 21.6); el QA marca la build |
| El tester humano no encuentra el punto exacto del mundo indicado en el ítem | Cada ítem de mundo/terreno indica coordenadas o uso del debug menu (M110 RF1: teletransporte) |
| Bugs no reproducibles se pierden | Edge case documentado: marcador `NO REPRODUCIDO` + reintento programado en la siguiente sesión |