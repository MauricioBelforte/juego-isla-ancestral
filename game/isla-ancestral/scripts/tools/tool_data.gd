# Modelo: ox-alpha
# Plataforma: Cline
# Fecha: 2026-08-25
#
# M13: Herramientas — ToolData (Resource)
# Catálogo de 9 herramientas × 4 niveles (cobre, hierro, oro, cristal).
# Stats según tablas de 01-Requerimientos.md §3.1 y balance de tiempos 03-Diseno.md §6.

## Resource de herramienta: tipo, nivel, durabilidad, velocidad, área.
class_name ToolData
extends Resource

## Tipos de herramienta (9)
enum Tipo {
	PICO,
	AZADA,
	HACHA,
	PALA,
	REGADERA,
	CANA,
	MARTILLO,
	TIJERAS,
	LUPA,
}

## Niveles/tiers (4)
enum Nivel {
	COBRE = 1,
	HIERRO = 2,
	ORO = 3,
	CRISTAL = 4,
}

## Acciones permitidas (contratos con otros módulos)
enum Accion {
	EXTRACT,   # try_extract → M08/M50
	TILL,      # till → M33
	WATER,     # water → M33
	FISH,      # fish → M35
	BUILD,     # build/rotate/repair → M17 (place)
	SHEAR,     # shear → M50
	INSPECT,   # inspect → M26/M44
}

@export var tipo: Tipo = Tipo.PICO
@export var nivel: Nivel = Nivel.COBRE
@export var nombre: String = ""
## Durabilidad máxima en golpes (cozy: nunca se rompe, queda inutilizada a 0)
@export var durabilidad_max: int = 100
## Segundos por golpe a nivel base (mejor nivel = más rápido)
@export var velocidad_segolpe: float = 1.0
## Área de extracción: 1 (1x1) o 9 (3x3, desde T3)
@export var area: int = 1
## Acciones permitidas (Array de Accion)
@export var acciones: Array[int] = []
## Costo de reparación: [recurso_id: String, cantidad: int] (½ fabricación)
@export var receta_reparacion: Dictionary = {}
## Durabilidad actual de esta instancia
@export var durabilidad_actual: int = 100
## Mejoras aplicadas (M158 §9): afilar/templar/potenciar, cada una 1 vez
@export var mejora_afilada: bool = false
@export var mejora_templada: bool = false
@export var mejora_potenciada: bool = false

## Tablas base por tipo y nivel: [durabilidad, velocidad, area]
const STATS := {
	Tipo.PICO: {1: [150, 1.2, 1], 2: [250, 0.9, 1], 3: [400, 0.7, 9], 4: [600, 0.5, 9]},
	Tipo.HACHA: {1: [120, 1.0, 1], 2: [200, 0.8, 1], 3: [350, 0.6, 9], 4: [500, 0.4, 9]},
	Tipo.AZADA: {1: [100, 1.0, 1], 2: [160, 0.8, 1], 3: [260, 0.6, 9], 4: [400, 0.45, 9]},
	Tipo.PALA: {1: [110, 0.8, 1], 2: [180, 0.65, 1], 3: [280, 0.5, 9], 4: [420, 0.35, 9]},
	Tipo.REGADERA: {1: [80, 0.5, 1], 2: [120, 0.4, 1], 3: [180, 0.3, 9], 4: [260, 0.25, 9]},
	Tipo.CANA: {1: [90, 1.0, 1], 2: [140, 0.9, 1], 3: [200, 0.8, 1], 4: [300, 0.7, 1]},
	Tipo.MARTILLO: {1: [-1, 0.8, 1], 2: [-1, 0.7, 1], 3: [-1, 0.6, 1], 4: [-1, 0.5, 1]},  # -1 = infinita
	Tipo.TIJERAS: {1: [70, 0.6, 1], 2: [110, 0.5, 1], 3: [170, 0.4, 1], 4: [240, 0.3, 1]},
	Tipo.LUPA: {1: [-1, 0.0, 1], 2: [-1, 0.0, 1], 3: [-1, 0.0, 1], 4: [-1, 0.0, 1]},  # infinita
}

## Nombres legibles por tipo
const NOMBRES := {
	Tipo.PICO: "Pico",
	Tipo.AZADA: "Azada",
	Tipo.HACHA: "Hacha",
	Tipo.PALA: "Pala",
	Tipo.REGADERA: "Regadera",
	Tipo.CANA: "Caña de Pescar",
	Tipo.MARTILLO: "Martillo",
	Tipo.TIJERAS: "Tijeras",
	Tipo.LUPA: "Lupa",
}

## Material por nivel
const MATERIALES := {
	Nivel.COBRE: "Cobre",
	Nivel.HIERRO: "Hierro",
	Nivel.ORO: "Oro",
	Nivel.CRISTAL: "Cristal",
}

## Crea una instancia nueva de herramienta con stats de tabla.
static func crear(p_tipo: int, p_nivel: int) -> ToolData:
	var t := ToolData.new()
	t.tipo = p_tipo as Tipo
	t.nivel = p_nivel as Nivel
	var stats: Array = STATS[p_tipo][p_nivel]
	t.durabilidad_max = stats[0]
	t.durabilidad_actual = stats[0]
	t.velocidad_segolpe = stats[1]
	t.area = stats[2]
	t.nombre = "%s de %s" % [NOMBRES[p_tipo], MATERIALES[p_nivel]]
	t.acciones = _acciones_por_tipo(p_tipo)
	return t

## Acciones permitidas según tipo (contrato 03-Diseno.md §2).
static func _acciones_por_tipo(p_tipo: int) -> Array[int]:
	match p_tipo:
		Tipo.PICO, Tipo.HACHA, Tipo.PALA:
			return [Accion.EXTRACT]
		Tipo.AZADA:
			return [Accion.TILL, Accion.EXTRACT]
		Tipo.REGADERA:
			return [Accion.WATER]
		Tipo.CANA:
			return [Accion.FISH]
		Tipo.MARTILLO:
			return [Accion.BUILD]
		Tipo.TIJERAS:
			return [Accion.SHEAR]
		Tipo.LUPA:
			return [Accion.INSPECT]
	return []

## ¿La herramienta puede ejecutar esta acción?
func permite(accion: int) -> bool:
	return acciones.has(accion)

## ¿Durabilidad infinita? (martillo, lupa)
func durabilidad_infinita() -> bool:
	return durabilidad_max < 0

## ¿Está inutilizada? (cozy: nunca desaparece, solo se repara)
func inutilizada() -> bool:
	if durabilidad_infinita():
		return false
	return durabilidad_actual <= 0

## ¿Necesita aviso de reparación? (<20%, regla cozy §7)
func necesita_reparacion() -> bool:
	if durabilidad_infinita():
		return false
	return float(durabilidad_actual) / float(durabilidad_max) <= 0.2

## Consume 1 punto de durabilidad por uso.
func gastar_uso() -> void:
	if not durabilidad_infinita() and durabilidad_actual > 0:
		durabilidad_actual -= 1

## Velocidad efectiva tras mejoras (+20% afilar).
func velocidad_efectiva() -> float:
	var v := velocidad_segolpe
	if mejora_afilada:
		v *= 0.8
	return v

## Serializa para GameState.M13 (M59).
func serializar() -> Dictionary:
	return {
		"tipo": tipo,
		"nivel": nivel,
		"durabilidad": durabilidad_actual,
		"afilada": mejora_afilada,
		"templada": mejora_templada,
		"potenciada": mejora_potenciada,
	}

## Restaura desde serialización.
static func deserializar(data: Dictionary) -> ToolData:
	var t := crear(int(data.get("tipo", 0)), int(data.get("nivel", 1)))
	t.durabilidad_actual = int(data.get("durabilidad", t.durabilidad_max))
	t.mejora_afilada = bool(data.get("afilada", false))
	t.mejora_templada = bool(data.get("templada", false))
	t.mejora_potenciada = bool(data.get("potenciada", false))
	return t
