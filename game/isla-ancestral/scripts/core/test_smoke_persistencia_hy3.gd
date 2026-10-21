# Modelo: Hy3 (WorkBuddy / Tencent Hunyuan)
# Plataforma: WorkBuddy
# Fecha: 2026-10-21
#
# Bloque C #52 (BACKLOG-MASTER Hy3): Runtime test del subsistema de
# persistencia / SaveManager (M59-Guardado). Verificacion runtime headless.
#
# NO es un sello §21.8 de M59: es un smoke test independiente del subsistema
# de guardado (autoria DeepSeek-V4.1-Flash, familia distinta a Hy3), enfocado
# en la maquina de estados en memoria (dirty flag / save-blocked) y la API
# publica del SaveManager. No escribe a disco (se evitan request_save /
# load_slot / slot_metadata, que tocan el filesystem del jugador).
#
# Ejecutar: Godot --headless --path game/isla-ancestral \
#           --script res://scripts/core/test_smoke_persistencia_hy3.gd
# Exit code != 0 si falla.
#
# Guarda anti-falso-verde: si _checks < MIN_CHECKS el suite ABORTA con
# codigo 1 (un SCRIPT ERROR temprano no puede reportar "0 fallos").

extends SceneTree

const MIN_CHECKS := 15  # medido en verde: 18 checks reales
var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [HY3] Smoke de persistencia / SaveManager (Bloque C #52) ===")
	var sm: Node = root.get_node_or_null("SaveManager")
	_check("SaveManager autoload presente", sm != null)
	if sm == null:
		_summary()
		return

	# --- API publica presente (sin invocar rutas de disco) ---
	_check("API request_save presente", sm.has_method("request_save"))
	_check("API load_slot presente", sm.has_method("load_slot"))
	_check("API slot_metadata presente", sm.has_method("slot_metadata"))
	_check("API slot_recoverable presente", sm.has_method("slot_recoverable"))
	_check("API register_provider presente", sm.has_method("register_provider"))
	_check("API mark_dirty presente", sm.has_method("mark_dirty"))
	_check("API clear_dirty presente", sm.has_method("clear_dirty"))
	_check("API is_dirty presente", sm.has_method("is_dirty"))
	_check("API set_save_blocked presente", sm.has_method("set_save_blocked"))
	_check("API is_save_blocked presente", sm.has_method("is_save_blocked"))

	# --- Maquina de estados dirty (en memoria) ---
	_check("is_dirty() inicia en false", sm.is_dirty() == false)
	sm.mark_dirty()
	_check("mark_dirty() -> is_dirty() == true", sm.is_dirty() == true)
	sm.clear_dirty()
	_check("clear_dirty() -> is_dirty() == false", sm.is_dirty() == false)

	# --- Maquina de estados save-blocked (en memoria) ---
	sm.set_save_blocked(true)
	_check("set_save_blocked(true) -> is_save_blocked() == true", sm.is_save_blocked() == true)
	sm.set_save_blocked(false)
	_check("set_save_blocked(false) -> is_save_blocked() == false", sm.is_save_blocked() == false)

	# --- register_provider round-trip (duck-typing, en memoria) ---
	var p1 := DumProvider.new()
	var r1: bool = sm.register_provider(p1)
	_check("register_provider(seccion nueva) devuelve true", r1 == true)
	var r2: bool = sm.register_provider(p1)
	_check("register_provider(duplicado) devuelve false", r2 == false)

	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _summary() -> void:
	print("=== Resumen HY3 persistencia: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0 or _checks < MIN_CHECKS:
		print("FALLO (fallos=%d, checks=%d < MIN=%d)" % [_fallos, _checks, MIN_CHECKS])
		quit(1)
	else:
		print("TODOS LOS CHECKS PASARON")
		quit(0)

# Provider dummy por duck-typing: implementa la interfaz minima que exige
# SaveSnapshot.register_provider (get_section_name). El nombre de seccion es
# estable (no aleatorio) para que el re-registro sea detectable como duplicado.
class DumProvider extends Node:
	var _sec: String = "hy3_smoke_dummy_persistencia"
	func get_section_name() -> String:
		return _sec
	func get_save_data() -> Dictionary:
		return {}
	func restore_save_data(_data: Dictionary) -> void:
		pass
