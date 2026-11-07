# Modelo: DeepSeek V4.1 Flash
# Plataforma: OpenCode
# Fecha: 2026-11-06
#
# M129: Merchandising — Boot pre-check (B-17 / B-12-06).
# Verifica sobre el ARRANQUE REAL del proyecto (autoloads instanciados):
#   1. /root/MerchManager existe y cargo el catalogo.
#   2. ServiceRegistry tiene el contrato "merch" apuntando al autoload.
#   3. SaveManager colecta la seccion "merch" (contrato M59) con las 3 tiradas.
# Uso: godot --headless --path game/isla-ancestral -s res://scripts/legal/test_merch_boot_m129.gd
# Exit code != 0 si falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M129] Boot pre-check (B-17 / B-12-06) ===")
	await process_frame
	await process_frame
	var raiz := root
	var mm: Node = raiz.get_node_or_null("MerchManager")
	_check("autoload MerchManager presente", mm != null)
	if mm != null:
		_check("MerchManager cargado", bool(mm.call("esta_cargado")))
		_check("3 tiradas limitadas en boot", int(mm.call("get_tirada_ids").size()) == 3,
			"ids=%s" % str(mm.call("get_tirada_ids")))
		_check("artbook 500 unidades", int(mm.call("unidades_totales", "artbook_pasta_dura")) == 500)
	var sr: Node = raiz.get_node_or_null("ServiceRegistry")
	_check("ServiceRegistry presente", sr != null)
	if sr != null:
		_check("contrato 'merch' registrado", bool(sr.call("has", "merch")))
		if bool(sr.call("has", "merch")):
			_check("contrato apunta al autoload", sr.call("get_service", "merch") == mm)
	var sm: Node = raiz.get_node_or_null("SaveManager")
	_check("SaveManager presente", sm != null)
	if sm != null:
		var snap = sm.get("snapshot")
		_check("SaveManager.snapshot disponible", snap != null)
		if snap != null:
			var payload: Dictionary = snap.collect("boot_check_m129")
			_check("save incluye seccion 'merch'", payload.has("merch"))
			if payload.has("merch"):
				var sec: Dictionary = payload["merch"]
				_check("seccion 'merch' trae 3 tiradas",
					int((sec.get("tiradas", {}) as Dictionary).size()) == 3)
	_resumen()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _resumen() -> void:
	print("=== Resumen boot M129: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("BOOT M129 FALLIDO — salida con codigo 1")
		quit(1)
	else:
		print("BOOT M129 OK — autoload + contrato + save")
		quit(0)
