# Modelo: GLM-5.3
# Plataforma: Kilo Code
# Fecha: 2026-09-10
#
# M13 iter 4: test de (1) persistencia del hotbar de herramientas en M59
# (ToolsSaveProvider, ítem D.12 / T-019) y (2) cableado M13→M15 (golpe E
# contra ResourceNode, cierra el [?] de M15 iter 4).
# Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/tools/test_herramientas_iter4.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_provider_persistencia_hotbar()
	_test_nombre_id_contrato_m15()
	_test_cableado_m13_m15()
	print("=== TEST M13 ITER4: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

## ── Test 1: ToolsSaveProvider round-trip (T-019) ────────────────────────
func _test_provider_persistencia_hotbar() -> void:
	# Hotbar simulado con estados variados (durabilidad, nivel, mejoras)
	var hotbar: Array[ToolData] = []
	var pico := ToolData.crear(ToolData.Tipo.PICO, ToolData.Nivel.HIERRO)
	pico.durabilidad_actual = 137
	pico.mejora_afilada = true
	hotbar.append(pico)
	var martillo := ToolData.crear(ToolData.Tipo.MARTILLO, ToolData.Nivel.COBRE)
	hotbar.append(martillo)
	hotbar.append(null)  # slot vacío
	var provider := ToolsSaveProvider.new(
		hotbar,
		Callable(self, "_get_indice_falso"),
		Callable(self, "_set_indice_falso"),
		Callable(self, "_set_hotbar_falso")
	)
	_check(provider.get_section_name() == "herramientas_m13", "sección del provider = herramientas_m13")
	# Guardar
	var save: Dictionary = provider.get_save_data()
	_check(int(save.get("version", 0)) == 1, "save version=1")
	_check(int(save.get("activa", -1)) == 2, "índice activo serializado (=2)")
	var herramientas: Array = save.get("herramientas", [])
	_check(herramientas.size() == 3, "3 slots serializados (incluye null)")
	var h0: Dictionary = herramientas[0]
	_check(int(h0.get("tipo", -1)) == ToolData.Tipo.PICO, "tipo PICO serializado")
	_check(int(h0.get("nivel", -1)) == ToolData.Nivel.HIERRO, "nivel HIERRO serializado")
	_check(int(h0.get("durabilidad", -1)) == 137, "durabilidad 137 serializada")
	_check(bool(h0.get("afilada", false)) == true, "mejora afilada serializada")
	# Restaurar en un hotbar nuevo (recibido por callback)
	_indice_recibido = -1
	_hotbar_recibido = []
	provider.restore_save_data(save)
	_check(_hotbar_recibido.size() == 3, "hotbar restaurado por callback (3 slots)")
	if _hotbar_recibido.size() == 3:
		var r0: ToolData = _hotbar_recibido[0]
		_check(r0 != null and r0.tipo == ToolData.Tipo.PICO, "slot 0 restaurado: PICO")
		_check(r0.durabilidad_actual == 137, "durabilidad restaurada (137)")
		_check(r0.mejora_afilada, "mejora afilada restaurada")
		_check(r0.nombre == "Pico de Hierro", "nombre reconstruido por deserializar")
		var r1: ToolData = _hotbar_recibido[1]
		_check(r1 != null and r1.durabilidad_infinita(), "slot 1 martillo: durabilidad infinita restaurada")
		_check(_hotbar_recibido[2] == null, "slot 2 null preservado")
	_check(_indice_recibido == 2, "índice activo restaurado (=2)")
	# restore con datos vacíos NO llama al callback (no pisa hotbar por defecto)
	_hotbar_recibido = []
	provider.restore_save_data({"version": 1, "herramientas": []})
	_check(_hotbar_recibido.is_empty(), "restore con herramientas vacías NO pisa el hotbar")

var _indice_recibido: int = -1
var _hotbar_recibido: Array[ToolData] = []

func _get_indice_falso() -> int:
	return 2

func _set_indice_falso(i: int) -> void:
	_indice_recibido = i

func _set_hotbar_falso(hb: Array[ToolData]) -> void:
	_hotbar_recibido = hb

## ── Test 2: contrato nombre_id ↔ M15 ────────────────────────────────────
func _test_nombre_id_contrato_m15() -> void:
	var rm = root.get_node_or_null("ResourceManager")
	_check(rm != null, "ResourceManager autoload presente")
	if rm == null:
		return
	# Las defs de M15 exigen "hacha" para madera_roble y "pico" para piedra_caliza
	var hacha := ToolData.crear(ToolData.Tipo.HACHA, ToolData.Nivel.COBRE)
	_check(hacha.nombre_id() == &"hacha", "HACHA → id 'hacha' (contrato M15)")
	var pico := ToolData.crear(ToolData.Tipo.PICO, ToolData.Nivel.COBRE)
	_check(pico.nombre_id() == &"pico", "PICO → id 'pico' (contrato M15)")
	# Validar el contrato directo contra la definición real de M15
	var def_roble: ResourceDefinition = rm.obtener_def(&"madera_roble")
	_check(def_roble != null and def_roble.es_accesible_con(hacha.nombre_id(), true), "hacha aceptada por madera_roble (M15)")
	var def_piedra: ResourceDefinition = rm.obtener_def(&"piedra_caliza")
	_check(def_piedra != null and def_piedra.es_accesible_con(pico.nombre_id(), true), "pico aceptado por piedra_caliza (M15)")
	_check(def_piedra != null and not def_piedra.es_accesible_con(hacha.nombre_id(), true), "hacha RECHAZADA por piedra_caliza (M15)")

## ── Test 3: cableado M13→M15 (golpe contra ResourceNode) ────────────────
## Valida la lógica pura del cableado sin cámara/jugador: el helper de M15
## recibir_golpe_en_nodo + el lookup _recurso_m15_cercano_a vía el flujo
## real de ResourceManager (nodos activos del spawner).
func _test_cableado_m13_m15() -> void:
	var rm = root.get_node_or_null("ResourceManager")
	if rm == null:
		return
	# Crear un nodo de M15 registrado (patrón test iter 3: add_child primero)
	var nodo := ResourceNode.new()
	nodo.configurar(rm.obtener_def(&"piedra_caliza"))
	root.add_child(nodo)
	nodo.global_position = Vector3(800, 30, 800)
	rm.registrar_nodo(nodo)
	var pico := ToolData.crear(ToolData.Tipo.PICO, ToolData.Nivel.COBRE)
	var inv = root.get_node_or_null("Inventario")
	var inv_antes: int = inv.count_item("piedra_caliza") if inv != null else 0
	# Golpes con la herramienta CORRECTA vía el helper que consume el cableado.
	# piedra_caliza requiere 2 golpes (def.golpes_requeridos): agotar completo
	# para que se entreguen los drops (lección del test iter 3).
	var golpes_total: int = nodo.golpes_restantes
	for i in range(golpes_total):
		rm.recibir_golpe_en_nodo(nodo, pico.nombre_id())
	_check(nodo.estado == ResourceNode.Estado.AGOTADO, "nodo M15 AGOTADO tras golpes con pico")
	_check(nodo.estado != ResourceNode.Estado.AGOTADO or nodo.respawn_dia_absoluto > 0, "nodo agotado programó respawn")
	var inv_despues: int = inv.count_item("piedra_caliza") if inv != null else 0
	_check(inv_despues > inv_antes, "drops entregados al inventario (M14) por nodo M15")
	# Golpe con herramienta INCORRECTA: no aplica, no rompe
	var hacha := ToolData.crear(ToolData.Tipo.HACHA, ToolData.Nivel.COBRE)
	var nodo2 := ResourceNode.new()
	nodo2.configurar(rm.obtener_def(&"piedra_caliza"))
	root.add_child(nodo2)
	nodo2.global_position = Vector3(810, 30, 810)
	rm.registrar_nodo(nodo2)
	var ok2: bool = rm.recibir_golpe_en_nodo(nodo2, hacha.nombre_id())
	_check(not ok2, "golpe hacha contra piedra M15 rechazado (regla cozy)")
	_check(nodo2.estado == ResourceNode.Estado.INTACTO, "nodo M15 intacto tras golpe inválido")
	# Limpieza
	rm.desregistrar_nodo(nodo)
	rm.desregistrar_nodo(nodo2)
	nodo.queue_free()
	nodo2.queue_free()
