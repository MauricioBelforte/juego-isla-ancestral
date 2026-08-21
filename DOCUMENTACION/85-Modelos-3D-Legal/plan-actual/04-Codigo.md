# Módulo 85: Modelos 3D — Legal — Código

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:26:00

## Archivos a Crear

### 1. `scripts/legal/model_legal_manager.gd` — Gestor legal de modelos 3D

```gdscript
class_name ModelLegalManager
extends Node

## Gestiona todos los aspectos legales de modelos 3D del juego.

signal license_added(license: ModelLicense)
signal credit_added(credit: ModelCredit)
signal validation_complete(result: ModelLegalValidationResult)

var licenses: Array[ModelLicense] = []
var credits: Array[ModelCredit] = []

func validate_all_models() -> ModelLegalValidationResult:
    var result = ModelLegalValidationResult.new()
    
    if licenses.is_empty():
        result.add_error("No hay licencias de modelos registradas")
    
    for license in licenses:
        var validator = ModelLicenseValidator.new()
        var license_result = validator.validate_license(license)
        if not license_result.is_valid:
            for error in license_result.errors:
                result.add_error("Modelo '%s': %s" % [license.model_name, error])
    
    for credit in credits:
        if credit.artist_name.is_empty():
            result.add_error("Crédito con nombre vacío encontrado")
    
    validation_complete.emit(result)
    return result

func add_license(license: ModelLicense) -> void:
    licenses.append(license)
    license_added.emit(license)

func add_credit(credit: ModelCredit) -> void:
    credits.append(credit)
    credit_added.emit(credit)

func generate_credits_text() -> String:
    var text := "ARTE 3D\n"
    text += "=".repeat(30) + "\n\n"
    
    var artists: Array[String] = []
    for credit in credits:
        artists.append("%s - %s" % [credit.person_name, credit.role])
    
    text += "Modelado: %s\n" % ", ".join(artists)
    return text

func generate_credits_web() -> String:
    var text := "# Créditos de Arte 3D — Isla Ancestral\n\n"
    
    for credit in credits:
        text += "## %s\n" % credit.artist_name
        text += "- **Rol:** %s\n" % credit.role
        text += "- **Contribución:** %s\n" % credit.contribution
        text += "- **Modelos:** %s\n" % ", ".join(credit.model_list)
        text += "- **Contrato:** %s\n" % credit.contract_reference
        text += "- **Estado:** %s\n\n" % credit.payment_status
    
    return text

func save_build_credits(output_path: String) -> void:
    DirAccess.make_dir_recursive_absolute(output_path.get_base_dir())
    var file = FileAccess.open(output_path, FileAccess.WRITE)
    if file:
        file.store_string(generate_credits_text())
        file.close()
```

### 2. `scripts/legal/model_license_validator.gd` — Validador de licencias de modelos

```gdscript
class_name ModelLicenseValidator
extends Node

func validate_license(license: ModelLicense) -> ModelLicenseValidationResult:
    var result = ModelLicenseValidationResult.new()
    
    if license.model_name.is_empty():
        result.add_error("Nombre de modelo vacío")
    
    if license.license_type == LicenseType.UNKNOWN:
        result.add_warning("Tipo de licencia desconocido: %s" % license.model_name)
    
    if not license.commercial_use:
        result.add_error("Licencia no permite uso comercial: %s" % license.model_name)
    
    if not license.perpetual:
        result.add_warning("Licencia no perpetua: %s" % license.model_name)
    
    if license.attribution_required and license.attribution_text.is_empty():
        result.add_error("Requiere attribution pero texto vacío: %s" % license.model_name)
    
    return result

func check_commercial_use(license: ModelLicense) -> bool:
    return license.commercial_use

func check_redistribution(license: ModelLicense) -> bool:
    return license.redistribution_allowed
```

### 3. `scripts/legal/model_license.gd` — Resource de licencia de modelo

```gdscript
class_name ModelLicense
extends Resource

@export var model_name: String
@export var model_type: ModelType
@export var license_type: LicenseType
@export var licensor: String
@export var license_scope: LicenseScope
@export var perpetual: bool
@export var commercial_use: bool
@export var attribution_required: bool
@export var attribution_text: String
@export var redistribution_allowed: bool
@export var modification_allowed: bool
@export var territory: String
@export var license_document_path: String
@export var notes: String

enum ModelType {
    ORIGINAL,
    STOCK,
    OPEN_SOURCE,
    AI_GENERATED,
    MODIFIED
}

enum LicenseScope {
    EXCLUSIVE,
    NON_EXCLUSIVE,
    SOLE
}
```

### 4. `scripts/legal/model_credit.gd` — Resource de crédito de modelo

```gdscript
class_name ModelCredit
extends Resource

@export var artist_name: String
@export var role: String
@export var contribution: String
@export var model_list: Array[String]
@export var contract_reference: String
@export var payment_status: String
```

## Archivos a Modificar

### 5. `export/build_script.gd` — Agregar paso de modelos

**Cómo modificar:** Después del paso de audio (M84), agregar:
```gdscript
# 3D models legal step
var model_legal = ModelLegalManager.new()
var model_validation = model_legal.validate_all_models()

if model_validation.has_errors():
    push_error("3D model legal validation failed:")
    for error in model_validation.errors:
        push_error("  - " + error)
    return false  # Build fails
```

## Integración con Sistemas Existentes

| Sistema | Cómo se conecta |
|---------|-----------------|
| Arte 3D (M45) | Lee modelos para licenciar |
| Gestión de Assets (M71) | Valida licencias al importar |
| Validación de Builds (M72) | Verifica modelos en build |
| Legal Contratos (M79) | Referencia a contratos de artistas |
| IA Generativa (M86) | Valida modelos generados por IA |
