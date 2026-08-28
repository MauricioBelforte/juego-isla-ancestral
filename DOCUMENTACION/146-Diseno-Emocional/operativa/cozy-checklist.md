**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 146-Diseno-Emocional
**Estado:** Implementación operativa (entregable M146)

---

# Cozy Checklist (`cozy-checklist`) — Módulo 146

> **Referencia rápida obligatoria** para cualquier decisión de diseño, contenido o implementación. Complementa (no reemplaza) el proceso de revisión de M152 (Principios Innegociables): si esta lista y M152 entran en conflicto, manda M152.

## 1. Las 7 preguntas "¿Esto es cozy?"

| # | Pregunta | Si la respuesta es NO |
|---|---|---|
| 1 | **¿Genera frustración?** (¿el jugador puede perder progreso, quedar bloqueado o sentirse castigado?) | Rediseñar: error debe informar, no castigar (coherente con M66/M152) |
| 2 | **¿Genera ansiedad?** (¿hay presión de tiempo, contenido que expira, miedo a "quedarse atrás"?) | Rediseñar: nada expira, sin timers agresivos, sin FOMO (M94) |
| 3 | **¿Es relajante?** (¿el ritmo permite respirar y volver a la calma?) | Rediseñar: insertar afterglow o reducir intensidad |
| 4 | **¿Es satisfactorio?** (¿el bucle cierra con un gesto de completado perceptible?) | Añadir feedback de cierre (M145 feedback) o acortar el bucle |
| 5 | **¿Es accesible?** (¿puede jugarlo alguien con las opciones R1-R8 activadas?) | Cumplir estándares de M145/M58 antes de aprobar |
| 6 | **¿Es amigable?** (¿el tono con NPCs, textos y errores es cálido y sin sarcasmo cruel?) | Revisar textos (M21/M88); el error siempre da la solución |
| 7 | **¿Qué emoción de la paleta refuerza?** (calma, curiosidad, satisfacción, asombro, pertenencia, nostalgia) | Si refuerza una emoción a evitar → rediseñar (paleta M146) |

## 2. Ejemplos de aplicación

### ✅ Decisión cozy (ejemplos reales del proyecto)
- **Error al usar la herramienta sobre bloque inválido:** sonido suave + mensaje "necesitas un pico" (informar, no castigar) — pasa las 7.
- **Festival que "se perdió":** vuelve el próximo año con variantes (M74/M94) — pasa 2 y 7 (pertenencia).
- **Guardar siempre posible** con indicador no bloqueante (M59) — pasa 1, 2 y 4.
- **Decorar la casa sin requisitos funcionales** — pasa 3, 4 y 7 (nostalgia).
- **Cultivo que no muere si no lo riegas un día** — pasa 1, 2 (M152: hambre/mantenimiento no castigador).

### ❌ Decisión NO cozy (contraejemplos, prohibidos)
- **Streak diario con recompensa que se rompe** → genera ansiedad/culpa (falla 2).
- **Stock de ítem único que se agota para siempre** → FOMO (falla 2).
- **Muerte permanente de cultivos por abandono** → frustración/culpa (falla 1).
- **Timer de puzzle agresivo con muerte** → ansiedad (falla 2 y 3).
- **NPC que se burla del jugador por fallar** → no amigable (falla 6).
- **Recompensa solo accesible con reflejos rápidos** → excluye accesibilidad (falla 5).

## 3. Uso obligatorio

1. **Quién:** todo agente antes de marcar `[x]` un ítem de diseño/gameplay, y el fundador al aprobar features nuevas.
2. **Cuándo:** en cada decisión de diseño, en el QA cruzado (§21.8: verificar contra esta lista) y en cada revisión trimestral del diseño emocional.
3. **Cómo se registra:** si una decisión falla una pregunta y se aprueba igual, se necesita **desviación justificada** (proceso de M152/§21.4) — sin excepciones silenciosas.
4. **Distribución:** vive versionado en el repo (equipo de 1 persona + agentes; la lectura de esta guía es parte del onboarding de M133). Revisión trimestral del texto junto a la paleta emocional.

**Firma del último agente que modificó este documento:**

**Modelo:** GLM
**Plataforma:** Kilo
