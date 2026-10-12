# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy (opencode)
# Fecha: 2026-10-11
#
# M35: Test del LOTE 2 (capa de dominio de mineria sobre M15).
# Cubre los 17 items cerrados en el lote 2 (encargo mimo msg 171):
#   J1 estado parcial persistido · J5 snapshot consistente · J9 cercania
#   K3 hot path sin allocs · K5 barrido iterativo · K6 profiler <= 1 ms · K7 instancia unica
#   L5 derrumbe cozy · L6 brillo decreciente · L7 anuncio dorado · L8 texto flotante · L9 vibracion
#   I1 vetas por region · I5 anti-softlock · I8 coleccion
#   G5 soporte (anti-flotamiento) · G10 chunks editados
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/mineria/test_mineria_lote2.gd
#
# 3 capas anti-falso-verde (trampas 85/122): contador de checks + piso
# CHECKS_MINIMOS medido en verde + marcadores de bloque _fin() con resumen diferido.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0
var _rm: Node = null
var _min: Node = null

const BLOQUES := ["parcial", "snapshot", "cercania", "sin_allocs", "barrido", "profiler", "compartidas", "derrumbe", "brillo_texto", "vibracion", "region", "softlock_soporte", "chunks", "coleccion"]
## Piso de checks MEDIDO en verde (no estimado). Se actualiza si crece la suite.
const CHECKS_MINIMOS := 104
## K6: presupuesto del golpe individual (us). Mismo valor que MiningManager.HIT_BUDGET_US.
const HIT_BUDGET_US := 1000
var _vistos: Dictionary = {}

## Capturas de señales (var miembro: las lambdas capturan por valor).
var _recuperadas: Array = []
var _derrumbes_n: int = 0
var _vib_n: int = 0

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")   # si _run() aborta, el resumen igual corre (trampa 61)

func _run() -> void:
	_rm = root.get_node_or_null("ResourceManager")
	_min = root.get_node_or_null("mineria")
	_check(_rm != null, "ResourceManager autoload presente (M15)")
	_check(_min != null, "mineria autoload presente (M35)")
	if _rm == null or _min == null:
		return
	_test_parcial()
	_fin("parcial")
	_test_snapshot()
	_fin("snapshot")
	_test_cercania()
	_fin("cercania")
	_test_sin_allocs()
	_fin("sin_allocs")
	_test_barrido()
	_fin("barrido")
	_test_profiler()
	_fin("profiler")
	_test_compartidas()
	_fin("compartidas")
	_test_derrumbe()
	_fin("derrumbe")
	_test_brillo_texto()
	_fin("brillo_texto")
	_test_vibracion()
	_fin("vibracion")
	_test_region()
	_fin("region")
	_test_softlock_soporte()
	_fin("softlock_soporte")
	_test_chunks()
	_fin("chunks")
	_test_coleccion()
	_fin("coleccion")

func _fin(nombre: String) -> void:
	_vistos[nombre] = true

func _summary() -> void:
	for n in BLOQUES:
		if not _vistos.has(n):
			_check(false, "bloque %s NO se ejecuto (posible SCRIPT ERROR)" % n)
	if _checks < CHECKS_MINIMOS:
		_check(false, "solo %d checks ejecutados (minimo %d) — posible aborto silencioso" % [_checks, CHECKS_MINIMOS])
	print("=== TEST M35 LOTE 2: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
	else:
		print("OK: " + msg)

## Crea un ResourceNode de prueba (configurar ANTES de add_child) y lo monta en root.
func _nodo_de(def: ResourceDefinition, pos: Vector3) -> ResourceNode:
	var rn := ResourceNode.new()
	rn.configurar(def)
	root.add_child(rn)
	rn.global_position = pos
	return rn

## Capturas de señal.
func _on_recuperada(def_id: StringName, _pos: Vector3, anuncio: bool) -> void:
	_recuperadas.append({"def": String(def_id), "anuncio": anuncio})

func _on_derrumbe(_def: StringName, _pos: Vector3) -> void:
	_derrumbes_n += 1

func _on_vibracion(_def: StringName, _pos: Vector3) -> void:
	_vib_n += 1

## Lectores de solidez para G5.
func _solido_abajo(p: Vector3) -> bool:
	return is_equal_approx(p.y, -1.0)

func _nada_solido(_p: Vector3) -> bool:
	return false

func _solido_al_lado(p: Vector3) -> bool:
	return is_equal_approx(p.x, 1.0)

## ── J1: veta a medias persistida y restaurada ───────────────────────────────

func _test_parcial() -> void:
	_min._zone_quota.clear()
	_min._vetas_parciales.clear()
	_min._test_t_usec = 1000000
	var def: ResourceDefinition = _rm.obtener_def(&"veta_ancestral")   # 6 golpes
	_check(def != null and def.golpes_requeridos == 6, "veta_ancestral declara 6 golpes")
	var t4 := ToolData.crear(ToolData.Tipo.PICO, ToolData.Nivel.CRISTAL)
	var rn := _nodo_de(def, Vector3(10, 40, 10))
	for i in range(2):
		_min._test_t_usec += 3000000
		var r: Dictionary = _min.intentar_extraccion(rn, t4)
		_check(bool(r.get("ok", false)), "golpe %d aceptado" % (i + 1))
	_check(rn.golpes_restantes == 4, "quedan 4 golpes tras 2 (got %d)" % rn.golpes_restantes)
	var clave: String = _min.clave_veta(rn)
	_check(_min.golpes_parciales(rn) == 4, "J1 estado parcial persistido = 4")

	var rn2 := _nodo_de(def, Vector3(10, 40, 10))   # misma posicion -> misma clave
	_check(_min.clave_veta(rn2) == clave, "J1 misma posicion -> misma clave de veta")
	_check(rn2.golpes_restantes == 6, "J1 nodo nuevo arranca con 6")
	_check(_min.aplicar_estado_parcial(rn2), "J1 aplicar_estado_parcial devuelve true")
	_check(rn2.golpes_restantes == 4, "J1 estado restaurado: 4 golpes (got %d)" % rn2.golpes_restantes)
	_check(rn2.estado == ResourceNode.Estado.DANIADO, "J1 nodo restaurado queda DANIADO")
	var fr: float = _min.fraccion_restante(rn2)
	_check(fr > 0.6 and fr < 0.7, "J1 fraccion restante ~0.667 (got %.3f)" % fr)

	var data: Dictionary = _min.get_save_data()
	_check(data.has("vetas_parciales"), "J1 el save incluye vetas_parciales")
	_min._vetas_parciales.clear()
	_min.restore_save_data(data)
	_check(_min.golpes_parciales(rn) == 4, "J1 el parcial sobrevive al save/load")

	# Al agotarse la veta se limpia el parcial (ya no esta "a medias").
	_min._zone_quota.clear()
	_min._test_t_usec = 1000000
	var rn3 := _nodo_de(def, Vector3(20, 40, 20))
	for i in range(6):
		_min._test_t_usec += 3000000
		_min.intentar_extraccion(rn3, t4)
	_check(rn3.estado == ResourceNode.Estado.AGOTADO, "J1 la veta se agota tras 6 golpes")
	_check(not _min._vetas_parciales.has(_min.clave_veta(rn3)), "J1 el parcial se limpia al agotarse")
	_min._test_t_usec = -1

## ── J5: snapshot consistente (guardar en medio de una secuencia de golpes) ──

func _test_snapshot() -> void:
	_min._zone_quota.clear()
	_min._coleccion.clear()
	_min._vetas_parciales.clear()
	_min._test_t_usec = 1000000
	var def: ResourceDefinition = _rm.obtener_def(&"veta_cristal")   # 4 golpes, region cueva
	var t3 := ToolData.crear(ToolData.Tipo.PICO, ToolData.Nivel.ORO)
	var rn := _nodo_de(def, Vector3(30, 40, 30))
	_min._test_t_usec += 3000000
	var r1: Dictionary = _min.intentar_extraccion(rn, t3)
	_check(bool(r1.get("ok", false)), "J5 primer golpe aceptado")
	var snap: Dictionary = _min.snapshot_estado()
	_check(snap.has("zone_quota"), "J5 el snapshot incluye zone_quota")
	_check(snap.has("vetas_parciales"), "J5 el snapshot incluye vetas_parciales")
	_check(snap.has("coleccion"), "J5 el snapshot incluye coleccion")
	var zq_snap: Dictionary = snap.get("zone_quota", {})
	_check(int(zq_snap.get("cueva", 0)) == 1, "J5 el snapshot registra 1 extraccion en cueva")

	_min._test_t_usec += 3000000
	var r2: Dictionary = _min.intentar_extraccion(rn, t3)
	_check(bool(r2.get("ok", false)), "J5 segundo golpe aceptado")
	_check(_min.golpes_parciales(rn) == 2, "J5 tras 2 golpes quedan 2 parciales")
	_check(int(_min._zone_quota.get("cueva", 0)) == 2, "J5 la cuota viva es 2")

	_min.restaurar_estado(snap)
	_check(_min.golpes_parciales(rn) == 3, "J5 el restore devuelve el parcial del snapshot (3)")
	_check(int(_min._zone_quota.get("cueva", 0)) == 1, "J5 el restore devuelve la cuota del snapshot (1)")
	_check(_min.aplicar_estado_parcial(rn), "J5 se puede re-aplicar el parcial al nodo")
	_check(rn.golpes_restantes == 3, "J5 el nodo queda consistente con el snapshot (3)")
	_min._test_t_usec = -1

## ── J9: prioridad por cercania ──────────────────────────────────────────────

func _test_cercania() -> void:
	var def: ResourceDefinition = _rm.obtener_def(&"veta_cobre")
	var a := _nodo_de(def, Vector3(100, 0, 0))
	var b := _nodo_de(def, Vector3(101, 0, 0))
	var c := _nodo_de(def, Vector3(103, 0, 0))
	var origen := Vector3(0, 0, 0)
	var elegida: ResourceNode = _min.seleccionar_veta_mas_cercana(origen, [c, b, a])
	_check(elegida == a, "J9 elige la mas cercana sin importar el orden")
	var elegida2: ResourceNode = _min.seleccionar_veta_mas_cercana(origen, [a, b, c])
	_check(elegida2 == a, "J9 determinista con el orden invertido")
	_check(_min.seleccionar_veta_mas_cercana(Vector3(103, 0, 0), [a, b, c]) == c, "J9 origen sobre una veta -> esa")
	# empate exacto: el desempate debe ser estable (misma eleccion en ambos ordenes)
	var d1 := _nodo_de(def, Vector3(-50, 0, 0))
	var d2 := _nodo_de(def, Vector3(50, 0, 0))
	var emp1: ResourceNode = _min.seleccionar_veta_mas_cercana(origen, [d2, d1])
	var emp2: ResourceNode = _min.seleccionar_veta_mas_cercana(origen, [d1, d2])
	_check(emp1 == emp2, "J9 empate resuelto de forma estable (mismo nodo en ambos ordenes)")
	_check(_min.seleccionar_veta_mas_cercana(origen, []) == null, "J9 lista vacia -> null")
	_check(_min.seleccionar_veta_mas_cercana(origen, [null, a]) == a, "J9 ignora nulos")

## ── K3: hot path sin allocaciones ───────────────────────────────────────────

func _test_sin_allocs() -> void:
	_min._zone_quota.clear()
	_min._test_t_usec = 1000000
	var def: ResourceDefinition = _rm.obtener_def(&"veta_ancestral")
	var t4 := ToolData.crear(ToolData.Tipo.PICO, ToolData.Nivel.CRISTAL)
	var rn := _nodo_de(def, Vector3(40, 40, 40))
	rn.golpes_restantes = 100000   # no se agota: mide el camino caliente completo
	var out: Dictionary = {}
	var allocs_antes: int = _min._allocs_resultado
	for i in range(50):
		_min._zone_quota.clear()
		_min._test_t_usec += 3000000
		_min.intentar_extraccion_en(rn, t4, out)
	_check(out.get("ok", false) == true, "K3 out (dict del caller) queda relleno con ok=true")
	_check(out.has("zona") and String(out.get("zona", "")) == "templo", "K3 out trae la zona resuelta")
	var delta: int = _min._allocs_resultado - allocs_antes
	_check(delta == 0, "K3 el hot path NO asigna dicts de resultado (delta=%d en 50 golpes)" % delta)
	_min._test_t_usec += 3000000
	var r: Dictionary = _min.intentar_extraccion(rn, t4)
	_check(bool(r.get("ok", false)), "K3 el wrapper de compatibilidad sigue devolviendo el contrato")
	_check(_min._allocs_resultado == allocs_antes + 1, "K3 el wrapper de compat asigna 1 dict (delta=%d)" % (_min._allocs_resultado - allocs_antes))
	# Identidad (los Dictionary comparan por VALOR con ==; se prueba mutando).
	r["marca_test"] = 1
	_check(not out.has("marca_test"), "K3 el wrapper NO devuelve el buffer del hot path (mutarlo no afecta a out)")
	_min._test_t_usec = -1

## ── K5 + L7 + H17: barrido de regeneracion iterativo ────────────────────────

func _test_barrido() -> void:
	_min._vetas_parciales.clear()
	_recuperadas.clear()
	_min.mina_veta_recuperada.connect(_on_recuperada)
	var def_comun: ResourceDefinition = _rm.obtener_def(&"veta_cobre")        # 2 golpes
	var def_rara: ResourceDefinition = _rm.obtener_def(&"veta_ancestral")     # 6 golpes, rareza 3
	var rn1 := _nodo_de(def_comun, Vector3(200, 0, 0))
	var rn2 := _nodo_de(def_rara, Vector3(210, 0, 0))
	var rn3 := _nodo_de(def_comun, Vector3(220, 0, 0))   # NO agotada
	rn1.estado = ResourceNode.Estado.AGOTADO
	rn1.golpes_restantes = 0
	rn1.programar_respawn(10)
	rn2.estado = ResourceNode.Estado.AGOTADO
	rn2.golpes_restantes = 0
	rn2.programar_respawn(10)
	var hijos_antes: int = root.get_child_count()
	var res: Dictionary = _min.barrido_regeneracion([rn1, rn2, rn3], 10, 0)
	var hijos_despues: int = root.get_child_count()
	_check(int(res.get("evaluados", -1)) == 3, "K5 evalua las 3 vetas")
	_check(int(res.get("respawnados", -1)) == 2, "K5 respawnean solo las 2 agotadas")
	_check(hijos_despues == hijos_antes, "K5 NO crea nodos (hijos %d -> %d)" % [hijos_antes, hijos_despues])
	_check(rn1.estado == ResourceNode.Estado.INTACTO, "K5 rn1 vuelve a INTACTO")
	_check(rn1.golpes_restantes == 2, "H17 rn1 (comun, def=2) queda con 2 golpes")
	_check(rn2.golpes_restantes == 6, "H17 rn2 (ancestral, def=6) queda con 6, NO 2 (defecto M15 corregido en M35)")
	_check(rn3.estado == ResourceNode.Estado.INTACTO and rn3.golpes_restantes == 2, "K5 la veta no agotada no se toca")
	_check(_recuperadas.size() == 2, "L7 emite 2 anuncios de recuperacion (got %d)" % _recuperadas.size())
	var dorados: int = 0
	var comunes: int = 0
	for e in _recuperadas:
		var d: Dictionary = e
		if bool(d.get("anuncio", false)):
			dorados += 1
		else:
			comunes += 1
	_check(dorados == 1 and comunes == 1, "L7 anuncio dorado solo para la rara (dorados=%d comunes=%d)" % [dorados, comunes])
	_min.mina_veta_recuperada.disconnect(_on_recuperada)

## ── K6: profiler del golpe <= 1 ms ──────────────────────────────────────────

func _test_profiler() -> void:
	_min._zone_quota.clear()
	_min._test_t_usec = 1000000
	var def: ResourceDefinition = _rm.obtener_def(&"veta_hierro")
	var t2 := ToolData.crear(ToolData.Tipo.PICO, ToolData.Nivel.HIERRO)
	var rn := _nodo_de(def, Vector3(300, 0, 0))
	rn.golpes_restantes = 1000000
	var r: Dictionary = _min.benchmark_golpe(rn, t2, 30)
	var mediana: float = float(r.get("mediana_us", -1.0))
	var maximo: float = float(r.get("max_us", -1.0))
	_check(int(r.get("n", 0)) == 30, "K6 el benchmark corre 30 golpes")
	_check(mediana >= 0.0, "K6 hay una mediana medida")
	print("K6 MEDIDO: mediana=%.1f us | max=%.1f us | presupuesto=%d us (headless, log DOM-MIN off, sin stdout en el tramo)" % [mediana, maximo, HIT_BUDGET_US])
	_check(mediana < float(HIT_BUDGET_US), "K6 la mediana (%.1f us) esta bajo el presupuesto de %d us" % [mediana, HIT_BUDGET_US])
	_min._test_t_usec = -1

## ── K7: definiciones compartidas (instancia unica) ──────────────────────────

func _test_compartidas() -> void:
	var info: Dictionary = _min.definiciones_compartidas()
	_check(int(info.get("ids", 0)) == 6, "K7 las 6 vetas del catalogo resuelven (got %d)" % int(info.get("ids", 0)))
	_check(int(info.get("instancia_unica", -1)) == int(info.get("ids", 0)), "K7 todas son instancia unica (sin copias)")
	var a: ResourceDefinition = _rm.obtener_def(&"veta_cobre")
	var b: ResourceDefinition = _rm.obtener_def(&"veta_cobre")
	_check(a == b and is_same(a, b), "K7 obtener_def devuelve la MISMA referencia (memoria unica)")

## ── L5: derrumbe controlado cozy ────────────────────────────────────────────

func _test_derrumbe() -> void:
	_min._zone_quota.clear()
	_derrumbes_n = 0
	_min.mina_derrumbe.connect(_on_derrumbe)
	_min._test_t_usec = 1000000
	var def: ResourceDefinition = _rm.obtener_def(&"veta_cobre")   # 2 golpes
	var t1 := ToolData.crear(ToolData.Tipo.PICO, ToolData.Nivel.COBRE)
	var rn := _nodo_de(def, Vector3(400, 0, 0))
	for i in range(2):
		_min._test_t_usec += 3000000
		_min.intentar_extraccion(rn, t1)
	_check(rn.estado == ResourceNode.Estado.AGOTADO, "L5 la veta se agota")
	_check(_derrumbes_n == 1, "L5 emite 1 derrumbe al agotarse (got %d)" % _derrumbes_n)
	_check(_min.derrumbe_activo(rn), "L5 el derrumbe esta activo justo al agotarse")
	_min._test_t_usec += 900000   # +0.9 s > DERRUMBE_DURACION_S (0.8)
	_check(not _min.derrumbe_activo(rn), "L5 el derrumbe termina a los 0.9 s (suave y breve)")
	# una veta NO agotada no tiene derrumbe
	var rn2 := _nodo_de(def, Vector3(410, 0, 0))
	_check(not _min.derrumbe_activo(rn2), "L5 una veta intacta no tiene derrumbe")
	_min.mina_derrumbe.disconnect(_on_derrumbe)
	_min._test_t_usec = -1

## ── L6 + L8: brillo decreciente y texto flotante ────────────────────────────

func _test_brillo_texto() -> void:
	var intacta: float = _min.intensidad_brillo(&"veta_cobre", 1.0)
	var media: float = _min.intensidad_brillo(&"veta_cobre", 0.5)
	var agotada: float = _min.intensidad_brillo(&"veta_cobre", 0.0)
	_check(intacta > media and media > agotada, "L6 el brillo decrece con lo que queda (%.3f > %.3f > %.3f)" % [intacta, media, agotada])
	_check(is_equal_approx(agotada, 0.0), "L6 veta agotada -> brillo 0 (se apaga)")
	_check(is_equal_approx(intacta, 1.0), "L6 veta comun intacta -> brillo 1")
	var rara_intacta: float = _min.intensidad_brillo(&"veta_ancestral", 1.0)
	_check(rara_intacta > intacta, "L6 las vetas raras brillan mas (%.3f > %.3f)" % [rara_intacta, intacta])
	_check(is_equal_approx(_min.intensidad_brillo(&"veta_cobre", 5.0), 1.0), "L6 fraccion fuera de rango se satura")
	_check(_min.texto_flotante(&"veta_cobre", 2) == "+2 Veta de Cobre", "L8 texto flotante exacto")
	_check(_min.texto_flotante(&"veta_ancestral", 1) == "+1 Mineral Ancestral", "L8 texto flotante de la rara")
	_check(_min.texto_flotante(&"inexistente", 3) == "+3 inexistente", "L8 fallback al id si no hay definicion")

## ── L9: vibracion opcional ──────────────────────────────────────────────────

func _test_vibracion() -> void:
	_min._zone_quota.clear()
	_vib_n = 0
	_min.mina_vibracion.connect(_on_vibracion)
	_min.configurar_vibracion(true)
	_min._test_t_usec = 1000000
	var def: ResourceDefinition = _rm.obtener_def(&"veta_cobre")
	var t1 := ToolData.crear(ToolData.Tipo.PICO, ToolData.Nivel.COBRE)
	var rn := _nodo_de(def, Vector3(500, 0, 0))
	_min._test_t_usec += 3000000
	var r1: Dictionary = _min.intentar_extraccion(rn, t1)
	_check(bool(r1.get("ok", false)), "L9 primer golpe aceptado")
	_check(_vib_n == 1, "L9 vibracion ON -> emite (n=%d)" % _vib_n)
	_min.configurar_vibracion(false)
	_min._test_t_usec += 3000000
	var r2: Dictionary = _min.intentar_extraccion(rn, t1)
	_check(bool(r2.get("ok", false)), "L9 segundo golpe aceptado (la prueba no es vacua)")
	_check(_vib_n == 1, "L9 vibracion OFF -> NO emite (n=%d)" % _vib_n)
	_check(_min.vibracion_habilitada == false, "L9 el flag queda en false")
	_min.configurar_vibracion(true)
	_check(_min.vibracion_habilitada == true, "L9 el flag vuelve a true (opcional)")
	_min.mina_vibracion.disconnect(_on_vibracion)
	_min._test_t_usec = -1

## ── I1: vetas por region (capa ancestral solo en M26) ───────────────────────

func _test_region() -> void:
	var templo: Array = _min.vetas_de_region(&"templo")
	_check(templo.size() == 2, "I1 la region templo tiene 2 vetas (got %d)" % templo.size())
	_check(templo.has(&"veta_ancestral") and templo.has(&"veta_polvo_estrellas"), "I1 las 2 son ancestral/polvo")
	var cantera: Array = _min.vetas_de_region(&"cantera")
	_check(cantera.size() == 3, "I1 la region cantera tiene 3 vetas (got %d)" % cantera.size())
	var cueva: Array = _min.vetas_de_region(&"cueva")
	_check(cueva.size() == 1 and cueva.has(&"veta_cristal"), "I1 la region cueva tiene veta_cristal")
	_check(_min.vetas_de_region(&"inexistente").is_empty(), "I1 region desconocida -> vacio")
	var cat: Array = MiningVeinCatalog.leer_catalogo()
	_check(cat.size() == 6, "I1 el catalogo tiene 6 entradas (got %d)" % cat.size())
	var ancestrales: int = 0
	var solo_templo: bool = true
	for e in cat:
		var d: Dictionary = e
		if String(d.get("profundidad_banda", "")) == "ancestral":
			ancestrales += 1
			if String(d.get("region", "")) != "templo":
				solo_templo = false
	_check(ancestrales == 2, "I1 hay 2 minerales de banda ancestral (got %d)" % ancestrales)
	_check(solo_templo, "I1 la banda ancestral SOLO existe en la region templo (cuevas M26)")

## ── I5 + G5: anti-softlock y soporte (anti-flotamiento) ─────────────────────

func _test_softlock_soporte() -> void:
	var zona := AABB(Vector3(-5, -5, -5), Vector3(10, 10, 10))
	_check(not _min.validar_anti_softlock(Vector3(0, 0, 0), [zona]), "I5 veta dentro de un mecanismo -> INVALIDO")
	_check(_min.validar_anti_softlock(Vector3(50, 0, 0), [zona]), "I5 veta fuera -> valida")
	_check(_min.validar_anti_softlock(Vector3(0, 0, 0), []), "I5 sin zonas protegidas -> valida")
	var debajo := Callable(self, "_solido_abajo")
	var nada := Callable(self, "_nada_solido")
	var al_lado := Callable(self, "_solido_al_lado")
	_check(_min.veta_tiene_soporte(Vector3(0, 0, 0), debajo), "G5 con bloque solido debajo -> NO flota")
	_check(not _min.veta_tiene_soporte(Vector3(0, 0, 0), nada), "G5 sin apoyo -> flotaria (INVALIDO)")
	_check(_min.veta_tiene_soporte(Vector3(0, 0, 0), al_lado), "G5 el apoyo lateral tambien cuenta")
	_check(not _min.veta_tiene_soporte(Vector3(0, 0, 0), Callable()), "G5 lector invalido -> false (no asume soporte)")

## ── G10: chunks editados no regeneran vetas ─────────────────────────────────

func _test_chunks() -> void:
	_min._chunks_editados.clear()
	_check(_min.debe_regenerar_vetas("0,0"), "G10 chunk virgen -> regenera")
	_min.marcar_chunk_editado("0,0")
	_check(not _min.debe_regenerar_vetas("0,0"), "G10 chunk editado -> NO regenera")
	_check(_min.debe_regenerar_vetas("1,0"), "G10 otro chunk sigue regenerando")
	_check(_min.chunks_editados() == 1, "G10 cuenta 1 chunk editado (got %d)" % _min.chunks_editados())
	_min.marcar_chunk_editado("0,0")
	_check(_min.chunks_editados() == 1, "G10 marcar dos veces no duplica")
	_min.marcar_chunk_editado("")
	_check(_min.chunks_editados() == 1, "G10 clave vacia se ignora")

## ── I8: coleccion de minerales del jugador ──────────────────────────────────

func _test_coleccion() -> void:
	_min._coleccion.clear()
	_min._zone_quota.clear()
	_min._test_t_usec = 1000000
	_check(_min.coleccion_minerales().is_empty(), "I8 la coleccion arranca vacia")
	_min.registrar_en_coleccion("mineral_cobre", 2)
	_check(int(_min.coleccion_minerales().get("mineral_cobre", 0)) == 2, "I8 registra 2")
	_min.registrar_en_coleccion("mineral_cobre", 3)
	_check(int(_min.coleccion_minerales().get("mineral_cobre", 0)) == 5, "I8 acumula (2+3=5)")
	_min.registrar_en_coleccion("x", 0)
	_check(not _min.coleccion_minerales().has("x"), "I8 cantidad 0 no registra")
	var def: ResourceDefinition = _rm.obtener_def(&"veta_cobre")
	var t1 := ToolData.crear(ToolData.Tipo.PICO, ToolData.Nivel.COBRE)
	var rn := _nodo_de(def, Vector3(600, 0, 0))
	for i in range(2):
		_min._test_t_usec += 3000000
		_min.intentar_extraccion(rn, t1)
	_check(rn.estado == ResourceNode.Estado.AGOTADO, "I8 la veta se agota")
	var acumulado: int = int(_min.coleccion_minerales().get("mineral_cobre", 0))
	_check(acumulado > 5, "I8 la extraccion real suma a la coleccion (got %d)" % acumulado)
	var data: Dictionary = _min.get_save_data()
	_check(data.has("coleccion"), "I8 la coleccion se persiste")
	_min._coleccion.clear()
	_min.restore_save_data(data)
	_check(int(_min.coleccion_minerales().get("mineral_cobre", 0)) == acumulado, "I8 la coleccion sobrevive al save/load")
	_min._test_t_usec = -1
