# Tareas módulo 142 142-Release-Candidate

**Estado:** 🟢 Disponible

**Items pendientes:** 106

[ ] T-142-001: Definir minutas firmadas de cada decisión del comité
[ ] T-142-002: Definir freeze firmado de features al inicio de RC
[ ] T-142-003: Definir política: solo hotfixes P0/P1 aprobados entran al RC
[ ] T-142-004: Definir rama de hotfix `hotfix/rc-N` con test de regresión obligatorio (M112)
[ ] T-142-005: Definir re-etiquetado `rc-2`, `rc-3` ante cada hotfix
[ ] T-142-006: Definir DiffAudit en CI (contra `beta-rc-candidate`)
[ ] T-142-007: Definir fallo de CI si hay diffs no autorizados
[ ] T-142-008: Definir ventana de 4 semanas máx. para la fase
[ ] T-142-009: Definir manifest de contenido inamovible (hash del inventario Beta)
[ ] T-142-010: Definir prohibición de nuevo contenido (misiones, ítems, eventos)
[ ] T-142-011: Definir excepción de contenido solo si es bug crítico de progresión
[ ] T-142-012: Definir registro de cambios de contenido en el manifest
[ ] T-142-013: Definir verificación semanal del estado del freeze
[ ] T-142-014: Definir definición de crash/bloqueo (P0)
[ ] T-142-015: Definir definición de pérdida de progreso (P1)
[ ] T-142-016: Definir definición de P2 (menor, con workaround)
[ ] T-142-017: Definir flujo de ticket P0/P1 → comité → hotfix
[ ] T-142-018: Definir hotfix con test de regresión previo al merge (M112)
[ ] T-142-019: Definir postmortem obligatorio por hotfix
[ ] T-142-020: Definir cola de P2 documentada para la primera actualización post-lanzamiento
[ ] T-142-021: Definir métrica de hotfixes por semana
[ ] T-142-022: Definir símbolos de crash accesibles al handler (M105)
[ ] T-142-023: Definir comprobación de assets de desarrollo (texturas/audio placeholder) fuera
[ ] T-142-024: Definir prueba de instalación desde cero en cada plataforma (VM limpia)
[ ] T-142-025: Definir verificación de arranque sin errores tras instalación limpia
[ ] T-142-026: Definir prueba de desinstalación/reinstalación sin residuos
[ ] T-142-027: Definir verificación de carpetas de datos correctas por plataforma
[ ] T-142-028: Definir prueba de instalación en disco con sín caracteres especiales
[ ] T-142-029: Definir prueba de actualización Beta → RC sin pérdida de datos
[ ] T-142-030: Definir prueba de actualización de RC-1 a RC-2 (delta)
[ ] T-142-031: Definir verificación de versión de save reportada como compatible
[ ] T-142-032: Definir registro de logs de actualización (éxito/fallo)
[ ] T-142-033: Definir rollback seguro si la actualización falla
[ ] T-142-034: Definir prueba de actualización con red cortada a mitad
[ ] T-142-035: Definir migración de save v3.x a versión RC sin pérdidas
[ ] T-142-036: Definir carga de saves de todas las fases previas (pre-Alpha a Beta)
[ ] T-142-037: Definir prueba de save corrupto → backup y recuperación (M66)
[ ] T-142-038: Definir reporte de versión de save en el manifiesto del usuario
[ ] T-142-039: Definir verificación de que no hay saves con flags de dev activos
[ ] T-142-040: Definir métrica de errores de save en piloto
[ ] T-142-041: Definir 30 ciclos de sincronización con latencia simulada
[ ] T-142-042: Definir resolución de conflicto "último ganador + backup"
[ ] T-142-043: Definir validación de integridad antes de aplicar el save cloud
[ ] T-142-044: Definir desconexión/reconexión de red durante sincronización
[ ] T-142-045: Definir batalla de saves entre dos dispositivos (prueba)
[ ] T-142-046: Definir reporte de errores de cloud sin reviente de UI
[ ] T-142-047: Definir telemetría de tamaño y frecuencia de sync
[ ] T-142-048: Definir matriz completa hitos → logros
[ ] T-142-049: Definir desbloqueo local de logros sin dependencia de red
[ ] T-142-050: Definir verificación de persistencia de logros tras reinicio
[ ] T-142-051: Definir verificación de notificación de logro visible
[ ] T-142-052: Definir logros retroactivos para saves Beta
[ ] T-142-053: Definir prueba de plataforma sin login (sin cuenta)
[ ] T-142-054: Definir 100% de logros alcanzables en juego limpio
[ ] T-142-055: Definir matriz de 6 idiomas × pantallas clave
[ ] T-142-056: Definir verificación de desbordes de texto por idioma (UI)
[ ] T-142-057: Definir verificación de traducción de logros y store (M149)
[ ] T-142-058: Definir verificación de fechas/números por idioma
[ ] T-142-059: Definir fallback a EN sin claves rotas
[ ] T-142-060: Definir perf de ruta fija 20 min en hardware mínimo
[ ] T-142-061: Definir perf de ruta fija 20 min en recomendado
[ ] T-142-062: Definir memoria dentro de M62 en las 6 islas
[ ] T-142-063: Definir tiempos de carga/streaming dentro de M63
[ ] T-142-064: Definir FPS p99 ≥ objetivo en sesiones largas (60+ min)
[ ] T-142-065: Definir batching/draw calls finales por zona
[ ] T-142-066: Definir informe de rendimiento del piloto (percentiles reales)
[ ] T-142-067: Definir comparativa final mínima vs recomendada
[ ] T-142-068: Definir objetivo crash rate < 0.5% de sesiones
[ ] T-142-069: Definir piloto de 1000 sesiones con invitados
[ ] T-142-070: Definir handler de crashes con stacktrace y símbolos (M105)
[ ] T-142-071: Definir triaje de crash stacks conocidos vs nuevos
[ ] T-142-072: Definir hotfix dirigido si crash rate no baja a objetivo
[ ] T-142-073: Definir reporte final de crash rate del piloto
[ ] T-142-074: Definir verificación de que los crashes no bloquean saves/cloud
[ ] T-142-075: Definir revisión de políticas de contenido (violencia/edad)
[ ] T-142-076: Definir prueba de certificación: instalación, actualización, saves
[ ] T-142-077: Definir aprobación firmada por responsable de plataforma
[ ] T-142-078: Definir registro de desvíos y excepciones aprobadas
[ ] T-142-079: Definir preparación de los paquetes de certificación (textos, archivos)
[ ] T-142-080: Definir términos de servicio final
[ ] T-142-081: Definir política de privacidad final (cloud, telemetría)
[ ] T-142-082: Definir atribuciones de assets de terceros completas
[ ] T-142-083: Definir clasificación etaria (ESRB/PEGI) con documentos
[ ] T-142-084: Definir contratos de voz/música con derechos despejados (M41-M44)
[ ] T-142-085: Definir revisión legal firmada
[ ] T-142-086: Definir verificación de no contenido ofensivo por región (M147)
[ ] T-142-087: Definir store page publicada-ready (textos, capturas, tags)
[ ] T-142-088: Definir tráiler final montado y aprobado
[ ] T-142-089: Definir comunicado de prensa final en 2 idiomas
[ ] T-142-090: Definir kit de medios (capturas HQ, logos, b-roll)
[ ] T-142-091: Definir plan de contenido de redes para día 0 y semana 1
[ ] T-142-092: Definir lista de reviewers/streamers contactados
[ ] T-142-093: Definir verificación de disponibilidad de la página (fecha oculta hasta día 0)
[ ] T-142-094: Definir canales de soporte (foros, Discord, correo) activos
[ ] T-142-095: Definir FAQ publicada (instalación, saves, plataformas, idiomas)
[ ] T-142-096: Definir SLA de respuesta definido (24 h hábiles)
[ ] T-142-097: Definir triaje diario de soporte en lanzamiento
[ ] T-142-098: Definir camino de escalado de bugs de soporte a tracker
[ ] T-142-099: Definir backup de canales (quién cubre a quién)
[ ] T-142-100: Definir cronograma día 0 con horas locales por región
[ ] T-142-101: Definir responsables de cada tarea del día 0
[ ] T-142-102: Definir runbook de incidentes (crash masivo, store caída, cloud)
[ ] T-142-103: Definir holgura de 48 h ante imprevistos
[ ] T-142-104: Definir aprobación final del plan por el equipo
[ ] T-142-105: Definir verificación de accesos de plataforma (quién puede publicar)
[ ] T-142-106: Definir respaldo de credenciales sin compartir secretos en repo
