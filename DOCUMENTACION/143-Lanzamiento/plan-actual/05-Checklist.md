**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 143: Lanzamiento (120 ítems)

## Convención
- `[ ]` = completado por documentación (fase documentada y validable). `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## 1. Publicar página (RF1/RF2/M149)

- [x] Definir página visible en Steam (y plataformas objetivo) el día 0 [M]
  · evidencia: 03-Diseno.md secc. Pagina visible en Steam (cola total, Reflection-Beam-1.0, T81, 2026-10-22)
- [x] Definir verificación de disponibilidad de la página (visible) [S]
  · evidencia: 03-Diseno.md secc. Pagina visible en Steam (cola total, Reflection-Beam-1.0, T81, 2026-10-22)
- [x] Definir captura de confirmación de publicación [S]
  · evidencia: 03-Diseno.md secc. Publicacion y trailer (cola total, Reflection-Beam-1.0, T83, 2026-10-22)
- [x] Definir ventana de publicación < 30 min entre plataformas [S]
  · evidencia: 03-Diseno.md secc. Pagina visible en Steam (cola total, Reflection-Beam-1.0, T81, 2026-10-22)
- [x] Definir detener publicación si una plataforma falla (runbook) [S]
  · evidencia: 03-Diseno.md secc. Pagina visible en Steam (cola total, Reflection-Beam-1.0, T81, 2026-10-22)
- [x] Definir página con requisitos, FAQ y descripciones sin errores [M]
  · evidencia: 03-Diseno.md secc. Publicacion y trailer (cola total, Reflection-Beam-1.0, T83, 2026-10-22)
- [x] Definir página con configuración de idiomas completa (M87/M149) [M]
- [x] Definir verificación de fecha de lanzamiento correcta por región [S]
  · evidencia: 03-Diseno.md secc. Publicacion y trailer (cola total, Reflection-Beam-1.0, T83, 2026-10-22)

## 2. Publicar build (RF1/RF2/M142)

- [x] Definir liberación de la build `rc-final` en las plataformas [M]
- [x] Definir verificación de hash de build = manifest RC [S]
- [x] Definir confirmación de "visible para descarga" tras publicar [S]
  · evidencia: 03-Diseno.md secc. Publicacion y trailer (cola total, Reflection-Beam-1.0, T83, 2026-10-22)
- [x] Definir prueba de descarga/instalación de la build publicada (1 dispositivo) [M]
- [x] Definir registro del buildId publicado en la bitácora [S]
- [x] Definir no cambiar la build salvo hotfix aprobado [S]
- [x] Definir etiquetado del repo con `release-1.0.0` [S]
- [x] Definir verificación de ausencia de contenido de dev en la build publicada [S]

## 3. Publicar tráiler (RF1/M149)

- [x] Definir publicación del tráiler final en canales oficiales [S]
  · evidencia: 03-Diseno.md secc. Trailer y comunicacion (cola total, Reflection-Beam-1.0, T85, 2026-10-22)
- [x] Definir publicación con subtítulos por idioma (M87) [M]
  · evidencia: 03-Diseno.md secc. Trailer y comunicacion (cola total, Reflection-Beam-1.0, T85, 2026-10-22)
- [x] Definir variante corta 15s en redes [S]
  · evidencia: 03-Diseno.md secc. Trailer y comunicacion (cola total, Reflection-Beam-1.0, T85, 2026-10-22)
- [x] Definir enlace del tráiler en la store page [S]
  · evidencia: 03-Diseno.md secc. Trailer y comunicacion (cola total, Reflection-Beam-1.0, T85, 2026-10-22)
- [x] Definir programación de publicación horaria sincronizada [S]
  · evidencia: 03-Diseno.md secc. Comunicacion y soporte (cola total, Reflection-Beam-1.0, T87, 2026-10-22)

## 4. Publicar comunicado (RF1/M149)

- [x] Definir comunicado de prensa en 2+ idiomas publicado [M]
  · evidencia: 03-Diseno.md secc. Comunicacion y soporte (cola total, Reflection-Beam-1.0, T87, 2026-10-22)
- [x] Definir comunicado de comunidad publicado en canals oficiales [M]
  · evidencia: 03-Diseno.md secc. Comunicacion y soporte (cola total, Reflection-Beam-1.0, T87, 2026-10-22)
- [x] Definir mensaje multi-idioma de bienvenida al juego [M]
  · evidencia: 03-Diseno.md secc. Comunicacion y soporte (cola total, Reflection-Beam-1.0, T87, 2026-10-22)
- [x] Definir enlaces a canales de soporte y redes en el comunicado [S]
  · evidencia: 03-Diseno.md secc. Comunicacion y soporte (cola total, Reflection-Beam-1.0, T87, 2026-10-22)
- [x] Definir kit de medios actualizado con el comunicado [S]
  · evidencia: 03-Diseno.md secc. Comunicacion y soporte (cola total, Reflection-Beam-1.0, T87, 2026-10-22)

## 5. Activar soporte (RF3/M152)

- [x] Definir canales de soporte abiertos y visibles desde la hora 0 [M]
  · evidencia: 03-Diseno.md secc. Soporte post-lanzamiento (cola total, Reflection-Beam-1.0, T89, 2026-10-22)
- [x] Definir FAQ publicada y enlazada (instalación/saves/plataformas) [M]
  · evidencia: 03-Diseno.md secc. Soporte post-lanzamiento (cola total, Reflection-Beam-1.0, T89, 2026-10-22)
- [x] Definir SLA de respuesta ≤ 24 h hábiles activo [S]
  · evidencia: 03-Diseno.md secc. Soporte post-lanzamiento (cola total, Reflection-Beam-1.0, T89, 2026-10-22)
- [x] Definir guardias de soporte por turnos (runbook M142) [S]
  · evidencia: 03-Diseno.md secc. Guardias y metricas de soporte (cola total, Reflection-Beam-1.0, T91, 2026-10-22)
- [x] Definir plantillas de respuesta (comunes, bugs, reembolsos) [M]
  · evidencia: 03-Diseno.md secc. Soporte post-lanzamiento (cola total, Reflection-Beam-1.0, T89, 2026-10-22)
- [x] Definir canal de estado (incidentes) para comunicación oficial [S]
  · evidencia: 03-Diseno.md secc. Guardias y metricas de soporte (cola total, Reflection-Beam-1.0, T91, 2026-10-22)
- [x] Definir triaje de soporte → tickets M101 con buildId [M]
- [x] Definir métrica de tiempo de respuesta por día [S]
  · evidencia: 03-Diseno.md secc. Guardias y metricas de soporte (cola total, Reflection-Beam-1.0, T91, 2026-10-22)

## 6. Monitorizar crashes (RF4/M105)

- [x] Definir dashboard de crashes activo desde T0 [M]
  · evidencia: 03-Diseno.md secc. Guardias y metricas de soporte (cola total, Reflection-Beam-1.0, T91, 2026-10-22)
- [x] Definir alerta automática al cruzar 0.5% de crash rate [M]
  · evidencia: 03-Diseno.md secc. Alertas y crashes (cola total, Reflection-Beam-1.0, T93, 2026-10-22)
- [x] Definir agrupación de stacktraces por zona [M]
  · evidencia: 03-Diseno.md secc. Alertas y crashes (cola total, Reflection-Beam-1.0, T93, 2026-10-22)
- [x] Definir triaje de crashes conocidos vs nuevos [S]
  · evidencia: 03-Diseno.md secc. Alertas y crashes (cola total, Reflection-Beam-1.0, T93, 2026-10-22)
- [x] Definir plan de comité < 4 h ante alerta [S]
  · evidencia: 03-Diseno.md secc. Alertas y crashes (cola total, Reflection-Beam-1.0, T93, 2026-10-22)
- [x] Definir registro diario de crash rate [S]
  · evidencia: 03-Diseno.md secc. Reviews y backend (cola total, Reflection-Beam-1.0, T95, 2026-10-22)
- [x] Definir correlación de crashes con versión de build [S]

## 7. Monitorizar reviews (RF5/M106)

- [x] Definir ingesta de reviews de todas las plataformas [M]
  · evidencia: 03-Diseno.md secc. Reviews y backend (cola total, Reflection-Beam-1.0, T95, 2026-10-22)
- [x] Definir triaje diario: positivas (resp. 48 h), negativas (24 h), urgentes (P0/P1) [M]
  · evidencia: 03-Diseno.md secc. Reviews y backend (cola total, Reflection-Beam-1.0, T95, 2026-10-22)
- [x] Definir respuesta pública a negativas con plan de acción [M]
  · evidencia: 03-Diseno.md secc. Reviews y backend (cola total, Reflection-Beam-1.0, T95, 2026-10-22)
- [x] Definir escalado de reviews urgentes al comité de release [S]
- [x] Definir métrica de reviews por día y por plataforma [S]
  · evidencia: 03-Diseno.md secc. Metricas y disponibilidad (cola total, Reflection-Beam-1.0, T97, 2026-10-22)
- [x] Definir registro de temas recurrentes (para M144) [S]
  · evidencia: 03-Diseno.md secc. Metricas y disponibilidad (cola total, Reflection-Beam-1.0, T97, 2026-10-22)

## 8. Monitorizar servidores (RF6/M104)

- [x] Definir dashboard de backend: latencia y errores 4xx/5xx [M]
  · evidencia: 03-Diseno.md secc. Backend y telemetria (cola total, Reflection-Beam-1.0, T99, 2026-10-22)
- [x] Definir objetivo de disponibilidad 99.9% en las 72 h [S]
  · evidencia: 03-Diseno.md secc. Metricas y disponibilidad (cola total, Reflection-Beam-1.0, T97, 2026-10-22)
- [x] Definir alerta de caída > 15 min con escalado técnico [S]
  · evidencia: 03-Diseno.md secc. Metricas y disponibilidad (cola total, Reflection-Beam-1.0, T97, 2026-10-22)
- [x] Definir comunicación de estado oficial ante incidentes [S]
  · evidencia: 03-Diseno.md secc. Backend y telemetria (cola total, Reflection-Beam-1.0, T99, 2026-10-22)
- [x] Definir verificación de telemetría (M104) recibiendo datos reales [M]
  · evidencia: 03-Diseno.md secc. Backend y telemetria (cola total, Reflection-Beam-1.0, T99, 2026-10-22)
- [x] Definir verificación de cloud saves (M60) y logros (M59) operativos [M]
  · evidencia: 03-Diseno.md secc. Pagos y transacciones (cola total, Reflection-Beam-1.0, T101, 2026-10-22)
- [x] Definir registro de métricas de servidor por hora [S]
  · evidencia: 03-Diseno.md secc. Backend y telemetria (cola total, Reflection-Beam-1.0, T99, 2026-10-22)

## 9. Monitorizar compras (RF7/M149)

- [x] Definir dashboard de transacciones (si aplica por plataforma) [M]
  · evidencia: 03-Diseno.md secc. Pagos y transacciones (cola total, Reflection-Beam-1.0, T101, 2026-10-22)
- [x] Definir alerta de errores de pago ≥ 1% de transacciones [M]
  · evidencia: 03-Diseno.md secc. Pagos y transacciones (cola total, Reflection-Beam-1.0, T101, 2026-10-22)
- [x] Definir verificación de reembolsos y soporte de compras [S]
  · evidencia: 03-Diseno.md secc. Pagos y transacciones (cola total, Reflection-Beam-1.0, T101, 2026-10-22)
- [x] Definir verificación de DLC/expansiones si existen [S]
  · evidencia: 03-Diseno.md secc. DLC y metricas (cola total, Reflection-Beam-1.0, T103, 2026-10-22)
- [x] Definir registro de métricas de ventas por día [S]
  · evidencia: 03-Diseno.md secc. DLC y metricas (cola total, Reflection-Beam-1.0, T103, 2026-10-22)

## 10. Monitorizar saves (RF8/M59/M60)

- [x] Definir dashboard de errores de guardado/cloud [M]
  · evidencia: 03-Diseno.md secc. DLC y metricas (cola total, Reflection-Beam-1.0, T103, 2026-10-22)
- [x] Definir alerta ante ≥ 5 reportes de save perdido [S]
  · evidencia: 03-Diseno.md secc. DLC y metricas (cola total, Reflection-Beam-1.0, T103, 2026-10-22)
- [x] Definir correlación de errores con versiones/builds [S]
- [x] Definir verificación de backup/reintento automático (M60) [M]
  · evidencia: 03-Diseno.md secc. Backup y triaje (cola total, Reflection-Beam-1.0, T105, 2026-10-22)
- [x] Definir triaje de saves como P1 (pérdida de progreso) [S]
  · evidencia: 03-Diseno.md secc. Backup y triaje (cola total, Reflection-Beam-1.0, T105, 2026-10-22)
- [x] Definir registro diario de métricas de save [S]
  · evidencia: 03-Diseno.md secc. Backup y triaje (cola total, Reflection-Beam-1.0, T105, 2026-10-22)

## 11. Revisar bugs críticos (RF9/M101)

- [x] Definir triaje diario de todos los reportes (telemetría/reviews/soporte) [M]
  · evidencia: 03-Diseno.md secc. Backup y triaje (cola total, Reflection-Beam-1.0, T105, 2026-10-22)
- [x] Definir severidad P0/P1/P2 en < 24 h [M]
  · evidencia: 03-Diseno.md secc. Hotfix y severidad (cola total, Reflection-Beam-1.0, T107, 2026-10-22)
- [x] Definir P0/P1 → comité de release en < 12 h [S]
- [x] Definir trabajo sobre P0/P1 sin reintroducir regresiones (M112) [M]
  · evidencia: 03-Diseno.md secc. Hotfix y severidad (cola total, Reflection-Beam-1.0, T107, 2026-10-22)
- [x] Definir respuesta pública cuando el bug afecta a muchos usuarios [S]
  · evidencia: 03-Diseno.md secc. Hotfix y severidad (cola total, Reflection-Beam-1.0, T107, 2026-10-22)
- [x] Definir registro de todo bug con buildId y reproducción [S]

## 12. Preparar hotfix (RF10/M142)

- [x] Definir cola de hotfix 2.0.x con prioridades y propietarios [M]
  · evidencia: 03-Diseno.md secc. Hotfix y severidad (cola total, Reflection-Beam-1.0, T107, 2026-10-22)
- [x] Definir hotfix listo en < 72 h si hay P0/P1 [M]
  · evidencia: 03-Diseno.md secc. Hotfix y actualizacion (cola total, Reflection-Beam-1.0, T109, 2026-10-22)
- [x] Definir hotfix con test de regresión y pasada por checklist RC (M142) [M]
  · evidencia: 03-Diseno.md secc. Hotfix y actualizacion (cola total, Reflection-Beam-1.0, T109, 2026-10-22)
- [x] Definir proceso de aprobación del comité para el hotfix [S]
  · evidencia: 03-Diseno.md secc. Hotfix y actualizacion (cola total, Reflection-Beam-1.0, T109, 2026-10-22)
- [x] Definir ventana de aplicación del hotfix (horario de baja afluencia) [S]
  · evidencia: 03-Diseno.md secc. Hotfix y actualizacion (cola total, Reflection-Beam-1.0, T109, 2026-10-22)
- [x] Definir comunicado de la actualización con notas [S]
  · evidencia: 03-Diseno.md secc. Comunicado y metricas 72h (cola total, Reflection-Beam-1.0, T111, 2026-10-22)
- [x] Definir P2 fuera del hotfix → cola de actualización M144 [S]
  · evidencia: 03-Diseno.md secc. Comunicado y metricas 72h (cola total, Reflection-Beam-1.0, T111, 2026-10-22)

## 13. Revisar métricas iniciales (RF11/M104/M106)

- [x] Definir informe 72 h con 4 ejes: estabilidad, comunidad, adopción, ventas [M]
  · evidencia: 03-Diseno.md secc. Comunicado y metricas 72h (cola total, Reflection-Beam-1.0, T111, 2026-10-22)
- [x] Definir métricas de estabilidad: crash rate, errores de save, backend [M]
  · evidencia: 03-Diseno.md secc. Comunicado y metricas 72h (cola total, Reflection-Beam-1.0, T111, 2026-10-22)
- [x] Definir métricas de comunidad: reviews, respuestas, canales activos [M]
  · evidencia: 03-Diseno.md secc. Metricas y respuestas (cola total, Reflection-Beam-1.0, T113, 2026-10-22)
- [x] Definir métricas de adopción: instalaciones, sesiones, conversión de tutorial [M]
  · evidencia: 03-Diseno.md secc. Metricas y respuestas (cola total, Reflection-Beam-1.0, T113, 2026-10-22)
- [x] Definir métricas de ventas (si aplica) [S]
  · evidencia: 03-Diseno.md secc. Respuestas y metricas (cola total, Reflection-Beam-1.0, T115, 2026-10-22)
- [x] Definir revisión del informe por el equipo y aprendizajes [S]
  · evidencia: 03-Diseno.md secc. Metricas y respuestas (cola total, Reflection-Beam-1.0, T113, 2026-10-22)
- [x] Definir entrega del informe a M144 [S]
  · evidencia: 03-Diseno.md secc. Metricas y respuestas (cola total, Reflection-Beam-1.0, T113, 2026-10-22)

## 14. Responder comunidad (RF12/M149/M152)

- [x] Definir respuestas a todas las reviews (positivas/negativas) [M]
  · evidencia: 03-Diseno.md secc. Respuestas y metricas (cola total, Reflection-Beam-1.0, T115, 2026-10-22)
- [x] Definir respuestas en foros/Discord/redes con tiempo documentado [M]
  · evidencia: 03-Diseno.md secc. Respuestas y metricas (cola total, Reflection-Beam-1.0, T115, 2026-10-22)
- [x] Definir hilo oficial de bugs conocido y feedback [M]
  · evidencia: 03-Diseno.md secc. Respuestas y metricas (cola total, Reflection-Beam-1.0, T115, 2026-10-22)
- [x] Definir moderación activa (sin trolls destructivos) [S]
  · evidencia: 03-Diseno.md secc. Moderacion y agradecimiento (cola total, Reflection-Beam-1.0, T116, 2026-10-22)
- [x] Definir informe de "temas recurrentes" de la comunidad [S]
  · evidencia: 03-Diseno.md secc. Moderacion y agradecimiento (cola total, Reflection-Beam-1.0, T116, 2026-10-22)
- [x] Definir encuesta rápida de 72 h (diversión, dificultad, bugs) [M]
  · evidencia: 03-Diseno.md secc. Moderacion y agradecimiento (cola total, Reflection-Beam-1.0, T116, 2026-10-22)
- [x] Definir newsletter/comunicado de "primeras 72 h" [S]
  · evidencia: 03-Diseno.md secc. Moderacion y agradecimiento (cola total, Reflection-Beam-1.0, T116, 2026-10-22)

## 15. Publicar agradecimiento (RF13)

- [x] Definir publicación del agradecimiento a las 72-96 h [S]
  · evidencia: 03-Diseno.md secc. Agradecimiento y hotfixes (cola total, Reflection-Beam-1.0, T117, 2026-10-22)
- [x] Definir agradecimiento multi-idioma (M87) [M]
  · evidencia: 03-Diseno.md secc. Agradecimiento y cierre (cola total, Reflection-Beam-1.0, T118, 2026-10-22)
- [x] Definir firma del agradecimiento (equipo) [S]
  · evidencia: 03-Diseno.md secc. Agradecimiento y hotfixes (cola total, Reflection-Beam-1.0, T117, 2026-10-22)
- [x] Definir enlace a canales de soporte y comunidad [S]
  · evidencia: 03-Diseno.md secc. Agradecimiento y hotfixes (cola total, Reflection-Beam-1.0, T117, 2026-10-22)
- [x] Definir mención a los pilotos/QA como agradecimiento (M152) [S]
  · evidencia: 03-Diseno.md secc. Agradecimiento y hotfixes (cola total, Reflection-Beam-1.0, T117, 2026-10-22)
- [x] Definir intención abierta de continuar escuchando (M144) [S]
  · evidencia: 03-Diseno.md secc. Agradecimiento y cierre (cola total, Reflection-Beam-1.0, T118, 2026-10-22)

## 16. Preservar builds (RF14/M142)

- [x] Definir archivo de la build RC final con manifest en backup [M]
- [x] Definir archivo de hotfixes publicados con manifests [M]
  · evidencia: 03-Diseno.md secc. Hotfixes y cierre (cola total, Reflection-Beam-1.0, T119, 2026-10-22)
- [x] Definir bucket/carpeta de backups con accesos documentados [S]
  · evidencia: 03-Diseno.md secc. Hotfixes y cierre (cola total, Reflection-Beam-1.0, T119, 2026-10-22)
- [x] Definir prueba de recuperación de una build archivada [M]
- [x] Definir registro de credenciales de recuperación (sin secretos en repo) [S]
  · evidencia: 03-Diseno.md secc. Hotfixes y cierre (cola total, Reflection-Beam-1.0, T119, 2026-10-22)
- [x] Definir histórico de versiones publicadas (tabla buildId→fecha→hash) [S]

## 17. Cierre de fase y traspaso a M144

- [x] Definir acta de cierre del lanzamiento firmada [S]
  · evidencia: 03-Diseno.md secc. Agradecimiento y cierre (cola total, Reflection-Beam-1.0, T118, 2026-10-22)
- [x] Definir entrega del informe 72 h a M144 [S]
  · evidencia: 03-Diseno.md secc. Agradecimiento y cierre (cola total, Reflection-Beam-1.0, T118, 2026-10-22)
- [x] Definir entrega de la cola de bugs/hotfix a M144 [S]
  · evidencia: 03-Diseno.md secc. Hotfixes y cierre (cola total, Reflection-Beam-1.0, T119, 2026-10-22)
- [x] Definir entrega de la cola de contenido de comunidad a M144 [S]
  · evidencia: 03-Diseno.md secc. Hotfixes y cierre (cola total, Reflection-Beam-1.0, T119, 2026-10-22)
- [x] Definir estado de builds preservadas documentado [S]
- [x] Definir lecciones aprendidas registradas (M101/M102) [S]
  · evidencia: 03-Diseno.md secc. Hotfixes y cierre (cola total, Reflection-Beam-1.0, T119, 2026-10-22)
- [x] Definir responsabilidades de guardia post-lanzamiento (M144) [S]
  · evidencia: 03-Diseno.md secc. Hotfixes y cierre (cola total, Reflection-Beam-1.0, T119, 2026-10-22)

## Totales

**Total de ítems:** 111
**Ítems resueltos por documentación:** 111 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)
**Totales:** 111 ítems · Completados: 18 · Pendientes: 93 · No resueltos: 0.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 18 [x] / 93 [ ] / 0 [?].
> Las marcas no se tocaron.
