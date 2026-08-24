**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 04-Codigo.md — Modulo 163: Sistema de Encantamientos

## 1. Archivos del Modulo

| Archivo | Tipo | Descripcion |
|---------|------|-------------|
| enchantment_system.gd | Autoload | Sistema central de encantamientos |
| enchantment_data.gd | Resource | Definicion de cada encantamiento |
| shaman_npc.gd | Node3D | NPC chaman del monte |
| shaman_ui.gd | Control | UI del chaman |
| incense_cultivation.gd | Resource | Sistema de cultivo de incienso |
| enchanted_tool_visual.gd | Node3D | Efectos visuales de herramienta encantada |
| incense_spawner.gd | Node3D | Spawner de plantas de incienso |

## 2. Contratos Clave

```
# Encantar herramienta
EnchantmentSystem.enchant_tool(tool_id: String, enchantment_id: String) -> bool

# Verificar si herramienta esta encantada
EnchantmentSystem.is_enchanted(tool_id: String) -> bool

# Obtener encantamiento de herramienta
EnchantmentSystem.get_enchantment(tool_id: String) -> EnchantmentData

# Verificar si jugador tiene incienso suficiente
EnchantmentSystem.has_incense(amount: int) -> bool

# Obtener habilidad activa del encantamiento
EnchantmentSystem.get_active_ability(tool_id: String) -> Dictionary

# Aplicar bonus de venta
EnchantmentTool.get_sell_bonus(tool_id: String) -> float
```

## 3. Estructura de Datos

```
# enchantment_data.gd (Resource)
@export var id: String                    # "ancestral_cobre", etc.
@export var display_name_key: String
@export var description_key: String
@export var tool_tier: int                # tier al que aplica
@export var ability_type: String          # "double_coins", "sell_bonus", "cave_bonus", "special_trade"
@export var ability_value: float          # valor del bonus (0.5 = +50%, 2.0 = x2)
@export var visual_effect: PackedScene    # escena de particulas
@export var icon: Texture2D
@export var incense_cost: int             # costo en incienso
@export var coin_cost: int                # costo en monedas
```

## 4. Integracion con M14 (Inventario)

- ItemData.campo `is_enchanted: bool`
- ItemData.campo `enchantment: String` (id del encantamiento)
- InventorySlot hereda el encantamiento del ItemData
- El encantamiento se serializa en to_dict/from_dict

---

## Modulos Relacionados

### Depende de

| Modulo | Que aporta |
|--------|------------|
| **M013** — Herramientas | Sistema base |
| **M158** — Tiers | Definicion de tiers |
| **M159** — Catalogo | Items encantados |

### Relacionados laterales

| Modulo | Relacion |
|--------|----------|
| **M039** — Tiendas | Vende encantados |
| **M014** — Inventario | Guarda encantados |
| **M011** — Personaje | Equipa encantados |
