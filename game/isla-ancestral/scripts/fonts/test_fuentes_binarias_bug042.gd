# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-18
#
# BUG-042 — Sonda de integridad de las FUENTES binarias.
#
# Por que existe: scripts/fonts/test_fonts_m88.gd prueba el CATALOGO (ids,
# familias, licencias) pero NUNCA carga un archivo de fuente. Resultado medido:
# el suite daba verde mientras 3 de las 4 `.ttf` del repo eran la pagina
# `Page not found . GitHub` guardada con extension `.ttf`. Falso verde
# estructural: el test no tocaba la capa donde estaba el bug.
#
# Esta sonda prueba la cadena REAL de produccion (`theme_ux.gd` L23-25 usa
# `FontFile.load_dynamic_font`) y no se conforma con `err == OK`:
#   - `load_dynamic_font()` sobre una pagina HTML devuelve un FontFile NO nulo
#     con las metricas en cero. `err == OK` NO alcanza para afirmar que hay
#     fuente. Hay que MEDIR (`get_string_size(...).x > 0`).
# El bloque E demuestra ese modo de fallo con un control negativo real.
#
# Guardas anti-falso-verde: marcadores `_fin()` por bloque (un SCRIPT ERROR
# aborta la funcion en silencio), piso de checks y `_summary()` en un
# `call_deferred` aparte (un watchdog en `_process` NO termina el proceso).

extends SceneTree

const RUTA_TEMA := "res://scripts/ui/theme/theme_ux.gd"
const TEXTO_BASE := "Jugar"
const TEXTO_ESPECIAL := "ñÑáéíóú¿¡"
const BLOQUES := ["A", "B", "C", "D", "E", "F", "G"]
const CHECKS_MINIMOS := 22  # real medido en verde; cualquier aborto lo baja
const TAM_BASE := 16
const TAM_GRANDE := 24
const FIJO_FALSO := "user://bug042_falso.ttf"
const HTML_404 := "<!DOCTYPE html><html><head><title>Page not found · GitHub</title></head><body>404</body></html>"

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _fin(nombre: String) -> void:
	_vistos[nombre] = true

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

## Carga una fuente por la MISMA via que produccion y devuelve el FontFile.
func _cargar(ruta: String) -> FontFile:
	var f := FontFile.new()
	f.load_dynamic_font(ruta)
	return f

## Ancho medido. `-1` de ancho para no truncar (trampa 55: con ancho positivo
## get_string_size recorta y devuelve la altura de UNA linea).
func _ancho(f: Font, texto: String, tam: int) -> float:
	return f.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x

## Rutas que el tema usa de verdad, leidas del propio script (no hardcodeadas).
func _rutas_del_tema() -> Array:
	var rutas: Array = []
	if not FileAccess.file_exists(RUTA_TEMA):
		return rutas
	var texto := FileAccess.get_file_as_string(RUTA_TEMA)
	var re := RegEx.new()
	re.compile("PATH_FONT_[A-Z_]+\\s*:=\\s*\"([^\"]+)\"")
	for m in re.search_all(texto):
		var r := m.get_string(1)
		if not rutas.has(r):
			rutas.append(r)
	return rutas

func _run() -> void:
	print("=== [BUG-042] Integridad de las fuentes binarias ===")

	# --- A: cada archivo declarado carga ---------------------------------
	print("--- A. Carga por load_dynamic_font ---")
	var rutas := _rutas_del_tema()
	_check("el tema declara rutas de fuente (>=3)", rutas.size() >= 3, "rutas=%s" % str(rutas))
	var fuentes: Dictionary = {}
	for r in rutas:
		var f := _cargar(r)
		fuentes[r] = f
		_check("existe el archivo %s" % r.get_file(), FileAccess.file_exists(r))
	_fin("A")

	# --- B: metricas > 0 (la prueba que de verdad importa) ---------------
	print("--- B. Metricas reales (load() no nulo NO alcanza) ---")
	for r in rutas:
		var f: FontFile = fuentes[r]
		var w := _ancho(f, TEXTO_BASE, TAM_BASE)
		_check("mide texto %s (%s)" % [TEXTO_BASE, r.get_file()], w > 0.0,
			"ancho=%.1f px (0.0 = fuente vacia)" % w)
	_fin("B")

	# --- C: caracteres que el diseno exige (RF5 tildes, RF6 enie, RF7 signos)
	print("--- C. Cobertura de caracteres del diseno ---")
	for r in rutas:
		var f: FontFile = fuentes[r]
		var faltan: Array = []
		for ch in TEXTO_ESPECIAL:
			if _ancho(f, ch, TAM_BASE) <= 0.0:
				faltan.append(ch)
		_check("soporta tildes/enie/signos (%s)" % r.get_file(), faltan.is_empty(),
			"faltan: %s" % str(faltan))
	_fin("C")

	# --- D: la escala crece (una fuente vacia no escala) -----------------
	print("--- D. Monotonia de escala ---")
	for r in rutas:
		var f: FontFile = fuentes[r]
		var w16 := _ancho(f, TEXTO_BASE, TAM_BASE)
		var w24 := _ancho(f, TEXTO_BASE, TAM_GRANDE)
		_check("24 px mide mas que 16 px (%s)" % r.get_file(), w24 > w16,
			"16=%.1f 24=%.1f" % [w16, w24])
	_fin("D")

	# --- E: control NEGATIVO — el modo de fallo de BUG-042 ---------------
	print("--- E. Control negativo: HTML disfrazado de .ttf ---")
	var w_falso := -1.0
	var err_falso := -999
	var fh := FileAccess.open(FIJO_FALSO, FileAccess.WRITE)
	if fh == null:
		_check("pude escribir el fixture falso", false)
	else:
		fh.store_string(HTML_404)
		fh.close()
		_check("fixture falso escrito (%d bytes de HTML)" % HTML_404.length(),
			FileAccess.file_exists(FIJO_FALSO))
		var falso := FontFile.new()
		err_falso = falso.load_dynamic_font(FIJO_FALSO)
		w_falso = _ancho(falso, TEXTO_BASE, TAM_BASE)
		# Hallazgo central de BUG-042: el error NO es visible (err=OK) y el
		# objeto NO es nulo, pero no hay un solo glifo. Solo la MEDICION delata.
		print("      (informativo) load_dynamic_font -> err=%d (OK=0), ancho=%.1f px"
			% [err_falso, w_falso])
		_check("el HTML disfrazado NO mide texto (asi se delata)", w_falso <= 0.0,
			"ancho=%.1f px: si midiera, el control negativo no probaria nada" % w_falso)
	_fin("E")

	# --- F: contraste real vs falso en la MISMA medicion -----------------
	print("--- F. La medicion distingue real de falso ---")
	var real: FontFile = fuentes[rutas[0]]
	var w_real := _ancho(real, TEXTO_BASE, TAM_BASE)
	_check("una fuente real mide > 0", w_real > 0.0, "ancho=%.1f" % w_real)
	_check("la medicion discrimina real (%.1f px) de falso (%.1f px)" % [w_real, w_falso],
		w_real > 0.0 and w_falso <= 0.0)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FIJO_FALSO))
	_check("fixture falso limpiado", not FileAccess.file_exists(FIJO_FALSO))
	_fin("F")

	# --- G: la guarda de PRODUCCION (theme_ux._try_load_font) ------------
	# Prueba por inyeccion: con el codigo anterior (`if err == OK: return`), el
	# HTML disfrazado PASABA y `con_falso` habria sido el FontFile vacio, no la
	# reserva. Si este bloque no discriminara, la guarda de produccion seria
	# decorativa.
	print("--- G. Guarda de produccion: _try_load_font rechaza el falso ---")
	var tema := ThemeUx.new()
	var reserva: Font = ThemeDB.fallback_font
	_check("ThemeUx expone _try_load_font", tema.has_method("_try_load_font"))
	var con_real: Font = tema._try_load_font(rutas[0], reserva)
	_check("acepta una fuente real (no cae a la reserva)", con_real != reserva)
	_check("la fuente devuelta mide texto", _ancho(con_real, TEXTO_BASE, TAM_BASE) > 0.0,
		"ancho=%.1f" % _ancho(con_real, TEXTO_BASE, TAM_BASE))
	var fh2 := FileAccess.open(FIJO_FALSO, FileAccess.WRITE)
	if fh2 == null:
		_check("pude reescribir el fixture falso para G", false)
	else:
		fh2.store_string(HTML_404)
		fh2.close()
		var con_falso: Font = tema._try_load_font(FIJO_FALSO, reserva)
		_check("RECHAZA el HTML disfrazado y devuelve la reserva", con_falso == reserva,
			"devolvio %s en vez de la reserva" % str(con_falso))
		DirAccess.remove_absolute(ProjectSettings.globalize_path(FIJO_FALSO))
	_fin("G")

func _summary() -> void:
	print("")
	var faltantes: Array = []
	for n in BLOQUES:
		if not _vistos.has(n):
			faltantes.append(n)
	if not faltantes.is_empty():
		_checks += 1
		_fallos += 1
		print("  [FAIL] bloques que NO se ejecutaron (posible SCRIPT ERROR): %s" % str(faltantes))
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen BUG-042: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST BUG-042 FALLIDO — salida con codigo 1")
		quit(1)
	else:
		print("TEST BUG-042 OK — las 3 fuentes son binarios reales y miden texto")
		quit(0)
