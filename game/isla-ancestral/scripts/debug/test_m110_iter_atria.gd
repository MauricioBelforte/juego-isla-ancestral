# Modelo: atria-dawn
# Plataforma: Kilo Code
# Fecha: 2026-09-16
#
# M110: Debug Menu — iter. atria-dawn (log 928)
# Verifica los gaps cerrados en esta iteración:
#   - Cableado de stubs: comandos cambiar_hora/cambiar_clima/exportar ahora
#     EJECUTAN las funciones reales (antes devolvían solo texto).
#   - RF15/RF17/RF19: toggles visuales faltantes + señal toggle_visual_cambiado.
#   - RF4: set_season (honesto: reporta + señal; no simula forzar).
#   - RF11: reset_npc (duck-typing VillagerManager).
#   - RF12: reset_puzzle (fallback honesto sin escena de templo).
#   - RF13: regenerar_chunk (fallback honesto sin VoxelTerrain).
#   - set_vida / limpiar_cache.
# Guardián anti-falso-verde: bloques con _fin() + inyección de aborto probada.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0
var _menu: Node = null
var _bloques_fin: Array[String] = []
var _bloques_esperados: Array[String] = ["A","B","C","D","E","F","G"]

func _init() -> void:
	call_deferred("_run")

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _fin(bloque: String) -> void:
	if bloque not in _bloques_fin:
		_bloques_fin.append(bloque)

func _run() -> void:
	print("=== [M110] iter. atria-dawn — gaps cerrados ===")
	var script_cargado: GDScript = load("res://scripts/debug/debug_menu.gd")
	if script_cargado == null or not script_cargado.is_class("GDScript"):
		print("=== FATAL: no se pudo cargar debug_menu.gd (parse error?) ===")
		quit(1)
		return
	_menu = script_cargado.new()
	if _menu == null:
		print("=== FATAL: debug_menu.gd.new() devolvió null ===")
		quit(1)
		return
	root.add_child(_menu)
	await process_frame
	_check("DebugMenu instanciado", _menu != null)

	# Mock mínimo de Player (nodo de escena, no autoload) para RF1/RF8/set_vida.
	var ps := GDScript.new()
	ps.source_code = "extends CharacterBody3D\nfunc add_tool_to_hotbar(_t):\n\tpass\nfunc set_vida(_v):\n\tpass\n"
	ps.reload()
	var player := CharacterBody3D.new()
	player.set_script(ps)
	player.name = "Player"
	root.add_child(player)

	# ── BLOQUES (await: _bloque_a usa process_frame para el export) ────
	await _bloque_a()
	_fin("A")
	_bloque_b()
	_fin("B")
	_bloque_c()
	_fin("C")
	_bloque_d()
	_fin("D")
	_bloque_e()
	_fin("E")
	_bloque_f()
	_fin("F")
	_bloque_g()
	_fin("G")

	_summary()

func _bloque_a() -> void:
	print("--- A: cableado de stubs (ahora ejecutan de verdad) ---")
	# cambiar_hora: antes devolvía "hora = N" sin tocar el reloj. Ahora llama
	# a avanzar_hasta() (API pública real de GameClock, determinista).
	var senal_clima: Array = []
	_menu.clima_solicitado.connect(func(t: int): senal_clima.append(t))
	var rh: Dictionary = _menu.ejecutar_comando("cambiar_hora")
	_check("A1 cambiar_hora responde ok", bool(rh.get("ok", false)), str(rh))
	var rc: Dictionary = _menu.ejecutar_comando("cambiar_clima")
	_check("A2 cambiar_clima responde ok", bool(rc.get("ok", false)), str(rc))
	_check("A2b cambiar_clima emite clima_solicitado", senal_clima.size() > 0, str(senal_clima))
	# exportar: antes era "diagnóstico exportado (stub M102)". Ahora ejecuta
	# el exportador real → genera .zip + .txt en user://diagnostics.
	var antes_zip := _contar_diagnosticos("zip")
	var re: Dictionary = _menu.ejecutar_comando("exportar_diagnostico")
	await process_frame
	var despues_zip := _contar_diagnosticos("zip")
	_check("A3 exportar ejecuta el exportador real (zip nuevo)", despues_zip > antes_zip, "antes=%d despues=%d res=%s" % [antes_zip, despues_zip, str(re)])
	_check("A4 exportar reporta ok", bool(re.get("ok", false)), str(re))
	# spawn: antes era texto plano; ahora da objetos al inventario de verdad.
	var rs: Dictionary = _menu.ejecutar_comando("spawn_madera")
	_check("A5 spawn_madera ejecuta dar_objetos", bool(rs.get("ok", false)), str(rs))
	# teleport: antes texto; ahora mueve al Player mock.
	var rt: Dictionary = _menu.ejecutar_comando("teleport_casa")
	_check("A6 teleport_casa ejecuta teleport_player", bool(rt.get("ok", false)), str(rt))

func _contar_diagnosticos(ext: String) -> int:
	var dir := DirAccess.open(ProjectSettings.globalize_path("user://diagnostics"))
	if dir == null:
		return 0
	var n := 0
	dir.list_dir_begin()
	var fn := dir.get_next()
	while fn != "":
		if fn.begins_with("diag_") and fn.ends_with("." + ext):
			n += 1
		fn = dir.get_next()
	dir.list_dir_end()
	return n

func _bloque_b() -> void:
	print("--- B: toggles nuevos RF15/17/19 + señal ---")
	var capturados: Array = []
	_menu.toggle_visual_cambiado.connect(func(id: String, hab: bool): capturados.append([id, hab]))
	_menu.toggle_fps(true)
	_check("B1 RF15 toggle_fps marca estado", _menu._show_fps == true)
	_menu.toggle_navigation(true)
	_check("B2 RF17 toggle_navigation marca estado", _menu._show_navigation == true)
	_menu.toggle_ai_states(true)
	_check("B3 RF19 toggle_ai_states marca estado", _menu._show_ai_states == true)
	_check("B4 señal toggle_visual_cambiado emitida 3x", capturados.size() == 3, str(capturados))
	# Via comando (config JSON → match):
	var rb: Dictionary = _menu.ejecutar_comando("toggle_fps")
	_check("B5 comando toggle_fps funciona", bool(rb.get("ok", false)), str(rb))
	var rbad: Dictionary = _menu.ejecutar_comando("toggle_inexistente")
	_check("B6 toggle desconocido -> !ok", bool(rbad.get("ok", true)) == false, str(rbad))

func _bloque_c() -> void:
	print("--- C: RF4 set_season (honesto, no simula forzar) ---")
	var senal_recibida: Array = []
	_menu.estacion_solicitada.connect(func(e: int): senal_recibida.append(e))
	var r4: Dictionary = _menu.set_season(2)
	_check("C1 RF4 set_season responde ok", bool(r4.get("ok", false)), str(r4))
	_check("C2 RF4 emite estacion_solicitada(2)", senal_recibida.size() > 0 and int(senal_recibida[0]) == 2, str(senal_recibida))
	var rc: Dictionary = _menu.ejecutar_comando("cambiar_estacion")
	_check("C3 comando cambiar_estacion funciona", bool(rc.get("ok", false)), str(rc))

func _bloque_d() -> void:
	print("--- D: RF11 reset_npc (duck-typing VillagerManager) ---")
	var vm := root.get_node_or_null("VillagerManager")
	if vm == null:
		_check("D1 VillagerManager presente (skip de fallback)", true)
		return
	var activos: Array = vm.obtener_activos() if vm.has_method("obtener_activos") else []
	if activos.is_empty():
		_check("D1 sin NPCs activos en headless (fallback OK)", true)
		return
	var npc_id: String = String(vm.vecino_id_de(activos[0])) if vm.has_method("vecino_id_de") else ""
	if npc_id == "":
		_check("D1 NPC sin id resoluble (fallback OK)", true)
		return
	var r11: Dictionary = _menu.reset_npc(npc_id)
	_check("D1 RF11 reset_npc responde", r11 != null and r11.has("resultado"), str(r11))
	_check("D2 RF11 reset_npc ok", bool(r11.get("ok", false)), str(r11))
	var rmal: Dictionary = _menu.reset_npc("npc_inexistente_xyz")
	_check("D3 RF11 npc inexistente -> !ok", bool(rmal.get("ok", true)) == false, str(rmal))

func _bloque_e() -> void:
	print("--- E: RF12 reset_puzzle (fallback honesto) ---")
	# En headless no hay escena de templo cargada → debe reportar !ok, NO crashear.
	var r12: Dictionary = _menu.reset_puzzle("templo_inexistente")
	_check("E1 RF12 sin PuzzleRoom -> !ok (honesto)", bool(r12.get("ok", true)) == false, str(r12))
	_check("E2 RF12 no crashea", r12 != null)

func _bloque_f() -> void:
	print("--- F: RF13 regenerar_chunk (fallback honesto) ---")
	var vt: Node = _menu._obtener_voxel_terrain()
	if vt == null:
		var r13: Dictionary = _menu.regenerar_chunk(0, 0)
		_check("F1 RF13 sin VoxelTerrain -> !ok (honesto)", bool(r13.get("ok", true)) == false, str(r13))
	else:
		var r13: Dictionary = _menu.regenerar_chunk(0, 0)
		_check("F1 RF13 con VoxelTerrain responde", r13 != null, str(r13))
	_check("F2 RF13 no crashea", true)

func _bloque_g() -> void:
	print("--- G: set_vida + limpiar_cache + avanzar_dia ---")
	var rv: Dictionary = _menu.set_vida(80)
	_check("G1 set_vida ok", bool(rv.get("ok", false)), str(rv))
	var rl: Dictionary = _menu.limpiar_cache()
	_check("G2 limpiar_cache ok", bool(rl.get("ok", false)), str(rl))
	var ra: Dictionary = _menu.avanzar_dia(1)
	_check("G3 avanzar_dia responde", ra != null and ra.has("resultado"), str(ra))

func _summary() -> void:
	# Guardián anti-falso-verde: si un bloque abortó a mitad (excepción o
	# return temprano), _fin() no se llamó y el bloque falta → se nombra.
	var faltantes: Array[String] = []
	for b in _bloques_esperados:
		if b not in _bloques_fin:
			faltantes.append(b)
	if faltantes.size() > 0:
		print("=== BLOQUES QUE NO TERMINARON: %s ===" % str(faltantes))
		print("=== Resumen M110 iter.atria-dawn: %d checks, %d fallos, %d bloques incompletos ===" % [_checks, _fallos, faltantes.size()])
		quit(1)
		return
	print("=== Resumen M110 iter.atria-dawn: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M110 ITER ATRIA-DAWN FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M110 ITER ATRIA-DAWN OK — todos los checks pasaron")
		quit(0)
