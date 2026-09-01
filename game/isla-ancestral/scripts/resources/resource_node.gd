# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M15: Recursos — ResourceNode (nodo 3D recolectable en el mundo).
# Estados INTACTO / DANIADO / AGOTADO. Usa TerrainLocator (M167) para posicionarse
# sobre el terreno REAL (anti-flotamiento). Al agotarse, pide a ResourceManager la
# generación de drops y emite recurso_agotado.
# Mesh placeholder por estado (se reemplaza por assets del equipo de arte).

class_name ResourceNode
extends Node3D

enum Estado { INTACTO, DANIADO, AGOTADO }

signal golpe_aplicado(def_id: StringName, dano: int)
signal agotado(def_id: StringName, pos: Vector3)
signal respawn_completado(def_id: StringName)

var def_id: StringName = &""
var estado: int = Estado.INTACTO
var golpes_restantes: int = 2
var herramientas_requerida: StringName = &""

## M15 iter 3: respawn. 0 = sin programar. dia_absoluto (M29) en que reaparece.
var respawn_dia_absoluto: int = 0
## Estación en que respawnea (0..3) o -1 para "cualquiera".
var respawn_estacion: int = -1

var _mesh_intacto: MeshInstance3D
var _mesh_daniado: MeshInstance3D
var _mesh_agotado: MeshInstance3D
var _area: Area3D

## Configura el nodo a partir de una ResourceDefinition.
func configurar(def: ResourceDefinition) -> void:
	def_id = def.def_id
	golpes_restantes = maxi(1, def.golpes_requeridos)
	herramientas_requerida = def.herramienta_requerida
	respawn_estacion = def.get_respawn_estacion_int()
	_crear_presentacion(def.categoria, def.rareza)

## Aplica un golpe (llamado por el sistema de interacción/M13).
## Devuelve true si el golpe fue efectivo (herramienta válida + quedan golpes).
func aplicar_golpe(herramienta_id: StringName) -> bool:
	if estado == Estado.AGOTADO:
		return false
	if herramientas_requerida != &"" and herramienta_id != herramientas_requerida:
		return false
	golpes_restantes -= 1
	golpe_aplicado.emit(def_id, 1)
	if golpes_restantes <= 0:
		_agotar()
	else:
		estado = Estado.DANIADO
		_actualizar_mesh()
	return true

func _agotar() -> void:
	estado = Estado.AGOTADO
	_actualizar_mesh()
	agotado.emit(def_id, global_position)

## M15 iter 3: respawn. Programa la estación del nodo y el día absoluto (M29)
## en que debe reaparecer. Llamado por ResourceManager al agotarse.
func programar_respawn(dia_absoluto: int) -> void:
	respawn_dia_absoluto = dia_absoluto

## Indica si el nodo está en un estado que permite respawn inmediato
## (AGOTADO y con respawn_dia_absoluto > 0).
func esta_listo_para_respawn() -> bool:
	return estado == Estado.AGOTADO and respawn_dia_absoluto > 0

## M15 iter 3: evalúa si el nodo debe respawnear HOY y en la estación correcta.
## Si dia_actual >= respawn_dia y (respawn_estacion==-1 o ==estacion_actual),
## vuelve a INTACTO con golpes_restantes = max(1, golpes_originales).
## dia_actual: int (M29 dia_absoluto). estacion_actual: int (0..3).
func evaluar_respawn(dia_actual: int, estacion_actual: int) -> bool:
	if not esta_listo_para_respawn():
		return false
	if dia_actual < respawn_dia_absoluto:
		return false
	if respawn_estacion >= 0 and respawn_estacion != estacion_actual:
		return false
	estado = Estado.INTACTO
	golpes_restantes = 2  # valor por defecto; el manager puede ajustar
	respawn_dia_absoluto = 0
	_actualizar_mesh()
	respawn_completado.emit(def_id)
	return true

## ── Presentación (placeholder hasta assets del arte) ─────

func _crear_presentacion(categoria: int, rareza: int) -> void:
	_mesh_intacto = _crear_mesh(categoria, rareza)
	_mesh_daniado = _crear_mesh(categoria, rareza)
	_mesh_agotado = _crear_mesh(categoria, rareza)
	# Diferenciar estados con escala/rotación visual
	_mesh_intacto.scale = Vector3(1, 1, 1)
	_mesh_daniado.scale = Vector3(0.85, 0.85, 0.85)
	_mesh_agotado.scale = Vector3(0.5, 0.5, 0.5)
	_crear_area()
	_actualizar_mesh()

func _crear_mesh(categoria: int, _rareza: int) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	# Tamaño según categoría: madera alto, piedra compacto, fibra bajo, etc.
	if categoria == ResourceDefinition.Categoria.MADERA:
		mesh.size = Vector3(0.6, 1.6, 0.6)
	elif categoria == ResourceDefinition.Categoria.PIEDRA or categoria == ResourceDefinition.Categoria.MINERAL:
		mesh.size = Vector3(1.0, 0.8, 1.0)
	elif categoria == ResourceDefinition.Categoria.RARO:
		mesh.size = Vector3(0.9, 1.4, 0.9)
	else:
		mesh.size = Vector3(0.7, 0.7, 0.7)
	mi.mesh = mesh
	mi.material_override = StandardMaterial3D.new()
	mi.material_override.albedo_color = _color_categoria(categoria)
	add_child(mi)
	return mi

func _color_categoria(categoria: int) -> Color:
	match categoria:
		ResourceDefinition.Categoria.MADERA: return Color(0.45, 0.27, 0.11)
		ResourceDefinition.Categoria.PIEDRA: return Color(0.55, 0.55, 0.58)
		ResourceDefinition.Categoria.FIBRA: return Color(0.76, 0.75, 0.55)
		ResourceDefinition.Categoria.COMIDA: return Color(0.85, 0.2, 0.25)
		ResourceDefinition.Categoria.MINERAL: return Color(0.75, 0.45, 0.2)
		ResourceDefinition.Categoria.RARO: return Color(0.85, 0.85, 0.3)
	return Color.WHITE

func _crear_area() -> void:
	_area = Area3D.new()
	var col := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 1.4
	col.shape = shape
	_area.add_child(col)
	add_child(_area)

func _actualizar_mesh() -> void:
	if _mesh_intacto:
		_mesh_intacto.visible = estado == Estado.INTACTO
	if _mesh_daniado:
		_mesh_daniado.visible = estado == Estado.DANIADO
	if _mesh_agotado:
		_mesh_agotado.visible = estado == Estado.AGOTADO
