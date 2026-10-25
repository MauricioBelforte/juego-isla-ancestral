# M53 L138 — Suite del modelo de feedback visual de 120 ms.
#
# Verifica `feedback_accion_m53.gd`: duracion canonica, tabla completa, pasos
# deterministas, canal UNICO (L144: ni audio ni toast) y aplicador que no deja
# Tweens huerfanos.
#
# Guardia de 3 capas (protocolo del proyecto):
#   1. BLOQUES: si un bloque no corre, se NOMBRA en el resumen y el exit es 1.
#   2. CHECKS_MINIMOS: piso MEDIDO en verde; si baja, falla (suite muerta).
#   3. _summary() diferido en call_deferred: publica DESPUES de los bloques.
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/ui/test_feedback_accion_m53.gd

extends SceneTree

const BLOQUES: Array[String] = ["A", "B", "C", "D", "E", "F"]
const CHECKS_MINIMOS := 64  # MEDIDO en verde 2026-10-25 (64 checks, 0 fallos, bloques 6/6)

const RUTA_FUENTE := "res://scripts/ui/feedback_accion_m53.gd"

## Se preloadea el modulo en vez de depender del registro global de class_name:
## con `--script` headless el cache de clases globales puede no estar refrescado.
const FB := preload("res://scripts/ui/feedback_accion_m53.gd")

var _checks: int = 0
var _fallos: int = 0
var _corridos: Array[String] = []
var _fuente: String = ""
var _codigo: String = ""


func _init() -> void:
	call_deferred("_run")


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)


func _fin(bloque: String) -> void:
	_corridos.append(bloque)


func _run() -> void:
	_fuente = _leer_fuente()
	# La guardia estructural mira SOLO codigo: el docstring del modulo nombra a
	# proposito los canales que NO usa (para documentar el contrato), y contarlo
	# como violacion seria un falso positivo del propio guardian.
	_codigo = _solo_codigo(_fuente)
	_bloque_a_constantes()
	_bloque_b_tabla()
	_bloque_c_pasos_deterministas()
	_bloque_d_canal_unico()
	await _bloque_e_aplicador()
	_bloque_f_sin_reloj_ni_azar()
	call_deferred("_summary")


func _leer_fuente() -> String:
	var f := FileAccess.open(RUTA_FUENTE, FileAccess.READ)
	if f == null:
		return ""
	var txt := f.get_as_text()
	f.close()
	return txt


## Quita comentarios de linea completa y de cola, para auditar solo CODIGO.
func _solo_codigo(txt: String) -> String:
	var out: PackedStringArray = PackedStringArray()
	for linea in txt.split("\n"):
		if linea.strip_edges().begins_with("#"):
			continue
		var idx := linea.find("#")
		out.append(linea.substr(0, idx) if idx >= 0 else linea)
	return "\n".join(out)


func _bloque_a_constantes() -> void:
	_check(FB.DURACION_S == 0.12, "DURACION_S es 0.12 (120 ms)")
	_check(FB.ACCIONES.size() == 3, "3 acciones declaradas")
	_check(FB.ACCIONES == ["colocacion", "cosecha", "compra"],
		"acciones exactas y en orden estable")
	for a in FB.ACCIONES:
		_check(FB.duracion_s(a) == 0.12,
			"duracion_s(%s) == 0.12" % a)
		_check(is_equal_approx(FB.duracion_total_s(a), 0.24),
			"duracion_total_s(%s) == 0.24 (2 fases de 120 ms)" % a)
	_fin("A")


func _bloque_b_tabla() -> void:
	var claves := ["escala", "tinte", "alfa", "trans", "ease"]
	for a in FB.ACCIONES:
		_check(FB.existe(a), "tabla tiene '%s'" % a)
		if not FB.existe(a):
			continue
		var cfg: Dictionary = FB.TABLA[a]
		var faltan: Array = []
		for k in claves:
			if not cfg.has(k):
				faltan.append(k)
		_check(faltan.is_empty(), "'%s' tiene las 5 claves (faltan %s)" % [a, faltan])
		var esc: float = float(cfg.get("escala", 0.0))
		_check(esc >= 1.0 and esc <= 1.3, "'%s' escala en rango 1.0-1.3 (%.3f)" % [a, esc])
		var alfa: float = float(cfg.get("alfa", -1.0))
		_check(alfa >= 0.0 and alfa <= 1.0, "'%s' alfa en rango 0-1 (%.3f)" % [a, alfa])
		var tinte: Color = cfg.get("tinte", Color.BLACK)
		_check(tinte.a > 0.0, "'%s' tinte opaco" % a)
	_check(not FB.existe("accion_inventada"),
		"accion inexistente NO esta en la tabla")
	_fin("B")


func _bloque_c_pasos_deterministas() -> void:
	for a in FB.ACCIONES:
		var p1: Array = FB.pasos(a)
		var p2: Array = FB.pasos(a)
		_check(p1.size() == 4, "'%s' devuelve 4 pasos (medido %d)" % [a, p1.size()])
		_check(p1 == p2, "'%s' pasos deterministas (2 llamadas identicas)" % a)
		var todas_120 := true
		for p in p1:
			if not is_equal_approx(float(p["duracion"]), 0.12):
				todas_120 = false
		_check(todas_120, "'%s' todos los pasos duran 120 ms" % a)
		var props: Array = []
		for p in p1:
			props.append(p["propiedad"])
		_check(props.count("scale") == 2, "'%s' toca scale en ida y vuelta" % a)
		_check(props.count("modulate") == 2, "'%s' toca modulate en ida y vuelta" % a)
	_check(FB.pasos("accion_inventada").is_empty(),
		"accion inexistente devuelve [] (no inventa default)")
	_fin("C")


func _bloque_d_canal_unico() -> void:
	for a in FB.ACCIONES:
		var c: Array = FB.canales(a)
		_check(c == ["visual"], "'%s' declara canal unico visual (medido %s)" % [a, c])
	# Guardia estructural: el fuente del modulo no puede nombrar los otros canales.
	_check(_fuente.length() > 500, "fuente del modulo legible (%d bytes)" % _fuente.length())
	var prohibidos := ["AudioStreamPlayer", "notif.push", "NotificationService", "UIFeedback",
		"play_sfx", "vibrate", "haptic"]
	for token in prohibidos:
		_check(not _codigo.contains(token),
			"fuente sin canal ajeno '%s' en CODIGO (L144)" % token)
	_fin("D")


func _bloque_e_aplicador() -> void:
	var nodo := Control.new()
	root.add_child(nodo)
	var tw: Tween = FB.aplicar(nodo, "cosecha")
	_check(tw != null, "aplicar() devuelve un Tween valido sobre Control")
	_check(tw != null and tw.is_valid(), "el Tween esta activo")
	# Esperar a que corran las dos fases (2 x 120 ms) + margen.
	await create_timer(0.40).timeout
	_check(is_equal_approx(nodo.scale.x, 1.0), "escala vuelve a 1.0 al terminar (%.4f)"
		% nodo.scale.x)
	_check(nodo.modulate.is_equal_approx(Color.WHITE), "modulate vuelve a blanco al terminar")
	_check(FB.aplicar(null, "cosecha") == null,
		"aplicar(null) devuelve null sin crash")
	_check(FB.aplicar(nodo, "accion_inventada") == null,
		"aplicar() con accion desconocida devuelve null")
	var nodo_sin_props := Node.new()
	root.add_child(nodo_sin_props)
	_check(FB.aplicar(nodo_sin_props, "compra") == null,
		"nodo sin scale ni modulate devuelve null (sin error de runtime)")
	nodo.queue_free()
	nodo_sin_props.queue_free()
	_fin("E")


func _bloque_f_sin_reloj_ni_azar() -> void:
	var prohibidos := ["Time.get_ticks", "randf(", "randi(", "TIME"]
	for token in prohibidos:
		_check(not _codigo.contains(token), "fuente determinista: sin '%s' en CODIGO" % token)
	_check(_fuente.contains("0.12") or _fuente.contains("DURACION_S := 0.12"),
		"la duracion 120 ms esta en el fuente")
	_fin("F")


func _summary() -> void:
	var faltantes: Array = []
	for b in BLOQUES:
		if not _corridos.has(b):
			faltantes.append(b)
	if not faltantes.is_empty():
		_fallos += faltantes.size()
		print("FALLO: bloques que NO corrieron: %s" % [faltantes])
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("FALLO: piso de checks %d < %d (suite muerta)" % [_checks, CHECKS_MINIMOS])
	print("=== TEST M53 FEEDBACK 120MS: %d checks, %d fallo(s), bloques %d/%d (piso %d) ==="
		% [_checks, _fallos, _corridos.size(), BLOQUES.size(), CHECKS_MINIMOS])
	quit(1 if _fallos > 0 else 0)
