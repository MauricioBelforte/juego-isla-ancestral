# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M95: Monetización — ScannerAntip2w
# Scan anti-pay-to-win (RF9/DoD 6): verifica que NINGÚN ítem de pago altere
# la progresión (M38 economía, M71 progresión). Devuelve violaciones.
# Diseño original (04-Codigo.md §1.1, AntiP2WScanner.cs).

class_name ScannerAntip2w
extends RefCounted

## Escanea la lista de ítems de pago (cada uno: {id, tipo, afecta_progresion}).
## Devuelve Array[String] de violaciones (vacía = OK).
static func escanear(items_pago: Array) -> Array:
	var violaciones: Array = []
	for item in items_pago:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var id: String = String(item.get("id", "?"))
		if bool(item.get("afecta_progresion", false)):
			violaciones.append("item_pago '%s' altera la progresión (P2W)" % id)
		# Ítems que otorgan ventaja directa en combate/recolección también son P2W
		if String(item.get("tipo", "")) in ["acelerador", "ventaja", "poder"]:
			violaciones.append("item_pago '%s' tipo '%s' otorga ventaja (P2W)" % [id, item.get("tipo", "")])
	return violaciones

static func reporte(violaciones: Array) -> String:
	if violaciones.is_empty():
		return "[M95] AntiP2W: OK — 0 ítems de pago alteran progresión"
	var lineas: Array = ["[M95] AntiP2W: %d VIOLACIONES:" % violaciones.size()]
	for v in violaciones:
		lineas.append("  - %s" % v)
	return "\n".join(lineas)