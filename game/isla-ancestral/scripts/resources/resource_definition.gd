# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M15: Recursos — ResourceDefinition (definicion serializable de un tipo de recurso).
# RF1/RF2: catalogo data-driven de madera, piedra, fibras, comida, minerales y raros.
# Se guarda como .tres o se construye en codigo (tests).

class_name ResourceDefinition
extends Resource

enum Categoria { MADERA, PIEDRA, FIBRA, COMIDA, MINERAL, RARO }

@export var def_id: StringName = &""
@export var display_name: String = ""
@export var categoria: int = Categoria.MADERA
@export var rareza: int = 0  # 0 comun .. 3 legendario
@export var herramienta_requerida: StringName = &""  # "" = manos
@export var golpes_requeridos: int = 2
@export var drops: Array[ResourceDropEntry] = []
@export var temporada_respawn: StringName = &"todas"
@export var evento_respawn: StringName = &""  # "" = ninguno
@export var region: StringName = &""  # "" = cualquier
@export var valor_venta: int = 0
@export var fuentes_alternativas: Array[StringName] = []
@export var dias_para_respawn: int = 2  # M15 iter 3: días M29 hasta respawn

## M15 iter 3: mapeo temporada_respawn -> estación int (0..3) o -1 si "todas".
func get_respawn_estacion_int() -> int:
	var t: String = String(temporada_respawn).to_lower().strip_edges()
	match t:
		"primavera": return 0
		"verano": return 1
		"otono", "otoño": return 2
		"invierno": return 3
		"todas", "": return -1
	return -1

## Devuelve los drops filtrados segun la herramienta usada.
## `mejorada` = true si la herramienta es de nivel superior (RF5).
func drops_para_herramienta(mejorada: bool) -> Array[ResourceDropEntry]:
	var out: Array[ResourceDropEntry] = []
	for d in drops:
		if d.requiere_herramienta_mejorada and not mejorada:
			continue
		out.append(d)
	return out

func es_accesible_con(herramienta_id: StringName, _manos_ok: bool = true) -> bool:
	if herramienta_requerida == &"":
		return true  # manos o cualquier herramienta
	return herramienta_id == herramienta_requerida
