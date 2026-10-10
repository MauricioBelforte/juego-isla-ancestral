# M11: Test headless del NUCLEO ADITIVO del Personaje del Jugador
#   (PlayerFSM + PlayerEnergy + CharacterSelector) — modelos puros.
#
# Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/player/test_player_core_m11.gd
# Exit: 0 = todo OK, 1 = algun fallo.
#
# ── Guardianes anti-falso-verde (3 capas, patron del repo) ──────────────
#   1. Marcadores _fin("A".."D") + BLOQUES_ESPERADOS: si un bloque no cierra
#      (aborto por SCRIPT ERROR), se NOMBRA y falla.
#   2. Piso CHECKS_MINIMOS = el total REAL medido en verde (no el teorico).
#   3. _summary() registrado con call_deferred en _init(): si _run() aborta,
#      la cola diferida sigue, el resumen sale y quit(1) decide el EXIT.
#   Los 3 se probaron EN ROJO por inyeccion antes de confiar en ellos.
#
# Nota de diseno: se usa preload() (no el nombre global de clase) para NO
# depender de la cache de clases globales (trampa 123: un class_name nuevo no
# existe para --script hasta regenerar la cache). Asi la suite corre igual en
# un checkout limpio.

extends SceneTree

const MODULO := "M11 Nucleo"
const BLOQUES_ESPERADOS := ["A", "B", "C", "D"]
## Total REAL medido en verde (3 corridas). Si baja, algo dejo de correr.
## 87 = 33 (A) + 28 (B) + 20 (C) + 6 (D). Subio de 81 al re-implementar la
## energia a 1/minuto (D1, msg 135): el bloque B paso de 22 a 28 checks.
const CHECKS_MINIMOS := 87

const FSM := preload("res://scripts/player/player_fsm.gd")
const ENERGY := preload("res://scripts/player/player_energy.gd")
const SELECTOR := preload("res://scripts/player/character_selector.gd")

var _checks := 0
var _fallos := 0
var _checks_previo := 0
var _vistos: Dictionary = {}
var _terminado := false

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

## ── Bloque A: FSM de estados (C.49-C.64) ────────────────────────────

func _bloque_a_fsm() -> void:
	var fsm: RefCounted = FSM.new()
	_check(fsm != null, "A1 PlayerFSM instanciable")

	_check(int(fsm.cantidad_estados()) == 11,
		"A2 11 estados declarados (%d)" % int(fsm.cantidad_estados()))
	_check((fsm.destinos_invalidos() as Array).is_empty(),
		"A3 sin destinos invalidos en el grafo de transiciones")
	_check((fsm.estados_incompletos() as Array).is_empty(),
		"A4 todo estado tiene permisos y transiciones")

	_check(int(fsm.estado_actual()) == 0,
		"A5 estado inicial = IDLE (%d)" % int(fsm.estado_actual()))
	_check(str(fsm.nombre_actual()) == "IDLE", "A6 nombre_actual() legible = IDLE")

	_check(bool(fsm.permite("mov")), "A7 IDLE permite mov")
	_check(bool(fsm.permite("correr")), "A8 IDLE permite correr")

	_check(bool(fsm.transicionar(1)), "A9 IDLE -> WALK valida")
	_check(int(fsm.estado_actual()) == 1, "A10 estado pasa a WALK")
	_check(not bool(fsm.transicionar(6)), "A11 WALK -> DIVE RECHAZADA (imposible)")
	_check(int(fsm.estado_actual()) == 1, "A12 estado NO cambio tras transicion invalida")
	_check(not bool(fsm.transicionar(99)), "A13 transicion a estado inexistente RECHAZADA")
	_check(not bool(fsm.puede_transicionar(6)), "A14 puede_transicionar(DIVE)=false desde WALK")

	# derivar(): cada rama del diseno seccion 2.
	_check(int(fsm.derivar({"durmiendo": true})) == 9, "A15 derivar durmiendo -> SLEEP")
	_check(int(fsm.derivar({"crafteando": true})) == 10, "A16 derivar crafteando -> CRAFT")
	_check(int(fsm.derivar({"interactuando": true})) == 8, "A17 derivar interactuando -> INTERACT")
	_check(int(fsm.derivar({"en_agua": true, "aire_restante": 0.1})) == 7,
		"A18 derivar agua + aire<=20% -> SURFACE (flota, cozy)")
	_check(int(fsm.derivar({"en_agua": true, "sumergido": true, "aire_restante": 0.9})) == 6,
		"A19 derivar agua + sumergido -> DIVE")
	_check(int(fsm.derivar({"en_agua": true, "aire_restante": 0.9})) == 5,
		"A20 derivar agua en superficie -> SWIM")
	_check(int(fsm.derivar({"en_suelo": false, "velocidad_y": 3.0})) == 3,
		"A21 derivar sin suelo + vy>0 -> JUMP")
	_check(int(fsm.derivar({"en_suelo": false, "velocidad_y": -3.0})) == 4,
		"A22 derivar sin suelo + vy<0 -> FALL")
	_check(int(fsm.derivar({"en_suelo": true, "magnitud_direccion": 0.0})) == 0,
		"A23 derivar en suelo quieto -> IDLE")
	_check(int(fsm.derivar({"en_suelo": true, "magnitud_direccion": 0.5})) == 1,
		"A24 derivar en suelo caminando -> WALK")
	_check(int(fsm.derivar({"en_suelo": true, "magnitud_direccion": 0.5, "correr": true})) == 2,
		"A25 derivar en suelo corriendo -> RUN")

	# Tabla de permisos por estado.
	var inter: RefCounted = FSM.new()
	inter.transicionar(0)
	inter.transicionar(8)  # IDLE -> INTERACT
	_check(not bool(inter.permite("mov")), "A26 INTERACT bloquea movimiento (0.3 s)")
	_check(not bool(inter.permite("saltar")), "A27 INTERACT no permite saltar")
	var jump: RefCounted = FSM.new()
	jump.transicionar(3)  # IDLE -> JUMP
	_check(bool(jump.permite("mov")), "A28 JUMP permite movimiento (control aereo 60%)")
	_check(not bool(jump.permite("correr")), "A29 JUMP no permite sprint")
	var dive: RefCounted = FSM.new()
	dive.actualizar_desde({"en_agua": true, "sumergido": true, "aire_restante": 0.9})
	_check(not bool(dive.permite("saltar")), "A30 DIVE no permite saltar")
	_check(not bool(dive.permite("interactuar")), "A31 DIVE no permite interactuar")

	# actualizar_desde(): integra derivar + validacion.
	var f2: RefCounted = FSM.new()
	_check(int(f2.actualizar_desde({"en_suelo": true, "magnitud_direccion": 0.5})) == 1,
		"A32 actualizar_desde -> WALK")
	_check(int(f2.actualizar_desde({"en_suelo": true, "magnitud_direccion": 0.0})) == 0,
		"A33 actualizar_desde -> IDLE")

	_fin("A")

## ── Bloque B: energia / stamina cozy (E) — 1/min (D1, msg 135)────────────────────────────

func _bloque_b_energy() -> void:
	var e: RefCounted = ENERGY.new()
	_check(e != null, "B1 PlayerEnergy instanciable")
	_check(absf(float(e.energia()) - 100.0) < 0.001,
		"B2 energia inicial = ENERGIA_MAX (%d)" % int(ENERGY.ENERGIA_MAX))
	_check(absf(float(e.fraccion()) - 1.0) < 0.001, "B3 fraccion inicial = 1.0")
	_check(not bool(e.agotada()), "B4 no agotada al inicio")
	_check(not bool(e.en_fatiga()), "B5 no en fatiga al inicio")

	# Constantes de la decision D1 (msg 135): 1/minuto (01-Requerimientos 6.1).
	_check(absf(float(ENERGY.COSTO_CORRER_POR_MINUTO) - 1.0) < 0.001,
		"B6 costo correr = 1/minuto (%d)" % int(ENERGY.COSTO_CORRER_POR_MINUTO))
	_check(absf(float(ENERGY.REGEN_POR_MINUTO) - 1.0) < 0.001,
		"B7 regen = 1/minuto (%d)" % int(ENERGY.REGEN_POR_MINUTO))
	_check(absf(float(e.regen_por_segundo()) - (1.0 / 60.0)) < 0.0001,
		"B8 regen_por_segundo = 1/60 -> %.5f" % float(e.regen_por_segundo()))
	_check(absf(float(e.costo_correr_por_segundo()) - (1.0 / 60.0)) < 0.0001,
		"B9 costo_correr_por_segundo = 1/60 -> %.5f" % float(e.costo_correr_por_segundo()))

	# Caminar y parado: regen 1/min SIEMPRE (L66). 60 s -> +1.
	var w: RefCounted = ENERGY.new()
	w.restaurar(50.0)
	w.actualizar(60.0, false, true)
	_check(absf(float(w.energia()) - 51.0) < 0.001,
		"B10 caminar 60 s regenera 1/min -> %.2f" % float(w.energia()))
	var p: RefCounted = ENERGY.new()
	p.restaurar(50.0)
	p.actualizar(60.0, false, false)
	_check(absf(float(p.energia()) - 51.0) < 0.001,
		"B11 parado 60 s regenera 1/min -> %.2f" % float(p.energia()))

	# Correr: costo 1/min + regen 1/min = balance NETO 0/min (L70 estructural).
	var r: RefCounted = ENERGY.new()
	r.restaurar(50.0)
	r.actualizar(60.0, true, true)
	_check(absf(float(r.energia()) - 50.0) < 0.001,
		"B12 correr 60 s tiene balance neto 0/min -> %.2f" % float(r.energia()))
	var r2: RefCounted = ENERGY.new()
	r2.restaurar(50.0)
	r2.actualizar(600.0, true, true)
	_check(absf(float(r2.energia()) - 50.0) < 0.001,
		"B13 correr 10 min NO baja la energia -> %.2f" % float(r2.energia()))

	# L70 (directiva del usuario): correr NUNCA lleva la energia a cero.
	var l70: RefCounted = ENERGY.new()
	l70.actualizar(6000.0, true, true)  # 100 min corriendo desde el maximo
	_check(float(l70.energia()) > 0.0,
		"B14 L70: correr 100 min NO agota (energia > 0) -> %.2f" % float(l70.energia()))
	_check(absf(float(l70.energia()) - 100.0) < 0.001,
		"B15 L70: correr 100 min mantiene ENERGIA_MAX -> %.2f" % float(l70.energia()))

	# Fatiga informativa al 30%.
	var f: RefCounted = ENERGY.new()
	f.restaurar(float(ENERGY.UMBRAL_FATIGA))
	_check(bool(f.en_fatiga()), "B16 en_fatiga() true en el umbral (30)")
	_check(bool(f.puede_correr()), "B17 en fatiga TODAVIA puede correr (informativo)")
	f.restaurar(float(ENERGY.UMBRAL_FATIGA) + 1.0)
	_check(not bool(f.en_fatiga()), "B18 fuera del umbral no hay fatiga")

	# Dormir / descansar.
	var s: RefCounted = ENERGY.new()
	s.restaurar(10.0)
	s.recargar_dormir()
	_check(absf(float(s.energia()) - 100.0) < 0.001, "B19 dormir recarga al 100%")
	s.restaurar(10.0)
	s.recargar_descanso()
	_check(absf(float(s.energia()) - 40.0) < 0.001,
		"B20 descanso recarga +30 (esperado 40.0): %.1f" % float(s.energia()))

	# Agotamiento por desgaste EXTERNO (herramientas): auto-descanso, sin muerte.
	var a: RefCounted = ENERGY.new()
	a.restaurar(0.0)
	_check(bool(a.agotada()), "B21 energia 0 (desgaste externo) -> agotada")
	_check(bool(a.descansando()), "B22 agotada -> auto-descanso (cozy, sin muerte)")
	_check(not bool(a.puede_correr()), "B23 agotada -> puede_correr() = false")

	# Clamp, recuperacion y no-deuda.
	var c: RefCounted = ENERGY.new()
	c.restaurar(150.0)
	_check(absf(float(c.energia()) - 100.0) < 0.001, "B24 restaurar clampea arriba a 100")
	c.restaurar(-5.0)
	_check(absf(float(c.energia()) - 0.0) < 0.001, "B25 restaurar clampea abajo a 0")
	c.actualizar(60.0, false, false)
	_check(float(c.energia()) > 0.0, "B26 se recupera al descansar (sin bloqueo permanente)")
	_check(bool(c.sin_deuda_permanente()), "B27 sin deuda permanente (valor absoluto)")

	# delta <= 0 no altera la energia.
	var z: RefCounted = ENERGY.new()
	z.restaurar(50.0)
	z.actualizar(0.0, true, true)
	_check(absf(float(z.energia()) - 50.0) < 0.001, "B28 delta<=0 no altera la energia")

	_fin("B")

## ── Bloque C: seleccion de personaje (I) ────────────────────────────

func _bloque_c_selector() -> void:
	var sel: RefCounted = SELECTOR.new()
	_check(sel != null, "C1 CharacterSelector instanciable")
	_check(int(sel.cantidad()) == 6, "C2 6 personajes base (%d)" % int(sel.cantidad()))
	var ids: PackedStringArray = sel.ids()
	_check(ids.size() == 6, "C3 ids() devuelve 6")
	_check(ids.has("char_01") and ids.has("char_06"), "C4 ids incluyen char_01..char_06")
	_check(str(sel.personaje_actual()) == "char_01", "C5 personaje inicial = char_01")
	_check(bool(sel.existe("char_03")), "C6 existe('char_03') = true")
	_check(not bool(sel.existe("char_99")), "C7 existe('char_99') = false")
	_check(bool(sel.seleccionar("char_03")), "C8 seleccionar id valido = true")
	_check(str(sel.personaje_actual()) == "char_03", "C9 seleccion aplicada")
	_check(not bool(sel.seleccionar("char_99")), "C10 seleccionar id invalido = false")
	_check(str(sel.personaje_actual()) == "char_03", "C11 seleccion invalida no cambia nada")
	_check((sel.desbloqueados() as PackedStringArray).size() == 6,
		"C12 los 6 desbloqueados desde el inicio (sin locks)")
	_check(bool(sel.todos_mismos_stats()), "C13 seleccion puramente visual (sin stats)")
	var d: Dictionary = sel.datos_actual()
	_check(str(d.get("nombre", "")) == "Luna", "C14 datos_actual().nombre coherente")
	_check(str(d.get("bioma", "")) != "", "C15 datos_actual() tiene bioma")
	var bloque: Dictionary = sel.serializar()
	_check(str(bloque.get("character_id", "")) == "char_03", "C16 serializar emite character_id")
	var s2: RefCounted = SELECTOR.new()
	_check(bool(s2.deserializar({"character_id": "char_05"})), "C17 deserializar id valido = true")
	_check(str(s2.personaje_actual()) == "char_05", "C18 deserializacion aplicada")
	_check(not bool(s2.deserializar({"character_id": "char_99"})), "C19 deserializar id invalido = false")
	_check(str(s2.personaje_actual()) == "char_05", "C20 id invalido no degrada la seleccion")

	_fin("C")

## ── Bloque D: contrato / observabilidad ─────────────────────────────

func _bloque_d_contrato() -> void:
	var fsm: RefCounted = FSM.new()
	var e: RefCounted = ENERGY.new()
	var sel: RefCounted = SELECTOR.new()
	_check(fsm != null and e != null and sel != null,
		"D1 los 3 modelos se instancian sin autoloads (puros)")
	_check(str(fsm.nombre_actual()) == "IDLE", "D2 FSM expone nombre legible (contrato HUD)")
	_check(float(e.fraccion()) >= 0.0 and float(e.fraccion()) <= 1.0,
		"D3 energia expone fraccion en [0,1] (contrato HUD)")
	_check(str(sel.personaje_actual()) != "", "D4 selector expone personaje_actual (contrato save)")
	# El modelo no entra en un estado imposible ni forzando la derivacion.
	var f3: RefCounted = FSM.new()
	f3.actualizar_desde({"en_agua": true, "sumergido": true, "aire_restante": 0.9})
	var ok_grafo := true
	for s in [{"durmiendo": true}, {"crafteando": true}, {"en_agua": true, "aire_restante": 0.05},
			{"en_suelo": false, "velocidad_y": 1.0}, {"en_suelo": false, "velocidad_y": -1.0},
			{"en_suelo": true, "magnitud_direccion": 1.0, "correr": true}]:
		var est := int(f3.actualizar_desde(s))
		if not (FSM.NOMBRES as Dictionary).has(est):
			ok_grafo = false
	_check(ok_grafo, "D5 ningun snapshot deriva a un estado inexistente")
	_check(int(fsm.cantidad_estados()) == (FSM.NOMBRES as Dictionary).size(),
		"D6 cantidad_estados coincide con la tabla de nombres")

	_fin("D")

## ── Suite principal ─────────────────────────────────────────────────

func _run() -> void:
	print("=== %s — suite del nucleo aditivo ===" % MODULO)
	_bloque_a_fsm()
	_bloque_b_energy()
	_bloque_c_selector()
	_bloque_d_contrato()
	_summary()
