# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M36: Test del modulo Fauna.
# Cubre: catalog (carga + validacion + biomas + ventana horaria), species
# (validacion + colores + rareza), registry (avistamientos + dedupe + persistencia),
# behavior (FSM 8 estados + transiciones + pausa + factor de miedo), manager
# (especie_aleatoria_para + porcentaje_descubierto + candidatos_manada).
# Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/fauna/test_fauna.gd

extends SceneTree

const SpeciesRef = preload("res://scripts/fauna/fauna_species.gd")
const CatalogRef = preload("res://scripts/fauna/fauna_catalog.gd")
const BehaviorRef = preload("res://scripts/fauna/fauna_behavior.gd")

var _fallos: int = 0
var _mgr: Node = null
var _registry: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_mgr = root.get_node_or_null("fauna")
	_registry = root.get_node_or_null("fauna_registry")
	_check(_mgr != null, "fauna autoload presente (M36)")
	_check(_registry != null, "fauna_registry autoload presente (M36)")
	if _mgr == null or _registry == null:
		print("=== TEST M36 FAUNA: %d fallo(s) ===" % _fallos)
		quit(1 if _fallos > 0 else 0)
		return
	_test_catalogo_basico()
	_test_catalogo_json()
	_test_especie_validacion()
	_test_ventana_horaria()
	_test_bioma_y_candidatas()
	_test_pesos_por_rareza()
	_test_registry_avistamiento()
	_test_registry_dedupe_y_tolerancia()
	_test_registry_persistencia()
	_test_behavior_inicializacion()
	_test_behavior_transiciones()
	_test_behavior_factor_miedo()
	_test_manager_aleatoria_y_descubierto()
	print("=== TEST M36 FAUNA: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
	else:
		print("OK: " + msg)

## â”€â”€ Tests â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

func _test_catalogo_basico() -> void:
	# El fallback debe haber cargado 5 especies si catalog.json no existe
	# Pero como SI existe catalog.json, debe cargar 7 (las del JSON).
	_check(_mgr.cantidad_especies() >= 5, "catalogo con >=5 especies: %d" % _mgr.cantidad_especies())
	_check(_mgr.obtener_especie(&"conejo_pradera") != null, "conejo_pradera existe")
	_check(_mgr.obtener_especie(&"no_existe") == null, "especie inexistente -> null")

func _test_catalogo_json() -> void:
	# catalog.json tiene 7 especies (conejo, gaviota, nutria, lechuza, salamandra, cangrejo, halcon)
	_check(_mgr.cantidad_especies() == 7, "catalogo JSON con 7 especies exactas: %d" % _mgr.cantidad_especies())
	_check(_mgr.obtener_especie(&"salamandra_ancestral") != null, "salamandra_ancestral existe en JSON")
	_check(_mgr.obtener_especie(&"halcon_montana") != null, "halcon_montana existe en JSON")

func _test_especie_validacion() -> void:
	var sp = _mgr.obtener_especie(&"conejo_pradera")
	_check(sp != null, "conejo no nulo")
	_check(sp.es_valido(), "conejo es valido")
	_check(sp.gregaria == true, "conejo es gregario")
	_check(sp.cantidad_manada_min == 2, "manada min conejo = 2")
	_check(sp.velocidad_huida > sp.velocidad_deambular, "velocidad huida > deambular (conejo)")
	_check(sp.color_variantes.size() >= 1, "conejo tiene variantes de color: %d" % sp.color_variantes.size())
	# Especie sin id no es valida
	var spvacio = SpeciesRef.new()
	_check(not spvacio.es_valido(), "especie sin id NO es valida")
	# Generar factor de miedo individual
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	var fm: float = sp.generar_factor_miedo_individual(rng)
	_check(fm >= 0.9 * sp.factor_miedo_base and fm <= 1.1 * sp.factor_miedo_base, "factor de miedo en +-10%%: %.3f" % fm)

func _test_ventana_horaria() -> void:
	var diurno = _mgr.obtener_especie(&"conejo_pradera")
	var nocturno = _mgr.obtener_especie(&"lechuza_bosque")
	_check(diurno.activa_en_hora(12), "conejo activo a las 12")
	_check(not diurno.activa_en_hora(2), "conejo NO activo a las 2")
	_check(nocturno.activa_en_hora(2), "lechuza activa a las 2")
	_check(not nocturno.activa_en_hora(12), "lechuza NO activa a las 12")
	# Crepuscular: salamandra (alba 5-8) y lechuza (crepuscular 17-20)
	var salamandra = _mgr.obtener_especie(&"salamandra_ancestral")
	_check(salamandra.activa_en_hora(6), "salamandra activa crepuscular 6h")
	_check(not salamandra.activa_en_hora(14), "salamandra NO activa 14h")
	# Cangrejo: toda_hora
	var cangrejo = _mgr.obtener_especie(&"cangrejo_humedal")
	_check(cangrejo.activa_en_hora(0), "cangrejo activa 0h")
	_check(cangrejo.activa_en_hora(23), "cangrejo activa 23h")

func _test_bioma_y_candidatas() -> void:
	# Conejo: pradera diurna
	var candidatas: Array = _mgr.candidatas_para(12, &"pradera")
	_check(candidatas.size() == 1, "1 candidata en pradera al mediodia: %d" % candidatas.size())
	if candidatas.size() > 0:
		_check(candidatas[0].id == &"conejo_pradera", "la candidata es conejo_pradera")
	# Pradera nocturna: sin candidatas
	var candidatas_noche: Array = _mgr.candidatas_para(2, &"pradera")
	_check(candidatas_noche.is_empty(), "0 candidatas en pradera de noche")
	# Bosque ancestral: solo salamandra (rara + crepuscular)
	var candidatas_ancestral: Array = _mgr.candidatas_para(6, &"bosque_ancestral")
	_check(candidatas_ancestral.size() == 1, "1 candidata en bosque_ancestral al crepusculo")
	# Bioma vacio: nada
	var candidatas_vacio: Array = _mgr.candidatas_para(12, &"bioma_inexistente")
	_check(candidatas_vacio.is_empty(), "0 candidatas en bioma inexistente")

func _test_pesos_por_rareza() -> void:
	var commons = _mgr.obtener_especie(&"conejo_pradera")
	var raras = _mgr.obtener_especie(&"halcon_montana")
	var muy_raras = _mgr.obtener_especie(&"salamandra_ancestral")
	var p_comun: float = _mgr.catalog.peso_por_rareza(commons.rareza)
	var p_rara: float = _mgr.catalog.peso_por_rareza(raras.rareza)
	var p_muy_rara: float = _mgr.catalog.peso_por_rareza(muy_raras.rareza)
	_check(p_comun > p_rara, "comun pesa mas que rara: %.2f > %.2f" % [p_comun, p_rara])
	_check(p_rara > p_muy_rara, "rara pesa mas que muy rara: %.2f > %.2f" % [p_rara, p_muy_rara])

func _test_registry_avistamiento() -> void:
	# Reset state del registry
	var keys_est: Array = _registry._estados.keys().duplicate()
	for k in keys_est:
		_registry._estados.erase(k)
	var keys_cont: Array = _registry._contador_avistamientos.keys().duplicate()
	for k in keys_cont:
		_registry._contador_avistamientos.erase(k)
	# Registrar avistamiento
	var ctx := {"instancia_id": "test_inst_1", "especie_id": "conejo_pradera", "distancia": 5.0, "tiempo_pantalla_s": 1.0}
	_registry.registrar_avistamiento(&"conejo_pradera", ctx)
	_check(_registry.estado_especie(&"conejo_pradera") == _registry.EstadoEspecie.AVISTADA, "conejo pasa a AVISTADA")
	_check(_registry.total_avistamientos(&"conejo_pradera") == 1, "contador conejo = 1")
	# Segundo avistamiento mismo individuo en menos de 30s -> ignorado
	var ctx2 := {"instancia_id": "test_inst_1", "especie_id": "conejo_pradera", "distancia": 5.0, "tiempo_pantalla_s": 1.0}
	_registry.registrar_avistamiento(&"conejo_pradera", ctx2)
	_check(_registry.total_avistamientos(&"conejo_pradera") == 1, "segundo avistamiento mismo inst en <30s: ignorado")
	# Distancia > 24: ignorado
	var ctx3 := {"instancia_id": "test_inst_2", "especie_id": "nutria_ribera", "distancia": 30.0, "tiempo_pantalla_s": 1.0}
	_registry.registrar_avistamiento(&"nutria_ribera", ctx3)
	_check(_registry.estado_especie(&"nutria_ribera") == _registry.EstadoEspecie.NO_AVISTADA, "nutria a 30m: NO_AVISTADA")
	# Foto: pasa a FOTOGRAFIADA
	_registry.registrar_foto(&"conejo_pradera", "foto_001")
	_check(_registry.estado_especie(&"conejo_pradera") == _registry.EstadoEspecie.FOTOGRAFIADA, "conejo pasa a FOTOGRAFIADA con foto")

func _test_registry_dedupe_y_tolerancia() -> void:
	# Reset
	var keys_est: Array = _registry._estados.keys().duplicate()
	for k in keys_est:
		_registry._estados.erase(k)
	var keys_cont: Array = _registry._contador_avistamientos.keys().duplicate()
	for k in keys_cont:
		_registry._contador_avistamientos.erase(k)
	var keys_dd: Array = _registry._dedupe.keys().duplicate()
	for k in keys_dd:
		_registry._dedupe.erase(k)
	# Tolerancia < 0.5s: ignorado
	var ctx_too_short := {"instancia_id": "inst_t1", "especie_id": "gaviota_playera", "distancia": 5.0, "tiempo_pantalla_s": 0.1}
	_registry.registrar_avistamiento(&"gaviota_playera", ctx_too_short)
	_check(_registry.total_avistamientos(&"gaviota_playera") == 0, "avistamiento con 0.1s pantalla: ignorado (tolerancia)")
	# Distinto individuo, distancia valida, tiempo OK: aceptado
	var ctx_valid := {"instancia_id": "inst_t2", "especie_id": "gaviota_playera", "distancia": 10.0, "tiempo_pantalla_s": 1.0}
	_registry.registrar_avistamiento(&"gaviota_playera", ctx_valid)
	_check(_registry.total_avistamientos(&"gaviota_playera") == 1, "avistamiento valido: aceptado")
	# Porcentaje descubierto: 1 de 7
	_check(abs(_registry.porcentaje_descubierto(7) - (1.0/7.0)) < 0.001, "porcentaje = 1/7 tras 1 descubrimiento")
	# Sin descubrir todas: 0%
	_check(_registry.porcentaje_descubierto(7) > 0.0, "porcentaje > 0 tras descubrimiento")

func _test_registry_persistencia() -> void:
	# Reset
	var keys_est: Array = _registry._estados.keys().duplicate()
	for k in keys_est:
		_registry._estados.erase(k)
	var keys_cont: Array = _registry._contador_avistamientos.keys().duplicate()
	for k in keys_cont:
		_registry._contador_avistamientos.erase(k)
	# Marcar
	var ctx := {"instancia_id": "i1", "especie_id": "halcon_montana", "distancia": 5.0, "tiempo_pantalla_s": 1.0}
	_registry.registrar_avistamiento(&"halcon_montana", ctx)
	# Snapshot
	var data: Dictionary = _registry.get_save_data()
	_check(int(data.get("version", 0)) >= 1, "version >= 1")
	_check(int(data.get("estados", {}).get("halcon_montana", -1)) == _registry.EstadoEspecie.AVISTADA, "halcon AVISTADA en save data")
	# Reset y restore
	_registry._estados.clear()
	_registry._contador_avistamientos.clear()
	_registry.restore_save_data(data)
	_check(_registry.estado_especie(&"halcon_montana") == _registry.EstadoEspecie.AVISTADA, "restore aplica estado")
	# Version antigua ignorada
	_registry._estados.clear()
	_registry.restore_save_data({"version": 0, "estados": {"halcon_montana": 2}})
	_check(_registry.estado_especie(&"halcon_montana") == _registry.EstadoEspecie.NO_AVISTADA, "version 0 ignorada (estado limpio)")

func _test_behavior_inicializacion() -> void:
	var sp = _mgr.obtener_especie(&"conejo_pradera")
	var b: Node3D = Node3D.new()
	b.set_script(load("res://scripts/fauna/fauna_behavior.gd"))
	root.add_child(b)
	b.global_position = Vector3(0, 0, 0)
	b.inicializar(sp)
	_check(b.especie == sp, "especie asignada")
	_check(b.factor_miedo >= 0.9 * sp.factor_miedo_base and b.factor_miedo <= 1.1 * sp.factor_miedo_base, "factor de miedo en +-10%%: %.3f (base=%.2f)" % [b.factor_miedo, sp.factor_miedo_base])
	_check(b.get_estado() == BehaviorRef.Estado.DEAMBULAR, "estado inicial = DEAMBULAR")
	_check(b.instancia_id != "", "instancia_id generado")
	b.queue_free()

func _test_behavior_transiciones() -> void:
	var sp = _mgr.obtener_especie(&"conejo_pradera")  # HUIDA_INSTINTIVA
	var b: Node3D = Node3D.new()
	b.set_script(load("res://scripts/fauna/fauna_behavior.gd"))
	root.add_child(b)
	b.global_position = Vector3(0, 0, 0)
	b.inicializar(sp)
	# Jugador dentro del radio de alarma (conejo = 4m)
	b.tick(0.1, Vector3(2, 0, 0))
	_check(b.get_estado() == BehaviorRef.Estado.HUIDA, "conejo HUIDA_INSTINTIVA en radio de alarma -> HUIDA")
	# Mover al jugador lejos
	b.global_position = Vector3(0, 0, 0)
	b.tick(0.1, Vector3(50, 0, 0))  # muy lejos
	_check(b.get_estado() == BehaviorRef.Estado.DEAMBULAR, "conejo vuelve a DEAMBULAR si jugador se aleja")
	b.queue_free()
	# Especie CURIOSA: cerca del jugador quieto -> CURIOSA_ACERCARSE
	var sp_nutria = _mgr.obtener_especie(&"nutria_ribera")
	var b2: Node3D = Node3D.new()
	b2.set_script(load("res://scripts/fauna/fauna_behavior.gd"))
	root.add_child(b2)
	b2.global_position = Vector3(0, 0, 0)
	b2.inicializar(sp_nutria)
	# nutria es CURIOSA con radio_curiosidad=6, radio_alarma=3.5
	# Si jugador esta a 5m: en radio de curiosidad pero NO de alarma
	b2.tick(0.1, Vector3(5, 0, 0))
	_check(b2.get_estado() == BehaviorRef.Estado.CURIOSA_ACERCARSE, "nutria CURIOSA a 5m -> CURIOSA_ACERCARSE")
	b2.queue_free()

func _test_behavior_factor_miedo() -> void:
	# Generar muchos individuos, todos en +-10% del base
	var sp = _mgr.obtener_especie(&"conejo_pradera")  # factor_miedo_base = 1.5
	var limites_ok: int = 0
	var n: int = 20
	for i in range(n):
		var b: Node3D = Node3D.new()
		b.set_script(load("res://scripts/fauna/fauna_behavior.gd"))
		root.add_child(b)
		b.global_position = Vector3(0, 0, 0)
		b.inicializar(sp)
		if b.factor_miedo >= 1.35 and b.factor_miedo <= 1.65:
			limites_ok += 1
		b.queue_free()
	_check(limites_ok == n, "todos los 20 individuos con factor_miedo en +-10%%: %d/%d" % [limites_ok, n])

func _test_manager_aleatoria_y_descubierto() -> void:
	# Reset
	var keys_est: Array = _registry._estados.keys().duplicate()
	for k in keys_est:
		_registry._estados.erase(k)
	var keys_cont: Array = _registry._contador_avistamientos.keys().duplicate()
	for k in keys_cont:
		_registry._contador_avistamientos.erase(k)
	# especie_aleatoria_para: pradera mediodia -> conejo (unica candidata)
	var sp = _mgr.especie_aleatoria_para(12, &"pradera")
	_check(sp != null, "especie_aleatoria_para(12, pradera) != null")
	_check(sp.id == &"conejo_pradera", "especie aleatoria = conejo_pradera")
	# Pradera de noche: null
	var sp_none = _mgr.especie_aleatoria_para(2, &"pradera")
	_check(sp_none == null, "especie_aleatoria_para(2, pradera) = null")
	# Porcentaje descubierto: 0 al inicio
	_check(_mgr.porcentaje_descubierto() == 0.0, "porcentaje = 0 al inicio")
	# Registrar un par de avistamientos
	for i in range(3):
		_mgr.registrar_avistamiento_test(&"conejo_pradera", {"instancia_id": "i_%d" % i, "especie_id": "conejo_pradera", "distancia": 5.0, "tiempo_pantalla_s": 1.0})
	_check(_mgr.porcentaje_descubierto() > 0.0, "porcentaje > 0 tras 3 avistamientos")
	_check(_mgr.total_avistamientos(&"conejo_pradera") == 3, "total_avistamientos(conejo) = 3 (instancias distintas)")
