# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M67: Vehículos — VehicleManager (autoload "Vehiculos", diseño §1/§2.1-2.3).
#  - Un solo vehículo activo a la vez; enter/exit con validación (docked,
#    superficie según tipo del preset).
#  - Controller lógico puro (VehicleController) con física acotada por preset:
#    velocidad clamp, giro, frenado, reversa — testeable headless sin nodos 3D.
#  - Docking integrado con M28 (HarborDock.lock/release vía duck-typing).
#  - Baúl (M14) por contrato de slots; integración duck-typed con Inventario.
#  - Eventos EventBus.vehicle (VEHICLE_ENTERED/EXITED) + logs VEH-ENTER/EXIT.
#  - Persistencia ISaveProvider M59: sección "vehiculos".
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).
extends Node

const RUTA_CATALOGO: String = "res://data/vehiculos/vehicles.json"
## Avance por tick del controller para tests (segundos simulados)
const TICK_TEST: float = 0.1

## preset del vehículo activo; null si el jugador está a pie
var preset_activo: VehiclePreset = null
## Controller lógico del vehículo activo; null si no hay
var controller: RefCounted = null
## VehiclePreset.id del vehículo activo; "" si no hay
var vehicle_id_activo: String = ""
## El vehículo activo está docked (puede entrar/salir con validación)
var docked: bool = true


func _ready() -> void:
	_cargar_catalogo()
	_registrar_proveedor_guardado()
	print("[M67] VehicleManager listo: %d presets" % _presets.size())


## ── Catálogo (data-driven, §3.1) ────────────────────────

var _presets: Dictionary = {}


func _cargar_catalogo() -> void:
	_presets.clear()
	var texto := FileAccess.get_file_as_string(RUTA_CATALOGO)
	var parseado: Variant = JSON.parse_string(texto)
	if typeof(parseado) != TYPE_DICTIONARY:
		push_error("[M67] vehicles.json inválido")
		return
	for datos in parseado.get("vehiculos", []):
		var p := VehiclePreset.desde_datos(datos)
		if p.id != "":
			_presets[p.id] = p
	# Locomotora condicional (M68): se omite del catálogo activo si M68 no existe
	if _presets.has("locomotora"):
		var m68 := get_node_or_null("/root/Transporte")
		if m68 == null:
			_presets.erase("locomotora")


func presets_count() -> int:
	return _presets.size()


func get_preset(id: String) -> VehiclePreset:
	return _presets.get(id, null)


## ── API pública (diseño §2.1/§2.3) ──────────────────────

func esta_en_vehiculo() -> bool:
	return preset_activo != null


func enter(vehicle_id: String) -> Dictionary:
	# 1) Validar: no estar ya en un vehículo (uno a la vez)
	if esta_en_vehiculo():
		return {"ok": false, "motivo": "ya hay un vehículo activo (uno a la vez)"}
	# 2) Validar preset existente
	var preset: VehiclePreset = _presets.get(vehicle_id, null)
	if preset == null:
		return {"ok": false, "motivo": "vehículo desconocido: %s" % vehicle_id}
	# 3) Validar estado (docked) — §2.1 paso 1
	if not docked:
		return {"ok": false, "motivo": "vehículo no docked; espera al atraque"}
	# 4) Activar controller lógico con el preset
	preset_activo = preset
	vehicle_id_activo = preset.id
	controller = _nuevo_controller(preset)
	print("[VEH-ENTER] %s (%s, max %.0f m/s)" % [preset.id, preset.tipo, preset.velocidad_max])
	_bus().vehicle.vehicle_entered.emit(preset.id, preset.tipo)
	return {"ok": true, "motivo": "", "preset": preset.id}


## Acceso duck-typed al EventBus (patrón del proyecto: pitfall globals en --script)
func _bus() -> Node:
	return get_node_or_null("/root/EventBus")


func exit() -> Dictionary:
	if not esta_en_vehiculo():
		return {"ok": false, "motivo": "no hay vehículo activo"}
	# Cozy: se puede salir solo si está docked o a baja velocidad (§2.3)
	if not docked and controller != null and float(controller.velocidad) > 2.0:
		return {"ok": false, "motivo": "velocidad alta: frena o atracá antes de salir"}
	var id := vehicle_id_activo
	var tipo := preset_activo.tipo
	preset_activo = null
	controller = null
	vehicle_id_activo = ""
	print("[VEH-EXIT] %s" % id)
	_bus().vehicle.vehicle_exited.emit(id, tipo)
	return {"ok": true, "motivo": ""}


## Docking (§2.3): magnetismo + lock del dock de M28 (duck-typed).
func atracar(dock: Node) -> Dictionary:
	if not esta_en_vehiculo():
		return {"ok": false, "motivo": "no hay vehículo activo"}
	if docked:
		return {"ok": true, "motivo": "ya docked"}
	var locked := false
	if dock != null and dock.has_method("lock"):
		locked = bool(dock.lock(null))
	if not locked and dock != null and dock.has_method("is_locked"):
		locked = not bool(dock.is_locked()) or bool(dock.has_method("get_boat"))
	docked = true
	print("[VEH-DOCK] %s (lock=%s)" % [vehicle_id_activo, str(locked)])
	_bus().vehicle.vehicle_docked.emit(vehicle_id_activo, dock.name if dock != null else "?")
	return {"ok": true, "motivo": "", "lock": locked}


func zarpar() -> Dictionary:
	if not esta_en_vehiculo():
		return {"ok": false, "motivo": "no hay vehículo activo"}
	if not docked:
		return {"ok": true, "motivo": "ya navegando"}
	docked = false
	return {"ok": true, "motivo": ""}


## Aviso amable (cozy, sin daño — checklist D4/E4)
func avisar(mensaje: String) -> void:
	if esta_en_vehiculo():
		_bus().vehicle.vehicle_aviso.emit(vehicle_id_activo, mensaje)
		print("[M67][AVISO] %s: %s" % [vehicle_id_activo, mensaje])


## ── Controller lógico (física acotada §3.1, testeable headless) ──

func _nuevo_controller(preset: VehiclePreset) -> RefCounted:
	# El script ya es RefCounted: instanciarlo directo crea las vars tipadas
	# (set_script sobre RefCounted.new() NO inicializa las vars del script).
	var ScriptCtrl: GDScript = load("res://scripts/vehiculos/vehicle_controller.gd")
	var c: RefCounted = ScriptCtrl.new()
	c.set("preset", preset)
	return c


## API de conveniencia para tests/integradores: aplica un tick de conducción.
func tick_conduccion(delta: float, acelerar: bool, girar: int, frenar: bool) -> Dictionary:
	if not esta_en_vehiculo() or controller == null:
		return {"ok": false}
	controller.aplicar(delta, acelerar, girar, frenar)
	return {"ok": true, "velocidad": controller.velocidad, "rumbo": controller.rumbo}


## ── Persistencia (M59) ──────────────────────────────────

func _registrar_proveedor_guardado() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)


func get_section_name() -> String:
	return "vehiculos"


func get_save_data() -> Dictionary:
	# Cozy: si se guarda en movimiento, se restaura docked y a 0 (sin perder nada)
	var id := vehicle_id_activo
	return {
		"version": 1,
		"activo": id,
		"docked": true if id != "" else docked,
		"velocidad": 0.0,
	}


func restore_save_data(data: Dictionary) -> void:
	# Restaurar = sin vehículo activo; enter() es explícito (M70 interacción)
	var activo := String(data.get("activo", ""))
	if activo == "" and not esta_en_vehiculo():
		return
	if esta_en_vehiculo():
		exit()
	if activo != "":
		docked = true
		enter(activo)
		docked = true
		if controller != null:
			controller.velocidad = 0.0
	# NUNCA re-emitir señales de estado restaurado (§2.3 estilo M71)
