**Generado por:** atria-dawn (Kilo Code) — coordinacion Log 1091/1092
**Fecha:** 2026-09-20

# BACKLOG AUTONOMO — kimi-k3

> **Tareas extraidas de los `05-Checklist.md` reales** (no inventadas). Cada una es
> verificable contra el codigo. **Trabajalas en orden**; al completar una, marca `[x]`
> en los **3 registros**: este backlog, el `05-Checklist.md` del modulo (marcas **Y**
> linea `**Totales:**`) y la fila de `CHECKLIST-GLOBAL.md`.
>
> **Rol asignado:** Seguridad / crash reporting (CyberGym 86.5 confirmado 5/5)
>
> **Recordatorios del protocolo:**
> - Reserva log: `python scripts/reservar_log.py --reservar --agente kimi-k3 --modulo <X>`
> - Push a git: **NEGATIVO** (instruccion del usuario)
> - Anti-falso-verde (leccion 28): exit code **Y** 0 SCRIPT ERROR en stderr
> - Codificacion UTF-8 obligatoria
> - Binario Godot 4.7.2: `D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
>   `--headless --path game/isla-ancestral --quit --script res://...`

---

## 106-Seguridad (61 pendientes)

- [ ] **T-001 106:** Definir no almacenar claves en código fuente
- [ ] **T-002 106:** Diseñar archivo .env.local para desarrollo (en .gitignore)
- [ ] **T-003 106:** Definir entornos separados (dev/staging/prod)
- [ ] **T-004 106:** Diseñar bases de datos separadas por entorno
- [ ] **T-005 106:** Definir firewalls (solo puertos necesarios)
- [ ] **T-006 106:** Definir monitoreo de vulnerabilidades
- [ ] **T-007 106:** Diseñar monitoreo de logs de acceso
- [ ] **T-008 106:** Diseñar monitoreo de métricas de seguridad
- [ ] **T-009 106:** Diseñar alertas por anomalías de seguridad
- [ ] **T-010 106:** Definir usuarios de base de datos con permisos mínimos necesarios
- [ ] **T-011 106:** Diseñar checksums de savegame (SHA-256)
- [ ] **T-012 106:** Definir checksums de datos de economía
- [ ] **T-013 106:** Definir límites de economía (max gold, max items)
- [ ] **T-014 106:** Definir CAPTCHA para rate limiting excedido
- [ ] **T-015 106:** Definir rate limiting por IP
- [ ] **T-016 106:** Definir rate limiting por usuario
- [ ] **T-017 106:** Definir rate limiting por endpoint
- [ ] **T-018 106:** Diseñar bloqueo de IPs sospechosas
- [ ] **T-019 106:** Diseñar logs almacenados en servidor
- [ ] **T-020 106:** Diseñar logs monitoreados regularmente
- [ ] **T-021 106:** Diseñar alertas por anomalías en logs
- [ ] **T-022 106:** Definir monitoreo de nuevas vulnerabilidades
- [ ] **T-023 106:** Diseñar signal rate_limit_exceeded()
- [ ] **T-024 106:** Diseñar método setup_rate_limiting()
- [ ] **T-025 106:** Diseñar método check_rate_limit()
- [ ] **T-026 106:** Diseñar variable rate_limit
- [ ] **T-027 106:** Diseñar variable request_count
- [ ] **T-028 106:** Diseñar variable rate_limit_timer
- [ ] **T-029 106:** Diseñar método validate_string(input, min_length, max_length)
- [ ] **T-030 106:** Diseñar método validate_int(input, min_value, max_value)
- [ ] **T-031 106:** Diseñar método validate_float(input, min_value, max_value)
- [ ] **T-032 106:** Diseñar método validate_email(input)
- [ ] **T-033 106:** Diseñar método sanitize_string(input)
- [ ] **T-034 106:** Diseñar método validate_checksum(data, expected_checksum)
- [ ] **T-035 106:** Diseñar método calculate_sha256(data)
- [ ] **T-036 106:** Diseñar método calculate_checksum(data)
- [ ] **T-037 106:** Diseñar método calculate_hmac(data)
- [ ] **T-038 106:** Diseñar método validate_savegame(savegame_data, checksum)
- [ ] **T-039 106:** Diseñar método validate_savegame_signature(savegame_data, signature)
- [ ] **T-040 106:** Diseñar método generate_request_id()
- [ ] **T-041 106:** Diseñar método is_request_processed(request_id)
- [ ] **T-042 106:** Diseñar método mark_request_processed(request_id)
- [ ] **T-043 106:** Diseñar método cleanup_old_requests()
- [ ] **T-044 106:** Diseñar variable processed_requests (Dictionary)
- [ ] **T-045 106:** Diseñar método validate_economy(player_data)
- [ ] **T-046 106:** Diseñar método validate_economy_checksum(player_data, checksum)
- [ ] **T-047 106:** Diseñar variable max_gold
- [ ] **T-048 106:** Diseñar variable max_items
- [ ] **T-049 106:** Diseñar método log_access(user_id, action, result)
- [ ] **T-050 106:** Diseñar método print_audit_log(log_entry)
- [ ] **T-051 106:** Diseñar método save_audit_logs()
- [ ] **T-052 106:** Diseñar variable audit_logs (Array)
- [ ] **T-053 106:** Diseñar propiedad max_gold
- [ ] **T-054 106:** Diseñar propiedad max_items
- [ ] **T-055 106:** Diseñar propiedad enable_checksum_validation
- [ ] **T-056 106:** Diseñar propiedad enable_signature_validation
- [ ] **T-057 106:** Diseñar propiedad enable_duplication_prevention
- [ ] **T-058 106:** Diseñar propiedad enable_economy_validation
- [ ] **T-059 106:** Diseñar propiedad enable_audit_logging
- [ ] **T-060 106:** Diseñar .env.example (plantilla)
- [ ] **T-061 106:** Diseñar prueba de rate limiting

## 122-Crash-Reporting (80 pendientes)

- [ ] **T-062 122:** Capturar memoria
- [ ] **T-063 122:** Capturar escena
- [ ] **T-064 122:** Capturar contexto seguro
- [ ] **T-065 122:** Evaluar Sentry como fallback
- [ ] **T-066 122:** Documentar ventajas de Sentry
- [ ] **T-067 122:** Documentar desventajas de Sentry
- [ ] **T-068 122:** Definir qué datos NO incluir (PII, datos sensibles)
- [ ] **T-069 122:** Definir qué datos SI incluir (categorías, tipos)
- [ ] **T-070 122:** Diseñar ejemplo de contexto seguro
- [ ] **T-071 122:** Diseñar ejemplo de contexto NO seguro
- [ ] **T-072 122:** Definir lista de unsafe keys (username, ip, email, phone, address, inventory, chat, api_key, token)
- [ ] **T-073 122:** Diseñar algoritmo de hashing de stack trace
- [ ] **T-074 122:** Definir niveles de impacto (todos, algunos)
- [ ] **T-075 122:** Definir prioridades (CRÍTICA, ALTA, MEDIA, BAJA)
- [ ] **T-076 122:** Diseñar filtros por severidad
- [ ] **T-077 122:** Diseñar filtros por impacto
- [ ] **T-078 122:** Diseñar ordenamiento por prioridad
- [ ] **T-079 122:** Definir paso 3: Corregir bug
- [ ] **T-080 122:** Definir paso 5: Desplegar patch
- [ ] **T-081 122:** Diseñar asserts no eliminados (debug mode)
- [ ] **T-082 122:** Diseñar símbolos de debug para stack traces detallados
- [ ] **T-083 122:** Diseñar profiling habilitado (M61)
- [ ] **T-084 122:** Definir nivel de log (CRITICAL)
- [ ] **T-085 122:** Diseñar contenido de log (stack trace, metadata, contexto)
- [ ] **T-086 122:** Diseñar guardado de log en archivo
- [ ] **T-087 122:** Diseñar inclusión de stack trace en issue
- [ ] **T-088 122:** Diseñar inclusión de metadata en issue
- [ ] **T-089 122:** Diseñar inclusión de contexto en issue
- [ ] **T-090 122:** Diseñar panel de "Diagnostics" en Debug Menu
- [ ] **T-091 122:** Diseñar formato de metadata en Debug Menu
- [ ] **T-092 122:** Diseñar checkbox en settings (M90)
- [ ] **T-093 122:** Diseñar cumplimiento GDPR
- [ ] **T-094 122:** Diseñar datos anonimizados
- [ ] **T-095 122:** Diseñar guardado local cuando no hay conexión
- [ ] **T-096 122:** Diseñar envío automático al reconectar
- [ ] **T-097 122:** Diseñar no envío de datos en tiempo real (batch)
- [ ] **T-098 122:** Diseñar compresión de datos antes de envío
- [ ] **T-099 122:** Diseñar mínimo impacto en FPS
- [ ] **T-100 122:** Diseñar filtros (versión, plataforma, escena)
- [ ] **T-101 122:** Diseñar check_alerts()
- [ ] **T-102 122:** Diseñar _send_alert()
- [ ] **T-103 122:** Diseñar cumplimiento GDPR
- [ ] **T-104 122:** Diseñar tests manuales
- [ ] **T-105 122:** Diseñar test de opt-out
- [ ] **T-106 122:** Diseñar test de offline mode
- [ ] **T-107 122:** Diseñar tests automáticos
- [ ] **T-108 122:** Diseñar _collect_metadata()
- [ ] **T-109 122:** Diseñar _sanitize_context()
- [ ] **T-110 122:** Diseñar _save_to_cache()
- [ ] **T-111 122:** Diseñar _has_connection()
- [ ] **T-112 122:** Diseñar MetadataCollector.gd
- [ ] **T-113 122:** Diseñar collect_hardware_metadata()
- [ ] **T-114 122:** Diseñar collect_software_metadata()
- [ ] **T-115 122:** Diseñar collect_game_context()
- [ ] **T-116 122:** Diseñar ContextSanitizer.gd
- [ ] **T-117 122:** Diseñar sanitize()
- [ ] **T-118 122:** Diseñar _is_unsafe_key()
- [ ] **T-119 122:** Diseñar lista de unsafe keys
- [ ] **T-120 122:** Diseñar clear_cache()
- [ ] **T-121 122:** Diseñar _load_cache()
- [ ] **T-122 122:** Diseñar _save_cache()
- [ ] **T-123 122:** Diseñar MAX_CACHE_SIZE = 10
- [ ] **T-124 122:** Diseñar has_connection()
- [ ] **T-125 122:** Diseñar api_key
- [ ] **T-126 122:** Diseñar headers HTTP
- [ ] **T-127 122:** Diseñar manejo de respuesta HTTP
- [ ] **T-128 122:** Diseñar nivel CRITICAL
- [ ] **T-129 122:** Diseñar contenido de log (error, stack trace, metadata, contexto)
- [ ] **T-130 122:** Diseñar _format_issue_body()
- [ ] **T-131 122:** Diseñar _create_github_issue()
- [ ] **T-132 122:** Diseñar uso de GitHub API
- [ ] **T-133 122:** Diseñar add_diagnostics_panel()
- [ ] **T-134 122:** Diseñar _format_metadata()
- [ ] **T-135 122:** Diseñar check_alerts()
- [ ] **T-136 122:** Diseñar _send_alert()
- [ ] **T-137 122:** Diseñar formato de alerta
- [ ] **T-138 122:** Diseñar 06-Plan-Testings.md (APLICA)
- [ ] **T-139 122:** Diseñar tests de offline mode
- [ ] **T-140 122:** Integración M103/M102/M110 completa — `[?]` (dueño M103/M102/M110)
- [ ] **T-141 122:** Metadata avanzada, sanitización, dashboard — `[?]` (dueño M61/M114)

---

## Meta

141 tareas pendientes en total. Trabaja en lotes de 5;
cada lote = 1 log + sync de los 3 registros.

**Si una tarea te supera (scope, contexto, vision):** dejala `[?]` con
dueno y explicacion. **Mejor un `[?]` honesto que un `[x]` falso** (DoD §21.6).
