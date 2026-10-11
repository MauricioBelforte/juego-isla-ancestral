# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-09
# M18 Frente C: CasasPanel — UI MODAL que muestra casas, etapa y muebles.
# Regla §9: la UI llama al manager, no implementa lógica.
extends CanvasLayer
class_name CasasPanel

var _house_manager: Node = null
var _panel: Panel = null
var _titulo: Label = null
var _info_etapa: Label = null
var _info_muebles: Label = null
var _btn_mejorar: Button = null
var _btn_cerrar: Button = null
var _visible := false

func _ready() -> void:
	_house_manager = get_node_or_null("/root/HouseManager")
	_construir_ui()
	visible = false

func _construir_ui() -> void:
	_panel = Panel.new()
	_panel.set_name("CasasPanel")
	_panel.custom_minimum_size = Vector2(400, 300)
	add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.set_name("Contenido")
	_panel.add_child(vbox)

	_titulo = Label.new()
	_titulo.text = "Casas del Jugador"
	_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_titulo)

	_info_etapa = Label.new()
	_info_etapa.text = ""
	vbox.add_child(_info_etapa)

	_info_muebles = Label.new()
	_info_muebles.text = ""
	vbox.add_child(_info_muebles)

	_btn_mejorar = Button.new()
	_btn_mejorar.text = "Mejorar Etapa"
	_btn_mejorar.pressed.connect(_on_mejorar)
	vbox.add_child(_btn_mejorar)

	_btn_cerrar = Button.new()
	_btn_cerrar.text = "Cerrar"
	_btn_cerrar.pressed.connect(_on_cerrar)
	vbox.add_child(_btn_cerrar)

	_refrescar()

func _refrescar() -> void:
	if _house_manager == null:
		_info_etapa.text = "HouseManager no disponible"
		_info_muebles.text = ""
		return
	var casa: Dictionary = _house_manager.obtener_casa_jugador()
	if casa.is_empty():
		_info_etapa.text = "Sin casa registrada"
		_info_muebles.text = ""
		_btn_mejorar.disabled = true
		return
	var etapa: int = int(casa.get("etapa", 1))
	var nombres_etapa := {1: "Choza", 2: "Ampliación", 3: "Cocina", 4: "Taller", 5: "Sótano/Ático"}
	_info_etapa.text = "Etapa: %d — %s" % [etapa, nombres_etapa.get(etapa, "?")]
	var muebles: Array = casa.get("muebles", [])
	if muebles.is_empty():
		_info_muebles.text = "Muebles: ninguno"
	else:
		_info_muebles.text = "Muebles (%d): %s" % [muebles.size(), ", ".join(muebles)]
	var costes: Dictionary = _house_manager.COSTES_ETAPA.get(etapa, [])
	if costes.is_empty():
		_btn_mejorar.disabled = true
		_btn_mejorar.text = "Etapa Máxima"
	else:
		_btn_mejorar.disabled = false
		_btn_mejorar.text = "Mejorar (coste: %s)" % _formatear_costes(costes)

func _formatear_costes(costes: Variant) -> String:
	var partes: Array = []
	if typeof(costes) != TYPE_ARRAY:
		return "?"
	for grupo in costes:
		for req in grupo:
			partes.append("%s×%d" % [req.get("id", ""), int(req.get("cant", 0))])
	return " + ".join(partes)

func _on_mejorar() -> void:
	if _house_manager == null:
		return
	var casa: Dictionary = _house_manager.obtener_casa_jugador()
	var id: String = String(casa.keys()[0]) if not casa.is_empty() else ""
	if id.is_empty():
		return
	var resultado: Dictionary = _house_manager.cobrar_etapa(id)
	if bool(resultado.get("ok", false)):
		_refrescar()

func _on_cerrar() -> void:
	visible = false

## Abre el panel (para tests).
func abrir() -> void:
	visible = true
	_refrescar()

## Cierra el panel.
func cerrar() -> void:
	visible = false

## Devuelve si el panel está visible.
func esta_visible() -> bool:
	return visible

## Devuelve el texto de etapa (para tests).
func obtener_info_etapa() -> String:
	return _info_etapa.text if _info_etapa != null else ""

## Devuelve si el HouseManager está conectado.
func manager_conectado() -> bool:
	return _house_manager != null
