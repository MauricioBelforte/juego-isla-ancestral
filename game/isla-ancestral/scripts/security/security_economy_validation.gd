# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-25
#
# M106: Seguridad — SecurityEconomyValidation (helper reutilizable, V0 + headless).
# Implementa el servicio "EconomyValidation" del diseño (03-Diseno.md §8), que quedó `[ ]`:
#   max_gold                 -> max_oro (variable pública)
#   max_items                -> max_objetos (variable pública)
#   validate_economy         -> validar_economia
#   validate_economy_checksum-> validar_economia_checksum
# Lógica pura (RefCounted, sin class_name → preload). NO reemplaza al autoload
# `SecurityManager.validar_economia` (que ya cubre RF11 sobre "plata"/"objetos_inventario"/"nivel");
# este helper agrega el CHECKSUM de economía y los límites parametrizables que el diseño pide.
#
# Vocabulario: acepta las claves del diseño ("gold"/"inventory"/"quantity") y las del autoload
# ("oro"/"plata"/"inventario"/"objetos_inventario"/"cantidad"). Se documenta en 04-Codigo.md.

extends RefCounted

var max_oro: int = 1000000
var max_objetos: int = 9999


func _init(max_oro_inicial: int = 1000000, max_objetos_inicial: int = 9999) -> void:
	max_oro = max_oro_inicial
	max_objetos = max_objetos_inicial


## Valida la economía: oro en [0, max_oro] y cada item con cantidad en [0, max_objetos].
## Devuelve true si es legítima; false si algún valor está fuera de rango o es negativo.
func validar_economia(datos: Dictionary) -> bool:
	var oro: int = _leer_oro(datos)
	if oro < 0 or oro > max_oro:
		return false
	var inv: Array = _leer_inventario(datos)
	for item in inv:
		var cant: int = _leer_cantidad(item)
		if cant < 0 or cant > max_objetos:
			return false
	return true


## Valida el checksum SHA-256 del bloque económico {oro, inventario}.
func validar_economia_checksum(datos: Dictionary, checksum: String) -> bool:
	return calcular_checksum_economia(datos) == checksum


## Checksum SHA-256 del bloque económico (serialización canónica).
func calcular_checksum_economia(datos: Dictionary) -> String:
	var canonico := {
		"oro": _leer_oro(datos),
		"inventario": _leer_inventario(datos),
	}
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(JSON.stringify(canonico).to_utf8_buffer())
	var digest: PackedByteArray = ctx.finish()
	return digest.hex_encode()


func _leer_oro(datos: Dictionary) -> int:
	if datos.has("oro"):
		return int(datos["oro"])
	if datos.has("gold"):
		return int(datos["gold"])
	if datos.has("plata"):
		return int(datos["plata"])
	return 0


func _leer_inventario(datos: Dictionary) -> Array:
	var v: Variant = null
	if datos.has("inventario"):
		v = datos["inventario"]
	elif datos.has("inventory"):
		v = datos["inventory"]
	var out: Array = []
	if typeof(v) == TYPE_ARRAY:
		out = v
	return out


func _leer_cantidad(item: Variant) -> int:
	if typeof(item) == TYPE_DICTIONARY:
		var d: Dictionary = item
		if d.has("cantidad"):
			return int(d["cantidad"])
		if d.has("quantity"):
			return int(d["quantity"])
		return 0
	return int(item)
