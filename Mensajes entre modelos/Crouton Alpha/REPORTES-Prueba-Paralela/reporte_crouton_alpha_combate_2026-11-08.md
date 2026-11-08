# Reporte Crouton Alpha — Combate, daño, salud, vida y muerte de entidades

**Modelo:** Crouton Alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-11-08
**Alcance:** `game/isla-ancestral/scripts/` (`.gd` relacionados con combate, daño, salud, vida y muerte)
**Idioma:** Español

## Resumen ejecutivo

El sistema de combate está en fase **data-driven / de diseño**, no de ejecución en runtime. Existe un componente genérico de salud (`HealthComponent`), una interfaz de contrato (`IDamageable`) y datos/catálogos de enemigos y jefes (M164), pero **no están cableados entre sí ni con el jugador o los enemigos en escena**. Resultado: hay clamp de salud y validación en datos, pero no hay validación de daño negativo en el componente central, no hay pipeline de muerte/desaparición, y el jugador no tiene salud ni puede morir en runtime.

---

## 1. Archivos analizados

| Archivo | Rol | Líneas relevantes |
|---|---|---|
| `game/isla-ancestral/scripts/utils/components/health_component.gd` | Componente reutilizable de salud (M111) | 30 líneas completas: señales 7-8, setter de `current_health` 12-19, `damage()` 26-27, `heal()` 29-30 |
| `game/isla-ancestral/scripts/interfaces/i_damageable.gd` | Interfaz `IDamageable` (contrato de daño/salud) | `take_damage()` 16-17, `get_health()` 21-22, `is_alive()` 31-32, `heal()` 37-38, `set_health()` 42-43, señales 46, 49 |
| `game/isla-ancestral/scripts/combat/combat_island_system.gd` | Autoload `combat_island` (M164): zonas, derrotas, recompensas, persistencia | 212 líneas; `registrar_derrota()` 126-130; cabecera 12-15 declara explícitamente que NO gestiona IA, spawner, combate real ni vida del jugador |
| `game/isla-ancestral/scripts/combat/enemy_data.gd` | `EnemyData` (Resource): `hp_max`, `attack`, `speed`, `gem_reward`, `loot_table` | `es_valido()` 36-38; `hp_max` 20, `attack` 22 |
| `game/isla-ancestral/scripts/combat/enemy_catalog.gd` | Catálogo por código de 11 enemigos + 2 jefes | Tabla 21-34 (HP 2-15, jefes 30 y 50 HP), `_e()` 36-48, `_b()` 50-62 |
| `game/isla-ancestral/scripts/combat/boss_data.gd` | `BossData extends EnemyData`: fases y habilidades especiales | `es_valido_jefe()` 25-37; cabecera: la ejecución de fases la consume `enemy_ai` (M64, pendiente) |
| `game/isla-ancestral/scripts/combat/gem_currency.gd` | Moneda de acceso a zonas (cozy: nunca se pierde al morir) | `add_gems()` 41-46, `spend_gems()` 49-58 |
| `game/isla-ancestral/scripts/combat/combat_reward.gd` | Recompensas cosméticas de la Isla de Combate | 54 líneas; sin daño ni salud |
| `game/isla-ancestral/scripts/player/player.gd` | Jugador `CharacterBody3D` (movimiento, inventario, herramientas, hotbar) | 1215 líneas; **sin** `HealthComponent`, sin `take_damage`, sin salud |
| `game/isla-ancestral/scripts/player/player_core_m11.gd` | Adaptador FSM + energía (M11) | 282 líneas; solo energía cozy, sin salud ni muerte |
| `game/isla-ancestral/scripts/player/player_energy.gd` | Modelo puro de energía/stamina cozy (M11) | `actualizar()` 76-97; líneas 89-90: "no hay muerte ni bloqueo permanente" |
| `game/isla-ancestral/scripts/core/event_bus.gd` | EventBus central | `PlayerEvents.player_died(spawn_point)` línea 154 y `damage_taken(amount, source)` línea 158 (definidas, sin emisores encontrados) |
| `game/isla-ancestral/tests/test_m111_utils_headless.gd` | Test headless del componente de salud | `_test_components()` líneas 148-157 |
| `game/isla-ancestral/tests/unit/interfaces/test_i_damageable.gd` | Test de la interfaz `IDamageable` | `take_damage` líneas 38, 144, 201; señal `died` línea 226 |

> No existen carpetas `scripts/dano/` ni `scripts/salud/`. Los equivalentes son `scripts/combat/`, `scripts/interfaces/i_damageable.gd` y `scripts/utils/components/health_component.gd`.

---

## 2. (1) ¿Cómo se gestiona el daño y la salud?

### 2.1 `HealthComponent` — el único sistema de salud ejecutable

`scripts/utils/components/health_component.gd:1-30`:

```gdscript
class_name HealthComponent
extends Node

signal health_changed(current: float, max_value: float)
signal died

@export var max_health: float = 100.0

var current_health: float:
    get:
        return _current
    set(v):
        _current = clamp(v, 0.0, max_health)
        health_changed.emit(_current, max_health)
        if _current <= 0.0:
            died.emit()

var _current: float = 100.0

func _ready() -> void:
    _current = max_health

func damage(amount: float) -> void:
    current_health -= amount

func heal(amount: float) -> void:
    current_health += amount
```

Comportamiento medido:

- **Clamp en el setter (12-19):** toda escritura pasa por `clamp(v, 0.0, max_health)`. Test en `tests/test_m111_utils_headless.gd:152-157` lo confirma: `damage(200.0)` con 100 HP deja `current_health == 0.0`; `heal(50.0)` con 70 HP deja `100.0`.
- **Señales:** `health_changed(current, max)` en cada escritura; `died` cuando se llega a 0.
- **No hay resistencias, armadura, tipo de daño ni fuente del golpe** en la implementación, aunque la interfaz sí los prevé (ver 2.2).
- **No devuelve daño real aplicado:** `damage()` y `heal()` retornan `void` (26-30), a diferencia del contrato de la interfaz.

### 2.2 `IDamageable` — contrato bien diseñado, no implementado por el componente

`scripts/interfaces/i_damageable.gd:16-49`:

- `take_damage(amount, damage_type: StringName = &"", source: Node = null) -> float` (16): devuelve el **daño real aplicado** tras resistencias/armadura.
- `get_health()` (21), `get_max_health()` (26), `is_alive()` → `get_health() > 0.0` (31-32), `heal(amount) -> float` (37), `set_health(value)` con clamp a `[0, max_health]` (42-43).
- Señales: `health_changed(new_health, max_health, damage_taken)` (46) y `died(killer: Node)` (49).

Desconexión detectada: **ninguna clase de runtime implementa `IDamageable`**. `HealthComponent` no hereda de él ni expone `take_damage()`, `get_health()`, `is_alive()` o `set_health()`. Además hay un desajuste de firma: `HealthComponent.died` es `signal died` sin argumentos (línea 8) mientras que la interfaz declara `signal died(killer: Node)` (línea 49), por lo que un listener conectado al contrato no podría conectarse directamente al componente. El test `tests/unit/interfaces/test_i_damageable.gd:38,144,201,226` usa una clase stub propia, no el componente real.

### 2.3 Datos de enemigos (M164, solo diseño)

`scripts/combat/enemy_data.gd:20-32,36-38` y `scripts/combat/enemy_catalog.gd:21-34`:

- `EnemyData` define `hp_max: int = 1` (20), `attack: int = 1` (22), `speed` (24), `gem_reward` (26), `loot_table` (28), `ai_type: "melee"|"ranged"|"stationary"` (30) y `spawn_weight` (32).
- El catálogo instancia 11 enemigos (HP 2-15, ataque 1-5) y 2 jefes (`guardian_montana` HP 30, `senor_del_templo` HP 50, con `phase_thresholds` y `special_abilities` en `boss_data.gd:13-17`).
- **Nadie consume estos datos en runtime:** la cabecera de `combat_island_system.gd:12-15` y `enemy_data.gd:23` / `boss_data.gd:8` indican que la IA, el spawner, los meshes y el combate real son del pendiente M64/M45. No hay `Enemy` ni `Boss` escena/script que aplique `attack` a un `HealthComponent`.

### 2.4 Jugador — sin salud, solo energía cozy

- `scripts/player/player.gd` (1215 líneas): movimiento, voxel, herramientas, inventario y hotbar. **No instancia `HealthComponent`, no define `take_damage`, no tiene `max_health` ni `current_health`.**
- `scripts/player/player_core_m11.gd` y `scripts/player/player_energy.gd:76-97`: el jugador vive de **energía/stamina** (0-100), no de salud. La regla cozy (líneas 15-20 y 89-90 de `player_energy.gd`): la energía nunca llega a 0 por caminar/correr (costo 1/min = regen 1/min, balance neto 0); a 0 por herramientas el personaje descansa, "**no hay muerte ni bloqueo permanente**".
- El daño al jugador está declarado en el bus (`event_bus.gd:158`, `damage_taken(amount, source)`) pero **no se encontró ningún emisor**; `player_died(spawn_point)` (`event_bus.gd:154`, comentado como "cozy: respawn, no game over") tampoco se emite en ningún script de `scripts/`. El respawn cozy existente es de náufrago en el océano (`islas/island_travel_guard.gd:397`, `respawn_cozy(pos)`), no de muerte en combate.
- `gem_currency.gd:11` documenta "las gemas nunca se pierden al morir (B.45)", pero al no haber muerte del jugador en runtime esa regla no es ejercitable.

### 2.5 Sistema central de la Isla de Combate

`scripts/combat/combat_island_system.gd` (212 líneas): autoload `combat_island` que gestiona **desbloqueo de zonas por gemas** (`unlock_zone()` 97-114), **conteo de derrotas** (`registrar_derrota(enemy_id)` 126-130, emite `enemigo_derrotado(enemy_id, total)`) y **recompensas** (146-164), con persistencia M59. **No aplica daño, no controla HP, no mata ni despawnea entidades.** Su propia cabecera (12-15) lo declara: el combate real, la vida del jugador y la IA de enemigos quedan fuera de esta iteración.

---

## 3. (2) ¿Hay validación de valores de daño negativos o nulos?

### 3.1 Donde SÍ hay validación

| Lugar | Validación | Archivo:línea |
|---|---|---|
| Clamp de salud resultante | `clamp(v, 0.0, max_health)` en el setter de `current_health` | `health_component.gd:16` |
| Datos de enemigo | `es_valido()`: `hp_max > 0 and attack > 0 and speed > 0.0 and gem_reward >= 0` | `enemy_data.gd:36-38` |
| Jefes | `phases >= 1` y umbrales en `(0,1)` descendentes (líneas 28-36) | `boss_data.gd:25-37` |
| Moneda de gemas | `add_gems(amount)`: `if amount <= 0: return` (42-43); `spend_gems(amount)`: `if amount <= 0: return true` (50-51); `has_gems(amount)`: `amount >= 0 and _gemas >= amount` (38) | `gem_currency.gd:38,42-51` |
| Energía del jugador (análogo) | `clampf(..., 0.0, ENERGIA_MAX)` y `consumir_energia` usa `maxf(costo, 0.0)` | `player_energy.gd:87,118`; `player_core_m11.gd:252` |

### 3.2 Donde NO hay validación — hallazgos

**H1. `HealthComponent.damage()` y `heal()` aceptan valores negativos sin validar** (`health_component.gd:26-30`):

```gdscript
func damage(amount: float) -> void:
    current_health -= amount

func heal(amount: float) -> void:
    current_health += amount
```

- `damage(-50.0)` equivale a curar 50 (sube la salud hasta el clamp). `heal(-50.0)` equivale a dañar 50 y puede **matar** (emite `died`) sin que el llamador lo espere.
- `damage(0.0)` / `heal(0.0)` no son no-op: re-emiten `health_changed` y, si la salud ya era 0, **re-emiten `died`** (ver H2).
- La interfaz `IDamageable` tampoco valida en su cuerpo por defecto (`take_damage()` retorna `0.0` sin tocar nada, `i_damageable.gd:16-17`): cualquier implementación que la reproduzca heredaría la ausencia de guardas.

**H2. `died` se emite en cada escritura a 0, no una sola vez** (`health_component.gd:18-19`):

```gdscript
if _current <= 0.0:
    died.emit()
```

Como el setter emite siempre (`health_changed` + chequeo), tras morir cualquier `damage()` posterior (o incluso `heal(-1.0)`) vuelve a emitir `died`. No hay flag `_muerto` / `is_alive()` en el componente. Un listener que libere botín, cuente la derrota o libere el nodo recibiría el evento **N veces** por la misma muerte. En `tests/test_m111_utils_headless.gd:156-157` el test solo aserta el clamp final (`current_health == 0.0`), no la unicidad de `died`.

**H3. `max_health` sin validación de su propio valor** (`health_component.gd:10`): es `@export var max_health: float = 100.0` sin setter. Un diseñador puede poner `max_health = -5.0` o `0.0` y entonces `clamp(v, 0.0, max_health)` colapsa (en Godot, `clamp` con mínimo > máximo devuelve el máximo: toda escritura quedaría en un valor negativo o 0 y la entidad nacería muerta, emitiendo `died` en el primer set). Además `_current` se inicializa hardcodeado a `100.0` (línea 21) y recién se iguala a `max_health` en `_ready()` (línea 24): si un nodo se instancia y se le escribe salud antes de `_ready()`, el valor inicial no refleja el máximo configurado.

**H4. `EnemyData` valida en datos, pero nada valida en runtime:** `es_valido()` (`enemy_data.gd:36-38`) existe y `enemy_catalog.gd:74-82` (`todas_validas()`) lo usa como guardián anti-falso-verde en tests, pero al no existir escena de enemigo que aplique `attack` ni `hp_max` a un `HealthComponent`, la validación no protege ningún flujo de daño real. Un `attack` negativo creado por código (no por catálogo) pasaría directamente a `HealthComponent.damage()` (H1).

**H5. `CombatIslandSystem.registrar_derrota()` sin validación de entrada** (`combat_island_system.gd:126-130`):

```gdscript
func registrar_derrota(enemy_id: String) -> void:
    var total: int = int(_derrotas.get(enemy_id, 0)) + 1
    _derrotas[enemy_id] = total
    enemigo_derrotado.emit(enemy_id, total)
```

Acepta `enemy_id = ""` o un id inexistente, creando una entrada fantasma en `_derrotas` que computa en `total_enemigos_derrotados()` (135-139) y puede otorgar la recompensa de hito (`titulo_cazador_de_cristal` a los 100, líneas 147-149) con derrotas inválidas.

---

## 4. (3) ¿Hay problemas de muerte / desaparición de entidades?

**Sí. Hay un problema de arquitectura, no un bug puntual: el evento de muerte no está conectado a ninguna consecuencia.** Detalle:

1. **Muerte sin cuerpo:** `HealthComponent` emite `died` (línea 19) pero el componente **no despawnea, no hace `queue_free()`, no desactiva físicas, no suelta loot ni notifica al `CombatIslandSystem`**. Como es un `Node` hijo reutilizable (composición), la entidad padre queda con salud 0 pero **sigue en escena, sigue colisionando y puede seguir atacando** hasta que alguien lo retire manualmente. No se encontró ningún `died.connect(...)` en `scripts/` que maneje desaparición, loot o conteo de derrotas.
2. **Doble conteo por re-emisión (H2):** si el futuro listener de M64 conecta `died` a `CombatIslandSystem.registrar_derrota()` + `GemCurrency.add_gems()` + loot, cada golpe posterior a la muerte re-emitiría `died` y **multiplicaría recompensas y derrotas**. Hoy el riesgo está latente porque nada escucha la señal; en cuanto M64 la conecte, el bug se activa.
3. **Jugador inmortal por ausencia, no por diseño de respawn:** el bus define `player_died(spawn_point)` (`event_bus.gd:154`) pero nadie lo emite; el jugador no tiene `HealthComponent` (`player.gd` completo sin salud). No hay pantalla de muerte, ni respawn por combate, ni pérdida (cozy B.45) ejercitable. El único respawn existente es el de náufrago (`island_travel_guard.gd:397`, `respawn_cozy`), que no pasa por salud.
4. **Enemigos sin ciclo de vida:** no existe escena/script de enemigo instanciable (`enemy_ai` M64 pendiente, `boss_data.gd:8`). No hay spawner ni despawn por distancia/tiempo que pueda hacer desaparecer entidades por accidente; tampoco hay `queue_free()` de enemigo al morir porque no hay enemigo vivo que liberar. Los únicos `queue_free()` del dominio son de tests (`tests`/`test_*`) y de UI.
5. **NPCs:** `scripts/ia_npc/state_machine.gd:184-185,217` define `_respawn_emergency()` para NPCs atascados (flujo Ilde/Idle), sin relación con daño/salud: los NPCs tampoco tienen `HealthComponent` (grep sin resultados en `scripts/ia_npc/`). No hay muerte de NPC en runtime.
6. **Sin invulnerabilidad ni ventana post-golpe:** nada impide que dos hits en el mismo frame bajen la salud dos veces o que un DoT re-emita `died` varias veces (H2). No hay `is_alive()` en el componente para que un atacante pregunte "¿sigue vivo?" antes de golpear.

**Conclusión del punto (3):** las entidades **no desaparecen hoy** porque **no pueden morir en runtime de forma completa**: falta el pipeline `died → (loot / conteo / gemas) → queue_free/despawn` y falta el guard de "ya murió una vez". El problema se manifestará como duplicación de recompensas y entidades-zombi en cuanto M64 (IA de enemigos) conecte la señal.

---

## 5. (4) Dos mejoras propuestas

### Mejora A — Endurecer `HealthComponent` (validación + muerte única + contrato)

Archivo: `game/isla-ancestral/scripts/utils/components/health_component.gd` (líneas 10-30).

```gdscript
@export var max_health: float = 100.0:
    set(v):
        max_health = maxf(v, 1.0)   # H3: máximo siempre > 0
        _current = clampf(_current, 0.0, max_health)

var _muerto: bool = false

func is_alive() -> bool:
    return not _muerto and _current > 0.0

func damage(amount: float) -> float:   # devuelve daño real aplicado (contrato IDamageable)
    if _muerto or amount <= 0.0:
        return 0.0                     # H1: negativo/nulo = no-op
    var antes := _current
    current_health -= amount
    return antes - _current

func heal(amount: float) -> float:
    if _muerto or amount <= 0.0:
        return 0.0
    var antes := _current
    current_health += amount
    return _current - antes

# En el setter de current_health, reemplazar la emisión final por:
# if _current <= 0.0 and not _muerto:
#     _muerto = true
#     died.emit()
# Y agregar set_health(value) + get_health()/get_max_health() para cumplir IDamageable,
# alineando la señal a died(killer: Node) o documentando la diferencia.
```

Efecto: cierra H1 (daño/curación negativa), H2 (muerte única) y H3 (máximo inválido), y hace al componente implementable como `IDamageable` sin duplicación de lógica en cada enemigo futuro.

### Mejora B — Cablear el pipeline de muerte (sin duplicar recompensas)

Archivos: `game/isla-ancestral/scripts/utils/components/health_component.gd:8,19` (origen), `game/isla-ancestral/scripts/combat/combat_island_system.gd:126` (destino de conteo), futuro `enemy_ai` M64 (destino de `queue_free`).

1. Conectar `HealthComponent.died` **una sola vez por entidad** (apoyándose en el guard `_muerto` de la Mejora A) a un manejador único del enemigo que, en orden: (a) desactive colisión/IA, (b) llame a `CombatIslandSystem.registrar_derrota(enemy_id)` y `GemCurrency.add_gems(gem_reward)` **después** de validar `enemy_id != ""` y existente en el catálogo (cierra H5), (c) suelte el `loot_table` de `EnemyData:28`, y (d) haga `queue_free()` o devuelva la instancia al pool del spawner.
2. Para el jugador, cuando se le agregue un `HealthComponent` (hoy inexistente en `player.gd`), conectar su `died` a `EventBus.PlayerEvents.player_died.emit(spawn_point)` (`event_bus.gd:154`) y al `respawn_cozy` ya probado de `island_travel_guard.gd:397`, manteniendo la regla cozy B.45 (`gem_currency.gd:11`: las gemas no se pierden al morir).
3. Agregar un test headless que afirme: (i) `damage(-10)` y `heal(-10)` son no-op, (ii) `died` se emite exactamente 1 vez tras 3 golpes letales, (iii) `registrar_derrota("")` no crea entrada ni otorga hitos.

Efecto: convierte la señal huérfana en un ciclo de vida completo (muerte → recompensa → desaparición/respawn), elimina el riesgo de entidades-zombi y de duplicación de botín, y hace ejercitable la regla cozy de respawn.

---

## 6. Conclusión final

El sistema de combate de Isla Ancestral es **sano en datos y frágil en runtime**. `EnemyData`/`BossData`/`EnemyCatalog` (M164) validan HP, ataque, velocidad y fases; `GemCurrency` valida montos; `HealthComponent` aplica clamp y un test headless lo cubre. Pero el componente central **no valida daño negativo/nulo**, **re-emite `died` en cada escritura a 0**, **no valida `max_health`** y **no implementa el contrato `IDamageable`** que él mismo debería satisfacer. El jugador **no tiene salud** (solo energía cozy sin muerte, `player_energy.gd:89-90`) y el bus define `player_died` sin emisor (`event_bus.gd:154`). El pipeline de muerte está **ausente**: nadie escucha `died`, nadie despawnea, nadie otorga loot ni cuenta la derrota al morir. Las dos correcciones propuestas — endurecer `HealthComponent` (validación + muerte única + contrato) y cablear el pipeline muerte → recompensa → desaparición/respawn — son el camino mínimo para que M64 (IA de enemigos) pueda implementarse sin heredar los bugs H1-H5.
