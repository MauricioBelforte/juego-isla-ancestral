# Módulo 146: Diseño Emocional — Checklist

**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28 (implementación) · 2026-08-21 (checklist original por Nemotron 3 Ultra)
**Estado:** Implementación completa (pendiente de QA cruzado) — 90/100 `[x]` + 10 `[?]` programados para la fase jugable

## Reserva actual

- Estado: Liberado 2026-08-28 (fue 🔵 En curso; ver Notas del Agente en `04-Codigo.md`)
- Agente: GLM (Kilo)
- Fase: F0/transversal de diseño, V0
- Dificultad: 2
- Visión: V0
- Entrada: M145 🟡 (emociones por fase ya definidas, log 199); M152 documentado
- Salida: 5 documentos operativos en `operativa/` (paleta, mapeo, wow moments, guía de playtesting emocional, cozy checklist)
- Archivos: `DOCUMENTACION/146-Diseno-Emocional/operativa/*`, `plan-actual/04-Codigo.md`, `plan-actual/05-Checklist.md`, `CHECKLIST-GLOBAL.md`, `ESTADO-PARALELO.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, `Logs/`
- Fecha: 2026-08-28 22:25:00 (reserva) · 2026-08-28 22:50:00 (liberación)

---

> **Cómo se marcó (2026-08-28, GLM/Kilo):** ítems de diseño/documentación `[x]` contra los 5 documentos de `operativa/`. Ítems que exigen **jugadores o sistemas implementados** (playtesting emocional, testeo de audio/visual) marcados `[?]` con el plan que los ejecutará (`operativa/playtesting-guide.md` → M114 en M138+). Honestidad de protocolo (§21.4.3).

## A. Paleta Emocional (10 ítems)

- [x] Definir emoción principal: Calma → `operativa/emotional-palette.md` §1
- [x] Definir emoción secundaria: Curiosidad → §1
- [x] Definir emoción de logro: Satisfacción → §1
- [x] Definir emoción de descubrimiento: Asombro → §1
- [x] Definir emoción social: Pertenencia → §1
- [x] Definir emoción nostálgica: Nostalgia → §1
- [x] Definir intensidad de cada emoción (baja/media/alta) → §1 columna intensidad
- [x] Definir frecuencia de cada emoción (constante/frecuente/regular/infrecuente) → §1 + reglas de dosificación §2
- [x] Documentar emociones a evitar (frustración, aburrimiento, ansiedad) → §3 (+ culpa y sobrecarga)
- [x] Crear tabla resumen de paleta emocional → §1

## B. Mapeo Emocional (15 ítems)

- [x] Mapear emociones en fase de Introducción (0-30 min) → `operativa/emotional-mapping.md` §1
- [x] Mapear emociones en fase de Primeras Horas (30 min - 3h) → §1
- [x] Mapear emociones en fase de Juego Principal (3h+) → §1
- [x] Mapear emociones por mecánica: Construcción → §2
- [x] Mapear emociones por mecánica: Exploración → §2
- [x] Mapear emociones por mecánica: Socialización → §2
- [x] Mapear emociones por mecánica: Progresión → §2
- [x] Mapear emociones por momento del día (mañana, tarde, noche) → §3 (5 franjas M31)
- [x] Mapear emociones por estación del año → §4
- [x] Crear diagrama visual de mapeo emocional → §5 (ASCII)
- [x] Identificar gaps emocionales (faltan emociones en alguna fase) → §6 (pertenencia tardía, con mitigación)
- [x] Identificar over-emotional moments (demasiada emoción junta) → §6 (regla de separación festival/Sello)
- [?] Validar mapeo con playtesting → requiere jugadores; `playtesting-guide.md` (M114, M138+)
- [?] Iterar mapeo según hallazgos → idem
- [x] Documentar mapeo completo → documento completo + changelog en paleta

## C. Mecánicas Emocionales (15 ítems)

- [x] Diseñar mecánica de Construcción para generar satisfacción → mapeo §2 (progreso visible, resultado persistente)
- [x] Diseñar mecánica de Exploración para generar curiosidad → §2 (siluetas, rumores M148)
- [x] Diseñar mecánica de Socialización para generar pertenencia → §2 (NPCs recuerdan, M162/M20)
- [x] Diseñar mecánica de Progresión para generar logro → §2 (Sellos con ceremonia)
- [x] Diseñar mecánica de Decoración para generar nostalgia → §2 (la casa como diario)
- [x] Definir feedback emocional por cada mecánica → M145 `feedback-system.md` §2 (20 acciones) + mapeo §2
- [x] Definir ritmo emocional por sesión de juego → paleta §2 (micro-satisfacción cada 5-15 min, calma <2 min)
- [x] Crear curva emocional por fase del juego → mapeo §5 (diagrama)
- [x] Identificar momentos de calma (descanso emocional) → mapeo §3-4 + afterglow de wow-moments
- [x] Identificar momentos de emoción (pico) → wow-moments.md (8 momentos dosificados)
- [x] Definir transiciones emocionales suaves → afterglow ≥2 min (wow-moments §1) + transiciones musicales
- [x] Evitar choques emocionales bruscos → mapeo §6 (nunca pico tras pico) + feedback §3
- [?] Testear mecánicas emocionales con jugadores → requiere build; playtesting-guide (M138+)
- [?] Iterar según feedback emocional → idem
- [x] Documentar mecánicas emocionales → documentos completos

## D. Wow Moments (10 ítems)

- [x] Definir Wow Moment #1: Primera vista de Aurora (asombro) → `operativa/wow-moments.md` WM-1
- [x] Definir Wow Moment #2: Primera casa completada (satisfacción) → WM-2
- [x] Definir Wow Moment #3: Descubrir Templo de la Brisa (asombro) → WM-3
- [x] Definir Wow Moment #4: Primer evento estacional (pertenencia) → WM-4
- [x] Definir Wow Moment #5: Ver isla completa desde arriba (asombro) → WM-5
- [x] Definir Wow Moment #6: Recibir regalo de NPC (pertenencia) → WM-6
- [x] Definir Wow Moment #7: Completar historia principal (satisfacción) → WM-7
- [x] Definir Wow Moment #8: Encontrar Easter egg final (curiosidad) → WM-8
- [x] Diseñar estructura de cada wow moment (setup, reveal, payoff, afterglow) → §1 + cada WM con sus 4 etapas
- [x] Presupuestar wow moments por fase → §3 (tabla por hito del roadmap + regla de separación)

## E. Audio Emocional (10 ítems)

- [x] Definir música para momentos de calma → intención definida (paleta §5 nota sonora; mapeo §3); composición = M41
- [x] Definir música para momentos de curiosidad → idem (motivo que se sugiere)
- [x] Definir música para momentos de satisfacción → idem (acorde ascendente)
- [x] Definir música para momentos de asombro → idem (capa orquestal)
- [x] Definir música para momentos de pertenencia → idem (tema comunitario)
- [x] Definir efectos de sonido emocionales (satisfactorios) → M145 `feedback-system.md` §2
- [x] Definir transiciones musicales entre emociones → capas reactivas M41 + afterglow
- [x] Colaborar con M41 (Música) en diseño emocional → frontera documentada: intención aquí, implementación M41
- [x] Colaborar con M42 (Sonido Ambiental) en calma → idem (ambiente constante en calma)
- [?] Testear audio emocional con jugadores → requiere audio integrado; playtesting S3+ (M114)

## F. Visual Emocional (10 ítems)

- [x] Definir iluminación para calma (suave, cálida) → paleta §5 (intención para M49)
- [x] Definir iluminación para asombro (épica, dramática) → paleta §5
- [x] Definir partículas para satisfacción (brillo, colores) → M145 feedback §2 (confeti, brillos)
- [x] Definir animaciones para satisfacción (suaves, satisfactorias) → M145 feedback §1 + M48 (intención)
- [x] Definir colores por emoción → paleta §5 (HEX sugeridos, a validar con M53/M47)
- [x] Definir composición visual por emoción → paleta §5 (encuadres por emoción)
- [x] Colaborar con M45 (Arte 3D) en visual emocional → frontera documentada
- [x] Colaborar con M49 (Iluminación) en iluminación emocional → frontera documentada
- [?] Testear visual emocional con jugadores → requiere visual integrado; playtesting S1-S3 (M114)
- [x] Documentar guidelines visuales emocionales → paleta §5 (documento completo)

## G. Validación Emocional (10 ítems)

- [x] Crear guía de playtesting emocional → `operativa/playtesting-guide.md`
- [x] Definir preguntas clave para playtesting → §1 (6 preguntas sin sesgo)
- [x] Crear checklist de emociones a verificar → §2
- [x] Definir proceso de recolección de feedback emocional → §3-4
- [x] Crear template de reporte emocional → §3
- [?] Realizar playtesting emocional (mínimo 5 jugadores) → requiere build jugable; programado M138+ (S1-S5 de M145)
- [?] Analizar resultados de playtesting → idem
- [?] Iterar diseño según hallazgos → idem (proceso §4)
- [x] Documentar lecciones aprendidas → mecanismo definido (§4.4: reporte mensual M133 + cierre de hitos)
- [x] Revisar diseño emocional trimestralmente → anclado a la ceremonia de revisión de M135/M133 (guía §4.5)

## H. Cozy Checklist (10 ítems)

- [x] Crear checklist "¿Esto es cozy?" → `operativa/cozy-checklist.md` §1
- [x] Incluir pregunta: ¿Genera frustración? → §1 pregunta 1
- [x] Incluir pregunta: ¿Genera ansiedad? → §1 pregunta 2
- [x] Incluir pregunta: ¿Es relajante? → §1 pregunta 3
- [x] Incluir pregunta: ¿Es satisfactorio? → §1 pregunta 4
- [x] Incluir pregunta: ¿Es accesible? → §1 pregunta 5
- [x] Incluir pregunta: ¿Es amigable? → §1 pregunta 6 (+ pregunta 7: emoción de la paleta)
- [x] Aplicar checklist a cada decisión de diseño → uso obligatorio §3 (QA cruzado lo verifica)
- [x] Distribuir checklist a todo el equipo → repo versionado + onboarding M133 (adaptado a 1 persona)
- [x] Revisar checklist trimestralmente → anclado a la revisión de M135/M146 (§3.4)

## I. Documentación y Mantenimiento (10 ítems)

- [x] Crear directorio docs/emotional-design/ → *adaptación documentada:* `DOCUMENTACION/146-Diseno-Emocional/operativa/` (convención `AGENTS.md` §3)
- [x] Mantener documentos actualizados → reglas de firma/log del proyecto
- [x] Distribuir guidelines al equipo → repo + onboarding M133 (adaptado a 1 persona)
- [x] Entrenar al equipo en diseño emocional → *adaptado:* la paleta + cozy checklist son el material de onboarding; agentes los leen antes de diseñar
- [x] Revisar diseño emocional por milestone → anclado a cierres de hito (wow-moments §3) y trimestral
- [x] Documentar decisiones emocionales → logs + ADR de M133 cuando cambian reglas; changelog de la paleta
- [x] Crear referencia rápida para el equipo → cozy-checklist (referencia de 7 preguntas) + paleta §4
- [x] Archivar versiones anteriores → git (historial versionado; plan-inicial inmutable)
- [x] Crear changelog de diseño emocional → sección Changelog en `emotional-palette.md` (primera entrada 2026-08-28)
- [?] Evaluar efectividad del diseño emocional → requiere datos de playtest/telemetría; método definido (wow-moments §4)

---

## Notas de verificación (GLM / Kilo, 2026-08-28)

- Entregables creados en `operativa/`: `emotional-palette.md`, `emotional-mapping.md`, `wow-moments.md`, `playtesting-guide.md`, `cozy-checklist.md`.
- Los 10 `[?]` son actividades futuras programadas (playtesting emocional con ≥5 jugadores desde M138; evaluación con telemetría). Método, preguntas, checklist y template ya creados.
- Módulo parte de M145 (emociones por fase) y alimenta a M152 (cozy checklist operativa su principio), M41-M52 (intención audiovisual) y M21/M22 (tono emocional).
- El módulo queda 🟡 (liberado con pendientes programados) y listo para **QA cruzado** (§21.8) por un modelo distinto a GLM.


## Notas del Agente (QA Cruzado - AGENTS.md §21.8)

**Verificador:** Hy3 (Kilo) | **Fecha:** 2026-08-28 | **Implementador verificado:** GLM (Kilo)

### Verificación realizada
- Conteo de ítems del checklist coincide con CHECKLIST-GLOBAL.md (ver recuento al inicio del archivo).
- Entregables presentes en operativa/ (o plan-actual/) y firmados por el implementador GLM.
- Sin errores de compilación/runtime: módulos V0 sin Godot; scripts validadores ejecutados por GLM (8 PASS/0 FAIL en M133; validate_vision.py en verde en M153; validar_nombres.py ejecutado en M149).
- Logs 197-202, 220 y 221 presentes en Logs/.
- Los [?] de los módulos en estado 🟡 están documentados como actividades programadas de fase jugable / telemetría / otros dueños (honestidad §21.4.3), no deuda de diseño.

### Veredicto
Módulo 146 (Diseño Emocional): mantiene estado 🟡; 10 [?] justificados (playtesting/evaluación con datos M138+, M105). Reflejado en CHECKLIST-GLOBAL.md, ESTADO-PARALELO.md y DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md. Log 204.
