extends Node

## Autoload de paleta oficial de marca (M128 H1).
## Colores centralizados segun DOCUMENTACION/128-Identidad-De-Marca/plan-actual/03-Diseno.md §3.
## Tambien expone un helper de contraste WCAG 2.1 (usado por el test H3).
##
## Sin class_name: el nombre "BrandConfig" es el singleton autoload y colisionaria
## (igual que AssetProfile). Solo datos + funciones puras, sin _ready (boot trivial).

const COLORES := {
	"azul_bosque":   Color("#2E5A4C"),
	"dorado_anciano": Color("#D4A843"),
	"blanco_perla":  Color("#F5F0E8"),
	"verde_hoja":    Color("#5A8A6C"),
	"terracota":     Color("#C47A5A"),
	"cielo_claro":   Color("#8AB4D4"),
	"carbon":        Color("#2C2C2C"),
	"gris_piedra":   Color("#6B6B6B"),
	"crema":         Color("#FAF8F5"),
}

## Devuelve el Color oficial por nombre (o Color negro si no existe).
func color(nombre: String) -> Color:
	if COLORES.has(nombre):
		return COLORES[nombre]
	return Color(0, 0, 0, 1)

## Luminancia relativa WCAG 2.1 (canal en espacio lineal).
func _rel_lum(c: Color) -> float:
	var lin := []
	for v in [c.r, c.g, c.b]:
		if v <= 0.03928:
			lin.append(v / 12.92)
		else:
			lin.append(pow((v + 0.055) / 1.055, 2.4))
	return 0.2126 * lin[0] + 0.7152 * lin[1] + 0.0722 * lin[2]

## Contraste WCAG 2.1 entre dos colores (>= 1.0; mayor = mas contraste).
func contraste_wcag(a: Color, b: Color) -> float:
	var l1 := _rel_lum(a)
	var l2 := _rel_lum(b)
	if l1 < l2:
		var t := l1
		l1 = l2
		l2 = t
	return (l1 + 0.05) / (l2 + 0.05)
