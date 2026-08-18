**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 114: Playtest

## 1. Análisis del dominio

### 1.1 ¿Qué es un playtest y por qué es crítico para Isla Ancestral?

Un playtest es una sesión en la que **jugadores reales** (representantes del público objetivo) juegan una build del juego mientras el equipo observa, registra y pregunta. A diferencia de las pruebas internas de QA (M101), que buscan bugs técnicos, el playtest busca **experiencia**: emociones, comprensión, pacing, frustración, aburrimiento, satisfacción.

Para un juego cozy estilo Stardew Valley en un mundo voxel, el playtest es **el instrumento de validación principal del tono**. El equipo ya sabe jugar su propio juego; un primerizo no. Preguntas que solo responde un playtest:

- ¿El jugador se siente **abrumado** el día 1 con los objetivos?
- ¿La cámara voxel y el mundo a cielo abierto generan **mareo** o **ansiedad** en vez de calma?
- ¿El ritmo de día/noche **estresa** o motiva?
- ¿La falta de instrucciones **frustra** o invita a explorar?
- ¿El jugador **abandona** por aburrimiento en los primeros 15 minutos?
- ¿Los sonidos y la música refuerzan la calma o la rompen?
- ¿El jugador siente **agencia** (control sobre su experiencia) o se siente empujado por el sistema?

### 1.2 Tipos de playtest relevantes para el proyecto

| Tipo | Descripción | Cuándo usarlo en Isla Ancestral |
|---|---|---|
| Playtest de prototipo | Prueba de los primeros loops (recoger, plantar, vender, dormir) con builds mínimas | Cierre del prototipo (M137): validar que el loop central es satisfactorio |
| Playtest de usabilidad | Descubre si el jugador comprende la UI, los menús, los prompts y los controles | Cada vez que se cambia UI o controles; prerrequisito de la pre-alpha |
| Playtest de tono/emocional | Mide la sensación cozy/estrés/aburrimiento mediante auto-reporte y observación | De forma transversal en todas las rondas; es el corazón de una ronda "cozy" dedicada |
| Playtest de pacing | Verifica la curva día 1 → semana 1: objetivos, recompensas, eventos | Final de pre-alpha (M139) |
| Playtest de sesión guiada | Moderador presente, think-aloud, preguntas en vivo | Primera ronda de cada hito, cuando hay más incógnitas de diseño |
| Playtest libre | Jugador solo, mínima interferencia, registro de pantalla | Segunda ronda del hito, para validar la experiencia real sin moderación |
| Playtest de regresión social | Re-testear fixes de rondas anteriores con jugadores | Al inicio de cada ronda nueva; verifica que los fixes funcionan en personas nuevas |
| Playtest de accesibilidad | Jugadores con limitaciones visuales/motoras/cognitivas | Antes del alpha (M140), con base en M58 (Accesibilidad) |

### 1.3 ¿Cuándo hacer playtests?

| Etapa | Frecuencia mínima | Foco |
|---|---|---|
| Prototipo (M137) | 1 ronda (3–5 jugadores) | Loop central, tono base, controles |
| Pre-alpha (M139) | 1 ronda por hito/mes | Pacing, UI, abrumamiento, tono |
| Alpha (M140) | 1 ronda por mes o por build mayor | Contenido, balance, retención |
| Beta/post-early access | Playtests abiertos + encuestas Steam | Datos masivos (más allá de este módulo; ver M97) |

La regla general: **una ronda por cada hito de desarrollo cerrado** y **siempre después de cambios que afecten el tono** (clima, día/noche, música, densidad de objetivos, economía).

### 1.4 ¿Cuántos jugadores?

- **Mínimo viable:** 3 jugadores por ronda (se detectan los problemas de usabilidad más groseros).
- **Ronda estándar:** 5–8 jugadores (recomendado por la regla de Nielsen de usabilidad: 5 participantes encuentran la mayoría de los problemas; 8 da margen de confianza).
- **Saturación:** si 5+ jugadores consecutivos repiten el mismo hallazgo, el problema está confirmado; no hace falta más jugadores para esa pregunta.
- **Público:** mezcla de cozy gamers (perfil principal), casuales y al menos 1 no jugador por ronda para detectar problemas de onboarding.
- **Presupuesto:** con herramientas gratuitas y Discord como canal, el costo por ronda es tiempo humano (moderación y análisis), no licencias.

### 1.5 ¿Cómo medir el tono cozy / estrés / aburrimiento?

**Enfoque mixto (cuantitativo + cualitativo), con cuatro instrumentos:**

1. **Escala Likert de emociones (encuesta post-sesión).** En español, de 1 a 5:
   - "Durante la sesión me sentí estresado/a" (1 = nada, 5 = muchísimo)
   - "Me sentí abrumado/a por la cantidad de cosas por hacer"
   - "Me sentí aburrido/a en algún momento"
   - "Me sentí tranquilo/a y relajado/a"
   - "Disfruté mi tiempo en la isla"
   - "Sentí que yo controlaba mi experiencia (y no el juego a mí)"
   - "Me dieron ganas de seguir jugando" (agencia + retención)

2. **Métricas de comportamiento (registradas por el observador o la build):** tiempo en menús, reinicios de día, veces que vuelve al spawn, cantidad de objetivos abandonados, minerales/items obtenidos por minuto, momentos de pausa larga (parálisis de decisión).

3. **Observación de señales no verbales (guion de observación):** suspiros, exclamaciones ("¿qué tengo que hacer?"), sonrisas, postura, velocidad del mouse, silencio prolongado vs comentarios espontáneos, ganas de quedarse jugando al terminar (se mide: ¿el tester siguió jugando al terminar la sesión?).

4. **Entrevista cualitativa breve (5–10 min):** "¿Qué fue lo más estresante?", "¿Qué fue lo más lindo?", "¿En qué momento quisiste dejar de jugar?", "¿Qué harías primero si volvieras a jugar?".

**Índice de tono cozy (propuesta):** agregado ponderado de las escalas:
- `TonoCozy = (Tranquilo + Disfrute + Agencia) / 3 − (Estrés + Abrumamiento + Aburrimiento) / 3`
- Rango teórico: −4 a +4. Objetivo por etapa: prototipo ≥ +0.5; pre-alpha ≥ +1.0; alpha ≥ +1.5. Se registra en el informe de cada ronda para ver tendencia entre rondas.

### 1.6 Herramientas gratuitas

| Herramienta | Uso | Costo |
|---|---|---|
| Discord (servidor de testers) | Comunicación, canales por tester, threads por sesión | Gratis |
| Google Forms | Encuesta post-sesión; exporta a Google Sheets | Gratis |
| Google Sheets | Tabla de resultados, índice de tono cozy, tendencias | Gratis |
| OBS Studio | Grabación de pantalla y webcam del tester (con consentimiento) | Gratis, open source |
| Discord (stream) | Alternativa a OBS en sesiones remotas; grabar con restream/OBS | Gratis |
| Trello / GitHub Projects | Tablero de hallazgos y su priorización | Gratis |
| Canva | Tarjetas impresionistas para el briefing del tester | Gratis |
| Notepad++ / VS Code | Edición de plantillas Markdown | Gratis |
| ShareX | Capturas de pantalla rápidas del observador | Gratis, open source |
| Google Calendar / Doodle | Coordinación de horarios de sesiones | Gratis |

### 1.7 NDA y consentimiento para jugadores

- **NDA (Acuerdo de No Divulgación):** documento breve (1 página), lenguaje claro, firmado digitalmente (o por escrito) antes de la primera sesión. Prohíbe divulgar builds, grabaciones, mecánicas no anunciadas y materiales recibidos. Vigencia: hasta el anuncio público del juego (o 2 años si no hay fecha).
- **Consentimiento informado:** permiso explícito para grabar pantalla, audio y (opcional) webcam; uso exclusivo interno (análisis del equipo); derecho a retirarse y a solicitar borrado de sus datos.
- **Tratamiento de datos personales:** conforme a M80 (Legal/Privacidad): se minimizan los datos (alias, edad, experiencia previa, hardware básico), se anonimizan en informes y se resguarda el registro de firmas.
- **Incentivo:** opcional y ético (gift card pequeña, crédito en créditos del juego, early access futuro). El incentivo no debe condicionar el feedback; se comunica que la honestidad se agradece más que los elogios.

## 2. Alternativas consideradas

| Alternativa | A favor | En contra | Decisión |
|---|---|---|---|
| Solo QA interno sin jugadores | Rápido, sin reclutamiento | No capta experiencia ni tono; sesgo del equipo | Rechazada: playtest complementa, no reemplaza |
| Playtest público masivo/abierto | Muchos datos | Sin NDA efectivo, ruido, problemas de moderación | Rechazada para pre-alpha; reservada para beta/post EA |
| Solo encuesta sin observación | Barato y rápido | No explica el "porqué"; el auto-reporte miente sin querer | Rechazada: la observación es obligatoria en todo playtest |
| Solo sesiones guiadas | Control máximo | Costoso en tiempo; el moderador influye en la experiencia | Mixta: guiada en ronda 1, libre en ronda 2 |
| Grabación de pantalla vs toma de notas en vivo | La grabación permite re-análisis | Toma de notas en vivo captura lo que la grabación no (clima, cara, contexto) | Decisión: ambas — nota en vivo + grabación como respaldo |
| Encuesta en papel | Presencial, sin fricción digital | Digitalización manual | Decisión: Google Forms (automatiza la tabulación) |
| Métricas de telemetría automática (M104) en vez de observación | Datos masivos sin observador | Requiere instrumentar el juego; no capta emociones | Decisión: complementarias; la telemetría valida en masa lo que el playtest descubre cualitativamente |

## 3. Decisiones y justificación

1. **Protocolo por rondas (3–8 jugadores, con saturación):** equilibrio entre costo indie y calidad de hallazgos (Nielsen: 5 testers detectan ~85% de problemas de usabilidad).
2. **Ronda guiada + ronda libre por hito:** la guiada genera hipótesis y detalles; la libre valida la experiencia real sin influencia del moderador. El tono cozy se corrobora mejor en la sesión libre.
3. **Medición mixta con índice de tono cozy:** una sola cifra rastreable entre rondas + desglose cualitativo para explicarla.
4. **NDA obligatorio desde la primera sesión:** protege el concepto del juego en el ecosistema indie (riesgo de clones y leaks antes del anuncio).
5. **Herramientas 100% gratuitas:** coherente con la restricción de presupuesto; la única inversión es tiempo humano, que se estandariza con las plantillas.
6. **Hallazgos priorizados por severidad × frecuencia × impacto en tono:** un bug poco frecuente pero que rompe la calma (ej: ruido agresivo al amanecer) puede superar a un bug funcional frecuente.
7. **Español íntegro (RN10):** el público inicial del proyecto es hispanohablante; se documenta la extensión a otros idiomas como mejora futura.
8. **Iteración ligada a rondas:** los fixes se comprometen a la siguiente ronda; sin re-test con personas nuevas no se considera resuelto (regresión social).