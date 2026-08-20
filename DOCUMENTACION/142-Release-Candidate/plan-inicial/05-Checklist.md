**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 142: Release Candidate (130 ítems)

## Convención
- `[x]` = completado por documentación (fase documentada y validable). `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## 1. Freeze de features (RF1)

- [x] Definir comité de release (producción, QA, plataformas) con voto para hotfixes [S]
- [x] Definir minutas firmadas de cada decisión del comité [S]
- [x] Definir freeze firmado de features al inicio de RC [S]
- [x] Definir política: solo hotfixes P0/P1 aprobados entran al RC [S]
- [x] Definir rama de hotfix `hotfix/rc-N` con test de regresión obligatorio (M112) [M]
- [x] Definir re-etiquetado `rc-2`, `rc-3` ante cada hotfix [S]
- [x] Definir DiffAudit en CI (contra `beta-rc-candidate`) [M]
- [x] Definir fallo de CI si hay diffs no autorizados [S]
- [x] Definir ventana de 4 semanas máx. para la fase [S]
- [x] Definir replanificación de fecha si el gate no se cierra a las 4 semanas [S]

## 2. Freeze de contenido (RF1)

- [x] Definir manifest de contenido inamovible (hash del inventario Beta) [M]
- [x] Definir verificación de hash en cada build RC [S]
- [x] Definir prohibición de nuevo contenido (misiones, ítems, eventos) [S]
- [x] Definir excepción de contenido solo si es bug crítico de progresión [S]
- [x] Definir registro de cambios de contenido en el manifest [S]
- [x] Definir verificación semanal del estado del freeze [S]

## 3. Solo correcciones críticas (RF1/RF9)

- [x] Definir definición de crash/bloqueo (P0) [S]
- [x] Definir definición de pérdida de progreso (P1) [S]
- [x] Definir definición de P2 (menor, con workaround) [S]
- [x] Definir flujo de ticket P0/P1 → comité → hotfix [S]
- [x] Definir hotfix con test de regresión previo al merge (M112) [M]
- [x] Definir postmortem obligatorio por hotfix [S]
- [x] Definir cola de P2 documentada para la primera actualización post-lanzamiento [S]
- [x] Definir métrica de hotfixes por semana [S]

## 4. Build limpia (RF2/M104/M105)

- [x] Definir build final sin asserts/debug en Release [M]
- [x] Definir eliminación de logs de desarrollo en la build final [S]
- [x] Definir símbolos de crash accesibles al handler (M105) [M]
- [x] Definir telemetría de sesión activa en la build RC (M104) [M]
- [x] Definir versionado visible (buildId) en la pantalla de título [S]
- [x] Definir verificación de cero scripts de editor en el player [S]
- [x] Definir comprobación de assets de desarrollo (texturas/audio placeholder) fuera [S]
- [x] Definir build real (no Development Build) para G4 en adelante [S]

## 5. Instalación limpia (RF3/M149)

- [x] Definir prueba de instalación desde cero en cada plataforma (VM limpia) [M]
- [x] Definir verificación de arranque sin errores tras instalación limpia [M]
- [x] Definir prueba de desinstalación/reinstalación sin residuos [M]
- [x] Definir verificación de carpetas de datos correctas por plataforma [S]
- [x] Definir verificación de firmas de build (hash contra manifest) [S]
- [x] Definir prueba de instalación sobre sistema con idioma por defecto no-EN [M]
- [x] Definir prueba de instalación en disco con sín caracteres especiales [S]

## 6. Actualización funcional (RF3)

- [x] Definir prueba de actualización Beta → RC sin pérdida de datos [M]
- [x] Definir prueba de actualización de RC-1 a RC-2 (delta) [M]
- [x] Definir verificación de versión de save reportada como compatible [S]
- [x] Definir registro de logs de actualización (éxito/fallo) [S]
- [x] Definir rollback seguro si la actualización falla [M]
- [x] Definir prueba de actualización con red cortada a mitad [M]
- [x] Definir prueba de actualización de la build pública Beta a la RC [M]

## 7. Saves compatibles (RF4/M59)

- [x] Definir migración de save v3.x a versión RC sin pérdidas [M]
- [x] Definir 30 ciclos de guardar/cargar en la build RC [M]
- [x] Definir carga de saves de todas las fases previas (pre-Alpha a Beta) [M]
- [x] Definir prueba de save corrupto → backup y recuperación (M66) [M]
- [x] Definir reporte de versión de save en el manifiesto del usuario [S]
- [x] Definir verificación de que no hay saves con flags de dev activos [S]
- [x] Definir métrica de errores de save en piloto [S]

## 8. Cloud saves (RF5/M60)

- [x] Definir sincronización cloud activa en la build RC [M]
- [x] Definir 30 ciclos de sincronización con latencia simulada [M]
- [x] Definir resolución de conflicto "último ganador + backup" [M]
- [x] Definir validación de integridad antes de aplicar el save cloud [M]
- [x] Definir desconexión/reconexión de red durante sincronización [M]
- [x] Definir batalla de saves entre dos dispositivos (prueba) [M]
- [x] Definir reporte de errores de cloud sin reviente de UI [S]
- [x] Definir telemetría de tamaño y frecuencia de sync [S]

## 9. Logros (RF6/M59)

- [x] Definir matriz completa hitos → logros [M]
- [x] Definir desbloqueo local de logros sin dependencia de red [M]
- [x] Definir verificación de persistencia de logros tras reinicio [M]
- [x] Definir verificación de notificación de logro visible [S]
- [x] Definir logros retroactivos para saves Beta [M]
- [x] Definir prueba de plataforma sin login (sin cuenta) [S]
- [x] Definir 100% de logros alcanzables en juego limpio [M]

## 10. Idiomas (RF7/M87)

- [x] Definir matriz de 6 idiomas × pantallas clave [M]
- [x] Definir gate CI de claves sin huecos por idioma [M]
- [x] Definir playtest de 30 min por idioma en la build RC [M]
- [x] Definir verificación de desbordes de texto por idioma (UI) [M]
- [x] Definir verificación de traducción de logros y store (M149) [S]
- [x] Definir verificación de fechas/números por idioma [S]
- [x] Definir fallback a EN sin claves rotas [S]
- [x] Definir identificación de idioma del sistema correcta [S]

## 11. Rendimiento (RF8/M61-M63)

- [x] Definir perf de ruta fija 20 min en hardware mínimo [M]
- [x] Definir perf de ruta fija 20 min en recomendado [M]
- [x] Definir memoria dentro de M62 en las 6 islas [M]
- [x] Definir tiempos de carga/streaming dentro de M63 [M]
- [x] Definir FPS p99 ≥ objetivo en sesiones largas (60+ min) [M]
- [x] Definir batching/draw calls finales por zona [M]
- [x] Definir informe de rendimiento del piloto (percentiles reales) [M]
- [x] Definir gate CI de rendimiento en la build RC [M]
- [x] Definir comparativa final mínima vs recomendada [S]

## 12. Crash rate (RF9/M105)

- [x] Definir objetivo crash rate < 0.5% de sesiones [S]
- [x] Definir piloto de 1000 sesiones con invitados [M]
- [x] Definir handler de crashes con stacktrace y símbolos (M105) [M]
- [x] Definir dashboard de crashes por zona/build [M]
- [x] Definir triaje de crash stacks conocidos vs nuevos [M]
- [x] Definir hotfix dirigido si crash rate no baja a objetivo [M]
- [x] Definir reporte final de crash rate del piloto [S]
- [x] Definir verificación de que los crashes no bloquean saves/cloud [S]

## 13. Certificación (RF10/M149)

- [x] Definir checklist de certificación por plataforma (build, contenido, cloud, edad) [M]
- [x] Definir revisión de políticas de contenido (violencia/edad) [S]
- [x] Definir capturas de la build final para certificación [S]
- [x] Definir prueba de certificación: instalación, actualización, saves [M]
- [x] Definir aprobación firmada por responsable de plataforma [S]
- [x] Definir registro de desvíos y excepciones aprobadas [S]
- [x] Definir preparación de los paquetes de certificación (textos, archivos) [M]

## 14. Legal (RF11/M149)

- [x] Definir términos de servicio final [S]
- [x] Definir política de privacidad final (cloud, telemetría) [S]
- [x] Definir atribuciones de assets de terceros completas [M]
- [x] Definir clasificación etaria (ESRB/PEGI) con documentos [M]
- [x] Definir contratos de voz/música con derechos despejados (M41-M44) [M]
- [x] Definir revisión legal firmada [S]
- [x] Definir verificación de no contenido ofensivo por región (M147) [S]

## 15. Marketing (RF12/M149)

- [x] Definir store page publicada-ready (textos, capturas, tags) [M]
- [x] Definir tráiler final montado y aprobado [M]
- [x] Definir comunicado de prensa final en 2 idiomas [M]
- [x] Definir kit de medios (capturas HQ, logos, b-roll) [M]
- [x] Definir plan de contenido de redes para día 0 y semana 1 [M]
- [x] Definir lista de reviewers/streamers contactados [M]
- [x] Definir verificación de disponibilidad de la página (fecha oculta hasta día 0) [S]

## 16. Soporte (RF13/M152)

- [x] Definir canales de soporte (foros, Discord, correo) activos [M]
- [x] Definir FAQ publicada (instalación, saves, plataformas, idiomas) [M]
- [x] Definir proceso de reportes versionados por buildId (M101) [M]
- [x] Definir SLA de respuesta definido (24 h hábiles) [S]
- [x] Definir triaje diario de soporte en lanzamiento [S]
- [x] Definir camino de escalado de bugs de soporte a tracker [S]
- [x] Definir backup de canales (quién cubre a quién) [S]

## 17. Plan de lanzamiento (RF14/M143)

- [x] Definir cronograma día 0 con horas locales por región [M]
- [x] Definir responsables de cada tarea del día 0 [S]
- [x] Definir runbook: publicar página, publicar build, publicar tráiler, comunicado [M]
- [x] Definir runbook de incidentes (crash masivo, store caída, cloud) [M]
- [x] Definir holgura de 48 h ante imprevistos [S]
- [x] Definir aprobación final del plan por el equipo [S]
- [x] Definir verificación de accesos de plataforma (quién puede publicar) [S]
- [x] Definir respaldo de credenciales sin compartir secretos en repo [S]

## Totales

**Total de ítems:** 129
**Ítems resueltos por documentación:** 129 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)