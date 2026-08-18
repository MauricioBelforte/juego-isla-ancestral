**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 114: Playtest

## 1. Carácter del Componente

Módulo de **procesos y documentación operativa** para sesiones de playtest con jugadores reales. No requiere código GDScript en el juego (Godot 4.x): sus entregables son **plantillas Markdown** de guía de sesión, encuesta post-sesión e informe de hallazgos, más la definición de flujos de análisis e iteración.

**06-Plan-Testings.md:** NO aplica (es un módulo de documentación y procesos, no código que requiere tests automatizados; la verificación se realiza mediante el checklist del módulo y las pruebas manuales del flujo de sesión).

## 2. Archivos previstos (implementación)

> ⚠️ **Pendiente de implementación.** Los archivos y estructuras siguientes son la especificación de lo que un agente de implementación debe crear. No existen todavía en el repositorio.

```
docs/playtest/
├── PLAYTEST-GUIA.md                  → Guía de sesión completa (incluye guion de preguntas y hoja de observación)
├── PLAYTEST-ENCUESTA.md              → Plantilla de encuesta post-sesión + fórmula del índice de tono cozy
├── PLAYTEST-INFORME.md               → Plantilla de informe de hallazgos de ronda
├── README.md                         → Explicación del uso del protocolo (cómo planificar una ronda en 30 min)
└── sesiones/                         → Archivo de materiales por sesión (grabaciones, notas, exports)
    └── AAAA-MM-DD_{ronda}_{aliasTester}/   → Nomenclatura estandarizada de respaldo
```

## 3. Esqueleto de las plantillas

### 3.1 `PLAYTEST-GUIA.md` (esqueleto — pendiente de implementación)

```markdown
# Guía de Sesión de Playtest — Isla Ancestral

## Encabezado
- Build: {hash/commit} | Fecha: {AAAA-MM-DD} | Hito: {M137 Prototipo / M139 Pre-Alpha}
- Ronda: {nombre} | Tipo: {GUIADA / LIBRE}
- Pregunta central: {UNA pregunta accionable}

## Perfiles requeridos
- [ ] Cozy gamer (1-2) | [ ] Casual (1-2) | [ ] No jugador (1)

## Preparación
- [ ] Build instalada y guardados limpios pre-generados
- [ ] NDA y consentimiento firmados
- [ ] Encuesta activa (Google Forms)
- [ ] OBS / stream de Discord configurado
- [ ] Materiales del briefing listos

## Briefing (5 min)
"Gracias por venir a probar Isla Ancestral. Queremos entender CÓMO SE SIENTE jugar,
no si te gustó o no. No hay respuestas incorrectas. Por favor, pensá en voz alta
mientras jugás. Podés abandonar cuando quieras. La honestidad nos ayuda más que los elogios."

## Escenario
{Descripción del mundo, punto de partida y restricciones}

## Tareas guiadas (opcional)
- [ ] T1: Plantar el primer cultivo
- [ ] T2: Vender 5 items
- [ ] T3: Dormir para pasar al día 2

## Guion de preguntas
- "¿Qué estás pensando mientras hacés eso?"
- "¿Qué creés que tenés que hacer ahora?"
- "¿Algo te confundió recién?"
- "¿Cómo te sentís con la cantidad de cosas que te marca la pantalla?"
- "¿Sabés dónde está tu casa / el pueblo / la playa?"
- "¿El ruido o la música te molesta o te relaja?"
- "¿Sentís que perdiste el tiempo en algún momento?"
- "¿Qué hubieras hecho si esto no te saliera?"

## Hoja de observación
| Tiempo | Código | Descripción breve | Impacto tono (-5..+1) | Nota |
|--------|--------|-------------------|----------------------|------|
| {mm:ss} | {DUD/FRU/ABU/OVR/SAT/CAL/ERR/DLN/TRY/SKP} | {descripción} | {valor} | {nota} |

## Bloques de tiempo (total 80 min)
Briefing 5' → Juego libre 40' → Tareas guiadas 15' → Encuesta 10' → Entrevista 10'

## Cierre
- Agradecimiento y recordatorio de NDA
- Canal de contacto para preguntas posteriores

## Notas de la sesión
{Anotaciones libres del moderador}
```

### 3.2 `PLAYTEST-ENCUESTA.md` (esqueleto — pendiente de implementación)

```markdown
# Encuesta Post-Sesión — Isla Ancestral
Fecha límite: dentro de las 2 horas posteriores a la sesión.

## A. Datos de sesión
- Código de tester: {alias} | Fecha: {AAAA-MM-DD} | Build: {hash}
- Edad: {rango} | Experiencia previa en juegos cozy: {nunca / poca / mucha} | Horas de juego semanales: {n}

## B. Tono emocional (1 = nada, 5 = muchísimo)
1. Durante la sesión me sentí estresado/a: [1-5]
2. Me sentí abrumado/a por la cantidad de cosas por hacer: [1-5]
3. Me sentí aburrido/a en algún momento: [1-5]
4. Me sentí tranquilo/a y relajado/a: [1-5]
5. Disfruté mi tiempo en la isla: [1-5]
6. Sentí que yo controlaba mi experiencia: [1-5]
7. Me dieron ganas de seguir jugando: [1-5]

## C. Comprensión (1 = nada, 5 = totalmente)
8. Supe qué hacer en todo momento: [1-5]
9. Entendí a dónde ir al despertar: [1-5]
10. Los avisos de la UI me ayudaron: [1-5]

## D. Cuantitativo de juego (auto-reporte)
11. Objetivos cumplidos: {n}
12. Reinicios de día / muertes: {n}
13. Items obtenidos: {n}
14. Tiempo total jugado: {minutos}

## E. Cualitativo
15. Lo que MÁS me gustó: {texto}
16. Lo que MENOS me gustó: {texto}
17. El momento más estresante: {texto}
18. El momento más lindo: {texto}
19. Si pudiera cambiar UNA cosa sería: {texto}

## F. Perfil emocional
20. ¿En qué momento quisiste dejar de jugar? {nunca / momento específico / texto}
21. ¿Jugarías 30 minutos más ahora mismo? {sí / no / quizás}

---
## Índice de tono cozy (Google Sheets)
TonoCozy = (Q4 + Q5 + Q6)/3 - (Q1 + Q2 + Q3)/3
Rango: -4 a +4 | Meta prototipo: >= +0.5 | Meta pre-alpha: >= +1.0
```

### 3.3 `PLAYTEST-INFORME.md` (esqueleto — pendiente de implementación)

```markdown
# Informe de Hallazgos — Isla Ancestral — Ronda {nombre}
Fecha: {AAAA-MM-DD} | Hito: {M137/M139} | Build: {hash}

## Resumen ejecutivo
- Pregunta central: {pregunta}
- Respuesta en 2 líneas: {respuesta}
- Índice de tono cozy: {valor} (tendencia: {anterior} -> {actual})

## Datos de la ronda
| Jugador (alias) | Tipo de sesión | Build | Archivo archivado |
|---|---|---|---|

## Hallazgos
| ID | Título | Evidencia | Severidad (S1-S4) | Frecuencia | Impacto en tono | Módulo destino |
|----|--------|-----------|-------------------|------------|-----------------|----------------|
| H-001 | {título} | {cita/evento/sesión} | {S1..S4} | {n/N} | {-5..+1} | {M101/M102/M93/M114} |

## Escala de severidad
S1 bloqueante (crash, pérdida de guardado, progreso imposible) | S2 mayor (bloqueo parcial, confusión grave)
S3 menor (fricción leve) | S4 cosmético (estética, pulido)

## Índice de tono cozy por jugador
| Jugador | Tranquilo | Disfrute | Agencia | Estrés | Abrumamiento | Aburrimiento | TonoCozy |
|---|---|---|---|---|---|---|---|
| {alias} | {Q4} | {Q5} | {Q6} | {Q1} | {Q2} | {Q3} | {fórmula} |

## Observaciones clave (citas anonimizadas)
- "{cita}" — tester {alias}

## Priorización de fixes (máximo 5 comprometidos)
| # | Fix | Prioridad (S x Frec x Tono) | Responsable | Módulo | Ronda de verificación |
|---|-----|----------------------------|-------------|--------|-----------------------|

## Derivaciones
- M102: issues creados {ids}
- M93: hallazgos de balance comunicados {ids}
- M104: solicitudes de instrumentación {ids}
- M101: sospechas a verificar {ids}

## Seguimiento de rondas anteriores
| Fix | Ronda de origen | Estado en esta ronda (resuelto/pendiente/retest) |
|-----|-----------------|---------------------------------------------------|

## Lecciones de proceso
- {qué funcionó del método} | {qué mejorar para la próxima ronda}
```

## 4. Ejemplo de aplicación (ficticio, para ilustrar el formato)

**Ronda R1-Prototipo (sesión guiada), tester T-03 (no jugador):**

- Evento 12:34 | FRU | "Otra vez me caí al agua y perdí lo que llevaba" | -4 | jugador abandonó el objetivo de recolectar.
- Evento 27:05 | OVR | "¿Tengo que regar TODO esto todos los días?" | -3 | tres cultivos plantados por error repetido.
- Encuesta T-03: Estrés 4, Abrumamiento 4, Aburrimiento 2, Tranquilidad 2, Disfrute 3, Agencia 2, Ganas de seguir 2 → TonoCozy = (2+3+2)/3 - (4+4+2)/3 = 2.33 - 3.33 = **-1.0**.
- Hallazgo H-007: "Perder items al caer al agua genera frustración desproporcionada (rompe la calma)" — S2, 4/5 jugadores, impacto -4 → Prioridad = 6 x 0.8 x 4 = **19.2** → comprometido como fix prioritario en la ronda R2 (verificar con regresión social: evento F-007 en la hoja de observación).
- Derivación: H-007 también informado a M93 (mecánica de pérdida de items vs economía) y registrado en el informe como insumo del DoD del prototipo (M139).

## 5. Contratos de integración

### Entrada
- **M137 (Prototipo):** builds estables y funcionalidades mínimas a testear.
- **M139 (Pre-Alpha):** builds de hito y criterios de entrada/salida.
- **M101 (QA General):** áreas de riesgo técnico a observar en sesión.
- **M93 (Balance):** curvas de dificultad y economía a vigilar.
- **M152 (Principios Innegociables):** definición operativa del tono cozy.

### Salida
- **M102 (Bug Tracking):** issues con severidad, evidencia y referencia `RNDA-{n}-H-###`.
- **M93 (Balance):** informes de desbalance con evidencia cuantitativa.
- **M104 (Analytics):** métricas de comportamiento a instrumentar.
- **M139/M140:** informes de ronda como insumo de DoD de hito.
- **5-FUTURAS-MEJORAS:** ideas de contenido futuro detectadas en sesiones (vía usuario).

## 6. Decisiones de implementación registradas

- Las plantillas son **Markdown** (no se requiere tooling); se elige GitHub/VS Code como editor y Google Forms + Sheets como tabulador, todo gratuito.
- El proyecto es **Godot 4.x + Voxel Tools con GDScript**; este módulo no introduce scripts. Si en el futuro se instrumenta telemetría de sesión dentro del juego, eso pertenece a M104 (Analytics) y M105 (Telemetría de Gameplay).
- Las plantillas son agnósticas al motor: el mismo formato sirve para el prototipo voxel y para la pre-alpha.
- Los archivos de sesión (grabaciones, fotos, exports de encuestas) se guardan fuera del control de versiones del juego o en un repositorio privado, dado que contienen datos personales de testers (M80 Legal/Privacidad).

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa, DELEGABLE PARA IMPLEMENTAR

### Lo que hice
- Creé la documentación completa del módulo 114 (Playtest): 01-Requerimientos, 02-Análisis, 03-Diseño, 04-Código y 05-Checklist (más de 120 ítems).
- Definí el protocolo de rondas (planificar → reclutar → ejecutar → analizar → priorizar → iterar), con sesiones guiadas y libres.
- Definí el **índice de tono cozy** (TonoCozy = (Tranquilo+Disfrute+Agencia)/3 − (Estrés+Abrumamiento+Aburrimiento)/3) como métrica rastreable entre rondas, con metas por etapa.
- Especifiqué 3 plantillas Markdown pendientes de implementación: `PLAYTEST-GUIA.md` (con guion y hoja de observación con códigos), `PLAYTEST-ENCUESTA.md` (con fórmula del índice) y `PLAYTEST-INFORME.md` (con priorización por severidad × frecuencia × impacto en tono).
- Documenté la integración con M101 (QA General), M102 (Bug Tracking), M93 (Balance), M104 (Analytics), M137 (Prototipo), M139 (Pre-Alpha) y M152 (Principios Innegociables).
- Documenté edge cases: tester demasiado familiarizado, pocos testers, feedback contradictorio (detalle en 05-Checklist.md).
- Verifiqué que plan-inicial y plan-actual son idénticos byte a byte (mismos hashes SHA-256).

### Lo que NO pude hacer (honestidad obligatoria)
- **Ejecutar playtests reales:** requiere jugadores reales y un prototipo jugable (M137), que aún no existe. El protocolo es especificación, no resultados.
- **Validar las preguntas del guion en la práctica:** el wording de la encuesta y del índice de tono cozy necesitan al menos una ronda piloto para calibrar (¿los no jugadores entienden las escalas?).
- **Verificar compatibilidad de herramientas:** se asumió disponibilidad de Google Forms/Sheets, OBS Studio y Discord, pero la configuración real del entorno de sesión debe probarse en una sesión de ensayo.
- **Crear las plantillas físicas** en `docs/playtest/`: marcadas como pendiente de implementación en 04-Codigo.md.
- **Actualizar CHECKLIST-GLOBAL.md y la documentación general (`*-ACTUAL.md`)**: fuera del alcance explícito de esta tarea (se restringió a `DOCUMENTACION/114-Playtest/`); el agente implementador debe hacerlo al activar el módulo.

### Recomendaciones para el próximo agente
- Al implementar: crear `docs/playtest/` con las 3 plantillas + README, usando los esqueletos de la sección 3 como base literal.
- Ejecutar una **sesión piloto de ensayo** (con un miembro del equipo) antes de la primera sesión con testers reales: calibrar tiempos, claridad de las preguntas y la fórmula del índice de tono cozy.
- Al cerrar el prototipo (M137), planificar la Ronda R1 con la pregunta central: "¿el loop recoger → plantar → vender → dormir es satisfactorio y transmite calma?".
- Antes de la pre-alpha (M139), confirmar que el NDA y el consentimiento cumplan M80 (Legal/Privacidad).
- Verificar la integración con M102: probar el flujo completo informe → issue → fix → regresión social en una ronda real.
- Actualizar CHECKLIST-GLOBAL.md (fila 114) y los `*-ACTUAL.md` de la raíz de DOCUMENTACION/ cuando el módulo se active o complete, siguiendo el protocolo multiagente (sección 21 de AGENTS.md).
- Recordar: los fixes de tono cozy tienen prioridad por sobre bugs funcionales menores (el tono es el producto).
