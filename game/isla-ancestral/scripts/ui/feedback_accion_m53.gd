class_name FeedbackAccionM53
## M53 L138 — Feedback visual de colocacion, cosecha y compra con Tween de 120 ms.
##
## Modelo DETERMINISTA de feedback visual por accion: la tabla de amplitudes,
## la curva y la duracion viven aca como datos; el aplicador solo los consume.
## No usa `Time`, `TIME` ni azar: dos llamadas con la misma accion devuelven
## exactamente los mismos pasos.
##
## Canal UNICO (L144): este modulo NO reproduce audio, NO encola toasts y NO
## vibra. La accion ya tiene su canal de audio (M44/FeedbackDirector) y su canal
## de aviso (NotificationService); sumar un tercero seria la triple redundancia
## que L144 prohibe. `canales()` lo declara y `test_feedback_accion_m53.gd` lo
## verifica por lectura del propio fuente.
##
## Estado: modelo + aplicador + suite. NO cableado a los emisores todavia
## (0 consumidores fuera de su test) — el cableado es de M17 (colocacion),
## M16/farm (cosecha) y M95/shops (compra).

## Duracion canonica del item L138: 120 ms por paso.
const DURACION_S := 0.12

## Las tres acciones que pide el item. Orden estable (lo verifica la suite).
const ACCIONES: Array[String] = ["colocacion", "cosecha", "compra"]

## Fuente unica de color (L159): los tintes salen de la paleta del tema, no de
## literales. Si la paleta cambia, el feedback cambia con ella.
const ThemeUxRef := preload("res://scripts/ui/theme/theme_ux.gd")

## Tabla de diseño: amplitud de escala, tinte y alfa finales por accion.
##   escala  — pico de escala relativa (1.0 = sin cambio)
##   tinte   — color del flash de confirmacion (paleta ThemeUx, L159)
##   alfa    — alfa del flash en su pico
##   trans/ease — curva del Tween (misma en ida y vuelta: legible y corta)
const TABLA := {
	"colocacion": {
		"escala": 1.10,
		"tinte": ThemeUxRef.COLOR_HIGHLIGHT_GOLD,
		"alfa": 0.55,
		"trans": Tween.TRANS_QUAD,
		"ease": Tween.EASE_OUT,
	},
	"cosecha": {
		"escala": 1.14,
		"tinte": ThemeUxRef.COLOR_SPEAKER_NPC,
		"alfa": 0.50,
		"trans": Tween.TRANS_BACK,
		"ease": Tween.EASE_OUT,
	},
	"compra": {
		"escala": 1.08,
		"tinte": ThemeUxRef.COLOR_ACCENT_OCRE,
		"alfa": 0.60,
		"trans": Tween.TRANS_SINE,
		"ease": Tween.EASE_OUT,
	},
}

## Canales que este modulo usa. Uno solo, por diseño (L144).
const CANALES_USADOS: Array[String] = ["visual"]


static func existe(accion: String) -> bool:
	return TABLA.has(accion)


static func duracion_s(_accion: String) -> float:
	## Todos los pasos duran lo mismo: 120 ms. Se devuelve la constante, no una
	## copia por accion, para que no puedan divergir.
	return DURACION_S


static func canales(_accion: String) -> Array[String]:
	## Contrato de canal unico: solo visual. Nunca audio, toast ni haptico.
	return CANALES_USADOS.duplicate()


static func pasos(accion: String) -> Array[Dictionary]:
	## Devuelve los pasos del Tween como DATOS (sin crear nada).
	## Ida: escala y tinte suben al pico en 120 ms. Vuelta: bajan a neutro en 120 ms.
	## [] si la accion no existe (el llamador decide; no se inventa un default).
	var out: Array[Dictionary] = []
	if not TABLA.has(accion):
		return out
	var cfg: Dictionary = TABLA[accion]
	out.append({
		"propiedad": "scale",
		"valor": Vector2(cfg["escala"], cfg["escala"]),
		"duracion": DURACION_S,
		"trans": cfg["trans"],
		"ease": cfg["ease"],
		"fase": "ida",
	})
	out.append({
		"propiedad": "modulate",
		"valor": Color(cfg["tinte"], cfg["alfa"]),
		"duracion": DURACION_S,
		"trans": cfg["trans"],
		"ease": cfg["ease"],
		"fase": "ida",
	})
	out.append({
		"propiedad": "scale",
		"valor": Vector2.ONE,
		"duracion": DURACION_S,
		"trans": cfg["trans"],
		"ease": cfg["ease"],
		"fase": "vuelta",
	})
	out.append({
		"propiedad": "modulate",
		"valor": Color.WHITE,
		"duracion": DURACION_S,
		"trans": cfg["trans"],
		"ease": cfg["ease"],
		"fase": "vuelta",
	})
	return out


static func duracion_total_s(accion: String) -> float:
	## Suma de los pasos de UNA fase (ida o vuelta); las dos fases van en paralelo
	## por propiedad, asi que el total real es 2 x 120 ms = 240 ms.
	if not TABLA.has(accion):
		return 0.0
	return DURACION_S * 2.0


static func aplicar(nodo: Node, accion: String) -> Tween:
	## Aplica el feedback a un Control/Node2D. Devuelve el Tween o null.
	## - nodo null o accion desconocida -> null (no se crea Tween huerfano)
	## - nodo que no expone "scale"/"modulate" -> null (se evita el error de runtime)
	if nodo == null or not TABLA.has(accion):
		return null
	var props := pasos(accion)
	if props.is_empty():
		return null
	var tiene_escala := "scale" in nodo
	var tiene_modulate := "modulate" in nodo
	if not tiene_escala and not tiene_modulate:
		return null
	var tw := nodo.create_tween()
	tw.set_parallel(true)
	for p in props:
		if p["propiedad"] == "scale" and not tiene_escala:
			continue
		if p["propiedad"] == "modulate" and not tiene_modulate:
			continue
		tw.tween_property(nodo, p["propiedad"], p["valor"], p["duracion"]) \
			.set_trans(p["trans"]).set_ease(p["ease"])
	return tw
