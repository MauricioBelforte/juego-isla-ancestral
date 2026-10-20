# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-19
#
# M62 / M27: ITEM 16 de la COLA V3 (Log 2021).
#   "Preset Baja en isla pequeña (M27): carga priorizada y descarga agresiva de viajeros"
#
# El Log 2019 midio que 2 de las 3 sub-partes ya existian (cola priorizada y
# `debe_precargar` con tope por parametro) y que faltaban: (a) el tope derivado
# del preset y (b) la descarga agresiva de islas viajeras. Este test verifica
# ambas sobre el codigo real de M27, sin dobles.
#
# ⚠️ El preset se INYECTA: M27 no lee M90 ni M62. `baja` = 1 isla en memoria
# (premisa del item); `media`/`alta` conservan el tope de diseño (2).
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_m62_preset_baja_m27.gd

extends SceneTree

const MODULO := "M62 preset baja M27"
const CHECKS_MINIMOS := 13   # MEDIDO en verde (13 checks x3), no estimado

var _checks := 0
var _fallos := 0


func _initialize() -> void:
	call_deferred("_correr")


func _check(nombre: String, ok: bool, detalle: String = "") -> void:
	_checks += 1
	if not ok:
		_fallos += 1
		print("  [FALL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])
	else:
		print("  [ok]   %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])


## Isla mínima válida para la vista del guardián.
func _isla(id: String, cx: float, cargada: bool, uso: int, visitada: bool = false) -> Dictionary:
	return {
		"id": StringName(id),
		"ancla": Vector3(cx, 0.0, 0.0),
		"centro": Vector3(cx, 0.0, 0.0),
		"radio": 400,
		"altura_min": -4.0,
		"altura_max": 60.0,
		"playa_ancho": 30.0,
		"anillo": 2,
		"es_flotante": false,
		"es_secreta": false,
		"tiene_ancla": true,
		"descubierta": visitada,
		"visitada": visitada,
		"desbloqueada": true,
		"punto_llegada": Vector3(cx, 1.0, 0.0),
		"punto_partida": Vector3(cx, 1.0, 0.0),
		"cargada": cargada,
		"ultimo_uso": uso,
	}


func _vista(cargadas: Array[String]) -> Dictionary:
	var v: Dictionary = {}
	v["aurora"] = _isla("aurora", 0.0, cargadas.has("aurora"), 1, true)
	v["isla_sur"] = _isla("isla_sur", 800.0, cargadas.has("isla_sur"), 5, true)
	v["isla_norte"] = _isla("isla_norte", -400.0, cargadas.has("isla_norte"), 3)
	v["isla_lejos"] = _isla("isla_lejos", 9000.0, cargadas.has("isla_lejos"), 2)
	return v


func _solo_intocables(cargadas: Array[String], intocables: Array) -> bool:
	for id in cargadas:
		if not intocables.has(id):
			return false
	return true


func _correr() -> void:
	await process_frame
	print("=== %s ===" % MODULO)

	# ── A: tope por preset ──
	var baja: IslandTravelGuard = IslandTravelGuard.new()
	baja.configurar(_vista([]), {"preset": "baja"})
	var media: IslandTravelGuard = IslandTravelGuard.new()
	media.configurar(_vista([]), {"preset": "media"})
	var raro: IslandTravelGuard = IslandTravelGuard.new()
	raro.configurar(_vista([]), {"preset": "ultra"})
	_check("A: preset baja = 1 isla en memoria", baja.max_islas_en_memoria() == 1,
		"tope=%d" % baja.max_islas_en_memoria())
	_check("A: preset media = 2 islas (tope de diseño)", media.max_islas_en_memoria() == 2,
		"tope=%d" % media.max_islas_en_memoria())
	_check("A: preset desconocido cae a media (no a 0)", raro.max_islas_en_memoria() == 2,
		"preset=%s tope=%d" % [raro.preset(), raro.max_islas_en_memoria()])

	# ── B: descarga agresiva en BAJA ──
	var g: IslandTravelGuard = IslandTravelGuard.new()
	g.configurar(_vista(["aurora", "isla_sur", "isla_norte"]), {"preset": "baja"})
	var antes: Dictionary = g.snapshot_estado()
	var res: Dictionary = g.descarga_agresiva_viajeros("isla_sur", null)
	var despues: Dictionary = g.snapshot_estado()
	_check("B: descarga las viajeras (3 cargadas -> queda 1 + actual)",
		int((res["descargadas"] as Array).size()) == 1,
		"descargadas=%s" % str(res["descargadas"]))
	_check("B: la isla actual NUNCA se descarga", not (res["descargadas"] as Array).has("isla_sur"))
	_check("B: la isla principal NUNCA se descarga", not (res["descargadas"] as Array).has("aurora"))
	_check("B: el progreso (descubierta/visitada) se preserva",
		bool(res["estado_preservado"]) and str(antes) == str(despues))
	_check("B: no queda NINGUNA isla viajera cargada",
		_solo_intocables(g.islas_cargadas(), ["aurora", "isla_sur"]),
		"cargadas=%s" % str(g.islas_cargadas()))

	# ── C: en MEDIA, con 2 cargadas no hay nada que descargar ──
	var gm: IslandTravelGuard = IslandTravelGuard.new()
	gm.configurar(_vista(["aurora", "isla_sur"]), {"preset": "media"})
	var resm: Dictionary = gm.descarga_agresiva_viajeros("isla_sur", null)
	_check("C: media con 2 cargadas no descarga nada",
		(resm["descargadas"] as Array).is_empty(),
		"descargadas=%s" % str(resm["descargadas"]))
	_check("C: media conserva las 2 islas", gm.islas_cargadas().size() == 2,
		"cargadas=%d" % gm.islas_cargadas().size())

	# ── D: carga priorizada (sub-parte 1 del item) ──
	var gb: IslandTravelGuard = IslandTravelGuard.new()
	gb.configurar(_vista([]), {"preset": "baja"})
	var op_baja: Array[String] = gb.debe_precargar(Vector3.ZERO, "aurora")
	var gmed: IslandTravelGuard = IslandTravelGuard.new()
	gmed.configurar(_vista([]), {"preset": "media"})
	var op_media: Array[String] = gmed.debe_precargar(Vector3.ZERO, "aurora", 2)
	_check("D: en baja la precarga por defecto se limita a 1 isla",
		op_baja.size() == 1, "ops=%s" % str(op_baja))
	_check("D: la isla elegida es la MÁS CERCANA (carga priorizada)",
		not op_baja.is_empty() and op_baja[0] == "isla_norte", "ops=%s" % str(op_baja))
	_check("D: con presupuesto explícito 2 devuelve 2 y en orden de cercanía",
		op_media.size() == 2 and op_media[0] == "isla_norte" and op_media[1] == "isla_sur",
		"ops=%s" % str(op_media))

	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FALLO] solo %d checks (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con codigo 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — todos los checks pasaron" % MODULO)
		quit(0)
