**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 07: Arquitectura General

## 1. Carácter del Componente

Módulo de **diseño arquitectónico** (complejidad 5). Hoy entrega el contrato; la implementación real (scripts core) arranca en el hito M1. Los 06/07 de testing se integrarán con el prototipo (verificación de capas por script).

## 2. Archivos de referencia para M1 (esqueleto de implementación)

| Script futuro | Rol |
|---|---|
| `scripts/core/bootstrap.gd` | Registro de servicios, arranque |
| `scripts/core/event_bus.gd` | Señales tipadas por dominio |
| `scripts/core/service_registry.gd` | Service Locator |
| `scripts/core/thread_pool.gd` | Cola de trabajos pesados |
| `scripts/world/voxel_world.gd` | World + chunks |
| `scripts/data/game_state.gd` | Estado serializable (M59) |

## 3. Decisiones que otros módulos consumen

| Decisión | Consumida por |
|---|---|
| Service Locator + capas UI→Servicios→Sistemas→Datos | Todos los módulos de código |
| Contrato de integración (6 pasos) | M08-M75, QA |
| GameState particionado por dominio | M59, M38, M22 |
| EventBus con dominios tipados | M29 (calendar), M22 (quest), M38 (economy) |
| Escenas separadas por isla + carga diégetica | M28, M63 |
| Verificación de capas automatizada | M1, QA |

## 4. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Lista final y orden de registro de los 18 servicios | Hito M1 (bootstrap real) |
| Script de verificación de capas (imports) | Hito M1 |
| Detalle de partición/versionado del GameState | M59 Guardado |
| Presupuesto de eventos (perf) | M61 Rendimiento |

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 02:15:00
**Estado:** Completado (diseño; implementación en M1)

### Lo que hice
- Resolví los 27 puntos del plan maestro (sección 6) mapeándolos a 18 servicios por dominio.
- Diseñé capas unidireccionales, Service Locator, EventBus por dominios, GameState particionado y contrato de integración.
- Alternativas evaluadas (ECS descartado, MVC parcial).

### Lo que NO pude hacer (honestidad obligatoria)
- Implementar los scripts core → requiere el proyecto Godot (hito M1).
- Validar la ausencia real de dependencias circulares → la verificación es de M1.
- Medir el costo del bus de eventos → pendiente M61.

### Recomendaciones para el próximo agente
- M08 (Mundo Voxel): VoxelWorld/ChunkManager deben cumplir el contrato de integración y comunicarse por `world:` events.
- El prototipo M1 debe arrancar con Bootstrap + EventBus + ServiceRegistry mínimo (3 scripts) para validar el patrón antes de agregar voxel.