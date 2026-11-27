# Modelo: GLM-5.3-Flash
# Plataforma: Kilo Code
# Fecha: 2026-11-25
#
# M85: Modelos 3D Legal — ModelLegalManager (Node)
# Espejo directo de scripts/legal/audio_legal_manager.gd (M84, mimo-v2.5),
# para assets 3D: carga data/legal/modelos_3d.json, licencias y créditos,
# validación completa, generación de créditos (texto compacto + web detallado)
# y archivo MODEL_CREDITS.txt para builds.
#
# NO es autoload (igual que AudioLegalManager): se instancia donde se necesita
# (build pipeline, herramienta de legal, tests) — evita el orden de arranque.
# Sin lógica de gameplay: pura capa legal/documental (§9 de AGENTS.md).
#
# Checklist M85 que cierra (tanda GLM-5.3-Flash 2026-11-25):
#   L66 validate_all_models() · L67 add_license()/add_credit() ·
#   L68 generate_credits_text() · L69 generate_credits_web() ·
#   L70 save_build_credits() · L112 dry-run · L113 skip en builds dev.
#   Tests L92-L101: scripts/legal/test_model_legal_m85.gd.

extends Node

const RUTA_DATA := "res://data/legal/modelos_3d.json"
const ValidatorRef := preload("res://scripts/legal/model3d_validator.gd")

## Señales para integración (mismo patrón que AudioLegalManager M84)
signal licencia_agregada(licencia: ModelLicense)
signal credito_agregado(credito: ModelCredit)
signal validacion_completada(errores: Array)

## Estado: asset_id -> Array[ModelLicense] (un asset puede tener VARIAS
## licencias: mesh del artista + texturas propias, edge case del checklist)
var _licencias: Dictionary = {}
var _creditos: Array[ModelCredit] = []
var _datos_raw: Dictionary = {}

## M85 L112: modo dry-run — valida pero NO genera outputs
var _dry_run: bool = false
## M85 L113: skip de validación en builds de desarrollo (OS.is_debug_build)
var _skip_validation: bool = false


func cargar_datos(ruta: String = RUTA_DATA) -> void:
	var file := FileAccess.open(ruta, FileAccess.READ)
	if file == null:
		push_warning("[M85] No se pudo cargar %s" % ruta)
		return
	var texto := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(texto)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("[M85] JSON inválido en %s" % ruta)
		return
	_datos_raw = parsed
	_parsear_assets()


func _parsear_assets() -> void:
	_licencias.clear()
	for a in _datos_raw.get("assets", []):
		var d: Dictionary = a as Dictionary
		var lic := ModelLicense.new()
		lic.asset_id = String(d.get("id", ""))
		lic.nombre = String(d.get("nombre", ""))
		var origen_str := String(d.get("origen", "propio"))
		lic.origen = ModelLicense.Origen.PROPIO if origen_str == "propio" else ModelLicense.Origen.get(origen_str.to_upper(), ModelLicense.Origen.PROPIO)
		var lic_str := String(d.get("licencia", "propia")).to_upper()
		lic.license_type = _mapear_licencia(lic_str)
		lic.uso_comercial = lic_str != "CC-BY-NC"
		lic.attribution_requerida = lic_str == "CC-BY"
		lic.attribution_texto = String(d.get("attribution", ""))
		add_license(lic)


## Mapeo de licencias del JSON a la enum (mismos valores que M84)
func _mapear_licencia(licencia_str: String) -> ModelLicense.LicenseType:
	match licencia_str:
		"PROPIA", "PROPIO": return ModelLicense.LicenseType.PROPIA
		"MIT": return ModelLicense.LicenseType.MIT
		"CC0": return ModelLicense.LicenseType.CC0
		"CC-BY": return ModelLicense.LicenseType.CC_BY
		"CC-BY-SA": return ModelLicense.LicenseType.CC_BY_SA
		"CC-BY-NC": return ModelLicense.LicenseType.CC_BY_NC
		_: return ModelLicense.LicenseType.OTRO


## --- API pública (checklist L66/L67) ---

## Agrega (o agrega-otra) una licencia. Un asset con varias licencias queda
## registrado en la MISMA entrada del diccionario (Array por asset_id).
func add_license(licencia: ModelLicense) -> void:
	if licencia == null or licencia.asset_id.is_empty():
		return
	if not _licencias.has(licencia.asset_id):
		_licencias[licencia.asset_id] = []
	(_licencias[licencia.asset_id] as Array).append(licencia)
	licencia_agregada.emit(licencia)


func add_credit(credito: ModelCredit) -> void:
	if credito == null or credito.persona_nombre.is_empty():
		return
	_creditos.append(credito)
	credito_agregado.emit(credito)


func get_licencias_de(asset_id: String) -> Array[ModelLicense]:
	var out: Array[ModelLicense] = []
	for lic in _licencias.get(asset_id, []):
		out.append(lic as ModelLicense)
	return out


func get_creditos() -> Array[ModelCredit]:
	return _creditos.duplicate()


func buscar_credito(persona: String) -> ModelCredit:
	for cred in _creditos:
		if cred.persona_nombre == persona:
			return cred
	return null


## Validación COMPLETA del inventario legal de modelos (checklist L66).
## Devuelve Array[String] de errores (vacío = OK).
func validate_all_models() -> Array:
	var errores: Array = []

	if _licencias.is_empty():
		errores.append("No hay licencias de modelos 3D registradas")

	for asset_id in _licencias:
		var lista: Array = _licencias[asset_id]
		if lista.is_empty():
			errores.append("%s: sin licencia" % asset_id)
			continue
		for lic in lista:
			var ml := lic as ModelLicense
			if ml.license_type == ModelLicense.LicenseType.CC_BY_NC:
				errores.append("%s: licencia CC-BY-NC no permitida (uso comercial)" % asset_id)
			if not ml.uso_comercial:
				errores.append("%s: licencia sin uso comercial" % asset_id)
			if ml.attribution_requerida and ml.attribution_texto.is_empty():
				errores.append("%s: CC-BY sin texto de atribución" % asset_id)
			if ml.duracion.to_lower() != "perpetua" or not ml.perpetua:
				errores.append("%s: licencia NO perpetua (%s) — revisar renovación" % [asset_id, ml.duracion])
			if ml.documento_licencia_ruta.is_empty() and ml.license_type != ModelLicense.LicenseType.PROPIA:
				errores.append("%s: licencia de terceros sin documento de respaldo" % asset_id)

	for cred in _creditos:
		if cred.persona_nombre.is_empty():
			errores.append("Crédito con nombre vacío")
		if cred.roles.is_empty():
			errores.append("Crédito sin rol: %s" % cred.persona_nombre)
		elif not cred.roles_validos():
			errores.append("Crédito con rol desconocido: %s" % cred.persona_nombre)
		if cred.asset_ids.is_empty():
			errores.append("Crédito sin asset asociado: %s" % cred.persona_nombre)

	validacion_completada.emit(errores)
	return errores


## Validación contra el JSON crudo (segunda fuente, igual que M84)
func validate_with_json_data() -> Array:
	return ValidatorRef.validar(_datos_raw)


## --- Créditos (checklist L68/L69) ---

## Formato COMPACTO para el archivo de créditos del juego (una línea por asset)
func generate_credits_text() -> String:
	var lineas: Array[String] = ["MODELOS 3D — CRÉDITOS"]
	for asset_id in _licencias:
		var lista: Array = _licencias[asset_id]
		for lic in lista:
			var ml := lic as ModelLicense
			if ml.license_type == ModelLicense.LicenseType.PROPIA:
				lineas.append("%s — Estudio interno (licencia propia)" % ml.nombre)
			else:
				lineas.append("%s — %s (%s)" % [ml.nombre, ml.artista, ModelLicense.LicenseType.keys()[ml.license_type]])
	return "\n".join(lineas) + "\n"


## Formato DETALLADO para la página web/créditos completos (una sección por asset)
func generate_credits_web() -> String:
	var secciones: Array[String] = ["<h1>Modelos 3D — Créditos completos</h1>"]
	for asset_id in _licencias:
		var lista: Array = _licencias[asset_id]
		for lic in lista:
			var ml := lic as ModelLicense
			secciones.append("<h2>%s</h2>" % ml.nombre)
			secciones.append("<ul>")
			secciones.append("<li>Artista: %s</li>" % (ml.artista if not ml.artista.is_empty() else "Estudio interno"))
			secciones.append("<li>Licencia: %s (%s, %s)</li>" % [ModelLicense.LicenseType.keys()[ml.license_type], ml.duracion, ml.territorio])
			if ml.tiene_atribucion_requerida():
				secciones.append("<li>Atribución: %s</li>" % ml.attribution_texto)
			secciones.append("<li>Documento: %s</li>" % (ml.documento_licencia_ruta if not ml.documento_licencia_ruta.is_empty() else "interno"))
			secciones.append("</ul>")
	# Créditos de personas (con roles múltiples en una línea)
	if not _creditos.is_empty():
		secciones.append("<h2>Equipo</h2>")
		secciones.append("<ul>")
		for cred in _creditos:
			secciones.append("<li>%s — %s</li>" % [cred.persona_nombre, ", ".join(cred.roles)])
		secciones.append("</ul>")
	return "\n".join(secciones) + "\n"


## --- Build (checklist L70/L75/L107/L112/L113) ---

func set_dry_run(active: bool) -> void:
	_dry_run = active


func is_dry_run() -> bool:
	return _dry_run


func set_skip_validation(skip: bool) -> void:
	_skip_validation = skip


func should_validate() -> bool:
	return not _skip_validation


## Guarda MODEL_CREDITS.txt + reporte de licencias en la carpeta de build.
## Respeta dry-run (valida pero no escribe) y skip (dev builds: reporte igual,
## sin exigir validez). Devuelve el resumen de la validación.
func save_build_credits(ruta_credits: String = "res://build/MODEL_CREDITS.txt") -> Dictionary:
	var errores := validate_all_models() if should_validate() else []
	var resultado := {
		"errores": errores,
		"total_assets": _licencias.size(),
		"total_creditos": _creditos.size(),
		"dry_run": _dry_run,
		"skip_validation": _skip_validation,
		"timestamp": Time.get_datetime_string_from_system(),
	}
	resultado["archivos_generados"] = false
	if _dry_run:
		resultado["motivo"] = "dry_run: no se generan outputs"
		return resultado
	# build/ puede no existir en un checkout limpio: crearla (los builds
	# previos de M84 asumían lo mismo con AUDIO_CREDITS.txt)
	DirAccess.make_dir_recursive_absolute(ruta_credits.get_base_dir())
	var file := FileAccess.open(ruta_credits, FileAccess.WRITE)
	if file == null:
		errores.append("No se pudo escribir %s" % ruta_credits)
		resultado["errores"] = errores
		return resultado
	file.store_string(generate_credits_text())
	file.close()
	# Reporte detallado de licencias junto al créditos
	var ruta_reporte := ruta_credits.get_basename() + "_REPORT.txt"
	var file_rep := FileAccess.open(ruta_reporte, FileAccess.WRITE)
	if file_rep != null:
		var rep: Array[String] = ["REPORTE DE LICENCIAS DE MODELOS 3D", ""]
		for asset_id in _licencias:
			for lic in _licencias[asset_id]:
				var ml := lic as ModelLicense
				rep.append("%s | %s | %s | %s" % [ml.asset_id, ml.nombre, ModelLicense.LicenseType.keys()[ml.license_type], ml.artista])
		file_rep.store_string("\n".join(rep) + "\n")
		file_rep.close()
	resultado["archivos_generados"] = true
	return resultado


## Resumen para el build log / dashboards
func get_resumen() -> Dictionary:
	var propios := 0
	var terceros := 0
	for asset_id in _licencias:
		for lic in _licencias[asset_id]:
			var ml := lic as ModelLicense
			if ml.license_type == ModelLicense.LicenseType.PROPIA:
				propios += 1
			else:
				terceros += 1
	return {
		"total_assets": _licencias.size(),
		"licencias_propias": propios,
		"licencias_terceros": terceros,
		"total_creditos": _creditos.size(),
		"dry_run": _dry_run,
		"skip_validation": _skip_validation,
	}
