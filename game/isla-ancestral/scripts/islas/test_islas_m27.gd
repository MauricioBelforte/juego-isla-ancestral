# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-11
#
# M27: Islas del Mundo — test headless (iter. 1).
# Cubre el núcleo verificable sin GPU: definición, anillos, registro (carga,
# orden, duplicados), fallback de `.tres` faltante, anclas, vecinas,
# descubrimiento/persistencia y el contrato de IslandProps.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://scripts/islas/test_islas_m27.gd

extends SceneTree

var _checks: int = 0
var _fallos: int = 0
var _bloque: String = ""

## Disposición de anclas de REFERENCIA (misma que documenta generar_islas.gd).
## No se serializa: la pone M10 en runtime. Acá se usa para validar geometría.
const LAYOUT := {
	"aurora": Vector3i(0, 0, 0),
	"coral": Vector3i(0, 0, 1100),
	"verde": Vector3i(-953, 0, -550),
	"pequena": Vector3i(953, 0, -550),
	"cenizas": Vector3i(2078, 0, 1200),
	"desierto": Vector3i(-2078, 0, 1200),
	"flotante": Vector3i(0, 0, -2400),
	"cielo": Vector3i(4400, 0, 0),
	"nieve": Vector3i(2200, 0, 3811),
	"volcanica": Vector3i(-2200, 0, 3811),
	"submarina": Vector3i(-4400, 0, 0),
	"misteriosa": Vector3i(-2200, 0, -3811),
	"secreta": Vector3i(2200, 0, -3811),
}

const TMP_DEFS := "user://test_m27_defs"
const TMP_VACIO := "user://test_m27_vacio"
const TMP_ARCH := "user://test_m27_arch.tres"

var _reg: Node = null


func _init() -> void:
	call_deferred("_run")


func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s" % nombre)


func _bloque_nombre(t: String) -> void:
	_bloque = t
	print("-- %s" % t)


func _run() -> void:
	print("=== [M27] Test Islas del Mundo (iter. 1) ===")
	_reg = root.get_node_or_null("IslandRegistry")
	if _reg == null:
		print("  [FALLO] IslandRegistry no es un autoload accesible")
		print("=== Resumen M27: 1 checks, 1 fallos ===")
		quit(1)
		return

	_test_anillos()
	_test_definicion()
	_test_carga()
	_test_fallback()
	_test_anclas()
	_test_vecinas()
	_test_descubrimiento()
	_test_props()
	_test_geometria()
	_test_integracion_guardado()
	_test_coherencia_legacy()

	print("=== Resumen M27: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)


## ── A. Anillos ────────────────────────────────────────────

func _test_anillos() -> void:
	_bloque_nombre("A. IslandRing")
	_check("NUCLEO=0 CERCANO=1 MEDIO=2 LEJANO=3",
		IslandRing.NUCLEO == 0 and IslandRing.CERCANO == 1
		and IslandRing.MEDIO == 2 and IslandRing.LEJANO == 3)
	_check("nombre(2) == MEDIO", IslandRing.nombre(2) == "MEDIO")
	_check("desde_nombre('lejano') == LEJANO", IslandRing.desde_nombre("lejano") == IslandRing.LEJANO)
	_check("desde_nombre('zzz') == -1", IslandRing.desde_nombre("zzz") == -1)
	_check("es_valido(4) == false", not IslandRing.es_valido(4))
	_check("es_valido(-1) == false", not IslandRing.es_valido(-1))
	_check("radio_vecindad(NUCLEO) == 0", IslandRing.radio_vecindad(IslandRing.NUCLEO) == 0)
	_check("radio_vecindad(CERCANO) > 0", IslandRing.radio_vecindad(IslandRing.CERCANO) > 0)
	_check("distancia_max_anillo crece por anillo",
		IslandRing.distancia_max_anillo(IslandRing.CERCANO)
		< IslandRing.distancia_max_anillo(IslandRing.MEDIO)
		and IslandRing.distancia_max_anillo(IslandRing.MEDIO)
		< IslandRing.distancia_max_anillo(IslandRing.LEJANO))
	_check("REQUIERE_PROGRESO: NUCLEO/CERCANO libres",
		not IslandRing.REQUIERE_PROGRESO[IslandRing.NUCLEO]
		and not IslandRing.REQUIERE_PROGRESO[IslandRing.CERCANO]
		and IslandRing.REQUIERE_PROGRESO[IslandRing.LEJANO])


## ── B. IslandDefinition ───────────────────────────────────

func _test_definicion() -> void:
	_bloque_nombre("B. IslandDefinition.validar()")
	var base: IslandDefinition = _reg.get_isla(&"aurora")
	_check("aurora es una definición cargada", base != null)
	_check("aurora válida", base.es_valida())
	_check("catálogo M09 tiene 13 biomas", IslandDefinition.BIOMAS.size() == 13)
	_check("bioma_nombre(2) == Bosque", IslandDefinition.bioma_nombre(2) == "Bosque")
	_check("bioma_nombre(99) == Desconocido", IslandDefinition.bioma_nombre(99) == "Desconocido")
	_check("aurora.bioma_base_nombre() == Bosque", base.bioma_base_nombre() == "Bosque")

	# Casos rotos: cada uno debe ser capturado por validar().
	_check("radio<=0 capturado", _valida_con(base, "radio", 0))
	_check("altura invertida capturada", _valida_con(base, "altura_max", base.altura_min - 1))
	_check("altura_min negativa capturada", _valida_con(base, "altura_min", -1))
	_check("bioma_base fuera de catálogo capturado", _valida_con(base, "bioma_base", 13))
	_check("anillo inválido capturado", _valida_con(base, "anillo", 9))
	_check("playa se come el radio capturada", _valida_con(base, "playa_ancho", base.radio))
	_check("id vacío capturado", _valida_con(base, "id", &""))
	_check("NUCLEO secreta capturada", _valida_con(base, "es_secreta", true))
	_check("mezcla desalineada capturada", _valida_con(base, "proporciones_mezcla", _floats([])))
	_check("proporciones que no suman 1 capturadas",
		_valida_con(base, "proporciones_mezcla", _floats([0.1, 0.1, 0.1, 0.1])))
	_check("punto de llegada fuera del disco capturado",
		_valida_con(base, "punto_llegada", Vector3i(base.radio * 2, 3, 0)))

	# Isla flotante con punto bajo la losa.
	var flot: IslandDefinition = _reg.get_isla(&"flotante")
	_check("flotante válida", flot != null and flot.es_valida())
	_check("flotante con punto bajo la losa capturada",
		_valida_con(flot, "punto_llegada", Vector3i(20, flot.altura_max - 1, 0)))


## Clona `base` (vía .tres en memoria no hace falta: se duplica el Resource),
## muta un campo y devuelve true si validar() reporta algún error.
func _valida_con(base: IslandDefinition, campo: String, valor: Variant) -> bool:
	var copia: IslandDefinition = base.duplicate(true)
	copia.set(campo, valor)
	return not copia.validar().is_empty()


func _floats(v: Array) -> Array[float]:
	var out: Array[float] = []
	for x in v:
		out.append(float(x))
	return out


## ── C. Carga del registro ─────────────────────────────────

func _test_carga() -> void:
	_bloque_nombre("C. IslandRegistry — carga")
	var inf: Dictionary = _reg.cargar_definiciones()
	_check("registry cargado", _reg.esta_cargado())
	_check("13 islas cargadas (1 + 12)", _reg.contar() == 13)
	_check("informe: cargadas == 13", int(inf.get("cargadas", -1)) == 13)
	_check("informe: esperadas == 13", int(inf.get("esperadas", -1)) == 13)
	_check("informe: sin faltantes", (inf.get("faltantes", []) as Array).is_empty())
	_check("informe: sin extra", (inf.get("extra", []) as Array).is_empty())
	_check("informe: sin duplicados", _reg.duplicados().is_empty())
	_check("informe: sin errores de carga", _reg.errores_carga().is_empty())
	_check("informe: ok == true", bool(inf.get("ok", false)))
	_check("isla principal es aurora", _reg.isla_principal() != null
		and _reg.isla_principal().id == &"aurora")
	_check("aurora es NUCLEO", _reg.get_isla(&"aurora").anillo == IslandRing.NUCLEO)

	var ids: Array[StringName] = _reg.ids()
	_check("13 ids", ids.size() == 13)
	var ordenado: bool = true
	for i in range(1, ids.size()):
		if String(ids[i - 1]) > String(ids[i]):
			ordenado = false
	_check("orden determinista (alfabético por id)", ordenado)
	_reg.cargar_definiciones()
	var ids2: Array[StringName] = _reg.ids()
	_check("orden estable entre dos cargas", ids == ids2)
	_check("todas_las_islas() == contar()", _reg.todas_las_islas().size() == _reg.contar())
	_check("get_isla(inexistente) == null", _reg.get_isla(&"no_existe") == null)
	_check("tiene_isla('coral')", _reg.tiene_isla(&"coral"))
	_check("tiene_isla('no_existe') == false", not _reg.tiene_isla(&"no_existe"))
	_check("12 satélites + núcleo", _reg.contar() - 1 == 12)


## ── D. Fallback de .tres faltante ─────────────────────────

func _test_fallback() -> void:
	_bloque_nombre("D. Fallback .tres faltante")
	# El índice declara 2 islas pero sólo existe aurora.tres en la carpeta temp.
	DirAccess.make_dir_recursive_absolute(TMP_DEFS)
	DirAccess.make_dir_recursive_absolute(TMP_VACIO)
	var origen: String = "%s/aurora.tres" % _reg.RUTA_DEFINICIONES
	var destino: String = "%s/aurora.tres" % TMP_DEFS
	var err: int = DirAccess.copy_absolute(origen, destino)
	_check("copiar aurora.tres a carpeta temporal", err == OK or FileAccess.file_exists(destino))

	var arch := Archipielago.new()
	arch.id_principal = &"aurora"
	arch.islas_esperadas = PackedStringArray(["aurora", "coral"])
	_check("guardar índice temporal", ResourceSaver.save(arch, TMP_ARCH) == OK)

	_reg._test_rutas(TMP_DEFS, TMP_ARCH)
	var inf: Dictionary = _reg.cargar_definiciones()
	_check("sólo carga la que existe (1)", _reg.contar() == 1)
	_check("detecta 'coral' como faltante", (inf.get("faltantes", []) as Array).has("coral"))
	_check("informe ok == false con faltante", not bool(inf.get("ok", true)))
	_check("Aurora SIEMPRE carga pese al faltante", _reg.isla_principal() != null)

	# Carpeta vacía + índice que exige aurora → error de isla principal.
	var arch2 := Archipielago.new()
	arch2.id_principal = &"aurora"
	arch2.islas_esperadas = PackedStringArray(["aurora"])
	ResourceSaver.save(arch2, TMP_ARCH)
	_reg._test_rutas(TMP_VACIO, TMP_ARCH)
	var inf2: Dictionary = _reg.cargar_definiciones()
	_check("carpeta vacía: 0 islas", _reg.contar() == 0)
	_check("carpeta vacía: sin isla principal", _reg.isla_principal() == null)
	_check("carpeta vacía: informe ok == false", not bool(inf2.get("ok", true)))
	var tiene_error_principal: bool = false
	for e in _reg.errores_carga():
		if String(e).contains("isla principal"):
			tiene_error_principal = true
	_check("loguea ERROR por isla principal ausente", tiene_error_principal)

	# Restaurar el dataset real.
	_reg._test_rutas("", "")
	_reg.cargar_definiciones()
	_check("dataset real restaurado (13)", _reg.contar() == 13)
	_check("sin errores tras restaurar", _reg.errores_carga().is_empty())

	# Comparador de índice (mecanismo puro).
	var cmp: Dictionary = arch2.comparar(["aurora", "coral"])
	_check("comparar(): sin faltantes si aurora está", (cmp.get("faltantes", []) as Array).is_empty())
	_check("comparar() detecta 1 extra (coral)", (cmp.get("extra", []) as Array) == ["coral"])
	var cmp2: Dictionary = arch2.comparar(["coral"])
	_check("comparar() detecta faltante (aurora)", (cmp2.get("faltantes", []) as Array) == ["aurora"])
	_check("comparar() ok == false con faltante", not bool(cmp2.get("ok", true)))

	# Limpieza de fixtures (viven bajo /Godot/, que está gitignoreado).
	DirAccess.remove_absolute(destino)
	DirAccess.remove_absolute(TMP_ARCH)
	DirAccess.remove_absolute(TMP_DEFS)
	DirAccess.remove_absolute(TMP_VACIO)


## ── E. Anclas ─────────────────────────────────────────────

func _test_anclas() -> void:
	_bloque_nombre("E. Anclas (M10)")
	_check("semilla_de_isla determinista",
		_reg.semilla_de_isla(4242, &"coral") == _reg.semilla_de_isla(4242, &"coral"))
	_check("semilla_de_isla distinta por id",
		_reg.semilla_de_isla(4242, &"coral") != _reg.semilla_de_isla(4242, &"nieve"))
	_check("semilla_de_isla distinta por partida",
		_reg.semilla_de_isla(1, &"coral") != _reg.semilla_de_isla(2, &"coral"))
	_check("semilla_de_isla >= 0", _reg.semilla_de_isla(-7, &"x") >= 0)

	_check("antes de anclar: tiene_ancla == false", not _reg.tiene_ancla(&"coral"))
	var err_anclar: bool = _reg.anclar(&"coral", LAYOUT["coral"], 4242)
	_check("anclar() devuelve true", err_anclar)
	_check("tras anclar: tiene_ancla == true", _reg.tiene_ancla(&"coral"))
	_check("posicion_ancla devuelve el ancla", _reg.posicion_ancla(&"coral") == LAYOUT["coral"])
	_check("posicion_ancla con cache (2ª llamada igual)", _reg.posicion_ancla(&"coral") == LAYOUT["coral"])
	_check("anclar() isla desconocida == false", not _reg.anclar(&"no_existe", Vector3i.ZERO, 1))

	# Anclar todas según el layout.
	for id in LAYOUT.keys():
		_reg.anclar(StringName(id), LAYOUT[id], 4242)
	var errores: Array[String] = _reg.validar_anclas()
	_check("validar_anclas() sin errores con layout de referencia", errores.is_empty())
	if not errores.is_empty():
		for e in errores:
			print("    · %s" % e)

	# Aurora descentrada → error.
	_reg.anclar(&"aurora", Vector3i(900, 0, 900), 4242)
	_check("detecta Aurora fuera del centro", not _reg.validar_anclas().is_empty())
	_reg.anclar(&"aurora", Vector3i.ZERO, 4242)
	_check("vuelve a ser válido al recentrar Aurora", _reg.validar_anclas().is_empty())

	# Solapamiento: mover cenizas encima de coral (mismo anillo distinto).
	var ancla_cenizas: Vector3i = LAYOUT["cenizas"]
	_reg.anclar(&"cenizas", LAYOUT["coral"] + Vector3i(10, 0, 0), 4242)
	var err_solape: Array[String] = _reg.validar_anclas()
	var detecta: bool = false
	for e in err_solape:
		if String(e).contains("solapamiento") and String(e).contains("coral") and String(e).contains("cenizas"):
			detecta = true
	_check("detecta solapamiento coral/cenizas", detecta)
	_reg.anclar(&"cenizas", ancla_cenizas, 4242)

	# Anillo incoherente: una CERCANO a 5000 del centro.
	_reg.anclar(&"pequena", Vector3i(5000, 0, 0), 4242)
	var err_anillo: Array[String] = _reg.validar_anclas()
	var detecta_anillo: bool = false
	for e in err_anillo:
		if String(e).contains("pequena") and String(e).contains("demasiado lejos"):
			detecta_anillo = true
	_check("detecta isla CERCANO demasiado lejos", detecta_anillo)
	_reg.anclar(&"pequena", LAYOUT["pequena"], 4242)

	# Ancla faltante → reporte explícito.
	_reg._test_definir(_def_minima(&"fantasma", IslandRing.CERCANO))
	_check("reporta isla sin ancla", not _reg.validar_anclas().is_empty())
	_check("anclas_validas() == false con isla sin ancla", not _reg.anclas_validas())
	# Limpiar el fantasma: recargar el registro real.
	_reg.cargar_definiciones()
	for id in LAYOUT.keys():
		_reg.anclar(StringName(id), LAYOUT[id], 4242)
	_check("anclas_validas() == true tras limpiar", _reg.anclas_validas())


func _def_minima(id: StringName, anillo: int) -> IslandDefinition:
	var d := IslandDefinition.new()
	d.id = id
	d.nombre_display = String(id)
	d.radio = 100
	d.altura_min = 0
	d.altura_max = 40
	d.playa_ancho = 8
	d.bioma_base = 1
	d.anillo = anillo
	return d


## ── F. Vecinas ────────────────────────────────────────────

func _test_vecinas() -> void:
	_bloque_nombre("F. Vecinas (streaming M63)")
	_anclar_todo()
	var v_coral: Array[IslandDefinition] = _reg.vecinas(&"coral")
	_check("coral tiene >= 2 vecinas", v_coral.size() >= 2)
	_check("verde es vecina de coral", _contiene(v_coral, &"verde"))
	_check("pequena es vecina de coral", _contiene(v_coral, &"pequena"))
	_check("coral no es vecina de sí misma", not _contiene(v_coral, &"coral"))
	var v_cercano: Array[IslandDefinition] = _reg.vecinas(&"coral", IslandRing.CERCANO)
	_check("corte CERCANO excluye anillos mayores (cenizas fuera)",
		not _contiene(v_cercano, &"cenizas") and not _contiene(v_cercano, &"nieve"))
	_check("corte CERCANO conserva verde y pequena",
		_contiene(v_cercano, &"verde") and _contiene(v_cercano, &"pequena"))
	_check("corte CERCANO incluye aurora (NUCLEO, d=1100 <= 2200)",
		_contiene(v_cercano, &"aurora") and v_cercano.size() == 3)
	var v_aurora: Array[IslandDefinition] = _reg.vecinas(&"aurora")
	_check("NUCLEO: vecinas = todas las demás (12)", v_aurora.size() == 12)
	var v_aurora_c: Array[IslandDefinition] = _reg.vecinas(&"aurora", IslandRing.CERCANO)
	_check("NUCLEO con corte CERCANO = 3", v_aurora_c.size() == 3)
	_check("vecinas(inexistente) vacío", _reg.vecinas(&"no_existe").is_empty())


func _contiene(lista: Array, id: StringName) -> bool:
	for d in lista:
		if d.id == id:
			return true
	return false


## Repone el layout de anclas de referencia sobre el catálogo cargado.
func _anclar_todo() -> void:
	for id in LAYOUT.keys():
		_reg.anclar(StringName(id), LAYOUT[id], 4242)


## ── G. Descubrimiento / persistencia ──────────────────────

func _test_descubrimiento() -> void:
	_bloque_nombre("G. Descubrimiento / persistencia (M54/M59)")
	_reg._test_limpiar()
	_check("aurora siempre descubierta", _reg.esta_descubierta(&"aurora"))
	_check("coral no descubierta al inicio", not _reg.esta_descubierta(&"coral"))
	_check("descubrir(coral) == true", _reg.descubrir(&"coral"))
	_check("descubrir(coral) 2ª vez == false", not _reg.descubrir(&"coral"))
	_check("coral ahora descubierta", _reg.esta_descubierta(&"coral"))
	_check("descubrir(inexistente) == false", not _reg.descubrir(&"no_existe"))
	_check("visitar(nieve) == true", _reg.visitar(&"nieve"))
	_check("visitar marca visitada", _reg.esta_visitada(&"nieve"))
	_check("visitar implica descubrir", _reg.esta_descubierta(&"nieve"))
	_check("visitar(nieve) 2ª vez == false", not _reg.visitar(&"nieve"))
	_check("visible_en_mapa(secreta) == false sin descubrir", not _reg.visible_en_mapa(&"secreta"))
	_reg.descubrir(&"secreta")
	_check("visible_en_mapa(secreta) == true tras descubrir", _reg.visible_en_mapa(&"secreta"))
	_check("visible_en_mapa(inexistente) == false", not _reg.visible_en_mapa(&"no_existe"))

	# Anti-aliasing (BUG-014): el snapshot no debe ser una referencia viva.
	var snap: Dictionary = _reg.get_save_data()
	(snap["descubiertas"] as Array).append("inyectado")
	(snap["visitadas"] as Array).append("inyectado")
	var snap2: Dictionary = _reg.get_save_data()
	_check("get_save_data() no expone referencias vivas",
		not (snap2["descubiertas"] as Array).has("inyectado")
		and not (snap2["visitadas"] as Array).has("inyectado"))
	_check("sección de guardado == 'islas'", _reg.get_section_name() == "islas")

	# Round-trip.
	var guardado: Dictionary = _reg.get_save_data()
	_reg._test_limpiar()
	_check("estado limpio tras _test_limpiar", _reg.islas_descubiertas().is_empty())
	_reg.restore_save_data(guardado)
	_check("round-trip: coral descubierta", _reg.esta_descubierta(&"coral"))
	_check("round-trip: nieve visitada", _reg.esta_visitada(&"nieve"))
	_check("round-trip: secreta descubierta", _reg.esta_descubierta(&"secreta"))
	_check("round-trip: no resucita ids inexistentes",
		not _reg.esta_visitada(&"fantasma"))

	# Desbloqueo (M22): sin WorldState, una isla con flag queda bloqueada.
	_check("aurora siempre desbloqueada", _reg.esta_desbloqueada(&"aurora"))
	_check("isla CERCANO sin flag desbloqueada", _reg.esta_desbloqueada(&"coral"))
	_check("isla con flag bloqueada sin WorldState", not _reg.esta_desbloqueada(&"nieve"))
	_check("isla inexistente no desbloqueada", not _reg.esta_desbloqueada(&"no_existe"))
	_reg._test_limpiar()


## ── H. IslandProps ────────────────────────────────────────

func _test_props() -> void:
	_bloque_nombre("H. IslandProps")
	var props := IslandProps.new()
	_check("sin spawners: tipos_registrados() vacío", props.tipos_registrados().is_empty())
	_check("registrar flora", props.registrar_spawner(IslandProps.TIPO_FLORA, _spawner_conteo))
	_check("registrar fauna", props.registrar_spawner(IslandProps.TIPO_FAUNA, _spawner_conteo))
	_check("registrar recurso", props.registrar_spawner(IslandProps.TIPO_RECURSO, _spawner_conteo))
	_check("registrar poi", props.registrar_spawner(IslandProps.TIPO_POI, _spawner_conteo))
	_check("tiene_spawner(flora)", props.tiene_spawner(IslandProps.TIPO_FLORA))
	_check("tipos_registrados == 4", props.tipos_registrados().size() == 4)
	_check("tipo desconocido rechazado",
		not props.registrar_spawner(&"magia", _spawner_conteo))
	_check("Callable inválido rechazado",
		not props.registrar_spawner(IslandProps.TIPO_FLORA, Callable()))

	var coral: IslandDefinition = _reg.get_isla(&"coral")
	_check("materializar(null) falla", not bool(props.materializar(null).get("ok", true)))
	# Sin ancla no se materializa (requisito 86).
	_reg.cargar_definiciones()
	var inf_sin: Dictionary = props.materializar(_reg.get_isla(&"coral"))
	_check("sin ancla no materializa", not bool(inf_sin.get("ok", true)))
	_check("sin ancla: informe con error", not (inf_sin.get("errores", []) as Array).is_empty())

	_reg.anclar(&"coral", LAYOUT["coral"], 4242)
	coral = _reg.get_isla(&"coral")
	var inf: Dictionary = props.materializar(coral)
	_check("materializar ok con ancla", bool(inf.get("ok", false)))
	_check("invoca los 4 tipos", (inf.get("invocados", []) as Array).size() == 4)
	_check("semilla de props > 0", int(inf.get("semilla", 0)) > 0)
	var conteo: Dictionary = inf.get("props", {}) as Dictionary
	_check("flora = 2 (alga_coral, palma_coral)", int(conteo.get("flora", -1)) == 2)
	_check("fauna = 3", int(conteo.get("fauna", -1)) == 3)
	_check("recursos = 3", int(conteo.get("recurso", -1)) == 3)
	_check("poi = 1 (buceo_arrecife)", int(conteo.get("poi", -1)) == 1)
	_check("esta_materializada(coral)", props.esta_materializada(&"coral"))
	_check("conteo_props(coral) tiene 4 tipos", props.conteo_props(&"coral").size() == 4)

	# Determinismo: misma semilla → mismo conteo.
	var semilla_1: int = props.semilla_props(coral)
	props.limpiar(&"coral")
	_check("limpiar() olvida la isla", not props.esta_materializada(&"coral"))
	var inf2: Dictionary = props.materializar(coral)
	_check("semilla de props determinista", int(inf2.get("semilla", 0)) == semilla_1)
	_check("conteo determinista entre materializaciones",
		(inf2.get("props", {}) as Dictionary) == conteo)

	# Zona se propaga al contexto. OJO: las lambdas de GDScript capturan por
	# VALOR; para observar el contexto se usa un Dictionary (tipo referencia).
	var captura: Dictionary = {}
	var props2 := IslandProps.new()
	props2.registrar_spawner(IslandProps.TIPO_FLORA, func(_i, c): captura["ctx"] = c; return 0)
	props2.materializar(coral, 3)
	var ctx_zona: Dictionary = captura.get("ctx", {}) as Dictionary
	_check("zona se propaga al contexto", int(ctx_zona.get("zona", -1)) == 3)
	_check("contexto lleva bounds de la isla", ctx_zona.has("bounds") and ctx_zona.has("centro"))
	_check("semilla_zona != 0 con zona >= 0", int(ctx_zona.get("semilla_zona", 0)) != 0)

	# Isla sin contenido exclusivo → tipos omitidos.
	var vacia := _def_minima(&"vacia", IslandRing.CERCANO)
	vacia.ancla = Vector3i.ZERO
	vacia.ancla_asignada = true
	var inf_vacia: Dictionary = props.materializar(vacia)
	_check("isla sin contenido omite todos los tipos",
		(inf_vacia.get("invocados", []) as Array).is_empty()
		and (inf_vacia.get("omitidos", []) as Array).size() == 4)

	# Spawner que devuelve int (no Dictionary).
	var props3 := IslandProps.new()
	props3.registrar_spawner(IslandProps.TIPO_FLORA, func(_i, c): return (c["items"] as PackedStringArray).size())
	var inf3: Dictionary = props3.materializar(coral)
	_check("spawner que devuelve int se contabiliza",
		int((inf3.get("props", {}) as Dictionary).get("flora", -1)) == 2)
	props.limpiar_todo()
	_check("limpiar_todo() vacía el estado", not props.esta_materializada(&"coral"))


func _spawner_conteo(_isla: IslandDefinition, ctx: Dictionary) -> Dictionary:
	return {"spawneados": (ctx["items"] as PackedStringArray).size()}


## ── I. Geometría ──────────────────────────────────────────

func _test_geometria() -> void:
	_bloque_nombre("I. Geometría (bounds/centro/puertos)")
	_anclar_todo()
	var aurora: IslandDefinition = _reg.get_isla(&"aurora")
	var b: Rect2i = aurora.bounds_locales()
	_check("bounds aurora = 512x512", b.size == Vector2i(512, 512))
	_check("bounds aurora centrado en ancla", b.position == Vector2i(-256, -256))
	var c: Vector3 = aurora.centro_mundo()
	_check("centro_mundo aurora y = (0+140)/2", is_equal_approx(c.y, 70.0))
	_check("centro_mundo aurora x/z = ancla", c.x == 0.0 and c.z == 0.0)
	var coords: Rect2i = _reg.coordenadas_por_isla(&"aurora")
	_check("coordenadas_por_isla == bounds_locales", coords == b)
	_check("coordenadas_por_isla(inexistente) vacío", _reg.coordenadas_por_isla(&"no_existe").size == Vector2i.ZERO)
	var llegada: Vector3 = aurora.punto_llegada_mundo()
	_check("punto_llegada_mundo = ancla + local",
		llegada.x == float(aurora.ancla.x + aurora.punto_llegada.x)
		and llegada.z == float(aurora.ancla.z + aurora.punto_llegada.z))
	_check("punto_partida_mundo = ancla + local",
		aurora.punto_partida_mundo().z == float(aurora.ancla.z + aurora.punto_partida.z))
	_check("distancia_a(aurora, coral) == 1100", is_equal_approx(aurora.distancia_a(_reg.get_isla(&"coral")), 1100.0))
	_check("distancia_a(null) == INF", aurora.distancia_a(null) == INF)
	_check("huella() estable", aurora.huella() == aurora.huella())
	_check("a_diccionario() trae id y anillo",
		String(aurora.a_diccionario().get("id", "")) == "aurora"
		and String(aurora.a_diccionario().get("anillo", "")) == "NUCLEO")


## ── J. Integración con el guardado (M59) ──────────────────

func _test_integracion_guardado() -> void:
	_bloque_nombre("J. Integración con M59 (sección 'islas')")
	var sm = root.get_node_or_null("SaveManager")
	if sm == null:
		_check("SaveManager disponible", false)
		return
	_check("SaveManager disponible", true)
	if sm.snapshot == null:
		_check("snapshot disponible", false)
		return
	_reg._test_limpiar()
	_reg.descubrir(&"coral")
	_reg.visitar(&"nieve")
	var payload: Dictionary = sm.snapshot.collect("")
	_check("el payload de guardado incluye la sección 'islas'", payload.has("islas"))
	var sec: Dictionary = payload.get("islas", {}) as Dictionary
	_check("la sección trae 'descubiertas'", sec.has("descubiertas"))
	_check("la sección trae 'visitadas'", sec.has("visitadas"))
	_check("la sección refleja el estado real",
		(sec.get("descubiertas", []) as Array).has("coral")
		and (sec.get("visitadas", []) as Array).has("nieve"))
	# Añadir la sección 'islas' no rompe el schema base de M59.
	var base_ok: bool = true
	for b in ["schema_version", "profile_id", "world", "player", "inventory"]:
		if not payload.has(b):
			base_ok = false
	_check("el schema base de M59 conserva sus bloques", base_ok)
	_check("el payload conserva 'schema_version'", payload.has("schema_version"))
	_reg._test_limpiar()


## ── K. Coherencia con el dataset legacy ───────────────────
func _test_coherencia_legacy() -> void:
	_bloque_nombre("K. Coherencia con islas.json legacy")
	var txt: String = FileAccess.get_file_as_string("res://data/islas/islas.json")
	var cfg: Variant = JSON.parse_string(txt)
	_check("islas.json parseable", typeof(cfg) == TYPE_DICTIONARY)
	if typeof(cfg) != TYPE_DICTIONARY:
		return
	var legacy: Dictionary = (cfg as Dictionary).get("islas", {})
	_check("islas.json declara 4 islas", legacy.size() == 4)
	# Las 4 legacy son las 4 de Aurora/Coral/Ceniza... el nuevo catálogo las
	# cubre con ids largos; verificamos que el núcleo y Coral existen.
	_check("el catálogo nuevo incluye la principal (aurora)", _reg.tiene_isla(&"aurora"))
	_check("el catálogo nuevo incluye coral", _reg.tiene_isla(&"coral"))
	_check("el catálogo nuevo es superset (>= 13)", _reg.contar() >= 13)
	# El schema legacy sigue siendo válido (no lo rompimos).
	var schema: GDScript = load("res://scripts/islas/islas_schema.gd")
	_check("IslasSchema.validar_islas sigue OK",
		schema != null and (schema.validar_islas(cfg) as Array).is_empty())
