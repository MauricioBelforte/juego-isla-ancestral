# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-11
#
# M68 — Generador del dataset del grafo de transporte.
# Construye TransportNetwork (10 paradas, 20 rutas) y lo guarda como
# res://data/transporte/transport_network.tres (única fuente de verdad).
#
# Se genera por script (no a mano) para garantizar un .tres válido y para
# poder versionar el dataset con revisión: cualquier cambio de costes/paradas
# se hace AQUÍ y se regenera el .tres.
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/transporte/generar_red_transporte.gd

extends SceneTree

const DESTINO := "res://data/transporte/transport_network.tres"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var red := TransportNetwork.new()
	red.schema_version = 1

	# ── Paradas ─────────────────────────────────────────────
	red.stops = [
		_parada("puerto_aurora", "Puerto de Aurora", "barco", "isla_raiz", Vector3(0, 0, 0), 6, 22, true, true, &"", "poi_puerto_aurora"),
		_parada("muelle_raiz_sur", "Muelle Sur de Aurora", "muelle", "isla_raiz", Vector3(0, 0, 40), 6, 22, true, true, &"", "poi_muelle_sur"),
		_parada("plataforma_norte", "Plataforma del Norte", "dirigible", "isla_raiz", Vector3(0, 60, -30), 8, 19, true, true, &"", "poi_plataforma_norte"),
		_parada("estacion_central", "Estación Central", "tren", "isla_raiz", Vector3(20, 0, -10), 6, 21, true, true, &"", "poi_estacion_central"),
		_parada("puerto_sur", "Puerto de la Isla del Sur", "barco", "isla_sur", Vector3(0, 0, 180), 7, 21, true, true, &"", "poi_puerto_sur"),
		_parada("puerto_este", "Puerto de la Isla del Este", "barco", "isla_este", Vector3(200, 0, 0), 7, 21, true, true, &"", "poi_puerto_este"),
		_parada("puerto_norte", "Puerto de la Isla del Norte", "barco", "isla_norte", Vector3(0, 0, -200), 7, 20, true, true, &"", "poi_puerto_norte"),
		_parada("puerto_brisa", "Puerto de la Isla Brisa", "barco", "isla_brisa", Vector3(150, 0, 150), 8, 20, true, false, &"templo_brisa_abierto", "poi_puerto_brisa"),
		_parada("puerto_espejo", "Puerto de la Isla Espejo", "barco", "isla_espejo", Vector3(-200, 0, 0), 9, 19, true, true, &"", "poi_puerto_espejo"),
		_parada("puerto_festival", "Puerto del Festival", "barco", "isla_raiz", Vector3(0, 0, 60), 10, 23, true, false, &"festival_activo", "poi_puerto_festival"),
	]

	# ── Rutas (aristas dirigidas, inversas explícitas) ──────
	# Coste DIRECTO > coste de combinar (03-Diseno §3.2: incentivo a explorar).
	#   aurora→sur   = 80  >  aurora→muelle(8) + muelle→sur(60) = 68
	#   aurora→este  = 90  >  aurora→muelle(8) + muelle→este(70) = 78
	#   aurora→norte = sin directa: 2 saltos por la plataforma = 120
	red.routes = [
		# Locales de la isla raíz
		_ruta("r_aurora_muelle", "puerto_aurora", "muelle_raiz_sur", 5.0, 8, "muelle"),
		_ruta("r_muelle_aurora", "muelle_raiz_sur", "puerto_aurora", 5.0, 8, "muelle"),
		_ruta("r_aurora_estacion", "puerto_aurora", "estacion_central", 6.0, 12, "tren"),
		_ruta("r_estacion_aurora", "estacion_central", "puerto_aurora", 6.0, 12, "tren"),
		_ruta("r_aurora_plataforma", "puerto_aurora", "plataforma_norte", 10.0, 20, "dirigible"),
		_ruta("r_plataforma_aurora", "plataforma_norte", "puerto_aurora", 10.0, 20, "dirigible"),
		# Festival (temporal, M74)
		# El festival no es una estación: su puerta es la FLAG de la parada
		# (`festival_activo`), no la temporada.
		_ruta("r_muelle_festival", "muelle_raiz_sur", "puerto_festival", 8.0, 10, "barco"),
		_ruta("r_festival_muelle", "puerto_festival", "muelle_raiz_sur", 8.0, 10, "barco"),
		# Inter-isla (barco)
		_ruta("r_aurora_sur", "puerto_aurora", "puerto_sur", 60.0, 80, "barco"),
		_ruta("r_sur_aurora", "puerto_sur", "puerto_aurora", 60.0, 80, "barco"),
		_ruta("r_muelle_sur", "muelle_raiz_sur", "puerto_sur", 55.0, 60, "barco"),
		_ruta("r_sur_muelle", "puerto_sur", "muelle_raiz_sur", 55.0, 60, "barco"),
		_ruta("r_aurora_este", "puerto_aurora", "puerto_este", 70.0, 90, "barco"),
		_ruta("r_este_aurora", "puerto_este", "puerto_aurora", 70.0, 90, "barco"),
		_ruta("r_muelle_este", "muelle_raiz_sur", "puerto_este", 65.0, 70, "barco"),
		_ruta("r_este_muelle", "puerto_este", "muelle_raiz_sur", 65.0, 70, "barco"),
		# Dirigible (norte)
		_ruta("r_plataforma_norte", "plataforma_norte", "puerto_norte", 50.0, 100, "dirigible"),
		_ruta("r_norte_plataforma", "puerto_norte", "plataforma_norte", 50.0, 100, "dirigible"),
		# Secretas (M22: requieren flag de historia)
		# Isla Brisa: el gate es la PARADA (flag de M22) + la temporada (M29).
		_ruta("r_aurora_brisa", "puerto_aurora", "puerto_brisa", 90.0, 150, "barco", "", true, "verano"),
		# Isla Espejo: el gate es la RUTA (flag de historia). La parada existe.
		_ruta("r_aurora_espejo", "puerto_aurora", "puerto_espejo", 110.0, 220, "barco", "pistas_secreto_completas", true),
	]

	var errores: Array[String] = red.validar()
	if not errores.is_empty():
		push_error("Dataset inválido, NO se guarda: %s" % str(errores))
		quit(1)
		return

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://data/transporte"))
	var err: int = ResourceSaver.save(red, DESTINO)
	if err != OK:
		push_error("No se pudo guardar %s (err=%d)" % [DESTINO, err])
		quit(1)
		return

	print("Red de transporte generada: %d paradas, %d rutas -> %s" % [red.contar_stops(), red.contar_rutas(), DESTINO])
	print("Huella: %s" % red.huella())
	quit(0)


func _parada(id: String, nombre: String, tipo: String, isla: String, pos: Vector3,
		apertura: int, cierre: int, cartel: bool, inicial: bool, flag: StringName, poi: String) -> TransportStop:
	var s := TransportStop.new()
	s.id = StringName(id)
	s.nombre_clave = "M68.STOP.%s" % id
	s.nombre_fallback = nombre
	s.tipo = tipo
	s.isla_id = isla
	s.pos = pos
	s.horario_apertura = apertura
	s.horario_cierre = cierre
	s.tiene_cartel = cartel
	s.desbloqueada_inicial = inicial
	s.desbloquea_flag = flag
	s.poi_id = poi
	return s


func _ruta(id: String, desde: String, hasta: String, dur: float, coste: int, medio: String,
		flag: String = "", secreta: bool = false, temporada: String = "") -> TransportRoute:
	var r := TransportRoute.new()
	r.id = StringName(id)
	r.from_id = StringName(desde)
	r.to_id = StringName(hasta)
	r.duracion_seg = dur
	r.base_cost = coste
	r.medio = medio
	r.requiere_flag = StringName(flag)
	r.es_secreta = secreta
	r.temporada = temporada
	r.bidireccional = true
	return r
