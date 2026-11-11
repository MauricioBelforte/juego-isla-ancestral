# Reporte de análisis: combate, daño, salud y muerte

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-10  
**Alcance:** `game/isla-ancestral/scripts/` (búsqueda de `.gd` relacionados con combate/daño/salud/vida/muerte) y tests unitarios asociados.

## 1) Archivos relevantes analizados

| Archivo | Rol | Líneas clave |
|---|---|---|
| `game/isla-ancestral/scripts/interfaces/i_damageable.gd` | Contrato/interfaz de entidades dañables | `6-49` (API: `take_damage`, `get_health`, `get_max_health`, `is_alive`, `heal`, `set_health`; señales `health_changed`, `died`) |
| `game/isla-ancestral/scripts/utils/components/health_component.gd` | Componente reutilizable de salud/daño (composición) | `25-157` (estado, validaciones, aplicación, muerte única, contrato IDamageable por duck-typing) |
| `game/isla-ancestral/scripts/combat/combat_island_system.gd` | Sistema central de Isla de Combate (zonas, derrotas, recompensas, persistencia) | `16-212` (catálogo, desbloqueos, `registrar_derrota`, `total_derrotas`, `jefe_derrotado`, recompensas/hitos) |
| `game/isla-ancestral/scripts/combat/combat_reward.gd` | Recurso de recompensas cosméticas de combate | `8-54` |
| `game/isla-ancestral/scripts/combat/combat_island_save_provider.gd` | Provider de guardado M59 para isla de combate | `8-29` |
| `game/isla-ancestral/scripts/combat/gem_currency.gd` | Moneda gemas (ganancia/gasto/persistencia) | `17-108` |
| `game/isla-ancestral/scripts/combat/enemy_data.gd` | Definición data-driven de enemigo (stats: `hp_max`, `attack`, `speed`, `gem_reward`, etc.) | `9-48` |
| `game/isla-ancestral/scripts/combat/boss_data.gd` | Definición de jefe (extiende `EnemyData`, fases/umbrales) | `9-37` |
| `game/isla-ancestral/tests/unit/interfaces/test_i_damageable.gd` | Tests unitarios del contrato IDamageable | `1-228` |
| `game/isla-ancestral/tests/unit/components/test_health_component.gd` | Tests unitarios de `HealthComponent` (validación, muerte única, contrato) | `1-206` |

**Observación de alcance:** no existen scripts runtime dedicados de combate activo con nombres tipo `combat_damage`, `health_system`, `death_handler`, `combat_island_enemy.gd` o `combat_hitbox.gd` en `game/isla-ancestral/scripts/combat/`; la carpeta contiene datos/sistema de progresión/persistencia y tests (`test_combat_m164_atria.gd`), pero no la ejecución de daño/vida por entidad en runtime.

## 2) ¿Cómo se gestiona el daño y la salud?

### Contrato (`IDamageable`)
- **Interfaz base:** `scripts/interfaces/i_damageable.gd:3-49` define el contrato para entidades dañables.
- **API declarada:** `take_damage(amount, damage_type, source) -> float` (`16-17`), `get_health()` (`21-22`), `get_max_health()` (`26-27`), `is_alive()` basado en `get_health() > 0` (`31-32`), `heal(amount)` (`37-38`), `set_health(value)` (`42-43`).
- **Señales:** `health_changed(new_health, max_health, damage_taken)` (`46`) y `died(killer)` (`48`).
- **Naturaleza:** implementaciones por defecto son neutras (`0.0`, `pass`), por lo que la lógica real depende de implementaciones concretas.

### Implementación reutilizable (`HealthComponent`)
- **Componente:** `scripts/utils/components/health_component.gd:25-157`, `extends Node`, pensado para composición (M111).
- **Estado:** `max_health` exportada (`41`), `_current` interno (`51`), bandera `is_dead` (`43`), inicialización en `_ready` saneando máximo y fijando vida completa (`54-58`, `150-153`).
- **Aplicar daño:** `damage(amount, killer = null) -> bool` (`62-71`) — rechaza si ya está muerto o si el valor no es utilizable, calcula `nuevo = clampf(_current - amount, 0.0, max_health)` y aplica vía `_aplicar`.
- **Curación:** `heal(amount) -> bool` (`75-87`) — solo si vivo, valor válido y no al máximo; clamp superior a `max_health`.
- **Revive:** `revive(fraccion = 1.0)` (`92-99`) — no revive a un vivo; restaura fracción de `max_health`.
- **Contrato por duck-typing:** `take_damage` (`105-108`), `get_health` (`111-112`), `get_max_health` (`115-116`), `is_alive` (`119-120`), `set_health` (`125-130`) para alinearse con `IDamageable`.
- **Núcleo común:** `_aplicar(nuevo, delta, killer)` (`135-147`) blinda finitud, clampea a `[0, max_health]`, actualiza `_current`, emite `health_changed(current, max_health, delta)` y emite `died(killer)` una sola vez al cruzar a `<= 0`.

### Integración con otros sistemas de "combate"
- **Progresión/estado de isla:** `combat_island_system.gd` gestiona desbloqueo de zonas por gemas, conteo de derrotas (`registrar_derrota`/`total_derrotas`, `126-139`), recompensas/hitos (`146-164`), porcentaje completado (`167-175`) y persistencia (`178-212`). No aplica daño ni administra HP de entidades en runtime.
- **Datos de enemigos/jefes:** `enemy_data.gd` (`20-35`) y `boss_data.gd` (`13-37`) definen stats/catálogos (`hp_max`, `attack`, fases, etc.), pero no contienen lógica de recepción de daño ni transición de muerte en ejecución.
- **Uso real en runtime:** el propio `HealthComponent` documenta que al momento de su endurecimiento "NINGÚN sistema del runtime instancia este componente" (`health_component.gd:20-23`). La búsqueda en `game/isla-ancestral/scripts/` confirma que sus símbolos principales (`take_damage`, `health_changed`, `died.emit`, etc.) no aparecen consumidos fuera de la interfaz/componente, salvo coincidencias no relacionadas (`data_store.gd` usa `is_alive()` de hilos, no de daño).

## 3) ¿Hay validación de valores de daño negativos o nulos?

**Sí, en `HealthComponent` (implementación concreta):**
- **Filtro de utilidad:** `_valor_util(amount)` exige `is_finite(amount) and amount > 0.0` (`156-157`), por lo que rechaza negativos, cero, `NaN` e infinito.
- **Daño:** `damage()` retorna `false` y emite `cambio_ignorado` si está muerto o el valor es inválido (`63-68`); no modifica la salud en esos casos.
- **Curación:** `heal()` aplica el mismo criterio de valor válido y además evita curar a muertos, valores inválidos o cuando ya está al máximo (`75-84`).
- **Setter directo:** `set_health()` rechaza valores no finitos (`125-128`), clampea valores finitos al rango `[0, max_health]` (`129`) y reutiliza `_aplicar`; `_aplicar` vuelve a blindar finitud/clamp (`138-141`).
- **Saneamiento de configuración:** `_sanear_maximo()` corrige `max_health` inválido/<=0/no finito a `100.0` (`150-153`).
- **Evidencia en tests:** `tests/unit/components/test_health_component.gd` cubre daño negativo/cero/NaN/INF (bloque B, `99-114`), curación inválida y sobre muerto (bloque D, `136-154`), `set_health` con NaN/clamp/muerte (bloque E, `157-175`) y `max_health` inválido (bloque F, `178-187`).

**Matiz importante:** la interfaz `IDamageable` por sí sola no impone validación (sus métodos devuelven valores por defecto), así que la protección efectiva depende de que las entidades usen `HealthComponent` u otra implementación con las mismas garantías.

## 4) ¿Hay problemas de muerte/desaparición de entidades?

### Lo que está bien resuelto (a nivel de componente)
- **Muerte única:** `_aplicar` marca `is_dead = true` y emite `died(killer)` solo cuando `current <= 0` y aún no estaba muerto (`145-147`).
- **No repetición tras morir:** `damage()` y `heal()` rechazan operaciones si `is_dead` (`63-65`, `76-78`); `take_damage` inválido devuelve `0.0` (`105-108`).
- **Cobertura de pruebas:** `test_health_component.gd` verifica muerte con killer, una sola emisión de `died`, rechazo de daño/curación sobre muerto y revive controlado (`118-133`, `149-153`).

### Riesgos / problemas observados
1. **Falta de integración runtime de la muerte/desaparición:** `HealthComponent` emite señales pero no elimina nodos (`queue_free`) ni desactiva entidades; además declara que no está instanciado por sistemas runtime actualmente (`health_component.gd:20-23`). No se hallaron consumidores en `scripts/` que conecten `died` a limpieza/desaparición de entidades. En consecuencia, hoy no hay una cadena comprobable "recibir daño letal → morir → desaparecer" en gameplay.
2. **Combate enemigo/jefe no implementado en ejecución:** `EnemyData`/`BossData` (`enemy_data.gd`, `boss_data.gd`) y `CombatIslandSystem` (`combat_island_system.gd:14-15,126-142`) modelan stats y derrotas agregadas, pero no existe en los scripts revisados una entidad runtime de enemigo que posea salud, reciba `take_damage` y se retire al morir. Las "derrotas" se registran como contadores/hitos, no como consecuencia observable de un componente de vida por instancia.
3. **Desalineación de contrato/señal entre interfaz y componente:** `IDamageable` declara `health_changed(new_health, max_health, damage_taken)` (`i_damageable.gd:46`), mientras `HealthComponent` emite `health_changed(current, max_value, delta)` donde `delta` representa variación (negativa en daño) y se calcula como cambio real (`health_component.gd:30,144`). Además `take_damage` en el componente devuelve el `amount` solicitado si se aplicó (`health_component.gd:105-108`), no el daño neto efectivamente descontado (`antes - después`) en casos de sobre-daño/clamp. Esto puede generar inconsistencias para futuros consumidores que dependan estrictamente del contrato de la interfaz.
4. **`set_health` puede provocar muerte "directa":** fijar salud a `0.0` dispara la lógica de muerte una vez (`set_health` → `_aplicar`, `125-130`, `145-147`, test E9 `173-174`). Es útil para saves/respawn/debug, pero si se usa sin una política clara de killer/flujo de muerte puede producir transiciones abruptas si más adelante se integra en runtime.

## 5) Sugerencias de mejora (2)

1. **Unificar semántica del contrato de daño/salud y exponer daño real aplicado.**  
   - **Qué hacer:** alinear `HealthComponent` con `IDamageable` en la señal `health_changed` (nombre/semántica de parámetros y documentación) y hacer que `take_damage` devuelva el daño neto realmente aplicado (`salud_antes - salud_después`) en lugar del `amount` bruto.  
   - **Dónde:** `game/isla-ancestral/scripts/utils/components/health_component.gd` (`30`, `105-108`, `135-144`) y, si corresponde, ajustar documentación/firma esperada en `game/isla-ancestral/scripts/interfaces/i_damageable.gd` (`15-16`, `46`) para evitar ambigüedad.  
   - **Impacto:** reduce errores de integración (UI, feedback de daño, estadísticas) y hace consistente el comportamiento ante sobre-daño, clamp y futuros modificadores (armadura/resistencias).

2. **Implementar e integrar el pipeline runtime de muerte/desaparición de entidades.**  
   - **Qué hacer:** conectar consumidores reales (jugador, NPCs/enemigos de combate cuando exista su runtime) a `HealthComponent`/`IDamageable`: al recibir `died(killer)` ejecutar una secuencia estándar y única (deshabilitar IA/input/colisiones/hitboxes, reproducir animación/VFX/loot según diseño, notificar sistemas como `CombatIslandSystem.registrar_derrota(...)` cuando aplique) y finalizar con retirada segura (`queue_free()` o retorno a pool) con protección ante doble ejecución.  
   - **Dónde:** nuevos scripts/escenas runtime de entidades de combate/jugador-NPC (actualmente ausentes en `scripts/combat/`) reutilizando `game/isla-ancestral/scripts/utils/components/health_component.gd`; puntos de integración de progresión en `game/isla-ancestral/scripts/combat/combat_island_system.gd:126-142`.  
   - **Impacto:** cierra la brecha entre "estado de vida/muerte calculado" y "entidad desaparece/termina correctamente", evitando entidades zombis, señales huérfanas o conteos de derrota desacoplados del combate real.

## 6) Conclusión final

La base de daño/salud está **bien diseñada a nivel de contrato y componente**: `IDamageable` define la API y `HealthComponent` implementa validaciones robustas (rechazo de daño negativo/nulo/NaN/INF, clamp, saneamiento de máximo, `set_health` seguro) y una lógica de **muerte única** con `is_dead` y emisión controlada de `died`, respaldada por tests unitarios específicos. Sin embargo, en el código revisado **no hay evidencia de integración runtime completa** (el componente no se instancia en sistemas actuales y faltan entidades de combate que reciban daño y se eliminen al morir), y persisten **pequeñas desalineaciones semánticas** entre la interfaz y el componente (`health_changed`/retorno de `take_damage`). La prioridad práctica es integrar el componente en entidades reales y estandarizar el flujo de muerte/desaparición, junto con alinear la semántica del contrato para evitar inconsistencias futuras.
