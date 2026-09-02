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
