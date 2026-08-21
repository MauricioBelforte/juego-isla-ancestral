# Módulo 119: Actualizaciones — Código

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:28:00

## Archivos a Crear

### 1. `scripts/updates/update_manager.gd` — Gestor de actualizaciones

```gdscript
class_name UpdateManager
extends Node

## Gestor principal de actualizaciones del juego.

signal update_available(info: UpdateInfo)
signal update_progress(progress: float)
signal update_downloaded(info: UpdateInfo)
signal update_applied(info: UpdateInfo)
signal update_failed(error: String)

var current_version: GameVersion
var latest_version: GameVersion
var is_downloading: bool = false

func _ready() -> void:
    current_version = _load_current_version()

func check_for_updates() -> void:
    var checker = UpdateChecker.new()
    latest_version = await checker.check_latest()
    
    if latest_version and latest_version.is_newer_than(current_version):
        var info = UpdateInfo.new()
        info.version = latest_version
        update_available.emit(info)

func download_update(info: UpdateInfo) -> void:
    is_downloading = true
    var downloader = UpdateDownloader.new()
    
    var progress = await downloader.download(info.download_url)
    update_progress.emit(progress)
    
    if progress >= 1.0:
        update_downloaded.emit(info)
        is_downloading = false

func apply_update(info: UpdateInfo) -> void:
    # 1. Backup del save actual
    var migrator = SaveMigrator.new()
    migrator.backup_all_saves()
    
    # 2. Aplicar archivos nuevos
    var applier = UpdateApplier.new()
    var success = await applier.apply(info)
    
    if success:
        # 3. Migrar saves si es necesario
        if info.version.is_newer_than(current_version):
            migrator.migrate_all_saves(current_version, info.version)
        
        # 4. Guardar nueva versión
        _save_version(info.version)
        
        update_applied.emit(info)
    else:
        update_failed.emit("Failed to apply update")

func rollback() -> void:
    var rollback_manager = RollbackManager.new()
    rollback_manager.restore_previous_version()

func _load_current_version() -> GameVersion:
    if FileAccess.file_exists("user://version.tres"):
        return load("user://version.tres") as GameVersion
    return GameVersion.new()

func _save_version(version: GameVersion) -> void:
    ResourceSaver.save(version, "user://version.tres")
```

### 2. `scripts/updates/update_checker.gd` — Verificador de actualizaciones

```gdscript
class_name UpdateChecker
extends Node

## Verifica actualizaciones disponibles en la plataforma.

const STEAM_APP_ID = 0  # Reemplazar con ID real

func check_latest() -> GameVersion:
    # Intentar verificar vía Steam
    if Engine.has_singleton("Steam"):
        return await _check_steam()
    
    # Fallback: verificar vía HTTP
    return await _check_http()

func _check_steam() -> GameVersion:
    var steam = Engine.get_singleton("Steam")
    # Implementación específica de Steam
    return null

func _check_http() -> GameVersion:
    var http = HTTPRequest.new()
    add_child(http)
    
    var error = http.request("https://api.example.com/latest-version")
    if error != OK:
        return null
    
    var response = await http.request_completed
    var result = response[0]
    var code = response[1]
    var body = response[2]
    
    if code == 200:
        var json = JSON.parse_string(body.get_string_from_utf8())
        if json:
            var version = GameVersion.new()
            version.major = json.get("major", 0)
            version.minor = json.get("minor", 0)
            version.patch = json.get("patch", 0)
            version.build = json.get("build", 0)
            return version
    
    return null
```

### 3. `scripts/updates/save_migrator.gd` — Migrador de saves

```gdscript
class_name SaveMigrator
extends Node

## Migra saves a nueva versión del juego.

const SAVES_DIR = "user://saves/"
const BACKUP_DIR = "user://saves/backups/"

func migrate_all_saves(from_version: GameVersion, to_version: GameVersion) -> void:
    var dir = DirAccess.open(SAVES_DIR)
    if not dir:
        return
    
    dir.list_dir_begin()
    var file_name = dir.get_next()
    
    while file_name != "":
        if file_name.ends_with(".tres"):
            var save_path = SAVES_DIR.path_join(file_name)
            migrate_save(save_path, from_version, to_version)
        file_name = dir.get_next()

func migrate_save(save_path: String, from_version: GameVersion, to_version: GameVersion) -> bool:
    # Buscar migración necesaria
    var migration = _find_migration(from_version, to_version)
    if not migration:
        return true  # No necesita migración
    
    # Ejecutar migración
    var script = load(migration.migration_script)
    if script:
        var instance = script.new()
        var success = instance.migrate(save_path)
        
        if success:
            # Verificar integridad
            return _verify_save(save_path)
    
    return false

func backup_all_saves() -> void:
    DirAccess.make_dir_recursive_absolute(BACKUP_DIR)
    
    var dir = DirAccess.open(SAVES_DIR)
    if not dir:
        return
    
    dir.list_dir_begin()
    var file_name = dir.get_next()
    var timestamp = Time.get_datetime_string_from_system()
    
    while file_name != "":
        if file_name.ends_with(".tres"):
            var source = SAVES_DIR.path_join(file_name)
            var dest = BACKUP_DIR.path_join(file_name.replace(".tres", "_backup_%s.tres" % timestamp))
            DirAccess.copy_absolute(source, dest)
        file_name = dir.get_next()

func _find_migration(from: GameVersion, to: GameVersion) -> SaveMigration:
    # Buscar migración en el array de migraciones
    # Retornar null si no hay migración necesaria
    return null

func _verify_save(save_path: String) -> bool:
    var save = ResourceLoader.load(save_path)
    return save != null
```

### 4. `scripts/updates/game_version.gd` — Resource de versión

```gdscript
class_name GameVersion
extends Resource

@export var major: int = 0
@export var minor: int = 0
@export var patch: int = 0
@export var build: int = 0
@export var date: String = ""

func to_string() -> String:
    return "v%s.%s.%s.%s (%s)" % [major, minor, patch, build, date]

func is_newer_than(other: GameVersion) -> bool:
    if major != other.major: return major > other.major
    if minor != other.minor: return minor > other.minor
    if patch != other.patch: return patch > other.patch
    return build > other.build

func is_same_major_minor(other: GameVersion) -> bool:
    return major == other.major and minor == other.minor
```

## Archivos a Modificar

### 5. `project.godot` — Agregar autoload

**Cómo modificar:** Agregar:
```
[autoload]
UpdateManager="*res://scripts/updates/update_manager.gd"
```

## Integración con Sistemas Existentes

| Sistema | Cómo se conecta |
|---------|-----------------|
| Build System (M117) | Genera versiones y metadata |
| Guardado (M59) | Migra saves entre versiones |
| DLC (M120) | Verifica compatibilidad de versión |
| Soporte (M121) | Registra actualizaciones instaladas |
| Steam/GOG | API de plataforma para updates |
