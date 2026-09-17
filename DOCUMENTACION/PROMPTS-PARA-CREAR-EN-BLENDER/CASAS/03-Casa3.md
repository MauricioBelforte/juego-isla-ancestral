Seguimos con la **integración arquitectónica en Godot**:

1. **Colisiones que respetan puertas y ventanas.**
2. **Entrada transitable mediante una rampa de piedra opcional.**
3. **Ocultación de la cubierta cuando el jugador entra.**
4. Una escena reutilizable para las cinco casas.

Trabajaremos primero con **ALTA**, para comprobar los interiores. Los LOD exteriores se conectarán después sin cambiar las colisiones.

> No necesitas modificar los GLB. Este sistema crea los componentes de juego alrededor del modelo importado.

---

# 1. Organización en Godot

Crea esta estructura:

```text
res://casas/
├── modelos/
│   ├── SM_CASA_01_CHOZA_ALTA.glb
│   ├── SM_CASA_02_CASA_MEDIANA_ALTA.glb
│   └── ...
├── scripts/
│   └── casa_transitable.gd
└── escenas/
    └── CASA_BASE.tscn
```

La escena resultante tendrá:

```text
CASA_BASE
├── VISUAL_ALTA             ← GLB completo
├── COLISIONES              ← Geometría física estática
├── DETECTOR_INTERIOR       ← Area3D
└── RAMPA_ENTRADA           ← Opcional, visible y con colisión
```

### Decisión importante sobre las colisiones

**No usaremos una caja única ni un casco convexo para la casa.** Cualquiera de esas soluciones podría tapar las puertas.

Crearemos colisiones **trimesh estáticas** a partir de los meshes ALTA:

- Respetan las aberturas modeladas.
- Sirven para paredes, suelo y muebles inmóviles.
- No se recalculan al ocultar el techo.
- No dependen de los LOD visuales.

Las cortinas y superficies translúcidas se excluyen para que no actúen como paredes invisibles.

---

# 2. Script `casa_transitable.gd`

Guárdalo en:

```text
res://casas/scripts/casa_transitable.gd
```

```gdscript
class_name CasaTransitable
extends Node3D

signal jugador_entro(casa: CasaTransitable)
signal jugador_salio(casa: CasaTransitable)

@export_category("Modelo")
@export var escena_alta: PackedScene
@export var identificador: StringName = &"CASA_01"

@export_category("Dimensiones arquitectónicas")
# Metros, sin incluir aleros, terraza o pórtico.
@export var largo_x: float = 5.0
@export var ancho_y_blender: float = 4.0

# En Godot el eje vertical es Y.
@export var piso_terminado_y: float = 0.245
@export var altura_interior: float = 2.60

@export_category("Puerta")
@export var puerta_centro_x: float = 2.50
@export var puerta_ancho: float = 1.00

@export_category("Física")
# Capa 1: entorno estático.
@export_flags_3d_physics var capa_colision_casa: int = 1

# Ajustar a la capa física real de tu jugador.
@export_flags_3d_physics var mascara_detector_jugador: int = 1

@export var grupo_jugador: StringName = &"JUGADOR"

# Si el GLB ya contiene colisiones, el script no debe duplicarlas.
@export var generar_colisiones: bool = true

@export_category("Cubierta")
@export var ocultar_cubierta_al_entrar: bool = true

# Dejar False permite caminar sobre la cubierta.
# True: no genera colisión en esos meshes.
@export var excluir_colision_cubierta: bool = false

# Fragmentos de nombre, comparados en mayúsculas.
@export var nombres_cubierta: PackedStringArray = PackedStringArray([
	"SM_TECHO",
	"SM_CUMBRERA",
	"SM_TORRE_TECHO",
])

# Estos elementos quedan fuera del sistema automático.
@export var excluir_meshes_colision: PackedStringArray = PackedStringArray([])

@export_category("Rampa de entrada")
@export var crear_rampa: bool = true
@export var rampa_ancho: float = 1.12
@export var rampa_longitud: float = 1.30

# Altura del terreno donde comienza la rampa, relativa a la casa.
@export var terreno_entrada_y: float = 0.0

@export_category("Diagnóstico")
@export var imprimir_resumen: bool = true

var _visual: Node3D
var _grupo_colisiones: Node3D
var _detector: Area3D

var _cubierta: Array[GeometryInstance3D] = []
var _jugadores_dentro: Array[Node3D] = []

var _materiales_omitidos: Dictionary = {}
var _cuerpos_creados: int = 0


func _ready() -> void:
	if escena_alta == null:
		push_error("%s: falta asignar el GLB ALTA." % name)
		return

	if largo_x <= 0.0 or ancho_y_blender <= 0.0:
		push_error("%s: dimensiones inválidas." % name)
		return

	var instancia := escena_alta.instantiate()

	if not instancia is Node3D:
		instancia.free()
		push_error("%s: la raíz del modelo no es Node3D." % name)
		return

	_visual = instancia as Node3D
	_visual.name = "VISUAL_ALTA"
	add_child(_visual)

	# No corregimos escala u orientación del archivo automáticamente.
	# Debe conservar las medidas exportadas.
	_grupo_colisiones = Node3D.new()
	_grupo_colisiones.name = "COLISIONES"
	add_child(_grupo_colisiones)

	var meshes: Array[MeshInstance3D] = []
	_recoger_meshes(_visual, meshes)

	for mesh_instance in meshes:
		if _es_cubierta(mesh_instance.name):
			_cubierta.append(mesh_instance)

	var colisiones_importadas := _contar_colisiones(_visual)

	if generar_colisiones:
		if colisiones_importadas > 0:
			push_warning(
				"%s: el GLB ya contiene colisiones. "
				% name
				+ "Se omite la generación automática para no duplicarlas."
			)
		else:
			for mesh_instance in meshes:
				_crear_colision_mesh(mesh_instance)

	_crear_detector_interior()

	if crear_rampa:
		_crear_rampa_entrada()

	if imprimir_resumen:
		print(
			"%s — meshes: %d | cuerpos estáticos nuevos: %d | "
			% [identificador, meshes.size(), _cuerpos_creados]
			+ "meshes de cubierta: %d" % _cubierta.size()
		)

		if not _materiales_omitidos.is_empty():
			print(
				"Superficies excluidas de colisión: ",
				_materiales_omitidos.keys()
			)


func _recoger_meshes(
	node: Node,
	resultado: Array[MeshInstance3D]
) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh != null:
			resultado.append(mesh_instance)

	for child in node.get_children():
		_recoger_meshes(child, resultado)


func _contar_colisiones(node: Node) -> int:
	var cantidad := 0

	if node is CollisionShape3D:
		var shape_node := node as CollisionShape3D
		if shape_node.shape != null:
			cantidad += 1

	for child in node.get_children():
		cantidad += _contar_colisiones(child)

	return cantidad


func _es_cubierta(nombre_mesh: String) -> bool:
	var upper := nombre_mesh.to_upper()

	for fragmento in nombres_cubierta:
		if upper.contains(fragmento.to_upper()):
			return true

	return false


func _mesh_excluido(nombre_mesh: String) -> bool:
	var upper := nombre_mesh.to_upper()

	for fragmento in excluir_meshes_colision:
		if upper.contains(fragmento.to_upper()):
			return true

	return false


func _omitir_material(mat: Material) -> bool:
	if mat == null:
		return false

	var nombre_material := mat.resource_name.to_upper()

	# Nombres del generador de casas.
	if (
		nombre_material.contains("CORTINA")
		or nombre_material.contains("TRANSLUCIDO")
		or nombre_material.contains("TRANSLUCENT")
	):
		return true

	if mat is BaseMaterial3D:
		var material_3d := mat as BaseMaterial3D

		if (
			material_3d.transparency
			!= BaseMaterial3D.TRANSPARENCY_DISABLED
			and material_3d.albedo_color.a < 0.99
		):
			return true

	return false


func _crear_colision_mesh(instancia: MeshInstance3D) -> void:
	if _mesh_excluido(instancia.name):
		return

	if excluir_colision_cubierta and _es_cubierta(instancia.name):
		return

	var fuente := instancia.mesh
	var filtrada := ArrayMesh.new()

	for surface_index in range(fuente.get_surface_count()):
		if (
			fuente.surface_get_primitive_type(surface_index)
			!= Mesh.PRIMITIVE_TRIANGLES
		):
			continue

		var mat := instancia.get_active_material(surface_index)

		if _omitir_material(mat):
			if mat != null:
				_materiales_omitidos[mat.resource_name] = true
			continue

		var arrays := fuente.surface_get_arrays(surface_index)

		if arrays.is_empty():
			continue

		filtrada.add_surface_from_arrays(
			Mesh.PRIMITIVE_TRIANGLES,
			arrays
		)

	if filtrada.get_surface_count() == 0:
		return

	var shape := filtrada.create_trimesh_shape()

	if shape == null:
		push_warning(
			"%s: no se pudo crear colisión para %s."
			% [name, instancia.name]
		)
		return

	# Una casa estática puede necesitar colisión por ambos lados
	# en telas estructurales, cubiertas o plataformas abiertas.
	shape.backface_collision = true

	var body := StaticBody3D.new()
	body.name = "COL_" + instancia.name
	body.collision_layer = capa_colision_casa
	body.collision_mask = 0

	_grupo_colisiones.add_child(body)

	# La shape utiliza coordenadas locales del mesh.
	# El StaticBody recibe su transformación mundial.
	body.global_transform = instancia.global_transform

	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	collision.shape = shape
	body.add_child(collision)

	_cuerpos_creados += 1


func _crear_detector_interior() -> void:
	_detector = Area3D.new()
	_detector.name = "DETECTOR_INTERIOR"
	_detector.collision_layer = 0
	_detector.collision_mask = mascara_detector_jugador
	_detector.monitoring = true
	_detector.monitorable = false
	add_child(_detector)

	var margen := 0.18

	var shape := BoxShape3D.new()
	shape.size = Vector3(
		maxf(0.20, largo_x - margen * 2.0),
		altura_interior + 0.15,
		maxf(0.20, ancho_y_blender - margen * 2.0)
	)

	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	collision.shape = shape

	# Blender +Y frontal -> Godot -Z frontal.
	collision.position = Vector3(
		largo_x * 0.5,
		piso_terminado_y + altura_interior * 0.5,
		-ancho_y_blender * 0.5
	)

	_detector.add_child(collision)

	_detector.body_entered.connect(_on_body_entered)
	_detector.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group(grupo_jugador):
		return

	if _jugadores_dentro.has(body):
		return

	_jugadores_dentro.append(body)
	_actualizar_cubierta()
	jugador_entro.emit(self)


func _on_body_exited(body: Node3D) -> void:
	if not _jugadores_dentro.has(body):
		return

	_jugadores_dentro.erase(body)
	_actualizar_cubierta()
	jugador_salio.emit(self)


func _process(_delta: float) -> void:
	# Evita dejar el techo oculto si el jugador se elimina
	# o cambia de escena sin producir una salida normal.
	var cambio := false

	for i in range(_jugadores_dentro.size() - 1, -1, -1):
		if not is_instance_valid(_jugadores_dentro[i]):
			_jugadores_dentro.remove_at(i)
			cambio = true

	if cambio:
		_actualizar_cubierta()


func _actualizar_cubierta() -> void:
	var ocultar := (
		ocultar_cubierta_al_entrar
		and not _jugadores_dentro.is_empty()
	)

	for pieza in _cubierta:
		if is_instance_valid(pieza):
			pieza.visible = not ocultar


func hay_jugador_dentro() -> bool:
	return not _jugadores_dentro.is_empty()


func _crear_rampa_entrada() -> void:
	var desnivel := piso_terminado_y - terreno_entrada_y

	if desnivel <= 0.005:
		return

	if rampa_longitud <= 0.05 or rampa_ancho <= 0.05:
		push_warning("%s: dimensiones de rampa inválidas." % name)
		return

	var pendiente := rad_to_deg(
		atan2(desnivel, rampa_longitud)
	)

	if pendiente > 30.0:
		push_warning(
			"%s: rampa de %.1f grados; conviene alargarla."
			% [name, pendiente]
		)

	# El frente de la casa se encuentra en Z = -ancho.
	var z_puerta := -ancho_y_blender
	var z_exterior := z_puerta - rampa_longitud
	var z_interior := z_puerta + 0.14

	var x0 := puerta_centro_x - rampa_ancho * 0.5
	var x1 := puerta_centro_x + rampa_ancho * 0.5

	var y_base := terreno_entrada_y - 0.035
	var y_bajo := terreno_entrada_y + 0.005
	var y_alto := piso_terminado_y

	# Cuña sólida. El extremo alto llega al suelo interior.
	var vertices := PackedVector3Array([
		Vector3(x0, y_base, z_exterior), # 0
		Vector3(x1, y_base, z_exterior), # 1
		Vector3(x1, y_base, z_interior), # 2
		Vector3(x0, y_base, z_interior), # 3

		Vector3(x0, y_bajo, z_exterior), # 4
		Vector3(x1, y_bajo, z_exterior), # 5
		Vector3(x1, y_alto, z_interior), # 6
		Vector3(x0, y_alto, z_interior), # 7
	])

	var caras := [
		[0, 1, 2, 3],
		[4, 7, 6, 5],
		[0, 4, 5, 1],
		[1, 5, 6, 2],
		[2, 6, 7, 3],
		[3, 7, 4, 0],
	]

	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)

	for cara in caras:
		for index in [cara[0], cara[1], cara[2],
				cara[0], cara[2], cara[3]]:
			surface.add_vertex(vertices[index])

	surface.generate_normals()
	var mesh := surface.commit()

	var mat := StandardMaterial3D.new()
	mat.resource_name = "MAT_RAMPA_PIEDRA"
	mat.albedo_color = Color("#827D78")
	mat.roughness = 0.95
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.surface_set_material(0, mat)

	var body := StaticBody3D.new()
	body.name = "RAMPA_ENTRADA"
	body.collision_layer = capa_colision_casa
	body.collision_mask = 0
	add_child(body)

	var visual := MeshInstance3D.new()
	visual.name = "SM_RAMPA_ENTRADA"
	visual.mesh = mesh
	body.add_child(visual)

	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"

	var shape := mesh.create_trimesh_shape()
	shape.backface_collision = true
	collision.shape = shape

	body.add_child(collision)
```

---

# 3. Escena `CASA_BASE.tscn`

Guarda:

```text
res://casas/escenas/CASA_BASE.tscn
```

```ini
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://casas/scripts/casa_transitable.gd" id="1_casa"]

[node name="CASA_BASE" type="Node3D"]
script = ExtResource("1_casa")
```

Después instancia esta escena en tu mundo y asigna el GLB correspondiente desde el Inspector.

**Mantén la escala de `CASA_BASE` en `(1,1,1)`.** Puedes trasladarla y rotarla alrededor de Y, pero no conviene escalar físicamente una casa ya medida para NPCs de tamaño humano.

---

# 4. Parámetros para las cinco casas

Los valores corresponden a los generadores anteriores.

| Parámetro | Choza | Mediana | Casona | Mansión | Vecino |
|---|---:|---:|---:|---:|---:|
| `largo_x` | 5 | 8 | 10 | 14 | 7 |
| `ancho_y_blender` | 4 | 6 | 8 | 10 | 5 |
| `piso_terminado_y` | 0,245 | 0,295 | 0,345 | 0,445 | 0,195 |
| `altura_interior` | 2,60 | 2,60 | 2,60 | 2,80 | 2,60 |
| `puerta_centro_x` | 2,50 | 5,50 | 5,00 | 7,00 | 2,50 |
| `puerta_ancho` | 1,00 | 1,00 | 1,00 | 1,20 | 1,00 |
| `rampa_ancho` | 1,12 | 1,12 | 1,12 | 1,32 | 1,12 |
| `rampa_longitud` | 1,30 | 1,50 | 1,70 | 2,00 | 1,10 |

El parámetro `terreno_entrada_y` se expresa **respecto al origen de la casa**.

Ejemplo: si la casa está colocada sobre terreno plano que coincide con su origen, utiliza:

```text
terreno_entrada_y = 0.0
```

### Sobre la rampa

La rampa es una **pieza de integración en Godot**, no modifica el GLB:

- Añade un mesh y un cuerpo estático al conjunto de juego.
- No forma parte del presupuesto exportado de la casa.
- Puede desactivarse si prefieres resolver la entrada con terreno, escalones o una pieza artística propia.
- Mantiene el interior original y permite probarlo sin que el cimiento actúe como escalón bloqueante.

---

# 5. Configurar al jugador

En el `CharacterBody3D` del jugador:

1. Añade el grupo:

```text
JUGADOR
```

2. Asegúrate de que su **collision mask** incluye la capa física 1.
3. Configura `mascara_detector_jugador` de la casa para incluir la capa en la que está el jugador.

Ejemplo sencillo:

| Elemento | Collision Layer | Collision Mask |
|---|---:|---:|
| Entorno y casas | 1 | — |
| Jugador | 1 | 1 |
| NPCs de la guía anterior | 2 | 1 |

Si tu jugador usa otra capa, cambia la máscara del detector; **el nombre del grupo por sí solo no basta para que un `Area3D` lo detecte**.

Para las rampas, utiliza en el controlador del jugador:

```gdscript
floor_snap_length = 0.25
floor_max_angle = deg_to_rad(45.0)
```

Y conserva el movimiento mediante `move_and_slide()`.

---

# 6. Prueba de recorrido

Empieza con la choza:

1. Coloca `CASA_BASE` en un terreno plano.
2. Asigna `SM_CASA_01_CHOZA_ALTA.glb`.
3. Configura sus dimensiones según la tabla.
4. Activa **Debug → Visible Collision Shapes**.
5. Camina desde el exterior hasta la rampa.
6. Cruza la puerta.
7. Comprueba que el techo se oculta.
8. Recorre el pasillo entre cama y mesa.
9. Sal de la casa: el techo debe reaparecer.

### Qué debería quedar claro al probar

| Situación | Resultado esperado |
|---|---|
| Chocar contra una pared | El jugador se detiene |
| Pasar por la puerta | El hueco no está bloqueado |
| Tocar una cortina | No funciona como pared física |
| Entrar | Se ocultan los meshes de cubierta identificados |
| Salir | Se restauran |
| Caminar contra la mesa | Colisión con el mueble |
| Ocultar el techo | Sus colisiones permanecen, salvo exclusión configurada |

---

# 7. Limitaciones que mantenemos visibles

### Las paredes todavía pueden tapar una cámara en tercera persona

Esta entrega oculta **solo la cubierta**. No elimina automáticamente paredes interiores o fachadas. Para primera persona no suele ser un problema; para una cámara elevada añadiremos después ocultación selectiva por obstrucción.

### La torre necesita revisión aparte

El detector rectangular de la mansión incluye la torre, pero **la escalera sigue siendo un prototipo visual**. La colisión automática permite inspeccionarla, no garantiza que sea cómoda ni que tenga altura libre suficiente.

### No hay puertas móviles todavía

Los generadores construyen huecos y marcos. Las hojas abatibles y sus colisiones deben incorporarse como elementos independientes, especialmente en la casona y la mansión.

### El sistema genera colisiones al iniciar

Es adecuado para la guía y las primeras pruebas. Cuando las casas estén aprobadas, conviene **guardar esas colisiones en escenas preparadas**, en lugar de reconstruirlas durante cada carga.

### Navegación de NPCs

Los NPCs no empezarán a utilizar los interiores automáticamente.

Necesitaremos un `NavigationMesh` que conecte:

```text
Terreno → rampa → puerta → suelo interior
```

Como estos colliders se crean en ejecución, un bake realizado previamente en el editor **no los incorpora automáticamente**. La siguiente etapa será preparar el bake y los puntos de interacción de cama, mesa, silla y cocina.

---

## Resultado de esta etapa

Las cinco casas pasan de ser modelos exportados a **espacios que el jugador puede recorrer**, con una entrada accesible y cubierta ocultable.

**Siguiente paso:** navegación interior e interacción con muebles, leyendo las posiciones del `INFORME.json` de cada casa y sin duplicar lógica por edificio.