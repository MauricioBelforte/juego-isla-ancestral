extends Node3D

## M36: ESCENA DEMO v13 — gaviota parada con las alas CERRADAS (fix de ejes)
##
## Historia del bug (v11/v12): el plegado nunca funciono porque se seteaban
## ejes de rotacion equivocados. En Godot el GLB queda: pico +X, arriba +Y,
## span de las alas ±Z (dump_glb.py: Ala_L Z 0→+0.82, Ala_R -0.82→0), y la
## composicion de Euler es R = Ry·Rx·Rz (Z se aplica PRIMERO al vector).
##
## La v12 seteaba rotation.y (barrido) + rotation.x ("roll"). Pero X es el
## eje de la CUERDA (pico→cola): al aplicarse antes que Y, ese "roll" pone
## el span VERTICAL — ala izquierda (+Z) hacia ARRIBA (nuca) y ala derecha
## (-Z) hacia ABAJO (garganta), por el espejo. Era exactamente lo que el
## usuario vio: "ala derecha por la nuca, ala izquierda desde la garganta".
##
## v13 — ejes CORRECTOS para este GLB:
##   rotation.z  = ROLL alrededor del eje del span (Z): verticaliza la
##                 superficie del ala contra el flanco. Se aplica primero.
##   rotation.y  = YAW que barre el span (±Z) hacia atras (-X: la cola).
##                 Se aplica despues y SI encuentra el ala horizontal.
##   Pose parada: el pitch morro-arriba es rotation.z POSITIVO del modelo
##                 (rotar alrededor del eje del span = eje del cuerpo ahi),
##                 no rotation.x (que era un roll lateral).

const GLB := "res://assets/3d/alta/36-Fauna_gaviota.glb"

# PLEGADO — mismos ángulos de la v12, ejes corregidos:
const YAW_PLEGADO := 1.45   # barrido del span hacia atras (~83°: cerradas)
const ROLL_PLEGADO := 1.50  # superficie vertical contra el flanco
# v13f — pose parada casi HORIZONTAL (0.10 rad): el GLB tiene las patas
# cortas (pose recogida de vuelo) y con 0.45 rad la cola caia 0.20 m POR
# DEBAJO de las patas — imposible que ambas toquen: asentar por patas
# enterraba la cola, asentar por el minimo global dejaba las patas
# flotando 20 cm (reporte del usuario v13e). Una gaviota posada real
# esta casi horizontal; el pitch alto lo da el cuello, no el cuerpo.
# v15 (feedback usuario: "mas erguida — pecho arriba, colita pegada al
# suelo, patas quietas"): con las patas LARGAS (0.18, v14) ya hay margen
# para inclinar el cuerpo sin enterrar la cola: 0.42 rad baja la cola
# ~10 cm (queda ~5 cm del suelo). Las patas NO giran: _desplegar_patas
# las fuerza verticales EN MUNDO (quaternion), ajenas al pitch del
# cuerpo, y _calibrar_altura reasienta los pies tras el giro.
# SNAPSHOTS: 0.10 = aprobada v14 (volver aca si sale mal) · 0.45 = v13
# (enterraba cola con patas cortas — NO reusar).
const POSE_PARADA := 0.42   # pitch morro-arriba ERGUIDA (v15)
# v13c — asentado real contra el suelo: la punta del ala plegada apunta a
# atras-abajo por el pitch del cuerpo (0.45 rad baja la cola ~0.35); sin
# compensacion las puntas y las patas se clavan en la arena.
# v13d — el pitch del plegado se ELIGE POR MEDICION (no signo fijo): la
# composicion roll+yaw+pitch hace que el MISMO angulo.x suba un ala y
# hunda la otra (y negarlo por lado invierte la que estaba bien — reporte
# del usuario "una ala la plego, la otra quedo apuntando para arriba").
# Solucion: busqueda de 41 valores en [-1,+1] rad y se toma el que deja
# la punta del span a REL_Y_OBJETIVO sobre el hombro (medido con el
# global_transform real, que ya incluye roll+yaw+pose del cuerpo).
const PITCH_BUSQ_MIN := -1.0
const PITCH_BUSQ_MAX := 1.0
const PITCH_BUSQ_PASOS := 41
# SNAPSHOT v15: rel_y 0.05 (aprobada en pose 0.10; con cuerpo erguido 0.42
# el usuario pide alas MAS BAJAS) — volver aca si sale mal.
# v15b: −0.10 (le gustó) → v15c: −0.20, caida plena pegada al flanco.
const REL_Y_OBJETIVO := -0.20  # punta del ala plegada vs hombro

var _alas: Array[Node3D] = []
var _puntas: Array[Node3D] = []
var _patas: Array[Node3D] = []
var _pies: Array[Node3D] = []
var _base_rot: Dictionary = {}
var _t: float = 0.0
var _modelo: Node3D = null
var _diag_impreso := false
var _asentada := false
var _altura_calibrada := -0.28
var _pitch_elegido := [0.0, 0.0]  # v13d: pitch.x del plegado por ala


func _ready() -> void:
	var mundo := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.55, 0.75, 0.95)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.9, 0.9, 0.85)
	env.ambient_light_energy = 0.8
	mundo.environment = env
	add_child(mundo)

	var sol := DirectionalLight3D.new()
	sol.rotation_degrees = Vector3(-55, -30, 0)
	sol.light_energy = 1.2
	sol.shadow_enabled = true
	add_child(sol)

	var suelo := MeshInstance3D.new()
	var malla := BoxMesh.new()
	malla.size = Vector3(40, 0.5, 40)
	suelo.mesh = malla
	suelo.position = Vector3(0, -0.25, 0)
	var mat_suelo := StandardMaterial3D.new()
	mat_suelo.albedo_color = Color(0.72, 0.65, 0.45)  # arena
	suelo.material_override = mat_suelo
	add_child(suelo)

	var escena: PackedScene = load(GLB)
	_modelo = escena.instantiate()
	_modelo.name = "Modelo"
	add_child(_modelo)
	# v13c — el piso de la demo es la cara superior del BoxMesh (y=0):
	# calibrar la altura del origen con el BOUNDING REAL del modelo ya
	# plegado (espera 2 frames a que el lerp converge) y asentar a +0.005.
	# El -0.28 fijo de v13a dejaba las patas ~3 cm DENTRO de la arena.
	_modelo.position = Vector3(0, -0.28, 0)  # arranque; recalibrado abajo

	_resolver_nodos()
	_guardar_rotaciones_base()

	var cam := Camera3D.new()
	add_child(cam)
	cam.position = Vector3(1.30, 0.75, 1.30)
	cam.look_at(Vector3(0, 0.45, 0))
	print("[Demo v13] gaviota lista — alas: %d, puntas: %d, patas: %d, pies: %d" % [_alas.size(), _puntas.size(), _patas.size(), _pies.size()])


func _resolver_nodos() -> void:
	var nombres: Array[String] = []
	_recolectar(_modelo, nombres)
	print("[Demo v13] hijos del GLB: %s" % str(nombres))
	for sufijo in ['Ala_L', 'Ala_R']:
		var a := _buscar(_modelo, sufijo)
		if a:
			_alas.append(a)
	for i in 2:
		var p := _buscar(_modelo, "Punta_%d" % i)
		if p and _alas.size() == 2:
			_puntas.append(p)
			var ala_padre: Node3D = _alas[1] if i == 1 else _alas[0]
			var off: Vector3 = ala_padre.global_transform.affine_inverse() * p.global_transform.origin
			p.get_parent().remove_child(p)
			ala_padre.add_child(p)
			p.position = off
	# v14 — PATAS Y PIES: re-parentar cada pie a su pata (en vuelo van
	# pegados al extremo; al rotar la pata hacia abajo el pie acompana).
	for i in 2:
		var pata := _buscar(_modelo, "Pata_%d" % i)
		if pata:
			_patas.append(pata)
			var pie := _buscar(_modelo, "Pie_%d" % i)
			if pie:
				_pies.append(pie)
				var off: Vector3 = pata.global_transform.affine_inverse() * pie.global_transform.origin
				pie.get_parent().remove_child(pie)
				pata.add_child(pie)
				pie.position = off


func _recolectar(nodo: Node, acc: Array[String]) -> void:
	for h in nodo.get_children():
		acc.append(h.name)
		_recolectar(h, acc)


func _buscar(desde: Node, sufijo: String) -> Node3D:
	if desde == null:
		return null
	for hijo in desde.get_children():
		if hijo is Node3D and hijo.name.to_lower().contains(sufijo.to_lower()):
			return hijo
		var r := _buscar(hijo, sufijo)
		if r:
			return r
	return null


func _guardar_rotaciones_base() -> void:
	for a in _alas:
		_base_rot[a] = a.rotation


## v13d — Buscar el pitch (rotation.x) del plegado de cada ala POR
## MEDICION: pruebo PITCH_BUSQ_PASOS valores en el rango y elijo el que
## deja la punta del span (punto del mesh a 0.82 del hombro) mas cerca
## de REL_Y_OBJETIVO sobre el hombro en Y de mundo. La busqueda usa el
## global_transform real del ala (ya plegada en roll/yaw y con la pose
## parada del cuerpo), asi la composicion de Euler no se adivina: se
## mide. Al final restaura la rotacion previa (el lerp del _process
## converge al valor elegido).
func _elegir_pitch_plegado() -> void:
	for i in _alas.size():
		var ala: Node3D = _alas[i]
		var lado: int = -1 if i == 0 else 1
		var rot_previa: Vector3 = ala.rotation
		# punta del span en LOCAL del ala (0.82 hacia su lado)
		var punta_local := Vector3(0.0, 0.0, 0.60 * (1 if lado < 0 else -1))
		var mejor_pitch := 0.0
		var mejor_err := INF
		for s in PITCH_BUSQ_PASOS:
			var p: float = lerpf(PITCH_BUSQ_MIN, PITCH_BUSQ_MAX,
					float(s) / float(PITCH_BUSQ_PASOS - 1))
			ala.rotation.x = p
			# Godot compone al leer global_transform: no hace falta
			# esperar un frame.
			var punta_mundo: Vector3 = ala.global_transform * punta_local
			var hombro_mundo: Vector3 = ala.global_transform.origin
			var rel_y: float = punta_mundo.y - hombro_mundo.y
			var err: float = absf(rel_y - REL_Y_OBJETIVO)
			if err < mejor_err:
				mejor_err = err
				mejor_pitch = p
		ala.rotation = rot_previa
		_pitch_elegido[i] = mejor_pitch
		print("[Demo v13d] ala %d: pitch elegido %.2f (err %.3f, rel_y obj %.2f)" % [
			i, mejor_pitch, mejor_err, REL_Y_OBJETIVO])


## v13c — Medir el punto mas bajo del modelo YA PLEGADO (en mundo) y
## mover el origen para que ese punto quede a +0.005 (apoyada, no clavada).
## v13f — se asienta por las PATAS, no por el min global: con el morro
## arriba (pose parada 0.45 rad) la COLA baja y era ella la que tocaba
## primero, dejando las patas (recogidas, pose de vuelo del GLB)
## flotando en el aire. Asiento los dedos de las patas al ras; si algun
## otro punto (cola/vientre) queda por debajo, se imprime para decidir.
## Se llama a los ~2.6 s, cuando el plegado y el pitch ya convergieron.
func _calibrar_altura() -> void:
	var min_patas := INF
	var min_resto := INF
	# v14f — recorrer TODOS los descendientes (los pies son hijos de las
	# patas tras el re-parenting; v13f solo media hijos directos y los
	# pies quedaban ~1 cm por debajo sin medir).
	var cola: Array[Node3D] = [_modelo]
	while not cola.is_empty():
		var nodo: Node3D = cola.pop_back()
		for h in nodo.get_children():
			if h is Node3D:
				cola.append(h)
		if nodo is MeshInstance3D and nodo != _modelo:
			var es_pata: bool = nodo.name.to_lower().contains("pata") or nodo.name.to_lower().contains("pie")
			var aabb: AABB = (nodo as MeshInstance3D).get_aabb()
			for cx in [aabb.position.x, aabb.end.x]:
				for cy in [aabb.position.y, aabb.end.y]:
					for cz in [aabb.position.z, aabb.end.z]:
						var p: Vector3 = nodo.global_transform * Vector3(cx, cy, cz)
						if es_pata:
							min_patas = minf(min_patas, p.y)
						else:
							min_resto = minf(min_resto, p.y)
	if is_finite(min_patas):
		_altura_calibrada = _modelo.position.y - min_patas + 0.005
		var resto_al_suelo: float = min_resto - min_patas if is_finite(min_resto) else 0.0
		print("[Demo v13f] patas/pies y=%.3f → origen %.3f | resto (cola/vientre) queda %+.3f respecto de las patas (negativo=tocaria primero)" % [
			min_patas, _altura_calibrada, resto_al_suelo])


func _process(delta: float) -> void:
	_t += delta
	# ── PLEGADO v13 (ejes corregidos) ─────────────────────────
	# Orden de aplicacion de Godot (R = Ry·Rx·Rz, Z primero):
	#   1) rotation.z: roll alrededor de ±Z (el eje del span) → pone la
	#      superficie del ala VERTICAL, pegada al flanco. El signo
	#      DEBE diferir por lado para que ambas caigan hacia el cuerpo:
	#      girar +Z CCW visto desde +Z; el ala L (span +Z) gira su cuerda
	#      con signo +, el ala R (span -Z) con signo -.
	#   2) rotation.y: yaw que barre el span hacia atras. Mismo signo
	#      por lado NO: el span L vive en +Z y el R en -Z — para llevar
	#      AMBOS hacia -X el yaw es IGUAL en signo (rot Y mueve +Z→+X
	#      y -Z→-X con angulo negativo... verificado en el DIAG de los
	#      2 s: se imprime la Y REAL y se ajusto con el volcado).
	# En la practica: yaw con signo por lado calculado del span:
	#   span +Z → rotation.y = +YAW (lleva +Z hacia -X es -? — el DIAG
	#   decide; se usa el signo que PONE la punta cerca de la cola).
	var k: float = clampf(4.0 * delta, 0.0, 1.0)
	for i in _alas.size():
		var ala := _alas[i]
		var lado: int = -1 if i == 0 else 1
		# v13b — ROLL con MISMO signo en ambas alas (fix residual de v13):
		# la cuerda original vive en ±X; con roll negado por lado la cuerda
		# izquierda quedaba abajo y la derecha ARRIBA (una plegada, una
		# levantada) y el manto de la derecha miraba al cuerpo. Mismo signo
		# (−ROLL): ambas cuerdas abajo, ambos mantos grises hacia afuera.
		ala.rotation.z = lerpf(ala.rotation.z, -ROLL_PLEGADO, k)
		# YAW si se niega por lado: Ala_L (span +Z) necesita yaw − y Ala_R
		# (span −Z) yaw + para que AMBAS puntas vayan a −X (la cola).
		ala.rotation.y = lerpf(ala.rotation.y, YAW_PLEGADO * lado, k)
		# v13d — PITCH por MEDICION (elegido una vez al converger, en
		# _elegir_pitch_plegado): busco el angulo.x que deja la punta del
		# span a la altura de pose de ave posada. Cero signos a mano.
		ala.rotation.x = lerpf(ala.rotation.x, _pitch_elegido[i], k)
	# ── v14: PATAS — de pose de vuelo (recogidas atras) a VERTICALES ──
	# Dump GLB: el eje del cono de la pata vive en local Y (la conversion
	# Y-up del export alineo el eje del cono con Y del nodo). v14c lo ponia
	# en Z y la pata quedaba ACOSTADA (horizontal, DIAG min_y = centro).
	# Quaternion de rotacion mas corta del eje actual a (0,-1,0) mundo.
	for i in _patas.size():
		var pata := _patas[i]
		var eje_mundo: Vector3 = (pata.global_basis * Vector3(0.0, 1.0, 0.0)).normalized()
		var objetivo := Vector3(0.0, -1.0, 0.0)
		if eje_mundo.length() > 0.001 and eje_mundo.dot(objetivo) < 0.999:
			var q_giro := Quaternion(eje_mundo, objetivo)
			var q_actual: Quaternion = pata.global_transform.basis.get_rotation_quaternion()
			var q_final: Quaternion = q_giro * q_actual
			var objetivo_local: Quaternion = (pata.get_parent() as Node3D).global_transform.basis.get_rotation_quaternion().inverse() * q_final
			pata.quaternion = pata.quaternion.slerp(objetivo_local, k)
	# v14e — PIES: aplanarlos contra el suelo. Heredan la rotacion de la
	# pata vertical y su pad queda DE CANTO; se los aplana al plano XY
	# del mundo (yaw del modelo incluido) rotando su eje mayor a horizontal.
	for i in _pies.size():
		var pie := _pies[i]
		var eje_largo: Vector3 = pie.global_basis * Vector3(1.0, 0.0, 0.0)  # pad largo en X
		var plano := Vector3(eje_largo.x, 0.0, eje_largo.z)
		if plano.length() > 0.001:
			var objetivo := plano.normalized()
			var eje_actual := eje_largo.normalized()
			if eje_actual.dot(objetivo) < 0.999:
				var q_giro := Quaternion(eje_actual, objetivo)
				var q_actual: Quaternion = pie.global_transform.basis.get_rotation_quaternion()
				var q_final: Quaternion = q_giro * q_actual
				var objetivo_local: Quaternion = (pie.get_parent() as Node3D).global_transform.basis.get_rotation_quaternion().inverse() * q_final
				pie.quaternion = pie.quaternion.slerp(objetivo_local, k)
	# ── Pose parada + head-bob ────────────────────────────────
	# Pitch morro-arriba: rotacion alrededor del eje del span del CUERPO
	# (= Z en este GLB, el cuerpo vive en el plano XY). rotation.x era un
	# roll lateral (volcaba la gaviota de costado).
	var paso: float = absf(sin(_t * 4.0))
	_modelo.rotation.z = POSE_PARADA - 0.05 * paso  # morro arriba + bob
	# v13c — altura calibrada (ver _calibrar_altura): base de las patas al
	# ras de la arena SIN clavarlas (el bob vive en la escala del paso).
	_modelo.position.y = _altura_calibrada + 0.015 * paso
	# v13e — asentar DESPUES de que el pitch elegido converge (v13d calibraba
	# a 1.2s, con las puntas todavia bajas → min_y subestimado → FLOTABA).
	# El pitch elegido es ±0.60 y converge a k=4/delta; 2.6s es post-
	# convergencia. Orden: elegir pitch (1.2s) → calibrar altura (2.6s).
	if not _asentada and _t > 2.6:
		_asentada = true
		_elegir_pitch_plegado()
		_calibrar_altura()
	# La gaviota gira lenta sobre si misma para verla de todos los angulos
	_modelo.rotate_y(0.35 * delta)
	# ── DIAGNOSTICO a los 2 s (convergencia del lerp) ─────────
	if not _diag_impreso and _t > 2.0:
		_diag_impreso = true
		print("[Demo v13] DIAG a los 2s — alas: %d" % _alas.size())
		for i in _alas.size():
			var ala := _alas[i]
			var lado_d: int = -1 if i == 0 else 1
			var ok_roll: bool = absf(ala.rotation.z - (-ROLL_PLEGADO)) < 0.2
			var ok_yaw: bool = absf(ala.rotation.y - YAW_PLEGADO * lado_d) < 0.2
			var ok_pitch: bool = absf(ala.rotation.x - _pitch_elegido[i]) < 0.05
			# Verificacion GEOMETRICA: ¿a donde quedo la punta del ala?
			# v14: span reducido a 0.60 en Blender (dump actualizado).
			var nodo: Node3D = ala
			var fin_local := Vector3(0.0, 0.0, -0.60 if lado_d > 0 else 0.60)
			var fin_mundo: Vector3 = nodo.global_transform * fin_local
			var origen_mundo: Vector3 = nodo.global_transform.origin
			var rel: Vector3 = fin_mundo - origen_mundo
			print("[Demo v13] ala %d: rotZ=%.3f rotY=%.3f rotX=%.3f — %s | punta: (%.2f, %.2f, %.2f) rel_x=%.2f rel_y=%.2f (atras=negativo, arriba=positivo)" % [
				i, ala.rotation.z, ala.rotation.y, ala.rotation.x,
				"PLEGADA OK" if (ok_roll and ok_yaw and ok_pitch) else "NO PLEGO",
				fin_mundo.x, fin_mundo.y, fin_mundo.z, rel.x, rel.y])
