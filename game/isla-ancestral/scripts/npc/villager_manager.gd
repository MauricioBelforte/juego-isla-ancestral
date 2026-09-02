extends Node

## Módulo 19: NPC y Vecinos — VillagerManager (autoload)
##
## Autoridad de la población: detecta interacción F, gestiona NPCs activos,
## emite señales para M20/M21/M64.
##
## Iteración mudanzas (glm-5.3-flash / Kilo Code, 2026-09-01, diseño §2.1/§3.2):
##  - Ciclo de vida: propuesta (visitante) → aprobación del jugador → llegada
##    al día siguiente 08:00 (EventBus/calendar) → vida cotidiana → aviso de
##    partida → (aceptar/rechazar) → partida libera plaza.
##  - Rechazo de partida: enfriamiento 30 días sin nuevos avisos (checklist).
##  - Catálogo data-driven en res://data/villagers/ (VillagerProfile .tres).
##  - Persistencia ISaveProvider M59: sección "npc".
##  - Emite EventBus.npc.npc_moved_in (M07) al llegar un vecino (M20/M21 consumen).

signal poblacion_cambio(lista_activa: Array)
signal regalo_recibido(vecino: Node, objeto_id: String)
signal interaccion_exitosa(vecino: Node)
## Señales del diseño §3.2 (mudanzas)
signal mudanza_propuesta(candidato_id: String)
signal mudanza_aprobada(candidato_id: String, llegada_dia: int)
signal mudanza_cancelada(candidato_id: String)
signal vecino_llego(candidato_id: String)
signal aviso_partida(vecino_id: String)
signal vecino_partio(vecino_id: String)

const RANGO_DETECTAR: float = 3.0
const POBLACION_MAX: int = 10
const HORA_LLEGADA: int = 8
## Días de enfriamiento tras rechazar una partida (checklist M19)
const ENFRIAMIENTO_PARTIDA: int = 30
## Día absoluto de partida pendiente por vecino (aviso → partida efectiva)
const DIA_PARTIDA_DEFAULT: int = 1
## P1: población de arranque al primer día (diseño P1: 6 vecinos)
const POBLACION_ARRANQUE: int = 6
## P26: memoria máxima de interacciones por vecino (rotativa, cap suave)
const MEMORIA_MAX: int = 20

var _activos: Array[Node] = []
var _target_actual: Node = null

## ── Estado de mudanzas (persistible) ──────────────────
## Catálogo cargado de data/villagers/: perfil_id -> VillagerProfile
var _catalogo: Dictionary = {}
## Candidatos con propuesta activa (visitantes): perfil_id -> true
var _visitantes: Dictionary = {}
## Mudanzas aprobadas pendientes de llegada: perfil_id -> dia_llegada (absoluto)
var _llegadas_pendientes: Dictionary = {}
## Vecinos registrados con partida aprobada pendiente: vecino_id -> dia_partida
var _partidas_pendientes: Dictionary = {}
## Vecinos con aviso de partida activo (esperando respuesta): vecino_id -> true
var _avisos_partida: Dictionary = {}
## Enfriamiento tras rechazo: vecino_id -> dia_absoluto_habilitado
var _enfriamiento_partida: Dictionary = {}
## Hogares asignados: vecino_id/candidato_id -> parcela_id (índice)
var _hogares: Dictionary = {}

## ── P26: memoria de interacciones (iter. 3) ─────────────
## vecino_id -> Array[Dictionary {dia, tipo, detalle}] (rotativa, MEMORIA_MAX)
var _memoria: Dictionary = {}

## ── P11/P12/P24: agenda horaria para M64 (iter. 3) ─────
## Franjas del diseño P12 (cozy, sin grindeo)
const FRANJAS_DIA := [
	{"desde": 6, "hasta": 8, "actividad": "desayuno"},
	{"desde": 8, "hasta": 12, "actividad": "trabajo"},
	{"desde": 12, "hasta": 14, "actividad": "comida"},
	{"desde": 14, "hasta": 18, "actividad": "trabajo_ocio"},
	{"desde": 18, "hasta": 22, "actividad": "social"},
	{"desde": 22, "hasta": 6, "actividad": "dormir"},
]


func _ready() -> void:
	print("[VillagerManager] Inicializado (población max: %d)" % POBLACION_MAX)
	_cargar_catalogo()
	_registrar_proveedor_guardado()
	_suscribir_tiempo()
	# P1 iter. 3: población de arranque (deferred: la escena Main aún no existe
	# durante el bootstrap de autoloads; diferimos un frame al árbol listo)
	call_deferred("poblar_arranque")


## ── Catálogo (data/villagers/) ─────────────────────────

func _cargar_catalogo() -> void:
	_catalogo.clear()
	var dir := DirAccess.open("res://data/villagers")
	if dir == null:
		push_warning("[M19] Directorio data/villagers no encontrado")
		return
	for archivo in dir.get_files():
		if not archivo.ends_with(".tres"):
			continue
		var perfil := load("res://data/villagers/" + archivo)
		if perfil != null and perfil.get("id") != null and str(perfil.get("id")) != "":
			_catalogo[str(perfil.get("id"))] = perfil
	print("[M19] Catálogo de vecinos: %d perfiles" % _catalogo.size())


func catalogo_count() -> int:
	return _catalogo.size()


## ── Tiempo (M29/M30): llegada 08:00 y partidas ─────────

func _suscribir_tiempo() -> void:
	var gt := get_node_or_null("/root/GameTime")
	if gt != null and gt.has_signal("hora_cambio"):
		gt.hora_cambio.connect(_on_hora_cambio)


func _on_hora_cambio(hora: int) -> void:
	if hora != HORA_LLEGADA:
		return
	_asegurar_dia()
	# Llegadas aprobadas: activar vecino (lógica de población)
	for candidato_id in _llegadas_pendientes.keys():
		if int(_llegadas_pendientes[candidato_id]) <= _dia_absoluto_actual():
			_llegadas_pendientes.erase(candidato_id)
			_visitantes.erase(candidato_id)
			_asignar_hogar(candidato_id)
			vecino_llego.emit(candidato_id)
			var bus := get_node_or_null("/root/EventBus")
			if bus != null and bus.npc.has_signal("npc_moved_in"):
				bus.npc.npc_moved_in.emit(candidato_id, "aurora")
			print("[M19] %s llegó a la isla (hogar=%s)" % [candidato_id, str(_hogares.get(candidato_id, "?"))])
	# Partidas aprobadas: liberar plaza
	for vecino_id in _partidas_pendientes.keys():
		if int(_partidas_pendientes[vecino_id]) <= _dia_absoluto_actual():
			_partidas_pendientes.erase(vecino_id)
			_avisos_partida.erase(vecino_id)
			_hogares.erase(vecino_id)
			vecino_partio.emit(vecino_id)
			print("[M19] %s partió de la isla" % vecino_id)


func _dia_absoluto_actual() -> int:
	var gt := get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("dia_absoluto"):
		return int(gt.dia_absoluto())
	return 1


func _asegurar_dia() -> void:
	# Los Dictionarys con días se limpian de entradas vencidas en _on_hora_cambio;
	# acá solo garantizamos que exista un día válido para consultas.
	if _dia_absoluto_actual() < 1:
		pass


## ── Mudanzas: propuesta → aprobación → llegada (diseño §2.1) ──

## Propone un candidato como visitante (si hay plaza y no está ya en proceso).
func proponer_mudanza(candidato_id: String) -> bool:
	if not plaza_libre():
		return false
	if not _catalogo.has(candidato_id):
		return false
	if _visitantes.has(candidato_id) or _llegadas_pendientes.has(candidato_id):
		return false
	_visitantes[candidato_id] = true
	mudanza_propuesta.emit(candidato_id)
	print("[M19] Mudanza propuesta: %s (visitante)" % candidato_id)
	return true


## El jugador aprueba: agenda la llegada para el día siguiente 08:00.
func aprobar_mudanza(candidato_id: String) -> bool:
	if not _visitantes.has(candidato_id):
		return false
	var llegada := _dia_absoluto_actual() + 1
	_llegadas_pendientes[candidato_id] = llegada
	mudanza_aprobada.emit(candidato_id, llegada)
	print("[M19] Mudanza aprobada: %s llega el día %d a las %02d:00" % [candidato_id, llegada, HORA_LLEGADA])
	return true


## Cancela en cualquier fase (propuesta/aprobada): checklist "3 fases".
func cancelar_mudanza(candidato_id: String) -> bool:
	var estaba := false
	if _visitantes.has(candidato_id):
		_visitantes.erase(candidato_id)
		estaba = true
	if _llegadas_pendientes.has(candidato_id):
		_llegadas_pendientes.erase(candidato_id)
		estaba = true
	if estaba:
		mudanza_cancelada.emit(candidato_id)
		print("[M19] Mudanza cancelada: %s" % candidato_id)
	return estaba


## ── Partida (aviso → aceptar/rechazar) ─────────────────

## Anuncia que un vecino quiere partir (aviso 1 día antes).
func anunciar_partida(vecino_id: String) -> bool:
	_asegurar_dia()
	if _avisos_partida.has(vecino_id) or _partidas_pendientes.has(vecino_id):
		return false
	# Enfriamiento activo: sin nuevos avisos (checklist)
	if _enfriamiento_partida.has(vecino_id) and _dia_absoluto_actual() < int(_enfriamiento_partida[vecino_id]):
		return false
	var vecino: Node = obtener_vecino(vecino_id)
	if vecino == null:
		return false
	_avisos_partida[vecino_id] = true
	aviso_partida.emit(vecino)
	print("[M19] Aviso de partida: %s" % vecino_id)
	return true


## El jugador acepta la partida: se programa para el día siguiente.
func aceptar_partida(vecino_id: String) -> bool:
	if not _avisos_partida.has(vecino_id):
		return false
	_avisos_partida.erase(vecino_id)
	_partidas_pendientes[vecino_id] = _dia_absoluto_actual() + 1
	print("[M19] Partida aceptada: %s parte el día %d" % [vecino_id, int(_partidas_pendientes[vecino_id])])
	return true


## El jugador rechaza: permanece con enfriamiento de 30 días.
func rechazar_partida(vecino_id: String) -> bool:
	if not _avisos_partida.has(vecino_id):
		return false
	_avisos_partida.erase(vecino_id)
	_enfriamiento_partida[vecino_id] = _dia_absoluto_actual() + ENFRIAMIENTO_PARTIDA
	print("[M19] Partida rechazada: %s permanece (enfriamiento %d días)" % [vecino_id, ENFRIAMIENTO_PARTIDA])
	return true


## ¿Puede volver a avisar partida? (consulta para M64/M21)
func puede_avisar_partida(vecino_id: String) -> bool:
	_asegurar_dia()
	if _enfriamiento_partida.has(vecino_id):
		return _dia_absoluto_actual() >= int(_enfriamiento_partida[vecino_id])
	return true


## ── Hogares ────────────────────────────────────────────

func _asignar_hogar(vecino_id: String) -> void:
	# Asignación simple: primer índice libre (parcelas 0..POBLACION_MAX-1)
	var ocupadas := {}
	for h in _hogares.values():
		ocupadas[int(h)] = true
	for i in range(POBLACION_MAX):
		if not ocupadas.has(i):
			_hogares[vecino_id] = i
			return


func hogar_de(vecino_id: String) -> int:
	return int(_hogares.get(vecino_id, -1))


## Retorna diccionario vecino_id → Vector3 (posición del hogar en el mundo).
## Usado por M64 state_machine para respawn de emergencia.
func get_hogares() -> Dictionary:
	var resultado: Dictionary = {}
	var locator = get_node_or_null("/root/TerrainLocator")
	for vecino_id in _hogares:
		var parcela_idx: int = int(_hogares[vecino_id])
		var pos := _calcular_posicion_parcela(parcela_idx, locator)
		resultado[vecino_id] = pos
	return resultado


## Retorna la posición de spawn (Vector3) para un índice de parcela.
## Usado por M64 npc_agent para get_location_position("casa").
func get_spawn_for_parcela(parcela_idx: int) -> Vector3:
	var locator = get_node_or_null("/root/TerrainLocator")
	return _calcular_posicion_parcela(parcela_idx, locator)


## Calcula la posición mundo de una parcela a partir de su índice.
## Grid circular: radio 48, separación 16, centrado en isla.
func _calcular_posicion_parcela(idx: int, locator: Node) -> Vector3:
	var radio := 48.0
	var separacion := 16.0
	var angulo := (idx * 2.0 * PI) / POBLACION_MAX
	var x := radio * cos(angulo)
	var z := radio * sin(angulo)
	var y := 1.0
	if locator:
		var h: int = locator.get_height(int(x), int(z))
		if h >= 0:
			y = float(h)
	return Vector3(x, y, z)


## ── Consultas de población ─────────────────────────────

func visitantes() -> Array:
	return _visitantes.keys()


func llegadas_pendientes() -> Dictionary:
	return _llegadas_pendientes.duplicate()


func avisos_partida_activos() -> Array:
	return _avisos_partida.keys()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		# Solo interactuar si el inventario NO está abierto
		var player := _obtener_jugador()
		if player and player.has_method("get"):
			var inv_open: bool = player.get("_inventory_open") if player.get("_inventory_open") != null else false
			if not inv_open:
				_intentar_interaccion()


## ── Detección de objetivo ──────────────────────────────

func _intentar_interaccion() -> void:
	var player := _obtener_jugador()
	if not player:
		return

	var mejor: Node = null
	var mejor_dist: float = RANGO_DETECTAR + 1.0

	for villager in _activos:
		if not is_instance_valid(villager):
			continue
		if villager.has_method("esta_disponible") and not villager.esta_disponible():
			continue
		var dist: float = player.global_position.distance_to(villager.global_position)
		if dist < mejor_dist:
			# Raycast vóxel: no interactuar a través de paredes (checklist 86)
			if not hay_linea_de_vision(player.global_position, villager.global_position):
				continue
			mejor_dist = dist
			mejor = villager

	if mejor:
		_target_actual = mejor
		mejor.interactuar(player)
		interaccion_exitosa.emit(mejor)
		print("[VillagerManager] Interacción con %s (dist=%.2f)" % [mejor.name, mejor_dist])
	else:
		_target_actual = null


func detectar_objetivo(pos_jugador: Vector3) -> Node:
	var mejor: Node = null
	var mejor_dist: float = RANGO_DETECTAR + 1.0

	for villager in _activos:
		if not is_instance_valid(villager):
			continue
		if villager.has_method("esta_disponible") and not villager.esta_disponible():
			continue
		var dist: float = pos_jugador.distance_to(villager.global_position)
		if dist < mejor_dist:
			# Raycast vóxel: no interactuar a través de paredes (checklist 86)
			if not hay_linea_de_vision(pos_jugador, villager.global_position):
				continue
			mejor_dist = dist
			mejor = villager
	return mejor


## ── Gestión de población ───────────────────────────────

func registrar_villager(villager: Node) -> void:
	if villager not in _activos:
		_activos.append(villager)
		poblacion_cambio.emit(_activos)
		print("[VillagerManager] %s registrado (%d activos)" % [villager.name, _activos.size()])


func desregistrar_villager(villager: Node) -> void:
	_activos.erase(villager)
	poblacion_cambio.emit(_activos)
	print("[VillagerManager] %s desregistrado (%d activos)" % [villager.name, _activos.size()])


func obtener_activos() -> Array:
	return _activos.duplicate()


func obtener_vecino(id: String) -> Node:
	for v in _activos:
		if is_instance_valid(v) and v.name == id:
			return v
	return null


func plaza_libre() -> bool:
	return _activos.size() < POBLACION_MAX


func obtener_poblacion_actual() -> int:
	return _activos.size()


## ── Regalos ────────────────────────────────────────────

func entregar_regalo(vecino_id: String, objeto_id: String) -> void:
	var vecino: Node = obtener_vecino(vecino_id)
	if vecino and vecino.has_method("recibir_regalo"):
		vecino.recibir_regalo(objeto_id)
		regalo_recibido.emit(vecino, objeto_id)
		# P26 iter. 3: registrar en la memoria del vecino
		registrar_interaccion(vecino_id, "regalo", objeto_id)


## ── Utilidades ─────────────────────────────────────────

## ── P26: memoria de interacciones (iter. 3) ────────────

## Registra una interacción en la memoria del vecino (rotativa, MEMORIA_MAX).
## tipo: "regalo" | "charla" | "hito" | "mudanza" | ...
func registrar_interaccion(vecino_id: String, tipo: String, detalle: String) -> bool:
	if not _memoria.has(vecino_id):
		_memoria[vecino_id] = []
	var lista: Array = _memoria[vecino_id]
	lista.append({
		"dia": _dia_absoluto_actual(),
		"tipo": tipo,
		"detalle": detalle,
	})
	while lista.size() > MEMORIA_MAX:
		lista.pop_front()
	return true


## Memoria completa de un vecino (para M20/M21/M64: reacciones y continuidad)
func memoria_de(vecino_id: String) -> Array:
	return (_memoria.get(vecino_id, []) as Array).duplicate()


## Resumen consultable: cuántas veces por tipo (p. ej. regalos recibidos)
func memoria_conteo(vecino_id: String, tipo: String) -> int:
	var n := 0
	for m in _memoria.get(vecino_id, []):
		if String(m.get("tipo", "")) == tipo:
			n += 1
	return n


## Hook del ciclo existente: regalo recibido → memoria (P26 + RF5)
func _memorizar_regalo(vecino: Node, objeto_id: String) -> void:
	var id := vecino_id_de(vecino)
	if id != "":
		registrar_interaccion(id, "regalo", objeto_id)


## Resuelve el id del vecino desde el nodo (por nombre de escena)
func vecino_id_de(vecino: Node) -> String:
	if vecino == null:
		return ""
	return String(vecino.name)


## ── P11/P12/P24: agenda horaria determinista (iter. 3) ──

## Agenda completa del día para un vecino (contrato hacia M64, P23/P24):
## franja → actividad, combinando rutina_diaria del perfil con variación
## PRNG determinista (seed día+id, M29): mismo día → misma agenda.
func agenda_dia(vecino_id: String, dia_absoluto: int = -1) -> Dictionary:
	var perfil: Resource = _catalogo.get(vecino_id, null)
	if perfil == null:
		return {}
	var dia := dia_absoluto if dia_absoluto >= 0 else _dia_absoluto_actual()
	# PRNG determinista estilo M29: seed = dia_absoluto + hash(id)
	var rng := RandomNumberGenerator.new()
	rng.seed = dia * 100000 + int(abs(hash(vecino_id)) % 100000)
	var rutina: Dictionary = perfil.get("rutina_diaria") if "rutina_diaria" in perfil else {}
	var agenda := {}
	for franja in FRANJAS_DIA:
		var clave := "%02d:00" % int(franja.get("desde", 0))
		var actividad := "libre"
		if rutina.has(clave):
			actividad = String(rutina[clave])
		else:
			actividad = String(franja.get("actividad", "libre"))
		# Variación suave (15% de las franjas cambian a "ocio" — cozy, sin caos)
		if rng.randf() < 0.15 and actividad != "dormir":
			actividad = "ocio"
		agenda[clave] = actividad
	return agenda


## Actividad ACTUAL del vecino según la hora de juego (M64 la consulta cada tick)
func actividad_actual(vecino_id: String) -> String:
	var agenda := agenda_dia(vecino_id)
	if agenda.is_empty():
		return "libre"
	var hora := _hora_actual()
	for franja in FRANJAS_DIA:
		var desde := int(franja.get("desde", 0))
		var hasta := int(franja.get("hasta", 0))
		var en_franja: bool
		if desde <= hasta:
			en_franja = hora >= desde and hora < hasta
		else:
			en_franja = hora >= desde or hora < hasta  # franja nocturna 22-6
		if en_franja:
			var clave := "%02d:00" % desde
			return String(agenda.get(clave, "libre"))
	return "libre"


func _hora_actual() -> int:
	var gt := get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("get_hora"):
		return int(gt.get_hora())
	var cal := get_node_or_null("/root/TimeCalendar")
	if cal != null and cal.has_method("get_hora"):
		return int(cal.get_hora())
	return 12


## ── P1: población de arranque (iter. 3) ────────────────

## Activa los primeros POBLACION_ARRANQUE perfiles del catálogo (día 1).
## Idempotente: solo rellena hasta completar el arranque si hay plaza.
func poblar_arranque() -> Array:
	var activados: Array = []
	if _activos.size() >= POBLACION_ARRANQUE:
		return activados
	# Orden determinista por id del catálogo
	var ids := _catalogo.keys()
	ids.sort()
	for id in ids:
		if _activos.size() >= POBLACION_ARRANQUE:
			break
		if _visitantes.has(id) or _llegadas_pendientes.has(id):
			continue
		if obtener_vecino(String(id)) != null:
			continue  # ya activo
		var perfil: Resource = _catalogo[id]
		var villager := _spawn_vecino_de_perfil(String(id), perfil)
		if villager != null:
			activados.append(String(id))
			registrar_interaccion(String(id), "mudanza", "vecino inicial (arranque P1)")
	if activados.size() > 0:
		print("[M19] Población de arranque: %d vecinos activados (P1)" % activados.size())
	return activados


## Instancia un villager desde el perfil (reutiliza villager.tscn si existe,
## sino crea un Node3D con nombre del id para que el manager lo gestione).
## En headless sin escena raíz (bootstrap de autoloads con --script), registra
## un nodo lógico huérfano del manager: la población lógica queda coherente y
## la visual la completará M64/escena cuando exista árbol.
func _spawn_vecino_de_perfil(id: String, perfil: Resource) -> Node:
	var escena := load("res://scenes/npc/villager.tscn") if ResourceLoader.exists("res://scenes/npc/villager.tscn") else null
	var nodo: Node = null
	if escena != null:
		nodo = escena.instantiate()
	else:
		nodo = Node3D.new()
	nodo.name = id
	# Posición sobre terreno según su parcela asignada (P13: hogares)
	if _activos.size() < POBLACION_MAX:
		var parcela := _activos.size()
		_asignar_hogar_directo(id, parcela)
	# Snap al terreno con TerrainLocator (nunca flotar — regla 167/07 §10.15)
	if nodo is Node3D:
		var pos := _calcular_posicion_parcela(int(_hogares.get(id, 0)), get_node_or_null("/root/TerrainLocator"))
		nodo.global_position = pos + Vector3(0, 1, 0)
	# Sincronizar con el perfil (el villager.tscn tomará colores/rutinas)
	if "profile" in nodo:
		nodo.profile = perfil
	# Agregar a la escena actual si hay árbol (bootstrap puede no tenerla aún)
	var root_scene := get_tree().current_scene
	if root_scene != null:
		root_scene.add_child(nodo)
		registrar_villager(nodo)
		return nodo
	# Headless sin escena: registrar lógicamente con el manager como padre
	add_child(nodo)
	registrar_villager(nodo)
	return nodo


func _asignar_hogar_directo(vecino_id: String, parcela: int) -> void:
	_hogares[vecino_id] = parcela


## ── Altura del terreno (ya existente) ───────────────────

## Obtiene la altura del suelo en una posición XZ usando el generador de mundo.
## Retorna la coordenada Y de la superficie, o -1.0 si no encontró nada.
func get_ground_height(xz_pos: Vector2) -> float:
	# Estrategia anti-flotamiento: usar el TerrainLocator (generador real del mundo),
	# nunca crear un generador propio con radio hardcodeado.
	var locator = get_node_or_null("/root/TerrainLocator")
	if locator:
		var h: int = locator.get_height(int(xz_pos.x), int(xz_pos.y))
		if h >= 0:
			return float(h)
	return -1.0


## Posiciona un nodo sobre el terreno en la posición XZ dada.
## Si no encuentra suelo, deja la posición actual.
func colocar_sobre_terreno(nodo: Node3D, xz_pos: Vector2) -> void:
	var h: float = get_ground_height(xz_pos)
	if h >= 0.0:
		nodo.global_position = Vector3(xz_pos.x, h, xz_pos.y)


## ── Persistencia (ISaveProvider M59, diseño §5) ────────
## Solo estado (no perfiles .tres). IDs huérfanos se eliminan con log al cargar.

func _registrar_proveedor_guardado() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)


func get_section_name() -> String:
	return "npc"


func get_save_data() -> Dictionary:
	# ⚠️ Deep copy de TODOS los Dictionary/Array: son por referencia en Godot,
	# sin duplicate() un _clear() posterior vaciaría también el save capturado
	# (bug de aliasing detectado en test iter. 3).
	var memoria_copy := {}
	for k in _memoria:
		memoria_copy[String(k)] = (_memoria[k] as Array).duplicate(true)
	return {
		"visitantes": _visitantes.keys().duplicate(),
		"llegadas": _llegadas_pendientes.duplicate(true),
		"partidas": _partidas_pendientes.duplicate(true),
		"avisos": _avisos_partida.keys().duplicate(),
		"enfriamientos": _enfriamiento_partida.duplicate(true),
		"hogares": _hogares.duplicate(true),
		"memoria": memoria_copy,
	}


func restore_save_data(data: Dictionary) -> void:
	_visitantes.clear()
	for v in data.get("visitantes", []):
		var vid := String(v)
		if _catalogo.has(vid):
			_visitantes[vid] = true
		else:
			print("[M19] Huérfano eliminado al cargar: visitante %s" % vid)
	_llegadas_pendientes.clear()
	var llegadas: Dictionary = data.get("llegadas", {})
	for k in llegadas:
		if _catalogo.has(String(k)):
			_llegadas_pendientes[String(k)] = int(llegadas[k])
		else:
			print("[M19] Huérfano eliminado al cargar: llegada %s" % String(k))
	_partidas_pendientes.clear()
	var partidas: Dictionary = data.get("partidas", {})
	for k in partidas:
		_partidas_pendientes[String(k)] = int(partidas[k])
	_avisos_partida.clear()
	for a in data.get("avisos", []):
		_avisos_partida[String(a)] = true
	_enfriamiento_partida.clear()
	var enf: Dictionary = data.get("enfriamientos", {})
	for k in enf:
		_enfriamiento_partida[String(k)] = int(enf[k])
	_hogares.clear()
	var hog: Dictionary = data.get("hogares", {})
	for k in hog:
		_hogares[String(k)] = int(hog[k])
	# P26 iter. 3: memoria (ids de catálogo o históricos válidos; cap MEMORIA_MAX)
	_memoria.clear()
	var mem: Dictionary = data.get("memoria", {})
	for k in mem:
		var vid := String(k)
		if _catalogo.has(vid) or _hogares.has(vid) or _visitantes.has(vid):
			var lista: Array = []
			for m in mem[k]:
				lista.append({
					"dia": int(m.get("dia", 0)),
					"tipo": String(m.get("tipo", "")),
					"detalle": String(m.get("detalle", "")),
				})
			while lista.size() > MEMORIA_MAX:
				lista.pop_front()
			_memoria[vid] = lista


## ── Línea de visión (raycast vóxel, checklist ítem 86) ──
## Muestreo DDA a lo largo de la línea jugador→vecino usando VoxelTool
## (patrón de raycast de M13/follow_camera). Si algún voxel del camino
## es sólido (no aire), la visión está bloqueada. Sin terrain → true.

func hay_linea_de_vision(desde: Vector3, hasta: Vector3) -> bool:
	var terrain := _obtener_terrain()
	if terrain == null or not terrain.has_method("get_voxel_tool"):
		return true
	var vt = terrain.get_voxel_tool()
	if vt == null:
		return true
	var delta := hasta - desde
	var dist := delta.length()
	if dist < 0.5:
		return true
	var paso := delta / dist
	var t := 0.4  # arranca dentro (evita el voxel del propio jugador)
	while t < dist - 0.4:  # termina antes del vecino (evita su propio cuerpo)
		var p := desde + paso * t
		var voxel := vt.get_voxel(Vector3i(int(floor(p.x)), int(floor(p.y)), int(floor(p.z))))
		if int(voxel) != 0:
			return false
		t += 0.5
	return true


func _obtener_terrain() -> VoxelTerrain:
	var root = get_tree().current_scene
	if root:
		var t = root.get_node_or_null("VoxelTerrain")
		if t is VoxelTerrain:
			return t
	# Fallback: buscar desde la raíz del árbol
	if get_tree().root:
		var t2 = get_tree().root.get_node_or_null("Main/VoxelTerrain")
		if t2 is VoxelTerrain:
			return t2
	# Fallback general (bootstrap carga la escena manualmente)
	if get_tree().root:
		for hijo in get_tree().root.get_children():
			if hijo.name.begins_with("Isla") or hijo.name == "Main":
				var t3 = hijo.get_node_or_null("VoxelTerrain")
				if t3 is VoxelTerrain:
					return t3
	return null


func _obtener_jugador() -> Node:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	return null
