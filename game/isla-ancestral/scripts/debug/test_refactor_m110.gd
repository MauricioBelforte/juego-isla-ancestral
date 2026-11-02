# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy AI
# Fecha: 2026-11-02
# M110: suite del REFACTOR — items L139, L142, L176, L275, L286, L287, L288 del
# 05-Checklist ("embebido en debug_menu.gd", "el archivo no existia").
#
# Que prueba, y que NO prueba:
#  - Prueba que los tres archivos existen en la ruta EXACTA que pide el
#    checklist y que cargan.
#  - Prueba que el despacho de comandos y el exportador FUNCIONAN por si
#    mismos (se ejercitan directo, con hosts falsos).
#  - Prueba, por MEDICION DEL CUERPO, que `debug_menu.gd` ya no contiene esas
#    dos implementaciones: si el `match` de 60 lineas siguiera ahi, el cuerpo de
#    `ejecutar_comando` mediria decenas de lineas y el check C falla. Un archivo
#    extraido al lado de una copia viva es la trampa clasica de este tipo de
#    item, y por eso el check es de longitud + llamada, no de presencia.
#  - NO prueba que el comportamiento sea identico: eso lo cubren las 12 suites
#    de M110 que se re-ejecutan como regresion.
#
# Guardia de 3 capas (protocolo del proyecto):
#  1. `_fin(bloque)` al FINAL del CUERPO de cada bloque: un SCRIPT ERROR aborta
#     la funcion y el llamador retoma, asi que un `_fin` en el llamador seria
#     ciego.
#  2. `CHECKS_MINIMOS` MEDIDO en verde (no estimado).
#  3. `_summary()` en un `call_deferred` SEPARADO: si corriera dentro de
#     `_run()`, un aborto se lo salta y la suite "pasa" sin resumen.
extends SceneTree

const BLOQUES := ["A", "B", "C", "D", "E", "F"]
## MEDIDO en verde antes de fijarlo. Si baja, la suite falla aunque no haya
## ningun [FAIL]: un bloque que deja de correr no puede pasar desapercibido.
const CHECKS_MINIMOS := 49

const RUTA_MENU := "res://scripts/debug/debug_menu.gd"
const RUTA_EXPORTADOR := "res://scripts/debug/diagnostic_exporter.gd"
const RUTA_COMANDOS := "res://scripts/debug/debug_commands.gd"
const RUTA_BASE := "res://scripts/debug/panel_base.gd"

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}
var _root: Window = null


## Host falso: registra las llamadas y devuelve lo que se le pida.
class HostFalso extends Node:
	var llamadas: Array = []
	var retorno: Dictionary = {"ok": true, "resultado": "hecho"}

	func _registrar(metodo: String, args: Array) -> Dictionary:
		llamadas.append([metodo, args])
		return retorno

	func teleport_player(pos: Vector3) -> Dictionary:
		return _registrar("teleport_player", [pos])

	func dar_objetos(item: String, n: int) -> Dictionary:
		return _registrar("dar_objetos", [item, n])

	func set_game_time(hora: int) -> Dictionary:
		return _registrar("set_game_time", [hora])

	func set_weather(clima: int) -> Dictionary:
		return _registrar("set_weather", [clima])

	func set_season(est: int) -> Dictionary:
		return _registrar("set_season", [est])

	func _toggle_visual(id: String, on: bool) -> Dictionary:
		return _registrar("_toggle_visual", [id, on])

	func metricas_sistema() -> Dictionary:
		llamadas.append(["metricas_sistema", []])
		return {"fps": 60}

	func _export_diagnostic_zip() -> Dictionary:
		llamadas.append(["_export_diagnostic_zip", []])
		return {"ok": true, "path": "x.zip"}

	func save_config() -> Dictionary:
		return _registrar("save_config", [])

	func reset_config() -> Dictionary:
		return _registrar("reset_config", [])

	func esta_visible() -> bool:
		return false

	func toggle_activo(_id: String) -> bool:
		return false


## Host sin ninguno de los metodos del backend: debe dar ok=false, no crash.
class HostVacio extends Node:
	pass


func _init() -> void:
	call_deferred("_run")
	# SEPARADO a proposito: si un aborto corta `_run`, el resumen igual corre.
	call_deferred("_summary")


func _run() -> void:
	_root = root
	_bloque_a()
	_bloque_b()
	_bloque_c()
	_bloque_d()
	_bloque_e()
	_bloque_f()


# ── A: los archivos del checklist existen donde el checklist dice ──────────
func _bloque_a() -> void:
	var rutas := [RUTA_EXPORTADOR, RUTA_COMANDOS, RUTA_BASE]
	for r in rutas:
		_check("A archivo en la ruta del checklist: %s" % r, FileAccess.file_exists(r))
	for r in rutas:
		var s: Script = load(r) as Script
		_check("A carga como Script: %s" % r, s != null)
	# El checklist L288 pide literalmente `scripts/debug/panel_*.gd` (raiz de
	# debug, no `panels/`). Se comprueba el prefijo, no el nombre exacto.
	var dir := DirAccess.open("res://scripts/debug")
	var paneles: Array[String] = []
	if dir != null:
		for f in dir.get_files():
			if String(f).begins_with("panel_") and String(f).ends_with(".gd"):
				paneles.append(String(f))
	_check("A existe al menos un scripts/debug/panel_*.gd", paneles.size() >= 1)
	_fin("A")


# ── B: el modulo de comandos despacha de verdad ────────────────────────────
func _bloque_b() -> void:
	var mod: Script = load(RUTA_COMANDOS) as Script
	_check("B1 el modulo de comandos carga", mod != null)
	if mod == null:
		_fin("B")
		return

	var host := HostFalso.new()
	var r1: Dictionary = mod.call("ejecutar", host, "teleport_casa", {"accion": "teleport", "parametros": {"x": 1, "y": 2, "z": 3}}, {})
	_check("B2 teleport llega al host con Vector3(1,2,3)",
		host.llamadas.size() == 1 and String(host.llamadas[0][0]) == "teleport_player"
		and (host.llamadas[0][1][0] as Vector3).is_equal_approx(Vector3(1, 2, 3)))
	_check("B3 teleport devuelve el Dictionary del host", bool(r1.get("ok", false)))

	var r2: Dictionary = mod.call("ejecutar", host, "toggle_fps", {"accion": "toggle_fps", "parametros": {"enabled": true}}, {})
	var ult: Array = host.llamadas[-1]
	_check("B4 toggle_fps se traduce a _toggle_visual(\"fps\", true)",
		String(ult[0]) == "_toggle_visual" and String(ult[1][0]) == "fps" and bool(ult[1][1]) == true)
	_check("B5 toggle_fps devuelve ok", bool(r2.get("ok", false)))

	# Los 6 toggles del catalogo tienen que mapear; si uno falta, aqui se ve.
	var mod_map: Dictionary = mod.get_script_constant_map().get("ACCIONES_VISUALES", {})
	_check("B6 los 6 toggles visuales estan mapeados", mod_map.size() == 6)
	_check("B7 el mapa cubre ai_states", String(mod_map.get("toggle_ai_states", "")) == "ai_states")

	var r3: Dictionary = mod.call("ejecutar", host, "estadisticas", {"accion": "estadisticas"}, {})
	_check("B8 estadisticas ENVUELVE las metricas (no devuelve el dict crudo)",
		bool(r3.get("ok", false)) and String(r3.get("comando", "")) == "estadisticas"
		and String(r3.get("resultado", "")).find("fps") >= 0)

	var r4: Dictionary = mod.call("ejecutar", host, "ayuda", {"accion": "ayuda"}, {"a": {}, "b": {}})
	_check("B9 ayuda lista el catalogo recibido", String(r4.get("resultado", "")).find("a") >= 0)

	var r5: Dictionary = mod.call("ejecutar", host, "inventado", {"accion": "no_existe"}, {})
	_check("B10 accion desconocida devuelve ok=false", bool(r5.get("ok", true)) == false)

	var vacio := HostVacio.new()
	var r6: Dictionary = mod.call("ejecutar", vacio, "teleport_casa", {"accion": "teleport", "parametros": {}}, {})
	_check("B11 host sin el metodo: fail-closed, no crash", bool(r6.get("ok", true)) == false)
	vacio.free()
	host.free()
	_fin("B")


# ── C: el codigo YA NO vive en debug_menu.gd (medido por longitud de cuerpo) ─
func _bloque_c() -> void:
	var fuente := FileAccess.get_file_as_string(RUTA_MENU)
	_check("C1 debug_menu.gd se puede leer", fuente.length() > 0)

	var cuerpo_cmd := _cuerpo(fuente, "func ejecutar_comando(")
	_check("C2 ejecutar_comando tiene cuerpo corto (delega, no despacha)", cuerpo_cmd.size() > 0 and cuerpo_cmd.size() <= 12)
	var texto_cmd := "\n".join(PackedStringArray(cuerpo_cmd))
	_check("C3 ejecutar_comando llama al modulo de comandos", texto_cmd.find("COMANDOS_DEBUG.ejecutar(") >= 0)

	var cuerpo_exp := _cuerpo(fuente, "func _export_diagnostic_zip(")
	_check("C4 _export_diagnostic_zip tiene cuerpo corto", cuerpo_exp.size() > 0 and cuerpo_exp.size() <= 4)
	_check("C5 _export_diagnostic_zip llama al exportador",
		"\n".join(PackedStringArray(cuerpo_exp)).find("EXPORTADOR_DIAG.exportar(") >= 0)

	# La cadena del defecto original solo puede vivir en el modulo extraido: si
	# siguiera en debug_menu.gd, habria DOS implementaciones y el item seria
	# un archivo decorativo al lado de la copia viva.
	var mod_src := FileAccess.get_file_as_string(RUTA_COMANDOS)
	_check("C6 'accion desconocida' vive solo en el modulo",
		mod_src.find("accion desconocida") >= 0 and fuente.find("accion desconocida") < 0)
	_check("C7 debug_menu.gd ya no tiene el match de acciones", fuente.find("\"cambiar_estacion\":") < 0)
	_fin("C")


# ── D: el exportador produce un ZIP real ───────────────────────────────────
func _bloque_d() -> void:
	var mod: Script = load(RUTA_EXPORTADOR) as Script
	_check("D1 el exportador carga", mod != null)
	if mod == null:
		_fin("D")
		return
	var r: Dictionary = mod.call("exportar", {"prueba": 1}, ["linea1", "linea2"], null)
	_check("D2 exportar devuelve ok", bool(r.get("ok", false)))
	var ruta := String(r.get("path", ""))
	_check("D3 el ZIP existe en disco", ruta.length() > 0 and FileAccess.file_exists(ruta))
	_check("D4 el ZIP no esta vacio", FileAccess.get_file_as_bytes(ruta).size() > 0)
	var txt := String(r.get("txt_path", ""))
	_check("D5 escribe tambien el .txt legible", txt.length() > 0 and FileAccess.file_exists(txt))

	# El delegado del backend tiene que usar el mismo camino: se ejercita el
	# metodo real de DebugMenu, no el modulo.
	var dm := _root.get_node_or_null("DebugMenu")
	_check("D6 DebugMenu (autoload) disponible", dm != null)
	if dm != null:
		var r2: Dictionary = dm.call("_export_diagnostic_zip")
		_check("D7 el delegado del backend exporta igual", bool(r2.get("ok", false)))
		_check("D8 el delegado devuelve una ruta existente", FileAccess.file_exists(String(r2.get("path", ""))))
	_fin("D")


# ── E: los paneles heredan de la base comun ────────────────────────────────
func _bloque_e() -> void:
	var base: Script = load(RUTA_BASE) as Script
	var p1: Node = (load("res://scripts/debug/panels/panel_mundo.gd") as Script).new()
	var p2: Node = (load("res://scripts/debug/panels/panel_entidades.gd") as Script).new()
	_root.add_child(p1)
	_root.add_child(p2)

	var b1: Script = (p1.get_script() as Script).get_base_script()
	var b2: Script = (p2.get_script() as Script).get_base_script()
	_check("E1 panel_mundo hereda de panel_base", b1 != null and b1.resource_path == RUTA_BASE)
	_check("E2 panel_entidades hereda de panel_base", b2 != null and b2.resource_path == RUTA_BASE)
	_check("E3 la base es la misma instancia de Script", b1 == base)

	var w1: Dictionary = p1.call("widgets_presentes")
	var w2: Dictionary = p2.call("widgets_presentes")
	var ok1 := true
	for k in w1:
		if not bool(w1[k]):
			ok1 = false
	_check("E4 panel_mundo conserva sus 8 widgets", ok1 and w1.size() == 8)
	var ok2 := true
	for k in w2:
		if not bool(w2[k]):
			ok2 = false
	_check("E5 panel_entidades conserva sus 5 widgets", ok2 and w2.size() == 5)

	# Un panel suelto (fuera del arbol) no debe romper al refrescar.
	var suelto: Node = (load("res://scripts/debug/panels/panel_mundo.gd") as Script).new()
	var crashea := false
	if not suelto.has_method("refrescar"):
		crashea = true
	else:
		suelto.call("refrescar")
	_check("E6 refrescar() fuera del arbol es no-op (no null-deref)", not crashea)
	_check("E7 la base expone _llamar fail-closed", suelto.has_method("_llamar") and suelto.has_method("_inyectar_menu"))
	suelto.free()

	p1.queue_free()
	p2.queue_free()
	_fin("E")


# ── F: boton "Guardar Configuración" (L139) ────────────────────────────────
func _bloque_f() -> void:
	var escena: PackedScene = load("res://scenes/debug/debug_menu.tscn") as PackedScene
	_check("F1 la escena del menu carga", escena != null)
	if escena == null:
		_fin("F")
		return
	var ui: Node = escena.instantiate()
	var fake := HostFalso.new()
	ui.call("_inyectar_menu", fake)
	_root.add_child(ui)

	var btn: Button = ui.call("obtener_boton_guardar_config")
	_check("F2 existe el boton 'Guardar Configuración'", btn is Button)
	_check("F3 el boton dice 'Guardar Configuración'", btn != null and btn.text.find("Guardar Configuraci") >= 0)
	_check("F4 la barra de configuracion esta montada", ui.call("obtener_barra_config") != null)

	var antes: int = fake.llamadas.size()
	if btn != null:
		btn.pressed.emit()
	var guardo := false
	for i in range(antes, fake.llamadas.size()):
		if String(fake.llamadas[i][0]) == "save_config":
			guardo = true
	_check("F5 presionar el boton llama save_config() del backend", guardo)

	var btn_r: Button = ui.call("obtener_boton_reset_config")
	var antes2: int = fake.llamadas.size()
	if btn_r != null:
		btn_r.pressed.emit()
	var reset := false
	for i in range(antes2, fake.llamadas.size()):
		if String(fake.llamadas[i][0]) == "reset_config":
			reset = true
	_check("F6 el boton Restablecer llama reset_config()", reset)

	# Fail-closed de los botones. NO se aserta "no crashea" (infalsable: un
	# SCRIPT ERROR aborta el handler y el llamador retoma, asi que la bandera
	# nunca cambiaria). Se mide el EFECTO observable: la consola NO debe recibir
	# el aviso de "guardada" cuando el backend no puede guardar. Si el guardia
	# `has_method()` desapareciera, `Object.call()` sobre un metodo inexistente
	# devuelve null SIN abortar y `_avisar_consola()` SI se ejecutaria -> el
	# conteo de lineas cambia y el check falla.
	var cons: Control = ui.call("obtener_consola")
	_check("F7 la consola esta disponible para medir el efecto", cons != null)
	if cons != null:
		var lineas_antes: int = int(cons.call("tamano"))
		var vacio := HostVacio.new()
		ui.call("_inyectar_menu", vacio)
		if btn != null:
			btn.pressed.emit()
		var lineas_despues: int = int(cons.call("tamano"))
		_check("F8 backend sin save_config(): no anuncia un guardado que no ocurrio",
			lineas_despues == lineas_antes)
		vacio.free()

	# Backend nulo: el guardia de null tiene que cortar antes de tocar nada.
	ui.call("_inyectar_menu", null)
	if cons != null:
		var l2_antes: int = int(cons.call("tamano"))
		if btn != null:
			btn.pressed.emit()
		_check("F9 backend nulo: tampoco escribe en la consola",
			int(cons.call("tamano")) == l2_antes)

	ui.queue_free()
	fake.free()
	_fin("F")


# ── Infraestructura ────────────────────────────────────────────────────────

## Devuelve las lineas del CUERPO de `cabecera` (sin la firma) hasta la proxima
## linea que empiece con `func ` en columna 0.
func _cuerpo(fuente: String, cabecera: String) -> Array[String]:
	var lineas := fuente.split("\n")
	var out: Array[String] = []
	var dentro := false
	for l in lineas:
		if not dentro:
			if String(l).begins_with(cabecera):
				dentro = true
			continue
		if String(l).begins_with("func ") or String(l).begins_with("const ") or String(l).begins_with("var "):
			break
		out.append(String(l))
	# Quitar blancos del final.
	while out.size() > 0 and out[-1].strip_edges().is_empty():
		out.pop_back()
	return out


func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("[FAIL] %s" % nombre)


func _fin(bloque: String) -> void:
	_vistos[bloque] = true


func _summary() -> void:
	for b in BLOQUES:
		if not _vistos.has(b):
			_fallos += 1
			print("[FAIL] el bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] piso de checks: %d < %d (la suite se quedo corta)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M110-refactor: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
