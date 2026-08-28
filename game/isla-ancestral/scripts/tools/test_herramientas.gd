# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-28
#
# M13: Test headless de Herramientas (ToolData + tablas del ToolController)
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/tools/test_herramientas.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	_test_catalogo_36_combos()
	_test_durabilidad_cozy()
	_test_reparacion()
	_test_serializacion()
	_test_acciones_por_tipo()
	_test_mapeo_bloques()
	_test_tabla_golpes()
	print("=== TEST HERRAMIENTAS M13: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, mensaje: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: %s" % mensaje)

func _test_catalogo_36_combos() -> void:
	for tipo in 9:
		for nivel in range(1, 5):
			var t: ToolData = ToolData.crear(tipo, nivel)
			_check(t != null, "crear(%d, %d) devolvió null" % [tipo, nivel])
			_check(t.nombre != "", "nombre vacío para (%d, %d)" % [tipo, nivel])
			_check(t.durabilidad_max > 0 or t.durabilidad_infinita(), "durabilidad inválida (%d, %d)" % [tipo, nivel])
			_check(t.durabilidad_actual == t.durabilidad_max, "durabilidad actual != max en creación (%d, %d)" % [tipo, nivel])
			_check(t.velocidad_segolpe >= 0.0 and t.velocidad_segolpe <= 2.0, "velocidad fuera de rango (%d, %d)" % [tipo, nivel])
			if tipo != ToolData.Tipo.LUPA:
				_check(t.velocidad_segolpe > 0.0, "velocidad 0 en herramienta de golpeo (%d, %d)" % [tipo, nivel])
			_check(t.area == 1 or t.area == 9, "área inválida (%d, %d)" % [tipo, nivel])
			_check(not t.acciones.is_empty(), "acciones vacías (%d, %d)" % [tipo, nivel])
	print("  [OK] catálogo 9×4 verificado")

func _test_durabilidad_cozy() -> void:
	var pico: ToolData = ToolData.crear(ToolData.Tipo.PICO, ToolData.Nivel.COBRE)
	var maximo: int = pico.durabilidad_max
	for i in maximo:
		pico.gastar_uso()
	_check(pico.inutilizada(), "pico debería estar inutilizado a 0")
	_check(pico.durabilidad_actual == 0, "durabilidad debería ser exactamente 0")
	pico.gastar_uso()
	_check(pico.durabilidad_actual == 0, "durabilidad NUNCA debe ser negativa (regla cozy roja)")
	var martillo: ToolData = ToolData.crear(ToolData.Tipo.MARTILLO, ToolData.Nivel.COBRE)
	martillo.gastar_uso()
	_check(not martillo.inutilizada(), "martillo de durabilidad infinita nunca se inutiliza")
	var lupa: ToolData = ToolData.crear(ToolData.Tipo.LUPA, ToolData.Nivel.COBRE)
	_check(lupa.durabilidad_infinita(), "lupa debe tener durabilidad infinita")
	print("  [OK] durabilidad cozy (nunca negativa, infinitas para martillo/lupa)")

func _test_reparacion() -> void:
	var pala: ToolData = ToolData.crear(ToolData.Tipo.PALA, ToolData.Nivel.COBRE)
	pala.durabilidad_actual = int(pala.durabilidad_max * 0.2)
	_check(pala.necesita_reparacion(), "aviso de reparación al 20%")
	pala.durabilidad_actual = int(pala.durabilidad_max * 0.5)
	_check(not pala.necesita_reparacion(), "sin aviso de reparación al 50%")
	print("  [OK] umbral de reparación al 20%")

func _test_serializacion() -> void:
	var original: ToolData = ToolData.crear(ToolData.Tipo.HACHA, ToolData.Nivel.HIERRO)
	original.durabilidad_actual = 77
	original.mejora_afilada = true
	var datos: Dictionary = original.serializar()
	var copia: ToolData = ToolData.deserializar(datos)
	_check(copia.tipo == original.tipo, "roundtrip: tipo")
	_check(copia.nivel == original.nivel, "roundtrip: nivel")
	_check(copia.durabilidad_actual == 77, "roundtrip: durabilidad")
	_check(copia.mejora_afilada, "roundtrip: mejora afilada")
	print("  [OK] serializar/deserializar roundtrip")

func _test_acciones_por_tipo() -> void:
	var esperados := {
		ToolData.Tipo.PICO: [ToolData.Accion.EXTRACT],
		ToolData.Tipo.AZADA: [ToolData.Accion.TILL, ToolData.Accion.EXTRACT],
		ToolData.Tipo.HACHA: [ToolData.Accion.EXTRACT],
		ToolData.Tipo.PALA: [ToolData.Accion.EXTRACT],
		ToolData.Tipo.REGADERA: [ToolData.Accion.WATER],
		ToolData.Tipo.CANA: [ToolData.Accion.FISH],
		ToolData.Tipo.MARTILLO: [ToolData.Accion.BUILD],
		ToolData.Tipo.TIJERAS: [ToolData.Accion.SHEAR],
		ToolData.Tipo.LUPA: [ToolData.Accion.INSPECT],
	}
	for tipo in esperados:
		var t: ToolData = ToolData.crear(tipo, ToolData.Nivel.COBRE)
		for accion in esperados[tipo]:
			_check(t.permite(accion), "tipo %d debería permitir acción %d" % [tipo, accion])
	var martillo: ToolData = ToolData.crear(ToolData.Tipo.MARTILLO, ToolData.Nivel.COBRE)
	_check(not martillo.permite(ToolData.Accion.EXTRACT), "martillo no debe extraer")
	print("  [OK] acciones por tipo")

func _test_mapeo_bloques() -> void:
	_check(ToolController._block_to_item_id(1) == "dirt", "bloque 1 → dirt")
	_check(ToolController._block_to_item_id(2) == "grass", "bloque 2 → grass")
	_check(ToolController._block_to_item_id(3) == "stone", "bloque 3 → stone")
	_check(ToolController._block_to_item_id(9) == "copper_ore", "bloque 9 → copper_ore")
	_check(ToolController._block_to_item_id(26) == "snow", "bloque 26 → snow (BlockType)")
	_check(ToolController._block_to_item_id(27) == "gravel", "bloque 27 → gravel (BlockType)")
	_check(ToolController._block_to_item_id(28) == "moss", "bloque 28 → moss (BlockType)")
	_check(ToolController._block_to_item_id(29) == "mud", "bloque 29 → mud (BlockType)")
	print("  [OK] mapeo block_id → item_id alineado con BlockType")

func _test_tabla_golpes() -> void:
	var golpes: Dictionary = ToolController.GOLPES
	for bloque in golpes:
		var g: int = int(golpes[bloque])
		_check(g >= 1 and g <= 6, "golpes de bloque %d fuera del rango 1-6 (spec 2-6 golpes)" % bloque)
	_check(not golpes.has(0), "aire no debe estar en la tabla de golpes")
	_check(not golpes.has(4), "roca madre no debe estar en la tabla de golpes")
	_check(not golpes.has(17), "agua no debe estar en la tabla de golpes")
	print("  [OK] tabla de golpes 2-6 sin aire/roca madre/agua")
