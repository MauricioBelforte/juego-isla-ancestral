# Reporte detallado: sistemas de partículas / VFX / efectos visuales

- **Modelo:** Glyph Cluster (stealth, early access)
- **Plataforma:** Kilo Code / VS Code
- **Fecha:** 2026-11-08
- **Alcance solicitado:** `game/isla-ancestral/scripts/` — búsqueda de `.gd` relacionados con partículas, VFX o efectos visuales (`scripts/particulas/`, `scripts/vfx/`, `scripts/efectos/` o similar).
- **Resultado de búsqueda:** no existe `scripts/particulas/`, `scripts/vfx/` ni `scripts/efectos/`. Los archivos relevantes encontrados son:
  - `game/isla-ancestral/scripts/particles/` (M52): `vfx_schema.gd`, `vfx_factory.gd`, `vfx_pool.gd`, `vfx_director.gd`, `vfx_trigger.gd`, `vfx_loops.gd`, `preview_particles.gd`, `preview_vfx_m52.gd`, y varios tests headless.
  - `game/isla-ancestral/scripts/terrenos/terrain_particles.gd` (M156): partículas por terreno del jugador.

## Archivos analizados

| Archivo | Rol |
|---|---|
| `game/isla-ancestral/scripts/particles/vfx_schema.gd` | Validación del catálogo VFX (campos, rangos, cobertura, reglas RF). Líneas clave: `63-83`, `86-151`. |
| `game/isla-ancestral/scripts/particles/vfx_factory.gd` | Creación/configuración de `GPUParticles3D` desde catálogo; `nuevo_emisor`, `redisparar`, `crear`. Líneas: `21-27`, `39-77`. |
| `game/isla-ancestral/scripts/particles/vfx_pool.gd` | Pool de emisores reutilizables, límites, reciclado, precalentamiento, semillas deterministas. Líneas: `45-61`, `91-112`, `118-171`, `215-278`. |
| `game/isla-ancestral/scripts/particles/vfx_director.gd` | Orquestador: carga catálogo, dispara por evento, avanza vida y libera emisores al pool. Líneas: `53-68`, `76-111`, `151-156`. |
| `game/isla-ancestral/scripts/particles/vfx_trigger.gd` | Traducción `bus -> VFX` desde catálogo; conexión a señales namespaced reales del `EventBus`. Líneas: `32-48`, `70-99`, `104-112`. |
| `game/isla-ancestral/scripts/particles/vfx_loops.gd` | Registro lógico de loops ambientales con culling por radio, LOD y fase fija determinista. Líneas: `36-50`, `73-81`, `93-102`, `108-111`. |
| `game/isla-ancestral/scripts/terrenos/terrain_particles.gd` | Partículas `CPUParticles3D` por terreno al moverse el jugador; precarga escenas, pooling simple, ráfagas temporizadas. Líneas: `53-94`, `102-153`, `173-185`. |
| `game/isla-ancestral/scripts/particles/test_vfx_m52_iter6.gd` | Suite headless que valida catálogo, schema, loops, trigger y existencia de señales reales en `event_bus.gd`. Líneas: `84-94`, `128-190`, `193-221`, `244-289`, `293-320`. |

> Nota: se leyeron también los tests/scripts de preview en el directorio, pero el análisis funcional se centra en los módulos de runtime anteriores.

## 1) ¿Cómo se gestionan los sistemas de partículas?

### M52 — VFX global (GPU particles, data-driven)

El sistema M52 separa responsabilidades:

- **Catálogo + validación:** `vfx_schema.gd` define la forma esperada del catálogo (`VERSION_ESPERADA = 2`, conjuntos cerrados, rangos de cantidad/emisión, reglas RF). `validar_catalogo` recorre entradas y acumula errores (`63-83`); `validar_entrada` exige `id` snake case `vfx_*`, evento, tipo/categoría/emisor/material válidos, color hex, presupuesto suficiente, `luz_por_particula=false`, límite de parpadeo, coherencia loop/radio/fase y bus o dueño (`86-151`).
- **Creación de emisores:** `vfx_factory.gd` carga `res://data/vfx/vfx_catalog.json` (`21-27`), normaliza parámetros (`30-37`), crea `GPUParticles3D` con `draw_pass_1` y `ParticleProcessMaterial` (`46-61`, `79-97`), y re-dispara emisores existentes fijando semilla **después** de `restart()` para determinismo (`69-77`).
- **Pooling:** `vfx_pool.gd` mantiene `_libres` por id, `_activos` con metadatos, contadores, límites `max_emisores/max_particulas` (`45-61`). `prestar()` busca libre del mismo id, crea si hay cupo, recicla el activo más antiguo si hace falta, reconfigura con `redisparar` y asigna semilla determinista `semilla_de(id, _emisiones)` (`118-152`). `liberar()` detiene emisión y devuelve al pool (`154-163`). `precalentar()` crea emisores sin emitir (`91-104`). `_hacer_hueco()` recicla para respetar presupuesto de partículas (`247-260`). Los descartes emiten señal `emision_descartada` (`31`, `235-240`).
- **Dirección/orquestación:** `vfx_director.gd` indexa el catálogo por `evento` (`60-63`), expone `disparar(evento_id, pos)` que pide al pool (`87-99`), registra vida restante `_vida` y, en `actualizar(delta)`, libera emisores agotados al pool (`103-111`). `finalizar()` limpia vida y hace `queue_free()` de todos los nodos del pool (`151-156`).
- **Conexión a eventos reales:** `vfx_trigger.gd` deriva un mapa `bus namespaced -> ids` desde el catálogo (`32-48`), conecta señales reales del `EventBus` (`70-99`) y filtra por condición (`104-122`). Esto fue introducido porque el director original intentaba usar `EventBus.evento_generico`, señal inexistente.
- **Loops ambientales:** `vfx_loops.gd` es lógica pura: registra loops por zona única, calcula activos por culling de radio, aplica LOD 25% lejos, limita cantidad mínima y calcula fase fija determinista (`36-135`). No instancia nodos; decide qué emitir.

### M156 — partículas de terreno

`terrain_particles.gd` usa `CPUParticles3D` procedural por terreno (`23`, `48`, `65-71`, `123-135`). Se conecta al `TerrainDetector` hermano y lee velocidad del `CharacterBody3D` padre (`54-59`). En `_physics_process` emite ráfagas cuando la velocidad horizontal supera el umbral y el temporizador alcanza la frecuencia configurada (`78-94`). Tiene un pool interno simple de nodos reutilizados y un límite `max_emisores` (`37`, `48-49`, `102-153`).

## 2) ¿Hay fugas de partículas no detenidas?

### Hallazgo A — Enganche roto en `VfxDirector` (efectos no disparados por eventos reales)

`vfx_director.gd:65-67` intenta conectar `EventBus.evento_generico`:
```gdscript
var event_bus := get_node_or_null("/root/EventBus")
if event_bus and event_bus.has_signal("evento_generico"):
    event_bus.evento_generico.connect(_on_evento)
```
El propio archivo documenta que esa señal **no existe** (`21-32`) y que la ruta correcta es `vfx_trigger.gd`. `test_vfx_m52_iter6.gd:318-319` verifica que `evento_generico` no existe en `event_bus.gd`. Consecuencia: el director como autoload/nodo conectado al bus real **queda mudo**; no se disparan VFX por eventos del juego. No es una fuga de emisión continua, pero sí un fallo grave de gestión: el sistema parece listo y no ejecuta su función principal.

### Hallazgo B — Ciclo de vida acoplado a `actualizar(delta)` en `VfxDirector`

`VfxDirector` no usa timers por emisor ni señales de fin; mantiene `_vida[nodo] = emision` (`98`) y libera cuando `actualizar(delta)` lo reduce a `<= 0` (`103-111`). Si nadie llama `actualizar()` en cada frame, los nodos prestados permanecen activos en `_activos` del pool y no vuelven a `_libres`. Esto puede agotar el pool (`max_emisores`) y producir descartes (`VFX-SKIP`), o dejar emisores vivos más tiempo del esperado. No se encontró en los archivos analizados una llamada obligatoria a `VfxDirector.actualizar()`; debe verificarse su integración en el loop del juego.

### Hallazgo C — `VfxPool` sin dueño fuerte de nodos en memoria

Los nodos se crean con `FACTORY.nuevo_emisor()` (`99`, `134`) y solo se añaden al árbol si se pasa `container` (`147-150`). Los emisores libres/activos viven en diccionarios del pool (`50-51`). `finalizar()` del director hace `queue_free()` de `pool.nodos()` (`151-156`), pero depende de que se invoque. Si el director/pool se reemplaza o se sale de escena sin `finalizar()`, nodos sin padre pueden quedar huérfanos hasta que el GC/árbol los gestione; en Godot, `Node` sin padre no se libera automáticamente por referencia GDScript. Riesgo medio, dependiente del ciclo de escena.

### Hallazgo D — M156: nodos de partículas nunca se liberan con `queue_free()`

`terrain_particles.gd` reutiliza nodos: al terminar ráfaga llama `_liberar()` (`139-144`, `147-152`), que hace `emitting=false`, `visible=false` y los guarda en `_pool`. Nunca se llama `queue_free()` ni hay limpieza en `_exit_tree`/`finalizar`. Los nodos quedan como hijos de este `Node3D` (`134`) mientras exista el componente. Dado `max_emisores = 6` por defecto (`37`), la fuga está acotada, pero no hay política de drenaje al desactivar/cambiar de contexto.

### Conclusión parcial sobre fugas

No se observan bucles obvios de `emitting=true` permanente en los módulos analizados. Los riesgos principales son: **desconexión funcional del director al bus real** (no fuga, sí efecto no gestionado), **dependencia de `actualizar()` para devolver emisores al pool**, y **retención acotada de nodos CPU en M156** sin liberación final explícita.

## 3) ¿Hay problemas de rendimiento con demasiadas partículas activas?

### Controles existentes

- **M52:** límites explícitos `MAX_EMISORES_DEF = 32`, `MAX_PARTICULAS_DEF = 1200` (`vfx_pool.gd:37-38`, `59-61`). `_hacer_hueco()` recicla el activo más antiguo y puede rechazar si una emisión sola supera el presupuesto (`249-260`). El schema limita cantidad por entrada (`CANTIDAD_MIN/MAX`, `109-111`) y exige `presupuesto >= cantidad` (`117-118`).
- **M52 loops:** lógica pura con culling por radio (`vfx_loops.gd:73-81`), LOD al 25% fuera del 50% del radio (`84-90`, `93-102`) y cantidad mínima para evitar emisiones irrelevantes (`26-27`, `102`). RF9 impone un emisor global por zona (`36-38`).
- **M156:** `max_emisores = 6` (`37`), al exceder recicla el más antiguo (`103-105`), intensidad clampeada (`109`), ráfagas temporizadas por frecuencia/velocidad (`78-94`).

### Riesgos de rendimiento

1. **`GPUParticles3D` por disparo reutilizado, pero con material nuevo frecuente.** `redisparar()` reasigna `process_material = _material(vfx)` (`vfx_factory.gd:73`), y `_material()` crea un `ParticleProcessMaterial` nuevo cada vez (`79-88`). Esto evita compartir estado inesperado, pero genera asignaciones/objetos en runtime bajo alta frecuencia de disparos.
2. **`nuevo_emisor()` crea `QuadMesh` y material nuevos** (`58-60`, `79-97`). El pool mitiga al reusar emisores por id, pero si hay muchos ids distintos o se vacía el pool, habrá churn de creación.
3. **`VfxDirector.actualizar()` itera sobre `keys()` de `_vida`** (`105-110`). Con pocos emisores es irrelevante; con picos cercanos a 32 emisores sigue bajo, pero la llamada debe ser barata porque corre cada frame si está integrada.
4. **M156 usa `CPUParticles3D`** — apropiado para headless/compatibilidad según su comentario (`13-14`), pero más costoso en CPU que GPU particles si se escala. El límite a 6 emisores lo contiene.
5. **Sin backpressure global entre M52 y M156.** Son sistemas independientes: uno usa `GPUParticles3D` pool global, otro `CPUParticles3D` por jugador/terreno. No comparten presupuesto total de partículas en pantalla.

## 4) ¿Hay partículas que no se limpian al salir del área?

### M52 loops

`vfx_loops.gd` calcula `activos(camara)` y `cantidad_efectiva()` por distancia al centro de zona (`73-102`). Es decisión lógica pura: si la cámara sale del radio, devuelve 0 / no incluye la zona. **Limpieza real de nodos emisores** no ocurre aquí; depende del consumidor que materialice el loop (pool/director u otro sistema). Si el consumidor solo consulta estado pero no detiene/libera el emisor al perder culling, el nodo podría seguir emitiendo fuera de área. El módulo `vfx_loops.gd` por sí solo no posee nodos.

### M52 one-shot / director

Los efectos one-shot se liberan por tiempo en `VfxDirector.actualizar()` (`103-111`). No dependen de área, sino de duración. Salir de un área no los cancela explícitamente salvo que el llamador lo haga. Esto es aceptable para impactos breves, pero puede ser indeseado para efectos ligados a zona.

### M156 terreno

Las partículas se emiten en pies del jugador (`110`, `117-120`) y se detienen por temporizador interno (`138-144`). No hay condición “salir del área”: el efecto es local al movimiento. Al detenerse el jugador, `_timer_rafaga` se reinicia y no se emiten nuevas ráfagas (`82-85`), lo cual es correcto.

### M52 trigger/director sin cambio de escena explícito

`VfxDirector.finalizar()` libera nodos (`151-156`), pero no se observó un hook automático como `_exit_tree()` o conexión a cambio de escena. La limpieza al salir de área/escena depende de integración externa.

## 5) Sugerencias de mejora (2)

### Mejora 1 — Unificar el disparo real por `VfxTrigger` y darle ciclo de vida explícito al director

- **Problema:** `vfx_director.gd:65-67` se conecta a una señal inexistente (`evento_generico`), por lo que el director no recibe eventos reales; el test iter. 6 ya demuestra el contrato correcto vía `vfx_trigger.gd` (`244-289`, `293-320`).
- **Acción concreta:**
  1. Hacer que `VfxDirector` use `VfxTrigger` (o delegar completamente en él) para construir el mapa desde catálogo y conectar señales namespaced reales.
  2. Añadir `_exit_tree()` o `_notification(NOTIFICATION_EXIT_TREE/PREDELETE)` que llame `finalizar()` para garantizar `queue_free()` de emisores.
  3. Documentar/asegurar quién llama `actualizar(delta)` cada frame (autoload con `_process`/`_physics_process`, o integración en un manager de juego). Alternativamente, usar un `SceneTreeTimer` o señal de fin por emisor para no depender del tick externo.
- **Beneficio:** restaura el flujo evento -> VFX, evita acumulación por falta de tick y hace explícita la limpieza al salir de escena.

### Mejora 2 — Reducir churn de recursos y hacer limpieza determinista de loops/CPU particles

- **Problema:** `vfx_factory.gd` crea `ParticleProcessMaterial` y geometría en rutas calientes (`58-60`, `73`, `79-97`); `terrain_particles.gd` retiene nodos en pool sin liberación final (`123-135`, `147-152`); `vfx_loops.gd` decide culling pero no gestiona la detención del emisor real.
- **Acción concreta:**
  1. Cachear `QuadMesh` y, cuando sea seguro, plantillas de `ParticleProcessMaterial` por `id`/tipo o clonar desde caché, reasignando solo propiedades variables (posición/semilla ya se controlan).
  2. En `terrain_particles.gd`, agregar `_exit_tree()`/`limpiar()` que haga `queue_free()` de `_pool` y nodos activos, y vacíe arrays.
  3. Definir un contrato para loops: cuando `cantidad_efectiva(zona, camara) == 0` o la zona se desregistra, el consumidor debe `stop`/`liberar` el emisor asignado. Añadir un método de reconciliación tipo `aplicar_estado(camara, pool/director)` o documentar el hook requerido.
- **Beneficio:** menor presión de asignaciones en runtime, limpieza clara al cambiar de escena/área y menor riesgo de emisores de loop activos fuera de culling.

## Conclusión final

El subsistema M52 en `scripts/particles/` tiene una base técnica sólida: catálogo data-driven validado por `VfxSchema`, factory compatible con Godot 4.3 (`draw_pass_1`), pool con límites/presupuesto/reciclado/precalentamiento, semillas deterministas y lógica pura para loops/culling. También existe evidencia de madurez en pruebas (`test_vfx_m52_iter6.gd`) y de correcciones históricas documentadas.

Sin embargo, la **gestión de disparo real está partida**: `VfxDirector` sigue intentando conectarse a `EventBus.evento_generico`, señal inexistente (`vfx_director.gd:65-67`, `21-32`), mientras que `VfxTrigger` ya implementa el mapeo correcto a señales namespaced. Además, la vida útil de emisores depende de que un integrador llame `actualizar(delta)` y de `finalizar()` al salir; sin esos hooks, hay riesgo de acumulación/retención. En M156 (`terrain_particles.gd`), el pooling local está acotado a 6 emisores por defecto, pero no hay liberación final explícita al salir del árbol.

**Estado general:** diseño y piezas principales presentes, con riesgo operativo alto en el enganche a eventos reales y riesgos medios de limpieza/ciclo de vida. Prioridad recomendada: corregir la ruta `Director/Trigger/EventBus` y formalizar los hooks de actualización/liberación antes de ampliar el catálogo o el uso en gameplay.
