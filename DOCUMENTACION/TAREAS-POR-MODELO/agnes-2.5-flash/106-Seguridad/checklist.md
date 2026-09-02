# Tareas M106 — Seguridad

**Modelo:** agnes-2.5-flash
**Fecha inicio:** 2026-09-02
**Fuente:** DOCUMENTACION/106-Seguridad/plan-actual/05-Checklist.md

## Tareas pendientes

[ ] T-001 Proteger APIs
[ ] T-002 Proteger claves
[ ] T-003 No incluir secrets en builds
[ ] T-004 Separar desarrollo y producción
[ ] T-005 Proteger servidores
[ ] T-006 Proteger bases de datos
[ ] T-007 Validar entradas
[ ] T-008 Validar datos online
[ ] T-009 Prevenir manipulación
[ ] T-010 Prevenir duplicación
[ ] T-011 Prevenir economía adulterada
[ ] T-012 Prevenir bots
[ ] T-013 Registrar accesos importantes
[ ] T-014 Implementar backups
[ ] T-015 Rotar credenciales
[ ] T-016 Auditar dependencias
[ ] T-017 Definir autenticación (API keys, JWT, OAuth 2.0)
[ ] T-018 Definir rate limiting (por IP, por usuario, por endpoint)
[ ] T-019 Diseñar middleware de autenticación en servidor
[ ] T-020 Diseñar middleware de rate limiting en servidor
[ ] T-021 Diseñar headers de autenticación en cliente
[ ] T-022 Diseñar manejo de errores de autenticación y rate limiting
[ ] T-023 Definir no almacenar claves en código fuente
[ ] T-024 Diseñar archivo .env.local para desarrollo (en .gitignore)
[ ] T-025 Diseñar archivo .env.production para producción (en .gitignore)
[ ] T-026 Diseñar carga de variables de entorno al inicio del juego
[ ] T-027 Diseñar validación de que todas las claves requeridas están presentes
[ ] T-028 Definir secrets en .gitignore
[ ] T-029 Definir variables de entorno en lugar de hardcoded values
[ ] T-030 Diseñar scanners de secrets en CI/CD
[ ] T-031 Definir entornos separados (dev/staging/prod)
[ ] T-032 Definir desarrollo: localhost, datos de prueba, keys de desarrollo
[ ] T-033 Definir staging: entorno intermedio, datos simulados, keys de staging
[ ] T-034 Definir producción: entorno real, datos reales, keys de producción
[ ] T-035 Diseñar variables de entorno para diferenciar entornos
[ ] T-036 Diseñar bases de datos separadas por entorno
[ ] T-037 Diseñar APIs separadas por entorno (dev-api, staging-api, prod-api)
[ ] T-038 Definir firewalls (solo puertos necesarios)
[ ] T-039 Definir reglas de firewall específicas por servicio
[ ] T-040 Definir bloqueo de IPs maliciosas (si aplica)
[ ] T-041 Definir actualizaciones automáticas de seguridad del sistema operativo
[ ] T-042 Definir actualizaciones automáticas de dependencias de seguridad
[ ] T-043 Definir monitoreo de vulnerabilidades
[ ] T-044 Diseñar monitoreo de logs de acceso
[ ] T-045 Diseñar monitoreo de métricas de seguridad
[ ] T-046 Diseñar alertas por anomalías de seguridad
[ ] T-047 Definir autenticación fuerte para acceso a base de datos
[ ] T-048 Definir usuarios de base de datos con permisos mínimos necesarios
[ ] T-049 Definir no usar root/superuser en aplicaciones
[ ] T-050 Definir encriptación en reposo (encryption at rest)
[ ] T-051 Definir encriptación en tránsito (TLS/SSL)
[ ] T-052 Definir encriptación de campos sensibles (si aplica)
[ ] T-053 Diseñar backups automáticos (integración con M107)
[ ] T-054 Diseñar backups encriptados
[ ] T-055 Diseñar backups fuera del servidor (off-site)
[ ] T-056 Definir validación de todas las entradas de usuario
[ ] T-057 Definir validación de tipos (string, int, float, etc.)
[ ] T-058 Definir validación de rangos (longitud, valor mínimo/máximo)
[ ] T-059 Definir validación de formato (email, URL, etc.)
[ ] T-060 Definir sanitización de entradas (prevenir XSS, SQL injection)
[ ] T-061 Diseñar funciones de validación reutilizables
[ ] T-062 Diseñar validación en frontend (Godot)
[ ] T-063 Diseñar validación en backend (si aplica)
[ ] T-064 Diseñar validación en capas de servicios
[ ] T-065 Definir validación de datos recibidos de servicios online
[ ] T-066 Definir validación de tipos y rangos
[ ] T-067 Definir validación de integridad (checksums, firmas digitales)
[ ] T-068 Diseñar funciones de validación de respuestas de APIs
[ ] T-069 Diseñar validación de checksums
[ ] T-070 Diseñar manejo de errores de validación
[ ] T-071 Definir prevención de manipulación de savegame
[ ] T-072 Definir prevención de manipulación de datos de jugador
[ ] T-073 Diseñar checksums de savegame (SHA-256)
[ ] T-074 Diseñar firma digital de savegame (HMAC con secret del servidor)
[ ] T-075 Diseñar validación de savegame al cargar
[ ] T-076 Definir operaciones idempotentes
[ ] T-077 Definir IDs únicos para transacciones (UUID)
[ ] T-078 Definir prevención de reenvío de formularios (replay attack)
[ ] T-079 Diseñar IDs únicos para operaciones (request_id)
[ ] T-080 Diseñar verificación de que la operación no se ejecutó previamente
[ ] T-081 Diseñar timeout de operaciones pendientes
[ ] T-082 Definir validación de economía del cliente en servidor
[ ] T-083 Definir checksums de datos de economía
[ ] T-084 Definir límites de economía (max gold, max items)
[ ] T-085 Diseñar validación de economía al guardar savegame
[ ] T-086 Diseñar validación de economía al cargar savegame
[ ] T-087 Diseñar validación de economía en servidor (si hay online components)
[ ] T-088 Definir CAPTCHA para operaciones sensibles
[ ] T-089 Definir CAPTCHA para rate limiting excedido
[ ] T-090 Definir rate limiting por IP
[ ] T-091 Definir rate limiting por usuario
[ ] T-092 Definir rate limiting por endpoint
[ ] T-093 Diseñar detección de patrones de bots
[ ] T-094 Diseñar detección de comportamientos anómalos
[ ] T-095 Diseñar bloqueo de IPs sospechosas
[ ] T-096 Definir logs seguros (no exponer secrets)
[ ] T-097 Definir logs inmutables (no modificables)
[ ] T-098 Diseñar sistema de audit logs
[ ] T-099 Diseñar logs almacenados en servidor
[ ] T-100 Diseñar logs monitoreados regularmente
[ ] T-101 Diseñar alertas por anomalías en logs
[ ] T-102 Definir backups automáticos de datos críticos
[ ] T-103 Definir backups regulares (diario, semanal, mensual)
[ ] T-104 Definir backups encriptados
[ ] T-105 Definir backups fuera del servidor (off-site)
[ ] T-106 Diseñar integración con M107 (Backups)
[ ] T-107 Diseñar backups de base de datos
[ ] T-108 Diseñar backups de archivos
[ ] T-109 Diseñar verificación de integridad de backups
[ ] T-110 Definir rotación de API keys periódica (cada 90 días)
[ ] T-111 Definir rotación de contraseñas periódica (cada 90 días)
[ ] T-112 Definir rotación de certificados SSL/TLS periódica
[ ] T-113 Definir rotación de secrets cuando se sospecha compromiso
[ ] T-114 Diseñar sistema de rotación de credenciales
[ ] T-115 Diseñar automatización de rotación cuando sea posible
[ ] T-116 Diseñar notificación de rotación de credenciales
[ ] T-117 Diseñar documentación de rotación de credenciales
[ ] T-118 Definir auditoría de dependencias por vulnerabilidades de seguridad
[ ] T-119 Definir integración con CI/CD (scanners de seguridad)
[ ] T-120 Definir actualización de dependencias vulnerables
[ ] T-121 Definir monitoreo de nuevas vulnerabilidades
[ ] T-122 Diseñar integración con CI/CD (GitHub Dependabot)
[ ] T-123 Diseñar actualización automática de dependencias (cuando sea seguro)
[ ] T-124 Diseñar monitoreo de nuevas vulnerabilidades (security advisories)
[ ] T-125 Diseñar signal api_authenticated(success)
[ ] T-126 Diseñar signal rate_limit_exceeded()
[ ] T-127 Diseñar método load_api_key()
[ ] T-128 Diseñar método setup_rate_limiting()
[ ] T-129 Diseñar método authenticate_request(headers)
[ ] T-130 Diseñar método check_rate_limit()
[ ] T-131 Diseñar variable api_key
[ ] T-132 Diseñar variable rate_limit
[ ] T-133 Diseñar variable request_count
[ ] T-134 Diseñar variable rate_limit_timer
[ ] T-135 Diseñar método load_keys_from_environment()
[ ] T-136 Diseñar método get_key(key_name)
[ ] T-137 Diseñar método validate_keys()
[ ] T-138 Diseñar variable keys (Dictionary)
[ ] T-139 Diseñar método validate_string(input, min_length, max_length)
[ ] T-140 Diseñar método validate_int(input, min_value, max_value)
[ ] T-141 Diseñar método validate_float(input, min_value, max_value)
[ ] T-142 Diseñar método validate_email(input)
[ ] T-143 Diseñar método sanitize_string(input)
[ ] T-144 Diseñar método validate_checksum(data, expected_checksum)
[ ] T-145 Diseñar método calculate_sha256(data)
[ ] T-146 Diseñar método validate_signature(data, signature, public_key)
[ ] T-147 Diseñar método calculate_checksum(data)
[ ] T-148 Diseñar método calculate_hmac(data)
[ ] T-149 Diseñar método validate_savegame(savegame_data, checksum)
[ ] T-150 Diseñar método validate_savegame_signature(savegame_data, signature)
[ ] T-151 Diseñar variable secret_key
[ ] T-152 Diseñar método generate_request_id()
[ ] T-153 Diseñar método is_request_processed(request_id)
[ ] T-154 Diseñar método mark_request_processed(request_id)
[ ] T-155 Diseñar método cleanup_old_requests()
[ ] T-156 Diseñar variable processed_requests (Dictionary)
[ ] T-157 Diseñar método validate_economy(player_data)
[ ] T-158 Diseñar método validate_economy_checksum(player_data, checksum)
[ ] T-159 Diseñar variable max_gold
[ ] T-160 Diseñar variable max_items
[ ] T-161 Diseñar método log_access(user_id, action, result)
[ ] T-162 Diseñar método print_audit_log(log_entry)
[ ] T-163 Diseñar método save_audit_logs()
[ ] T-164 Diseñar variable audit_logs (Array)
[ ] T-165 Diseñar propiedad api_rate_limit
[ ] T-166 Diseñar propiedad max_gold
[ ] T-167 Diseñar propiedad max_items
[ ] T-168 Diseñar propiedad enable_checksum_validation
[ ] T-169 Diseñar propiedad enable_signature_validation
[ ] T-170 Diseñar propiedad enable_duplication_prevention
[ ] T-171 Diseñar propiedad enable_economy_validation
[ ] T-172 Diseñar propiedad enable_audit_logging
[ ] T-173 Diseñar .env.example (plantilla)
[ ] T-174 Diseñar .gitignore con archivos de secrets
[ ] T-175 Diseñar prueba de validación de entradas
[ ] T-176 Diseñar prueba de validación de datos online
[ ] T-177 Diseñar prueba de prevención de manipulación
[ ] T-178 Diseñar prueba de prevención de duplicación
[ ] T-179 Diseñar prueba de prevención de economía adulterada
[ ] T-180 Diseñar prueba de rate limiting
[ ] T-181 Diseñar prueba de autenticación de APIs
[ ] T-182 Diseñar prueba de auditoría de dependencias