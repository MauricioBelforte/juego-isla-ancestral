**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 165: Guía de Voxel Tools

## Arquitectura de Voxel Tools

Voxel Tools es una GDExtension que provee:
- `VoxelTerrain`: Nodo principal que gestiona chunks de voxels
- `VoxelMesherBlocky`: Mesh para bloques estilo Minecraft
- `VoxelBlockyLibrary`: Catálogo de modelos de bloques
- `VoxelGeneratorNoise2D/3D`: Generadores procedurales basados en ruido
- `VoxelViewer`: Define la región donde se generan voxels

## Flujo de datos
```
VoxelViewer (posición cámara) → VoxelTerrain → VoxelGenerator → VoxelBuffer → VoxelMesher → Mesh renderizado
```

## Configuración mínima funcional

### 1. Nodos requeridos en la escena
```
Node3D (root)
├── VoxelTerrain
│   └── (configurar en script)
├── Camera3D
│   └── VoxelViewer (hijo de la cámara)
└── DirectionalLight3D
```

### 2. Script de WorldManager
```gdscript
extends Node3D

@onready var terrain: VoxelTerrain = $VoxelTerrain

func _ready():
    # 1. Material con vertex color
    var mat := StandardMaterial3D.new()
    mat.vertex_color_use_as_albedo = true
    mat.roughness = 0.8
    terrain.material_override = mat
    
    # 2. Mesher con library
    var mesher := VoxelMesherBlocky.new()
    var library := VoxelBlockyLibrary.new()
    
    # Modelo 0: Aire (siempre primero)
    var air := VoxelBlockyModelEmpty.new()
    air.set_name("air")
    library.add_model(air)
    
    # Modelo 1: Bloque sólido
    var cube := VoxelBlockyModelCube.new()
    cube.set_name("block")
    library.add_model(cube)
    
    library.bake()  # OBLIGATORIO
    mesher.library = library
    terrain.mesher = mesher
    
    # 3. Generador
    var generator := VoxelGeneratorNoise2D.new()
    generator.channel = VoxelBuffer.CHANNEL_TYPE
    var noise := FastNoiseLite.new()
    noise.seed = 42
    noise.frequency = 0.02
    generator.noise = noise
    terrain.generator = generator
```

### 3. VoxelViewer
- **Obligatorio**: Sin él, el motor no genera voxels
- **Ubicación**: Como hijo del Camera3D
- **view_distance**: Distancia de generación (ej: 128.0)

## Errores conocidos

### Error 1: "VoxelStreamScript::_load_voxel_block is unimplemented!"
- **Causa**: Usar `VoxelStreamScript.new()` directamente
- **Solución**: NO asignar stream para generación procedural básica
- **Estado**: Resuelto 2026-08-25

### Error 2: Terreno no visible sin errores
- **Causa**: Falta material con vertex color
- **Solución**: Asignar `StandardMaterial3D` con `vertex_color_use_as_albedo = true`
- **Estado**: Resuelto 2026-08-25

### Error 3: VoxelBlockyModelCube no tiene set_material()
- **Causa**: La API no expone ese método
- **Solución**: Solo usar `set_name()`, colores por material override
- **Estado**: Resuelto 2026-08-25

### Error 4: Terreno no visible a pesar de setup correcto
- **Causa**: VoxelTerrain anidado bajo WorldManager (Node3D padre)
- **Solución**: VoxelTerrain debe ser hijo DIRECTO del root Node3D
- **Estado**: Resuelto 2026-08-25
- **Verificación**: La escena minimal_test.tscn funcionó porque VoxelTerrain era hijo directo del root

### Error 5: Cámara no muestra terreno
- **Causa**: Script de cámara con lógica compleja de seguimiento
- **Solución**: Usar Camera3D estática primero, luego agregar seguimiento
- **Estado**: Resuelto 2026-08-25
