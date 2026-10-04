# Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
# Fecha: 2026-10-04
#
# M17 Construccion iter. 2/3 — BuildGhost: la representacion visual del fantasma.
#
# Este nodo NO decide nada: consume el resultado de `BuildPreview` (que es el
# nucleo puro) y solo lo dibuja. La malla se construye de forma PEREZOSA en el
# primer `configurar()` (no en `_ready`), de modo que la clase se puede instanciar
# y testear en headless sin agregarla a un arbol de escena.
#
# Pooling (bloque E): una instancia se reutiliza; `aplicar_resultado()` no crea
# nodos nuevos si ya existen. `aplicar_lod()` permite degradar la malla a
# distancia.
#
# iter. 3 agrega tres cosas (autorizadas por el director):
#   * MESH REAL de la receta: si `PlacementRule.mesh_path` apunta a una malla
#     disponible, el fantasma la muestra; si no, usa la CAJA de respaldo. Nunca
#     falla por una ruta ausente (cae a la caja y lo reporta por `usando_malla_real`).
#   * FOLLOW con lerp: `seguir()` acerca el fantasma al objetivo por frame con un
#     factor `vel*delta` acotado a [0,1] (sin sobrepasar el objetivo).
#   * AUTO-OCULTADO fuera de zona: `actualizar_visibilidad()` esconde el fantasma
#     cuando el rechazo es de ZONA (o cuando no hay terreno), y lo vuelve a
#     mostrar en cuanto la celda es valida.

class_name BuildGhost
extends Node3D

## Distancia (m) a partir de la cual se aplica el LOD simple (bloque E).
const DISTANCIA_LOD: float = 40.0

## Motivos de rechazo que ESCONDEN el fantasma (no tiene sentido pintar una caja
## roja fuera de la zona edificable o en agua prohibida). Ver `debe_ocultarse()`.
const MOTIVOS_OCULTAN: Array = [
	ConstruccionTipos.Motivo.FUERA_DE_ZONA,
	ConstruccionTipos.Motivo.ZONA_PROTEGIDA,
	ConstruccionTipos.Motivo.ZONA_NARRATIVA,
	ConstruccionTipos.Motivo.AGUA_NO_PERMITIDA,
]

var _mesh: MeshInstance3D = null
var _mat: StandardMaterial3D = null
var _box: BoxMesh = null
var _visible_logico: bool = false
var _color: Color = BuildPreview.COLOR_INVALIDO
var _celdas: Array[Vector3i] = []
var _receta_id: StringName = &""
var _lod: bool = false
## Malla REAL en uso (null si se usa la caja de respaldo).
var _malla_real: Mesh = null
## Cache ruta -> Mesh (o null si la ruta no resuelve). Evita recargar por frame.
var _cache_malla: Dictionary = {}

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

## ── Malla real (iter. 3) ────────────────────────────────────────────────

## Registra una malla para una ruta (precarga). Util para evitar cargas en el
## tick de preview y para testear la resolucion sin depender del importador.
func registrar_malla(ruta: String, mesh: Mesh) -> void:
	if ruta != "":
		_cache_malla[ruta] = mesh

## Resuelve la malla de una receta (o null si no declara ruta o no resuelve).
func resolver_malla(receta: PlacementRule) -> Mesh:
	if receta == null:
		return null
	return malla_desde_ruta(receta.mesh_path)

## Resuelve una malla desde una ruta res:// (cacheada). Devuelve null si la ruta
## esta vacia, no existe o no contiene una malla. NUNCA lanza: una ruta rota
## degrada a la caja de respaldo.
func malla_desde_ruta(ruta: String) -> Mesh:
	if ruta == "":
		return null
	if _cache_malla.has(ruta):
		return _cache_malla[ruta]
	var m: Mesh = cargar_malla_ruta(ruta)
	_cache_malla[ruta] = m
	return m

## Carga una malla desde una ruta. Acepta un `Mesh` directo o un `PackedScene`
## (p. ej. un `.glb` importado) del que toma la primera `MeshInstance3D`.
static func cargar_malla_ruta(ruta: String) -> Mesh:
	if not ResourceLoader.exists(ruta):
		return null
	var res: Variant = ResourceLoader.load(ruta)
	if res is Mesh:
		return res
	if res is PackedScene:
		var inst: Node = (res as PackedScene).instantiate()
		var m: Mesh = _primer_mesh(inst)
		inst.free()
		return m
	return null

static func _primer_mesh(nodo: Node) -> Mesh:
	if nodo is MeshInstance3D and (nodo as MeshInstance3D).mesh != null:
		return (nodo as MeshInstance3D).mesh
	for hijo in nodo.get_children():
		var m: Mesh = _primer_mesh(hijo)
		if m != null:
			return m
	return null

## Fuerza el uso de una malla real (o la caja si `m` es null). Devuelve true si
## quedo usando la malla real.
func cargar_malla(m: Mesh) -> bool:
	_asegurar_nodos()
	_malla_real = m
	_mesh.mesh = m if m != null else _box
	return _malla_real != null

## true si el fantasma esta mostrando una malla real (no la caja de respaldo).
func usando_malla_real() -> bool:
	return _malla_real != null

## Malla que el fantasma esta mostrando (real o la caja de respaldo).
func malla_actual() -> Mesh:
	return _mesh.mesh if _mesh != null else null

## ── API ─────────────────────────────────────────────────────────────────

## Configura el fantasma a partir de un resultado de `BuildPreview`.
## `receta` puede ser null (entonces se usa el tamano 1x1x1 y la caja).
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

	# MESH REAL (iter. 3): si la receta declara una malla que resuelve, se usa;
	# si no, la caja de respaldo. La caja SIEMPRE conserva la huella (dim) para
	# que `tamano_actual()` siga siendo la huella real de la pieza.
	var malla: Mesh = resolver_malla(receta)
	if malla != null:
		_malla_real = malla
		_mesh.mesh = malla
	else:
		_malla_real = null
		_mesh.mesh = _box

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

## Tamano actual de la HUELTA (caja). Independiente de la malla mostrada: sigue
## siendo el ancho/alto/fondo de la pieza (para verificar rotacion en tests).
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

## ── Follow con lerp (iter. 3) ───────────────────────────────────────────

## Centro de la huella de `receta` anclada en `celda` (mismo criterio que
## `aplicar_resultado`). Sirve de objetivo del follow.
static func destino_de(celda: Vector3i, receta: PlacementRule, rotacion: int = 0) -> Vector3:
	var dim := Vector3(1.0, 1.0, 1.0)
	if receta != null:
		var paso: int = posmod(rotacion, 4)
		var t: Vector2i = receta.tamano
		if paso % 2 == 1:
			t = Vector2i(receta.tamano.y, receta.tamano.x)
		dim = Vector3(float(maxi(1, t.x)), maxf(0.05, receta.altura), float(maxi(1, t.y)))
	return Vector3(
		float(celda.x) + dim.x * 0.5,
		float(celda.y) + dim.y * 0.5,
		float(celda.z) + dim.z * 0.5)

## Acerca la posicion del fantasma a `objetivo` con un factor `vel*delta`
## acotado a [0,1] (nunca sobrepasa el objetivo). Devuelve la posicion nueva.
func seguir(objetivo: Vector3, delta: float, vel: float = 12.0) -> Vector3:
	var t: float = clampf(vel * maxf(0.0, delta), 0.0, 1.0)
	position = position.lerp(objetivo, t)
	return position

## Follow por celda: calcula el objetivo y aplica el lerp.
func seguir_celda(celda: Vector3i, receta: PlacementRule, delta: float,
		rotacion: int = 0, vel: float = 12.0) -> Vector3:
	return seguir(destino_de(celda, receta, rotacion), delta, vel)

## Distancia (m) del fantasma a un objetivo.
func distancia_a(objetivo: Vector3) -> float:
	return position.distance_to(objetivo)

## true si el fantasma ya esta practicamente sobre el objetivo.
func asentado(objetivo: Vector3, eps: float = 0.01) -> bool:
	return distancia_a(objetivo) <= eps

## ── Auto-ocultado fuera de zona (iter. 3) ───────────────────────────────

## true si el resultado debe ESCONDER el fantasma: el rechazo es de zona (no
## tiene sentido pintar una caja roja fuera de la zona edificable).
static func debe_ocultarse(res: Dictionary) -> bool:
	if bool(res.get("ok", false)):
		return false
	for m in (res.get("motivos", []) as Array):
		if MOTIVOS_OCULTAN.has(int(m)):
			return true
	return false

## Actualiza la visibilidad del fantasma segun el resultado y el terreno.
## Devuelve el estado de visibilidad resultante. Sin terreno cargado, se oculta
## (no hay referencia espacial). Con rechazo de zona, se oculta. En cualquier
## otro caso, se muestra.
func actualizar_visibilidad(res: Dictionary, terreno_cargado: bool = true) -> bool:
	_asegurar_nodos()
	if not terreno_cargado or debe_ocultarse(res):
		ocultar()
		return false
	_visible_logico = true
	_mesh.visible = true
	return true
