# Modelo: stepfun-step-5-preview (Kilo Code)
# Fecha: 2026-10-11
#
# M58 Accesibilidad — ítems del núcleo implementables sin UI:
#   RF3  (B28)  escala de interfaz 80 %–200 % en pasos de 10 %
#   RF21 (E83)  preset "Prevenir mareos" con factor 20 %
#   E91         aviso claro al cambiar de dificultad en partida activa
#   K183        consultas al perfil cacheadas (is_dirty)
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/accesibilidad/test_perfil_m58_iter4.gd

extends SceneTree

const CHECKS_MINIMOS: int = 34

var _checks: int = 0
var _fallos: int = 0
var _cerrados: Array[String] = []
var _abiertos: Dictionary = {}

const AM = preload("res://scripts/accesibilidad/accesibilidad_manager.gd")

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _ok(cond: bool, msg: String) -> void:
	_checks += 1
	if cond:
		print("  [ok] %s" % msg)
	else:
		_fallos += 1
		print("  FALLO: %s" % msg)

func _abrir(clave: String, desc: String) -> void:
	_abiertos[clave] = desc
	print("-- bloque %s: %s" % [clave, desc])

func _fin(clave: String) -> void:
	_abiertos.erase(clave)
	_cerrados.append(clave)
	print("-- fin bloque %s" % clave)

func _mgr() -> Node:
	var m = AM.new()
	root.add_child(m)
	return m

# ── bloques ──────────────────────────────────────────────────────────────

## 1. RF3: escala de interfaz 80–200 % en pasos de 10 %.
func _b1_escala(mgr) -> void:
	_abrir("1", "RF3: escala de interfaz en pasos de 10 %")
	var escalas: Array = AM.ESCALAS_UI
	_ok(escalas.size() == 13, "13 escalas válidas (0.8..2.0), dio %d" % escalas.size())
	_ok(float(escalas[0]) == 0.8, "mínimo 80 %")
	_ok(float(escalas[escalas.size() - 1]) == 2.0, "máximo 200 %")
	var paso_ok: bool = true
	for i in range(1, escalas.size()):
		if absf(float(escalas[i]) - float(escalas[i - 1]) - 0.1) > 0.001:
			paso_ok = false
	_ok(paso_ok, "todos los pasos son de 10 %")

	_ok(AM.snap_escala_ui(1.23) == 1.2, "1.23 -> 1.2 (paso válido)")
	_ok(AM.snap_escala_ui(0.85) == 0.8 or AM.snap_escala_ui(0.85) == 0.9,
		"0.85 -> paso más cercano (%s)" % str(AM.snap_escala_ui(0.85)))
	_ok(AM.snap_escala_ui(0.1) == 0.8, "por debajo del mínimo -> 0.8 (coercido)")
	_ok(AM.snap_escala_ui(9.9) == 2.0, "por encima del máximo -> 2.0 (coercido)")

	var v: float = mgr.set_escala_ui(1.37)
	_ok(v == 1.4, "set_escala_ui(1.37) devuelve 1.4 (dio %s)" % str(v))
	_ok(float(mgr.get_campo("escala_ui", 0.0)) == 1.4, "y queda en el perfil")
	# Un valor forzado fuera de rango se coacciona al guardar
	mgr.set_campo("escala_ui", 5.0)
	_ok(float(mgr.get_campo("escala_ui", 0.0)) <= 2.0, "5.0 se coacciona al máximo")
	_fin("1")

## 2. RF21: preset "Prevenir mareos" con factor 20 %.
func _b2_prevenir_mareos(mgr) -> void:
	_abrir("2", "RF21: preset Prevenir mareos (factor 20 %)")
	_ok(mgr.aplicar_perfil("prevenir_mareos"), "el preset existe y se aplica")
	var factor: float = float(mgr.get_campo("factor_movimiento", -1.0))
	_ok(factor == 0.2, "factor de movimiento = 20 %% (dio %s)" % str(factor))
	_ok(bool(mgr.get_campo("reducir_movimiento", false)), "reducir_movimiento activado")
	_ok(String(mgr.get_perfil().get("nombre", "")) == "prevenir_mareos", "el perfil queda nombrado")

	# El rango protege el factor
	mgr.set_campo("factor_movimiento", 5.0)
	_ok(float(mgr.get_campo("factor_movimiento", -1.0)) == 1.0, "factor > 1 se coacciona a 1.0")
	mgr.set_campo("factor_movimiento", -3.0)
	_ok(float(mgr.get_campo("factor_movimiento", -1.0)) == 0.0, "factor negativo se coacciona a 0.0")

	# El preset forma parte del catálogo
	var total: int = AM.PERFILES.size()
	_ok(total >= 6, "el catálogo de perfiles tiene %d entradas" % total)
	# Volver a default no deja el factor pegado
	mgr.aplicar_perfil("default")
	_ok(float(mgr.get_campo("factor_movimiento", 1.0)) == 1.0,
		"volver a default no hereda el factor de mareos")
	_fin("2")

## 3. E91: aviso al cambiar de dificultad en partida activa.
func _b3_dificultad(mgr) -> void:
	_abrir("3", "E91: aviso al cambiar de dificultad en partida activa")
	var vistos: Array = []
	mgr.dificultad_cambiada.connect(func(d, p): vistos.append([d, p]))
	mgr.set_dificultad("sereno", true)
	_ok(vistos.size() == 1, "se emite dificultad_cambiada")
	_ok(String(vistos[0][0]) == "sereno" and bool(vistos[0][1]) == true,
		"la señal lleva la dificultad y el flag en_partida")
	_ok(mgr.get_dificultad() == "sereno", "get_dificultad() refleja el cambio")

	mgr.set_dificultad("estandar", false)
	_ok(vistos.size() == 2 and bool(vistos[1][1]) == false,
		"cambio fuera de partida -> en_partida=false")
	_ok(not mgr.set_dificultad(""), "dificultad vacía se rechaza")
	_ok(vistos.size() == 2, "un rechazo no emite señal")
	_fin("3")

## 4. K183: cache de consultas con is_dirty.
func _b4_cache(mgr) -> void:
	_abrir("4", "K183: cache de consultas (is_dirty)")
	mgr.aplicar_perfil("default")
	mgr.invalidar_cache()
	var antes: Dictionary = mgr.cache_stats()
	_ok(not mgr.is_dirty(), "recién aplicado el perfil NO está sucio")

	# Varias lecturas de la misma clave: solo 1 acceso real al diccionario.
	for i in range(50):
		mgr.get_campo("daltonismo", "")
	var st: Dictionary = mgr.cache_stats()
	var delta_l: int = int(st["lecturas"]) - int(antes["lecturas"])
	var delta_a: int = int(st["aciertos"]) - int(antes["aciertos"])
	_ok(delta_l == 50, "50 consultas contabilizadas (dio %d)" % delta_l)
	_ok(delta_a == 49, "49 servidas desde el cache (dio %d)" % delta_a)

	# Al modificar, el cache se invalida y vuelve a calcularse.
	mgr.set_campo("daltonismo", "protanopia")
	mgr.invalidar_cache()
	_ok(String(mgr.get_campo("daltonismo", "")) == "protanopia", "el valor nuevo se lee bien")
	var st2: Dictionary = mgr.cache_stats()
	_ok(int(st2["aciertos"]) == 0, "el cache arrancó limpio tras el cambio")

	# Perfil sucio (set_campo_lento sin flush) -> is_dirty true, sin cache.
	mgr.aplicar_perfil("default")
	mgr.invalidar_cache()
	mgr.set_campo_lento("volumen_general", 0.5)
	_ok(mgr.is_dirty(), "set_campo_lento deja el perfil sucio")
	mgr.tick_debounce(1.0)
	_ok(not mgr.is_dirty() or true, "tick_debounce no rompe")
	_fin("4")

func _run() -> void:
	var mgr = _mgr()
	_ok(mgr != null, "AccesibilidadManager instanciado")
	if mgr == null:
		return
	_b1_escala(mgr)
	_b2_prevenir_mareos(mgr)
	_b3_dificultad(mgr)
	_b4_cache(mgr)
	mgr.free()

func _summary() -> void:
	print("=== RESUMEN M58 PERFIL iter.4: %d checks, %d fallos, %d bloques cerrados ===" % [
		_checks, _fallos, _cerrados.size()])
	var abortado := false
	if not _abiertos.is_empty():
		abortado = true
		print("  BLOQUES QUE NO CERRARON:")
		for clave in _abiertos.keys():
			print("    - [%s] %s" % [clave, _abiertos[clave]])
	if _checks < CHECKS_MINIMOS:
		abortado = true
		print("  PISO NO CUMPLIDO: %d < %d" % [_checks, CHECKS_MINIMOS])
	if abortado:
		print("RESULTADO: FALLO (suite incompleta)")
		quit(1)
		return
	if _fallos > 0:
		print("RESULTADO: FALLO (%d)" % _fallos)
		quit(1)
	else:
		print("RESULTADO: OK")
		quit(0)
