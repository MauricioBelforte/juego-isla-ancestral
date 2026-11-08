# Reporte: combate / daño / salud / muerte

**Modelo:** Glyph Cluster  
**Plataforma:** Vercel AI Gateway (Kilo Code)  
**Fecha:** 2026-11-08  
**Alcance revisado:** `game/isla-ancestral/scripts/` (búsqueda recursiva por nombres y por términos `take_damage|damage|health|salud|vida|muerte|died|morir|IDamageable|HealthComponent`).

## 1) Archivos relacionados encontrados

| Archivo | Rol |
|---|---|
| `game/isla-ancestral/scripts/interfaces/i_damageable.gd` | Contrato/interfaz `IDamageable` (`Resource`) para entidades dañables. |
| `game/isla-ancestral/scripts/utils/components/health_component.gd` | Componente reusable `HealthComponent` (salud actual, daño, curación, muerte). |
| `game/isla-ancestral/scripts/combat/enemy_data.gd` | Datos de enemigo (HP/ataque/velocidad/gemas) — **sin lógica de runtime**. |
| `game/isla-ancestral/scripts/combat/boss_data.gd` | Datos de jefe, extiende `EnemyData` (fases/umbrales) — **sin lógica de runtime**. |
| `game/isla-ancestral/scripts/combat/combat_island_system.gd` | Sistema central Isla de Combate: zonas, derrotas registradas, recompensas, persistencia — **no aplica daño ni gestiona HP en runtime**. |
| `game/isla-ancestral/scripts/combat/gem_currency.gd` | Moneda de gemas (acceso a zonas) — menciona regla cozy “no se pierden al morir” (línea 11), pero no implementa muerte del jugador. |
| `game/isla-ancestral/scripts/combat/enemy_catalog.gd` | Catálogo de 11 enemigos + 2 jefes (data). |
| `game/isla-ancestral/scripts/combat/combat_reward.gd`, `island_zone.gd`, `gem_save_provider.gd`, `combat_island_save_provider.gd` | Soporte data/persistencia de combate (sin HP/daño). |
| `game/isla-ancestral/tests/unit/interfaces/test_i_damageable.gd` | Tests headless del contrato `IDamageable` (incluye implementación custom de prueba). |
| `game/isla-ancestral/scripts/core/event_bus.gd` | `PlayerEvents.player_died(spawn_point)` y `damage_taken(amount, source)` declarados (líneas 152-158), sin emisores/consumidores detectados en `scripts/` por el patrón revisado. |

**No existen** (al momento del análisis): `scripts/combate/`, `scripts/dano/`, `scripts/salud/` (con nombres en español), ni scripts runtime de controlador de enemigo/jugador que apliquen daño usando estos contratos.

## 2) Análisis

### (1) ¿Cómo se gestiona el daño y la salud?

- **Contrato (`IDamageable`, `scripts/interfaces/i_damageable.gd`):** define la API de daño/salud como `Resource` con métodos stub:
  - `take_damage(amount, damage_type, source) -> float` (líneas 16-17) — retorna `0.0` por defecto.
  - `get_health/get_max_health/is_alive/heal/set_health` (21-43) — valores por defecto.
  - Señales `health_changed(new_health, max_health, damage_taken)` (46) y `died(killer)` (49).
- **Componente (`HealthComponent`, `scripts/utils/components/health_component.gd`):** `Node` reusable (M111) con `@export max_health = 100.0` (10), backing `_current` (21) y setter clamped `clamp(v, 0.0, max_health)` (16). Emite `health_changed(current, max_value)` (17) y `died` sin parámetros (18-19) cuando `_current <= 0.0`. Expone `damage(amount)` (26-27) y `heal(amount)` (29-30) que operan sobre `current_health`. `_ready()` inicializa `_current = max_health` (23-24).
- **Datos de combate (`EnemyData/BossData`, `scripts/combat/enemy_data.gd`, `boss_data.gd`):** solo atributos estáticos (`hp_max`, `attack`, `speed`, `gem_reward`, fases de jefe). `es_valido()` exige `hp_max > 0 and attack > 0 and speed > 0.0` (líneas 36-38 de `enemy_data.gd`); `BossData.es_valido_jefe()` valida fases/umbrales (25-37).
- **Sistema Isla de Combate (`CombatIslandSystem`, `combat_island_system.gd`):** gestiona progresión (zonas desbloqueadas por gemas, conteo de derrotas `registrar_derrota`, recompensas, persistencia M59). **No aplica daño ni resta HP**; las derrotas se registran como eventos lógicos (`registrar_derrota`, 126-130) — la conexión con un enemigo runtime/IA (M64) está pendiente según sus propios comentarios (7-15).
- **Integración runtime:** no se detectaron scripts en `scripts/` que extiendan `IDamageable` o que referencien `HealthComponent` para aplicar daño en gameplay (fuera de un `preload` en `scripts/editor/_colector_sintaxis.gd` y el test). Esto sugiere que la capa de **aplicación de daño/muerte en entidades vivas** aún no está implementada o no está conectada.

### (2) ¿Hay validación de valores de daño negativos o nulos?

- **`IDamageable.take_damage`**: no valida; stub retorna `0.0` (interfaz, sin semántica de validación).
- **`HealthComponent.damage(amount)`** (26-27): **no valida** `amount`. Hace `current_health -= amount`. Consecuencias:
  - `amount < 0` **cura** al objetivo (resta un negativo) y puede llevar la salud por encima de `max_health` antes del clamp solo si se pasa por setter; el setter clampa a `[0, max_health]`, por lo que un daño negativo termina actuando como curación clamped (efecto lateral inesperado, depende de intención).
  - `amount == 0` aplica un cambio nulo pero igualmente pasa por el setter (asigna `_current = clamp(...)`), emitiendo `health_changed` y pudiendo re-evaluar muerte si ya estaba en 0 — **señales espurias**.
  - `amount == NaN/INF` no se filtra; `clamp` con NaN en GDScript puede producir resultados no deseados.
- **`HealthComponent.heal(amount)`** (29-30): mismo patrón sin validación; `amount < 0` actuaría como daño.
- **`CombatIslandSystem`/catálogos:** validan datos estáticos (`hp_max > 0`, `attack > 0`), pero no son el camino de aplicación de daño en runtime.
- **Conclusión:** **no hay validación explícita de daño/curación negativos, nulos o no finitos** en el componente reusable; el clamp posterior mitiga parcialmente el overflow/underflow de salud, pero no la semántica ni las señales.

### (3) ¿Hay problemas de muerte/desaparición de entidades?

- **`HealthComponent`**: al llegar a `<= 0` emite `died` en el setter (18-19). Problemas observables:
  1. **Muerte repetible / sin estado “muerto”:** no hay guard `_is_dead`. Si se aplica daño o curación repetida mientras `_current` es 0 (o se re-asigna 0), el setter vuelve a evaluar `<= 0` y puede emitir `died` múltiples veces. `damage()`/`heal()` no hacen early-return cuando ya murió.
  2. **La señal `died` no lleva contexto** (`died` sin argumentos), mientras `IDamageable.died` declara `killer: Node` (i_damageable.gd:49). Si un implementador usa `HealthComponent` internamente, hay **desalineación de contrato** (quién mató, tipo de muerte).
  3. **No hay desaparición (`queue_free`, deshabilitar colisiones/IA, drop/loot, animación de muerte)**: el componente solo emite la señal. Esto es aceptable para un componente genérico, pero hoy no se detectan consumidores en runtime que gestionen la desaparición de enemigos/NPCs/jugador.
  4. **Orden señal `health_changed` + `died`:** el setter emite `health_changed` (17) y luego `died` (19). Consumidores deben estar preparados para recibir ambos en el mismo cambio; si alguno libera el nodo en `died`, puede afectar conexiones pendientes (riesgo bajo pero a considerar).
- **`EventBus.PlayerEvents`** declara `player_died(spawn_point)` y `damage_taken` (152-158), pero la conexión real jugador↔salud↔muerte no está evidenciada en los scripts revisados.
- **`CombatIslandSystem.registrar_derrota`** (126-130) incrementa contadores sin verificar existencia del `enemy_id` ni coordinar con una instancia viva; es coherente con un modelo data-driven pendiente de IA runtime, pero **no implementa la desaparición de la entidad derrotada**.
- **Tests:** `test_i_damageable.gd` cubre el contrato/interfaz y una clase custom de prueba (clamp manual, `set_health(0)` => `is_alive()==false`), pero **no hay tests del `HealthComponent`** (ni de daño negativo/nulo, ni de doble emisión de `died`, ni de curación sobre máximo).

## 3) Sugerencias de mejora (2)

1. **Endurecer `HealthComponent` (validación + estado de muerte + contrato de señales):**
   - En `damage(amount)`: ignorar `amount <= 0` o `!is_finite(amount)` (o tratar como 0) y retornar/no-op según política; opcionalmente devolver el daño real aplicado para alinear con `IDamageable.take_damage`.
   - En `heal(amount)`: ignorar `amount <= 0` o no finito.
   - Agregar `var is_dead: bool` / `func is_alive() -> bool` y un early-return si ya está muerto (evitar re-emisión de `died`); decidir si la curación puede “revivir” (respawn) o solo aplica `set_health` controlado.
   - Alinear señal: `signal died(killer: Node = null)` o documentar explícitamente la diferencia con `IDamageable.died(killer)`. Considerar exponer `take_damage(amount, damage_type := &"", source: Node = null) -> float` en el componente para compatibilidad directa con la interfaz.
   - Añadir tests headless de `HealthComponent` (daño normal, daño negativo/nulo, clamp, muerte única, curación en máximo, revive/respawn si aplica).

2. **Cerrar la brecha runtime combate/salud/muerte (integración + desaparición segura):**
   - Implementar (o conectar) el flujo pendiente que el propio M164 declara fuera de alcance: una entidad runtime de enemigo/jugador que componga `HealthComponent` (o implemente `IDamageable`), reciba `take_damage`, emita/escuche `died`, y al morir ejecute una secuencia segura de desaparición: deshabilitar input/IA/colisiones/hurtbox, reproducir feedback (animación/VFX/SFX según módulos M45/M52/M42), otorgar gemas/botín vía `GemCurrency.add_gems` + `CombatIslandSystem.registrar_derrota`, y diferir `queue_free()` (o pooling) tras la animación.
   - Conectar `player_died`/`damage_taken` del `EventBus` con el estado real del jugador (respawn cozy, sin pérdida de gemas, coherente con `gem_currency.gd:11`). Sin consumidores/emisores reales, esos eventos son contratos huérfanos.

## 4) Conclusión final

El proyecto **tiene definida la base de daño/salud** (contrato `IDamageable` + componente `HealthComponent`) y una **capa de datos/progresión de combate** (`scripts/combat/*`) coherente con el diseño M164, pero **no existe aún una implementación runtime completa** que aplique daño a entidades, gestione HP en juego y materialice la muerte/desaparición (IA/combate real están explícitamente pendientes en M164). Los riesgos concretos en el código existente son: **falta de validación de daño/curación negativos/nulos/no finitos en `HealthComponent`**, **posible re-emisión de `died` sin estado terminal**, **desalineación entre la señal `died` del componente y la de `IDamageable`**, y **ausencia de tests del componente**. Las dos mejoras priorizadas son endurecer `HealthComponent` y cerrar el flujo runtime de daño→muerte→desaparición/recompensa con manejo seguro de señales y ciclo de vida del nodo.
