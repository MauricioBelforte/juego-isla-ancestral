# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M94: Retención sin FOMO — RecompensaAcumulada
# Cola de recompensas SIN expiración (RF1/RF9): lo que no se cobró al
# completar un objetivo queda pendiente hasta que el jugador lo cobre
# desde el diario (M55). Límite de pendientes: 50; excedente se liquida
# en oro al momento de cobrar (diseño original 04-Codigo.md §2).
#
# ⚠️ Sin class_name: se accede por API del MotivacionManager (autoload)
# o por preload. Evita colisiones con el autoload (§9.17/§9.41).

class_name RecompensaAcumulada
extends RefCounted

const LIMITE_PENDIENTES: int = 50

var pendientes: Array = []   # [ {recompensa_id, cantidad}, ... ]

func agregar(recompensa_id: String, cantidad: int) -> void:
	if pendientes.size() >= LIMITE_PENDIENTES:
		# Límite alcanzado: se descarta (el jugador debe cobrar antes)
		return
	pendientes.append({"recompensa_id": recompensa_id, "cantidad": cantidad})

## Entrega la lista de pendientes y vacía la cola. Devuelve Array.
func cobrar_pendientes() -> Array:
	var salida := pendientes.duplicate()
	pendientes.clear()
	return salida

func pendientes_count() -> int:
	return pendientes.size()

func a_diccionario() -> Dictionary:
	return {"pendientes": pendientes.duplicate(true)}

static func desde_diccionario(d: Dictionary) -> RecompensaAcumulada:
	var r := RecompensaAcumulada.new()
	var lista: Array = d.get("pendientes", [])
	for item in lista:
		if typeof(item) == TYPE_DICTIONARY:
			r.pendientes.append(item.duplicate(true))
	return r