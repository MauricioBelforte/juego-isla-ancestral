# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-02
#
# M62: Memoria — Suite de la iter. 6 (Log 1196)
#
# Cierra el item L98 del checklist (§E RF4 Prevencion de leaks):
#   "Los datos de partida (M29) no retienen referencias a nodos del mundo [M]"
#
# Que mide
# --------
# El contrato ISaveProvider (M59) dice que `get_save_data()` devuelve el estado
# del sistema como DATOS. Si un proveedor devolviera un Nodo (o un Dictionary
# que lo contuviera), el payload del save retendria una referencia al mundo:
# leak garantizado (el nodo no se puede liberar mientras el save viva) y ademas
# un valor no serializable. Esta suite recorre RECURSIVAMENTE el payload de los
# 39 proveedores registrados como autoload y exige 0 referencias a objetos.
#
# Por que en runtime y no solo estatico
# -------------------------------------
# Un analisis estatico no puede resolver el tipo de un miembro (`self._cache`
# puede o no ser un Nodo); la unica prueba honesta del item es llamar a
# `get_save_data()` de verdad y mirar que devuelve. Por eso es una suite
# headless: los autoloads ya registraron sus 39 proveedores al arrancar.
#
# Guardia anti-falso-verde de 3 capas (skill §2, trampas 11/28/46/61/63/119):
#   1. marcadores `_fin("X")` por bloque -> nombra el bloque que no corrio;
#   2. piso `CHECKS_MINIMOS` MEDIDO en verde -> caza el aborto en un helper;
#   3. `_summary()` en un `call_deferred` APARTE -> si `_run()` aborta por un
#      SCRIPT ERROR, la cola diferida sigue y el resumen igual se imprime.
# Ademas el bloque D prueba el ESCANER en rojo (inyecta un proveedor que
# devuelve un Nodo) para que un "0 objetos" no sea indistinguible de un
# escaner ciego.
#
# NO sella §21.8 (el autor no puede auto-verificarse; trampa 46/119).
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_m62_pureza_save.gd

extends SceneTree

const MODULO := "M62-pureza"
const BLOQUES: Array[String] = ["A", "B", "C", "D", "E"]
## Piso MEDIDO en verde (1a corrida), NO copiado.
const CHECKS_MINIMOS := 58
## Piso de proveedores MEDIDO en verde (39). Generoso a la baja para tolerar
## churn de otros modulos sin volverse ciego ante un registro roto.
const PISO_PROVEEDORES := 35
## Piso de claves del payload MEDIDO en verde (46).
const PISO_CLAVES_PAYLOAD := 40
## Ruta del escaner de save (M59) para las sondas rojas aisladas.
const RUTA_SNAPSHOT := "res://scripts/saving/save_snapshot.gd"

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}

## Contador y rutas de la ultima pasada del escaner (se reinician antes de cada uso).
var _objetos: int = 0
var _rutas: Array[String] = []

# ── Proveedores sinteticos SOLO para las sondas rojas/verdes del bloque D ──
# No se registran en el SaveManager real: viven en un SaveSnapshot aislado.

class ProveedorImpuro extends RefCounted:
	func get_section_name() -> String:
		return "impuro_test"
	func get_save_data() -> Dictionary:
		return {"nodo": Node.new()}
	func restore_save_data(_d: Dictionary) -> void:
		pass

class ProveedorPuro extends RefCounted:
	func get_section_name() -> String:
		return "puro_test"
	func get_save_data() -> Dictionary:
		return {"n": 1, "lista": [1, 2, {"a": "b"}]}
	func restore_save_data(_d: Dictionary) -> void:
		pass

class ProveedorAnidado extends RefCounted:
	func get_section_name() -> String:
		return "anidado_test"
	func get_save_data() -> Dictionary:
		return {"capa": [{"hondo": {"nodo": Node.new()}}]}
	func restore_save_data(_d: Dictionary) -> void:
		pass

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	print("=== [M62] Suite pureza de save (L98, Log 1196) ===")
	_bloque_a_contrato()
	_bloque_b_pureza_proveedores()
	_bloque_c_payload()
	_bloque_d_sonda_roja()
	_bloque_e_cobertura()

## ── A. Contrato ISaveProvider de los proveedores registrados ──────────────
func _bloque_a_contrato() -> void:
	print("--- A. Contrato: todo proveedor registrado implementa los 3 metodos ---")
	var provs := _proveedores()
	_check("SaveManager.snapshot expone proveedores", not provs.is_empty(),
		"n=%d" % provs.size())
	_check("hay >= %d proveedores (piso medido; anti-ceguera)" % PISO_PROVEEDORES,
		provs.size() >= PISO_PROVEEDORES, "n=%d" % provs.size())
	var faltan: Array[String] = []
	var vacias: Array[String] = []
	for sec in provs:
		var p = provs[sec]
		var ok: bool = p is Object \
			and p.has_method("get_section_name") \
			and p.has_method("get_save_data") \
			and p.has_method("restore_save_data")
		if not ok:
			faltan.append(str(sec))
		elif String(p.get_section_name()).strip_edges() == "":
			vacias.append(str(sec))
	_check("ningun proveedor carece de get_section_name/get_save_data/restore_save_data",
		faltan.is_empty(), str(faltan))
	_check("ninguna seccion tiene nombre vacio", vacias.is_empty(), str(vacias))
	_fin("A")

## ── B. Pureza por proveedor (el corazon de L98) ───────────────────────────
func _bloque_b_pureza_proveedores() -> void:
	print("--- B. Pureza: cada get_save_data() devuelve solo datos (sin nodos) ---")
	var provs := _proveedores()
	var secciones := provs.keys()
	secciones.sort()
	var impuros: Array[String] = []
	for sec in secciones:
		var p = provs[sec]
		var data = p.get_save_data()
		if typeof(data) != TYPE_DICTIONARY:
			impuros.append("%s(tipo=%d)" % [sec, typeof(data)])
			_check("seccion '%s' devuelve un Dictionary" % sec, false,
				"tipo=%d" % typeof(data))
			continue
		_objetos = 0
		_rutas = []
		_escanear(data, str(sec))
		_check("seccion '%s' sin referencias a objetos" % sec, _objetos == 0,
			"objetos=%d rutas=%s" % [_objetos, str(_rutas)])
		if _objetos > 0:
			impuros.append(str(sec))
	_check("las %d secciones son puras" % secciones.size(), impuros.is_empty(),
		str(impuros))
	_fin("B")

## ── C. Pureza del payload COMPLETO que se escribe (collect) ───────────────
func _bloque_c_payload() -> void:
	print("--- C. Pureza del payload completo que se escribe (collect) ---")
	var sm = root.get_node_or_null("/root/SaveManager")
	if sm == null or sm.snapshot == null:
		_check("SaveManager y su snapshot estan disponibles", false,
			"sin SaveManager/snapshot")
		_fin("C")
		return
	var payload: Dictionary = sm.snapshot.collect("probe_pureza")
	_check("collect() devuelve un Dictionary no vacio", not payload.is_empty(),
		"claves=%d" % payload.size())
	_check("el payload tiene >= %d claves (piso medido)" % PISO_CLAVES_PAYLOAD,
		payload.size() >= PISO_CLAVES_PAYLOAD, "claves=%d" % payload.size())
	_objetos = 0
	_rutas = []
	_escanear(payload, "payload")
	_check("el payload COMPLETO no contiene objetos", _objetos == 0,
		"objetos=%d rutas=%s" % [_objetos, str(_rutas)])
	for s in ["player", "stream", "inventory"]:
		_check("el payload incluye la seccion '%s'" % s, payload.has(s))
	_fin("C")

## ── D. Sonda roja: el escaner PUEDE fallar (probado por inyeccion) ────────
func _bloque_d_sonda_roja() -> void:
	print("--- D. Sonda roja: el escaner PUEDE fallar (inyeccion) ---")
	var sc = load(RUTA_SNAPSHOT)

	var s_imp = sc.new()
	_check("registrar un proveedor impuro devuelve true",
		s_imp.register_provider(ProveedorImpuro.new()) == true)
	var p_imp: Dictionary = s_imp.collect("x")
	_objetos = 0
	_rutas = []
	_escanear(p_imp, "impuro")
	_check("el escaner DETECTA 1 objeto en el proveedor impuro", _objetos == 1,
		"objetos=%d" % _objetos)
	_check("y nombra la ruta exacta del objeto",
		_rutas == ["impuro.impuro_test.nodo"], str(_rutas))

	var s_pur = sc.new()
	s_pur.register_provider(ProveedorPuro.new())
	var p_pur: Dictionary = s_pur.collect("x")
	_objetos = 0
	_rutas = []
	_escanear(p_pur, "puro")
	_check("control negativo: un proveedor puro da 0 objetos", _objetos == 0,
		"objetos=%d" % _objetos)

	var s_an = sc.new()
	s_an.register_provider(ProveedorAnidado.new())
	var p_an: Dictionary = s_an.collect("x")
	_objetos = 0
	_rutas = []
	_escanear(p_an, "anidado")
	_check("el escaner ve nodos ANIDADOS (dict en array en dict)", _objetos == 1,
		"objetos=%d" % _objetos)
	_check("y nombra la ruta anidada",
		_rutas == ["anidado.anidado_test.capa[0].hondo.nodo"], str(_rutas))
	_fin("D")

## ── E. Cobertura y anti-ceguera ───────────────────────────────────────────
func _bloque_e_cobertura() -> void:
	print("--- E. Cobertura: se escanearon TODAS las secciones, no una muestra ---")
	var provs := _proveedores()
	_check("se enumeraron los proveedores reales (no vacio)", provs.size() > 0,
		"n=%d" % provs.size())
	var recorridas := 0
	for sec in provs:
		var data = provs[sec].get_save_data()
		if typeof(data) == TYPE_DICTIONARY:
			recorridas += 1
	_check("se escanearon las %d secciones (cobertura completa)" % provs.size(),
		recorridas == provs.size(), "recorridas=%d" % recorridas)
	_fin("E")

## ── Utilidades ────────────────────────────────────────────────────────────

## Proveedores reales registrados en el SaveManager autoload (39 medidos).
func _proveedores() -> Dictionary:
	var sm = root.get_node_or_null("/root/SaveManager")
	if sm == null or sm.snapshot == null:
		return {}
	return sm.snapshot._providers

## Escaner recursivo: cuenta Objects (nodos/recursos) y anota su ruta.
## Cubre Dictionary y Array; cualquier otro tipo se considera dato puro.
func _escanear(v, ruta: String) -> void:
	var t := typeof(v)
	if t == TYPE_OBJECT:
		_objetos += 1
		_rutas.append(ruta)
		return
	if t == TYPE_DICTIONARY:
		for k in v:
			_escanear(v[k], ruta + "." + str(k))
	elif t == TYPE_ARRAY:
		for i in range(v.size()):
			_escanear(v[i], ruta + "[%d]" % i)

func _fin(nombre: String) -> void:
	_vistos[nombre] = true

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

## Capa 3: corre SIEMPRE, aunque `_run()` haya abortado por un SCRIPT ERROR.
func _summary() -> void:
	for n in BLOQUES:
		if not _vistos.has(n):
			_checks += 1
			_fallos += 1
			print("[FAIL] el bloque %s NO se ejecuto (posible SCRIPT ERROR que aborto la funcion)" % n)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo medido en verde: %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con codigo 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — los %d checks pasaron" % [MODULO, _checks])
		quit(0)
