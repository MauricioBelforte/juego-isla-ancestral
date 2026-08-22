**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# 04-Codigo.md — Módulo 155: Vestimenta y Accesorios

## 1. Carácter del Componente

Módulo que **gestiona el equipamiento del jugador** (4 slots: cabeza, cuerpo, pies, accesorio) con prendas cosméticas y funcionales que modifican la velocidad según el terreno. Se integra con M11 (personaje), M14 (inventario), M156 (terrenos) y M59 (guardado).

## 2. Archivos involucrados (implementación prevista)

```
scripts/player/equipment_manager.gd     → EquipmentManager: autoload, lógica de equipamiento
scripts/player/equipment_slot.gd        → Resource: slot individual con bonos
scripts/player/player_equipment.gd      → Resource: 4 slots del jugador
scripts/ui/equipment_ui.gd              → Interfaz de equipamiento (CanvasLayer)
data/equipment/equipment_catalog.tres   → Catálogo completo de prendas
data/equipment/terrain_bonuses.tres     → Tabla de bonos por terreno
```

## 3. Contratos de integración

- **Entrada:** Input del jugador (atajo de teclado para menú de equipo, selección de slot/prenda).
- **Salida:** `PlayerEquipment` actualizado → M11 (aplica bonos de velocidad), M156 (consulta de terreno).
- **Consume:** ítems del inventario (M14), datos de terreno (M156), slot del personaje (M11).
- **Publica:** `equipment_changed(slot_type, new_item)`, `terrain_bonus_updated(total_bonus)`.
- **Conecta:** M11 (personaje), M14 (inventario), M156 (terrenos), M59 (guardado), M39 (tiendas), M65 (assets).

## 4. Pendientes de implementación

| Pendiente | Dueño |
|---|---|
| Crear Resource EquipmentSlot con todos los campos | Implementación |
| Crear Resource PlayerEquipment con lógica de bonos | Implementación |
| Crear EquipmentManager autoload | Implementación |
| Crear interfaz de equipamiento (UI) | Implementación |
| Crear catálogo de prendas iniciales (12+ prendas) | Diseño + Implementación |
| Integrar con M11 (aplicar bonos al movimiento) | Implementación |
| Integrar con M14 (prendas como ítems) | Implementación |
| Integrar con M59 (guardar equipo) | Implementación |
| Crear meshes voxel para prendas | M65 (assets) |
| Balancear bonos por terreno | Playtest |

## 5. Notas del Agente

**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22
**Estado:** Diseño completado, documentación lista para implementación

### Lo que hice
- Diseñé la arquitectura completa del sistema de equipamiento.
- Definí 4 slots con tipos de prendas y bonos por terreno.
- Creé catálogo inicial de 12+ prendas con desbloqueo progresivo.
- Definí API pública y contratos de integración.
- Establecí reglas de bonos suaves (+5-15%) y penalizaciones leves.

### Lo que NO pude hacer (honestidad obligatoria)
- No implementé el código GDScript real (diseño y documentación solo).
- No creé los meshes voxel de las prendas (requiere M65).
- No balanceé los bonos exactos (requiere playtest).

### Recomendaciones para el próximo agente
- El slot PIES es el más importante: es donde van botas, patines, bicicleta.
- Mantener bonos suaves: nunca bloquear movimiento, solo modificar velocidad.
- Las prendas cosméticas no dan bonos: solo las funcionales.
- Integrar con M156 para que el sistema de terrenos consulte el equipamiento.
- Crear al menos 2 prendas por slot para tener variedad inicial.
