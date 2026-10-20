# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-20
#
# M87 — COLA V3 item 47 (i18n b2): VALIDACION DE PLACEHOLDERS Y PLURALIZACION.
#
# Que agrega sobre test_validador_po_m87.gd (que ya cubre R1-R13 + P1/P3/P5):
#   * R14 — el catalogo declara `nplurals=N` en la cabecera; hasta hoy solo se
#     verificaba que existiera el indice 0. Un plural con `msgstr[0]` y nada mas
#     pasaba VERDE y el motor cae siempre a la forma 0 (nunca pluraliza).
#   * R15 — `placeholders_de()` UNE todas las formas plurales en un solo
#     conjunto, asi que una forma que pierde `{n}` quedaba invisible: el texto
#     sale sin el numero y no hay error en runtime.
#   * Coherencia llamada<->catalogo para las claves con placeholders printf:
#     un `%d` resuelto con `.format()` NO sustituye nada (devuelve el texto
#     intacto, sin excepcion) -> el jugador ve "Comprar: %d AO".
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral \
#     --script res://scripts/localization/test_placeholders_plurales_m87.gd
#
# ⚠️ TRAMPA (heredada): un error de script aborta la funcion en silencio y las
# aserciones posteriores no corren -> "0 fallos" falso. Cada bloque deja marca
# con `_fin()`, `_run()` exige las 7 marcas y `_summary()` va en su propio
# `call_deferred`. `CHECKS_MINIMOS` es MEDIDO en verde, nunca estimado.

extends SceneTree

# --- Guardia anti-falso-verde (3 capas) -------------------------------------
const CHECKS_MINIMOS := 46
var _checks: int = 0
var _fallos: int = 0
var _wb_cerrado: bool = false
var _hechos: Dictionary = {}

const BLOQUES: Array[String] = [
	"catalogos_reales", "r14_falta", "r14_contiguo",
	"r15_formas", "real_plural_formas", "llamadas_printf", "resolucion_plural",
]

const RUTA_ES := "res://locales/es.po"
const RUTA_EN := "res://locales/en.po"

const CAB := "msgid \"\"\nmsgstr \"\"\n\"Content-Type: text/plain; charset=UTF-8\\n\"\n\"Language: es\\n\"\n\"Plural-Forms: nplurals=2; plural=(n != 1);\\n\"\n\n"


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
	print("=== Resumen M87 placeholders/plurales: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	_test_catalogos_reales()
	_test_r14_falta()
	_test_r14_contiguo()
	_test_r15_formas()
	_test_real_plural_formas()
	_test_llamadas_printf()
	_test_resolucion_plural()
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


func _tiene(items: Array, prefijo: String) -> bool:
	for i in items:
		if str(i).begins_with(prefijo):
			return true
	return false


func _contiene(items: Array, texto: String) -> bool:
	for i in items:
		if str(i).contains(texto):
			return true
	return false


func _escribir(ruta: String, texto: String) -> void:
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	f.store_string(texto)
	f.close()


## Lista recursiva de .gd bajo un directorio `res://`.
func _gd_files(raiz: String) -> Array[String]:
	var out: Array[String] = []
	var pend: Array[String] = [raiz]
	while not pend.is_empty():
		var d: String = pend.pop_back()
		var dir := DirAccess.open(d)
		if dir == null:
			continue
		for f in dir.get_files():
			if f.ends_with(".gd"):
				out.append(d.path_join(f))
		for sub in dir.get_directories():
			pend.append(d.path_join(sub))
	return out


# --- A. catalogo real: base de la regla --------------------------------------

func _test_catalogos_reales() -> void:
	var es: Dictionary = ValidadorPO.validar_archivo(RUTA_ES)
	var en: Dictionary = ValidadorPO.validar_archivo(RUTA_EN)
	_check(int(es["nplurals"]) == 2, "es.po declara nplurals=2 (leido %d)" % int(es["nplurals"]))
	_check(int(en["nplurals"]) == 2, "en.po declara nplurals=2 (leido %d)" % int(en["nplurals"]))
	_check(not _tiene(es["errores"], "R14"), "es.po sin R14 -> " + str(es["errores"]))
	_check(not _tiene(es["errores"], "R15"), "es.po sin R15 -> " + str(es["errores"]))
	_check(not _tiene(en["errores"], "R14"), "en.po sin R14 -> " + str(en["errores"]))
	_check(not _tiene(en["errores"], "R15"), "en.po sin R15 -> " + str(en["errores"]))
	_check(not _contiene(es["avisos"], "R12"), "es.po sin mezcla {llave}/printf -> " + str(es["avisos"]))
	_check(not _contiene(en["avisos"], "R12"), "en.po sin mezcla {llave}/printf -> " + str(en["avisos"]))
	_check((es["claves_plural"] as Array).size() == 4, "es.po con 4 claves plurales (tiene %d)" % (es["claves_plural"] as Array).size())
	_check((en["claves_plural"] as Array).size() == 4, "en.po con 4 claves plurales (tiene %d)" % (en["claves_plural"] as Array).size())
	var par: Dictionary = ValidadorPO.validar_par(RUTA_ES, RUTA_EN)
	_check(bool(par["ok"]), "par es<->en sin errores -> " + str(par["errores"]))
	_check((par["placeholders_desalineados"] as Array).is_empty(), "placeholders alineados es<->en")
	_fin("catalogos_reales")


# --- B. R14: forma plural ausente (fixture rojo + control verde) -------------

func _test_r14_falta() -> void:
	var rojo := "user://m87pp_falta.po"
	_escribir(rojo, CAB + "msgid \"T.SECC.PLURAL\"\nmsgid_plural \"T.SECC.PLURAL\"\nmsgstr[0] \"{n} cosa\"\n\n")
	var r: Dictionary = ValidadorPO.validar_archivo(rojo)
	_check(_contiene(r["errores"], "falta msgstr[1]"), "R14 detecta la forma 1 ausente -> " + str(r["errores"]))
	_check(not bool(r["ok"]), "R14 pone ok=false (no se puede cerrar en verde)")
	var verde := "user://m87pp_ok.po"
	_escribir(verde, CAB + "msgid \"T.SECC.PLURAL\"\nmsgid_plural \"T.SECC.PLURAL\"\nmsgstr[0] \"{n} cosa\"\nmsgstr[1] \"{n} cosas\"\n\n")
	var r2: Dictionary = ValidadorPO.validar_archivo(verde)
	_check(not _tiene(r2["errores"], "R14"), "R14 no marca un plural completo (control) -> " + str(r2["errores"]))
	_check(bool(r2["ok"]), "el plural completo cierra ok -> " + str(r2["errores"]))
	_fin("r14_falta")


# --- C. R14: indices no contiguos --------------------------------------------

func _test_r14_contiguo() -> void:
	var f := "user://m87pp_contiguo.po"
	_escribir(f, CAB + "msgid \"T.SECC.PLURAL\"\nmsgid_plural \"T.SECC.PLURAL\"\nmsgstr[0] \"{n} cosa\"\nmsgstr[2] \"{n} cosas\"\n\n")
	var r: Dictionary = ValidadorPO.validar_archivo(f)
	_check(_contiene(r["errores"], "no contiguos"), "R14 detecta indices no contiguos -> " + str(r["errores"]))
	_check(_contiene(r["errores"], "falta msgstr[1]"), "R14 nombra el indice que falta (1)")
	_check(not bool(r["ok"]), "indices no contiguos ponen ok=false")
	_fin("r14_contiguo")


# --- D. R15: una forma pierde el placeholder ---------------------------------

func _test_r15_formas() -> void:
	var rojo := "user://m87pp_forma_sin_n.po"
	_escribir(rojo, CAB + "msgid \"T.SECC.PLURAL\"\nmsgid_plural \"T.SECC.PLURAL\"\nmsgstr[0] \"{n} hora\"\nmsgstr[1] \"horas\"\n\n")
	var r: Dictionary = ValidadorPO.validar_archivo(rojo)
	_check(_contiene(r["errores"], "R15"), "R15 detecta una forma sin {n} -> " + str(r["errores"]))
	_check(_contiene(r["errores"], "T.SECC.PLURAL"), "R15 nombra la clave afectada")
	_check(not bool(r["ok"]), "R15 pone ok=false")
	var verde := "user://m87pp_forma_ok.po"
	_escribir(verde, CAB + "msgid \"T.SECC.PLURAL\"\nmsgid_plural \"T.SECC.PLURAL\"\nmsgstr[0] \"{n} hora\"\nmsgstr[1] \"{n} horas\"\n\n")
	var r2: Dictionary = ValidadorPO.validar_archivo(verde)
	_check(not _tiene(r2["errores"], "R15"), "R15 no marca formas coherentes (control)")
	var r3: Dictionary = ValidadorPO.validar_archivo("user://m87pp_forma_sin_n.po")
	_check((r3["claves_plural"] as Array).has("T.SECC.PLURAL"), "la clave plural se sigue listando con R15")
	_fin("r15_formas")


# --- E. datos REALES: cada forma plural lleva {n} -----------------------------

func _test_real_plural_formas() -> void:
	var es: Dictionary = ValidadorPO.validar_archivo(RUTA_ES)
	var claves: Array = es["claves_plural"]
	_check(claves.size() == 4, "se auditan las 4 claves plurales reales")
	var sin_n: Array = []
	var formas_ok: int = 0
	for k in claves:
		var texto: String = str((es["textos"] as Dictionary).get(k, ""))
		var formas: Array = texto.split(" | ")
		if formas.size() == 2:
			formas_ok += 1
		for i in range(formas.size()):
			if not str(formas[i]).contains("{n}"):
				sin_n.append("%s[%d]" % [k, i])
	_check(formas_ok == 4, "las 4 claves plurales reales tienen 2 formas (tienen %d)" % formas_ok)
	_check(sin_n.is_empty(), "toda forma plural real lleva {n} -> " + str(sin_n))
	var en: Dictionary = ValidadorPO.validar_archivo(RUTA_EN)
	_check((en["claves_plural"] as Array).size() == (es["claves_plural"] as Array).size(), "es y en declaran el mismo numero de claves plurales")
	var en_sin_n: Array = []
	for k in (en["claves_plural"] as Array):
		var texto: String = str((en["textos"] as Dictionary).get(k, ""))
		for f in texto.split(" | "):
			if not str(f).contains("{n}"):
				en_sin_n.append(k)
	_check(en_sin_n.is_empty(), "toda forma plural de en.po lleva {n} -> " + str(en_sin_n))
	_fin("real_plural_formas")


# --- F. llamada <-> catalogo para claves con placeholders printf -------------

func _test_llamadas_printf() -> void:
	var es: Dictionary = ValidadorPO.validar_archivo(RUTA_ES)
	var claves: Array = []
	for k in (es["placeholders"] as Dictionary).keys():
		if (es["placeholders"][k] as Dictionary).has("printf"):
			claves.append(k)
	_check(claves.size() == 7, "claves con placeholders printf medidas: %d" % claves.size())
	var archivos: Array[String] = _gd_files("res://scripts")
	_check(archivos.size() > 50, "se escanearon %d .gd (guardia anti-vacio)" % archivos.size())
	var malos: Array = []
	var sitios: int = 0
	var con_sitio: Array = []
	for k in claves:
		var tiene_sitio: bool = false
		for f in archivos:
			var lineas: PackedStringArray = FileAccess.get_file_as_string(f).split("\n")
			for i in range(lineas.size()):
				var l: String = lineas[i].strip_edges()
				if not l.contains("\"%s\"" % k):
					continue
				if l.begins_with("#") or l.contains("const "):
					continue
				tiene_sitio = true
				sitios += 1
				if l.contains(".format("):
					malos.append("%s:%d" % [f, i + 1])
		if tiene_sitio:
			con_sitio.append(k)
	_check(sitios >= 5, "sitios de llamada medidos (guardia anti-vacio): %d" % sitios)
	_check(malos.is_empty(), "ningun sitio de clave printf usa .format() (no sustituye) -> " + str(malos))
	print("[info] claves printf con sitio de llamada: %d/%d -> %s" % [con_sitio.size(), claves.size(), str(con_sitio)])
	print("[info] claves printf SIN sitio de llamada (huerfanas): %d" % (claves.size() - con_sitio.size()))
	_fin("llamadas_printf")


# --- G. el camino real de resolucion de plurales -----------------------------

func _test_resolucion_plural() -> void:
	var ruta := "res://scripts/localization/localization_manager.gd"
	_check(FileAccess.file_exists(ruta), "existe localization_manager.gd")
	var src: String = FileAccess.get_file_as_string(ruta)
	_check(src.contains("_plural_forms"), "el manager guarda formas plurales en _plural_forms")
	_check(src.contains("func _buscar_texto"), "existe _buscar_texto (resolucion por n)")
	_check(src.contains("if n != -1"), "la rama plural se activa por n != -1")
	# Medido: el proyecto NO usa tr_n() del motor; pluraliza por su cuenta.
	# ⚠️ Se excluyen los `test_*.gd`: este mismo archivo nombra `tr_n(` 3 veces
	# (comentario + print + asercion) y se contaba a si mismo -> 3 en vez de 0.
	var tr_n: int = 0
	var archivos_prod: int = 0
	for f in _gd_files("res://scripts"):
		if f.get_file().begins_with("test_"):
			continue
		archivos_prod += 1
		tr_n += FileAccess.get_file_as_string(f).count("tr_n(")
	print("[info] .gd de produccion escaneados: %d | llamadas a tr_n(): %d (el proyecto pluraliza via _plural_forms)" % [archivos_prod, tr_n])
	_check(archivos_prod > 50, "se escanearon %d .gd de produccion (guardia anti-vacio)" % archivos_prod)
	_check(tr_n == 0, "el catalogo plural se sirve por _plural_forms, no por tr_n (medido %d)" % tr_n)
	_fin("resolucion_plural")


func _limpiar() -> void:
	var d := DirAccess.open("user://")
	if d == null:
		return
	for f in ["m87pp_falta.po", "m87pp_ok.po", "m87pp_contiguo.po", "m87pp_forma_sin_n.po", "m87pp_forma_ok.po"]:
		if d.file_exists(f):
			d.remove(f)
