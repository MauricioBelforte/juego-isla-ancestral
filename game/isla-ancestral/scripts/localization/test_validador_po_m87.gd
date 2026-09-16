# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-13
#
# M87: Test iteración 5 — validador de catálogos .po (RF21/RN10/RN12/RF20) +
# auditoría de claves código↔catálogo. Complementa test_localization.gd (núcleo)
# + iter2 + iter3 + iter4.
# Foco: reglas de bytes (BOM/CRLF/UTF-8), cabecera, estructura, duplicados,
# plurales, convención de claves, placeholders y coherencia entre idiomas.
# iter. 6 (2026-09-15): bloque I — exención P5 declarada en el .po con
# `#. no-traducir: <motivo>`, para plantillas sin palabras que no son un olvido.
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/localization/test_validador_po_m87.gd
#
# ⚠️ TRAMPA (aprendida acá): en GDScript un error de script (cast inválido,
# acceso a clave inexistente) ABORTA la función en silencio. Si el error ocurre
# dentro de un bloque de test, las aserciones posteriores no se ejecutan y el
# test puede reportar "0 fallos" con el bloque sin correr. Por eso cada bloque
# deja una MARCA FINAL con `_fin()` y `_run()` exige que estén las 9.

extends SceneTree

const CAB := "msgid \"\"\nmsgstr \"\"\n\"Content-Type: text/plain; charset=UTF-8\\n\"\n\"Language: es\\n\"\n\"Plural-Forms: nplurals=2; plural=(n != 1);\\n\"\n\n"
const F_BOM := "user://m87_val_bom.po"
const F_CRLF := "user://m87_val_crlf.po"
const F_SIN_CAB := "user://m87_val_sincab.po"
const F_VACIO := "user://m87_val_vacio.po"
const F_DUP := "user://m87_val_dup.po"
const F_PLURAL := "user://m87_val_plural.po"
const F_MINUS := "user://m87_val_minus.po"
const F_MIX := "user://m87_val_mix.po"
const F_EN_OK := "user://m87_val_en_ok.po"
const F_EN_FALTA := "user://m87_val_en_falta.po"
const F_EN_PH := "user://m87_val_en_ph.po"
const F_EN_SINTRAD := "user://m87_val_en_sintrad.po"
const F_EXEN_ES := "user://m87_val_exen_es.po"
const F_EXEN_EN := "user://m87_val_exen_en.po"
const F_EXEN_SIN := "user://m87_val_exen_sin.po"
const BLOQUES: Array[String] = [
	"catalogos", "bytes", "estructura", "plurales",
	"placeholders", "coherencia", "auditor", "unidades", "exencion_p5",
]

var _fallos: int = 0
var _hechos: Dictionary = {}


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_catalogos_reales()
	_test_reglas_bytes()
	_test_cabecera_y_estructura()
	_test_plurales_y_convencion()
	_test_placeholders()
	_test_coherencia_idiomas()
	_test_auditor_claves()
	_test_unidades()
	_test_exencion_p5()
	for b in BLOQUES:
		_check(_hechos.has(b), "el bloque '%s' se ejecutó completo (sin aborto por error de script)" % b)
	_limpiar()
	print("=== TEST M87 ITER5 (validador .po): %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)


func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)


## Marca de final de bloque: si un bloque no llega acá, se abortó por error.
func _fin(nombre: String) -> void:
	_hechos[nombre] = true


func _tiene(items: Array, prefijo: String) -> bool:
	for i in items:
		if str(i).begins_with(prefijo):
			return true
	return false


## ⚠️ `_tiene` compara PREFIJO; para buscar dentro del texto usar `_contiene`.
func _contiene(items: Array, texto: String) -> bool:
	for i in items:
		if str(i).contains(texto):
			return true
	return false


func _entrada(clave: String, texto: String) -> String:
	return "msgid \"%s\"\nmsgstr \"%s\"\n\n" % [clave, texto]


func _escribir(ruta: String, texto: String) -> void:
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	f.store_string(texto)
	f.close()


func _escribir_bytes(ruta: String, bytes: PackedByteArray) -> void:
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	f.store_buffer(bytes)
	f.close()


## A. Catálogos reales del proyecto: deben estar limpios y alineados.
func _test_catalogos_reales() -> void:
	var es: Dictionary = ValidadorPO.validar_archivo("res://locales/es.po", "es")
	_check(bool(es["ok"]), "es.po sin errores -> " + str(es["errores"]))
	_check(str(es["locale"]) == "es", "es.po declara Language: es")
	_check(int(es["entradas"]) >= 60, "es.po con >= 60 entradas (tiene %d)" % es["entradas"])
	_check(not _tiene(es["errores"], "R1"), "es.po sin BOM (§28)")
	_check(not _tiene(es["errores"], "R2"), "es.po con saltos LF (RN10)")
	var en: Dictionary = ValidadorPO.validar_archivo("res://locales/en.po", "en")
	_check(bool(en["ok"]), "en.po sin errores -> " + str(en["errores"]))
	_check(str(en["locale"]) == "en", "en.po declara Language: en")
	var par: Dictionary = ValidadorPO.validar_par("res://locales/es.po", "res://locales/en.po")
	_check(bool(par["ok"]), "par es<->en sin errores -> " + str(par["errores"]))
	_check((par["faltantes_en_traduccion"] as Array).is_empty(), "en.po cubre todas las claves de es.po")
	_check((par["placeholders_desalineados"] as Array).is_empty(), "placeholders alineados es<->en")
	_check((par["no_traducidas"] as Array).is_empty(), "sin entradas sin traducir -> " + str(par["no_traducidas"]))
	_fin("catalogos")


## B. Reglas de bytes: BOM (§28), CRLF (RN10) y UTF-8.
func _test_reglas_bytes() -> void:
	var bytes := PackedByteArray([0xEF, 0xBB, 0xBF])
	bytes.append_array((CAB + _entrada("A.B", "x")).to_utf8_buffer())
	_escribir_bytes(F_BOM, bytes)
	var r: Dictionary = ValidadorPO.validar_archivo(F_BOM)
	_check(_tiene(r["errores"], "R1"), "detecta BOM UTF-8")
	_check(int(r["entradas"]) >= 2, "con BOM igual parsea el resto")

	_escribir(F_CRLF, (CAB + _entrada("A.B", "x")).replace("\n", "\r\n"))
	var r2: Dictionary = ValidadorPO.validar_archivo(F_CRLF)
	_check(_tiene(r2["errores"], "R2"), "detecta saltos CRLF")

	var r3: Dictionary = ValidadorPO.validar_archivo("res://locales/NO_EXISTE.po")
	_check(_tiene(r3["errores"], "R1"), "detecta archivo inexistente")
	_fin("bytes")


## C. Cabecera (R4) y estructura (R6/R7).
func _test_cabecera_y_estructura() -> void:
	_escribir(F_SIN_CAB, _entrada("A.B", "x"))
	var r: Dictionary = ValidadorPO.validar_archivo(F_SIN_CAB)
	_check(_tiene(r["errores"], "R4"), "detecta falta de cabecera gettext")

	_escribir(F_VACIO, CAB + _entrada("A.B", ""))
	var r2: Dictionary = ValidadorPO.validar_archivo(F_VACIO)
	_check(_tiene(r2["errores"], "R6"), "detecta msgstr vacío")

	_escribir(F_DUP, CAB + _entrada("A.B", "uno") + _entrada("A.B", "dos"))
	var r3: Dictionary = ValidadorPO.validar_archivo(F_DUP)
	_check(_tiene(r3["errores"], "R7"), "detecta msgid duplicado")
	_fin("estructura")


## D. Plurales (R8/R13) y convención de claves (R10).
func _test_plurales_y_convencion() -> void:
	_escribir(F_PLURAL, CAB + "msgid \"ITEMS.X\"\nmsgid_plural \"ITEMS.X\"\nmsgstr[1] \"muchos\"\n\n")
	var r: Dictionary = ValidadorPO.validar_archivo(F_PLURAL)
	_check(_tiene(r["errores"], "R13"), "detecta plural sin msgstr[0]")

	_escribir(F_MINUS, CAB + _entrada("npc.catalina", "Catalina") + _entrada("minus.cosa", "y"))
	var r2: Dictionary = ValidadorPO.validar_archivo(F_MINUS)
	_check(not _contiene(r2["avisos"], "npc.catalina"), "excepción npc.catalina no se marca")
	_check(_tiene(r2["avisos"], "R10"), "clave en minúscula sí se marca")
	_check(_contiene(r2["avisos"], "minus.cosa"), "la clave marcada es la correcta")
	_check((r2["avisos"] as Array).size() == 1, "solo se marca la clave que incumple")
	_fin("plurales")


## E. Placeholders: mezcla de convenciones (R12) y extracción.
func _test_placeholders() -> void:
	_escribir(F_MIX, CAB + _entrada("A.B", "hola {n} y %s"))
	var r: Dictionary = ValidadorPO.validar_archivo(F_MIX)
	_check(_tiene(r["avisos"], "R12"), "detecta mezcla {llave} + printf")
	var ph: Dictionary = r["placeholders"].get("A.B", {})
	_check((ph.get("llaves", []) as Array).has("{n}"), "extrae llave {n}")
	_check((ph.get("printf", []) as Array).has("%s"), "extrae printf %s")
	_fin("placeholders")


## F. Coherencia entre idiomas: faltantes (P1), placeholders (P3), sin traducir (P5).
func _test_coherencia_idiomas() -> void:
	_escribir(F_VACIO, CAB + _entrada("HUD.VIDA", "Vida") + _entrada("HUD.ENERGIA", "Energia {n}"))
	_escribir(F_EN_OK, CAB + _entrada("HUD.VIDA", "Health") + _entrada("HUD.ENERGIA", "Energy {n}"))
	var p_ok: Dictionary = ValidadorPO.validar_par(F_VACIO, F_EN_OK)
	_check(bool(p_ok["ok"]), "par sintético correcto -> " + str(p_ok["errores"]))

	_escribir(F_EN_FALTA, CAB + _entrada("HUD.VIDA", "Health"))
	var p1: Dictionary = ValidadorPO.validar_par(F_VACIO, F_EN_FALTA)
	_check(_tiene(p1["errores"], "P1"), "detecta clave ausente en la traducción")
	_check((p1["faltantes_en_traduccion"] as Array).has("HUD.ENERGIA"), "reporta HUD.ENERGIA como faltante")

	_escribir(F_EN_PH, CAB + _entrada("HUD.VIDA", "Health") + _entrada("HUD.ENERGIA", "Energy {x}"))
	var p3: Dictionary = ValidadorPO.validar_par(F_VACIO, F_EN_PH)
	_check(_tiene(p3["errores"], "P3"), "detecta placeholders desalineados")

	_escribir(F_EN_SINTRAD, CAB + _entrada("HUD.VIDA", "Vida") + _entrada("HUD.ENERGIA", "Energy {n}"))
	var p5: Dictionary = ValidadorPO.validar_par(F_VACIO, F_EN_SINTRAD)
	_check(_tiene(p5["avisos"], "P5"), "detecta entrada sin traducir")
	_check((p5["no_traducidas"] as Array).has("HUD.VIDA"), "reporta HUD.VIDA como no traducida")
	_fin("coherencia")


## G. Auditor de claves: dinámicas, ausentes y filtro de tests.
func _test_auditor_claves() -> void:
	var codigo := "func f() -> void:\n\t_t(\"SETTINGS.PAUSA\")\n\t_t(\"DIARY.CAT_\" + str(1))\n\ttraducir_clave(\"SETTINGS.CERRAR\")\n\ttr_key(\"MAIN_MENU\", \"PLAY\", \"\")\n\t_t(\"NOPE.NOPE.X\")\n\t_t(\"HUD.FANTASMA\")\n"
	var inf: Dictionary = AuditorClaves.auditar_texto(codigo, "fixture.gd", "res://locales/es.po")
	_check(inf.has("total_claves") and int(inf["total_claves"]) > 0, "auditor devuelve informe bien formado")
	_check((inf["dinamicas"] as Array).has("DIARY.CAT_"), "auditor detecta prefijo dinámico")
	_check((inf["usadas_sin_clave"] as Array).has("HUD.FANTASMA"), "auditor detecta clave usada ausente")
	_check(not (inf["usadas_sin_clave"] as Array).has("SETTINGS.PAUSA"), "auditor no marca claves presentes")
	_check(not (inf["usadas_sin_clave"] as Array).has("NOPE.NOPE.X"), "auditor ignora claves de test")
	_check(not (inf["usadas_sin_clave"] as Array).has("DIARY.CAT_"), "auditor no marca el prefijo dinámico")
	_check(not (inf["usadas_sin_clave"] as Array).has("MAIN_MENU.PLAY"), "tr_key compuesta resuelta")
	var real: Dictionary = AuditorClaves.auditar("res://scripts", "res://locales/es.po")
	_check(int(real["archivos"]) > 100, "auditor real escanea >100 archivos (%d)" % real["archivos"])
	_check(int(real["total_usadas"]) > 20, "auditor real >20 claves usadas (%d)" % real["total_usadas"])
	_check((real["usadas_sin_clave"] as Array).is_empty(), "auditor real: 0 claves de PRODUCCIÓN ausentes -> " + str(real["usadas_sin_clave"]))
	_check(bool(real["ok"]), "auditor real: veredicto OK")
	_check((real["usadas_sin_clave_solo_tests"] as Array).size() > 0, "auditor real: separa los probes de test")
	_check((real["claves_dinamicas"] as Array).has("DIARY.CAT_LUGARES"), "auditor real: reconoce claves de prefijo dinámico")
	print(AuditorClaves.formatear_informe(real))
	_fin("auditor")


## H. Unidades: convención de claves, placeholders y formato de informe.
func _test_unidades() -> void:
	_check(ValidadorPO.clave_cumple_convencion("HUD.ENERGIA"), "HUD.ENERGIA cumple convención")
	_check(ValidadorPO.clave_cumple_convencion("CLOCK.ESTACIONES.0"), "CLOCK.ESTACIONES.0 cumple (3 niveles)")
	_check(not ValidadorPO.clave_cumple_convencion("minus.cosa"), "minus.cosa NO cumple")
	_check(ValidadorPO.clave_cumple_convencion("npc.catalina"), "npc.catalina exenta por diseño")
	var ph: Dictionary = ValidadorPO.placeholders_de("", {0: "uno {n}", 1: "dos {n} %s"})
	_check((ph.get("llaves", []) as Array).has("{n}"), "placeholders_de une formas plurales")
	_check(int(ph.get("printf_n", 0)) == 1, "placeholders_de cuenta printf")
	var inf_aud: Dictionary = {"archivos": 1, "total_usadas": 2, "total_claves": 3, "usadas_sin_clave": ["X.Y"], "usadas_sin_clave_solo_tests": [], "claves_sin_uso": [], "claves_dinamicas": [], "dinamicas": [], "origenes": {}, "errores": [], "ok": false}
	_check(AuditorClaves.formatear_informe(inf_aud).contains("X.Y"), "informe de auditor legible")
	_check(ValidadorPO.formatear_informe(ValidadorPO.validar_archivo("res://locales/es.po")).contains("RESULTADO"), "informe de validador legible")
	_fin("unidades")


## I. Exención P5 declarada en el propio .po con `#. no-traducir: <motivo>`.
##
## La regla P5 ("msgstr idéntico a la fuente") es una HEURÍSTICA: no puede
## distinguir "nadie lo tradujo" de "no hay nada que traducir" (una plantilla
## `→ {destino} · {metros} m`, un código de divisa, `{h} h {m} min`). El marcador
## es un comentario de traductor gettext estándar, así que viaja con el archivo y
## el traductor lo ve en Poedit.
##
## Se prueba en las DOS direcciones con fixtures SINTÉTICOS (no depende del
## estado de los catálogos reales) y después se contrasta contra el par real.
func _test_exencion_p5() -> void:
	var es := CAB + _entrada("HUD.VIDA", "Vida") + _entrada("M68.SIGN.GENERICO", "→ {d} m")
	var marca := "#. no-traducir: plantilla sin palabras\n"
	_escribir(F_EXEN_ES, es)
	_escribir(F_EXEN_SIN, CAB + _entrada("HUD.VIDA", "Vida") + _entrada("M68.SIGN.GENERICO", "→ {d} m"))
	_escribir(F_EXEN_EN, CAB + _entrada("HUD.VIDA", "Vida") + marca + _entrada("M68.SIGN.GENERICO", "→ {d} m"))

	# 1) SIN marcador: el msgstr idéntico se reporta (la regla sigue viva).
	var sin: Dictionary = ValidadorPO.validar_par(F_EXEN_ES, F_EXEN_SIN)
	_check((sin["no_traducidas"] as Array).has("M68.SIGN.GENERICO"), "sin marcador, la entrada idéntica se reporta")
	_check(not (sin["exentas_p5"] as Array).has("M68.SIGN.GENERICO"), "sin marcador, no figura como exenta")
	_check(_tiene(sin["avisos"], "P5 2 clave"), "sin marcador, el aviso P5 cuenta las 2 claves")

	# 2) CON marcador en la traducción: sale de no_traducidas y entra en exentas_p5.
	var con: Dictionary = ValidadorPO.validar_par(F_EXEN_ES, F_EXEN_EN)
	_check(not (con["no_traducidas"] as Array).has("M68.SIGN.GENERICO"), "con marcador, deja de ser no traducida")
	_check((con["exentas_p5"] as Array).has("M68.SIGN.GENERICO"), "con marcador, aparece como exenta")
	_check(_tiene(con["avisos"], "P5 1 clave"), "con marcador, el aviso P5 baja a 1 clave")
	# 3) La exención es POR CLAVE: no contagia al resto del archivo.
	_check((con["no_traducidas"] as Array).has("HUD.VIDA"), "la exención no contagia a las demás claves")

	# 4) El marcador en la FUENTE también exime (es donde el autor declara el diseño).
	_escribir(F_EXEN_ES, CAB + _entrada("HUD.VIDA", "Vida") + marca + _entrada("M68.SIGN.GENERICO", "→ {d} m"))
	var fuente: Dictionary = ValidadorPO.validar_par(F_EXEN_ES, F_EXEN_SIN)
	_check(not (fuente["no_traducidas"] as Array).has("M68.SIGN.GENERICO"), "el marcador en la fuente también exime")

	# 5) El comentario NO se cuela en el texto traducido (parseo).
	var a: Dictionary = ValidadorPO.validar_archivo(F_EXEN_EN)
	_check(str((a["textos"] as Dictionary).get("M68.SIGN.GENERICO", "")) == "→ {d} m", "el comentario no contamina el msgstr")
	_check((a["no_traducibles"] as Array).has("M68.SIGN.GENERICO"), "validar_archivo expone las claves marcadas")
	_check(not (a["no_traducibles"] as Array).has("HUD.VIDA"), "validar_archivo no marca las no exentas")

	# 6) Catálogos REALES: 0 sin traducir y las exenciones son las declaradas.
	var real: Dictionary = ValidadorPO.validar_par("res://locales/es.po", "res://locales/en.po")
	_check((real["no_traducidas"] as Array).is_empty(), "catálogos reales: 0 sin traducir -> " + str(real["no_traducidas"]))
	_check((real["exentas_p5"] as Array).size() >= 13, "catálogos reales: >=13 exenciones declaradas (%d)" % (real["exentas_p5"] as Array).size())
	_check((real["exentas_p5"] as Array).has("M68.TRIP.CURRENCY"), "catálogos reales: el código de divisa está exento")
	_fin("exencion_p5")


func _limpiar() -> void:
	# ⚠️ globalize_path("user://…") devuelve ruta RELATIVA en este entorno;
	# abrir la raíz user:// y borrar por nombre relativo es lo que funciona.
	var d: DirAccess = DirAccess.open("user://")
	if d == null:
		return
	for r in [F_BOM, F_CRLF, F_SIN_CAB, F_VACIO, F_DUP, F_PLURAL, F_MINUS, F_MIX, F_EN_OK, F_EN_FALTA, F_EN_PH, F_EN_SINTRAD, F_EXEN_ES, F_EXEN_EN, F_EXEN_SIN]:
		if d.file_exists(r.get_file()):
			d.remove(r.get_file())
