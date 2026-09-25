# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-20
#
# M53 (iter. agnes, Log 1118) — Puente M53 ↔ M87: adopción de la convención de
# metadatos de `RetraductorUI` (M87) por los scripts de UI.
#
# M87 ya expone el mecanismo (scripts/localization/retraductor_ui.gd):
# un nodo declara su clave con set_meta("text_key", "HUD.ENERGIA") o
# set_meta("tooltip_text_key", "SETTINGS.IDIOMA_DESC") y al cambiar de idioma
# se re-traduce lo visible sin re-render completo. Este helper es el punto de
# adopción de M53: los scripts de capa/widget lo usan en vez de repetir el
# get_node_or_null("/root/Localization") + traducir_clave de cada capa.
#
# Cero dependencias de render: todo es determinista y testeable headless.

class_name UiI18n
extends RefCounted

## Raíz del árbol de escena (SceneTree.root). Null fuera de un juego.
static func raiz_nodos() -> Node:
	var ml := Engine.get_main_loop()
	if ml is SceneTree:
		return (ml as SceneTree).root
	return null

## Autoload M87 (o null si M87 no está montado — fallback a la clave literal).
static func _localization() -> Node:
	var r := raiz_nodos()
	if r == null:
		return null
	return r.get_node_or_null("Localization")

## Traduce una clave completa (ej "EQUIP.TITULO") al locale activo.
## Si M87 no está o la clave no existe, devuelve la clave (misma política
## de fallback de Localization._buscar_texto).
## (Nombre propio: `tr` choca con el método nativo Object.tr — no usar.)
static func traducir(clave: String) -> String:
	var loc := _localization()
	if loc != null and loc.has_method("traducir_clave"):
		var res = loc.traducir_clave(clave)
		if res != clave:
			return str(res)
	return clave

## Igual que traducir() pero con parámetros ({p}, {n}, {item}...) vía M87.
static func traducir_param(clave: String, params: Dictionary) -> String:
	var loc := _localization()
	if loc != null and loc.has_method("traducir_clave"):
		var res = loc.traducir_clave(clave, params)
		if res != clave:
			return str(res)
	return clave

## Declara el metadato de texto (convención RetraductorUI de M87) y aplica el
## texto traducido de inmediato. Etiquetas DINÁMICAS (con parámetros) NO
## deben usar esto: el re-traductor global no pasa params; esas las gestiona
## su capa re-leyendo en locale_changed (ver EquipmentLayer).
static func meta_texto(nodo: Node, clave: String) -> void:
	if nodo == null:
		return
	nodo.set_meta("text_key", clave)
	if nodo is Control:
		var c := nodo as Control
		if "text" in c:
			c.set("text", traducir(clave))

## Declara el metadato de tooltip (convención RetraductorUI de M87).
static func meta_tooltip(nodo: Node, clave: String) -> void:
	if nodo == null:
		return
	nodo.set_meta("tooltip_text_key", clave)

## Re-traduce un subárbol visible vía RetraductorUI (M87). Devuelve el
## informe de RetraductorUI; si M87 no está montado, {"sin_m87": true}.
static func retraducir(raiz: Node, rect_visible: Rect2 = Rect2()) -> Dictionary:
	if raiz == null:
		return {"sin_raiz": true}
	var loc := _localization()
	if loc == null or not loc.has_method("traducir_clave"):
		return {"sin_m87": true, "visitados": 0, "traducidos": 0, "saltados": 0,
			"claves": [], "ms": 0.0, "cabe_en_60fps": true}
	var traductor := Callable(loc, "traducir_clave")
	return RetraductorUI.retraducir(raiz, traductor, rect_visible)

## Suscribe el locale_changed de M87 a un callback (una sola vez).
## El callback recibe el locale nuevo; normalmente re-correrá sus etiquetas
## dinámicas. Idempotente: no duplica la conexión.
static func conectar_locale(nodo_suscriptor: Node, callback: Callable) -> bool:
	var loc := _localization()
	if loc == null or not loc.has_signal("locale_changed"):
		return false
	if nodo_suscriptor != null:
		for c in loc.locale_changed.get_connections():
			if c.callable == callback:
				return true
	loc.locale_changed.connect(callback)
	return true

## ¿La clave se resolvió a un texto del catálogo (y no al literal de la clave)?
static func clave_resuelta(clave: String) -> bool:
	return traducir(clave) != clave
