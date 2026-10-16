# Modelo: Step-5-WorkBuddy
# Plataforma: WorkBuddy
# Fecha: 2026-10-16
#
# M31 lote 2 (msg 51 del director De-Director V4.1, 2026-10-15): genera
# season_mod.tres, la data estacional que faltaba (diseno sec. 4: "4
# multiplicadores por estacion (M29) aplicados a ambas curvas"; item E.15
# del 05-Checklist, hoy [?] por "NO existe; curva unica anual").
# Patron de gen_curvas.gd: valida ANTES de guardar y aborta con quit(1).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/world/gen_season_mod.gd
extends SceneTree

const RUTA: String = "res://data/light/season_mod.tres"

# estacion -> multiplicador. Indices segun game_clock.gd NOMBRES_ESTACIONES:
# 0 Primavera, 1 Verano, 2 Otono, 3 Invierno.
# Los valores son DECISION DE IMPLEMENTACION (el diseno sec. 4 no fija cifras):
# verano algo mas luminoso, invierno algo menos, primavera neutro. La regla de
# oro anti-oscuridad (piso 0.15, diseno sec. 7) la garantiza el clamp de
# day_night_cycle._aplicar_iluminacion, NO estos multiplicadores.
const MULTIS := [1.0, 1.1, 0.95, 0.85]
const CANTIDAD_ESTACIONES := 4

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var c := Curve.new()
	c.min_value = 0.5
	c.max_value = 1.5
	c.min_domain = 0.0
	c.max_domain = 3.0
	for i in range(MULTIS.size()):
		c.add_point(Vector2(float(i), float(MULTIS[i])))
	if not _validar(c):
		quit(1)
		return
	var err := ResourceSaver.save(c, RUTA)
	print("season_mod.tres -> err=%d (%d puntos, dominio %.0f-%.0f)" % [err, c.point_count, c.min_domain, c.max_domain])
	quit(1 if err != OK else 0)

func _validar(c: Curve) -> bool:
	var ok := true
	if c.point_count != CANTIDAD_ESTACIONES:
		print("FALLO: se esperaban %d puntos (uno por estacion), hay %d" % [CANTIDAD_ESTACIONES, c.point_count])
		ok = false
	if absf(c.max_domain - 3.0) > 0.001 or absf(c.min_domain) > 0.001:
		print("FALLO: dominio debe ser 0-3 (indices de estacion), es %.1f-%.1f" % [c.min_domain, c.max_domain])
		ok = false
	for i in range(CANTIDAD_ESTACIONES):
		var v: float = c.sample(float(i))
		if v < 0.5 or v > 1.5:
			print("FALLO: multiplicador de estacion %d fuera de rango (%.2f)" % [i, v])
			ok = false
		if absf(v - float(MULTIS[i])) > 0.001:
			print("FALLO: estacion %d deberia ser %.2f y sample da %.2f" % [i, float(MULTIS[i]), v])
			ok = false
	return ok
