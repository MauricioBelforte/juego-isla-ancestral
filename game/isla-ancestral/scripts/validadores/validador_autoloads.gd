# Modelo: space-bunny-alpha
# Plataforma: Kilo Code
# Fecha: 2026-10-05
# SB-08 · Log 1297
#
# M151-family guard: validador de autoloads.
#
# Lee la seccion [autoload] de project.godot y, por cada autoload, verifica que
# el .gd referenciado (a) EXISTA y (b) COMPILE. Sin esas dos comprobaciones, un
# autoload roto produce la familia BUG-091 ("Identifier not found: <Autoload>")
# en 44 lugares del proyecto, y el mismo error se reporta N veces.
#
# Uso (headless):
#   godot --headless --path game/isla-ancestral \
#         --script scripts/validadores/validador_autoloads.gd
#
# Salida por autoload:
#   OK    <nombre> -> <ruta>
#   FALLA <nombre> -> <motivo>
#
# Codigo de salida (misma convencion que scripts/verificar_checklist.py, BUG-075):
#   0  todos los autoloads existen y compilan
#   1  al menos uno falla (fail-fast al terminar el recorrido, NO en el primero:
#       se reporta la lista completa para poder arreglarla de una vez)
#   3  DETECTOR CIEGO: no pude leer project.godot (no existe, vacio, sin
#       seccion [autoload]). NO es "0 fallos": es "no mire".
#
# Por que el chequeo de compilacion es `load()` + `reload()` SOBRE EL RECURSO
# CARGADO (y no `source_code + reload()`, que es lo obvio):
#
# MEDIDO en este repo con sondas descartables, no supuesto:
#   A) `GDScript.new()` + `source_code` + `reload()`
#      -> FALSOS POSITIVOS. Marca 6 autoloads que SI compilan (EventBus,
#         TooltipService, NotificationService, TermsManager, combat_island,
#         gem_currency) con "Parse error". El motivo real que Godot imprime es
#         `Parse Error: Class "EventBus_" hides a global script class`: un
#         GDScript ANONIMO (sin ruta) no tiene contexto de `class_name`, asi
#         que choca con la clase ya registrada en el proyecto.
#   B) `ResourceLoader.load()` solo
#      -> NO detecta errores de sintaxis: devuelve un GDScript igual. Un .gd con
#         `func roto(:` carga "bien" y solo explota al instanciarse.
#   C) `ResourceLoader.load()` + `(r as GDScript).reload()`   <-- ESTE
#      -> Detecta la rotura real (`Parse error`, `can_instantiate=false`) y NO
#         produce falsos positivos: sobre un autoload ya instanciado por el
#         proyecto devuelve ERR_ALREADY_IN_USE, que NO es un fallo de compilacion
#         (si hubiera compilado mal, nunca habria llegado a estar instanciado).
#
# Los tres metodos se mediron con las sondas `_sonda_1..4.gd` (descartadas al
# terminar; sus resultados quedaron en el Log 1299). El metodo C quedo porque es
# el unico que separa la rotura real del falso positivo.

extends SceneTree

const RUTA_PROJECT_POR_DEFECTO := "res://project.godot"


## Normaliza el valor de un autoload: quita el prefijo '*' (singleton) y
## comillas, y valida que sea una ruta res:// con extension .gd.
static func normalizar_ruta(bruta: String) -> Dictionary:
	var s := bruta.strip_edges()
	if s.begins_with("*"):
		s = s.substr(1).strip_edges()
	if s.begins_with("&"):
		s = s.substr(1).strip_edges()
	s = s.strip_edges().trim_prefix("\"").trim_suffix("\"")
	if not s.begins_with("res://"):
		return {"ok": false, "motivo": "no es ruta res:// ('%s')" % s, "ruta": s}
	if not s.ends_with(".gd"):
		return {"ok": false, "motivo": "no apunta a un .gd ('%s')" % s, "ruta": s}
	return {"ok": true, "motivo": "", "ruta": s}


## Verifica UN autoload. Devuelve {ok, nombre, ruta, existe, compila, motivo}.
##
## Por que NO soporta rutas fuera de res://: el metodo autoritativo (load)
## solo existe sobre el VFS del proyecto. Aceptar rutas de disco exigiría el
## metodo A, que ya se demostro que produce falsos positivos. Prefiero un
## validador que cubre el caso real (project.godot) sin mentir sobre los demas.
static func verificar_autoload(nombre: String, ruta_bruta: String) -> Dictionary:
	var res := {"ok": false, "nombre": nombre, "ruta": ruta_bruta,
		"existe": false, "compila": false, "motivo": ""}

	var n := normalizar_ruta(ruta_bruta)
	res["ruta"] = n["ruta"]
	if not n["ok"]:
		res["motivo"] = n["motivo"]
		return res

	var ruta: String = n["ruta"]

	# (a) EXISTENCIA (ResourceLoader.exists respeta el VFS; el .import no cuenta
	# como fuente).
	var existe := ResourceLoader.exists(ruta) or FileAccess.file_exists(ruta)
	res["existe"] = existe
	if not existe:
		res["motivo"] = "el archivo no existe"
		return res

	# (b) CARGA — lo que Godot hace al bootear.
	var r := ResourceLoader.load(ruta, "", ResourceLoader.CACHE_MODE_IGNORE)
	if r == null:
		res["motivo"] = "ResourceLoader.load devolvio null"
		return res
	if not (r is GDScript):
		res["motivo"] = "la ruta no resuelve a un GDScript (%s)" % r.get_class()
		return res

	# (c) COMPILACION sobre el recurso YA CARGADO (tiene ruta, asi que el
	# class_name resuelve). ERR_ALREADY_IN_USE = ya estaba instanciado por el
	# proyecto, o sea que compilo.
	var gs := r as GDScript
	var err: int = gs.reload()
	if err != OK and err != ERR_ALREADY_IN_USE:
		res["motivo"] = "no compila (%s)" % error_string(err)
		return res

	# Corroborante: si no se puede instanciar, el script esta roto aunque el
	# reload no se quejara (p.ej. falta una clase base).
	if not gs.can_instantiate():
		res["motivo"] = "no se puede instanciar (clase base ausente o script invalido)"
		return res

	res["compila"] = true
	res["ok"] = true
	return res


## Lee la seccion [autoload] de un project.godot.
## Devuelve {ok, motivo, mapa: {nombre: ruta}}.
static func leer_autoloads(ruta_project: String) -> Dictionary:
	if not FileAccess.file_exists(ruta_project):
		return {"ok": false, "motivo": "no existe %s" % ruta_project, "mapa": {}}
	var cf := ConfigFile.new()
	var err := cf.load(ruta_project)
	if err != OK:
		return {"ok": false, "motivo": "no se pudo leer (%s)" % error_string(err), "mapa": {}}
	if not cf.has_section("autoload"):
		return {"ok": false, "motivo": "no hay seccion [autoload] en %s" % ruta_project,
			"mapa": {}}
	var mapa := {}
	for k in cf.get_section_keys("autoload"):
		mapa[String(k)] = String(cf.get_value("autoload", k, ""))
	return {"ok": true, "motivo": "", "mapa": mapa}


## Verifica todos los autoloads de un project.godot.
## Devuelve {ok, resultados: Array[Dictionary], duplicados: Array}.
static func verificar_proyecto(ruta_project: String) -> Dictionary:
	var lec := leer_autoloads(ruta_project)
	if not lec["ok"]:
		return {"ok": false, "motivo": lec["motivo"], "resultados": [], "duplicados": []}

	var mapa: Dictionary = lec["mapa"]
	var nombres := mapa.keys()
	nombres.sort()

	var resultados := []
	for n in nombres:
		resultados.append(verificar_autoload(String(n), String(mapa[n])))

	# Dos autoloads apuntando al MISMO archivo casi siempre es un sistema
	# duplicado (histórico: el proyecto tuvo un par Localization/LocalizationManager,
	# resuelto en BUG-104 2026-10-08 — solo queda "Localization").
	# No es un fallo del boot, asi que se reporta aparte, no como FALLA.
	var por_ruta := {}
	for n in nombres:
		var nr := normalizar_ruta(String(mapa[n]))
		if not nr["ok"]:
			continue
		if not por_ruta.has(nr["ruta"]):
			por_ruta[nr["ruta"]] = []
		por_ruta[nr["ruta"]].append(String(n))
	var duplicados := []
	for ruta in por_ruta.keys():
		if por_ruta[ruta].size() > 1:
			duplicados.append({"ruta": ruta, "nombres": por_ruta[ruta]})
	duplicados.sort_custom(func(a, b): return String(a["ruta"]) < String(b["ruta"]))

	var todos_ok := true
	for r in resultados:
		if not r["ok"]:
			todos_ok = false
	return {"ok": todos_ok, "resultados": resultados, "duplicados": duplicados}


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var ruta := RUTA_PROJECT_POR_DEFECTO
	for a in OS.get_cmdline_user_args():
		if String(a).begins_with("--project="):
			ruta = String(a).substr("--project=".length())

	print("=== [SB-08] Validador de autoloads ===")
	print("project.godot: %s" % ruta)
	print("")

	var v := verificar_proyecto(ruta)

	# exit 3 = detector ciego: no pude leer la fuente. NO es "0 fallos".
	if not v.has("resultados") or (v["resultados"] as Array).is_empty():
		print("== [SB-08] DETECTOR CIEGO: %s ==" % v.get("motivo", "sin resultados"))
		print("Esto NO es 'todos los autoloads OK': es 'no mire'.")
		quit(3)
		return

	var fallan := 0
	for r in v["resultados"]:
		if r["ok"]:
			print("OK    %s -> %s" % [r["nombre"], r["ruta"]])
		else:
			fallan += 1
			print("FALLA %s -> %s" % [r["nombre"], r["motivo"]])

	print("")
	print("autoloads verificados: %d · OK: %d · FALLAN: %d"
		% [v["resultados"].size(), v["resultados"].size() - fallan, fallan])

	if not (v["duplicados"] as Array).is_empty():
		print("")
		print("AVISO — %d ruta(s) compartida(s) por mas de un autoload" % (v["duplicados"] as Array).size())
		print("  (no es un fallo del boot, pero un sistema duplicado suele serlo):")
		for d in v["duplicados"]:
			print("    %s -> %s" % [d["ruta"], ", ".join(PackedStringArray(d["nombres"]))])

	print("")
	if fallan == 0:
		print("== [SB-08] TODOS LOS AUTOLOADS OK ==")
		quit(0)
	else:
		print("== [SB-08] BLOQUEADO — %d autoload(s) con problema ==" % fallan)
		quit(1)