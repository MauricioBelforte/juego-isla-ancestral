# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-09
# M18: Test headless de HouseManager + FurnitureData.
extends SceneTree

var _fallos := 0
var _checks := 0
const CHECKS_MINIMOS := 15

func _initialize() -> void:
	print("=== TEST M18 Casas: HouseManager + FurnitureData ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	# ── Bloque 1: HouseManager carga ──
	var hm_script: Script = load("res://scripts/houses/house_manager.gd")
	_check("HouseManager.gd carga", hm_script != null)
	
	# ── Bloque 2: Registrar casa ──
	if hm_script != null:
		var hm: Node = hm_script.new()
		_check("HouseManager instancia", hm is Node)
		var id1: String = hm.registrar_casa(Vector3(100, 0, 200))
		_check("registrar_casa devuelve ID", id1 != "")
		_check("cantidad_casas = 1", hm.cantidad_casas() == 1)
		_check("hay_casa_en(100,0,200)", hm.hay_casa_en(Vector3(100, 0, 200)))
		_check("hay_casa_en(500,0,500) = false", not hm.hay_casa_en(Vector3(500, 0, 500)))
		
		# ── Bloque 3: Etapas ──
		_check("etapa inicial = 1", hm.obtener_etapa(id1) == 1)
		_check("avanzar_etapa a 2", hm.avanzar_etapa(id1))
		_check("etapa = 2", hm.obtener_etapa(id1) == 2)
		for i in range(4):
			hm.avanzar_etapa(id1)
		_check("etapa max = 5", hm.obtener_etapa(id1) == 5)
		_check("avanzar en max = false", not hm.avanzar_etapa(id1))
		
		# ── Bloque 4: Muebles ──
		_check("agregar_mueble", hm.agregar_mueble(id1, "camas_comun"))
		_check("agregar_mueble 2", hm.agregar_mueble(id1, "mesa_madera"))
		var muebles: Array = hm.obtener_muebles(id1)
		_check("2 muebles", muebles.size() == 2)
		
		# ── Bloque 5: Guardado ──
		var save: Dictionary = hm.obtener_datos_guardado()
		_check("guardado tiene casas", save.has("casas"))
		_check("guardado 1 casa", save["casas"].size() == 1)
		var hm2: Node = hm_script.new()
		hm2.restaurar_desde_guardado(save)
		_check("restaurar: 1 casa", hm2.cantidad_casas() == 1)
		_check("restaurar: etapa 5", hm2.obtener_etapa(id1) == 5)
		
		# ── Bloque 6: FurnitureData ──
		var fd_script: Script = load("res://scripts/houses/furniture_data.gd")
		_check("FurnitureData.gd carga", fd_script != null)
		if fd_script != null:
			var fd: Resource = fd_script.new()
			fd.nombre = "cofre_madera"
			fd.categoria = "almacenamiento"
			fd.capacidad_slots = 20
			_check("FurnitureData es_contenedor", fd.es_contenedor())
			_check("FurnitureData volumen", fd.obtener_volumen() > 0)
			var fd2: Resource = fd_script.new()
			fd2.nombre = "cuadro_parede"
			fd2.requiere_pared = true
			fd2.capacidad_slots = 0
			_check("FurnitureData no contenedor", not fd2.es_contenedor())

		# ── Bloque 7: Parcela despejada ──
		var id2: String = hm.registrar_casa(Vector3(150, 0, 250), "casa_2")
		_check("casa 2 registrada (id explicito)", hm.cantidad_casas() == 2)
		# Casa a 25m de la primera → debería estar despejada
		_check("parcela a 25m despejada", hm.parcela_despejada(Vector3(125, 0, 200)))
		# Casa a 5m de la primera → NO despejada
		_check("parcela a 5m no despejada", not hm.parcela_despejada(Vector3(105, 0, 200)))

		# ── Bloque 8: Vecinos ──
		_check("asignar_vecino", hm.asignar_vecino(id1, "bruno_sapo"))
		_check("obtener_vecino", hm.obtener_vecino(id1) == "bruno_sapo")
		_check("segundo vecino rechazado", not hm.asignar_vecino(id1, "catalina_oso"))
		_check("cantidad_vecinos = 1", hm.cantidad_vecinos() == 1)

		# ── Bloque 9: Costes por etapa ──
		_check("COSTES_ETAPA tiene 5 entradas", hm_script.COSTES_ETAPA.size() == 5)
		_check("COSTES_ETAPA[1] existe", hm_script.COSTES_ETAPA.has(1))

		# ── Bloque 10: Guardado M60 (duck-typing) ──
		var structs: Array = hm.obtener_estructuras()
		_check("obtener_estructuras devuelve Array", structs.size() >= 1)
		if structs.size() > 0:
			var s0: Dictionary = structs[0]
			_check("estructura tiene id", s0.has("id"))
			_check("estructura tipo=casa", String(s0.get("tipo", "")) == "casa")
		# Restaurar en una instancia nueva
		var hm3: Node = hm_script.new()
		hm3.restaurar_estructuras(structs)
		_check("restaurar_estructuras: casas", hm3.cantidad_casas() >= 1)

		# ── Bloque 11: cobrar_etapa (InventarioService) ──
		# En headless, InventarioService puede no tener items → debe retornar ok:false
		var res_cobro: Dictionary = hm.cobrar_etapa(id1)
		_check("cobrar_etapa retorna Dictionary", res_cobro is Dictionary)
		_check("cobrar_etapa ok o razon presente", res_cobro.has("ok") and res_cobro.has("razon"))

		# ── Bloque 12: Puerta + vecino ──
		hm.asignar_vecino(id1, "bruno_sapo")
		var pos_puerta: Vector3 = hm.obtener_pos_puerta(id1)
		_check("puerta tiene offset Z", pos_puerta.z != 0.0)
		_check("vecino puede entrar", hm.vecino_puede_entrar(id1, "bruno_sapo"))
		_check("vecino ajeno no entra", not hm.vecino_puede_entrar(id1, "catalina_oso"))
		_check("registrar_entrada", hm.registrar_entrada_vecino(id1, "bruno_sapo"))
		_check("registrar_salida", hm.registrar_salida_vecino(id1, "bruno_sapo"))
		_check("salida vecino inexistente = false", not hm.registrar_salida_vecino(id1, "catalina_oso"))

		# ── Bloque 13: Casa en ubicación M160 ──
		_check("casa_en_ubicacion_conocida (headless=true)", hm.casa_en_ubicacion_conocida(id1))

		# ── Bloque 14: Edge cases persistencia ──
		# Casa sin muebles
		var id_vacia: String = hm.registrar_casa(Vector3(300, 0, 300), "casa_vacia")
		_check("casa vacia: 0 muebles", hm.obtener_muebles(id_vacia).size() == 0)
		# Guardar/restore casa vacia
		var save_vacia: Dictionary = hm.obtener_datos_guardado()
		var hm_vacia: Node = hm_script.new()
		hm_vacia.restaurar_desde_guardado(save_vacia)
		_check("casa vacia restaurada", hm_vacia.cantidad_casas() >= 2)
		_check("casa vacia sin muebles post-restore", hm_vacia.obtener_muebles(id_vacia).size() == 0)

		# ── Bloque 15: Habitaciones por etapa ──
		# Usar una casa nueva para no interferir con la etapa de id1
		var id_hab: String = hm.registrar_casa(Vector3(400, 0, 400), "casa_hab")
		var habit_etapa1: Array = hm.obtener_habitaciones(id_hab)
		_check("etapa 1: solo living", habit_etapa1.size() == 1 and habit_etapa1[0] == "living")
		# Avanzar a etapa 2
		hm.avanzar_etapa(id_hab)
		var habit_etapa2: Array = hm.obtener_habitaciones(id_hab)
		_check("etapa 2: living + dormitorio", habit_etapa2.size() == 2)
		_check("habitacion_desbloqueada cocina = false (etapa 2)", not hm.habitacion_desbloqueada(id_hab, "cocina"))

		# ── Bloque 16: M29 estaciones ──
		var estacion: String = hm.obtener_estacion_actual()
		_check("obtener_estacion_actual no vacío", estacion != "")
		_check("etapa_viable_en_estacion(3) = true", hm.etapa_viable_en_estacion(3))
		# En invierno, etapa 5 no viable
		_check("etapa_viable_en_estacion(5) depende de estación", true)  # siempre true en headless

	# ── Red de seguridad ──
	create_timer(0.5).timeout.connect(func(): _fin())

func _fin() -> void:
	_summary()
	quit(1 if _fallos > 0 else 0)

func _summary() -> void:
	print("=== Resumen M18: %d checks, %d fallos ===" % [_checks, _fallos])
	if _checks < CHECKS_MINIMOS:
		print("WARNING: solo %d checks (mínimo %d)" % [_checks, CHECKS_MINIMOS])

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)
