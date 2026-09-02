# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M36: Fauna - FaunaCatalog (RefCounted). Carga y valida el catalogo de especies
# desde data/fauna/catalog.json. NO es autoload (RefCounted) para que cualquier
# manager (FaunaManager, FaunaSpawner, M37 Museos) lo pueda usar como instancia
# inyectable. Iter 1 usa un catalogo in-code como fallback si el JSON no existe
# (asi el test headless funciona sin assets de data/).

extends RefCounted

const CATALOGO_PATH := "res://data/fauna/catalog.json"
const SpeciesRef = preload("res://scripts/fauna/fauna_species.gd")

var _especies: Dictionary = {}    # StringName -> Resource (FaunaSpecies instance)

## Carga el catalogo desde JSON. Si falla, usa el fallback in-code (5 especies base).
## Devuelve la cantidad de especies cargadas.
func cargar() -> int:
	_especies.clear()
	if FileAccess.file_exists(CATALOGO_PATH):
		var contenido := FileAccess.get_file_as_string(CATALOGO_PATH)
		if contenido.is_empty():
			return _cargar_fallback()
		var parsed: Variant = JSON.parse_string(contenido)
		if typeof(parsed) != TYPE_ARRAY:
			push_warning("[M36] catalog.json no es array; usando fallback")
			return _cargar_fallback()
		return _cargar_desde_array(parsed)
	return _cargar_fallback()

## Construye una especie desde un dict de JSON.
func _especie_desde_dict(data: Dictionary) -> Resource:
	var sp = SpeciesRef.new()
	sp.id = StringName(String(data.get("id", "")))
	sp.display_name = String(data.get("display_name", ""))
	sp.nombre_cientifico = String(data.get("nombre_cientifico", ""))
	sp.bioma_principal = StringName(String(data.get("bioma_principal", "")))
	sp.rareza = _parsear_enum(SpeciesRef.Rareza, String(data.get("rareza", "COMUN")))
	sp.ventana_horaria = _parsear_ventana(String(data.get("ventana_horaria", "DIURNA")))
	sp.comportamiento = _parsear_comportamiento(String(data.get("comportamiento", "PASIVA")))
	sp.clase = _parsear_clase(String(data.get("clase", "TERRESTRE")))
	sp.gregaria = bool(data.get("gregaria", false))
	sp.cantidad_manada_min = int(data.get("manada_min", 1))
	sp.cantidad_manada_max = maxi(sp.cantidad_manada_min, int(data.get("manada_max", 1)))
	sp.escala_min = float(data.get("escala_min", 0.5))
	sp.escala_max = maxi(sp.escala_min, float(data.get("escala_max", 1.0)))
	# colores (variantes)
	var cols: Array = data.get("color_variantes", [])
	for c in cols:
		sp.color_variantes.append(_parse_color(c))
	sp.velocidad_deambular = float(data.get("velocidad_deambular", 1.0))
	sp.velocidad_huida = float(data.get("velocidad_huida", 3.0))
	sp.radio_alarma = float(data.get("radio_alarma", 4.0))
	sp.radio_curiosidad = float(data.get("radio_curiosidad", 6.0))
	sp.factor_miedo_base = float(data.get("factor_miedo_base", 1.0))
	return sp

func _cargar_desde_array(arr: Array) -> int:
	var cargadas: int = 0
	for entrada in arr:
		if not (entrada is Dictionary):
			continue
		var sp := _especie_desde_dict(entrada)
		if sp.es_valido():
			_especies[sp.id] = sp
			cargadas += 1
		else:
			push_warning("[M36] especie invalida descartada: %s" % String(entrada.get("id", "?")))
	return cargadas

## Catalogo minimo in-code (5 especies representativas de 4 biomas).
## Activa cuando no hay catalog.json o falla la carga.
func _cargar_fallback() -> int:
	_especies.clear()
	var ejemplos: Array = [
		{"id": "gaviota_playera", "display_name": "Gaviota Playera", "bioma_principal": "playa", "rareza": "COMUN", "ventana_horaria": "DIURNA", "comportamiento": "PASIVA_AEREA", "clase": "AEREA"},
		{"id": "salamandra_ancestral", "display_name": "Salamandra Ancestral", "bioma_principal": "bosque_ancestral", "rareza": "MUY_RARA", "ventana_horaria": "CREPUSCULAR", "comportamiento": "CURIOSA", "clase": "ANFIBIA"},
		{"id": "conejo_pradera", "display_name": "Conejo de Pradera", "bioma_principal": "pradera", "rareza": "COMUN", "ventana_horaria": "DIURNA", "comportamiento": "HUIDA_INSTINTIVA", "clase": "TERRESTRE", "gregaria": true, "manada_min": 2, "manada_max": 4},
		{"id": "nutria_ribera", "display_name": "Nutria de Ribera", "bioma_principal": "ribera", "rareza": "POCO_COMUN", "ventana_horaria": "DIURNA", "comportamiento": "CURIOSA", "clase": "ANFIBIA"},
		{"id": "lechuza_bosque", "display_name": "Lechuza del Bosque", "bioma_principal": "bosque", "rareza": "POCO_COMUN", "ventana_horaria": "NOCTURNA", "comportamiento": "PASIVA_AEREA", "clase": "AEREA"},
	]
	return _cargar_desde_array(ejemplos)

## ── API publica ─────────────────────────────────────────────

func obtener(id: StringName) -> Resource:
	return _especies.get(id, null)

func obtener_todas() -> Array:
	return _especies.values()

func cantidad() -> int:
	return _especies.size()

func especies_por_bioma(bioma: StringName) -> Array:
	var out: Array = []
	for sp in _especies.values():
		if sp.bioma_principal == bioma:
			out.append(sp)
	return out

## Devuelve las especies compatibles con la hora actual y el bioma dados.
## RF B: ventana horaria. RF C: filtro por bioma.
func candidatas_para(hora: int, bioma: StringName) -> Array:
	var out: Array = []
	for sp in _especies.values():
		if sp.bioma_compatible(bioma) and sp.activa_en_hora(hora):
			out.append(sp)
	return out

## Pesos para muestreo por rareza (mas comun = mas probable).
func peso_por_rareza(rareza: int) -> float:
	match rareza:
		SpeciesRef.Rareza.COMUN: return 1.0
		SpeciesRef.Rareza.POCO_COMUN: return 0.5
		SpeciesRef.Rareza.RARA: return 0.25
		SpeciesRef.Rareza.MUY_RARA: return 0.1
		_: return 0.5

## ── Helpers ────────────────────────────────────────────────

func _parsear_enum(enum_dict, nombre: String) -> int:
	for k in enum_dict.keys():
		if String(k) == nombre:
			return int(enum_dict[k])
	return 0

func _parsear_ventana(s: String) -> int:
	return _parsear_enum(SpeciesRef.VentanaHoraria, s)

func _parsear_comportamiento(s: String) -> int:
	return _parsear_enum(SpeciesRef.Comportamiento, s)

func _parsear_clase(s: String) -> int:
	return _parsear_enum(SpeciesRef.Clase, s)

func _parse_color(c) -> Color:
	if c is Color:
		return c
	if c is Array and c.size() >= 3:
		return Color(float(c[0]), float(c[1]), float(c[2]), 1.0 if c.size() < 4 else float(c[3]))
	if c is String:
		return Color(c)
	return Color.WHITE
