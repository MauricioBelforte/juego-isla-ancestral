**Modelo:** Devin
**Plataforma:** Antigravity
**Fecha:** 2026-08-16 21:30:00

# Log 29 — Creación del Componente 122: Crash Reporting

## Descripción breve
Se documentó el módulo M122 de Crash Reporting especificando sistema de crash reporting con Crashlytics/Sentry, recolección de metadata, sanitización de contexto, caché offline, dashboard de estadísticas, alertas automáticas e integraciones con M103 (Logging), M102 (Bug Tracking) y M110 (Debug Menu).

## Archivos creados

### DOCUMENTACION/122-Crash-Reporting/plan-inicial/
- `01-Requerimientos.md` — Requisitos funcionales (15), no funcionales, criterios de aceptación
- `02-Analisis.md` — Análisis de 15 puntos del plan maestro, alternativas de crash reporter, metadata, contexto seguro, agrupación, priorización, workflow, builds de diagnóstico, integraciones, opt-out, offline mode, performance, dashboard, alertas, retención de datos, testing
- `03-Diseno.md` — Arquitectura del módulo, CrashReporter, MetadataCollector, ContextSanitizer, CrashCache, CrashSender, CrashDashboard, integraciones, configuración, diagrama de flujo, priorización, builds de diagnóstico, alertas
- `04-Codigo.md` — Archivos involucrados, contratos de integración, esqueletos de código, pendientes con dueño
- `05-Checklist.md` — Checklist de 335 ítems (especificación, alternativas, metadata, contexto seguro, agrupación, priorización, workflow, builds de diagnóstico, integraciones, opt-out, offline mode, performance, dashboard, alertas, retención de datos, testing, CrashReporter, MetadataCollector, ContextSanitizer, CrashCache, CrashSender, CrashDashboard, CrashLogging, CrashBugTracking, CrashDebugMenu, CrashAlerts, configuración, plan de testings)

### DOCUMENTACION/122-Crash-Reporting/plan-actual/
- Copia de los 5 archivos desde plan-inicial

## Cambios colaterales

### CHECKLIST-GLOBAL.md
- Actualizada fila de M122 a `🟢 Disponible` con progreso `335/335`
- Nota: resumen de decisiones clave (Crashlytics/Sentry, metadata, contexto seguro, offline mode, dashboard, alertas, integraciones)

### DOCUMENTACION/README.md
- Actualizado árbol de carpetas: agregado `122-Crash-Reporting/`
- **PENDIENTE:** Actualizar tabla de componentes (error de coincidencia de texto en README)

### Logs/ULTIMO_NUMERO.txt
- Actualizado de `25` a `26`

## Decisiones clave

1. **Crashlytics (Firebase) como servicio externo:** Se seleccionó Crashlytics como opción principal, con Sentry como fallback y implementación propia como último recurso. Crashlytics es gratis para uso moderado, tiene integración nativa con Godot, dashboard potente y agrupación automática de crashes.

2. **Metadata del sistema:** Se diseñó recolección de información de hardware (OS, arquitectura, CPU, GPU, RAM), software (versión del juego, versión de Godot, modo de ejecución, escena activa) y contexto del juego (hora, estación, posición del jugador, seed del mundo).

3. **Contexto seguro:** Se diseñó sanitización de contexto para no enviar datos personales (PII). Se definió lista de unsafe keys (username, ip, email, phone, address, inventory, chat, api_key, token) y solo se envían datos anonimizados (categorías, tipos).

4. **Agrupación de crashes:** Se diseñó agrupación por stack trace hashing, tipo de error, escena activa y versión del juego. Esto permite identificar crashes recurrentes y priorizar correcciones.

5. **Priorización de crashes:** Se diseñó matriz de prioridad basada en frecuencia (alta >5%, media 1-5%, baja <1%), severidad (crash vs hang) e impacto (todos vs algunos usuarios). Prioridades: CRÍTICA, ALTA, MEDIA, BAJA.

6. **Workflow de corrección de crashes:** Se diseñó workflow de 6 pasos: identificar → reproducir → corregir → testear → desplegar → verificar. Integración con M102 (Bug Tracking) para crear issues automáticamente por crashes críticos.

7. **Builds de diagnóstico:** Se diseñaron builds especiales con logs adicionales (M103), asserts no eliminados (debug mode), símbolos de debug para stack traces detallados, profiling habilitado (M61) y crash reporter en modo verbose.

8. **Integración con M103 (Logging):** Se diseñó log de crash en Logging service marcado como CRITICAL, con contenido JSON (stack trace, metadata, contexto) para parseo automático.

9. **Integración con M102 (Bug Tracking):** Se diseñó creación automática de issue en GitHub por crash crítico, con plantilla que incluye stack trace, metadata, contexto, frecuencia y prioridad.

10. **Integración con M110 (Debug Menu):** Se diseñó panel de "Diagnostics" en Debug Menu con botón "Test Crash" para testear crash reporter, botón "Send Crash Report" para envío manual y visualización de metadata del sistema.

11. **Opt-out del usuario:** Se diseñaron opciones de opt-out (checkbox en configuración inicial, checkbox en settings, botón "No enviar" al primer crash) y cumplimiento GDPR (consentimiento explícito, opción de opt-out en cualquier momento, datos anonimizados, política de privacidad accesible).

12. **Offline mode:** Se diseñó caché de crashes para cuando no hay conexión (guardado local en user://crash_cache.json, envío automático al reconectar, límite de 10 crashes, descarte de crash más antiguo si caché llena).

13. **Performance impact:** Se diseñó crash reporter ligero (no impactar FPS), envío de crash en background, no envío de datos en tiempo real (batch), compresión de datos antes de envío.

14. **Dashboard de estadísticas:** Se diseñó CrashDashboard con métricas (crashes por versión, plataforma, escena, frecuencia por 1000 usuarios, tasa de corrección), visualización (gráficos de tendencia, tablas, filtros, exportación CSV).

15. **Alertas automáticas:** Se diseñó CrashAlerts con alertas automáticas cuando crash crítico supera umbral (5% de usuarios) o cuando crash nueva de alta frecuencia (>100 usuarios en 24h), con notificación por email/Slack a equipo de desarrollo.

16. **Retención de datos:** Se especificó política de retención (crashes retenidos por 90 días, crash metadata anonimizada, logs de crash retenidos por 30 días, cumplimiento GDPR).

17. **Testing de crash reporter:** Se diseñaron tests manuales (test crash con "Test Crash" en Debug Menu, verificación de envío, metadata, contexto seguro, opt-out, offline mode) y tests automáticos (mock de crash reporter, tests de sanitización, tests de agrupación).

18. **CrashReporter (servicio principal):** Se diseñó CrashReporter.gd con métodos capture_crash(), _collect_metadata(), _sanitize_context(), _send_crash(), _save_to_cache(), _has_connection() y signals crash_sent, crash_saved_to_cache.

19. **MetadataCollector:** Se diseñó MetadataCollector.gd con métodos collect_hardware_metadata(), collect_software_metadata(), collect_game_context() para recolectar información de hardware, software y contexto del juego.

20. **ContextSanitizer:** Se diseñó ContextSanitizer.gd con método sanitize() y _is_unsafe_key() para sanitizar contexto y no enviar datos personales.

21. **CrashCache:** Se diseñó CrashCache.gd con métodos save_crash(), load_cached_crashes(), clear_cache(), _load_cache(), _save_cache() para caché offline.

22. **CrashSender:** Se diseñó CrashSender.gd con métodos send_crash(), send_cached_crashes(), has_connection() para enviar crashes a servicio externo.

23. **CrashDashboard:** Se diseñó CrashDashboard.gd con métodos load_crashes(), _display_crashes(), _display_crash_chart(), _fetch_crashes_from_service() para visualizar crashes y estadísticas.

24. **CrashLogging (integración M103):** Se diseñó CrashLogging.gd con método log_crash() para loggear crashes en Logging service marcados como CRITICAL.

25. **CrashBugTracking (integración M102):** Se diseñó CrashBugTracking.gd con métodos create_issue_for_crash(), _format_issue_body(), _create_github_issue() para crear issues automáticamente por crashes críticos.

26. **CrashDebugMenu (integración M110):** Se diseñó CrashDebugMenu.gd con métodos add_diagnostics_panel(), _on_test_crash(), _on_send_crash_report(), _format_metadata() para agregar panel de "Diagnostics" en Debug Menu.

27. **CrashAlerts:** Se diseñó CrashAlerts.gd con métodos check_alerts(), _send_alert() para alertas automáticas por Slack webhook.

28. **Configuración:** Se diseñó sección crash_reporting en project.gd con configuraciones enabled, service, api_key, opt_out_allowed, anonymous_only, cache_enabled, cache_max_size.

## Resumen de la tanda

| Módulo | ID | Estado | Progreso |
|--------|----|---------|----------|
| Bug Tracking | 102 | 🟢 Disponible | 121/121 |
| Logging | 103 | 🟢 Disponible | 134/134 |
| Backups | 107 | 🟢 Disponible | 137/137 |
| Debug Menu | 110 | 🟢 Disponible | 138/138 |
| Código de Calidad | 111 | 🟢 Disponible | 248/248 |
| Crash Reporting | 122 | 🟢 Disponible | 335/335 |

**Total de módulos completados en Tanda A:** 6/10
**Próximo módulo:** M152 Principios Innegociables
