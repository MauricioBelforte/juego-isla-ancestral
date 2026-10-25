**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 114: Playtest

## 1. Arquitectura del módulo

M114 es un módulo de **procesos y documentación operativa** (no de código del juego). Su arquitectura es un **flujo circular de 6 etapas** que se repite por cada ronda de playtest:

```
[1. Planificar la ronda] -> [2. Reclutar y preparar] -> [3. Ejecutar sesiones]
                                                              |
                                                              v
[6. Iterar y re-testear] <- [5. Priorizar fixes] <- [4. Analizar y reportar]
```

Cada etapa tiene artefactos definidos (plantillas) y estados (pendiente/en curso/completado) que se registran en el `05-Checklist.md` de la ronda.

## 2. Componentes del diseño

### 2.1 Guía de sesión (`PLAYTEST-GUIA.md`)

Documento de una ronda que el moderador sigue paso a paso durante la sesión:

| Sección | Contenido |
|---|---|
| Encabezado | Build verificada (hash/commit del prototipo), fecha, hito (M137/M139), nombre de ronda, tipo (guiada/libre) |
| Pregunta central | La pregunta que la ronda busca responder (una sola, accionable) |
| Perfiles | Perfiles de tester requeridos (cozy gamer, casual, no jugador) y cantidad |
| Preparación | Build instalada, guardados limpios pre-generados, NDA firmados, encuesta lista, OBS/Discord configurado, checklist de materiales |
| Briefing | Discurso de apertura (5 min): objetivo del testeo, think-aloud, no hay respuestas incorrectas, puede abandonar cuando quiera, honestidad valorada |
| Escenario | Build del mundo, punto de partida, restricciones (ej: "no se muestran tutoriales hoy") |
| Tareas guiadas | Lista de tareas opcionales para sesiones guiadas (ej: "planta tu primer cultivo"; "vende 5 items") |
| Hoja de observación | Tabla de eventos a registrar con códigos (ver 2.3) |
| Bloques de tiempo | Timeline: briefing (5 min), juego libre (40 min), tareas guiadas (15 min), encuesta (10 min), entrevista (10 min) |
| Cierre | Agradecimiento, orientación sobre el NDA, canal de contacto para preguntas posteriores |
| Notas de la sesión | Espacio libre para anotaciones del moderador y desviaciones del plan |

### 2.2 Guion de preguntas (dentro de la guía)

Preguntas del moderador en sesiones guiadas (think-aloud y puntos de control), en español:

- "¿Qué estás pensando mientras hacés eso?" (durante el juego)
- "¿Qué creés que tenés que hacer ahora?" (después de un objetivo cumplido/fallido)
- "¿Algo te confundió recién?"
- "¿Cómo te sentís con la cantidad de cosas que te marca la pantalla?" (evaluar abrumamiento UI)
- "¿Sabés dónde está tu casa / el pueblo / la playa?" (orientación en el mundo voxel)
- "¿El ruido o la música te molesta o te relaja?" (regulación del tono)
- "¿Sentís que perdiste el tiempo en algún momento?" (pacing)
- "¿Qué hubieras hecho si esto no te saliera?" (agencia / frustración)

Reglas del guion: nunca dar la solución; reformular en español simple; esperar 10 segundos de silencio antes de intervenir; registrar la REACCIÓN del jugador, no la propia opinión.

### 2.3 Hoja de observación (dentro de la guía)

Tabla con códigos de evento predefinidos para registrar en menos de 5 segundos por evento:

| Código | Evento | Ejemplo |
|---|---|---|
| DUD | Dudas de comprensión | "¿esto qué es?" |
| FRU | Frustración/enojo | Suspiro, "otra vez no", golpe de mesa suave |
| ABU | Aburrimiento | Bostezos, miradas al techo, "¿me falta mucho?" |
| OVR | Abrumamiento (overwhelm) | "¿Tengo que hacer TODO eso?" |
| SAT | Satisfacción visible | Sonrisa, "¡lo logré!", "¡mirá qué lindo!" |
| CAL | Calma/relajación | Postura relajada, voz tranquila, pausas contemplativas |
| ERR | Error del juego | Bug visible, glitch, crash (derivar a M102) |
| DLN | Desconexión del loop | No encuentra qué hacer; idle prolongado sin decisión |
| TRY | Exploración curiosa | "¿Qué pasa si toco esto?" |
| SKP | Omitió/ignoró instrucción o contenido | Pasó de largo el tutorial, no miró el panel de objetivos |

Columnas de la hoja: tiempo (mm:ss), código, descripción breve, impacto en tono (+1 a -5), nota del observador. Al final, resumen del observador: 3 momentos más memorables y 1 cita textual del tester (si aplica).

### 2.4 Encuesta post-sesión (`PLAYTEST-ENCUESTA.md`)

Formulario (Google Forms) a completar dentro de las 2 horas posteriores a la sesión. Estructura:

| Bloque | Preguntas | Formato |
|---|---|---|
| A. Datos de sesión | Código de tester, fecha, build; edad (rango), experiencia previa cozy, horas de juego semanales | Selección/número |
| B. Tono emocional | 7 escalas Likert 1-5 (estrés, abrumamiento, aburrimiento, tranquilidad, disfrute, agencia, ganas de seguir) | Likert 1-5 |
| C. Comprensión | "Supe qué hacer en todo momento", "Entendí a dónde ir al despertar", "Los avisos de la UI me ayudaron" | Likert 1-5 |
| D. Cuantitativo de juego | Objetivos cumplidos, muertes/reinicios, items obtenidos, tiempo total | Números (auto-reporte) |
| E. Cualitativo | "Lo que MÁS me gustó", "Lo que MENOS me gustó", "El momento más estresante", "El momento más lindo", "Si pudiera cambiar UNA cosa sería..." | Texto libre |
| F. Perfil emocional | "¿En qué momento quisiste dejar de jugar?", "¿Jugarías 30 minutos más?" | Selección + texto |

La encuesta calcula automáticamente el índice de tono cozy en Google Sheets (fórmula documentada en la plantilla).

### 2.5 Informe de hallazgos (`PLAYTEST-INFORME.md`)

Documento por ronda que consolida todas las sesiones:

| Sección | Contenido |
|---|---|
| Resumen ejecutivo | Pregunta central, respuesta en 2 líneas, índice de tono cozy de la ronda |
| Datos de la ronda | Fechas, jugadores (alias), builds, tipo de sesiones, materiales archivados |
| Hallazgos | Tabla: ID (H-001...), título, evidencia (cita/evento/sesión), severidad (S1-S4), frecuencia (n de N jugadores), impacto en tono, módulo destino (M101/M102/M93/M114) |
| Escala de severidad | S1 bloqueante / S2 mayor / S3 menor / S4 cosmético |
| Índice de tono cozy | Valor numérico de la ronda + gráfico de tendencia entre rondas |
| Encuestas | Resultados tabulados de Likert (promedios y distribución) |
| Observaciones clave | Citas textuales (anonimizadas) más reveladoras |
| Priorización de fixes | Lista ordenada con recomendaciones; ver 2.6 |
| Derivaciones | Issues creados en M102, comunicados a M93/M104, pendientes de M114 |
| Seguimiento de rondas anteriores | Estado de fixes comprometidos en rondas previas (resuelto/pendiente/retest en esta ronda) |
| Lecciones de proceso | Qué funcionó y qué no funcionó del método de testeo (mejora del propio M114) |

### 2.6 Cómo priorizar fixes

**Fórmula de prioridad:**

```
Prioridad = Severidad x (Frecuencia / TotalJugadores) x ImpactoEnTono
```

- Severidad: S1=10, S2=6, S3=3, S4=1.
- Frecuencia: jugadores afectados / total de la ronda (0 a 1).
- ImpactoEnTono: -5 (rompe la calma profundamente) a +1 (no afecta). Se aplica **valor absoluto** cuando el hallazgo es positivo (ej: "el amanecer encantó a todos" -> +5, se prioriza conservarlo).

**Reglas adicionales:**
1. Cualquier hallazgo con severidad S1 se prioriza por encima de todo (crashes, guardados perdidos, bloqueo de progreso).
2. Un hallazgo que rompe el tono cozy (impacto -4/-5) se prioriza sobre un bug funcional menor aunque sea más frecuente: el tono es el producto.
3. Los hallazgos positivos de alto impacto se protegen: si un fix futuro los puede romper, se agrega un criterio de regresión social.
4. Máximo 5 fixes comprometidos por ronda (límite realista indie); el resto queda como backlog de hallazgos.
5. Cada fix comprometido tiene: responsable, módulo destino y ronda de verificación prevista.

## 3. Flujos de trabajo

### 3.1 Flujo de una ronda de playtest

1. Definir pregunta central y tipo de ronda (guiada/libre).
2. Seleccionar build estable del prototipo (M137) / pre-alpha (M139) con los últimos fixes de la ronda anterior.
3. Reclutar testers según perfiles; validar NDA y consentimiento.
4. Preparar materiales: guía completada, encuesta activa en Google Forms, tablero de hallazgos, builds instaladas.
5. Ejecutar sesiones (guiadas con moderador; libres con mínima interferencia).
6. Tabular encuestas y calcular índice de tono cozy.
7. Consolidar informe de hallazgos con priorización.
8. Crear issues en M102 para bugs confirmados; comunicar a M93 los desbalances; registrar métricas para M104.
9. Comprometer hasta 5 fixes; asignar responsables.
10. Archivar todo el material y actualizar el historial del módulo.

### 3.2 Flujo de regresión social (verificación de fixes)

1. Al planificar la ronda N, incluir los fixes de la ronda N-1 en la build.
2. Agregar a la hoja de observación los códigos temporales F-001... (eventos relacionados con los fixes).
3. Si el problema no reaparece en al menos 2/3 de los jugadores y ningún nuevo hallazgo lo reintroduce -> fix VERIFICADO.
4. Si reaparece -> vuelve a la priorización de la ronda actual con la nueva evidencia.

### 3.3 Flujo de derivación a otros módulos

- **M102 (Bug Tracking):** errores del juego (ERR) confirmados por 2 o más testers o con evidencia reproducible -> issue con referencia `RNDA-{n}-H-###`.
- **M93 (Balance):** economía, tiempos de crafting, recompensas desproporcionadas -> informe breve con evidencia cuantitativa de la ronda.
- **M104 (Analytics):** métricas de comportamiento observadas que convenga medir en masa -> solicitud formal de instrumentación.
- **M101 (QA General):** sospecha de bug no confirmada -> lista de verificación para QA técnico; no contaminar el informe con rumores.
- **M139 (Pre-Alpha):** resultados de la ronda del prototipo -> criterio de entrada/salida al hito (DoD de la sección 21.6 de AGENTS.md).

## 4. Contratos de integración

### Entrada (desde otros módulos)
- M137 (Prototipo): builds estables y funcionalidades a testear.
- M139 (Pre-Alpha): builds de hitos y criterios de entrada a la etapa.
- M101 (QA General): lista de áreas de riesgo técnico a observar.
- M93 (Balance): áreas de curva de dificultad a vigilar.
- M152 (Principios Innegociables): definición del tono cozy a preservar.

### Salida (hacia otros módulos)
- M102: issues de bugs confirmados con referencia de sesión.
- M93: hallazgos de desbalance con evidencia.
- M104: solicitudes de instrumentación y datos observados.
- M139/M140: informe de ronda como insumo de DoD del hito.
- 5-FUTURAS-MEJORAS (vía usuario): observaciones de los testers que sean ideas de contenido futuro.

## 5. Configuración del material

- Flujo de material: las plantillas viven en `docs/playtest/` (pendiente de implementación), nombradas con prefijo estándar:
  - `PLAYTEST-GUIA.md` — guía de sesión completa (incluye guion y hoja de observación).
  - `PLAYTEST-ENCUESTA.md` — plantilla de encuesta post-sesión + fórmula del índice de tono cozy.
  - `PLAYTEST-INFORME.md` — plantilla de informe de hallazgos de ronda.
- Archivos de respaldo de sesiones (grabaciones, encuestas exportadas, notas) se archivan en `docs/playtest/sesiones/` con nomenclatura `AAAA-MM-DD_{ronda}_{aliasTester}/`.
- El tablero de hallazgos (Trello/GitHub Projects) refleja el estado de cada H-### (nuevo / priorizado / en fix / verificado / descartado).

## 6. Criterios de salida de una ronda

- Al menos 3 sesiones completas registradas (o saturación alcanzada con 5 hallazgos repetidos).
- Encuestas completadas por al menos el 80% de los testers.
- Informe con hallazgos priorizados y hasta 5 fixes comprometidos.
- Cero NDA/consentimientos faltantes.
- Material archivado y trazabilidad hacia M102/M93 cerrada.

## Presupuestos numericos (Reflection-Beam-1.0, 2026-10-23)

| # | Presupuesto | Valor | Formula/Justificacion |
|---|-------------|-------|----------------------|
| 25 | Sesiones esperadas x tester x perfil | Cozy 5 sesiones, casual 3 sesiones. Muestra: 8-12 testers por ronda. | Coherente con "al menos 3 sesiones completas" y "saturacion con 5 hallazgos repetidos". |
| 26 | Presupuesto USD total del playtest | 0 USD base (testers voluntarios), max 200 USD (compensacion minima si aplica). | Coherente con presupuesto indie. |
| 27 | Tiempos de revision de feedback por etapa | 48h por etapa. | Coherente con SLA <=72h de M144. |
| 28 | Fechas/builds de cada etapa | M137 (prototipo) -> M139 (pre-alpha) -> M140 (alpha). | Coherente con cadencias de M144 (hotfix <72h, patch mensual). |
| 29 | Tabla de captura por metrica | 9 metricas de M144. T2 captura todas 9, T1 captura 5 (bugs, rendimiento, economia, dificultad, tutorial). | Coherente con M105 (telemetria emite los eventos). |
| 30 | Presupuesto fix-cap por ronda | Max 5 fixes, 2-8h por fix. Total 10-40h por ronda. | Coherente con "maximo 5 fixes comprometidos por ronda". |

## Presupuestos numericos II - detalle minucioso (2da capa)

Definidos por Beam-1.0 via Audit-CRON E x8 (auto-auditoria de la 1ra capa) y escalado al fundador. Formula y unidades con dependencias cruzadas (M93 80/dia, M58 0.5ms, M144 <48h SLA).
- **Presupuesto de sesiones x tester x perfil revisado cosechas** [x] - formula del upsize del H25 con la 4.1-b (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose vive en la seccion 'Presupuestos numericos II - formulas concretas' de este 03; los mensajes 252/257/260/265/267 son el origen de la asignacion (correccion de cita rota: Hy3 347, aplicada por director))
- **Presupuesto USD por disciplina** [x] - formula del total consunter (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose vive en la seccion 'Presupuestos numericos II - formulas concretas' de este 03; los mensajes 252/257/260/265/267 son el origen de la asignacion (correccion de cita rota: Hy3 347, aplicada por director))
- **Presupuesto de fixes por ronda** [x] - formula de capacidad numera max 5 (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose vive en la seccion 'Presupuestos numericos II - formulas concretas' de este 03; los mensajes 252/257/260/265/267 son el origen de la asignacion (correccion de cita rota: Hy3 347, aplicada por director))

## Presupuestos numericos II - formulas concretas (Reflection-Beam-1.0, 2026-10-23)

### 20. Sesiones x tester x perfil
- Formula (SUPERSEDED por GO fundador 23oct 20:25, PAQ-5/H25 — ver L237): muestra minima = 30 sesiones por tester; los valores previos (cozy 5 / casual 3, 8-12 testers) quedan como historial. (correccion Hy3 343: el cuerpo no reflejaba el GO).
- Coherente con "al menos 3 sesiones completas" y "saturacion con 5 hallazgos repetidos".
- Unidad: sesiones. Dependencia: M114 (plan de playtest).

### 21. Presupuesto USD por disciplina
- Formula: 0 USD base (testers voluntarios), max 200 USD (compensacion minima si aplica).
- Coherente con presupuesto indie.
- Unidad: USD. Dependencia: M144 (post-lanzamiento).

### 22. Tiempos de revision de feedback por etapa
- Formula: 48h por etapa. Coherente con SLA <=72h de M144.
- Unidad: horas. Dependencia: M144 (SLA).

### 23. Fechas/builds de cada etapa
- Formula: M137 (prototipo) -> M139 (pre-alpha) -> M140 (alpha). Coherente con cadencias de M144 (hotfix <72h, patch mensual).
- Unidad: etapas. Dependencia: M137, M139, M140, M144.

### 24. Tabla de captura por metrica
- Formula: 9 metricas de M144. T2 captura todas 9, T1 captura 5 (bugs, rendimiento, economia, dificultad, tutorial).
- Coherente con M105 (telemetria emite los eventos).
- Unidad: metricas. Dependencia: M105, M144.

### 25. Presupuesto fix-cap por ronda
- Formula: max 5 fixes, 2-8h por fix. Total 10-40h por ronda.
- Coherente con "maximo 5 fixes comprometidos por ronda".
- Unidad: horas. Dependencia: M144 (post-lanzamiento).

## Notas Paquete-H (GO fundador 23oct 20:25, ratificado director 315)
- **PAQ-5 (H25)**: M114 muestra minima = **30 sesiones por tester** (supersede el 8/8-12 del bloque 3). Coherente con muestra 30 de M105/06 (telemetria). Cita canonica: "GO FUNDADOR 23oct 20:25: «sí, me gustan las recomendaciones» (via director 315)".



Riel design-docs SIN DATOS (encargo agnes-3-flash msg 255, 2026-10-24 21:08; GO directora). Produce-first line-based, sin vision: cada numero medido en disco con cita archivo:linea (recorrido python -X utf8 + Grep/Read; sin ejecutar Godot). Las capas I/II (Beam 1.0, 2026-10-23) quedan intactas; aqui se groundean con mediciones reales y se documentan los drift hallados. **Modelo:** Ling-3.1-Flash / **Plataforma:** Kilo Code / **Fecha:** 2026-10-25

## Presupuestos numericos III - mediciones en disco (Ling-3.1-Flash, 2026-10-25)

### 26. Sesiones por tester (GO fundador + plantillas medidas)
- CANONICA: muestra minima = 30 sesiones por tester — GO del fundador 2026-10-23 20:25 via director 315 (este 03, L237 PAQ-5; supersedes el 8/8-12 historico de L209).
- Duracion de sesion medida en plantilla: 80 min = briefing 5' + libre 40' + tareas 15' + encuesta 10' + entrevista 10' (docs/playtest/README.md L17).
- Testers por ronda: 3-5 cubriendo perfiles cozy/casual/no jugador (docs/playtest/README.md L15); historico (plan-inicial 01-Requerimientos L58): 3-8 jugadores por ronda.
- DRIFT (cita rota): la referencia "muestra 30 de M105/06 (telemetria)" NO tiene sustento — M105 no tiene 06-Plan-Testings.md (plan-actual solo 01-05) y grep de "muestra" sobre todo el modulo M105 = 0 hits. La fuente canonica valida es el GO del fundador. Recomendacion al director: corregir la referencia cruzada (M114 03 L237) o agregar el dato a M105.

### 27. Presupuesto USD (modo costo cero, medido)
- 134-Presupuesto/operativa/budget-breakdown.md L17: presupuesto total actual = USD 0/mes (desarrollo autofinanciado, costo cero); L19: unico desembolso previsto confirmado = USD 100 (Steam Direct Fee, una vez); L68-69: colaborador/lead USD 0, agente de IA USD 0 (nunca autoriza ni realiza gastos).
- Playtest = USD 0 (sin desembolso previsto en 134-Presupuesto). El techo de diseño "max 200 USD" (capa I #26) queda sin ejercer. Coherente con dashboard-metrics.md L17/L19 (burn rate 0, ~0% consumido de USD 100).

### 28. Fixes por ronda (medido en plantilla)
- Max 5 fixes por ronda (docs/playtest/README.md L19: "Priorizar maximo 5 fixes y derivar a M102/M93/M104/M101"); 2-8 h por fix, 10-40 h por ronda (capa II ###25).

### 29. Metricas de tono cozy (formula medida en plantilla)
- TonoCozy = (Q4 + Q5 + Q6)/3 - (Q1 + Q2 + Q3)/3; rango -4 a +4; metas: >= +0.5 prototipo (M137), >= +1.0 pre-alpha (M139) (docs/playtest/README.md L21-23).
- SLA de revision de feedback: 48 h, SLA <= 72 h (05-Checklist L253; auditoria L261: 0 correcciones).
- Integraciones medidas: M101 areas de riesgo, M102 issues RNDA-{n}-H-###, M93 balance con evidencia cuantitativa, M104 metricas instrumentadas, M152 definicion operativa del tono, M80 NDA/consentimiento (README L26-31).
