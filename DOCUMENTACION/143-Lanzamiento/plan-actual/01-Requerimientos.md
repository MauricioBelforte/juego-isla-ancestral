**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 143: Lanzamiento

## 1. Problema
El RC (M142) está aprobado y congelado. El lanzamiento ejecuta **día 0 y las primeras 72 h de vida del juego**: publicación de página, build, tráiler y comunicado; soporte activado; monitorización de crashes, reviews, servidores, compras y saves; revisión de bugs críticos; preparación de hotfix; análisis de métricas iniciales; respuesta a la comunidad; agradecimiento público; y preservación de builds.

## 2. Objetivo del módulo
Publicar "Isla Ancestral" con el RC final en todas las plataformas objetivo, manteniendo el juego estable (monitorización activa) y una comunidad bien atendida desde el minuto uno, con hotfix listo si surge un problema crítico y toda la información guardada para el post-lanzamiento (M144).

## 3. Alcance (derivado del plan maestro: sección 142 "LANZAMIENTO")
1. **Publicar página** — store page visible al público (sale live).
2. **Publicar build** — build RC final liberada en las plataformas.
3. **Publicar tráiler** — tráiler final en canales oficiales.
4. **Publicar comunicado** — comunicado de prensa y de comunidad multi-idioma.
5. **Activar soporte** — canales con SLA activo desde la hora 0.
6. **Monitorizar crashes** — dashboard de crashes con alertas (M105).
7. **Monitorizar reviews** — reviews de todas las plataformas con triaje (M106).
8. **Monitorizar servidores** — estado de servidores/backend (telemetría, cloud, logros) (M104/M105).
9. **Monitorizar compras** — compras/DLC/regalos según plataforma (M149).
10. **Monitorizar saves** — errores de guardado/cloud en sesiones reales (M59/M60).
11. **Revisar bugs críticos** — triaje P0/P1 de la comunidad y telemetría.
12. **Preparar hotfix** — cola de hotfix 2.0.x lista para el día siguiente.
13. **Revisar métricas iniciales** — primeras 72 h: instalaciones, sesiones, conversión de tutorial, retención.
14. **Responder comunidad** — hilos, mails, redes con tiempos de respuesta.
15. **Publicar agradecimiento** — mensaje de gracias con fecha y firmas.
16. **Preservar builds** — builds RC y hotfixes archivados con manifiestos (M142).

## 4. Requisitos funcionales (RF)
| RF | Descripción |
|----|-------------|
| RF1 | Día 0 ejecutado según runbook (M142): página, build, tráiler, comunicado en el orden y hora definidos |
| RF2 | Publicación sincronizada entre plataformas (ventana < 30 min de diferencia) |
| RF3 | Soporte activo desde la hora 0 con SLA de respuesta ≤ 24 h hábiles |
| RF4 | Monitorización de crashes con alertas automáticas (umbral 0.5%) y stacktraces |
| RF5 | Monitorización de reviews con triaje diario (positivas/negativas/urgentes) |
| RF6 | Monitorización de servidores/backend: latencia, errores y disponibilidad 99.9% en las primeras 72 h |
| RF7 | Monitorización de compras (si aplica) sin errores de transacción |
| RF8 | Monitorización de saves: sin picos de errores de guardado/cloud |
| RF9 | Triaje de bugs de comunidad con severidad y prioridad en < 24 h |
| RF10 | Hotfix 2.0.x preparado y aprobado en < 72 h si hay P0/P1 (runbook de incidentes) |
| RF11 | Informe de métricas iniciales (72 h) con aprendizajes para M144 |
| RF12 | Comunidad respondida: tiempo de respuesta documentado; sin preguntas críticas sin respuesta |
| RF13 | Agradecimiento público publicado (72-96 h) |
| RF14 | Builds preservados con manifiestos y accesos de recuperación |

## 5. Criterios de aceptación (DoD del módulo)
1. Página, build, tráiler y comunicado publicados en todas las plataformas dentro de la ventana definida.
2. Monitorización activa operativa desde la hora 0 (dashboards accesibles al equipo).
3. Cero incidentes no gestionados: todo P0/P1 de la comunidad/telemetría con ticket y respuesta.
4. Informe de 72 h generado y revisado por el equipo (métricas de la RF11).
5. Agradecimiento publicado y comunidad con respuesta documentada.
6. Builds preservadas con manifiestos (M142) y documentación de recuperación.
7. Plan-actual (143-Lanzamiento) actualizado y firmado.

## 6. Restricciones
- **Aplican:** M142 (RC/runbook), M101/M102 (bugs), M104/M105 (telemetría/crash), M106 (tracking), M149 (plataforma/mercadotecnia), M152 (soporte/UX), M59/M60 (saves/cloud).
- La ventana de publicación es de 30 min entre plataformas; si una falla, se detiene el resto (runbook de incidentes).
- No se cambia la build una vez publicada salvo hotfix aprobado por el comité de release.
- Los secretos de plataforma nunca van al repositorio (solo referencias).

## 7. Dependencias
- M142 (RC ✅): build final, checklist, runbook, accesos.
- M149 (Plataformas/Marketing), M104/M105 (Telemetría/Crash), M106 (Tracking), M151 (Control Final), M59/M60 (Saves/Cloud), M152 (Soporte/Manual).
- M144 (Después del lanzamiento): recibe métricas y cola de hotfix.

## 8. Entregables del módulo
1. Registro de publicación día 0 (timeline con horas y responsables).
2. Informe de monitorización 72 h (crashes, reviews, servidores, compras, saves, bugs).
3. Cola de hotfix 2.0.x con prioridades y propietarios.
4. Informe de métricas iniciales + aprendizajes.
5. Acta de comunidad (respuestas, agradecimiento) y preservación de builds.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M097** — Steam / Store Page | Lanzamiento en Steam |
| **M142** — Release Candidate | Lanzamiento sobre RC |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M144** — Después del Lanzamiento | Después del lanzamiento |
| **M151** — Control Final | Control final |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M097** — Steam / Store Page | Depende de este módulo |
| **M142** — Release Candidate | Depende de este módulo |
| **M144** — Después del Lanzamiento | Este módulo lo necesita |
| **M151** — Control Final | Este módulo lo necesita |

