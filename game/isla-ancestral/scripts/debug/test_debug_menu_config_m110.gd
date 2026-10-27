# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-27
#
# M110 (Debug Menu) - suite de la PERSISTENCIA DE ESTADO (seccion N).
# Cubre los items de "N. Configuracion y persistencia":
#   save_config(), reset_config(), guardar posicion y tamano, guardar
#   visibilidad de paneles, guardar estado de toggles, guardar filtros de
#   consola y guardar la configuracion al cerrar.
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral \
#     --script res://scripts/debug/test_debug_menu_config_m110.gd
#
# Guardas anti-falso-verde (3 capas, ver skill isla-ancestral-ciclo-modulo):
#   1. `_fin(bloque)` al FINAL del cuerpo de cada bloque (no en el runner).
#   2. `CHECKS_MINIMOS` = piso MEDIDO en verde (no estimado).
#   3. `_summary()` en un `call_deferred` SEPARADO: si `_run()` aborta por un
#      SCRIPT ERROR, el resumen corre igual, nombra los bloques faltantes y
#      sale con EXIT 1 en vez de colgarse.
#
# La suite NO agrega el menu al arbol (no dispara `_ready`): instancia el
# script y llama a la API publica. El cableado de `_ready`/`_notification` se
# verifica de forma ESTATICA en el bloque G (el archivo debe llamar a
# `_cargar_estado()` en `_ready` y a `save_config()` en `_notification`).

extends SceneTree

const MODULO := "M110"
const MENU := preload("res://scripts/debug/debug_menu.gd")
const RUTA_SCRIPT := "res://scripts/debug/debug_menu.gd"
const RUTA_ESTADO := "user://debug_menu_estado.json"

## Bloques esperados (los nombres que usa `_fin`)
const BLOQUES: Array[String] = ["A", "B", "C", "D", "E", "F", "G"]

## Piso MEDIDO en verde: 75 checks (A 14 + B 9 + C 18 + D 9 + E 11 + F 7 + G 7).
## Re-medir si la suite crece; nunca estimar.
const CHECKS_MINIMOS: int = 75

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}
var _original: PackedByteArray = PackedByteArray()
var _habia_original: bool = false


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")  # corre aunque _run() aborte (SCRIPT ERROR)


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("[FALLO] " + msg)


func _fin(bloque: String) -> void:
	_vistos[bloque] = true
	print("[FIN] bloque %s (acumulado %d checks)" % [bloque, _checks])


func _summary() -> void:
	for b in BLOQUES:
		if not _vistos.has(b):
			_checks += 1
			_fallos += 1
			print("[FALLO] el bloque %s NO se ejecutó (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_checks += 1
		_fallos += 1
		print("[FALLO] solo %d checks ejecutados (mínimo medido %d)"
			% [_checks - 1, CHECKS_MINIMOS])
	print("=== Resumen %s persistencia: %d checks, %d fallo(s) ===" % [MODULO, _checks, _fallos])
	quit(1 if _fallos > 0 else 0)


func _run() -> void:
	_guardar_original()
	_bloque_a()
	_bloque_b()
	_bloque_c()
	_bloque_d()
	_bloque_e()
	_bloque_f()
	_bloque_g()
	_restaurar_original()


func _guardar_original() -> void:
	if FileAccess.file_exists(RUTA_ESTADO):
		_habia_original = true
		_original = FileAccess.get_file_as_bytes(RUTA_ESTADO)


func _restaurar_original() -> void:
	## La suite deja `user://` como lo encontro (no contamina otras suites).
	if _habia_original:
		var f := FileAccess.open(RUTA_ESTADO, FileAccess.WRITE)
		if f != null:
			f.store_buffer(_original)
			f.close()
	elif FileAccess.file_exists(RUTA_ESTADO):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(RUTA_ESTADO))


func _borrar_estado() -> void:
	if FileAccess.file_exists(RUTA_ESTADO):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(RUTA_ESTADO))


func _nuevo() -> Node:
	return MENU.new()


func _existe_tmp() -> bool:
	return FileAccess.file_exists(RUTA_ESTADO + ".tmp")


func _bloque_a() -> void:
	print("--- A: defaults y forma de estado_actual() ---")
	var m: Node = _nuevo()
	_check(m != null, "A1 el script instancia")
	var e: Dictionary = m.estado_actual()
	_check(typeof(e) == TYPE_DICTIONARY, "A2 estado_actual() devuelve Dictionary")
	for clave in ["version", "posicion", "tamano", "paneles", "toggles", "filtros_consola"]:
		_check(e.has(clave), "A3 estado_actual() tiene la clave '%s'" % clave)
	_check(int(e.get("version", -1)) == int(m.VERSION_ESTADO), "A4 la version del estado es la declarada")
	var toggles: Dictionary = e.get("toggles", {})
	_check(toggles.size() == 6, "A5 hay 6 toggles persistidos (medido %d)" % toggles.size())
	var todos_off := true
	for k in toggles:
		if bool(toggles[k]):
			todos_off = false
	_check(todos_off, "A6 un menu nuevo arranca con los 6 toggles en false")
	var filtros: Dictionary = e.get("filtros_consola", {})
	_check(int(filtros.get("nivel", 99)) == -1 and int(filtros.get("categoria", 99)) == -1,
		"A7 filtros por defecto = -1 (todos)")
	_check(String(filtros.get("busqueda", "x")) == "" and bool(filtros.get("autoscroll", false)) == true,
		"A8 busqueda vacia + autoscroll activo por defecto")
	_check(m.estado_sucio() == false, "A9 un menu nuevo NO esta sucio")
	_fin("A")


func _bloque_b() -> void:
	print("--- B: save_config() escribe un JSON valido ---")
	_borrar_estado()
	var m: Node = _nuevo()
	var r: Dictionary = m.save_config()
	_check(bool(r.get("ok", false)), "B1 save_config() reporta ok: " + str(r))
	_check(FileAccess.file_exists(RUTA_ESTADO), "B2 el archivo existe en " + RUTA_ESTADO)
	_check(not _existe_tmp(), "B3 no queda un .tmp residual")
	var txt := FileAccess.get_file_as_string(RUTA_ESTADO)
	var parseado: Variant = JSON.parse_string(txt)
	_check(typeof(parseado) == TYPE_DICTIONARY, "B4 el archivo parsea como Dictionary")
	if typeof(parseado) == TYPE_DICTIONARY:
		var d: Dictionary = parseado
		_check(int(d.get("version", -1)) == int(m.VERSION_ESTADO), "B5 el archivo guarda la version")
		_check((d.get("posicion", []) as Array).size() == 2, "B6 guarda posicion como par [x,y]")
		_check((d.get("tamano", []) as Array).size() == 2, "B7 guarda tamano como par [w,h]")
	# Idempotencia: dos guardados seguidos no cambian los bytes.
	var bytes1 := FileAccess.get_file_as_bytes(RUTA_ESTADO)
	m.save_config()
	var bytes2 := FileAccess.get_file_as_bytes(RUTA_ESTADO)
	_check(bytes1 == bytes2, "B8 dos save_config() seguidos son byte-identicos")
	_check(m.estado_sucio() == false, "B9 tras guardar el estado queda limpio")
	_fin("B")


func _bloque_c() -> void:
	print("--- C: round-trip (set -> save -> instancia nueva -> load) ---")
	_borrar_estado()
	var m: Node = _nuevo()
	m.set_geometria(Vector2i(120, 90), Vector2i(800, 500))
	m.set_panel_visible("mundo", true)
	m.set_panel_visible("npc", false)
	m.toggle_fps(true)
	m.toggle_navigation(true)
	m.toggle_colliders(true)
	m.set_filtros_consola({"nivel": 2, "categoria": 1, "busqueda": "chunk", "autoscroll": false})
	_check(m.estado_sucio() == true, "C1 cambiar estado marca sucio")
	var rs: Dictionary = m.save_config()
	_check(bool(rs.get("ok", false)), "C2 save_config() del estado cambiado ok")
	var m2: Node = _nuevo()
	var rl: Dictionary = m2._cargar_estado()
	_check(bool(rl.get("ok", false)), "C3 _cargar_estado() encuentra y aplica el archivo: " + str(rl))
	var g: Dictionary = m2.get_geometria()
	_check(g.get("posicion", Vector2i.ZERO) == Vector2i(120, 90), "C4 posicion restaurada: " + str(g))
	_check(g.get("tamano", Vector2i.ZERO) == Vector2i(800, 500), "C5 tamano restaurado: " + str(g))
	_check(m2.panel_visible("mundo") == true, "C6 panel 'mundo' restaurado visible")
	_check(m2.panel_visible("npc") == false, "C7 panel 'npc' restaurado oculto")
	_check(m2.panel_visible("inexistente") == false, "C8 panel desconocido -> false (fail-closed)")
	_check(m2.toggle_activo("fps") == true, "C9 toggle fps restaurado")
	_check(m2.toggle_activo("navigation") == true, "C10 toggle navigation restaurado")
	_check(m2.toggle_activo("colliders") == true, "C11 toggle colliders restaurado")
	_check(m2.toggle_activo("chunks") == false, "C12 toggle chunks sigue en false")
	_check(m2.toggle_activo("basura") == false, "C13 toggle desconocido -> false")
	var f: Dictionary = m2.filtros_consola()
	_check(int(f.get("nivel", -1)) == 2, "C14 filtro nivel restaurado")
	_check(int(f.get("categoria", -1)) == 1, "C15 filtro categoria restaurado")
	_check(String(f.get("busqueda", "")) == "chunk", "C16 filtro busqueda restaurado")
	_check(bool(f.get("autoscroll", true)) == false, "C17 autoscroll restaurado")
	_check(m2.estado_sucio() == false, "C18 cargar deja el estado limpio (no reescribe)")
	_fin("C")


func _bloque_d() -> void:
	print("--- D: reset_config() borra el archivo y vuelve a defaults ---")
	_borrar_estado()
	var m: Node = _nuevo()
	m.set_geometria(Vector2i(10, 20), Vector2i(300, 200))
	m.set_panel_visible("mundo", true)
	m.toggle_fps(true)
	m.save_config()
	_check(FileAccess.file_exists(RUTA_ESTADO), "D1 precondicion: hay archivo guardado")
	var rr: Dictionary = m.reset_config()
	_check(bool(rr.get("ok", false)), "D2 reset_config() reporta ok")
	_check(not FileAccess.file_exists(RUTA_ESTADO), "D3 reset_config() borra el archivo")
	var g: Dictionary = m.get_geometria()
	_check(g.get("posicion", Vector2i.ZERO) == Vector2i(64, 64), "D4 geometria vuelve al default")
	_check(g.get("tamano", Vector2i.ZERO) == Vector2i(640, 400), "D5 tamano vuelve al default")
	_check(m.panel_visible("mundo") == false, "D6 paneles vuelven a ocultos")
	_check(m.toggle_activo("fps") == false, "D7 toggles vuelven a false")
	_check(m.estado_sucio() == false, "D8 tras reset el estado queda limpio")
	# Un guardado posterior vuelve a crear el archivo con los defaults.
	m.save_config()
	var m2: Node = _nuevo()
	m2._cargar_estado()
	_check(m2.get_geometria().get("posicion", Vector2i.ZERO) == Vector2i(64, 64),
		"D9 el archivo regenerado tiene los defaults")
	_fin("D")


func _bloque_e() -> void:
	print("--- E: filtros de consola (nivel / categoria / busqueda / autoscroll) ---")
	var m: Node = _nuevo()
	m._on_logger_line(0, 0, "arranque ok")
	m._on_logger_line(1, 1, "aviso de clima")
	m._on_logger_line(2, 2, "ERROR de chunk")
	m._on_logger_line(3, 0, "traza de red")
	_check(m.console_get_lines().size() == 4, "E1 console_get_lines() devuelve las 4 lineas (contrato previo)")
	m.set_filtros_consola({"nivel": -1, "categoria": -1, "busqueda": "", "autoscroll": true})
	_check(m.aplicar_filtros_consola().size() == 4, "E2 sin filtros pasan las 4")
	m.set_filtros_consola({"nivel": 2})
	var solo_nivel: Array[String] = m.aplicar_filtros_consola()
	_check(solo_nivel.size() == 1 and solo_nivel[0] == "ERROR de chunk", "E3 filtro por nivel: " + str(solo_nivel))
	m.set_filtros_consola({"nivel": -1, "categoria": 0})
	var solo_cat: Array[String] = m.aplicar_filtros_consola()
	_check(solo_cat.size() == 2, "E4 filtro por categoria 0 -> 2 lineas: " + str(solo_cat))
	m.set_filtros_consola({"categoria": -1, "busqueda": "error"})
	var solo_txt: Array[String] = m.aplicar_filtros_consola()
	_check(solo_txt.size() == 1, "E5 busqueda es case-insensitive: " + str(solo_txt))
	m.set_filtros_consola({"nivel": 2, "categoria": 0})
	_check(m.aplicar_filtros_consola().size() == 0, "E6 filtros combinados pueden dar 0")
	m.set_filtros_consola({"nivel": -1, "categoria": -1, "busqueda": ""})
	_check(m.aplicar_filtros_consola().size() == 4, "E7 quitar filtros devuelve las 4")
	m.set_filtros_consola({"autoscroll": false})
	_check(bool(m.filtros_consola().get("autoscroll", true)) == false, "E8 autoscroll se guarda como preferencia")
	_check(m.aplicar_filtros_consola().size() == 4, "E9 autoscroll NO filtra lineas")
	# La consola respeta el tope de 100 lineas tambien en las entradas con nivel.
	for i in range(120):
		m._on_logger_line(0, 0, "linea %d" % i)
	_check(m.console_get_lines().size() == 100, "E10 la consola se recorta a 100 lineas")
	_check(m.aplicar_filtros_consola().size() == 100, "E11 las entradas con nivel se recortan igual")
	_fin("E")


func _bloque_f() -> void:
	print("--- F: guardado al cerrar (solo si hubo cambios) ---")
	_borrar_estado()
	var m: Node = _nuevo()
	_check(m.estado_sucio() == false, "F1 instancia limpia")
	m._notification(Node.NOTIFICATION_EXIT_TREE)
	_check(not FileAccess.file_exists(RUTA_ESTADO), "F2 cerrar SIN cambios NO escribe el archivo")
	m.set_panel_visible("mundo", true)
	_check(m.estado_sucio() == true, "F3 un cambio marca el estado sucio")
	_check(not FileAccess.file_exists(RUTA_ESTADO), "F4 el cambio no escribe hasta cerrar/guardar")
	m._notification(Node.NOTIFICATION_EXIT_TREE)
	_check(FileAccess.file_exists(RUTA_ESTADO), "F5 cerrar CON cambios escribe el archivo")
	var m2: Node = _nuevo()
	m2._cargar_estado()
	_check(m2.panel_visible("mundo") == true, "F6 lo escrito al cerrar se recupera")
	# Ventana cerrada por el usuario (WM_CLOSE_REQUEST) se comporta igual.
	_borrar_estado()
	var m3: Node = _nuevo()
	m3.toggle_chunks(true)
	m3._notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
	_check(FileAccess.file_exists(RUTA_ESTADO), "F7 WM_CLOSE_REQUEST tambien guarda")
	_fin("F")


func _bloque_g() -> void:
	print("--- G: fail-closed ante archivo corrupto + cableado estatico ---")
	# G1/G2: JSON invalido -> defaults, y NO se pisa el archivo.
	_borrar_estado()
	var f := FileAccess.open(RUTA_ESTADO, FileAccess.WRITE)
	f.store_string("{esto no es json")
	f.close()
	var m: Node = _nuevo()
	var rl: Dictionary = m._cargar_estado()
	_check(bool(rl.get("ok", false)) == false, "G1 JSON invalido -> _cargar_estado() !ok: " + str(rl))
	_check(m.get_geometria().get("posicion", Vector2i.ZERO) == Vector2i(64, 64),
		"G2 JSON invalido -> defaults")
	_check(FileAccess.get_file_as_string(RUTA_ESTADO) == "{esto no es json",
		"G3 el archivo corrupto NO se pisa al cargar")
	# G4: version distinta -> defaults (no se migra a ciegas).
	var f2 := FileAccess.open(RUTA_ESTADO, FileAccess.WRITE)
	f2.store_string(JSON.stringify({"version": 999, "posicion": [1, 1], "tamano": [2, 2]}))
	f2.close()
	var m2: Node = _nuevo()
	var rl2: Dictionary = m2._cargar_estado()
	_check(bool(rl2.get("ok", false)) == false, "G4 version distinta -> !ok: " + str(rl2))
	_check(m2.get_geometria().get("posicion", Vector2i.ZERO) == Vector2i(64, 64),
		"G5 version distinta -> defaults")
	# G6/G7: cableado estatico — `_ready` carga el estado y `_notification`
	# guarda al cerrar. Sin esto la persistencia seria codigo muerto.
	var src := FileAccess.get_file_as_string(RUTA_SCRIPT)
	var cuerpo_ready := _cuerpo_de(src, "_ready")
	var cuerpo_notif := _cuerpo_de(src, "_notification")
	_check(cuerpo_ready.find("_cargar_estado()") >= 0,
		"G6 _ready() llama a _cargar_estado()")
	_check(cuerpo_notif.find("save_config()") >= 0 and cuerpo_notif.find("_estado_sucio") >= 0,
		"G7 _notification() guarda al cerrar solo si el estado esta sucio")
	_borrar_estado()
	_fin("G")


func _cuerpo_de(texto: String, nombre: String) -> String:
	var marca := "func %s(" % nombre
	var i := texto.find(marca)
	if i < 0:
		return ""
	var resto := texto.substr(i)
	var j := resto.find("\nfunc ", marca.length())
	if j < 0:
		return resto
	return resto.substr(0, j)
