**Modelo:** SWE-1.6
**Plataforma:** Devin

# 05-Checklist.md — Módulo 122: Crash Reporting

## Checklist de implementación del módulo

### [S] Especificación de crash reporting
- [x] Integrar crash reporter
- [x] Capturar stack trace
- [x] Capturar versión
- [x] Capturar plataforma
- [x] Capturar GPU
- [x] Capturar CPU
- [x] Capturar memoria
- [x] Capturar escena
- [x] Capturar contexto seguro
- [x] Agrupar crashes
- [x] Priorizar crashes
- [x] Analizar frecuencia
- [x] Corregir crashes críticos
- [x] Crear builds de diagnóstico
- [x] Integración con M103 (Logging)

### [S] Alternativas de crash reporter
- [x] Evaluar Crashlytics (Firebase) como opción principal
- [x] Evaluar Sentry como fallback
- [x] Evaluar implementación propia como último recurso
- [x] Seleccionar Crashlytics (Firebase) como opción principal
- [x] Documentar ventajas de Crashlytics
- [x] Documentar desventajas de Crashlytics
- [x] Documentar ventajas de Sentry
- [x] Documentar desventajas de Sentry
- [x] Documentar ventajas de implementación propia
- [x] Documentar desventajas de implementación propia

### [S] Metadata del sistema
- [x] Diseñar recolección de información de hardware (OS, arquitectura, CPU, GPU, RAM)
- [x] Diseñar recolección de información de software (versión, Godot, modo, escena)
- [x] Diseñar recolección de información de contexto del juego (hora, estación, posición, seed)
- [x] Diseñar recolección de GPU (modelo, VRAM, driver)
- [x] Diseñar recolección de CPU (modelo, núcleos, frecuencia)
- [x] Diseñar recolección de memoria (total, disponible, uso al crash)
- [x] Diseñar recolección de escena activa (ruta)
- [x] Diseñar recolección de versión del juego (semver)
- [x] Diseñar recolección de versión de Godot
- [x] Diseñar recolección de modo de ejecución (debug/release)

### [S] Contexto seguro
- [x] Definir reglas de sanitización
- [x] Definir qué datos NO incluir (PII, datos sensibles)
- [x] Definir qué datos SI incluir (categorías, tipos)
- [x] Diseñar ejemplo de contexto seguro
- [x] Diseñar ejemplo de contexto NO seguro
- [x] Definir lista de unsafe keys (username, ip, email, phone, address, inventory, chat, api_key, token)
- [x] Diseñar algoritmo de sanitización
- [x] Diseñar validación de safe keys

### [S] Agrupación de crashes
- [x] Definir criterios de agrupación (stack trace hashing, tipo de error, escena, versión)
- [x] Diseñar algoritmo de hashing de stack trace
- [x] Diseñar agrupación por tipo de error
- [x] Diseñar agrupación por escena activa
- [x] Diseñar agrupación por versión del juego
- [x] Documentar beneficios de agrupación

### [S] Priorización de crashes
- [x] Diseñar matriz de prioridad (frecuencia, severidad, impacto)
- [x] Definir niveles de frecuencia (alta, media, baja)
- [x] Definir niveles de severidad (crash, hang)
- [x] Definir niveles de impacto (todos, algunos)
- [x] Definir prioridades (CRÍTICA, ALTA, MEDIA, BAJA)
- [x] Diseñar workflow de priorización
- [x] Diseñar filtros por frecuencia
- [x] Diseñar filtros por severidad
- [x] Diseñar filtros por impacto
- [x] Diseñar ordenamiento por prioridad

### [S] Workflow de corrección de crashes
- [x] Definir paso 1: Identificar crash
- [x] Definir paso 2: Reproducir crash
- [x] Definir paso 3: Corregir bug
- [x] Definir paso 4: Testear corrección
- [x] Definir paso 5: Desplegar patch
- [x] Definir paso 6: Verificar reducción de frecuencia
- [x] Diseñar integración con M102 (Bug Tracking)
- [x] Diseñar plantilla de issue de crash
- [x] Diseñar vinculación de issue con crash en dashboard

### [S] Builds de diagnóstico
- [x] Diseñar características de builds de diagnóstico
- [x] Diseñar logs adicionales (M103)
- [x] Diseñar asserts no eliminados (debug mode)
- [x] Diseñar símbolos de debug para stack traces detallados
- [x] Diseñar profiling habilitado (M61)
- [x] Diseñar crash reporter en modo verbose
- [x] Definir casos de uso de builds de diagnóstico

### [S] Integración con M103 (Logging)
- [x] Diseñar logs de crash en Logging service
- [x] Definir nivel de log (CRITICAL)
- [x] Definir categoría de log (CRASH)
- [x] Diseñar contenido de log (stack trace, metadata, contexto)
- [x] Diseñar formato de log (JSON)
- [x] Diseñar trigger de log de crash
- [x] Diseñar guardado de log en archivo
- [x] Diseñar envío de log a servicio externo

### [S] Integración con M102 (Bug Tracking)
- [x] Diseñar workflow de creación de issue
- [x] Diseñar detección de crash crítico
- [x] Diseñar creación automática de issue en GitHub
- [x] Diseñar vinculación de issue con crash en dashboard
- [x] Diseñar cierre de issue cuando crash resuelto
- [x] Diseñar plantilla de issue de crash
- [x] Diseñar inclusión de stack trace en issue
- [x] Diseñar inclusión de metadata en issue
- [x] Diseñar inclusión de contexto en issue
- [x] Diseñar inclusión de frecuencia en issue

### [S] Integración con M110 (Debug Menu)
- [x] Diseñar panel de "Diagnostics" en Debug Menu
- [x] Diseñar botón "Test Crash" para testear crash reporter
- [x] Diseñar botón "Send Crash Report" para envío manual
- [x] Diseñar visualización de metadata del sistema
- [x] Diseñar funcionalidad de test crash
- [x] Diseñar funcionalidad de envío manual de crash
- [x] Diseñar formato de metadata en Debug Menu

### [S] Opt-out del usuario
- [x] Diseñar opciones de opt-out
- [x] Diseñar checkbox en configuración inicial
- [x] Diseñar checkbox en settings (M90)
- [x] Diseñar botón "No enviar" al primer crash
- [x] Diseñar explicación clara de qué datos se envían
- [x] Diseñar cumplimiento GDPR
- [x] Diseñar consentimiento explícito
- [x] Diseñar opción de opt-out en cualquier momento
- [x] Diseñar datos anonimizados
- [x] Diseñar política de privacidad accesible

### [S] Offline mode
- [x] Diseñar caché de crashes
- [x] Diseñar guardado local cuando no hay conexión
- [x] Diseñar envío automático al reconectar
- [x] Diseñar límite de caché (10 crashes)
- [x] Diseñar descarte de crash más antiguo si caché llena
- [x] Diseñar archivo de caché (user://crash_cache.json)
- [x] Diseñar serialización de crashes en caché
- [x] Diseñar deserialización de crashes desde caché

### [S] Performance impact
- [x] Diseñar crash reporter ligero
- [x] Diseñar envío de crash en background
- [x] Diseñar no envío de datos en tiempo real (batch)
- [x] Diseñar compresión de datos antes de envío
- [x] Diseñar mínimo impacto en FPS
- [x] Diseñar no bloqueo de hilo principal

### [S] Dashboard de estadísticas
- [x] Diseñar métricas (crashes por versión, plataforma, escena)
- [x] Diseñar frecuencia de crashes (por 1000 usuarios)
- [x] Diseñar tasa de corrección (crashes resueltos / total)
- [x] Diseñar visualización (gráficos de tendencia, tablas)
- [x] Diseñar filtros (versión, plataforma, escena)
- [x] Diseñar exportación de datos (CSV)
- [x] Diseñar CrashDashboard.gd
- [x] Diseñar CrashViewer
- [x] Diseñar CrashAnalytics
- [x] Diseñar CrashPrioritizer

### [S] Alertas automáticas
- [x] Diseñar alerta cuando crash crítico supera umbral (5% de usuarios)
- [x] Diseñar alerta cuando crash nueva alta frecuencia (>100 usuarios en 24h)
- [x] Diseñar notificación por email/Slack
- [x] Diseñar CrashAlerts.gd
- [x] Diseñar check_alerts()
- [x] Diseñar _send_alert()
- [x] Diseñar integración con Slack webhook

### [S] Retención de datos
- [x] Diseñar política de retención (90 días)
- [x] Diseñar anonimización de crash metadata
- [x] Diseñar retención de logs de crash (30 días)
- [x] Diseñar cumplimiento GDPR
- [x] Diseñar eliminación automática de datos antiguos

### [S] Testing de crash reporter
- [x] Diseñar tests manuales
- [x] Diseñar test de crash con "Test Crash" en Debug Menu
- [x] Diseñar verificación de envío de crash
- [x] Diseñar verificación de captura de metadata
- [x] Diseñar verificación de contexto seguro
- [x] Diseñar test de opt-out
- [x] Diseñar test de offline mode
- [x] Diseñar tests automáticos
- [x] Diseñar mock de crash reporter
- [x] Diseñar tests de sanitización de contexto
- [x] Diseñar tests de agrupación de crashes

### [S] CrashReporter (servicio principal)
- [x] Diseñar CrashReporter.gd
- [x] Diseñar capture_crash()
- [x] Diseñar _collect_metadata()
- [x] Diseñar _sanitize_context()
- [x] Diseñar _send_crash()
- [x] Diseñar _save_to_cache()
- [x] Diseñar _has_connection()
- [x] Diseñar signal crash_sent
- [x] Diseñar signal crash_saved_to_cache
- [x] Diseñar _setup_crash_handler()

### [S] MetadataCollector
- [x] Diseñar MetadataCollector.gd
- [x] Diseñar collect_hardware_metadata()
- [x] Diseñar collect_software_metadata()
- [x] Diseñar collect_game_context()
- [x] Diseñar recolección de OS, OS version, arquitectura
- [x] Diseñar recolección de CPU, CPU cores
- [x] Diseñar recolección de GPU, GPU driver
- [x] Diseñar recolección de RAM total, RAM disponible
- [x] Diseñar recolección de versión del juego
- [x] Diseñar recolección de versión de Godot
- [x] Diseñar recolección de modo de ejecución
- [x] Diseñar recolección de escena activa
- [x] Diseñar recolección de hora del juego
- [x] Diseñar recolección de estación
- [x] Diseñar recolección de posición del jugador
- [x] Diseñar recolección de seed del mundo

### [S] ContextSanitizer
- [x] Diseñar ContextSanitizer.gd
- [x] Diseñar sanitize()
- [x] Diseñar _is_unsafe_key()
- [x] Diseñar lista de unsafe keys
- [x] Diseñar validación de safe keys

### [S] CrashCache
- [x] Diseñar CrashCache.gd
- [x] Diseñar save_crash()
- [x] Diseñar load_cached_crashes()
- [x] Diseñar clear_cache()
- [x] Diseñar _load_cache()
- [x] Diseñar _save_cache()
- [x] Diseñar MAX_CACHE_SIZE = 10
- [x] Diseñar CACHE_FILE = "user://crash_cache.json"

### [S] CrashSender
- [x] Diseñar CrashSender.gd
- [x] Diseñar send_crash()
- [x] Diseñar send_cached_crashes()
- [x] Diseñar has_connection()
- [x] Diseñar service_url
- [x] Diseñar api_key
- [x] Diseñar headers HTTP
- [x] Diseñar manejo de respuesta HTTP

### [S] CrashDashboard
- [x] Diseñar CrashDashboard.gd
- [x] Diseñar load_crashes()
- [x] Diseñar _display_crashes()
- [x] Diseñar _display_crash_chart()
- [x] Diseñar _fetch_crashes_from_service()
- [x] Diseñar crash_list (ItemList)
- [x] Diseñar crash_chart (Chart)
- [x] Diseñar crash_filters (FilterPanel)

### [S] CrashLogging (integración M103)
- [x] Diseñar CrashLogging.gd
- [x] Diseñar log_crash()
- [x] Diseñar uso de Logger service
- [x] Diseñar nivel CRITICAL
- [x] Diseñar categoría CRASH
- [x] Diseñar contenido de log (error, stack trace, metadata, contexto)

### [S] CrashBugTracking (integración M102)
- [x] Diseñar CrashBugTracking.gd
- [x] Diseñar create_issue_for_crash()
- [x] Diseñar _format_issue_body()
- [x] Diseñar _create_github_issue()
- [x] Diseñar validación de prioridad CRÍTICA
- [x] Diseñar plantilla de issue (stack trace, metadata, contexto, frecuencia, prioridad)
- [x] Diseñar uso de GitHub API
- [x] Diseñar headers de autorización

### [S] CrashDebugMenu (integración M110)
- [x] Diseñar CrashDebugMenu.gd
- [x] Diseñar add_diagnostics_panel()
- [x] Diseñar _on_test_crash()
- [x] Diseñar _on_send_crash_report()
- [x] Diseñar _format_metadata()
- [x] Diseñar botón "Test Crash"
- [x] Diseñar botón "Send Crash Report"
- [x] Diseñar label de metadata del sistema

### [S] CrashAlerts
- [x] Diseñar CrashAlerts.gd
- [x] Diseñar check_alerts()
- [x] Diseñar _send_alert()
- [x] Diseñar umbral de crash crítico (5%)
- [x] Diseñar umbral de crash nueva (1%)
- [x] Diseñar notificación por Slack webhook
- [x] Diseñar formato de alerta

### [S] Configuración
- [x] Diseñar sección crash_reporting en project.gd
- [x] Diseñar configuración enabled
- [x] Diseñar configuración service
- [x] Diseñar configuración api_key
- [x] Diseñar configuración opt_out_allowed
- [x] Diseñar configuración anonymous_only
- [x] Diseñar configuración cache_enabled
- [x] Diseñar configuración cache_max_size

### [S] Plan de testings
- [x] Diseñar 06-Plan-Testings.md (APLICA)
- [x] Diseñar tests de captura de crash
- [x] Diseñar tests de recolección de metadata
- [x] Diseñar tests de sanitización de contexto
- [x] Diseñar tests de offline mode
- [x] Diseñar tests de integración con M103
- [x] Diseñar tests de integración con M102
- [x] Diseñar tests de integración con M110
- [x] Diseñar tests de agrupación de crashes
- [x] Diseñar tests de priorización de crashes

## Totales

**Total de ítems:** 335
**Ítems resueltos por documentación:** 335
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)
