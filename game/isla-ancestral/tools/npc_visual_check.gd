# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M161: Verificador del catálogo visual de NPCs (auditoría data-driven).
# Carga todos los .tres de data/npc_visuals/ (recursivo), los valida contra
# las reglas del 03-Diseno (23 NPCs, 4 islas, rangos de piel/cabello/ojos,
# HEX válidos, npc_id coincidente con isla) y escribe tools/reportes/npc_visual_check.txt.
# Ejecutar: godot --headless --path game/isla-ancestral -s res://tools/npc_visual_check.gd

extends SceneTree

const RAiz := "res://data/npc_visuals/"
const ISLAS := ["RIZ", "COR", "CEN", "AUR"]
const EXPECTADOS := 23

var _fallos: int = 0
var _aviso: int = 0
var _total: int = 0
var _lineas := PackedStringArray()

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_lineas.append("=== M161: VERIFICADOR VISUAL DE NPCs (2026-09-02) ===")
	_lineas.append("")
	var visuales: Array[NPCVisualData] = []
	var ids_usados := {}
	_escaneados(RAiz, visuales, ids_usados)
	_total = visuales.size()

	_check(_total == EXPECTADOS, "total de diseños = %d (esperado %d)" % [_total, EXPECTADOS])
	_check(ids_usados.size() == _total, "ids únicos = %d (esperado %d)" % [ids_usados.size(), _total])

	for visual in visuales:
		_verificar_visual(visual)

	# Estructura por isla (03-Diseno §4-7: 8/5/5/5)
	for isla in ISLAS:
		var n := 0
		for v in visuales:
			if v.isla == isla:
				n += 1
		var esperado := 8 if isla == "RIZ" else 5
		_check(n == esperado, "isla %s: %d diseños (esperado %d)" % [isla, n, esperado])

	_lineas.append("")
	_lineas.append("=== Resultado: %d diseños, %d fallo(s), %d aviso(s) ===" % [_total, _fallos, _aviso])
	_dir_report()
	print("\n".join(_lineas))
	quit(1 if _fallos > 0 else 0)

func _escaneados(ruta: String, visuales: Array[NPCVisualData], ids: Dictionary) -> void:
	var dir := DirAccess.open(ruta)
	if dir == null:
		return
	dir.list_dir_begin()
	var nombre := dir.get_next()
	while nombre != "":
		var ruta_archivo := ruta + nombre
		if dir.current_is_dir() and nombre != "." and nombre != "..":
			_escaneados(ruta_archivo + "/", visuales, ids)
		elif nombre.ends_with(".tres"):
			var v := load(ruta_archivo) as NPCVisualData
			if v and v.npc_id != "":
				visuales.append(v)
				ids[v.npc_id] = true
			else:
				_aviso += 1
				_lineas.append("  [AVISO] .tres inválido: " + ruta_archivo)
		nombre = dir.get_next()
	dir.list_dir_end()

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		_lineas.append("  [FALLO] " + msg)
	else:
		_lineas.append("  [OK] " + msg)

func _verificar_visual(v: NPCVisualData) -> void:
	# npc_id formato
	var prefijo := String(v.npc_id).substr(0, 7)
	_check(ISLAS.has(v.isla), "%s: isla válida (%s)" % [v.npc_id, v.isla])
	_check(prefijo == "NPC-" + v.isla, "%s: npc_id coincide isla (%s)" % [v.npc_id, prefijo])
	# piel/cabello/ojos
	_check(RegEx.create_from_string("^SK-0[1-5]$").search(v.piel) != null, "%s: piel válida (%s)" % [v.npc_id, v.piel])
	_check(RegEx.create_from_string("^HR-0[1-8]$").search(v.cabello) != null, "%s: cabello válido (%s)" % [v.npc_id, v.cabello])
	_check(RegEx.create_from_string("^EY-0[1-5]$").search(v.ojos) != null, "%s: ojos válidos (%s)" % [v.npc_id, v.ojos])
	# colores HEX de prendas presentes
	var prendas := {"sombrero": v.sombrero, "torso": v.torso, "piernas": v.piernas, "pies": v.pies}
	var hex_rex := RegEx.create_from_string("^#[0-9A-Fa-f]{6}$")
	for clave in prendas:
		var prenda = prendas[clave]
		if prenda == null:
			_aviso += 1
			_lineas.append("  [AVISO] %s: prenda '%s' nula" % [v.npc_id, clave])
			continue
		var color := String(prenda.get("color_principal", ""))
		if color == "" or hex_rex.search(color) == null:
			_aviso += 1
			_lineas.append("  [AVISO] %s: '%s' sin HEX válido ('%s')" % [v.npc_id, clave, color])

func _dir_report() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tools/reportes"))
	var f := FileAccess.open("res://tools/reportes/npc_visual_check.txt", FileAccess.WRITE)
	if f:
		f.store_string("\n".join(_lineas))
		f.close()
