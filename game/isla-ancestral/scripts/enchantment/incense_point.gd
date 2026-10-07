# M163 - Sistema de Encantamientos (iter. 2, seccion C: Incienso)
# IncensePoint — planta de montaña interactuable (cadena E, M70).
#  - Nace plantado (ciclo de 3 dias) y se cosecha con E cuando esta listo.
#  - Tras la cosecha queda NO_DISPONIBLE y se renueva a los 3 dias (C8).
#  - `raro = true` cosecha "incense_rare" (estacionalidad via M29, C3/C12).
extends InteractableBase
class_name IncensePoint

## Estados de EstadoInteractuable (interaction_manager.gd L38).
const EST_DISPONIBLE: int = 0
const EST_NO_DISPONIBLE: int = 2

var cultivo: IncenseCultivation = null
var raro: bool = false
var dia_agotado: int = -1

func _ready() -> void:
	super._ready()
	categoria = &"cosecha"
	prioridad = 5
	radio = 2.0
	if cultivo == null:
		cultivo = IncenseCultivation.new()
		cultivo.plantar(_dia_actual())

# ── Contrato IInteractable ────────────────────────────────────

func obtener_nombre_prompt() -> String:
	if cultivo == null or not cultivo.plantado:
		return "Incienso raro agotado" if raro else "Incienso agotado"
	var dia := _dia_actual()
	if cultivo.listo(dia):
		return "Cosechar incienso raro" if raro else "Cosechar incienso"
	var faltan := cultivo.dias_restantes(dia)
	return "Incienso (faltan %d d)" % faltan

func obtener_razon_no_disponible() -> String:
	if estado != EST_DISPONIBLE:
		var faltan: int = IncenseCultivation.DIAS_COSECHA
		if dia_agotado != -1:
			faltan = maxi(0, IncenseCultivation.DIAS_COSECHA - (_dia_actual() - dia_agotado))
		return "Agotado (renueva en %d d)" % faltan
	return ""

func requisitos_cumplidos(_jugador) -> bool:
	return estado == EST_DISPONIBLE and cultivo != null and cultivo.plantado

func interactuar(_datos: Dictionary) -> void:
	var dia := _dia_actual()
	if not cultivo.listo(dia):
		# Guard C4 en la cadena E: E antes de tiempo no cosecha nada.
		print("[M163] Incienso no listo: faltan %d dias" % cultivo.dias_restantes(dia))
		return
	var cantidad: int = cultivo.cosechar(dia)
	if cantidad <= 0:
		return
	var item_id := "incense_rare" if raro else "incense"
	var inv = get_node_or_null("/root/Inventario")
	if inv != null and inv.has_method("add_item"):
		inv.add_item(item_id, cantidad)
	estado = EST_NO_DISPONIBLE
	dia_agotado = dia
	print("[M163] Cosechaste %dx %s" % [cantidad, item_id])

# ── Renovacion (C8) ───────────────────────────────────────────

## true si el punto esta agotado y ya pasaron los 3 dias de renovacion.
func listo_para_renovar(dia_ahora: int) -> bool:
	if estado == EST_DISPONIBLE:
		return false
	if dia_agotado == -1:
		return false
	return dia_ahora - dia_agotado >= IncenseCultivation.DIAS_COSECHA

## Rehabilita el punto si pasaron los 3 dias. Devuelve true si renovo.
func renovar(dia_ahora: int) -> bool:
	if not listo_para_renovar(dia_ahora):
		return false
	estado = EST_DISPONIBLE
	dia_agotado = -1
	cultivo.plantar(dia_ahora)
	return true

# ── Helpers ───────────────────────────────────────────────────

func _dia_actual() -> int:
	var ml = Engine.get_main_loop()
	if ml == null:
		return 0
	var gt = ml.root.get_node_or_null("GameTime")
	if gt != null and gt.has_method("dia_absoluto"):
		return int(gt.dia_absoluto())
	return 0
