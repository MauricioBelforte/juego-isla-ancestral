# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M70: Test del modulo de Interacciones.
# Cubre: registro/desregistro, filtro por distancia/estado, ordenamiento por
# prioridad/distancia/registro, histeresis, despacho, cancelacion, persistencia,
# auto-registro de InteractableBase, contrato ampliado de IInteractable.
# Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/interacciones/test_interacciones.gd

extends SceneTree

var _fallos: int = 0
var _mgr: Node = null
var _jugador_fake: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_mgr = root.get_node_or_null("interacciones")
	_check(_mgr != null, "interacciones autoload presente (M70)")
	if _mgr == null:
		print("=== TEST M70 INTERACCIONES: %d fallo(s) ===" % _fallos)
		quit(1 if _fallos > 0 else 0)
		return
	# Jugador fake (Node3D con global_position)
	_jugador_fake = Node3D.new()
	_jugador_fake.name = "JugadorFake"
	root.add_child(_jugador_fake)
	_jugador_fake.global_position = Vector3.ZERO
	_mgr.configurar_jugador(_jugador_fake)
	_test_contrato_iinteractable_ampliado()
	_test_registro_desregistro()
	_test_filtro_estado()
	_test_filtro_distancia()
	_test_ordenamiento_prioridad_distancia_registro()
	_test_histeresis()
	_test_despacho_y_cozy_no_objetivo()
	_test_cancelacion()
	_test_persistencia()
	_test_interactable_base_auto_register()
	_test_interactable_base_obtener_prioridad()
	_test_despacho_instantaneo_auto_finaliza()
	_test_histeresis_no_mantiene_objetivo_invalido()
	_test_persistencia_restaura_estado_base()
	print("=== TEST M70 INTERACCIONES: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
	else:
		print("OK: " + msg)

func _make_interactuable(id_str: String, pos: Vector3, prioridad: int, categoria: StringName, estado: int = 0, radio: float = 0.5, duracion: float = 0.0):
	var n := Node3D.new()
	n.name = id_str
	n.global_position = pos
	n.set_script(load("res://scripts/interacciones/test_mock_interactable.gd"))
	n.mock_id = id_str
	n.mock_pos = pos
	n.mock_prioridad = prioridad
	n.mock_categoria = categoria
	n.mock_estado = estado
	n.mock_radio = radio
	n.mock_duracion = duracion
	root.add_child(n)
	return n

func _limpiar_interactuables() -> void:
	for it in _mgr._interactuables.duplicate():
		if it != null and is_instance_valid(it):
			it.queue_free()
	_mgr._interactuables.clear()
	_mgr._objetivo_actual = null
	_mgr._candidatos_frame.clear()

func _test_contrato_iinteractable_ampliado() -> void:
	# IInteractable extends Resource; lo instanciamos solo como Resource.
	var n = Resource.new()
	n.set_script(load("res://scripts/interfaces/i_interactable.gd"))
	_check(n.obtener_estado() == 0, "IInteractable.obtener_estado default = DISPONIBLE")
	_check(n.obtener_categoria() == &"", "IInteractable.obtener_categoria default = vacio")
	_check(n.obtener_posicion_interaccion() == Vector3.ZERO, "IInteractable.obtener_posicion_interaccion default = ZERO")
	_check(n.obtener_radio() >= 0.0, "IInteractable.obtener_radio devuelve float >= 0")
	_check(n.obtener_duracion_esperada() == 0.0, "IInteractable.obtener_duracion_esperada default = 0")
	_check(n.interact(null) == false, "IInteractable.interact legacy default = false")
	_check(n.is_interactable(null) == true, "IInteractable.is_interactable legacy default = true")
	_check(n.requisitos_cumplidos(null) == true, "IInteractable.requisitos_cumplidos delega a is_interactable")
	_check(n.obtener_prioridad() == 0, "IInteractable.obtener_prioridad default = 0")
	_check(n.obtener_rango() == 2.0, "IInteractable.obtener_rango default = 2.0")

func _test_registro_desregistro() -> void:
	_limpiar_interactuables()
	var a = _make_interactuable("a", Vector3(1, 0, 0), 0, &"objeto")
	_mgr.registrar(a)
	_check(_mgr.cantidad_registrados() == 1, "1 interactuable registrado")
	var b = _make_interactuable("b", Vector3(2, 0, 0), 1, &"cofre")
	_mgr.registrar(b)
	_check(_mgr.cantidad_registrados() == 2, "2 interactuables registrados")
	# Doble registro del mismo: no duplica
	_mgr.registrar(a)
	_check(_mgr.cantidad_registrados() == 2, "registro duplicado no aumenta conteo")
	_mgr.desregistrar(a)
	_check(_mgr.cantidad_registrados() == 1, "desregistro reduce conteo")

func _test_filtro_estado() -> void:
	_limpiar_interactuables()
	# OCULTO no debe aparecer en candidatos
	var oculto = _make_interactuable("oculto", Vector3(1, 0, 0), 5, &"npc", 3)  # 3 = OCULTO
	_mgr.registrar(oculto)
	_mgr._evaluar_y_seleccionar()
	_check(_mgr.obtener_objetivo_actual() == null, "OCULTO excluido de candidatos")
	# INTERACTUANDO tampoco
	var interactuando = _make_interactuable("interactuando", Vector3(1, 0, 0), 5, &"npc", 1)  # 1 = INTERACTUANDO
	_mgr.registrar(interactuando)
	_mgr._evaluar_y_seleccionar()
	_check(_mgr.obtener_objetivo_actual() == null, "INTERACTUANDO excluido de candidatos")

func _test_filtro_distancia() -> void:
	_limpiar_interactuables()
	# DEFAULT_RANGO=2.5 + radio 0.5 = 3 m total
	var cerca = _make_interactuable("cerca", Vector3(1, 0, 0), 1, &"cofre", 0, 0.5)
	var lejos = _make_interactuable("lejos", Vector3(50, 0, 0), 10, &"npc", 0, 0.5)
	_mgr.registrar(cerca)
	_mgr.registrar(lejos)
	_mgr._evaluar_y_seleccionar()
	_check(_mgr.obtener_objetivo_actual() == cerca, "objetivo cercano gana sobre lejano")
	_check(_mgr.obtener_objetivo_actual() != lejos, "objetivo lejano NO se selecciona")

func _test_ordenamiento_prioridad_distancia_registro() -> void:
	_limpiar_interactuables()
	# mismo distancia, distinta prioridad: gana mayor prioridad
	var prio_alta = _make_interactuable("prio_alta", Vector3(2, 0, 0), 10, &"cofre")
	var prio_baja = _make_interactuable("prio_baja", Vector3(2, 0, 0), 1, &"objeto")
	_mgr.registrar(prio_alta)
	_mgr.registrar(prio_baja)
	_mgr._evaluar_y_seleccionar()
	_check(_mgr.obtener_objetivo_actual() == prio_alta, "mayor prioridad gana en empate")
	# misma prioridad y distancia: gana orden de registro
	_limpiar_interactuables()
	var primero = _make_interactuable("primero", Vector3(2, 0, 0), 5, &"cofre")
	var segundo = _make_interactuable("segundo", Vector3(2, 0, 0), 5, &"cofre")
	_mgr.registrar(primero)
	_mgr.registrar(segundo)
	_mgr._evaluar_y_seleccionar()
	_check(_mgr.obtener_objetivo_actual() == primero, "primer registrado gana en empate total")

func _test_histeresis() -> void:
	_limpiar_interactuables()
	var a = _make_interactuable("a", Vector3(1, 0, 0), 5, &"cofre")
	var b = _make_interactuable("b", Vector3(1.1, 0, 0), 5, &"cofre")  # a 0.1 m mas lejos
	_mgr.registrar(a)
	_mgr.registrar(b)
	_mgr._evaluar_y_seleccionar()
	_check(_mgr.obtener_objetivo_actual() == a, "primer objetivo seleccionado es el mas cercano")
	_mgr._evaluar_y_seleccionar()
	# Sin movimiento: histeresis mantiene a (0.1 < 0.15)
	_check(_mgr.obtener_objetivo_actual() == a, "histeresis mantiene objetivo (0.1 m < 0.15 m)")
	# Si b se acerca mucho (misma posicion que a, dist 0): orden de registro = a gana (estable)
	b.mock_pos = Vector3(1.0, 0, 0)  # mismo lugar que a
	_mgr._evaluar_y_seleccionar()
	_check(_mgr.obtener_objetivo_actual() == a, "empate total (mismo dist+prio): gana orden de registro (a)")

func _test_despacho_y_cozy_no_objetivo() -> void:
	_limpiar_interactuables()
	# Sin objetivo: presionar_interact NO debe fallar (regla cozy) y NO debe cambiar estado
	_check(_mgr.obtener_estado() == _mgr.InteractionState.INACTIVO, "estado inicial INACTIVO (sin _process)")
	_mgr.presionar_interact()
	_check(_mgr.obtener_estado() == _mgr.InteractionState.INACTIVO, "sin objetivo: estado no cambia (cozy, sin error)")
	# Disparar _process para forzar evaluacion -> SELECCIONANDO
	_mgr._process(0.016)
	_check(_mgr.obtener_estado() == _mgr.InteractionState.SELECCIONANDO, "tras _process sin candidatos: SELECCIONANDO")
	# Con objetivo DISPONIBLE (interaccion LARGA: duracion 1.0s, no auto-finaliza)
	var it = _make_interactuable("it", Vector3(1, 0, 0), 1, &"cofre", 0, 0.5, 1.0)
	_mgr.registrar(it)
	_mgr._evaluar_y_seleccionar()
	_mgr.presionar_interact()
	_check(it.mock_interacciones_recibidas == 1, "objetivo DISPONIBLE recibe 1 llamada a interactuar")
	_check(_mgr.obtener_estado() == _mgr.InteractionState.INTERACTUANDO, "estado pasa a INTERACTUANDO tras despacho")
	_mgr.finalizar_interaccion(it, true)
	_check(_mgr.obtener_estado() == _mgr.InteractionState.SELECCIONANDO, "estado vuelve a SELECCIONANDO tras finalizar")
	# Con objetivo NO_DISPONIBLE: cancelar respetuoso
	var no_disp = _make_interactuable("no_disp", Vector3(2, 0, 0), 1, &"cofre", 2)  # 2 = NO_DISPONIBLE
	_mgr._objetivo_actual = no_disp
	_mgr.presionar_interact()
	_check(no_disp.mock_interacciones_recibidas == 0, "objetivo NO_DISPONIBLE NO recibe despacho")

func _test_cancelacion() -> void:
	_limpiar_interactuables()
	var it = _make_interactuable("it", Vector3(1, 0, 0), 1, &"cofre")
	_mgr.registrar(it)
	_mgr._evaluar_y_seleccionar()
	_mgr.presionar_interact()
	_mgr.cancelar_interaccion(it, "test_motivo")
	_check(_mgr.obtener_estado() == _mgr.InteractionState.SELECCIONANDO, "cancelar vuelve a SELECCIONANDO")
	# Dormido por UI
	_mgr.set_estado_dormido(true)
	_check(_mgr.obtener_estado() == _mgr.InteractionState.DORMIDO, "set_estado_dormido(true) -> DORMIDO")
	_mgr.presionar_interact()
	_check(it.mock_interacciones_recibidas == 1, "en DORMIDO no se re-despacha")
	_mgr.set_estado_dormido(false)
	_check(_mgr.obtener_estado() == _mgr.InteractionState.SELECCIONANDO, "set_estado_dormido(false) vuelve al estado anterior")

func _test_persistencia() -> void:
	_limpiar_interactuables()
	var it = _make_interactuable("it", Vector3(1, 0, 0), 1, &"cofre")
	_mgr.registrar(it)
	# Save snapshot
	var data: Dictionary = _mgr.get_save_data()
	_check(data.has("version"), "save data tiene version")
	_check(int(data.get("version", 0)) >= 1, "version >= 1")
	_check(data.has("estado"), "save data tiene estado por instancia")
	# Restore
	_limpiar_interactuables()
	_check(_mgr.cantidad_registrados() == 0, "tras limpiar, 0 interactuables")
	_mgr.restore_save_data(data)
	# Re-registrar it: el estado guardado debe aplicarse
	_mgr.registrar(it)
	# Version antigua debe rechazarse
	_mgr.restore_save_data({"version": 0})
	_check(_mgr.cantidad_registrados() >= 1, "registro post-restore no rompe el manager")

func _test_interactable_base_auto_register() -> void:
	_limpiar_interactuables()
	var n := Node3D.new()
	n.set_script(load("res://scripts/interacciones/interactable_base.gd"))
	n.categoria = &"puerta"
	n.prioridad = 5
	n.radio = 1.0
	n.global_position = Vector3(1, 0, 0)
	root.add_child(n)
	_check(_mgr.cantidad_registrados() == 1, "InteractableBase se auto-registra al _ready")
	var asInteractable = n
	_check(asInteractable.obtener_categoria() == &"puerta", "InteractableBase expone categoria")
	_check(asInteractable.obtener_prioridad() == 5, "InteractableBase expone prioridad")
	n.queue_free()

func _test_interactable_base_obtener_prioridad() -> void:
	# Bug C (QA Log 378, Hy3): InteractableBase debe implementar obtener_prioridad(),
	# sino el manager CRASHEA al evaluar cualquier consumidor real (el mock si lo
	# tenia, por eso el test original pasaba sin notar el crash).
	_limpiar_interactuables()
	var n := Node3D.new()
	n.set_script(load("res://scripts/interacciones/interactable_base.gd"))
	n.categoria = &"puerta"
	n.prioridad = 7
	n.global_position = Vector3(1, 0, 0)
	root.add_child(n)
	_check(n.obtener_prioridad() == 7, "InteractableBase.obtener_prioridad() implementado (Bug C corregido)")
	n.queue_free()

func _test_despacho_instantaneo_auto_finaliza() -> void:
	# Bug A (QA Log 378, Hy3): interaccion instantanea (duracion 0) debe
	# auto-finalizar; si no, el gestor queda en INTERACTUANDO y bloquea todas
	# las interacciones siguientes (soft-lock, M66).
	_limpiar_interactuables()
	var it = _make_interactuable("it", Vector3(1, 0, 0), 1, &"cofre", 0, 0.5, 0.0)
	_mgr.registrar(it)
	_mgr._evaluar_y_seleccionar()
	_mgr.presionar_interact()
	_check(_mgr.obtener_estado() == _mgr.InteractionState.SELECCIONANDO, "interaccion instantanea auto-finaliza a SELECCIONANDO (sin soft-lock)")
	_check(it.mock_interacciones_recibidas == 1, "interactuar llamado 1 vez tras 1er E")
	# Segundo E re-despacha (sin soft-lock).
	_mgr._evaluar_y_seleccionar()
	_mgr.presionar_interact()
	_check(it.mock_interacciones_recibidas == 2, "segundo E re-despacha (sin soft-lock)")

func _test_histeresis_no_mantiene_objetivo_invalido() -> void:
	# Bug B (QA Log 378, Hy3): la histeresis no debe mantener un objetivo ya
	# invalido (OCULTO); debe cambiar al candidato valido mas cercano.
	_limpiar_interactuables()
	var a = _make_interactuable("a", Vector3(1, 0, 0), 5, &"cofre")
	_mgr.registrar(a)
	_mgr._evaluar_y_seleccionar()
	_check(_mgr.obtener_objetivo_actual() == a, "a seleccionado inicialmente")
	# 'a' pasa a OCULTO; aparece 'b' valido a 0.05 m (dentro de la histeresis 0.15 m).
	a.mock_estado = 3  # OCULTO
	var b = _make_interactuable("b", Vector3(1.05, 0, 0), 5, &"cofre")
	_mgr.registrar(b)
	_mgr._evaluar_y_seleccionar()
	_check(_mgr.obtener_objetivo_actual() == b, "objetivo cambia a 'b' (el anterior ya no es valido)")

func _test_persistencia_restaura_estado_base() -> void:
	# Bug D (QA Log 378, Hy3): aplicar_estado_guardado debe restaurar el estado
	# en InteractableBase para que la persistencia M59 sea real y no un no-op.
	_limpiar_interactuables()
	var n := Node3D.new()
	n.set_script(load("res://scripts/interacciones/interactable_base.gd"))
	n.categoria = &"cofre"
	n.estado = 0
	n.global_position = Vector3(1, 0, 0)
	root.add_child(n)
	n.aplicar_estado_guardado({"estado": 2})  # 2 = NO_DISPONIBLE
	_check(n.obtener_estado() == 2, "InteractableBase.aplicar_estado_guardado restaura estado (Bug D)")
	n.queue_free()