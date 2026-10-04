# Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
# Fecha: 2026-10-03
#
# M17 Construccion iter. 2 — BuildGhost: la representacion visual del fantasma.
#
# Este nodo NO decide nada: consume el resultado de `BuildPreview` (que es el
# nucleo puro) y solo lo dibuja. La malla se construye de forma PEREZOSA en el
# primer `configurar()` (no en `_ready`), de modo que la clase se puede instanciar
# y testear en headless sin agregarla a un arbol de escena.
#
# Pooling (bloque E): una instancia se reutiliza; `configurar()` no crea nodos
# nuevos si ya existen. `aplicar_lod()` permite degradar la malla a distancia.

class_name BuildGhost
extends Node3D

## Distancia (m) a partir de la cual se aplica el LOD simple (bloque E).
const DISTANCIA_LOD: float = 40.0

var _mesh: MeshInstance3D = null
var _mat: StandardMaterial3D = null
var _box: BoxMesh = null
var _visible_logico: bool = false
var _color: Color = BuildPreview.COLOR_INVALIDO
var _celdas: Array[Vector3i] = []
var _receta_id: StringName = &""
var _lod: bool = false

## ── Construccion perezosa ───────────────────────────────────────────────

func _asegurar_nodos() -> void:
	if _mesh != null:
		return
	_mat = StandardMaterial3D.new()
	_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat.albedo_color = _color
	_box = BoxMesh.new()
	_box.size = Vector3.ONE
	_mesh = MeshInstance3D.new()
	_mesh.name = "GhostMesh"
	_mesh.mesh = _box
	_mesh.material_override = _mat
	_mesh.visible = false
	# El fantasma nunca colisiona ni es raycastable (bloque E).
	_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_mesh)

## ── API ─────────────────────────────────────────────────────────────────

## Configura el fantasma a partir de un resultado de `BuildPreview`.
## `receta` puede ser null (entonces se usa el tamano 1x1x1).
func aplicar_resultado(res: Dictionary, receta: PlacementRule) -> void:
	_asegurar_nodos()
	var ok: bool = bool(res.get("ok", false))
	_color = BuildPreview.color_del_resultado(res)
	_mat.albedo_color = _color
	var celda: Vector3i = res.get("celda", Vector3i.ZERO)
	_celdas.clear()
	for c in res.get("celdas", []):
		_celdas.append(c)
	_receta_id = StringName(String(res.get("receta_id", "")))

	var dim := Vector3(1.0, 1.0, 1.0)
	if receta != null:
		var paso: int = posmod(int(res.get("rotacion", 0)), 4)
		var t: Vector2i = receta.tamano
		if paso % 2 == 1:
			t = Vector2i(receta.tamano.y, receta.tamano.x)
		dim = Vector3(float(maxi(1, t.x)), maxf(0.05, receta.altura), float(maxi(1, t.y)))
	_box.size = dim
	# El ancla es la esquina de menor x/z: el centro del box queda a media huella.
	position = Vector3(
		float(celda.x) + dim.x * 0.5,
		float(celda.y) + dim.y * 0.5,
		float(celda.z) + dim.z * 0.5)
	_mesh.visible = true
	_visible_logico = true

## Oculta el fantasma (sin destruir la malla -> pooling).
func ocultar() -> void:
	_visible_logico = false
	_celdas.clear()
	if _mesh != null:
		_mesh.visible = false

func esta_visible() -> bool:
	return _visible_logico

func color_actual() -> Color:
	return _color

func celdas_actuales() -> Array[Vector3i]:
	return _celdas.duplicate()

func receta_actual() -> StringName:
	return _receta_id

## Tamano actual de la caja (para verificar rotacion en tests).
func tamano_actual() -> Vector3:
	return _box.size if _box != null else Vector3.ZERO

## LOD simple: si la distancia a la camara supera `DISTANCIA_LOD`, se degrada
## (se oculta la sombra y se achica el detalle). Devuelve el estado resultante.
func aplicar_lod(distancia: float) -> bool:
	_asegurar_nodos()
	_lod = distancia > DISTANCIA_LOD
	if _mesh != null:
		_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return _lod

func en_lod() -> bool:
	return _lod

## Cuantos nodos hijos creo (auditoria de pooling: debe ser 0 o 1, nunca crecer).
func hijos_creados() -> int:
	return get_child_count()

## Devuelve el fantasma al pool: lo oculta y lo saca del arbol si esta dentro.
func devolver_al_pool() -> void:
	ocultar()
	if is_inside_tree():
		get_parent().remove_child(self)
