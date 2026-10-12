# Modelo: MiniMax-M3
# Plataforma: Kilo Code
# Fecha: 2026-08-31
#
# M35: Test del módulo de Minería (capa sobre ResourceManager M15).
# Cubre: carga del catalogo, integración con M15, RF6 (doble drop por T3+),
# RF10 (limite suave por zona), persistencia de cuotas M59.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/mineria/test_mineria.gd
#
# Endurecido 2026-10-11 (re-QA §21.8, DeepSeek-V4.1-Flash): la version previa imprimia
# "0 fallo(s)" SIN contador de checks y llamaba a quit() desde _run(). Un SCRIPT ERROR
# dentro de un bloque _test_* abortaba esa funcion en silencio, perdia sus checks y la
# suite igual daba verde + EXIT 0 (falso verde, trampa 85/122). Se agregan las 3 capas:
# contador de checks, piso CHECKS_MINIMOS medido en verde, y marcadores de bloque _fin()
# + resumen diferido. Probe en rojo (aborto inyectado): 41 -> 35 checks, EXIT 1.
#
# Lote 1 (2026-10-11, DeepSeek-V4.1-Flash): bloques nuevos tool_niveles (H-A),
# guards (J6/J8/J10/veta agotada) y entrega_real (H-B/H-C + RF6 real). La asercion
# vieja "tool nivel 3 -> pico_oro" se elimino: consagraba el bug H-A (el id "pico_oro"
# era RECHAZADO por es_accesible_con, que compara por igualdad contra "pico").

extends SceneTree

var _fallos: int = 0
var _checks: int = 0
var _rm: Node = null
var _min: Node = null
var _inv: Node = null

## Bloques esperados: si uno no cierra su _fin(), se reporta como fallo.
const BLOQUES := ["catalogo", "definiciones", "integridad_m15", "drops_resuelven", "limite_zona", "rf6", "tool_niveles", "guards", "entrega_real", "persistencia"]
## Piso de checks MEDIDO en verde (corrida real del lote 1: 92). No estimar.
const CHECKS_MINIMOS := 92
var _vistos: Dictionary = {}

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")   # si _run() aborta, el resumen igual corre (trampa 61)

func _run() -> void:
	_rm = root.get_node_or_null("ResourceManager")
	_min = root.get_node_or_null("mineria")
	_inv = root.get_node_or_null("Inventario")
	_check(_rm != null, "ResourceManager autoload presente")
	_check(_min != null, "mineria autoload presente (M35)")
	if _rm == null or _min == null:
		return   # _summary() reportara los bloques faltantes
	_test_catalogo_minas()
	_fin("catalogo")
	_test_definiciones_mineras()
	_fin("definiciones")
	_test_integridad_con_m15()
	_fin("integridad_m15")
	_test_drops_resuelven()
	_fin("drops_resuelven")
	_test_limite_zona()
	_fin("limite_zona")
	_test_rf6_doble_drop_mejorada()
	_fin("rf6")
	_test_tool_niveles()
	_fin("tool_niveles")
	_test_guards()
	_fin("guards")
	_test_entrega_real()
	_fin("entrega_real")
	_test_persistencia()
	_fin("persistencia")

func _fin(nombre: String) -> void:
	_vistos[nombre] = true

func _summary() -> void:
	for n in BLOQUES:
		if not _vistos.has(n):
			_check(false, "bloque %s NO se ejecuto (posible SCRIPT ERROR)" % n)
	if _checks < CHECKS_MINIMOS:
		_check(false, "solo %d checks ejecutados (minimo %d) — posible aborto silencioso" % [_checks, CHECKS_MINIMOS])
	print("=== TEST M35 MINERIA: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
	else:
		print("OK: " + msg)

## Crea un ResourceNode de prueba DETACHED (configurar antes de add_child para
## evitar el camino M47, que depende del arbol) y lo monta en root.
func _nodo_de(def: ResourceDefinition, pos: Vector3) -> ResourceNode:
	var rn := ResourceNode.new()
	rn.configurar(def)
	root.add_child(rn)
	rn.global_position = pos
	return rn

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

## H10/BUG-132: cada drop de veta debe resolver a un item REAL del catalogo (M15/M159).
## Antes del fix el drop usaba el id de la VETA (p.ej. "veta_cobre"), que NO existe como
## item -> recompensa fantasma (sin nombre/icono/valor), inutil para crafting (M16) o venta
## (M36/M38). Esta es la asercion del camino FELIZ que la suite no tenia (falso verde por
## OMISION, familia trampa O/1197): probaba categoria/region/golpes pero NUNCA cruzaba el drop.
func _test_drops_resuelven() -> void:
	var idb: Node = root.get_node_or_null("ItemDatabase")
	_check(idb != null, "ItemDatabase autoload presente (M159)")
	if idb == null:
		return
	var vetas := ["veta_cobre", "veta_hierro", "veta_oro", "veta_cristal", "veta_ancestral", "veta_polvo_estrellas"]
	for vid in vetas:
		var def: ResourceDefinition = _rm.obtener_def(StringName(vid))
		_check(def != null, "%s existe para cruzar su drop" % vid)
		if def == null:
			continue
		_check(def.drops.size() > 0, "%s declara al menos un drop" % vid)
		for d in def.drops:
			var iid: String = String(d.item_id)
			var item = idb.get_item(iid)
			_check(item != null, "drop de %s -> item '%s' resuelve en ItemDatabase" % [vid, iid])

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
	# limpiar para los bloques de extraccion que siguen
	_min._zone_quota.clear()

func _test_rf6_doble_drop_mejorada() -> void:
	# Verificar la firma del helper de cálculo (sin instanciar ResourceNode real)
	var def: ResourceDefinition = _rm.obtener_def(&"veta_oro")
	_check(def != null, "veta_oro existe para test RF6")
	var tiene_mejorado: bool = _min._def_tiene_drop_mejorado(def)
	_check(tiene_mejorado, "veta_oro detecta drop que requiere herramienta mejorada (RF6)")
	# cobre no debe tener flag mejorado
	var cobre: ResourceDefinition = _rm.obtener_def(&"veta_cobre")
	_check(not _min._def_tiene_drop_mejorado(cobre), "veta_cobre NO requiere mejorada (RF6)")
	# Tool id helper (H-A: SIEMPRE el id corto "pico", que es el contrato de M15)
	var tool_basico := ToolData.crear(ToolData.Tipo.PICO, ToolData.Nivel.COBRE)
	var tool_mejorado := ToolData.crear(ToolData.Tipo.PICO, ToolData.Nivel.ORO)
	_check(_min._tool_id(tool_basico) == &"pico", "tool T1 → pico (contrato M15)")
	_check(_min._tool_id(tool_mejorado) == &"pico", "tool T3 → pico (contrato M15, NO pico_oro)")
	_check(not _min._es_mejorada(tool_basico), "tool cobre NO es mejorada")
	_check(_min._es_mejorada(tool_mejorado), "tool oro ES mejorada (RF6)")
	_check(_min._nivel(tool_mejorado) == 3, "nivel del tool T3 = 3")
	# _item_principal debe devolver el item REAL, nunca el id de la veta (H-C)
	_check(_min._item_principal(def) == "ancient_crystal", "_item_principal(veta_oro) = ancient_crystal (no 'veta_oro')")

## H-A: el pico de CUALQUIER nivel debe ser aceptado por la definicion (el bug era
## que T2+ daba tool_id "pico_hierro"/"pico_oro"/... y es_accesible_con lo rechazaba).
func _test_tool_niveles() -> void:
	var def: ResourceDefinition = _rm.obtener_def(&"veta_cobre")
	var niveles := [ToolData.Nivel.COBRE, ToolData.Nivel.HIERRO, ToolData.Nivel.ORO, ToolData.Nivel.CRISTAL]
	for nv in niveles:
		var t := ToolData.crear(ToolData.Tipo.PICO, nv)
		var tid: StringName = _min._tool_id(t)
		_check(def.es_accesible_con(tid, true), "pico nivel %d aceptado por veta_cobre (tool_id=%s)" % [nv, tid])
	_check(_min._tool_id(ToolData.crear(ToolData.Tipo.HACHA, ToolData.Nivel.COBRE)) == &"hacha", "hacha → hacha")
	_check(not def.es_accesible_con(&"hacha", true), "veta_cobre rechaza hacha")

## Guards del lote 1: J8 (herramienta rota), J6 (cooldown), J10 (definicion ausente),
## veta ya agotada (idempotente).
func _test_guards() -> void:
	_min._zone_quota.clear()
	_min._test_t_usec = 1000000
	var def: ResourceDefinition = _rm.obtener_def(&"veta_cobre")

	# J8: herramienta inutilizada (durabilidad 0) -> rechazo, sin tocar el nodo
	var rota := ToolData.crear(ToolData.Tipo.PICO, ToolData.Nivel.COBRE)
	rota.durabilidad_actual = 0
	_check(rota.inutilizada(), "tool con durabilidad 0 esta inutilizada")
	var rn1 := _nodo_de(def, Vector3(0, 50, 0))
	var g0: int = rn1.golpes_restantes
	var r8: Dictionary = _min.intentar_extraccion(rn1, rota)
	_check(r8.get("razon", "") == "herramienta_rota", "J8 herramienta rota -> razon herramienta_rota")
	_check(rn1.golpes_restantes == g0, "J8 herramienta rota NO consume golpes del nodo")
	_check(int(_min._zone_quota.get("cantera", 0)) == 0, "J8 herramienta rota NO consume cuota")

	# J6: cooldown por veta -> segundo golpe inmediato descartado
	var t1 := ToolData.crear(ToolData.Tipo.PICO, ToolData.Nivel.COBRE)
	var rn2 := _nodo_de(def, Vector3(0, 60, 0))
	var ok1: Dictionary = _min.intentar_extraccion(rn2, t1)
	_check(bool(ok1.get("ok", false)), "J6 primer golpe aceptado")
	var r6: Dictionary = _min.intentar_extraccion(rn2, t1)   # mismo reloj -> dentro del cooldown
	_check(r6.get("razon", "") == "cooldown", "J6 segundo golpe inmediato -> cooldown")
	_min._test_t_usec += 2000000   # +2 s (cooldown del pico T1 = 1.2 s)
	var ok2: Dictionary = _min.intentar_extraccion(rn2, t1)
	_check(bool(ok2.get("ok", false)), "J6 golpe tras el cooldown aceptado")

	# J10: definicion ausente -> razon definicion_ausente + fallback declarado
	var rn3 := ResourceNode.new()
	rn3.def_id = &"veta_inexistente"
	root.add_child(rn3)
	rn3.global_position = Vector3(0, 70, 0)
	var r10: Dictionary = _min.intentar_extraccion(rn3, t1)
	_check(r10.get("razon", "") == "definicion_ausente", "J10 definicion ausente -> razon definicion_ausente")
	_check(bool(r10.get("fallback", false)), "J10 definicion ausente -> fallback=true")

	# veta ya agotada: idempotente, no gasta cuota
	_min._zone_quota.clear()
	var rn4 := _nodo_de(def, Vector3(0, 80, 0))
	rn4.estado = ResourceNode.Estado.AGOTADO
	var rA: Dictionary = _min.intentar_extraccion(rn4, t1)
	_check(rA.get("razon", "") == "veta_agotada", "veta agotada -> razon veta_agotada")
	_check(int(_min._zone_quota.get("cantera", 0)) == 0, "veta agotada NO consume cuota")
	_min._test_t_usec = -1

## H-B/H-C + RF6: el drop se entrega UNA vez, al item REAL, y el RF6 duplica de verdad.
func _test_entrega_real() -> void:
	_check(_inv != null, "Inventario autoload presente (M14)")
	if _inv == null:
		return
	_min._zone_quota.clear()
	_min._test_t_usec = 5000000

	# --- cobre con pico T1: delta de inventario == cantidad reportada ---
	var def: ResourceDefinition = _rm.obtener_def(&"veta_cobre")
	var t1 := ToolData.crear(ToolData.Tipo.PICO, ToolData.Nivel.COBRE)
	var antes_cobre: int = _inv.count_item("mineral_cobre")
	var antes_fantasma: int = _inv.count_item("veta_cobre")
	var rn := _nodo_de(def, Vector3(0, 100, 0))
	var res: Dictionary = {}
	var golpes: int = def.golpes_requeridos
	for i in range(golpes):
		_min._test_t_usec += 3000000   # 3 s entre golpes: fuera de cooldown
		res = _min.intentar_extraccion(rn, t1)
	_check(bool(res.get("ok", false)), "cobre: la veta se agota con golpes validos")
	_check(rn.estado == ResourceNode.Estado.AGOTADO, "cobre: nodo AGOTADO tras los golpes")
	var delta_cobre: int = _inv.count_item("mineral_cobre") - antes_cobre
	_check(delta_cobre >= 1, "cobre: el inventario recibio mineral_cobre (delta=%d)" % delta_cobre)
	_check(delta_cobre == int(res.get("cantidad", -1)), "cobre: cantidad reportada == entregada (%d)" % delta_cobre)
	_check(_inv.count_item("veta_cobre") == antes_fantasma, "cobre: NO se entrego el item fantasma 'veta_cobre'")
	# nodo agotado no vuelve a entregar
	_min._test_t_usec += 3000000
	var res2: Dictionary = _min.intentar_extraccion(rn, t1)
	_check(res2.get("razon", "") == "veta_agotada", "cobre: segundo intento sobre veta agotada rechazado")
	_check(_inv.count_item("mineral_cobre") - antes_cobre == delta_cobre, "cobre: veta agotada no entrega de nuevo")

	# --- oro con pico T3: RF6 doble drop REAL al item correcto ---
	var def_oro: ResourceDefinition = _rm.obtener_def(&"veta_oro")
	var t3 := ToolData.crear(ToolData.Tipo.PICO, ToolData.Nivel.ORO)
	_check(_min._es_mejorada(t3), "oro: el pico T3 es mejorada")
	var antes_crystal: int = _inv.count_item("ancient_crystal")
	var antes_veta_oro: int = _inv.count_item("veta_oro")
	var rn2 := _nodo_de(def_oro, Vector3(0, 110, 0))
	var res3: Dictionary = {}
	for i in range(def_oro.golpes_requeridos):
		_min._test_t_usec += 3000000
		res3 = _min.intentar_extraccion(rn2, t3)
	_check(bool(res3.get("ok", false)), "oro: la veta se agota con pico T3")
	var delta_crystal: int = _inv.count_item("ancient_crystal") - antes_crystal
	_check(delta_crystal == 2, "oro: RF6 entrega 2 ancient_crystal (delta=%d)" % delta_crystal)
	_check(int(res3.get("cantidad", -1)) == 2, "oro: la cantidad reportada es 2")
	_check(_inv.count_item("veta_oro") == antes_veta_oro, "oro: NO se entrego el item fantasma 'veta_oro' (H-C)")
	_min._test_t_usec = -1

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
