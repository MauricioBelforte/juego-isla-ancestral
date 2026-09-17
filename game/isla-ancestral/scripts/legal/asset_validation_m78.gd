# Modelo: mimo-v2.5
# Plataforma: OpenCode
# Fecha: 2026-09-15
#
# M78: Legal Propiedad Intelectual — AssetValidation
# Script opcional que valida que todos los assets importados tengan fila
# en el registro de legal_data.json. Detecta assets sin licencia documentada.

class_name AssetValidationM78
extends RefCounted

const RUTA_LEGAL_DATA := "res://data/legal/legal_data.json"

## Escanea directorios de assets y verifica que todos estén registrados.
## Retorna Array[String] de errores.
static func validar_assets_contra_registro(directorios: Array[String] = []) -> Array:
	var errores: Array = []
	if directorios.is_empty():
		directorios = [
			"res://assets/",
			"res://models/",
			"res://textures/",
			"res://fonts/",
			"res://audio/",
		]

	var data := _cargar_legal_data()
	if data.is_empty():
		errores.append("No se pudo cargar legal_data.json")
		return errores

	var assets_registrados := _obtener_nombres_registrados(data)
	var archivos_encontrados: Array[String] = []

	for dir_path in directorios:
		archivos_encontrados.append_array(_escanear_directorio(dir_path))

	for archivo in archivos_encontrados:
		var nombre := archivo.get_file()
		if not _esta_registrado(nombre, assets_registrados):
			errores.append("Asset sin registro: %s" % archivo)

	return errores


## Verifica que no existan assets CC-BY-NC o CC-BY-ND en el registro.
static func verificar_nc_nd(data: Dictionary = {}) -> Array:
	var errores: Array = []
	if data.is_empty():
		data = _cargar_legal_data()
	if data.is_empty():
		errores.append("No se pudo cargar legal_data.json")
		return errores

	var licencias_rechazadas := ["CC-BY-NC", "CC-BY-ND", "CC-BY-NC-SA", "CC-BY-NC-ND"]

	for asset in data.get("assets_terceros", []):
		var licencia: String = String(asset.get("licencia", ""))
		var nombre: String = String(asset.get("nombre", ""))
		if licencia in licencias_rechazadas:
			errores.append("Asset con licencia rechazada: %s (%s)" % [nombre, licencia])

	return errores


## Genera reporte completo de validación.
static func generar_reporte() -> String:
	var lineas: Array = ["[M78] Reporte de Validación de Assets", "=" .repeat(40)]

	var data := _cargar_legal_data()
	if data.is_empty():
		lineas.append("ERROR: No se pudo cargar legal_data.json")
		return "\n".join(lineas)

	# Contar assets
	var assets := data.get("assets_terceros", [])
	lineas.append("Total assets registrados: %d" % assets.size())

	# Verificar NC/ND
	var nc_nd_errores := verificar_nc_nd(data)
	if nc_nd_errores.is_empty():
		lineas.append("Licencias NC/ND: OK (ninguna encontrada)")
	else:
		lineas.append("Licencias NC/ND: %d ERRORES" % nc_nd_errores.size())
		for e in nc_nd_errores:
			lineas.append("  - %s" % e)

	# Verificar atribuciones
	var sin_atribucion: Array = []
	for asset in assets:
		if bool(asset.get("atribucion_requerida", false)):
			if String(asset.get("atribucion_texto", "")).is_empty():
				sin_atribucion.append(String(asset.get("nombre", "")))
	if sin_atribucion.is_empty():
		lineas.append("Atribuciones obligatorias: OK")
	else:
		lineas.append("Atribuciones faltantes: %d" % sin_atribucion.size())
		for nombre in sin_atribucion:
			lineas.append("  - %s" % nombre)

	# Verificar estados
	var activos := 0
	for asset in assets:
		if String(asset.get("estado", "")) == "activo":
			activos += 1
	lineas.append("Assets activos: %d/%d" % [activos, assets.size()])

	return "\n".join(lineas)


# --- Helpers privados ---


static func _cargar_legal_data() -> Dictionary:
	var file := FileAccess.open(RUTA_LEGAL_DATA, FileAccess.READ)
	if not file:
		return {}
	var texto := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(texto)
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}


static func _obtener_nombres_registrados(data: Dictionary) -> Array:
	var nombres: Array = []
	for asset in data.get("assets_terceros", []):
		nombres.append(String(asset.get("nombre", "")).to_lower())
	for prop in data.get("propias", []):
		nombres.append(String(prop.get("nombre", "")).to_lower())
	return nombres


static func _esta_registrado(nombre: String, registrados: Array) -> bool:
	var nombre_lower := nombre.to_lower()
	for reg in registrados:
		if nombre_lower.contains(reg) or reg.contains(nombre_lower):
			return true
	return false


static func _escanear_directorio(dir_path: String) -> Array:
	var archivos: Array = []
	var dir := DirAccess.open(dir_path)
	if not dir:
		return archivos
	dir.list_dir_begin()
	var nombre := dir.get_next()
	while nombre != "":
		if not nombre.begins_with("."):
			var ruta_completa := dir_path.path_join(nombre)
			if dir.current_is_dir():
				archivos.append_array(_escanear_directorio(ruta_completa))
			else:
				archivos.append(ruta_completa)
		nombre = dir.get_next()
	return archivos
