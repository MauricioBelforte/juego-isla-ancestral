# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M88: Fuentes Tipográficas — FontCatalog (autoload)
# Catálogo de fuentes data-driven con licencias (fonts.json), acceso por id,
# auditoría de licencias. Adaptación Godot 4.7/GDScript del diseño.
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const RUTA_FONTS := "res://data/fonts/fonts.json"

var config: Dictionary = {}

func _ready() -> void:
	_cargar_fonts()
	_registrar_servicio()
	print("[M88] FontCatalog listo (%d fuentes)" % config.get("fuentes", []).size())

func _cargar_fonts() -> void:
	if not FileAccess.file_exists(RUTA_FONTS):
		push_warning("[M88] fonts.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_FONTS))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("fonts"):
		sr.register("fonts", self)

func fuente(id: String) -> Dictionary:
	for f in config.get("fuentes", []):
		if String(f.get("id", "")) == id:
			return f
	return {}

func fuentes_por_familia(familia: String) -> Array:
	var resultado: Array = []
	for f in config.get("fuentes", []):
		if String(f.get("familia", "")) == familia:
			resultado.append(f)
	return resultado

func licencias_permitidas() -> Array:
	return config.get("licencias_permitidas", [])

## Auditoría (FontAuditor). Devuelve Array de errores.
func auditar() -> Array:
	return FontAuditor.validar(config)

## M87 iter. 3 (glm-5.3-flash): cobertura de caracteres por idioma.
## Cada fuente declara "cobertura": Array de locales soportados (es/en) o
## "todos". La UI M53/M110 elige la fuente según el idioma activo (checklist
## M87 ítems "compatibilidad de caracteres" y "FontLoader según idioma").
func cobertura_de(id: String) -> Array:
	var f := fuente(id)
	if f.is_empty():
		return []
	var cobertura: Array = f.get("cobertura", ["todos"])
	return cobertura.duplicate()


func soporta_idioma(id: String, locale: String) -> bool:
	var cobertura := cobertura_de(id)
	if cobertura.has("todos") or cobertura.is_empty():
		return true
	return cobertura.has(locale)


## Fuente recomendada para un idioma: primera de familia "body" que soporte
## el locale (fallback: cualquier body; el catálogo es data-driven).
func fuente_para_idioma(locale: String) -> Dictionary:
	var body := fuentes_por_familia("body")
	for f in body:
		var cobertura: Array = f.get("cobertura", ["todos"])
		if cobertura.has("todos") or cobertura.has(locale):
			return f
	if not body.is_empty():
		return body[0]
	return {}

## RF14 (M87): validación de cobertura de caracteres es/en en las fuentes.
## Una fuente sin cobertura declarada para un idioma activo = error de validación.
func validar_cobertura_idiomas(locales: Array) -> Array:
	var errores: Array = []
	for f in config.get("fuentes", []):
		var id := String(f.get("id", ""))
		var cobertura: Array = f.get("cobertura", ["todos"])
		var cubre_alguno := cobertura.has("todos") or cobertura.is_empty()
		for locale in locales:
			if cobertura.has(locale):
				cubre_alguno = true
		if not cubre_alguno:
			errores.append("%s: sin cobertura para ninguno de los locales %s" % [id, str(locales)])
	return errores