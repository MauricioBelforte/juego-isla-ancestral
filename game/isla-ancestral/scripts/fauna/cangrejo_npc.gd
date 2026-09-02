extends CharacterBody3D

## M36: Cangrejo de playa NPC — deambula DE LADO como los cangrejos reales
##
## Segundo animal del pipeline Blender->Godot->movimiento (ver
## 07-GUIA-GODOT §11). Patron tortuga_npc.gd (log 545) con las
## particularidades del cangrejo:
##   - CAMINA DE LADO: el cangrejo no apunta su frente (+X del GLB) hacia
##     la direccion de marcha; apunta PERPENDICULAR (su lado mira al
##     destino). Como los cangrejos reales (sprint lateral).
##   - 8 patitas remando en SECUENCIA: cada patita oscila con una fase
##     propia (delay por indice), la oleada viaja de atras hacia adelante
##     — se lee "caminando" sin rig.
##   - 2 pinzas agitandose (rotacion Z alternada, amenazante-cute).
##   - 2 ojos en pedunculos: en pausa se inclinan mirando alrededor.
##   - En pausa: cuerpo quieto, pinzas se abren/cierran sutilmente.
##
## E-50 offset: el GLB nace asentado a z_min 0.045 (arena del set), se
## compensa con -0.045 (igual que la tortuga).

@export var centro_isla: Vector2 = Vector2(256.0, 256.0)
@export var radio_paseo_min: float = 6.0
@export var radio_paseo_max: float = 20.0
@export var velocidad: float = 1.3        # cangrejos esprintan mas que tortugas
@export var pausa_min: float = 1.5
@export var pausa_max: float = 4.0
@export var amplitud_pata: float = 0.35
@export var amplitud_pinza: float = 0.20

var _patas: Array[Node3D] = []
var _pinzas: Array[Node3D] = []
var _ojos: Array[Node3D] = []
var _base_rot: Dictionary = {}
var _destino: Vector3 = Vector3.ZERO
var _estado: int = ESTADO_PAUSA
var _t: float = 0.0
var _t_pausa: float = 0.0
var _snap_intentos: int = 0

enum { ESTADO_CAMINANDO, ESTADO_PAUSA }

const GRUPO := "fauna_npc"
const VARIANTE_LOD := "alta"


func _ready() -> void:
	add_to_group(GRUPO)
	_instanciar_modelo()
	_resolver_nodos()
	_snap_to_ground.call_deferred()
	_elegir_destino()
	_guardar_rotaciones_base()
	print("[Cangrejo] en la playa (spawn %.0f, %.0f) — %d patas, %d pinzas, %d ojos" % [
		global_position.x, global_position.z, _patas.size(), _pinzas.size(), _ojos.size()])


func _instanciar_modelo() -> void:
	var glb := "res://assets/3d/%s/36-Fauna_cangrejo_playa.glb" % VARIANTE_LOD
	if not ResourceLoader.exists(glb):
		push_warning("[Cangrejo] GLB no encontrado: %s" % glb)
		return
	var modelo: Node3D = load(glb).instantiate()
	modelo.name = "Modelo"
	modelo.position.y = -0.045  # E-50: compensa el asentado de Blender
	add_child(modelo)


func _resolver_nodos() -> void:
	# Patitas: SM_Cangrejo_Pata_{L,R}_{0..3} (8 en ALTA; menos si el LOD funde)
	for lado in ['L', 'R']:
		for j in 4:
			var p := _buscar_hijo("Pata_%s_%d" % [lado, j])
			if p:
				_patas.append(p)
	for lado in ['L', 'R']:
		var pin := _buscar_hijo("Pinza_%s" % lado)
		if pin:
			_pinzas.append(pin)
	for i in 2:
		var ojo := _buscar_hijo("Ojo_%d" % i)
		if ojo:
			_ojos.append(ojo)
	if _patas.size() + _pinzas.size() + _ojos.size() < 4:
		push_warning("[Cangrejo] pocas piezas animables (%d) — ¿merge del LOD?" % (
			_patas.size() + _pinzas.size() + _ojos.size()))


func _buscar_hijo(sufijo: String) -> Node3D:
	return _buscar_rec(get_node_or_null("Modelo"), sufijo)


func _buscar_rec(desde: Node, sufijo: String) -> Node3D:
	if desde == null:
		return null
	for hijo in desde.get_children():
		var nombre := hijo.name.to_lower()
		if hijo is Node3D and nombre.contains(sufijo.to_lower()):
			return hijo
		var r := _buscar_rec(hijo, sufijo)
		if r:
			return r
	return null


func _snap_to_ground() -> void:
	var locator := get_node_or_null("/root/TerrainLocator")
	if locator:
		var h: int = locator.get_height(int(global_position.x), int(global_position.z))
		if h >= 0:
			global_position.y = float(h) + 1.0
			return
	_snap_intentos += 1
	if _snap_intentos <= 6:
		get_tree().create_timer(0.5).timeout.connect(_snap_to_ground)


func _elegir_destino() -> void:
	var ang: float = randf() * TAU
	var radio: float = randf_range(radio_paseo_min, radio_paseo_max)
	_destino = Vector3(centro_isla.x + cos(ang) * radio, global_position.y,
					   centro_isla.y + sin(ang) * radio)
	_estado = ESTADO_CAMINANDO


func _physics_process(delta: float) -> void:
	if _estado == ESTADO_CAMINANDO:
		_paso_caminando(delta)
	else:
		_paso_pausa(delta)
	_animar(delta)
	_seguir_suelo()


func _paso_caminando(delta: float) -> void:
	var a_plano := Vector3(_destino.x, global_position.y, _destino.z)
	var hacia := a_plano - global_position
	if hacia.length() < 0.4:
		_estado = ESTADO_PAUSA
		_t_pausa = randf_range(pausa_min, pausa_max)
		return
	var dir := hacia.normalized()
	velocity = dir * velocidad
	move_and_slide()
	# CAMINA DE LADO: el FRENTE del cangrejo (+X del GLB) apunta 90 grados a
	# la izquierda de la marcha — el cangrejo mira de costado al avanzar.
	# atan2(dir.x, dir.z) da el yaw "frontal"; restamos PI/2 para el lateral.
	if dir.length_squared() > 0.001:
		var objetivo: float = atan2(dir.x, dir.z) - PI / 2.0
		rotation.y = lerp_angle(rotation.y, objetivo, 8.0 * delta)


func _paso_pausa(delta: float) -> void:
	velocity = Vector3.ZERO
	move_and_slide()
	_t_pausa -= delta
	if _t_pausa <= 0.0:
		_elegir_destino()


func _guardar_rotaciones_base() -> void:
	for nodo: Node3D in _patas + _pinzas + _ojos:
		_base_rot[nodo] = nodo.rotation


func _animar(delta: float) -> void:
	var caminando: bool = _estado == ESTADO_CAMINANDO
	_t += delta * (2.4 if caminando else 0.7)

	# 8 patitas en secuencia: fase por indice (la oleada recorre el cuerpo).
	# El eje de bisagra es Z local (la patita "cuelga" de la cadera).
	for i in _patas.size():
		var p := _patas[i]
		var fase: float = sin(_t * 2.0 + i * 0.8)
		p.rotation.z = _base_rot[p].z + (fase * amplitud_pata if caminando else fase * 0.06)

	# Pinzas: agitacion alternada (la izq contrafase de la der) — amenazante.
	for i in _pinzas.size():
		var q := _pinzas[i]
		var fase_p: float = sin(_t * 1.4 + (PI if i == 1 else 0.0))
		q.rotation.z = _base_rot[q].z + (fase_p * amplitud_pinza if caminando else fase_p * 0.08)

	# Ojos en pedunculos: en pausa se inclinan mirando el paisaje (curiosos);
	# al caminar, erguidos y atentos (rotacion X hacia adelante sutil).
	for i in _ojos.size():
		var o := _ojos[i]
		if not caminando:
			o.rotation.z = _base_rot[o].z + sin(_t * 0.9 + i * 1.3) * 0.22
		else:
			o.rotation.z = lerp(o.rotation.z, _base_rot[o].z, 4.0 * delta)

	# Cuerpo: bobbing sutil (el cangrejo es bajo, el roll no se lee).
	var modelo := get_node_or_null("Modelo")
	if modelo:
		modelo.position.y = -0.045 + absf(sin(_t * 2.0)) * (0.008 if caminando else 0.003)


func _seguir_suelo() -> void:
	var locator := get_node_or_null("/root/TerrainLocator")
	if not locator:
		return
	var h: int = locator.get_height(int(global_position.x), int(global_position.z))
	if h >= 0:
		global_position.y = lerp(global_position.y, float(h) + 1.0, 0.15)
