# 1-DOCUMENTO-DE-ESPECIFICACIONES-ACTUAL.md

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16
**Estado:** Esqueleto vigente — el contenido lo completan los módulos técnicos dueños (marcar secciones al completar).

## Propósito

Especificaciones técnicas vigentes del sistema: motor, arquitectura, rendimiento, entrada/salida, datos.

## Secciones

| Sección | Estado | Módulo dueño |
|---|---|---|
| Motor y pipeline (Unity vs Godot) | ✅ **Godot 4.x + Voxel Tools (GDExtension) + GDScript — CONFIRMADO 2026-08-16** (investigación y decisión final en `04-Game-Engine/plan-actual/`, Log 17) | 04 Game Engine |
| Arquitectura de software | ✅ Service Locator + capas unidireccionales + EventBus tipado — ver `07-Arquitectura-General/` | 07 Arquitectura |
| Mundo voxel (chunks, culling, LOD) | Pendiente | 08 Mundo Voxel |
| Rendimiento y frame budget | Pendiente | 61 Rendimiento |
| Guardado y serialización | Pendiente | 59 Guardado |
| Input (teclado/mando) | Pendiente | 57 Interfaz de Control |
| Cargas y streaming | Pendiente | 63 Cargas y Streaming |

## Reglas de actualización

- Actualizar aquí ante cambios significativos (AGENTS §3, sección 3).
- Firmar con modelo/plataforma cada modificación.