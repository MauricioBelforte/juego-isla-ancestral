**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 04-Codigo.md — Módulo 120: DLC y Expansiones

## 1. Carácter del Componente

Módulo de **DLC y expansiones** para contenido post-lanzamiento. Define estrategia de DLC, contenido del juego base, nuevas islas, nuevas historias, nuevos NPCs, nuevos sistemas, nuevos biomas, nuevas músicas, nuevas colecciones, nuevas ruinas, compatibilidad, precios, bundles, marketing y regla de no bloquear contenido esencial. Implementable inmediatamente (depende de M95 para monetización, M142 para release candidate, M22 para historia principal, M27 para islas del mundo). Es un módulo de diseño y configuración.

**06-Plan-Testings.md:** NO APLICA (módulo de DLC y expansiones, sin código de gameplay complejo; tests pueden ser manuales de carga de DLC)

## 2. Archivos involucrados (implementación)

```
res://dlc/
├── dlc_manager.gd                              → Sistema de carga de DLC
├── dlc_compatibility_checker.gd                 → Sistema de validación de compatibilidad
├── dlc_uninstaller.gd                           → Sistema de desinstalación de DLC
└── dlc_bundle_manager.gd                        → Sistema de bundles de DLC

res://dlc/bundles.json                           → Configuración de bundles

DLC/
├── Isla de Hielo/
│   ├── manifest.json                            → Metadatos del DLC
│   ├── islas/                                   → Archivos de islas
│   ├── biomas/                                  → Archivos de biomas
│   ├── npcs/                                    → Archivos de NPCs
│   ├── historias/                               → Archivos de historias
│   ├── sistemas/                                → Archivos de sistemas
│   ├── ruinas/                                  → Archivos de ruinas
│   ├── musica/                                  → Archivos de música
│   └── colecciones/                             → Archivos de colecciones
└── manifest.json                                → Metadatos de DLCs disponibles

06-Plan-Testings.md                               → NO APLICA
07-Resultados-Testings.md                        → NO APLICA
```

## 3. Contratos de integración

### Salida (hacia otros módulos)
- **M95 (Monetización):** Precios de DLC y bundles para monetización
- **M142 (Release Candidate):** DLC como contenido post-lanzamiento
- **M22 (Historia Principal):** DLC con historias secundarias opcionales
- **M27 (Islas del Mundo):** DLC con nuevas islas

### Entrada (desde otros módulos)
- **M95 (Monetización):** Plataforma de distribución (Steam) para DLC
- **M142 (Release Candidate):** Versión del juego base para compatibilidad
- **M22 (Historia Principal):** Historia principal del juego base para no bloquear contenido esencial
- **M27 (Islas del Mundo):** Sistema de islas del juego base para integración con DLC

### Configuración
- `res://dlc/dlc_manager.gd` define sistema de carga de DLC
- `res://dlc/bundles.json` define configuración de bundles
- `DLC/*/manifest.json` define metadatos de cada DLC

## 4. Implementación de dlc_manager.gd (esqueleto)

```gdscript
# res://dlc/dlc_manager.gd
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

func load_island(island_id: String):
    # Cargar isla del DLC
    # (implementación específica según sistema de islas M27)
    pass

func load_biome(biome_id: String):
    # Cargar biome del DLC
    # (implementación específica según sistema de biomas M09)
    pass

func load_npc(npc_id: String):
    # Cargar NPC del DLC
    # (implementación específica según sistema de NPCs M19)
    pass

func load_historia(historia_id: String):
    # Cargar historia del DLC
    # (implementación específica según sistema de historia M22)
    pass

func load_sistema(sistema_id: String):
    # Cargar sistema del DLC
    # (implementación específica según sistema del DLC)
    pass

func load_ruin(ruin_id: String):
    # Cargar ruina del DLC
    # (implementación específica según sistema de ruinas M25)
    pass

func load_music(track_id: String):
    # Cargar música del DLC
    # (implementación específica según sistema de música M41)
    pass

func load_coleccion(coleccion_id: String):
    # Cargar colección del DLC
    # (implementación específica según sistema de colecciones M37)
    pass
```

## 5. Implementación de dlc_compatibility_checker.gd (esqueleto)

```gdscript
# res://dlc/dlc_compatibility_checker.gd
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

## 6. Implementación de dlc_uninstaller.gd (esqueleto)

```gdscript
# res://dlc/dlc_uninstaller.gd
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
    # (implementación específica según lógica de savegame M59)
    pass
```

## 7. Implementación de dlc_bundle_manager.gd (esqueleto)

```gdscript
# res://dlc/dlc_bundle_manager.gd
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
    # (implementación específica según plataforma de distribución Steam)
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

## 9. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Crear res://dlc/dlc_manager.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://dlc/dlc_compatibility_checker.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://dlc/dlc_uninstaller.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://dlc/dlc_bundle_manager.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://dlc/bundles.json | **IMPLEMENTACIÓN INMEDIATA** |
| Crear estructura de DLC (Isla de Hielo, Isla de Volcán, Isla de Bosque) | **IMPLEMENTACIÓN MANUAL** |
| Crear manifest.json para cada DLC | **IMPLEMENTACIÓN MANUAL** |
| Integrar con M95 (Monetización) para precios de DLC | **M95 (Monetización)** |
| Integrar con M142 (Release Candidate) para compatibilidad | **M142 (Release Candidate)** |
| Integrar con M22 (Historia Principal) para historias secundarias | **M22 (Historia Principal)** |
| Integrar con M27 (Islas del Mundo) para nuevas islas | **M27 (Islas del Mundo)** |
| Integrar con Steam para distribución de DLC | **IMPLEMENTACIÓN MANUAL** |
| Crear trailers y marketing para DLC | **IMPLEMENTACIÓN MANUAL** |

## 10. Notas del Agente

**Modelo:** SWE-1.6
**Plataforma:** DEVIN
**Fecha:** 2026-08-19 04:15:00
**Estado:** Completado (especificación; implementación inmediata posible)

### Lo que hice
- Resolví los 15 puntos de la sección 119 del plan maestro.
- Definí estrategia de DLC (frecuencias trimestrales/semestrales/anuales, tamaños pequeños/medianos/grandes, temáticas coherentes con visión cozy).
- Definí contenido del juego base (historia principal completa, 7 islas base, 13 biomas base, sistemas core, música base, 30 NPCs base).
- Definí nuevas islas DLC (Isla de Hielo, Isla de Volcán, Isla de Bosque).
- Definí nuevas historias DLC (historias secundarias opcionales, 2-3 cadenas por DLC, sellos nuevos).
- Definí nuevos NPCs DLC (5-10 NPCs por DLC, rutinas, diálogos, amistad, misiones opcionales).
- Definí nuevos sistemas DLC (acuicultura, jardinería, fotografía avanzada, colecciones avanzadas).
- Definí nuevos biomas DLC (2-3 biomas nuevos por DLC, flora y fauna específicas, recursos específicos).
- Definí nuevas músicas DLC (10-15 tracks nuevos por DLC, leitmotifs de NPCs nuevos, leitmotifs de islas nuevas).
- Definí nuevas colecciones DLC (colecciones opcionales, 10-20 items por colección, recompensas cosméticas).
- Definí nuevas ruinas DLC (2-3 ruinas/tempos nuevos por DLC, puzzles opcionales, sellos nuevos).
- Definí compatibilidad DLC (compatible con juego base, compatible con otros DLC, backward compatible, soporta desinstalación).
- Definí precios DLC (USD 5-10 pequeños, USD 10-20 medianos, USD 20-30 grandes, sensibles para género cozy).
- Definí bundles DLC (season pass 3 DLC por USD 20-25, bundle completo todos DLC por USD 50-60, bundles temáticos).
- Definí marketing DLC (trailers específicos, screenshots, anuncios Steam, social media).
- Definí regla DLC: no bloquear contenido esencial del juego base, DLC es opcional y expande la experiencia.
- Diseñé estructura de DLC (directorios para islas, biomas, NPCs, historias, sistemas, ruinas, música, colecciones).
- Diseñé manifest.json de DLC con metadatos (dlc_id, dlc_name, dlc_version, dlc_size, dlc_price, dlc_description, dlc_requires_base_game, dlc_requires_other_dlc, dlc_content, dlc_compatibility).
- Diseñé DLCManager (servicio de carga de DLC) con signal dlc_loaded/dlc_unloaded.
- Diseñé DLCCompatibilityChecker (servicio de validación de compatibilidad) con check_compatibility().
- Diseñé DLCUninstaller (servicio de desinstalación de DLC) con mark_savegames_as_incomplete(), delete_dlc_files(), update_savegames().
- Diseñé DLCBundleManager (servicio de bundles de DLC) con get_bundle_price(), get_bundle_dlc_ids(), calculate_bundle_discount().
- Diseñé bundles.json con configuración de bundles (season_pass_2024, bundle_completo, bundle_islas).
- Diseñé sistema de carga de DLC con load_dlc_content() y unload_dlc_content().
- Diseñé sistema de validación de compatibilidad con get_base_game_version() e is_version_compatible().
- Diseñé sistema de desinstalación de DLC con mark_savegames_as_incomplete() y delete_dlc_files().
- Diseñé sistema de bundles con get_bundle_price(), get_bundle_dlc_ids() y calculate_bundle_discount().

### Lo que NO pude hacer (honestidad obligatoria)
- Implementar carga real de islas del DLC (requiere integración con M27)
- Implementar carga real de biomas del DLC (requiere integración con M09)
- Implementar carga real de NPCs del DLC (requiere integración con M19)
- Implementar carga real de historias del DLC (requiere integración con M22)
- Implementar carga real de sistemas del DLC (requiere implementación específica)
- Implementar carga real de ruinas del DLC (requiere integración con M25)
- Implementar carga real de música del DLC (requiere integración con M41)
- Implementar carga real de colecciones del DLC (requiere integración con M37)
- Implementar comparación semántica de versiones (requiere librería externa)
- Implementar integración real con Steam para distribución de DLC (requiere configuración manual)
- Crear estructura real de DLC (archivos de islas, biomas, NPCs, etc.)
- Crear manifest.json real para cada DLC (requiere contenido de DLC)

### Recomendaciones para el primer agente (implementador)
- Implementar DLCManager en Godot con autoload.
- Implementar DLCCompatibilityChecker con validación de versión del juego base.
- Implementar DLCUninstaller con mark_savegames_as_incomplete() y delete_dlc_files().
- Implementar DLCBundleManager con get_bundle_price(), get_bundle_dlc_ids() y calculate_bundle_discount().
- Integrar con M27 (Islas del Mundo) para carga de islas del DLC.
- Integrar con M09 (Terreno y Geografía) para carga de biomas del DLC.
- Integrar con M19 (NPC y Vecinos) para carga de NPCs del DLC.
- Integrar con M22 (Historia Principal) para carga de historias del DLC.
- Integrar con M41 (Música) para carga de música del DLC.
- Integrar con M37 (Museos y Colecciones) para carga de colecciones del DLC.
- Crear estructura de DLC con directorios para islas, biomas, NPCs, historias, sistemas, ruinas, música, colecciones.
- Crear manifest.json para cada DLC con metadatos completos.
- Integrar con Steam para distribución de DLC (requiere configuración manual de Steamworks).
- Crear trailers y marketing para DLC (requiere contenido de DLC).
- Probar carga de DLC.
- Probar compatibilidad con juego base.
- Probar compatibilidad con otros DLC.
- Probar backward compatibility.
- Probar desinstalación de DLC.
- Probar savegames con contenido DLC.
- Probar savegames sin contenido DLC.
- Probar bundles de DLC.
