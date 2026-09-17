Seguimos con **navegación interior e interacción con los muebles**.

Vamos a separar dos cosas:

1. **La navegación:** permite que los NPCs crucen la entrada y recorran el interior.
2. **Los puntos de interacción:** permiten identificar una cama, mesa, cocina o silla sin convertir cada mueble en una escena independiente.

**Importante:** las coordenadas del generador indican dónde está el mueble, no dónde debe colocarse el personaje para usarlo. Por eso crearemos dos puntos distintos:

```text
MUEBLE
├── Centro visual
└── Posición de uso      ← Debe quedar en una zona libre y navegable
```

La primera versión permite al jugador interactuar y enviar a un NPC hasta una posición de uso. **Sentarse, acostarse y cocinar todavía necesitan sus animaciones específicas.**

---

# 1. Preparar los informes de las casas

Para las casas 2–5, copia el `INFORME.json` generado por Blender dentro de Godot:

```text
res://casas/datos/
├── casa_02.json
├── casa_03.json
├── casa_04.json
└── casa_05.json
```

Estos archivos ya contienen:

```json
{
  "interacciones": [
    {
      "id": "MESA_0",
      "mesh": "SM_Mesa_Comedor",
      "tipo": "MESA",
      "posicion_godot": [2.0, 0.295, -3.45]
    }
  ]
}
```

## Casa 1: añadir sus cuatro muebles

El informe de la choza anterior no incluía la lista de puntos de interacción. Crea:

```text
res://casas/datos/casa_01.json
```

Con este contenido:

```json
{
  "casa": "CHOZA_AMPLIADA",
  "interacciones": [
    {
      "id": "CAMA",
      "mesh": "SM_Cama",
      "tipo": "CAMA",
      "posicion_godot": [0.80, 0.245, -1.47]
    },
    {
      "id": "MESA",
      "mesh": "SM_Mesa",
      "tipo": "MESA",
      "posicion_godot": [4.35, 0.245, -2.05]
    },
    {
      "id": "SILLA",
      "mesh": "SM_Silla",
      "tipo": "SILLA",
      "posicion_godot": [3.45, 0.245, -2.05]
    },
    {
      "id": "ESTANTERIA",
      "mesh": "SM_Estanteria",
      "tipo": "ESTANTE",
      "posicion_godot": [4.68, 0.245, -1.22]
    }
  ]
}
```

El hogar de esta choza se mantiene **decorativo**, como pediste.

---

# 2. Nodo de interacción de un mueble

Crea:

```text
res://casas/scripts/punto_mueble.gd
```

```gdscript
class_name PuntoMueble
extends Node3D

signal utilizado(punto: PuntoMueble, actor: Node3D)

@export var identificador: StringName
@export var tipo: StringName = &"MUEBLE"
@export var nombre_mesh: StringName

@export var distancia_interaccion: float = 2.0

# Posición respecto al centro del mueble, en ejes locales de la casa.
@export var desplazamiento_uso: Vector3 = Vector3.ZERO

# False mientras no se haya definido una posición libre.
@export var posicion_uso_definida: bool = false

# Punto al que apunta el jugador, elevado respecto al suelo.
@export var altura_objetivo: float = 0.75

var _ocupante: Node3D


func _ready() -> void:
	add_to_group("MUEBLES_INTERACTUABLES")


func obtener_objetivo_visual() -> Vector3:
	return to_global(Vector3(0.0, altura_objetivo, 0.0))


func obtener_posicion_uso() -> Vector3:
	return to_global(desplazamiento_uso)


func esta_disponible_para(actor: Node3D) -> bool:
	return (
		not is_instance_valid(_ocupante)
		or _ocupante == actor
	)


func reservar(actor: Node3D) -> bool:
	if not is_instance_valid(actor):
		return false

	if not esta_disponible_para(actor):
		return false

	_ocupante = actor
	return true


func liberar(actor: Node3D) -> void:
	if _ocupante == actor:
		_ocupante = null


func intentar_usar(actor: Node3D) -> bool:
	if not is_instance_valid(actor):
		return false

	if not esta_disponible_para(actor):
		return false

	if actor.global_position.distance_to(global_position) > distancia_interaccion:
		return false

	utilizado.emit(self, actor)
	return true


func texto_accion() -> String:
	match tipo:
		&"CAMA":
			return "Descansar"
		&"MESA":
			return "Usar mesa"
		&"SILLA":
			return "Sentarse"
		&"SOFA":
			return "Sentarse"
		&"COCINA":
			return "Cocinar"
		&"NEVERA_RUSTICA":
			return "Abrir despensa"
		&"ESTANTE":
			return "Examinar estantería"
		&"COMODA":
			return "Abrir cómoda"
		_:
			return "Examinar"
```

Este nodo **no reproduce todavía animaciones ni abre inventarios**. Emite una señal para que esos sistemas se conecten después.

La reserva permite evitar, por ejemplo, que dos NPCs intenten ocupar la misma silla.

---

# 3. Leer el JSON y crear los puntos

Crea:

```text
res://casas/scripts/interior_casa.gd
```

Este script se coloca en un hijo de `CASA_BASE`, con transformación identidad.

```gdscript
class_name InteriorCasa
extends Node3D

signal mueble_utilizado(
	punto: PuntoMueble,
	actor: Node3D
)

@export_file("*.json")
var archivo_informe: String

# JSON opcional para posiciones de uso ajustadas.
@export_file("*.json")
var archivo_posiciones_uso: String

@export var mostrar_marcadores: bool = false

var puntos: Dictionary = {}


func _ready() -> void:
	_cargar_puntos()


func _leer_json(ruta: String) -> Dictionary:
	if ruta.is_empty():
		return {}

	if not FileAccess.file_exists(ruta):
		push_error("%s: no existe %s" % [name, ruta])
		return {}

	var parser := JSON.new()
	var error := parser.parse(
		FileAccess.get_file_as_string(ruta)
	)

	if error != OK:
		push_error(
			"%s: JSON inválido en línea %d: %s"
			% [
				ruta,
				parser.get_error_line(),
				parser.get_error_message()
			]
		)
		return {}

	if not parser.data is Dictionary:
		push_error("%s: se esperaba un objeto JSON." % ruta)
		return {}

	return parser.data


func _vector_desde_array(valor: Variant) -> Vector3:
	if not valor is Array or valor.size() != 3:
		return Vector3.ZERO

	return Vector3(
		float(valor[0]),
		float(valor[1]),
		float(valor[2])
	)


func _cargar_puntos() -> void:
	var informe := _leer_json(archivo_informe)
	var ajustes := _leer_json(archivo_posiciones_uso)

	var lista: Variant = informe.get("interacciones", [])

	if not lista is Array:
		push_error("%s: 'interacciones' no es una lista." % name)
		return

	for entrada in lista:
		if not entrada is Dictionary:
			continue

		var id := String(entrada.get("id", ""))

		if id.is_empty():
			continue

		if puntos.has(id):
			push_warning(
				"%s: identificador de mueble duplicado: %s"
				% [name, id]
			)
			continue

		var posicion: Variant = entrada.get(
			"posicion_godot",
			null
		)

		if not posicion is Array or posicion.size() != 3:
			push_warning(
				"%s: el mueble %s no tiene posición válida."
				% [name, id]
			)
			continue

		var punto := PuntoMueble.new()
		punto.name = "PUNTO_" + id.validate_node_name()
		punto.identificador = StringName(id)
		punto.tipo = StringName(
			String(entrada.get("tipo", "MUEBLE"))
		)
		punto.nombre_mesh = StringName(
			String(entrada.get("mesh", ""))
		)
		punto.position = _vector_desde_array(posicion)

		var ajuste: Variant = ajustes.get(id, {})

		if ajuste is Dictionary:
			if ajuste.has("offset"):
				punto.desplazamiento_uso = _vector_desde_array(
					ajuste["offset"]
				)
				punto.posicion_uso_definida = true

			punto.altura_objetivo = float(
				ajuste.get("altura_objetivo", 0.75)
			)
			punto.distancia_interaccion = float(
				ajuste.get("distancia_interaccion", 2.0)
			)

		add_child(punto)
		puntos[id] = punto

		punto.utilizado.connect(_on_mueble_utilizado)

		if mostrar_marcadores:
			_crear_marcadores(punto)

	print(
		"%s: %d puntos de interacción cargados."
		% [name, puntos.size()]
	)


func obtener_punto(id: StringName) -> PuntoMueble:
	return puntos.get(String(id)) as PuntoMueble


func _on_mueble_utilizado(
	punto: PuntoMueble,
	actor: Node3D
) -> void:
	mueble_utilizado.emit(punto, actor)

	# Respuesta mínima para comprobar el circuito.
	print(
		"%s utiliza %s (%s)."
		% [actor.name, punto.identificador, punto.tipo]
	)


func _crear_marcadores(punto: PuntoMueble) -> void:
	var objetivo := MeshInstance3D.new()
	objetivo.name = "DEBUG_OBJETIVO"

	var esfera := SphereMesh.new()
	esfera.radius = 0.045
	esfera.height = 0.09
	esfera.radial_segments = 8
	esfera.rings = 4

	objetivo.mesh = esfera
	objetivo.position.y = punto.altura_objetivo

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#D3AD6F")
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	objetivo.material_override = mat

	punto.add_child(objetivo)

	if punto.posicion_uso_definida:
		var uso := MeshInstance3D.new()
		uso.name = "DEBUG_POSICION_USO"

		var cilindro := CylinderMesh.new()
		cilindro.top_radius = 0.14
		cilindro.bottom_radius = 0.14
		cilindro.height = 0.025
		cilindro.radial_segments = 12

		uso.mesh = cilindro
		uso.position = (
			punto.desplazamiento_uso + Vector3(0, 0.025, 0)
		)

		var mat_uso := StandardMaterial3D.new()
		mat_uso.albedo_color = Color("#809D77")
		mat_uso.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		uso.material_override = mat_uso

		punto.add_child(uso)
```

---

# 4. Posiciones de uso de la choza

Crea:

```text
res://casas/datos/casa_01_uso.json
```

```json
{
  "CAMA": {
    "offset": [1.0, 0.0, 0.0],
    "altura_objetivo": 0.58,
    "distancia_interaccion": 2.0
  },
  "MESA": {
    "offset": [-0.8, 0.0, -0.9],
    "altura_objetivo": 0.80,
    "distancia_interaccion": 2.0
  },
  "SILLA": {
    "offset": [-0.65, 0.0, 0.0],
    "altura_objetivo": 0.65,
    "distancia_interaccion": 1.6
  },
  "ESTANTERIA": {
    "offset": [-1.0, 0.0, 0.0],
    "altura_objetivo": 1.40,
    "distancia_interaccion": 2.0
  }
}
```

Son posiciones iniciales basadas en la distribución de la choza:

- **Cama:** aproximación desde el pasillo central.
- **Mesa:** aproximación desde el extremo frontal, evitando colocar al NPC sobre la silla.
- **Silla:** aproximación por detrás.
- **Estantería:** aproximación desde el interior.

**Estos puntos todavía deben comprobarse contra la navegación resultante.** El siguiente script puede hacerlo.

---

# 5. Navegación generada a partir de las colisiones

Como las colisiones de `CasaTransitable` se crean al iniciar, un bake previo en el editor no las incluye automáticamente.

Para la guía utilizaremos un **bake en ejecución, una vez**, después de crear la casa.

### Limitaciones deliberadas

- Es un proceso de preparación, no algo que deba ejecutarse continuamente.
- La versión siguiente procesa `ConcavePolygonShape3D` y `BoxShape3D`, suficientes para las colisiones trimesh de la casa y un suelo de caja.
- El bake es síncrono y puede detener brevemente el juego.
- No debe superponerse sin control con otra región de navegación ya horneada en el mismo espacio.

Crea:

```text
res://casas/scripts/navegacion_casa.gd
```

```gdscript
class_name NavegacionCasa
extends NavigationRegion3D

signal navegacion_preparada

@export var casa: CasaTransitable

# Nodo que contiene la casa Y el suelo exterior cercano.
@export var origen_colisiones: Node3D

@export var interior: InteriorCasa

@export_category("Agente")
@export var radio_agente: float = 0.26
@export var altura_agente: float = 1.90
@export var escalon_maximo: float = 0.20
@export var pendiente_maxima: float = 40.0

@export_category("Bake")
@export var generar_al_iniciar: bool = true
@export var margen_exterior: float = 2.5

# Limita el bake a la planta baja.
# Se mide desde el piso terminado.
@export var altura_volumen_bake: float = 2.45

var preparada: bool = false


func _ready() -> void:
	if generar_al_iniciar:
		call_deferred("_preparar_diferido")


func _preparar_diferido() -> void:
	# Esperar a que CasaTransitable cree sus cuerpos estáticos.
	await get_tree().physics_frame
	await get_tree().physics_frame

	generar()


func generar() -> void:
	if casa == null or origen_colisiones == null:
		push_error(
			"%s: asigna casa y origen_colisiones." % name
		)
		return

	preparada = false

	# La región debe compartir origen y orientación con la casa.
	global_transform = casa.global_transform

	var nav := NavigationMesh.new()
	nav.cell_size = 0.10
	nav.cell_height = 0.05

	nav.agent_radius = radio_agente
	nav.agent_height = altura_agente
	nav.agent_max_climb = escalon_maximo
	nav.agent_max_slope = pendiente_maxima

	nav.region_min_size = 0.4
	nav.region_merge_size = 1.0

	nav.filter_low_hanging_obstacles = true
	nav.filter_ledge_spans = true
	nav.filter_walkable_low_height_spans = true

	var y_min := minf(
		casa.terreno_entrada_y,
		casa.piso_terminado_y
	) - 0.50

	var y_max := casa.piso_terminado_y + altura_volumen_bake

	nav.filter_baking_aabb = AABB(
		Vector3(
			-margen_exterior,
			y_min,
			-casa.ancho_y_blender - margen_exterior
		),
		Vector3(
			casa.largo_x + margen_exterior * 2.0,
			y_max - y_min,
			casa.ancho_y_blender + margen_exterior * 2.0
		)
	)

	var source := NavigationMeshSourceGeometryData3D.new()
	_recoger_colisiones(origen_colisiones, source)

	if not source.has_data():
		push_error("%s: no se encontró geometría para el bake." % name)
		return

	NavigationServer3D.bake_from_source_geometry_data(
		nav,
		source
	)

	if nav.get_polygon_count() == 0:
		push_error(
			"%s: el bake no produjo polígonos navegables." % name
		)
		return

	navigation_mesh = nav

	# Esperar sincronización de la región con el servidor.
	await get_tree().physics_frame
	await get_tree().physics_frame

	preparada = true
	navegacion_preparada.emit()

	print(
		"%s: navegación creada, %d polígonos."
		% [name, nav.get_polygon_count()]
	)

	if interior != null:
		_comprobar_puntos_uso()


func _recoger_colisiones(
	node: Node,
	source: NavigationMeshSourceGeometryData3D
) -> void:
	if node is CollisionShape3D:
		var collision := node as CollisionShape3D

		if (
			not collision.disabled
			and collision.shape != null
			and collision.get_parent() is StaticBody3D
		):
			var local_transform := (
				global_transform.affine_inverse()
				* collision.global_transform
			)

			if collision.shape is ConcavePolygonShape3D:
				var concave := collision.shape as ConcavePolygonShape3D
				source.add_faces(
					concave.get_faces(),
					local_transform
				)

			elif collision.shape is BoxShape3D:
				var box_shape := collision.shape as BoxShape3D
				var box_mesh := BoxMesh.new()
				box_mesh.size = box_shape.size

				source.add_mesh(
					box_mesh,
					local_transform
				)

			else:
				push_warning(
					"%s: shape omitida del bake: %s"
					% [name, collision.shape.get_class()]
				)

	for child in node.get_children():
		_recoger_colisiones(child, source)


func _comprobar_puntos_uso() -> void:
	var map_rid := get_navigation_map()

	for value in interior.puntos.values():
		var punto := value as PuntoMueble

		if not punto.posicion_uso_definida:
			continue

		var objetivo := punto.obtener_posicion_uso()
		var cercano := NavigationServer3D.map_get_closest_point(
			map_rid,
			objetivo
		)

		var error := objetivo.distance_to(cercano)

		if error > 0.25:
			push_warning(
				"%s: posición de uso de %s fuera de navegación "
				% [name, punto.identificador]
				+ "(distancia %.2f m)." % error
			)
```

### Qué hace el límite de altura

El volumen de bake se concentra en la planta baja para **no convertir los tejados en zonas de deambulación**.

No obstante, debes inspeccionar el resultado: una superficie alta, una estantería o una escalera pueden producir pequeñas zonas navegables inesperadas. El filtrado no sustituye esa revisión.

**Para la torre de la mansión utilizaremos una región aparte**, después de corregir la escalera y sus alturas libres.

---

# 6. Escena de prueba completa

Organiza:

```text
TEST_CASA
├── SUELO_EXTERIOR          ← StaticBody3D + BoxShape3D
├── CASA_BASE
│   ├── Interior           ← InteriorCasa
│   └── Navegacion         ← NavegacionCasa
├── PLAYER
└── NPC_LUNA
```

### `Interior`

Asigna:

```text
Archivo Informe:
    res://casas/datos/casa_01.json

Archivo Posiciones Uso:
    res://casas/datos/casa_01_uso.json

Mostrar Marcadores:
    true
```

### `Navegacion`

Asigna:

```text
Casa:
    CASA_BASE

Origen Colisiones:
    TEST_CASA

Interior:
    CASA_BASE/Interior
```

Para esta prueba, **desactiva cualquier otra región que cubra la misma casa y el mismo suelo**.

Activa:

```text
Debug → Visible Navigation
```

Debes ver una superficie navegable continua:

```text
Suelo exterior → rampa → puerta → pasillo interior
```

Si la puerta no conecta:

- Comprueba que la rampa realmente llega al piso.
- Verifica que el suelo exterior tiene colisión.
- Reduce el radio del agente solo si corresponde a su tamaño real.
- Comprueba que el marco no estrecha accidentalmente el hueco.
- No subas `agent_max_climb` para ocultar un desnivel mal construido.

---

# 7. Interacción del jugador con los muebles

Para no interferir con la tecla **E** que ya usamos para hablar con NPCs, durante la prueba crea una acción:

```text
usar_mueble
```

Asígnale **F**.

Crea:

```text
res://casas/scripts/interactor_muebles.gd
```

```gdscript
extends Node

@export var actor: Node3D
@export var camera: Camera3D

@export var distancia_maxima: float = 2.5
@export var angulo_maximo: float = 25.0

# Entorno y muebles estáticos.
@export_flags_3d_physics var mascara_obstaculos: int = 1

var _seleccionado: PuntoMueble

var _canvas: CanvasLayer
var _label: Label


func _ready() -> void:
	_canvas = CanvasLayer.new()
	add_child(_canvas)

	_label = Label.new()
	_label.position = Vector2(24, 24)
	_label.add_theme_font_size_override("font_size", 22)
	_canvas.add_child(_label)


func _physics_process(_delta: float) -> void:
	_seleccionado = _buscar_mueble()

	if _seleccionado != null:
		_label.text = "[F] " + _seleccionado.texto_accion()
	else:
		_label.text = ""


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("usar_mueble"):
		return

	if is_instance_valid(_seleccionado):
		_seleccionado.intentar_usar(actor)

	get_viewport().set_input_as_handled()


func _buscar_mueble() -> PuntoMueble:
	if not is_instance_valid(actor) or not is_instance_valid(camera):
		return null

	var forward := -camera.global_basis.z
	var cos_limit := cos(deg_to_rad(angulo_maximo))

	var mejor: PuntoMueble
	var mejor_puntuacion := -INF

	for node in get_tree().get_nodes_in_group("MUEBLES_INTERACTUABLES"):
		var punto := node as PuntoMueble

		if punto == null or not punto.esta_disponible_para(actor):
			continue

		if actor.global_position.distance_to(
			punto.global_position
		) > distancia_maxima:
			continue

		var objetivo := punto.obtener_objetivo_visual()
		var direccion := objetivo - camera.global_position

		if direccion.length_squared() < 0.001:
			continue

		var alineacion := forward.dot(direccion.normalized())

		if alineacion < cos_limit:
			continue

		if not _objetivo_visible(punto, objetivo):
			continue

		var puntuacion := (
			alineacion * 4.0
			- actor.global_position.distance_to(punto.global_position)
		)

		if puntuacion > mejor_puntuacion:
			mejor_puntuacion = puntuacion
			mejor = punto

	return mejor


func _objetivo_visible(
	punto: PuntoMueble,
	objetivo: Vector3
) -> bool:
	var query := PhysicsRayQueryParameters3D.create(
		camera.global_position,
		objetivo
	)
	query.collision_mask = mascara_obstaculos
	query.collide_with_areas = false

	if actor is CollisionObject3D:
		query.exclude = [(actor as CollisionObject3D).get_rid()]

	var hit := actor.get_world_3d().direct_space_state.intersect_ray(query)

	if hit.is_empty():
		return true

	var collider := hit["collider"] as Node

	if collider == null:
		return false

	# Los colliders del paso anterior se llaman COL_<nombre mesh>.
	if collider.name == "COL_" + String(punto.nombre_mesh):
		return true

	# Tolerancia pequeña para un objetivo situado sobre una superficie.
	var hit_position: Vector3 = hit["position"]
	return hit_position.distance_to(objetivo) < 0.08
```

### Limitación de los conjuntos

En algunas casas una mesa y sus sillas comparten mesh. El raycast puede confirmar que estamos mirando ese **conjunto**, pero no identifica cada silla por triángulo.

Los puntos individuales permiten distinguirlas por dirección y distancia. Si después necesitas selección exacta, añadiremos pequeñas áreas de interacción por mueble.

---

# 8. Enviar un NPC a una posición de uso

El controlador `CozyNPC` ya tiene `ir_a()`. Podemos aprovecharlo sin modificar su máquina de estados.

Crea:

```text
res://casas/scripts/prueba_npc_mueble.gd
```

Este script sirve para probar un recorrido concreto.

```gdscript
extends Node

@export var npc: CozyNPC
@export var interior: InteriorCasa
@export var navegacion: NavegacionCasa

@export var mueble_destino: StringName = &"CAMA"
@export var tiempo_maximo: float = 30.0

var _destino: PuntoMueble
var _espera_anterior: bool = true
var _activo: bool = false

var _timer: Timer


func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = true
	add_child(_timer)
	_timer.timeout.connect(_cancelar)

	if navegacion != null:
		navegacion.navegacion_preparada.connect(_iniciar)


func _iniciar() -> void:
	if npc == null or interior == null:
		return

	_destino = interior.obtener_punto(mueble_destino)

	if _destino == null:
		push_warning("No existe el mueble de destino.")
		return

	if not _destino.posicion_uso_definida:
		push_warning("El mueble no tiene posición de uso definida.")
		return

	if not _destino.reservar(npc):
		return

	_espera_anterior = npc.wander_enabled
	npc.wander_enabled = false

	# Reiniciar una posible ruta de deambulación previa.
	npc.state = CozyNPC.State.IDLE

	if not npc.ir_a(_destino.obtener_posicion_uso()):
		_cancelar()
		return

	_activo = true
	_timer.start(tiempo_maximo)


func _physics_process(_delta: float) -> void:
	if not _activo:
		return

	if not is_instance_valid(npc) or not is_instance_valid(_destino):
		_cancelar()
		return

	var distancia := npc.global_position.distance_to(
		_destino.obtener_posicion_uso()
	)

	if distancia > 0.38:
		return

	_activo = false
	_timer.stop()

	npc.state = CozyNPC.State.IDLE
	npc.velocity.x = 0.0
	npc.velocity.z = 0.0

	var usado := _destino.intentar_usar(npc)

	print(
		"NPC llegó a %s. Interacción: %s"
		% [_destino.identificador, usado]
	)

	# Solo prueba de llegada: libera el mueble y devuelve
	# el comportamiento anterior. No simula dormir/sentarse.
	_destino.liberar(npc)
	npc.wander_enabled = _espera_anterior


func _cancelar() -> void:
	_activo = false

	if is_instance_valid(_timer):
		_timer.stop()

	if is_instance_valid(npc):
		npc.state = CozyNPC.State.IDLE
		npc.velocity.x = 0.0
		npc.velocity.z = 0.0
		npc.wander_enabled = _espera_anterior

	if is_instance_valid(_destino) and is_instance_valid(npc):
		_destino.liberar(npc)
```

Este script **no teletransporta al NPC ni lo mete dentro de la cama**. Comprueba que puede:

```text
Estar fuera → cruzar la rampa → entrar → llegar al lado del mueble
```

Si no llega dentro del tiempo máximo, cancela y libera la reserva.

---

# 9. Orden de prueba

Hazlo primero con la choza:

### Prueba 1 — Jugador

- Entrar por la rampa.
- Confirmar que se oculta el techo.
- Apuntar a la cama.
- Pulsar F.
- Ver el mensaje de interacción en la consola.

### Prueba 2 — Navegación

- Activar navegación visible.
- Confirmar que existe una ruta continua hasta el pasillo.
- Revisar advertencias de posiciones de uso.

### Prueba 3 — NPC

- Colocar a Luna fuera.
- Ejecutar `prueba_npc_mueble.gd`.
- Confirmar que entra y llega junto a la cama sin atravesar muebles.

### Prueba 4 — Otras casas

- Copiar su `INFORME.json`.
- Crear sus archivos de posiciones de uso.
- Ajustar los puntos mirando los marcadores.
- Repetir el recorrido.

---

## Qué queda resuelto con esta etapa

- Lectura de muebles desde los informes.
- Puntos de interacción independientes del mesh.
- Posiciones de aproximación configurables.
- Reserva básica para NPCs.
- Interacción del jugador sin atravesar paredes.
- Bake inicial de navegación a partir de las colisiones.
- Prueba de recorrido NPC → mueble.

## Lo siguiente

Una vez que podamos recorrer las casas, pasamos a **acciones reales**:

1. **Silla:** posición final y animación de sentarse.
2. **Cama:** descansar, avanzar tiempo o recuperar energía.
3. **Estantería/cómoda:** inventario.
4. **Cocina/mesa:** interfaz de elaboración.
5. **Puertas:** hojas abatibles, apertura y actualización del paso.

Para mantener el progreso ordenado, empezaría por **puertas y silla**, porque son los dos elementos que más afectan a circulación, colisiones y postura del personaje.