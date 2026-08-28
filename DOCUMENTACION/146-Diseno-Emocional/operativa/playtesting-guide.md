**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 146-Diseno-Emocional
**Estado:** Implementación operativa (entregable M146)

---

# Guía de Playtesting Emocional (`playtesting-guide`) — Módulo 146

> Cómo validar que el juego **siente** como debe. Ejecución real: **M114 (Playtest)** con build jugable (M138+). Complementa al plan general de M145 (`../145-Diseno-De-Experiencia/operativa/plan-testing-experiencia.md`): ese mide usabilidad; este mide emoción.

## 1. Preguntas clave (post-sesión, máximo 6)

1. ¿En qué momento te sentiste **más tranquilo/a**?
2. ¿Hubo un momento que recordás con una **sonrisa**?
3. ¿Algo te **frustró, angustió o aburrió**? (sin defender el diseño)
4. ¿Sentiste que la isla te **conocía** o te respondía? (pertenencia)
5. Si tuvieras que describir el juego en **3 palabras**, ¿cuáles?
6. ¿Qué harías **mañana** al abrir el juego otra vez? (motivación de retorno)

Regla: nunca preguntar "¿te gustó X?" (sesgo); siempre "¿qué sentiste en X?".

## 2. Checklist de emociones a verificar (durante la observación)

- [ ] La **calma** sostiene las sesiones (el jugador no acelera ansioso).
- [ ] La **curiosidad** dispara desvíos espontáneos ("¿y eso qué es?").
- [ ] La **satisfacción** cierra micro-bucles (gestos de cierre: suspiro, asentir).
- [ ] El **asombro** produce pausa observable o comentario en los reveals dosificados.
- [ ] La **pertenencia** aparece: menciona a NPCs por nombre.
- [ ] **Nada** generó frustración/ansiedad visible (tabla de emociones a evitar).
- [ ] Los **afterglow** se respetan (no hay pico tras pico).
- [ ] El ritmo emocional de la sesión alterna calma y satisfacción (no monotono, no montaña rusa).

## 3. Template de reporte emocional (copiar por sesión)

```markdown
# Reporte emocional — Sesión S{N} ({fecha})
**Build:** {etiqueta} · **Jugadores:** {N} · **Facilitador:** {quién}

## Por jugador
| # | Emoción dominante observada | Momento pico | Frase textual destacada |
|---|---|---|---|

## Palabras de descripción (pregunta 5)
{word cloud de las 3 palabras por jugador}

## Emociones a evitar detectadas
{ninguna / hallazgo con minuto y contexto}

## Wow moments: ¿funcionaron?
| WM | ¿Reacción observable? | Notas |
|---|---|---|

## Conclusiones (máximo 3)
1. {Hallazgo → cambio propuesto en el módulo dueño}
2. …

**Firma:** {Modelo} / {Plataforma}
```

## 4. Proceso de iteración

1. Priorizar hallazgos de **emociones a evitar** (críticos: rompen M152) sobre reforzamiento de positivas.
2. Un hallazgo = un cambio acotado en el módulo dueño (M41/M45/M49/M52/M21…), con log.
3. Re-test en la sesión siguiente: los hallazgos corregidos deben desaparecer.
4. Lecciones aprendidas → reporte mensual de M133 y cierre de hitos.
5. Revisión trimestral del diseño emocional completo junto a la revisión de riesgos de M135 (misma ceremonia).

## 5. Estado

- ⏳ **Pendiente de ejecución real:** requiere build jugable (M138+) y ≥ 5 jugadores para la validación del mapeo (ítem G6 del checklist). La guía, preguntas, checklist y template ya están listos.

**Firma del último agente que modificó este documento:**

**Modelo:** GLM
**Plataforma:** Kilo
