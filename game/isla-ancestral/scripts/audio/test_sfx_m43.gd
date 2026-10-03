# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M43: Efectos de Sonido — Test headless
# Valida: SFXManager (pool 24 voces con límite duro, prioridades,
# reproducción por superficie con variaciones, familia tonal §4).
# Exit code != 0 si falla.
#
# Lote B1 (2026-10-03, mimo-v2.6-flash-free): + _test_tonos() contra
# data/audio/sfx_tones.json (03-Diseno §4). Los checks originales se
# conservan sin tocar.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M43] Test de Efectos de Sonido ===")
	_test_surfaces()
	_test_pool()
	_test_prioridad()
	_test_tonos()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_surfaces() -> void:
	print("--- Superficies: 6 × 4 variaciones ---")
	var sfx := root.get_node_or_null("SFXManager")
	if sfx == null:
		_check("SFXManager autoload presente", false)
		_summary()
		quit(1)
		return
	_check("SFXManager autoload presente", true)
	_check("6 superficies", sfx.surfaces.size() == 6, "size=%d" % sfx.surfaces.size())
	for sup in sfx.surfaces:
		var variaciones: Array = sfx.surfaces[sup].get("variaciones", [])
		_check("superficie %s con 4 variaciones" % sup, variaciones.size() == 4, "size=%d" % variaciones.size())
	var variacion = sfx.reproducir_superficie("madera", 5)
	_check("madera devuelve variación", variacion.begins_with("golpe_madera"), "v=%s" % variacion)
	var vacio = sfx.reproducir_superficie("no_existe", 5)
	_check("superficie inexistente -> ''", vacio == "")

func _test_pool() -> void:
	print("--- Pool: 24 voces con límite duro ---")
	var sfx := root.get_node_or_null("SFXManager")
# Llenar el pool hasta 24 (1 ya existe del test de superficies, caben 23 más)
	var ok_llenar = true
	for i in range(23):
		if not sfx.reproducir("sfx_%d" % i, 1):
			ok_llenar = false
			break
	_check("pool lleno a 24 (1 existente + 23 nuevas)", ok_llenar and sfx.voces_activas() == 24, "voces=%d" % sfx.voces_activas())
	# Pool lleno: nueva voz de mayor prioridad reemplaza la menor (prioridad 1)
	var ok_alta = sfx.reproducir("sfx_importante", 10)
	_check("prioridad alta reemplaza en pool lleno", ok_alta and sfx.voces_activas() == 24, "ok=%s voces=%d" % [ok_alta, sfx.voces_activas()])
	# Pool lleno: nueva voz de menor prioridad se descarta
	var ok_baja = sfx.reproducir("sfx_trivial", 0)
	_check("prioridad baja descartada (límite duro)", ok_baja == false and sfx.voces_activas() == 24, "ok=%s voces=%d" % [ok_baja, sfx.voces_activas()])

func _test_prioridad() -> void:
	print("--- Prioridades básicas ---")
	var sfx := root.get_node_or_null("SFXManager")
	# Reset: limpiar voces viejas es complejo en test; verificamos API básica
	_check("reproducir prioridad media", sfx.reproducir("test_medio", 5) == true)
	_check("reproducir prioridad alta", sfx.reproducir("test_alto", 9) == true)

## Familia tonal (03-Diseno §4): 7 SFX de UI/eventos verificables por datos.
## NOTA: JSON.parse_string convierte todos los números a float, así que las
## comparaciones de semitonos se normalizan a int (error Godot 4 documentado).
func _a_ints(a: Array) -> Array:
	var r: Array = []
	for v in a:
		r.append(int(v))
	return r

func _test_tonos() -> void:
	print("--- Familia tonal: 7 SFX (03-Diseno §4) ---")
	var sfx := root.get_node_or_null("SFXManager")
	if sfx == null:
		_check("SFXManager presente (tonos)", false)
		return
	_check("sfx_tones.json cargado con 7 entradas", sfx.tones.size() == 7, "size=%d" % sfx.tones.size())
	_check("API tono() responde", not sfx.tono("confirmacion").is_empty())
	_check("tono inexistente -> {}", sfx.tono("no_existe").is_empty())
	_check("tonos_disponibles() == 7", sfx.tonos_disponibles().size() == 7, "n=%d" % sfx.tonos_disponibles().size())

	# Confirmación: 2 notas ascendentes con 5ª justa (7 semitonos)
	var conf: Dictionary = sfx.tono("confirmacion")
	var conf_n: Array = conf.get("notas_semitonos", [])
	_check("confirmacion: 2 notas", conf_n.size() == 2, "n=%d" % conf_n.size())
	_check("confirmacion: 5ª justa ascendente",
		conf_n.size() == 2 and int(conf_n[1]) - int(conf_n[0]) == 7
		and String(conf.get("orden", "")) == "ascendente")
	_check("confirmacion: tono calido", String(conf.get("tono", "")) == "calido")

	# Logro: arpegio de tríada mayor (3 notas: 3ª mayor + 5ª justa)
	var logro: Dictionary = sfx.tono("logro")
	var logro_n: Array = logro.get("notas_semitonos", [])
	_check("logro: tríada mayor 0-4-7", _a_ints(logro_n) == [0, 4, 7], "v=%s" % str(logro_n))
	_check("logro: 3 notas ascendentes", String(logro.get("orden", "")) == "ascendente")
	_check("logro: tono brillante", String(logro.get("tono", "")) == "brillante")

	# Error: tríada menor descendente, 0.4 s, nunca buzz
	var err: Dictionary = sfx.tono("error")
	var err_n: Array = err.get("notas_semitonos", [])
	_check("error: tríada menor descendente 7-4-0", _a_ints(err_n) == [7, 4, 0], "v=%s" % str(err_n))
	_check("error: duracion 0.4 s", is_equal_approx(float(err.get("duracion_s", 0.0)), 0.4),
		"d=%s" % str(err.get("duracion_s")))
	_check("error: tono suave", String(err.get("tono", "")) == "suave")

	# Recoger: nota aguda corta, positiva
	var rec: Dictionary = sfx.tono("recoger")
	var rec_n: Array = rec.get("notas_semitonos", [])
	_check("recoger: nota aguda (+1 octava)", rec_n.size() == 1 and int(rec_n[0]) >= 12, "v=%s" % str(rec_n))
	_check("recoger: corta (<=0.25 s)", float(rec.get("duracion_s", 9.0)) <= 0.25,
		"d=%s" % str(rec.get("duracion_s")))

	# Compra vs venta: audiblemente distintas
	var cmp: Dictionary = sfx.tono("compra")
	var vta: Dictionary = sfx.tono("venta")
	var cmp_n: Array = cmp.get("notas_semitonos", [])
	var vta_n: Array = vta.get("notas_semitonos", [])
	_check("compra: 2 monedas", int(cmp.get("monedas", 0)) == 2, "m=%s" % str(cmp.get("monedas")))
	_check("compra != venta", _a_ints(cmp_n) != _a_ints(vta_n), "compra=%s venta=%s" % [str(cmp_n), str(vta_n)])
	_check("venta: tríada menor 0-3-7", _a_ints(vta_n) == [0, 3, 7], "v=%s" % str(vta_n))
	_check("venta: tono medio distinto de compra",
		String(vta.get("tono", "")) != String(cmp.get("tono", "")))

	# Crafting éxito: arpegio corto de 4ª-5ª
	var cra: Dictionary = sfx.tono("crafting_exito")
	var cra_n: Array = cra.get("notas_semitonos", [])
	_check("crafting_exito: arpegio 4ª-5ª (0-5-7)", _a_ints(cra_n) == [0, 5, 7], "v=%s" % str(cra_n))

func _summary() -> void:
	print("=== Resumen M43: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M43 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M43 OK — todos los checks pasaron")
		quit(0)