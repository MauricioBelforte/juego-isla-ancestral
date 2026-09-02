# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M95: Monetización — ScannerAntilootbox
# Scan anti-lootbox (RF9/DoD 6): verifica que NO existan sistemas de cajas
# de azar (aleatoriedad con pago o grind obligatorio por contenido de azar).
# Devuelve violaciones. Diseño original (04-Codigo.md §1.1, AntiLootboxScanner.cs).

class_name ScannerAntilootbox
extends RefCounted

## Escanea sistemas sospechosos. Cada sistema: {id, tipo, aleatorio, requiere_pago}.
## Un lootbox = aleatorio + (pago directo O contenido no obtenible de otra forma).
static func escanear(sistemas: Array) -> Array:
	var violaciones: Array = []
	for sistema in sistemas:
		if typeof(sistema) != TYPE_DICTIONARY:
			continue
		var id: String = String(sistema.get("id", "?"))
		var aleatorio: bool = bool(sistema.get("aleatorio", false))
		var requiere_pago: bool = bool(sistema.get("requiere_pago", false))
		var unica_via: bool = bool(sistema.get("unica_via", false))
		if aleatorio and (requiere_pago or unica_via):
			violaciones.append("sistema '%s' es lootbox (aleatorio + %s)" % [id, "pago" if requiere_pago else "contenido exclusivo"])
		elif aleatorio:
			# aleatorio sin pago y con otra vía: permitido (regalo de pesca etc.) pero se registra
			pass
	return violaciones

static func reporte(violaciones: Array) -> String:
	if violaciones.is_empty():
		return "[M95] AntiLootbox: OK — 0 cajas de azar"
	var lineas: Array = ["[M95] AntiLootbox: %d VIOLACIONES:" % violaciones.size()]
	for v in violaciones:
		lineas.append("  - %s" % v)
	return "\n".join(lineas)