**Modelo:** stepfun-3.7-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01

# 03-Diseno.md — Módulo 155: Vestimenta y Accesorios

## 1. Arquitectura

```
M11 (Personaje) ──► EquipmentManager (autoload)
M14 (Inventario) ──► gestión de ítems tipo "prenda"
M156 (Terrenos) ──► consulta de modificadores de terreno
                          │
                  ──► EquipmentUI (CanvasLayer)
                          │
                  ──► EquipmentData (Resource: 4 slots)
                          │
                          ▼
                  PlayerEquipmentComponent (node en M11)
```

## 2. Data Model

### 2.1 Resource: EquipmentSlot

```gdscript
class_name EquipmentSlot extends Resource

enum SlotType { HEAD, BODY, FEET, ACCESSORY }

@export var slot_type: SlotType
@export var item_id: String
@export var item_name: String  # localizable
@export var cosmetic_mesh: Mesh  # voxel mesh para renderizar
@export var terrain_bonuses: Dictionary  # { "mud": 0.35, "pavement": 0.30 }
@export var comfort_penalty: float  # -0.05 si usa equipamiento "equivocado"
@export var description: String  # localizable
@export var rarity: String  # common, uncommon, rare, legendary
```

### 2.2 Resource: PlayerEquipment

```gdscript
class_name PlayerEquipment extends Resource

@export var head: EquipmentSlot = null
@export var body: EquipmentSlot = null
@export var feet: EquipmentSlot = null
@export var accessory: EquipmentSlot = null

func get_total_terrain_bonus(terrain_type: String) -> float:
    var bonus = 0.0
    for slot in [head, body, feet, accessory]:
        if slot and slot.terrain_bonuses.has(terrain_type):
            bonus += slot.terrain_bonuses[terrain_type]
    return clamp(bonus, -0.15, 0.40)

func get_comfort_penalty(terrain_type: String) -> float:
    var penalty = 0.0
    for slot in [head, body, feet, accessory]:
        if slot and slot.comfort_penalty < 0:
            penalty += slot.comfort_penalty
    return clamp(penalty, -0.15, 0.0)
```

## 3. Catálogo de prendas (ejemplos iniciales)

### 3.1 Slot Pies (funcional principal)

| ID | Nombre | Bonos | Desbloqueo |
|----|--------|-------|------------|
| feet_boots_mud | Botas de barro | Barro +35%, césped 0%, pavimento 0% | Tienda del pueblo |
| feet_skates | Patines | Pavimento +30%, barro -60%, arena -70% | Misión del comerciante |
| feet_bike | Bicicleta | Camino +20%, pavimento +40%, barro -50% | Tienda ciudad (late-game) |
| feet_boots_water | Botas de agua | Agua poco profunda +30%, barro +10% | Exploración costa |
| feet_sandals | Sandalias | Arena +20%, césped +5%, nieve -15% | Inicio del juego |
| feet_boots_winter | Botas de invierno | Nieve +20%, hielo +15%, barro +5% | Evento de invierno |

### 3.2 Slot Cabeza (cosmético + bono menor)

| ID | Nombre | Bonos | Desbloqueo |
|----|--------|-------|------------|
| head_hat_fisher | Sombrero de pescador | Lluvia -10% (comodidad) | EVENTO: regalo del pescador |
| head_helm_explorer | Casco de explorador | Caída menor reducida | Misión de templo |
| head_scarf_warm | Bufanda de lana | Frío +15% (comodidad) | Tienda de invierno |

### 3.3 Slot Cuerpo (cosmético + bono climático)

| ID | Nombre | Bonos | Desbloqueo |
|----|--------|-------|------------|
| body_coat_rain | Capa impermeable | Lluvia +25% comodidad, nadar +10% | Tienda de la costa |
| body_vest_explorer | Chaleco explorador | Carga +10% (M14 slots extra) | Misión de exploración |
| body_shirt_casual | Camisa casual | Sin bonos, solo cosmético | Inicio del juego |

### 3.4 Slot Accesorio (funcional secundario)

| ID | Nombre | Bonos | Desbloqueo |
|----|--------|-------|------------|
| acc_backpack | Mochila | Inventario +5 slots (M14) | Tienda del pueblo |
| acc_linterna | Linterna | Visibilidad en cuevas +20% | Exploración ruinas |
| acc_brújula | Brújula | Muestra dirección en HUD | Regalo del anciano |

## 4. Flujo de equipamiento

1. Jugador abre menú de equipo (atajo teclado o desde inventario M14).
2. Muestra los 4 slots vacíos o con prenda actual.
3. Jugador selecciona un slot → ve lista de prendas disponibles para ese slot.
4. Jugador selecciona una prenda → se equipa instantáneamente.
5. Si ya había una prenda equipada → se intercambia (la anterior vuelve al inventario).
6. Los bonos se aplican inmediatamente al cálculo de velocidad en M11/M156.

## 5. Feedback visual

- Al equipar una prenda → el mesh del personaje se actualiza (superposición voxel).
- Indicador de bono activo: mini-icono en HUD mostrando terreno favorito.
- Si el jugador está en terreno "adecuado" para su equipamiento → brillo sutil en el slot.
- Si el jugador está en terreno "inadecuado" → icono de advertencia suave (sin penalización visual).

## 6. Integración con guardado (M59)

- `PlayerEquipment` se serializa como Resource en GameState.
- Las prendas equipadas se guardan como `Array[EquipmentSlot]`.
- Las prendas en inventario se guardan como `Array[ItemData]` en M14.
- Al cargar partida → se restaura el equipo y se recalculan bonos.

## 7. Tabla de bonos por terreno (implementada) — item L110

> **Documentado el 2026-10-11 (DeepSeek-V4.1-Flash).** El checklist (L110) pedía documentar la
> tabla completa. Fuente: `equipment_manager.gd::_load_terrain_bonus_table()` (líneas 175-206).

### 7.1 Terrenos conocidos (7)

El enum `EquipmentSlot.TerrainType` define los 7 terrenos y su id numérico coincide con el
`terrain_id` de M156 (§4.1 de M156). La clave usada en los `Dictionary` es el nombre del enum
**en minúsculas** (`TerrainModifiers.clave_terreno_m155()` hace el lookup inverso id → clave):

| id | Enum | Clave (dict) |
|---|---|---|
| 0 | GRASS | `grass` |
| 1 | MUD | `mud` |
| 2 | PAVEMENT | `pavement` |
| 3 | SAND | `sand` |
| 4 | SHALLOW_WATER | `shallow_water` |
| 5 | SNOW | `snow` |
| 6 | ROCK | `rock` |

### 7.2 Tabla `terrain_bonus_table` (multiplicadores por prenda de pies)

Valores tal como están en código (`equipment_manager.gd:176-205`). `1.00` = neutro.

| Terreno | boots_mud | skates | bike | boots_water | sandals | boots_winter |
|---|---|---|---|---|---|---|
| grass | 0.00 | 0.90 | 1.20 | 0.00 | 1.05 | 0.75 |
| mud | 0.95 | 0.40 | 0.50 | 0.70 | 0.55 | 0.85 |
| pavement | 0.00 | 1.30 | 1.40 | 0.00 | 1.00 | 0.90 |
| sand | 0.80 | 0.30 | 0.60 | 0.75 | 1.20 | 0.60 |
| shallow_water | 0.60 | 0.00 | 0.00 | 1.30 | 0.40 | 0.75 |
| snow | 0.85 | 0.50 | 0.70 | 0.75 | 0.60 | 1.20 |
| rock | 0.90 | 0.80 | 0.00 | 0.90 | 0.85 | 0.90 |

### 7.3 Alcance real de esta tabla (honestidad de diseño vs. código)

Medido con `grep` (2026-10-11): `terrain_bonus_table` se usa **solo para enumerar las 7 claves**
(`equipment_manager.gd:291`, dentro de `_emit_terrain_bonus_update()`). El bono efectivo que
consume M11/M156 **no** sale de esta tabla, sino de los `terrain_bonuses` de cada prenda
(§2.1) agregados por `PlayerEquipment.get_total_terrain_bonus()`:

```
velocidad_efectiva = move_speed × modificador_terreno(M156) × (1 + get_terrain_bonus(clave))
```

`get_terrain_bonus(clave)` → `player_equipment.get_total_terrain_bonus(clave)`, con el clamp
`[-0.15, 0.40]` de §2.2. Es decir: **los multiplicadores de §7.2 no entran en el cálculo de
velocidad**; son datos de diseño que quedaron sin consumidor. Reportado, no modificado
(el balance de bonos es deuda de playtest).

### 7.4 Feedback visual del terreno actual (item L123)

§5 pide *"brillo sutil en el slot"* cuando el jugador está en un terreno adecuado. Implementado el
2026-10-11 en `scripts/ui/layers/equipment_layer.gd`: cada slot se resalta (color de fuente verde
si el bono es positivo, rojo si es negativo) cuando la prenda equipada tiene un bono distinto de
cero para la clave del terreno actual. El terreno se lee del `TerrainDetector` del Player
(`get_current_terrain_id()` → `TerrainModifiers.clave_terreno_m155()`); sin detector, no hay
resaltado. Suite: `scripts/ui/test_equipment_highlight_m155.gd`.
