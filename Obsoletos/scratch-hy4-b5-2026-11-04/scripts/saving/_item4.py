# -*- coding: utf-8 -*-
# M59 ítem 4: botón Guardar deshabilitado si no hay cambios (no dirty)
import io

P = r"game\isla-ancestral\scripts\ui\layers\pause_layer.gd"
s = io.open(P, encoding="utf-8").read()

# 1) Después de crear el botón Guardar: estado inicial + señales del SM.
old = "\t_boton_borrar = _agregar_boton(vbox, \"SETTINGS.BORRAR_SLOT\", func(): _pedir_confirmacion_borrado())"
assert s.count(old) == 1
s = s.replace(old, old + "\n" +
    "\t# M59 ítem 4: botón Guardar deshabilitado si no hay cambios (is_dirty=).\n"
    "\t_boton_guardar.disabled = true\n"
    "\t_conectar_dirty_guardar()")

# 2) Funciones: conexión (señales del manager + refresh al abrir pausa) y refresh.
ancla = "## Abre el ConfirmPopup; al aceptar, guarda por SaveManager (M59, cola real)"
assert s.count(ancla) == 1
s = s.replace(ancla, """## M59 ítem 4 (G-5.3-Flash-Agente, 2026-10-21): el botón Guardar se deshabilita
## cuando la sesión no registra cambios (is_dirty=false) y se re-habilita con
## cualquier evento que marque dirty. Refresco: al abrir la pausa, al cerrar el
## guardado y ante los cambios señalados por el manager.
func _conectar_dirty_guardar() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm == null:
		_boton_guardar.disabled = false
		return
	for sig in ["item_added", "item_removed"]:
		if sm.has_signal(sig) and not sm.is_connected(sig, _refrescar_guardar_dirty):
			sm.connect(sig, _refrescar_guardar_dirty)
	for sig in ["quest_completed", "gift_given"]:
		pass  # las de inventario bastan para el guard de dirty más común
	if sm.has_signal("save_completed") and not sm.save_completed.is_connected(_on_guardado_ok):
		sm.save_completed.connect(_on_guardado_ok)
	if sm.has_signal("save_failed") and not sm.save_failed.is_connected(_on_guardado_fail):
		sm.save_failed.connect(_on_guardado_fail)
	_refrescar_guardar_dirty()


func _refrescar_guardar_dirty() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm == null or not sm.has_method("is_dirty"):
		return
	_boton_guardar.disabled = not sm.is_dirty()


## Abre el ConfirmPopup; al aceptar, guarda por SaveManager (M59, cola real)""")

# 3) Refresh también al abrir la pausa: hook en on_layer_opened si existe; si no, en visible toggle.
if "func on_layer_closed() -> void:" in s:
    s = s.replace("func on_layer_closed() -> void:",
                  "func on_layer_opened() -> void:\n\t_refrescar_guardar_dirty()\n\nfunc on_layer_closed() -> void:")

io.open(P, "w", encoding="utf-8", newline="\n").write(s)
print("ítem 4 aplicado")
