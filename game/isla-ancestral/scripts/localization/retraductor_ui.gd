class_name RetraductorUI
extends RefCounted
## M87 — Re-traducción selectiva de la UI en vivo (ítems 144 / 147 / 166 / 181).
##
## Recorre un árbol de nodos y re-traduce las propiedades de texto de los nodos
## que las exponen (`text`, `placeholder_text`, `tooltip_text`), **saltando** los
## que no pueden verse: invisibles, fuera del árbol o fuera del rectángulo
## visible. Reutiliza los nodos existentes (no crea ninguno).
##
## Por qué importa: en un HUD grande, traducir nodos que el jugador no ve es
## trabajo tirado, y ese trabajo es lo que hace que el cambio de idioma en vivo
## se note como un tirón. Saltear lo invisible es lo que mantiene el coste por
## debajo del presupuesto de 16,67 ms de un frame a 60 fps.
##
## La clave de traducción de un nodo se declara por metadato, siguiendo la
## convención de integración con M53:
##     label.set_meta("text_key", "HUD.ENERGIA")
##     boton.set_meta("tooltip_text_key", "SETTINGS.IDIOMA_DESC")
## Si no hay metadato específico de la propiedad, se usa `tr_key` como respaldo.
##
## Determinista y headless: no necesita render ni fuentes, así que su coste se
## mide en CI.

## Presupuesto de un frame a 60 fps (ms).
const PRESUPUESTO_MS_60FPS := 16.67

## Propiedades de texto que el re-traductor sabe actualizar.
const PROPS_TEXTO := ["text", "placeholder_text", "tooltip_text"]

## Clave de traducción declarada para una propiedad concreta de un nodo.
## Orden: `<prop>_key` → `tr_key` → "" (sin clave, no se toca).
static func clave_de(nodo: Node, prop: String) -> String:
	if nodo == null:
		return ""
	var especifica := "%s_key" % prop
	if nodo.has_meta(especifica):
		return str(nodo.get_meta(especifica))
	if nodo.has_meta("tr_key"):
		return str(nodo.get_meta("tr_key"))
	return ""

## Decisión pura: ¿este nodo debe re-traducirse?
## `rect_visible` vacío = no se comprueba el encuadre (solo visibilidad).
static func debe_retraducir(nodo: Node, rect_visible: Rect2 = Rect2()) -> bool:
	if nodo == null:
		return false
	if not nodo.is_inside_tree():
		return false
	var c := nodo as CanvasItem
	if c != null:
		if not c.visible:
			return false
		var ctrl := c as Control
		if ctrl != null:
			if not ctrl.is_visible_in_tree():
				return false
			if rect_visible.size.x > 0.0 and rect_visible.size.y > 0.0:
				if not rect_visible.intersects(ctrl.get_global_rect()):
					return false
	return true

## Rectángulo visible del viewport de un nodo (para pasar a `retraducir`).
static func rect_viewport(nodo: Node) -> Rect2:
	if nodo == null:
		return Rect2()
	var vp := nodo.get_viewport()
	if vp == null:
		return Rect2()
	return Rect2(Vector2.ZERO, vp.get_visible_rect().size)

## Re-traduce el árbol desde `raiz`.
##
## `traductor` es un Callable que recibe una clave y devuelve el texto traducido
## (típicamente `Localization.traducir_clave`). Se inyecta para poder testear sin
## autoloads.
##
## Devuelve { visitados, traducidos, saltados, claves, ms, cabe_en_60fps }.
static func retraducir(raiz: Node, traductor: Callable,
		rect_visible: Rect2 = Rect2()) -> Dictionary:
	var t0: int = Time.get_ticks_usec()
	var visitados := 0
	var traducidos := 0
	var saltados := 0
	var claves: Array[String] = []

	if raiz == null:
		return {
			"visitados": 0, "traducidos": 0, "saltados": 0,
			"claves": claves, "ms": 0.0, "cabe_en_60fps": true,
		}

	var pila: Array[Node] = []
	pila.append(raiz)
	while not pila.is_empty():
		var n: Node = pila.pop_back()
		visitados += 1
		if debe_retraducir(n, rect_visible):
			for prop in PROPS_TEXTO:
				if not (prop in n):
					continue
				var clave: String = clave_de(n, prop)
				if clave.is_empty():
					continue
				var nuevo: String = str(traductor.call(clave))
				if nuevo.is_empty():
					continue
				n.set(prop, nuevo)
				traducidos += 1
				if not claves.has(clave):
					claves.append(clave)
		else:
			saltados += 1
		for h in n.get_children():
			pila.append(h)

	var ms: float = float(Time.get_ticks_usec() - t0) / 1000.0
	return {
		"visitados": visitados,
		"traducidos": traducidos,
		"saltados": saltados,
		"claves": claves,
		"ms": ms,
		"cabe_en_60fps": ms <= PRESUPUESTO_MS_60FPS,
	}

## Informe legible del resultado de `retraducir()`.
static func formatear_informe(r: Dictionary) -> String:
	var lineas: PackedStringArray = PackedStringArray()
	lineas.append("── RetraductorUI: re-traducción selectiva ──")
	lineas.append("nodos visitados   : %d" % int(r.get("visitados", 0)))
	lineas.append("propiedades traducidas : %d" % int(r.get("traducidos", 0)))
	lineas.append("nodos saltados    : %d" % int(r.get("saltados", 0)))
	lineas.append("claves distintas  : %d" % (r.get("claves", []) as Array).size())
	lineas.append("coste             : %.3f ms (presupuesto 60 fps = %.2f ms)" % [
		float(r.get("ms", 0.0)), PRESUPUESTO_MS_60FPS,
	])
	lineas.append("cabe en 60 fps    : %s" % ("sí" if bool(r.get("cabe_en_60fps", false)) else "NO"))
	return "\n".join(lineas)
