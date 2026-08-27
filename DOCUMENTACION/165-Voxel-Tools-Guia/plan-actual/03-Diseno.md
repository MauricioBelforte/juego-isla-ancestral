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
