# M11: Test headless del CABLEADO del nucleo (PlayerCoreM11) al nodo del jugador.
#   Verifica que el nucleo aditivo (PlayerFSM + PlayerEnergy + CharacterSelector)
#   este REALMENTE conectado al runtime: un nodo hijo de Player lo alimenta por
#   frame desde el CharacterBody3D padre (duck-typing) y expone el estado.
#
# Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/player/test_player_cableado_m11.gd
# Exit: 0 = todo OK, 1 = algun fallo.
#
# ── Guardianes anti-falso-verde (3 capas, patron del repo) ──────────────
#   1. Marcadores _fin("A".."E") + BLOQUES_ESPERADOS: si un bloque no cierra
#      (aborto por SCRIPT ERROR), se NOMBRA y falla.
#   2. Piso CHECKS_MINIMOS = el total REAL medido en verde (no el teorico).
#   3. _summary() registrado con call_deferred en _init(): si _run() aborta,
#      la cola diferida sigue, el resumen sale y quit(1) decide el EXIT.
#
# Se usa preload() (no el nombre global de clase) para no depender de la cache
# de clases globales (trampa 123).

extends SceneTree

const MODULO := "M11 Cableado"
const BLOQUES_ESPERADOS := ["A", "B", "C", "D", "E"]
## Total REAL medido en verde (49 = 9 A + 9 B + 13 C + 10 D + 8 E). Si baja, algo dejo de correr.
const CHECKS_MINIMOS := 49

const CORE := preload("res://scripts/player/player_core_m11.gd")

## Jugador falso: CharacterBody3D con la MISMA superficie que player.gd
## (`_on_ground` var y `_en_agua()` metodo) para ejercitar el duck-typing.
class FakePlayer extends CharacterBody3D:
	var _on_ground: bool = true
	var _agua: bool = false
	func _en_agua() -> bool:
		return _agua

var _checks := 0
var _fallos := 0
var _checks_previo := 0
var _vistos: Dictionary = {}
var _terminado := false

var _player: CharacterBody3D = null
var _core: Node = null

func _init() -> void:
	call_deferred("_run")
	call_deferred("_resumen_seguro")

func _resumen_seguro() -> void:
	if _terminado:
		return
	_fallos += 1
	print("!! _run() NO llego al final: aborto por SCRIPT ERROR (no hubo veredicto)")
	_summary()

func _check(ok: bool, msg: String) -> void:
	_checks += 1
	if ok:
		print("[OK]    ", msg)
	else:
		_fallos += 1
		print("[FALLO] ", msg)

func _fin(nombre: String) -> void:
	_vistos[nombre] = true
	print("[FIN] bloque %s (+%d checks)" % [nombre, _checks - _checks_previo])
	_checks_previo = _checks

func _summary() -> void:
	_terminado = true
	for b in BLOQUES_ESPERADOS:
		if not _vistos.has(b):
			_checks += 1
			_fallos += 1
			print("[FALLO] Bloque faltante: %s" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FALLO] solo %d checks ejecutados (minimo %d): aborto parcial" % [_checks, CHECKS_MINIMOS])
	print("=== %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	quit(1 if _fallos > 0 else 0)

## Monta un jugador falso con el nodo del nucleo como hijo (dispara _ready) y
## desactiva el _physics_process del motor (la suite lo llama a mano).
func _montar() -> void:
	_player = FakePlayer.new()
	root.add_child(_player)
	_core = CORE.new()
	_player.add_child(_core)
	_core.set_physics_process(false)

func _desmontar() -> void:
	if _player != null:
		_player.free()
	_player = null
	_core = null

func _tic(delta: float) -> void:
	_core.call("actualizar", delta)

func _estado() -> int:
	return int(_core.call("estado_actual"))

## ── Bloque A: montaje e instanciacion de los 3 modelos ───────────────

func _bloque_a_montaje() -> void:
	_check(CORE != null, "A1 PlayerCoreM11 (script del cableado) carga")
	_montar()
	_check(_core != null, "A2 el nodo del nucleo se instancia")
	_check(_core.get("fsm") != null, "A3 fsm instanciada en _ready")
	_check(_core.get("energia") != null, "A4 energia instanciada en _ready")
	_check(_core.get("selector") != null, "A5 selector instanciado en _ready")
	_check(int(_core.call("frames")) == 0, "A6 frames() = 0 antes del primer tic")
	_check(str(_core.call("nombre_estado")) == "IDLE", "A7 estado inicial = IDLE")
	_check(absf(float(_core.call("energia_actual")) - 100.0) < 0.001, "A8 energia inicial = 100")
	_check(str(_core.call("personaje_actual")) == "char_01", "A9 personaje inicial = char_01")
	_desmontar()
	_fin("A")

## ── Bloque B: la FSM esta VIVA (deriva del padre real) ───────────────

func _bloque_b_fsm_viva() -> void:
	_montar()
	_player.velocity = Vector3.ZERO
	_player.set("_on_ground", true)
	_tic(0.016)
	_check(_estado() == 0, "B1 padre quieto en suelo -> IDLE (%d)" % _estado())

	_player.velocity = Vector3(5.0, 0.0, 0.0)
	_tic(0.016)
	_check(_estado() == 1, "B2 padre con velocidad horizontal -> WALK (%d)" % _estado())
	_check(str(_core.call("nombre_estado")) == "WALK", "B3 nombre_estado() legible = WALK")

	_player.velocity = Vector3(0.0, 3.0, 0.0)
	_player.set("_on_ground", false)
	_tic(0.016)
	_check(_estado() == 3, "B4 sin suelo + vy>0 -> JUMP (%d)" % _estado())

	_player.velocity = Vector3(0.0, -3.0, 0.0)
	_tic(0.016)
	_check(_estado() == 4, "B5 sin suelo + vy<0 -> FALL (%d)" % _estado())

	# Agua: el padre expone _en_agua() -> SWIM.
	_player.set("_agua", true)
	_player.velocity = Vector3.ZERO
	_tic(0.016)
	_check(_estado() == 5, "B6 _en_agua() del padre -> SWIM (%d)" % _estado())

	# Volver a suelo quieto -> IDLE (el agua deja de mandar).
	_player.set("_agua", false)
	_player.set("_on_ground", true)
	_player.velocity = Vector3.ZERO
	_tic(0.016)
	_check(_estado() == 0, "B7 vuelve a suelo quieto -> IDLE (%d)" % _estado())

	# vy<0 con suelo: el suelo manda (no FALL).
	_player.velocity = Vector3(0.0, -3.0, 0.0)
	_tic(0.016)
	_check(_estado() == 0, "B8 en_suelo manda sobre vy<0 (no FALL) (%d)" % _estado())

	_check(int(_core.call("frames")) == 7, "B9 frames() cuenta los 7 tics (%d)" % int(_core.call("frames")))
	_desmontar()
	_fin("B")

## ── Bloque C: la energia esta VIVA (actualiza por frame) ─────────────

func _bloque_c_energia_viva() -> void:
	_montar()
	_player.velocity = Vector3.ZERO
	_player.set("_on_ground", true)
	_tic(60.0)
	_check(absf(float(_core.call("energia_actual")) - 100.0) < 0.001,
		"C1 60 s sin correr: regen clampeada en max (%.2f)" % float(_core.call("energia_actual")))

	_core.call("consumir_energia", 50.0)
	_check(absf(float(_core.call("energia_actual")) - 50.0) < 0.001,
		"C2 consumir 50 -> energia 50 (%.2f)" % float(_core.call("energia_actual")))

	_tic(60.0)
	_check(absf(float(_core.call("energia_actual")) - 51.0) < 0.001,
		"C3 60 s regeneran 1/min -> 51 (%.2f)" % float(_core.call("energia_actual")))

	# Sprint (hook): marcado corriendo + movimiento en suelo -> RUN, y el drenado
	# queda cubierto por el modelo (neto 0/min). Hoy player.gd no llama al hook.
	_core.call("marcar_corriendo", true)
	_player.velocity = Vector3(5.0, 0.0, 0.0)
	_tic(0.016)
	_check(_estado() == 2, "C4 hook correr + suelo en movimiento -> RUN (%d)" % _estado())

	_tic(60.0)
	_check(absf(float(_core.call("energia_actual")) - 51.0) < 0.001,
		"C5 correr 60 s tiene balance neto 0/min -> 51 (%.2f)" % float(_core.call("energia_actual")))

	_tic(600.0)
	_check(float(_core.call("energia_actual")) > 0.0,
		"C6 L70: correr 10 min NO agota (>0) (%.2f)" % float(_core.call("energia_actual")))

	_core.call("consumir_energia", 1000.0)
	_check(absf(float(_core.call("energia_actual")) - 0.0) < 0.001,
		"C7 consumir de mas clampea a 0 (%.2f)" % float(_core.call("energia_actual")))
	_check(bool(_core.call("agotada")), "C8 agotada() true a energia 0")
	_check(bool(_core.call("descansando")), "C9 agotada -> auto-descanso (cozy)")
	_check(not bool(_core.call("puede_correr")), "C10 agotada -> puede_correr() false")

	_core.call("recargar_dormir")
	_check(absf(float(_core.call("energia_actual")) - 100.0) < 0.001,
		"C11 recargar_dormir() -> 100 (%.2f)" % float(_core.call("energia_actual")))
	_core.call("consumir_energia", 90.0)
	_core.call("recargar_descanso")
	_check(absf(float(_core.call("energia_actual")) - 40.0) < 0.001,
		"C12 recargar_descanso() desde 10 -> 40 (%.2f)" % float(_core.call("energia_actual")))

	var fr := float(_core.call("fraccion_energia"))
	_check(fr >= 0.0 and fr <= 1.0, "C13 fraccion_energia() en [0,1] (%.2f)" % fr)
	_desmontar()
	_fin("C")

## ── Bloque D: el selector esta VIVO (seleccion + persistencia) ───────

func _bloque_d_selector_vivo() -> void:
	_montar()
	_check(str(_core.call("personaje_actual")) == "char_01", "D1 personaje inicial char_01")
	_check(bool(_core.call("seleccionar_personaje", "char_03")), "D2 seleccionar_personaje(char_03) = true")
	_check(str(_core.call("personaje_actual")) == "char_03", "D3 seleccion aplicada")
	_check(not bool(_core.call("seleccionar_personaje", "char_99")), "D4 id invalido = false")
	_check(str(_core.call("personaje_actual")) == "char_03", "D5 id invalido no cambia la seleccion")
	var bloque: Dictionary = _core.call("serializar_personaje")
	_check(str(bloque.get("character_id", "")) == "char_03", "D6 serializar emite character_id")
	_check(bool(_core.call("deserializar_personaje", {"character_id": "char_05"})), "D7 deserializar id valido = true")
	_check(str(_core.call("personaje_actual")) == "char_05", "D8 deserializacion aplicada")
	_check(not bool(_core.call("deserializar_personaje", {"character_id": "char_99"})), "D9 deserializar id invalido = false")
	_check(str(_core.call("personaje_actual")) == "char_05", "D10 id invalido no degrada la seleccion")
	_desmontar()
	_fin("D")

## ── Bloque E: contrato / no requiere autoloads ni padre ──────────────

func _bloque_e_contrato() -> void:
	# Nodo suelto (sin _ready): los accesores guardan contra null, sin crash.
	var suelto: Node = CORE.new()
	var snap: Dictionary = suelto.call("leer_snapshot")
	_check(bool(snap.get("en_suelo", false)) and float(snap.get("magnitud_direccion", 1.0)) == 0.0,
		"E1 snapshot por defecto sin padre (en_suelo=true, magnitud=0)")
	_check(int(suelto.call("estado_actual")) == -1, "E2 estado_actual() = -1 sin modelos (guard)")
	_check(float(suelto.call("energia_actual")) == -1.0, "E3 energia_actual() = -1 sin modelos (guard)")
	_check(str(suelto.call("personaje_actual")) == "", "E4 personaje_actual() = '' sin modelos (guard)")
	suelto.call("marcar_corriendo", true)
	suelto.call("consumir_energia", 10.0)
	var snap2: Dictionary = suelto.call("leer_snapshot")
	_check(bool(snap2.get("correr", false)) and int(suelto.call("estado_actual")) == -1,
		"E5 hooks sin modelos: no rompen y el objeto sigue usable")
	suelto.free()

	# Padre que NO es CharacterBody3D: no crash, snapshot por defecto.
	var n3 := Node3D.new()
	root.add_child(n3)
	var c2: Node = CORE.new()
	n3.add_child(c2)
	c2.set_physics_process(false)
	c2.call("actualizar", 0.016)
	_check(int(c2.call("estado_actual")) == 0, "E6 padre Node3D -> IDLE sin crash (%d)" % int(c2.call("estado_actual")))
	n3.free()

	# El nodo montado realmente en Player.tscn es hijo del jugador.
	var packed: PackedScene = load("res://scenes/player/Player.tscn")
	var jugador: Node = packed.instantiate() if packed != null else null
	if jugador != null:
		root.add_child(jugador)
		var nodo: Node = jugador.get_node_or_null("NucleoM11")
		_check(nodo != null, "E7 Player.tscn monta el nodo NucleoM11")
		_check(nodo != null and nodo.get_script() == CORE, "E8 el nodo NucleoM11 usa el script del cableado")
		jugador.queue_free()
	else:
		_check(false, "E7-E8 no se pudo instanciar Player.tscn")
	_fin("E")

## ── Suite principal ─────────────────────────────────────────────────

func _run() -> void:
	print("=== %s — suite del cableado del nucleo ===" % MODULO)
	_bloque_a_montaje()
	_bloque_b_fsm_viva()
	_bloque_c_energia_viva()
	_bloque_d_selector_vivo()
	_bloque_e_contrato()
	_summary()
