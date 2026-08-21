# Módulo 84: Música y Audio — Legal — Código

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:25:00

## Archivos a Crear

### 1. `scripts/legal/audio_legal_manager.gd` — Gestor legal de audio

```gdscript
class_name AudioLegalManager
extends Node

## Gestiona todos los aspectos legales del audio del juego.
## Licencias, créditos, validación y clearances.

signal license_added(license: AudioLicense)
signal credit_added(credit: AudioCredit)
signal validation_complete(result: AudioLegalValidationResult)

var licenses: Array[AudioLicense] = []
var credits: Array[AudioCredit] = []

## Valida que todo el audio tenga licencias y créditos
func validate_all_audio() -> AudioLegalValidationResult:
    var result = AudioLegalValidationResult.new()
    
    # Verificar que haya al menos una banda sonora
    if licenses.is_empty():
        result.add_error("No hay licencias de audio registradas")
    
    # Verificar que cada licencia sea válida
    for license in licenses:
        var validator = AudioLicenseValidator.new()
        var license_result = validator.validate_license(license)
        if not license_result.is_valid:
            for error in license_result.errors:
                result.add_error("Licencia '%s': %s" % [license.audio_name, error])
    
    # Verificar que cada artista tenga crédito
    for credit in credits:
        if credit.person_name.is_empty():
            result.add_error("Crédito con nombre vacío encontrado")
    
    validation_complete.emit(result)
    return result

## Agrega una licencia al inventario
func add_license(license: AudioLicense) -> void:
    licenses.append(license)
    license_added.emit(license)

## Agrega un crédito al registro
func add_credit(credit: AudioCredit) -> void:
    credits.append(credit)
    credit_added.emit(credit)

## Genera texto de créditos compacto para el juego
func generate_game_credits() -> String:
    var text := "MÚSICA Y AUDIO\n"
    text += "=".repeat(30) + "\n\n"
    
    # Agrupar por rol
    var composers: Array[String] = []
    var musicians: Array[String] = []
    var sound_designers: Array[String] = []
    
    for credit in credits:
        match credit.role.to_lower():
            "composer":
                composers.append(credit.person_name)
            "musician":
                musicians.append(credit.person_name)
            "sound designer":
                sound_designers.append(credit.person_name)
    
    if composers.size() > 0:
        text += "Banda Sonora: %s\n" % ", ".join(composers)
    if musicians.size() > 0:
        text += "Músicos: %s\n" % ", ".join(musicians)
    if sound_designers.size() > 0:
        text += "Sonido: %s\n" % ", ".join(sound_designers)
    
    return text

## Genera créditos detallados para archivo web
func generate_web_credits() -> String:
    var text := "# Créditos de Audio — Isla Ancestral\n\n"
    
    for credit in credits:
        text += "## %s\n" % credit.person_name
        text += "- **Rol:** %s\n" % credit.role
        text += "- **Contribución:** %s\n" % credit.contribution
        text += "- **Pistas:** %s\n" % ", ".join(credit.track_list)
        text += "- **Contrato:** %s\n" % credit.contract_reference
        text += "- **Estado de pago:** %s\n\n" % credit.payment_status
    
    return text

## Guarda créditos en archivo para build
func save_build_credits(output_path: String) -> void:
    DirAccess.make_dir_recursive_absolute(output_path.get_base_dir())
    
    var file = FileAccess.open(output_path, FileAccess.WRITE)
    if file:
        file.store_string(generate_game_credits())
        file.close()
```

### 2. `scripts/legal/audio_license_validator.gd` — Validador de licencias de audio

```gdscript
class_name AudioLicenseValidator
extends Node

## Valida licencias de audio contra requisitos del juego.

func validate_license(license: AudioLicense) -> AudioLicenseValidationResult:
    var result = AudioLicenseValidationResult.new()
    
    # Verificar que tenga nombre
    if license.audio_name.is_empty():
        result.add_error("Nombre de audio vacío")
    
    # Verificar tipo de licencia
    if license.license_type == LicenseType.UNKNOWN:
        result.add_warning("Tipo de licencia desconocido: %s" % license.audio_name)
    
    # Verificar uso comercial
    if not license.commercial_use:
        result.add_error("Licencia no permite uso comercial: %s" % license.audio_name)
    
    # Verificar perpetual vs subscription
    if not license.perpetual:
        result.add_warning("Licencia no perpetua (subscription): %s" % license.audio_name)
    
    # Verificar attribution
    if license.attribution_required and license.attribution_text.is_empty():
        result.add_error("Requiere attribution pero texto está vacío: %s" % license.audio_name)
    
    return result

## Verifica si una licencia permite uso comercial
func check_commercial_use(license: AudioLicense) -> bool:
    return license.commercial_use

## Genera crédito basado en la licencia
func generate_credit_from_license(license: AudioLicense) -> AudioCredit:
    var credit = AudioCredit.new()
    credit.person_name = license.licensor
    credit.role = "Licensor"
    credit.contribution = "Licencia de audio: %s" % license.audio_name
    credit.contract_reference = license.license_document_path
    return credit
```

### 3. `scripts/legal/audio_credits_generator.gd` — Generador de créditos

```gdscript
class_name AudioCreditsGenerator
extends Node

## Genera archivos de créditos de audio para builds y web.

const CREDITS_FILENAME := "AUDIO_CREDITS.txt"

## Genera créditos compactos para el menú del juego
func generate_game_credits(credits: Array[AudioCredit]) -> String:
    var text := ""
    var roles: Dictionary = {}
    
    for credit in credits:
        if not roles.has(credit.role):
            roles[credit.role] = []
        roles[credit.role].append(credit.person_name)
    
    for role in roles.keys():
        text += "%s: %s\n" % [role.to_upper(), ", ".join(roles[role])]
    
    return text

## Genera créditos detallados para archivo web
func generate_web_credits(credits: Array[AudioCredit]) -> String:
    var text := "# Créditos de Audio — Isla Ancestral\n\n"
    text += "Fecha de generación: %s\n\n" % Time.get_datetime_string_from_system()
    
    for credit in credits:
        text += "---\n"
        text += "## %s\n" % credit.person_name
        text += "- **Rol:** %s\n" % credit.role
        text += "- **Contribución:** %s\n" % credit.contribution
        if credit.track_list.size() > 0:
            text += "- **Pistas:** %s\n" % ", ".join(credit.track_list)
        text += "- **Contrato:** %s\n" % credit.contract_reference
        text += "- **Estado:** %s\n\n" % credit.payment_status
    
    return text

## Guarda créditos en directorio de build
func save_build_credits(credits: Array[AudioCredit], build_dir: String) -> void:
    DirAccess.make_dir_recursive_absolute(build_dir)
    var file = FileAccess.open(
        build_dir.path_join(CREDITS_FILENAME),
        FileAccess.WRITE
    )
    if file:
        file.store_string(generate_game_credits(credits))
        file.close()
```

### 4. `scripts/legal/audio_license.gd` — Resource de licencia de audio

```gdscript
class_name AudioLicense
extends Resource

## Resource que representa una licencia de audio.

@export var audio_name: String
@export var audio_type: AudioType
@export var license_type: LicenseType
@export var licensor: String
@export var license_scope: LicenseScope
@export var perpetual: bool
@export var commercial_use: bool
@export var attribution_required: bool
@export var attribution_text: String
@export var royalty_required: bool
@export var royalty_rate: float
@export var territory: String
@export var duration: String
@export var license_document_path: String
@export var notes: String

enum AudioType {
    ORIGINAL_COMPOSITION,
    STOCK_LIBRARY,
    AI_GENERATED,
    SAMPLE,
    SOUND_DESIGN,
    VOICE_ACTING
}

enum LicenseScope {
    EXCLUSIVE,
    NON_EXCLUSIVE,
    SOLE
}
```

### 5. `scripts/legal/audio_credit.gd` — Resource de crédito de audio

```gdscript
class_name AudioCredit
extends Resource

## Resource que representa un crédito de audio.

@export var person_name: String
@export var role: String
@export var contribution: String
@export var track_list: Array[String]
@export var contract_reference: String
@export var payment_status: String
```

## Archivos a Modificar

### 6. `export/build_script.gd` — Agregar paso de créditos de audio

**Cómo modificar:** Después del paso de licencias (M83), agregar:
```gdscript
# Audio credits step
var audio_legal = AudioLegalManager.new()
var audio_validation = audio_legal.validate_all_audio()

if audio_validation.has_errors():
    push_error("Audio legal validation failed:")
    for error in audio_validation.errors:
        push_error("  - " + error)
    return false  # Build fails

var credits_generator = AudioCreditsGenerator.new()
credits_generator.save_build_credits(audio_legal.credits, output_path)
```

## Integración con Sistemas Existentes

| Sistema | Cómo se conecta |
|---------|-----------------|
| Música (M41) | Lee composiciones para licenciar |
| Legal Contratos (M79) | Referencia a contratos de artistas |
| IA Generativa (M86) | Valida audio generado por IA |
| Build Pipeline (M117) | Incluye créditos en builds |
| Legal PI (M78) | Verifica propiedad intelectual |
