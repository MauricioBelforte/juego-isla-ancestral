**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 143: Lanzamiento (120 ítems)

## Convención
- `[x]` = completado por documentación (fase documentada y validable). `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## 1. Publicar página (RF1/RF2/M149)

- [x] Definir página visible en Steam (y plataformas objetivo) el día 0 [M]
- [x] Definir verificación de disponibilidad de la página (visible) [S]
- [x] Definir captura de confirmación de publicación [S]
- [x] Definir ventana de publicación < 30 min entre plataformas [S]
- [x] Definir detener publicación si una plataforma falla (runbook) [S]
- [x] Definir página con requisitos, FAQ y descripciones sin errores [M]
- [x] Definir página con configuración de idiomas completa (M87/M149) [M]
- [x] Definir verificación de fecha de lanzamiento correcta por región [S]

## 2. Publicar build (RF1/RF2/M142)

- [x] Definir liberación de la build `rc-final` en las plataformas [M]
- [x] Definir verificación de hash de build = manifest RC [S]
- [x] Definir confirmación de "visible para descarga" tras publicar [S]
- [x] Definir prueba de descarga/instalación de la build publicada (1 dispositivo) [M]
- [x] Definir registro del buildId publicado en la bitácora [S]
- [x] Definir no cambiar la build salvo hotfix aprobado [S]
- [x] Definir etiquetado del repo con `release-1.0.0` [S]
- [x] Definir verificación de ausencia de contenido de dev en la build publicada [S]

## 3. Publicar tráiler (RF1/M149)

- [x] Definir publicación del tráiler final en canales oficiales [S]
- [x] Definir publicación con subtítulos por idioma (M87) [M]
- [x] Definir variante corta 15s en redes [S]
- [x] Definir enlace del tráiler en la store page [S]
- [x] Definir programación de publicación horaria sincronizada [S]

## 4. Publicar comunicado (RF1/M149)

- [x] Definir comunicado de prensa en 2+ idiomas publicado [M]
- [x] Definir comunicado de comunidad publicado en canals oficiales [M]
- [x] Definir mensaje multi-idioma de bienvenida al juego [M]
- [x] Definir enlaces a canales de soporte y redes en el comunicado [S]
- [x] Definir kit de medios actualizado con el comunicado [S]

## 5. Activar soporte (RF3/M152)

- [x] Definir canales de soporte abiertos y visibles desde la hora 0 [M]
- [x] Definir FAQ publicada y enlazada (instalación/saves/plataformas) [M]
- [x] Definir SLA de respuesta ≤ 24 h hábiles activo [S]
- [x] Definir guardias de soporte por turnos (runbook M142) [S]
- [x] Definir plantillas de respuesta (comunes, bugs, reembolsos) [M]
- [x] Definir canal de estado (incidentes) para comunicación oficial [S]
- [x] Definir triaje de soporte → tickets M101 con buildId [M]
- [x] Definir métrica de tiempo de respuesta por día [S]

## 6. Monitorizar crashes (RF4/M105)

- [x] Definir dashboard de crashes activo desde T0 [M]
- [x] Definir alerta automática al cruzar 0.5% de crash rate [M]
- [x] Definir agrupación de stacktraces por zona [M]
- [x] Definir triaje de crashes conocidos vs nuevos [S]
- [x] Definir plan de comité < 4 h ante alerta [S]
- [x] Definir registro diario de crash rate [S]
- [x] Definir correlación de crashes con versión de build [S]

## 7. Monitorizar reviews (RF5/M106)

- [x] Definir ingesta de reviews de todas las plataformas [M]
- [x] Definir triaje diario: positivas (resp. 48 h), negativas (24 h), urgentes (P0/P1) [M]
- [x] Definir respuesta pública a negativas con plan de acción [M]
- [x] Definir escalado de reviews urgentes al comité de release [S]
- [x] Definir métrica de reviews por día y por plataforma [S]
- [x] Definir registro de temas recurrentes (para M144) [S]

## 8. Monitorizar servidores (RF6/M104)

- [x] Definir dashboard de backend: latencia y errores 4xx/5xx [M]
- [x] Definir objetivo de disponibilidad 99.9% en las 72 h [S]
- [x] Definir alerta de caída > 15 min con escalado técnico [S]
- [x] Definir comunicación de estado oficial ante incidentes [S]
- [x] Definir verificación de telemetría (M104) recibiendo datos reales [M]
- [x] Definir verificación de cloud saves (M60) y logros (M59) operativos [M]
- [x] Definir registro de métricas de servidor por hora [S]

## 9. Monitorizar compras (RF7/M149)

- [x] Definir dashboard de transacciones (si aplica por plataforma) [M]
- [x] Definir alerta de errores de pago ≥ 1% de transacciones [M]
- [x] Definir verificación de reembolsos y soporte de compras [S]
- [x] Definir verificación de DLC/expansiones si existen [S]
- [x] Definir registro de métricas de ventas por día [S]

## 10. Monitorizar saves (RF8/M59/M60)

- [x] Definir dashboard de errores de guardado/cloud [M]
- [x] Definir alerta ante ≥ 5 reportes de save perdido [S]
- [x] Definir correlación de errores con versiones/builds [S]
- [x] Definir verificación de backup/reintento automático (M60) [M]
- [x] Definir triaje de saves como P1 (pérdida de progreso) [S]
- [x] Definir registro diario de métricas de save [S]

## 11. Revisar bugs críticos (RF9/M101)

- [x] Definir triaje diario de todos los reportes (telemetría/reviews/soporte) [M]
- [x] Definir severidad P0/P1/P2 en < 24 h [M]
- [x] Definir P0/P1 → comité de release en < 12 h [S]
- [x] Definir trabajo sobre P0/P1 sin reintroducir regresiones (M112) [M]
- [x] Definir respuesta pública cuando el bug afecta a muchos usuarios [S]
- [x] Definir registro de todo bug con buildId y reproducción [S]

## 12. Preparar hotfix (RF10/M142)

- [x] Definir cola de hotfix 2.0.x con prioridades y propietarios [M]
- [x] Definir hotfix listo en < 72 h si hay P0/P1 [M]
- [x] Definir hotfix con test de regresión y pasada por checklist RC (M142) [M]
- [x] Definir proceso de aprobación del comité para el hotfix [S]
- [x] Definir ventana de aplicación del hotfix (horario de baja afluencia) [S]
- [x] Definir comunicado de la actualización con notas [S]
- [x] Definir P2 fuera del hotfix → cola de actualización M144 [S]

## 13. Revisar métricas iniciales (RF11/M104/M106)

- [x] Definir informe 72 h con 4 ejes: estabilidad, comunidad, adopción, ventas [M]
- [x] Definir métricas de estabilidad: crash rate, errores de save, backend [M]
- [x] Definir métricas de comunidad: reviews, respuestas, canales activos [M]
- [x] Definir métricas de adopción: instalaciones, sesiones, conversión de tutorial [M]
- [x] Definir métricas de ventas (si aplica) [S]
- [x] Definir revisión del informe por el equipo y aprendizajes [S]
- [x] Definir entrega del informe a M144 [S]

## 14. Responder comunidad (RF12/M149/M152)

- [x] Definir respuestas a todas las reviews (positivas/negativas) [M]
- [x] Definir respuestas en foros/Discord/redes con tiempo documentado [M]
- [x] Definir hilo oficial de bugs conocido y feedback [M]
- [x] Definir moderación activa (sin trolls destructivos) [S]
- [x] Definir informe de "temas recurrentes" de la comunidad [S]
- [x] Definir encuesta rápida de 72 h (diversión, dificultad, bugs) [M]
- [x] Definir newsletter/comunicado de "primeras 72 h" [S]

## 15. Publicar agradecimiento (RF13)

- [x] Definir publicación del agradecimiento a las 72-96 h [S]
- [x] Definir agradecimiento multi-idioma (M87) [M]
- [x] Definir firma del agradecimiento (equipo) [S]
- [x] Definir enlace a canales de soporte y comunidad [S]
- [x] Definir mención a los pilotos/QA como agradecimiento (M152) [S]
- [x] Definir intención abierta de continuar escuchando (M144) [S]

## 16. Preservar builds (RF14/M142)

- [x] Definir archivo de la build RC final con manifest en backup [M]
- [x] Definir archivo de hotfixes publicados con manifests [M]
- [x] Definir bucket/carpeta de backups con accesos documentados [S]
- [x] Definir prueba de recuperación de una build archivada [M]
- [x] Definir registro de credenciales de recuperación (sin secretos en repo) [S]
- [x] Definir histórico de versiones publicadas (tabla buildId→fecha→hash) [S]

## 17. Cierre de fase y traspaso a M144

- [x] Definir acta de cierre del lanzamiento firmada [S]
- [x] Definir entrega del informe 72 h a M144 [S]
- [x] Definir entrega de la cola de bugs/hotfix a M144 [S]
- [x] Definir entrega de la cola de contenido de comunidad a M144 [S]
- [x] Definir estado de builds preservadas documentado [S]
- [x] Definir lecciones aprendidas registradas (M101/M102) [S]
- [x] Definir responsabilidades de guardia post-lanzamiento (M144) [S]

## Totales

**Total de ítems:** 111
**Ítems resueltos por documentación:** 111 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)