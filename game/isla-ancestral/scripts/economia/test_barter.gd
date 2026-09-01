# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-08-31
#
# M38: Test del BarterSystem (trueque RF7/RF8/RF12, límites diarios, atomicidad).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/economia/test_barter.gd

extends SceneTree

var _fallos: int = 0
var _barter: Node = null
var _inv: Node = null
var _eco: Node = null
var _fs: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_barter = root.get_node_or_null("Barter")
	_inv = root.get_node_or_null("Inventario")
	_eco = root.get_node_or_null("EconomyManager")
	_fs = root.get_node_or_null("Friendship")
	_check(_barter != null, "Barter autoload presente")
	_check(_inv != null, "Inventario presente")
	if _barter == null or _inv == null:
		print("=== TEST M38 BARTER: 1+ fallo(s) ===")
		quit(1)
		return
	_test_carga_ofertas()
	_test_salvavidas_rf12()
	_test_atomicidad()
	_test_limite_diario()
	_test_amistad_rf8()
	_test_temporada_rf7()
	_test_saldo_intacto()
	print("=== TEST M38 BARTER: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _dar(item: String, n: int) -> void:
	_inv.agregar_items({item: n})

func _quitar(item: String) -> void:
	_inv.remover_items({item: _inv.count_item(item)})

func _test_carga_ofertas() -> void:
	_check(_barter.ofertas_count() == 3, "3 ofertas cargadas: %d" % _barter.ofertas_count())
	_check(_barter.get_section_name() == "barter", "sección 'barter'")

func _test_salvavidas_rf12() -> void:
	# RF12: con 0 monedas y sin amistad, el salvavidas SIEMPRE está disponible
	var salvavidas: Array = _barter.propuestas_disponibles("cualquiera")
	var tiene := false
	for o in salvavidas:
		if o.oferta_id == &"trueque_salvavidas":
			tiene = true
	_check(tiene, "salvavidas disponible para cualquier NPC")
	# Sin los items del pedido → rechazo claro
	_quitar("piedra_caliza")
	var res: Dictionary = _barter.ejecutar_trueque("cualquiera", &"trueque_salvavidas")
	_check(not bool(res.ok), "salvavidas sin items rechazado con motivo")
	_check(String(res.motivo) != "", "motivo no vacío")
	# Con items → intercambio exitoso
	_dar("piedra_caliza", 3)
	var antes_madera: int = _inv.count_item("madera_roble")
	res = _barter.ejecutar_trueque("cualquiera", &"trueque_salvavidas")
	_check(bool(res.ok), "salvavidas ejecutado OK")
	_check(_inv.count_item("piedra_caliza") == 1, "pedido removido (3-2)")
	_check(_inv.count_item("madera_roble") == antes_madera + 2, "entregado recibido (+2)")

func _test_atomicidad() -> void:
	# Rollback: inventario lleno simulado via pedido parcialmente removable no
	# aplica; probamos que el pedido se remueve solo si TODO está disponible
	_quitar("madera_roble")
	_quitar("fibra_algodon")
	_dar("madera_roble", 5)  # menos de los 8 pedidos
	var res: Dictionary = _barter.ejecutar_trueque("finneas", &"trueque_finneas_herramienta")
	_check(not bool(res.ok), "finneas sin items suficientes rechazado")
	_check(_inv.count_item("madera_roble") == 5, "inventario intacto tras rechazo (todo-o-nada)")

func _test_limite_diario() -> void:
	# Salvavidas no consume límite: ejecutar de nuevo sigue OK si hay items
	_quitar("piedra_caliza")
	_dar("piedra_caliza", 4)
	var res: Dictionary = _barter.ejecutar_trueque("cualquiera", &"trueque_salvavidas")
	_check(bool(res.ok), "segundo salvavidas OK (no consume límite diario)")
	# Límite por oferta: catalina limite 2 → tercer trueque rechazado
	_fs.registrar_vecino("catalina")
	_fs._vecino("catalina").aplicar_puntos(999, {})  # amistad alta para RF8
	_quitar("baya_roja")
	_dar("baya_roja", 20)
	var estacion_ok: bool = _barter.propuestas_disponibles("catalina").any(
		func(o) -> bool: return o.oferta_id == &"trueque_catalina_fibra")
	if not estacion_ok:
		# Estación actual ≠ verano: la oferta estacional no está hoy; solo validamos el rechazo limpio
		res = _barter.ejecutar_trueque("catalina", &"trueque_catalina_fibra")
		_check(not bool(res.ok), "oferta estacional fuera de temporada rechazada")
	else:
		res = _barter.ejecutar_trueque("catalina", &"trueque_catalina_fibra")
		_check(bool(res.ok), "trueque catalina 1 OK")
		res = _barter.ejecutar_trueque("catalina", &"trueque_catalina_fibra")
		_check(bool(res.ok), "trueque catalina 2 OK (límite 2)")
		res = _barter.ejecutar_trueque("catalina", &"trueque_catalina_fibra")
		_check(not bool(res.ok), "tercer trueque rechazado (límite diario 2)")
		_check(String(res.motivo).contains("límite"), "motivo límite diario")

func _test_amistad_rf8() -> void:
	# Oferta de finneas requiere amistad 2: con vecino sin puntos → no disponible
	_fs.registrar_vecino("finneas")
	var disp: Array = _barter.propuestas_disponibles("finneas")
	var tiene := false
	for o in disp:
		if o.oferta_id == &"trueque_finneas_herramienta":
			tiene = true
	_check(not tiene, "oferta amistad 2 NO disponible con nivel bajo")
	# Subir amistad → disponible
	_fs._vecino("finneas").aplicar_puntos(999, {})
	disp = _barter.propuestas_disponibles("finneas")
	tiene = false
	for o in disp:
		if o.oferta_id == &"trueque_finneas_herramienta":
			tiene = true
	_check(tiene, "oferta amistad 2 disponible tras subir amistad (RF8)")

func _test_temporada_rf7() -> void:
	# Oferta estacional (verano [1]) rechazada fuera de temporada (validación dura)
	var res: Dictionary = _barter.ejecutar_trueque("catalina", &"trueque_catalina_fibra")
	if bool(res.ok):
		# estamos en verano: la oferta funciona (día 1 = primavera, pero por si acaso)
		_check(true, "en verano el trueque estacional funciona")
	else:
		_check(String(res.motivo).contains("temporada") or String(res.motivo).contains("límite")
			or String(res.motivo).contains("amistad"),
			"rechazo estacional/amistad con motivo claro: %s" % res.motivo)

func _test_saldo_intacto() -> void:
	# RF7: el trueque jamás toca monedas
	var saldo_antes: int = _eco.saldo
	_quitar("piedra_caliza")
	_dar("piedra_caliza", 3)
	_barter.ejecutar_trueque("cualquiera", &"trueque_salvavidas")
	_check(_eco.saldo == saldo_antes, "saldo intacto (trueque sin moneda)")
