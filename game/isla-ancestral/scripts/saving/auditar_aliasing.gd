# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M59/M19: Auditoría de aliasing en ISaveProviders (hallazgo Log 553).
# Detecta providers cuyo get_save_data() retorna referencias vivas a los
# contenedores de instancia: si un restore vacío borra también el snapshot,
# el provider tiene aliasing (riesgo de corrupción silenciosa de saves).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/saving/auditar_aliasing.gd
# NO modifica código: solo reporta (los fixes son por módulo dueño).

extends SceneTree

var _ok: Array = []
var _aliasing: Array = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	for child in root.get_children():
		if child == null or not is_instance_valid(child):
			continue
		if not child.has_method("get_save_data") or not child.has_method("restore_save_data"):
			continue
		if not child.has_method("get_section_name"):
			continue
		var nombre: String = child.name
		var script_obj: Variant = child.get_script()
		if script_obj != null and script_obj.resource_path != "":
			nombre = String(script_obj.resource_path.get_file())
		# 1) Snapshot ANTES (referencia viva si hay aliasing)
		var snapshot: Dictionary = child.get_save_data()
		var tenia_datos := _tiene_datos(snapshot)
		if not tenia_datos:
			continue  # provider vacío en boot: no auditable sin estado
		# 2) Restore vacío (muta el estado; y con aliasing, el snapshot)
		child.restore_save_data({})
		# 3) ¿El snapshot perdió los datos?
		var quedo_vacio := not _tiene_datos(snapshot)
		if quedo_vacio:
			_aliasing.append(nombre)
			push_error("[AUDIT-ALIASING] %s: snapshot corrompido tras restore vacío (get_save_data sin deep-copy)" % nombre)
		else:
			_ok.append(nombre)
		# Nota: NO restauramos el estado original — es headless, no persiste nada.
	print("=== AUDITORIA ALIASING ISaveProvider ===")
	print("OK (%d): %s" % [_ok.size(), str(_ok)])
	print("ALIASING (%d): %s" % [_aliasing.size(), str(_aliasing)])
	quit(0)


func _tiene_datos(d: Dictionary) -> bool:
	for k in d:
		var v: Variant = d[k]
		if v is Dictionary and not (v as Dictionary).is_empty():
			return true
		if v is Array and not (v as Array).is_empty():
			return true
	return false
