extends CharacterBody3D

## M36: Tortuga marina NPC — deambula por la isla con animación procedural
##
## Encargo directo del usuario (2026-09-02, log 534): "una tortuguita
## deambulando por ahí que se mueva sola como NPC".
##
## Patrón copiado del villager (M19): CharacterBody3D + snap al terreno
## vía TerrainLocator (autoload) con reintentos diferidos — NUNCA un
## IslandGenerator propio (07-GUIA-GODOT §10.16: es la causa de los NPCs
## flotando). Sistema SEPARADO del fauna_manager (§15: no tocar lo que
## funciona); es un NPC decorativo, no una especie del registry.
##
## Comportamiento: pasea entre puntos aleatorios de un anillo alrededor
## del spawn (visible desde el arranque), se orienta hacia donde camina,
## aletas remando alterno + bobbing suave, pausas al llegar ("mirando el
## paisaje"). Al acercarse el jugador, la tortuga sigue su paseo (no
## huye: la tortuga real es tranquila).

## ── Configuración ─────────────────────────────────────
@export var centro_isla: Vector2 = Vector2(256.0, 256.0)
@export var radio_paseo_min: float = 8.0    # anillo alrededor del spawn
@export var radio_paseo_max: float = 26.0
@export var velocidad: float = 0.9          # m/s: paso de tortuga tranquila
@export var pausa_min: float = 2.0          # segundos mirando el paisaje
@export var pausa_max: float = 6.0

## ── Nodos de aletas (resueltos en _ready, DESPUES de instanciar el GLB) ──
## BUGFIX v3 (2026-09-02): antes eran @onready, que se evaluan ANTES de
## _ready() — es decir, ANTES de que el GLB existiera en el arbol -> las
## 5 refs quedaban null y la tortuga quedaba PARALIZADA (aletas y cabeza
## muertas). Ahora se resuelven en _resolver_nodos() tras crear el modelo.
var _aleta_d_izq: Node3D = null
var _aleta_d_der: Node3D = null
var _aleta_t_izq: Node3D = null
var _aleta_t_der: Node3D = null
var _cabeza: Node3D = null

## ── Estado ────────────────────────────────────────────
var _destino: Vector3 = Vector3.ZERO
var _estado: int = ESTADO_PAUSA
var _t_remar: float = 0.0
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
	print("[Tortuga] deambulando por la isla (spawn %.0f, %.0f)" % [
		global_position.x, global_position.z])


func _resolver_nodos() -> void:
	_aleta_d_izq = _buscar_hijo("Aleta_D_0")
	_aleta_d_der = _buscar_hijo("Aleta_D_1")
	_aleta_t_izq = _buscar_hijo("leta_T_0")
	_aleta_t_der = _buscar_hijo("leta_T_1")
	_cabeza = _buscar_hijo("Cabeza")
	var n: int = 0
	for a in [_aleta_d_izq, _aleta_d_der, _aleta_t_izq, _aleta_t_der, _cabeza]:
		if a != null:
			n += 1
	print("[Tortuga] nodos animables: %d/5%s" % [
		n, "" if n == 5 else " — ¡ALERTA! animacion incompleta"])


## ── Modelo (GLB del pipeline M166) ─────────────────────
func _instanciar_modelo() -> void:
	var glb := "res://assets/3d/%s/36-Fauna_tortuga_marina.glb" % VARIANTE_LOD
	if not ResourceLoader.exists(glb):
		push_warning("[Tortuga] GLB no encontrado: %s — usando placeholder" % glb)
		_instanciar_placeholder()
		return
	var escena: PackedScene = load(glb)
	var modelo: Node3D = escena.instantiate()
	modelo.name = "Modelo"
	# El GLB nace asentado con la base en z=0.045 (5 mm enterrada en la
	# arena del set). Como CharacterBody3D posiciona el ORIGEN en los
	# "pies", la bajamos esos 4.5 cm para que la panza quede al ras del
	# suelo del terreno (y no 4.5 cm arriba).
	modelo.position.y = -0.045
	add_child(modelo)


func _instanciar_placeholder() -> void:
	var mi := MeshInstance3D.new()
	var esfera := SphereMesh.new()
	esfera.radius = 0.30
	esfera.height = 0.25
	mi.mesh = esfera
	mi.position.y = 0.15
	mi.name = "Modelo"
	add_child(mi)


## ── Búsqueda tolerante de nodos por sufijo (el merge M166 ──
## renombra SM_Tortuga_X a sm_Tortuga_X etc. según variante) ─
func _buscar_hijo(sufijo: String) -> Node3D:
	return _buscar_rec(get_node_or_null("Modelo"), sufijo)


func _buscar_rec(desde: Node, sufijo: String) -> Node3D:
	if desde == null:
		return null
	for hijo in desde.get_children():
		if hijo is Node3D and hijo.name.to_lower().contains(sufijo.to_lower()):
			return hijo
		var r := _buscar_rec(hijo, sufijo)
		if r:
			return r
	return null


## ── Snap al terreno (patrón villager, §10.16) ──────────
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
	else:
		print("[Tortuga] no pudo calcular altura tras %d intentos" % _snap_intentos)


## ── Deambular ──────────────────────────────────────────
func _elegir_destino() -> void:
	var ang: float = randf() * TAU
	var radio: float = randf_range(radio_paseo_min, radio_paseo_max)
	var x: float = centro_isla.x + cos(ang) * radio
	var z: float = centro_isla.y + sin(ang) * radio
	_destino = Vector3(x, global_position.y, z)
	_estado = ESTADO_CAMINANDO


func _physics_process(delta: float) -> void:
	if _estado == ESTADO_CAMINANDO:
		_paso_caminando(delta)
	else:
		_paso_pausa(delta)
	_animar_aletas(delta)
	_seguir_suelo()


func _paso_caminando(delta: float) -> void:
	var a_plano: Vector3 = Vector3(_destino.x, global_position.y, _destino.z)
	var hacia: Vector3 = a_plano - global_position
	if hacia.length() < 0.4:
		_estado = ESTADO_PAUSA
		_t_pausa = randf_range(pausa_min, pausa_max)
		return
	var dir: Vector3 = hacia.normalized()
	velocity = dir * velocidad
	move_and_slide()
	# Orientar el modelo hacia donde camina (el +X del GLB es el frente)
	if dir.length_squared() > 0.001:
		var objetivo: float = atan2(dir.x, dir.z)
		rotation.y = lerp_angle(rotation.y, objetivo - PI / 2.0, 8.0 * delta)


func _paso_pausa(delta: float) -> void:
	velocity = Vector3.ZERO
	move_and_slide()
	_t_pausa -= delta
	if _t_pausa <= 0.0:
		_elegir_destino()


## ── Animación procedural ──────────────────────────────
## v2 (pedido del usuario: "movimiento de su cuerpo"): ademas de las
## aletas, el CUERPO entero se mueve —
##   - ROLL (rotation.z): se mece lateralmente con cada remada (la
##     tortuga real se balancea al caminar por el peso del caparazon)
##   - PITCH (rotation.x): cabecea adelante-atras al ritmo del paso,
##     y "respira" suavemente durante las pausas
##   - El bobbing vertical (position.y) se conserva
var _base_rot_aletas: Dictionary = {}
var _base_rot_cabeza: Vector3 = Vector3.ZERO
var _base_rot_modelo: Vector3 = Vector3.ZERO


func _guardar_rotaciones_base() -> void:
	for nodo in [_aleta_d_izq, _aleta_d_der, _aleta_t_izq, _aleta_t_der]:
		if nodo:
			_base_rot_aletas[nodo] = nodo.rotation
	if _cabeza:
		_base_rot_cabeza = _cabeza.rotation
	var modelo := get_node_or_null("Modelo")
	if modelo:
		_base_rot_modelo = modelo.rotation


func _animar_aletas(delta: float) -> void:
	var freq: float = 1.6 if _estado == ESTADO_CAMINANDO else 0.5
	_t_remar += delta * freq
	# v3: amplitudes MAS fuertes para que la remada se lea de lejos
	var amp: float = 0.45 if _estado == ESTADO_CAMINANDO else 0.12
	# Delanteras: remo alterno (fase invertida). El eje de bisagra es Z
	# local (la aleta "cuelga" del hombro): rotarla hacia adelante-atras.
	if _aleta_d_izq:
		_aleta_d_izq.rotation.z = _base_rot_aletas.get(_aleta_d_izq, _aleta_d_izq.rotation).z + sin(_t_remar) * amp
	if _aleta_d_der:
		_aleta_d_der.rotation.z = _base_rot_aletas.get(_aleta_d_der, _aleta_d_der.rotation).z + sin(_t_remar + PI) * amp
	# Traseras: medio remo, desfase largo (timon)
	if _aleta_t_izq:
		_aleta_t_izq.rotation.z = _base_rot_aletas.get(_aleta_t_izq, _aleta_t_izq.rotation).z + sin(_t_remar * 0.5 + 1.2) * amp * 0.6
	if _aleta_t_der:
		_aleta_t_der.rotation.z = _base_rot_aletas.get(_aleta_t_der, _aleta_t_der.rotation).z + sin(_t_remar * 0.5 + 1.2 + PI) * amp * 0.6

	# ---- MOVIMIENTO DEL CUERPO (v3: AMPLIFICADO, se tenia que VER) ----
	var modelo := get_node_or_null("Modelo")
	if modelo:
		if _estado == ESTADO_CAMINANDO:
			# Roll: se mece lateralmente con cada remada — bien visible
			modelo.rotation.z = _base_rot_modelo.z + sin(_t_remar) * 0.10
			# Pitch: cabeceo marcado al ritmo del paso
			modelo.rotation.x = _base_rot_modelo.x + sin(_t_remar * 1.0 + 0.6) * 0.08
			# Bobbing vertical amplio
			modelo.position.y = -0.045 + absf(sin(_t_remar * 2.0)) * 0.030
		else:
			# Pausa: "respiracion" lenta y profunda (lomo que sube y baja)
			modelo.rotation.z = lerp(modelo.rotation.z, _base_rot_modelo.z, 2.0 * delta)
			modelo.rotation.x = _base_rot_modelo.x + sin(_t_remar * 0.8) * 0.025
			modelo.position.y = -0.045 + sin(_t_remar * 0.8) * 0.012

	# La cabeza mira alrededor durante la pausa (vida)
	if _cabeza and _estado == ESTADO_PAUSA:
		_cabeza.rotation.y = sin(_t_remar * 0.7) * 0.35
		# Micro-cabeceo de curiosidad en la pausa
		_cabeza.rotation.x = _base_rot_cabeza.x + sin(_t_remar * 1.1) * 0.05
	else:
		# Suavizar la rotación de vuelta a 0 durante el caminar
		if _cabeza:
			_cabeza.rotation.y = lerp(_cabeza.rotation.y, 0.0, 3.0 * delta)
			_cabeza.rotation.x = lerp(_cabeza.rotation.x, _base_rot_cabeza.x, 3.0 * delta)


## ── Altura continua ────────────────────────────────────
func _seguir_suelo() -> void:
	var locator := get_node_or_null("/root/TerrainLocator")
	if not locator:
		return
	var h: int = locator.get_height(int(global_position.x), int(global_position.z))
	if h >= 0:
		# Seguimiento suave: el terreno cambia de a metros, no saltar
		var objetivo_y: float = float(h) + 1.0
		global_position.y = lerp(global_position.y, objetivo_y, 0.15)
