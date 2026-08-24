**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 04-Codigo.md — Modulo 164: Isla de Combate Endgame

## 1. Archivos del Modulo

| Archivo | Tipo | Descripcion |
|---------|------|-------------|
| combat_island_system.gd | Autoload | Sistema central de la isla |
| gem_currency.gd | Resource | Sistema de gemas |
| island_zone.gd | Resource | Zona de la isla |
| enemy_data.gd | Resource | Definicion de enemigos |
| boss_data.gd | Resource | Definicion de jefes |
| combat_reward.gd | Resource | Recompensas de combate |
| gem_exchange_npc.gd | Node3D | NPC intercambio por gemas |
| enemy_spawner.gd | Node3D | Spawner de enemigos |
| enemy_ai.gd | Node3D | IA basica de enemigos |
| combat_island_ui.gd | Control | UI de la isla |
| health_system.gd | Resource | Sistema de vida del jugador |

## 2. Contratos Clave

```
# Intercambiar herramienta por gemas
GemExchangeNPC.exchange_tool(tool_id: String) -> int  # retorna gemas obtenidas

# Verificar si jugador tiene gemas suficientes
CombatIslandSystem.can_access_zone(zone_id: String) -> bool

# Desbloquear zona
CombatIslandSystem.unlock_zone(zone_id: String) -> bool

# Derrotar enemigo
CombatDefeatenemy(enemy_id: String) -> Dictionary  # retorna gemas + recursos

# Derrotar jefe
CombatDefeatBoss(boss_id: String) -> Dictionary  # retorna recompensas

# Obtener gemas del jugador
GemCurrency.get_gems() -> int

# Agregar gemas
GemCurrency.add_gems(amount: int) -> void

# Gastar gemas
GemCurrency.spend_gems(amount: int) -> bool
```

## 3. Estructura de Datos

```
# enemy_data.gd (Resource)
@export var id: String
@export var display_name_key: String
@export var hp_max: int
@export var attack: int
@export var speed: float
@export var gem_reward: int
@export var loot_table: Array[Dictionary]  # [{item_id, chance, min, max}]
@export var ai_type: String  # "melee", "ranged", "stationary"
@export var mesh: Mesh
@export var spawn_weight: float  # peso en el spawner

# boss_data.gd (Resource) extends EnemyData
@export var phases: int  # numero de fases
@export var phase_thresholds: Array[float]  # % de HP para cambiar fase
@export var special_abilities: Array[String]  # habilidades especiales
@export var music_track: AudioStream  # musica de jefe
```

---

## Modulos Relacionados

### Depende de

| Modulo | Que aporta |
|--------|------------|
| **M158** — Herramientas | Acceso |
| **M163** — Encantamientos | Gemas |
| **M22** — Historia | Contexto |
| **M27** — Islas | Estructura |
| **M38** — Economia | Gemas |

### Relacionados laterales

| Modulo | Relacion |
|--------|----------|
| **M013** — Herramientas | Combate |
| **M039** — Tiendas | Tienda |
| **M014** — Inventario | Gemas |
| **M071** — Progresion | Hitos |
| **M072** — Logros | Logros |
