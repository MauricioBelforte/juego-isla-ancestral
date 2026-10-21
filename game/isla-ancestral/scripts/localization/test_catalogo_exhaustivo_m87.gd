# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-21
#
# M87 — COLA V3 item 46 (i18n clave-exhaust): EXHAUSTIVIDAD DE CLAVES.
#
# Que cierra:
#   * El auditor solo miraba texto `.gd`. Una clave declarada en un RECURSO de
#     datos (`*.tres`: `nombre_clave`/`descripcion_clave`) y ausente del catalogo
#     era invisible: no hay llamada `_t()` que la delate y el catalogo no la tiene.
#   * Las 14 claves de capitulo de M149 (`eventos.historia_c1..c7_nombre/_desc`)
#     vivian SOLO en `data/localizacion/strings_*.json`, un catalogo que el
#     autoload `Localization` NO lee (carga `res://locales/*.po`). Medido
#     2026-10-21: 260 claves en el .po, ninguna de las 14. Aspiradas en esta
#     tanda (260 -> 274 en es y en).
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral \
#     --script res://scripts/localization/test_catalogo_exhaustivo_m87.gd
#
# ⚠️ TRAMPA (heredada): un error de script aborta la funcion en silencio y las
# aserciones posteriores no corren -> "0 fallos" falso. Cada bloque deja marca
# con `_fin()`, `_run()` exige las 7 marcas y `_summary()` va en su propio
# `call_deferred`. `CHECKS_MINIMOS` es MEDIDO en verde, nunca estimado.

extends SceneTree

# --- Guardia anti-falso-verde (3 capas) -------------------------------------
## MEDIDO en verde el 2026-10-21 (36 checks, 0 fallos, EXIT 0 x3). No estimado.
const CHECKS_MINIMOS := 36
var _checks: int = 0
var _fallos: int = 0
var _wb_cerrado: bool = false
var _hechos: Dictionary = {}

const BLOQUES: Array[String] = [
	"catalogos_reales", "capitulos_en_catalogo", "recursos_reales",
	"fixture_ausente", "fixture_presente", "fixture_formato", "informe",
]

const RUTA_ES := "res://locales/es.po"
const RUTA_EN := "res://locales/en.po"
const DIR_CAPITULOS := "res://scripts/eventos/data/capitulos"
const DIR_FIXTURE := "user://m87_exhaustivo_fixture"

## Las 14 claves que M149 declara en sus 7 recursos y que el catalogo runtime
## no tenia. Si alguien las borra del .po, esto se pone rojo.
const CLAVES_CAPITULO: Array[String] = [
	"eventos.historia_c1_nombre", "eventos.historia_c1_desc",
	"eventos.historia_c2_nombre", "eventos.historia_c2_desc",
	"eventos.historia_c3_nombre", "eventos.historia_c3_desc",
	"eventos.historia_c4_nombre", "eventos.historia_c4_desc",
	"eventos.historia_c5_nombre", "eventos.historia_c5_desc",
	"eventos.historia_c6_nombre", "eventos.historia_c6_desc",
	"eventos.historia_c7_nombre", "eventos.historia_c7_desc",
]


func _summary() -> void:
	if _wb_cerrado:
		return
	_wb_cerrado = true
	for b in BLOQUES:
		if not _hechos.has(b):
			_fallos += 1
			print("[FAIL] bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M87 catalogo exhaustivo: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	_test_catalogos_reales()
	_test_capitulos_en_catalogo()
	_test_recursos_reales()
	_test_fixture_ausente()
	_test_fixture_presente()
	_test_fixture_formato()
	_test_informe()
	for b in BLOQUES:
		_check(_hechos.has(b), "el bloque '%s' se ejecuto completo (sin aborto por error de script)" % b)
	_limpiar()
	_summary()


# --- utilidades --------------------------------------------------------------

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)


func _fin(nombre: String) -> void:
	_hechos[nombre] = true


func _tiene(items: Array, texto: String) -> bool:
	for i in items:
		if str(i) == texto:
			return true
	return false


func _escribir(ruta: String, texto: String) -> void:
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	f.store_string(texto)
	f.close()


func _limpiar() -> void:
	var d := DirAccess.open(DIR_FIXTURE)
	if d == null:
		return
	for f in d.get_files():
		DirAccess.remove_absolute(DIR_FIXTURE.path_join(f))
	DirAccess.remove_absolute(DIR_FIXTURE)


func _preparar_fixture() -> bool:
	_limpiar()
	if DirAccess.make_dir_recursive_absolute(DIR_FIXTURE) != OK:
		return false
	return true


# --- A. catalogos reales -----------------------------------------------------

func _test_catalogos_reales() -> void:
	var es: Dictionary = ValidadorPO.validar_archivo(RUTA_ES)
	var en: Dictionary = ValidadorPO.validar_archivo(RUTA_EN)
	_check(bool(es["ok"]), "es.po sin errores -> " + str(es["errores"]))
	_check(bool(en["ok"]), "en.po sin errores -> " + str(en["errores"]))
	var par: Dictionary = ValidadorPO.validar_par(RUTA_ES, RUTA_EN)
	_check(bool(par["ok"]), "par es<->en sin errores -> " + str(par["errores"]))
	_check((par["faltantes_en_traduccion"] as Array).is_empty(), "en.po cubre todas las claves de es.po")
	_fin("catalogos_reales")


# --- B. las 14 claves de capitulo, en AMBOS catalogos ------------------------

func _test_capitulos_en_catalogo() -> void:
	var es: Dictionary = ValidadorPO.validar_archivo(RUTA_ES)
	var en: Dictionary = ValidadorPO.validar_archivo(RUTA_EN)
	var claves_es: Array = es["claves"]
	var claves_en: Array = en["claves"]
	var faltan_es: Array[String] = []
	var faltan_en: Array[String] = []
	var textos: Dictionary = es["textos"]
	for k in CLAVES_CAPITULO:
		if not _tiene(claves_es, k):
			faltan_es.append(k)
		if not _tiene(claves_en, k):
			faltan_en.append(k)
	_check(faltan_es.is_empty(), "las 14 claves de capitulo estan en es.po -> faltan " + str(faltan_es))
	_check(faltan_en.is_empty(), "las 14 claves de capitulo estan en en.po -> faltan " + str(faltan_en))
	# Control positivo de contenido: no basta la clave, el texto tiene que existir.
	var vacias: Array[String] = []
	for k in CLAVES_CAPITULO:
		if String(textos.get(k, "")).strip_edges().is_empty():
			vacias.append(k)
	_check(vacias.is_empty(), "ninguna clave de capitulo con texto vacio -> " + str(vacias))
	# Y no puede ser la clave devuelta como texto (sintoma clasico de fallback).
	_check(String(textos.get("eventos.historia_c1_nombre", "")) != "eventos.historia_c1_nombre",
		"el texto de c1_nombre NO es la propia clave (sin fallback silencioso)")
	_fin("capitulos_en_catalogo")


# --- C. los recursos reales de capitulo contra el catalogo -------------------

func _test_recursos_reales() -> void:
	var inf: Dictionary = AuditorClaves.auditar(DIR_CAPITULOS, RUTA_ES)
	_check(int(inf["recursos"]) == 7, "7 recursos de capitulo escaneados (leidos %d)" % int(inf["recursos"]))
	var faltan: Array = inf["claves_recurso_sin_catalogo"]
	_check(faltan.is_empty(), "ningun recurso de capitulo declara claves ausentes de es.po -> " + str(faltan))
	var inf_en: Dictionary = AuditorClaves.auditar(DIR_CAPITULOS, RUTA_EN)
	_check((inf_en["claves_recurso_sin_catalogo"] as Array).is_empty(),
		"ningun recurso de capitulo declara claves ausentes de en.po -> " + str(inf_en["claves_recurso_sin_catalogo"]))
	# El escaneo de codigo no debe haberse contaminado con las claves de datos.
	_check(not (inf["usadas_sin_clave"] as Array).has("eventos.historia_c1_nombre"),
		"una clave de RECURSO no se reporta como 'usada en codigo'")
	_fin("recursos_reales")


# --- D. fixture: clave ausente SI se reporta (guardián en rojo) -------------

func _test_fixture_ausente() -> void:
	if not _preparar_fixture():
		_check(false, "no se pudo preparar el fixture en " + DIR_FIXTURE)
		_fin("fixture_ausente")
		return
	var cuerpo := "[gd_resource type=\"Resource\" format=3]\n\n[resource]\nnombre_clave = &\"FIXTURE.AUSENTE.NOMBRE\"\ndescripcion_clave = &\"FIXTURE.AUSENTE.DESC\"\n"
	_escribir(DIR_FIXTURE.path_join("ausente.tres"), cuerpo)
	var inf: Dictionary = AuditorClaves.auditar(DIR_FIXTURE, RUTA_ES)
	_check(int(inf["recursos"]) == 1, "el fixture .tres se escaneo (leidos %d)" % int(inf["recursos"]))
	var faltan: Array = inf["claves_recurso_sin_catalogo"]
	_check(_tiene(faltan, "FIXTURE.AUSENTE.NOMBRE"), "reporta nombre_clave ausente -> " + str(faltan))
	_check(_tiene(faltan, "FIXTURE.AUSENTE.DESC"), "reporta descripcion_clave ausente -> " + str(faltan))
	_check(faltan.size() == 2, "reporta exactamente 2 claves (leidas %d)" % faltan.size())
	# El veredicto `ok` NO se ensucia: es deuda de contenido, no de codigo.
	_check(bool(inf["ok"]), "la deuda de contenido no cambia el veredicto ok del codigo")
	_fin("fixture_ausente")


# --- E. fixture: clave presente NO se reporta (control negativo) ------------

func _test_fixture_presente() -> void:
	if not _preparar_fixture():
		_check(false, "no se pudo preparar el fixture en " + DIR_FIXTURE)
		_fin("fixture_presente")
		return
	var cuerpo := "[gd_resource type=\"Resource\" format=3]\n\n[resource]\nnombre_clave = &\"MAIN_MENU.PLAY\"\n"
	_escribir(DIR_FIXTURE.path_join("presente.tres"), cuerpo)
	var inf: Dictionary = AuditorClaves.auditar(DIR_FIXTURE, RUTA_ES)
	var faltan: Array = inf["claves_recurso_sin_catalogo"]
	_check(faltan.is_empty(), "una clave presente en el catalogo no se reporta -> " + str(faltan))
	_check(int(inf["recursos"]) == 1, "un .tres sin claves ausentes igual se cuenta como escaneado")
	_fin("fixture_presente")


# --- F. fixture: formatos que el regex debe (y no debe) capturar ------------

func _test_fixture_formato() -> void:
	if not _preparar_fixture():
		_check(false, "no se pudo preparar el fixture en " + DIR_FIXTURE)
		_fin("fixture_formato")
		return
	# Variantes legitimas: con &, sin &, otro nombre de campo, con sangria.
	var cuerpo := (
		"[gd_resource type=\"Resource\" format=3]\n\n[resource]\n"
		+ "id = \"no_es_clave\"\n"
		+ "    nombre_clave = &\"FIXTURE.FMT.UNO\"\n"
		+ "\tdescripcion_clave = \"FIXTURE.FMT.DOS\"\n"
		+ "nombre_clave_i18n = &\"FIXTURE.FMT.TRES\"\n"
		+ "clave_vacia = &\"\"\n"
		+ "nota = \"esto no lleva la palabra clave\"\n"
	)
	_escribir(DIR_FIXTURE.path_join("formatos.tres"), cuerpo)
	var inf: Dictionary = AuditorClaves.auditar(DIR_FIXTURE, RUTA_ES)
	var faltan: Array = inf["claves_recurso_sin_catalogo"]
	_check(_tiene(faltan, "FIXTURE.FMT.UNO"), "captura `nombre_clave = &\"...\"`")
	_check(_tiene(faltan, "FIXTURE.FMT.DOS"), "captura `descripcion_clave = \"...\"` sin &")
	_check(_tiene(faltan, "FIXTURE.FMT.TRES"), "captura `nombre_clave_i18n`")
	_check(not _tiene(faltan, "no_es_clave"), "NO captura `id = \"...\"` (no es campo de clave)")
	_check(not _tiene(faltan, ""), "NO captura la clave vacia")
	_check(faltan.size() == 3, "captura exactamente 3 claves (leidas %d) -> " + str(faltan.size()))
	_fin("fixture_formato")


# --- G. informe legible: el conteo se publica aunque sea 0 ------------------

func _test_informe() -> void:
	var inf: Dictionary = AuditorClaves.auditar(DIR_CAPITULOS, RUTA_ES)
	var txt: String = AuditorClaves.formatear_informe(inf)
	_check(txt.contains("RECURSOS (*.tres) ESCANEADOS: 7"), "el informe publica los 7 recursos escaneados")
	_check(txt.contains("claves declaradas: 14"), "el informe publica las 14 claves declaradas en los recursos")
	_check(txt.contains("sin entrada en el catálogo: 0"), "el informe publica 0 claves ausentes (medido)")
	# Informe parcial: un Dictionary sin las claves nuevas no debe reventar
	# (formatear_informe es publico y el suite hermano le pasa dicts a mano).
	var parcial: Dictionary = {
		"archivos": 0, "total_usadas": 0, "total_claves": 0, "usadas_sin_clave": [],
		"usadas_sin_clave_solo_tests": [], "claves_sin_uso": [], "claves_dinamicas": [],
		"dinamicas": [], "errores": [], "ok": true,
	}
	var txt2: String = AuditorClaves.formatear_informe(parcial)
	_check(txt2.contains("RESULTADO: OK"), "un informe parcial sigue formateandose")
	_fin("informe")
