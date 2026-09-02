# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M150: Diseño Sonoro Narrativo — Test headless
# Valida: NarrativeSound (momentos narrativos, leitmotifs, reglas).
# Exit code != 0 si falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M150] Test de Diseño Sonoro Narrativo ===")
	_test_config()
	_test_momentos()
	_test_leitmotifs()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_config() -> void:
	print("--- Config: narrative_sound.json ---")
	var ns := root.get_node_or_null("NarrativeSound")
	if ns == null:
		_check("NarrativeSound autoload presente", false)
		_summary()
		quit(1)
		return
	_check("NarrativeSound autoload presente", true)
	_check("6 momentos", ns.config.get("momentos", {}).size() == 6, "size=%d" % ns.config.get("momentos", {}).size())
	_check("4 leitmotifs", ns.config.get("leitmotifs", {}).size() == 4, "size=%d" % ns.config.get("leitmotifs", {}).size())

func _test_momentos() -> void:
	print("--- Momentos narrativos ---")
	var ns := root.get_node_or_null("NarrativeSound")
	var sello = ns.momento("sello_obtenido")
	_check("sello_obtenido existe", not sello.is_empty() and sello.get("intensidad", 0) == 1.0)
	_check("sello con leitmotif", String(sello.get("leitmotif", "")) == "aurora_motivo")
	var elysia = ns.momento("elysia_avistada")
	_check("elysia intensidad 1.0", float(elysia.get("intensidad", 0)) == 1.0)
	_check("momento inexistente -> {}", ns.momento("no_existe").is_empty())
	_check("6 momentos ids", ns.momentos_ids().size() == 6)

func _test_leitmotifs() -> void:
	print("--- Leitmotifs y reglas ---")
	var ns := root.get_node_or_null("NarrativeSound")
	var aurora = ns.leitmotif("aurora_motivo")
	_check("leitmotif aurora existe", not aurora.is_empty() and String(aurora.get("nombre", "")) == "Motivo de Aurora")
	_check("leitmotif inexistente -> {}", ns.leitmotif("no_existe").is_empty())
	_check("regla silencio tras sello", ns.regla("silencio_narrativo_tras_sello") == true)
	_check("regla inexistente -> false", ns.regla("no_existe") == false)

func _summary() -> void:
	print("=== Resumen M150: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M150 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M150 OK — todos los checks pasaron")
		quit(0)