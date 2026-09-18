# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-13
#
# M87: Localización — AuditorClaves (herramienta dev/CI, RF21 + RN4).
# Inventario determinista de claves entre el CÓDIGO y el CATÁLOGO:
#   · usadas en código pero AUSENTES del catálogo → la UI muestra la clave cruda
#   · presentes en el catálogo pero sin uso literal → huérfanas (o dinámicas)
#   · construcciones dinámicas (`_t("DIARY.CAT_" + cat)`) → prefijos, no falsos positivos
#   · claves con contexto gettext (`tr_ctx`) → clave compuesta "MOD.SEC.CTX|CLAVE"
#   · claves que NO pasan por `_t()`: APIs que reciben la clave como argumento y
#     traducen adentro (`open_confirm` → `ConfirmPopup.configurar` hace `_t(clave)`)
#
# Uso: AuditorClaves.auditar("res://scripts", "res://locales/es.po")
# ⚠️ class_name nuevo → requiere `--editor --quit` una vez para registrarse.

class_name AuditorClaves
extends RefCounted

const RE_T := "_t\\s*\\(\\s*\"([^\"]+)\""
const RE_DINAMICA := "_t\\s*\\(\\s*\"([^\"]*)\"\\s*\\+"
const RE_TRAD := "traducir_clave\\s*\\(\\s*\"([^\"]+)\""
const RE_TR_KEY := "tr_key\\s*\\(\\s*\"([^\"]+)\"\\s*,\\s*\"([^\"]+)\"\\s*,\\s*\"([^\"]*)\""
const RE_TR_CTX := "tr_ctx\\s*\\(\\s*\"([^\"]+)\"\\s*,\\s*\"([^\"]+)\"\\s*,\\s*\"([^\"]+)\"\\s*,\\s*\"([^\"]+)\""

## APIs que reciben CLAVES como argumentos string: el llamador las traduce adentro
## (`ConfirmPopup.configurar` hace `_t(title_key)`), así que la clave NO aparece en
## una llamada `_t()` y el auditor no la veía. Sin estos patrones, una clave usada
## así y ausente del catálogo se reportaba como huérfana en vez de faltante.
##
## Regresión real (M53/M87, Log 1015): `SETTINGS.DESCARTAR_TITULO` y
## `SETTINGS.DESCARTAR_MENSAJE` se usaban en `inventory_layer.gd` desde M53
## (`84d975d`) pero nunca entraron al catálogo; el auditor sólo veía
## `SETTINGS.DESCARTAR` (que sí pasa por `_t()`), así que el hueco pasó inadvertido.
##
## Se captura cada POSICIÓN por separado para tolerar llamadas mixtas (un título
## literal y un mensaje con clave). La forma exigida es MODULO.SECCION.CLAVE, de
## modo que un texto humano (`open_confirm("¿Seguro?")`) no se marca como clave.
const RE_CLAVE_ARG1 := "open_confirm\\s*\\(\\s*\"([A-Z][A-Z0-9_]*(?:\\.[A-Z0-9_]+)+)\""
const RE_CLAVE_ARG2 := "open_confirm\\s*\\(\\s*\"[^\"]*\"\\s*,\\s*\"([A-Z][A-Z0-9_]*(?:\\.[A-Z0-9_]+)+)\""

## Prefijos de claves que solo existen en tests negativos (fallback / clave literal).
const PREFIJOS_TEST: Array[String] = ["NOPE.", "TEST."]

## ── API pública ──────────────────────────────────────────

## Audita el directorio de scripts contra el catálogo fuente.
## Devuelve {ok, archivos, total_usadas, total_claves, usadas_sin_clave,
##          claves_sin_uso, dinamicas, origenes, errores}.
static func auditar(dir_scripts: String, ruta_catalogo: String) -> Dictionary:
	var inf: Dictionary = _nuevo_informe(ruta_catalogo)
	_escanear(dir_scripts, inf)
	return _finalizar(inf)


## Audita UN texto en memoria (CI sobre un diff, o tests sin tocar el disco).
static func auditar_texto(texto: String, archivo: String, ruta_catalogo: String) -> Dictionary:
	var inf: Dictionary = _nuevo_informe(ruta_catalogo)
	inf["archivos"] = 1
	_escanear_texto(texto, archivo, inf)
	return _finalizar(inf)


static func _nuevo_informe(ruta_catalogo: String) -> Dictionary:
	# ⚠️ `dinamicas` se usa como DICTIONARY durante el escaneo (clave = prefijo) y
	# `_finalizar` lo convierte a Array ordenado. No inicializarlo como Array:
	# `arr["prefijo"] = true` revienta con "Invalid cast" y aborta en silencio.
	var inf: Dictionary = {
		"ok": false, "archivos": 0, "total_usadas": 0, "total_claves": 0,
		"usadas_sin_clave": [], "usadas_sin_clave_solo_tests": [],
		"claves_sin_uso": [], "claves_dinamicas": [], "dinamicas": {},
		"origenes": {}, "errores": [], "usadas": {}, "claves": {},
	}
	var cat: Dictionary = ValidadorPO.validar_archivo(ruta_catalogo)
	if not (cat["errores"] as Array).is_empty():
		inf["errores"].append_array(cat["errores"])
	inf["claves"] = _conjunto(cat["claves"])
	return inf


static func _finalizar(inf: Dictionary) -> Dictionary:
	var usadas: Dictionary = inf["usadas"]
	var claves: Dictionary = inf["claves"]
	var dinamicas: Array = (inf["dinamicas"] as Dictionary).keys()
	dinamicas.sort()
	for k in usadas.keys():
		if claves.has(k) or _es_test(k) or _cubierta(k, dinamicas):
			continue
		# Un probe de test (ej. tr_ctx con contexto inventado) no exige entrada
		# en el catálogo: se informa aparte para no ensuciar el veredicto.
		if _solo_tests(inf["origenes"].get(k, [])):
			inf["usadas_sin_clave_solo_tests"].append(k)
		else:
			inf["usadas_sin_clave"].append(k)
	for k in claves.keys():
		if usadas.has(k):
			continue
		if _cubierta(k, dinamicas):
			inf["claves_dinamicas"].append(k)
			continue
		inf["claves_sin_uso"].append(k)
	inf["usadas_sin_clave"].sort()
	inf["usadas_sin_clave_solo_tests"].sort()
	inf["claves_sin_uso"].sort()
	inf["claves_dinamicas"].sort()
	inf["dinamicas"] = dinamicas
	inf["total_usadas"] = usadas.size()
	inf["total_claves"] = claves.size()
	inf.erase("usadas")
	inf.erase("claves")
	# El veredicto mira SOLO el código de producción: los probes de test no cuentan.
	inf["ok"] = (inf["usadas_sin_clave"] as Array).is_empty() and (inf["errores"] as Array).is_empty()
	return inf


## ¿Todas las apariciones de la clave vienen de archivos de test?
static func _solo_tests(origenes: Array) -> bool:
	if origenes.is_empty():
		return false
	for o in origenes:
		if not str(o).begins_with("test_"):
			return false
	return true


## Informe legible para consola / CI.
static func formatear_informe(inf: Dictionary) -> String:
	var l: Array[String] = []
	l.append("── AuditorClaves: %d archivo(s), %d clave(s) usadas, %d en catálogo" % [
		inf["archivos"], inf["total_usadas"], inf["total_claves"]])
	_volcar(l, "USADAS EN CÓDIGO PERO AUSENTES DEL CATÁLOGO", inf["usadas_sin_clave"], inf["origenes"])
	_volcar(l, "AUSENTES PERO SOLO USADAS POR TESTS (probes)", inf["usadas_sin_clave_solo_tests"], inf["origenes"])
	_volcar(l, "EN EL CATÁLOGO SIN USO LITERAL NI DINÁMICO", inf["claves_sin_uso"], {})
	_volcar(l, "EN EL CATÁLOGO, USADAS POR PREFIJO DINÁMICO", inf["claves_dinamicas"], {})
	if not (inf["dinamicas"] as Array).is_empty():
		l.append("Prefijos dinámicos detectados (%d):" % (inf["dinamicas"] as Array).size())
		for d in inf["dinamicas"]:
			l.append("  · " + str(d) + "*")
	_volcar(l, "ERRORES", inf["errores"], {})
	l.append("RESULTADO: " + ("OK" if inf["ok"] else "CLAVES SIN TRADUCCIÓN"))
	return "\n".join(l)

## ── Escaneo ──────────────────────────────────────────────

static func _escanear(dir: String, inf: Dictionary) -> void:
	var d: DirAccess = DirAccess.open(dir)
	if d == null:
		(inf["errores"] as Array).append("directorio inaccesible: " + dir)
		return
	for f in d.get_files():
		if not f.ends_with(".gd"):
			continue
		inf["archivos"] += 1
		_escanear_texto(FileAccess.get_file_as_string(dir.path_join(f)), f, inf)
	for sub in d.get_directories():
		_escanear(dir.path_join(sub), inf)


static func _escanear_texto(t: String, archivo: String, inf: Dictionary) -> void:
	var usadas: Dictionary = inf["usadas"]
	for m in _matches(t, RE_DINAMICA):
		inf["dinamicas"][m.get_string(1)] = true
	for m in _matches(t, RE_T):
		_registrar(usadas, inf["origenes"], m.get_string(1), archivo)
	for m in _matches(t, RE_TRAD):
		_registrar(usadas, inf["origenes"], m.get_string(1), archivo)
	for m in _matches(t, RE_TR_KEY):
		var k: String = m.get_string(1) + "." + m.get_string(2)
		if m.get_string(3) != "":
			k += "." + m.get_string(3)
		_registrar(usadas, inf["origenes"], k.to_upper(), archivo)
	for m in _matches(t, RE_TR_CTX):
		var ctx: String = m.get_string(2) + "." + m.get_string(3) + "." + m.get_string(1) + "|" + m.get_string(4)
		_registrar(usadas, inf["origenes"], ctx.to_upper(), archivo)
	for m in _matches(t, RE_CLAVE_ARG1):
		_registrar(usadas, inf["origenes"], m.get_string(1), archivo)
	for m in _matches(t, RE_CLAVE_ARG2):
		_registrar(usadas, inf["origenes"], m.get_string(1), archivo)

## ── Utilidades ───────────────────────────────────────────

static func _registrar(usadas: Dictionary, origenes: Dictionary, clave: String, archivo: String) -> void:
	usadas[clave] = true
	if not origenes.has(clave):
		origenes[clave] = []
	var lista: Array = origenes[clave]
	if not lista.has(archivo):
		lista.append(archivo)

## ¿La clave la cubre algún prefijo dinámico? ("DIARY.CAT_" cubre "DIARY.CAT_LUGARES")
static func _cubierta(clave: String, dinamicas: Array) -> bool:
	for p in dinamicas:
		if clave.begins_with(str(p)):
			return true
	return false

static func _es_test(clave: String) -> bool:
	for p in PREFIJOS_TEST:
		if clave.begins_with(p):
			return true
	return false

static func _matches(t: String, patron: String) -> Array:
	var re := RegEx.new()
	re.compile(patron)
	return re.search_all(t)

static func _conjunto(arr: Array) -> Dictionary:
	var d: Dictionary = {}
	for k in arr:
		d[k] = true
	return d

static func _volcar(l: Array[String], titulo: String, items: Array, origenes: Dictionary) -> void:
	if items.is_empty():
		return
	l.append("%s (%d):" % [titulo, items.size()])
	for i in items:
		var origen: String = ""
		if origenes.has(i):
			origen = "  [" + ", ".join(origenes[i]) + "]"
		l.append("  · " + str(i) + origen)
