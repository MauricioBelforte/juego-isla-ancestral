# Módulo 146: Diseño Emocional — Análisis

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:33:00

## 1. Análisis del Dominio

### Paleta Emocional de Juegos Cozy

| Emoción | Descripción | Ejemplo en Isla Ancestral |
|---------|-------------|--------------------------|
| **Calma** | Tranquilidad, relajación | Explorar la isla al atardecer |
| **Curiosidad** | Ganas de descubrir | Encontrar una cueva oculta |
| **Satisfacción** | Logro cumplido | Completar una construcción |
| **Asombro** | Maravilla ante la belleza | Ver una cascada por primera vez |
| **Pertenencia** | Sentirse parte del lugar | Ser aceptado por los NPCs |
| **Nostalgia** | Recuerdos tiernos | Decorar la casa con recuerdos |
| **Logro** | Sentirse capaz | Desbloquear una herramienta nueva |

### Emociones a EVITAR

| Emoción | Por qué evitarla | Cómo prevenirla |
|---------|------------------|-----------------|
| **Frustración** | Rompe la experiencia cozy | Sin penalizaciones, hints opcionales |
| **Aburrimiento** | El jugador abandona | Ritmo constante, contenido fresco |
| **Ansiedad** | No es el tono del juego | Sin timers, sin presión |
| **Confusión** | El jugador se pierde | Onboarding claro, feedback |
| **Miedo** | No es un juego de terror | Diseño amigable, sin jump scares |

## 2. Decisiones de Diseño

### Decisión 1: Enfoque del Diseño Emocional

**Opción A:** Emociones como resultado de mecánicas
- Pro: Orgánico, auténtico
- Contra: Difícil de controlar

**Opción B:** Emociones como objetivo explícito
- Pro: Controlable, medible
- Contra: Puede ser forzado

**Decisión:** Combinación. Emociones como objetivo de diseño, pero logradas orgánicamente vía mecánicas, no vía scripts forzados.

### Decisión 2: Medición de Emociones

**Opción A:** Métricas indirectas (retención, tiempo de sesión)
- Pro: Fácil de medir
- Contra: No dice QUÉ siente el jugador

**Opción B:** Feedback directo (encuestas, playtesting)
- Pro: Entiende emociones reales
- Contra: Subjetivo, costoso

**Decisión:** Ambas. Métricas para tendencias, playtesting para profundidad.

### Decisión 3: Momentos Memorables

**Opción A:** Pocos momentos "wow" muy impactantes
- Pro: Memorables, compartibles
- Contra: Difíciles de crear

**Opción B:** Muchos pequeños momentos de satisfacción
- Pro: Constante, coherente
- Contra: Puede no ser memorable

**Decisión:** Combinación. Unos pocos "wow moments" + constante small satisfactions.

## 3. Análisis de Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| Emociones no se generan | Media | Alto | Playtesting constante |
| Mecánicas generan frustración | Media | Crítico | Test con jugadores diversos |
| Audio no apoya emociones | Baja | Alto | Colaboración con M41-44 |
| Momentos memorables no funcionan | Media | Medio | Iterar según feedback |
| Experiencia no es cozy | Baja | Crítico | Checklist de cozy en cada decisión |
