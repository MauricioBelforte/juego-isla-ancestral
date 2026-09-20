# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-20
#
# M103: Logging — medicion del impacto en el frame budget (iter. 2, Log 1109).
#
# Cierra por MEDICION el item `[?]` de L199 del checklist ("Definir impacto
# maximo en frame budget (< 0.5%)"), que estaba delegado a M61 con la nota
# "no hay medicion". El *objetivo de build* y su aprobacion siguen siendo de
# M61; lo que este test aporta es la cifra REAL y repetible del coste de una
# llamada al logger, que es lo que faltaba para poder decidir.
#
# Por que se puede medir headless: el coste del logger no depende de la GPU ni
# del render; es CPU + IO. Lo que NO es medible headless es el frame completo.
#
# ⚠️ Metodologia (trampa 78): un benchmark de UNA sola pasada y orden fijo miente
# porque la primera variante paga el arranque en frio. Aca:
#   (a) RONDAS INTERCALADAS — en cada ronda se miden TODAS las variantes;
#   (b) MINIMO por variante (descarta warm-up y ruido del asignador);
#   (c) la suite se corre x3 y se comprueba que el SIGNO del resultado no cambia.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://scripts/logging/test_m103_frame_budget.gd

extends SceneTree

const MODULO := "M103 frame-budget"
const BLOQUES_ESPERADOS: Array[String] = ["A", "B", "C"]
const CHECKS_MINIMOS := 9

const RONDAS := 5
const ITERACIONES := 200
const PRESUPUESTO_FRAME_MS := 16.67   # 60 FPS
const LIMITE_PCT := 0.5               # el criterio de aceptacion del item

const LV_INFO := 1
const LV_WARNING := 2
const LV_ERROR := 4

var _fallos: int = 0
var _checks: int = 0
var _completados: Array[String] = []
var _checks_por_bloque: Dictionary = {}
var _checks_marca: int = 0

var _log: Node = null
var _tmp := "user://test_m103_budget/bench.log"
var _min_gate: int = 1 << 60
var _min_filtrada: int = 1 << 60
var _min_escritura: int = 1 << 60
var _min_disco: int = 1 << 60

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _fin(nombre: String) -> void:
	var letra: String = nombre.substr(0, 1)
	if not _completados.has(letra):
		_completados.append(letra)
	var delta: int = _checks - _checks_marca
	_checks_por_bloque[letra] = int(_checks_por_bloque.get(letra, 0)) + delta
	_checks_marca = _checks
	print("[FIN] %s (+%d checks)" % [nombre, delta])

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s%s" % [nombre, "" if detalle.is_empty() else "  << %s" % detalle])

func _run() -> void:
	# ── A. Preparacion ──
	_log = root.get_node_or_null("GameLogger")
	_check("autoload GameLogger presente", _log != null)
	if _log == null:
		return
	_log.set_log_path(_tmp)
	_check("set_log_path acepta un path temporal de test", _log.get_log_file_path() == _tmp)
	_check("API de medicion disponible (is_level_enabled)", _log.has_method("is_level_enabled"))
	_fin("A. Preparación")

	# ── B. Medicion (rondas intercaladas, minimo por variante) ──
	# Variante 1: el GATE solo (lo que cuesta preguntar si el nivel pasa).
	# Variante 2: llamada FILTRADA (nivel por debajo de min_level -> debe salir
	#             por el gate sin formatear ni escribir).
	# Variante 3: llamada que ESCRIBE (formatea + sanitiza + disco + flush).
	for ronda in RONDAS:
		_min_gate = mini(_min_gate, _medir_gate())
		_min_filtrada = mini(_min_filtrada, _medir_filtrada())
		_min_escritura = mini(_min_escritura, _medir_escritura())
		_min_disco = mini(_min_disco, _medir_disco())

	_check("se midieron las 4 variantes en %d rondas" % RONDAS,
		_min_gate < (1 << 60) and _min_filtrada < (1 << 60) and _min_escritura < (1 << 60) and _min_disco < (1 << 60))
	_check("la llamada FILTRADA cuesta menos que la que ESCRIBE (el gate corta antes de formatear)",
		_min_filtrada < _min_escritura,
		"filtrada=%d us  escritura=%d us" % [_min_filtrada, _min_escritura])
	# El gate debe evitar la MAYOR PARTE del coste. Se compara contra la llamada
	# que escribe, NO contra `is_level_enabled` solo: entre el gate y la llamada
	# filtrada esta el formateo del string en el SITIO DE LLAMADA (`"... %d" % k`),
	# que ninguna API puede evitar. Comparar con el gate daba 8x y era una
	# expectativa mal calibrada, no un defecto.
	_check("la llamada FILTRADA cuesta menos del 5%% de la que ESCRIBE (el gate evita el 95%% del coste)",
		float(_min_filtrada) < float(_min_escritura) * 0.05,
		"filtrada=%d us  escritura=%d us" % [_min_filtrada, _min_escritura])
	# Invariante: escribir incluye el `print()` de consola ADEMAS del disco, asi
	# que su coste debe superar al de solo-disco. (NO se afirma que el coste sea
	# aceptable ni inaceptable: eso es lo que se REPORTA abajo. Afirmar el defecto
	# seria consagrarlo — trampa 88.)
	_check("escribir cuesta mas que solo el disco (=> el coste NO es el disco)",
		_min_escritura > _min_disco,
		"escritura=%d us  solo_disco=%d us" % [_min_escritura, _min_disco])
	_fin("B. Medición")

	# ── C. Veredicto contra el presupuesto (medicion, no aprobacion de build) ──
	var presupuesto_us: float = PRESUPUESTO_FRAME_MS * 1000.0 * (LIMITE_PCT / 100.0)
	var us_gate: float = float(_min_gate) / float(ITERACIONES)
	var us_filtrada: float = float(_min_filtrada) / float(ITERACIONES)
	var us_escritura: float = float(_min_escritura) / float(ITERACIONES)
	var us_disco: float = float(_min_disco) / float(ITERACIONES)
	var cabe_filtradas: int = int(floor(presupuesto_us / maxf(us_filtrada, 0.001)))
	var cabe_escrituras: int = int(floor(presupuesto_us / maxf(us_escritura, 0.001)))

	print("-- presupuesto: %.2f%% de %.2f ms (60 FPS) = %.2f us por frame" % [LIMITE_PCT, PRESUPUESTO_FRAME_MS, presupuesto_us])
	print("-- coste medido por llamada (MINIMO de %d rondas x %d iteraciones):" % [RONDAS, ITERACIONES])
	print("     gate is_level_enabled ....... %.3f us" % us_gate)
	print("     llamada FILTRADA ............ %.3f us   (caben %d por frame en el 0.5%%)" % [us_filtrada, cabe_filtradas])
	print("     solo disco (store+flush) .... %.3f us" % us_disco)
	print("     llamada que ESCRIBE (total).. %.3f us   (caben %d por frame en el 0.5%%)" % [us_escritura, cabe_escrituras])
	print("-- ATRIBUCION del coste de escribir: disco=%.0f%%  resto(consola+formato)=%.0f%%" % [
		100.0 * us_disco / maxf(us_escritura, 0.001),
		100.0 * (1.0 - us_disco / maxf(us_escritura, 0.001))])
	print("-- OJO: el coste de la consola depende del DESTINO de stdout (tuberia ~35x mas caro que archivo).")

	_check("una llamada FILTRADA cabe holgadamente en el presupuesto de 0.5%% de frame",
		us_filtrada <= presupuesto_us,
		"%.3f us vs %.2f us" % [us_filtrada, presupuesto_us])
	_check("el presupuesto admite al menos 10 llamadas FILTRADAS por frame", cabe_filtradas >= 10, "caben=%d" % cabe_filtradas)
	_fin("C. Veredicto")


func _medir_gate() -> int:
	var t0: int = Time.get_ticks_usec()
	for k in ITERACIONES:
		_log.is_level_enabled(LV_INFO)
	return Time.get_ticks_usec() - t0


func _medir_filtrada() -> int:
	_log.set_min_level(LV_ERROR)
	var t0: int = Time.get_ticks_usec()
	for k in ITERACIONES:
		_log.info("bench filtrada %d" % k)
	return Time.get_ticks_usec() - t0


func _medir_escritura() -> int:
	_log.set_min_level(LV_WARNING)
	var t0: int = Time.get_ticks_usec()
	for k in ITERACIONES:
		_log.warning("bench escritura %d" % k, _log.Category.SYSTEM)
	return Time.get_ticks_usec() - t0


## Control: solo el disco (store_line + flush por linea), SIN consola ni formato
## ni sanitizado. Sirve para ATRIBUIR: si escribir costara lo mismo que esto, el
## cuello seria el disco; si cuesta mucho mas, el cuello esta en otro sitio.
func _medir_disco() -> int:
	var f := FileAccess.open(_tmp + ".ctrl", FileAccess.WRITE)
	if f == null:
		return 1 << 60
	var t0: int = Time.get_ticks_usec()
	for k in ITERACIONES:
		f.store_line("bench control %d" % k)
		f.flush()
	var t: int = Time.get_ticks_usec() - t0
	f.close()
	DirAccess.remove_absolute(_tmp + ".ctrl")
	return t


func _summary() -> void:
	var faltantes: Array[String] = []
	for b in BLOQUES_ESPERADOS:
		if not _completados.has(b):
			faltantes.append(b)
	if not faltantes.is_empty():
		_check("los %d bloques se completaron — no terminaron: %s" % [BLOQUES_ESPERADOS.size(), str(faltantes)], false)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FALLO] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	# Limpieza del path temporal
	DirAccess.remove_absolute(_tmp)
	DirAccess.remove_absolute(_tmp + ".1.gz")
	print("-- checks por bloque: %s" % str(_checks_por_bloque))
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con código 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — todos los checks pasaron" % MODULO)
		quit(0)
