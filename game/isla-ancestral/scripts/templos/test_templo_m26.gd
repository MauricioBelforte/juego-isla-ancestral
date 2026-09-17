# Modelo: DeepSeek-V4.1-Flash / WorkBuddy
# Plataforma: WorkBuddy
# Fecha: 2026-09-14
#
# M26 — Templo Subterráneo (iteración 2). Suite headless de la parte verificable:
# gating, anti-exploit, checkpoints atómicos, telemetría de puzzles y las suites
# de validación (softlock / voxel / accesibilidad / orientación).
#
# Marcadores `_fin("X")` por bloque: un error de script ABORTA la función en
# SILENCIO, así que un bloque puede no ejecutarse y el test salir "verde". Al
# final se verifica que los 7 marcadores estén presentes.
#
# Uso:
#   Godot... --headless --path game/isla-ancestral --script res://scripts/templos/test_templo_m26.gd

extends SceneTree

# `preload` en vez de los nombres globales: un `class_name` nuevo no resuelve
# como identificador en modo `--script` (trampa conocida del proyecto).
const FlowGd := preload("res://scripts/templos/templo_flow.gd")
const CpGd := preload("res://scripts/templos/templo_checkpoint.gd")
const TelGd := preload("res://scripts/templos/templo_telemetria.gd")
const ValGd := preload("res://scripts/templos/templo_validadores.gd")
const SchemaGd := preload("res://scripts/templos/templo_schema.gd")

const RUTA_DISENO := "res://data/templos/templo_layout_diseno.json"
const RUTA_BLUEPRINT := "res://data/templos/templo_blueprint.json"
const RUTA_ITER1 := "res://data/templos/templo_subterraneo.json"
const DIR_TEST := "user://test_m26_cp"

var _checks := 0
var _fallos := 0
var _marcadores: Array[String] = []
var glifos: Array = []


func _init() -> void:
	call_deferred("_run")


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s%s" % [nombre, (" | " + detalle) if not detalle.is_empty() else ""])


func _fin(bloque: String) -> void:
	_marcadores.append(bloque)
	print("  -- bloque %s completado --" % bloque)


func _tiene(errores: Array, sub: String) -> bool:
	for e in errores:
		if str(e).contains(sub):
			return true
	return false


func _sin_conexion(conexiones: Array, a: String, b: String) -> Array:
	var out: Array = []
	for par in conexiones:
		if typeof(par) != TYPE_ARRAY:
			continue
		var p: Array = par as Array
		if p.size() < 2:
			continue
		var pa := str(p[0])
		var pb := str(p[1])
		if (pa == a and pb == b) or (pa == b and pb == a):
			continue
		out.append(p)
	return out


func _glifos_del_diseno() -> Array:
	var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RUTA_DISENO))
	var anillos: Array = layout.get("anillos", [])
	anillos.sort_custom(func(x, y): return int((x as Dictionary).get("indice", 0)) < int((y as Dictionary).get("indice", 0)))
	var gl: Array = []
	for a in anillos:
		gl.append(str((a as Dictionary).get("glifo", "")))
	return gl


func _contar_recompensas(layout: Dictionary) -> int:
	var n := 0
	for p in (layout.get("puzzles", []) as Array):
		if not str((p as Dictionary).get("recompensa", "")).is_empty():
			n += 1
	return n


# ------------------------------------------------------------------ A ------

func _bloque_a() -> void:
	print("[A] TemploFlow — gating básico")
	var flow = FlowGd.new(glifos)
	_check("7 anillos iniciales, todos inactivos", flow.anillos.size() == 7 and flow.anillos_activos() == 0)
	_check("progreso inicial 0.0", is_equal_approx(flow.progreso(), 0.0))
	_check("registrar sello nuevo devuelve true", flow.registrar_sello("sello_cristal_1"))
	_check("activar anillo 0 con sello+glifo correctos", flow.activar_anillo(0, "sello_cristal_1", "glifo_brisa"))
	_check("anillos_activos == 1", flow.anillos_activos() == 1)
	_check("progreso 1/7", is_equal_approx(flow.progreso(), 1.0 / 7.0))
	_check("rechaza anillo fuera de rango",
		not flow.activar_anillo(7, "sello_cristal_2", "glifo_raiz") and flow.ultimo_motivo == "anillo_fuera_de_rango")
	_check("rechaza anillo ya activo",
		not flow.activar_anillo(0, "sello_cristal_2", "glifo_raiz") and flow.ultimo_motivo == "anillo_ya_activo")
	_check("rechaza sello inexistente",
		not flow.activar_anillo(1, "sello_fantasma", "glifo_raiz") and flow.ultimo_motivo == "sello_inexistente")
	flow.registrar_sello("sello_cristal_2")
	_check("rechaza glifo incorrecto",
		not flow.activar_anillo(1, "sello_cristal_2", "glifo_malo") and flow.ultimo_motivo == "glifo_incorrecto",
		"motivo=%s" % flow.ultimo_motivo)
	_check("el sello del intento fallido sigue libre",
		flow.sello_colocado_en("sello_cristal_2") == -1)
	_check("activar anillo 1 con el glifo correcto funciona",
		flow.activar_anillo(1, "sello_cristal_2", "glifo_raiz") and flow.anillos_activos() == 2)
	_check("registrar sello duplicado devuelve false",
		not flow.registrar_sello("sello_cristal_1") and flow.ultimo_motivo == "sello_duplicado")
	_check("estado() serializa 7 anillos", (flow.estado() as Dictionary)["anillos"].size() == 7)
	_fin("A")


# ------------------------------------------------------------------ B ------

func _bloque_b() -> void:
	print("[B] TemploFlow — anti-exploit (sellos únicos, salida sellada)")
	var flow = FlowGd.new(glifos)
	for i in 7:
		flow.registrar_sello("sello_cristal_%d" % (i + 1))
	var ok_todos := true
	for i in 7:
		if not flow.activar_anillo(i, "sello_cristal_%d" % (i + 1), glifos[i]):
			ok_todos = false
	_check("los 7 anillos se activan con sus 7 sellos", ok_todos and flow.anillos_activos() == 7)
	_check("anillos_completos() true", flow.anillos_completos())

	var flow2 = FlowGd.new(glifos)
	flow2.registrar_sello("sello_cristal_1")
	flow2.activar_anillo(0, "sello_cristal_1", glifos[0])
	_check("sello_colocado_en() localiza el sello", flow2.sello_colocado_en("sello_cristal_1") == 0)
	_check("un sello ya colocado no puede ir a otro anillo",
		not flow2.activar_anillo(1, "sello_cristal_1", glifos[1]) and flow2.ultimo_motivo == "sello_ya_colocado")

	var flow3 = FlowGd.new(glifos)
	_check("salida cerrada sin sello restaurado", not flow3.salida_abierta())
	_check("restaurar_sello() falla sin los 7 anillos",
		not flow3.restaurar_sello() and flow3.ultimo_motivo == "faltan_anillos")
	_check("intentar_abrir_salida() falla y NO cambia estado",
		not flow3.intentar_abrir_salida() and flow3.ultimo_motivo == "sello_no_restaurado" and not flow3.salida_abierta())
	for i in 7:
		flow3.registrar_sello("sello_cristal_%d" % (i + 1))
		flow3.activar_anillo(i, "sello_cristal_%d" % (i + 1), glifos[i])
	_check("restaurar_sello() ok con los 7 anillos", flow3.restaurar_sello())
	_check("salida abierta tras restaurar el sello", flow3.salida_abierta() and flow3.intentar_abrir_salida())

	var flow4 = FlowGd.new(glifos)
	flow4.cargar_estado(flow3.estado())
	_check("round-trip de estado preserva anillos y sello",
		flow4.anillos_activos() == 7 and flow4.sello_restaurado and flow4.salida_abierta())
	_check("round-trip preserva los sellos colocados", flow4.sello_colocado_en("sello_cristal_5") == 4)
	_fin("B")


# ------------------------------------------------------------------ C ------

func _bloque_c() -> void:
	print("[C] TemploCheckpoint — guardado atómico tmp+rename+.bak")
	var cp = CpGd.new(DIR_TEST)
	var creado: bool = cp.asegurar_dir()
	# limpiar restos de corridas previas (por id: no se lista el directorio)
	for id in CpGd.CP_IDS:
		cp.borrar(id)
	_check("asegurar_dir() crea el directorio", creado)
	_check("el directorio arranca vacío tras la limpieza",
		cp.cantidad_backups() == 0 and cp.cantidad_tmp_huerfanos() == 0 and cp.listar().is_empty())
	_check("CP_IDS tiene 5 ids", CpGd.CP_IDS.size() == 5)
	_check("asegurar_dir() es idempotente", cp.asegurar_dir())

	var datos := {"sala": "vestibulo", "anillos": [true, false], "sello_restaurado": false}
	_check("guardar() devuelve true", cp.guardar("vestibulo", datos))
	_check("existe() true tras guardar", cp.existe("vestibulo"))
	_check("no queda .tmp huérfano tras guardar", not FileAccess.file_exists("%s/cp_vestibulo.json.tmp" % DIR_TEST))
	_check("el primer guardado no genera .bak", not cp.respaldo_existe("vestibulo"))

	_check("segundo guardar() true", cp.guardar("vestibulo", {"sala": "vestibulo", "anillos": [true, true]}), cp.ultimo_error)
	_check("el segundo guardado genera .bak", cp.respaldo_existe("vestibulo"))
	_check("cantidad_backups() == 1", cp.cantidad_backups() == 1)
	_check("cantidad_tmp_huerfanos() == 0", cp.cantidad_tmp_huerfanos() == 0)

	var leido: Dictionary = cp.cargar("vestibulo")
	var anillos_leidos: Array = leido.get("anillos", [])
	_check("cargar() devuelve el último estado", anillos_leidos.size() == 2 and bool(anillos_leidos[1]))

	# Corromper el principal: cargar_con_respaldo() debe caer al .bak.
	var f := FileAccess.open("%s/cp_vestibulo.json" % DIR_TEST, FileAccess.WRITE)
	f.store_string("{ json corrupto")
	f.close()
	var rec: Dictionary = cp.cargar_con_respaldo("vestibulo")
	var anillos_bak: Array = rec.get("anillos", [])
	_check("cargar_con_respaldo() usa el .bak si el principal está corrupto",
		cp.origen_carga == "respaldo" and not rec.is_empty())
	_check("el respaldo conserva el estado previo (1 anillo ON, no 2)",
		anillos_bak.size() == 2 and not bool(anillos_bak[1]))
	_check("cargar() del principal corrupto devuelve {} y setea error",
		cp.cargar("vestibulo").is_empty() and not cp.ultimo_error.is_empty())
	_check("validar_atomico() sin errores en el estado sano", cp.validar_atomico().is_empty())
	_check("listar() incluye el checkpoint escrito", cp.listar().has("vestibulo"))
	_check("borrar() limpia principal + tmp + bak",
		cp.borrar("vestibulo") and not cp.existe("vestibulo") and not cp.respaldo_existe("vestibulo"))
	_check("tras borrar no queda nada listado", cp.listar().is_empty())
	_fin("C")


# ------------------------------------------------------------------ D ------

func _bloque_d() -> void:
	print("[D] TempleTelemetria — intentos/pistas/tiempo + export a M24")
	var tel = TelGd.new("templo_subterraneo")
	tel.avanzar(10.0)
	tel.registrar_intento("puz_viento_1", 0)
	tel.avanzar(15.0)
	tel.registrar_intento("puz_viento_1", 1)
	tel.avanzar(5.0)
	tel.registrar_resolucion("puz_viento_1")
	var r: Dictionary = tel.resumen("puz_viento_1")
	_check("intentos == 2", int(r.get("intentos", 0)) == 2)
	_check("pistas == 1", int(r.get("pistas", 0)) == 1)
	_check("tiempo == 20 s (primer intento t=10 → resuelto t=30)",
		is_equal_approx(float(r.get("tiempo_s", -1.0)), 20.0))
	_check("resuelto == true", bool(r.get("resuelto", false)))
	_check("intentos_hasta_resolver == 2", int(r.get("intentos_hasta_resolver", -1)) == 2)

	for i in 4:
		tel.registrar_intento("puz_anillos", 0)
	var g: Dictionary = tel.resumen_global()
	_check("resumen global: 2 puzzles", int(g.get("puzzles", 0)) == 2)
	_check("resumen global: 1 resuelto", int(g.get("resueltos", 0)) == 1)
	_check("resumen global: 6 intentos", int(g.get("intentos", 0)) == 6)
	var dif: Array = tel.puzzles_dificiles(3)
	_check("puzzles_dificiles(3) == [puz_anillos]", dif.size() == 1 and str(dif[0]) == "puz_anillos")

	var payload: Dictionary = tel.exportar_a_m24()
	var lista: Array = payload.get("puzzles", [])
	_check("payload M24: version 1 y origen M26",
		int(payload.get("version", 0)) == 1 and str(payload.get("origen", "")) == "M26")
	_check("payload M24: 2 puzzles ordenados por id",
		lista.size() == 2 and str((lista[0] as Dictionary).get("puzzle_id", "")) == "puz_anillos")

	var json: String = tel.exportar_json()
	_check("exportar_json() produce JSON válido", typeof(JSON.parse_string(json)) == TYPE_DICTIONARY)
	var tel2 = TelGd.new("x")
	var reimp: bool = tel2.cargar_json(json)
	_check("cargar_json() reimporta la exportación", reimp and int(tel2.resumen_global().get("intentos", 0)) == 6)
	var json2: String = tel2.exportar_json()
	_check("round-trip: re-exportar da el mismo JSON", json2 == json)
	_fin("D")


# ------------------------------------------------------------------ E ------

func _bloque_e() -> void:
	print("[E] TemploValidadores — el diseño real pasa las 6 suites")
	var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RUTA_DISENO))
	var bp: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RUTA_BLUEPRINT))
	_check("layout de diseño: 20 salas", (layout.get("salas", []) as Array).size() == 20)
	_check("layout de diseño: 24 conexiones", (layout.get("conexiones", []) as Array).size() == 24)
	_check("softlock: 0 problemas", ValGd.validar_softlock(layout).is_empty(), str(ValGd.validar_softlock(layout)))
	_check("anti-exploit: 0 problemas", ValGd.validar_anti_exploit(layout, bp).is_empty(), str(ValGd.validar_anti_exploit(layout, bp)))
	_check("voxel: 0 problemas", ValGd.validar_voxel(bp).is_empty(), str(ValGd.validar_voxel(bp)))
	_check("accesibilidad: 0 problemas", ValGd.validar_accesibilidad(bp).is_empty(), str(ValGd.validar_accesibilidad(bp)))
	_check("orientación: 0 problemas", ValGd.validar_orientacion(bp).is_empty(), str(ValGd.validar_orientacion(bp)))
	_check("checkpoints: 0 problemas", ValGd.validar_checkpoints(layout, bp).is_empty(), str(ValGd.validar_checkpoints(layout, bp)))
	var todo: Dictionary = ValGd.validar_todo(layout, bp)
	_check("validar_todo().ok == true", bool(todo.get("ok", false)))
	_check("las 20 salas son alcanzables desde 'porte'", ValGd.alcanzables(layout, "porte").size() == 20)
	_check("7 puzzles con recompensa (7 sellos de cristal)", _contar_recompensas(layout) == 7)
	_check("las 4 salas secretas tienen recompensa", _contar_salas_secretas(layout) == 4)
	_fin("E")


# ------------------------------------------------------------------ F ------

func _bloque_f() -> void:
	print("[F] TemploValidadores — detecta fallos inyectados")
	var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RUTA_DISENO))
	var bp: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RUTA_BLUEPRINT))

	# 1) sala inalcanzable (softlock)
	var l1: Dictionary = layout.duplicate(true)
	l1["conexiones"] = _sin_conexion(l1["conexiones"], "sec_mural", "h_secuencia")
	l1["conexiones"] = _sin_conexion(l1["conexiones"], "sec_mural", "final")
	_check("detecta sala inalcanzable", _tiene(ValGd.validar_softlock(l1), "inalcanzable"))

	# 2) zona con recompensa con un solo camino
	var l2: Dictionary = layout.duplicate(true)
	l2["conexiones"] = _sin_conexion(l2["conexiones"], "sec_placa", "pasillo_artesano")
	_check("detecta zona con recompensa con <2 caminos", _tiene(ValGd.validar_softlock(l2), "menos de 2 caminos"))

	# 3) sello duplicable
	var l3: Dictionary = layout.duplicate(true)
	(l3["puzzles"] as Array)[5]["recompensa"] = "sello_cristal_1"
	_check("detecta sello duplicable", _tiene(ValGd.validar_anti_exploit(l3, bp), "duplicada"))

	# 4) salida sin gating
	var l4: Dictionary = layout.duplicate(true)
	for sala in (l4["salas"] as Array):
		if str((sala as Dictionary).get("tipo", "")) == "salida":
			(sala as Dictionary)["requiere"] = ""
	_check("detecta salida sin exigir el sello", _tiene(ValGd.validar_anti_exploit(l4, bp), "sello_restaurado"))

	# 5) voxel: corredor 3x3x3
	var b1: Dictionary = bp.duplicate(true)
	b1["voxel"]["corredor"] = {"ancho": 3, "alto": 3, "largo": 3}
	_check("detecta corredor != 4x4x4", _tiene(ValGd.validar_voxel(b1), "4x4x4"))

	# 6) teleports
	var b2: Dictionary = bp.duplicate(true)
	b2["voxel"]["teleports"] = true
	_check("detecta teleports", _tiene(ValGd.validar_anti_exploit(layout, b2), "teleports"))

	# 7) rampa > 20°
	var b5: Dictionary = bp.duplicate(true)
	b5["voxel"]["rampa_grados_max"] = 30
	_check("detecta rampa > 20°", _tiene(ValGd.validar_voxel(b5), "rampa"))

	# 8) accesibilidad: contraste bajo
	var b3: Dictionary = bp.duplicate(true)
	b3["accesibilidad"]["contraste_min"] = 2.0
	_check("detecta contraste < 4.5:1", _tiene(ValGd.validar_accesibilidad(b3), "contraste"))

	# 9) accesibilidad: presión temporal
	var b6: Dictionary = bp.duplicate(true)
	b6["accesibilidad"]["presion_temporal"] = true
	_check("detecta presión temporal", _tiene(ValGd.validar_accesibilidad(b6), "presión"))

	# 10) orientación: mojones cada 60 m
	var b4: Dictionary = bp.duplicate(true)
	b4["orientacion"]["mojon_metros_max"] = 60
	_check("detecta mojones > 40 m", _tiene(ValGd.validar_orientacion(b4), "mojones"))

	# 11) checkpoint faltante
	var l5: Dictionary = layout.duplicate(true)
	for sala in (l5["salas"] as Array):
		if str((sala as Dictionary).get("id", "")) == "central":
			(sala as Dictionary)["checkpoint"] = false
	_check("detecta checkpoint faltante", _tiene(ValGd.validar_checkpoints(l5, bp), "deben existir 5"))

	# 12) el layout de iteración 1 (4 salas lineales) NO es voxel-compatible ni
	#     tiene 5 CP: el validador debe rechazarlo, no "aprobar todo".
	var iter1: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RUTA_ITER1))
	_check("el layout de iter 1 no pasa la suite de checkpoints",
		not ValGd.validar_checkpoints(iter1, bp).is_empty())
	_fin("F")


func _contar_salas_secretas(layout: Dictionary) -> int:
	var n := 0
	for s in (layout.get("salas", []) as Array):
		if str((s as Dictionary).get("tipo", "")) == "secreta":
			n += 1
	return n


# ------------------------------------------------------------------ G ------

func _bloque_g() -> void:
	print("[G] TemploSchema (iteración 1) sigue verde sobre su layout")
	var templo: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RUTA_ITER1))
	_check("layout de iteración 1 válido para TemploSchema", SchemaGd.validar_layout(templo).is_empty())
	_fin("G")


# ----------------------------------------------------------------- run -----

func _run() -> void:
	print("=== [M26] Templo Subterráneo — iteración 2 (DeepSeek-V4.1-Flash / WorkBuddy) ===")
	glifos = _glifos_del_diseno()
	_check("se leyeron 7 glifos del diseño", glifos.size() == 7)
	_bloque_a()
	_bloque_b()
	_bloque_c()
	_bloque_d()
	_bloque_e()
	_bloque_f()
	_bloque_g()
	# Anti-falso-verde: si un bloque no se ejecutó (error de script que aborta la
	# función en silencio), su marcador falta y esto lo delata.
	for b in ["A", "B", "C", "D", "E", "F", "G"]:
		_check("bloque %s ejecutado hasta el final" % b, _marcadores.has(b))
	print("=== Resumen M26: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
