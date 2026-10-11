extends SceneTree

## Sonda BUG-119 — MEDICIÓN temporal (NO es fix, NO es suite: el discovery del
## runner solo toca archivos que empiezan con "test_", este empieza con _).
## Mide en un arranque --script REAL (mismo camino de bootstrap que el runner):
##   1. frame/t en que TerrainLocator._terrain queda resuelto
##   2. frame/t en que get_height(2320, 2300) deja de devolver -1 (+ valor)
##   3. frame/t en que el current_scene monta (bootstrap.change_scene_to_file)
##   4. frame/t en que IncenseSpawner pasa de 0 a N puntos (+ fallas acumuladas)
##   5. frame/t en que el chaman sale del fallback y=35 (reposicion)
## Uso: godot --headless --path <proyecto> --script res://tests/_sonda_bug119.gd
## Evidencia de corridas: TEMP/opencode/sonda119_*_{out,err}.txt

var _frame := 0
var _t0 := 0
var _vistos := {}
var _fin := false

func _initialize() -> void:
	_t0 = Time.get_ticks_msec()
	print("[SONDA-119] t=0 arranque --script (mismo camino que el runner)")

func _process(_delta: float) -> bool:
	if _fin:
		return false
	_frame += 1
	var ms := Time.get_ticks_msec() - _t0
	var loc = root.get_node_or_null("TerrainLocator")
	_ev("locator", loc != null, ms, "")
	if loc != null:
		var t = loc.get("_terrain")
		var terreno := t != null and is_instance_valid(t)
		_ev("terreno_resuelto", terreno, ms, "")
		var h := -999
		if loc.has_method("get_height"):
			h = int(loc.get_height(2320, 2300))
		_ev("altura_ok", h >= 0, ms, "h=%d" % h)
		if h >= 0:
			_vistos["altura_final"] = h
	var esc = current_scene
	if esc != null:
		_ev("escena_montada", true, ms, str(esc.scene_file_path))
		var sp = esc.get_node_or_null("IncenseSpawner")
		if sp != null and sp.has_method("puntos"):
			var n: int = sp.puntos().size()
			_vistos["puntos_final"] = n
			_vistos["fallas_final"] = sp.fallas_altura()
			_ev("spawner_puntos", n > 0, ms, "puntos=%d fallas=%d" % [n, sp.fallas_altura()])
		var ch = esc.get_node_or_null("ShamanMonte")
		if ch != null:
			_vistos["chaman_final"] = ch.global_position.y
			_ev("chaman_no_fallback", absf(ch.global_position.y - 35.0) > 0.01, ms,
					"y=%.1f" % ch.global_position.y)
	if _vistos.size() >= 7 or ms > 30000:
		_resumen(ms)
		_fin = true
		quit(0)
	return false

## Imprime la transicion false->true de cada condicion UNA sola vez.
func _ev(clave: String, cond: bool, ms: int, extra: String) -> bool:
	if cond and not _vistos.has(clave):
		_vistos[clave] = ms
		print("[SONDA-119] frame=%d t=%dms %s %s" % [_frame, ms, clave, extra])
		return true
	return false

func _resumen(ms: int) -> void:
	print("[SONDA-119] RESUMEN frames=%d t=%dms" % [_frame, ms])
	for k in ["locator", "escena_montada", "terreno_resuelto", "altura_ok",
			"spawner_puntos", "chaman_no_fallback"]:
		if _vistos.has(k):
			print("[SONDA-119]   %s -> t=%dms" % [k, _vistos[k]])
		else:
			print("[SONDA-119]   %s -> NUNCA" % k)
	print("[SONDA-119]   altura_final=%s puntos=%s fallas=%s chaman_y=%s" % [
			str(_vistos.get("altura_final", "n/d")), str(_vistos.get("puntos_final", "n/d")),
			str(_vistos.get("fallas_final", "n/d")), str(_vistos.get("chaman_final", "n/d"))])
