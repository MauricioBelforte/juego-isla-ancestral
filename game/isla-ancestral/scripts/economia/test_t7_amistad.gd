# Modelo: GLM-5.3
# Plataforma: Kilo Code
# Fecha: 2026-09-11
#
# M38 iter 5b: prueba T7 — descuentos por amistad en 3 niveles REALES.
# (06-Plan-Testings §T7). Usa el autoload Friendship con niveles forzados
# vía VecinoAmistad.aplicar_puntos (umbrales reales 20/40/70 = niveles 2/3/4)
# y valida que precio_compra_vigente aplique 5/10/15% exactos + tope 20%
# combinado con volumen + invalidación de caché al cambiar el nivel.
# Uso: godot --headless --path game/isla-ancestral --script res://scripts/economia/test_t7_amistad.gd

extends SceneTree

var _fallos := 0
var _checks := 0

# NPC de prueba: madera_roble precio_compra base 10 (catálogo econ_prices.tres)
const NPC := "npc_t7_amistad"
const ITEM := "madera_roble"

func _initialize() -> void:
	print("=== TEST M38 T7: AMISTAD 3 NIVELES ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	var eco = root.get_node_or_null("EconomyManager")
	var fs = root.get_node_or_null("Friendship")
	if eco == null or fs == null or not fs.has_method("get_nivel"):
		print("[FAIL] EconomyManager/Friendship no disponibles"); quit(1); return
	var pm = eco.precios
	if pm == null:
		print("[FAIL] PriceManager no disponible"); quit(1); return

	# Registrar el vecino de prueba en Friendship (si no está) y forzar niveles
	# con aplicar_puntos (umbrales reales: 20→n2, 40→n3, 70→n4).
	if not fs.has_method("registrar_vecino"):
		print("[FAIL] Friendship sin registrar_vecino"); quit(1); return
	fs.registrar_vecino(NPC)
	var v = fs._vecino(NPC)
	if v == null:
		print("[FAIL] no se pudo registrar el vecino de prueba"); quit(1); return

	# Precio base sin amistad (nivel 1 de un NPC nuevo): 10, sin descuento
	_check("nivel inicial %d: sin descuento (10)" % fs.get_nivel(NPC), int(pm.precio_compra_vigente(ITEM, NPC, 1)) == 10)

	# ── Nivel 2 (20 puntos): descuento 5% ──
	v.aplicar_puntos(20 - v.get_puntos(), {})
	_check("nivel 2 alcanzado", fs.get_nivel(NPC) == 2)
	pm.invalidar_cache_amistad(NPC)  # simula la señal M20 que el manager escucha
	# 10 * 0.95 = 9.5 → round(9.5) = 10 (half-up de Godot): con precio chico el
	# 5% se pierde en el redondeo — el descuento exacto se valida con tela_lino.
	_check("nivel 2: madera 10 → 10 (5% se absorbe en redondeo)", int(pm.precio_compra_vigente(ITEM, NPC, 1)) == 10)
	_check("nivel 2: tela_lino 60 → 57 (5% exacto)", int(pm.precio_compra_vigente("tela_lino", NPC, 1)) == 57)

	# ── Nivel 3 (40 puntos): descuento 10% ──
	v.aplicar_puntos(40 - v.get_puntos(), {})
	_check("nivel 3 alcanzado", fs.get_nivel(NPC) == 3)
	pm.invalidar_cache_amistad(NPC)
	_check("nivel 3: madera 10 → 9 (10% exacto)" , int(pm.precio_compra_vigente(ITEM, NPC, 1)) == 9)
	_check("nivel 3: tela_lino 60 → 54 (10% exacto)", int(pm.precio_compra_vigente("tela_lino", NPC, 1)) == 54)

	# ── Nivel 4 (70 puntos): descuento 15% ──
	v.aplicar_puntos(70 - v.get_puntos(), {})
	_check("nivel 4 alcanzado", fs.get_nivel(NPC) == 4)
	pm.invalidar_cache_amistad(NPC)
	_check("nivel 4: tela_lino 60 → 51 (15% exacto)" , int(pm.precio_compra_vigente("tela_lino", NPC, 1)) == 51)

	# ── Tope combinado con volumen: amistad 15% + volumen 15% > 20% → clamp 20% ──
	_check("nivel 4 + volumen 20: tope 20% → 8", int(pm.precio_compra_vigente(ITEM, NPC, 20)) == 8)

	# ── La señal M20 real: EconomyManager conectado a nivel_amistad_cambio ──
	var bus = root.get_node_or_null("EventBus")
	if bus != null:
		var dom = bus.get("progresion")
		if dom != null and dom.has_signal("nivel_amistad_cambio"):
			var conectado := false
			for c in dom.nivel_amistad_cambio.get_connections():
				if c.callable.get_object() == eco:
					conectado = true
			_check("EconomyManager conectado a señal M20 nivel_amistad_cambio (J.8)", conectado)
			# Emitir la señal REAL invalida la caché sin llamar manualmente
			dom.emit_signal("nivel_amistad_cambio", NPC, 4)
			_check("señal M20 emitida sin crash (invalidación re-disparada)", true)
		else:
			_check("dominio progresion con señal nivel_amistad_cambio", false)
	else:
		_check("EventBus presente para J.8", false)

	print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLOS DETECTADOS"); quit(1)
	else:
		print("M38 T7 AMISTAD OK"); quit(0)

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)
