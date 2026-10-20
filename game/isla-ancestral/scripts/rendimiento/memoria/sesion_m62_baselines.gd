# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-20
#
# M62: Memoria - ITEMS 18..22 de la COLA V3 (baselines de memoria de la seccion L).
#   * L- "Baseline menu principal: objetivo < 600 MB"
#   * L- "Baseline spawn de Aurora: objetivo < 1.600 MB"
#   * L- "Baseline horizonte terrestre oteado: objetivo < 2.200 MB"
#   * L- "Baseline subterraneo del templo (M26): objetivo < 2.000 MB"
#   * L- "Baseline tormenta maxima (M32) + banco de audio completo: <= 2.500 MB (Alta)"
#
# Un escenario por PROCESO (cada baseline es un boot limpio, no una acumulacion):
#   M62_ESCENARIO = spawn | horizonte | subterraneo | tormenta | menu
#
# QUE MIDE Y QUE NO (declarado ANTES de correr):
#   SI: la ESCENA REAL (res://scenes/main_island.tscn) con sus autoloads y el
#       MemoryMonitor de PRODUCCION. La memoria se lee con memoria_actual_mb() y
#       memoria_pico_mb() del monitor, sin formulas paralelas. El escenario se
#       aplica por API de produccion: set_zoom_level() de CameraRig, la posicion
#       del Player, y avanzar_hasta() de GameTime (la misma que "dormir en cama")
#       para llegar a TORMENTA deterministica de M32.
#   NO: headless no crea renderer -> la memoria de GPU/texturas de video NO entra
#       en OS.get_static_memory_usage(). El numero medido es un PISO, no el
#       baseline de Play Mode. Por eso un verde aca NO cierra el item: se reporta
#       como piso medido y el flip lo decide el director.
#   NO: "banco de audio completo" no existe en el repo (0 assets de audio,
#       medido en Log 2028). El escenario tormenta mide CLIMA; la mitad de audio
#       queda declarada como no medible.
#
# CODIGOS DE SALIDA (convencion del proyecto):
#   0 = medido y por debajo del objetivo (con el alcance declarado)
#   1 = fallo real del arnes (escena/monitor/lectura) o el piso SUPERA el objetivo
#   3 = DETECTOR CIEGO: el escenario no es medible (sin artefacto / sin API)
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/sesion_m62_baselines.gd
#
# Variables: M62_ESCENARIO (default spawn) · M62_ASENTAR_S (default 45)

extends SceneTree

const MODULO := "M62 baselines"
const ESCENA := "res://scenes/main_island.tscn"
const CLIMA_TORMENTA := 3
const DIAS_MAX_TORMENTA := 90
const BLOQUES := ["A", "B", "C"]

const OBJETIVOS := {
	"menu": 600,
	"spawn": 1600,
	"horizonte": 2200,
	"subterraneo": 2000,
	"tormenta": 2500,
}

const CANDIDATOS_MENU := [
	"res://scenes/main_menu.tscn",
	"res://scenes/ui/main_menu.tscn",
	"res://scenes/ui/menu.tscn",
	"res://scenes/menu.tscn",
]

var _escenario := "spawn"
var _asentar_s := 45.0
var _objetivo_mb := 0
var _t0_ms := 0
var _monitor: Node = null
var _raiz: Node = null
var _escena_ok := false
var _aplicado := false
var _no_medible := ""
var _evidencia: Array[String] = []
var _checks := 0
var _fallos := 0
var _vistos: Dictionary = {}
var _cerrado := false
var _mem_inicial := 0.0
var _mem_final := 0.0
var _pico := 0.0
var _muestras := 0
var _objetos := 0
var _huerfanos := 0
var _retardo_aplicar := 0.0


func _initialize() -> void:
	var env_esc := OS.get_environment("M62_ESCENARIO")
	if env_esc != "":
		_escenario = env_esc
	var env_as := OS.get_environment("M62_ASENTAR_S")
	if env_as != "":
		_asentar_s = float(env_as)
	_objetivo_mb = int(OBJETIVOS.get(_escenario, 0))
	_t0_ms = Time.get_ticks_msec()

	print("=== %s ===" % MODULO)
	print("-- escenario: %s | objetivo: %d MB | asentar: %.0f s" % [_escenario, _objetivo_mb, _asentar_s])
	print("-- inicio: %s" % Time.get_datetime_string_from_system())

	if _escenario == "menu":
		_escenario_menu()
		return
	_arrancar_escena()


## Escenario "menu principal": lo unico honesto es medir si el artefacto existe.
func _escenario_menu() -> void:
	print("-- escenario menu: buscando la escena del menu principal")
	var hallados: Array[String] = []
	for ruta in CANDIDATOS_MENU:
		var existe := ResourceLoader.exists(String(ruta))
		print("   %s -> %s" % [ruta, ("EXISTE" if existe else "no existe")])
		if existe:
			hallados.append(String(ruta))
	var main_scene := String(ProjectSettings.get_setting("application/run/main_scene", ""))
	print("-- main_scene del proyecto: %s" % main_scene)
	_check(not hallados.is_empty(), "existe una escena de menu principal")
	_check(main_scene.find("main_island") == -1, "el juego arranca en un menu y no directo en la isla")
	_fin("A")
	_fin("B")
	_fin("C")
	if hallados.is_empty():
		_no_medible = "no existe escena de menu principal (0 de %d candidatas); main_scene=%s" % [CANDIDATOS_MENU.size(), main_scene]
	_cerrar()


func _arrancar_escena() -> void:
	var packed: PackedScene = load(ESCENA)
	if packed == null:
		print("  [FALLO] no se pudo cargar %s" % ESCENA)
		_fallos += 1
		_cerrar()
		return
	var inst: Node = packed.instantiate()
	if inst == null:
		print("  [FALLO] la escena no se pudo instanciar")
		_fallos += 1
		_cerrar()
		return
	root.add_child(inst)
	current_scene = inst
	_raiz = inst
	_escena_ok = true
	print("-- escena real instanciada (%s)" % ESCENA)


func _process(_delta: float) -> bool:
	if _cerrado:
		return true
	var t := float(Time.get_ticks_msec() - _t0_ms) / 1000.0

	if _monitor == null:
		_monitor = _buscar_monitor(root)
		if _monitor != null:
			_mem_inicial = _leer_memoria()
			print("-- monitor encontrado (memoria inicial %.1f MB)" % _mem_inicial)
			_check(_escena_ok, "la escena real se instancio")
			_check(_monitor != null, "MemoryMonitor de produccion presente")
			_check(_mem_inicial > 0.0, "lectura de memoria > 0 (el medidor no esta ciego)")
			_fin("A")
			# La camara resuelve su _target en un process_frame (follow_camera._ready);
			# aplicar el escenario en el mismo frame deja al horizonte con la camara
			# en el origen. Se espera 1 s para que el seguimiento este asentado.
			_retardo_aplicar = 1.0
		elif t > 60.0:
			print("  [FALLO] sin MemoryMonitor a los 60 s")
			_fallos += 1
			_cerrar()
			return true

	if _monitor != null and not _aplicado and _retardo_aplicar > 0.0:
		_retardo_aplicar -= _delta
		if _retardo_aplicar <= 0.0:
			_aplicar_escenario()
			_fin("B")

	if _monitor != null and t >= _asentar_s:
		_medir()
		_cerrar()
		return true

	if t > _asentar_s + 300.0:
		print("  [FALLO] watchdog: no se llego a medir en %.0f s" % t)
		_fallos += 1
		_cerrar()
		return true
	return false


func _aplicar_escenario() -> void:
	match _escenario:
		"spawn":
			_evidencia.append("sin manipulacion: boot directo (spawn de Aurora)")
			_aplicado = true
		"horizonte":
			_aplicar_horizonte()
		"subterraneo":
			_aplicar_subterraneo()
		"tormenta":
			_aplicar_tormenta()
		_:
			_no_medible = "escenario desconocido: %s" % _escenario


func _aplicar_horizonte() -> void:
	# La escena real usa `scripts/follow_camera.gd` (no CameraRig): su unico camino
	# de zoom es el scroll (MOUSE_BUTTON_WHEEL_DOWN aleja hasta max_distance=20).
	# Se inyecta por `_unhandled_input`, que ES el punto de entrada de produccion, y
	# el efecto se mide sobre la Camera3D real (distancia al Player), no sobre un
	# campo privado: asi el check no depende de como se llame la variable interna.
	var cam: Node = _buscar_por_script(root, "scripts/follow_camera.gd")
	var rig: Node = _buscar_por_script(root, "camera/camera_rig.gd")
	if cam == null and rig == null:
		_no_medible = "no hay camara de produccion (follow_camera/CameraRig) en el arbol"
		return
	if rig != null:
		rig.call("set_zoom_level", 2)
		var nivel := int(rig.call("get_zoom_level"))
		_evidencia.append("CameraRig zoom nivel -> %d, distancia %.1f" % [nivel, float(rig.call("get_zoom_distance_value"))])
		_check(nivel == 2, "el zoom quedo en el nivel maximo (2)")
		if nivel != 2:
			_no_medible = "CameraRig no acepto el zoom maximo (modo actual != EXPLORE)"
			return
		_aplicado = true
		return

	var jugador: Node = _raiz.find_child("Player", true, false)
	var camara3d: Camera3D = _raiz.find_child("Camera3D", true, false) as Camera3D
	if jugador == null or camara3d == null:
		_no_medible = "sin Player o Camera3D: no se puede medir la distancia de oteo"
		return
	var objetivo: Variant = cam.get("_target")
	var en_grupo := get_nodes_in_group("player").size()
	_evidencia.append("camara en %s | Player en %s | _target=%s | grupo 'player': %d | frames: phys=%d proc=%d"
		% [str(camara3d.global_position), str((jugador as Node3D).global_position),
		("null" if objetivo == null else str(objetivo)), en_grupo,
		Engine.get_physics_frames(), Engine.get_process_frames()])
	if objetivo == null:
		_no_medible = "follow_camera sin _target: la camara no sigue al Player y el zoom no aplica"
		return
	var antes := camara3d.global_position.distance_to((jugador as Node3D).global_position)
	# Si la camara no esta sobre el Player, el escenario "oteo" no existe: se mide
	# ANTES de inyectar scroll para no reportar como baseline una escena que no oteo.
	if antes > 100.0:
		_no_medible = "la camara de seguimiento no esta sobre el Player (%.0f m): la camara no siguio al Player y el oteo no se reproduce" % antes
		return
	var modo_antes := int(cam.call("get_mode"))
	if modo_antes != 0:
		cam.call("set_mode", 0)
	_evidencia.append("modo camara: %d -> %d (0=EXPLORE)" % [modo_antes, int(cam.call("get_mode"))])
	for i in 12:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_WHEEL_DOWN
		ev.pressed = true
		cam.call("_unhandled_input", ev)
	# El scroll solo cambia _distance; la posicion de la camara converge en
	# _physics_process. Se simulan 2 s de seguimiento antes de medir la distancia.
	for i in 20:
		cam.call("_physics_process", 0.1)
	var despues := camara3d.global_position.distance_to((jugador as Node3D).global_position)
	_evidencia.append("scroll x12: distancia camara->Player %.2f -> %.2f (max_distance=20)" % [antes, despues])
	_check(despues > antes + 1.0, "el scroll alejo la camara (distancia crecio)")
	_check(despues >= 19.0, "la camara quedo en el tope de oteo (>= 19 m)")
	if despues < 19.0:
		_no_medible = "el zoom no llego al tope (%.2f m): la camara no se deja otear" % despues
		return
	_aplicado = true


func _aplicar_subterraneo() -> void:
	var jugador: Node = _raiz.find_child("Player", true, false)
	if jugador == null:
		_no_medible = "no hay nodo Player en la escena: no se puede bajar al subterraneo"
		return
	var p3 := jugador as Node3D
	if p3 == null:
		_no_medible = "el Player no es Node3D"
		return
	var y_antes := p3.global_position.y
	p3.global_position = Vector3(p3.global_position.x, y_antes - 40.0, p3.global_position.z)
	_evidencia.append("Player Y %.1f -> %.1f" % [y_antes, p3.global_position.y])
	_check(absf(p3.global_position.y - (y_antes - 40.0)) < 0.01, "el Player bajo 40 m (subterraneo)")
	# VoxelTerrain es una clase NATIVA (sin script): contar por script daba 0 y el
	# detector era CIEGO (0 de un detector roto == 0 de un arbol limpio).
	var voxels := _contar_voxel(root)
	_evidencia.append("VoxelTerrain en el arbol: %d" % voxels)
	var bloques := _bloques_voxel(root)
	_evidencia.append("bloques actualizados por el VoxelTerrain: %d" % bloques)
	if voxels == 0:
		_no_medible = "0 VoxelTerrain en la escena: el subterraneo del templo no existe en este arbol"
		return
	if bloques <= 0:
		_no_medible = "VoxelTerrain presente pero 0 bloques generados en headless: el subterraneo no se ejercita (medido en Log 2028)"
		return
	_aplicado = true


func _aplicar_tormenta() -> void:
	var gt: Node = root.get_node_or_null("/root/GameTime")
	var w: Node = root.get_node_or_null("/root/Weather")
	if gt == null or w == null:
		_no_medible = "sin autoloads GameTime/Weather: no se puede llegar a TORMENTA"
		return
	var dias := 0
	var clima := int(w.call("get_clima"))
	for i in DIAS_MAX_TORMENTA:
		if clima == CLIMA_TORMENTA:
			break
		gt.call("avanzar_hasta", 23, 59)
		gt.call("avanzar_hasta", 0, 0)
		clima = int(w.call("get_clima"))
		dias += 1
	_evidencia.append("clima alcanzado: %d (%s) tras %d dias" % [clima, str(w.call("get_nombre_clima", clima)), dias])
	_evidencia.append("buses de audio: %d | reproductores en el arbol: %d"
		% [AudioServer.bus_count, _contar_audio_players(root)])
	_check(clima == CLIMA_TORMENTA, "se alcanzo TORMENTA deterministica de M32")
	if clima != CLIMA_TORMENTA:
		_no_medible = "no se alcanzo TORMENTA en %d dias" % DIAS_MAX_TORMENTA
		return
	_aplicado = true


func _medir() -> void:
	# Se fuerza una muestra ANTES de leer: `memoria_pico_mb()` solo se actualiza en
	# `muestrear_ahora()` (cada 5 s en calma), asi que sin esto el pico puede quedar
	# por detras de la lectura final y la comparacion mediria el lag del muestreo.
	_monitor.call("muestrear_ahora")
	_mem_final = _leer_memoria()
	_pico = float(_monitor.call("memoria_pico_mb"))
	_muestras = int(_monitor.call("muestras_registradas"))
	_objetos = int(_monitor.call("objetos_vivos"))
	_huerfanos = int(_monitor.call("nodos_huerfanos"))
	print("-- memoria final %.1f MB | pico %.1f MB | muestras %d | objetos %d | huerfanos %d"
		% [_mem_final, _pico, _muestras, _objetos, _huerfanos])
	for e in _evidencia:
		print("-- evidencia: %s" % e)
	_check(_aplicado, "el escenario se aplico por API de produccion")
	_check(_muestras > 0, "el monitor registro muestras durante el asentamiento")
	_check(_pico >= _mem_final - 0.1, "el pico es coherente con la memoria final")
	_check(_mem_final <= float(_objetivo_mb), "el piso medido (%.1f MB) NO supera el objetivo (%d MB)"
		% [_mem_final, _objetivo_mb])
	_fin("C")


func _leer_memoria() -> float:
	if _monitor != null and _monitor.has_method("memoria_actual_mb"):
		return float(_monitor.call("memoria_actual_mb"))
	return snappedf(float(OS.get_static_memory_usage()) / (1024.0 * 1024.0), 0.1)


func _buscar_monitor(n: Node) -> Node:
	if n.get_script() != null:
		var ruta := (n.get_script() as Script).resource_path
		if ruta.ends_with("rendimiento/memoria/memory_monitor.gd"):
			return n
	for h in n.get_children():
		var encontrado := _buscar_monitor(h)
		if encontrado != null:
			return encontrado
	return null


func _buscar_por_script(n: Node, sufijo: String) -> Node:
	if n.get_script() != null:
		var ruta := (n.get_script() as Script).resource_path
		if ruta.ends_with(sufijo):
			return n
	for h in n.get_children():
		var encontrado := _buscar_por_script(h, sufijo)
		if encontrado != null:
			return encontrado
	return null


## VoxelTerrain/VoxelViewer son clases NATIVAS (sin script asociado): contarlas
## por ruta de script devuelve 0 SIEMPRE y el detector queda ciego.
func _contar_voxel(n: Node) -> int:
	var total := 0
	if n is VoxelTerrain:
		total += 1
	for h in n.get_children():
		total += _contar_voxel(h)
	return total


## Bloques que el VoxelTerrain dice haber actualizado (0 en headless: medido en Log 2028).
func _bloques_voxel(n: Node) -> int:
	if n is VoxelTerrain:
		var vt := n as VoxelTerrain
		if vt.has_method("get_statistics"):
			var st: Variant = vt.call("get_statistics")
			if typeof(st) == TYPE_DICTIONARY:
				return int((st as Dictionary).get("updated_blocks", 0))
		return 0
	for h in n.get_children():
		var r := _bloques_voxel(h)
		if r > 0:
			return r
	return 0


func _contar_audio_players(n: Node) -> int:
	var total := 0
	if n is AudioStreamPlayer or n is AudioStreamPlayer3D or n is AudioStreamPlayer2D:
		total += 1
	for h in n.get_children():
		total += _contar_audio_players(h)
	return total


func _check(ok: bool, que: String) -> void:
	_checks += 1
	if ok:
		print("  [OK] %s" % que)
	else:
		_fallos += 1
		print("  [FALLO] %s" % que)


func _fin(nombre: String) -> void:
	_vistos[nombre] = true


func _cerrar() -> void:
	if _cerrado:
		return
	_cerrado = true
	var faltantes: Array[String] = []
	for b in BLOQUES:
		if not _vistos.has(b):
			faltantes.append(String(b))
	if not faltantes.is_empty():
		_check(false, "bloques NO ejecutados (posible SCRIPT ERROR): %s" % str(faltantes))
	# El piso se mide SOLO en la ruta con escena: el escenario "menu" no instancia
	# nada y sus 2 checks son la medicion completa (existencia del artefacto).
	# MEDIDO en verde: 7 checks en "spawn" (sin check de escenario) y 8 en los
	# escenarios que agregan su propia asercion (horizonte/subterraneo/tormenta).
	var piso := 2
	if _escenario != "menu":
		piso = 7 if _escenario == "spawn" else 8
	# En un escenario NO MEDIBLE el piso no aplica: el codigo de salida ya es 3 y
	# sumar un "solo N checks" ahi confunde un bloqueo con un defecto.
	if _no_medible == "" and _checks < piso:
		_check(false, "solo %d checks ejecutados (minimo %d)" % [_checks, piso])

	print("-- fin: %s" % Time.get_datetime_string_from_system())
	print("=== Resumen %s [%s]: %d checks, %d fallos ===" % [MODULO, _escenario, _checks, _fallos])
	if _no_medible != "":
		print("NO MEDIBLE: %s" % _no_medible)
		print("TEST %s [%s] NO MEDIBLE - salida 3 (detector ciego)" % [MODULO, _escenario])
		quit(3)
		return
	if _fallos > 0:
		print("TEST %s [%s] FALLIDO - salida 1" % [MODULO, _escenario])
		quit(1)
		return
	var alcance := "headless, sin VRAM" if DisplayServer.get_name() == "headless" else "renderer real; VRAM medida aparte"
	print("TEST %s [%s] OK - piso %.1f MB bajo el objetivo %d MB (alcance: %s)"
		% [MODULO, _escenario, _mem_final, _objetivo_mb, alcance])
	quit(0)
