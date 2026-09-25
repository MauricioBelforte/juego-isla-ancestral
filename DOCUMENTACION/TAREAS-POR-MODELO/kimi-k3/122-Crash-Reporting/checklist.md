**Modelo:** kimi-k3 (Moonshot AI)
**Plataforma:** Kilo Code
**Modulo:** 122-Crash-Reporting
**Fuente:** `DOCUMENTACION/122-Crash-Reporting/plan-actual/05-Checklist.md` (fuente de verdad)
**Total:** 80 tareas (80 pendientes + 0 con dudas)

## Reglas
- Marcar `[x]` SOLO con evidencia (log + test headless rc=0 o verificacion binario real).
- `[?]` = no resuelto, con razon y dueno. `[→]` = movida a otro modelo.
- Al completar T-###: actualizar tambien el `05-Checklist.md` del modulo y la fila de CHECKLIST-GLOBAL.
- Reservar log: `python scripts/reservar_log.py --reservar --agente kimi-k3 --modulo 122`.

## Tareas

- [ ] T-001 Capturar memoria
- [ ] T-002 Capturar escena
- [ ] T-003 Capturar contexto seguro
- [ ] T-004 Evaluar Sentry como fallback
- [ ] T-005 Documentar ventajas de Sentry
- [ ] T-006 Documentar desventajas de Sentry
- [ ] T-007 Definir qué datos NO incluir (PII, datos sensibles)
- [ ] T-008 Definir qué datos SI incluir (categorías, tipos)
- [ ] T-009 Diseñar ejemplo de contexto seguro
- [ ] T-010 Diseñar ejemplo de contexto NO seguro
- [ ] T-011 Definir lista de unsafe keys (username, ip, email, phone, address, inventory, chat, api_key, token)
- [ ] T-012 Diseñar algoritmo de hashing de stack trace
- [ ] T-013 Definir niveles de impacto (todos, algunos)
- [ ] T-014 Definir prioridades (CRÍTICA, ALTA, MEDIA, BAJA)
- [ ] T-015 Diseñar filtros por severidad
- [ ] T-016 Diseñar filtros por impacto
- [ ] T-017 Diseñar ordenamiento por prioridad
- [ ] T-018 Definir paso 3: Corregir bug
- [ ] T-019 Definir paso 5: Desplegar patch
- [ ] T-020 Diseñar asserts no eliminados (debug mode)
- [ ] T-021 Diseñar símbolos de debug para stack traces detallados
- [ ] T-022 Diseñar profiling habilitado (M61)
- [ ] T-023 Definir nivel de log (CRITICAL)
- [ ] T-024 Diseñar contenido de log (stack trace, metadata, contexto)
- [ ] T-025 Diseñar guardado de log en archivo
- [ ] T-026 Diseñar inclusión de stack trace en issue
- [ ] T-027 Diseñar inclusión de metadata en issue
- [ ] T-028 Diseñar inclusión de contexto en issue
- [ ] T-029 Diseñar panel de "Diagnostics" en Debug Menu
- [ ] T-030 Diseñar formato de metadata en Debug Menu
- [ ] T-031 Diseñar checkbox en settings (M90)
- [ ] T-032 Diseñar cumplimiento GDPR
- [ ] T-033 Diseñar datos anonimizados
- [ ] T-034 Diseñar guardado local cuando no hay conexión
- [ ] T-035 Diseñar envío automático al reconectar
- [ ] T-036 Diseñar no envío de datos en tiempo real (batch)
- [ ] T-037 Diseñar compresión de datos antes de envío
- [ ] T-038 Diseñar mínimo impacto en FPS
- [ ] T-039 Diseñar filtros (versión, plataforma, escena)
- [ ] T-040 Diseñar check_alerts()
- [ ] T-041 Diseñar _send_alert()
- [ ] T-042 Diseñar cumplimiento GDPR
- [ ] T-043 Diseñar tests manuales
- [ ] T-044 Diseñar test de opt-out
- [ ] T-045 Diseñar test de offline mode
- [ ] T-046 Diseñar tests automáticos
- [ ] T-047 Diseñar _collect_metadata()
- [ ] T-048 Diseñar _sanitize_context()
- [ ] T-049 Diseñar _save_to_cache()
- [ ] T-050 Diseñar _has_connection()
- [ ] T-051 Diseñar MetadataCollector.gd
- [ ] T-052 Diseñar collect_hardware_metadata()
- [ ] T-053 Diseñar collect_software_metadata()
- [ ] T-054 Diseñar collect_game_context()
- [ ] T-055 Diseñar ContextSanitizer.gd
- [ ] T-056 Diseñar sanitize()
- [ ] T-057 Diseñar _is_unsafe_key()
- [ ] T-058 Diseñar lista de unsafe keys
- [ ] T-059 Diseñar clear_cache()
- [ ] T-060 Diseñar _load_cache()
- [ ] T-061 Diseñar _save_cache()
- [ ] T-062 Diseñar MAX_CACHE_SIZE = 10
- [ ] T-063 Diseñar has_connection()
- [ ] T-064 Diseñar api_key
- [ ] T-065 Diseñar headers HTTP
- [ ] T-066 Diseñar manejo de respuesta HTTP
- [ ] T-067 Diseñar nivel CRITICAL
- [ ] T-068 Diseñar contenido de log (error, stack trace, metadata, contexto)
- [ ] T-069 Diseñar _format_issue_body()
- [ ] T-070 Diseñar _create_github_issue()
- [ ] T-071 Diseñar uso de GitHub API
- [ ] T-072 Diseñar add_diagnostics_panel()
- [ ] T-073 Diseñar _format_metadata()
- [ ] T-074 Diseñar check_alerts()
- [ ] T-075 Diseñar _send_alert()
- [ ] T-076 Diseñar formato de alerta
- [ ] T-077 Diseñar 06-Plan-Testings.md (APLICA)
- [ ] T-078 Diseñar tests de offline mode
- [ ] T-079 Integración M103/M102/M110 completa — `[?]` (dueño M103/M102/M110) [M]
- [ ] T-080 Metadata avanzada, sanitización, dashboard — `[?]` (dueño M61/M114) [M]
