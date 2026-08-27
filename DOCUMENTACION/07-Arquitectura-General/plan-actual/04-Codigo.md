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

**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-26 01:30:00
**Estado:** Implementación core completada y validada

### Lo que hice
- Implementé `event_bus.gd`: Bus de eventos global con 9 dominios tipados (world, economy, inventory, quest, npc, calendar, travel, ui, player)
- Implementé `service_registry.gd`: Service Locator con registro por interfaz, listado y validación
- Implementé `bootstrap.gd`: Registro de servicios core + carga de escena principal (deferred)
- Creé escena de prueba `test_arquitectura.tscn` que valida 6 puntos: EventBus activo, ServiceRegistry activo, registro en ServiceRegistry, dominios presentes, emisión/recepción de eventos, servicios listados
- Registré EventBus y ServiceRegistry como autoloads en project.godot (orden: EventBus primero, Bootstrap último)
- **Test: 6 PASS, 0 FAIL — arquitectura base validada**

### Errores encontrados y corregidos
1. `class_name ServiceRegistry` colisiona con autoload del mismo nombre → eliminado class_name
2. `class_name Bootstrap` colisiona con autoload → eliminado class_name
3. `func get()` en Node ya existe (firma `get(StringName) -> Variant`) → renombrado a `get_service()`
4. Parámetro `type` es palabra reservada en GDScript → renombrado a `expected_type` (luego eliminado `get_typed` por simplificar)
5. `change_scene_to_file()` en `_ready()` causa error "Parent node busy" → cambiado a `call_deferred()`
6. Lambda `func(): received = true` no captura variable externa → corregido con `func(_pos, _type): _event_received = true`
7. Señal con 2 argumentos conectada a lambda de 0 argumentos → corregido con lambda que acepta los 2 argumentos

### Lo que NO pude hacer
- GameState (M59) → pendiente, placeholder registrado
- Verificación de capas por script → pendiente
- Presupuesto de eventos (perf) → pendiente M61

### Recomendaciones para el próximo agente
- M08 (Mundo Voxel): VoxelWorld/ChunkManager deben cumplir el contrato de integración y comunicarse por `EventBus.world.*`
- M11/M12 (Jugador/Cámara): pueden usar `EventBus.player.*` para comunicación
- El siguiente paso es completar M08 (colisión + edibilidad de bloques) o M07 avanzado (GameState, más servicios)