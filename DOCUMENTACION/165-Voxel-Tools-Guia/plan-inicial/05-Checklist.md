**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 165: Guía de Voxel Tools

## Checklist de Verificación (mínimo 100 ítems)

### Configuración Básica
- [x] VoxelTerrain agregado a la escena
- [x] VoxelMesherBlocky configurado como mesher
- [x] VoxelBlockyLibrary creada con modelos
- [x] VoxelBlockyModelEmpty registrado como modelo 0 (aire)
- [x] VoxelBlockyModelCube registrado para bloques sólidos
- [x] library.bake() llamado después de agregar modelos
- [x] StandardMaterial3D creado con vertex_color_use_as_albedo
- [x] Material asignado a terrain.material_override

### Generador Procedural
- [x] VoxelGeneratorNoise2D creado
- [x] channel configurado a VoxelBuffer.CHANNEL_TYPE
- [x] FastNoiseLite creado y asignado
- [x] noise.seed configurado
- [x] noise.frequency ajustado (0.02 recomendado)
- [x] noise.fractal_octaves configurado (5 recomendado)
- [x] generator.noise asignado
- [x] terrain.generator asignado

### VoxelViewer
- [x] VoxelViewer creado
- [x] VoxelViewer es hijo de Camera3D
- [x] view_distance configurado (128.0 recomendado)
- [x] Camera3D posicionada sobre el terreno

### Escena
- [x] WorldEnvironment con sky configurado
- [x] DirectionalLight3D con shadows habilitados
- [x] UI con FPSLabel y ControlsLabel
- [x] Script de cámara que sigue al jugador

### Errores Conocidos
- [x] Error "VoxelStreamScript unimplemented" resuelto (no asignar stream)
- [x] Error "set_material not found" documentado
- [x] Error inferencia de tipos con clamp() documentado

### Pruebas
- [ ] Escena de prueba simple funciona
- [ ] Terreno visible con un solo tipo de bloque
- [ ] Terreno visible con múltiples bloques
- [ ] Cámara sigue al jugador correctamente
- [ ] FPS estable (>30 FPS)

### Optimización
- [ ] view_distance calibrado para rendimiento
- [ ] chunk_size óptimo determinado
- [ ] LOD configurado si es necesario

### Documentación
- [x] Guía creada en DOCUMENTACION/165-Voxel-Tools-Guia/
- [x] Errores documentados en 07-GUIA-GODOT.md
- [x] Recipe de configuración mínima
- [x] Referencias a documentación oficial

### Integración con Proyecto
- [x] WorldManager configurado para Isla Raíz
- [x] BlockCatalog con 20+ bloques definidos
- [x] IslandGenerator con heightmap procedural
- [x] Player y cámara integrados

### Pendientes
- [ ] Verificar renderizado visual del terreno
- [ ] Probar con texturas reales en vez de vertex colors
- [ ] Implementar sistema de chunks dinámicos
- [ ] Agregar LOD para optimización
- [ ] Probar con terreno destructible
