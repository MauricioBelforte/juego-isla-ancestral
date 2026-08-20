**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 03-Diseno.md — Módulo 120: DLC y Expansiones

## 1. Arquitectura del módulo

```
DLC y Expansiones (sistema de contenido post-lanzamiento)
├── Estrategia de DLC
│   ├── Frecuencia (trimestral/semestral/anual)
│   ├── Tamaño (pequeño/mediano/grande)
│   └── Temática (coherente con visión cozy)
├── Contenido del juego base
│   ├── Historia principal completa
│   ├── 7 islas base
│   ├── 13 biomas base
│   ├── Sistemas core
│   ├── Música base
│   ├── 30 NPCs base
│   └── Sistemas de transporte y navegación
├── Nuevas islas DLC
│   ├── Isla de Hielo (DLC 1)
│   ├── Isla de Volcán (DLC 2)
│   └── Isla de Bosque (DLC 3)
├── Nuevas historias DLC
│   ├── Historias secundarias opcionales
│   ├── 2-3 cadenas por DLC
│   └── Sellos nuevos (opcional)
├── Nuevos NPCs DLC
│   ├── 5-10 NPCs por DLC
│   ├── Rutinas diarias y semanales
│   ├── Diálogos y amistad
│   └── Misiones opcionales
├── Nuevos sistemas DLC
│   ├── Sistema de acuicultura
│   ├── Sistema de jardinería
│   ├── Sistema de fotografía avanzada
│   └── Sistema de colecciones avanzadas
├── Nuevos biomas DLC
│   ├── 2-3 biomas nuevos por DLC
│   ├── Flora y fauna específicas
│   └── Recursos específicos
├── Nuevas músicas DLC
│   ├── 10-15 tracks nuevos por DLC
│   ├── Leitmotifs de NPCs nuevos
│   └── Leitmotifs de islas nuevas
├── Nuevas colecciones DLC
│   ├── Colecciones opcionales
│   ├── 10-20 items por colección
│   └── Recompensas cosméticas
├── Nuevas ruinas DLC
│   ├── 2-3 ruinas/tempos nuevos por DLC
│   ├── Puzzles opcionales
│   └── Sellos nuevos (opcional)
├── Compatibilidad DLC
│   ├── Compatibilidad con juego base
│   ├── Compatibilidad con otros DLC
│   ├── Backward compatibility
│   └── Desinstalación
├── Precios DLC
│   ├── DLC pequeños: USD 5-10
│   ├── DLC medianos: USD 10-20
│   └── DLC grandes: USD 20-30
├── Bundles DLC
│   ├── Season Pass (3 DLC por USD 20-25)
│   ├── Bundle Completo (todos DLC por USD 50-60)
│   └── Bundles temáticos
├── Marketing DLC
│   ├── Trailers específicos
│   ├── Screenshots
│   ├── Anuncios Steam
│   └── Social Media
└── Evitar bloquear contenido esencial
    ├── DLC no bloquea contenido esencial
    ├── DLC es completamente opcional
    └── DLC no es necesario para disfrutar del juego base
```

## 2. Estructura de DLC

**Estructura de DLC:**
```
DLC/
├── Isla de Hielo/
│   ├── islas/
│   │   ├── isla_hielo.tscn
│   │   └── data_isla_hielo.json
│   ├── biomas/
│   │   ├── hielo/
│   │   │   ├── bloque_hielo.tscn
│   │   │   └── data_hielo.json
│   │   └── nieve/
│   │       ├── bloque_nieve.tscn
│   │       └── data_nieve.json
│   ├── npcs/
│   │   ├── npc_hielo_1.tscn
│   │   ├── npc_hielo_2.tscn
│   │   └── data_npcs_hielo.json
│   ├── historias/
│   │   ├── historia_hielo_1.json
│   │   └── historia_hielo_2.json
│   ├── sistemas/
│   │   ├── sistema_acuicultura.gd
│   │   └── data_acuicultura.json
│   ├── ruinas/
│   │   ├── templo_hielo.tscn
│   │   └── data_templo_hielo.json
│   ├── musica/
│   │   ├── track_hielo_1.ogg
│   │   ├── track_hielo_2.ogg
│   │   └── leitmotif_npc_hielo_1.ogg
│   ├── colecciones/
│   │   ├── coleccion_peces_articos.json
│   │   └── coleccion_cristales_hielo.json
│   └── metadata.json
└── manifest.json
```

## 3. manifest.json de DLC

**Archivo: manifest.json**

**Estructura:**
```json
{
  "dlc_id": "dlc_hielo",
  "dlc_name": "Isla de Hielo",
  "dlc_version": "1.0.0",
  "dlc_size": "500MB",
  "dlc_price": "9.99",
  "dlc_description": "Nueva isla de hielo con nuevos NPCs, historia secundaria, sistema de acuicultura y puzzles opcionales.",
  "dlc_requires_base_game": true,
  "dlc_requires_other_dlc": [],
  "dlc_content": {
    "islands": ["isla_hielo"],
    "biomes": ["hielo", "nieve"],
    "npcs": ["npc_hielo_1", "npc_hielo_2", "npc_hielo_3", "npc_hielo_4", "npc_hielo_5"],
    "historias": ["historia_hielo_1", "historia_hielo_2"],
    "sistemas": ["sistema_acuicultura"],
    "ruinas": ["templo_hielo"],
    "musica": ["track_hielo_1", "track_hielo_2", "leitmotif_npc_hielo_1"],
    "colecciones": ["coleccion_peces_articos", "coleccion_cristales_hielo"]
  },
  "dlc_compatibility": {
    "base_game_version": "1.0.0",
    "other_dlc": [],
    "backward_compatible": true
  }
}
```

## 4. Sistema de carga de DLC

**Archivo: res://dlc/dlc_manager.gd**

**Estructura:**
```gdscript
class_name DLCManager
extends Node

signal dlc_loaded(dlc_id: String)
signal dlc_unloaded(dlc_id: String)

var loaded_dlcs: Dictionary = {}
var available_dlcs: Dictionary = {}

func _ready():
    load_available_dlcs()

func load_available_dlcs():
    # Cargar DLCs disponibles en sistema de archivos
    var dlc_dir = "user://dlc/"
    var dir = DirAccess.open(dlc_dir)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".json"):
                var dlc_path = dlc_dir + file_name
                var file = FileAccess.open(dlc_path, FileAccess.READ)
                if file:
                    var json = JSON.parse_string(file.get_as_text())
                    if json.error == OK:
                        var dlc_data = json.result
                        available_dlcs[dlc_data.dlc_id] = dlc_data
                    file.close()
            file_name = dir.get_next()
        dir.list_dir_end()

func load_dlc(dlc_id: String):
    if not available_dlcs.has(dlc_id):
        print("DLC not available: %s" % dlc_id)
        return
    
    var dlc_data = available_dlcs[dlc_id]
    if loaded_dlcs.has(dlc_id):
        print("DLC already loaded: %s" % dlc_id)
        return
    
    # Cargar contenido del DLC
    load_dlc_content(dlc_data)
    loaded_dlcs[dlc_id] = dlc_data
    dlc_loaded.emit(dlc_id)

func unload_dlc(dlc_id: String):
    if not loaded_dlcs.has(dlc_id):
        print("DLC not loaded: %s" % dlc_id)
        return
    
    var dlc_data = loaded_dlcs[dlc_id]
    unload_dlc_content(dlc_data)
    loaded_dlcs.erase(dlc_id)
    dlc_unloaded.emit(dlc_id)

func load_dlc_content(dlc_data: Dictionary):
    # Cargar islas del DLC
    for island_id in dlc_data.dlc_content.islands:
        load_island(island_id)
    
    # Cargar biomas del DLC
    for biome_id in dlc_data.dlc_content.biomas:
        load_biome(biome_id)
    
    # Cargar NPCs del DLC
    for npc_id in dlc_data.dlc_content.npcs:
        load_npc(npc_id)
    
    # Cargar historias del DLC
    for historia_id in dlc_data.dlc_content.historias:
        load_historia(historia_id)
    
    # Cargar sistemas del DLC
    for sistema_id in dlc_data.dlc_content.sistemas:
        load_sistema(sistema_id)
    
    # Cargar ruinas del DLC
    for ruin_id in dlc_data.dlc_content.ruinas:
        load_ruin(ruin_id)
    
    # Cargar música del DLC
    for track_id in dlc_data.dlc_content.musica:
        load_music(track_id)
    
    # Cargar colecciones del DLC
    for coleccion_id in dlc_data.dlc_content.colecciones:
        load_coleccion(coleccion_id)

func unload_dlc_content(dlc_data: Dictionary):
    # Descargar contenido del DLC
    # (implementación similar a load_dlc_content pero descargando)
    pass

func is_dlc_loaded(dlc_id: String) -> bool:
    return loaded_dlcs.has(dlc_id)

func is_dlc_available(dlc_id: String) -> bool:
    return available_dlcs.has(dlc_id)
```

## 5. Sistema de validación de compatibilidad

**Archivo: res://dlc/dlc_compatibility_checker.gd**

**Estructura:**
```gdscript
class_name DLCCompatibilityChecker
extends Node

func check_compatibility(dlc_data: Dictionary) -> bool:
    # Verificar versión del juego base
    var base_game_version = get_base_game_version()
    var required_version = dlc_data.dlc_compatibility.base_game_version
    if not is_version_compatible(base_game_version, required_version):
        print("DLC not compatible with base game version")
        return false
    
    # Verificar otros DLC requeridos
    for required_dlc in dlc_data.dlc_compatibility.other_dlc:
        if not DLCManager.is_dlc_loaded(required_dlc):
            print("DLC requires other DLC: %s" % required_dlc)
            return false
    
    return true

func get_base_game_version() -> String:
    # Obtener versión del juego base
    return ProjectSettings.get_setting("application/config/version", "1.0.0")

func is_version_compatible(current_version: String, required_version: String) -> bool:
    # Comparación de versiones (simplificada)
    # En implementación real, usar comparación semántica de versiones
    return current_version == required_version
```

## 6. Sistema de desinstalación de DLC

**Archivo: res://dlc/dlc_uninstaller.gd**

**Estructura:**
```gdscript
class_name DLCUninstaller
extends Node

func uninstall_dlc(dlc_id: String):
    if not DLCManager.is_dlc_loaded(dlc_id):
        print("DLC not loaded: %s" % dlc_id)
        return
    
    # Marcar savegames con contenido DLC como incompletos
    mark_savegames_as_incomplete(dlc_id)
    
    # Descargar DLC
    DLCManager.unload_dlc(dlc_id)
    
    # Eliminar archivos del DLC
    delete_dlc_files(dlc_id)
    
    # Actualizar savegames
    update_savegames()

func mark_savegames_as_incomplete(dlc_id: String):
    # Marcar savegames con contenido DLC como incompletos
    var savegames_dir = "user://savegames/"
    var dir = DirAccess.open(savegames_dir)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".json"):
                var savegame_path = savegames_dir + file_name
                var file = FileAccess.open(savegame_path, FileAccess.READ)
                if file:
                    var json = JSON.parse_string(file.get_as_text())
                    if json.error == OK:
                        var savegame_data = json.result
                        if savegame_data.has("dlc_content"):
                            if savegame_data.dlc_content.has(dlc_id):
                                savegame_data.dlc_content[dlc_id] = "incomplete"
                                file.close()
                                file = FileAccess.open(savegame_path, FileAccess.WRITE)
                                file.store_string(JSON.stringify(savegame_data))
                    file.close()
            file_name = dir.get_next()
        dir.list_dir_end()

func delete_dlc_files(dlc_id: String):
    # Eliminar archivos del DLC
    var dlc_dir = "user://dlc/" + dlc_id + "/"
    var dir = DirAccess.open(dlc_dir)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            var file_path = dlc_dir + file_name
            DirAccess.remove_absolute(file_path)
            file_name = dir.get_next()
        dir.list_dir_end()
        DirAccess.remove_absolute(dlc_dir)

func update_savegames():
    # Actualizar savegames para reflejar DLC desinstalado
    # (implementación específica según lógica de savegame)
    pass
```

## 7. Sistema de bundles

**Archivo: res://dlc/dlc_bundle_manager.gd**

**Estructura:**
```gdscript
class_name DLCBundleManager
extends Node

var bundles: Dictionary = {}

func _ready():
    load_bundles()

func load_bundles():
    # Cargar bundles disponibles
    var bundles_file = FileAccess.open("res://dlc/bundles.json", FileAccess.READ)
    if bundles_file:
        var json = JSON.parse_string(bundles_file.get_as_text())
        if json.error == OK:
            bundles = json.result
        bundles_file.close()

func get_bundle_price(bundle_id: String) -> float:
    if bundles.has(bundle_id):
        return bundles[bundle_id].bundle_price
    return 0.0

func get_bundle_dlc_ids(bundle_id: String) -> Array:
    if bundles.has(bundle_id):
        return bundles[bundle_id].bundle_dlcs
    return []

func calculate_bundle_discount(bundle_id: String) -> float:
    var dlc_ids = get_bundle_dlc_ids(bundle_id)
    var individual_price = 0.0
    for dlc_id in dlc_ids:
        individual_price += get_dlc_price(dlc_id)
    var bundle_price = get_bundle_price(bundle_id)
    var discount = 1.0 - (bundle_price / individual_price)
    return discount

func get_dlc_price(dlc_id: String) -> float:
    # Obtener precio individual de DLC
    # (implementación específica según plataforma de distribución)
    return 0.0
```

## 8. Configuración de bundles

**Archivo: res://dlc/bundles.json**

**Estructura:**
```json
{
  "season_pass_2024": {
    "bundle_id": "season_pass_2024",
    "bundle_name": "Season Pass 2024",
    "bundle_price": 24.99,
    "bundle_dlcs": ["dlc_hielo", "dlc_volcan", "dlc_bosque"],
    "bundle_description": "Incluye 3 DLC lanzados en 2024 con descuento de ~30%."
  },
  "bundle_completo": {
    "bundle_id": "bundle_completo",
    "bundle_name": "Bundle Completo",
    "bundle_price": 59.99,
    "bundle_dlcs": ["dlc_hielo", "dlc_volcan", "dlc_bosque"],
    "bundle_description": "Incluye todos los DLC lanzados con descuento de ~40%."
  },
  "bundle_islas": {
    "bundle_id": "bundle_islas",
    "bundle_name": "Bundle de Islas",
    "bundle_price": 24.99,
    "bundle_dlcs": ["dlc_hielo", "dlc_volcan", "dlc_bosque"],
    "bundle_description": "Incluye todos los DLC de islas con descuento de ~30%."
  }
}
```

## 9. Diagrama de flujo de DLC

```
[Usuario compra DLC]
    ↓
[Plataforma de distribución (Steam) descarga DLC]
    ↓
[DLCManager detecta DLC disponible]
    ↓
[DLCManager carga DLC]
    ↓
[DLCCompatibilityChecker verifica compatibilidad]
    ↓
[Compatibilidad OK?]
    ↓ No
[Error: DLC no compatible]
    ↓
[DLCManager carga contenido DLC]
    ↓
[DLCManager registra DLC como cargado]
    ↓
[DLC disponible en juego]
    ↓
[Usuario accede a contenido DLC]
    ↓
[Usuario puede desinstalar DLC]
    ↓
[DLCUninstaller marca savegames como incompletos]
    ↓
[DLCUninstaller descarga DLC]
    ↓
[DLCUninstaller elimina archivos DLC]
    ↓
[DLC desinstalado]
```

## 10. Pruebas de DLC

**Pruebas manuales:**
- Probar carga de DLC
- Probar compatibilidad con juego base
- Probar compatibilidad con otros DLC
- Probar backward compatibility
- Probar desinstalación de DLC
- Probar savegames con contenido DLC
- Probar savegames sin contenido DLC
- Probar bundles de DLC

**Pruebas automáticas:**
- Tests de carga de DLC
- Tests de compatibilidad de DLC
- Tests de desinstalación de DLC
- Tests de savegames con contenido DLC
