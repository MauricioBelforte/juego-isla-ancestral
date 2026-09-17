# Modelo: mimo-v2.5
# Plataforma: OpenCode
# Fecha: 2026-09-15
#
# M78: Legal Propiedad Intelectual — Test headless (v2 expandido)
# Valida: LegalValidator v2 (datos data-driven, atribuciones, licencias,
# compatibilidad, políticas, marcas). Exit code != 0 si falla.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/legal/legal_validator.gd")
const RUTA_DATA := "res://data/legal/legal_data.json"

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M78] Test Legal Propiedad Intelectual v2 ===")
	_test_data()
	_test_ips()
	_test_assets_terceros()
	_test_atribuciones()
	_test_licencias()
	_test_politicas()
	_test_marcas()
	_test_validator()
	_test_validator_errores()
	_test_estadisticas()
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

func _test_data() -> void:
	print("--- Datos: legal_data.json ---")
	var data = _cargar()
	_check("legal_data.json cargado", not data.is_empty())
	_check("versión presente", data.has("version"))
	_check("título del juego", String(data.get("game_title", "")).length() > 0)
	_check("copyright_holder presente", data.has("copyright_holder"))
	_check("7 IPs registradas", data.get("ips", []).size() == 7, "size=%d" % data.get("ips", []).size())
	_check("5 assets de terceros", data.get("assets_terceros", []).size() == 5, "size=%d" % data.get("assets_terceros", []).size())
	_check("7 assets propios", data.get("assets_propios", []).size() == 7, "size=%d" % data.get("assets_propios", []).size())
	_check("políticas definidas", not data.get("politicas", {}).is_empty())
	_check("marcas registradas", data.get("marcas", {}).size() >= 2)

func _test_ips() -> void:
	print("--- IPs: IDs únicos y campos ---")
	var data = _cargar()
	var ips: Array = data.get("ips", [])
	var ids := {}
	var duplicados := 0
	for ip in ips:
		var id: String = String(ip.get("id", ""))
		if ids.has(id):
			duplicados += 1
		ids[id] = true
	_check("0 IPs duplicadas", duplicados == 0, "duplicadas=%d" % duplicados)

	# Verificar tipos válidos
	var tipos_validos := ["marca", "copyright", "licencia_tercero"]
	var tipos_invalidos := 0
	for ip in ips:
		var tipo: String = String(ip.get("tipo", ""))
		if not tipo.is_empty() and tipo not in tipos_validos:
			tipos_invalidos += 1
	_check("0 IPs con tipo inválido", tipos_invalidos == 0, "inválidos=%d" % tipos_invalidos)

func _test_assets_terceros() -> void:
	print("--- Assets de terceros: campos obligatorios ---")
	var data = _cargar()
	var assets: Array = data.get("assets_terceros", [])
	var campos_ok := 0
	for asset in assets:
		var id: String = String(asset.get("id", ""))
		var tiene_nombre: bool = not String(asset.get("nombre", "")).is_empty()
		var tiene_autor: bool = not String(asset.get("autor", "")).is_empty()
		var tiene_licencia: bool = not String(asset.get("licencia", "")).is_empty()
		var tiene_fuente: bool = not String(asset.get("fuente", "")).is_empty()
		if tiene_nombre and tiene_autor and tiene_licencia and tiene_fuente:
			campos_ok += 1
		else:
			print("    [WARN] %s: campos incompletos (nombre=%s, autor=%s, lic=%s, fuente=%s)" % [
				id, tiene_nombre, tiene_autor, tiene_licencia, tiene_fuente
			])
	_check("todos los assets tienen campos obligatorios", campos_ok == assets.size(), "completos=%d/%d" % [campos_ok, assets.size()])

func _test_atribuciones() -> void:
	print("--- Atribuciones: textos completos ---")
	var data = _cargar()
	var assets: Array = data.get("assets_terceros", [])
	var con_atribucion := 0
	var sin_atribucion := 0
	for asset in assets:
		if not asset.get("atribucion_requerida", false):
			continue
		var texto: String = String(asset.get("atribucion_texto", ""))
		if not texto.is_empty():
			con_atribucion += 1
		else:
			sin_atribucion += 1
			print("    [WARN] %s: atribución requerida pero vacía" % asset.get("id", "?"))
	_check("assets con atribución requerida tienen texto", sin_atribucion == 0, "sin_atrib=%d" % sin_atribucion)
	_check("al menos 3 assets con atribución", con_atribucion >= 3, "con_atrib=%d" % con_atribucion)

func _test_licencias() -> void:
	print("--- Licencias: no hay NC/ND rechazadas ---")
	var data = _cargar()
	var assets: Array = data.get("assets_terceros", [])
	var nc_nd_count := 0
	for asset in assets:
		var licencia: String = String(asset.get("licencia", ""))
		if licencia.contains("NC") or licencia.contains("ND"):
			nc_nd_count += 1
			print("    [WARN] %s: licencia NC/ND detectada (%s)" % [asset.get("id", "?"), licencia])
	_check("0 assets con licencia NC/ND", nc_nd_count == 0, "nc_nd=%d" % nc_nd_count)

	# Verificar que no haya assets sin licencia
	var sin_licencia := 0
	for asset in assets:
		if String(asset.get("licencia", "")).is_empty():
			sin_licencia += 1
	_check("0 assets sin licencia", sin_licencia == 0, "sin_lic=%d" % sin_licencia)

func _test_politicas() -> void:
	print("--- Políticas: campos críticos ---")
	var data = _cargar()
	var politicas: Dictionary = data.get("politicas", {})
	_check("checklist_atribucion_obligatorio=true", politicas.get("checklist_atribucion_obligatorio", false) == true)
	_check("prohibido_nc_nd=true", politicas.get("prohibido_nc_nd", false) == true)
	_check("prohibido_plagio=true", politicas.get("prohibido_plagio", false) == true)
	_check("escala de preferencia definida", politicas.get("escala_preferencia_licencias", []).size() > 0)

func _test_marcas() -> void:
	print("--- Marcas: búsquedas y decisiones ---")
	var data = _cargar()
	var marcas: Dictionary = data.get("marcas", {})
	_check("al menos 2 marcas registradas", marcas.size() >= 2, "size=%d" % marcas.size())
	for nombre in marcas.keys():
		var info: Dictionary = marcas[nombre]
		_check("'%s' tiene búsquedas" % nombre, info.get("busquedas", []).size() > 0)
		_check("'%s' tiene decisión" % nombre, not String(info.get("decision", "")).is_empty())

func _test_validator() -> void:
	print("--- LegalValidator v2: data real ---")
	var data = _cargar()
	var errores = _SC_VALIDATOR.validar(data)
	_check("data válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))

func _test_validator_errores() -> void:
	print("--- LegalValidator v2: errores detectados ---")
	var malo = {
		"ips": [
			{"id": "", "nombre": "", "tipo": "", "titular": "", "jurisdiccion": "", "estado": ""}
		],
		"assets_terceros": [
			{"id": "A999", "nombre": "", "autor": "", "fuente": "", "licencia": "CC-BY-NC", "uso_comercial": true, "atribucion_requerida": true, "atribucion_texto": "", "estado": ""}
		],
		"politicas": {},
		"marcas": {}
	}
	var errores = _SC_VALIDATOR.validar(malo)
	_check("IP sin campos detectada", str(errores).contains("campo") or str(errores).contains("sin id"))
	_check("licencia NC detectada", str(errores).contains("RECHAZADA") or str(errores).contains("NC"))
	_check("sin políticas detectado", str(errores).contains("políticas"))
	_check("marca sin búsqueda detectada", str(errores).contains("búsquedas"))

func _test_estadisticas() -> void:
	print("--- Estadísticas ---")
	var data = _cargar()
	var stats = _SC_VALIDATOR.estadisticas(data)
	_check("stats.ips == 7", stats.get("ips", 0) == 7, "ips=%d" % stats.get("ips", 0))
	_check("stats.assets_terceros == 5", stats.get("assets_terceros", 0) == 5, "terceros=%d" % stats.get("assets_terceros", 0))
	_check("stats.assets_propios == 7", stats.get("assets_propios", 0) == 7, "propios=%d" % stats.get("assets_propios", 0))
	_check("stats.politicas_definidas == true", stats.get("politicas_definidas", false) == true)

func _summary() -> void:
	print("=== Resumen M78 v2: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M78 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M78 OK — todos los checks pasaron")
		quit(0)
