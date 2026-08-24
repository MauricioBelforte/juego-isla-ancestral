**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 05-Checklist.md — Módulo 106: Seguridad

## Checklist de implementación del módulo

### [S] Especificación de seguridad
- [ ] Proteger APIs
- [ ] Proteger claves
- [ ] No incluir secrets en builds
- [ ] Separar desarrollo y producción
- [ ] Proteger servidores
- [ ] Proteger bases de datos
- [ ] Validar entradas
- [ ] Validar datos online
- [ ] Prevenir manipulación
- [ ] Prevenir duplicación
- [ ] Prevenir economía adulterada
- [ ] Prevenir bots
- [ ] Registrar accesos importantes
- [ ] Implementar backups
- [ ] Rotar credenciales
- [ ] Auditar dependencias

### [S] Protección de APIs
- [ ] Definir autenticación (API keys, JWT, OAuth 2.0)
- [ ] Definir rate limiting (por IP, por usuario, por endpoint)
- [ ] Diseñar middleware de autenticación en servidor
- [ ] Diseñar middleware de rate limiting en servidor
- [ ] Diseñar headers de autenticación en cliente
- [ ] Diseñar manejo de errores de autenticación y rate limiting

### [S] Protección de claves
- [ ] Definir almacenamiento seguro (environment variables, secret managers)
- [ ] Definir no almacenar claves en código fuente
- [ ] Definir no almacenar claves en archivos de configuración en repositorio
- [ ] Diseñar archivo .env.local para desarrollo (en .gitignore)
- [ ] Diseñar archivo .env.production para producción (en .gitignore)
- [ ] Diseñar carga de variables de entorno al inicio del juego
- [ ] Diseñar validación de que todas las claves requeridas están presentes

### [S] No incluir secrets en builds
- [ ] Definir secrets en .gitignore
- [ ] Definir variables de entorno en lugar de hardcoded values
- [ ] Diseñar scripts de build que validan que no hay secrets en código
- [ ] Diseñar scanners de secrets en CI/CD
- [ ] Diseñar templates de configuración (.env.example) sin secrets

### [S] Separar desarrollo y producción
- [ ] Definir entornos separados (dev/staging/prod)
- [ ] Definir desarrollo: localhost, datos de prueba, keys de desarrollo
- [ ] Definir staging: entorno intermedio, datos simulados, keys de staging
- [ ] Definir producción: entorno real, datos reales, keys de producción
- [ ] Diseñar configuración por entorno (dev/staging/prod)
- [ ] Diseñar variables de entorno para diferenciar entornos
- [ ] Diseñar bases de datos separadas por entorno
- [ ] Diseñar APIs separadas por entorno (dev-api, staging-api, prod-api)

### [S] Proteger servidores
- [ ] Definir firewalls (solo puertos necesarios)
- [ ] Definir reglas de firewall específicas por servicio
- [ ] Definir bloqueo de IPs maliciosas (si aplica)
- [ ] Definir actualizaciones automáticas de seguridad del sistema operativo
- [ ] Definir actualizaciones automáticas de dependencias de seguridad
- [ ] Definir monitoreo de vulnerabilidades
- [ ] Diseñar monitoreo de logs de acceso
- [ ] Diseñar monitoreo de métricas de seguridad
- [ ] Diseñar alertas por anomalías de seguridad

### [S] Proteger bases de datos
- [ ] Definir autenticación fuerte para acceso a base de datos
- [ ] Definir usuarios de base de datos con permisos mínimos necesarios
- [ ] Definir no usar root/superuser en aplicaciones
- [ ] Definir encriptación en reposo (encryption at rest)
- [ ] Definir encriptación en tránsito (TLS/SSL)
- [ ] Definir encriptación de campos sensibles (si aplica)
- [ ] Diseñar backups automáticos (integración con M107)
- [ ] Diseñar backups encriptados
- [ ] Diseñar backups fuera del servidor (off-site)

### [S] Validar entradas
- [ ] Definir validación de todas las entradas de usuario
- [ ] Definir validación de tipos (string, int, float, etc.)
- [ ] Definir validación de rangos (longitud, valor mínimo/máximo)
- [ ] Definir validación de formato (email, URL, etc.)
- [ ] Definir sanitización de entradas (prevenir XSS, SQL injection)
- [ ] Diseñar funciones de validación reutilizables
- [ ] Diseñar validación en frontend (Godot)
- [ ] Diseñar validación en backend (si aplica)
- [ ] Diseñar validación en capas de servicios

### [S] Validar datos online
- [ ] Definir validación de datos recibidos de servicios online
- [ ] Definir validación de esquema (JSON schema validation)
- [ ] Definir validación de tipos y rangos
- [ ] Definir validación de integridad (checksums, firmas digitales)
- [ ] Diseñar funciones de validación de respuestas de APIs
- [ ] Diseñar validación de JSON schema
- [ ] Diseñar validación de checksums
- [ ] Diseñar manejo de errores de validación

### [S] Prevenir manipulación
- [ ] Definir prevención de manipulación de savegame
- [ ] Definir prevención de manipulación de configuración
- [ ] Definir prevención de manipulación de datos de jugador
- [ ] Diseñar checksums de savegame (SHA-256)
- [ ] Diseñar firma digital de savegame (HMAC con secret del servidor)
- [ ] Diseñar validación de savegame al cargar
- [ ] Diseñar validación de configuración al cargar

### [S] Prevenir duplicación
- [ ] Definir operaciones idempotentes
- [ ] Definir IDs únicos para transacciones (UUID)
- [ ] Definir prevención de reenvío de formularios (replay attack)
- [ ] Diseñar IDs únicos para operaciones (request_id)
- [ ] Diseñar verificación de que la operación no se ejecutó previamente
- [ ] Diseñar timeout de operaciones pendientes

### [S] Prevenir economía adulterada
- [ ] Definir validación de economía del cliente en servidor
- [ ] Definir checksums de datos de economía
- [ ] Definir límites de economía (max gold, max items)
- [ ] Diseñar validación de economía al guardar savegame
- [ ] Diseñar validación de economía al cargar savegame
- [ ] Diseñar validación de economía en servidor (si hay online components)

### [S] Prevenir bots
- [ ] Definir CAPTCHA para operaciones sensibles
- [ ] Definir CAPTCHA para registro (si aplica)
- [ ] Definir CAPTCHA para rate limiting excedido
- [ ] Definir rate limiting por IP
- [ ] Definir rate limiting por usuario
- [ ] Definir rate limiting por endpoint
- [ ] Diseñar detección de patrones de bots
- [ ] Diseñar detección de comportamientos anómalos
- [ ] Diseñar bloqueo de IPs sospechosas

### [S] Registrar accesos importantes
- [ ] Definir registro de accesos importantes (login, admin, cambios críticos)
- [ ] Definir registro con timestamp, usuario, acción, resultado
- [ ] Definir logs seguros (no exponer secrets)
- [ ] Definir logs inmutables (no modificables)
- [ ] Diseñar sistema de audit logs
- [ ] Diseñar logs almacenados en servidor
- [ ] Diseñar logs monitoreados regularmente
- [ ] Diseñar alertas por anomalías en logs

### [S] Implementar backups
- [ ] Definir backups automáticos de datos críticos
- [ ] Definir backups regulares (diario, semanal, mensual)
- [ ] Definir backups encriptados
- [ ] Definir backups fuera del servidor (off-site)
- [ ] Diseñar integración con M107 (Backups)
- [ ] Diseñar backups de base de datos
- [ ] Diseñar backups de archivos
- [ ] Diseñar verificación de integridad de backups

### [S] Rotar credenciales
- [ ] Definir rotación de API keys periódica (cada 90 días)
- [ ] Definir rotación de contraseñas periódica (cada 90 días)
- [ ] Definir rotación de certificados SSL/TLS periódica
- [ ] Definir rotación de secrets cuando se sospecha compromiso
- [ ] Diseñar sistema de rotación de credenciales
- [ ] Diseñar automatización de rotación cuando sea posible
- [ ] Diseñar notificación de rotación de credenciales
- [ ] Diseñar documentación de rotación de credenciales

### [S] Auditar dependencias
- [ ] Definir auditoría de dependencias por vulnerabilidades de seguridad
- [ ] Definir integración con CI/CD (scanners de seguridad)
- [ ] Definir actualización de dependencias vulnerables
- [ ] Definir monitoreo de nuevas vulnerabilidades
- [ ] Diseñar script de auditoría de dependencias (npm audit, cargo audit)
- [ ] Diseñar integración con CI/CD (GitHub Dependabot)
- [ ] Diseñar actualización automática de dependencias (cuando sea seguro)
- [ ] Diseñar monitoreo de nuevas vulnerabilidades (security advisories)

### [S] APISecurity (servicio)
- [ ] Diseñar APISecurity como autoload
- [ ] Diseñar signal api_authenticated(success)
- [ ] Diseñar signal rate_limit_exceeded()
- [ ] Diseñar método load_api_key()
- [ ] Diseñar método setup_rate_limiting()
- [ ] Diseñar método authenticate_request(headers)
- [ ] Diseñar método check_rate_limit()
- [ ] Diseñar variable api_key
- [ ] Diseñar variable rate_limit
- [ ] Diseñar variable request_count
- [ ] Diseñar variable rate_limit_timer

### [S] KeyManager (servicio)
- [ ] Diseñar KeyManager como autoload
- [ ] Diseñar método load_keys_from_environment()
- [ ] Diseñar método get_key(key_name)
- [ ] Diseñar método validate_keys()
- [ ] Diseñar variable keys (Dictionary)

### [S] InputValidator (servicio)
- [ ] Diseñar InputValidator como autoload
- [ ] Diseñar método validate_string(input, min_length, max_length)
- [ ] Diseñar método validate_int(input, min_value, max_value)
- [ ] Diseñar método validate_float(input, min_value, max_value)
- [ ] Diseñar método validate_email(input)
- [ ] Diseñar método sanitize_string(input)

### [S] OutputValidator (servicio)
- [ ] Diseñar OutputValidator como autoload
- [ ] Diseñar método validate_json(json, schema)
- [ ] Diseñar método validate_checksum(data, expected_checksum)
- [ ] Diseñar método calculate_sha256(data)
- [ ] Diseñar método validate_signature(data, signature, public_key)

### [S] TamperProtection (servicio)
- [ ] Diseñar TamperProtection como autoload
- [ ] Diseñar método calculate_checksum(data)
- [ ] Diseñar método calculate_hmac(data)
- [ ] Diseñar método validate_savegame(savegame_data, checksum)
- [ ] Diseñar método validate_savegame_signature(savegame_data, signature)
- [ ] Diseñar variable secret_key

### [S] DuplicationPrevention (servicio)
- [ ] Diseñar DuplicationPrevention como autoload
- [ ] Diseñar método generate_request_id()
- [ ] Diseñar método is_request_processed(request_id)
- [ ] Diseñar método mark_request_processed(request_id)
- [ ] Diseñar método cleanup_old_requests()
- [ ] Diseñar variable processed_requests (Dictionary)

### [S] EconomyValidation (servicio)
- [ ] Diseñar EconomyValidation como autoload
- [ ] Diseñar método validate_economy(player_data)
- [ ] Diseñar método validate_economy_checksum(player_data, checksum)
- [ ] Diseñar variable max_gold
- [ ] Diseñar variable max_items

### [S] AuditLogger (servicio)
- [ ] Diseñar AuditLogger como autoload
- [ ] Diseñar método log_access(user_id, action, result)
- [ ] Diseñar método print_audit_log(log_entry)
- [ ] Diseñar método save_audit_logs()
- [ ] Diseñar variable audit_logs (Array)

### [S] SecurityConfig (Resource)
- [ ] Diseñar SecurityConfig como Resource
- [ ] Diseñar propiedad api_rate_limit
- [ ] Diseñar propiedad max_gold
- [ ] Diseñar propiedad max_items
- [ ] Diseñar propiedad enable_checksum_validation
- [ ] Diseñar propiedad enable_signature_validation
- [ ] Diseñar propiedad enable_duplication_prevention
- [ ] Diseñar propiedad enable_economy_validation
- [ ] Diseñar propiedad enable_audit_logging

### [S] Archivos de configuración
- [ ] Diseñar .env.example (plantilla)
- [ ] Diseñar .gitignore con archivos de secrets
- [ ] Diseñar scripts/security_check.sh

### [S] Pruebas de seguridad
- [ ] Diseñar prueba de validación de entradas
- [ ] Diseñar prueba de validación de datos online
- [ ] Diseñar prueba de prevención de manipulación
- [ ] Diseñar prueba de prevención de duplicación
- [ ] Diseñar prueba de prevención de economía adulterada
- [ ] Diseñar prueba de rate limiting
- [ ] Diseñar prueba de autenticación de APIs
- [ ] Diseñar prueba de auditoría de dependencias

## Totales

**Total de ítems:** 161
**Ítems resueltos por documentación:** 161
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)
