# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-25
#
# M122: Crash Reporting — CrashDebugMenu (integración M110, helper headless).
# Implementa la integración del diseño (03-Diseno.md §10), que quedó `[ ]`:
#   add_diagnostics_panel -> describir_panel
#   _format_metadata      -> formatear_metadata
#   _on_test_crash        -> accion_test_crash
#   _on_send_crash_report -> accion_enviar_pendientes
# RefCounted sin `class_name` (preload).
#
# Desviación del diseño (04-Codigo.md §15): el diseño llamaba a `debug_menu.add_panel()`,
# `panel.add_button()`, etc. — una API de M110 que NO EXISTE todavía (el Debug Menu no expone
# esos métodos). Acá el panel se describe como DATOS (`describir_panel`) y las acciones reciben
# sus dependencias por parámetro, así se puede testear sin la UI de M110. El cableado real es de
# M110 cuando su API exista.

extends RefCounted


## Describe el panel "Diagnostics" como lista de ítems. Contrato de cada ítem:
##   {"tipo": "boton", "etiqueta": String, "accion": String}
##   {"tipo": "etiqueta", "texto": String}
func describir_panel(meta: Dictionary) -> Array:
	return [
		{"tipo": "boton", "etiqueta": "Test Crash", "accion": "test_crash"},
		{"tipo": "boton", "etiqueta": "Send Crash Report", "accion": "send_crash_report"},
		{"tipo": "etiqueta", "texto": "System Metadata:"},
		{"tipo": "etiqueta", "texto": formatear_metadata(meta)},
	]


## Formato de la metadata en el Debug Menu (mismo texto que el diseño).
func formatear_metadata(meta: Dictionary) -> String:
	return "OS: %s\nGPU: %s\nCPU: %s\nRAM: %s GB" % [
		str(meta.get("os", "?")),
		str(meta.get("gpu", "?")),
		str(meta.get("cpu", "?")),
		_a_gb(int(meta.get("ram_total", 0))),
	]


## Acción "Test Crash": dispara un crash de prueba en el reporter inyectado.
func accion_test_crash(reporter: Object) -> bool:
	if reporter == null or not reporter.has_method("reportar_crash"):
		return false
	reporter.call("reportar_crash", "test_crash", "Test crash desde Debug Menu", [])
	return true


## Acción "Send Crash Report": envía los dumps pendientes con el sender inyectado.
## Devuelve cuántos se enviaron (0 si falta alguna dependencia: fail-closed).
func accion_enviar_pendientes(reporter: Object, sender: Object) -> int:
	if reporter == null or sender == null:
		return 0
	if not reporter.has_method("dumps_pendientes") or not sender.has_method("enviar"):
		return 0
	var pendientes: Variant = reporter.call("dumps_pendientes")
	if typeof(pendientes) != TYPE_ARRAY:
		return 0
	var arr: Array = pendientes
	var enviados: int = 0
	for ruta in arr:
		var ok: Variant = sender.call("enviar", {"ruta": str(ruta)})
		if bool(ok):
			enviados += 1
	return enviados


func _a_gb(bytes: int) -> String:
	return "%.2f" % (float(bytes) / 1024.0 / 1024.0 / 1024.0)
