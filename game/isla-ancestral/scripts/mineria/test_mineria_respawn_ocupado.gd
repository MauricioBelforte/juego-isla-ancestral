# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-20
#
# M35: guarda de OCUPACION en el respawn (items J2 y J4 de 05-Checklist.md).
#   J2 "Respawn con zona ocupada: reintento diferido"
#   J4 "Respawn con construccion M17 encima: espera al proximo dia"
#
# Contexto medido antes de implementar: `ResourceNode.evaluar_respawn()` (M15) MUTA
# el estado y NO consulta ocupacion (0 apariciones de `ocupad|puede_reaparecer` en
# scripts/resources/). Por eso la unica forma de diferir sin tocar M15 es decidir
# ANTES de llamarlo. El predicado `ocupado` es inyectable: jugador (J2), construccion
# M17 (J4) u otra veta. Sin predicado el comportamiento es el historico.
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/mineria/test_mineria_respawn_ocupado.gd
#
# 3 capas anti-falso-verde (trampas 85/122): contador de checks + piso CHECKS_MINIMOS
# medido en verde + marcadores _fin() con resumen en call_deferred aparte (trampa 61).

extends SceneTree

var _fallos: int = 0
var _checks: int = 0
var _rm: Node = null
var _min: Node = null

const BLOQUES := ["libre", "ocupado", "liberado", "selectividad", "tope", "espejo", "retrocompat"]
## Piso de checks MEDIDO en verde (no estimado): 60 en 3 corridas identicas.
const CHECKS_MINIMOS := 60

var _vistos: Dictionary = {}
## Capturas de señal (var miembro: las lambdas capturan por valor).
var _recuperadas: Array = []
## Nodo diferido en el bloque B, reutilizado en C (el reintento es sobre la MISMA veta).
var _rn_diferida: ResourceNode = null

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")   # si _run() aborta, el resumen igual corre (trampa 61)

func _run() -> void:
	_rm = root.get_node_or_null("ResourceManager")
	_min = root.get_node_or_null("mineria")
	_check(_rm != null, "ResourceManager autoload presente (M15)")
	_check(_min != null, "mineria autoload presente (M35)")
	if _rm == null or _min == null:
		return
	_min.mina_veta_recuperada.connect(_on_recuperada)
	_min.limpiar_diferidos()
	_min._vetas_parciales.clear()
	_test_libre()
	_fin("libre")
	_test_ocupado()
	_fin("ocupado")
	_test_liberado()
	_fin("liberado")
	_test_selectividad()
	_fin("selectividad")
	_test_tope()
	_fin("tope")
	_test_espejo()
	_fin("espejo")
	_test_retrocompat()
	_fin("retrocompat")

func _fin(nombre: String) -> void:
	_vistos[nombre] = true

func _summary() -> void:
	for n in BLOQUES:
		if not _vistos.has(n):
			_check(false, "bloque %s NO se ejecuto (posible SCRIPT ERROR)" % n)
	if _checks < CHECKS_MINIMOS:
		_check(false, "solo %d checks ejecutados (minimo %d) - posible aborto silencioso" % [_checks, CHECKS_MINIMOS])
	print("=== TEST M35 RESPAWN OCUPADO: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
	else:
		print("OK: " + msg)

## Crea un ResourceNode de prueba (configurar ANTES de add_child) y lo monta en root.
func _nodo_de(def: ResourceDefinition, pos: Vector3) -> ResourceNode:
	var rn := ResourceNode.new()
	rn.configurar(def)
	root.add_child(rn)
	rn.global_position = pos
	return rn

## Deja el nodo AGOTADO con respawn programado para el dia indicado.
func _agotar(rn: ResourceNode, dia: int) -> void:
	rn.estado = ResourceNode.Estado.AGOTADO
	rn.golpes_restantes = 0
	rn.programar_respawn(dia)

func _on_recuperada(def_id: StringName, _pos: Vector3, _anuncio: bool) -> void:
	_recuperadas.append(String(def_id))

## ── Predicados de ocupacion (inyectables) ───────────────────────────────────

func _todo_ocupado(_p: Vector3) -> bool:
	return true

func _nadie_ocupado(_p: Vector3) -> bool:
	return false

## J4: simula una construccion de M17 sobre la mitad izquierda del terreno.
func _ocupado_x_menor_500(p: Vector3) -> bool:
	return p.x < 500.0

## ── A: control positivo, sin predicado (comportamiento historico) ───────────

func _test_libre() -> void:
	_min.limpiar_diferidos()
	_recuperadas.clear()
	var def: ResourceDefinition = _rm.obtener_def(&"veta_cobre")
	_check(def != null, "A1 el catalogo resuelve veta_cobre")
	var rn := _nodo_de(def, Vector3(400, 0, 0))
	_agotar(rn, 10)
	var res: Dictionary = _min.barrido_regeneracion([rn], 10, 0)
	_check(int(res.get("evaluados", -1)) == 1, "A2 evalua 1 veta")
	_check(int(res.get("respawnados", -1)) == 1, "A3 sin predicado respawnea (control positivo)")
	_check(int(res.get("diferidos", -1)) == 0, "A4 sin predicado no difiere nada")
	_check(int(res.get("no_listos", -1)) == 0, "A5 la veta estaba lista por calendario")
	_check(rn.estado == ResourceNode.Estado.INTACTO, "A6 la veta vuelve a INTACTO")
	_check(_recuperadas.size() == 1, "A7 emite 1 anuncio de recuperacion (got %d)" % _recuperadas.size())
	_check(_min.diferidos() == 0, "A8 el total de diferimientos queda en 0")

## ── B: lugar ocupado -> NO respawnea, se difiere, M15 no muta ───────────────

func _test_ocupado() -> void:
	_min.limpiar_diferidos()
	_recuperadas.clear()
	var def: ResourceDefinition = _rm.obtener_def(&"veta_cobre")
	var rn := _nodo_de(def, Vector3(410, 0, 0))
	_agotar(rn, 10)
	_rn_diferida = rn
	var clave: String = _min.clave_veta(rn)
	var res: Dictionary = _min.barrido_regeneracion([rn], 10, 0, Callable(self, "_todo_ocupado"))
	_check(int(res.get("diferidos", -1)) == 1, "B1 con el lugar ocupado se difiere 1 veta")
	_check(int(res.get("respawnados", -1)) == 0, "B2 no se respawnea nada")
	_check(rn.estado == ResourceNode.Estado.AGOTADO, "B3 la veta SIGUE agotada (M15 no muto el estado)")
	_check(rn.respawn_dia_absoluto == 10, "B4 el calendario de respawn queda intacto (dia 10)")
	_check(_recuperadas.is_empty(), "B5 NO se emite el anuncio de recuperacion")
	_check(_min.diferidos() == 1, "B6 el total de diferimientos sube a 1")
	_check(_min.veta_diferida(clave) == 1, "B7 la veta registra 1 barrido diferido")
	# Segundo barrido tambien ocupado: el contador por veta acumula.
	_min.barrido_regeneracion([rn], 10, 0, Callable(self, "_todo_ocupado"))
	_check(_min.veta_diferida(clave) == 2, "B8 dos barridos ocupados -> 2 diferimientos de la MISMA veta")
	_check(_min.diferidos() == 2, "B9 el total historico acumula (2)")

## ── C: se libera el lugar -> respawnea en el barrido siguiente ──────────────

func _test_liberado() -> void:
	# Reutiliza el MISMO nodo diferido en el bloque B: el reintento es sobre esa veta.
	var rn: ResourceNode = _rn_diferida
	_check(rn != null, "C0 el nodo diferido del bloque B esta disponible")
	if rn == null:
		return
	var clave: String = _min.clave_veta(rn)
	_check(_min.veta_diferida(clave) > 0, "C1 el nodo reutilizado sigue registrado como diferido")
	_check(rn.estado == ResourceNode.Estado.AGOTADO, "C2 arranca agotado (no respawneo en el bloque B)")
	_recuperadas.clear()
	var res: Dictionary = _min.barrido_regeneracion([rn], 10, 0, Callable(self, "_nadie_ocupado"))
	_check(int(res.get("respawnados", -1)) == 1, "C3 liberado el lugar, respawnea en el barrido siguiente")
	_check(rn.estado == ResourceNode.Estado.INTACTO, "C4 la veta queda INTACTO")
	_check(_min.veta_diferida(clave) == 0, "C5 el diferimiento por veta se limpia al respawnear")
	_check(_min.diferidos() == 2, "C6 el total historico NO baja (sigue 2)")
	_check(_recuperadas.size() == 1, "C7 emite el anuncio al respawnear")

## ── D: selectividad — solo se difiere lo ocupado ────────────────────────────

func _test_selectividad() -> void:
	_min.limpiar_diferidos()
	_recuperadas.clear()
	var def: ResourceDefinition = _rm.obtener_def(&"veta_hierro")
	var ocupada := _nodo_de(def, Vector3(450, 0, 0))    # x < 500 -> construccion M17
	var libre := _nodo_de(def, Vector3(550, 0, 0))      # x > 500 -> libre
	_agotar(ocupada, 10)
	_agotar(libre, 10)
	var res: Dictionary = _min.barrido_regeneracion([ocupada, libre], 10, 0, Callable(self, "_ocupado_x_menor_500"))
	_check(int(res.get("evaluados", -1)) == 2, "D1 evalua las 2 vetas")
	_check(int(res.get("diferidos", -1)) == 1, "D2 difiere solo la ocupada")
	_check(int(res.get("respawnados", -1)) == 1, "D3 respawnea solo la libre")
	_check(ocupada.estado == ResourceNode.Estado.AGOTADO, "D4 la ocupada sigue agotada")
	_check(libre.estado == ResourceNode.Estado.INTACTO, "D5 la libre vuelve a INTACTO")
	_check(_recuperadas.size() == 1, "D6 un solo anuncio (la libre)")

## ── E: el mapa de diferimientos esta ACOTADO (no crece sin limite) ──────────

func _test_tope() -> void:
	_min.limpiar_diferidos()
	var def: ResourceDefinition = _rm.obtener_def(&"veta_cobre")
	var vetas: Array = []
	for i in range(_min.MAX_DIFERIDOS + 6):
		var rn := _nodo_de(def, Vector3(1000 + i * 10, 0, 0))
		_agotar(rn, 10)
		vetas.append(rn)
	var res: Dictionary = _min.barrido_regeneracion(vetas, 10, 0, Callable(self, "_todo_ocupado"))
	_check(int(res.get("diferidos", -1)) == _min.MAX_DIFERIDOS + 6, "E1 cuenta TODOS los diferimientos del barrido")
	_check(_min.diferidos() == _min.MAX_DIFERIDOS + 6, "E2 el total historico cuenta todos")
	var mapa: Dictionary = _min.diferidos_por_veta()
	_check(mapa.size() == _min.MAX_DIFERIDOS, "E3 el mapa queda acotado a MAX_DIFERIDOS (%d, got %d)" % [_min.MAX_DIFERIDOS, mapa.size()])

## ── F: el espejo de calendario coincide con M15 en los 5 casos ──────────────

func _test_espejo() -> void:
	var def: ResourceDefinition = _rm.obtener_def(&"veta_cobre")
	var casos: Array = [
		{"dia": 9, "est": 0, "resp_dia": 10, "resp_est": -1, "estado": ResourceNode.Estado.AGOTADO, "esperado": false, "msg": "dia no alcanzado"},
		{"dia": 10, "est": 0, "resp_dia": 10, "resp_est": -1, "estado": ResourceNode.Estado.AGOTADO, "esperado": true, "msg": "dia alcanzado"},
		{"dia": 10, "est": 0, "resp_dia": 10, "resp_est": 2, "estado": ResourceNode.Estado.AGOTADO, "esperado": false, "msg": "estacion distinta"},
		{"dia": 10, "est": 2, "resp_dia": 10, "resp_est": 2, "estado": ResourceNode.Estado.AGOTADO, "esperado": true, "msg": "estacion coincide"},
		{"dia": 10, "est": 0, "resp_dia": 0, "resp_est": -1, "estado": ResourceNode.Estado.AGOTADO, "esperado": false, "msg": "respawn no programado"},
		{"dia": 10, "est": 0, "resp_dia": 10, "resp_est": -1, "estado": ResourceNode.Estado.INTACTO, "esperado": false, "msg": "veta no agotada"},
	]
	for i in range(casos.size()):
		var c: Dictionary = casos[i]
		# Dos nodos IDENTICOS: uno para el espejo (no muta), otro para M15 (muta).
		var a := _nodo_de(def, Vector3(2000 + i * 10, 0, 0))
		var b := _nodo_de(def, Vector3(2000 + i * 10, 0, 0))
		for rn in [a, b]:
			rn.estado = int(c["estado"])
			rn.respawn_estacion = int(c["resp_est"])
			rn.programar_respawn(int(c["resp_dia"]))
		var espejo: bool = _min._listo_por_calendario(a, int(c["dia"]), int(c["est"]))
		var m15: bool = b.evaluar_respawn(int(c["dia"]), int(c["est"]))
		_check(espejo == m15, "F%d espejo == M15 en '%s' (espejo=%s m15=%s)" % [i + 1, String(c["msg"]), str(espejo), str(m15)])
		_check(espejo == bool(c["esperado"]), "F%d valor esperado en '%s' (%s)" % [i + 1, String(c["msg"]), str(c["esperado"])])
		_check(a.estado == int(c["estado"]), "F%d el espejo NO muta el estado del nodo" % [i + 1])

## ── G: retrocompatibilidad del contrato del barrido ─────────────────────────

func _test_retrocompat() -> void:
	var res: Dictionary = _min.barrido_regeneracion([], 10, 0)
	_check(int(res.get("evaluados", -1)) == 0, "G1 array vacio -> evaluados 0")
	_check(res.has("respawnados"), "G2 conserva la clave 'respawnados' del contrato historico")
	_check(res.has("diferidos") and res.has("no_listos"), "G3 agrega las claves nuevas sin quitar las viejas")
	# Una veta no agotada cuenta como no_lista y no se toca.
	var def: ResourceDefinition = _rm.obtener_def(&"veta_cobre")
	var rn := _nodo_de(def, Vector3(3000, 0, 0))
	var res2: Dictionary = _min.barrido_regeneracion([rn], 10, 0, Callable(self, "_todo_ocupado"))
	_check(int(res2.get("no_listos", -1)) == 1, "G4 una veta INTACTA cuenta como no_lista")
	_check(int(res2.get("diferidos", -1)) == 0, "G5 no se difiere lo que ni siquiera esta listo")
	_check(rn.estado == ResourceNode.Estado.INTACTO, "G6 la veta no agotada no se toca")
