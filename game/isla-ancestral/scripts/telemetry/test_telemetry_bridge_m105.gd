# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-21
#
# M105 iter. 9 — Test del PUENTE EventBus -> track_* (item 27 del backlog).
#
# POR QUE EXISTE (medido, no supuesto):
#   Las 13 funciones `track_*` de `telemetry_director.gd` tenian **0 llamadores de
#   produccion** (grep `.track_X(` sobre `scripts/`, excluyendo `test_*` = 0 en los
#   13). El checklist afirmaba "M105 ya emite los 11 eventos 'first'" y el item 228
#   decia que el hook de M22 "requiere M22 iteracion adicional". Ambas cosas eran
#   FALSAS/VENCIDAS: `EventBus.quest.prereq_met` existe y `story_manager.gd:187`
#   ya lo emite. Faltaba el consumidor de este lado.
#
# QUE FIJA ESTA SUITE:
#   A  el autoload cablea el puente solo (`bridge_cobertura().conectado`).
#   B  toda fila de la tabla cita simbolos que EXISTEN (senal en el bus + metodo
#      en el director). Sin esto la tabla puede podrirse en silencio.
#   C  el despacho real emite `seal_first_obtained` con el sello recibido.
#   D  dedup: dos emits del MISMO sello producen UN evento (contrato `_track_first`).
#   E  opt-out: con `opt_in = false` el puente NO emite nada (privacidad).
#   F  fail-closed: director nulo / bus nulo => 0 conexiones + motivo explicito.
#   G  idempotencia: conectar() dos veces con la MISMA instancia no duplica.
#   H  control NEGATIVO: una senal NO mapeada (`quest.quest_completed`) no produce
#      ningun evento de sello. Sin este control, C pasaria aunque el puente
#      escuchara "cualquier cosa".
#
# GUARDIAN ANTI-FALSO-VERDE (trampas 61/62/63/122 del proyecto):
#   - `_fin("bloque")` al final de CADA bloque; `_resumen()` nombra los faltantes.
#   - `_resumen()` corre en su PROPIO `call_deferred`, SEPARADO del de `_ejecutar`:
#     si `_ejecutar` aborta por SCRIPT ERROR, el resumen igual corre y sale EXIT 1.
#     (Con el resumen al final de `_ejecutar` la suite se CUELGA en vez de fallar.)
#   - `quit()` vive SOLO en `_resumen()`.
#   - Piso `CHECKS_MINIMOS` MEDIDO en verde, no estimado.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://scripts/telemetry/test_telemetry_bridge_m105.gd
extends SceneTree

const BLOQUES := [
	"autoload",
	"tabla_simbolos",
	"despacho",
	"dedup",
	"optout",
	"fail_closed",
	"idempotencia",
	"control_negativo",
	"limpieza",
]

## Piso de chequeos: MEDIDO en verde = 38 (no estimado: la primera version puso 40
## de memoria y el propio piso la delato con 38 reales).
const CHECKS_MINIMOS := 38

const RUTA_BRIDGE := "res://scripts/telemetry/telemetry_bridge.gd"
const RUTA_DIRECTOR := "res://scripts/telemetry/telemetry_director.gd"

var _fallos := 0
var _checks := 0
var _vistos: Dictionary = {}
var _resumen_hecho := false
var _ad = null
var _stub = null
var _puente = null
var _dir_aislado = null
var _stub_aislado = null
var _senales: Array = []


class _AnalyticsStub:
	extends Node
	var calls: Array = []
	func registrar_evento(tipo: String, datos: Dictionary = {}) -> void:
		calls.append({"tipo": tipo, "datos": datos})
	func establecer_opt_out(_v: bool) -> void:
		pass


func _initialize() -> void:
	print("=== TEST TELEMETRIA M105 ITER9 (puente EventBus -> track_*) ===")
	# DOS deferred INDEPENDIENTES (trampa 61): si `_ejecutar` aborta, `_resumen` corre.
	call_deferred("_ejecutar")
	call_deferred("_resumen")


func _fin(bloque: String) -> void:
	_vistos[bloque] = true


func _ejecutar() -> void:
	_ad = root.get_node_or_null("TelemetryDirector")
	_check("autoload TelemetryDirector presente", _ad != null)
	if _ad == null:
		_fin("autoload")
		return
	_ad._settings_path = "user://telemetry_test_iter9/telemetry.cfg"
	_stub = _AnalyticsStub.new()
	_ad.analytics_service = _stub
	_ad.establecer_opt_in(true)
	# El autoload cablea el puente en un `call_deferred` de su `_ready()`; si esta
	# corrida llego antes, lo forzamos (idempotente).
	_ad._conectar_bridge()
	var cob: Dictionary = _ad.bridge_cobertura()
	_check("puente instanciado por el autoload", bool(cob.get("conectado", false)))
	_check("al menos 1 senal conectada en produccion", int(cob.get("conectadas", 0)) >= 1)
	var claves: Array = cob.get("claves", [])
	_check("la clave quest.prereq_met esta conectada", claves.has("quest.prereq_met"))
	_check("declaradas == 1 (tabla medida, no inflada)", int(cob.get("declaradas", -1)) == 1)
	_fin("autoload")

	_test_tabla_simbolos()
	_test_despacho()
	_test_dedup()
	_test_optout()
	_test_fail_closed()
	_test_idempotencia()
	_test_control_negativo()

	# limpieza
	if _ad != null and FileAccess.file_exists(_ad._settings_path):
		DirAccess.remove_absolute(_ad._settings_path)
		DirAccess.remove_absolute(_ad._settings_path.get_base_dir())
	if _dir_aislado != null and is_instance_valid(_dir_aislado):
		_dir_aislado.free()
	if _stub_aislado != null and is_instance_valid(_stub_aislado):
		_stub_aislado.free()
	_fin("limpieza")


# ── B: la tabla solo cita simbolos que existen ────────────────────────────
func _test_tabla_simbolos() -> void:
	var bus := root.get_node_or_null("EventBus")
	_check("EventBus autoload presente", bus != null)
	var script_puente = load(RUTA_BRIDGE)
	_check("telemetry_bridge.gd carga", script_puente != null)
	if script_puente == null or bus == null:
		_fin("tabla_simbolos")
		return
	var p = script_puente.new()
	var informe: Dictionary = p.verificar(_ad, bus)
	_check("tabla declara >= 1 fila", int(informe.get("declaradas", 0)) >= 1)
	_check("todas las filas resuelven (senal + metodo)",
		int(informe.get("verificadas", -1)) == int(informe.get("declaradas", -2)))
	var detalle: Array = informe.get("detalle", [])
	_check("el detalle audita cada fila", detalle.size() == int(informe.get("declaradas", -1)))
	var fila0: Dictionary = detalle[0] if detalle.size() > 0 else {}
	_check("fila 0: la senal existe en el bus", bool(fila0.get("senal_existe", false)))
	_check("fila 0: el metodo existe en el director", bool(fila0.get("metodo_existe", false)))
	_check("fila 0 mapea a track_seal_first_obtained",
		str(fila0.get("metodo", "")) == "track_seal_first_obtained")
	_fin("tabla_simbolos")


# ── C: el despacho real emite el evento ───────────────────────────────────
func _test_despacho() -> void:
	var bus := root.get_node_or_null("EventBus")
	if bus == null:
		_check("EventBus presente para despacho", false)
		_fin("despacho")
		return
	var antes: int = _conteo_evento("seal_first_obtained")
	var sello := "sello_iter9_alfa"
	bus.quest.prereq_met.emit(sello)
	var despues: int = _conteo_evento("seal_first_obtained")
	_check("el emit de prereq_met produjo seal_first_obtained", despues == antes + 1)
	_check("el payload lleva el sello recibido", _ultimo_sello() == sello)
	var cob: Dictionary = _ad.bridge_cobertura()
	_check("el puente registro >= 1 despacho", int(cob.get("despachos", 0)) >= 1)
	_check("0 descartes del puente", int(cob.get("descartes", -1)) == 0)
	_fin("despacho")


# ── D: dedup del mismo sello ──────────────────────────────────────────────
## CONTRATO MEDIDO (no supuesto): `track_seal_first_obtained` usa la clave de
## tracker `&"sello"`, NO el id del sello. Es decir: el evento es "el PRIMER sello
## obtenido" y se emite **una sola vez por sesion**, sea cual sea el id. Un test
## que espere un evento por cada sello distinto estaria fijando lo contrario del
## diseno (familia de la trampa 88: dos errores que se cancelan). Lo que se afirma
## es el contrato real: UN evento, y el PUENTE despachando en cada emit.
func _test_dedup() -> void:
	var bus := root.get_node_or_null("EventBus")
	if bus == null:
		_check("EventBus presente para dedup", false)
		_fin("dedup")
		return
	var antes: int = _conteo_evento("seal_first_obtained")
	var desp_antes: int = int(_ad.bridge_cobertura().get("despachos", 0))
	bus.quest.prereq_met.emit("sello_iter9_alfa")
	_check("re-emitir el MISMO sello NO duplica el evento", _conteo_evento("seal_first_obtained") == antes)
	bus.quest.prereq_met.emit("sello_iter9_beta")
	_check("un sello DISTINTO tampoco emite: la clave es 'sello', no el id",
		_conteo_evento("seal_first_obtained") == antes)
	_check("pero el puente SI despacho los 2 emits",
		int(_ad.bridge_cobertura().get("despachos", 0)) == desp_antes + 2)
	_fin("dedup")


# ── E: opt-out respeta la privacidad ─────────────────────────────────────
func _test_optout() -> void:
	var bus := root.get_node_or_null("EventBus")
	if bus == null:
		_check("EventBus presente para optout", false)
		_fin("optout")
		return
	# Director AISLADO para no ensuciar el autoload (y para tener su propio stub).
	var script_dir = load(RUTA_DIRECTOR)
	if script_dir == null:
		_check("telemetry_director.gd carga", false)
		_fin("optout")
		return
	_dir_aislado = script_dir.new()
	_stub_aislado = _AnalyticsStub.new()
	_dir_aislado.analytics_service = _stub_aislado
	_dir_aislado.opt_in = false
	var p = load(RUTA_BRIDGE).new()
	var n: int = p.conectar(_dir_aislado, bus)
	_check("el puente se conecta a un director aislado", n == 1)
	bus.quest.prereq_met.emit("sello_iter9_optout")
	_check("con opt_out=false NO se registra evento", _stub_aislado.calls.size() == 0)
	# y con opt_in=true el mismo camino si emite (control positivo del bloque)
	_dir_aislado.opt_in = true
	bus.quest.prereq_met.emit("sello_iter9_optin")
	_check("con opt_in=true SI se registra evento", _stub_aislado.calls.size() >= 1)
	var ok_evento := false
	for c in _stub_aislado.calls:
		if str(c["datos"].get("evento", "")) == "seal_first_obtained":
			ok_evento = true
	_check("el evento registrado es seal_first_obtained", ok_evento)
	p.desconectar()
	_fin("optout")


# ── F: fail-closed ────────────────────────────────────────────────────────
func _test_fail_closed() -> void:
	var bus := root.get_node_or_null("EventBus")
	var p = load(RUTA_BRIDGE).new()
	_check("conectar(director, bus) sin director => 0", p.conectar(null, bus) == 0)
	var motivos: Array = p.cobertura().get("motivos", [])
	_check("sin director reporta motivo", motivos.size() == 1 and str(motivos[0]).contains("director nulo"))
	_check("conectar(director, bus) sin bus => 0", p.conectar(_ad, null) == 0)
	var motivos2: Array = p.cobertura().get("motivos", [])
	_check("sin bus reporta motivo", motivos2.size() == 1 and str(motivos2[0]).contains("bus nulo"))
	_check("un puente sin conectar no despacha nada", int(p.cobertura().get("despachos", -1)) == 0)
	_fin("fail_closed")


# ── G: idempotencia ───────────────────────────────────────────────────────
func _test_idempotencia() -> void:
	var bus := root.get_node_or_null("EventBus")
	var p = load(RUTA_BRIDGE).new()
	var n1: int = p.conectar(_ad, bus)
	_check("primera conexion conecta 1 senal", n1 == 1)
	var n2: int = p.conectar(_ad, bus)
	_check("segunda conexion con la MISMA instancia => 0", n2 == 0)
	_check("no se duplico el registro", int(p.cobertura().get("conectadas", -1)) == 1)
	var motivos: Array = p.cobertura().get("motivos", [])
	var ya_conectada := false
	for m in motivos:
		if str(m).contains("ya conectada"):
			ya_conectada = true
	_check("reporta 'ya conectada' como motivo", ya_conectada)
	var quitadas: int = p.desconectar()
	_check("desconectar() quita 1 conexion", quitadas == 1)
	_check("tras desconectar, conectadas == 0", int(p.cobertura().get("conectadas", -1)) == 0)
	_fin("idempotencia")


# ── H: control negativo (senal NO mapeada) ────────────────────────────────
func _test_control_negativo() -> void:
	var bus := root.get_node_or_null("EventBus")
	if bus == null:
		_check("EventBus presente para control negativo", false)
		_fin("control_negativo")
		return
	var antes: int = _conteo_evento("seal_first_obtained")
	var desp_antes: int = int(_ad.bridge_cobertura().get("despachos", 0))
	bus.quest.quest_completed.emit("quest_no_mapeada_iter9")
	_check("una senal NO mapeada no produce evento de sello",
		_conteo_evento("seal_first_obtained") == antes)
	_check("una senal NO mapeada tampoco pasa por el puente",
		int(_ad.bridge_cobertura().get("despachos", 0)) == desp_antes)
	# El puente sigue vivo: el despacho se cuenta aunque el tracker ya este usado.
	bus.quest.prereq_met.emit("sello_iter9_gamma")
	_check("el puente sigue despachando tras una senal ajena",
		int(_ad.bridge_cobertura().get("despachos", 0)) == desp_antes + 1)
	_fin("control_negativo")


# ── helpers ───────────────────────────────────────────────────────────────
func _constantes() -> Dictionary:
	return _ad.get_script().get_script_constant_map()


func _conteo_evento(evento: String) -> int:
	var c := 0
	for call in _stub.calls:
		if str(call["datos"].get("evento", "")) == evento:
			c += 1
	return c


func _ultimo_sello() -> String:
	for i in range(_stub.calls.size() - 1, -1, -1):
		var d: Dictionary = _stub.calls[i]["datos"]
		if str(d.get("evento", "")) == "seal_first_obtained":
			return str(d.get("sello_id", ""))
	return ""


func _resumen() -> void:
	if _resumen_hecho:
		return
	_resumen_hecho = true
	var faltantes: Array = []
	for b in BLOQUES:
		if not _vistos.has(b):
			faltantes.append(b)
	if not faltantes.is_empty():
		_fallos += 1
		print("[FAIL] bloques NO completados (aborto silencioso): %s" % str(faltantes))
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d): aborto silencioso dentro de un bloque" % [_checks, CHECKS_MINIMOS])
	print("=== TEST TELEMETRIA M105 ITER9: %d fallo(s) de %d cheque(s) ===" % [_fallos, _checks])
	quit(1 if _fallos > 0 else 0)


func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s" % nombre)
