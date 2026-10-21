extends SceneTree

## M88 - Fuentes: suite de la herramienta de optimizacion (subsetter).
##
## Cierra el [ ? ] "Optimizar archivos de fuente" del 05-Checklist de M88: la
## herramienta estaba DISENADA en 03-Diseno.md seccion 9 pero no implementada
## (delegaba en pyftsubset / woff2_compress, que no estan instalados).
##
## Ejecutar:
##   godot --headless --path game/isla-ancestral \
##         --script res://scripts/fonts/test_fuentes_optimizadas_m88.gd
##
## Que verifica (6 bloques):
##   A. La herramienta responde por CLI (--medir) y reporta ahorro.
##   B. Genera los 3 subsets de fuentes estaticas, mas chicos que el original.
##   C. Godot CARGA cada subset y cubre 78/79 codepoints del catalogo.
##   D. ROJO: un subset de un solo caracter NO tiene los demas glifos.
##   E. Los originales quedan intactos (sha256) y la fuente variable se rechaza.
##   F. El informe JSON coincide con el disco (bytes, ratio, verificado).
##
## Nota de independencia: el tool esta en Python y esta suite en GDScript. La
## cobertura se mide por dos caminos distintos (cmap en Python, has_char en
## Godot) y ambos tienen que dar el MISMO numero.

const HERRAMIENTA := "res://tools/font_subsetter.py"
const DIR_FUENTES := "res://assets/fonts"
const DIR_LOCALES := "res://locales"
const DIR_SALIDA := "user://m88_subset"

const ESTATICAS: Array[String] = ["Nunito-Regular.ttf", "Nunito-Bold.ttf", "FredokaOne-Regular.ttf"]
const VARIABLE := "Nunito-Variable.ttf"
const CODEPOINTS_ESPERADOS := 79
const SIN_GLIFO_EN_ORIGEN := 0x2192

const BLOQUES := ["A", "B", "C", "D", "E", "F"]
const CHECKS_MINIMOS := 49

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}
var _py: String = ""
var _informes: Dictionary = {}


func _init() -> void:
	# El resumen va en una llamada diferida SEPARADA de la corrida: si un
	# SCRIPT ERROR aborta _correr(), el resumen igual se ejecuta y nombra los
	# bloques que faltaron. Medido: con el resumen al final de _correr(), un
	# aborto de runtime deja el proceso COLGADO en vez de fallar.
	call_deferred("_correr")
	call_deferred("_summary")


func _summary() -> void:
	for b in BLOQUES:
		if not _vistos.has(b):
			_fallos += 1
			print("  [FAIL] el bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M88 optimizacion: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST FAIL")
		quit(1)
	else:
		print("TEST OK")
		quit(0)


func _check(nombre: String, ok: bool, detalle: String = "") -> void:
	_checks += 1
	if not ok:
		_fallos += 1
		print("  [FAIL] %s%s" % [nombre, "" if detalle.is_empty() else " -> " + detalle])


func _bloque(nombre: String, titulo: String) -> void:
	_vistos[nombre] = true
	print("--- %s. %s ---" % [nombre, titulo])


func _abs(ruta: String) -> String:
	return ProjectSettings.globalize_path(ruta).replace("\\", "/")


func _ejecutar(argumentos: PackedStringArray) -> Dictionary:
	var salida: Array = []
	var codigo: int = OS.execute(_py, argumentos, salida, true)
	return {"code": codigo, "out": String("").join(salida)}


func _correr() -> void:
	var herramienta := _abs(HERRAMIENTA)
	var locales := _abs(DIR_LOCALES)
	DirAccess.make_dir_recursive_absolute(_abs(DIR_SALIDA))

	_bloque("A", "La herramienta responde por CLI")
	var candidatos := PackedStringArray(["python3", "python", "py"])
	for c in candidatos:
		var r: Array = []
		var code: int = OS.execute(c, PackedStringArray([herramienta, "--help"]), r, true)
		if code == 0 and String("").join(r).contains("--codepoints"):
			_py = c
			break
	_check("hay un interprete de Python con la herramienta", not _py.is_empty(),
		"probados: python3, python, py")
	if _py.is_empty():
		# No se marcan B-F como vistos: el resumen tiene que nombrarlos como
		# bloques que no corrieron. Marcarlos seria un falso verde.
		return

	var mide := _ejecutar(PackedStringArray([herramienta,
		"--input", _abs(DIR_FUENTES + "/Nunito-Regular.ttf"),
		"--medir", "--po", locales]))
	_check("--medir sale con exit 0", int(mide["code"]) == 0, str(mide["code"]))
	_check("--medir reporta ahorro", String(mide["out"]).contains("menos"),
		String(mide["out"]).strip_edges().substr(0, 120))
	_check("--medir nombra los checks de verificacion",
		String(mide["out"]).contains("checks:"), "")

	_bloque("B", "Genera los subsets mas chicos que el original")
	for nombre in ESTATICAS:
		var origen := DIR_FUENTES + "/" + nombre
		var destino := DIR_SALIDA + "/" + nombre
		var informe := DIR_SALIDA + "/" + nombre.get_basename() + ".json"
		var r := _ejecutar(PackedStringArray([herramienta,
			"--input", _abs(origen), "--output", _abs(destino),
			"--po", locales, "--report", _abs(informe)]))
		_check("%s: la herramienta sale con exit 0" % nombre, int(r["code"]) == 0,
			String(r["out"]).strip_edges().substr(0, 160))
		var hay: bool = FileAccess.file_exists(destino)
		_check("%s: el subset existe en disco" % nombre, hay)
		if not hay:
			continue
		var tam_orig := _tam(origen)
		var tam_sub := _tam(destino)
		_check("%s: el subset pesa menos que el original" % nombre, tam_sub < tam_orig,
			"%d vs %d" % [tam_sub, tam_orig])
		_check("%s: el ahorro supera el 50%%" % nombre, tam_sub * 2 < tam_orig,
			"%d vs %d" % [tam_sub, tam_orig])
		if FileAccess.file_exists(informe):
			_informes[nombre] = _leer_json(informe)

	_bloque("C", "Godot carga el subset y cubre el catalogo")
	var cps: Array = _codepoints_catalogo()
	_check("el catalogo pide %d codepoints" % CODEPOINTS_ESPERADOS,
		cps.size() == CODEPOINTS_ESPERADOS, str(cps.size()))
	for nombre in ESTATICAS:
		var f := _cargar_fuente(DIR_SALIDA + "/" + nombre)
		_check("%s: Godot carga el subset" % nombre, f != null)
		if f == null:
			continue
		var faltan: Array = []
		for c in cps:
			if not f.has_char(int(c)):
				faltan.append(int(c))
		_check("%s: cubre %d de %d codepoints" % [nombre, cps.size() - 1, cps.size()],
			faltan.size() == 1 and int(faltan[0]) == SIN_GLIFO_EN_ORIGEN,
			"faltan: %s" % str(faltan))
		_check("%s: dibuja texto con ancho real" % nombre,
			f.get_string_size("Hola mundo", 0, -1, 16).x > 0.0,
			"%.2f px" % f.get_string_size("Hola mundo", 0, -1, 16).x)

	_bloque("D", "ROJO: el subset respeta el conjunto pedido")
	var rojo := DIR_SALIDA + "/_rojo_solo_A.ttf"
	var r_rojo := _ejecutar(PackedStringArray([herramienta,
		"--input", _abs(DIR_FUENTES + "/Nunito-Regular.ttf"),
		"--output", _abs(rojo), "--codepoints", "0041"]))
	_check("el subset de un caracter se genera", int(r_rojo["code"]) == 0,
		String(r_rojo["out"]).strip_edges().substr(0, 120))
	var fr := _cargar_fuente(rojo)
	_check("el subset rojo carga", fr != null)
	if fr != null:
		_check("rojo: la A esta presente", fr.has_char(0x41))
		_check("rojo: la enie NO esta presente", not fr.has_char(0xF1))
		_check("rojo: la flecha NO esta presente", not fr.has_char(SIN_GLIFO_EN_ORIGEN))
		_check("rojo: pesa menos de la mitad del original",
			_tam(rojo) * 2 < _tam(DIR_FUENTES + "/Nunito-Regular.ttf"),
			"%d" % _tam(rojo))

	_bloque("E", "Originales intactos y fuente variable rechazada")
	for nombre in ESTATICAS:
		var antes: String = FileAccess.get_sha256(_abs(DIR_FUENTES + "/" + nombre))
		_ejecutar(PackedStringArray([herramienta,
			"--input", _abs(DIR_FUENTES + "/" + nombre),
			"--medir", "--po", locales]))
		var despues: String = FileAccess.get_sha256(_abs(DIR_FUENTES + "/" + nombre))
		_check("%s: el original no se modifico" % nombre, antes == despues,
			"%s vs %s" % [antes.substr(0, 12), despues.substr(0, 12)])
	var r_var := _ejecutar(PackedStringArray([herramienta,
		"--input", _abs(DIR_FUENTES + "/" + VARIABLE),
		"--medir", "--po", locales]))
	_check("la fuente variable se rechaza (exit != 0)", int(r_var["code"]) != 0,
		str(r_var["code"]))
	_check("el rechazo nombra la causa variable",
		String(r_var["out"]).to_lower().contains("variable"),
		String(r_var["out"]).strip_edges().substr(0, 120))

	_bloque("F", "El informe JSON coincide con el disco")
	for nombre in ESTATICAS:
		var d: Dictionary = _informes.get(nombre, {})
		_check("%s: hay informe JSON" % nombre, not d.is_empty())
		if d.is_empty():
			continue
		var real := _tam(DIR_SALIDA + "/" + nombre)
		_check("%s: bytes_out del informe == tamano en disco" % nombre,
			int(d.get("bytes_out", -1)) == real,
			"%s vs %d" % [str(d.get("bytes_out", -1)), real])
		_check("%s: el informe se declara verificado" % nombre,
			bool(d.get("verificado", false)) and int(d.get("checks_fallidos", 1)) == 0)
		_check("%s: el informe mide el codepoint sin glifo" % nombre,
			int(d.get("codepoints_mapeados", 0)) == CODEPOINTS_ESPERADOS - 1,
			str(d.get("codepoints_mapeados", -1)))
	# El resumen NO se llama aca: va diferido aparte (ver _init).


func _tam(ruta: String) -> int:
	if not FileAccess.file_exists(ruta):
		return -1
	return int(FileAccess.get_file_as_bytes(ruta).size())


func _leer_json(ruta: String) -> Dictionary:
	var f := FileAccess.open(ruta, FileAccess.READ)
	if f == null:
		return {}
	var txt := f.get_as_text()
	f.close()
	var dato: Variant = JSON.parse_string(txt)
	if dato is Dictionary:
		return dato
	return {}


func _cargar_fuente(ruta: String) -> FontFile:
	if not FileAccess.file_exists(ruta):
		return null
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(ruta)
	if bytes.is_empty():
		return null
	var f := FontFile.new()
	f.data = bytes
	return f


func _codepoints_catalogo() -> Array:
	var aud = load("res://scripts/fonts/auditar_glifos.gd")
	if aud == null:
		return []
	var d: Dictionary = aud.caracteres_de_po([DIR_LOCALES + "/es.po", DIR_LOCALES + "/en.po"])
	var cps: Array = (d["chars"] as Dictionary).keys()
	cps.sort()
	return cps
