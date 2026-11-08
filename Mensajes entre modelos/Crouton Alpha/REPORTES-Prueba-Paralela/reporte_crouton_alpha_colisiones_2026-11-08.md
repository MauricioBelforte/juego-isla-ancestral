**Modelo:** Crouton Alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-11-08

# Reporte de Colisiones, Triggers y Áreas de Detección — game/isla-ancestral/scripts/

## Alcance y metodología

- Raíz analizada: `game/isla-ancestral/scripts/` (árbol completo).
- Carpetas pedidas `scripts/fisica/`, `scripts/colisiones/`, `scripts/areas/` **no existen** en el proyecto (`glob` vacío para las tres). La lógica de colisiones está dispersa en módulos temáticos (`player/`, `viajes/`, `crafting/`, `resources/`, `ruinas/`, `terrenos/`, `terrain/`, `camera/`, `ia_npc/`, `fauna/`, `foto/`).
- Grep de términos: `Area2D|Area3D|body_entered|body_exited|collision_layer|collision_mask|monitorable|monitoring|trigger|PhysicsBody|CharacterBody|RigidBody|StaticBody` → ~100 hits (límite). Segundo grep de precisión `Area3D.new()|extends Area3D|body_entered|get_overlapping_bodies|collision_layer\s*=|collision_mask\s*=` → 28 hits.
- Exploitación incompleta: `glob` con `**/*trigger*.gd` halló 3 archivos; `**/*area*.gd` → 0. En total se leyeron completos: `player/player.gd` (1215 líneas), `viajes/embark_trigger.gd` (65), `crafting/crafting_station.gd` (133), `resources/resource_node.gd` (181), `ruinas/generador_ruina.gd` (122), `particles/vfx_trigger.gd` (144), `terrenos/terrain_block.gd` (43), `terrenos/terrain_detector.gd` (239), `terrain/terrain_detector.gd` (56), `camera/camera_spring.gd` (147), `scenes/player/Player.tscn`, `scenes/main.tscn`. Además se revisaron `npc_agent.gd` (inicio), `npc/villager.gd`, fauna (cangrejo, tortuga, gaviota, jabalí — todos `extends CharacterBody3D`), `foto/navigator.gd` (línea 83), `debug/debug_visualizer.gd` (hitboxes Area3D).

---

## (1) ¿Cómo se gestionan las colisiones entre entidades?

### 1.1 Dos sistemas de movimiento NO unificados

1. **Jugador: física voxel propia, sin física de Godot.** `player/player.gd` extiende `CharacterBody3D` pero **no usa `move_and_slide()`** en el camino principal. `_physics_process` (líneas 301-407) integra manualmente velocidad + gravedad y resuelve colisión con `VoxelBoxMover` (clase nativa de Voxel Tools, estilo Minecraft):
   - Instancia en `_ready` (líneas 89-97): `_box_mover = VoxelBoxMover.new()`, `get_voxel_tool()` sobre `VoxelTerrain`, canal `VoxelBuffer.CHANNEL_TYPE`.
   - AABB del jugador (líneas 19 y 370-377): `AABB(Vector3(-0.4,0,-0.4), Vector3(0.8,1.8,0.8))`, origen en los pies; `motion = velocity * delta`; `motion = _box_mover.get_motion(global_position, motion, _character_box, _terrain)`; luego `global_translate(motion)`. Suelo = `abs(motion.y) < 0.001 and velocity.y <= 0`.
   - Solo hay fallback `move_and_slide()` en el `else` de la línea 402-405 (cuando no hay `_box_mover` o no hay `_terrain`).
   - **Su único `CollisionShape3D`** (`Player.tscn` líneas 25-27, cápsula r=0.4, h=1.5, offset y=0.75) es **decorativo**: no tiene `collision_layer/mask` propios en la escena (capa 1 = "mundo" por defecto) y nada en `player.gd` consulta el resultado de la física de esa cápsula. La escena (`Player.tscn`) tampoco define `collision_layer` ni `collision_mask` para el `CharacterBody3D` raíz — quedan en el default 1.

2. **NPCs y fauna: `move_and_slide()` estándar.** `ia_npc/npc_agent.gd` (línea 9 `extends CharacterBody3D`, línea 317 `move_and_slide()`), `npc/villager.gd`, fauna completa (`cangrejo_npc.gd`, `tortuga_npc.gd`, `gaviota_npc.gd` ×7 llamadas, `jabali_npc.gd`, `simple_walk.gd`, `prototipo/player_proto.gd`) usan `move_and_slide()` contra la física de Godot. Ninguno de estos scripts define `collision_layer/mask` en código (quedan en 1 = mundo). El test `terrenos/test_terrenos_b3.gd` (líneas 200-205, 255-278) lo confirma midiendo: los NPC creados en escena **no fijan `collision_layer`** y comparten capa 1 con el terreno.

**Consecuencia de arquitectónica:** hay **dos capas de colisión paralelas e incompatibles**:
- El voxel (terreno) lo lee el jugador vía `VoxelBoxMover` (sin capas de Godot).
- El voxel lo leen NPC/fauna vía `move_and_slide()` contra el `VoxelTerrain` (que en Godot es un `StaticBody3D`-like con `collision_layer = 1 | 32`). Solo funciona si la capa 1 del NPC entra en la máscara del terreno (viene por defecto), pero el NPC se desalinea del sistema de movimiento del jugador.
- **Jugador vs NPC / NPC vs jugador: no hay colisión física real entre ellos** — el jugador ignora la física de Godot (usa voxel puro) y los NPC usan Godot puro sin que el voxel los empuje: pueden solaparse visualmente o atravessarse sin reacción, salvo las separaciones blandas de `npc_agent.gd` (líneas 42-45: `MAX_SIMULTANEOUS_SOCIALS=3`, `SEPARATION_RADIUS=1.5`, fuerza de separación social, no física dura).

### 1.2 Capas de colisión utilizadas (mezcla de convenciones)

| Capa (bit) | Valor | Uso real en disco |
|---|---|---|
| 1 = mundo | `1` | Default Godot. Jugador/NPC/fauna/VoxelTerrain (y `terrain_block.gd` para "césped", `camera_spring.gd`, `foto/navigator.gd:83`). Es la capa "todo lo físico". |
| 6 = bit dedicado de terreno | `32` | `terrenos/terrain_detector.gd` línea 34 (`LAYER_TERRENO_MASK = 1 << 5`) y `Player.tscn` línea 31 (`TerrainDetector.collision_mask = 32`). |
| 5 = agua (declarado en comentarios) | `16` | Solo en comentarios/lógica de voxel (no en máscaras de escena). |
| Bit 20 = vetas de recursos | `1 << 20` | `resources/resource_node.gd` línea 171 (`_area.collision_layer = 1 << 20`, `mask = 0`). |
| Capa 0 = excluido | `0` | `crafting/crafting_station.gd` líneas 119-120 (área inerte, ver §2). |
| Por tipo de terreno (legacy) | `1..64` | `terrenos/terrain_block.gd` líneas 17-26: césped=1, barro=2, pavimento=4, arena=8, agua=16, nieve=32, rocas=64. **Convivencia conflictiva**: "capa 6 = bit dedicado" (32) de `terrain_detector.gd` **colisiona numéricamente con "nieve = 32"** de `terrain_block.gd`, aunque `terrain_block.gd` parece legacy (nada en el terreno voxel lo instancia como `StaticBody3D` por bloque hoy). |

- **VoxelTerrain**: `main.tscn` línea 31 lo instancia sin overrides; el bit 32 se agrega en runtime desde `terrain_detector.gd` línea 161-168 (`_asegurar_capa_dedicada()` hace OR del bit sin quitar el 1). El rayo del detector (`Player.tscn` 29-34: `collision_mask = 32`, `collide_with_areas=false`, `collide_with_bodies=true`) ve **solo** el bit 32 — esa es la razón documentada del fix G4 (líneas 13-16 del detector): antes el rayo (mask 1) se frenaba en NPC que comparten capa 1.
- `foto/navigator.gd` línea 83 (`query.collision_mask = 1  # terreno`): consulta el terreno por capa 1, no por el bit 32.
- Cámara: `camera_spring.gd` está **marcada deprecated** (líneas 1-3) — código muerto que sigue referenciado desde `main.tscn` (CameraSpring, `collision_layer = 1`, RayCast `collision_mask = 1`, líneas 44-50). La colisión de cámara viva está en `follow_camera.gd` vía raycast voxel.
- Sin `PhysicsBody3D`/`RigidBody3D` en `scripts/` — no hay objetos dinámicos; los cuerpos dinámicos son solo `CharacterBody3D` (jugador, 1 villager, 4 fauna, `npc_agent`, `simple_walk`, `player_proto`). No hay `RigidBody` (objetos empujables/caída) ni `StaticBody3D` salvo `terrain_block.gd` (legacy).

### 1.3 Raycasts como "colisión lógica" (patrón dominante)

En vez de áreas físicas, el proyecto consulta el mundo con raycasts:
- **Movimiento/ocupación**: `VoxelBoxMover.get_motion` (jugador), `move_and_slide()` (NPC).
- **Terreno bajo los pies**: `terrenos/terrain_detector.gd` (`extends RayCast3D`, líneas 52-91) + copia legacy `terrain/terrain_detector.gd` huérfana (56 líneas, sin consumidor — ver §2).
- **Edición de bloques**: `player.gd` `_do_raycast()` (líneas 260-267) vía `_voxel_tool.raycast(origin, direction, edit_distance=8.0)`.
- **Terreno** (foto): `foto/navigator.gd:83` con `query.collision_mask = 1`.
- **Cámara**: voxel raycast (actual) / `camera_spring.gd` (deprecated).

Grep de `body_entered|body_exited` y `get_overlapping_bodies` en `scripts/`: **2 únicos `body_entered`** (`viajes/embark_trigger.gd`, `ruinas/generador_ruina.gd`), **0 `get_overlapping_bodies`**.

---

## (2) ¿Hay áreas de detección sin señales conectadas?

### Resumen: 4 `Area3D` en producción; 2 son "fantasmas" (cero señales) y 2 tienen señales conectadas

| # | Archivo:líneas | Tipo | Señales | Veredicto |
|---|---|---|---|---|
| A1 | `viajes/embark_trigger.gd` líneas 11, 23-27, 41-52 | `extends Area3D` (zona de embarque en el muelle) | `body_entered` + `body_exited` conectadas en `_ready` → `_on_body_entered/_on_body_exited` → grupo `"player"` (línea 42, 49) → `EventBus.interaction.prompt_visible/prompt_hidden` (líneas 54-60) | **Conectada, pero frágil** (ver §3.1). |
| A2 | `ruinas/generador_ruina.gd` líneas 82, 91, 99-105 | `_placa = Area3D.new()`, caja 2×2×2 (líneas 84-88), posición base+0.5y (línea 90) | `body_entered` conectado (línea 91) → `if body is CharacterBody3D` (línea 100) → acomoda emisor de puzzle (líneas 101-105) | **Conectada, pero asimétrica** (ver §3.2). |
| A3 | `crafting/crafting_station.gd` líneas 109-120 | `_area = Area3D.new()` + `CollisionShape3D` caja (2.0, 1.8, 1.6) | NINGUNA. `monitoring=false`, `monitorable=false`, `collision_layer=0`, `collision_mask=0` (líneas 117-120). El comentario (líneas 112-116) lo declara: *"El Area es declarativo — M11 no lo consulta ... la interacción es por distancia en `_unhandled_input`"*. Interacción real: distancia 2.5 m (línea 15, línea 56) | **Fantasma deliberado** (optimización), ANTES fué trigger válido — hoy Area3D sin señales. La clase es funcional, el área no. |
| A4 | `resources/resource_node.gd` líneas 162-173 | `_area = Area3D.new()` + esfera r=1.4 (líneas 164-167), `collision_layer = 1 << 20`, `mask = 0` (líneas 171-172) | NINGUNA en este archivo. Comentario (líneas 168-170): *"mask=0: el area es pasiva (no escanea cuerpos por si sola)"*. Es el "hub de consulta" pasivo para raycasts/overlaps con máscara `1<<20` (enunciado del comentario M35). Ningún consumidor de ese bit apareció en el grep (ningún raycast con máscara 1<<20 lo consulta) | **Fantasma pasiva**: `monitorable=true` por defecto, `monitoring` default true, pero `mask=0` ⇒ no detecta. Para que funcione, alguien debe hacer un overlap/raycast con `mask = 1<<20` — no hay ningún consumidor en `scripts/`. |

**Áreas NO físicas** (→ no son Area3D, pero usan "trigger" en el nombre):
- `particles/vfx_trigger.gd` (144 líneas): NO es `Area3D` — es `extends RefCounted` (línea 22) que traduce eventos de `EventBus` (namespaced, ej. `world.block_placed`) a VFX. Ninguna señal Godot de física; 0 `body_entered`. El proyecto no usa Area3D para VFX.
- `tutorial/test_tutorial_triggers.gd`: solo test.
- `editor/_colector_sintaxis.gd`: lista `preload` de scripts (líneas 655, 934, 1037).

**Áreas EXTRA-PROYECTO (ver §2, ítems fantasma)**: `debug/debug_visualizer.gd` línea 383 (`_nodos_de_clase("Area3D")`) y su test `debug/test_debug_visualizer_real_m110.gd` línea 346-368 (`Area3D.new()` con hitboxes de debug) — esas **sí** existen en escena y definen su propio dibujado.

### Conclusión parcial sobre (2)

- **Áreas sin señales: A3 y A4** — ambas **intencionales** y documentadas en código (comentarios de la M16 y M35), no olvidos.
- **Áreas con señales: A1 y A2** — ambas susceptibles de fallos derivados de §3 (A1 con riesgo de quedarse "en falso positivo " dentro del área al morir/respawn; A2 con one-shot sin `body_exited`).

---

## (3) ¿Hay problemas de cuerpos que atraviesan triggers?

### 3.1 `viajes/embark_trigger.gd` — sí, riesgo alto

- **No hay `collision_layer` ni `collision_mask` fijados en código ni en escena.** La escena que lo instancia (muelle, harbor de M27) debe traer el collider *configurado desde el editor* (comentario línea 19: *"zona de activación (collider configurado desde el editor)"*), pero en `scripts/` no hay ningún override que lo fuerce. Si el editor deja los defaults, `collision_layer=1`, `collision_mask=1` ⇒ el área detecta **cualquier cuerpo físico** (NPC incluidos) — no solo al jugador. El filtro, si intenta, es el grupo `"player"` en `_on_body_entered/_on_body_exited` (líneas 42 y 49) pero **no filtra `collision_mask`**: `body_exited` de un NPC también dispara, y el handler lo ignora (queda `_jugador_dentro=false` incorrecto si el jugador estaba dentro y el NPC sale).
- **Tunneling (cuerpos que atraviesan la trigger)**: el jugador **no usa la física de Godot** (§1.1) — se teletransporta/mueve con `global_translate(motion)` desde `VoxelBoxMover`. El detector de áreas de Godot, en cambio, **solo dispara a cuerpos con la física de Godot** (el `CharacterBody3D` a 60 Hz). Por tanto el evento `body_entered` puede **no disparar** si:
  1. El jugador se mueve por `global_translate` más rápido que el step de física del área (edge: `move_speed=25` en dev, `player.gd` línea 60, y teletransporte T línea 352 `global_position = ... + Vector3(2,2,0)`, salto/tramos largos).
  2. Sin garantía de que el area `collision_mask` incluya la capa del jugador: el jugador hereda la capa 1 (default) — hoy coincide, pero si alguien cambia la capa del jugador (ej. capa 2 "jugador" según tabla de capas de la §4.1 de 04-Codigo — la convención del proyecto dice capa 2 = jugador, que el jugador NO usa en Player.tscn), `embark_trigger` dejará de detectar.
- **Falso "dentro" persistente**: `_jugador_dentro` (línea 20) solo se pone en false en `body_exited`. Si el jugador muere/respawnea, se teletransporta (clave T línea 352) o cambia de escena sin pasar por `body_exited`, el flag queda en true para siempre y el prompt `prompt_hidden` nunca se emite. No hay `get_overlapping_bodies()` de confirmación ni reset en `_ready`.
- **Emitter en `/root/EventBus`**: el autoload existe (así que el bus no es el problema), pero no se valida `bus.interaction != null` en la salida (línea 56) robustamente — solo envía si existe.

### 3.2 `ruinas/generador_ruina.gd` (`_placa`, líneas 82-105) — one-shot sin salida

- Solo conecta `body_entered`, **sin `body_exited`** (línea 91). El puzzle disparado (`PuzzleRoom.set_emisor(0, true)`, líneas 101-102) queda activo para siempre aunque el cuerpo salga. Es intencional (placa de presión latching), pero el problema de tunneling es estructural: el handler acepta cualquier `CharacterBody3D` (línea 100: `if body is CharacterBody3D`), sin discriminar jugador vs NPC vs animal. Si un NPC pasa pisando la placa, abre la puerta sin que el jugador intervenga. Además, el jugador que no sea `CharacterBody3D` de Godot-en-movimiento (usa `global_translate`) puede cruzar la caja 2×2×2 (línea 86) en un solo physics step a alta velocidad y no disparar nunca.
- La placa se posiciona a `base + Vector3(0, 0.5, 0)` (línea 90) sin confirmar la altura real del terreno voxel (el `base.y` se resolvió con `TerrainLocator` línea 40, pero la placa agrega 0.5 m sobre ello — puede quedar flotante o enterrada si el `base.y` no coincide con la altitud renderizada).

### 3.3 `crafting/crafting_station.gd` y `resources/resource_node.gd` — atraviesan pero no importa (por diseño)

- A3: `monitoring=false` + `mask=0` ⇒ ningún cuerpo puede "disparar" la estación. El jugador la atraviesa sin que pasa nada porque el área **no existe para la física**. La interacción es por distancia 2.5 m (línea 15): no hay trigger, no hay riesgo.
- A4: `mask=0` ⇒ la esfera de 1.4 m (línea 165) es invisible para cuerpos propios. El diseño supone que "alguien" la consultará con un overlap con `mask = 1<<20`. Sin consumidor, el área es **completamente pasiva**: el jugador y los NPC la atraviesan sin interacción. No es un bug de "atraviesa triggers", es un trigger muerto.

### 3.4 Triggers lógicos (no Area3D) — mismo patrón de riesgo

- `particles/vfx_trigger.gd`: 0 áreas físicas; traslada eventos lógicos del `EventBus`. Si un evento de gameplay se pierde (bus inexistente), no hay VFX. El archivo lo documenta (líneas 8-16: `evento_generico` inexistente en iter.5). No hay riesgo de tunneling físico, pero sí de "evento fantasma" (señal que nadie emite).

### 3.5 Colisión vóxel-vs-física (nivel terreno-mundo)

- **El terreno voxel NO colisiona con los NPC como voxels**. Los NPC usan `move_and_slide()` contra el `VoxelTerrain` en capa 1. Si el chunk voxel no ha materializado aún (streaming lento — caso M09 documentado en `player.gd` líneas 378-401), los NPC caen al vacío mientras el jugador se sostiene con el suelo fantasma (`get_height`). Es el mismo bug que el jugador ya tenía y mantiene un "colchón fantasma" solo para él (`player.gd` línea 387-401) — los NPC no tienen ese parche.
- **Tunneling de alta velocidad**: `move_speed=25` (dev) con `VoxelBoxMover.get_motion` (tipo Minecraft) resuelve colisión voxel en un solo paso; si un frame hace `motion` mayor que un voxel entero, el AABB atraviesa la pared sin parar (el `VoxelBoxMover.get_motion` no itera substeps como el `move_and_slide` de Godot sí hace por defecto). No hay `delta` clamp en `velocity * delta` (player.gd línea 371). Con FPS bajos (<20) el jugador puede atravesar pared de 1 bloque.

---

## 4 pistas menores y deuda técnica (extra)

- **Doble `terrain_detector.gd`**: `scripts/terrenos/terrain_detector.gd` (239 líneas, vigente desde M156) y `scripts/terrain/terrain_detector.gd` (56 líneas, `class_name TerrainDetectorLegacy` línea 5, comentado como renombrada el 2026-09-02). El legacy está huérfano — nadie lo consume. Riesgo: alguien importa `terrain/terrain_detector.gd` y usa su API vieja.
- **`camera_spring.gd` deprecated** (147 líneas) pero instanciado en `main.tscn` (líneas 38-50) con raycast capa 1. Si la escena actual es `main.tscn`, la cámara sigue usando el spring-arm muerto en vez del voxel raycast de `follow_camera.gd`.
- **`TerrainDetector` collide_with_areas=false** (líneas 57-58 del vigente, `Player.tscn` línea 32-33): el agua decorativa (Area3D capa 5) no frena el rayo — correcto — pero cualquier otro Area3D (A1, A2) tampoco frena el rayo. No es bug, sí decisión documentada.
- **Sin `RigidBody3D` ni `StaticBody3D` dinámicos**: no hay física de propósitos; no hay riesgo de "cuerpos rígidos atascados".

---

## (4) 2 mejoras sugeridas (concretas y priorizadas)

### Mejora 1 — [ALTA] Unificar `collision_layer/mask` del jugador y aplicar `monitorable` patrón en `embark_trigger` y `generador_ruina` + anti-tunneling por `get_overlapping_bodies` (barrato por física step)

**Por qué**: hoy hay 3 sistemas de capas descoordinados (capa 1 por defecto, bit 32 del detector, bit 20 de vetas) + 2 triggers que no fijan capas y dependen de que el editor recuerde el layer correcto + jugador que no usa la física de Godot para su propio movimiento (§1.1, §3.1-3.2). Es la fuente de "atravieso la trigger" que pide la tarea.

**Qué cambiar (5 pasos, sin quebrar M08 ni M156)**:
1. Fijar explícitamente en `Player.tscn`: `collision_layer = 2` (capa "jugador" de la convención §4.1), `collision_mask = 1 | 32` (mundo + terreno dedicado). Hoy hereda 1/1, que coincide *de casualidad*, no por *diseño*.
2. En `viajes/embark_trigger.gd` `_ready` (línea 23): `collision_layer = 0`, `collision_mask = 2`, `monitoring = true`, `monitorable = false`. El área deja de "escuchar" al mundo y solo escucha al jugador. En `ruinas/generador_ruina.gd` líneas 82-91: lo mismo (layer 0, mask 2 = solo jugador/NPC según se prefiera; si debe ser solo jugador, mask 2).
3. En `embark_trigger.gd`, agregar en `_physics_process` (nuevo) un barrido `get_overlapping_bodies()` cada ~0.1 s que sincronice `_jugador_dentro` con la realidad — resuelve tunneling por `global_translate` y falsos positivos de muerte/teleporte sin `body_exited` (§3.1, §3.2).
4. En `generador_ruina.gd`, en vez de `if body is CharacterBody3D` (línea 100) filtrar `if body.is_in_group("player")` (mismo grupo que A1, línea 42) para que NPC/fauna no resuelvan el puzzle.
5. Si el movimiento del jugador pasa a ≥10 m/s (hoy 25 dev), subdividir `motion = velocity * delta` en substeps de ≤0.25 m antes de `get_motion` (`player.gd:371`): evita tunneling voxel en paredes de 1 bloque con FPS bajo (§3.5).

**Verificación sugerida**: test headless como `test_terrenos_b3.gd` (ya existe) que cree un `CharacterBody3D` con capa 2, otro con capa 1, otros con capa 0 y compruebe que solo el de capa 2 dispara `body_entered` en cada trigger; más un test de `get_overlapping_bodies()` tras `global_translate` simulado.

### Mejora 2 — [MEDIA] Matar los 2 Area3D fantasma (A3 y A4) o conectarlos: hoy son muertos/erectos pero propagan deuda

**Por qué**: A3 (`crafting_station.gd` líneas 109-120) y A4 (`resource_node.gd` líneas 161-173) son `Area3D` con `monitoring=false/mask=0`, sin ningún consumidor (ver §2, líneas 112-116 y 168-172). Mantienen shapes de colisión huérfanos que confunden a quien audita ("¿dónde está la interacción?") y, en el caso de `debug_visualizer.gd` línea 383, inflan el conteo de hitboxes. El patrón actual — "área declarativa + interacción por distancia" (A3) y "área pasiva + consultas con máscara bit 20" (A4) — no se ha consumado nunca.

**Qué cambiar (elegir UNA de las dos opciones por área, no las dos)**:
1. **A3 (crafting)**: ELIMINAR el `Area3D` + `CollisionShape3D` (líneas 105-111 y 109-111) y dejar solo la interacción por distancia (`_unhandled_input`, líneas 51-65). Ahorra 1 área × estaciones y elimina la deuda. El test `qa_m16_station_fisica.gd` líneas 29-32 se cambia a assert de *ausencia* del área. Pérdida: no hay (el área ya es 0 por física).
2. **A4 (resource)**: DECIDIR si el sistema de vetas M35 realmente va a usar overlaps con `mask = 1<<20`. Si SÍ: agregar un consumer (p. ej. `ToolController` → antes de golpear, `intersect_shape` con `mask = 1<<20` sobre la estación buscada) y conectar la señal que falte (hoy ninguna). Si NO: eliminar el `Area3D` y la esfera r=1.4 — hoy todas las vetas son invisibles para la física. Alternativa de compromiso: A4 queda como `CollisionObject3D.monitoring = true` + `monitorable = true` + `mask = 2` (solo jugador) con `body_entered` que emita `recurso_agotado` al toque inicial — lo que hoy no hace nadie.

**Bonificación (mismo sprint)**:
- Borrar `scripts/terrain/terrain_detector.gd` (legacy, 56 líneas, `class_name TerrainDetectorLegacy`) — la convención del proyecto dice "colisión de clases → renombrar"; ya existe la renombrada hecha pero no el borrado. Y marcar `camera_spring.gd` con `queue_free` desde `camera_rig.gd` o eliminar las referencias de `main.tscn` si la cámara viva es `follow_camera.gd`.

---

## Conclusión final

El proyecto Isla Ancestral NO tiene un sistema único de colisiones: tiene **dos motores paralelos** (voxel para el jugador vía `VoxelBoxMover`, Godot `move_and_slide()` para NPC/fauna) + raycasts lógicos en vez de áreas + 4 `Area3D` de los cuales **2 son fantasmas deliberados** (crafting A3, recurso A4 — ambos `monitorable=false/mask=0` y sin consumidores) y **2 son triggers reales** (embarque A1 y placa A2) que concentran los problemas hallados:

1. **Atraviesan triggers**: `embark_trigger.gd` (A1) y `generador_ruina.gd` (A2) no fijan `collision_layer/mask`, dependen de que el editor lo haga y del que el jugador (que NO usa física de Godot) siga en capa 1 — sujeto a tunneling por `global_translate`/teleporte sin `body_exited` que lo rescate. La placa de A2 además acepta cualquier `CharacterBody3D` (NPC incluidos) y es latching (no se deshace).
2. **Capas sobrecargadas**: bit 32 (terreno dedicado) vive junto a "nieve=32" legacy de `terrain_block.gd`; capa 1 = "mundo" alberga a la vez terreno+j ugador+NPC+fauna. El detector ya parcheó el síntoma (G4), pero la arquitectura sigue con dos fuentes de verdad de capa.

La mejora 1 unifica capas y añade `get_overlapping_bodies` como red de seguridad (resuelve §3 sin reescribir M08). La mejora 2 cierra la deuda de áreas fantasmas A3/A4 elegiendo entre borrar o consumar. Sin ellas, cualquier nuevo `Area3D` que se agregue hereda el mismo riesgo: señales conectadas pero nunca disparadas, o disparadas por quien no debía.

**Archivo de diagnóstico**: `game/isla-ancestral/scripts/player/player.gd:301-407` (movimiento voxel), `viajes/embark_trigger.gd:23-52`, `ruinas/generador_ruina.gd:81-105`, `crafting/crafting_station.gd:105-120`, `resources/resource_node.gd:161-173`, `terrenos/terrain_detector.gd:26-91, 157-168`, `terrenos/terrain_block.gd:11-26`.

