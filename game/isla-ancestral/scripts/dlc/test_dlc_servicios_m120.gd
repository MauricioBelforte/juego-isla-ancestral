# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-12
#
# M120: DLC y Expansiones — Test de los 3 servicios (D3)
# Cubre DLCCompatibilityChecker, DLCBundleManager, DLCUninstaller y los
# loaders de contenido de DlcManager.
#
# Guardian de 3 capas (trampa 122 del skill):
#   1. marcadores _fin("X") por bloque -> nombra el bloque que no cerro
#   2. piso CHECKS_MINIMOS MEDIDO en verde -> caza el aborto dentro de un helper
#   3. _summary() diferido en _init -> si _run() aborta, el resumen corre igual

extends SceneTree

const _SC_COMPAT := preload("res://scripts/dlc/dlc_compatibility_checker.gd")
const _SC_UNINST := preload("res://scripts/dlc/dlc_uninstaller.gd")
const _SC_BUNDLES := preload("res://scripts/dlc/dlc_bundle_manager.gd")
const _SC_DM := preload("res://scripts/dlc/dlc_manager.gd")

const BLOQUES := ["A", "B", "C", "D", "E", "F"]
const CHECKS_MINIMOS := 61  # MEDIDO en verde (3 corridas), no estimado

var _fallos: int = 0
var _checks: int = 0
var _vistos: Dictionary = {}

## Doble de prueba del DlcManager: version base y DLCs activos inyectables.
class FakeManager extends RefCounted:
	var version := "1.0.0"
	var activos: Array = []

	func version_base_actual() -> String:
		return version

	func esta_activo(id: String) -> bool:
		return id in activos

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _fin(nombre: String) -> void:
	_vistos[nombre] = true

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _run() -> void:
	print("=== [M120] Test servicios DLC (D3) ===")
	_bloque_a_checker()
	_bloque_b_bundles()
	_bloque_c_uninstaller()
	_bloque_d_loaders()
	_bloque_e_integracion()
	_bloque_f_config()

func _summary() -> void:
	var faltantes: Array = []
	for n in BLOQUES:
		if not _vistos.has(n):
			faltantes.append(n)
	if not faltantes.is_empty():
		_fallos += 1
		print("[FAIL] bloques NO cerrados: %s" % str(faltantes))
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M120 servicios: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M120 servicios FALLIDO — salida con codigo 1")
		quit(1)
	else:
		print("TEST M120 servicios OK — todos los checks pasaron")
		quit(0)

func _bloque_a_checker() -> void:
	print("--- A: DLCCompatibilityChecker ---")
	var chk = _SC_COMPAT.new()
	_check("A1 get_base_game_version no vacio", not chk.get_base_game_version().is_empty())
	_check("A2 1.0.0 vs 1.0.0 -> true", chk.is_version_compatible("1.0.0", "1.0.0") == true)
	_check("A3 0.9.0 vs 1.0.0 -> false", chk.is_version_compatible("0.9.0", "1.0.0") == false)
	_check("A4 1.10.0 vs 1.9.0 -> true (semantico)", chk.is_version_compatible("1.10.0", "1.9.0") == true)
	_check("A5 sin requisito -> true", chk.is_version_compatible("0.1.0", "") == true)
	_check("A6 dlc_data vacio -> false", chk.check_compatibility({}) == false)

	var fake := FakeManager.new()
	fake.version = "1.0.0"
	var chk2 = _SC_COMPAT.new(fake)
	var isla := {"id": "isla_hielo", "version_requerida": "1.0.0", "dependencias": []}
	_check("A7 compatible con base 1.0.0", chk2.check_compatibility(isla) == true)
	fake.version = "0.9.0"
	_check("A8 incompatible con base 0.9.0", chk2.check_compatibility(isla) == false)
	fake.version = "1.0.0"
	var con_dep := {"id": "x", "version_requerida": "1.0.0", "dependencias": ["pack_aurora"]}
	_check("A9 dependencia ausente -> false", chk2.check_compatibility(con_dep) == false)
	fake.activos = ["pack_aurora"]
	_check("A10 dependencia activa -> true", chk2.check_compatibility(con_dep) == true)
	_check("A11 backward_compatible default true", chk.es_backward_compatible({}) == true)
	var con_flag := {"dlc_compatibility": {"backward_compatible": false}}
	_check("A12 backward_compatible false respetado", chk.es_backward_compatible(con_flag) == false)
	_fin("A")

func _bloque_b_bundles() -> void:
	print("--- B: DLCBundleManager ---")
	var bm = _SC_BUNDLES.new()
	_check("B1 total 4 bundles", bm.total() == 4, "n=%d" % bm.total())
	var ids: Array = bm.ids()
	_check("B2 season_pass_2024 presente", "season_pass_2024" in ids)
	_check("B3 bundle_completo presente", "bundle_completo" in ids)
	_check("B4 bundle_islas presente", "bundle_islas" in ids)
	_check("B5 precio bundle_completo 59.99", is_equal_approx(bm.get_bundle_price("bundle_completo"), 59.99))
	_check("B6 precio inexistente 0.0", bm.get_bundle_price("no_existe") == 0.0)
	_check("B7 bundle_islas 3 dlcs", bm.get_bundle_dlc_ids("bundle_islas").size() == 3)
	_check("B8 dlcs inexistente vacio", bm.get_bundle_dlc_ids("no_existe").is_empty())
	_check("B9 precio dlc isla_hielo 14.99", is_equal_approx(bm.get_dlc_price("isla_hielo"), 14.99))
	_check("B10 precio dlc inexistente 0.0", bm.get_dlc_price("no_existe") == 0.0)
	var d_deluxe: float = bm.calculate_bundle_discount("bundle_deluxe")
	_check("B11 descuento deluxe CALCULADO ~0.1496", absf(d_deluxe - 0.1496) < 0.005, "d=%f" % d_deluxe)
	_check("B12 descuento season_pass DECLARADO 0.30", is_equal_approx(bm.calculate_bundle_discount("season_pass_2024"), 0.30))
	var bm2 = _SC_BUNDLES.new("res://data/dlc/no_existe_zzz.json")
	_check("B13 ruta inexistente -> 0 bundles", bm2.total() == 0)
	_fin("B")

func _bloque_c_uninstaller() -> void:
	print("--- C: DLCUninstaller ---")
	var raiz := OS.get_temp_dir().path_join("m120_d3_uninstaller")
	var dir_saves := raiz.path_join("saves")
	var dir_dlc := raiz.path_join("dlc")
	_limpiar(raiz)
	DirAccess.make_dir_recursive_absolute(dir_saves)
	DirAccess.make_dir_recursive_absolute(dir_dlc.path_join("isla_hielo"))
	_escribir(dir_saves.path_join("slot_1.json"), {"dlc_content": {"isla_hielo": "complete"}, "dia": 1})
	_escribir(dir_saves.path_join("slot_2.json"), {"dlc_content": {"pack_aurora": "complete"}, "dia": 2})
	_escribir(dir_dlc.path_join("isla_hielo").path_join("a.pck"), {"x": 1})
	_escribir(dir_dlc.path_join("isla_hielo").path_join("b.pck"), {"x": 2})

	var un = _SC_UNINST.new(null, dir_saves, dir_dlc)
	_check("C1 marca 1 save", un.mark_savegames_as_incomplete("isla_hielo") == 1)
	var s1: Dictionary = _leer(dir_saves.path_join("slot_1.json"))
	var cont: Dictionary = s1.get("dlc_content", {})
	_check("C2 slot_1 marcado incomplete", str(cont.get("isla_hielo", "")) == "incomplete")
	var s2: Dictionary = _leer(dir_saves.path_join("slot_2.json"))
	var cont2: Dictionary = s2.get("dlc_content", {})
	_check("C3 slot_2 intacto", str(cont2.get("pack_aurora", "")) == "complete")
	_check("C4 update_savegames 1", un.update_savegames() == 1)
	_check("C5 borra 2 archivos", un.delete_dlc_files("isla_hielo") == 2)
	_check("C6 dir dlc borrado", not DirAccess.dir_exists_absolute(dir_dlc.path_join("isla_hielo")))
	_check("C7 dlc_id vacio -> 0", un.mark_savegames_as_incomplete("") == 0)

	var fake := FakeManager.new()
	fake.activos = ["isla_hielo"]
	var un2 = _SC_UNINST.new(fake, dir_saves, dir_dlc)
	var inf: Dictionary = un2.uninstall_dlc("isla_hielo")
	_check("C8 uninstall_dlc ok", bool(inf.get("ok", false)) == true)
	_check("C9 uninstall_dlc informa cargado", bool(inf.get("cargado", false)) == true)
	var inf2: Dictionary = un2.uninstall_dlc("no_existe")
	_check("C10 dlc no cargado -> ok false", bool(inf2.get("ok", false)) == false)
	var inf3: Dictionary = un2.uninstall_dlc("")
	_check("C11 dlc vacio -> ok false", bool(inf3.get("ok", false)) == false)
	_limpiar(raiz)
	_fin("C")

func _bloque_d_loaders() -> void:
	print("--- D: DlcManager loaders de contenido ---")
	var dm = root.get_node_or_null("DlcManager")
	if dm == null:
		_check("D1 DlcManager presente", false)
		_fin("D")
		return
	_check("D1 DlcManager presente", true)
	_check("D2 load_island", dm.load_island("isla_test_d3") == true)
	_check("D3 isla registrada", "isla_test_d3" in dm.contenido_cargado("islas"))
	_check("D4 load_biome", dm.load_biome("bioma_test_d3") == true)
	_check("D5 load_npc", dm.load_npc("npc_test_d3") == true)
	_check("D6 load_historia", dm.load_historia("hist_test_d3") == true)
	_check("D7 load_ruin", dm.load_ruin("ruina_test_d3") == true)
	_check("D8 load_music", dm.load_music("track_test_d3") == true)
	_check("D9 musica registrada", "track_test_d3" in dm.contenido_cargado("musica"))
	_check("D10 idempotente", dm.load_island("isla_test_d3") == true and dm.contenido_cargado("islas").size() == 1)
	_check("D11 tipo vacio -> false", dm.cargar_contenido("", "x") == false)
	_check("D12 id vacio -> false", dm.cargar_contenido("islas", "") == false)
	_check("D13 tipo inexistente -> []", dm.contenido_cargado("zzz").is_empty())
	_fin("D")

func _bloque_e_integracion() -> void:
	print("--- E: Accessors + cruce de versiones ---")
	var dm = root.get_node_or_null("DlcManager")
	_check("E1 accessor compatibility_checker", dm.compatibility_checker() != null)
	_check("E2 accessor uninstaller", dm.uninstaller() != null)
	_check("E3 accessor bundle_manager", dm.bundle_manager() != null)

	var chk = dm.compatibility_checker()
	var pares := [["1.0.0", "1.0.0"], ["0.9.0", "1.0.0"], ["1.10.0", "1.9.0"], ["2.0.0", "1.9.9"], ["1.0.0", "1.0.1"]]
	var cruces := 0
	for p in pares:
		var a := str(p[0])
		var b := str(p[1])
		var local: bool = chk.is_version_compatible(a, b)
		var manager: bool = int(_SC_DM.comparar_versiones(a, b)) >= 0
		if local == manager:
			cruces += 1
	_check("E4 cruce checker vs DlcManager (5/5)", cruces == 5, "n=%d" % cruces)
	_check("E5 base version coincide", chk.get_base_game_version() == dm.version_base_actual(), "chk=%s dm=%s" % [chk.get_base_game_version(), dm.version_base_actual()])
	var real_ok: bool = chk.check_compatibility(dm.dlc("isla_hielo"))
	var esperado: bool = int(_SC_DM.comparar_versiones(dm.version_base_actual(), "1.0.0")) >= 0
	_check("E6 check_compatibility real == prediccion", real_ok == esperado, "real=%s esp=%s" % [str(real_ok), str(esperado)])
	_fin("E")

func _bloque_f_config() -> void:
	print("--- F: Configuracion de bundles (dlc_manager) ---")
	var dm = root.get_node_or_null("DlcManager")
	_check("F1 season_pass_2024 existe", not dm.bundle("season_pass_2024").is_empty())
	_check("F2 bundle_completo existe", not dm.bundle("bundle_completo").is_empty())
	_check("F3 bundle_islas existe", not dm.bundle("bundle_islas").is_empty())
	_check("F4 season_pass descuento 0.30", is_equal_approx(float(dm.bundle("season_pass_2024").get("descuento", 0.0)), 0.30))
	_check("F5 bundle_completo contiene pack_aurora", "pack_aurora" in dm.bundle("bundle_completo").get("dlcs", []))
	_check("F6 bundle_islas 3 dlcs", dm.bundle("bundle_islas").get("dlcs", []).size() == 3)
	_fin("F")

# --- helpers de fixture ----------------------------------------------------

func _escribir(ruta: String, datos: Dictionary) -> void:
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(datos))
		f.close()

func _leer(ruta: String) -> Dictionary:
	if not FileAccess.file_exists(ruta):
		return {}
	var p: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	if typeof(p) == TYPE_DICTIONARY:
		return p
	return {}

func _limpiar(ruta: String) -> void:
	if not DirAccess.dir_exists_absolute(ruta):
		return
	var dir := DirAccess.open(ruta)
	if dir == null:
		return
	dir.list_dir_begin()
	var nombre := dir.get_next()
	while nombre != "":
		if dir.current_is_dir():
			_limpiar(ruta.path_join(nombre))
		else:
			DirAccess.remove_absolute(ruta.path_join(nombre))
		nombre = dir.get_next()
	dir.list_dir_end()
	DirAccess.remove_absolute(ruta)
