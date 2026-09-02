# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01 (iter. 1-2) / 2026-09-02 (iter. 3)
#
# M37: Museos y Colecciones — DonationService (autoload "DonationService")
# Valida y ejecuta donaciones (03-Diseno §2.4, §4.1-§4.3):
#  - validate/donate con DonationResult estructurado (reason: "", "duplicate",
#    "not_owned", "wrong_exhibition", "invalid_item").
#  - Donate consume el item del inventario (M14) SOLO si toda la validación pasa
#    (§4.3.3: rechazo = inventario intacto).
#  - Recompensa de exposición al completarse: única e idempotente (§4.2).
#  - Señales tipadas para M55/UI: donation_accepted/donation_rejected/reward_granted.
# Iter. 3 (glm-5.3-flash 2026-09-02, Log 542):
#  - Estadística "donaciones_museo" en el perfil M71 al aceptar (duck-typed)
#    — el evaluador M71 puede condicionar hitos/logros sobre ella.
#  - Registro en el diario M55 vía EventBus.diary.entrada_nueva (duck-typed).
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).
extends Node

signal donation_accepted(exhibition_id: String, item_id: String)
signal donation_rejected(exhibition_id: String, item_id: String, reason: String)
signal reward_granted(exhibition_id: String, reward_item_id: String)

## DonationResult vive en su propio archivo (class_name global, diseño §5)
## para que tests y UI puedan tipar el resultado.


func donate(exhibition_id: String, item_id: String) -> DonationResult:
	var res := validate(exhibition_id, item_id)
	if not res.accepted:
		donation_rejected.emit(exhibition_id, item_id, res.reason)
		return res
	# §4.1.5: consumo del item solo tras la validación completa
	var inv := get_node_or_null("/root/Inventario")
	if inv == null or not inv.remover_items({item_id: 1}):
		var fail := DonationResult.new(exhibition_id, item_id, false, "not_owned")
		donation_rejected.emit(exhibition_id, item_id, fail.reason)
		return fail
	# §4.1.6: registro de la pieza en el Registry
	var registry := get_node_or_null("/root/CollectionRegistry")
	if registry == null:
		inv.agregar_items({item_id: 1})  # rollback cozy: nunca se pierde
		var fail2 := DonationResult.new(exhibition_id, item_id, false, "invalid_item")
		return fail2
	registry.register_item(exhibition_id, item_id)
	donation_accepted.emit(exhibition_id, item_id)
	print("[M37] Donación aceptada: %s → %s" % [item_id, exhibition_id])
	# Iter. 3: estadística para M71 (evaluador de hitos/logros la consume)
	var profile := get_node_or_null("/root/PlayerProfile")
	if profile != null and profile.has_method("incrementar"):
		profile.incrementar("donaciones_museo", 1)
	# Iter. 3: registro en el diario M55 (duck-typed, no interrumpe el flujo)
	var bus := get_node_or_null("/root/EventBus")
	if bus != null and bus.diary != null and bus.diary.has_signal("entrada_nueva"):
		bus.diary.entrada_nueva.emit("donacion_" + item_id, "museo")
	# §4.2: si la exposición quedó completa, recompensa única idempotente
	if bool(registry.is_exhibition_completed(exhibition_id)) and not bool(registry.is_reward_claimed(exhibition_id)):
		var reward: String = registry.otorgar_recompensa(exhibition_id)
		if reward != "":
			reward_granted.emit(exhibition_id, reward)
			print("[M37] Exposición '%s' completada: recompensa '%s'" % [exhibition_id, reward])
	return res


## §4.1.4: item existe, es del jugador, no está registrado, pertenece a la sala
func validate(exhibition_id: String, item_id: String) -> DonationResult:
	var registry := get_node_or_null("/root/CollectionRegistry")
	if registry == null or not registry.has_method("pertenece"):
		return DonationResult.new(exhibition_id, item_id, false, "invalid_item")
	if String(item_id) == "" or not registry.pertenece(exhibition_id, item_id):
		# §4.3: pieza de otra exposición o inexistente
		if registry.exposiciones_count() > 0 and _existe_en_otra(exhibition_id, item_id, registry):
			return DonationResult.new(exhibition_id, item_id, false, "wrong_exhibition")
		return DonationResult.new(exhibition_id, item_id, false, "invalid_item")
	if registry.is_registered(exhibition_id, item_id):
		return DonationResult.new(exhibition_id, item_id, false, "duplicate")
	var inv := get_node_or_null("/root/Inventario")
	if inv == null or int(inv.count_item(item_id)) < 1:
		return DonationResult.new(exhibition_id, item_id, false, "not_owned")
	return DonationResult.new(exhibition_id, item_id, true)


func _existe_en_otra(exhibition_id: String, item_id: String, registry) -> bool:
	for id in registry._exposiciones:
		if String(id) != exhibition_id and registry.pertenece(String(id), item_id):
			return true
	return false


## Lista de items donables del inventario para una exposición (UI §4.1.2)
func get_donatable_items(exhibition_id: String) -> Array:
	var registry := get_node_or_null("/root/CollectionRegistry")
	if registry == null:
		return []
	return registry.donables_pendientes(exhibition_id)
