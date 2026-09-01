# Modelo: MiniMax-M3
# Plataforma: Kilo Code
# Fecha: 2026-08-31
#
# M35: Test del módulo de Minería (capa sobre ResourceManager M15).
# Cubre: carga del catalogo, integración con M15, RF6 (doble drop por T3+),
# RF10 (limite suave por zona), persistencia de cuotas M59.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/mineria/test_mineria.gd

extends SceneTree

var _fallos: int = 0
var _rm: Node = null
var _min: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_rm = root.get_node_or_null("ResourceManager")
	_min = root.get_node_or_null("mineria")
	_check(_rm != null, "ResourceManager autoload presente")
	_check(_min != null, "mineria autoload presente (M35)")
	if _rm == null or _min == null:
		print("=== TEST M35 MINERIA: %d fallo(s) ===" % _fallos)
		quit(1 if _fallos > 0 else 0)
		return
	_test_catalogo_minas()
	_test_definiciones_mineras()
	_test_integridad_con_m15()
	_test_limite_zona()
	_test_rf6_doble_drop_mejorada()
	_test_persistencia()
	print("=== TEST M35 MINERIA: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
	else:
		print("OK: " + msg)

## ── Tests ──────────────────────────────────────────────────────

func _test_catalogo_minas() -> void:
	# El catalogo debe registrar las 6 vetas del JSON
	var veta_cobre: ResourceDefinition = _rm.obtener_def(&"veta_cobre")
	_check(veta_cobre != null, "veta_cobre registrada")
	var veta_hierro: ResourceDefinition = _rm.obtener_def(&"veta_hierro")
	_check(veta_hierro != null, "veta_hierro registrada")
	var veta_oro: ResourceDefinition = _rm.obtener_def(&"veta_oro")
	_check(veta_oro != null, "veta_oro registrada")
	var veta_cristal: ResourceDefinition = _rm.obtener_def(&"veta_cristal")
	_check(veta_cristal != null, "veta_cristal registrada")
	var veta_ancestral: ResourceDefinition = _rm.obtener_def(&"veta_ancestral")
	_check(veta_ancestral != null, "veta_ancestral registrada")
	var veta_polvo: ResourceDefinition = _rm.obtener_def(&"veta_polvo_estrellas")
	_check(veta_polvo != null, "veta_polvo_estrellas registrada")

func _test_definiciones_mineras() -> void:
	var cobre: ResourceDefinition = _rm.obtener_def(&"veta_cobre")
	_check(cobre != null and cobre.categoria == ResourceDefinition.Categoria.MINERAL, "veta_cobre categoria MINERAL")
	_check(cobre.herramienta_requerida == &"pico", "veta_cobre requiere pico")
	_check(cobre.golpes_requeridos >= 2 and cobre.golpes_requeridos <= 4, "veta_cobre golpes 2-4 (got %d)" % (cobre.golpes_requeridos if cobre else -1))
	_check(cobre.region == &"cantera", "veta_cobre region cantera")

	var ancestral: ResourceDefinition = _rm.obtener_def(&"veta_ancestral")
	_check(ancestral != null and ancestral.categoria == ResourceDefinition.Categoria.RARO, "veta_ancestral categoria RARO")
	_check(ancestral.rareza == 3, "veta_ancestral rareza 3 (legendario)")
	_check(ancestral.region == &"templo", "veta_ancestral region templo")
	# verificar que tiene flag requiere_mejorada en su drop entry
	var tiene_flag: bool = false
	if ancestral != null:
		for d in ancestral.drops:
			if d.requiere_herramienta_mejorada:
				tiene_flag = true
				break
	_check(tiene_flag, "veta_ancestral tiene drop con requiere_mejorada")

func _test_integridad_con_m15() -> void:
	# El catalogo de M35 NO debe romper las definiciones de M15
	var madera: ResourceDefinition = _rm.obtener_def(&"madera_roble")
	_check(madera != null, "M15 madera_roble sigue presente tras carga M35")
	_check(madera.categoria == ResourceDefinition.Categoria.MADERA, "M15 madera_roble categoria intacta")
	var mineral_m15: ResourceDefinition = _rm.obtener_def(&"mineral_cobre")
	_check(mineral_m15 != null, "M15 mineral_cobre preservado (no sobreescrito)")
	_check(mineral_m15.display_name == "Mineral de Cobre", "M15 mineral_cobre display_name original")
	# y fragmento_ancestral de M15 tampoco debe ser pisado
	var frag_m15: ResourceDefinition = _rm.obtener_def(&"fragmento_ancestral")
	_check(frag_m15 != null, "M15 fragmento_ancestral preservado")
	_check(frag_m15.display_name == "Fragmento Ancestral", "M15 fragmento_ancestral display_name original")

func _test_limite_zona() -> void:
	# Verificar que la zona arranca con DEFAULT_ZONE_QUOTA disponible
	_check(_min.quota_restante(&"cantera") == 12, "cantera arranca con 12 disponibles")
	_check(_min.quota_restante(&"templo") == 12, "templo arranca con 12 disponibles")
	_check(not _min.is_zone_exhausted(&"cantera"), "cantera NO agotada al inicio")
	# Consumir todas las cuotas manualmente
	for i in range(12):
		_min._consume_zone_quota("cantera")
	_check(_min.is_zone_exhausted(&"cantera"), "cantera agotada tras 12 consumos")
	# Otras zonas intactas
	_check(not _min.is_zone_exhausted(&"templo"), "templo sigue NO agotada")

func _test_rf6_doble_drop_mejorada() -> void:
	# Verificar la firma del helper de cálculo (sin instanciar ResourceNode real)
	var def: ResourceDefinition = _rm.obtener_def(&"veta_oro")
	_check(def != null, "veta_oro existe para test RF6")
	var tiene_mejorado: bool = _min._def_tiene_drop_mejorado(def)
	_check(tiene_mejorado, "veta_oro detecta drop que requiere herramienta mejorada (RF6)")
	# cobre no debe tener flag mejorado
	var cobre: ResourceDefinition = _rm.obtener_def(&"veta_cobre")
	_check(not _min._def_tiene_drop_mejorado(cobre), "veta_cobre NO requiere mejorada (RF6)")
	# Tool id helper
	var tool_basico := ToolData.crear(ToolData.Tipo.PICO, ToolData.Nivel.COBRE)
	var tool_mejorado := ToolData.crear(ToolData.Tipo.PICO, ToolData.Nivel.ORO)
	_check(_min._tool_id(tool_basico) == &"pico", "tool basico → pico")
	_check(_min._tool_id(tool_mejorado) == &"pico_oro", "tool nivel 3 → pico_oro")
	_check(not _min._es_mejorada(tool_basico), "tool cobre NO es mejorada")
	_check(_min._es_mejorada(tool_mejorado), "tool oro ES mejorada (RF6)")

func _test_persistencia() -> void:
	# Save data tiene la forma esperada
	var data: Dictionary = _min.get_save_data()
	_check(data.has("version"), "save data tiene version")
	_check(int(data.get("version", 0)) >= 1, "version >= 1")
	_check(data.has("zone_quota"), "save data tiene zone_quota")
	_check(data.has("zone_quota_dia"), "save data tiene zone_quota_dia")
	# Restore no rompe
	_min._consume_zone_quota("cantera")
	var antes: int = int(_min._zone_quota.get("cantera", 0))
	_min.restore_save_data({"version": 1, "zone_quota": {"cantera": 7}, "zone_quota_dia": {"cantera": 42}})
	var despues: int = int(_min._zone_quota.get("cantera", 0))
	_check(despues == 7, "restore_save_data aplica cuotas: %d (esperado 7)" % despues)
	# version antigua debe rechazarse
	_min.restore_save_data({"version": 0})
	_check(int(_min._zone_quota.get("cantera", -99)) == 7, "version 0 ignorada (cuota sigue en 7)")
	_check(antes >= 1, "consumo de prueba se realizo (cantera=%d)" % antes)