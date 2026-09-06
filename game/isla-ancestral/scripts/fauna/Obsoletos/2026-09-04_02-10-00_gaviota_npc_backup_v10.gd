extends CharacterBody3D

## M36: Gaviota NPC — VUELA y CAMINA (aire ⇄ tierra) · v8 REESCRITA
##
## Diseño de la v8 tras investigar la doc de CharacterBody3D (docs.godot
## .engine.org, clases/characterbody3d): las versiones anteriores se trababan
## contra bloques porque apilaban rescates (clamps/watchdogs/proyecciones)
## que peleaban entre sí. Los 4 principios de esta versión:
##
## 1. MODO FÍSICO POR ESTADO: aire = MOTION_MODE_FLOATING (todas las
##    colisiones se reportan como pared — sin "floor" que bloquee), tierra =
##    MOTION_MODE_GROUNDED + floor_snap_length para ondulación.
## 2. ESQUIVAR, NO EMPUJAR: en vuelo, si toca pared (is_on_wall) se desvía
##    con get_wall_normal() — un pájaro vuela ALREDEDOR del obstáculo.
## 3. ABORTAR ATERRIZAJES: si durante el descenso toca una pared, aborta y
##    vuelve a VUELO (lo intentará más tarde en otro lugar). El descenso
##    NUNCA insiste contra un obstáculo.
## 4. RECUPERACIÓN IMPARABLE: ascenso VERTICAL puro (ninguna pared lateral
##    puede bloquear el movimiento vertical) + watchdog global: si la
##    gaviota no se mueve 2.5 s en cualquier estado de aire → despegue
##    vertical forzado. Siempre puede volver a volar. Ese es el ciclo
##    que en v7 moría atrapado.
##
## Ciclo: VUELO (órbita con banking) → descenso planeado → ATERRIZADA en
## piso real (is_on_floor) → CAMINA con alas PLEGADAS y pose parada →
## posada larga → DESPEGUE vertical → VUELO. Todo random.

@export var centro_isla: Vector2 = Vector2(256.0, 256.0)
@export var radio_vuelo: float = 30.0
@export var altura_vuelo: float = 9.0
@export var velocidad_vuelo: float = 6.0
@export var velocidad_caminata: float = 0.8
@export var escala_modelo: float = 1.0

var _alas: Array[Node3D] = []
var _puntas: Array[Node3D] = []
var _base_rot: Dictionary = {}
var _estado: int = ESTADO_VUELO
var _t: float = 0.0
var _ang_orbita: float = 0.0
var _dir_orbita: int = 1
var _t_prox_aterrizaje: float = 10.0
var _caminatas: int = 0
var _caminatas_objetivo: int = 2
var _finalizando: bool = false
var _destino_suelo: Vector3 = Vector3.ZERO
var _punto_aterrizaje: Vector3 = Vector3.ZERO
var _t_pausa: float = 0.0
var _desvio: Vector3 = Vector3.ZERO      # waypoint temporal de esquive
var _t_desvio: float = 0.0
var _ult_pos: Vector3 = Vector3.ZERO     # watchdog: si no se mueve...
var _t_quieto: float = 0.0               # ...durante esto, forzar despegue
var _t_descenso: float = 0.0
var _t_muro: float = 0.0  # contacto continuo contra muro (filtra escalones)
var _t_sin_muro: float = 0.0
var _salto_pendiente: bool = false  # hop de ave en curso
var _v_salto: float = 0.0
var _hops: int = 0
var _reintentos_dir: int = 0

enum { ESTADO_VUELO, ESTADO_IR_PUNTO, ESTADO_ATERRIZANDO, ESTADO_CAMINANDO, ESTADO_PAUSA_SUELO, ESTADO_DESPEGUE_VERTICAL, ESTADO_DESPEGUE_CURVA }

const GRUPO := "fauna_npc"
const VARIANTE_LOD := "alta"
const PLEGADO_ALA := 1.45
const POSE_PARADA := 0.45
const ALTURA_TIERRA := -0.16
const UMBRAL_QUIETA := 2.5  # s sin moverse en aire → recuperación forzada


func _ready() -> void:
	add_to_group(GRUPO)
	motion_mode = MOTION_MODE_FLOATING  # arranca volando
	_instanciar_modelo()
	_resolver_nodos()
	_guardar_rotaciones_base()
	_ang_orbita = randf() * TAU
	_dir_orbita = 1 if randf() > 0.5 else -1
	global_position = _pos_en_orbita(_ang_orbita)
	_ult_pos = global_position
	_t_prox_aterrizaje = _t + randf_range(8.0, 18.0)
	print("[Gaviota] volando (centro %.0f,%.0f r %.0f) — %d alas, %d puntas" % [
		centro_isla.x, centro_isla.y, radio_vuelo, _alas.size(), _puntas.size()])


func _instanciar_modelo() -> void:
	var glb := "res://assets/3d/%s/36-Fauna_gaviota.glb" % VARIANTE_LOD
	if not ResourceLoader.exists(glb):
		push_warning("[Gaviota] GLB no encontrado: %s" % glb)
		return
	var modelo: Node3D = load(glb).instantiate()
	modelo.name = "Modelo"
	modelo.scale = Vector3.ONE * escala_modelo
	add_child(modelo)
	# v10b — FIX DE COLISION: esfera r 0.30 → CAPSULA (cilindro r 0.22 con
	# tapas). La esfera tangenteaba el borde del escalon vecino ANTES de
	# posarse (reportaba "pared" en plena caida vertical: el casquete
	# inferior es curvo y toca las ARISTAS de los voxels). La cara plana
	# inferior de la capsula aterriza sobre la cara superior del voxel
	# de una. Altura 0.55: cuerpo del ave, no el pico largo.
	var cs := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.22
	shape.height = 0.70
	cs.shape = shape
	cs.position = Vector3(0.0, 0.42, 0.0)
	cs.name = "Colision"
	add_child(cs)
	# Laderas de voxel = aristas de 45-50 deg: reconocerlas como PISO
	# transitable (default 45 deg exacto es justo el borde del voxel).
	floor_max_angle = 0.96  # ~55 deg: sube el escalon en vez de "muro"


func _resolver_nodos() -> void:
	for sufijo in ['Ala_L', 'Ala_R']:
		var a := _buscar_hijo(sufijo)
		if a:
			_alas.append(a)
	for i in 2:
		var p := _buscar_hijo("Punta_%d" % i)
		if p and _alas.size() == 2:
			_puntas.append(p)
			var ala_padre: Node3D = _alas[1] if i == 1 else _alas[0]
			var offset_local: Vector3 = ala_padre.global_transform.affine_inverse() * p.global_transform.origin
			p.get_parent().remove_child(p)
			ala_padre.add_child(p)
			p.position = offset_local
	if _alas.size() < 2:
		push_warning("[Gaviota] %d/2 alas resueltas — merge del LOD" % _alas.size())


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


func _altura_suelo_en(pos: Vector3) -> float:
	var locator := get_node_or_null("/root/TerrainLocator")
	if locator:
		var h: int = locator.get_height(int(pos.x), int(pos.z))
		if h >= 0:
			return float(h) + 1.0
	return pos.y - altura_vuelo


func _pos_en_orbita(ang: float) -> Vector3:
	var p := Vector3(centro_isla.x + cos(ang) * radio_vuelo, 0.0,
					 centro_isla.y + sin(ang) * radio_vuelo)
	p.y = _altura_suelo_en(p) + altura_vuelo + sin(ang * 3.0) * 1.5
	return p


func _physics_process(delta: float) -> void:
	_t += delta
	match _estado:
		ESTADO_VUELO:
			_paso_vuelo(delta)
		ESTADO_IR_PUNTO:
			_paso_ir_punto(delta)
		ESTADO_ATERRIZANDO:
			_paso_aterrizando(delta)
		ESTADO_CAMINANDO:
			_paso_caminando(delta)
		ESTADO_PAUSA_SUELO:
			_paso_pausa_suelo(delta)
		ESTADO_DESPEGUE_VERTICAL:
			_paso_despegue_vertical(delta)
		ESTADO_DESPEGUE_CURVA:
			_paso_despegue_curva(delta)
	_watchdog_recuperacion(delta)
	_animar(delta)


## ¿Está en un estado de aire? (para el watchdog y la animación)
func _en_aire() -> bool:
	return _estado in [ESTADO_VUELO, ESTADO_IR_PUNTO, ESTADO_ATERRIZANDO, ESTADO_DESPEGUE_VERTICAL, ESTADO_DESPEGUE_CURVA]


## ── WATCHDOG GLOBAL: nunca más atrapada ──────────────────────
## Si en un estado de AIRE no se mueve durante UMBRAL_QUIETA segundos,
## fuerza DESPEGUE VERTICAL (ascenso recto: ninguna pared lateral puede
## bloquearlo). Este es el camino de recuperación imparable de la v8.
## v8b: la quietud se mide en una VENTANA (posición de hace N s), no por
## frame — por frame con umbral 0.05 declaraba "quieta" a 2.9 m/s.
func _watchdog_recuperacion(delta: float) -> void:
	if not _en_aire():
		_t_quieto = 0.0
		_ult_pos = global_position
		return
	_t_quieto += delta
	if _t_quieto >= UMBRAL_QUIETA:
		if global_position.distance_to(_ult_pos) < 0.35:
			print("[Gaviota] QUIETA EN EL AIRE %.1fs → despegue vertical forzado" % UMBRAL_QUIETA)
			_t_quieto = 0.0
			_ult_pos = global_position
			_iniciar_despegue_vertical()
		else:
			_t_quieto = 0.0
			_ult_pos = global_position


func _iniciar_despegue_vertical() -> void:
	motion_mode = MOTION_MODE_FLOATING
	_estado = ESTADO_DESPEGUE_VERTICAL
	_finalizando = false
	var modelo := get_node_or_null("Modelo")
	if modelo:
		modelo.position.y = 0.0
		modelo.rotation.x = 0.0
	rotation.z = 0.0
	rotation.x = 0.0


## ── VUELO ─────────────────────────────────────────────
func _paso_vuelo(delta: float) -> void:
	motion_mode = MOTION_MODE_FLOATING
	var objetivo: Vector3
	if _t_desvio > 0.0:
		# DESVÍO ACTIVO: volar hacia el punto de escape (lejos del muro)
		_t_desvio -= delta
		objetivo = _desvio
	else:
		var vel_ang: float = _dir_orbita * velocidad_vuelo / radio_vuelo
		_ang_orbita = wrapf(_ang_orbita + vel_ang * delta, 0.0, TAU)
		objetivo = _pos_en_orbita(_ang_orbita)
	var hacia := objetivo - global_position
	velocity = hacia.normalized() * velocidad_vuelo
	move_and_slide()
	# PRINCIPIO 2 — ESQUIVAR, NO EMPUJAR: muro REAL (contacto continuo,
	# v8c: los escalones de voxel reportan wall unos frames y NO cuentan)
	# → punto de escape en la normal del muro (vuela ALREDEDOR).
	if is_on_wall():
		_t_muro += delta
		if _t_muro > 0.8:
			_t_muro = 0.0
			var n: Vector3 = get_wall_normal()
			_desvio = global_position + Vector3(n.x, 0.15, n.z).normalized() * 7.0
			_t_desvio = 1.6
	else:
		_t_muro = 0.0
	# Orientación y banking
	var tangente := hacia.normalized() if hacia.length() > 0.01 else Vector3(1, 0, 0)
	tangente.y = 0.0
	if tangente.length_squared() > 0.001:
		var objetivo_yaw: float = atan2(tangente.x, tangente.z) - PI / 2.0
		rotation.y = lerp_angle(rotation.y, objetivo_yaw, 4.0 * delta)
	rotation.z = lerp(rotation.z, -0.30 * _dir_orbita * (0.0 if _t_desvio > 0.0 else 1.0), 1.5 * delta)
	# Ciclo de aterrizaje random
	if _t >= _t_prox_aterrizaje and _t_desvio <= 0.0:
		_t_prox_aterrizaje = _t + randf_range(8.0, 18.0)
		# v10: elegir PUNTO DE ATERRIZAJE ANTES de bajar (patron de ave
		# real): primero volar hasta estar directamente ENCIMA del punto
		# (a altura de crucero), recien entonces caer VERTICAL PURO. Cero
		# avance horizontal en la caida = cero cara lateral de voxel que
		# empujar = imposible arar contra laderas (los 20+ "muro REAL" del
		# log v9 eran el planeo Fase-1 arando laderas).
		var ang_p: float = randf() * TAU
		var radio_p: float = randf_range(8.0, 26.0)
		_punto_aterrizaje = Vector3(
			clampf(centro_isla.x + cos(ang_p) * radio_p, centro_isla.x - 40.0, centro_isla.x + 40.0),
			0.0,
			clampf(centro_isla.y + sin(ang_p) * radio_p, centro_isla.y - 40.0, centro_isla.y + 40.0))
		_punto_aterrizaje.y = _altura_suelo_en(_punto_aterrizaje)
		_estado = ESTADO_IR_PUNTO
		rotation.z = 0.0
		print("[Gaviota] aterrizaje elegido en (%.0f, %.0f) — voy al punto" % [
			_punto_aterrizaje.x, _punto_aterrizaje.z])


## ── IR AL PUNTO (v10): volar a altura de crucero hasta estar
## directamente ENCIMA del punto elegido. Recien entonces caer.
func _paso_ir_punto(delta: float) -> void:
	motion_mode = MOTION_MODE_FLOATING
	var sobre_punto := Vector3(_punto_aterrizaje.x, global_position.y, _punto_aterrizaje.z)
	var hacia := sobre_punto - global_position
	if hacia.length() < 1.5:
		_estado = ESTADO_ATERRIZANDO
		_t_descenso = 0.0
		_t_muro = 0.0
		print("[Gaviota] sobre el punto — iniciando caida vertical")
		return
	velocity = hacia.normalized() * velocidad_vuelo
	velocity.y = clampf(velocity.y, -1.0, 1.5)  # mantener altura de crucero
	move_and_slide()
	# Esquivar muros REALES de camino al punto (mismo filtro de tiempo)
	if is_on_wall():
		_t_muro += delta
		if _t_muro > 0.8:
			_t_muro = 0.0
			var n: Vector3 = get_wall_normal()
			_desvio = global_position + Vector3(n.x, 0.15, n.z).normalized() * 7.0
			_t_desvio = 1.6
	else:
		_t_muro = 0.0
	var tangente := hacia.normalized()
	tangente.y = 0.0
	if tangente.length_squared() > 0.001:
		var objetivo_yaw: float = atan2(tangente.x, tangente.z) - PI / 2.0
		rotation.y = lerp_angle(rotation.y, objetivo_yaw, 4.0 * delta)


## ── DESCENSO VERTICAL PURO (v10) ───────────────────────
## v10c — FIX CRÍTICO (la línea perdida): la v10 borró sin querer el
## `motion_mode = MOTION_MODE_GROUNDED` de la v8b al reescribir el
## descenso. Heredaba FLOATING del IR_PUNTO y la doc es explícita: en
## FLOATING "todas las colisiones se reportan como pared" → el PROPIO
## SUELO era reportado como muro (log v10b: 17/17 "muro en caida
## vertical" = el piso voxel, 0 aterrizajes). Con GROUNDED el contacto
## con la cara superior ES floor: is_on_floor() aterriza.
func _paso_aterrizando(delta: float) -> void:
	motion_mode = MOTION_MODE_GROUNDED  # ← LA LÍNEA PERDIDA (v10c)
	_t_descenso += delta
	velocity = Vector3(0.0, -2.2, 0.0)
	move_and_slide()
	if is_on_floor():
		_aterrizar()
		return
	# Solo un muro LATERAL real (bloque flotante raro) aborta
	if is_on_wall():
		_t_muro += delta
		if _t_muro > 0.8:
			_t_muro = 0.0
			print("[Gaviota] muro en caida vertical → aborto")
			_estado = ESTADO_VUELO
			_t_prox_aterrizaje = _t + randf_range(6.0, 14.0)
			velocity = Vector3.UP * 2.0
			return
	else:
		_t_muro = 0.0
	# Watchdog: caida de mas de 10 s sin tocar (fallback del locator)
	if _t_descenso > 10.0:
		print("[Gaviota] caida muy larga → aborto")
		_estado = ESTADO_VUELO
		_t_prox_aterrizaje = _t + randf_range(6.0, 14.0)


func _aterrizar() -> void:
	velocity = Vector3.ZERO
	_estado = ESTADO_CAMINANDO
	motion_mode = MOTION_MODE_GROUNDED
	floor_snap_length = 0.3
	_caminatas = 0
	_caminatas_objetivo = int(randf_range(1.0, 4.0))
	_finalizando = false
	_salto_pendiente = false
	_hops = 0
	_reintentos_dir = 0
	_t_muro = 0.0
	_t_sin_muro = 0.0
	rotation.z = 0.0
	rotation.x = 0.0
	var modelo := get_node_or_null("Modelo")
	if modelo:
		modelo.position.y = ALTURA_TIERRA
		modelo.rotation.x = -POSE_PARADA
	print("[Gaviota] ATERRIZADA en el suelo — caminatas: %d" % _caminatas_objetivo)
	_elegir_destino_suelo()


## ── TIERRA ─────────────────────────────────────────────
## v9: destino con FILTRO DE PENDIENTE — en terreno voxel caminar hacia
## terreno mas alto es chocar escalones sin parar. Solo acepta destinos
## con elevacion similar (±1.5 m, 8 intentos); fallback: cualquiera corto.
func _elegir_destino_suelo() -> void:
	var y_actual: float = _altura_suelo_en(global_position)
	for intento in 8:
		var ang: float = randf() * TAU
		var radio: float = randf_range(3.0, 9.0)
		var x: float = clampf(global_position.x + cos(ang) * radio, centro_isla.x - 40.0, centro_isla.x + 40.0)
		var z: float = clampf(global_position.z + sin(ang) * radio, centro_isla.y - 40.0, centro_isla.y + 40.0)
		var candidato := Vector3(x, global_position.y, z)
		if absf(_altura_suelo_en(candidato) - y_actual) <= 1.5:
			_destino_suelo = candidato
			_estado = ESTADO_CAMINANDO
			return
	var ang2: float = randf() * TAU
	_destino_suelo = Vector3(
		clampf(global_position.x + cos(ang2) * 5.0, centro_isla.x - 40.0, centro_isla.x + 40.0),
		global_position.y,
		clampf(global_position.z + sin(ang2) * 5.0, centro_isla.y - 40.0, centro_isla.y + 40.0))
	_estado = ESTADO_CAMINANDO


func _paso_caminando(delta: float) -> void:
	motion_mode = MOTION_MODE_GROUNDED
	floor_snap_length = 0.3
	var a_plano := Vector3(_destino_suelo.x, global_position.y, _destino_suelo.z)
	var hacia := a_plano - global_position
	if hacia.length() < 0.4:
		if _caminatas >= _caminatas_objetivo:
			_estado = ESTADO_PAUSA_SUELO
			_t_pausa = randf_range(6.0, 14.0)
			_finalizando = true
		else:
			_estado = ESTADO_PAUSA_SUELO
			_t_pausa = randf_range(1.5, 4.0)
		return
	var dir := hacia.normalized()
	velocity = dir * velocidad_caminata
	if _salto_pendiente:
		# v9: HOP de ave sobre el escalon de voxel (arco manual)
		_v_salto -= 14.0 * delta
		velocity.y = _v_salto
	else:
		velocity.y = -1.2  # contacto constante con el piso
	move_and_slide()
	if _salto_pendiente and _v_salto < 0.0 and is_on_floor():
		_salto_pendiente = false  # aterrizo el saltito
	# v9: seguir el terreno (patron villager §10.16) — y al ras de la
	# superficie, sin clamps agresivos; solo cuando pisa (no en pleno hop)
	if not _salto_pendiente:
		var y_suelo: float = _altura_suelo_en(global_position)
		global_position.y = lerpf(global_position.y, y_suelo, 0.2)
	# v9 ANTI-BLOQUEO POR TIEMPO (fix del bug "toca el piso y despega"):
	# en v8 el is_on_wall() sumaba _caminatas CADA FRAME — aterrizada
	# pegada a un escalon cualquiera acumulaba 5-8 en 0.1 s y despegaba
	# al instante. Ahora: el terreno voxel son escalones de 1 m y un AVE
	# los SALTA (hop tras 0.3 s de muro). 3 hops sin avanzar → nueva
	# direccion; 3 direcciones → recien ahi despega (vuela sobre todo).
	if is_on_wall():
		_t_muro += delta
		_t_sin_muro = 0.0
		if _t_muro > 0.3 and not _salto_pendiente:
			_t_muro = 0.0
			_salto_pendiente = true
			_v_salto = 5.4  # apex ~1.04 m con g manual 14: salva escalon de 1 m
			_hops += 1
			if _hops >= 3:
				_hops = 0
				_reintentos_dir += 1
				if _reintentos_dir >= 3:
					_reintentos_dir = 0
					print("[Gaviota] tierra muy bloqueada → despego")
					_iniciar_despegue_vertical()
					return
				_elegir_destino_suelo()
	else:
		_t_muro = 0.0
		_t_sin_muro += delta
		if _t_sin_muro > 0.5:
			_hops = 0  # avanzo bien: la cuenta de saltos se reinicia
	if dir.length_squared() > 0.001:
		var objetivo_yaw: float = atan2(dir.x, dir.z) - PI / 2.0
		rotation.y = lerp_angle(rotation.y, objetivo_yaw, 6.0 * delta)


func _paso_pausa_suelo(delta: float) -> void:
	motion_mode = MOTION_MODE_GROUNDED
	velocity = Vector3.ZERO
	velocity.y = -2.0
	move_and_slide()
	_t_pausa -= delta
	if _t_pausa <= 0.0:
		if _finalizando:
			print("[Gaviota] despegando tras la posada larga")
			_iniciar_despegue_vertical()
		else:
			_caminatas += 1
			_elegir_destino_suelo()


## ── DESPEGUE en 2 fases ────────────────────────────────
## Fase 1 VERTICAL: sube recto 3.5 m. Ninguna pared lateral bloquea el
## movimiento vertical → recuperación imparable (principio 4).
func _paso_despegue_vertical(_delta: float) -> void:
	motion_mode = MOTION_MODE_FLOATING
	var y_objetivo: float = _altura_suelo_en(global_position) + 3.5
	velocity = Vector3(0.0, 4.5, 0.0)
	move_and_slide()
	# Aleteo potente hacia arriba (la animación lo lee por estado)
	if global_position.y >= y_objetivo:
		_estado = ESTADO_DESPEGUE_CURVA
		# Retomar la órbita por el ángulo MÁS CERCANO a la posición actual
		_ang_orbita = atan2(global_position.z - centro_isla.y,
							global_position.x - centro_isla.x)


## Fase 2 CURVA: trepar en espiral suave hasta la altura de órbita.
func _paso_despegue_curva(delta: float) -> void:
	motion_mode = MOTION_MODE_FLOATING
	var objetivo := _pos_en_orbita(_ang_orbita)
	var hacia := objetivo - global_position
	if hacia.length() < 2.0 or global_position.y >= objetivo.y - 1.0:
		_estado = ESTADO_VUELO
		_t_prox_aterrizaje = _t + randf_range(8.0, 18.0)
		print("[Gaviota] en vuelo de nuevo")
		return
	velocity = hacia.normalized() * velocidad_vuelo * 0.8
	velocity.y = maxf(velocity.y, 2.5)  # siempre trepando
	move_and_slide()
	# Esquivar durante la trepada también
	if is_on_wall():
		var n: Vector3 = get_wall_normal()
		_desvio = global_position + Vector3(n.x, 0.2, n.z).normalized() * 7.0
		_t_desvio = 1.6
		_estado = ESTADO_VUELO
		var tangente := hacia.normalized()
		tangente.y = 0.0
		if tangente.length_squared() > 0.001:
			rotation.y = lerp_angle(rotation.y, atan2(tangente.x, tangente.z) - PI / 2.0, 4.0 * delta)


## ── ANIMACIÓN ─────────────────────────────────────────
func _guardar_rotaciones_base() -> void:
	for a in _alas:
		_base_rot[a] = a.rotation


func _animar(delta: float) -> void:
	match _estado:
		ESTADO_VUELO, ESTADO_IR_PUNTO:
			if _t_desvio > 0.0:
				_bater_alas(delta, 3.5, 0.40, false)  # maniobra de esquive
			else:
				_bater_alas(delta, 2.2, 0.28, false)  # planeo
		ESTADO_ATERRIZANDO:
			_bater_alas(delta, 5.0, 0.45, false)      # frenando el flare
		ESTADO_DESPEGUE_VERTICAL, ESTADO_DESPEGUE_CURVA:
			_bater_alas(delta, 9.0, 0.65, false)      # impulso
		ESTADO_CAMINANDO, ESTADO_PAUSA_SUELO:
			_bater_alas(delta, 0.0, 0.0, true)        # plegadas + parada
			var modelo := get_node_or_null("Modelo")
			if modelo:
				var activo: bool = _estado == ESTADO_CAMINANDO
				modelo.rotation.x = -POSE_PARADA + absf(sin(_t * 6.0)) * (0.03 if activo else 0.0)
				modelo.position.y = ALTURA_TIERRA + absf(sin(_t * 6.0)) * (0.008 if activo else 0.0)


func _bater_alas(_delta: float, frecuencia: float, amplitud: float, plegar: bool) -> void:
	if _alas.size() == 2:
		for i in 2:
			var ala := _alas[i]
			var lado: int = -1 if i == 0 else 1
			var base: Vector3 = _base_rot.get(ala, ala.rotation)
			if plegar:
				var objetivo_z: float = base.z + PLEGADO_ALA * -lado
				ala.rotation.z = lerp(ala.rotation.z, objetivo_z, 3.0 * _delta)
				ala.rotation.x = lerp(ala.rotation.x, 0.15, 3.0 * _delta)
			else:
				ala.rotation.z = base.z
				ala.rotation.x = base.x + sin(_t * frecuencia) * amplitud * -lado
