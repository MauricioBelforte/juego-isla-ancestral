# Modelo: deepseek-v4.1-flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-21
#
# M88 / M87 (i18n b3) - Suite de cobertura de glifos del catalogo .po.
#
# Cierra dos falsos verdes medidos el 2026-10-21:
#   1. El unico chequeo de cobertura del repo (bloque B de
#      `test_fuentes_reales_m88.gd`) decidia "falta el glifo" con el ANCHO.
#      Un glifo ausente se dibuja como `.notdef` y su avance NO es cero: medido,
#      U+2192 da 14.0 px en las 3 fuentes de produccion con `has_char()==false`.
#      -> bloque C: prueba que el metodo viejo es ciego (control negativo).
#   2. Contar los caracteres del ARCHIVO .po incluye los COMENTARIOS: por bytes
#      hay 16 no-ASCII, en el texto mostrable 14 (U+2500 solo vive en las lineas
#      `# ──`). -> bloque A: el parser excluye comentarios y cabecera.
#
# Estado medido (2026-10-21): las 4 fuentes del repo NO tienen U+2192 (flecha),
# que el catalogo usa en 31 claves x 2 idiomas y que 3 sitios de produccion
# emiten (crafting_ui, diary_layer, transport_localizer).
#
# Guardas anti-falso-verde (patron del repo): marcadores `_fin()` por bloque,
# piso `CHECKS_MINIMOS` MEDIDO en verde y `_summary()` en un `call_deferred`
# aparte (si `_run()` aborta, el resumen corre igual y sale con EXIT 1).

extends SceneTree

const AUD := preload("res://scripts/fonts/auditar_glifos.gd")

const DIR_FUENTES := "res://assets/fonts"
const POS := ["res://locales/es.po", "res://locales/en.po"]
const FUENTES := [
	"res://assets/fonts/Nunito-Regular.ttf",
	"res://assets/fonts/Nunito-Bold.ttf",
	"res://assets/fonts/FredokaOne-Regular.ttf",
	"res://assets/fonts/Nunito-Variable.ttf",
]
const PRODUCCION_3 := [
	"res://assets/fonts/Nunito-Regular.ttf",
	"res://assets/fonts/Nunito-Bold.ttf",
	"res://assets/fonts/FredokaOne-Regular.ttf",
]
# Sitios de PRODUCCION que emiten la flecha en texto que ve el jugador.
const SITIOS := [
	"res://scripts/crafting/crafting_ui.gd",
	"res://scripts/ui/layers/diary_layer.gd",
	"res://scripts/transporte/transport_localizer.gd",
]
const FLECHA := 0x2192
const CHEVRON := 0x00BB
const CAJA := 0x2500
const BLOQUES := ["A", "B", "C", "D", "E", "F"]
const CHECKS_MINIMOS := 50  # MEDIDO en verde (3 corridas identicas); se re-mide al agregar checks

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	print("=== M88/M87 - cobertura de glifos del catalogo .po ===")
	_bloque_a_parser()
	_bloque_b_cobertura()
	_bloque_c_ancho_ciego()
	_bloque_d_sustitutos()
	_bloque_e_sitios()
	_bloque_f_informe()


# ── A: el parser mide TEXTO, no bytes de archivo ────────────────────────
func _bloque_a_parser() -> void:
	print("-- A. Parser de .po: comentarios y cabecera excluidos --")
	var po: Dictionary = AUD.caracteres_de_po(POS)
	var chars: Dictionary = po["chars"]
	_check("A1 parsea las 2 rutas", (po["rutas"] as Array).size() == 2,
		"rutas=%s" % str(po["rutas"]))
	_check("A2 entradas incluyen la cabecera (275 x 2)", int(po["entradas"]) == 550,
		"entradas=%d" % int(po["entradas"]))
	_check("A3 formas msgstr (278 x 2)", int(po["formas"]) == 556,
		"formas=%d" % int(po["formas"]))
	_check("A4 codepoints requeridos = 79 (74 en es.po + 69 en en.po, union)", chars.size() == 79,
		"codepoints=%d" % chars.size())
	_check("A5 el guion de caja U+2500 SOLO vive en comentarios: NO es requerido",
		not chars.has(CAJA), "U+2500 contado como texto mostrable")
	_check("A6 la flecha U+2192 SI es requerida", chars.has(FLECHA))
	var claves_flecha: Array = chars.get(FLECHA, [])
	_check("A7 la flecha la usan 31 claves (misma clave en los 2 .po)", claves_flecha.size() == 31,
		"claves=%d" % claves_flecha.size())
	for ruta in POS:
		var uno: Dictionary = AUD.caracteres_de_po([ruta])
		var c1: Dictionary = uno["chars"]
		_check("A8 %s exige la flecha" % String(ruta).get_file(), c1.has(FLECHA))
	_check("A9 ningun codepoint de control en el set",
		not chars.has(9) and not chars.has(10) and not chars.has(13))
	var con_clave: int = int(po["entradas_con_texto"])
	_check("A10 entradas con texto = 548 (la cabecera de cada .po queda fuera)",
		con_clave == 548, "con_texto=%d" % con_clave)
	_fin("A")


# ── B: cobertura real por `has_char` ────────────────────────────────────
func _bloque_b_cobertura() -> void:
	print("-- B. Cobertura real de las 4 fuentes (has_char) --")
	var res: Dictionary = AUD.auditar(FUENTES, POS)
	var cps: Array = (res["po"] as Dictionary)["chars"].keys()
	for f in res["fuentes"]:
		var d: Dictionary = f
		var nombre := String(d["ruta"]).get_file()
		_check("B1 %s carga" % nombre, bool(d["carga"]))
		_check("B2 %s cubre %d de %d" % [nombre, int(d["cubiertos"]), int(d["total"])],
			int(d["cubiertos"]) == int(d["total"]) - 1, "cubiertos=%d" % int(d["cubiertos"]))
		var faltan: Array = d["faltantes"]
		_check("B3 %s: el unico glifo ausente es U+2192" % nombre,
			faltan.size() == 1 and int(faltan[0]) == FLECHA, "faltan=%s" % str(faltan))
	var gl: Array = res["faltantes_globales"]
	_check("B4 ninguna de las 4 fuentes tiene la flecha (hueco global)",
		gl.size() == 1 and int(gl[0]) == FLECHA, "globales=%s" % str(gl))
	_check("B5 el veredicto del auditor es ROJO", not bool(res["ok"]))
	_fin("B")


# ── C: control negativo del metodo viejo (ancho) ────────────────────────
func _bloque_c_ancho_ciego() -> void:
	print("-- C. El ancho NO prueba que el glifo exista --")
	var ciegos: int = 0
	for ruta in PRODUCCION_3:
		var f: Font = load(ruta) as Font
		var nombre := String(ruta).get_file()
		_check("C1 %s: has_char(U+2192) = false" % nombre,
			f != null and not f.has_char(FLECHA))
		var ancho: float = 0.0
		if f != null:
			ancho = f.get_string_size(String.chr(FLECHA), HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
		_check("C2 %s: el ancho de la flecha es > 0 (%.1f px) pese a no tener glifo" % [nombre, ancho],
			ancho > 0.0, "ancho=%.1f" % ancho)
		if f != null and ancho > 0.0 and not f.has_char(FLECHA):
			ciegos += 1
	_check("C3 el metodo por ancho es ciego en las 3 fuentes de produccion (ancho>0 y sin glifo)",
		ciegos == 3, "ciegos=%d" % ciegos)
	var f0: Font = load(PRODUCCION_3[0]) as Font
	var ancho_chevron: float = 0.0
	if f0 != null:
		ancho_chevron = f0.get_string_size(String.chr(CHEVRON), HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
	_check("C4 control POSITIVO: U+00BB si tiene glifo y mide (%.1f px)" % ancho_chevron,
		f0 != null and f0.has_char(CHEVRON) and ancho_chevron > 0.0)
	_fin("C")


# ── D: la tabla de sustitutos cubre el hueco ────────────────────────────
func _bloque_d_sustitutos() -> void:
	print("-- D. Tabla de sustitutos (dato) --")
	var res: Dictionary = AUD.auditar(FUENTES, POS)
	var gl: Array = res["faltantes_globales"]
	var tabla: Dictionary = AUD.sustitutos_para(gl)
	_check("D1 la tabla declara sustituto para la flecha", tabla.has(FLECHA),
		"tabla=%s" % str(tabla))
	_check("D2 el sustituto es U+00BB", str(tabla.get(FLECHA, "")) == String.chr(CHEVRON),
		"sustituto=%s" % str(tabla.get(FLECHA, "")))
	var pendientes: Array = AUD.sin_sustituto(gl, tabla)
	_check("D3 ningun faltante queda sin sustituto", pendientes.is_empty(),
		"sin sustituto=%s" % str(pendientes))
	for ruta in PRODUCCION_3:
		var f: Font = load(ruta) as Font
		var nombre := String(ruta).get_file()
		_check("D4 %s dibuja el sustituto U+00BB" % nombre,
			f != null and f.has_char(CHEVRON))
	_fin("D")


# ── E: severidad — sitios de produccion que emiten la flecha ────────────
func _bloque_e_sitios() -> void:
	print("-- E. Sitios de produccion que emiten U+2192 --")
	var encontrados: int = 0
	for ruta in SITIOS:
		var existe := FileAccess.file_exists(ruta)
		_check("E1 existe %s" % String(ruta).get_file(), existe)
		if not existe:
			continue
		var texto := FileAccess.get_file_as_string(ruta)
		_check("E2 %s emite la flecha en un literal" % String(ruta).get_file(),
			texto.contains(String.chr(FLECHA)))
		encontrados += 1
	_check("E3 al menos 3 sitios de produccion afectados", encontrados >= 3,
		"encontrados=%d" % encontrados)
	var dir := DirAccess.open("res://scripts")
	_check("E4 el escaneo tiene acceso al arbol de scripts", dir != null)
	_fin("E")


# ── F: informe legible ──────────────────────────────────────────────────
func _bloque_f_informe() -> void:
	print("-- F. Informe --")
	var res: Dictionary = AUD.auditar(FUENTES, POS)
	var txt := String(AUD.informe(res))
	print(txt)
	_check("F1 el informe nombra el codepoint ausente", txt.contains("U+2192"))
	_check("F2 el informe trae veredicto", txt.contains("VEREDICTO"))
	_check("F3 el informe lista las 4 fuentes", txt.contains("Nunito-Variable.ttf"))
	_fin("F")


# ── guardas ─────────────────────────────────────────────────────────────
func _fin(nombre: String) -> void:
	_vistos[nombre] = true


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])


func _summary() -> void:
	for b in BLOQUES:
		if not _vistos.has(b):
			_fallos += 1
			print("  [FAIL] el bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M88 glifos: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST FAIL")
		quit(1)
	else:
		print("TEST OK")
		quit(0)
