# Reporte de físicas y colisiones — Glyph Cluster

**Fecha:** 2026-11-08  
**Alcance solicitado:** `game/isla-ancestral/scripts/` (búsqueda de `.gd` relacionados con físicas, colisiones, rigidbody/characterbody; carpetas `scripts/fisica/`, `scripts/colisiones/` o similares).  
**Método:** búsqueda por patrones (`CharacterBody3D`, `RigidBody3D`, `StaticBody3D`, `Area3D`, `move_and_slide`, `collision_layer/mask`, `CollisionShape3D`, `Shape3D`, `continuous_cd`, `move_and_collide`, `safe_margin`) y lectura de archivos/escenas relevantes.

## Hallazgos de estructura

- No existen carpetas dedicadas `game/isla-ancestral/scripts/fisica/` ni `game/isla-ancestral/scripts/colisiones/` en el árbol actual de `scripts/`. La física/colisión está distribuida por dominio (`player/`, `npc/`, `fauna/`, `ia_npc/`, `terrenos/`, `terrain/`, `houses/`, `crafting/`, `camera/`, `resources/`, `ruinas/`, `viajes/`, `prototipo/`, `simple_walk.gd`, etc.).
- Scripts/escenas con física explícita detectados (muestra representativa): `scripts/player/player.gd`, `scripts/npc/villager.gd`, `scripts/ia_npc/npc_agent.gd`, `scripts/fauna/*.gd`, `scripts/prototipo/player_proto.gd`, `scripts/simple_walk.gd`, `scripts/terrenos/terrain_block.gd`, `scripts/terrenos/terrain_detector.gd`, `scripts/terrain/terrain_detector.gd` (legacy), `scripts/camera/camera_spring.gd` (deprecated), `scripts/crafting/crafting_station.gd`, `scripts/resources/resource_node.gd`, `scripts/ruinas/generador_ruina.gd`, `scripts/viajes/embark_trigger.gd`, `scripts/houses/interior_collision.gd`; escenas `scenes/player/Player.tscn`, `scenes/npc/npc_agent.tscn`, `scenes/simple_walk.tscn`, `scenes/main_test.tscn`.

## (1) ¿Cómo se gestionan las colisiones y físicas?

### Cuerpos de personaje / agentes (`CharacterBody3D` + `move_and_slide`)
- **Jugador principal**: `scripts/player/player.gd:1` (`extends CharacterBody3D`). Usa un enfoque híbrido: si hay `VoxelBoxMover` y `VoxelTerrain`, calcula `motion = velocity * delta` (`:371`), lo ajusta con `_box_mover.get_motion(global_position, motion, _character_box, _terrain)` (`:372`), aplica `global_translate(motion)` (`:373`) y detecta suelo por bloqueo vertical (`:375-377`). Si no hay mover/terreno, hace fallback a `move_and_slide()` (`:403-405`). Incluye “suelo fantasma” anti-caída por streaming lento (`:378-401`) consultando altura precalculada del generador.
- **Escena del jugador**: `scenes/player/Player.tscn:16-27` define `Player` como `CharacterBody3D` con `BodyCollision` (`CollisionShape3D`, cápsula `radius=0.4`, `height=1.5`, transform Y=0.75). También monta `TerrainDetector` (`:29-34`) como `RayCast3D` con `collision_mask=32` (bit dedicado terreno) y script `scripts/terrenos/terrain_detector.gd`.
- **NPC aldeano**: `scripts/npc/villager.gd:1` (`CharacterBody3D`). Crea colisión en runtime (`:106-112`) con `CollisionShape3D` + `CapsuleShape3D` (`radius=0.3`, `height=1.6`, posición Y=0.8). No muestra uso de `move_and_slide` en el archivo leído (comportamiento más estático/interactivo).
- **NPC agente IA**: `scripts/ia_npc/npc_agent.gd:9` (`CharacterBody3D`), llama `move_and_slide()` en `:317`. La escena `scenes/npc/npc_agent.tscn:13-23` define cápsula de colisión `CollisionShape3D`/`CapsuleShape3D` (r=0.3, h=1.6).
- **Fauna**: varios `CharacterBody3D` con `move_and_slide()` (`scripts/fauna/tortuga_npc.gd:1,193,202`; `jabali_npc.gd:1,189,198`; `cangrejo_npc.gd:1,169,180`; `gaviota_npc.gd:1,300,356,386,559,604,622,643`). Algunos crean colisión en runtime (ej. gaviota `:135-139` crea `CollisionShape3D`+`CapsuleShape3D`).
- **Prototipo/simple walk**: `scripts/prototipo/player_proto.gd:1,24` y `scripts/simple_walk.gd:1,37` usan `CharacterBody3D` + `move_and_slide()`. `scenes/simple_walk.tscn:69-70,105-106` define `StaticBody3D` de suelo y colisión del jugador.

### Cuerpos estáticos / áreas / detectores
- **Bloques de terreno legacy/simple**: `scripts/terrenos/terrain_block.gd:1` (`extends StaticBody3D`), asigna `collision_layer` por tipo en `_ready()` (`:13`, `_layer_for_type` `:17-26`).
- **Estaciones de crafting**: `scripts/crafting/crafting_station.gd:105-120` crea `CollisionShape3D` + `BoxShape3D` dentro de un `Area3D`, pero **desactiva** física por diseño (`monitoring=false`, `monitorable=false`, `collision_layer=0`, `collision_mask=0`); la interacción es por distancia en `_unhandled_input` (`:51-65`). El QA asociado valida esto (`scripts/crafting/qa_m16_station_fisica.gd:29-38`).
- **Recursos/ruinas**: crean `CollisionShape3D`/shapes para áreas o colisión (`scripts/resources/resource_node.gd:163-172` crea `Area3D` con `collision_layer = 1<<20`, `collision_mask=0`; `scripts/ruinas/generador_ruina.gd:84-88` crea `CollisionShape3D` + `BoxShape3D`).
- **Detección de terreno por raycast**: `scripts/terrenos/terrain_detector.gd` (vigor, M156 B3) usa `RayCast3D` con debounce, `collision_mask` dedicado (`LAYER_TERRENO_MASK = 32`, `:34,59,168`), agrega bit dedicado al `VoxelTerrain` sin quitar capa mundo (`:157-168`), y obtiene el bloque voxel con `VoxelTool.get_voxel` (`:179-194`). Hay una variante legacy renombrada `scripts/terrain/terrain_detector.gd:5` (`TerrainDetectorLegacy`), no consumida según comentario.
- **Cámara spring (deprecated)**: `scripts/camera/camera_spring.gd:53-66,74-103` configura `RayCast3D` contra cuerpos para evitar atravesar geometría; está marcado como código muerto en favor de `follow_camera.gd` vía voxel raycast (`:1-8`).

### Terreno voxel
- El jugador y detectores integran colisión/consulta con `VoxelTerrain`/`VoxelTool`/`VoxelBoxMover` (`player.gd:15-26,89-97,370-377,436-496`; `terrain_detector.gd:76-80,179-194`). Esto sugiere que gran parte de la colisión de mundo depende del pipeline de Voxel Tools, no solo de `StaticBody3D`/`CollisionShape3D` manuales.

## (2) ¿Hay cuerpos rígidos sin shape de colisión?

### `RigidBody3D` / cuerpos rígidos dinámicos
- **No se detectó** `extends RigidBody3D` en `game/isla-antestral/scripts/**/*.gd` ni referencias a `RigidBody3D` en las escenas `.tscn` revisadas (`scenes/`, `scripts/player`, `npc`, `fauna`, `houses`, `crafting`, `resources`, `ruinas`, `prototipo`, `terrenos`, `terrain`, `world`, `camera`, `ui`, `preview`, `test`, `qa`, `validadores`, `debug`, `tools`, `simple_walk.gd`). El proyecto parece apoyarse principalmente en `CharacterBody3D`, `StaticBody3D`, `Area3D` y colisión/consulta voxel.

### Shapes creados pero no conectados a un cuerpo físico activo (hallazgo relevante)
- **`scripts/houses/interior_collision.gd` — shapes huérfanos de física**: el script genera `BoxShape3D` (`:48-49`, `:56-57`) y los guarda en `_paredes` (`:50,61`), pero **no crea `CollisionShape3D`**, **no crea `StaticBody3D`/`Area3D`**, **no los añade como hijos al árbol**, ni expone una API para montar esos shapes en nodos de colisión. Métodos como `generar_colisiones` (`:23-31`) solo devuelven conteos; `cantidad_formas` (`:44-45`) cuenta shapes en memoria. `es_interior` (`:38-41`) es una comprobación lógica por AABB, no colisión física. **Conclusión:** en su estado actual, este componente no produce colisiones reales en runtime; los shapes existen solo como recursos en memoria. Puede considerarse equivalente funcional a “sin colisión efectiva”, aunque no sea un `RigidBody3D` sin shape.

### Casos deliberados (no son defectos)
- `scripts/crafting/crafting_station.gd:105-120` crea `Area3D` + `CollisionShape3D` pero los desactiva a propósito (QA en `qa_m16_station_fisica.gd:29-32`). Tiene shape, pero no participa en física; es decisión explícita.
- Escenas revisadas (`Player.tscn`, `npc_agent.tscn`, `simple_walk.tscn`, `main_test.tscn`) muestran `CollisionShape3D` con `shape` asignado (`SubResource(...)`).

## (3) ¿Hay problemas de tunelización o cuerpos que atraviesan paredes?

No se observan `RigidBody3D` rápidos con CCD configurable, porque no hay `RigidBody3D` detectados. Sin embargo, hay **riesgos/patrones** que pueden producir atravesado o caída, dependiendo de velocidad, delta, streaming y geometría:

1. **Jugador híbrido con movimiento manual + fallback** (`scripts/player/player.gd:370-405`):
   - Cuando usa `VoxelBoxMover`, aplica `global_translate(motion)` tras obtener movimiento ajustado (`:372-373`). La protección contra tunelización depende enteramente de la implementación de `VoxelBoxMover.get_motion` y del tamaño de `_character_box` (`:19`). No se ve configuración explícita de substeps/CCD en este script.
   - En fallback usa `move_and_slide()` (`:404`), que en Godot maneja colisiones de `CharacterBody3D`, pero no sustituye CCD para cuerpos dinámicos rápidos; con `delta` grande o geometría delgada podría haber penetración puntual.
   - `move_speed` está alto en desarrollo (`:8`, `:60` = 25.0; export escena 5.0 en `Player.tscn:19`), lo que aumenta el desplazamiento por frame (`velocity * delta`, `:371`).

2. **Suelo fantasma / anticaída** (`scripts/player/player.gd:378-401`): mitiga caída al vacío por chunks no materializados, pero introduce teletransportes verticales (`global_position.y = ...`) cuando se cumplen condiciones (`velocity.y < -5.0` y altura bajo umbral). No es tunelización clásica, pero puede percibirse como atravesar/atravesado vertical si la heurística discrepa del terreno real.

3. **Agentes con `move_and_slide()` directo** (`ia_npc/npc_agent.gd:317`; fauna varios; `simple_walk.gd:37`; `prototipo/player_proto.gd:24`): comportamiento estándar de `CharacterBody3D`. Riesgo bajo-medio si velocidades son moderadas y colisionadores sólidos; riesgo mayor si se combinan velocidades altas, colisionadores delgados o movimiento manual adicional en otros scripts.

4. **Paredes interiores sin colisión física efectiva** (`scripts/houses/interior_collision.gd:23-68`): aunque no es “tunelización” del motor, el resultado práctico es que **no hay barrera física** generada por este módulo; un personaje puede atravesar donde se esperaba colisión, salvo que otra lógica/malla/colisionador externo lo impida.

5. **Ausencia de evidencia de `continuous_cd`/CCD**: la búsqueda no encontró `continuous_cd`/configuración CCD en scripts/escenas revisadas. Esto es coherente con la ausencia de `RigidBody3D`, pero significa que no hay mitigación CCD de motor para cuerpos rígidos rápidos (porque no existen) y que cualquier movimiento manual debe ser seguro por paso pequeño o por swept checks propios.

## (4) Sugerencias de mejora (2)

1. **Completar `InteriorCollision` para generar colisión real o eliminar el falso contrato**
   - Archivos: `scripts/houses/interior_collision.gd:23-68`.
   - Problema: `generar_colisiones`/`_crear_plano`/`_crear_paredes` solo crean `BoxShape3D` en memoria (`_paredes`), sin `CollisionShape3D` ni cuerpo físico (`StaticBody3D`/`Area3D`) añadido al árbol. El módulo reporta “formas” pero no bloquea físicamente.
   - Mejora: crear nodos `StaticBody3D` (o `CollisionShape3D` hijos de un cuerpo existente) por suelo/pared, asignar `shape`, `transform/position` coherentes con `HABITACIONES_LIMITE`, y añadirlos al árbol; o, si la intención es solo lógica, renombrar/documentar claramente que no provee colisión física y evitar usar “colisiones” en la API. Añadir prueba que verifique presencia de `CollisionShape3D` en árbol y respuesta de física/raycast.

2. **Endurecer el movimiento del jugador contra pasos grandes y estados de streaming**
   - Archivos: `scripts/player/player.gd:8,60,370-405,378-401`; escena `scenes/player/Player.tscn:19`.
   - Problema: el movimiento depende de `velocity * delta` y `global_translate` con `VoxelBoxMover` (protección no visible aquí), tiene fallback a `move_and_slide()`, y usa teletransporte vertical de recuperación. La velocidad DEV elevada (25.0) aumenta riesgo en pruebas.
   - Mejora: (a) limitar `delta` efectivo para movimiento (clamp o `min(delta, max_physics_step)`) o subdividir `motion` en substeps cuando el desplazamiento supere una fracción del tamaño del AABB (`_character_box`); (b) normalizar/validar `move_speed` según modo dev/release para evitar valores extremos accidentales; (c) mantener el suelo fantasma pero registrar/medir discrepancias con la colisión real al materializar chunks (telemetría/debug) para detectar casos donde el ajuste vertical atraviesa geometría esperada.

## Conclusión final

La gestión de colisiones/físicas en `game/isla-ancestral/scripts/` es **híbrida y distribuida**: `CharacterBody3D` + `move_and_slide()` para agentes/NPCs/fauna/prototipos, movimiento especial del jugador con `VoxelBoxMover`/`VoxelTerrain` y fallback, raycasts dedicados para detección de terreno/cámara, y algunos `StaticBody3D`/`Area3D`/`CollisionShape3D` creados en escenas o runtime. **No se detectaron `RigidBody3D`** ni configuración `continuous_cd` en el alcance revisado, por lo que no hay cuerpos rígidos dinámicos sin shape evidentes; sin embargo, **`scripts/houses/interior_collision.gd` crea shapes de colisión que nunca se montan en nodos físicos**, dejando sin colisión efectiva esa funcionalidad. Los riesgos principales de atravesado no provienen de CCD ausente en rigid bodies, sino de **movimiento manual/substeps no verificables aquí**, velocidad de desarrollo alta y geometría/streaming voxel; se recomienda completar la colisión interior y endurecer el paso de movimiento del jugador.
