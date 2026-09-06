# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-05
#
# M118 iter. 2 — Escaneo de assets con presupuesto M166 (E-33/E-40: tris reales
# con loop_triangles, no polygons), validador de JSON data-driven, y gates
# automáticos. Ejecutar: blender --background --python escanear_assets.py <media_dir>
# O desde Godot: Godot --headless --script res://scripts/ci/escanear_assets.py
#
# Este script es un Node del autoload (no se ejecuta solo) — el escaneo real
# es un script standalone que corre fuera del engine.

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

# ═══════════ Iter. 2 (glm-5.3-flash): validador de data + gates de optimización ═══════════

## RF del gate "data_valid": escanea los subdirectorios conocidos de data/
## y verifica que los .json parseen sin error. Sin recursión (res:// safe).
func validar_data_json() -> Dictionary:
	var total := 0
	var errores := 0
	var detalles: Array[String] = []
	var subdirs := ["balance", "ci", "clima", "eventos", "mineria", "vegetacion"]
	for sub in subdirs:
		var ruta: String = "res://data/" + sub
		var dir := DirAccess.open(ruta)
		if dir == null:
			continue
		for archivo in dir.get_files():
			var fname: String = String(archivo)
			if fname.ends_with(".json"):
				total += 1
				var texto: String = FileAccess.get_file_as_string(ruta + "/" + fname)
				var parsed: Variant = JSON.parse_string(texto)
				if parsed == null:
					errores += 1
					detalles.append("JSON inválido: %s/%s" % [ruta, fname])
	return {"total": total, "errores": errores, "detalles": detalles,
		"ok": errores == 0}

## Gate "data_valid": ejecuta validar_data_json() y registra el resultado.
func gate_data_valid() -> bool:
	var r := validar_data_json()
	var ok := bool(r.get("ok", false))
	registrar_resultado("data_json_valido", ok)
	if not ok:
		for det in r.get("detalles", []):
			push_error("[M118] " + str(det))
	print("[M118] data_valid: %d archivos, %d errores" % [int(r.get("total", 0)), int(r.get("errores", 0))])
	return ok

## Gate "m166_budget": verifica que los assets .glb en media/ no excedan el
## presupuesto de triángulos (necesita Blender — este método solo valida que
## los archivos existan y no estén vacíos; el conteo de tris lo hace Blender).
func gate_assets_existen() -> bool:
	var rutas := ["res://assets/3d/media/"]
	var total := 0
	var vacios := 0
	for ruta in rutas:
		var dir := DirAccess.open(ruta)
		if dir == null:
			continue
		for archivo in dir.get_files():
			var fname: String = String(archivo)
			if fname.ends_with(".glb"):
				total += 1
				var f := FileAccess.open(ruta + "/" + fname, FileAccess.READ)
				if f == null or f.get_length() < 100:
					vacios += 1
					push_warning("[M118] GLB sospechoso (vacío): %s" % fname)
				elif f:
					f.close()
	registrar_resultado("assets_glb_presentes", vacios == 0 and total > 0)
	print("[M118] assets_glb: %d archivos, %d vacíos" % [total, vacios])
	return vacios == 0

## Ejecuta TODOS los gates automáticos y retorna el resumen.
func ejecutar_gates_automaticos() -> Dictionary:
	var res := {}
	res["data_valid"] = gate_data_valid()
	res["assets_existen"] = gate_assets_existen()
	var ok := true
	for k in res:
		if not res[k]:
			ok = false
	print("[M118] Gates automáticos: %s" % ("TODOS OK" if ok else "HAY FALLOS"))
	return res
