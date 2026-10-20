# Modelo: Hy3 (WorkBuddy / Tencent Hunyuan)
# Plataforma: WorkBuddy
# Fecha: 2026-10-19
#
# Bloque C #51 (BACKLOG-MASTER Hy3): Suite de smoke de managers core
# (bootstrap / eventbus / registries). Verificación runtime headless.
# No es QA de sello de módulo: ejercita infraestructura fundacional
# (EventBus/ServiceRegistry/Bootstrap, autoría agnes-3-flash / M40, familia
# distinta a Hy3) como artefacto de humo independiente.
#
# Ejecutar: Godot --headless --path game/isla-ancestral \
#           --script res://scripts/core/test_smoke_core_hy3.gd
# Exit code != 0 si falla.
#
# Guarda anti-falso-verde: si _checks < MIN_CHECKS el suite ABORTA con
# código 1 (un SCRIPT ERROR temprano no puede reportar "0 fallos").

extends SceneTree

const MIN_CHECKS := 15  # medido en verde: 15 checks reales
var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [HY3] Smoke de managers core (Bloque C #51) ===")
	var bus: Node = root.get_node_or_null("EventBus")
	var reg: Node = root.get_node_or_null("ServiceRegistry")
	var boot: Node = root.get_node_or_null("Bootstrap")

	_check("EventBus autoload presente", bus != null)
	_check("ServiceRegistry autoload presente", reg != null)
	_check("Bootstrap autoload presente", boot != null)
	if bus == null or reg == null or boot == null:
		_summary()
		return

	# --- Dominios del EventBus (sub-objetos tipados) ---
	var dominios := ["world","economy","inventory","quest","npc","calendar",
		"time","weather","travel","vehicle","ui","player","infra","fishing","diary"]
	var ok_dominios := 0
	for d in dominios:
		if bus.get(d) != null:
			ok_dominios += 1
		else:
			print("  [WARN] EventBus.%s ausente" % d)
	_check("EventBus: >=14 dominios presentes", ok_dominios >= 14,
		"ok=%d/%d" % [ok_dominios, dominios.size()])

	# --- Señales clave en el dominio infra ---
	var infra: Variant = bus.get("infra")
	_check("EventBus.infra existe (Object)", infra != null and (infra is Object))
	if infra is Object:
		_check("infra tiene señal game_flow_changed",
			infra.has_signal("game_flow_changed"))
		_check("infra tiene señal boot_completado",
			infra.has_signal("boot_completado"))
		_check("infra tiene señal carga_iniciada",
			infra.has_signal("carga_iniciada"))

	# --- ServiceRegistry round-trip con contrato aislado ---
	var dummy := Node.new()
	var c: String = "hy3_smoke_dummy_%d" % randi()
	var r1: bool = reg.register(c, dummy)
	_check("ServiceRegistry.register devuelve true", r1 == true)
	_check("ServiceRegistry.has detecta contrato", reg.has(c) == true)
	var got: Variant = reg.get_service(c)
	_check("ServiceRegistry.get_service devuelve la instancia", got == dummy)
	var r2: bool = reg.register(c, dummy)
	_check("registro duplicado rechazado (false)", r2 == false)
	reg.unregister(c)
	_check("unregister elimina contrato", reg.has(c) == false)

	# --- Bootstrap -> ServiceRegistry: servicios core cableados ---
	_check("Bootstrap registró 'event_bus' en ServiceRegistry",
		reg.has("event_bus") == true)
	_check("Bootstrap registró 'service_registry' en ServiceRegistry",
		reg.has("service_registry") == true)

	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _summary() -> void:
	print("=== Resumen HY3 smoke core: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0 or _checks < MIN_CHECKS:
		print("FALLO (fallos=%d, checks=%d < MIN=%d)" % [_fallos, _checks, MIN_CHECKS])
		quit(1)
	else:
		print("TODOS LOS CHECKS PASARON")
		quit(0)
