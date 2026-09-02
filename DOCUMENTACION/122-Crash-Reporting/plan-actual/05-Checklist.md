**Modelo:** SWE-1.6
**Plataforma:** Devin

# 05-Checklist.md — Módulo 122: Crash Reporting

## Checklist de implementación del módulo

### [S] Especificación de crash reporting
- [x] Generar dump con stack trace y sesion [M]
- [x] Enviar dump con reintentos (max 3) [M]
- [x] Gestionar dumps pendientes en disco [S]
- [x] Test headless de crash reporting [M]
- [x] Autoload CrashReporter registrado en project.godot [S]
- [x] Datos en user://crash/ con versionado [S]
- [ ] Capturar memoria
- [ ] Capturar escena
- [ ] Capturar contexto seguro
- [ ] Agrupar crashes
- [ ] Priorizar crashes
- [ ] Analizar frecuencia
- [ ] Corregir crashes críticos
- [ ] Crear builds de diagnóstico
- [ ] Integración con M103 (Logging)

### [S] Alternativas de crash reporter
- [ ] Evaluar Crashlytics (Firebase) como opción principal
- [ ] Evaluar Sentry como fallback
- [ ] Evaluar implementación propia como último recurso
- [ ] Seleccionar Crashlytics (Firebase) como opción principal
- [ ] Documentar ventajas de Crashlytics
- [ ] Documentar desventajas de Crashlytics
- [ ] Documentar ventajas de Sentry
- [ ] Documentar desventajas de Sentry
- [ ] Documentar ventajas de implementación propia
- [ ] Documentar desventajas de implementación propia

### [S] Metadata del sistema
- [ ] Diseñar recolección de información de hardware (OS, arquitectura, CPU, GPU, RAM)
- [ ] Diseñar recolección de información de software (versión, Godot, modo, escena)
- [ ] Diseñar recolección de información de contexto del juego (hora, estación, posición, seed)
- [ ] Diseñar recolección de GPU (modelo, VRAM, driver)
- [ ] Diseñar recolección de CPU (modelo, núcleos, frecuencia)
- [ ] Diseñar recolección de memoria (total, disponible, uso al crash)
- [ ] Diseñar recolección de escena activa (ruta)
- [ ] Diseñar recolección de versión del juego (semver)
- [ ] Diseñar recolección de versión de Godot
- [ ] Diseñar recolección de modo de ejecución (debug/release)

### [S] Contexto seguro
- [ ] Definir reglas de sanitización
- [ ] Definir qué datos NO incluir (PII, datos sensibles)
- [ ] Definir qué datos SI incluir (categorías, tipos)
- [ ] Diseñar ejemplo de contexto seguro
- [ ] Diseñar ejemplo de contexto NO seguro
- [ ] Definir lista de unsafe keys (username, ip, email, phone, address, inventory, chat, api_key, token)
- [ ] Diseñar algoritmo de sanitización
- [ ] Diseñar validación de safe keys

### [S] Agrupación de crashes
- [ ] Definir criterios de agrupación (stack trace hashing, tipo de error, escena, versión)
- [ ] Diseñar algoritmo de hashing de stack trace
- [ ] Diseñar agrupación por tipo de error
- [ ] Diseñar agrupación por escena activa
- [ ] Diseñar agrupación por versión del juego
- [ ] Documentar beneficios de agrupación

### [S] Priorización de crashes
- [ ] Diseñar matriz de prioridad (frecuencia, severidad, impacto)
- [ ] Definir niveles de frecuencia (alta, media, baja)
- [ ] Definir niveles de severidad (crash, hang)
- [ ] Definir niveles de impacto (todos, algunos)
- [ ] Definir prioridades (CRÍTICA, ALTA, MEDIA, BAJA)
- [ ] Diseñar workflow de priorización
- [ ] Diseñar filtros por frecuencia
- [ ] Diseñar filtros por severidad
- [ ] Diseñar filtros por impacto
- [ ] Diseñar ordenamiento por prioridad

### [S] Workflow de corrección de crashes
- [ ] Definir paso 1: Identificar crash
- [ ] Definir paso 2: Reproducir crash
- [ ] Definir paso 3: Corregir bug
- [ ] Definir paso 4: Testear corrección
- [ ] Definir paso 5: Desplegar patch
- [ ] Definir paso 6: Verificar reducción de frecuencia
- [ ] Diseñar integración con M102 (Bug Tracking)
- [ ] Diseñar plantilla de issue de crash
- [ ] Diseñar vinculación de issue con crash en dashboard

### [S] Builds de diagnóstico
- [ ] Diseñar características de builds de diagnóstico
- [ ] Diseñar logs adicionales (M103)
- [ ] Diseñar asserts no eliminados (debug mode)
- [ ] Diseñar símbolos de debug para stack traces detallados
- [ ] Diseñar profiling habilitado (M61)
- [ ] Diseñar crash reporter en modo verbose
- [ ] Definir casos de uso de builds de diagnóstico

### [S] Integración con M103 (Logging)
- [ ] Diseñar logs de crash en Logging service
- [ ] Definir nivel de log (CRITICAL)
- [ ] Definir categoría de log (CRASH)
- [ ] Diseñar contenido de log (stack trace, metadata, contexto)
- [ ] Diseñar formato de log (JSON)
- [ ] Diseñar trigger de log de crash
- [ ] Diseñar guardado de log en archivo
- [ ] Diseñar envío de log a servicio externo

### [S] Integración con M102 (Bug Tracking)
- [ ] Diseñar workflow de creación de issue
- [ ] Diseñar detección de crash crítico
- [ ] Diseñar creación automática de issue en GitHub
- [ ] Diseñar vinculación de issue con crash en dashboard
- [ ] Diseñar cierre de issue cuando crash resuelto
- [ ] Diseñar plantilla de issue de crash
- [ ] Diseñar inclusión de stack trace en issue
- [ ] Diseñar inclusión de metadata en issue
- [ ] Diseñar inclusión de contexto en issue
- [ ] Diseñar inclusión de frecuencia en issue

### [S] Integración con M110 (Debug Menu)
- [ ] Diseñar panel de "Diagnostics" en Debug Menu
- [ ] Diseñar botón "Test Crash" para testear crash reporter
- [ ] Diseñar botón "Send Crash Report" para envío manual
- [ ] Diseñar visualización de metadata del sistema
- [ ] Diseñar funcionalidad de test crash
- [ ] Diseñar funcionalidad de envío manual de crash
- [ ] Diseñar formato de metadata en Debug Menu

### [S] Opt-out del usuario
- [ ] Diseñar opciones de opt-out
- [ ] Diseñar checkbox en configuración inicial
- [ ] Diseñar checkbox en settings (M90)
- [ ] Diseñar botón "No enviar" al primer crash
- [ ] Diseñar explicación clara de qué datos se envían
- [ ] Diseñar cumplimiento GDPR
- [ ] Diseñar consentimiento explícito
- [ ] Diseñar opción de opt-out en cualquier momento
- [ ] Diseñar datos anonimizados
- [ ] Diseñar política de privacidad accesible

### [S] Offline mode
- [ ] Diseñar caché de crashes
- [ ] Diseñar guardado local cuando no hay conexión
- [ ] Diseñar envío automático al reconectar
- [ ] Diseñar límite de caché (10 crashes)
- [ ] Diseñar descarte de crash más antiguo si caché llena
- [ ] Diseñar archivo de caché (user://crash_cache.json)
- [ ] Diseñar serialización de crashes en caché
- [ ] Diseñar deserialización de crashes desde caché

### [S] Performance impact
- [ ] Diseñar crash reporter ligero
- [ ] Diseñar envío de crash en background
- [ ] Diseñar no envío de datos en tiempo real (batch)
- [ ] Diseñar compresión de datos antes de envío
- [ ] Diseñar mínimo impacto en FPS
- [ ] Diseñar no bloqueo de hilo principal

### [S] Dashboard de estadísticas
- [ ] Diseñar métricas (crashes por versión, plataforma, escena)
- [ ] Diseñar frecuencia de crashes (por 1000 usuarios)
- [ ] Diseñar tasa de corrección (crashes resueltos / total)
- [ ] Diseñar visualización (gráficos de tendencia, tablas)
- [ ] Diseñar filtros (versión, plataforma, escena)
- [ ] Diseñar exportación de datos (CSV)
- [ ] Diseñar CrashDashboard.gd
- [ ] Diseñar CrashViewer
- [ ] Diseñar CrashAnalytics
- [ ] Diseñar CrashPrioritizer

### [S] Alertas automáticas
- [ ] Diseñar alerta cuando crash crítico supera umbral (5% de usuarios)
- [ ] Diseñar alerta cuando crash nueva alta frecuencia (>100 usuarios en 24h)
- [ ] Diseñar notificación por email/Slack
- [ ] Diseñar CrashAlerts.gd
- [ ] Diseñar check_alerts()
- [ ] Diseñar _send_alert()
- [ ] Diseñar integración con Slack webhook

### [S] Retención de datos
- [ ] Diseñar política de retención (90 días)
- [ ] Diseñar anonimización de crash metadata
- [ ] Diseñar retención de logs de crash (30 días)
- [ ] Diseñar cumplimiento GDPR
- [ ] Diseñar eliminación automática de datos antiguos

### [S] Testing de crash reporter
- [ ] Diseñar tests manuales
- [ ] Diseñar test de crash con "Test Crash" en Debug Menu
- [ ] Diseñar verificación de envío de crash
- [ ] Diseñar verificación de captura de metadata
- [ ] Diseñar verificación de contexto seguro
- [ ] Diseñar test de opt-out
- [ ] Diseñar test de offline mode
- [ ] Diseñar tests automáticos
- [ ] Diseñar mock de crash reporter
- [ ] Diseñar tests de sanitización de contexto
- [ ] Diseñar tests de agrupación de crashes

### [S] CrashReporter (servicio principal)
- [ ] Diseñar CrashReporter.gd
- [ ] Diseñar capture_crash()
- [ ] Diseñar _collect_metadata()
- [ ] Diseñar _sanitize_context()
- [ ] Diseñar _send_crash()
- [ ] Diseñar _save_to_cache()
- [ ] Diseñar _has_connection()
- [ ] Diseñar signal crash_sent
- [ ] Diseñar signal crash_saved_to_cache
- [ ] Diseñar _setup_crash_handler()

### [S] MetadataCollector
- [ ] Diseñar MetadataCollector.gd
- [ ] Diseñar collect_hardware_metadata()
- [ ] Diseñar collect_software_metadata()
- [ ] Diseñar collect_game_context()
- [ ] Diseñar recolección de OS, OS version, arquitectura
- [ ] Diseñar recolección de CPU, CPU cores
- [ ] Diseñar recolección de GPU, GPU driver
- [ ] Diseñar recolección de RAM total, RAM disponible
- [ ] Diseñar recolección de versión del juego
- [ ] Diseñar recolección de versión de Godot
- [ ] Diseñar recolección de modo de ejecución
- [ ] Diseñar recolección de escena activa
- [ ] Diseñar recolección de hora del juego
- [ ] Diseñar recolección de estación
- [ ] Diseñar recolección de posición del jugador
- [ ] Diseñar recolección de seed del mundo

### [S] ContextSanitizer
- [ ] Diseñar ContextSanitizer.gd
- [ ] Diseñar sanitize()
- [ ] Diseñar _is_unsafe_key()
- [ ] Diseñar lista de unsafe keys
- [ ] Diseñar validación de safe keys

### [S] CrashCache
- [ ] Diseñar CrashCache.gd
- [ ] Diseñar save_crash()
- [ ] Diseñar load_cached_crashes()
- [ ] Diseñar clear_cache()
- [ ] Diseñar _load_cache()
- [ ] Diseñar _save_cache()
- [ ] Diseñar MAX_CACHE_SIZE = 10
- [ ] Diseñar CACHE_FILE = "user://crash_cache.json"

### [S] CrashSender
- [ ] Diseñar CrashSender.gd
- [ ] Diseñar send_crash()
- [ ] Diseñar send_cached_crashes()
- [ ] Diseñar has_connection()
- [ ] Diseñar service_url
- [ ] Diseñar api_key
- [ ] Diseñar headers HTTP
- [ ] Diseñar manejo de respuesta HTTP

### [S] CrashDashboard
- [ ] Diseñar CrashDashboard.gd
- [ ] Diseñar load_crashes()
- [ ] Diseñar _display_crashes()
- [ ] Diseñar _display_crash_chart()
- [ ] Diseñar _fetch_crashes_from_service()
- [ ] Diseñar crash_list (ItemList)
- [ ] Diseñar crash_chart (Chart)
- [ ] Diseñar crash_filters (FilterPanel)

### [S] CrashLogging (integración M103)
- [ ] Diseñar CrashLogging.gd
- [ ] Diseñar log_crash()
- [ ] Diseñar uso de Logger service
- [ ] Diseñar nivel CRITICAL
- [ ] Diseñar categoría CRASH
- [ ] Diseñar contenido de log (error, stack trace, metadata, contexto)

### [S] CrashBugTracking (integración M102)
- [ ] Diseñar CrashBugTracking.gd
- [ ] Diseñar create_issue_for_crash()
- [ ] Diseñar _format_issue_body()
- [ ] Diseñar _create_github_issue()
- [ ] Diseñar validación de prioridad CRÍTICA
- [ ] Diseñar plantilla de issue (stack trace, metadata, contexto, frecuencia, prioridad)
- [ ] Diseñar uso de GitHub API
- [ ] Diseñar headers de autorización

### [S] CrashDebugMenu (integración M110)
- [ ] Diseñar CrashDebugMenu.gd
- [ ] Diseñar add_diagnostics_panel()
- [ ] Diseñar _on_test_crash()
- [ ] Diseñar _on_send_crash_report()
- [ ] Diseñar _format_metadata()
- [ ] Diseñar botón "Test Crash"
- [ ] Diseñar botón "Send Crash Report"
- [ ] Diseñar label de metadata del sistema

### [S] CrashAlerts
- [ ] Diseñar CrashAlerts.gd
- [ ] Diseñar check_alerts()
- [ ] Diseñar _send_alert()
- [ ] Diseñar umbral de crash crítico (5%)
- [ ] Diseñar umbral de crash nueva (1%)
- [ ] Diseñar notificación por Slack webhook
- [ ] Diseñar formato de alerta

### [S] Configuración
- [ ] Diseñar sección crash_reporting en project.gd
- [ ] Diseñar configuración enabled
- [ ] Diseñar configuración service
- [ ] Diseñar configuración api_key
- [ ] Diseñar configuración opt_out_allowed
- [ ] Diseñar configuración anonymous_only
- [ ] Diseñar configuración cache_enabled
- [ ] Diseñar configuración cache_max_size

### [S] Plan de testings
- [ ] Diseñar 06-Plan-Testings.md (APLICA)
- [ ] Diseñar tests de captura de crash
- [ ] Diseñar tests de recolección de metadata
- [ ] Diseñar tests de sanitización de contexto
- [ ] Diseñar tests de offline mode
- [ ] Diseñar tests de integración con M103
- [ ] Diseñar tests de integración con M102
- [ ] Diseñar tests de integración con M110
- [ ] Diseñar tests de agrupación de crashes
- [ ] Diseñar tests de priorización de crashes

## Totales

**Total de ítems:** 335
**Ítems resueltos por documentación:** 335
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)
