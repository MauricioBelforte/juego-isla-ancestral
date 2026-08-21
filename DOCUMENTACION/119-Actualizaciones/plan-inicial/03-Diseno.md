# Módulo 119: Actualizaciones — Diseño

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:28:00

## 1. Flujo de Actualización

```
[Conexión a Internet]
       │
       ▼
[UpdateChecker] ──► Verificar versión actual vs. última disponible
       │
       ▼
[¿Hay actualización?] ── NO ──► [Sin cambios]
       │
      SÍ
       │
       ▼
[Notificar al Jugador] ──► Popup en menú principal
       │
       ▼
[Jugador Acepta] ──► [Descargar Update]
       │
       ▼
[Backup Save] ──► Guardar copia de seguridad
       │
       ▼
[Aplicar Update] ──► Instalar archivos nuevos
       │
       ▼
[Migrar Save] ──► Convertir save a nuevo schema
       │
       ▼
[Reiniciar Juego] ──► Cargar nueva versión
       │
       ▼
[¿Funciona?] ── SÍ ──► [Eliminar backup antiguo]
       │
      NO
       │
       ▼
[Rollback] ──► Restaurar versión anterior + save
```

## 2. Recursos de Datos

### GameVersion (Resource)

```gdscript
class_name GameVersion
extends Resource

@export var major: int
@export var minor: int
@export var patch: int
@export var build: int
@export var date: String

func to_string() -> String:
    return "v%s.%s.%s.%s (%s)" % [major, minor, patch, build, date]

func is_newer_than(other: GameVersion) -> bool:
    if major != other.major: return major > other.major
    if minor != other.minor: return minor > other.minor
    if patch != other.patch: return patch > other.patch
    return build > other.build
```

### UpdateInfo (Resource)

```gdscript
class_name UpdateInfo
extends Resource

@export var version: GameVersion
@export var title: String
@export var description: String
@export var changelog: Array[String]
@export var download_url: String
@export var file_size_mb: int
@export var is_critical: bool
@export var required_version: GameVersion
@export var release_date: String
```

### SaveMigration (Resource)

```gdscript
class_name SaveMigration
extends Resource

@export var from_version: GameVersion
@export var to_version: GameVersion
@export var migration_script: String        # Ruta al script de migración
@export var backup_required: bool
@export var description: String
```

## 3. Nodos Principales

### UpdateManager (Node)

```gdscript
class_name UpdateManager
extends Node

## Gestor principal de actualizaciones del juego.

signal update_available(info: UpdateInfo)
signal update_downloaded(info: UpdateInfo)
signal update_applied(info: UpdateInfo)
signal update_failed(error: String)

var current_version: GameVersion
var latest_version: GameVersion

func check_for_updates() -> void:
    # Verificar con la API de la plataforma
    # Emitir signal si hay actualización

func download_update(info: UpdateInfo) -> void:
    # Descargar actualización
    # Mostrar progreso
    # Emitir signal al completar

func apply_update(info: UpdateInfo) -> void:
    # Backup del save actual
    # Aplicar archivos nuevos
    # Migrar save si es necesario
    # Reiniciar juego

func rollback() -> void:
    # Restaurar versión anterior
    # Restaurar save desde backup
```

### UpdateChecker (Node)

```gdscript
class_name UpdateChecker
extends Node

## Verifica actualizaciones disponibles.

func check_steam() -> UpdateInfo:
    # Verificar vía Steamworks API
    pass

func check_gog() -> UpdateInfo:
    # Verificar vía GOG Galaxy
    pass

func check_manual(url: String) -> UpdateInfo:
    # Verificar vía URL manual
    pass
```

### SaveMigrator (Node)

```gdscript
class_name SaveMigrator
extends Node

## Migra saves a nueva versión del juego.

func migrate_save(save_path: String, from_version: GameVersion, to_version: GameVersion) -> bool:
    # Buscar migración necesaria
    # Ejecutar script de migración
    # Verificar integridad del save migrado
    # Retornar éxito/fallo

func backup_save(save_path: String) -> String:
    # Crear copia de seguridad
    # Retornar ruta del backup

func restore_save(backup_path: String) -> bool:
    # Restaurar save desde backup
    pass
```

## 4. Integración con Plataformas

### Steam (Steamworks)

```
[Steam API] ──► SteamApp.UpdateAvailable()
                     │
                     ▼
               [Download via Steam]
                     │
                     ▼
               [Auto-apply on restart]
```

### GOG (Galaxy)

```
[GOG API] ──► Galaxy.UpdateAvailable()
                    │
                    ▼
              [Download via GOG]
                    │
                    ▼
              [Apply on restart]
```

### Manual (itch.io, etc.)

```
[Manual Check] ──► HTTP GET to URL
                         │
                         ▼
                   [Compare versions]
                         │
                         ▼
                   [Download ZIP]
                         │
                         ▼
                   [Extract + Apply]
```

## 5. Compatibilidad de Saves

### Estrategia de Migración

```
[Save Version X] ──► Migración 1 ──► [Save Version X+1]
                                            │
                                            ▼
                                      Migración 2
                                            │
                                            ▼
                                      [Save Version X+2]
```

### Backup Automático

```
user://saves/
├── save_001.tres              ← Save actual
├── save_001_backup_v1.2.2.tres  ← Backup antes de migrar
└── save_001_backup_v1.2.3.tres  ← Backup de versión anterior
```
