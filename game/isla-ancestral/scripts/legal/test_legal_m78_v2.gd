# Modelo: mimo-v2.5
# Plataforma: OpenCode
# Fecha: 2026-09-15
#
# M78: Legal Propiedad Intelectual — Test headless v2
# Valida: legal_data.json completo (IPs, assets, atribuciones, licencias,
# políticas, marcas), NC/ND check, y asset_validation_m78.
# Exit code != 0 si falla.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/legal/legal_validator.gd")
const _SC_ASSET_VAL := preload("res://scripts/legal/asset_validation_m78.gd")
const RUTA_DATA := "res://data/legal/legal_data.json"

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M78] Test de Legal Propiedad Intelectual v2 ===")
	_test_data_structure()
	_test_ips()
	_test_assets_terceros()
	_test_atribuciones()
	_test_licencias()
	_test_politicas()
	_test_marcas()
	_test_nc_nd()
	_test_asset_validation()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _cargar() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_DATA))
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}

func _test_data_structure() -> void:
	print("--- Estructura de datos ---")
	var data := _cargar()
	_check("legal_data.json cargado", not data.is_empty())
	_check("Tiene version", data.has("version"))
	_check("Tiene game_title", data.has("game_title"))
	_check("Tiene ips", data.has("ips"))
	_check("Tiene assets_terceros", data.has("assets_terceros"))

func _test_ips() -> void:
	print("--- IPs registradas ---")
	var data := _cargar()
	var ips: Array = data.get("ips", [])
	_check("Al menos 1 IP registrada", ips.size() >= 1, "size=%d" % ips.size())
	for ip in ips:
		var id: String = String(ip.get("id", ""))
		_check("IP %s tiene nombre" % id, not String(ip.get("nombre", "")).is_empty())
		_check("IP %s tiene tipo" % id, not String(ip.get("tipo", "")).is_empty())
		_check("IP %s tiene titular" % id, not String(ip.get("titular", "")).is_empty())
		_check("IP %s tiene estado" % id, not String(ip.get("estado", "")).is_empty())

func _test_assets_terceros() -> void:
	print("--- Assets de terceros ---")
	var data := _cargar()
	var assets: Array = data.get("assets_terceros", [])
	_check("Al menos 1 asset de tercero", assets.size() >= 1, "size=%d" % assets.size())
	for asset in assets:
		var id: String = String(asset.get("id", ""))
		_check("Asset %s tiene nombre" % id, not String(asset.get("nombre", "")).is_empty())
		_check("Asset %s tiene licencia" % id, not String(asset.get("licencia", "")).is_empty())
		_check("Asset %s tiene autor" % id, not String(asset.get("autor", "")).is_empty())

func _test_atribuciones() -> void:
	print("--- Atribuciones ---")
	var data := _cargar()
	var assets: Array = data.get("assets_terceros", [])
	var con_atribucion := 0
	var sin_texto := 0
	for asset in assets:
		if bool(asset.get("atribucion_requerida", false)):
			con_atribucion += 1
			if String(asset.get("atribucion_texto", "")).is_empty():
				sin_texto += 1
	_check("Assets con atribución requerida: ≥1", con_atribucion >= 1, "count=%d" % con_atribucion)
	_check("Todos con atribución tienen texto", sin_texto == 0, "faltan=%d" % sin_texto)

func _test_licencias() -> void:
	print("--- Licencias ---")
	var data := _cargar()
	var assets: Array = data.get("assets_terceros", [])
	var licencias_validas := ["MIT", "BSD", "Apache-2.0", "ISC", "CC0", "CC-BY-4.0", "CC-BY-3.0", "SIL OFL 1.1", "SIL OFL 1.0", "Zlib"]
	var licencias_rechazadas := ["CC-BY-NC", "CC-BY-ND", "CC-BY-NC-SA", "CC-BY-NC-ND"]
	var rechazadas_encontradas := 0
	for asset in assets:
		var lic: String = String(asset.get("licencia", ""))
		if lic in licencias_rechazadas:
			rechazadas_encontradas += 1
	_check("Ningún asset con licencia rechazada", rechazadas_encontradas == 0, "rechazadas=%d" % rechazadas_encontradas)

func _test_politicas() -> void:
	print("--- Políticas ---")
	var data := _cargar()
	_check("Tiene copyright_year", data.has("copyright_year"))
	_check("copyright_year es 2026", data.get("copyright_year", 0) == 2026)
	_check("Tiene jurisdicciones", data.has("jurisdicciones"))

func _test_marcas() -> void:
	print("--- Marcas ---")
	var data := _cargar()
	var ips: Array = data.get("ips", [])
	var marcas := 0
	for ip in ips:
		if String(ip.get("tipo", "")) == "marca":
			marcas += 1
	_check("Al menos 1 marca registrada", marcas >= 1, "marcas=%d" % marcas)

func _test_nc_nd() -> void:
	print("--- NC/ND Check ---")
	var nc_nd_errores := _SC_ASSET_VAL.verificar_nc_nd(_cargar())
	_check("Sin assets NC/ND", nc_nd_errores.is_empty(), "errores=%d" % nc_nd_errores.size())

func _test_asset_validation() -> void:
	print("--- Asset Validation ---")
	var reporte := _SC_ASSET_VAL.generar_reporte()
	_check("Reporte generado", not reporte.is_empty())
	_check("Reporte contiene título", reporte.contains("Reporte de Validación"))

func _summary() -> void:
	print("\n=== RESUMEN M78 ===")
	print("Checks: %d | Fallos: %d" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLO — %d checks no pasaron" % _fallos)
		quit(1)
	else:
		print("TODOS LOS CHECKS PASARON")
		quit(0)
