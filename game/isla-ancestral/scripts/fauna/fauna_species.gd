# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M36: Fauna - FaunaSpecies (Resource) — datos puros de una especie.
# Sin class_name (07-GUIA-GODOT §9.17) para que test headless --script funcione via preload.
# Sin embargo este Resource es instanciable via .new() directo (no via GDScript.new()).
# Cobertura: secciones A (catalogo), parte de B (comportamiento), parte de C (biomas).

extends Resource

enum Comportamiento { HUIDA_INSTINTIVA, HUIDA_SUAVE, CURIOSA, PASIVA, PASIVA_AEREA, PASIVA_MARINA }
enum Clase { TERRESTRE, ACUATICA, AEREA, ANFIBIA }
enum Rareza { COMUN, POCO_COMUN, RARA, MUY_RARA }
enum VentanaHoraria { DIURNA, CREPUSCULAR, NOCTURNA, ALBA, TODA_HORA }

# Identificacion
@export var id: StringName = &""
@export var display_name: String = ""
@export var nombre_cientifico: String = ""

# Ecologia
@export var bioma_principal: StringName = &""      # playa, humedal, ribera, pradera, bosque, bosque_ancestral, montana, oceano, cueva
@export var rareza: int = Rareza.COMUN
@export var ventana_horaria: int = VentanaHoraria.DIURNA
@export var comportamiento: int = Comportamiento.PASIVA
@export var clase: int = Clase.TERRESTRE
@export var gregaria: bool = false
@export var cantidad_manada_min: int = 1
@export var cantidad_manada_max: int = 1

# Visual / escala
@export var escala_min: float = 0.5
@export var escala_max: float = 1.0
@export var color_variantes: Array[Color] = []      # 2-3 colores

# Movimiento
@export var velocidad_deambular: float = 1.0
@export var velocidad_huida: float = 3.0
@export var radio_alarma: float = 4.0
@export var radio_curiosidad: float = 6.0
@export var factor_miedo_base: float = 1.0

# ── Validacion ─────────────────────────────────────────────

func es_valido() -> bool:
	if id == &"":
		return false
	if display_name.is_empty():
		return false
	if bioma_principal == &"":
		return false
	return true

## Devuelve true si la especie puede estar activa en la hora actual (0-23).
## RF B: ventana horaria de la especie.
func activa_en_hora(hora: int) -> bool:
	match ventana_horaria:
		VentanaHoraria.TODA_HORA:
			return true
		VentanaHoraria.DIURNA:
			return hora >= 6 and hora < 19
		VentanaHoraria.NOCTURNA:
			return hora < 6 or hora >= 19
		VentanaHoraria.CREPUSCULAR:
			return (hora >= 5 and hora < 8) or (hora >= 17 and hora < 20)
		VentanaHoraria.ALBA:
			return hora >= 5 and hora < 8
	return true

## RF C: filtro por bioma valido. bioma_origen es el bioma en la posicion del spawn.
func bioma_compatible(bioma_origen: StringName) -> bool:
	if bioma_principal == &"":
		return false
	return bioma_origen == bioma_principal

## Genera factor de miedo individual +-10% usando PRNG.
## RF B: factor_miedo individual.
func generar_factor_miedo_individual(rng: RandomNumberGenerator) -> float:
	return factor_miedo_base * rng.randf_range(0.9, 1.1)
