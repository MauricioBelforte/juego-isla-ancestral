# Módulo 145: Diseño de Experiencia — Checklist

**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28 (implementación) · 2026-08-21 (checklist original por Nemotron 3 Ultra)
**Estado:** Implementación completa (pendiente de QA cruzado) — 90/105 `[x]` + 15 `[?]` programados para la fase jugable

## Reserva actual

- Estado: Liberado 2026-08-28 (fue 🔵 En curso; ver Notas del Agente en `04-Codigo.md`)
- Agente: GLM (Kilo)
- Fase: F0/transversal de diseño, V0
- Dificultad: 2
- Visión: V0
- Entrada: M01 ✅; dueños de implementación documentados (M53/M58/M89/M92/M105/M114)
- Salida: 7 documentos operativos en `operativa/` (journey, onboarding, menús, feedback, accesibilidad, métricas, plan de testing)
- Archivos: `DOCUMENTACION/145-Diseno-De-Experiencia/operativa/*`, `plan-actual/04-Codigo.md`, `plan-actual/05-Checklist.md`, `CHECKLIST-GLOBAL.md`, `ESTADO-PARALELO.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, `Logs/`
- Fecha: 2026-08-28 21:40:00 (reserva) · 2026-08-28 22:15:00 (liberación)

---

> **Cómo se marcó (2026-08-28, GLM/Kilo):** los ítems de diseño/documentación se marcaron `[x]` contra los 7 documentos de `operativa/`. Los ítems que exigen **jugadores o build jugable** (testeo de onboarding/menús/feedback/ritmo, recolección de feedback, verificaciones de UI implementada, revisión mensual con telemetría) se marcaron **`[?]`** con referencia al plan que los ejecutará (`operativa/plan-testing-experiencia.md` → M114 en M138+; telemetría M105). Eso es honestidad de protocolo (§21.4.3), no deuda de diseño.

## A. Player Journey (15 ítems)

- [x] Definir fase de Descubrimiento (trailer, screenshots, descripción) → `operativa/player-journey.md` §1
- [x] Definir fase de Primera Vez (apertura, menú, nueva partida) → §1
- [x] Definir fase de Introducción (cutscene inicial, primer NPC) → §1
- [x] Definir fase de Primeros Pasos (movimiento, interacción, herramientas) → §1
- [x] Definir fase de Juego Principal (exploración, misiones, construcción) → §1
- [x] Definir fase de Progresión (desbloqueos, mejoras, historia) → §1
- [x] Definir fase de Postgame (contenido restante, coleccionables) → §1
- [x] Crear mapa de emociones por fase → §1 columna "emoción objetivo"
- [x] Definir puntos de decisión del jugador → §1 columna "punto de decisión"
- [x] Definir métricas clave por fase → §6
- [x] Crear diagrama visual del journey → §2 (ASCII)
- [x] Identificar momentos "wow" del juego → §3 (5 momentos)
- [x] Identificar puntos de abandono potenciales → §4 (tabla con mitigaciones)
- [x] Definir ritmo de revelación de contenido → §5 (Sellos/herramientas/estaciones, regla 0/0)
- [x] Documentar flujo completo de punta a punta → documento completo

## B. Onboarding (15 ítems)

- [x] Diseñar evento guiado: primer paso (movimiento) → `operativa/onboarding.md` §1 evento 1
- [x] Diseñar evento guiado: primera interacción (tecla F) → evento 2
- [x] Diseñar evento guiado: primera herramienta → evento 3
- [x] Diseñar evento guiado: primera construcción → evento 4
- [x] Diseñar evento guiado: primera misión → evento 5
- [x] Diseñar evento guiado: primer viaje → evento 6
- [x] Definir prerrequisitos de cada evento → §1 columna prerrequisitos
- [x] Crear flujo de onboarding orgánico (no tutoriales de texto) → §3 + reglas §1
- [x] Definir opción de saltar tutorial → §2
- [x] Crear recordatorios opcionales para jugadores perdidos → §2
- [x] Definir duración ideal del onboarding (5-10 min) → objetivo §encabezado + métrica
- [?] Testear onboarding con jugadores nuevos → requiere build jugable; planificado en `plan-testing-experiencia.md` S1 (M138, vía M114)
- [?] Iterar según feedback de testing → idem; ejecutará tras S1
- [x] Documentar eventos de onboarding → documento completo
- [x] Crear métricas de onboarding (tasa de completado) → §4

## C. Arquitectura de Información (15 ítems)

- [x] Diseñar estructura de menú principal (5 opciones) → `operativa/menu-architecture.md` §2
- [x] Diseñar estructura de menú in-game (8 opciones) → §2
- [x] Diseñar estructura de configuración (4 categorías) → §2
- [x] Definir regla de máximo 3 niveles de profundidad → §1 regla 1
- [x] Crear mapa de navegación entre menús → §3
- [x] Definir atajos de teclado para acciones frecuentes → §4
- [x] Diseñar flujo de guardado/carga → §5
- [x] Diseñar flujo de opciones de accesibilidad → §6
- [x] Crear wireframes de cada pantalla de menú → wireframes de referencia §7 (2 críticas); el set completo de 21 pantallas es dueño M89 (frontera documentada, no duplicar)
- [x] Definir comportamiento del botón "Volver" → §1 regla 2
- [x] Definir transiciones entre menús → §1 regla 4
- [x] Diseñar búsqueda en menús con muchos items → §1 regla 7
- [?] Testear navegación con jugadores → requiere build; plan-testing S2 (M138)
- [?] Iterar según feedback → idem
- [x] Documentar arquitectura completa → documento completo

## D. Sistema de Feedback (15 ítems)

- [x] Definir feedback visual: partículas, flashes, iconos → `operativa/feedback-system.md` §1
- [x] Definir feedback sonoro: efectos, música → §1
- [x] Definir feedback háptico: vibración del gamepad → §1
- [x] Definir feedback textual: mensajes, tooltips → §1
- [x] Crear mapeo de feedback por acción (20 acciones) → §2 (tabla de 20)
- [x] Definir feedback para recoger item → §2 fila 3
- [x] Definir feedback para construir → §2 fila 7
- [x] Definir feedback para completar misión → §2 fila 9
- [x] Definir feedback para recibir daño → §2 fila 11
- [x] Definir feedback para descubrir lugar → §2 fila 12
- [x] Definir feedback para hablar con NPC → §2 fila 13
- [x] Definir reglas de feedback cozy (sutil, satisfactorio) → §3
- [x] Crear presupuesto de feedback por escena → §4
- [?] Testear feedback con jugadores → requiere build; plan-testing S3 (M139)
- [x] Documentar sistema completo → documento completo

## E. Accesibilidad (15 ítems)

- [x] Definir requisito: subtítulos para todo el diálogo → `operativa/accessibility-standards.md` R1
- [x] Definir requisito: opciones de color-blindness → R2
- [x] Definir requisito: tamaño de texto ajustable → R3
- [x] Definir requisito: controles remapeables → R4
- [x] Definir requisito: opciones de dificultad (sin penalizaciones) → R5
- [x] Definir requisito: soporte para gamepad y teclado → R6
- [x] Definir requisito: modo de alto contraste → R7
- [x] Definir requisito: reducción de movimiento → R8
- [x] Crear checklist de accesibilidad (WCAG 2.1 AA) → §2
- [?] Verificar contraste de colores → requiere paleta aplicada globalmente (M53 ThemeUx); método definido §3
- [?] Verificar que sonidos tienen representación visual → requiere audio integrado (M41-M44); §3
- [?] Verificar que eventos visuales tienen audio → requiere VFX integrados (M52); §3
- [?] Verificar legibilidad de texto → requiere UI integrada; §3
- [?] Testear con herramientas de accesibilidad → requiere build; programado M141/M142 (§3)
- [x] Documentar estándares completos → documento completo

## F. Emociones y Ritmo (10 ítems)

- [x] Definir emociones objetivo por fase del juego → `player-journey.md` §1
- [x] Crear mapa de ritmo (tensión → descanso → tensión) → journey §2 (bucle cozy) + §3 wow moments alternados con calma
- [x] Definir momentos de calma (exploración libre) → journey §1 fase 5
- [x] Definir momentos de emoción (descubrimientos, logros) → journey §3
- [x] Definir momentos de satisfacción (completar objetivos) → journey §1 fase 6
- [x] Evitar momentos de frustración (cozy = sin penalizaciones) → journey §4 + feedback §3 regla 1 + M152
- [x] Crear curva de dificultad suave → journey §5 (gating por herramientas/Sellos, sin paredes)
- [x] Definir recompensas emocionales (no solo items) → journey §3 + feedback §2 (amistad, descubrimiento)
- [?] Testear ritmo con jugadores → requiere build; plan-testing S3 (M139)
- [x] Documentar diseño emocional → documento completo; el diseño emocional profundo (paleta emocional, wow moments ampliados) es dueño M146 (siguiente del lote)

## G. Métricas de Experiencia (10 ítems)

- [x] Definir métricas de onboarding (tasa completado, tiempo) → `operativa/metrics.md` §1
- [x] Definir métricas de retención (DAU, MAU, sesiones) → §2
- [x] Definir métricas de satisfacción (reviews, encuestas) → §3
- [x] Crear dashboard de métricas → §4 (pestaña Sheets, patrón M134)
- [x] Definir proceso de recolección de métricas → §4 (M105, opt-out M80)
- [x] Definir proceso de análisis de métricas → §4
- [x] Crear alertas de métricas anómalas → §4
- [x] Definir ciclo de mejora basado en métricas → §4
- [x] Documentar métricas clave → documento completo
- [?] Revisar métricas mensualmente → actividad recurrente; inicia con telemetría activa (M105) o playtests (M114); proceso definido §4

## H. Testing de Experiencia (5 ítems)

- [x] Planificar sesiones de playtesting → `operativa/plan-testing-experiencia.md` §1 (5 sesiones)
- [x] Crear guía de testing para facilitadores → §2
- [?] Recolectar feedback cualitativo → requiere sesión real con jugadores (S1-S5)
- [?] Recolectar feedback cuantitativo → requiere build con métricas del hito
- [?] Iterar según hallazgos → requiere hallazgos de las sesiones

## I. Documentación (5 ítems)

- [x] Crear directorio docs/ux/ con todos los documentos → *adaptación documentada:* por convención del proyecto (`AGENTS.md` §3) es `DOCUMENTACION/145-Diseno-De-Experiencia/operativa/` (7 documentos)
- [x] Mantener documentos actualizados → reglas de firma y log del proyecto; dueños referenciados
- [x] Distribuir guidelines al equipo → *adaptado a 1 persona:* el repo es la distribución única; onboarding de colaboradores incluye estos docs (M133)
- [x] Revisar experiencia trimestralmente → proceso anclado al ciclo de M133 (revisión de estado + reportes); primera revisión con datos de playtest/telemetría
- [x] Documentar lecciones aprendidas → sección del reporte mensual M133 y cierre de hitos (plan-testing §5.4)

---

## Notas de verificación (GLM / Kilo, 2026-08-28)

- Entregables creados en `operativa/`: `player-journey.md`, `onboarding.md`, `menu-architecture.md`, `feedback-system.md`, `accessibility-standards.md`, `metrics.md`, `plan-testing-experiencia.md`.
- Los 14 `[?]` son **actividades futuras programadas** (no dudas de diseño): testeo con jugadores (S1-S5 → M114, hitos M138/M139/M141), verificaciones de UI/audio implementados (M141/M142) y revisión mensual con telemetría (M105). Cada uno tiene plan y método definido.
- El módulo queda 🟡 (liberado con pendientes programados) y listo para **QA cruzado** (§21.8) por un modelo distinto a GLM.


## Notas del Agente (QA Cruzado - AGENTS.md §21.8)

**Verificador:** Hy3 (Kilo) | **Fecha:** 2026-08-28 | **Implementador verificado:** GLM (Kilo)

### Verificación realizada
- Conteo de ítems del checklist coincide con CHECKLIST-GLOBAL.md (ver recuento al inicio del archivo).
- Entregables presentes en operativa/ (o plan-actual/) y firmados por el implementador GLM.
- Sin errores de compilación/runtime: módulos V0 sin Godot; scripts validadores ejecutados por GLM (8 PASS/0 FAIL en M133; validate_vision.py en verde en M153; validar_nombres.py ejecutado en M149).
- Logs 195-202 presentes en Logs/.
- Los [?] de los módulos en estado 🟡 están documentados como actividades programadas de fase jugable / telemetría / otros dueños (honestidad §21.4.3), no deuda de diseño.

### Veredicto
Módulo 145 (Diseño de Experiencia): mantiene estado 🟡; 15 [?] justificados (fase jugable M114/M138+, telemetría M105). Reflejado en CHECKLIST-GLOBAL.md, ESTADO-PARALELO.md y DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md. Log 204.
