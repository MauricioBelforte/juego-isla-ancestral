# Módulo 83: Licencias de Software — Código

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:24:00

## Archivos a Crear

### 1. `scripts/licensing/license_scanner.gd` — Escáner de licencias

```gdscript
class_name LicenseScanner
extends Node

## Escáner automático de licencias de dependencias del proyecto.
## Detecta dependencias, extrae licencias y genera inventario.

signal scan_complete(inventory: Array[LicenseProfile])
signal scan_error(error: String)

# Directorios de búsqueda
const ADDONS_DIR := "res://addons/"
const SCRIPTS_DIR := "res://scripts/"
const LICENSE_FILES := ["LICENSE", "LICENSE.txt", "LICENSE.md", "COPYING", "COPYING.txt"]
const PLUGIN_CONFIG := "plugin.cfg"

## Escanea todo el proyecto y retorna inventario de licencias
func scan_project() -> Array[LicenseProfile]:
    var inventory: Array[LicenseProfile] = []
    
    # 1. Escanear engine (siempre MIT)
    inventory.append(_create_godot_profile())
    
    # 2. Escanear addons
    var addons = _scan_directory(ADDONS_DIR)
    inventory.append_array(addons)
    
    # 3. Escanear dependencias externas detectadas
    var externals = _scan_external_deps()
    inventory.append_array(externals)
    
    scan_complete.emit(inventory)
    return inventory

## Escanea un addon específico
func scan_addon(addon_path: String) -> LicenseProfile:
    var profile = LicenseProfile.new()
    profile.dependency_name = addon_path.get_file()
    
    # Buscar plugin.cfg para metadata
    var config_path = addon_path.path_join(PLUGIN_CONFIG)
    if FileAccess.file_exists(config_path):
        var config = ConfigFile.new()
        config.load(config_path)
        profile.dependency_name = config.get_value("plugin", "name", addon_path.get_file())
        profile.version = config.get_value("plugin", "version", "unknown")
    
    # Buscar archivo de licencia
    profile.license_type = _detect_license(addon_path)
    
    return profile

## Detecta tipo de licencia buscando archivos de licencia
func _detect_license(search_path: String) -> LicenseLicenseType:
    for license_file in LICENSE_FILES:
        var full_path = search_path.path_join(license_file)
        if FileAccess.file_exists(full_path):
            var content = _read_file(full_path)
            return _classify_license(content)
    
    # Buscar recursivamente en subdirectorios
    var dir = DirAccess.open(search_path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if dir.current_is_dir() and not file_name.begins_with("."):
                var sub_result = _detect_license(search_path.path_join(file_name))
                if sub_result != LicenseType.UNKNOWN:
                    return sub_result
            file_name = dir.get_next()
    
    return LicenseType.UNKNOWN

## Clasifica licencia basándose en contenido del texto
func _classify_license(license_text: String) -> LicenseType:
    var lower = license_text.to_lower()
    
    if "mit license" in lower or "permission is hereby granted, free of charge" in lower:
        return LicenseType.MIT
    elif "apache license, version 2.0" in lower:
        return LicenseType.APACHE_2
    elif "gnu general public license, version 2" in lower and "version 3" not in lower:
        return LicenseType.GPL_2
    elif "gnu general public license, version 3" in lower:
        return LicenseType.GPL_3
    elif "gnu lesser general public license" in lower:
        return LicenseType.LGPL
    elif "mozilla public license, version 2.0" in lower:
        return LicenseType.MPL_2
    elif "gnu affero general public license" in lower:
        return LicenseType.AGPL
    elif "bsd 2-clause" in lower or "redistribution and use in source and binary" in lower:
        return LicenseType.BSD_2
    elif "bsd 3-clause" in lower or "neither the name of the" in lower:
        return LicenseType.BSD_3
    elif "creative commons" in lower and "noncommercial" in lower:
        return LicenseType.CC_BY_NC
    elif "creative commons" in lower and "attribution" in lower:
        return LicenseType.CC_BY
    elif "public domain" in lower or "cc0" in lower:
        return LicenseType.CC0
    else:
        return LicenseType.UNKNOWN
```

### 2. `scripts/licensing/license_validator.gd` — Validador de compatibilidad

```gdscript
class_name LicenseValidator
extends Node

## Valida compatibilidad de licencias entre dependencias del proyecto.

var policy: LicensePolicy

func validate(inventory: Array[LicenseProfile]) -> LicenseValidationResult:
    var result = LicenseValidationResult.new()
    
    for profile in inventory:
        # Verificar si la licencia está permitida
        if profile.license_type in policy.prohibited_licenses:
            result.add_error("Licencia prohibida: %s (%s)" % [
                profile.dependency_name,
                LicenseType.keys()[profile.license_type]
            ])
        
        # Verificar si la licencia está en la lista de permitidas
        if policy.allowed_licenses.size() > 0:
            if profile.license_type not in policy.allowed_licenses:
                result.add_warning("Licencia no verificada: %s (%s)" % [
                    profile.dependency_name,
                    LicenseType.keys()[profile.license_type]
                ])
        
        # Verificar uso comercial
        if not profile.commercial_use:
            result.add_warning("Uso comercial no permitido: %s" % profile.dependency_name)
        
        # Verificar copyleft
        if _is_copyleft(profile.license_type):
            match policy.copyleft_mode:
                CopyleftMode.DENY:
                    result.add_error("Copyleft denegado: %s (%s)" % [
                        profile.dependency_name,
                        LicenseType.keys()[profile.license_type]
                    ])
                CopyleftMode.ISOLATE:
                    result.add_info("Copyleft requiere aislamiento: %s" % profile.dependency_name)
                CopyleftMode.ALLOW:
                    pass  # OK
    
    return result

## Verifica si dos licencias son compatibles
func check_compatibility(license_a: LicenseType, license_b: LicenseType) -> bool:
    # Reglas básicas de compatibilidad
    if license_a == LicenseType.GPL_3 and license_b == LicenseType.MIT:
        return true  # GPL-3 puede incluir MIT
    if license_a == LicenseType.MIT and license_b == LicenseType.GPL_3:
        return false  # MIT no puede ser relicenciado como GPL-3
    
    # Por defecto, permitir (la validación detallada requiere análisis específico)
    return true

## Verifica si alguna licencia requiere source code offer
func requires_source_offer(inventory: Array[LicenseProfile]) -> bool:
    for profile in inventory:
        if profile.source_offer_required:
            return true
    return false

func _is_copyleft(license_type: LicenseType) -> bool:
    return license_type in [
        LicenseType.GPL_2, LicenseType.GPL_3,
        LicenseType.LGPL, LicenseType.AGPL
    ]
```

### 3. `scripts/licensing/license_notice_generator.gd` — Generador de atribuciones

```gdscript
class_name LicenseNoticeGenerator
extends Node

## Genera archivos de notice/atribución para builds de distribución.

const NOTICE_FILENAME := "THIRD_PARTY_LICENSES.txt"
const LICENSES_DIR := "licenses"

## Genera el contenido del archivo de notices
func generate_notice(inventory: Array[LicenseProfile]) -> String:
    var notice := "# Third-Party Software Licenses\n"
    notice += "# Generated by Isla Ancestral Build System\n"
    notice += "# This file is auto-generated. Do not edit manually.\n\n"
    
    for profile in inventory:
        notice += "=" .repeat(60) + "\n"
        notice += "Name: %s\n" % profile.dependency_name
        notice += "Version: %s\n" % profile.version
        notice += "License: %s\n" % LicenseType.keys()[profile.license_type]
        notice += "URL: %s\n" % profile.license_url if profile.license_url != "" else ""
        notice += "-".repeat(60) + "\n"
        notice += profile.license_text + "\n\n"
    
    return notice

## Guarda notices en directorio especificado
func save_notices(inventory: Array[LicenseProfile], output_dir: String) -> void:
    DirAccess.make_dir_recursive_absolute(output_dir)
    
    # Generar archivo principal
    var notice = generate_notice(inventory)
    var file = FileAccess.open(
        output_dir.path_join(NOTICE_FILENAME),
        FileAccess.WRITE
    )
    if file:
        file.store_string(notice)
        file.close()
    
    # Copiar licencias originales a subdirectorio
    var licenses_path = output_dir.path_join(LICENSES_DIR)
    DirAccess.make_dir_recursive_absolute(licenses_path)
    
    for profile in inventory:
        if profile.license_url != "":
            var license_file = FileAccess.open(
                licenses_path.path_join(profile.dependency_name + ".txt"),
                FileAccess.WRITE
            )
            if license_file:
                license_file.store_string(profile.license_text)
                license_file.close()

## Incluye notices en build output
func include_in_build(inventory: Array[LicenseProfile], build_dir: String) -> void:
    save_notices(inventory, build_dir)
```

## Archivos a Modificar

### 4. `export/build_script.gd` — Agregar paso de licencias

**Cómo modificar:** Después del paso de validación de builds (M72), agregar:
```gdscript
# Licenses step
var license_scanner = LicenseScanner.new()
var license_inventory = license_scanner.scan_project()

var license_validator = LicenseValidator.new()
license_validator.policy = preload("res://resources/licensing/default_policy.tres")
var validation_result = license_validator.validate(license_inventory)

if validation_result.has_errors():
    push_error("License validation failed:")
    for error in validation_result.errors:
        push_error("  - " + error)
    return false  # Build fails

var notice_generator = LicenseNoticeGenerator.new()
notice_generator.include_in_build(license_inventory, output_path)
```

### 5. `project.godot` — Agregar autoload de licencias

**Cómo modificar:** Agregar:
```
[autoload]
LicenseScanner="*res://scripts/licensing/license_scanner.gd"
```

## Integración con Sistemas Existentes

| Sistema | Cómo se conecta |
|---------|-----------------|
| Gestión de Dependencias (M55) | Lee inventario de dependencias |
| Build Pipeline (M117) | Agrega paso de validación de licencias |
| Validación de Builds (M72) | Agrega checks de licencia |
| Assets de Terceros (M71) | Verifica licencias de assets |
