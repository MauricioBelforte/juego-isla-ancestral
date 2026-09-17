# Modelo: mimo-v2.5
# Plataforma: OpenCode
# Fecha: 2026-09-15
#
# M78: Legal Propiedad Intelectual — LegalValidator (v2 expandido)
# Valida: IPs, assets de terceros, atribuciones, licencias, compatibilidad,
# políticas y registro de marcas. Devuelve Array[String] de errores.

class_name LegalValidator
extends RefCounted

# --- Licencias aceptadas (permisivas) ---
const LICENCIAS_ACEPTADAS := [
	"MIT", "BSD", "Apache-2.0", "ISC",
	"CC0", "CC-BY-4.0", "CC-BY-3.0",
	"SIL OFL 1.1", "SIL OFL 1.0",
	"Apache-2.0", "Zlib",
	"dominio_publico"
]

# --- Licencias que requieren evaluación ---
const LICENCIAS_EVALUAR := ["CC-BY-SA-4.0", "CC-BY-SA-3.0", "GPL-3.0", "LGPL-3.0"]

# --- Licencias rechazadas ---
const LICENCIAS_RECHAZADAS := ["CC-BY-NC", "CC-BY-ND", "CC-BY-NC-SA", "CC-BY-NC-ND"]

# --- Campos obligatorios por IP ---
const CAMPOS_IP := ["id", "nombre", "tipo", "titular", "jurisdiccion", "estado"]

# --- Campos obligatorios por asset de tercero ---
const CAMPOS_ASSET := ["id", "nombre", "tipo", "autor", "fuente", "licencia", "uso_comercial", "atribucion_requerida", "atribucion_texto", "estado"]


static func validar(data: Dictionary) -> Array:
	var errores: Array = []

	errores.append_array(_validar_ips(data))
	errores.append_array(_validar_assets_terceros(data))
	errores.append_array(_validar_atribuciones(data))
	errores.append_array(_validar_licencias(data))
	errores.append_array(_validar_compatibilidad(data))
	errores.append_array(_validar_politicas(data))
	errores.append_array(_validar_marcas(data))

	return errores


static func _validar_ips(data: Dictionary) -> Array:
	var errores: Array = []
	var ips: Array = data.get("ips", [])
	var ids: Dictionary = {}

	for ip in ips:
		var id: String = String(ip.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"

		if id.is_empty():
			errores.append("IP sin id")
		elif ids.has(id):
			errores.append("IP duplicada: %s" % id)
		ids[id] = true

		for campo in CAMPOS_IP:
			if String(ip.get(campo, "")).is_empty():
				errores.append("%s: campo '%s' vacío" % [etiqueta, campo])

		# Verificar que el tipo sea válido
		var tipo: String = String(ip.get("tipo", ""))
		if not tipo.is_empty() and tipo not in ["marca", "copyright", "licencia_tercero", "trade_secret", "patente"]:
			errores.append("%s: tipo desconocido '%s'" % [etiqueta, tipo])

	return errores


static func _validar_assets_terceros(data: Dictionary) -> Array:
	var errores: Array = []
	var assets: Array = data.get("assets_terceros", [])
	var ids: Dictionary = {}

	for asset in assets:
		var id: String = String(asset.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id_asset)"

		if id.is_empty():
			errores.append("Asset tercero sin id")
		elif ids.has(id):
			errores.append("Asset tercero duplicado: %s" % id)
		ids[id] = true

		for campo in CAMPOS_ASSET:
			var valor = asset.get(campo, null)
			if valor == null or (typeof(valor) == TYPE_STRING and String(valor).is_empty()):
				errores.append("%s: campo '%s' vacío" % [etiqueta, campo])

		# Verificar que la fuente sea URL válida
		var fuente: String = String(asset.get("fuente", ""))
		if not fuente.is_empty() and not fuente.begins_with("http"):
			errores.append("%s: fuente no es URL válida (%s)" % [etiqueta, fuente])

		# Verificar que atribución esté presente si se requiere
		if asset.get("atribucion_requerida", false):
			var atribucion: String = String(asset.get("atribucion_texto", ""))
			if atribucion.is_empty():
				errores.append("%s: atribución requerida pero texto vacío" % etiqueta)

	return errores


static func _validar_atribuciones(data: Dictionary) -> Array:
	var errores: Array = []
	var assets: Array = data.get("assets_terceros", [])

	for asset in assets:
		var id: String = String(asset.get("id", ""))
		if not asset.get("atribucion_requerida", false):
			continue

		var texto: String = String(asset.get("atribucion_texto", ""))
		# La atribución debe contener autor, licencia y al menos un enlace
		if not texto.is_empty():
			if not texto.contains("Copyright") and not texto.contains("©"):
				errores.append("%s: atribución sin mención de copyright/autor" % id)
			if not texto.contains("License") and not texto.contains("License") and not texto.contains("OFL"):
				errores.append("%s: atribución sin mención de licencia" % id)

	return errores


static func _validar_licencias(data: Dictionary) -> Array:
	var errores: Array = []
	var assets: Array = data.get("assets_terceros", [])

	for asset in assets:
		var id: String = String(asset.get("id", ""))
		var licencia: String = String(asset.get("licencia", ""))

		if licencia.is_empty():
			errores.append("%s: sin licencia definida" % id)
			continue

		# Verificar si la licencia está en la lista de rechazadas
		for rechazada in LICENCIAS_RECHAZADAS:
			if licencia.contains(rechazada):
				errores.append("%s: licencia RECHAZADA '%s' — no puede integrarse" % [id, licencia])

		# Verificar si es NC y se marca como uso comercial permitido
		if licencia.contains("NC") and asset.get("uso_comercial", false):
			errores.append("%s: licencia NC pero uso_comercial=true — contradicción" % id)

	return errores


static func _validar_compatibilidad(data: Dictionary) -> Array:
	var errores: Array = []
	var assets: Array = data.get("assets_terceros", [])
	var tiene_share_alike := false
	var tiene_propietario := false

	for asset in assets:
		var licencia: String = String(asset.get("licencia", ""))
		if licencia.contains("SA"):
			tiene_share_alike = true
		if licencia in ["Propietaria", "Proprietary", "todos los derechos reservados"]:
			tiene_propietario = true

	if tiene_share_alike and tiene_propietario:
		errores.append("CONFLICTO DE LICENCIAS: asset CC-BY-SA junto a contenido propietario — evaluar compatibilidad de distribución")

	return errores


static func _validar_politicas(data: Dictionary) -> Array:
	var errores: Array = []
	var politicas: Dictionary = data.get("politicas", {})

	if politicas.is_empty():
		errores.append("Sin políticas definidas")
		return errores

	# Verificar políticas críticas
	if not politicas.get("checklist_atribucion_obligatorio", false):
		errores.append("Política: checklist de atribución no es obligatorio")
	if not politicas.get("prohibido_nc_nd", false):
		errores.append("Política: no se prohíben licencias NC/ND")
	if not politicas.get("prohibido_plagio", false):
		errores.append("Política: no se prohíbe el plagio")

	# Verificar que la escala de preferencia exista
	var escala: Array = politicas.get("escala_preferencia_licencias", [])
	if escala.is_empty():
		errores.append("Política: escala de preferencia de licencias vacía")

	return errores


static func _validar_marcas(data: Dictionary) -> Array:
	var errores: Array = []
	var marcas: Dictionary = data.get("marcas", {})

	for nombre in marcas.keys():
		var info: Dictionary = marcas[nombre]
		var busquedas: Array = info.get("busquedas", [])
		if busquedas.is_empty():
			errores.append("Marca '%s': sin búsquedas de colisión registradas" % nombre)
		var decision: String = String(info.get("decision", ""))
		if decision.is_empty():
			errores.append("Marca '%s': sin decisión documentada" % nombre)

	return errores


static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M78] LegalValidator v2: OK — todos los checks pasaron"
	var lineas: Array = ["[M78] LegalValidator v2: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)


static func estadisticas(data: Dictionary) -> Dictionary:
	return {
		"ips": data.get("ips", []).size(),
		"assets_terceros": data.get("assets_terceros", []).size(),
		"assets_propios": data.get("assets_propios", []).size(),
		"marcas": data.get("marcas", {}).size(),
		"politicas_definidas": not data.get("politicas", {}).is_empty()
	}
