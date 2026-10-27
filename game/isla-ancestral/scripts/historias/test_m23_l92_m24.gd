# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-26
#
# M23 — suite del item L92 ("Definir la integracion con el framework M24").
# Ejecutar: godot --headless --path game/isla-ancestral \
#   --script res://scripts/historias/test_m23_l92_m24.gd
#
# La suite NO fija los numeros del catalogo ni de las cadenas: los CRUZA en las
# dos direcciones y por caminos independientes.
#   - Catalogo M24: el API (Puente.catalogo) contra un conteo de disco
#     hecho aca mismo con DirAccess, y cada entrada contra su propio JSON.
#   - Cadenas: los `ref` de paso puzzle que ve el SERVICIO contra los que hay en
#     los JSON crudos, cadena por cadena.
# Si manana una cadena empieza a apuntar a un puzzle real de M24, la suite sigue
# verde con otros numeros. Si el puente miente, se pone roja.
#
# Guarda de 3 capas del repo: _fin(bloque) al FINAL de cada bloque + piso
# CHECKS_MINIMOS MEDIDO en verde + _summary() en un call_deferred SEPARADO de
# _run() (si _run() aborta por SCRIPT ERROR, el resumen corre igual y sale EXIT 1).

extends SceneTree

## Piso MEDIDO en verde el 2026-10-26 (36 checks, 0 fallos, EXIT 0 x3). No es una
## estimacion: se corrio primero con 30 y el resumen publico 36.
const CHECKS_MINIMOS := 36
const BLOQUES := ["A", "B", "C", "D", "E", "F"]

const RUTA_PUZZLES := "res://data/templos/puzzles"
const RUTAS_CADENAS := [
	"res://data/historias/secundarias.json",
	"res://data/historias/cadenas_ejemplo.json",
]

## El puente se carga por RUTA, no por su `class_name`: un class_name nuevo no
## esta en `.godot/global_script_class_cache.cfg` hasta que el editor reimporta,
## y esta suite tiene que correr headless sin depender de esa cache.
const Puente = preload("res://scripts/historias/puzzle_bridge_m24.gd")

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}
var _h: Node = null
var _cat: Dictionary = {}


func _init() -> void:
	# Dos diferidas SEPARADAS: si `_run()` aborta, la cola sigue y `_summary()`
	# corre igual (nombra el bloque que falta y sale != 0).
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	_h = root.get_node_or_null("Historias")
	_check(_h != null, "Historias autoload presente")
	if _h == null:
		return
	_cat = Puente.catalogo()
	_test_catalogo()
	_test_clasificacion()
	_test_inverso()
	_test_puente()
	_test_ceguera()
	_test_contrato()


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if cond:
		print("  [OK] " + msg)
	else:
		_fallos += 1
		print("  [FALLO] " + msg)


func _fin(bloque: String) -> void:
	_vistos[bloque] = true


func _summary() -> void:
	var faltan: Array = []
	for b in BLOQUES:
		if not _vistos.has(b):
			faltan.append(b)
	if not faltan.is_empty():
		_fallos += 1
		print("[FAIL] bloques que NO se ejecutaron (posible SCRIPT ERROR): %s" % str(faltan))
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== TEST M23 L92 (puente M24): %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)


# --- Bloque A: el catalogo de M24, API contra disco ----------------------

func _test_catalogo() -> void:
	_check(not _cat.is_empty(), "catalogo M24 no vacio (%d puzzles)" % _cat.size())
	# Conteo por un camino INDEPENDIENTE del que usa el puente.
	var en_disco: int = _contar_json(RUTA_PUZZLES)
	_check(en_disco == _cat.size(),
		"el API ve los mismos puzzles que el disco (%d disco / %d API)" % [en_disco, _cat.size()])
	# Cada entrada: el archivo existe y su `id` declarado coincide con la clave.
	var malos: Array = []
	for id in _cat:
		var ruta := String(_cat[id])
		if not FileAccess.file_exists(ruta):
			malos.append("%s(sin archivo)" % String(id))
			continue
		var def: Dictionary = PuzzleDef.cargar(ruta)
		if String(def.get("id", "")) != String(id):
			malos.append("%s(id='%s')" % [String(id), String(def.get("id", ""))])
	_check(malos.is_empty(), "cada entrada del catalogo existe y su id coincide (malos=%s)" % str(malos))
	# Los puzzles de M24 son validos por su PROPIO validador (no heredo el sello).
	var invalidos: Array = []
	for id in _cat:
		var errs: Array = PuzzleDef.validar_def(PuzzleDef.cargar(String(_cat[id])))
		if not errs.is_empty():
			invalidos.append("%s:%s" % [String(id), str(errs[0])])
	_check(invalidos.is_empty(), "los puzzles del catalogo validan en M24 (invalidos=%s)" % str(invalidos))
	_fin("A")


func _contar_json(dir: String) -> int:
	var n := 0
	var d := DirAccess.open(dir)
	if d == null:
		return 0
	d.list_dir_begin()
	var e := d.get_next()
	while e != "":
		if not e.begins_with("."):
			var ruta := dir.path_join(e)
			if d.current_is_dir():
				n += _contar_json(ruta)
			elif e.get_extension().to_lower() == "json":
				n += 1
		e = d.get_next()
	d.list_dir_end()
	return n


# --- Bloque B: clasificacion de los ref de M23 ---------------------------

func _test_clasificacion() -> void:
	var ids: Array = _h.ids_cadenas()
	_check(not ids.is_empty(), "el servicio expone las cadenas cargadas (%d)" % ids.size())
	# Camino 1: lo que ve el SERVICIO. Camino 2: los JSON crudos.
	var disco: Dictionary = _refs_de_disco()
	var desalineadas: Array = []
	for cid in ids:
		var api: Array = _refs_de_paso(String(cid))
		var crudo: Array = disco.get(String(cid), [])
		var a: Array = api.duplicate()
		var b: Array = crudo.duplicate()
		a.sort()
		b.sort()
		if a != b:
			desalineadas.append("%s(api=%d,disco=%d)" % [String(cid), a.size(), b.size()])
	_check(desalineadas.is_empty(),
		"los ref de puzzle coinciden servicio<->disco en las %d cadenas (mal=%s)" % [ids.size(), str(desalineadas)])
	var clasif: Dictionary = Puente.clasificar_servicio(_h, _cat)
	var total := int(clasif.get("total", -1))
	var suma: int = (clasif["m24"] as Array).size() + (clasif["narrativo"] as Array).size() \
		+ (clasif["vacio"] as Array).size()
	_check(total == suma, "todo paso puzzle queda clasificado (%d = %d)" % [total, suma])
	_check((clasif["vacio"] as Array).is_empty(),
		"ningun paso puzzle sin ref (%s)" % str(clasif["vacio"]))
	# Bidireccional: "m24" <=> esta en el catalogo.
	var falsos_m24: Array = []
	for r in (clasif["m24"] as Array):
		if not _cat.has(String(r)):
			falsos_m24.append(String(r))
	_check(falsos_m24.is_empty(), "todo ref clasificado m24 esta en el catalogo (%s)" % str(falsos_m24))
	var falsos_nar: Array = []
	for r in (clasif["narrativo"] as Array):
		if _cat.has(String(r)):
			falsos_nar.append(String(r))
	_check(falsos_nar.is_empty(), "ningun ref clasificado narrativo esta en el catalogo (%s)" % str(falsos_nar))
	print("  [MEDIDO] pasos puzzle: %d | m24: %d | narrativo: %d | vacio: %d" % [
		total, (clasif["m24"] as Array).size(),
		(clasif["narrativo"] as Array).size(), (clasif["vacio"] as Array).size()])
	_fin("B")


func _refs_de_paso(cadena_id: String) -> Array:
	var out: Array = []
	var pasos: Variant = _h.get_cadena(cadena_id).get("pasos", [])
	if typeof(pasos) != TYPE_ARRAY:
		return out
	for p in (pasos as Array):
		if typeof(p) == TYPE_DICTIONARY and String((p as Dictionary).get("tipo", "")) == "puzzle":
			out.append(String((p as Dictionary).get("ref", "")))
	return out


func _refs_de_disco() -> Dictionary:
	# Mismo criterio que el merge del servicio: el catalogo PRINCIPAL gana y los
	# ejemplos solo aportan ids nuevos. Sin esto, `cadena-faro` (que existe en los
	# dos archivos con ref distinto: faro-linterna vs M25-faro-linterna) se
	# comparaba contra la version equivocada. Medido 2026-10-26.
	var out: Dictionary = {}
	for ruta in RUTAS_CADENAS:
		var crudo: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta))
		if typeof(crudo) != TYPE_DICTIONARY:
			continue
		var lst: Variant = (crudo as Dictionary).get("cadenas", [])
		if typeof(lst) != TYPE_ARRAY:
			continue
		for c in (lst as Array):
			if typeof(c) != TYPE_DICTIONARY:
				continue
			var cid := String((c as Dictionary).get("id", ""))
			if out.has(cid):
				continue
			var refs: Array = []
			var pasos: Variant = (c as Dictionary).get("pasos", [])
			if typeof(pasos) == TYPE_ARRAY:
				for p in (pasos as Array):
					if typeof(p) == TYPE_DICTIONARY and String((p as Dictionary).get("tipo", "")) == "puzzle":
						refs.append(String((p as Dictionary).get("ref", "")))
			out[cid] = refs
	return out


# --- Bloque C: el otro sentido del cruce --------------------------------

func _test_inverso() -> void:
	var clasif: Dictionary = Puente.clasificar_servicio(_h, _cat)
	var sin_uso: Array = Puente.m24_sin_uso(_cat, clasif)
	var usados: Dictionary = {}
	for r in (clasif["m24"] as Array):
		usados[String(r)] = true
	_check(usados.size() + sin_uso.size() == _cat.size(),
		"usados(%d) + sin_uso(%d) cubren el catalogo(%d)" % [usados.size(), sin_uso.size(), _cat.size()])
	var repetidos: Array = []
	var vistos: Dictionary = {}
	for id in sin_uso:
		if vistos.has(String(id)):
			repetidos.append(String(id))
		vistos[String(id)] = true
	_check(repetidos.is_empty(), "m24_sin_uso() sin duplicados (%s)" % str(repetidos))
	var solapan: Array = []
	for id in sin_uso:
		if usados.has(String(id)):
			solapan.append(String(id))
	_check(solapan.is_empty(), "ningun puzzle esta a la vez usado y sin uso (%s)" % str(solapan))
	print("  [MEDIDO] puzzles de M24 usados por alguna cadena: %d de %d" % [usados.size(), _cat.size()])
	_fin("C")


# --- Bloque D: el puente completa un paso de verdad ---------------------

func _test_puente() -> void:
	# cadena-faro tiene el orden hablar -> explorar -> PUZZLE -> entregar, asi que
	# el paso puzzle es alcanzable con dos reportes y, al completarse la sala, la
	# cadena NO queda cerrada (queda el entregar): eso prueba que el puente avanzo
	# EXACTAMENTE un paso y no que salteo el resto.
	var cid := "cadena-faro"
	var res: Dictionary = _h.iniciar_cadena(cid)
	_check(bool(res.get("ok", false)), "iniciar %s OK (%s)" % [cid, String(res.get("motivo", ""))])
	res = _h.reportar_paso(cid, "hablar", "farero")
	_check(bool(res.get("ok", false)), "paso hablar farero OK")
	res = _h.reportar_paso(cid, "explorar", "faro")
	_check(bool(res.get("ok", false)), "paso explorar faro OK")
	var ref := String(_h.ref_paso_actual(cid))
	var ref_esperado := String(_refs_de_paso(cid)[0]) if not _refs_de_paso(cid).is_empty() else ""
	_check(not ref.is_empty() and ref == ref_esperado,
		"ref_paso_actual() coincide con el ref declarado por el dato ('%s' vs '%s')" % [ref, ref_esperado])
	# Control negativo: la evidencia del paso se sigue exigiendo.
	res = _h.reportar_paso(cid, "puzzle", "evidencia-que-no-es")
	_check(not bool(res.get("ok", false)) and String(res.get("motivo", "")).contains("evidencia"),
		"evidencia incorrecta rechazada antes de conectar (%s)" % String(res.get("motivo", "")))
	# Sala REAL de M24 (primer id del catalogo, medido; no hardcodeado).
	var ids: Array = _cat.keys()
	ids.sort()
	var pid := String(ids[0])
	var sala: PuzzleRoom = Puente.sala_de(pid, _cat)
	_check(sala != null, "sala_de('%s') construye una PuzzleRoom de M24" % pid)
	if sala == null:
		_fin("D")
		return
	res = Puente.conectar(sala, _h, cid)
	_check(bool(res.get("ok", false)), "conectar() cablea la sala al paso (%s)" % String(res.get("motivo", "")))
	# Completar la sala: encender el objetivo declarado por M24.
	for e in sala.objetivo:
		sala.set_emisor(int(e), true)
	_check(sala.completada, "la sala quedo completada con el objetivo encendido")
	# El puente avanzo EXACTAMENTE un paso: la cadena sigue activa (falta el
	# entregar) y el ref esperado ya no es el del puzzle.
	var ref_post := String(_h.ref_paso_actual(cid))
	_check(ref_post != ref and not ref_post.is_empty(),
		"el puente avanzo 1 paso: ref esperado ahora '%s' (era '%s')" % [ref_post, ref])
	_check(_h.esta_activa(cid) and not _h.esta_completada(cid),
		"la cadena sigue activa: el puente no salteo los pasos restantes")
	# Cerrar la cadena a mano prueba que el paso reportado por el puente quedo
	# REALMENTE consumado (no fue un avance fantasma).
	var inv := root.get_node_or_null("Inventario")
	if inv != null:
		inv.agregar_items({"farol_cargado": 1})
	res = _h.reportar_entrega(cid)
	_check(bool(res.get("ok", false)), "la cadena cierra despues del paso puenteado (%s)" % String(res.get("motivo", "")))
	_check(_h.esta_completada(cid), "cadena-faro completada tras el paso puenteado")
	# Controles de rechazo del puente.
	_check(not bool(Puente.conectar(null, _h, cid).get("ok", true)), "conectar(null) rechazado")
	_check(not bool(Puente.conectar(sala, null, cid).get("ok", true)), "conectar(servicio null) rechazado")
	_fin("D")


# --- Bloque E: guardas de ceguera --------------------------------------

func _test_ceguera() -> void:
	# Un escaneo roto devuelve {} y entonces TODOS los ref parecen "narrativo":
	# el numero sube y parece correcto. El piso lo delata.
	_check(_cat.size() >= 20, "catalogo NO ciego: %d puzzles (piso 20)" % _cat.size())
	_check(Puente.resolver("", _cat) == Puente.TIER_VACIO,
		"resolver('') = vacio")
	var alguno := String(_cat.keys()[0])
	_check(Puente.resolver(alguno, _cat) == Puente.TIER_M24,
		"resolver('%s') = m24" % alguno)
	_check(Puente.resolver("no-existe-jamas-en-m24", _cat) == Puente.TIER_NARRATIVO,
		"resolver(ref inexistente) = narrativo")
	_fin("E")


# --- Bloque F: el contrato de M23 quedo intacto ------------------------

func _test_contrato() -> void:
	var errores: Array = _h.validar_cadenas()
	_check(errores.is_empty(), "validar_cadenas() sigue sin errores (%s)" % str(errores))
	_check(String(_h.ref_paso_actual("cadena-que-no-existe")) == "",
		"ref_paso_actual() de una cadena inexistente devuelve \"\"")
	# El contrato de tipos sigue vigente: con la cadena ACTIVA, un tipo
	# desconocido no avanza nada (si no se iniciara, el rechazo seria por
	# "cadena no activa" y el check no probaria el contrato de tipos).
	var cid := "cadena-jardines"
	_h.iniciar_cadena(cid)
	var res: Dictionary = _h.reportar_paso(cid, "tipo-inventado", "jardines")
	_check(not bool(res.get("ok", false)) and String(res.get("motivo", "")).contains("tipo"),
		"tipo de paso desconocido sigue rechazado (%s)" % String(res.get("motivo", "")))
	_check(int(_h.get_cadena(cid).get("pasos", []).size()) > 0, "la cadena de control tiene pasos")
	_fin("F")
