**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 03-Diseno.md — Módulo 106: Seguridad

## 1. Arquitectura del módulo

```
Seguridad (sistema de protección del juego, datos y servicios)
├── Protección de APIs
│   ├── Autenticación (API keys, JWT, OAuth 2.0)
│   ├── Rate limiting (por IP, por usuario, por endpoint)
│   └── Middleware de autenticación y rate limiting
├── Protección de claves
│   ├── Environment variables
│   ├── Secret managers (AWS Secrets Manager, Azure Key Vault)
│   └── Carga de variables de entorno al inicio
├── No incluir secrets en builds
│   ├── .gitignore de archivos con secrets
│   ├── Scripts de pre-commit (scanners de secrets)
│   └── Scripts de CI/CD (validación de secrets)
├── Separar desarrollo y producción
│   ├── Entornos separados (dev/staging/prod)
│   ├── Configuración por entorno
│   └── Variables de entorno para diferenciar entornos
├── Proteger servidores
│   ├── Firewalls
│   ├── Actualizaciones de seguridad
│   └── Monitoreo
├── Proteger bases de datos
│   ├── Autenticación fuerte
│   ├── Encriptación en reposo y en tránsito
│   └── Backups encriptados
├── Validar entradas
│   ├── Input validation (tipos, rangos, formato)
│   ├── Sanitización (XSS, SQL injection)
│   └── Validación en frontend y backend
├── Validar datos online
│   ├── Output validation (JSON schema)
│   ├── Validación de integridad (checksums, firmas digitales)
│   └── Manejo de errores de validación
├── Prevenir manipulación
│   ├── Checksums de savegame (SHA-256)
│   ├── Firma digital de savegame (HMAC)
│   └── Validación de savegame al cargar
├── Prevenir duplicación
│   ├── Idempotencia (request_id)
│   ├── Verificación de operaciones previas
│   └── Timeout de operaciones pendientes
├── Prevenir economía adulterada
│   ├── Offline validation
│   ├── Checksums de datos de economía
│   └── Límites de economía
├── Prevenir bots
│   ├── CAPTCHA
│   ├── Rate limiting
│   └── Heurísticas de detección
├── Registrar accesos importantes
│   ├── Audit logs (timestamp, usuario, acción, resultado)
│   ├── Logs seguros (no exponer secrets)
│   └── Logs inmutables
├── Implementar backups
│   ├── Backups automáticos (integración con M107)
│   ├── Backups encriptados
│   └── Backups off-site
├── Rotar credenciales
│   ├── Rotación periódica (cada 90 días)
│   ├── Automatización de rotación
│   └── Notificación de rotación
└── Auditar dependencias
    ├── Scanners de seguridad (npm audit, cargo audit)
    ├── Integración con CI/CD (GitHub Dependabot)
    ├── Actualización de dependencias vulnerables
    └── Monitoreo de nuevas vulnerabilidades
```

## 2. Sistema de protección de APIs

**Archivo: res://security/api_security.gd**

**Estructura:**
```gdscript
class_name APISecurity
extends Node

signal api_authenticated(success: bool)
signal rate_limit_exceeded()

var api_key: String = ""
var rate_limit: int = 100  # requests por minuto
var request_count: int = 0
var rate_limit_timer: Timer

func _ready():
    load_api_key()
    setup_rate_limiting()

func load_api_key():
    api_key = OS.get_environment("API_KEY")
    if api_key.is_empty():
        print("WARNING: API_KEY not found in environment variables")

func setup_rate_limiting():
    rate_limit_timer = Timer.new()
    rate_limit_timer.wait_time = 60.0  # 1 minuto
    rate_limit_timer.timeout.connect(_on_rate_limit_reset)
    add_child(rate_limit_timer)
    rate_limit_timer.start()

func _on_rate_limit_reset():
    request_count = 0

func authenticate_request(headers: Dictionary) -> bool:
    var provided_key = headers.get("Authorization", "")
    if provided_key == "Bearer " + api_key:
        api_authenticated.emit(true)
        return true
    api_authenticated.emit(false)
    return false

func check_rate_limit() -> bool:
    if request_count >= rate_limit:
        rate_limit_exceeded.emit()
        return false
    request_count += 1
    return true
```

## 3. Sistema de protección de claves

**Archivo: res://security/key_manager.gd**

**Estructura:**
```gdscript
class_name KeyManager
extends Node

var keys: Dictionary = {}

func _ready():
    load_keys_from_environment()

func load_keys_from_environment():
    keys["API_KEY"] = OS.get_environment("API_KEY")
    keys["STEAM_API_KEY"] = OS.get_environment("STEAM_API_KEY")
    keys["ANALYTICS_KEY"] = OS.get_environment("ANALYTICS_KEY")
    keys["CRASH_REPORTING_KEY"] = OS.get_environment("CRASH_REPORTING_KEY")
    
    for key_name in keys.keys():
        if keys[key_name].is_empty():
            print("WARNING: %s not found in environment variables" % key_name)

func get_key(key_name: String) -> String:
    return keys.get(key_name, "")

func validate_keys() -> bool:
    for key_name in keys.keys():
        if keys[key_name].is_empty():
            return false
    return true
```

## 4. Sistema de validación de entradas

**Archivo: res://security/input_validator.gd**

**Estructura:**
```gdscript
class_name InputValidator
extends Node

func validate_string(input: String, min_length: int = 0, max_length: int = 1000) -> bool:
    if input.length() < min_length or input.length() > max_length:
        return false
    return true

func validate_int(input: int, min_value: int = 0, max_value: int = 2147483647) -> bool:
    if input < min_value or input > max_value:
        return false
    return true

func validate_float(input: float, min_value: float = 0.0, max_value: float = 1000000.0) -> bool:
    if input < min_value or input > max_value:
        return false
    return true

func validate_email(input: String) -> bool:
    var regex = RegEx.new()
    regex.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
    return regex.search(input) != null

func sanitize_string(input: String) -> String:
    # Sanitización básica (prevenir XSS)
    input = input.replace("<", "&lt;")
    input = input.replace(">", "&gt;")
    input = input.replace("\"", "&quot;")
    input = input.replace("'", "&#x27;")
    return input
```

## 5. Sistema de validación de datos online

**Archivo: res://security/output_validator.gd**

**Estructura:**
```gdscript
class_name OutputValidator
extends Node

func validate_json(json: Dictionary, schema: Dictionary) -> bool:
    # Validación de JSON schema (implementación básica)
    for key in schema.keys():
        if not json.has(key):
            return false
        var expected_type = schema[key]
        var actual_type = typeof(json[key])
        if actual_type != expected_type:
            return false
    return true

func validate_checksum(data: String, expected_checksum: String) -> bool:
    var actual_checksum = calculate_sha256(data)
    return actual_checksum == expected_checksum

func calculate_sha256(data: String) -> String:
    # Implementación de SHA-256 (usar CryptoKit o librería externa)
    return ""

func validate_signature(data: String, signature: String, public_key: String) -> bool:
    # Validación de firma digital (implementación básica)
    return true
```

## 6. Sistema de prevención de manipulación

**Archivo: res://security/tamper_protection.gd**

**Estructura:**
```gdscript
class_name TamperProtection
extends Node

var secret_key: String = ""

func _ready():
    secret_key = KeyManager.get_key("TAMPER_SECRET_KEY")

func calculate_checksum(data: String) -> String:
    var hash = calculate_sha256(data)
    return hash

func calculate_hmac(data: String) -> String:
    # Implementación de HMAC (usar CryptoKit o librería externa)
    var hash = calculate_sha256(secret_key + data)
    return hash

func validate_savegame(savegame_data: Dictionary, checksum: String) -> bool:
    var data_string = JSON.stringify(savegame_data)
    var expected_checksum = calculate_checksum(data_string)
    return expected_checksum == checksum

func validate_savegame_signature(savegame_data: Dictionary, signature: String) -> bool:
    var data_string = JSON.stringify(savegame_data)
    var expected_signature = calculate_hmac(data_string)
    return expected_signature == signature
```

## 7. Sistema de prevención de duplicación

**Archivo: res://security/duplication_prevention.gd**

**Estructura:**
```gdscript
class_name DuplicationPrevention
extends Node

var processed_requests: Dictionary = {}

func generate_request_id() -> String:
    return str(Time.get_unix_time_from_system()) + "_" + str(randi() % 10000)

func is_request_processed(request_id: String) -> bool:
    return processed_requests.has(request_id)

func mark_request_processed(request_id: String):
    processed_requests[request_id] = Time.get_unix_time_from_system()

func cleanup_old_requests():
    var current_time = Time.get_unix_time_from_system()
    var timeout = 3600.0  # 1 hora
    for request_id in processed_requests.keys():
        if current_time - processed_requests[request_id] > timeout:
            processed_requests.erase(request_id)
```

## 8. Sistema de prevención de economía adulterada

**Archivo: res://security/economy_validation.gd**

**Estructura:**
```gdscript
class_name EconomyValidation
extends Node

var max_gold: int = 1000000
var max_items: int = 9999

func validate_economy(player_data: Dictionary) -> bool:
    if player_data.has("gold"):
        if player_data["gold"] < 0 or player_data["gold"] > max_gold:
            return false
    
    if player_data.has("inventory"):
        for item in player_data["inventory"]:
            if item["quantity"] < 0 or item["quantity"] > max_items:
                return false
    
    return true

func validate_economy_checksum(player_data: Dictionary, checksum: String) -> bool:
    var economy_data = {
        "gold": player_data.get("gold", 0),
        "inventory": player_data.get("inventory", [])
    }
    var data_string = JSON.stringify(economy_data)
    var expected_checksum = calculate_sha256(data_string)
    return expected_checksum == checksum
```

## 9. Sistema de registro de accesos importantes

**Archivo: res://security/audit_logger.gd**

**Estructura:**
```gdscript
class_name AuditLogger
extends Node

var audit_logs: Array = []

func log_access(user_id: String, action: String, result: bool):
    var log_entry = {
        "timestamp": Time.get_unix_time_from_system(),
        "user_id": user_id,
        "action": action,
        "result": result
    }
    audit_logs.append(log_entry)
    print_audit_log(log_entry)

func print_audit_log(log_entry: Dictionary):
    print("AUDIT: [%s] User: %s, Action: %s, Result: %s" % [
        log_entry["timestamp"],
        log_entry["user_id"],
        log_entry["action"],
        "SUCCESS" if log_entry["result"] else "FAILURE"
    ])

func save_audit_logs():
    var file = FileAccess.open("user://logs/audit.json", FileAccess.WRITE)
    file.store_string(JSON.stringify(audit_logs))
    file.close()
```

## 10. Diagrama de flujo de seguridad

```
[Usuario hace operación]
    ↓
[Input validation]
    ↓
[Validación exitosa?]
    ↓ No
[Error de validación]
    ↓
[Output validation (si online)]
    ↓
[Validación exitosa?]
    ↓ No
[Error de validación]
    ↓
[Tamper protection (savegame)]
    ↓
[Validación exitosa?]
    ↓ No
[Error de manipulación]
    ↓
[Duplication prevention]
    ↓
[Operación ya procesada?]
    ↓ Sí
[Error de duplicación]
    ↓
[Economy validation]
    ↓
[Validación exitosa?]
    ↓ No
[Error de economía adulterada]
    ↓
[Rate limiting check]
    ↓
[Rate limit excedido?]
    ↓ Sí
[Error de rate limit]
    ↓
[API authentication (si online)]
    ↓
[Autenticación exitosa?]
    ↓ No
[Error de autenticación]
    ↓
[Operación ejecutada]
    ↓
[Audit log]
    ↓
[Operación completada]
```

## 11. Configuración de seguridad

**Archivo: res://security/security_config.gd**

**Estructura:**
```gdscript
class_name SecurityConfig
extends Resource

@export var api_rate_limit: int = 100
@export var max_gold: int = 1000000
@export var max_items: int = 9999
@export var enable_checksum_validation: bool = true
@export var enable_signature_validation: bool = true
@export var enable_duplication_prevention: bool = true
@export var enable_economy_validation: bool = true
@export var enable_audit_logging: bool = true
```

## 12. Archivos de configuración

**Archivo: .env.example (plantilla, sin secrets)**
```
API_KEY=your_api_key_here
STEAM_API_KEY=your_steam_api_key_here
ANALYTICS_KEY=your_analytics_key_here
CRASH_REPORTING_KEY=your_crash_reporting_key_here
TAMPER_SECRET_KEY=your_tamper_secret_key_here
```

**Archivo: .gitignore**
```
.env
.env.local
.env.production
.secrets
*.key
*.pem
```

## 13. Scripts de CI/CD

**Archivo: scripts/security_check.sh**
```bash
#!/bin/bash
# Scanner de secrets en código
git-secrets scan

# Auditoría de dependencias
npm audit
cargo audit

# Scanners de seguridad
safety check
bandit -r .
```

## 14. Pruebas de seguridad

**Pruebas manuales:**
- Probar validación de entradas (tipos, rangos, formato)
- Probar validación de datos online (JSON schema, checksums)
- Probar prevención de manipulación (checksums, firmas digitales)
- Probar prevención de duplicación (idempotencia)
- Probar prevención de economía adulterada (validación de economía)
- Probar rate limiting
- Probar autenticación de APIs
- Probar auditoría de dependencias

**Pruebas automáticas:**
- Tests de validación de entradas
- Tests de validación de datos online
- Tests de prevención de manipulación
- Tests de prevención de duplicación
- Tests de prevención de economía adulterada
- Tests de rate limiting
- Tests de autenticación de APIs
