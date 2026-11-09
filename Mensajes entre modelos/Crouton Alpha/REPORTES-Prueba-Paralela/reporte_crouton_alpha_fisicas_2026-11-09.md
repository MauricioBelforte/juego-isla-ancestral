# Reporte de Físicas / Colisiones — Isla Ancestral

**Modelo:** Crouton Alpha
**Plataforma:** Kilo
**Fecha:** 2026-11-09
**Alcance:** `game/isla-ancestral/scripts/` + escenas `.tscn` asociadas (búsqueda de archivos relacionados con físicas, colisiones, `RigidBody3D`, `CharacterBody3D`, `StaticBody3D`, `Area3D`, `CollisionShape3D`, `VoxelBoxMover`, capas/máscaras).

---

## 1. ¿Cómo se gestionan las colisiones y físicas?

La gestión de físicas es **híbrida y no uniforme**: no hay una carpeta dedicada `scripts/fisica/` ni `scripts/colisiones/` (glob `game/isla-ancestral/scripts/fisica/**/*.gd` y `.../colisiones/**/*.gd` → **0 archivos**). Las físicas están repartidas entre `player/`, `npc/`, `ia_npc/`, `fauna/`, `terrenos/`, `crafting/`, `resources/`, `ruinas/`, `houses/` y escenas `.tscn`.

### 1.1 Jugador — dualidad `VoxelBoxMover` + `CharacterBody3D`

**Archivo principal:** `game/isla-ancestral/scripts/player/player.gd:1` (`extends CharacterBody3D`)

- Usa **`VoxelBoxMover`** (colisión voxel estilo Minecraft) como sistema primario: `player.gd:16`, `player.gd:90` (`_box_mover = VoxelBoxMover.new()`), y en `_physics_process` (`player.gd:370-401`) calcula `motion = velocity * delta`, lo filtra con `_box_mover.get_motion(global_position, motion, _character_box, _terrain)` y aplica `global_translate(motion)`. La caja del jugador es `AABB(Vector3(-0.4, 0.0, -0.4), Vector3(0.8, 1.8, 0.8))` (`player.gd:19`).
- Detecta suelo manualmente: `_on_ground = abs(motion.y) < 0.001 and velocity.y <= 0.0` (`player.gd:375`).
- Fallback a `move_and_slide()` estándar solo si falta `_box_mover` o `_terrain`: `player.gd:402-405` (`_on_ground = is_on_floor()`).
- Gravedad propia: `gravity = 20.0` (`player.gd:9`), aplicada en `player.gd:357-359` (`if not _on_ground: velocity.y -= gravity * delta`). Velocidad desarrollo `move_speed = 25.0` forzada en `_ready` (`player.gd:60`), aunque la escena `Player.tscn:19` exporta `5.0` (`@export var move_speed: float = 100.0` en `player.gd:8`).
- Escena: `game/isla-ancestral/scenes/player/Player.tscn:12-14` define `CapsuleShape3D radius=0.4 height=1.5`, nodo `BodyCollision` en `Player.tscn:25-27` (offset Y 0.75). No fija `collision_layer`/`collision_mask` del cuerpo — heredan por defecto (capa 1).
- **Anti-caída al vacío (suelo fantasma):** `player.gd:378-401`. Si `_on_ground == false` y `velocity.y < -5.0`, consulta `_generador_isla()` → `get_height()` y sostiene al jugador en la altura precalculada (superficie de agua `y=4.45` si `h_piso < 4.0`).

### 1.2 NPC / Villager — `CharacterBody3D` + cápsula creada por código

- `game/isla-ancestral/scripts/npc/villager.gd:1` (`extends CharacterBody3D`). Crea su colisionador en `_crear_visuales()` (`villager.gd:105-112`): `CapsuleShape3D radius=0.3 height=1.6`, posición `y=0.8`. La escena `scenes/npc/villager.tscn:5-6` es solo el nodo raíz sin shape — el shape depende 100% del código.
- **No hay `move_and_slide()`** en `villager.gd`: el villager no se mueve físicamente; su posicionamiento es por snap: `_snap_to_ground()` (`villager.gd:151-169`) usa `TerrainLocator.get_height() + 1.0`, con reintentos diferidos (hasta 6 intentos cada 0.5 s).
- `game/isla-ancestral/scripts/ia_npc/npc_agent.gd:9` (`class_name NPCAgent extends CharacterBody3D`). Movimenta vía `NavigationAgent3D` (`npc_agent.gd:101-107`, `radius=0.4`) y `move_and_slide()` en `stop_movement()` (`npc_agent.gd:315-317`) y en los estados:
  - `game/isla-ancestral/scripts/ia_npc/states/movement_state.gd:32-33` (`controller.velocity = dir * spd; controller.move_and_slide()`).
  - `game/isla-ancestral/scripts/ia_npc/states/social_state.gd:32` (idem).
- Escena `scenes/npc/npc_agent.tscn:9-11,21-23`: `CapsuleShape3D radius=0.3 height=1.6` en `y=0.8`, `NavigationAgent3D radius=0.4`. **Sin `collision_layer`/`collision_mask` explícitos.**
- Separación anti-overlap en `npc_agent.gd:239-252` (`apply_separation`, `SEPARATION_RADIUS=1.5`).

### 1.3 Fauna — `CharacterBody3D` + `move_and_slide()` + snap manual

Todos los animales de `game/isla-ancestral/scripts/fauna/` extienden `CharacterBody3D` (`gaviota_npc.gd:1`, `tortuga_npc.gd:1`, `cangrejo_npc.gd:1`, `jabali_npc.gd:1`). Patrón común:

- `velocity = dir * velocidad` + `move_and_slide()` + `_seguir_suelo()` (lerp Y hacia `TerrainLocator.get_height() + 1.0`):
  - Tortuga: `tortuga_npc.gd:184-202` + `_seguir_suelo()` en `tortuga_npc.gd:278-286` (`lerp(..., 0.15)`).
  - Cangrejo: `cangrejo_npc.gd:160-183` + `_seguir_suelo()` en `cangrejo_npc.gd:223-229`.
  - Jabalí: `jabali_npc.gd:180-201` + `_seguir_suelo()` en `jabali_npc.gd:250-256`.
- **Gaviota (caso especial y el más robusto):** `game/isla-ancestral/scripts/fauna/gaviota_npc.gd`. Usa `motion_mode` dinámico (`MOTION_MODE_FLOATING` en aire, `MOTION_MODE_GROUNDED` en tierra — `gaviota_npc.gd:87,275,288,345,383,412,532,601,619,633`), `floor_max_angle = 0.96` (~55°, `gaviota_npc.gd:145`) y `floor_snap_length = 0.3` (`gaviota_npc.gd:413,533`). Su shape sí se crea en código: cápsula `radius=0.22 height=0.70` en `gaviota_npc.gd:135-142`. Es el único animal con shape creado explícitamente en el script; el resto depende de la escena o de no tener ninguno (ver §2).
- En tierra la gaviota usa caída controlada (`velocity.y = -1.2` en `gaviota_npc.gd:558`, `-2.0` en `gaviota_npc.gd:603`) y en vuelo clampa velocidad vertical (`gaviota_npc.gd:355`: `clampf(velocity.y, -1.0, 1.5)`).

### 1.4 Terreno — `VoxelTerrain` + `TerrainBlock` (StaticBody3D) + `TerrainDetector` (RayCast3D)

- Motor real: `VoxelTerrain` (nodo nativo del addon Voxel Tools). El jugador y los edificios lo usan vía `VoxelTool` (raycast `player.gd:260-267`, edición `player.gd:233-258`).
- `game/isla-ancestral/scripts/terrenos/terrain_block.gd:1` (`extends StaticBody3D`) — bloque de terreno M156 con `collision_layer` según tipo (`terrain_block.gd:17-26`: cesped=1, barro=2, pavimento=4, arena=8, agua=16, nieve=32, rocas=64). **No crea `CollisionShape3D` en el script** — si la escena no lo aporta, es un cuerpo estático fantasma (ver §2).
- `game/isla-ancestral/scripts/terrenos/terrain_detector.gd:23-24` (`class_name TerrainDetector extends RayCast3D`): raycast vertical (`ray_length=2.0`, `terrain_detector.gd:39`), `collision_mask = 32` (bit 6 dedicado, `terrain_detector.gd:34,59,168`), `collide_with_areas=false`, `collide_with_bodies=true`. Emite `terrain_changed` con debounce 0.15 s (`terrain_detector.gd:41,86-91`). Resuelve el `VoxelTerrain` por grupo/archivo (`terrain_detector.gd:103-126`).
- `project.godot:336-340` define capas: 1=mundo, 2=jugador, 3=npc, 4=interactuable, 5=agua. Motor físico: Jolt (`project.godot:343-344`: `3d/physics_engine="Jolt Physics"`).

### 1.5 Objetos interactuables — `Area3D` (sin física reactiva)

- `game/isla-ancestral/scripts/crafting/crafting_station.gd:105-120`: crea `BoxShape3D size=Vector3(2.0, 1.8, 1.6)` dentro de `Area3D`, pero con `monitoring=false`, `monitorable=false`, `collision_layer=0`, `collision_mask=0` — **intencionalmente fuera del broadphase** (optimización M16).
- `game/isla-ancestral/scripts/resources/resource_node.gd:161-173`: `SphereShape3D radius=1.4` en `Area3D`, `collision_layer = 1 << 20`, `collision_mask = 0` (capa exclusiva de vetas M35).
- `game/isla-ancestral/scripts/ruinas/generador_ruina.gd:81-91`: `BoxShape3D 2x2x2` en `Area3D` con `body_entered`.
- `game/isla-ancestral/scripts/viajes/embark_trigger.gd:11` (`extends Area3D`).
- `game/isla-ancestral/scripts/houses/interior_collision.gd:6-68`: genera `BoxShape3D` de suelo + 4 paredes (array `_paredes`) pero **no los adjunta a ningún `StaticBody3D`/`CollisionShape3D`** — son solo recursos en memoria, sin colisión real (ver §2).

### 1.6 `RigidBody3D` — inexistente

Búsqueda `extends RigidBody3D` / `extends AnimatableBody3D` en `scripts/`: **0 resultados**. No hay cuerpos rígidos con dinámica en todo el proyecto; todos los movimientos son cinemáticos (`CharacterBody3D` + `move_and_slide` o `VoxelBoxMover`).

---

## 2. ¿Hay cuerpos rígidos sin shape de colisión?

No hay `RigidBody3D`, pero **sí hay `StaticBody3D` y `CharacterBody3D` sin shape garantizada en código**, que dependen de la escena o quedan sin colisión:

| Archivo / línea | Cuerpo | Shape | Estado |
|---|---|---|---|
| `terrenos/terrain_block.gd:1-43` | `StaticBody3D` | **Ninguno en el .gd** (solo asigna `collision_layer` en `terrain_block.gd:13`) | ⚠️ **Sin shape en código.** Si la escena que instancia `terrain_block` no añade `CollisionShape3D`, es un `StaticBody3D` fantasma: ocupa capa/máscara pero no colisiona. Verificar la escena que lo instancia. |
| `fauna/tortuga_npc.gd:1-286` | `CharacterBody3D` | **Ninguno en el .gd** (grep en `fauna/` solo encuentra shape en `gaviota_npc.gd:135`) | ⚠️ **Sin shape en código.** Depende de `scenes/main_island.tscn:174` (`TortugaNPC`) — la escena **no declara** nodo `CollisionShape3D` (solo `CharacterBody3D` + script). Resultado: tortuga sin colisionador → atraviesa paredes y no genera colisiones; su "movimiento" es solo `move_and_slide()` sin forma que resolver (Godot emite warning). |
| `fauna/cangrejo_npc.gd:1-229` | `CharacterBody3D` | **Ninguno en el .gd** | ⚠️ Idem. `scenes/main_island.tscn:178` (`CangrejoNPC`) no declara shape. |
| `fauna/jabali_npc.gd:1-256` | `CharacterBody3D` | **Ninguno en el .gd** | ⚠️ Idem. `scenes/main_island.tscn:182,187` (`JabaliNPC`, `JabaliAdultoNPC`) sin shape en escena. |
| `fauna/gaviota_npc.gd:135-142` | `CharacterBody3D` | Cápsula r=0.22 h=0.70 creada en `_instanciar_modelo()` | ✅ OK — único animal con shape por código. |
| `npc/villager.gd:105-112` | `CharacterBody3D` | Cápsula r=0.3 h=1.6 por código | ✅ OK (aunque `scenes/npc/villager.tscn` no la declara, el .gd sí la crea). |
| `ia_npc/npc_agent.gd` + `scenes/npc/npc_agent.tscn:9-23` | `CharacterBody3D` | Cápsula r=0.3 h=1.6 en escena | ✅ OK. |
| `player/player.gd` + `scenes/player/Player.tscn:25-27` | `CharacterBody3D` | Cápsula r=0.4 h=1.5 en escena (`BodyCollision`) | ✅ OK, pero **dual**: la escena define cápsula 1.5 m mientras la lógica usa `AABB 0.8×1.8` (`player.gd:19`) — dos "formas" distintas conviviendo. |
| `houses/interior_collision.gd:47-63` | `Node3D` (no cuerpo) | Crea `BoxShape3D` (suelo + 4 paredes) y los guarda en `_paredes` sin adjuntarlos a ningún `CollisionShape3D`/`StaticBody3D` | ⚠️ **Shapes huérfanas.** `generar_colisiones()` (`interior_collision.gd:23-31`) devuelve un contador, pero ninguna forma se inserta en el árbol → **cero colisión real** en interiores. El jugador puede atravesar paredes/suelo de casas. |
| `crafting/crafting_station.gd:105-111` | `Node3D` + `Area3D` | `BoxShape3D 2.0×1.8×1.6` adjuntada al `Area3D` | ⚠️ Shape existe pero con `collision_layer=0`/`mask=0`/`monitoring=false` (`crafting_station.gd:117-120`) → **no interactúa**; la interacción es solo por distancia en `_unhandled_input` (línea 51-65). |
| `resources/resource_node.gd:161-173` | `Node3D` + `Area3D` | `SphereShape3D r=1.4` adjuntada, `layer=1<<20, mask=0` | ✅ OK por diseño (capa exclusiva M35, área pasiva). |
| `ruinas/generador_ruina.gd:81-91` | `Node3D` + `Area3D` | `BoxShape3D 2×2×2` adjuntada | ✅ OK (placa del puzzle). |

**Resumen §2:** 3 de 4 animales de `fauna/` (tortuga, cangrejo, jabalí — 4 instancias en `main_island.tscn:174-190`) son `CharacterBody3D` sin `CollisionShape3D` ni en el `.gd` ni en la escena. Problema estructural: Godot `move_and_slide()` sin shape no resuelve colisiones y puede lanzar `PhysicsServer` warnings/errores en runtime. Además `terrain_block.gd` y `interior_collision.gd` confirman el patrón de "cuerpo/shape creado a medias".

---

## 3. ¿Hay problemas de túnelización o cuerpos que atraviesan paredes?

### 3.1 Jugador (VoxelBoxMover primario) — riesgo moderado

- Con `move_speed` de desarrollo 25.0 m/s (`player.gd:60`), el desplazamiento por frame a 60 Hz es `25/60 ≈ 0.42 m`. El ancho de la caja es 0.8 m (`player.gd:19`), así que **no hay túnel horizontal en condiciones normales** (0.42 < 0.8). A 30 FPS (0.83 m/frame) el margen se estrecha y a velocidades >48 m/s podría tunelar. Sin clamp de velocidad ni `safe_margin` ajustado.
- Vertical: gravedad 20.0 (`player.gd:9`). En caída larga `velocity.y` crece sin límite (`player.gd:358-359`); el propio código reconoce el riesgo y añade el suelo fantasma con umbral `velocity.y < -5.0` (`player.gd:387`). Si `velocity.y` se acumula (caída de 50 m → `v ≈ -36 m/s`), el `motion.y` por frame supera 0.6 m y puede atravesar el voxel antes de que `VoxelBoxMover` lo detenga. El fallback `move_and_slide()` sí usa el kernel de Godot con barrido; `VoxelBoxMover` es un resolver AABB discreto → **riesgo de tunneling vertical en caídas largas**, mitigado parcialmente por el suelo fantasma (que solo cubre chunks sin materializar, no paredes).
- **Sin `floor_snap_length` ni `floor_max_angle` configurados** en el jugador (grep `floor_snap|MOTION_MODE` solo devuelve hits en `gaviota_npc.gd`). Al bajar pendientes, el jugador puede quedarse flotando o deslizarse sin contacto consistente — depende de la heurística `abs(motion.y) < 0.001` (`player.gd:375`).

### 3.2 NPC (NavigationAgent + move_and_slide) — riesgo bajo

- Velocidades 3.0-5.0 m/s (`movement_state.gd:6-7`). `move_and_slide()` de Godot incluye barrido por frame → sin túnel a 60 Hz. El riesgo real es otro: **NavigationAgent3D con `radius=0.4`** (`npc_agent.gd:106`) coincide con la cápsula del NPC (0.3) y la del jugador (0.4) sin capas/máscaras diferenciadas (ningún `.tscn` fija `collision_layer` para `npc_agent.tscn`/`villager.tscn`; solo `Player.tscn` y `TerrainDetector` tocan mascaras). NPC y jugador comparten capa 1 por defecto → colisionan entre sí, pero el `TerrainDetector` del raycast los ignora gracias al bit 6 (`terrain_detector.gd:59`).
- La gaviota es el patrón a seguir: en vuelo usa `MOTION_MODE_FLOATING` y en tierra `GROUNDED` con `floor_snap_length = 0.3`, más esquive con `get_wall_normal()` y watchdog de 2.5 s (`gaviota_npc.gd:257-271`). Aun así, su descenso es vertical puro a 2.2 m/s (`gaviota_npc.gd:385`) → sin túnel.

### 3.3 Fauna terrestre — **atraviesan paredes por diseño (no tienen shape)**

- Tortuga, cangrejo y jabalí **no tienen `CollisionShape3D`** (ver §2): `move_and_slide()` no tiene nada que resolver → **atraviesan paredes, muros de ruinas y rocas**. Su único "suelo" es el lerp `_seguir_suelo()` hacia `get_height()+1.0` (`tortuga_npc.gd:284-286`, `cangrejo_npc.gd:228-229`, `jabali_npc.gd:255-256`), que teleporta la Y sin consultar colisiones. Si el destino `_elegir_destino()` cae dentro de una pared voxel, el animal camina **a través** de ella. En el caso del jabalí/tortuga/cangrejo esto es visible: `radio_paseo_max` de 34 m cruza cualquier estructura.
- No usan `floor_snap_length` ni `is_on_floor()` — solo `move_and_slide()` ciego (`tortuga_npc.gd:193`, `cangrejo_npc.gd:169`, `jabali_npc.gd:189`).
- Velocidades 0.9-1.7 m/s → túnel por velocidad no aplica; el atraviesa-muros es por **ausencia de shape**, no por tunneling.

### 3.4 Interiores y terreno estático — atraviesan por falta de cuerpos

- `houses/interior_collision.gd:47-63` crea shapes sin adjuntar → paredes de casas sin colisión real. El jugador entra/sale de casas atravesando paredes.
- `terrenos/terrain_block.gd:13` asigna `collision_layer` pero no crea shape → cualquier bloque instanciado desde ese script sin shape en escena es atravesable. El terreno real es `VoxelTerrain` (atención: Voxel Tools sí genera colisión por voxel, así que el suelo principal no es el problema; el problema son los `StaticBody3D` sueltos).

### 3.5 Sin CCD ni barrido explícito en ningún script

Grep `safe_margin|cast_motion|test_motion|ray_cast` en `scripts/`: **0 hits** en gameplay (solo `RayCast3D` para cámara `camera_spring.gd:53` y `TerrainDetector`). Ningún `CharacterBody3D` usa `safe_margin` mayor ni comprobación `test_motion()` antes de `move_and_slide()`. A velocidades actuales es aceptable, pero cualquier aumento de `move_speed` (el `@export` llega a 100.0 en `player.gd:8`) o de gravedad rompería la garantía.

---

## 4. Mejoras sugeridas (2)

### Mejora 1 — Garantizar shape de colisión a toda la fauna terrestre y espiritizar el patrón de la gaviota

**Problema:** tortuga/cangrejo/jabalí son `CharacterBody3D` sin `CollisionShape3D` (§2, §3.3). Es el bug más visible y grave del sistema.

**Qué hacer:**

1. Añadir a `tortuga_npc.gd`, `cangrejo_npc.gd` y `jabali_npc.gd` la misma creación procedural que ya funciona en `gaviota_npc.gd:135-142` y `villager.gd:105-112`. Ejemplo mínimo para `tortuga_npc.gd::_instanciar_modelo()` (tras `add_child(modelo)`):

   ```gdscript
   var cs := CollisionShape3D.new()
   var shape := CapsuleShape3D.new()
   shape.radius = 0.35
   shape.height = 0.70
   cs.shape = shape
   cs.position = Vector3(0.0, 0.35, 0.0)
   cs.name = "Colision"
   add_child(cs)
   ```

   - Tortuga: `r=0.35 h=0.70` (caparazón bajo).
   - Cangrejo: `r=0.30 h=0.50` (bajo y ancho).
   - Jabalí joven/adulto: `r=0.40 h=1.10` / `r=0.60 h=1.70` (escalar con `etapa` en `jabali_npc.gd:36-39`).

2. Sustituir el teleport `_seguir_suelo()` (`lerp y 0.15`) por física real: `motion_mode = MOTION_MODE_GROUNDED`, `floor_snap_length = 0.3`, `floor_max_angle = 0.96` (como la gaviota, `gaviota_npc.gd:145,413`) y caída constante `velocity.y = -1.2` (como `gaviota_npc.gd:558`). Reservar `TerrainLocator.get_height()` solo para el snap inicial (`_snap_to_ground`, `tortuga_npc.gd:133-144`).

3. Corregir `houses/interior_collision.gd:47-63`: adjuntar cada `BoxShape3D` a un `CollisionShape3D` hijo de un `StaticBody3D` (p. ej. un `StaticBody3D` por habitación con 5 hijos) para que las paredes/suelo bloqueen al jugador.

**Impacto esperado:** los animales dejan de atravesar paredes/ruinas; los interiores bloquean correctamente; se elimina la dependencia del lerp manual de Y. Los esc_targets `main_island.tscn:174-190` heredan el shape por código aunque la escena no lo declare.

### Mejora 2 — Unificar capas/máscaras y cerrar túneles del jugador

**Problema:** capas genéricas (todo en capa 1) y sin protección contra tunneling a velocidad dev alta (§3.1, §3.5).

**Qué hacer:**

1. **Configurar capas según `project.godot:336-340`** en las escenas y scripts:
   - `Player.tscn` / `player.gd::_ready`: `collision_layer = 2` (jugador), `collision_mask = 1 | 4` (mundo + interactuable).
   - `npc_agent.tscn`, `villager.gd`, fauna: `collision_layer = 4` (npc), `collision_mask = 1` (solo mundo) → NPC no colisionan entre sí ni empujan al jugador; el `TerrainDetector` ya funciona con el bit 6 sin interferencia.
   - `terrain_block.gd`, `crafting_station.gd`, `resource_node.gd`, `ruinas`: asignar sus capas de Interactuable (4) / Agua (5) según corresponda, manteniendo el bit 6 para el terreno voxel (ya implementado en `terrain_detector.gd:161-168`).
   - Añadir `collision_layer`/`collision_mask` explícitos a `scenes/npc/villager.tscn`, `scenes/npc/npc_agent.tscn` y `scenes/main_island.tscn` (nodos NPC) — hoy ninguno los fija.

2. **Anti-tunneling del jugador:**
   - Clamp de velocidad vertical: `velocity.y = maxf(velocity.y, -30.0)` tras `player.gd:359` (corte de caída antes del umbral del suelo fantasma `-5.0`).
   - Aumentar `safe_margin` del `CharacterBody3D` (`player.gd::safe_margin = 0.08` recomendado para Jolt a 25 m/s) y configurar `floor_snap_length = 0.3` / `floor_max_angle` en el jugador, unificándolo con el patrón de `gaviota_npc.gd`.
   - Cuando `_box_mover` esté activo, comprobar el `motion` resultante en ejes contra la caja (ya se hace en `player.gd:370-373`) y, si `velocity.y < -25.0`, ejecutar un `move_and_slide()` de respaldo con barrido de Godot antes del `global_translate`, para no perder la garantía de barrido en caídas largas.

**Impacto esperado:** fin de colisiones fantasma NPC↔NPC y de raycast frenados (ya mitigado por el bit 6, pero ahora también a nivel de cuerpos), garantía de no-túnel vertical incluso a `move_speed=25` dev y caídas largas, y comportamiento de suelo coherente con el resto de `CharacterBody3D`.

---

## 5. Conclusión

**Estado general: aceptable para prototipo, con filtraciones reales en fauna e interiores.**

- **Puntos fuertes:** el jugador usa un sistema voxel dedicado (`VoxelBoxMover`) con suelo fantasma anti-caída (`player.gd:370-401`); la gaviota es un ejemplo completo de gestión de `motion_mode`/`floor_snap`/`get_wall_normal`/watchdog (`gaviota_npc.gd:87-145,257-271`); el `TerrainDetector` está bien aislado en el bit 6 (`terrain_detector.gd:34,59,161-168`); `villager.gd` y `npc_agent.gd` tienen shape correcta; no hay `RigidBody3D` descontrolados (todo cinemático).
- **Problemas detectados:**
  - **Críticos:** 3 especies de fauna (`tortuga_npc.gd`, `cangrejo_npc.gd`, `jabali_npc.gd`) sin `CollisionShape3D` → atraviesan paredes y terreno irregular; `houses/interior_collision.gd:47-63` y `terrenos/terrain_block.gd` crean shapes/cuerpos sin adjuntar → interiores y bloques estáticos sin colisión.
  - **Medios:** sin capas/máscaras diferenciadas (todo capa 1 por defecto) salvo el detector de terreno; sin CCD/safe_margin/anti-tunneling en el jugador con velocidad dev 25 m/s y caída libre sin clamp; sin `floor_snap` en jugador y fauna terrestre.
  - **Sin riesgo actual:** tunneling horizontal del jugador (0.42 m/frame < 0.8 m de caja) y sin `RigidBody3D` huérfanos.
- **Prioridad recomendada:** implementar primero la Mejora 1 (shapes de fauna + interiores) — es la que corrige comportamiento visible de atravesar-paredes; luego la Mejora 2 (capas + anti-túnel) para robustecer el sistema ante velocidades mayores o contenido nuevo.

**Archivos clave revisados (líneas):** `scripts/player/player.gd:8,19,60,89-90,357-359,370-405` · `scripts/npc/villager.gd:105-112,151-169` · `scripts/ia_npc/npc_agent.gd:101-107,239-317` · `scripts/ia_npc/states/movement_state.gd:6-7,32-33` · `scripts/fauna/gaviota_npc.gd:87,135-145,257-271,383-413,532-558` · `scripts/fauna/tortuga_npc.gd:1,184-202,278-286` · `scripts/fauna/cangrejo_npc.gd:1,160-183,223-229` · `scripts/fauna/jabali_npc.gd:1,180-201,250-256` · `scripts/terrenos/terrain_block.gd:1-43` · `scripts/terrenos/terrain_detector.gd:23-34,59,161-168` · `scripts/houses/interior_collision.gd:47-63` · `scripts/crafting/crafting_station.gd:105-120` · `scripts/resources/resource_node.gd:161-173` · `scripts/ruinas/generador_ruina.gd:81-91` · `scenes/player/Player.tscn:12-34` · `scenes/npc/villager.tscn` · `scenes/npc/npc_agent.tscn:9-23` · `scenes/main_island.tscn:72-194` · `project.godot:336-344`.
