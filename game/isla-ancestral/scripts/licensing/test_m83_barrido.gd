# Modelo: Ling-3.1-Flash
# Plataforma: Kilo Code
# Fecha: 2026-10-12
#
# M83: Licencias de Software — Test del barrido iter5 (Log 1724)
# Valida las extensiones del encargo msg 78 (director):
#   - B.9  verificar_uso_comercial()
#   - B.14 detectar_dual()
#   - G.9  verificar_integridad()
#   - C.4/C.5/C.6/G.6 save_notices ampliado + include_in_build
#   - H.4/H.5/B.4/B.7/B.8/B.12/B.13 validación con policies + compatibilidad
# Uso: godot --headless --path game/isla-ancestral -s res://scripts/licensing/test_m83_barrido.gd
# Exit 0 si todo OK, 1 si falla.

extends SceneTree

const _SC := preload("res://scripts/licensing/license_scanner.gd")
const _POL := preload("res://scripts/licensing/license_policy.gd")

var _checks: int = 0
var _fallos: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== [M83] Test barrido iter5 ===")
	_test_uso_comercial()
	_test_dual()
	_test_integridad()
	_test_notices()
	_test_policy()
	_test_compatibilidad()
	_summary()


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s %s" % [nombre, detalle])


func _contiene(arr: Array, nombre: String) -> bool:
	for s in arr:
		if String(s).contains(nombre):
			return true
	return false


func _test_uso_comercial() -> void:
	print("--- B.9 Uso comercial ---")
	var inv: Array = [
		{"name": "nc-asset", "version": "1.0", "license": "CC_BY_NC"},
		{"name": "ok-mit", "version": "1.0", "license": "MIT"},
		{"name": "perfil-no-com", "version": "1.0", "license": "PROPRIETARY", "commercial_use": false},
	]
	var alertas: Array = _SC.verificar_uso_comercial(inv)
	_check("CC_BY_NC detectada", _contiene(alertas, "nc-asset"), str(alertas))
	_check("commercial_use=false detectado", _contiene(alertas, "perfil-no-com"), str(alertas))
	_check("MIT no alerta", not _contiene(alertas, "ok-mit"), str(alertas))
	_check("inventario limpio sin alertas", _SC.verificar_uso_comercial([{"name": "x", "license": "MIT"}]).is_empty())


func _test_dual() -> void:
	print("--- B.14 Licencias duales ---")
	var dual: Array = _SC.detectar_dual("MIT License\nPermission is hereby granted...\nApache License\nVersion 2.0")
	_check("dual MIT+Apache detectado", dual.size() == 2 and dual.has("MIT") and dual.has("APACHE_2"), str(dual))
	var gpl3: Array = _SC.detectar_dual("GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007")
	_check("GPL-3 simple (no dual)", gpl3.size() == 1 and gpl3.has("GPL_3"), str(gpl3))
	var gpl2: Array = _SC.detectar_dual("GNU GENERAL PUBLIC LICENSE Version 2, June 1991")
	_check("GPL-2 simple", gpl2.size() == 1 and gpl2.has("GPL_2"), str(gpl2))
	_check("CC BY simple (no confunde con NC)", _SC.detectar_dual("Creative Commons Attribution 4.0 (CC BY 4.0)").size() == 1)
	_check("CC BY-NC simple", _SC.detectar_dual("Creative Commons BY-NC 4.0, non-commercial only").size() == 1)
	_check("vacio -> ninguno", _SC.detectar_dual("").is_empty())


func _test_integridad() -> void:
	print("--- G.9 Integridad ---")
	var inv: Array = [
		{"name": "con-lic", "version": "1.0", "license": "MIT", "license_file": "res://addons/gdUnit4/LICENSE"},
		{"name": "sin-arch", "version": "1.0", "license": "UNKNOWN", "license_file": ""},
		{"name": "rota", "version": "1.0", "license": "MIT", "license_file": "res://addons/no-existe/LICENSE"},
	]
	var problemas: Array = _SC.verificar_integridad(inv)
	_check("sin archivo -> WARN", _contiene(problemas, "sin-arch"), str(problemas))
	_check("ruta rota -> ERROR", _contiene(problemas, "rota"), str(problemas))
	_check("archivo real OK", not _contiene(problemas, "con-lic"), str(problemas))


func _test_notices() -> void:
	print("--- C.2/C.4/C.5/C.6/C.8/C.9/G.6 Notices ampliados ---")
	var inv: Array = [
		{"name": "dep-a", "version": "1.2.3", "license": "MIT", "license_url": "https://example.com/LICENSE", "license_file": "res://addons/gdUnit4/LICENSE"},
	]
	var tmp: String = "user://m83_barrido_test/"
	var ruta: String = _SC.save_notices(inv, tmp, "1.0.0-test", "txt")
	_check("save_notices txt creado", FileAccess.file_exists(ruta), ruta)
	var contenido: String = FileAccess.get_file_as_string(ruta)
	_check("C.6 header tiene build version", contenido.contains("1.0.0-test"), contenido.substr(0, 200))
	_check("C.2 separadores visuales", contenido.contains("===="))
	_check("C.8 URL incluida", contenido.contains("https://example.com/LICENSE"))
	_check("C.9 numeracion secuencial", contenido.contains("1. dep-a"))
	var copia: String = tmp.path_join("dep-a_LICENSE.txt")
	_check("C.4 copia individual existe", FileAccess.file_exists(copia), copia)
	var texto_copia: String = FileAccess.get_file_as_string(copia)
	_check("C.4 copia tiene texto original (no solo tipo)", texto_copia.length() > 10 and texto_copia.strip_edges() != "MIT", texto_copia.substr(0, 60))
	var ruta_md: String = _SC.save_notices(inv, tmp, "", "md")
	_check("G.6 formato md", FileAccess.file_exists(ruta_md) and FileAccess.get_file_as_string(ruta_md).contains("# THIRD_PARTY LICENSES"))
	var ruta_json: String = _SC.save_notices(inv, tmp, "", "json")
	var json_ok: bool = false
	if FileAccess.file_exists(ruta_json):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta_json))
		json_ok = typeof(parsed) == TYPE_DICTIONARY
	_check("G.6 formato json parseable", json_ok)
	var build_dir: String = "user://m83_barrido_build/"
	var ruta_build: String = _SC.include_in_build(inv, build_dir)
	_check("C.5 include_in_build genera archivo", FileAccess.file_exists(ruta_build) and FileAccess.get_file_as_string(ruta_build).contains("THIRD_PARTY LICENSES"))
	_check("dry_run sigue funcionando (regresion)", _SC.dry_run(inv).contains("dep-a"))


func _test_policy() -> void:
	print("--- H.4/H.5/B.4/B.7/B.8/B.12 Validacion con policy ---")
	var permisiva: LicensePolicy = _POL.new()
	permisiva.policy_name = "permisiva"
	var restrictiva: LicensePolicy = _POL.new()
	restrictiva.policy_name = "restrictiva"
	restrictiva.prohibited_licenses = ["GPL_3", "AGPL", "GPL_2", "LGPL"]
	var selectiva: LicensePolicy = _POL.new()
	selectiva.policy_name = "selectiva"
	selectiva.allowed_licenses = ["MIT", "BSD_3", "APACHE_2"]
	var inv: Array = [
		{"name": "mit-dep", "license": "MIT"},
		{"name": "gpl-dep", "license": "GPL_3", "attribution_required": true, "source_offer_required": true},
	]
	var res_perm: Array = _SC.verificar_contra_politica(inv, permisiva)
	_check("H.4 policy permisiva: sin ERROR (INFO/WARN de obligaciones OK)", not _contiene(res_perm, "ERROR"), str(res_perm))
	var res_rest: Array = _SC.verificar_contra_politica(inv, restrictiva)
	_check("H.5 policy restrictiva: GPL denegado", _contiene(res_rest, "gpl-dep"), str(res_rest))
	_check("policy restrictiva: MIT permitido", not _contiene(res_rest, "mit-dep"), str(res_rest))
	var res_sel: Array = _SC.verificar_contra_politica(inv, selectiva)
	_check("B.4 lista permitidas: GPL fuera de lista", _contiene(res_sel, "gpl-dep"), str(res_sel))
	_check("B.4 lista permitidas: MIT en lista", not _contiene(res_sel, "mit-dep"), str(res_sel))
	_check("B.7 attribution_required -> INFO", _contiene(res_perm, "atribución"), str(res_perm))
	_check("B.8 source_offer_required -> WARN", _contiene(res_perm, "source offer"), str(res_perm))
	_check("B.12 requires_source_offer(inventario)", _SC.requires_source_offer(inv))
	_check("requires_source_offer(inventario limpio)", not _SC.requires_source_offer([{"name": "x", "license": "MIT"}]))


func _test_compatibilidad() -> void:
	print("--- H.8/B.11/B.13 Compatibilidad ---")
	_check("B.13 MIT puede incluirse en GPL_3", _SC.check_compatibility("MIT", "GPL_3"))
	_check("B.13 GPL_3 no relicencia MIT (direccional)", not _SC.check_compatibility("GPL_3", "MIT"))
	_check("B.11 MIT + MIT compatible", _SC.check_compatibility("MIT", "MIT"))
	_check("MIT + AGPL NO compatible", not _SC.check_compatibility("MIT", "AGPL"))


func _summary() -> void:
	print("=== Resumen M83 barrido: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M83 BARRIDO FALLIDO — salida con codigo 1")
		quit(1)
	else:
		print("TEST M83 BARRIDO OK — todos los checks pasaron")
		quit(0)
