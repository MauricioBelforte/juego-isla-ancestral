# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M43: Efectos de Sonido — Test headless
# Valida: SFXManager (pool 24 voces con límite duro, prioridades,
# reproducción por superficie con variaciones). Exit code != 0 si falla.

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

func _summary() -> void:
	print("=== Resumen M43: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M43 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M43 OK — todos los checks pasaron")
		quit(0)