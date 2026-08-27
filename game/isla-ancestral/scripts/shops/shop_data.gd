# Modelo: ox-alpha
# Plataforma: Cline
# Fecha: 2026-08-25
#
# M39: Tiendas — ShopData (Resource data-driven por tienda)
# Una instancia .tres por tienda. Catálogos y horarios declarativos;
# la lógica vive en shop.gd / stock_generator.gd / shop_manager.gd.
extends Resource

## Tipos de establecimiento (01-Requerimientos §3.1)
enum Tipo {
	PUESTO_SEMILLAS,
	PESCADERIA,
	FERRETERIA,
	TIENDA_GENERAL,
	MERCADER_VIAJERO,
	TIENDA_JUGADOR,  # tienda propia del jugador (sistema reputación)
}

## Entrada de catálogo: qué vende/compra una tienda y cuánto
class StockEntry:
	var item_id: String = ""
	var stock_min: int = 1
	var stock_max: int = 10
	var peso_rareza: float = 1.0  # mayor = más raro → menos ejemplares
	var es_basico: bool = false   # básicos garantizan stock_min >= 1

	func _init(p_id: String = "", p_min: int = 1, p_max: int = 10, p_rareza: float = 1.0, p_basico: bool = false) -> void:
		item_id = p_id
		stock_min = p_min
		stock_max = p_max
		peso_rareza = p_rareza
		es_basico = p_basico

	func serializar() -> Dictionary:
		return {"id": item_id, "min": stock_min, "max": stock_max, "r": peso_rareza, "b": es_basico}

	static func deserializar(d: Dictionary) -> StockEntry:
		return StockEntry.new(
			str(d.get("id", "")),
			int(d.get("min", 1)),
			int(d.get("max", 10)),
			float(d.get("r", 1.0)),
			bool(d.get("b", false))
		)

@export var shop_id: String = ""
@export var nombre_clave_i18n: String = ""
@export var tipo: Tipo = Tipo.TIENDA_GENERAL
@export var npc_duenio_id: String = ""

## Horarios: días abiertos (0=domingo..6=sábado estilo M29) y franjas [inicio, fin] en horas
@export var dias_abiertos: Array[int] = [1, 2, 3, 4, 5]
@export var franjas_horarias: Array[Vector2i] = [Vector2i(8, 18)]  # hora inicio-fin
@export var dias_descanso: Array[int] = []          # feriados/festivos extra
@export var descanso_semanal: int = -1              # día fijo de descanso semanal (-1 = ninguno)

## Catálogos
@export var catalogo_venta: Array = []   # Array[StockEntry] — inner class, sin tipado estricto
@export var catalogo_recompra: Array[String] = []    # item_ids que le compra al jugador

## Canalización de stock (balance §8)
@export var restock_diario: int = 5
@export var rotacion_estacional_fuerte: bool = false
@export var recargo_mercader_pct: float = 0.0        # solo mercaderes viajeros (±10-15%)
@export var dias_aparicion_mercader: int = 0         # >0: aparece 1 de cada N días (PRNG)
