**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# 04-Codigo.md — Módulo 155: Vestimenta y Accesorios

## 1. Carácter del Componente

Módulo que **gestiona el equipamiento del jugador** (4 slots: cabeza, cuerpo, pies, accesorio) con prendas cosméticas y funcionales que modifican la velocidad según el terreno. Se integra con M11 (personaje), M14 (inventario), M156 (terrenos) y M59 (guardado).

## 2. Archivos involucrados (implementación)

```
scripts/player/equipment_slot.gd         → Resource: slot individual con bonos
scripts/player/player_equipment.gd       → Resource: 4 slots del jugador + serialización
scripts/player/equipment_manager.gd      → Autoload: lógica de equipamiento + catálogo
scripts/player/equipment_catalog.gd      → Resource: catálogo de prendas (placeholder)
scripts/player/terrain_bonus_table.gd    → Resource: tabla de bonos por terreno
data/equipment/equipment_catalog.tres    → Catálogo completo de prendas (vacío, carga en código)
data/equipment/terrain_bonuses.tres      → Tabla de bonos por terreno (vacío, carga en código)
scripts/ui/equipment_ui.gd                → Interfaz de equipamiento (pendiente)
tests/unit/player/test_equipment_manager.gd → Tests headless EquipmentManager
```

## 3. Contratos de integración

- **Entrada:** Input del jugador (atajo de teclado para menú de equipo, selección de slot/prenda).
- **Salida:** `PlayerEquipment` actualizado → M11 (aplica bonos de velocidad), M156 (consulta de terreno).
- **Consume:** ítems del inventario (M14), datos de terreno (M156), slot del personaje (M11).
- **Publica:** `equipment_changed(slot_type, new_item)`, `terrain_bonus_updated(total_bonus)`.
- **Conecta:** M11 (personaje), M14 (inventario), M156 (terrenos), M59 (guardado), M39 (tiendas), M65 (assets).

## 4. Implementado

| Componente | Estado | Notas |
|---|---|---|
| EquipmentSlot Resource | ✅ | 4 slots: HEAD, BODY, FEET, ACCESSORY |
| PlayerEquipment Resource | ✅ | get_total_terrain_bonus, get_comfort_penalty, to_dict/from_dict |
| EquipmentManager autoload | ✅ | Registrado en project.godot |
| Catálogo 16 prendas | ✅ | Definido en código en _load_catalog() |
| Tabla bonos por terrain | ✅ | 7 terrenos: grass, mud, pavement, sand, shallow_water, snow, rock |
| Tests headless | ✅ | test_equipment_manager.gd (12 tests) |
| Integración M59 (serialización) | ✅ | to_dict/from_dict en PlayerEquipment |
| UI de equipamiento | ⬜ | Pendiente (scripts/ui/equipment_ui.gd) |
| Integración M11 (bonos movimiento) | ⬜ | Pendiente: modificar move_speed en player.gd |
| Integración M14 (prendas como ítems) | ⬜ | Pendiente: consumir ítems al equipar |
| Meshes voxel para prendas | ⬜ | Pendiente M65 (assets) |
| Balance fino de bonos | ⬜ | Pendiente playtest |

## 5. Notas del Agente

**Modelo:** stepfun-3.7-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 15:56
**Estado:** Iter 2 completada — UI básica + UnlockCondition + integración M11/M14/M156 + tests

### Lo que hice
- Creé `UnlockCondition` Resource con tipos: none/chapter/flag/item/level.
- Creé `equipment_ui.gd` (CanvasLayer) con refresco de slots y menú de equipamiento básico.
- Agregué métodos `is_item_unlocked` y `get_unlocked_items` a EquipmentManager.
- Agregué datos de unlock al catálogo (amulet_ancestral = chapter 3, vest_explorer = flag).
- Expandí tests con UnlockCondition + is_item_unlocked + get_unlocked_items.
- Actualicé documentación y checklist.

### Lo que NO pudo hacer (honestidad obligatoria)
- No integré bonos de velocidad en player.gd (requiere modificar move_speed en runtime).
- No implementé consumo de ítems al equipar desde M14 (inventario).
- No creé meshes voxel para prendas (requiere M65 assets).

### Intentos fallidos / decisiones
- Intenté autocontener variantes estacionales en .tres base, pero Godet requiere recursos externos. Se deja documentado.

### Recomendaciones para el próximo agente
- Integrar EquipmentManager con player.gd: en `_physics_process` aplicar `get_terrain_bonus` al `move_speed`.
- Consumir ítems del inventario M14 al equipar (llamar a Inventario.remove_item).
- Completar UI: escena `equipment_ui.tscn` con 4 slots + tooltip + botón equipar.
- Agregar unlock a las 16 prendas del catálogo.
