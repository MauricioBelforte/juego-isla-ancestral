# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M118: CI/CD — CiCdManager (autoload)
# Gestión de gates de CI por módulo/hito: configuración data-driven
# (ci_gates.json), verificación de requisitos, checklist de integración.
# Adaptación Godot 4.7/GDScript del diseño Unity (04-Codigo.md §2).
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const RUTA_GATES := "res://data/ci/ci_gates.json"

var config: Dictionary = {}
var resultados: Dictionary = {}   # requisito -> bool (resultados de la corrida)

func _ready() -> void:
	_cargar_config()
	_registrar_servicio()
	print("[M118] CiCdManager listo (%d gates)" % config.get("gates", {}).size())

func _cargar_config() -> void:
	if not FileAccess.file_exists(RUTA_GATES):
		push_warning("[M118] ci_gates.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_GATES))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("cicd"):
		sr.register("cicd", self)

## Registra el resultado de un requisito (ej: "tests_ok" -> true).
func registrar_resultado(requisito: String, ok: bool) -> void:
	resultados[requisito] = ok

## Verifica un gate: devuelve {ok, faltantes: Array, presentes: Array}.
func verificar_gate(gate_id: String) -> Dictionary:
	var gate: Dictionary = config.get("gates", {}).get(gate_id, {})
	if gate.is_empty():
		return {"ok": false, "faltantes": ["gate_inexistente_%s" % gate_id], "presentes": []}
	var requisitos: Array = gate.get("requisitos", [])
	var presentes: Array = []
	var faltantes: Array = []
	for req in requisitos:
		if resultados.get(req, false):
			presentes.append(req)
		else:
			faltantes.append(req)
	return {"ok": faltantes.is_empty(), "faltantes": faltantes, "presentes": presentes}

## Checklist de integración: devuelve el checklist configurado.
func checklist_integracion() -> Array:
	return config.get("checklist_integracion", [])

## Reporte legible de un gate para CI/QA.
func reporte_gate(gate_id: String) -> String:
	var r := verificar_gate(gate_id)
	var gate: Dictionary = config.get("gates", {}).get(gate_id, {})
	if r["ok"]:
		return "[M118] Gate '%s': OK — %d requisitos cumplidos" % [gate_id, (r["presentes"] as Array).size()]
	var lineas: Array = ["[M118] Gate '%s': FALLA — faltan: %s" % [gate_id, str(r["faltantes"])]]
	return "\n".join(lineas)