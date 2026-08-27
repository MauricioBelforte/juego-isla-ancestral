**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 165: Guía de Voxel Tools

## Problema
No existe documentación centralizada sobre cómo usar correctamente Voxel Tools (GDExtension) en Godot 4.x para generación procedural de terreno. Los agentes repiten errores conocidos.

## Objetivos
- Documentar la configuración correcta de VoxelTerrain + VoxelMesherBlocky + VoxelGeneratorNoise2D
- Registrar errores comunes y sus soluciones
- Proporcionar recipes de uso rápido

## Alcance
- Configuración de VoxelTerrain para heightmap procedural
- Uso de VoxelViewer para generación dinámica
- Material con vertex color para bloques visibles
- Errores conocidos y soluciones

## Restricciones
- Godot 4.x con Voxel Tools GDExtension
- Solo bloques (VoxelMesherBlocky), no smooth terrain
