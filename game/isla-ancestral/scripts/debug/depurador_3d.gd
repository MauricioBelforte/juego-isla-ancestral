# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-11-01
#
# M110-UI — Depurador3D: constructor de lineas 3D inmediatas (equivalente Godot 4
# del `DebugDraw` que pide el diseno §4 y que NO existe en el motor).
#
# Por que existe este archivo:
#   `03-Diseno.md` §4 escribe `DebugDraw.draw_shape_3d(...)`, `DebugDraw.draw_box_3d(...)`,
#   `DebugDraw.draw_line_3d(...)` y `DebugDraw.draw_text_3d(...)`. MEDIDO en Godot
#   4.7.2-stable: `ClassDB.class_exists("DebugDraw")` == false y
#   `Engine.has_singleton("DebugDraw")` == false. `DebugDraw` es un addon de terceros,
#   no una API del motor: implementar §4 al pie de la letra es imposible.
#   El equivalente NATIVO para lineas 3D es `ImmediateMesh` (medido: existe, 4 vertices
#   -> 1 superficie, `ARRAY_INDEX` == null, `clear_surfaces()` deja 0 superficies).
#
# Este archivo es SOLO el pincel: no sabe nada del mundo ni del Debug Menu. La
# enumeracion de nodos reales vive en `debug_visualizer.gd`.
#
# Invariante que justifica el guardia: `ImmediateMesh.surface_add_vertex()` acepta
# `Vector3(NAN, 0, 0)` EN SILENCIO (medido) y la superficie queda con 2 vertices
# corruptos. Un solo NaN envenena el mesh sin error ni aviso, asi que toda
# coordenada no finita se RECHAZA y se cuenta en `rechazados()`.

extends RefCounted
class_name Depurador3D

## Segmentos de cada circulo maximo de una esfera de alambre.
const SEGMENTOS_ARO_ESFERA := 12

var _mesh: ImmediateMesh = null
var _abierto: bool = false
var _segmentos: int = 0
var _vertices: int = 0
var _rechazados: int = 0


func _init() -> void:
	_mesh = ImmediateMesh.new()
	limpiar()


## Vacia el mesh y los contadores. Se llama una vez por frame de dibujo.
func limpiar() -> void:
	if _mesh != null:
		_mesh.clear_surfaces()
	_abierto = false
	_segmentos = 0
	_vertices = 0
	_rechazados = 0


## Cierra la superficie abierta. Idempotente. Sin `cerrar()` el mesh puede quedar
## con la superficie a medio construir (y `surface_get_arrays()` la ve igual).
func cerrar() -> void:
	if _abierto:
		_mesh.surface_end()
		_abierto = false


static func _finito(v: Vector3) -> bool:
	return is_finite(v.x) and is_finite(v.y) and is_finite(v.z)


func _asegurar_superficie(color: Color) -> void:
	if not _abierto:
		_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		_abierto = true
	_mesh.surface_set_color(color)


## Un segmento. Devuelve `false` (y cuenta el rechazo) si algun extremo no es
## finito: un NaN silencioso corrompe el mesh entero.
func linea(a: Vector3, b: Vector3, color: Color = Color.WHITE) -> bool:
	if not _finito(a) or not _finito(b):
		_rechazados += 1
		return false
	_asegurar_superficie(color)
	_mesh.surface_add_vertex(a)
	_mesh.surface_add_vertex(b)
	_segmentos += 1
	_vertices += 2
	return true


## Caja alineada a los ejes: 12 aristas.
func caja(caja_local: AABB, color: Color = Color.GREEN) -> int:
	return caja_transformada(Transform3D.IDENTITY, caja_local, color)


## Caja con rotacion/escala: transforma las 8 esquinas y une las 12 aristas.
func caja_transformada(tf: Transform3D, caja_local: AABB, color: Color = Color.GREEN) -> int:
	var antes := _segmentos
	var esquinas: Array[Vector3] = []
	var pos := caja_local.position
	var fin := caja_local.end
	for i in 8:
		var esquina := Vector3(
			pos.x if (i & 1) == 0 else fin.x,
			pos.y if (i & 2) == 0 else fin.y,
			pos.z if (i & 4) == 0 else fin.z
		)
		esquinas.append(tf * esquina)
	# 12 aristas: pares de esquinas que difieren en UN solo bit.
	for i in 8:
		for bit in [1, 2, 4]:
			if (i & bit) == 0:
				linea(esquinas[i], esquinas[i | bit], color)
	return _segmentos - antes


## Esfera de alambre: 3 circulos maximos (XY, XZ, YZ).
## Segmentos = 3 * `segmentos_aro`. Default 12 -> 36 segmentos / 72 vertices.
func esfera(centro: Vector3, radio: float, color: Color = Color.WHITE,
		segmentos_aro: int = SEGMENTOS_ARO_ESFERA) -> int:
	if not is_finite(radio) or radio <= 0.0 or segmentos_aro < 3:
		_rechazados += 1
		return 0
	var antes := _segmentos
	var paso := TAU / float(segmentos_aro)
	for aro in 3:
		for i in segmentos_aro:
			var a0 := paso * float(i)
			var a1 := paso * float(i + 1)
			var p0 := centro
			var p1 := centro
			match aro:
				0:  # plano XY
					p0 += Vector3(cos(a0), sin(a0), 0.0) * radio
					p1 += Vector3(cos(a1), sin(a1), 0.0) * radio
				1:  # plano XZ
					p0 += Vector3(cos(a0), 0.0, sin(a0)) * radio
					p1 += Vector3(cos(a1), 0.0, sin(a1)) * radio
				_:  # plano YZ
					p0 += Vector3(0.0, cos(a0), sin(a0)) * radio
					p1 += Vector3(0.0, cos(a1), sin(a1)) * radio
			linea(p0, p1, color)
	return _segmentos - antes


## Polilinea: n puntos -> n-1 segmentos. Con 0 o 1 punto no dibuja nada.
func camino(puntos: PackedVector3Array, color: Color = Color.BLUE) -> int:
	if puntos.size() < 2:
		return 0
	var antes := _segmentos
	for i in range(1, puntos.size()):
		linea(puntos[i - 1], puntos[i], color)
	return _segmentos - antes


func superficies() -> int:
	return _mesh.get_surface_count() if _mesh != null else 0


func segmentos() -> int:
	return _segmentos


func vertices() -> int:
	return _vertices


func rechazados() -> int:
	return _rechazados


func hay_geometria() -> bool:
	return _segmentos > 0


func mesh() -> ImmediateMesh:
	return _mesh
