**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 165: Guía de Voxel Tools

## Recipe: Heightmap procedural con VoxelGeneratorNoise2D

```gdscript
# Configuración completa de VoxelTerrain
func setup_terrain(terrain: VoxelTerrain, seed_val: int) -> void:
    # Material
    var mat := StandardMaterial3D.new()
    mat.vertex_color_use_as_albedo = true
    mat.roughness = 0.8
    terrain.material_override = mat
    
    # Mesher
    var mesher := VoxelMesherBlocky.new()
    var library := VoxelBlockyLibrary.new()
    
    var air := VoxelBlockyModelEmpty.new()
    air.set_name("air")
    library.add_model(air)
    
    var cube := VoxelBlockyModelCube.new()
    cube.set_name("block")
    library.add_model(cube)
    
    library.bake()
    mesher.library = library
    terrain.mesher = mesher
    
    # Generador
    var generator := VoxelGeneratorNoise2D.new()
    generator.channel = VoxelBuffer.CHANNEL_TYPE
    var noise := FastNoiseLite.new()
    noise.seed = seed_val
    noise.frequency = 0.02
    noise.fractal_octaves = 5
    generator.noise = noise
    terrain.generator = generator
```

## Recipe: Escena mínima funcional

```
Node3D (Main)
├── WorldEnvironment (sky + ambient light)
├── VoxelTerrain (script configura mesher + generator)
├── Camera3D
│   ├── VoxelViewer (view_distance = 128)
│   └── Script de cámara
├── DirectionalLight3D (shadows on)
└── UI (CanvasLayer)
    ├── FPSLabel
    └── ControlsLabel
```

## Parámetros recomendados

| Parámetro | Valor | Notas |
|-----------|-------|-------|
| noise.frequency | 0.02 | Más bajo = terreno más suave |
| noise.fractal_octaves | 5 | Más octaves = más detalle |
| VoxelViewer.view_distance | 128.0 | Distancia de generación |
| material.roughness | 0.8 | Para bloques de tierra/piedra |

## Referencias
- Documentación oficial: https://voxel-tools.readthedocs.io/
- Quick start: https://voxel-tools.readthedocs.io/en/latest/quick_start/
- Repositorio: https://github.com/Zylann/voxel_game

## Recipe: Terreno destructible con VoxelTool

```gdscript
# Extraer bloque (romper)
func romber_bloque(terrain: VoxelTerrain, pos: Vector3) -> void:
    var vt := terrain.get_voxel_tool()
    if vt == null:
        return  # VoxelTool no listo (chunks no cargados aún)
    vt.mode = VoxelTool.MODE_REMOVE
    vt.value = 0  # 0 = aire
    vt.do_sphere(pos, 0.5)  # Radio 0.5 = 1 bloque

# Colocar bloque
func colocar_bloque(terrain: VoxelTerrain, pos: Vector3, block_id: int) -> void:
    var vt := terrain.get_voxel_tool()
    if vt == null:
        return
    vt.mode = VoxelTool.MODE_SET
    vt.value = block_id
    vt.do_sphere(pos, 0.5)

# ⚠️ PITFALL: VoxelTool.raycast() NO funciona al inicio del juego
# Los chunks cercanos al spawn no están cargados aún.
# Usar IslandGenerator.get_height() + offset en su lugar (ver 07-GUIA-GODOT §9.44)
```

## Recipe: Texturas reales (reemplazar vertex colors)

```gdscript
# En vez de vertex_color_use_as_albedo, usar texturas por bloque:
func setup_textured_terrain(terrain: VoxelTerrain) -> void:
    var mat := StandardMaterial3D.new()
    # Opción A: textura atlas (una imagen con todos los bloques)
    mat.albedo_texture = preload("res://textures/block_atlas.png")
    mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST  # Pixel art
    
    # Opción B: shader para UV por bloque
    # Cada VoxelBlockyModel puede tener su propio material
    terrain.material_override = mat

# Para materiales por bloque (no global):
func setup_block_materials(library: VoxelBlockyLibrary) -> void:
    for i in range(library.get_model_count()):
        var model := library.get_model(i)
        if model is VoxelBlockyModelCube:
            var mat := StandardMaterial3D.new()
            mat.albedo_color = BlockType.get_color(i)
            model.set_material_override(0, mat)  # Surface index 0
```

## Recipe: LOD (Level of Detail)

```gdscript
# VoxelViewer soporta LOD por distancia
func setup_lod(terrain: VoxelTerrain) -> void:
    # LOD automático: VoxelTools reduce geometría lejana
    # No hay API directa de LOD en VoxelMesherBlocky
    # La optimización viene de:
    # 1. view_distance limitado (128 = ~8 chunks)
    # 2. Generador procedural con frecuencia baja (0.02)
    # 3. chunk_size por defecto (16) es óptimo para Godot
    
    # Para optimización manual:
    # - Reducir view_distance a 64 en hardware débil
    # - Usar noise.fractal_octaves = 3 en vez de 5
    # - Evitar más de 20 tipos de bloque (increase memory)
    pass
```

## Recipe: Chunks dinámicos (forzados)

```gdscript
# VoxelTerrain ya maneja chunks automáticamente.
# Para forzar generación en posiciones específicas:
func precargar_chunks(terrain: VoxelTerrain, center: Vector3) -> void:
    var viewer := terrain.get_node_or_null("VoxelViewer")
    if viewer:
        # Mover el VoxelViewer fuerza regeneración de chunks
        viewer.global_position = center + Vector3(0, 10, 0)

# ⚠️ NO crear múltiples VoxelTerrain para islas diferentes
# Usar UN solo VoxelTerrain con VoxelViewer que se mueva
# o congenerador procedural que cubra toda la isla
```

## Guidelines de rendimiento

| Métrica | Objetivo | Cómo verificar |
|---------|----------|----------------|
| FPS | >30 estable | FPSLabel en UI |
| view_distance | 128 (default) | Reducir a 64 si <30 FPS |
| chunk_size | 16 (default) | No cambiar sin benchmark |
| Triángulos/chunk | ~512-2048 | Varies con terreno |
| Memoria | <512 MB | Task Manager Windows |

## Errores comunes adicionales

| Error | Causa | Solución |
|-------|-------|----------|
| Terreno invisible | Generador no asignado | Verificar `terrain.generator = generator` |
| Terreno plano | frequency muy alto | Reducir a 0.02 |
| Terreno muy rugoso | frequency muy bajo | Aumentar a 0.05 |
| FPS bajos | view_distance alto | Reducir a 64 |
| Bloques fantasma | library no bakeada | Llamar `library.bake()` |
| VoxelTool null | Chunks no cargados | Esperar 1-2s o usar get_height() |
