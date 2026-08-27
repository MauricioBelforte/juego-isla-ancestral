**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 165: Guía de Voxel Tools

## Archivos clave del proyecto

| Archivo | Propósito |
|---------|-----------|
| `scripts/world/world_manager.gd` | Configura VoxelTerrain con generator + mesher |
| `scripts/world/block_catalog.gd` | VoxelBlockyLibrary con 20+ bloques |
| `scripts/world/block_type.gd` | Resource con IDs de bloques |
| `scripts/world/island_generator.gd` | Generador procedural con heightmap |
| `scenes/main_island.tscn` | Escena principal con VoxelTerrain + VoxelViewer |

## API de VoxelBlockyLibrary

```gdscript
var library := VoxelBlockyLibrary.new()

# Agregar modelos (el orden importa - índice = block_id)
var air := VoxelBlockyModelEmpty.new()  # Modelo 0 = aire
air.set_name("air")
library.add_model(air)

var cube := VoxelBlockyModelCube.new()  # Modelo 1+ = sólidos
cube.set_name("block")
library.add_model(cube)

library.bake()  # OBLIGATORIO antes de usar
```

## API de VoxelGeneratorNoise2D

```gdscript
var generator := VoxelGeneratorNoise2D.new()
generator.channel = VoxelBuffer.CHANNEL_TYPE  # Canal a escribir

var noise := FastNoiseLite.new()
noise.seed = 42
noise.frequency = 0.02  # Escala del ruido
noise.fractal_octaves = 5  # Detalle
generator.noise = noise
```

## API de VoxelViewer

```gdscript
var viewer := VoxelViewer.new()
viewer.view_distance = 128.0  # Distancia de generación
# IMPORTANTE: debe ser hijo del Camera3D
```

## Notas del Agente

**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-25 01:32:00
**Estado:** Documentación inicial

### Lo que hice
- Creé módulo de documentación 165-Voxel-Tools-Guia
- Documenté configuración correcta de VoxelTerrain
- Registré errores conocidos y soluciones

### Lo que NO pude hacer
- Verificar visualmente que el terreno se renderiza (captura de pantalla falla por VS Code)
- Probar con múltiples bloques de colores

### Recomendaciones
- Siempre empezar con escena de prueba simple
- Verificar que VoxelViewer sea hijo de Camera3D
- Asignar material con vertex_color_use_as_albedo
