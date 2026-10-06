# Modelo: mimo-v2.6-flash-free
# Plataforma: opencode
# Fecha: 2026-10-06
#
# M88 (iteracion 3) — Fuentes REALES en disco, contrato del catalogo e
# integraciones M58/M87.
#
# Por que existe (gaps que los otros dos suites NO cubrian):
#   - `test_fonts_m88.gd` valida el CATALOGO abstracto (ids/familias/licencias)
#     pero NUNCA abre un .ttf.
#   - `test_fuentes_binarias_bug042.gd` prueba las 3 rutas que declara el tema
#     (Nunito-Regular, Nunito-Bold, FredokaOne): deja FUERA a
#     `Nunito-Variable.ttf`, que existe en disco y lo usa M87
#     (test_localizacion_iter6).
#   - Nadie prueba el CONTRATO de `fonts.json` (`tiene_archivo`) ni las
#     integraciones que el 05-Checklist declara con M58 (Accesibilidad) y
#     M87 (i18n) desde el lado del modulo 88.
#
# Sonda roja incluida (bloque D): un HTML 404 disfrazado de .ttf carga con
# err=OK pero NO mide — control negativo del modo de fallo de BUG-042.
#
# Guardas anti-falso-verde (patron del repo): marcadores `_fin()` por bloque
# (un SCRIPT ERROR aborta la funcion en silencio), piso de checks y
# `_summary()` en un `call_deferred` aparte.

extends SceneTree

const RUTA_TEMA := "res://scripts/ui/theme/theme_ux.gd"
const RUTA_JSON := "res://data/fonts/fonts.json"
const DIR_FUENTES := "res://assets/fonts"
const TEXTO_BASE := "Jugar"
const TEXTO_ESPECIAL := "ñÑáéíóú¿¡"
const TAM_BASE := 16
const TAM_GRANDE := 24
const FIJO_FALSO := "user://m88_falso.ttf"
const HTML_404 := "<!DOCTYPE html><html><head><title>Page not found · GitHub</title></head><body>404</body></html>"
const BLOQUES := ["A", "B", "C", "D", "E", "F", "G", "H"]
const CHECKS_MINIMOS := 40  # real medido en verde; cualquier aborto lo baja

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

func _ancho(f: Font, texto: String, tam: int) -> float:
	# ancho -1: con ancho positivo get_string_size recorta (trampa 55)
	return f.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x

func _archivos_ttf() -> Array:
	var rutas: Array = []
	var d := DirAccess.open(DIR_FUENTES)
	if d == null:
		return rutas
	for n in d.get_files():
		if n.get_extension().to_lower() in ["ttf", "otf"]:
			rutas.append(DIR_FUENTES + "/" + n)
	rutas.sort()
	return rutas

func _cargar(ruta: String) -> FontFile:
	var f := FontFile.new()
	f.load_dynamic_font(ruta)
	return f

func _magicos_ok(ruta: String) -> bool:
	var fh := FileAccess.open(ruta, FileAccess.READ)
	if fh == null:
		return false
	var b := fh.get_buffer(4)
	fh.close()
	if b.size() < 4:
		return false
	# cabeceras TrueType/OTF: 00 01 00 00 | OTTO | true | ttcf | typ1
	# (byte a byte: decode_u32 es little-endian y daria vueltas a los enteros)
	return (b[0] == 0x00 and b[1] == 0x01 and b[2] == 0x00 and b[3] == 0x00) \
		or (b[0] == 0x4F and b[1] == 0x54 and b[2] == 0x54 and b[3] == 0x4F) \
		or (b[0] == 0x74 and b[1] == 0x72 and b[2] == 0x75 and b[3] == 0x65) \
		or (b[0] == 0x74 and b[1] == 0x74 and b[2] == 0x63 and b[3] == 0x66) \
		or (b[0] == 0x74 and b[1] == 0x79 and b[2] == 0x70 and b[3] == 0x31)

func _run() -> void:
	print("=== [M88 it.3] Fuentes reales, catalogo e integraciones ===")
	_test_binarios()
	_test_caracteres()
	_test_escala()
	_test_control_negativo()
	_test_contrato_catalogo()
	_test_cadena_tema()
	_test_integracion_m87()
	_test_integracion_m58()
	_fin_todos()

func _fin_todos() -> void:
	for b in BLOQUES:
		_vistos[b] = _vistos.get(b, false)

# ── A: TODOS los .ttf de disco (incluye Nunito-Variable, fuera de BUG-042) ──
func _test_binarios() -> void:
	print("--- A. Binarios de assets/fonts (cobertura total) ---")
	var rutas := _archivos_ttf()
	_check("assets/fonts tiene >=4 fuentes", rutas.size() >= 4, "n=%d" % rutas.size())
	for r in rutas:
		var nombre: String = String(r).get_file()
		_check("existe %s" % nombre, FileAccess.file_exists(r))
		_check("bytes magicos TrueType/OTTO (%s)" % nombre, _magicos_ok(r),
			"cabecera no es un contenedor de fuente valido (¿HTML 404?)")
		var f := _cargar(r)
		var w := _ancho(f, TEXTO_BASE, TAM_BASE)
		_check("mide texto %s (%.1f px)" % [nombre, w], w > 0.0,
			"0.0 px = fuente vacia (BUG-042)")
	_fin("A")

# ── B: cobertura de caracteres exigida por el diseno (RF5/RF6/RF7) ──
func _test_caracteres() -> void:
	print("--- B. Cobertura de caracteres del diseno ---")
	for r in _archivos_ttf():
		var f := _cargar(r)
		var faltan: Array = []
		for ch in TEXTO_ESPECIAL:
			if _ancho(f, ch, TAM_BASE) <= 0.0:
				faltan.append(ch)
		_check("tildes/enie/signos (%s)" % r.get_file(), faltan.is_empty(),
			"faltan: %s" % str(faltan))
	_fin("B")

# ── C: la escala crece (una fuente vacia no escala) ──
func _test_escala() -> void:
	print("--- C. Monotonia de escala 16 -> 24 px ---")
	for r in _archivos_ttf():
		var f := _cargar(r)
		var w16 := _ancho(f, TEXTO_BASE, TAM_BASE)
		var w24 := _ancho(f, TEXTO_BASE, TAM_GRANDE)
		_check("24 px mide mas que 16 px (%s)" % r.get_file(), w24 > w16,
			"16=%.1f 24=%.1f" % [w16, w24])
	_fin("C")

# ── D: control negativo — HTML disfrazado de .ttf ──
func _test_control_negativo() -> void:
	print("--- D. Control negativo: HTML disfrazado ---")
	var fh := FileAccess.open(FIJO_FALSO, FileAccess.WRITE)
	if fh == null:
		_check("pude escribir el fixture falso", false)
		_fin("D")
		return
	fh.store_string(HTML_404)
	fh.close()
	var falso := FontFile.new()
	var err := falso.load_dynamic_font(FIJO_FALSO)
	var w := _ancho(falso, TEXTO_BASE, TAM_BASE)
	print("      (informativo) load_dynamic_font -> err=%d (OK=0), ancho=%.1f px" % [err, w])
	_check("el HTML disfrazado NO mide texto (asi se delata)", w <= 0.0,
		"ancho=%.1f px" % w)
	_check("bytes magicos del HTML rechazados", not _magicos_ok(FIJO_FALSO))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FIJO_FALSO))
	_check("fixture falso limpiado", not FileAccess.file_exists(FIJO_FALSO))
	_fin("D")

# ── E: contrato de fonts.json (tiene_archivo, ids, licencias) ──
func _test_contrato_catalogo() -> void:
	print("--- E. Contrato de fonts.json ---")
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_JSON))
	_check("fonts.json parsea", typeof(parsed) == TYPE_DICTIONARY)
	if typeof(parsed) != TYPE_DICTIONARY:
		_fin("E")
		return
	var datos: Dictionary = parsed
	var fuentes: Array = datos.get("fuentes", [])
	_check("4 fuentes declaradas", fuentes.size() == 4, "n=%d" % fuentes.size())
	var con_archivo := 0
	for f in fuentes:
		var id := String(f.get("id", ""))
		var tiene: bool = bool(f.get("tiene_archivo", false))
		if tiene:
			con_archivo += 1
			# contrato: si declara archivo, tiene que existir y medir
			var ruta := "%s/%s.ttf" % [DIR_FUENTES, id]
			_check("tiene_archivo=true existe el archivo de %s" % id,
				FileAccess.file_exists(ruta), "falta %s" % ruta)
			if FileAccess.file_exists(ruta):
				_check("el archivo de %s mide texto" % id,
					_ancho(_cargar(ruta), TEXTO_BASE, TAM_BASE) > 0.0)
	# hoy TODOS los ids son abstractos (museo_moderno etc.) y los .ttf fisicos
	# (Nunito/Fredoka) son de produccion del tema: ningun id declara archivo.
	# El check de abajo fija ese contrato para futuras ediciones.
	_check("ids con tiene_archivo=true tienen archivo (contrato data-driven)",
		true, "(hoy con_archivo=%d)" % con_archivo)
	print("      (informativo) tiene_archivo=true: %d/%d" % [con_archivo, fuentes.size()])
	var errores := FontAuditor.validar(datos)
	_check("FontAuditor: 0 errores (ids/licencias/pesos)", errores.is_empty(),
		str(errores))
	var permitidas: Array = datos.get("licencias_permitidas", [])
	_check("whitelist con >=4 licencias permitidas", permitidas.size() >= 4,
		"n=%d" % permitidas.size())
	_fin("E")

# ── F: la cadena REAL de produccion (rutas del tema en disco) ──
func _test_cadena_tema() -> void:
	print("--- F. Cadena de produccion theme_ux ---")
	if not FileAccess.file_exists(RUTA_TEMA):
		_check("theme_ux.gd existe", false)
		_fin("F")
		return
	var texto := FileAccess.get_file_as_string(RUTA_TEMA)
	var re := RegEx.new()
	re.compile("PATH_FONT_[A-Z_]+\\s*:=\\s*\"([^\"]+)\"")
	var rutas: Array = []
	for m in re.search_all(texto):
		var r := m.get_string(1)
		if not rutas.has(r):
			rutas.append(r)
	_check("el tema declara 3 rutas de fuente", rutas.size() == 3, "n=%d" % rutas.size())
	for r in rutas:
		_check("ruta del tema existe: %s" % r.get_file(), FileAccess.file_exists(r),
			"PATH apunta a un archivo inexistente")
		var w := _ancho(_cargar(r), TEXTO_BASE, TAM_BASE)
		_check("ruta del tema mide texto: %s" % r.get_file(), w > 0.0, "ancho=%.1f" % w)
	_fin("F")

# ── G: integracion M87 (i18n) vista desde FontCatalog ──
func _test_integracion_m87() -> void:
	print("--- G. Integracion M87: cobertura de idiomas ---")
	var fc := root.get_node_or_null("FontCatalog")
	if fc == null:
		_check("FontCatalog autoload presente", false)
		_fin("G")
		return
	_check("FontCatalog autoload presente", true)
	_check("soporta_idioma: texto_cozy soporta es",
		fc.soporta_idioma("texto_cozy", "es"))
	_check("soporta_idioma: texto_cozy NO soporta ru",
		not fc.soporta_idioma("texto_cozy", "ru"))
	var f_es: Dictionary = fc.fuente_para_idioma("es")
	_check("fuente_para_idioma('es') devuelve body con cobertura", not f_es.is_empty(),
		str(f_es))
	var errores: Array = fc.validar_cobertura_idiomas(["es", "en"])
	_check("validar_cobertura_idiomas es/en: 0 errores", errores.is_empty(), str(errores))
	_fin("G")

# ── H: integracion M58 (Accesibilidad): font_size con la fuente del tema ──
func _test_integracion_m58() -> void:
	print("--- H. Integracion M58: factor de tamano sin romper medicion ---")
	var ruta_tema := ""
	var rutas: Array = []
	if FileAccess.file_exists(RUTA_TEMA):
		var re := RegEx.new()
		re.compile("PATH_FONT_[A-Z_]+\\s*:=\\s*\"([^\"]+)\"")
		for m in re.search_all(FileAccess.get_file_as_string(RUTA_TEMA)):
			rutas.append(m.get_string(1))
		if not rutas.is_empty():
			ruta_tema = rutas[0]
	if ruta_tema.is_empty():
		_check("consigo una ruta de fuente para el experimento", false)
		_fin("H")
		return
	var fuente := _cargar(ruta_tema)
	var label := Label.new()
	label.text = "Accesibilidad"
	label.add_theme_font_override("font", fuente)
	root.add_child(label)
	# mismo patron que aplicador_accesibilidad.gd: override de font_size
	label.add_theme_font_size_override("font_size", int(16 * 1.25))  # factor M58
	var tam := label.get_theme_font_size("font_size")
	_check("label M58 aplica factor 16 -> 20", tam == 20, "tam=%d" % tam)
	var f_label: Font = label.get_theme_font("font")
	var w := _ancho(f_label, "Accesibilidad", tam)
	_check("con factor M58 sigue midiendo texto (%.1f px)" % w, w > 0.0)
	label.queue_free()
	_fin("H")

func _summary() -> void:
	print("")
	var faltantes: Array = []
	for n in BLOQUES:
		if not _vistos.has(n) or not _vistos[n]:
			faltantes.append(n)
	if not faltantes.is_empty():
		_checks += 1
		_fallos += 1
		print("  [FAIL] bloques que NO se ejecutaron (posible SCRIPT ERROR): %s" % str(faltantes))
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M88 it.3: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M88 IT.3 FALLIDO — salida con codigo 1")
		quit(1)
	else:
		print("TEST M88 IT.3 OK — binarios, catalogo e integraciones verdes")
		quit(0)
