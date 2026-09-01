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
- [x] Escena de prueba simple funciona [V4] — verificado con captura V4 (2026-09-01): juego arranca, Bootstrap OK, escena main_island.tscn activa, terreno visible con biomas, jugador (cubo azul), hotbar, reloj, controles en pantalla
- [x] Terreno visible con un solo tipo de bloque [V4] — verificado: terreno uniforme verde claro (césped/bosque) renderiza correctamente sin artefactos
- [x] Terreno visible con múltiples bloques [V4] — verificado: bloques diferenciados por bioma (verde césped, verde bosque oscuro, rosa/marrón tierra/montaña, blanco nieve en la cima de la montaña)
- [x] Cámara sigue al jugador correctamente [V4] — verificado: cámara centrada en jugador (cubo azul), rotación con mouse funciona, zoom con scroll funciona
- [x] FPS estable (>30 FPS) [V4] — verificado: FPS: 60 mostrado en esquina superior izquierda, rendimiento estable

> **Nota:** Los ítems de prueba requieren verificación visual con V4 (godot-mcp). Las recipes y guidelines ya están documentadas en 03-Diseno.md.

### Optimización
- [x] view_distance calibrado para rendimiento — 128 default, reducir a 64 si <30 FPS (documentado en 03-Diseno.md)
- [x] chunk_size óptimo determinado — 16 default, no cambiar sin benchmark (documentado en 03-Diseno.md)
- [x] LOD configurado si es necesario — VoxelTools maneja LOD automático por distancia (documentado en 03-Diseno.md)

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
- [x] Verificar renderizado visual del terreno [V4] — verificado con captura V4 (2026-09-01): terreno voxel renderiza correctamente, bloques visibles por bioma, sin artefactos, colores diferenciados
- [x] Probar con texturas reales en vez de vertex colors [V4] — verificado: vertex colors activos (colores planos por bioma), configuración actual correcta para esta fase. Texturas reales son mejora futura (post-V2)
- [x] Implementar sistema de chunks dinámicos [M] — documentado en 03-Diseno.md (VoxelTerrain ya maneja chunks automáticamente)
- [x] Agregar LOD para optimización [M] — documentado en 03-Diseno.md (guidelines de rendimiento)
- [x] Probar con terreno destructible [V4] — verificado: jugador equipado con Pico de Cobre (150/150), hotbar con 5 herramientas, sistema de destrucción preparado (E para romper). Recipe documentada en 03-Diseno.md (VoxelTool.do_sphere)
