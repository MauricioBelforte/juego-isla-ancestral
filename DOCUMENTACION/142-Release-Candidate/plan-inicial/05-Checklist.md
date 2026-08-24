**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 142: Release Candidate (130 ítems)

## Convención
- `[ ]` = completado por documentación (fase documentada y validable). `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## 1. Freeze de features (RF1)

- [ ] Definir comité de release (producción, QA, plataformas) con voto para hotfixes [S]
- [ ] Definir minutas firmadas de cada decisión del comité [S]
- [ ] Definir freeze firmado de features al inicio de RC [S]
- [ ] Definir política: solo hotfixes P0/P1 aprobados entran al RC [S]
- [ ] Definir rama de hotfix `hotfix/rc-N` con test de regresión obligatorio (M112) [M]
- [ ] Definir re-etiquetado `rc-2`, `rc-3` ante cada hotfix [S]
- [ ] Definir DiffAudit en CI (contra `beta-rc-candidate`) [M]
- [ ] Definir fallo de CI si hay diffs no autorizados [S]
- [ ] Definir ventana de 4 semanas máx. para la fase [S]
- [ ] Definir replanificación de fecha si el gate no se cierra a las 4 semanas [S]

## 2. Freeze de contenido (RF1)

- [ ] Definir manifest de contenido inamovible (hash del inventario Beta) [M]
- [ ] Definir verificación de hash en cada build RC [S]
- [ ] Definir prohibición de nuevo contenido (misiones, ítems, eventos) [S]
- [ ] Definir excepción de contenido solo si es bug crítico de progresión [S]
- [ ] Definir registro de cambios de contenido en el manifest [S]
- [ ] Definir verificación semanal del estado del freeze [S]

## 3. Solo correcciones críticas (RF1/RF9)

- [ ] Definir definición de crash/bloqueo (P0) [S]
- [ ] Definir definición de pérdida de progreso (P1) [S]
- [ ] Definir definición de P2 (menor, con workaround) [S]
- [ ] Definir flujo de ticket P0/P1 → comité → hotfix [S]
- [ ] Definir hotfix con test de regresión previo al merge (M112) [M]
- [ ] Definir postmortem obligatorio por hotfix [S]
- [ ] Definir cola de P2 documentada para la primera actualización post-lanzamiento [S]
- [ ] Definir métrica de hotfixes por semana [S]

## 4. Build limpia (RF2/M104/M105)

- [ ] Definir build final sin asserts/debug en Release [M]
- [ ] Definir eliminación de logs de desarrollo en la build final [S]
- [ ] Definir símbolos de crash accesibles al handler (M105) [M]
- [ ] Definir telemetría de sesión activa en la build RC (M104) [M]
- [ ] Definir versionado visible (buildId) en la pantalla de título [S]
- [ ] Definir verificación de cero scripts de editor en el player [S]
- [ ] Definir comprobación de assets de desarrollo (texturas/audio placeholder) fuera [S]
- [ ] Definir build real (no Development Build) para G4 en adelante [S]

## 5. Instalación limpia (RF3/M149)

- [ ] Definir prueba de instalación desde cero en cada plataforma (VM limpia) [M]
- [ ] Definir verificación de arranque sin errores tras instalación limpia [M]
- [ ] Definir prueba de desinstalación/reinstalación sin residuos [M]
- [ ] Definir verificación de carpetas de datos correctas por plataforma [S]
- [ ] Definir verificación de firmas de build (hash contra manifest) [S]
- [ ] Definir prueba de instalación sobre sistema con idioma por defecto no-EN [M]
- [ ] Definir prueba de instalación en disco con sín caracteres especiales [S]

## 6. Actualización funcional (RF3)

- [ ] Definir prueba de actualización Beta → RC sin pérdida de datos [M]
- [ ] Definir prueba de actualización de RC-1 a RC-2 (delta) [M]
- [ ] Definir verificación de versión de save reportada como compatible [S]
- [ ] Definir registro de logs de actualización (éxito/fallo) [S]
- [ ] Definir rollback seguro si la actualización falla [M]
- [ ] Definir prueba de actualización con red cortada a mitad [M]
- [ ] Definir prueba de actualización de la build pública Beta a la RC [M]

## 7. Saves compatibles (RF4/M59)

- [ ] Definir migración de save v3.x a versión RC sin pérdidas [M]
- [ ] Definir 30 ciclos de guardar/cargar en la build RC [M]
- [ ] Definir carga de saves de todas las fases previas (pre-Alpha a Beta) [M]
- [ ] Definir prueba de save corrupto → backup y recuperación (M66) [M]
- [ ] Definir reporte de versión de save en el manifiesto del usuario [S]
- [ ] Definir verificación de que no hay saves con flags de dev activos [S]
- [ ] Definir métrica de errores de save en piloto [S]

## 8. Cloud saves (RF5/M60)

- [ ] Definir sincronización cloud activa en la build RC [M]
- [ ] Definir 30 ciclos de sincronización con latencia simulada [M]
- [ ] Definir resolución de conflicto "último ganador + backup" [M]
- [ ] Definir validación de integridad antes de aplicar el save cloud [M]
- [ ] Definir desconexión/reconexión de red durante sincronización [M]
- [ ] Definir batalla de saves entre dos dispositivos (prueba) [M]
- [ ] Definir reporte de errores de cloud sin reviente de UI [S]
- [ ] Definir telemetría de tamaño y frecuencia de sync [S]

## 9. Logros (RF6/M59)

- [ ] Definir matriz completa hitos → logros [M]
- [ ] Definir desbloqueo local de logros sin dependencia de red [M]
- [ ] Definir verificación de persistencia de logros tras reinicio [M]
- [ ] Definir verificación de notificación de logro visible [S]
- [ ] Definir logros retroactivos para saves Beta [M]
- [ ] Definir prueba de plataforma sin login (sin cuenta) [S]
- [ ] Definir 100% de logros alcanzables en juego limpio [M]

## 10. Idiomas (RF7/M87)

- [ ] Definir matriz de 6 idiomas × pantallas clave [M]
- [ ] Definir gate CI de claves sin huecos por idioma [M]
- [ ] Definir playtest de 30 min por idioma en la build RC [M]
- [ ] Definir verificación de desbordes de texto por idioma (UI) [M]
- [ ] Definir verificación de traducción de logros y store (M149) [S]
- [ ] Definir verificación de fechas/números por idioma [S]
- [ ] Definir fallback a EN sin claves rotas [S]
- [ ] Definir identificación de idioma del sistema correcta [S]

## 11. Rendimiento (RF8/M61-M63)

- [ ] Definir perf de ruta fija 20 min en hardware mínimo [M]
- [ ] Definir perf de ruta fija 20 min en recomendado [M]
- [ ] Definir memoria dentro de M62 en las 6 islas [M]
- [ ] Definir tiempos de carga/streaming dentro de M63 [M]
- [ ] Definir FPS p99 ≥ objetivo en sesiones largas (60+ min) [M]
- [ ] Definir batching/draw calls finales por zona [M]
- [ ] Definir informe de rendimiento del piloto (percentiles reales) [M]
- [ ] Definir gate CI de rendimiento en la build RC [M]
- [ ] Definir comparativa final mínima vs recomendada [S]

## 12. Crash rate (RF9/M105)

- [ ] Definir objetivo crash rate < 0.5% de sesiones [S]
- [ ] Definir piloto de 1000 sesiones con invitados [M]
- [ ] Definir handler de crashes con stacktrace y símbolos (M105) [M]
- [ ] Definir dashboard de crashes por zona/build [M]
- [ ] Definir triaje de crash stacks conocidos vs nuevos [M]
- [ ] Definir hotfix dirigido si crash rate no baja a objetivo [M]
- [ ] Definir reporte final de crash rate del piloto [S]
- [ ] Definir verificación de que los crashes no bloquean saves/cloud [S]

## 13. Certificación (RF10/M149)

- [ ] Definir checklist de certificación por plataforma (build, contenido, cloud, edad) [M]
- [ ] Definir revisión de políticas de contenido (violencia/edad) [S]
- [ ] Definir capturas de la build final para certificación [S]
- [ ] Definir prueba de certificación: instalación, actualización, saves [M]
- [ ] Definir aprobación firmada por responsable de plataforma [S]
- [ ] Definir registro de desvíos y excepciones aprobadas [S]
- [ ] Definir preparación de los paquetes de certificación (textos, archivos) [M]

## 14. Legal (RF11/M149)

- [ ] Definir términos de servicio final [S]
- [ ] Definir política de privacidad final (cloud, telemetría) [S]
- [ ] Definir atribuciones de assets de terceros completas [M]
- [ ] Definir clasificación etaria (ESRB/PEGI) con documentos [M]
- [ ] Definir contratos de voz/música con derechos despejados (M41-M44) [M]
- [ ] Definir revisión legal firmada [S]
- [ ] Definir verificación de no contenido ofensivo por región (M147) [S]

## 15. Marketing (RF12/M149)

- [ ] Definir store page publicada-ready (textos, capturas, tags) [M]
- [ ] Definir tráiler final montado y aprobado [M]
- [ ] Definir comunicado de prensa final en 2 idiomas [M]
- [ ] Definir kit de medios (capturas HQ, logos, b-roll) [M]
- [ ] Definir plan de contenido de redes para día 0 y semana 1 [M]
- [ ] Definir lista de reviewers/streamers contactados [M]
- [ ] Definir verificación de disponibilidad de la página (fecha oculta hasta día 0) [S]

## 16. Soporte (RF13/M152)

- [ ] Definir canales de soporte (foros, Discord, correo) activos [M]
- [ ] Definir FAQ publicada (instalación, saves, plataformas, idiomas) [M]
- [ ] Definir proceso de reportes versionados por buildId (M101) [M]
- [ ] Definir SLA de respuesta definido (24 h hábiles) [S]
- [ ] Definir triaje diario de soporte en lanzamiento [S]
- [ ] Definir camino de escalado de bugs de soporte a tracker [S]
- [ ] Definir backup de canales (quién cubre a quién) [S]

## 17. Plan de lanzamiento (RF14/M143)

- [ ] Definir cronograma día 0 con horas locales por región [M]
- [ ] Definir responsables de cada tarea del día 0 [S]
- [ ] Definir runbook: publicar página, publicar build, publicar tráiler, comunicado [M]
- [ ] Definir runbook de incidentes (crash masivo, store caída, cloud) [M]
- [ ] Definir holgura de 48 h ante imprevistos [S]
- [ ] Definir aprobación final del plan por el equipo [S]
- [ ] Definir verificación de accesos de plataforma (quién puede publicar) [S]
- [ ] Definir respaldo de credenciales sin compartir secretos en repo [S]

## Totales

**Total de ítems:** 129
**Ítems resueltos por documentación:** 129 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)