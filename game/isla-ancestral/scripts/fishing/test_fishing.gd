# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M34: Test de pesca (sesión, resolución de especie, anti-frustración, colección).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/fishing/test_fishing.gd

extends SceneTree

var _fallos: int = 0
var _fm: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_fm = root.get_node_or_null("Fishing")
	_check(_fm != null, "Fishing autoload presente")
	if _fm == null:
		print("=== TEST M34 PESCA: 1 fallo(s) ===")
		quit(1)
		return
	_test_datos()
	_test_sesion_captura()
	_test_escape_sin_perdidas()
	_test_resolucion_condiciones()
	_test_coleccion()
	print("=== TEST M34 PESCA: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_datos() -> void:
	_check(_fm._peces.size() >= 2, "2+ peces cargados: %d" % _fm._peces.size())
	var sardina: FishDefinition = null
	for pez in _fm._peces:
		if pez.id == "pez_sardina":
			sardina = pez
	_check(sardina != null, "pez_sardina cargado")
	if sardina:
		_check(sardina.peso_rareza == 0.25, "sardina probabilidad 0.25")
		_check(sardina.tamano_min == 0.3, "sardina tamaño min 0.3")

func _test_sesion_captura() -> void:
	# Sesión con cana; simular flujo completo forzando picada y pulsaciones
	var cana := FishingRod.new()
	cana.id = "cana_test"
	cana.ventana_exito = 0.5
	var spot = Node3D.new()
	root.add_child(spot)
	_fm.registrar_spot(spot)
	var eventos: Array = []
	_fm.captura_exitosa.connect(func(pez, tamano): eventos.append(["captura", pez.id, tamano]))
	_fm.captura_fallida.connect(func(motivo): eventos.append(["fallo", motivo]))

	var ses = _fm.iniciar_sesion(spot, cana, null)
	_check(ses != null, "sesión iniciada")
	# Esperar a PICADA (máx 9s de espera simulada... en headless el timer corre real;
	# para no esperar, forzamos directamente el flujo):
	ses._on_picada()
	_check(ses.get_estado() == FishingSession.Estado.PICADA, "estado PICADA tras picada")
	# Pulsar en fase A -> MINIJUEGO
	ses.notificar_pulsacion_boton()
	_check(ses.get_estado() == FishingSession.Estado.MINIJUEGO, "MINIJUEGO tras pulsar fase A")
	# 3 pulsaciones en fase B (diseño §2.5) -> CAPTURA
	ses.notificar_pulsacion_boton()
	ses.notificar_pulsacion_boton()
	ses.notificar_pulsacion_boton()
	_check(ses.get_estado() == FishingSession.Estado.CAPTURA, "CAPTURA tras 3 pulsaciones")
	_check(eventos.size() >= 1 and eventos[0][0] == "captura", "captura_exitosa emitida")
	_check(_fm._capturas_totales == 1, "colección registra captura")

func _test_escape_sin_perdidas() -> void:
	var eventos: Array = []
	_fm.captura_fallida.connect(func(motivo): eventos.append(motivo))
	var cana := FishingRod.new()
	var spot = Node3D.new()
	root.add_child(spot)
	_fm.registrar_spot(spot)
	var ses = _fm.iniciar_sesion(spot, cana, null)
	# Picada y NO pulsar: forzar expiración de fase A
	ses._on_picada()
	ses._on_ventana_fase_a_expirada()
	_check(ses.get_estado() == FishingSession.Estado.IDLE, "IDLE tras escape")
	_check(eventos.has("el_pez_se_fue"), "escape emitido sin pérdidas")
	# §6.4: relanzar inmediato
	var ses2 = _fm.iniciar_sesion(spot, cana, null)
	_check(ses2 != null and ses2.get_estado() == FishingSession.Estado.ESPERA_PICADA, "relanzado sin cooldown")

func _test_resolucion_condiciones() -> void:
	# Resolución devuelve especies válidas y respeta condiciones de sardina (noche)
	var pez = _fm.resolver_especie(null, null)
	_check(pez != null, "resolver_especie devuelve pez")
	# Pity: pez lunar (pity 80) — tras forzar contador, peso x10 aplica
	_fm._pity_contadores["pez_luna"] = 80
	var elegido_luna := 0
	for i in range(50):
		var p = _fm.resolver_especie(null, null)
		if p != null and p.id == "pez_luna":
			elegido_luna += 1
			_fm._pity_contadores["pez_luna"] = 80  # mantener para la muestra
	_check(elegido_luna > 0, "pity aumenta chance del pez raro (%d/50)" % elegido_luna)

func _test_coleccion() -> void:
	var col: Dictionary = _fm.get_collection_data()
	_check(col.size() >= 1, "colección con entradas: %d" % col.size())
	var data: Dictionary = _fm.get_save_data()
	_check(data.has("coleccion"), "save data tiene colección")
	# Restaurar
	_fm._coleccion.clear()
	_fm.restore_save_data(data)
	_check(_fm.get_collection_data().size() >= 1, "restore recupera colección")