**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-11

# 04-Codigo.md — Módulo 155: Vestimenta y Accesorios

## 1. Carácter del Componente

Módulo que **gestiona el equipamiento del jugador** (4 slots: cabeza, cuerpo, pies, accesorio)
con prendas cosméticas y funcionales que modifican la velocidad según el terreno. Se integra con
M11 (personaje), M14 (inventario), M156 (terrenos) y M59 (guardado).

## 2. Archivos involucrados (implementación)

```
scripts/player/equipment_slot.gd         → Resource: slot individual (enum SlotType + enum TerrainType,
                                            item_id, item_name, terrain_bonuses, comfort_penalty)
scripts/player/player_equipment.gd       → Resource: 4 slots (head/body/feet/accessory) + accesorios
                                            + to_dict/from_dict
scripts/player/equipment_manager.gd      → Autoload: lógica de equipamiento + catálogo (16 prendas,
                                            `_load_catalog()`) + tabla de bonos por terreno
                                            (`_load_terrain_bonus_table()`) + ISaveProvider (M59)
scripts/player/terrain_bonus_table.gd    → Resource `TerrainBonusTable` (get_bonus / get_all_bonuses_for_terrain).
                                            EXISTE y está versionado (`git ls-files` rc=0). El manager
                                            NO lo usa: la tabla vive como Dictionary en _load_terrain_bonus_table()
scripts/player/equipment_catalog.gd      → Resource `EquipmentCatalog` (items: Dictionary). Igual:
                                            existe y versionado, pero el manager NO lo carga (catálogo en código)
data/equipment/equipment_catalog.tres    → instancia vacía de `EquipmentCatalog` (items = {}); nadie la carga
data/equipment/terrain_bonuses.tres      → instancia vacía de `TerrainBonusTable` (bonuses = {}); nadie la carga
scripts/ui/layers/equipment_layer.gd     → UI real (`EquipmentLayer`, capa M53): 4 slots + grid de 16
                                            + estado de desbloqueo + bono de terreno + highlight por terreno (L123)
scripts/ui/equipment_ui.gd               → esqueleto heredado (CanvasLayer) — reemplazado por
                                            equipment_layer.gd; NO montado
scripts/ui/preview_equipment.gd          → preview de equipamiento (editor/QA)
scripts/player/player.gd                 → M11: consume `EquipmentManager.terrain_bonus_updated`
                                            → recalcula velocidad efectiva (M156)
scripts/player/test_equipment_m155.gd    → Suite headless (extends SceneTree) del núcleo
scripts/ui/test_equipment_highlight_m155.gd → Suite headless del highlight por terreno (item L123)
tests/unit/ui/test_equipment_layer.gd    → Suite gdUnit4 de la capa (heredada)
```

> **CORRECCIÓN 2026-10-11 (DeepSeek-V4.1-Flash, autorizada por el director msg 149):**
> el director indicó que la cita a `scripts/player/terrain_bonus_table.gd` apuntaba a un archivo
> **inexistente**. **La medición dice lo contrario:** el archivo existe y está versionado
> (`git ls-files --error-unmatch scripts/player/terrain_bonus_table.gd` → rc=0; `class_name TerrainBonusTable`).
> Mi primera verificación fue defectuosa (usé `ls | grep -i equip`, que no matchea el nombre del
> archivo, y un `grep` en minúsculas que no matchea `class_name TerrainBonusTable`): **una medición
> que puede fallar en silencio no prueba una ausencia** (trampa 117 del skill). Se **conserva** la
> cita por ser correcta.
>
> Lo que **sí** era STALE (y se corrigió): (a) la sección "Implementado" marcaba como **pendientes**
> la UI, la integración M11 y la integración M14, que **están implementadas** contra el código;
> (b) la lista omitía la UI real (`equipment_layer.gd`), que reemplazó al esqueleto `equipment_ui.gd`.

## 3. Contratos de integración

- **Entrada:** Input del jugador (atajo de teclado para el panel de equipo, selección de slot/prenda).
- **Salida:** `PlayerEquipment` actualizado → M11 (aplica bonos de velocidad), M156 (consulta de terreno).
- **Consume:** ítems del inventario (M14), datos de terreno (M156), slot del personaje (M11).
- **Publica:** `equipment_changed(slot_type, new_item_id)`, `terrain_bonus_updated(total_bonus)`,
  `item_unlocked(item_id)`.
- **Conecta:** M11 (personaje), M14 (inventario), M156 (terrenos), M59 (guardado), M39 (tiendas), M65 (assets).

## 4. Esquema de serialización (M59) — item L54

`EquipmentManager` implementa el contrato duck-typed `ISaveProvider` de M59:

| Método | Firma | Rol |
|---|---|---|
| `get_section_name()` | `-> String` | Devuelve `"equipment"` (clave de sección del save). |
| `get_save_data()` | `-> Dictionary` | `PlayerEquipment.to_dict()` + `unlocked_items`. |
| `restore_save_data(data)` | `void` | `from_dict(data)` + reconstruye `_unlocked_items`. |

**Estructura del payload** (`PlayerEquipment.to_dict()` → `_slot_to_dict()`):

```json
{
  "head":      { "slot_type": 0, "item_id": "...", "item_name": "...",
                 "terrain_bonuses": { "pavement": 0.30 }, "comfort_penalty": 0.0,
                 "description": "...", "rarity": "common" },
  "body":      {},
  "feet":      {},
  "accessory": {},
  "accessories": [],
  "unlocked_items": ["acc_amulet_ancestral"]
}
```

Reglas del esquema:

- Las 4 claves `head`/`body`/`feet`/`accessory` son **siempre** Dictionary; un slot **vacío se
  serializa como `{}`** (`_slot_to_dict()` devuelve `{}` si el slot es `null` o no está equipado).
- `accessories` es un `Array` de slots (accesorios adicionales).
- `from_dict()` es tolerante: solo escribe las claves presentes (`if data.has(...)`), y
  `_dict_to_slot({})` devuelve `null` (slot vacío). Los campos ausentes usan default
  (`item_id` → `""`, `rarity` → `"common"`, `terrain_bonuses` → `{}`).
- `terrain_bonuses` es un `Dictionary` `{ "terreno": bono_float }` donde la clave es el nombre del
  enum `EquipmentSlot.TerrainType` **en minúsculas** (`grass`, `mud`, `pavement`, `sand`,
  `shallow_water`, `snow`, `rock`) — el mismo dialecto que espera `TerrainModifiers.clave_terreno_m155()`.
- `unlocked_items` es un `Array[String]` de ids desbloqueados permanentemente (además de las
  condiciones del catálogo). Se filtra al restaurar: solo entran `String` y sin duplicados.

## 5. Implementado

| Componente | Estado | Notas |
|---|---|---|
| EquipmentSlot Resource | ✅ | enum SlotType (4) + enum TerrainType (7); `get_terrain_bonus()`, `clear()` |
| PlayerEquipment Resource | ✅ | `get_total_terrain_bonus`, `get_comfort_penalty`, `to_dict/from_dict` |
| EquipmentManager autoload | ✅ | Registrado en `project.godot`; ISaveProvider (M59) |
| Catálogo 16 prendas | ✅ | Construido en código en `_load_catalog()` |
| Tabla de bonos por terreno | ✅ | 7 terrenos en `_load_terrain_bonus_table()` (código; NO se carga el `.tres`) |
| Tests headless | ✅ | `scripts/player/test_equipment_m155.gd` (29 checks) |
| Integración M59 (serialización) | ✅ | `get_save_data`/`restore_save_data` + esquema en §4 |
| UI de equipamiento | ✅ | `scripts/ui/layers/equipment_layer.gd` (capa M53, montada en `ui_root.gd`) |
| Integración M11 (bonos movimiento) | ✅ | `player.gd:68-72` conecta `terrain_bonus_updated` → `_update_effective_speed()` |
| Integración M14 (prendas como ítems) | ✅ | `equip_item` exige el ítem en `/root/Inventario` y lo consume (`remove_item`, L214-222); `unequip_slot` lo devuelve (`add_item`, L257-261) |
| Highlight visual de slots por terreno actual | ✅ | `equipment_layer.gd` + `test_equipment_highlight_m155.gd` (item L123, 2026-10-11) |
| Meshes voxel para prendas | ⬜ | Pendiente M65 (assets) |
| Test de combate con equipo (bonos de defensa) | ⬜ | Pendiente: el combate es M164/M16 y **no lee M155** (`grep defensa\|equipment` en `scripts/combat/` = 0) → `[?]` con dueño M164 |
| Balance fino de bonos | ⬜ | Pendiente playtest |

> **CORRECCIÓN 2026-10-11 (DeepSeek-V4.1-Flash):** esta tabla decía que la UI, la integración M11 y
> la integración M14 estaban **pendientes**. Es **falso contra el código**: `equipment_layer.gd` es
> la capa montada; `player.gd:68-72` conecta `terrain_bonus_updated`; y `equip_item()` (L214-222)
> consume el ítem del inventario M14 mientras `unequip_slot()` (L257-261) lo devuelve. El error
> nació de notas de una iteración temprana (2026-08-22) que quedaron sin actualizar.

### 5.1 Divergencia diseño ↔ código (reportada, no modificada)

`terrain_bonus_table.gd` (Resource `TerrainBonusTable`) y `equipment_catalog.gd` (Resource
`EquipmentCatalog`) **existen y están versionados**, y sus `.tres` (`data/equipment/`) son
instancias **vacías** (`{}`) que **nadie carga** (grep de los nombres `.tres` en `scripts/` = 0).
El `EquipmentManager` construye ambos datos **en código** (`_load_catalog()`,
`_load_terrain_bonus_table()`). Además, los **valores** de `terrain_bonus_table` se usan solo para
enumerar las 7 claves (`_emit_terrain_bonus_update()`); el bono efectivo sale de los
`terrain_bonuses` de cada prenda vía `get_total_terrain_bonus()`. No se toca: la migración a `.tres`
es una decisión de diseño de otro alcance.

## 6. Notas del Agente

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-11
**Estado:** Reserva M155 (msg 149). Corrección de documentación STALE + cierre de los 6 `[ ]` reales.

### Lo que hice (2026-10-11)

- Corregí las **dos afirmaciones falsas** de "Lo que NO pudo hacer" (velocidad M11 y consumo M14: ambos implementados) y la tabla de "Implementado" (UI/M11/M14 marcados pendientes siendo que están hechos).
- Añadí la UI real (`equipment_layer.gd`) a la lista de archivos.
- Documenté el **esquema de serialización** completo (§4, item L54).
- Agregué el **highlight visual** de slots con bonos activos para el terreno actual (§5, item L123).
- **Corregí mi propia verificación errónea**: `terrain_bonus_table.gd` SÍ existe (ver §2). Conservé su cita.

### Lo que NO pudo hacer (honestidad obligatoria)

- No creé meshes voxel para prendas (requiere M65 assets).
- No hay test de combate con equipo: el sistema de combate (M164) **no lee M155** (grep `defensa|equipment` en `scripts/combat/` = 0). Queda `[?]` con dueño M164.
- No hay verificación visual del M154 (vía de visión no operativa en esta corrida). Queda `[?]` con dueño M154.

### Historial de iteraciones (heredado)

- **Iter. 1-2 (2026-08-22 / 2026-09-01, MiMo V2.5 + stepfun-3.7-flash):** núcleo + `UnlockCondition` + UI básica + tests.
- **Iter. 3 (2026-09-01, deepseek-v4-flash-vision-exp):** `EquipmentLayer` (capa M53) reemplaza el esqueleto roto.
- **Iter. 4 (2026-10-10, DeepSeek-V4.1-Flash, Log 1609):** `test_equipment_m155.gd` — los 3 fallos eran expectativas del test, no bugs de producto; guardián anti-falso-verde + piso `CHECKS_MINIMOS=29`.
- **Iter. 5 (2026-10-11, DeepSeek-V4.1-Flash):** esta corrección documental + highlight L123.

### Recomendaciones para el próximo agente

- Integrar con M164 (combate) cuando ese módulo exista: exponer un `get_defense_bonus()` en `EquipmentManager` y consumirlo desde el combate.
- Decidir si se migra el catálogo/tabla a los `.tres` (`equipment_catalog.tres` / `terrain_bonuses.tres`) o se retiran los Resource hoy sin consumidor.
