# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy AI
# Fecha: 2026-11-02
# M110-UI: PanelBase — base comun de los paneles del debug menu.
#
# Item del 05-Checklist que este archivo cierra:
#   L288 "scripts/debug/panel_*.gd" -> solo existian `panels/panel_mundo.gd` y
#   `panels/panel_entidades.gd`; en `scripts/debug/` no habia ningun `panel_*.gd`.
#   Este es el prefijo comun que el checklist pide, y ademas elimina la
#   duplicacion real que habia entre los dos paneles.
#
# Lo que se deduplica (estaba COPIADO en los dos paneles, identico):
#   `var _menu`, `var _ultimo`, `_ready()` (misma secuencia),
#   `_inyectar_menu()`, `ultimo_resultado()` y `_llamar()` (fail-closed).
#
# Contrato que los dos paneles ya cumplian y que la base preserva:
#  - `_ready()` resuelve `/root/DebugMenu` si nadie inyecto un backend, fija la
#    separacion del VBox y corre `_construir() -> _poblar() -> _conectar() ->
#    refrescar()`. Un panel puede inyectarse ANTES de `add_child()`.
#  - `refrescar()` SINCRONIZA LA VISTA CON EL BACKEND, nunca al reves: los
#    widgets no son fuente de verdad de la hora, el clima ni las listas.
#  - `_llamar()` es fail-closed: sin backend, sin el metodo o con retorno
#    no-Dictionary devuelve `{ok:false, resultado:<motivo>}` y NUNCA inventa
#    estado. Ese es el motivo de que exista un unico punto de llamada.
#
# Las subclases NO definen `_ready()` (la heredan) y NO redefinen `refrescar()`
# (redefinen `_actualizar()`), para que el guardia de construccion no se pueda
# saltar por accidente.
extends VBoxContainer
class_name PanelBaseM110

## Separacion entre widgets de un panel.
const SEPARACION := 6

var _menu: Node = null
var _ultimo: Dictionary = {}
## Verdadero recien al final de `_ready()`: `refrescar()` antes de entrar al
## arbol es un no-op en vez de un null-deref sobre widgets que no existen.
var _construido: bool = false


func _ready() -> void:
	if _menu == null:
		_menu = get_node_or_null("/root/DebugMenu")
	add_theme_constant_override("separation", SEPARACION)
	_construir()
	_poblar()
	_conectar()
	_construido = true
	refrescar()


# ── Puntos de extension que cada panel implementa ───────────────────────────

## Crea los widgets. La base no crea ninguno.
func _construir() -> void:
	pass


## Llena catalogos (estaciones, climas, NPCs...). Por defecto nada.
func _poblar() -> void:
	pass


## Conecta señales de los widgets. Por defecto nada.
func _conectar() -> void:
	pass


## Sincroniza los widgets con el backend. Por defecto nada.
func _actualizar() -> void:
	pass


## Unico punto de refresco publico. No se reemplaza en las subclases.
func refrescar() -> void:
	if not _construido:
		return
	_actualizar()


# ── Backend ────────────────────────────────────────────────────────────────

## Devuelve el backend en uso (null si no hay).
func backend() -> Node:
	return _menu


## Hook de test: fuerza el backend ANTES de add_child (null = /root/DebugMenu).
func _inyectar_menu(nodo: Node) -> void:
	_menu = nodo


## Ultimo resultado devuelto por el backend (copia: no se puede mutar desde fuera).
func ultimo_resultado() -> Dictionary:
	return _ultimo.duplicate()


## Llamada fail-closed al backend. Nunca lanza y nunca inventa estado.
func _llamar(metodo: String, args: Array) -> Dictionary:
	if _menu == null:
		return {"ok": false, "resultado": "DebugMenu no disponible"}
	if not _menu.has_method(metodo):
		return {"ok": false, "resultado": "backend sin %s()" % metodo}
	var r: Variant = _menu.callv(metodo, args)
	if r is Dictionary:
		return r as Dictionary
	return {"ok": false, "resultado": "respuesta no-Dictionary de %s()" % metodo}


# ── Fabrica de widgets (nombres estables para las suites) ──────────────────

func _crear_label(nombre: String, texto: String) -> Label:
	var l := Label.new()
	l.set_name(nombre)
	l.text = texto
	add_child(l)
	return l


func _crear_boton(nombre: String, texto: String, tooltip: String = "") -> Button:
	var b := Button.new()
	b.set_name(nombre)
	b.text = texto
	if not tooltip.is_empty():
		b.tooltip_text = tooltip
	add_child(b)
	return b


func _crear_option(nombre: String, tooltip: String = "") -> OptionButton:
	var o := OptionButton.new()
	o.set_name(nombre)
	if not tooltip.is_empty():
		o.tooltip_text = tooltip
	add_child(o)
	return o


func _crear_spin(nombre: String, minimo: float, maximo: float, paso: float = 1.0) -> SpinBox:
	var s := SpinBox.new()
	s.set_name(nombre)
	s.min_value = minimo
	s.max_value = maximo
	s.step = paso
	add_child(s)
	return s
