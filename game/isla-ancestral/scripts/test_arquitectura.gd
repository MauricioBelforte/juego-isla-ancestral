extends Node3D
## Escena de prueba para validar la arquitectura base
## Verifica: EventBus, ServiceRegistry, Bootstrap

@onready var label: Label = $UI/Label

var _event_received := false


func _ready() -> void:
	print("=== Test Arquitectura ===")
	
	var results: Array[String] = []
	
	# Test 1: EventBus existe
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus:
		results.append("[OK] EventBus autoload activo")
	else:
		results.append("[FAIL] EventBus NO encontrado")
	
	# Test 2: ServiceRegistry existe
	var service_reg = get_node_or_null("/root/ServiceRegistry")
	if service_reg:
		results.append("[OK] ServiceRegistry autoload activo")
	else:
		results.append("[FAIL] ServiceRegistry NO encontrado")
	
	# Test 3: ServiceRegistry tiene EventBus registrado
	if service_reg and service_reg.has("event_bus"):
		results.append("[OK] EventBus registrado en ServiceRegistry")
	else:
		results.append("[FAIL] EventBus NO registrado en ServiceRegistry")
	
	# Test 4: EventBus tiene dominios
	if event_bus:
		var has_world = event_bus.world != null
		var has_economy = event_bus.economy != null
		if has_world and has_economy:
			results.append("[OK] EventBus tiene dominios (world, economy)")
		else:
			results.append("[FAIL] EventBus falta dominios")
	
	# Test 5: Se puede emitir y recibir un evento
	if event_bus:
		_event_received = false
		var callback = func(_pos: Vector3i, _type: int): _event_received = true
		event_bus.world.block_placed.connect(callback)
		event_bus.world.block_placed.emit(Vector3i(0, 0, 0), 1)
		event_bus.world.block_placed.disconnect(callback)
		if _event_received:
			results.append("[OK] EventBus: emisión y recepción funcional")
		else:
			results.append("[FAIL] EventBus: no se recibió el evento")
	
	# Test 6: ServiceRegistry.list_registered()
	if service_reg:
		var registered = service_reg.list_registered()
		results.append("[OK] ServiceRegistry: %d servicios registrados" % registered.size())
	
	# Mostrar resultados
	var output = "=== RESULTADOS TEST ARQUITECTURA ===\n"
	for r in results:
		output += r + "\n"
	
	var pass_count := 0
	var fail_count := 0
	for r in results:
		if r.begins_with("[OK]"):
			pass_count += 1
		else:
			fail_count += 1
	output += "\nTOTAL: %d PASS, %d FAIL" % [pass_count, fail_count]
	
	print(output)
	
	if label:
		label.text = output
	
	# Colores
	if fail_count == 0:
		print(">>> ARQUITECTURA BASE VALIDADA <<<")
	else:
		push_error(">>> HAY FALLOS EN LA ARQUITECTURA <<<")
