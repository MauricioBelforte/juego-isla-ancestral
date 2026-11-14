# Reporte de auditoria de sistemas de fisicas y colisiones
# Proyecto: Isla Ancestral (Godot 4.7)

**Modelo:** Glyph Cluster (modelo de arquitectura de sistemas Godot)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-13
**Alcance:** scripts/ de game/isla-ancestral/ — físicas (RigidBody3D, CharacterBody3D, Area3D, StaticBody3D, CollisionShape, capas/mascaras, raycasts, move_and_slide) y acoplamiento fisica<->gameplay.
**Regla aplicada:** no se escribio codigo del juego; solo supervision y validacion estatica de dependencias y configuracion de fisicas.

---

## Resumen ejecutivo

Se revisaron todos los archivos .gd de scripts/ con referencias a nodos de fisica y colision (RigidBody3D, CharacterBody3D, Area3D, StaticBody3D, CollisionShape3D, collision_layer, collision_mask, move_and_slide, raycasts, _physics_process).

**Resultado clave: se detectaron varios problemas de configuracion de colision y acoplamiento fuerte entre logica de fisicas y gameplay.** No se encontro uso de RigidBody3D ni StaticBody3D en scripts de produccion (salvo en debug_visualizer.gd como herramienta de editor). El cuerpo principal del jugador y los NPCs usan CharacterBody3D.

Los hallazgos mas relevantes son:
1. crafting_station.gd:119-120 — Area3D con collision_layer=0 y collision_mask=0 (invisible al broadphase de fisica).
2. ia_npc/npc_agent.gd — CharacterBody3D sin CollisionShape3D asignado en script (cuerpo sin shape).
3. foto/navigator.gd:83 — mascara de colision hardcodeada a 1 (terreno) sin constante/InputMap.
4. ia_npc/states/movement_state.gd:33 y social_state.gd:32 — estados de IA llaman directamente a move_and_slide() (acoplamiento gameplay<->fisica).
5. camera_spring.gd — codigo muerto (deprecated), sin impacto en runtime.

Se detallan a continuación con archivo:linea, severidad y accionable.

---

## Metodo de revision

1. Busqueda por regex en scripts/ de: RigidBody3D, CharacterBody3D, Area3D, StaticBody3D, CollisionShape, collision_layer, collision_mask, set_physics_process, _physics_process, move_and_slide, move_and_collide, get_slide_collision, is_colliding.
2. Lectura completa de los archivos de produccion mas relevantes (main.gd, crafting_station.gd, npc_agent.gd, camera_spring.gd, navigator.gd, movement_state.gd, social_state.gd, shaman_npc.gd).
3. Verificacion de presencia/ausencia de CollisionShape3D en CharacterBody3D y Area3D.
4. Verificacion de hardcodeo de capas/mascaras de colision.
5. Analisis de acoplamiento entre estados de IA y llamadas directas a fisica.

Archivos con referencias a fisica encontrados (seleccion de produccion):
- scripts/main.gd — player CharacterBody3D (sin shape definido en script)
- scripts/crafting/crafting_station.gd — Area3D de interaccion (capa/mascara 0)
- scripts/ia_npc/npc_agent.gd — CharacterBody3D principal de NPCs
- scripts/ia_npc/states/movement_state.gd — move_and_slide() desde estado de IA
- scripts/ia_npc/states/social_state.gd — move_and_slide() desde estado de IA
- scripts/camera/camera_spring.gd — RayCast3D (deprecated/codigo muerto)
- scripts/foto/navigator.gd — PhysicsRayQueryParameters3D con collision_mask hardcodeado
- scripts/fauna/tortuga_npc.gd, gaviota_npc.gd, jabali_npc.gd, cangrejo_npc.gd — CharacterBody3D con move_and_slide
- scripts/debug/debug_visualizer.gd — herramienta de editor (colliders/hitboxes, sin impacto runtime)

---

## Hallazgos

### F-01 — Area3D de interaccion con collision_layer y collision_mask en 0
**archivo:linea:** scripts/crafting/crafting_station.gd:119, scripts/crafting/crafting_station.gd:120
**Severidad:** Medio
**Accionable:** Si
**Descripcion:** El Area3D de interaccion de la estacion de crafting se configura con `collision_layer = 0` y `collision_mask = 0`, ademas de `monitoring = false` y `monitorable = false`. En Godot, un Area3D con capa y mascara en 0 no participa en el broadphase de fisica y nunca generara eventos de area_entered/area_exited ni sera detectable por raycasts. El comentario del script justifica esto como intencional ("cero trabajo por physics step por estación"), pero si la estacion pretende ser un area de interaccion detectable (por ejemplo por el sistema de interaccion M11 o por raycast del jugador), queda inaccesible a la fisica. La interaccion actual se resuelve por distancia en `_unhandled_input` (linea 51-65), por lo que el Area3D es puramente decorativo hoy, pero su configuracion en 0 es un riesgo si algun sistema posterior intenta consultarlo por fisica.
**Evidencia:** crafting_station.gd:117 `_area.monitoring = false`, :118 `_area.monitorable = false`, :119 `_area.collision_layer = 0`, :120 `_area.collision_mask = 0`.

### F-02 — CharacterBody3D de NPC sin CollisionShape3D asignado en script
**archivo:linea:** scripts/ia_npc/npc_agent.gd:9, scripts/ia_npc/npc_agent.gd:51-60
**Severidad:** Alto
**Accionable:** Si
**Descripcion:** `NPCAgent` extiende `CharacterBody3D` (linea 9) pero en `_ready()` y en el resto del script no se instancia ni asigna ningún `CollisionShape3D` al cuerpo. Un CharacterBody3D sin shape no colisiona con nada: `move_and_slide()` (llamado en movement_state.gd:33 y social_state.gd:32) no generara respuestas de colision reales, y el NPC atravesara geometria. Esto rompe el proposito fisico de un CharacterBody3D y puede causar que los NPCs traspasen paredes/terreno. Falta crear un CollisionShape3D (caja o capsula) como hijo del nodo y asignarle un Shape3D.
**Evidencia:** npc_agent.gd:9 `extends CharacterBody3D`; ninguna instancia de CollisionShape3D en el archivo. Los estados llaman a `controller.move_and_slide()` (movement_state.gd:33, social_state.gd:32) sin shape que colisione.

### F-03 — Mascara de colision hardcodeada a 1 (terreno) en raycast de camara de foto
**archivo:linea:** scripts/foto/navigator.gd:83
**Severidad:** Medio
**Accionable:** Si
**Descripcion:** En `navigator.gd` (camara de modo foto) el raycast de colision suave se configura con `query.collision_mask = 1  # terreno`. La mascara `1` esta hardcodeada como literal numerico, sin constante con nombre ni referencia al InputMap/project.godot. Si las capas de colision del proyecto cambian (por ejemplo, el terreno se mueve a otra capa), este raycast dejara de detectar el terreno o detectara capas incorrectas, permitiendo que la camara de foto atraviese geometria. Es acoplamiento a un identificador numerico magico de capa de fisica.
**Evidencia:** navigator.gd:82 `var query := PhysicsRayQueryParameters3D.create(origen, destino)`, :83 `query.collision_mask = 1  # terreno`.

### F-04 — Acoplamiento fuerte entre estados de IA y fisica directa (move_and_slide)
**archivo:linea:** scripts/ia_npc/states/movement_state.gd:33, scripts/ia_npc/states/social_state.gd:32
**Severidad:** Medio
**Accionable:** Si
**Descripcion:** Los estados de IA (`MovementState`, `SocialState`) llaman directamente a `controller.move_and_slide()` (metodo de fisica de CharacterBody3D) para mover al NPC. Esto acopla la logica de gameplay (maquina de estados de comportamiento) directamente a la API de fisica del motor. Cualquier cambio en el sistema de movimiento (por ejemplo, sustituir move_and_slide por move_and_collide, o añadir gravedad, friccion o desplazamiento por animacion) requiere editar todos los estados de IA. Es una violacion del principio de separacion entre logica de gameplay y capa de fisica: el estado debería pedir un "mover a destino" al controller y el controller encapsular la llamada a fisica.
**Evidencia:** movement_state.gd:33 `controller.move_and_slide()`; social_state.gd:32 `controller.move_and_slide()`. Ambos reciben `controller` (NPCAgent, que es CharacterBody3D) y llaman directamente a su metodo de fisica.

### F-05 — camera_spring.gd es codigo muerto (deprecated), sin impacto en runtime
**archivo:linea:** scripts/camera/camera_spring.gd:1-2, scripts/camera/camera_spring.gd:5-147
**Severidad:** Ruido
**Accionable:** No
**Descripcion:** `camera_spring.gd` declara `class_name CameraSpring` con RayCast3D y `_physics_process` para colision de camara contra bloques, pero el encabezado (lineas 1-5) indica que es CODIGO MUERTO desde 2026-09-18: "Solo era usado por camera_rig.gd (también deprecated). La colisión de cámara está integrada en follow_camera.gd via voxel raycast." No hay instanciacion ni referencia a CameraSpring en scripts de produccion. No impacta el runtime, pero ocupa espacio y puede confundir.
**Evidencia:** camera_spring.gd:1-5 (comentario de deprecated), :53 `@onready var _raycast: RayCast3D = $RayCast3D`, :68 `func _physics_process(delta: float)`.

### F-06 — Player CharacterBody3D sin configuracion de capas/mascara visible en script
**archivo:linea:** scripts/main.gd:9
**Severidad:** Bajo
**Accionable:** Si
**Descripcion:** `main.gd:9` declara `@onready var player: CharacterBody3D = $Player`, pero el script no configura `collision_layer` ni `collision_mask` del player, ni se ve un CollisionShape3D asignado en el script. La configuracion fisica del player depende enteramente de la escena .tscn (no revisada en esta auditoria de scripts). Si la escena no tiene shape/capras correctas, el player no colisionara. Se cita como bajo porque la configuracion puede residir en el .tscn, pero falta constancia en codigo.
**Evidencia:** main.gd:9 `@onready var player: CharacterBody3D = $Player`.

---

## Analisis de acoplamiento fisica <-> gameplay

- **Bien desacoplado:** `crafting_station.gd` resuelve la interaccion por distancia en `_unhandled_input` (no por eventos de Area3D), lo que evita depender del broadphase de fisica para la interaccion RF1.
- **Bien desacoplado:** `navigator.gd` usa `PhysicsRayQueryParameters3D` (API directa de espacio de fisica) en lugar de nodos Area/RayCast, lo cual es apropiado para una camara de foto.
- **Mal desacoplado:** `movement_state.gd` y `social_state.gd` llaman directamente a `controller.move_and_slide()` (F-04), mezclando logica de comportamiento con llamada a fisica.
- **Riesgo de shape faltante:** `npc_agent.gd` es CharacterBody3D sin CollisionShape3D (F-02), lo cual invalida cualquier llamada a `move_and_slide` desde los estados.

---

## Conclusiones

1. **No hay uso de RigidBody3D ni StaticBody3D en scripts de produccion** (solo en debug_visualizer.gd como herramienta de editor). Los cuerpos dinamicos son CharacterBody3D (player y NPCs) y las areas son Area3D (estaciones de crafting).
2. **El problema mas grave es F-02:** NPCs son CharacterBody3D sin CollisionShape3D, por lo que `move_and_slide` no produce colisiones reales.
3. **F-03 y F-04 son acoplamientos arquitectonicos** que dificultan el mantenimiento y el cambio del sistema de fisica.
4. **camera_spring.gd (F-05) es codigo muerto** y no afecta el runtime.

---

## Mejoras concretas (recomendaciones)

1. **Agregar un CollisionShape3D a NPCAgent y configurar capas/mascara.** En `npc_agent.gd`, instanciar un `CollisionShape3D` con un `CapsuleShape3D` (o `BoxShape3D`) como hijo del nodo en `_ready()`, y definir `collision_layer` y `collision_mask` segun las capas del proyecto (NPC vs terreno, jugador, etc.). Esto hace que `move_and_slide()` produzca colisiones reales y evite que los NPCs atravesen geometria.

2. **Encapsular la llamada a fisica en el controller y eliminar move_and_slide de los estados de IA.** En lugar de que `movement_state.gd:33` y `social_state.gd:32` llamen directamente a `controller.move_and_slide()`, agregar un metodo `controller.move_towards(position, speed)` (o similar) en `npc_agent.gd` que encapsule `move_and_slide`, la gravedad y el snapped-al-suelo. Los estados de IA solo piden movimiento al controller. Esto desacopla la logica de gameplay de la API de fisica (resuelve F-04) y centraliza el comportamiento de movimiento en un solo punto.

---

**Fin del reporte.**
