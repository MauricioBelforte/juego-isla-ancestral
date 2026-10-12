# Modelo: Ling-3.1-Flash
# Plataforma: Kilo Code
# Fecha: 2026-10-12
#
# M112 — Integración NPC (M19) → Amistad (M20):
# charla (diálogo) y regalo de un vecino → puntos/nivel con
# consumo real del ítem en M14, límites diarios, subida de
# nivel con señal, memoria de primer regalo y persistencia M59.
#
# ALCANCE (honesto): "mood" (estado de ánimo) NO existe como
# sistema en M19 — villager_profile.gd no tiene campo de ánimo
# (grep 0 hits, 2026-10-12). Este test cubre la integración
# NPC→amistad tal como existe hoy (diálogo=charla, regalo,
# niveles, memoria). El mood queda como hallazgo para el dueño
# de M19, documentado en el checklist de M112.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://tests/integration/test_villager_social.gd
#
# Guardia anti-falso-verde: _fin() por bloque + CHECKS_MINIMOS
# medido + _summary() en call_deferred SEPARADO + watchdog.

extends SceneTree

const TIMEOUT_SEG := 60.0
const CHECKS_MINIMOS := 20
const BLOQUES_ESPERADOS: Array[String] = ['A', 'B', 'C', 'D', 'E']
const VECINO := "npc_test_m112"

var _fr
var _inv

var _fallos: int = 0
var _checks: int = 0
var _bloque: String = "(inicio)"
var _abortado: bool = false
var _completados: Array[String] = []
var _checks_por_bloque: Dictionary = {}
var _checks_marca: int = 0


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	create_timer(TIMEOUT_SEG, true).timeout.connect(_on_watchdog)
	print("=== M19+M20 Villager↔Amistad (headless) ===")
	_fr = root.get_node_or_null("Friendship")
	_inv = root.get_node_or_null("Inventario")
	_check("autoload Friendship presente", _fr != null)
	_check("autoload Inventario presente", _inv != null)
	if _fr == null or _inv == null:
		return
	_fr.registrar_vecino(VECINO)
	_bloque_A()
	_bloque_B()
	_bloque_C()
	_bloque_D()
	_bloque_E()


func _on_watchdog() -> void:
	_abortado = true
	print("WATCHDOG: la suite no termino en %.0f s (ultimo bloque: %s)" % [TIMEOUT_SEG, _bloque])
	quit(1)


func _ini(nombre: String) -> void:
	_bloque = nombre
	_checks_marca = _checks
	print("\n-- %s --" % nombre)


func _fin(nombre: String) -> void:
	var letra: String = nombre.substr(0, 1)
	if not _completados.has(letra):
		_completados.append(letra)
	var delta: int = _checks - _checks_marca
	_checks_por_bloque[letra] = int(_checks_por_bloque.get(letra, 0)) + delta
	_checks_marca = _checks
	print("[FIN] %s (+%d checks)" % [nombre, delta])


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])


func _summary() -> void:
	var faltantes: Array[String] = []
	for letra in BLOQUES_ESPERADOS:
		if not _completados.has(letra):
			faltantes.append(letra)
	_check("todos los bloques se completaron (sin abortos silenciosos)", faltantes.is_empty(),
		"bloques que no terminaron: %s" % str(faltantes))
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("Checks por bloque: %s" % str(_checks_por_bloque))
	print("\n=== Resumen M19+M20: %d checks, %d fallos ===" % [_checks, _fallos])
	if _abortado:
		quit(1)
	elif _fallos == 0:
		print("TEST OK — todos los checks pasaron")
		quit(0)
	else:
		print("TEST FALLO — %d checks fallaron" % _fallos)
		quit(1)


func _bloque_A() -> void:
	_ini("A. charla (diálogo): puntos y límite diario")
	var res: Dictionary = _fr.charlar(VECINO)
	_check("charla ok", bool(res.get("ok", false)), str(res))
	_check("charla de nivel 1 otorga 5 puntos", int(res.get("puntos", 0)) == 5, str(res))
	_check("puntos aplicados al vecino", int(_fr.get_puntos(VECINO)) == 5,
		"p=%d" % int(_fr.get_puntos(VECINO)))
	var ev: Array = []
	_fr.charla_realizada.connect(func(_v, _p): ev.append(1))
	var res2: Dictionary = _fr.charlar(VECINO)
	_check("2da charla el mismo día es rechazada (límite diario)", not bool(res2.get("ok", false)),
		str(res2))
	_check("charla_realizada no emitida en rechazo", ev.is_empty())
	_fin("A. charla (diálogo): puntos y límite diario")


func _bloque_B() -> void:
	_ini("B. regalo: consumo real en M14 + puntos")
	_inv.agregar_items({"madera": 1})
	_check("madera disponible en M14", int(_inv.count_item("madera")) == 1)
	var ev: Array = []
	_fr.regalo_entregado.connect(func(_v, _i, _c, _p): ev.append(1))
	var res: Dictionary = _fr.regalar(VECINO, "madera")
	_check("regalo ok", bool(res.get("ok", false)), str(res))
	_check("madera consumida de M14 (integración M14)", int(_inv.count_item("madera")) == 0,
		"n=%d" % int(_inv.count_item("madera")))
	_check("puntos de regalo aplicados (min 5, nunca 0)", int(_fr.get_puntos(VECINO)) >= 10,
		"p=%d" % int(_fr.get_puntos(VECINO)))
	_check("regalo_entregado emitida", ev.size() == 1)
	_fin("B. regalo: consumo real en M14 + puntos")


func _bloque_C() -> void:
	_ini("C. subida de nivel (umbral 20) con evento de dominio")
	## charlar() sube de nivel vía _emitir_level_up (L565):
	## el evento de dominio real es EventBus.npc.friendship_level_up
	## (contrato M20 → M07, documentado en la cabecera del servicio).
	## La señal propia nivel_subido la emite solo regalar().
	var lvl: Array = []
	var bus = root.get_node_or_null("EventBus")
	_check("autoload EventBus presente", bus != null)
	if bus != null and bus.npc != null:
		bus.npc.friendship_level_up.connect(func(_v, n): lvl.append(int(n)))
	_fr.pivote_dia(2)
	var r2: Dictionary = _fr.charlar(VECINO)
	_check("charla del día 2 ok", bool(r2.get("ok", false)), str(r2))
	_fr.pivote_dia(3)
	var r3: Dictionary = _fr.charlar(VECINO)
	_check("charla del día 3 ok", bool(r3.get("ok", false)), str(r3))
	_check("puntos totales = 20 (umbral de nivel 2)", int(_fr.get_puntos(VECINO)) == 20,
		"p=%d" % int(_fr.get_puntos(VECINO)))
	_check("nivel subio a 2", int(_fr.get_nivel(VECINO)) == 2, "n=%d" % int(_fr.get_nivel(VECINO)))
	_check("EventBus.npc.friendship_level_up emitido con nivel 2",
		lvl.size() >= 1 and int(lvl[0]) == 2, str(lvl))
	_fin("C. subida de nivel (umbral 20) con evento de dominio")


func _bloque_D() -> void:
	_ini("D. persistencia M59 (roundtrip)")
	var datos: Dictionary = _fr.get_save_data()
	## get_save_data() envuelve: {"vecinos": {vid: ...}, "dia": ...,
	## "cartas": ...} (friendship_service.gd:640-650).
	var vecinos_data: Dictionary = datos.get("vecinos", {})
	_check("save data contiene al vecino", vecinos_data.has(VECINO))
	var fr2 = load("res://scripts/friendship/friendship_service.gd").new()
	fr2.restore_save_data(datos)
	_check("puntos restaurados en instancia nueva", int(fr2.get_puntos(VECINO)) == int(_fr.get_puntos(VECINO)),
		"rest=%d vivo=%d" % [int(fr2.get_puntos(VECINO)), int(_fr.get_puntos(VECINO))])
	_check("nivel restaurado", int(fr2.get_nivel(VECINO)) == int(_fr.get_nivel(VECINO)))
	fr2.free()
	_fin("D. persistencia M59 (roundtrip)")


func _bloque_E() -> void:
	_ini("E. memoria del primer regalo")
	var mem: Array = _fr.get_memoria(VECINO)
	var recuerdos: Array = _fr.get_recuerdos(VECINO)
	_check("memoria del vecino no vacía", mem.size() >= 1, "n=%d" % mem.size())
	_check("recuerdo primer_regalo:madera registrado",
		mem.has("primer_regalo:madera") or recuerdos.has("primer_regalo:madera"),
		"mem=%s rec=%s" % [str(mem), str(recuerdos)])
	_fin("E. memoria del primer regalo")
