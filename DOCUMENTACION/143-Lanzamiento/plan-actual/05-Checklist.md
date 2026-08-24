**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 143: Lanzamiento (120 ítems)

## Convención
- `[ ]` = completado por documentación (fase documentada y validable). `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## 1. Publicar página (RF1/RF2/M149)

- [ ] Definir página visible en Steam (y plataformas objetivo) el día 0 [M]
- [ ] Definir verificación de disponibilidad de la página (visible) [S]
- [ ] Definir captura de confirmación de publicación [S]
- [ ] Definir ventana de publicación < 30 min entre plataformas [S]
- [ ] Definir detener publicación si una plataforma falla (runbook) [S]
- [ ] Definir página con requisitos, FAQ y descripciones sin errores [M]
- [ ] Definir página con configuración de idiomas completa (M87/M149) [M]
- [ ] Definir verificación de fecha de lanzamiento correcta por región [S]

## 2. Publicar build (RF1/RF2/M142)

- [ ] Definir liberación de la build `rc-final` en las plataformas [M]
- [ ] Definir verificación de hash de build = manifest RC [S]
- [ ] Definir confirmación de "visible para descarga" tras publicar [S]
- [ ] Definir prueba de descarga/instalación de la build publicada (1 dispositivo) [M]
- [ ] Definir registro del buildId publicado en la bitácora [S]
- [ ] Definir no cambiar la build salvo hotfix aprobado [S]
- [ ] Definir etiquetado del repo con `release-1.0.0` [S]
- [ ] Definir verificación de ausencia de contenido de dev en la build publicada [S]

## 3. Publicar tráiler (RF1/M149)

- [ ] Definir publicación del tráiler final en canales oficiales [S]
- [ ] Definir publicación con subtítulos por idioma (M87) [M]
- [ ] Definir variante corta 15s en redes [S]
- [ ] Definir enlace del tráiler en la store page [S]
- [ ] Definir programación de publicación horaria sincronizada [S]

## 4. Publicar comunicado (RF1/M149)

- [ ] Definir comunicado de prensa en 2+ idiomas publicado [M]
- [ ] Definir comunicado de comunidad publicado en canals oficiales [M]
- [ ] Definir mensaje multi-idioma de bienvenida al juego [M]
- [ ] Definir enlaces a canales de soporte y redes en el comunicado [S]
- [ ] Definir kit de medios actualizado con el comunicado [S]

## 5. Activar soporte (RF3/M152)

- [ ] Definir canales de soporte abiertos y visibles desde la hora 0 [M]
- [ ] Definir FAQ publicada y enlazada (instalación/saves/plataformas) [M]
- [ ] Definir SLA de respuesta ≤ 24 h hábiles activo [S]
- [ ] Definir guardias de soporte por turnos (runbook M142) [S]
- [ ] Definir plantillas de respuesta (comunes, bugs, reembolsos) [M]
- [ ] Definir canal de estado (incidentes) para comunicación oficial [S]
- [ ] Definir triaje de soporte → tickets M101 con buildId [M]
- [ ] Definir métrica de tiempo de respuesta por día [S]

## 6. Monitorizar crashes (RF4/M105)

- [ ] Definir dashboard de crashes activo desde T0 [M]
- [ ] Definir alerta automática al cruzar 0.5% de crash rate [M]
- [ ] Definir agrupación de stacktraces por zona [M]
- [ ] Definir triaje de crashes conocidos vs nuevos [S]
- [ ] Definir plan de comité < 4 h ante alerta [S]
- [ ] Definir registro diario de crash rate [S]
- [ ] Definir correlación de crashes con versión de build [S]

## 7. Monitorizar reviews (RF5/M106)

- [ ] Definir ingesta de reviews de todas las plataformas [M]
- [ ] Definir triaje diario: positivas (resp. 48 h), negativas (24 h), urgentes (P0/P1) [M]
- [ ] Definir respuesta pública a negativas con plan de acción [M]
- [ ] Definir escalado de reviews urgentes al comité de release [S]
- [ ] Definir métrica de reviews por día y por plataforma [S]
- [ ] Definir registro de temas recurrentes (para M144) [S]

## 8. Monitorizar servidores (RF6/M104)

- [ ] Definir dashboard de backend: latencia y errores 4xx/5xx [M]
- [ ] Definir objetivo de disponibilidad 99.9% en las 72 h [S]
- [ ] Definir alerta de caída > 15 min con escalado técnico [S]
- [ ] Definir comunicación de estado oficial ante incidentes [S]
- [ ] Definir verificación de telemetría (M104) recibiendo datos reales [M]
- [ ] Definir verificación de cloud saves (M60) y logros (M59) operativos [M]
- [ ] Definir registro de métricas de servidor por hora [S]

## 9. Monitorizar compras (RF7/M149)

- [ ] Definir dashboard de transacciones (si aplica por plataforma) [M]
- [ ] Definir alerta de errores de pago ≥ 1% de transacciones [M]
- [ ] Definir verificación de reembolsos y soporte de compras [S]
- [ ] Definir verificación de DLC/expansiones si existen [S]
- [ ] Definir registro de métricas de ventas por día [S]

## 10. Monitorizar saves (RF8/M59/M60)

- [ ] Definir dashboard de errores de guardado/cloud [M]
- [ ] Definir alerta ante ≥ 5 reportes de save perdido [S]
- [ ] Definir correlación de errores con versiones/builds [S]
- [ ] Definir verificación de backup/reintento automático (M60) [M]
- [ ] Definir triaje de saves como P1 (pérdida de progreso) [S]
- [ ] Definir registro diario de métricas de save [S]

## 11. Revisar bugs críticos (RF9/M101)

- [ ] Definir triaje diario de todos los reportes (telemetría/reviews/soporte) [M]
- [ ] Definir severidad P0/P1/P2 en < 24 h [M]
- [ ] Definir P0/P1 → comité de release en < 12 h [S]
- [ ] Definir trabajo sobre P0/P1 sin reintroducir regresiones (M112) [M]
- [ ] Definir respuesta pública cuando el bug afecta a muchos usuarios [S]
- [ ] Definir registro de todo bug con buildId y reproducción [S]

## 12. Preparar hotfix (RF10/M142)

- [ ] Definir cola de hotfix 2.0.x con prioridades y propietarios [M]
- [ ] Definir hotfix listo en < 72 h si hay P0/P1 [M]
- [ ] Definir hotfix con test de regresión y pasada por checklist RC (M142) [M]
- [ ] Definir proceso de aprobación del comité para el hotfix [S]
- [ ] Definir ventana de aplicación del hotfix (horario de baja afluencia) [S]
- [ ] Definir comunicado de la actualización con notas [S]
- [ ] Definir P2 fuera del hotfix → cola de actualización M144 [S]

## 13. Revisar métricas iniciales (RF11/M104/M106)

- [ ] Definir informe 72 h con 4 ejes: estabilidad, comunidad, adopción, ventas [M]
- [ ] Definir métricas de estabilidad: crash rate, errores de save, backend [M]
- [ ] Definir métricas de comunidad: reviews, respuestas, canales activos [M]
- [ ] Definir métricas de adopción: instalaciones, sesiones, conversión de tutorial [M]
- [ ] Definir métricas de ventas (si aplica) [S]
- [ ] Definir revisión del informe por el equipo y aprendizajes [S]
- [ ] Definir entrega del informe a M144 [S]

## 14. Responder comunidad (RF12/M149/M152)

- [ ] Definir respuestas a todas las reviews (positivas/negativas) [M]
- [ ] Definir respuestas en foros/Discord/redes con tiempo documentado [M]
- [ ] Definir hilo oficial de bugs conocido y feedback [M]
- [ ] Definir moderación activa (sin trolls destructivos) [S]
- [ ] Definir informe de "temas recurrentes" de la comunidad [S]
- [ ] Definir encuesta rápida de 72 h (diversión, dificultad, bugs) [M]
- [ ] Definir newsletter/comunicado de "primeras 72 h" [S]

## 15. Publicar agradecimiento (RF13)

- [ ] Definir publicación del agradecimiento a las 72-96 h [S]
- [ ] Definir agradecimiento multi-idioma (M87) [M]
- [ ] Definir firma del agradecimiento (equipo) [S]
- [ ] Definir enlace a canales de soporte y comunidad [S]
- [ ] Definir mención a los pilotos/QA como agradecimiento (M152) [S]
- [ ] Definir intención abierta de continuar escuchando (M144) [S]

## 16. Preservar builds (RF14/M142)

- [ ] Definir archivo de la build RC final con manifest en backup [M]
- [ ] Definir archivo de hotfixes publicados con manifests [M]
- [ ] Definir bucket/carpeta de backups con accesos documentados [S]
- [ ] Definir prueba de recuperación de una build archivada [M]
- [ ] Definir registro de credenciales de recuperación (sin secretos en repo) [S]
- [ ] Definir histórico de versiones publicadas (tabla buildId→fecha→hash) [S]

## 17. Cierre de fase y traspaso a M144

- [ ] Definir acta de cierre del lanzamiento firmada [S]
- [ ] Definir entrega del informe 72 h a M144 [S]
- [ ] Definir entrega de la cola de bugs/hotfix a M144 [S]
- [ ] Definir entrega de la cola de contenido de comunidad a M144 [S]
- [ ] Definir estado de builds preservadas documentado [S]
- [ ] Definir lecciones aprendidas registradas (M101/M102) [S]
- [ ] Definir responsabilidades de guardia post-lanzamiento (M144) [S]

## Totales

**Total de ítems:** 111
**Ítems resueltos por documentación:** 111 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)