**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 114: Playtest

## 1. Problema y objetivos

- [ ] Documentar el problema del sesgo del equipo: el desarrollador no puede evaluar el tono cozy de su propio juego [S]
- [x] Definir el objetivo primario del módulo: medir y mejorar la experiencia real de jugadores con sesiones de playtest [S]
- [x] Establecer que el playtest complementa (no reemplaza) al QA técnico (M101) [S]
- [ ] Definir objetivos por etapa: prototipo (M137), pre-alpha (M139) y alpha (M140) [M]
- [ ] Establecer el principio de que el tono cozy es el criterio central de evaluación de todo hallazgo [S]
- [ ] Definir el alcance del módulo: qué incluye (sesiones, observación, encuestas, informes, iteración) y qué excluye (telemetría, bugs, balance) [M]
- [ ] Documentar las restricciones del proyecto indie: presupuesto reducido y herramientas gratuitas [S]
- [ ] Definir criterios de aceptación verificables del módulo: plantillas listas, métricas definidas, integraciones documentadas [M]

## 2. RF — Planificación de rondas

- [x] Definir el ciclo de ronda de playtest con 6 etapas: planificar, reclutar, ejecutar, analizar, priorizar, iterar [M]
- [ ] Establecer la frecuencia mínima: una ronda por hito de desarrollo cerrado [S]
- [ ] Definir ronda obligatoria al cierre del prototipo (M137) [S]
- [ ] Definir ronda por hito de la pre-alpha (M139) [S]
- [ ] Exigir una pregunta central accionable (una sola) por cada ronda [S]
- [ ] Definir plantilla de guía de sesión completada antes de empezar el reclutamiento [M]
- [ ] Definir tamaño de ronda: mínimo 3 jugadores, estándar 5-8 [M]
- [ ] Implementar la regla de saturación: 5 jugadores consecutivos con el mismo hallazgo confirman el problema [M]
- [ ] Definir composición de perfiles: cozy gamers, casuales y al menos un no jugador [M]
- [ ] Establecer timeline de sesión: briefing 5 min, juego libre 40 min, tareas 15 min, encuesta 10 min, entrevista 10 min [M]

## 3. RF — Reclutamiento y preparación

- [ ] Definir canales de reclutamiento gratuitos: Discord, comunidades cozy, amigos del equipo [S]
- [x] Redactar convocatoria de tester con criterios de exclusión (sin spoilers del roadmap, sin desarrollo de juegos) [M]
- [ ] Exigir firma de NDA antes de la primera sesión [S]
- [ ] Definir contenido mínimo del NDA: prohibición de divulgación de builds, mecánicas y grabaciones [M]
- [ ] Definir consentimiento informado de grabación (pantalla, audio, webcam opcional) [M]
- [x] Documentar el derecho del tester a retirarse y solicitar borrado de datos [S]
- [ ] Establecer incentivo opcional y ético (gift card pequeña, créditos, early access) [S]
- [ ] Documentar que el incentivo no debe condicionar el feedback (se pide honestidad explícita) [S]
- [x] Definir preparación de la build de testeo: guardados limpios pre-generados [M]
- [x] Definir registro de la build testeada (hash/commit) en cada sesión [S]
- [ ] Verificar instalación de herramientas: OBS Studio, Google Forms, Discord, tablero de hallazgos [M]
- [ ] Definir manejo de datos personales según M80 (Legal/Privacidad): minimización y anonimización [M]

## 4. RF — Sesiones guiadas

- [ ] Definir el rol del moderador en sesiones guiadas [S]
- [ ] Escribir el discurso de briefing estándar en español (5 minutos) [S]
- [x] Definir la técnica think-aloud y su instrucción al tester [S]
- [ ] Establecer regla de no ayuda: el moderador no da la solución salvo bloqueo absoluto [S]
- [ ] Definir la regla de los 10 segundos de silencio antes de intervenir [S]
- [ ] Registrar la reacción del jugador y no la opinión del moderador [S]
- [ ] Definir tareas guiadas opcionales por ronda (ej: plantar primer cultivo, vender 5 items) [M]
- [ ] Establecer puntos de control de preguntas en momentos clave (objetivo cumplido/fallido) [M]
- [x] Definir manejo del tester bloqueado: registrar el evento y ayudar solo al final [S]
- [ ] Definir duración máxima de sesión guiada: 80 minutos totales [S]
- [ ] Establecer que el moderador completa la hoja de observación en vivo con códigos [M]
- [ ] Definir cierre de sesión: agradecimiento, recordatorio de NDA y canal de contacto [S]

## 5. RF — Sesiones libres

- [ ] Definir sesión libre: jugador solo con instrucciones mínimas escritas [S]
- [ ] Establecer distancia de observación: el equipo no interviene salvo emergencia técnica [S]
- [ ] Definir registro de pantalla continuo con OBS o stream privado de Discord [M]
- [x] Definir instrucciones escritas estándar para el tester libre [S]
- [ ] Establecer que la sesión libre no incluye tareas guiadas salvo pedido explícito [S]
- [ ] Definir duración de sesión libre: 40-50 minutos de juego sin interrupciones [S]
- [x] Medir si el tester sigue jugando al terminar el tiempo (indicador de disfrute) [M]
- [ ] Definir análisis de la grabación posterior con la misma hoja de observación [M]
- [ ] Establecer que la encuesta se aplica igual que en sesión guiada [S]
- [ ] Documentar la recomendación de usar sesiones libres como segunda ronda de cada hito [S]

## 6. RF — Observación y registro

- [ ] Definir los códigos de observación: DUD, FRU, ABU, OVR, SAT, CAL, ERR, DLN, TRY, SKP [M]
- [ ] Documentar el significado de cada código con ejemplos en español [M]
- [ ] Definir columnas de la hoja de observación: tiempo, código, descripción, impacto en tono, nota [M]
- [ ] Definir escala de impacto en tono: de -5 (rompe la calma) a +1 (no afecta) [M]
- [ ] Establecer que cada evento se registra en menos de 5 segundos [S]
- [ ] Definir registro de señales no verbales: suspiros, exclamaciones, postura, velocidad de mouse [M]
- [ ] Definir registro de pausas largas como indicador de parálisis de decisión [M]
- [ ] Establecer que el observador resume 3 momentos memorables por sesión [S]
- [x] Establecer que el observador anota al menos 1 cita textual del tester [S]
- [ ] Definir registro de datos de juego: objetivos completados, reinicios, items obtenidos [M]
- [ ] Definir registro de fallos técnicos con código ERR y su derivación a M102 [S]
- [ ] Establecer que las grabaciones se archivan como respaldo del análisis en vivo [M]
- [ ] Definir la re-observación de grabaciones para eventos perdidos en vivo [M]
- [ ] Establecer que el observador es distinto del moderador cuando el equipo lo permite [S]

## 7. RF — Encuestas post-sesión

- [ ] Definir encuesta post-sesión aplicada dentro de las 2 horas posteriores a la sesión [S]
- [ ] Definir formulario en Google Forms con exportación automática a Google Sheets [M]
- [ ] Definir bloque de datos de sesión: alias, fecha, build, edad, experiencia cozy, horas semanales [S]
- [ ] Definir las 7 escalas Likert 1-5 de tono emocional (estrés, abrumamiento, aburrimiento, tranquilidad, disfrute, agencia, ganas de seguir) [M]
- [ ] Definir bloque de comprensión con Likert 1-5 (supe qué hacer, entendí a dónde ir, la UI ayudó) [M]
- [ ] Definir bloque cuantitativo de auto-reporte: objetivos, reinicios, items, tiempo total [M]
- [ ] Definir preguntas cualitativas de texto libre (lo que más gustó, lo que menos gustó, momentos estresantes/lindos, cambio sugerido) [M]
- [ ] Definir pregunta de abandono emocional: "¿en qué momento quisiste dejar de jugar?" [S]
- [ ] Definir pregunta de retención: "¿jugarías 30 minutos más?" [S]
- [ ] Documentar la fórmula del índice de tono cozy en la plantilla de encuesta [M]
- [x] Definir umbral de respuesta: mínimo 80% de testers completan la encuesta [S]
- [ ] Documentar que el lenguaje de las preguntas es accesible para no jugadores [S]

## 8. RF — Informe de hallazgos

- [ ] Definir informe por ronda con resumen ejecutivo de 2 líneas [S]
- [ ] Definir sección de datos de ronda: fechas, jugadores, builds, materiales archivados [S]
- [ ] Definir tabla de hallazgos con ID único H-### [S]
- [ ] Definir campos de hallazgo: título, evidencia, severidad (S1-S4), frecuencia, impacto en tono, módulo destino [M]
- [ ] Definir escala de severidad: S1 bloqueante, S2 mayor, S3 menor, S4 cosmético [S]
- [ ] Incluir el índice de tono cozy por jugador y el promedio de ronda [M]
- [ ] Incluir tendencia del índice entre rondas (historial acumulado) [M]
- [ ] Incluir citas textuales anonimizadas más reveladoras [S]
- [ ] Definir sección de derivaciones: issues de M102, comunicados a M93/M104 [M]
- [ ] Definir sección de seguimiento de fixes de rondas anteriores [M]
- [ ] Definir sección de lecciones de proceso para mejorar el propio método [S]
- [ ] Establecer que el informe se completa en menos de una semana tras la ronda [S]

## 9. RF — Priorización e iteración de diseño

- [ ] Definir fórmula de prioridad: severidad x (frecuencia/total) x impacto en tono (valor absoluto) [M]
- [ ] Definir pesos de severidad: S1=10, S2=6, S3=3, S4=1 [S]
- [ ] Establecer que los hallazgos S1 se priorizan por encima de todo [S]
- [ ] Establecer que un hallazgo que rompe el tono cozy supera a bugs funcionales menores [S]
- [ ] Definir protección de hallazgos positivos de alto impacto (criterio de regresión social) [M]
- [ ] Definir límite de 5 fixes comprometidos por ronda (realismo indie) [S]
- [ ] Definir que cada fix tiene responsable, módulo destino y ronda de verificación [M]
- [x] Definir flujo de regresión social: retest del fix con jugadores nuevos en la ronda siguiente [M]
- [ ] Definir criterio de fix verificado: no reaparece en 2/3 de los jugadores nuevos [M]
- [ ] Definir retorno de fixes no verificados a la priorización con nueva evidencia [S]

## 10. RF — Archivo, privacidad y trazabilidad

- [x] Definir nomenclatura de archivo de sesión: AAAA-MM-DD_{ronda}_{aliasTester} [S]
- [ ] Definir que grabaciones y datos personales se guardan fuera del repositorio público del juego [M]
- [ ] Definir trazabilidad completa: sesión -> hallazgo -> issue -> fix -> verificación [M]
- [ ] Definir codificación de referencias cruzadas: RNDA-{n}-H-### [S]
- [ ] Establecer que los informes acumulados por etapa muestran la evolución del tono [M]
- [ ] Definir que los NDA y consentimientos se archivan con respaldo físico/digital [M]
- [x] Establecer retención de datos mínima necesaria y borrado a solicitud del tester [M]
- [x] Definir que las ideas de contenido futuro de los testers se registran en 5-FUTURAS-MEJORAS vía el usuario [S]

## 11. Requisitos No Funcionales

- [x] Documentar RN1: confidencialidad de datos de testers según M80 [S]
- [ ] Documentar RN2: repetibilidad del protocolo entre rondas con variables documentadas [M]
- [ ] Documentar RN3: herramientas 100% gratuitas o de bajo costo [S]
- [ ] Documentar RN4: escalabilidad del protocolo de 3 a 8+ jugadores sin cambiar el método [S]
- [ ] Documentar RN5: sesión tipo de 60-90 minutos incluyendo consentimiento y encuesta [S]
- [ ] Documentar RN6: plantillas completables en menos de 5 minutos por evento registrado [S]
- [ ] Documentar RN7: trazabilidad de todo hallazgo hasta su resolución [S]
- [ ] Documentar RN8: ningún hallazgo se resuelve contradiciendo M152 (Principios Innegociables) [M]
- [ ] Documentar RN9: lenguaje de encuestas accesible para no jugadores [S]
- [ ] Documentar RN10: todas las plantillas y guiones íntegramente en español [S]

## 12. Análisis del dominio

- [x] Analizar los tipos de playtest aplicables al proyecto (prototipo, usabilidad, tono, pacing, guiado, libre, regresión social, accesibilidad) [M]
- [ ] Determinar cuándo corresponde cada tipo según la etapa del proyecto [M]
- [x] Justificar la frecuencia de playtest por etapa (prototipo 1 ronda, pre-alpha por hito) [M]
- [x] Fundamentar el tamaño de muestra con la regla de Nielsen (5 testers detectan ~85% de problemas) [M]
- [ ] Definir composición de público: mezcla de perfiles con al menos un no jugador por ronda [M]
- [ ] Analizar y adoptar enfoque mixto cuantitativo + cualitativo para medir emociones [M]
- [ ] Definir las 7 escalas Likert de tono emocional en español [M]
- [ ] Definir métricas de comportamiento complementarias (tiempo en menús, reinicios, pausas largas) [M]
- [ ] Definir observación de señales no verbales para validar el auto-reporte [M]
- [ ] Diseñar la fórmula del índice de tono cozy con rango -4 a +4 y metas por etapa [M]
- [ ] Evaluar herramientas gratuitas: Discord, Google Forms/Sheets, OBS Studio, Trello, ShareX [S]
- [ ] Analizar el requisito de NDA y consentimiento para el ecosistema indie (riesgo de leaks) [M]
- [x] Evaluar alternativas descartadas (solo QA, playtest público, solo encuesta, solo guiado) con justificación [M]
- [ ] Decidir ronda guiada (hipótesis) + ronda libre (validación) por hito [M]

## 13. Diseño de componentes

- [ ] Diseñar la guía de sesión con sus 10 secciones (encabezado, pregunta central, perfiles, preparación, briefing, escenario, tareas, observación, timeline, cierre) [M]
- [ ] Redactar el guion de 8 preguntas del moderador en español [M]
- [ ] Definir reglas del guion: no dar solución, esperar 10 segundos, registrar reacción [S]
- [ ] Diseñar la hoja de observación con 10 códigos de eventos [M]
- [ ] Diseñar la encuesta post-sesión con 6 bloques (datos, tono, comprensión, cuantitativo, cualitativo, perfil) [M]
- [ ] Diseñar el informe de hallazgos con 11 secciones [M]
- [ ] Diseñar la fórmula de priorización de fixes con reglas adicionales [M]
- [ ] Diseñar el flujo de regresión social con códigos temporales F-### [M]
- [ ] Diseñar el flujo de derivación a M102, M93, M104 y M101 [M]
- [ ] Diseñar la estructura de carpetas de archivo de sesiones [S]
- [ ] Definir criterios de salida de una ronda completa [S]
- [ ] Verificar que el diseño es aplicable a Godot 4.x sin requerir código del motor [S]

## 14. Integración con otros módulos

- [ ] Documentar integración con M101 (QA General): áreas de riesgo técnico observadas en sesión [M]
- [ ] Documentar integración con M102 (Bug Tracking): issues desde hallazgos ERR con referencia de sesión [M]
- [x] Documentar integración con M137 (Prototipo): builds estables que llegan al playtest [M]
- [ ] Documentar integración con M139 (Pre-Alpha): informes de ronda como insumo del DoD de hito [M]
- [ ] Documentar integración con M93 (Balance): derivación de desbalances con evidencia cuantitativa [M]
- [ ] Documentar integración con M104 (Analytics): solicitudes de instrumentación de métricas observadas [S]
- [ ] Documentar integración con M152 (Principios Innegociables): el tono cozy como criterio de evaluación [S]
- [ ] Documentar integración con M80 (Legal/Privacidad): NDA, consentimiento y tratamiento de datos [M]
- [x] Documentar integración con M110 (Debug Menu): acceso opcional en builds de testeo [S]
- [ ] Documentar que M114 no interfiere con M105 (Telemetría de Gameplay): instrumentación masiva es responsabilidad ajena [S]
- [ ] Definir contrato de entrada/salida completo del módulo en 04-Codigo.md [M]
- [ ] Referenciar que M101 y M137 pueden estar sin documentar; el módulo 114 los referencia por ID [S]

## 15. Edge cases

- [x] Definir manejo de tester demasiado familiarizado con el juego (sesgo de conocimiento previo) [M]
- [x] Definir manejo de tester que es amigo/familiar del equipo (feedback sesgado por complacencia) [M]
- [x] Definir manejo de pocos testers: mínimo 3; si no se alcanza, documentar la limitación de la ronda [M]
- [x] Definir manejo de feedback contradictorio entre testers: resolver con evidencia observacional y prioridad de tono [M]
- [ ] Definir manejo de hallazgos repetidos: la saturación confirma el problema sin más jugadores [S]
- [x] Definir manejo de tester que abandona a mitad de sesión: registrar causa y continuar con el resto [S]
- [ ] Definir manejo de crash/glitch en sesión: código ERR, reinicio de sesión y derivación a M102 [S]
- [x] Definir manejo de tester que busca agradar al moderador (demand characteristics) [M]
- [ ] Definir manejo de encuestas incompletas: seguimiento dentro de las 24 horas [S]
- [ ] Definir manejo de no jugadores que no entienden la encuesta: entrevista asistida corta [M]
- [x] Definir manejo de datos de tester que solicita borrado: eliminación en 48 horas y notificación [M]
- [ ] Definir manejo de resultados demasiado positivos (sospecha de sesgo): contrastar con observación y datos de juego [M]

## 16. Documentación

- [ ] Crear 01-Requerimientos.md con problema, objetivos, alcance, restricciones, RF1-RF18 y RN1-RN10 [M]
- [ ] Crear 02-Analisis.md con análisis del dominio, alternativas y decisiones [M]
- [ ] Crear 03-Diseno.md con arquitectura del Módulo y componentes de diseño [M]
- [ ] Crear 04-Codigo.md con archivos previstos, esqueletos de plantillas, ejemplo y notas del agente [M]
- [ ] Crear 05-Checklist.md con más de 120 ítems verificables [M]
- [ ] Firmar todos los archivos con modelo y plataforma (Deepseek V4 Flash / OpenCode) [S]
- [ ] Mantener todo el contenido del módulo en español [S]
- [ ] Garantizar que plan-inicial es idéntico a plan-actual (verificado con hashes SHA-256) [S]

## 17. Testings del protocolo

- [ ] Definir prueba piloto de ensayo con un miembro del equipo antes de la primera sesión real [M]
- [ ] Definir validación de la encuesta con un no jugador de prueba (comprensión de las escalas) [M]
- [ ] Definir prueba de la fórmula del índice de tono cozy con datos ficticios en Google Sheets [M]
- [ ] Definir prueba de la hoja de observación en una sesión simulada (registro en menos de 5 segundos) [M]
- [ ] Definir verificación del flujo completo informe -> issue (M102) -> fix -> regresión social en una ronda real [M]
- [ ] Definir prueba de herramientas: grabación con OBS, formulario activo, tablero de hallazgos [M]
- [x] Definir prueba de NDA y consentimiento con un tester de prueba (flujo de firma) [S]
- [ ] Definir criterio de éxito del piloto: 3 sesiones completas, 80% de encuestas, informe en una semana [S]
- [ ] Definir que los errores del piloto se corrigen en las plantillas antes de la ronda oficial [S]
- [ ] Definir medición del tiempo real de análisis por sesión para ajustar el presupuesto de horas [S]