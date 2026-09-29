**Modelo:** gemini-3.8-flash (Google DeepMind)
**Plataforma:** WorkBuddy
**Modulo:** 106-Seguridad
**Fuente:** `DOCUMENTACION/106-Seguridad/plan-actual/05-Checklist.md` (fuente de verdad)
**Total:** 66 tareas (66 pendientes + 0 con dudas)

## Reglas
- Marcar `[x]` SOLO con evidencia (log + test headless rc=0 o verificacion binario real).
- `[?]` = no resuelto, con razon y dueno. `[→]` = movida a otro modelo.
- Al completar T-###: actualizar tambien el `05-Checklist.md` del modulo y la fila de CHECKLIST-GLOBAL.
- Reservar log: `python scripts/reservar_log.py --reservar --agente gemini-3.8-flash --modulo 106`.

## Tareas

- [x] T-001 Prevenir economía adulterada — `SecurityManager.validar_economia()` + test bloque D (Log 1077, 21/0 verde)
- [x] T-002 Prevenir bots — `SecurityManager.registrar_accion_bot()` (detección timing inhumano data-driven) + test bloque E (Log 1080, 27/0 verde)
- [x] T-003 Registrar accesos importantes — `SecurityManager.registrar_acceso()` + `volcar_audit_log()` (audit local user://, retención data-driven) + test bloque F (Log 1081, 35/0 verde)
- [x] T-004 Definir rate limiting (por IP, por usuario, por endpoint) — `SecurityManager.verificar_limite_tasa()` + `_limite_tasa_de()` (ventana deslizante, catálogo `limites_tasa`) + test bloque G (Log 1082, 43/0 verde)
- [x] T-005 Diseñar middleware de rate limiting en servidor — `security_rate_limit_middleware.gd` (orquesta IP+usuario+endpoint, RefCounted inyectado) + `tasa_reintento_s()` + test (Log 1086, 19/0 verde)
- [x] T-006 Definir no almacenar claves en código fuente — `security_secret_scanner.gd` (escáner de secrets hardcodeados, patrones regex, filtros anti-placeholder) + test (Log 1088, 20/0 verde)
- [x] T-007 Diseñar archivo .env.local para desarrollo (en .gitignore) — `.env.local` creado (placeholders, APP_ENV=dev) + `.gitignore` cubre `.env*`/`*.key`/`*.pem` (git check-ignore OK) + test (Log 1126, 13/0 verde)
- [x] T-008 Definir entornos separados (dev/staging/prod) — `security_environments.json` + `security_environment_resolver.gd` (APP_ENV, dev/staging/prod) + test (Log 1132, 24/0 verde)
- [x] T-009 Diseñar bases de datos separadas por entorno — `security_database_config.gd` (config_bd + validar_separacion: dev/staging nunca apuntan a prod) + campos bd_* en JSON + test (Log 1134, 15/0 verde)
- [ ] T-010 Definir firewalls (solo puertos necesarios)
- [ ] T-011 Definir monitoreo de vulnerabilidades
- [ ] T-012 Diseñar monitoreo de logs de acceso
- [ ] T-013 Diseñar monitoreo de métricas de seguridad
- [ ] T-014 Diseñar alertas por anomalías de seguridad
- [ ] T-015 Definir usuarios de base de datos con permisos mínimos necesarios
- [ ] T-016 Diseñar checksums de savegame (SHA-256)
- [ ] T-017 Definir checksums de datos de economía
- [ ] T-018 Definir límites de economía (max gold, max items)
- [ ] T-019 Definir CAPTCHA para rate limiting excedido
- [ ] T-020 Definir rate limiting por IP
- [ ] T-021 Definir rate limiting por usuario
- [ ] T-022 Definir rate limiting por endpoint
- [ ] T-023 Diseñar bloqueo de IPs sospechosas
- [ ] T-024 Diseñar logs almacenados en servidor
- [ ] T-025 Diseñar logs monitoreados regularmente
- [ ] T-026 Diseñar alertas por anomalías en logs
- [ ] T-027 Definir monitoreo de nuevas vulnerabilidades
- [ ] T-028 Diseñar signal rate_limit_exceeded()
- [ ] T-029 Diseñar método setup_rate_limiting()
- [ ] T-030 Diseñar método check_rate_limit()
- [ ] T-031 Diseñar variable rate_limit
- [ ] T-032 Diseñar variable request_count
- [ ] T-033 Diseñar variable rate_limit_timer
- [ ] T-034 Diseñar método validate_string(input, min_length, max_length)
- [ ] T-035 Diseñar método validate_int(input, min_value, max_value)
- [ ] T-036 Diseñar método validate_float(input, min_value, max_value)
- [ ] T-037 Diseñar método validate_email(input)
- [ ] T-038 Diseñar método sanitize_string(input)
- [ ] T-039 Diseñar método validate_checksum(data, expected_checksum)
- [ ] T-040 Diseñar método calculate_sha256(data)
- [ ] T-041 Diseñar método calculate_checksum(data)
- [ ] T-042 Diseñar método calculate_hmac(data)
- [ ] T-043 Diseñar método validate_savegame(savegame_data, checksum)
- [ ] T-044 Diseñar método validate_savegame_signature(savegame_data, signature)
- [ ] T-045 Diseñar método generate_request_id()
- [ ] T-046 Diseñar método is_request_processed(request_id)
- [ ] T-047 Diseñar método mark_request_processed(request_id)
- [ ] T-048 Diseñar método cleanup_old_requests()
- [ ] T-049 Diseñar variable processed_requests (Dictionary)
- [ ] T-050 Diseñar método validate_economy(player_data)
- [ ] T-051 Diseñar método validate_economy_checksum(player_data, checksum)
- [ ] T-052 Diseñar variable max_gold
- [ ] T-053 Diseñar variable max_items
- [ ] T-054 Diseñar método log_access(user_id, action, result)
- [ ] T-055 Diseñar método print_audit_log(log_entry)
- [ ] T-056 Diseñar método save_audit_logs()
- [ ] T-057 Diseñar variable audit_logs (Array)
- [ ] T-058 Diseñar propiedad max_gold
- [ ] T-059 Diseñar propiedad max_items
- [ ] T-060 Diseñar propiedad enable_checksum_validation
- [ ] T-061 Diseñar propiedad enable_signature_validation
- [ ] T-062 Diseñar propiedad enable_duplication_prevention
- [ ] T-063 Diseñar propiedad enable_economy_validation
- [ ] T-064 Diseñar propiedad enable_audit_logging
- [ ] T-065 Diseñar .env.example (plantilla)
- [ ] T-066 Diseñar prueba de rate limiting
