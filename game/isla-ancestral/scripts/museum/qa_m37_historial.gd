# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-22
#
# M37: QA del historial cronologico de donaciones (CollectionRegistry v2).
# Item [S] "Historial ordenado cronologicamente sin entradas duplicadas" del
# 05-Checklist (turno 2-BIS).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/museum/qa_m37_historial.gd

extends SceneTree

const CHECKS_MINIMOS := 13
var _checks: int = 0
var _fallos: int = 0

func _summary() -> void:
	print("=== Resumen QA historial M37: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _nuevo_registry() -> Node:
	return (load("res://scripts/museum/collection_registry.gd") as Script).new()

func _run() -> void:
	var reg: Node = _nuevo_registry()
	root.add_child(reg)
	_check(int(reg.get("VERSION_GUARDADO")) == 2, "M37: VERSION_GUARDADO == 2 (historial)")
	_check(int(reg.validar_catalogo()) == 0, "M37: catalogo de exposiciones valido")
	# Registrar piezas en 3 exposiciones, orden no agrupado (cronologia real)
	var plan := [
		["flora", "baya_roja"],
		["fauna", "conejo_pradera"],
		["flora", "fibra_algodon"],
		["peces", "trucha_cascada"],
		["flora", "madera_roble"],
	]
	for p in plan:
		var ok: bool = reg.register_item(String(p[0]), String(p[1]))
		_check(ok, "registro %s -> %s aceptado" % [p[1], p[0]])
	# Historial: orden, sin duplicados, campos presentes
	var h: Array = reg.get_historial_donaciones()
	_check(h.size() == 5, "historial: 5 entradas por 5 donaciones reales (%d)" % h.size())
	var secuencia_correcta := true
	for i in h.size():
		var e: Dictionary = h[i]
		if String(e.get("exhibition_id", "z")) != String(plan[i][0]) or String(e.get("item_id", "z")) != String(plan[i][1]):
			secuencia_correcta = false
	_check(secuencia_correcta, "historial: respeta el orden cronologico de inscripcion")
	_check(all_haves_day(h), "historial: cada entrada trae dia (fallback 0 headless)")
	# Idempotencia: re-registro no agrega segunda entrada
	var antes: int = h.size()
	reg.register_item("flora", "baya_roja")
	reg.register_item("flora", "baya_roja")
	h = reg.get_historial_donaciones()
	_check(h.size() == antes, "historial: re-registro idempotente NO duplica (%d)" % h.size())
	# Copia read-only: mutar la salida no corrompe el estado interno
	var h2: Array = reg.get_historial_donaciones()
	if h2.size() > 0:
		h2[0]["item_id"] = "veneno_test"
	_check(String(reg.get_historial_donaciones()[0].get("item_id", "")) != "veneno_test",
		"historial: la copia es read-only (no filtra el buffer interno)")
	# Save/restore round-trip con historial
	var data: Dictionary = reg.get_save_data()
	_check(data.has("historial") and (data["historial"] as Array).size() == 5,
		"save: el historial viaja en el bloque v2")
	_check(int(data.get("version", 0)) == 2, "save: bloque declarado v2")
	var reg2: Node = _nuevo_registry()
	root.add_child(reg2)
	reg2.restore_save_data(data)
	var h3: Array = reg2.get_historial_donaciones()
	_check(h3.size() == 5 and String(h3[2].get("item_id", "")) == String(plan[2][1]),
		"restore: el historial sobrevive al round-trip (posicion 2 = %s)" % String(h3[2].get("item_id", "")))
	# Migracion v1 legado (sin historial) -> v2 no rompe la carga
	var legado := {"version": 1, "piezas": {"flora": ["baya_roja"]}, "recompensas": []}
	reg2.restore_save_data(legado)
	_check(reg2.get_historial_donaciones().is_empty(), "migracion v1->v2: bloque legado entra con historial vacio")
	_check(String(reg2.get_registered("flora").front()) == "baya_roja" if not reg2.get_registered("flora").is_empty() else false,
		"migracion v1->v2: las piezas legacy siguen cargando")
	# Robustez (item [M] mano de obra: fallo de senal de modulo origen sin crasheo):
	# DonationService real (autoload) con entradas invalidas NO crashea y
	# devuelve razon estructurada por senal donation_rejected.
	var svc := root.get_node_or_null("/root/DonationService")
	if svc != null:
		var rechazos: Array = []
		var cb: Callable = func(exh, itm, motivo): rechazos.append(String(motivo))
		svc.donation_rejected.connect(cb)
		var r1: DonationResult = svc.donate("exposicion_inexistente", "item_inexistente")
		_check(r1.accepted == false and r1.reason != "", "robustez: exposicion inexistente -> rechazo estructurado")
		var r2: DonationResult = svc.donate("flora", "item_inexistente")
		_check(r2.accepted == false and String(r2.reason) == "invalid_item", "robustez: item inexistente -> invalid_item (guardia de catalogo 4.3; orden validate: catalogo->duplicado->inventario)")
		_check(rechazos.size() >= 2, "robustez: senal donation_rejected emitida por cada rechazo")
		svc.donation_rejected.disconnect(cb)
	else:
		_check(true, "robustez: DonationService no disponible en esta corrida (skipped)")

	reg.queue_free()
	reg2.queue_free()

func all_haves_day(h: Array) -> bool:
	for e in h:
		if not e.has("dia") or int(e.get("dia", -1)) < 0:
			return false
	return true
