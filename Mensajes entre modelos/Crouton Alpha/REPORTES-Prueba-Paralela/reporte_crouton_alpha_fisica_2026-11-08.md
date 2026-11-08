**Modelo:** Crouton Alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-11-08
**Alcance:** Analisis de fisica y colisiones en `game/isla-ancestral/scripts/` (GDScript + escenas `.tscn` asociadas)

## 1. Alcance y metodologia

- No existe carpeta `scripts/fisica/` ni `scripts/colisiones/`. El grep por `*fisica*` solo devolvio
  `scripts/crafting/qa_m16_station_fisica.gd` (un QA de estacion, no un sistema de fisica).
- Busqueda por `extends (RigidBody3D|CharacterBody3D|StaticBody3D|AnimatableBody3D|CollisionObject3D)`:
  14 coincidencias `.gd`, de las cuales la mayoria `extends CharacterBody3D`.
- Busqueda por `RigidBody|PhysicsServer|PhysicsMaterial|safe_margin|ccd|continuous_cd|freeze`:
  **0 `RigidBody3D`, 0 `PhysicsMaterial`, 0 `safe_margin`, 0 `continuous_cd` en gameplay real**.
  Solo hits de `floor_snap_length` en la gaviota (ver §2) y un TODO en
  `scripts/debug/debug_menu.gd:1023` ("conectar a DebugUtils/PhysicsServer cuando exista").
- Escenas `.tscn`: `main_island.tscn` instancia 6 `CharacterBody3D`, `Player.tscn`, `villager.tscn`,
  `npc_agent.tscn`, `simple_walk.tscn`, `main_test.tscn`.

## 2. Como se gestionan colisiones y fisicas

| Sistema | Clase | Mecanismo | Archivo:linea clave |
|---|---|---|---|
| Jugador (ruta feliz) | `CharacterBody3D` + **no** `move_and_slide()` | `VoxelBoxMover.get_motion()` + `global_translate()`. Caja `AABB(Vector3(-0.4,0,-0.4), Vector3(0.8,1.8,0.8))`. Suelo custom `abs(motion.y) < 0.001 and velocity.y <= 0`. | `scripts/player/player.gd:16-19, 89-97, 370-377` |
| Jugador (fallback) | `CharacterBody3D` | `move_and_slide()` + `is_on_floor()` **solo si** no hay terreno. | `scripts/player/player.gd:403-405` |
| Jugador — rescate anti-vacio | — | "Suelo fantasma": si cae sin chunk materializado (`velocity.y < -5`), teletransporta Y a `IslandGenerator.get_height()` (en agua, a superficie `Y=4.45`). Es reparacion post-caida, no prevencion. | `scripts/player/player.gd:378-401` |
| Jugador — detector de terreno | `RayCast3D` | `collision_mask = 32` (bit dedicado terreno), `TerrainDetector` hijo en `Player.tscn`. | `scenes/player/Player.tscn:29-34`, `scripts/terrenos/terrain_detector.gd:59,166-168` |
| Fauna terrestre (tortuga, jabali, cangrejo) | `CharacterBody3D` | `velocity` horizontal plano + `move_and_slide()` + `_seguir_suelo()` manual: `lerp(Y, TerrainLocator.get_height(X,Z)+1.0, 0.15)` **sin consultar colision**. Sin gravedad, sin `floor_snap`, sin `is_on_floor`. Snap inicial con reintentos `TerrainLocator`. | `scripts/fauna/tortuga_npc.gd:184-202,278-286`; `scripts/fauna/jabali_npc.gd:180-201,250-256`; `scripts/fauna/cangrejo_npc.gd:160-183,223-229` |
| Gaviota (el unico avanzado) | `CharacterBody3D` | `MOTION_MODE_FLOATING` en aire, `MOTION_MODE_GROUNDED` en tierra; `floor_snap_length = 0.3`; `floor_max_angle = 0.96` (~55° para laderas voxel); `is_on_wall()` + `get_wall_normal()` para esquivar; aborta aterrizaje si toca pared; watchdog de despegue a 2.5 s sin movimiento. Colision `CapsuleShape3D r=0.22 h=0.70` con cara plana inferior (fix documentado "esfera tangenteaba aristas a 45°"). | `scripts/fauna/gaviota_npc.gd:87,129-145,304-308,383-413,533` |
| NPC IA (NPCAgent) | `CharacterBody3D` + `NavigationAgent3D` | Movimiento desde `states/movement_state.gd:32-33` y `states/social_state.gd:31-32` (`controller.move_and_slide()`), `stop_movement()` pone `velocity=ZERO` + `move_and_slide()`. Separacion manual por radio `1.5 m`. | `scripts/ia_npc/npc_agent.gd:101-107,239-252,315-317` |
| Villager | `CharacterBody3D` | Crea `CapsuleShape3D r=0.3 h=1.6` **en codigo** (`_crear_visuales()`). Su escena `villager.tscn` no tiene shape. | `scripts/npc/villager.gd:105-112`, `scenes/npc/villager.tscn:5` |
| NPCAgent escena | `CharacterBody3D` | Escena con `CapsuleShape3D r=0.3 h=1.6` en `CollisionShape3D`. | `scenes/npc/npc_agent.tscn:9-23` |
| Terreno voxel | `StaticBody3D` (`terrain_block.gd`) | `collision_layer` por tipo (ceped=1, barro=2, pavimento=4, arena=8, agua=16, nieve=32, rocas=64). `friction` leida de `data/terrenos/terrenos.json` pero **no aplica `PhysicsMaterial`**. No crea `CollisionShape3D` propio. | `scripts/terrenos/terrain_block.gd:1-43` |
| Obstaculos procedurales | `Area3D`/`StaticBody3D` + forma creada en codigo | `crafting_station.gd:105-108` `BoxShape3D`; `resource_node.gd:163-166` `SphereShape3D` (con `Area3D` capa `1<<20`); `generador_ruina.gd:84-87` `BoxShape3D`; `houses/interior_collision.gd:48-56` `BoxShape3D`. | varios |
| Triggers | `Area3D` | `embark_trigger.gd:11,25,41` `body_entered`. La estacion de crafting desactiva su Area (`collision_layer=0, mask=0`, `crafting_station.gd:119-120`). | — |
| Utileria de debug | — | `debug_visualizer.gd` enumera `CollisionShape3D` por clase, dibuja `SphereShape3D`/`BoxShape3D`/`ConvexPolygonShape3D`. | `scripts/debug/debug_visualizer.gd:290-321` |

**Resumen arquitectonico:** el juego no usa el motor clasico de `RigidBody3D`. Todo movimiento es
`CharacterBody3D` + `move_and_slide()` (NPCs/fauna) o `VoxelBoxMover` + `global_translate()` (jugador).
Las colisiones se resuelven ad-hoc por sistema, sin una capa comun de configuracion fisica
(`safe_margin`, `floor_snap`, `floor_block_on_wall`, `slide_on_ceiling`, `PhysicsMaterial` no se
configuran globalmente; solo la gaviota toca `floor_snap_length`/`floor_max_angle`).

## 3. Cuerpos rigidos sin shape de colision (ni cuerpos sin forma en general)

**No hay `RigidBody3D` en el proyecto** (grep = 0). Props fisicas dinamicas no existen. El problema
real es mas amplio: **cuerpos `CharacterBody3D`/`StaticBody3D` sin `CollisionShape3D`**.

### 3.1 Critico: 3 NPCs de fauna SIN forma de colision

El grep `CollisionShape3D.new|shape =|BoxShape|SphereShape|CapsuleShape` dentro de
`scripts/fauna/` devolvio **un solo** resultado productivo: `gaviota_npc.gd:135-142`.
`_instanciar_modelo()` de cada fauna solo instancia el GLB como `Node3D` hijo; nunca crea un `CollisionShape3D`:

- `scripts/fauna/tortuga_npc.gd:82-111` — `_instanciar_modelo()` y `_instanciar_placeholder()` sin shape.
- `scripts/fauna/jabali_npc.gd:85-100` — idem.
- `scripts/fauna/cangrejo_npc.gd:61-73` — idem.

Y `scenes/main_island.tscn:174-192` instancia los 3 como `CharacterBody3D` **sin nodos hijos de colision**.
Un `CharacterBody3D` sin forma no colisiona: `move_and_slide()` no genera `is_on_wall()` ni
`get_slide_collision()`. Son NPCs fantasma: atraviesan paredes, jugador y terreno voxel.

### 3.2 Ambiguo: `villager.tscn`

La escena `scenes/npc/villager.tscn:5` declara el `CharacterBody3D` con script pero **cero nodos
`CollisionShape3D`**. La forma se crea despues en `villager.gd:106-112`. Funciona en runtime, pero es
la inversa del patron de `npc_agent.tscn` (forma en escena). Si alguien instancia la escena sin pasar
por `_crear_visuales()` (herencia, test, respawn), queda sin forma sin warning.

### 3.3 `terrain_block.gd` (StaticBody3D)

`scripts/terrenos/terrain_block.gd:1-43` extiende `StaticBody3D` pero **nunca crea un
`CollisionShape3D`**. Si se instancia suelto (sin un `CollisionShape` padre externo), es un cuerpo
estatico sin forma: no bloquea nada. Ademas su `friction` (fuente JSON) no se aplica a ningun
`PhysicsMaterial`, por lo que elviento de `friction` es solo documentativo.

### 3.4 `player_proto.gd`

`scripts/prototipo/player_proto.gd:1,24` extiende `CharacterBody3D` y usa `move_and_slide()`, sin
crear forma en codigo. Su forma depende de su escena (no verificada en este barrido). Riesgo menor
(prototipo), pero mismo patron fragil que 3.2.

## 4. Tunelizacion y atravesamiento de paredes

### 4.1 Jugador: riesgo real a velocidad DEV

- `move_speed` exportado `100.0` (`player.gd:8`), sobrescrito en `_ready()` a `25.0` (`player.gd:60`);
  la escena `Player.tscn:19` fija `5.0`. A `25 m/s` y `delta=1/60`, el jugador avanza `~0.42 m/frame`,
  casi el ancho de su caja (`0.8 m`); a `30 fps` avanza `~0.83 m/frame`. Una pared de 1 voxel puede
  cruzarse en un frame.
- La ruta feliz **no usa `is_on_floor()` ni `floor_snap`** (`floor_snap_length` nunca se asigna en
  `player.gd`). Detecta suelo con `abs(motion.y) < 0.001 and velocity.y <= 0` (`player.gd:375`):
  fragil ante esquinas donde `motion.y` se anula sin contacto real.
- `global_translate(motion)` (`player.gd:373`) salta la busqueda de colisiones del motor; depende
  100% de que `VoxelBoxMover.get_motion()` resuelva antes. El "suelo fantasma" (`player.gd:387-401`)
  es rescate **posterior** al cruce (cuando ya cayo a `velocity.y < -5`), no prevencion.
- **No hay `safe_margin` custom** en ningun script de gameplay; se usa el default de Godot
  (0.08 m, insuficiente para 25 m/s).

### 4.2 Fauna terrestre: atravesamiento por construccion

- Sin `CollisionShape3D` (§3.1): `move_and_slide()` no detecta nada, no hay tunelizacion porque
  directamente **no hay colision**. Los 3 animals cruzan paredes y jugadores.
- `_seguir_suelo()` manipula `global_position.y` por `lerp` (`tortuga_npc.gd:285`, `jabali_npc.gd:256`,
  `cangrejo_npc.gd:229`): es teletransportacion suave independiente del motor de colisiones. Si dos
  puntos de `_destino` quedan a lados opuestos de una pared o una ladera, el cuerpo llega igual.
- Sin `floor_snap_length`, sin `floor_max_angle`, sin `floor_block_on_wall`, sin `is_on_floor()`,
  sin `get_slide_collision()`: no hay mecanica de "toparse con pared y deslizar" en tortuga/jabali/cangrejo.
- `test_terrenos_b3.gd:200` documenta que los personajes **no fijan `collision_layer` en escena**:
  quedan en layer por defecto (1), en el medio entre el voxel (1) y el bit de terreno (32). Filtrado
  ambiguo.

### 4.3 Gaviota: proteccion real, pero parcial

- Es el unico con `floor_snap_length = 0.3` (`gaviota_npc.gd:413,533`), `floor_max_angle = 0.96`
  (`gaviota_npc.gd:145`) y esquive por `is_on_wall()`/`get_wall_normal()` (`gaviota_npc.gd:304-308,358-362,645-646`).
- Quedan riesgos residuales: `velocidad_vuelo = 6.0` sin `safe_margin` custom ni CCD; puede atravesar
  elementos finos en vuelo. En aterrizaje, si el camino es diagonal al voxel, la forma capsula
  (`gaviota_npc.gd:135-141`) mitiga pero no elimina.
- El watchdog de 2.5 s (`gaviota_npc.gd:82`) evita atasco, no tunelizacion.

### 4.4 NPCAgent / Villager

- Movement/social states asignan `velocity` y llaman `move_and_slide()` sin proteccion extra
  (`ia_npc/states/movement_state.gd:32-33`, `social_state.gd:31-32`). A velocidad normal son seguros,
  pero sin `floor_snap` ni `safe_margin` heredan el riesgo generico de `CharacterBody3D`.
- `apply_separation()` (`npc_agent.gd:239-252`) es separacion soft por distancia, no colision fisica.

## 5. Dos mejoras propuestas (concretas y verificables)

### Mejora 1: Kit unico de colliders + auditoria de formas huerfanas

**Problema que ataca:** §3 (3 NPCs fantasma + 2 casos ambiguos), root cause de atravesamiento total.

**Propuesta:** un helper estatico, p. ej. `scripts/fisica/collider_kit.gd` (clase `ColliderKit`), con:

```gdscript
static func create_capsule(body: Node3D, r: float, h: float, y: float, nombre := "Colision") -> CollisionShape3D:
    var cs := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = r; shape.height = h
    cs.shape = shape; cs.position.y = y; cs.name = nombre
    body.add_child(cs)
    return cs

static func create_box(body: Node3D, tam: Vector3, centro: Vector3) -> CollisionShape3D:
    ...

static func ensure_shape(body: CharacterBody3D) -> bool:
    # devuelve false si el cuerpo no tiene >= 1 CollisionShape3D con shape != null
    ...
```

- Tortuga: `ColliderKit.create_capsule(self, 0.25, 0.6, 0.3)` en `_instanciar_modelo()`.
- Jabali: `ColliderKit.create_capsule(self, 0.35, 1.0, 0.6)` (escala con `escala_modelo`).
- Cangrejo: `ColliderKit.create_capsule(self, 0.22, 0.5, 0.25)`.
- `terrain_block.gd`: `create_box(self, Vector3(1,1,1), Vector3(0.5,0.5,0.5))` por defecto y
  `PhysicsMaterial` con `friction` aplicada (cierra tambien el friction huerfano).
- `villager.tscn` y `main_island.tscn` (fauna): mover la forma **a la escena** (como `npc_agent.tscn`)
  y dejar al codigo solo para retos ajustes. Doble fuente (escena + codigo) es la razon del bug §3.1.
- Guard inesperado en `_ready()` de cada `*Body3D`: `assert(ensure_shape(self))` con `push_warning`
  en release. Barato y detecta regresiones en el primer frame.

**Verificacion:** test headless nuevo `test_fisica_colliders.gd` que instancia cada escena
(`main_island.tscn` fauna, `villager.tscn`, `npc_agent.tscn`, `Player.tscn`, `terrain_block`) y
afirma "todo `*Body3D` tiene >= 1 `CollisionShape3D` hijo con `shape != null`". Mismo
patron que `test_player_m11.gd:122-137` y `debug_visualizer.gd:310`.

**Esfuerzo estimado:** 1 helper + 6 ediciones puntuales + 1 test. Bajo. Elimina la clase entera de
bugs fantasma.

### Mejora 2: Antitunelizado del jugador y fauna ("suelo seguro", no rescate)

**Problema que ataca:** §4.1 y §4.2 (velocidad DEV 25 m/s + lerp de suelo + rescate post-caida).

**Propuesta para `player.gd`** (ruta `VoxelBoxMover`):

- `floor_snap_length = 0.3` (igual que gaviota) y `floor_max_angle = radians_to_degrees(50.0)` como
  suelo, para que bajar escalones no dispare caida falsa ni atrape.
- `floor_block_on_wall = true` y `slide_on_ceiling = false` en el nodo `Player` (via `.tscn`).
- Clamp de velocidad: `velocidad = min(velocidad, 8.0)` en modo juego; dejar 25 m/s solo detras de
  flag DEV (`OS.has_feature("editor")`), o recalcular `motion` en subpasos si `|motion| > 0.5`:
  partir el desplazamiento en N pasos de `<= 0.3 m` (costo menor que CCD, sin cambiar a
  `RigidBody3D`). El `safe_margin` efectivo pasa a ser fijo por fraccionamiento.
- Reemplazar el suelo fantasma post-caida (`player.gd:387-401`, condicion `velocity.y < -5`) por
  **prediccion antes de caer**: si `not _on_ground` y `global_position.y - get_height() > 3.0`,
  anticipar aterrizaje a `get_height()+1.0` (el mismo `get_height` que hoy se usa post-caida).
  El rescate actual exige que la caida ya sea vertical y rapida; la prediccion cubre chunks sin
  materializar antes de que el jugador cruce la pared del chunk.
- `_on_ground` tambien debe aceptar `is_on_floor()` como OR en el fallback (ya esta en `player.gd:405`),
  mas el caso caja: `abs(motion.y) < 0.001` **y** `is_on_floor()`. Hoy la ruta voxel nunca llama a
  `is_on_floor()`.

**Propuesta para fauna terrestre** (tortuga/jabali/cangrejo, tras Mejora 1):

- Reemplazar `_seguir_suelo()` (lerp de Y) por mecanica Godot: `floor_snap_length = 0.25`,
  `velocity.y = -1.0` constante para "pegar" al suelo, y `move_and_slide()` real. Mantener
  `_snap_to_ground()` inicial con `TerrainLocator` (ya correcto).
- Si `is_on_wall()` tras `move_and_slide()`: frenar y elegir destino nuevo (patron gaviota §2,
  simplificado). Esto solo funcionara una vez aplicada la Mejora 1 (hoy sin forma `is_on_wall()`
  siempre es false).
- `_paso_caminando()` debe usar `velocity.x/z` y dejar `velocity.y` al sistema de suelo en vez de
  `Vector3.ZERO` en `_paso_pausa()` (`tortuga_npc.gd:201`, `jabali_npc.gd:197`, `cangrejo_npc.gd:179`).

**Verificacion:** test headless `test_fisica_tunel.gd` con un `StaticBody3D` pared de 1 voxel a `10 m`
del spawn: (a) jugador a velocidad juego `5 m/s` no la cruza en 120 frames; (b) a velocidad DEV
`25 m/s` el subpasado impide cruce; (c) tortuga/jabali/cangrejo colocados frente a pared reportan
`is_on_wall() == true` tras aplicar la mejora (hoy: false por falta de forma). Cobertura A/B antes
despues contra `player.gd` actual.

**Esfuerzo estimado:** medio. 2 renumeros de constantes + fraccionamiento de `motion` + reescritura
de `_seguir_suelo()` en 3 archivos + 1 test de tunel. Cambia el paradigma de rescate a prevencion,
costoso en tests pero no en runtime.

## 6. Conclusion final

- **No hay `RigidBody3D` ni carpeta fisica/colisiones.** Todo es `CharacterBody3D` + `move_and_slide()`
  (o `VoxelBoxMover` + `global_translate()` en el jugador), mas `StaticBody3D`/`Area3D` de soporte.
- **3 NPCs de fauna (tortuga, jabali, cangrejo) no tienen `CollisionShape3D`.**
  Son atajadores por construccion: atraviesan paredes, jugador y terreno. Es el hallazgo principal.
- **El jugador tiene riesgo de tunelizacion** a velocidad DEV `25 m/s` (desplazamiento ~0.42 m/frame,
  casi su ancho) con deteccion de suelo custom y rescate post-caida, sin `floor_snap` ni `safe_margin`.
- **La gaviota es la referencia de calidad** (`MOTION_MODE` por estado, `floor_snap 0.3`,
  esquive por pared, watchdog) y aun asi no define `safe_margin`/CCD.
- **Capas de colision ambiguas:** personajes sin `collision_layer`/`collision_mask` explicitos en
  escena; el bit de terreno (32) solo lo usa el `TerrainDetector` del jugador, no garantiza filtrado
  de personajes.
- Las mejoras 1 (kit de colliders + auditoria de formas) y 2 (antitunelizado con subpasos y suelo
  predictivo) son independientes, ordenables y verificables con tests headless del mismo patron que
  ya usa el proyecto (`test_player_m11.gd`, `test_debug_visualizer_real_m110.gd`).

*Archivos clave para empezar la Mejora 1: `scripts/fauna/tortuga_npc.gd:82-111`,
`scripts/fauna/jabali_npc.gd:85-100`, `scripts/fauna/cangrejo_npc.gd:61-73`,
`scenes/main_island.tscn:174-192`, `scripts/terrenos/terrain_block.gd:11-15`,
`scenes/npc/villager.tscn:5` vs `scripts/npc/villager.gd:105-112`.*
*Archivos clave para la Mejora 2: `scripts/player/player.gd:8,60,370-401`,
`scripts/fauna/tortuga_npc.gd:184-202,278-286` (idem jabali/cangrejo),
`scripts/fauna/gaviota_npc.gd:87,145,413` (patron a copiar).*
