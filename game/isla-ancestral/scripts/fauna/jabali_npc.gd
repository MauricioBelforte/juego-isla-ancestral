extends CharacterBody3D

## M36: Jabalí NPC — trote cuadrúpedo por la isla
##
## Tercer animal del pipeline Blender→Godot→movimiento (07 §11, guia 09 §9).
## Patron tortuga/cangrejo con las particularidades del jabali:
##   - TROTE DIAGONAL: patas en pares opuestos (delantera-izq con
##     trasera-der, y delantera-der con trasera-izq) — el gait clasico
##     de los cuadrupedos.
##   - REBOTE del cuerpo sincronizado con el trote (el jabali rebota al
##     trotar) + cabeceo del husmeo constante.
##   - COLA-CUERDA: menear lateralmente mientras camina (la cola del
##     v12b es 1 pieza con pivote en la grupa).
##   - CRESTA y cabeza: la cabeza baja un poco mas al pausar (olfatear
##     el piso), sube al caminar alerta.
##   - Al caminar es MAS rapido que la tortuga (trote) y hace pausas
##     mas cortas: el jabali es desconfiado.

@export var centro_isla: Vector2 = Vector2(256.0, 256.0)
@export var radio_paseo_min: float = 10.0
@export var radio_paseo_max: float = 34.0
@export var velocidad: float = 1.7        # trote tranquilo
@export var pausa_min: float = 1.5
@export var pausa_max: float = 5.0
@export var amplitud_pata: float = 0.40
@export var rebote_cuerpo: float = 0.022
## Escala visual del modelo (feedback usuario 2026-09-02: a escala real el
## jabali se veia chiquito junto al jugador estilizado). El GLB se escala
## desde los pies: el cuerpo crece hacia arriba, la huella no cambia.
@export var escala_modelo: float = 1.5
## Etapa de vida (feedback usuario 2026-09-03): "joven" (compacto, trote
## liviano) o "adulto" (2.3x — bruto grande, trote pesado y pausado). Al
## setear etapa en el inspector, escala/velocidad/ritmo se ajustan solos.
@export_enum("joven", "adulto") var etapa: String = "joven"

const _CFG_ETAPA := {
	"joven": {"escala": 1.5, "velocidad": 1.7, "rebote": 0.022, "pausa_min": 1.5, "pausa_max": 5.0},
	"adulto": {"escala": 2.3, "velocidad": 1.2, "rebote": 0.030, "pausa_min": 3.0, "pausa_max": 8.0},
}


func _ready() -> void:
	_aplicar_etapa()
	add_to_group(GRUPO)
	_instanciar_modelo()
	_resolver_nodos()
	_snap_to_ground.call_deferred()
	_elegir_destino()
	_guardar_rotaciones_base()
	print("[Jabali %s] troteando por la isla (spawn %.0f, %.0f) — %d patas, cola: %s, cabeza: %s" % [
		etapa, global_position.x, global_position.z, _patas.size(),
		"si" if _cola else "NO", "si" if _cabeza else "NO"])


func _aplicar_etapa() -> void:
	if not _CFG_ETAPA.has(etapa):
		etapa = "joven"
	var cfg: Dictionary = _CFG_ETAPA[etapa]
	escala_modelo = cfg["escala"]
	velocidad = cfg["velocidad"]
	rebote_cuerpo = cfg["rebote"]
	pausa_min = cfg["pausa_min"]
	pausa_max = cfg["pausa_max"]

var _patas: Array[Node3D] = []       # [FL, FR, BL, BR] por sufijo
var _cola: Node3D = null
var _cabeza: Node3D = null
var _base_rot: Dictionary = {}
var _destino: Vector3 = Vector3.ZERO
var _estado: int = ESTADO_PAUSA
var _t: float = 0.0
var _t_pausa: float = 0.0
var _snap_intentos: int = 0

enum { ESTADO_CAMINANDO, ESTADO_PAUSA }

const GRUPO := "fauna_npc"
const VARIANTE_LOD := "alta"


func _instanciar_modelo() -> void:
	var glb := "res://assets/3d/%s/36-Fauna_jabali.glb" % VARIANTE_LOD
	if not ResourceLoader.exists(glb):
		push_warning("[Jabali] GLB no encontrado: %s" % glb)
		return
	var modelo: Node3D = load(glb).instantiate()
	modelo.name = "Modelo"
	modelo.position.y = -0.045
	modelo.scale = Vector3(escala_modelo, escala_modelo, escala_modelo)
	# Escala desde los PIES: el GLB tiene la base en z 0 del origin, asi que
	# escalar el nodo crece hacia arriba — la panza no se hunde (E-50 OK).
	add_child(modelo)


func _resolver_nodos() -> void:
	# Orden canonico: FL, FR, BL, BR (el script Blender usa esos sufijos)
	for sufijo in ['Pata_FL', 'Pata_FR', 'Pata_BL', 'Pata_BR']:
		var p := _buscar_hijo(sufijo)
		if p:
			_patas.append(p)
	_cola = _buscar_hijo("Cola")
	# La cabeza: cuidado — "Cabeza" matchea tambien... no hay conflicto,
	# el tronco se llama Tronco. OK.
	_cabeza = _buscar_hijo("Cabeza")
	if _patas.size() < 4:
		push_warning("[Jabali] %d/4 patas — ¿merge del LOD?" % _patas.size())


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
	if hacia.length() < 0.5:
		_estado = ESTADO_PAUSA
		_t_pausa = randf_range(pausa_min, pausa_max)
		return
	var dir := hacia.normalized()
	velocity = dir * velocidad
	move_and_slide()
	# Frente del GLB = +X: yaw "frontal" directo (a diferencia del cangrejo)
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
	for nodo: Node3D in _patas + ([_cola] if _cola else []) + ([_cabeza] if _cabeza else []):
		_base_rot[nodo] = nodo.rotation


func _animar(delta: float) -> void:
	var caminando: bool = _estado == ESTADO_CAMINANDO
	_t += delta * (3.2 if caminando else 0.6)

	# TROTE DIAGONAL: FL+BR en fase, FR+BL contrafase. El eje de bisagra
	# es Z local (la pata cuelga de la cadera).
	if _patas.size() == 4:
		var fases: Array[float] = [0.0, PI, PI, 0.0]  # FL, FR, BL, BR
		for i in 4:
			var p := _patas[i]
			p.rotation.z = _base_rot[p].z + (sin(_t + fases[i]) * amplitud_pata if caminando else sin(_t + fases[i]) * 0.04)

	# COLA-CUERDA: meneo lateral (eje Z de la grupa) al caminar; quieta
	# (con leve balanceo) en pausa.
	if _cola:
		if caminando:
			_cola.rotation.z = _base_rot[_cola].z + sin(_t * 1.3) * 0.18
			_cola.rotation.x = _base_rot[_cola].x + sin(_t * 2.6) * 0.06
		else:
			_cola.rotation.z = _base_rot[_cola].z + sin(_t * 0.5) * 0.05
			_cola.rotation.x = lerp(_cola.rotation.x, _base_rot[_cola].x, 3.0 * delta)

	# CABEZA: al caminar husmea leve (cabeceo X); al pausar BAJA al piso
	# a olfatear (la firma del jabali curioso).
	if _cabeza:
		if caminando:
			_cabeza.rotation.x = _base_rot[_cabeza].x + sin(_t * 0.9) * 0.05
		else:
			_cabeza.rotation.x = lerp(_cabeza.rotation.x, _base_rot[_cabeza].x + 0.10, 2.5 * delta)

	# CUERPO: rebote del trote (vertical) + roll leve.
	var modelo := get_node_or_null("Modelo")
	if modelo:
		if caminando:
			modelo.position.y = -0.045 + absf(sin(_t)) * rebote_cuerpo
			modelo.rotation.z = sin(_t) * 0.025
		else:
			modelo.position.y = -0.045
			modelo.rotation.z = lerp(modelo.rotation.z, 0.0, 2.0 * delta)


func _seguir_suelo() -> void:
	var locator := get_node_or_null("/root/TerrainLocator")
	if not locator:
		return
	var h: int = locator.get_height(int(global_position.x), int(global_position.z))
	if h >= 0:
		global_position.y = lerp(global_position.y, float(h) + 1.0, 0.15)
