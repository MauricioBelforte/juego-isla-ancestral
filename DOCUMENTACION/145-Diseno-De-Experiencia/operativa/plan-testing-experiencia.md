**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 145-Diseno-De-Experiencia
**Estado:** Implementación operativa (entregable M145)

---

# Plan de Testing de Experiencia (`plan-testing-experiencia`) — Módulo 145

> Plan de sesiones de playtesting enfocadas en experiencia (H del checklist). Ejecución: **M114 (Playtest, dueño)** en los hitos con build jugable (M138 en adelante, según `ROADMAP.md`). Este documento planifica y da la guía; **la recolección real de feedback requiere jugadores y build** (pendiente por diseño de fases).

## 1. Sesiones planificadas

| Sesión | Hito | Participantes | Duración | Enfoque |
|---|---|---|---|---|
| S1 — Primer contacto | M138 (slice) | 3-5 jugadores nuevos | 30 min | Onboarding, claridad, primeras emociones |
| S2 — Navegación de menús | M138 | 3 jugadores | 10 min de tareas | Encontrar X en menús sin ayuda (100 % completado objetivo) |
| S3 — Loop del pre-alpha | M139 | 5 jugadores | 60 min | Ritmo del bucle diario, feedback por acción |
| S4 — Accesibilidad | M141 | 2-3 jugadores con perfil de accesibilidad | 45 min | Requisitos R1-R8 en juego real |
| S5 — Beta de equilibrio | M141 | ampliado (comunidad) | libre | Satisfacción 1-5, encuesta |

## 2. Guía para el facilitador (fundador o agente)

1. **Antes:** build etiquetado del hito + dispositivo de prueba + encuesta impresa/Google Form.
2. **Consigna al jugador:** "Juega como en casa; pensamos en voz alta si quieres. No hay forma de hacerlo mal."
3. **Durante:** observar y anotar (no ayudar); registrar minutos de cada bloqueo; nota de reacción en los momentos "wow" del journey.
4. **Preguntas post-sesión (máximo 5):**
   - ¿Qué hiciste primero y por qué?
   - ¿Hubo algo que no entendieras?
   - ¿Qué momento recordás más?
   - ¿Algo te frustró o aburrió? (sin defender el diseño)
   - Nota de diversión 1-5.
5. **Después:** volcar resultados en la plantilla de reporte (M133 reportes o M114) dentro de 48 h.

## 3. Qué se recolecta

| Tipo | Herramienta | Ejemplos |
|---|---|---|
| Cualitativo | Notas de observación + 5 preguntas | "no encontró el diario", "sonrió con el amanecer" |
| Cuantitativo | Métricas del hito (`metrics.md`) | tiempo hasta primer objetivo, % tareas de menú, nota 1-5 |

## 4. Iteración según hallazgos

1. Priorizar hallazgos que tocan requisitos (accesibilidad, onboarding) sobre preferencias estéticas.
2. Un hallazgo = un cambio acotado en el módulo dueño (M92/M89/M53/M43…) con su log.
3. Re-test de la sesión siguiente: los hallazgos corregidos deben desaparecer; si persisten 2 sesiones, revisar la hipótesis.
4. Lecciones aprendidas: sección del reporte mensual (M133) y del cierre de cada hito.

## 5. Estado de este plan

- ⏳ **Pendiente de ejecución real:** requiere build jugable (M138+) y jugadores. Es el bloque designado del roadmap; hasta entonces, los ítems de testeo de experiencia del checklist de este módulo permanecen `[?]` con referencia a este plan.
