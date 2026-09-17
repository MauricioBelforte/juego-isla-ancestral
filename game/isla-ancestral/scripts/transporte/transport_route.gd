# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-11
#
# M68: Transporte y Navegación — TransportRoute (Resource).
# Una arista dirigida del grafo: de una parada a otra, con duración, coste
# base (M38), restricciones de horario/clima/temporada y flag de desbloqueo.
#
# Decisión de diseño (03-Diseno §3.2): el coste DIRECTO es mayor que combinar
# dos rutas — incentiva la exploración. La propiedad es del DATASET, no del
# código: `TransportNetwork.validar()` sólo comprueba que el grafo sea simple.

class_name TransportRoute
extends Resource

## ID estable de la ruta.
@export var id: StringName = &""
## Parada de origen.
@export var from_id: StringName = &""
## Parada de destino.
@export var to_id: StringName = &""
## Duración en segundos reales de juego (transición, no tiempo real de reloj).
@export var duracion_seg: float = 30.0
## Coste base del boleto en AO (M38).
@export var base_cost: int = 0
## Medio de la ruta: "barco", "dirigible", "tren", "muelle".
@export var medio: String = "barco"
## Flag de WorldState que desbloquea la ruta (M22/M71). Vacío = sin requisito.
@export var requiere_flag: StringName = &""
## ¿Sólo visible si `requiere_flag` está activo? (rutas secretas de historia)
@export var es_secreta: bool = false
## Temporada requerida (M29). "" o "todas" = siempre.
@export var temporada: String = ""
## ¿Se puede comprar en el destino para volver? (informativo: la arista inversa
## es explícita en el grafo — esto sólo documenta la simetría del diseño).
@export var bidireccional: bool = true


## ¿Sufre esta ruta con clima adverso? (M32: barcos y dirigibles, no el tren)
func afectada_por_clima() -> bool:
	return medio == "barco" or medio == "dirigible"


## Duración con factor de clima (M32: tormenta/viento +25%).
func duracion_con_clima(factor: float) -> float:
	if not afectada_por_clima():
		return duracion_seg
	return duracion_seg * (1.0 + 0.25 * clampf(factor, 0.0, 1.0))


## Coste con descuento por amistad (M20: nivel 5+ → −20%).
func coste_con_descuento(nivel_amistad: int) -> int:
	if nivel_amistad >= 5:
		return int(round(float(base_cost) * 0.8))
	return base_cost


func a_diccionario() -> Dictionary:
	return {
		"id": String(id),
		"from": String(from_id),
		"to": String(to_id),
		"medio": medio,
		"duracion_seg": snappedf(duracion_seg, 0.01),
		"coste": base_cost,
		"temporada": temporada,
	}
