extends SceneTree

# Modelo: DeepSeek-V4.1-Flash (OpenCode)
# Plataforma: OpenCode
# Fecha: 2026-11-06
#
# M17 Construccion — PERSISTENCIA + coherencia de la rejilla tras guardar/cargar.
#
# Cubre dos items del 05-Checklist que estaban abiertos:
#   * L102 "La rejilla es coherente tras guardar y cargar (misma celda <-> misma posicion)"
#   * L256 "Tests de integracion: colocar -> guardar -> cargar -> restaurar identico (M58)"
#
# QUE MIDE (nucleo real, sin escena ni assets):
#   1. Coloca 3 piezas del CATALOGO REAL (piso, pared encima del piso, escalera 2x1).
#   2. Saca el snapshot con el contrato de save `obtener_estructuras()`.
#   3. Lo pasa por JSON.stringify + JSON.parse_string (el save real de M59 es JSON:
#      los enteros vuelven como float y `restaurar_estructuras` debe normalizarlos).
#   4. Limpia el manager y restaura desde el JSON.
#   5. Exige IDENTIDAD: mismos id/tipo/pos/rot_y/planta/variante, misma ocupacion
#      (incluida la segunda celda de una huella 2x1) y misma posicion mundial.
#   6. Exige que `mundo_desde_celda(celda)` sea EXACTAMENTE igual antes y despues:
#      esa es la coherencia de rejilla que pide L102.
#   7. Restaurar dos veces NO duplica estructuras (idempotencia del contrato M58).
#
# ANTI-FALSO-VERDE: cada check es falsable; el piso del runner (CHECKS_MINIMOS) es
# MEDIDO en la primera corrida verde, no estimado. Un fallo => exit 1.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://tests/test_m17_persistencia_rejilla.gd
# Exit: 0 = verde medido | 1 = fallos

const MODULO := "M17 construccion: persistencia + rejilla tras guardar/cargar"
const MGR := preload("res://scripts/construccion/build_manager.gd")
const TIPOS := preload("res://scripts/construccion/construccion_tipos.gd")
const MUNDO := preload("res://scripts/construccion/construccion_mundo.gd")
const CHECKS_MINIMOS := 20

var _checks := 0
var _fallos := 0
var _detalles: Array[String] = []

## Mundo falso: terreno PLANO y solido por debajo de y=0 (mismo patron que
## `test_construccion.gd`; evita depender del VoxelTerrain real en headless).
class MundoPlano:
	extends ConstruccionMundo
	var suelo: int = 0
	func superficie_voxel(celda: Vector3i) -> StringName:
		return &"terreno" if celda.y < suelo else &"aire"
	func escribir_voxel(celdas: Array, _bloque: int) -> int:
		escrituras += celdas.size()
		return celdas.size()
	func borrar_voxel(celdas: Array) -> int:
		borrados += celdas.size()
		return celdas.size()


func _initialize() -> void:
	var w := Timer.new()
	w.wait_time = 120.0
	w.one_shot = true
	w.timeout.connect(func() -> void:
		print("WATCHDOG: el suite excedio 120 s -> salida forzada con codigo 1")
		quit(1))
	root.add_child(w)
	w.start()
	call_deferred("_correr")


func _check(nombre: String, ok: bool, detalle: String = "") -> void:
	_checks += 1
	if ok:
		print("  [ok]   %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])
	else:
		_fallos += 1
		_detalles.append(nombre + (" (" + detalle + ")" if detalle != "" else ""))
		print("  [FAIL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])


func _colocar(mgr: Node, id: String, celda: Vector3i, rot: int) -> Dictionary:
	var r: PlacementRule = mgr.receta(StringName(id))
	if r == null:
		return {"ok": false, "detalle": ["receta ausente en el catalogo: " + id]}
	mgr.seleccionar_pieza(r)
	mgr.set_rotacion(rot)
	return mgr.confirmar_colocacion(celda)


## Firma canonica de una estructura para comparar antes/despues sin depender
## del orden del Array. `pos` normalizado a enteros.
func _firma(e: Dictionary) -> String:
	var pos: Array = e.get("pos", [0, 0, 0])
	return "%s|%s|%d,%d,%d|%d|%d|%s" % [
		String(e.get("id", "")),
		String(e.get("tipo", "")),
		int(pos[0]), int(pos[1]), int(pos[2]),
		int(e.get("rot_y", 0)),
		int(e.get("planta", 0)),
		String(e.get("variante", "")),
	]


func _firmas(lista: Array) -> Array[String]:
	var out: Array[String] = []
	for e in lista:
		out.append(_firma(e as Dictionary))
	out.sort()
	return out


func _celda_de(e: Dictionary) -> Vector3i:
	var pos: Array = e.get("pos", [0, 0, 0])
	return Vector3i(int(pos[0]), int(pos[1]), int(pos[2]))


func _correr() -> void:
	var mgr: Node = MGR.new()
	var n_catalogo: int = int(mgr._cargar_catalogo())
	_check("el catalogo real carga (>= 40 recetas)", n_catalogo >= 40, "recetas=%d" % n_catalogo)
	mgr.conectar_mundo(MundoPlano.new())

	# ── 1. Colocar 3 piezas reales ─────────────────────────────────────
	var r1: Dictionary = _colocar(mgr, "piso_tablones", Vector3i(2, 0, 3), 0)
	_check("piso_tablones se coloca sobre el terreno",
		bool(r1.get("ok", false)), String(r1.get("texto", "")))
	var r2: Dictionary = _colocar(mgr, "pared_madera", Vector3i(2, 1, 3), 1)
	_check("pared_madera se apoya sobre el piso (rotada 90)",
		bool(r2.get("ok", false)), String(r2.get("texto", "")))
	mgr.set_planta(1)
	var r3: Dictionary = _colocar(mgr, "escalera_doble", Vector3i(4, 0, -1), 0)
	mgr.set_planta(0)
	_check("escalera_doble 2x1 se coloca en el suelo",
		bool(r3.get("ok", false)), String(r3.get("texto", "")))

	var antes: Array = mgr.obtener_estructuras()
	_check("el save ve las 3 estructuras", antes.size() == 3, "n=%d" % antes.size())
	var firmas_antes: Array[String] = _firmas(antes)

	# Posiciones mundiales ANTES (la rejilla que debe sobrevivir al save).
	var mundo_antes: Dictionary = {}
	for e in antes:
		var c: Vector3i = _celda_de(e as Dictionary)
		mundo_antes[TIPOS.clave(c)] = MUNDO.mundo_desde_celda(c)

	# ── 2. Round-trip JSON (lo que hace el save M59 en disco) ──────────
	var json: String = JSON.stringify(antes)
	_check("el snapshot se serializa a JSON", json.length() > 2, "bytes=%d" % json.length())
	var cargado: Variant = JSON.parse_string(json)
	_check("el JSON se vuelve a parsear como Array", typeof(cargado) == TYPE_ARRAY)
	var lista: Array = cargado if typeof(cargado) == TYPE_ARRAY else []
	_check("el JSON conserva las 3 estructuras", lista.size() == 3, "n=%d" % lista.size())
	var pos_ok: bool = true
	for e in lista:
		var pos: Variant = (e as Dictionary).get("pos", null)
		if typeof(pos) != TYPE_ARRAY or (pos as Array).size() != 3:
			pos_ok = false
	_check("cada 'pos' del JSON es un Array de 3 numeros", pos_ok)

	# ── 3. Limpiar y restaurar ─────────────────────────────────────────
	mgr.limpiar_estructuras()
	_check("limpiar_estructuras() deja el manager vacio",
		int(mgr.cantidad_estructuras()) == 0)
	_check("tras limpiar, la celda del piso queda libre",
		(mgr.pieza_en_celda(Vector3i(2, 0, 3)) as Dictionary).is_empty())

	var emitidos: Array = []
	mgr.estructuras_restauradas.connect(func(n: int) -> void: emitidos.append(n))
	mgr.restaurar_estructuras(lista)
	_check("restaurar_estructuras() repone las 3", int(mgr.cantidad_estructuras()) == 3)
	_check("la senal estructuras_restauradas informa 3",
		emitidos.size() == 1 and int(emitidos[0]) == 3, str(emitidos))

	var despues: Array = mgr.obtener_estructuras()
	var firmas_despues: Array[String] = _firmas(despues)
	_check("id/tipo/pos/rot_y/planta/variante IDENTICOS tras restaurar",
		firmas_antes == firmas_despues, "%s vs %s" % [str(firmas_antes), str(firmas_despues)])
	_check("la rotacion de 90 de la pared sobrevive al save",
		firmas_despues.has("E_2,1,3|pared_madera|2,1,3|90|0|"), str(firmas_despues))
	_check("la planta=1 de la escalera sobrevive al save",
		firmas_despues.has("E_4,0,-1|escalera_doble|4,0,-1|0|1|"), str(firmas_despues))

	# ── 4. Coherencia de rejilla: misma celda -> misma posicion mundial ─
	var rejilla_ok: bool = true
	var detalle_rejilla: String = ""
	for e in despues:
		var c: Vector3i = _celda_de(e as Dictionary)
		var k: String = TIPOS.clave(c)
		if not mundo_antes.has(k):
			rejilla_ok = false
			detalle_rejilla = "celda nueva tras cargar: " + k
			continue
		if MUNDO.mundo_desde_celda(c) != (mundo_antes[k] as Vector3):
			rejilla_ok = false
			detalle_rejilla = "posicion distinta en " + k
	_check("misma celda -> misma posicion mundial antes y despues", rejilla_ok, detalle_rejilla)
	var rt_ok: bool = true
	for c in [Vector3i(0, 0, 0), Vector3i(2, 0, 3), Vector3i(-7, 5, 11)]:
		if MUNDO.celda_desde_mundo(MUNDO.mundo_desde_celda(c)) != c:
			rt_ok = false
	_check("round-trip celda -> mundo -> celda es exacto (incluye negativos)", rt_ok)

	# ── 5. La ocupacion se reconstruye, incluida la huella 2x1 ─────────
	_check("la celda del piso vuelve a estar ocupada",
		not (mgr.pieza_en_celda(Vector3i(2, 0, 3)) as Dictionary).is_empty())
	_check("la celda de la pared vuelve a estar ocupada",
		not (mgr.pieza_en_celda(Vector3i(2, 1, 3)) as Dictionary).is_empty())
	var segunda: Dictionary = mgr.pieza_en_celda(Vector3i(5, 0, -1))
	_check("la SEGUNDA celda de la huella 2x1 apunta al ancla (4,0,-1)",
		not segunda.is_empty() and _celda_de(segunda) == Vector3i(4, 0, -1), str(segunda))

	# ── 6. Idempotencia: restaurar dos veces no duplica ────────────────
	mgr.restaurar_estructuras(lista)
	_check("restaurar dos veces NO duplica (sigue habiendo 3)",
		int(mgr.cantidad_estructuras()) == 3, "n=%d" % int(mgr.cantidad_estructuras()))
	_check("tras la segunda restauracion la rejilla sigue coherente",
		_firmas(mgr.obtener_estructuras()) == firmas_antes)

	mgr.free()

	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	for d in _detalles:
		print("  FALLO: " + d)
	if _fallos > 0 or _checks < CHECKS_MINIMOS:
		print("TEST %s FALLIDO (checks=%d, minimo=%d)" % [MODULO, _checks, CHECKS_MINIMOS])
		quit(1)
	else:
		print("TEST %s OK — colocar/guardar/cargar/restaurar es identico y la rejilla se mantiene" % MODULO)
		quit(0)
