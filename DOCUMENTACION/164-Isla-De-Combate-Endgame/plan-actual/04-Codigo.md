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

---

## Notas del Agente (Iter 1 — parte data-driven)

**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-09-18 18:55
**Estado:** Parcial (data-driven) — modulo liberado a 🔵→🟡 por el alcance limitado

### Lo que hice

- **Nucleo data-driven de M164** (encaje A/B del agente — sin assets visuales):
  - `scripts/combat/gem_currency.gd` (autoload `gem_currency`): API get/has/add/spend,
    reglas cozy (nunca negativo, no descartable, no se pierde al morir), tabla de cambio
    por tier (T1=1, T2=2, T3=3, T4=5), rangos de gemas por categoria (basico 1-2, medio
    2-3, fuerte 3-5, jefe 5-15), persistencia versionada M59.
  - `scripts/combat/combat_island_system.gd` (autoload `combat_island`): 4 zonas con
    coste 0/10/25/50, desbloqueo permanente (cobra una sola vez), conteo de derrotas
    (M71/M72), recompensas, porcentaje de completado, persistencia M59.
  - `scripts/combat/enemy_catalog.gd`: 11 enemigos + 2 jefes con la tabla canonica del
    diseño (HP/ataque/velocidad/gemas/categoria/IA/peso), validacion de esquema.
  - `scripts/combat/enemy_data.gd` + `boss_data.gd`: Resources con esquema validable
    (patron FaunaSchema de M36).
  - `scripts/combat/island_zone.gd`: Resource de zona con coste/enemigos/recursos/tienda.
  - `scripts/combat/combat_reward.gd`: 6 recompensas exclusivas cosméticas.
  - `scripts/combat/gem_save_provider.gd` + `combat_island_save_provider.gd`: puentes
    M59 (patron separado AGENTS.md §15, igual que ToolsSaveProvider de M13).
  - `scripts/combat/test_combat_m164_atria.gd`: suite headless **0 fallos** con guardián
    anti-falso-verde (marcador `_fin` por bloque), cotas min Y max, ids inexistentes.
- **Autoloads** registrados en `project.godot` (lineas 132-133): `gem_currency` y
  `combat_island`. `.gd.uid` generados con el escaneo del editor.
- **Boot verificado**: 0 SCRIPT ERROR, 0 regresiones (test_herramientas M13 0 fallos).

### Lo que NO pude hacer (honestidad obligatoria)

- **Todo lo visual/VFX/IA** (encaje C — soy solo texto, error 400 confirmado en vision):
  meshes y animaciones de los 11 enemigos (D.12/D.13), IA de persecucion (D.14-D.16),
  fases de jefe ejecutadas (D.17), spawner con caps (D.18-D.19), barras de vida y
  feedback (D.20/D.21), combate y vida del jugador (seccion E completa), UI
  (combat_island_ui.gd), tienda y dialogo NPC (seccion G), sonidos (E.13-E.16).
- **Integraciones con modulos que no existen o estan en duda**: M155 (skins), M18
  (decoraciones), M39 (tienda isla), M19/M162 (dialogo NPC), M71/M72 (hitos/logros —
  los contadores SI estan listos para que ellos consuman), M14 (item gema M159).
- **Monetizacion** (B.41/B.42): comprar gemas con dinero real queda en [?]. El juego
  actual no integra Steam y vender gemas rompe el bucle cozy de progreso por juego;
  es decision de diseno del usuario (ver M126).

### Intentos fallidos / decisiones

- **Order de umbrales de fase**: originalmente validaba `phase_thresholds` en orden
  ascendente estricto, pero el diseño los expresa descendentes (0.75, 0.5, 0.25 — de
  HP alto a bajo). Corregido a descendente en `es_valido_jefe()`.
- **`_zonas_por_defecto` con Array tipado**: `enemy_ids.assign(array_plano)` fallaba en
  tipado estricto de Godot 4.7; reemplazado por construccion explicita `Array[String]`.
- **Test fuera del arbol**: `CombatIslandSystem.new()` en test headless no corre
  `_ready()`, asi que el catalogo no se cargaba. Anadido `cargar_catalogo_para_test()`
  publico (mismo patron que FaunaManager).
- **Autoload gem_currency en tests**: el test añade gemas a una instancia local, pero
  `unlock_zone` busca el autoload del arbol. Corregido para usar el nodo real con
  snapshot+restauracion del saldo (no ensucia el estado global).
- **class_name sin .uid**: Godot 4.7 no resolvio los `class_name` nuevos hasta que el
  editor escaneo y genero los `.gd.uid`. Documentado para el proximo agente: tras crear
  scripts con class_name, correr `--headless --editor --quit` una vez.

### Recomendaciones para el proximo agente

1. **Prioridad para cerrar el modulo**: M64 (IA de enemigos) es la dependencia mas
   grande — sin IA no hay combate. Despues M11 (vida del jugador, seccion E) y M53
   (UI de la isla).
2. **Los datos ya estan listos**: EnemyCatalog, IslandZone y CombatReward exponen toda
   la tabla del diseño; el agente de IA solo necesita consumirlos (no redisenar).
3. **`.tres` diferido**: el catalogo vive en codigo (patron M13/M36). Si M159 quiere
   editar los datos sin codigo, crear `data/combat/*.tres` — el cargador de
   `_cargar_catalogo()` ya lo prefiere si existe (`zone_catalog.tres` con
   `obtener_todas()`).
4. **B.41/B.42 (monetizacion)**: levantar la decision al usuario antes de tocarlo.
5. **Test de regresion**: correr `test_combat_m164_atria.gd` despues de cualquier
   cambio en el modulo — el guardián anti-falso-verde detecta bloques saltados.
