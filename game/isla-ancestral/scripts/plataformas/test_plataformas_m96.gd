# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M96: Plataformas — Test headless
# Valida: PlatformManager (bridge activo, matriz data-driven, prioridades),
# NullBridge (fallback sin cloud), SteamBridge mock (cloud simulada),
# cross-save (guardar/cargar cloud). Exit code != 0 si falla.

extends SceneTree

const _SC_BRIDGE := preload("res://scripts/plataformas/iplatform_bridge.gd")
const _SC_NULL := preload("res://scripts/plataformas/null_bridge.gd")
const _SC_STEAM := preload("res://scripts/plataformas/steam_bridge.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M96] Test de Plataformas ===")
	_test_manager()
	_test_null_bridge()
	_test_steam_bridge()
	_test_cross_save()
	_test_iter2_auto_detect()  # iter 2 (minimax-m3)
	_test_iter2_senales()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_manager() -> void:
	print("--- PlatformManager: bridge + matriz ---")
	var pm := root.get_node_or_null("PlatformManager")
	if pm == null:
		_check("PlatformManager autoload presente", false)
		_summary()
		quit(1)
		return
	_check("PlatformManager autoload presente", true)
	# Iter 2 (minimax-m3): en dev, OS.get_name() detecta plataforma real.
	# Windows -> "steam" o "windows" -> SteamBridge mock. Linux/macOS -> similar.
	# NullBridge es solo fallback si OS no se reconoce.
	_check("bridge activo", pm.bridge != null and (pm.bridge.nombre == "NullBridge" or pm.bridge.nombre == "SteamBridge"))
	_check("matriz con 10 plataformas", pm.matriz.size() == 10, "size=%d" % pm.matriz.size())
	var steam = pm.obtener_plataforma("steam")
	_check("steam en matriz", not steam.is_empty() and steam.get("prioridad", "") == "P0")
	_check("inexistente -> {}", pm.obtener_plataforma("no_existe").is_empty())
	var p0 = pm.plataformas_por_prioridad("P0")
	_check("P0 = steam + deck (2)", p0.size() == 2, "size=%d" % p0.size())
	_check("P0 ordenado: steam primero", String(p0[0].get("id", "")) == "steam")
	var p2 = pm.plataformas_por_prioridad("P2")
	_check("P2 = 3 consolas (GATE presupuesto)", p2.size() == 3, "size=%d" % p2.size())
	_check("ids = 10", pm.ids_plataformas().size() == 10)
	# API bridge en dev
	_check("cloud_disponible() en dev", pm.cloud_disponible() == pm.bridge.cloud_disponible() if pm.bridge else false)

func _test_null_bridge() -> void:
	print("--- NullBridge: fallback sin cloud ---")
	var n = _SC_NULL.new()
	_check("nombre NullBridge", n.nombre == "NullBridge")
	_check("cloud_disponible false", not n.cloud_disponible())
	_check("guardar_cloud false", n.guardar_cloud(PackedByteArray([1, 2])) == false)
	_check("cargar_cloud vacío", n.cargar_cloud().is_empty())
	_check("guardar_save_cloud false", n.guardar_save_cloud("user://x.bin") == false)

func _test_steam_bridge() -> void:
	print("--- SteamBridge (mock): cloud simulada ---")
	var s = _SC_STEAM.new()
	_check("nombre SteamBridge", s.nombre == "SteamBridge")
	_check("cloud disponible (mock)", s.cloud_disponible())
	var ok := s.guardar_cloud(PackedByteArray([9, 8, 7]))
	_check("guardar_cloud ok", ok)
	var data := s.cargar_cloud()
	_check("cargar_cloud round-trip", data == PackedByteArray([9, 8, 7]), "size=%d" % data.size())
	# limpiar
	DirAccess.remove_absolute("user://cloud/steam/save.bin")

func _test_cross_save() -> void:
	print("--- Cross-save: guardar/cargar save vía cloud (RF13) ---")
	var s = _SC_STEAM.new()
	var ruta := "user://test_cross_save.bin"
	if FileAccess.file_exists(ruta):
		DirAccess.remove_absolute(ruta)
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	f.store_buffer(PackedByteArray([1, 2, 3, 4]))
	f.close()
	var ok_save := s.guardar_save_cloud(ruta)
	_check("guardar_save_cloud ok", ok_save)
	DirAccess.remove_absolute(ruta)
	var ok_load := s.cargar_save_cloud(ruta)
	_check("cargar_save_cloud restaura", ok_load and FileAccess.file_exists(ruta))
	if FileAccess.file_exists(ruta):
		var data := FileAccess.get_file_as_bytes(ruta)
		_check("contenido íntegro", data == PackedByteArray([1, 2, 3, 4]), "size=%d" % data.size())
		DirAccess.remove_absolute(ruta)
	# NullBridge no hace cross-save
	var n = _SC_NULL.new()
	_check("null no guarda cloud", n.guardar_save_cloud(ruta) == false)
	DirAccess.remove_absolute("user://cloud/steam/save.bin")

func _summary() -> void:
	print("=== Resumen M96: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M96 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M96 OK — todos los checks pasaron")
		quit(0)

## ── Tests iter 2 (minimax-m3) ────────────────────────────────

func _test_iter2_auto_detect() -> void:
	print("--- Iter 2: auto-deteccion de plataforma via OS.get_name() ---")
	var pm := root.get_node_or_null("PlatformManager")
	if pm == null:
		_check("PlatformManager presente (iter 2)", false)
		return
	# plataforma_actual debe ser uno de los IDs conocidos
	_check("plataforma_actual detectada", pm.plataforma_actual != "")
	# "linux"/"macos"/"windows" son alias del id "steam" en dev (RF3: el build de Windows/Linux/macOS va a Steam)
	# Por lo tanto, plataforma_actual puede ser cualquiera de {steam, windows, linux, macos, null}
	var plat_in_matriz: bool = pm.matriz.has(pm.plataforma_actual) or pm.plataforma_actual in ["windows", "linux", "macos", "null"]
	_check("plataforma_actual conocida por el manager", plat_in_matriz)
	# _detectar_plataforma_actual debe devolver un id valido para OS actual
	var detected: String = pm._detectar_plataforma_actual()
	_check("_detectar_plataforma_actual() retorna string no vacio", detected != "")
	_check("detectada en {steam, windows, linux, macos, null}", detected in ["steam", "windows", "linux", "macos", "null"])
	# _bridge_para retorna Callable valida para plataformas conocidas, invalida para desconocidas
	var cb_steam: Callable = pm._bridge_para("steam")
	_check("_bridge_para(steam) valida", cb_steam.is_valid())
	var cb_deck: Callable = pm._bridge_para("steam_deck")
	_check("_bridge_para(steam_deck) valida", cb_deck.is_valid())
	var cb_unknown: Callable = pm._bridge_para("plataforma_fake_xyz")
	_check("_bridge_para(fake) invalida", not cb_unknown.is_valid())

func _test_iter2_senales() -> void:
	print("--- Iter 2: senales plataforma_cambiada y plataforma_no_soportada ---")
	var pm := root.get_node_or_null("PlatformManager")
	if pm == null:
		_check("PlatformManager presente (senales)", false)
		return
	# plataforma_cambiada es una signal property; verificamos que existe
	_check("plataforma_cambiada es una senal", pm.has_signal("plataforma_cambiada"))
	_check("plataforma_no_soportada es una senal", pm.has_signal("plataforma_no_soportada"))
	# plataforma_actual no debe estar vacio (se setea en _ready)
	_check("plataforma_actual seteada en _ready", pm.plataforma_actual != "")