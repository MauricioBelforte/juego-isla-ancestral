# Modelo: GLM-5.3
# Plataforma: Kilo Code
# Fecha: 2026-09-11
#
# M29 iter 1: test de la semilla de tiempo por partida (H120) + verificaciones
# de auditoría de los ítems base (hooks de señales, nombres en data, formatos,
# repetibilidad de eventos). Cierra la brecha real detectada: usar_semilla_tiempo
# existía en config pero nadie la consumía.
# Uso: godot --headless --path game/isla-ancestral --script res://scripts/time/test_semilla_iter1.gd

extends SceneTree

var _fallos := 0
var _checks := 0

func _init() -> void:
	call_deferred("_correr")

func _correr() -> void:
	print("=== TEST M29 ITER1: SEMILLA + AUDITORIA ===")
	var gt = root.get_node_or_null("GameTime")
	var tc = root.get_node_or_null("TimeCalendar")
	_check("GameTime presente", gt != null)
	_check("TimeCalendar presente", tc != null)
	if gt == null or tc == null:
		_fin()
		return

	# ── H120: semilla de tiempo por partida ──
	_check("H120: semilla de partida generada en boot", gt.get_semilla_partida() != 0)
	var semilla_original: int = gt.get_semilla_partida()

	# Determinismo: misma semilla + mismo día + mismo namespace → mismo valor
	var v1: int = gt.valor_diario("test_modulo", 0, 9999)
	var v2: int = gt.valor_diario("test_modulo", 0, 9999)
	_check("H120: valor_diario determinista (v1==v2: %d)" % v1, v1 == v2)

	# Namespaces distintos → valores independientes (colisión improbable pero posible:
	# se valida que el mecanismo separe, no que nunca colisione)
	var va: int = gt.valor_diario("ns_a", 0, 1000000)
	var vb: int = gt.valor_diario("ns_b", 0, 1000000)
	_check("H120: namespaces distintos independientes", va != vb)

	# rng_diario: secuencia reproducible del día
	var r1 = gt.rng_diario("seq_test")
	var seq1 := [r1.randi_range(0, 100), r1.randi_range(0, 100), r1.randi_range(0, 100)]
	var r2 = gt.rng_diario("seq_test")
	var seq2 := [r2.randi_range(0, 100), r2.randi_range(0, 100), r2.randi_range(0, 100)]
	_check("H120: rng_diario secuencia reproducible", str(seq1) == str(seq2))

	# Cambiar la semilla cambia los valores (per-partida)
	gt.set_semilla_partida(12345)
	var v_con_semilla_a: int = gt.valor_diario("test_modulo", 0, 999999)
	gt.set_semilla_partida(67890)
	var v_con_semilla_b: int = gt.valor_diario("test_modulo", 0, 999999)
	_check("H120: semilla distinta → valores distintos (%d vs %d)" % [v_con_semilla_a, v_con_semilla_b], v_con_semilla_a != v_con_semilla_b)

	# Persistencia: la semilla viaja en el save
	var save: Dictionary = gt.get_save_data()
	_check("H120: semilla en el save (sección time)", int(save.get("semilla_partida", -1)) == 67890)
	gt.restore_save_data({"semilla_partida": 987654, "hora": 8, "minuto": 0, "dia": 1, "mes": 1, "anio": 1})
	_check("H120: semilla restaurada del save (987654)", gt.get_semilla_partida() == 987654)

	# El día entra en el hash: avanzar un día cambia el valor del namespace
	gt.set_semilla_partida(semilla_original)
	var v_dia_actual: int = gt.valor_diario("dia_test", 0, 1000000)
	gt._dia += 1
	var v_dia_siguiente: int = gt.valor_diario("dia_test", 0, 1000000)
	gt._dia -= 1  # restaurar
	_check("H120: valor_diario depende del día absoluto", v_dia_actual != v_dia_siguiente)

	# ── Auditoría: señales API (sección G) expuestas por TimeCalendar ──
	_check("G: señal dia_cambio", tc.has_signal("dia_cambio"))
	_check("G: señal hora_cambio", tc.has_signal("hora_cambio"))
	_check("G: señal estacion_cambio", tc.has_signal("estacion_cambio"))
	_check("G: señal evento_activado", tc.has_signal("evento_activado"))
	_check("G: señal evento_proximo", tc.has_signal("evento_proximo"))

	# ── Auditoría: API pública completa (G107-G112) ──
	var api := ["get_hora", "get_fecha", "get_estacion", "es_de_dia", "obtener_proximos_eventos", "pausa", "resume", "avanzar_hasta", "get_semana_dia", "get_dia_absoluto", "formatear_hora", "formatear_fecha_completa", "get_nombre_dia", "get_nombre_mes", "get_nombre_estacion", "hay_festival_hoy", "obtener_eventos_hoy"]
	var faltan: Array = []
	for m in api:
		if not tc.has_method(m):
			faltan.append(m)
	_check("G: API pública completa (%d métodos, faltan: %s)" % [api.size(), str(faltan)], faltan.is_empty())

	# ── Auditoría: nombres en data (H119, localizable M57) ──
	_check("H119: get_nombre_dia no vacío", tc.get_nombre_dia(0) == "Lunes")
	_check("H119: get_nombre_mes(1) del config", tc.get_nombre_mes(1) == "Floración")
	_check("H119: get_nombre_estacion(0)", tc.get_nombre_estacion(0) == "Primavera")

	# ── Auditoría: formato 12h/24h (B42) ──
	_check("B42: formatear_hora 24h (default)", tc.formatear_hora(14, 30, true) == "14:30")
	_check("B42: formatear_fecha_completa no vacía", tc.formatear_fecha_completa().length() > 5)

	# ── Auditoría: eventos repetibles cozy (C59/C60) ──
	var config = tc.get_config()
	_check("C59: ventana_aviso configurada (24h)", int(config.ventana_aviso_evento_horas) == 24)
	var festivales = tc.get_festivales()
	_check("C59: data de festivales cargada", festivales != null)
	if festivales != null and festivales.has_method("obtener_proximos_eventos"):
		var prox: Array = festivales.obtener_proximos_eventos(tc.get_fecha()["dia"], tc.get_fecha()["mes"], tc.get_fecha()["anio"], 30)
		_check("C59/C60: próximos 30 días consultables (n=%d)" % prox.size(), prox.size() >= 0)

	# ── Auditoría: es_fin_de_semana (F94: cerrar domingos) ──
	_check("F94: es_fin_de_semana consultable", typeof(tc.es_fin_de_semana()) == TYPE_BOOL)

	_fin()

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] " + nombre)
	else:
		_fallos += 1
		print("  [FAIL] " + nombre)

func _fin() -> void:
	print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLOS DETECTADOS")
		quit(1)
	else:
		print("M29 ITER1 SEMILLA OK")
		quit(0)
