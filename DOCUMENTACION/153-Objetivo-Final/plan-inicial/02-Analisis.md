**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 153: Objetivo Final del Proyecto

## 1. Análisis del Dominio

Los 19 objetivos del plan maestro describen el **resultado emocional** del juego (hogar, curiosidad, pertenencia, pausa contemplativa). El error clásico: quedan como frases inspiracionales en un GDD y NADIE los verifica. El análisis los agrupa por naturaleza y los traduce en criterios observables:

| Grupo | Objetivos | Naturaleza | Cómo se mide |
|---|---|---|---|
| Pertenencia | O1, O3, O8, O9, O18, O19 | Vida en el pueblo | Playtest + telemetría de comportamiento |
| Curiosidad | O2, O4, O7, O10, O16 | Exploración e historia | Métricas (M104) + tests de memoria |
| Construcción | O5, O8, O9 | Agencia del jugador | Playtest + desbloqueos |
| Arquitectura | O12, O13, O15 | Salud técnica | Chequeo modular (M06/M15) |
| Identidad | O14, O17 | Coherencia narrativa | QA transversal |
| Continuidad | O6, O11 | Libertad y postgame | Playtest largo + M75 |

**Conclusión clave:** los objetivos NO se implementan — **se gobiernan**. Cada módulo dueño cumple su parte y el M153 los audita (equivalente al QA cruzado de la sección 21.8 pero sobre la visión).

## 2. Alternativas Consideradas

### 2.1 Formato del contrato de visión
- **A1. Tabla de 19 objetivos con criterio verificable + módulo dueño.** **ELEGIDA:** verificable, sin duplicar trabajo (cada dueño ya implementa).
- **A2. Lista de objetivos en el GDD general (sin dueño):** nadie los audita. Rechazada.

### 2.2 Indicadores de cumplimiento
- **A1. Mixtos: playtest estructurado (M113) + telemetría (M104) + chequeos de QA (M101).** **ELEGIDA:** cada objetivo usa el indicador más barato y confiable: los emocionales (O18, O19) miden con playtest; los de comportamiento (O2, O4) con telemetría; los técnicos (O12, O13) con chequeo de código.
- **A2. Solo telemetría:** no mide emoción. Solo playtest: caro y subjetivo. Mixto es la respuesta.

### 2.3 Auditoría
- **A1. `validate_vision.gd` (editor) + listas de verificación en M150 (Control Final) y M113 (Playtest).** **ELEGIDA:** barato, repetible, sin modificar el runtime.
- **A2. Auditoría manual "cuando haya tiempo":** nunca pasa. Rechazada.

### 2.4 Relación con los Principios (M151)
- **A1. Contrato de visión SUBORDINADO a M151:** si un criterio contradice un principio (ej.: O2 no debe exigir FOMO), el principio gana. **ELEGIDA:** M151 es el techo (cero combate, cero FOMO, sin grind), M153 es la meta (hogar, curiosidad, calma).
- **A2. Vision por encima de principios:** riesgo de derivas (grindeo "por progreso"). Rechazada.

## 3. Decisiones Técnicas

1. **Contrato en tabla (O1-O19)** con 4 columnas: objetivo, criterio verificable, indicador, módulos dueños. Vivirá en `01-Requerimientos.md` (fuente de verdad).
2. **Regla de integración:** nuevo módulo → declara objetivos O# que refuerza en su 01-Requerimientos (retroamenaza visible en el checklist del M153).
3. **Indicadores:** playtest (M113), telemetría (M104), chequeo modular (M06/M15), test narrativo (memoria de NPC, explicación de la Resonancia), QA transversal (M101).
4. **`validate_vision.gd`:** valida que cada objetivo tenga criterio y dueño; warn si un módulo no declara objetivos (excepto módulos de operaciones: build, legal... excepciones documentadas).
5. **Control Final (M150):** la checklist de M150 incluirá la "prueba de visión" O1-O19 completa.
6. **Subordinación a M151:** cero conflictos posibles (chequeado en el validator).
7. **Métricas dedicadas (M104):** "volver a casa", "acercarse a ruinas", "pausa contemplativa" — se instrumentan como eventos de telemetría.
8. **Duración de la prueba:** la "prueba de visión" corre en playtests de 30-60 min (M113), no en cada build.

## 4. Matriz de Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Objetivos olvidados en el desarrollo | Alta | Alto | Regla de integración + validate_vision.gd + checklist M153 |
| Criterios subjetivos ("se siente bien") | Media | Alto | Criterio verificable obligatorio por objetivo |
| Playtest caro/escaso | Media | Medio | Telemetría M104 cubre comportamiento; playtest solo emocional |
| Conflicto visión ↔ principios (M151) | Baja | Alto | Subordinación documentada + check en validator |
| Falsos positivos en telemetría | Media | Medio | Combinar con playtest estructurado |

## 5. Conclusiones del Análisis

- El M153 es **gobierno de la visión**, no implementación: tabla de contrato + regla de integración + validación + prueba en playtest.
- Los **indicadores mixtos** (playtest + telemetría + QA) cubren emocional Y comportamiento al menor costo.
- **M151 manda:** ningún objetivo puede violar los principios del proyecto.
- El juego se considera completo solo cuando el **Control Final (M150)** aprueba O1-O19 (criterio 2 de `01-Requerimientos`).