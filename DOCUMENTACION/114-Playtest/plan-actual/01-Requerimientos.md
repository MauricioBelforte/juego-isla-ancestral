**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 114: Playtest

## ID del Módulo
- **Código:** M114
- **Carpeta:** `DOCUMENTACION/114-Playtest/`
- **Dependencias:** M101 (QA General), M137 (Prototipo). Referencias: M93 (Balance), M139 (Pre-Alpha), M102 (Bug Tracking), M104 (Analytics)
- **Carácter:** Módulo de procesos y documentación operativa: sesiones de prueba con jugadores reales, observación, encuestas, análisis de resultados e iteración de diseño
- **Motor:** Godot 4.x + Voxel Tools, GDScript

## 1. Problema

Isla Ancestral es un mundo voxel cozy estilo Stardew Valley en la isla Aurora. El equipo de desarrollo no puede evaluar objetivamente si la experiencia **se siente** cozy, estresante, abrumadora o aburrida: el conocimiento profundo del código y del diseño genera un sesgo que impide ver los problemas reales de primerizos. Sin sesiones de playtest con jugadores reales, los problemas de frustración, confusión, pacing y tono emocional llegan tarde, en una etapa en la que corregirlos es caro.

El módulo 114 resuelve este problema definiendo un **protocolo profesional y repetible de playtesting**: cómo reclutar jugadores, cómo estructurar sesiones guiadas y libres, qué observar, qué preguntar, cómo encuestar, cómo convertir hallazgos en decisiones de diseño y cómo verificar que los fixes funcionaron.

## 2. Objetivos

1. Establecer un protocolo de playtest aplicable desde el prototipo (M137) hasta la pre-alpha (M139).
2. Proveer plantillas listas para usar: guía de sesión, guion de preguntas, hoja de observación, encuesta post-sesión e informe de hallazgos.
3. Definir métricas cualitativas y cuantitativas para medir el tono cozy (estrés, abrumamiento, aburrimiento, disfrute).
4. Definir un proceso de priorización de fixes basado en severidad, frecuencia e impacto en la visión cozy.
5. Integrar los hallazgos con M93 (Balance), M101 (QA General), M102 (Bug Tracking) y M104 (Analytics).
6. Garantizar la trazabilidad de cada hallazgo: de la sesión al informe, del informe al issue, del issue al fix verificado.

## 3. Alcance

### Incluye
- Diseño del protocolo de playtest (objetivos por etapa, tipo de sesión, duración, número de jugadores).
- Reclutamiento de testers (criterios de selección, canales, perfiles objetivo, NDA).
- Sesiones guiadas (moderadas) y sesiones libres (no moderadas).
- Observación estructurada (hoja de observación, registro de eventos, capturas de video/pantalla).
- Encuestas post-sesión (cuantitativas y cualitativas).
- Análisis de resultados y generación de informes de hallazgos.
- Iteración de diseño: priorización, tracking y verificación de fixes.
- Plantillas de documentación (`PLAYTEST-GUIA.md`, `PLAYTEST-ENCUESTA.md`, `PLAYTEST-INFORME.md`).
- Almacenamiento y privacidad de los datos de sesión.
- Criterios de éxito por etapa de desarrollo.

### Excluye (fuera de alcance)
- La ejecución automática de pruebas de regresión (responsabilidad de M101 QA General).
- El sistema de telemetría automática del juego (responsabilidad de M104 Analytics).
- El seguimiento de bugs en sí (responsabilidad de M102 Bug Tracking; este módulo solo genera inputs).
- El tuning fino de valores de balance (responsabilidad de M93 Balance; este módulo detecta problemas y los deriva).
- La definición de contenido del prototipo (responsabilidad de M137 Prototipo).
- La distribución del juego al público (Steam Store Page, M97).

## 4. Restricciones

1. **Proyecto indie:** presupuesto reducido; las herramientas deben ser gratuitas (Google Forms, Discord, OBS Studio, Trello o equivalentes) o de bajo costo.
2. **Idioma:** las plantillas y sesiones se realizan en español (mercado inicial del proyecto), con posible extensión futura.
3. **Privacidad:** los datos de testers se manejan según M80 (Legal/Privacidad); nunca se publican datos personales ni grabaciones sin consentimiento.
4. **NDA:** todo tester firma un acuerdo de no divulgación antes de la primera sesión para proteger la propuesta de valor del juego.
5. **No interference:** las sesiones de playtest no deben detener el desarrollo principal; se planifican en ventanas dedicadas (por ejemplo, al cierre de un hito del prototipo).
6. **Tono cozy como criterio central:** cada hallazgo se evalúa contra la pregunta "¿esto acerca o aleja la experiencia del tono cozy?" definido en M152 (Principios Innegociables).
7. **Tamaño de muestra realista:** con recursos indie, se apunta a sesiones con 3 a 8 jugadores por ronda, priorizando profundidad cualitativa sobre volumen.
8. **Registro obligatorio:** toda sesión queda documentada en la carpeta del módulo; no se permiten playtests informales sin registro.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Planificar rondas de playtest por hito | Al menos una ronda al cerrar el prototipo (M137) y una por cada hito de la pre-alpha (M139) |
| RF2 | Definir objetivo específico por sesión | Cada sesión tiene una pregunta central (ej: "¿el jugador encuentra su casa al despertar?", "¿el clima estresa?") |
| RF3 | Reclutar testers según perfiles | Cozy gamers, gamers casuales, no jugadores; priorizar el público objetivo del juego |
| RF4 | Firmar NDA y consentimiento | Antes de la primera sesión; incluye permiso de grabación, voz e imágenes para uso interno |
| RF5 | Preparar build de testeo | Build de desarrollo con formato de guardado separado, logs (M103) y acceso al debug menu (M110) si aplica |
| RF6 | Ejecutar sesiones guiadas | Moderador presente, protocolo think-aloud, guion de preguntas, sin ayuda salvo bloqueo absoluto |
| RF7 | Ejecutar sesiones libres | Jugador solo con instrucciones mínimas, distancia de observación, registro automático de pantalla |
| RF8 | Observar y registrar | Hoja de observación con eventos específicos: dudas, frustración, aburrimiento, satisfacción, errores de comprensión |
| RF9 | Aplicar encuesta post-sesión | Dentro de las 2 horas posteriores a la sesión, preferentemente presencial o por video |
| RF10 | Medir el tono emocional | Escalas para estrés, abrumamiento, aburrimiento, calma, disfrute y sensación de agencia |
| RF11 | Registrar datos de juego | Duración de sesión, objetivos completados, errores cometidos, zonas visitadas, items obtenidos |
| RF12 | Generar informe de hallazgos | Por ronda, con hallazgos clasificados por severidad, frecuencia e impacto emocional |
| RF13 | Priorizar fixes | Matriz severidad x frecuencia x impacto en tono cozy; los fixes de tono cozy tienen prioridad |
| RF14 | Derivar bugs a Bug Tracking | Los bugs confirmados se convierten en issues en M102 con referencia a la sesión |
| RF15 | Derivar problemas de balance | Los desbalances detectados se comunican a M93 con evidencia de la sesión |
| RF16 | Iterar y re-testear | Los fixes de sesiones anteriores se verifican en la siguiente ronda (testing de regresión social) |
| RF17 | Archivar el material de sesión | Grabaciones, fotos, encuestas y notas archivados con nomenclatura estandarizada |
| RF18 | Mantener historial acumulado | Informes acumulativos por etapa que muestran la evolución de los indicadores de tono |

## 6. Requisitos No Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RN1 | Confidencialidad | Datos de testers y NDA resguardados conforme a M80; las grabaciones no salen del equipo |
| RN2 | Repetibilidad | El protocolo permite comparar rondas entre sí; variables de sesión documentadas (build, fecha, tester, hardware) |
| RN3 | Bajo costo | El 100% de las herramientas del protocolo son gratuitas o fan-made sin licencias adicionales |
| RN4 | Escalabilidad | El protocolo funciona con 3 jugadores (mínimo) y escala hasta 8+ sin cambiar de método |
| RN5 | Tiempo acotado | Sesión tipo de 60–90 minutos incluyendo consentimiento, juego y encuesta |
| RN6 | Usabilidad para el moderador | Las plantillas se completan en menos de 5 minutos de trabajo por evento registrado |
| RN7 | Trazabilidad | Todo hallazgo es rastreable: sesión → informe → issue → fix → verificación |
| RN8 | Visión cozy preservada | Ningún hallazgo se resuelve contradiciendo los Principios Innegociables (M152) |
| RN9 | Accesibilidad | Las preguntas de la encuesta usan lenguaje sencillo, comprensible para no jugadores |
| RN10 | Idioma español | Todas las plantillas, guiones y encuestas están íntegramente en español |

## 7. Criterios de Aceptación

1. Existen las plantillas `PLAYTEST-GUIA.md`, `PLAYTEST-ENCUESTA.md` y `PLAYTEST-INFORME.md` completas y listas para usar.
2. El protocolo define sesiones guiadas y libres con roles, tiempos y materiales claros.
3. Las métricas de tono cozy (estrés, abrumamiento, aburrimiento, disfrute) están definidas y operacionalizadas.
4. El proceso de priorización de fixes produce un orden accionable en el informe.
5. La integración con M101, M102, M93, M104 y M137 está documentada con contratos de entrada/salida.
6. Se incluyen edge cases conocidos (tester familiarizado, pocos testers, feedback contradictorio) con estrategia de manejo.
7. Para el proyecto Godot 4.x: las plantillas son archivos Markdown en `docs/playtest/` (pendiente de implementación), no requieren código GDScript.