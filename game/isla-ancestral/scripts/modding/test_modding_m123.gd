# Modelo: deepseek-v4-flash (núcleo) · DeepSeek-V4.1-Flash (iter. 2, 2026-09-13)
# Plataforma: Kilo Code · WorkBuddy
# Fecha: 2026-09-13
#
# M123: Modding — Test headless (11 bloques A-K)
# Valida: ModdingManager (manifiesto, compatibilidad, conflictos, prioridad,
# updates M118) + ModValidator (códigos de error, paquete corrupto) +
# ModSandbox (path traversal, esquema de assets M108).
# Exit code != 0 si falla.
#
# Blindaje contra FALSO VERDE: cada bloque deja un marcador `_fin()` y `_run()`
# comprueba que TODOS los bloques corrieron (un error de script aborta la función
# en silencio y el suite imprimiría "0 fallos" con el bloque salteado).
#
# Preloads: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/modding/mod_validator.gd")
const _SC_SANDBOX := preload("res://scripts/modding/mod_sandbox.gd")

const BLOQUES := ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K"]

var _fallos: int = 0
var _checks: int = 0
var _hechos: Array = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M123] Test de Modding ===")
	_test_manifest()            # A
	_test_compatibilidad()      # B
	_test_conflictos()          # C
	_test_validator()           # D
	_test_validator_errores()   # E
	_test_sandbox()             # F
	_test_assets_m108()         # G
	_test_paquete()             # H
	_test_prioridad()           # I
	_test_update_m118()         # J
	_test_codigos()             # K
	_verificar_bloques()
	_summary()

func _fin(bloque: String) -> void:
	_hechos.append(bloque)

func _verificar_bloques() -> void:
	for b in BLOQUES:
		_check("bloque %s ejecutado (sin aborto silencioso)" % b, b in _hechos)

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _mm() -> Node:
	return root.get_node_or_null("ModdingManager")

# --- A ---------------------------------------------------------------------
func _test_manifest() -> void:
	print("--- A. Manifest: mods data-driven ---")
	var mm := _mm()
	if mm == null:
		_check("ModdingManager autoload presente", false)
		_fin("A")
		return
	_check("ModdingManager autoload presente", true)
	_check("2 mods", mm.config.get("mods", []).size() == 2, "size=%d" % mm.config.get("mods", []).size())
	_check("mod_aurora_items existe", not mm.mod("mod_aurora_items").is_empty())
	_check("mod inexistente -> {}", mm.mod("no_existe").is_empty())
	_check("carpeta mods user://mods", mm.carpeta_mods() == "user://mods")
	_check("schema_version presente", String(mm.config.get("schema_version", "")) == "1.0")
	_fin("A")

# --- B ---------------------------------------------------------------------
func _test_compatibilidad() -> void:
	print("--- B. Compatibilidad y activación ---")
	var mm := _mm()
	_check("mod compatible con 1.0.0", mm.es_compatible("mod_aurora_items", "1.0.0") == true)
	_check("mod incompatible con 0.8.0", mm.es_compatible("mod_aurora_items", "0.8.0") == false)
	_check("mod inexistente incompatible", mm.es_compatible("no_existe", "1.0.0") == false)
	_check("activar mod", mm.activar("mod_aurora_items") == true)
	_check("mod activo", mm.esta_activo("mod_aurora_items") == true)
	_check("activar inexistente falla", mm.activar("no_existe") == false)
	_fin("B")

# --- C ---------------------------------------------------------------------
func _test_conflictos() -> void:
	print("--- C. Conflictos: override ---")
	var mm := _mm()
	var conflictos: Array = mm.detectar_conflictos()
	_check("1 conflicto (mod_aurora_qol override)", conflictos.size() == 1, "size=%d" % conflictos.size())
	if conflictos.size() >= 1:
		_check("conflicto mod_aurora_qol -> mod_aurora_items",
			String(conflictos[0].get("override", "")) == "mod_aurora_items")
	_fin("C")

# --- D ---------------------------------------------------------------------
func _test_validator() -> void:
	print("--- D. ModValidator: data real ---")
	var mm := _mm()
	var errores: Array = _SC_VALIDATOR.validar(mm.config)
	_check("config válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))
	_fin("D")

# --- E ---------------------------------------------------------------------
func _test_validator_errores() -> void:
	print("--- E. ModValidator: errores detectados ---")
	var malo := {
		"mods": [
			{"id": "", "version": "", "min_build": "", "override": []},
			{"id": "a", "version": "1.0", "min_build": "1.0", "override": ["b"]}
		]
	}
	var errores: Array = _SC_VALIDATOR.validar(malo)
	_check("mod sin id detectado", str(errores).contains("sin id"))
	_check("mod sin versión detectado", str(errores).contains("sin versión"))
	_check("override 'b' no existe detectado", str(errores).contains("b"))
	# Duplicado CON override NO es error (es override legítimo)
	var dup := {"mods": [
		{"id": "x", "version": "1.0", "min_build": "1.0", "override": []},
		{"id": "x", "version": "1.0", "min_build": "1.0", "override": ["y"]},
		{"id": "y", "version": "1.0", "min_build": "1.0", "override": []},
	]}
	_check("duplicado con override no bloquea",
		not str(_SC_VALIDATOR.validar(dup)).contains("duplicado"))
	_fin("E")

# --- F ---------------------------------------------------------------------
func _test_sandbox() -> void:
	print("--- F. ModSandbox: aislamiento de paths (§4) ---")
	var base := "user://mods/m1"
	_check("ruta relativa válida aceptada",
		bool(_SC_SANDBOX.ruta_segura("assets/x.glb", base).get("ok", false)))
	_check("ruta queda dentro de la base",
		String(_SC_SANDBOX.ruta_segura("assets/x.glb", base).get("ruta", "")) == "user://mods/m1/assets/x.glb")
	_check("'..' rechazado",
		not bool(_SC_SANDBOX.ruta_segura("../../etc/passwd", base).get("ok", true)))
	_check("'..' anidado rechazado",
		not bool(_SC_SANDBOX.ruta_segura("assets/../../secreto", base).get("ok", true)))
	_check("ruta absoluta rechazada",
		not bool(_SC_SANDBOX.ruta_segura("/etc/passwd", base).get("ok", true)))
	_check("unidad de disco rechazada",
		not bool(_SC_SANDBOX.ruta_segura("C:/Windows/system32", base).get("ok", true)))
	_check("backslash con '..' rechazado",
		not bool(_SC_SANDBOX.ruta_segura("assets\\..\\..\\x", base).get("ok", true)))
	_check("ruta vacía rechazada",
		not bool(_SC_SANDBOX.ruta_segura("", base).get("ok", true)))
	_fin("F")

# --- G ---------------------------------------------------------------------
func _test_assets_m108() -> void:
	print("--- G. Esquema de assets (espejo de M108) (§3) ---")
	_check("nombre válido mdl_*", _SC_SANDBOX.nombre_asset_valido("mdl_item_espada_01"))
	_check("nombre válido ui_*", _SC_SANDBOX.nombre_asset_valido("ui_qol_hud_01"))
	_check("nombre sin prefijo rechazado", not _SC_SANDBOX.nombre_asset_valido("espada"))
	_check("nombre con mayúsculas rechazado", not _SC_SANDBOX.nombre_asset_valido("mdl_Item_01"))
	_check("prefijo desconocido rechazado", not _SC_SANDBOX.nombre_asset_valido("xyz_algo_01"))
	_check("glb con prefijo mdl OK", _SC_SANDBOX.extension_compatible("mdl_item_espada_01.glb"))
	_check("png con prefijo mdl rechazado", not _SC_SANDBOX.extension_compatible("mdl_item_espada_01.png"))
	_check("png con prefijo ui OK", _SC_SANDBOX.extension_compatible("ui_qol_hud_01.png"))
	# validar_assets: >10 MB y duplicado
	var assets := [
		{"nombre": "tex_item_pesada_01", "ruta": "assets/tex_item_pesada_01.png", "mb": 12.5},
		{"nombre": "ui_qol_hud_01", "ruta": "assets/ui_qol_hud_01.png", "mb": 0.3},
		{"nombre": "ui_qol_hud_01", "ruta": "assets/ui_qol_hud_01.png", "mb": 0.3},
		{"nombre": "espada", "ruta": "../../fuera.png", "mb": 0.1},
	]
	var errs: Array = _SC_SANDBOX.validar_assets(assets, "user://mods/m1")
	var s := str(errs)
	_check("E11 límite 10 MB detectado", s.contains("E11"))
	_check("E12 duplicado detectado", s.contains("E12"))
	_check("E08 nombre inválido detectado", s.contains("E08"))
	_check("E10 path traversal detectado", s.contains("E10"))
	_check("paquete limpio -> 0 errores",
		_SC_SANDBOX.validar_assets([{"nombre": "mdl_item_espada_01", "ruta": "assets/mdl_item_espada_01.glb", "mb": 2.4}], "user://mods/m1").is_empty())
	_fin("G")

# --- H ---------------------------------------------------------------------
func _test_paquete() -> void:
	print("--- H. Paquete corrupto / readme (§4) ---")
	var vacio: Array = _SC_VALIDATOR.validar_paquete({})
	_check("paquete vacío -> E06", str(vacio).contains("E06"))
	var sin_readme := {"id": "m", "version": "1.0", "min_build": "1.0", "author": "x",
		"readme": false, "assets": []}
	_check("readme ausente -> E07", str(_SC_VALIDATOR.validar_paquete(sin_readme)).contains("E07"))
	var schema_malo := {"id": "m", "version": "1.0", "min_build": "1.0", "author": "x",
		"readme": true, "schema_version": "2.0", "assets": []}
	_check("schema_version erróneo -> E13", str(_SC_VALIDATOR.validar_paquete(schema_malo)).contains("E13"))
	var ok := {"id": "m", "version": "1.0", "min_build": "1.0", "author": "x",
		"readme": true, "schema_version": "1.0",
		"assets": [{"nombre": "mdl_item_espada_01", "ruta": "assets/mdl_item_espada_01.glb", "mb": 2.4}]}
	_check("paquete válido -> 0 errores", _SC_VALIDATOR.validar_paquete(ok).is_empty(),
		"errores=%s" % str(_SC_VALIDATOR.validar_paquete(ok)))
	# paquete real del manifiesto
	var mm := _mm()
	if mm != null and mm.config.get("mods", []).size() > 0:
		var real: Dictionary = mm.config.get("mods", [])[0]
		_check("paquete real del manifiesto válido",
			_SC_VALIDATOR.validar_paquete(real, "user://mods").is_empty(),
			"errores=%s" % str(_SC_VALIDATOR.validar_paquete(real, "user://mods")))
	_fin("H")

# --- I ---------------------------------------------------------------------
func _test_prioridad() -> void:
	print("--- I. Prioridad: menor se omite + warning (§6) ---")
	var mm := _mm()
	var cfg := {"mods": [
		{"id": "base", "version": "1.0", "min_build": "1.0", "override": []},
		{"id": "alta", "version": "1.0", "min_build": "1.0", "override": ["base"], "prioridad": 9},
		{"id": "baja", "version": "1.0", "min_build": "1.0", "override": ["base"], "prioridad": 1},
	]}
	var r: Dictionary = mm.resolver_prioridad(cfg)
	var activos: Array = r.get("activos", [])
	var omitidos: Array = r.get("omitidos", [])
	_check("el de mayor prioridad queda activo", "alta" in activos, "activos=%s" % str(activos))
	_check("el de menor prioridad se omite", omitidos.size() == 1, "omitidos=%s" % str(omitidos))
	if omitidos.size() == 1:
		_check("motivo cita la prioridad", String(omitidos[0].get("motivo", "")).contains("prioridad"))
	# la config real no produce omisiones (1 solo mod override)
	var rr: Dictionary = mm.resolver_prioridad()
	_check("config real: sin omisiones", (rr.get("omitidos", []) as Array).is_empty())
	_fin("I")

# --- J ---------------------------------------------------------------------
func _test_update_m118() -> void:
	print("--- J. Compatibilidad con updates M118 (§7) ---")
	var mm := _mm()
	_check("update a 1.0.0 compatible", mm.es_compatible_update("mod_aurora_items", "1.0.0") == true)
	_check("downgrade a 0.9.0 incompatible", mm.es_compatible_update("mod_aurora_items", "0.9.0") == false)
	_check("update a 1.2.0 compatible", mm.es_compatible_update("mod_aurora_items", "1.2.0") == true)
	_check("mod inexistente incompatible", mm.es_compatible_update("no_existe", "1.0.0") == false)
	_fin("J")

# --- K ---------------------------------------------------------------------
func _test_codigos() -> void:
	print("--- K. Códigos de error por caso (§6) ---")
	var codigos: Dictionary = _SC_VALIDATOR.CODIGOS
	_check("hay >= 12 códigos", codigos.size() >= 12, "size=%d" % codigos.size())
	var faltan: Array = []
	for i in range(1, 15):
		var c := "E%02d" % i
		if not codigos.has(c):
			faltan.append(c)
	_check("E01..E14 definidos", faltan.is_empty(), "faltan=%s" % str(faltan))
	var malo := {"mods": [{"id": "", "version": "", "min_build": "", "override": []}]}
	var errs: Array = _SC_VALIDATOR.validar(malo)
	var con_codigo := true
	for e in errs:
		if typeof(e) != TYPE_DICTIONARY or not String(e.get("codigo", "")).begins_with("E"):
			con_codigo = false
	_check("los errores traen código", con_codigo, "errs=%s" % str(errs))
	_check("reporte lista los mensajes", _SC_VALIDATOR.reporte(errs).contains("ERRORES"))
	_fin("K")

func _summary() -> void:
	print("=== Resumen M123: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M123 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M123 OK — todos los checks pasaron")
		quit(0)
