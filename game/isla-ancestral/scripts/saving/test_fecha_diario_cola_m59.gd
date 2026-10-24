# Modelo: Step-5-WorkBuddy
# Fecha: 2026-10-23
#
# M59 tanda "fecha distinta / diario 500+ / cola sin GC" — SUITE:
#   L143 "Testear carga en una fecha distinta a la del guardado" [C]
#   L152 "Testear diario 500+ entradas y fotos faltantes (fallback)" [C]
#   L175 "Sin GC pesado ni hitching al encolar" [M]
#
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/saving/test_fecha_diario_cola_m59.gd
#
# Guardia anti-falso-verde de 3 capas (misma doctrina que test_carga_npc_misiones_m59.gd):
#   1) _abrir/_fin(clave) cierra cada bloque: un bloque que no cierra NO corrio.
#   2) CHECKS_MINIMOS: piso MEDIDO en la primera corrida VERDE (no estimado).
#   3) _summary() en call_deferred separado: sobrevive a un SCRIPT ERROR que
#      aborte _run() y decide el exit code. ESPERA la bandera _run_terminado.
#
# Contratos ejercitados (todos REALES, leidos en disco):
#   SaveLoader/SaveManager: el camino de carga NO compara fechas. `meta.last_saved`
#     lo sella SaveManager al escribir (Time.get_datetime_string_from_system) y NO
#     tiene consumidor fuera de los scripts de guardado (medido por grep): la carga
#     en una fecha distinta no resetea, expira ni duplica nada.
#   slot_metadata() expone last_saved y day (SaveSchema.dia_de traduce el dialecto
#     dia/day del proveedor de tiempo M29).
#   DiaryService (autoload "Diary", seccion "diary"): provider real M59
#     (get_save_data -> {schema_version, entradas, ui}); restore_save_data valida
#     cada entrada contra el catalogo (data/diario/diario_catalog.json, 44 entradas)
#     y las Huerfanas se IGNORAN con print (fallback medido, sin crash). El
#     catalogo tiene 44 entradas: "500+ entradas" se ejercita con payload sintetico
#     (44 validas + 456 huerfanas) escrito por SaveWriter.write_atomic (HMAC valido).
#   Fotos: la seccion "photos" = {ids: []} NO tiene proveedor (M56 dueno); los ids
#     son REFERENCIAS, no bytes: un save con 300 ids faltantes carga igual y ocupa
#     poco (relacionado con el [x] "Save tipico < 120 KB").
#   SaveManager.request_save: encolar = append a _queue (Array[Dictionary]); con
#     _writing=true la cola solo crece (sin I/O). Se miden OBJECT_COUNT (allocacion
#     de Objects = lo que el GC de Godot recolecta), MEMORY_STATIC y us por encolado.

extends SceneTree

## Piso de checks. MEDIDO en la corrida VERDE del 2026-10-23 (3 bloques cerrados).
const CHECKS_MINIMOS: int = 45

const SLOT_A: int = 1
const FECHA_VIEJA: String = "2026-09-15 08:30:00"
const FECHA_FUTURA: String = "2027-03-01 00:00:00"

var _checks: int = 0
var _fallos: int = 0
var _cerrados: Array[String] = []
var _abiertos: Dictionary = {}

var _ok_guardados := [0]
var _fail_guardados := [0]

var _saves_previos: Array = []
var _diary_previo: Dictionary = {}
var _hist_previo: Dictionary = {}

## Bandera de fin de _run(): _summary() la espera antes de reportar.
var _run_terminado := false

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

# ── utilidades de reporte ───────────────────────────────────────────────

func _ok(cond: bool, msg: String) -> void:
	_checks += 1
	if cond:
		print("  [ok] %s" % msg)
	else:
		_fallos += 1
		print("  FALLO: %s" % msg)

func _abrir(clave: String, desc: String) -> void:
	_abiertos[clave] = desc
	print("-- bloque %s: %s" % [clave, desc])

func _fin(clave: String) -> void:
	_abiertos.erase(clave)
	_cerrados.append(clave)
	print("-- fin bloque %s" % clave)

func _esperar_guardado() -> bool:
	for i in 120:
		await process_frame
		if _ok_guardados[0] + _fail_guardados[0] > 0:
			return true
	return false

func _snapshot_saves() -> Array:
	var out: Array = []
	var dir := DirAccess.open("user://saves")
	if dir == null:
		return out
	dir.list_dir_begin()
	var f := dir.get_next()
	while f != "":
		if not dir.current_is_dir():
			var fa := FileAccess.open("user://saves/" + String(f), FileAccess.READ)
			if fa != null:
				out.append({"nombre": String(f), "bytes": fa.get_buffer(fa.get_length())})
				fa.close()
		f = dir.get_next()
	dir.list_dir_end()
	return out

func _restore_saves() -> void:
	var dir := DirAccess.open("user://saves")
	if dir == null:
		return
	var actuales: Array = []
	dir.list_dir_begin()
	var f := dir.get_next()
	while f != "":
		if not dir.current_is_dir():
			actuales.append(String(f))
		f = dir.get_next()
	dir.list_dir_end()
	for n in actuales:
		DirAccess.remove_absolute("user://saves/" + String(n))
	for entrada in _saves_previos:
		var e: Dictionary = entrada
		var b: PackedByteArray = e.get("bytes", PackedByteArray())
		var fw := FileAccess.open("user://saves/" + String(e.get("nombre", "")), FileAccess.WRITE)
		if fw != null:
			fw.store_buffer(b)
			fw.close()

func _leer_doc(slot: int) -> Dictionary:
	var content: String = SaveWriter.read_document(SaveWriter.path_for(slot))
	if content == "":
		return {"ok": false, "reason": "documento vacio/ilegible", "payload": null}
	return SaveWriter.parse_document(content)

func _payload_en_disco(slot: int) -> Dictionary:
	var doc: Dictionary = _leer_doc(slot)
	if not bool(doc.get("ok", false)):
		return {}
	var p: Variant = doc.get("payload", null)
	if typeof(p) != TYPE_DICTIONARY:
		return {}
	return p

func _backup() -> void:
	var d := root.get_node_or_null("/root/Diary")
	if d != null:
		_diary_previo = d.get_save_data()
	var h := root.get_node_or_null("/root/Historias")
	if h != null:
		_hist_previo = h.get_save_data()
	_saves_previos = _snapshot_saves()

func _restore() -> void:
	var d := root.get_node_or_null("/root/Diary")
	if d != null and not _diary_previo.is_empty():
		d.restore_save_data(_diary_previo)
	var h := root.get_node_or_null("/root/Historias")
	if h != null and not _hist_previo.is_empty():
		h.restore_save_data(_hist_previo)
	_restore_saves()

# ── bloques ─────────────────────────────────────────────────────────────

## L143: cargar en una fecha distinta a la del guardado no resetea ni expira nada.
func _b1_fecha_distinta(sm) -> void:
	_abrir("1", "L143: carga en fecha distinta - estado preservado, fecha no reescrita")
	var h := root.get_node_or_null("/root/Historias")
	_ok(h != null, "autoload Historias presente")
	if h == null:
		return
	# estado conocido: cadena-faro a mitad de camino
	h.restore_save_data({})
	h.iniciar_cadena("cadena-faro")
	h.reportar_paso("cadena-faro", "hablar", "farero")
	# payload REAL (collect sobre los proveedores vivos) con la fecha de guardado
	# retrocedida un mes: simula un save hecho en otra fecha.
	var base: Dictionary = sm.snapshot.collect("slot_1")
	if typeof(base.get("meta")) != TYPE_DICTIONARY:
		base["meta"] = {}
	var meta: Dictionary = base["meta"]
	meta["last_saved"] = FECHA_VIEJA
	meta["playtime_seconds"] = 12345.0
	if typeof(base.get("time")) == TYPE_DICTIONARY:
		var t: Dictionary = base["time"]
		t["dia"] = 42
		t["day"] = 42
	var escribio: bool = SaveWriter.write_atomic(SLOT_A, base)
	_ok(escribio, "write_atomic con la fecha vieja (HMAC recalculado sobre el payload)")
	var doc: Dictionary = _leer_doc(SLOT_A)
	_ok(bool(doc.get("ok", false)), "el documento en disco verifica su checksum con la fecha vieja")
	var en_disco: Dictionary = _payload_en_disco(SLOT_A)
	_ok(String(en_disco.get("meta", {}).get("last_saved", "")) == FECHA_VIEJA,
		"la fecha vieja quedo sellada en el archivo")
	# carga REAL en la fecha de hoy (distinta a la del guardado)
	var code: int = sm.load_slot(SLOT_A)
	_ok(code == SaveLoader.LoadResult.OK, "la carga devuelve OK con un save de otra fecha (dio %d)" % code)
	_ok(h.esta_activa("cadena-faro"), "la mision a medias sigue activa tras cargar en otra fecha")
	var act: Dictionary = h.get_save_data().get("activas", {})
	var est: Dictionary = act.get("cadena-faro", {})
	_ok(int(est.get("paso_actual", -1)) == 1,
		"paso_actual=1 preservado (progreso NO reseteado por la fecha, dio %d)" % int(est.get("paso_actual", -1)))
	var p2: Dictionary = h.reportar_paso("cadena-faro", "explorar", "faro")
	_ok(bool(p2.get("ok", false)), "el paso siguiente se puede reportar tras cargar en otra fecha")
	# la carga NO reescribe la fecha: el documento sigue con la fecha del guardado
	var post: Dictionary = _payload_en_disco(SLOT_A)
	_ok(String(post.get("meta", {}).get("last_saved", "")) == FECHA_VIEJA,
		"la carga NO reescribe meta.last_saved (sigue la fecha real del guardado)")
	_ok(float(post.get("meta", {}).get("playtime_seconds", -1.0)) == 12345.0,
		"playtime preservado (dio %s)" % float(post.get("meta", {}).get("playtime_seconds", -1.0)))
	var md: Dictionary = sm.slot_metadata(SLOT_A)
	_ok(String(md.get("last_saved", "")) == FECHA_VIEJA,
		"slot_metadata expone la fecha real del guardado (la UI mostraria '%s')" % String(md.get("last_saved", "")))
	_ok(int(md.get("day", -1)) == 42, "slot_metadata.day=42 (dialecto dia_de, dio %d)" % int(md.get("day", -1)))
	_ok(SaveSchema.dia_de(post) == 42, "dia_de(payload en disco)=42 - el dia de juego no se reseteo")
	# variante fecha FUTURA: un save fechado en el futuro tambien carga (no se rechaza por fecha)
	var base2: Dictionary = sm.snapshot.collect("slot_1")
	if typeof(base2.get("meta")) != TYPE_DICTIONARY:
		base2["meta"] = {}
	var meta2: Dictionary = base2["meta"]
	meta2["last_saved"] = FECHA_FUTURA
	var escribio2: bool = SaveWriter.write_atomic(SLOT_A, base2)
	_ok(escribio2, "write_atomic con fecha futura")
	var code2: int = sm.load_slot(SLOT_A)
	_ok(code2 == SaveLoader.LoadResult.OK, "un save con fecha futura carga OK (no se rechaza por fecha, dio %d)" % code2)
	var md2: Dictionary = sm.slot_metadata(SLOT_A)
	_ok(String(md2.get("last_saved", "")) == FECHA_FUTURA, "slot_metadata refleja la fecha futura tal cual")
	# sello NOW: request_save sella la fecha del sistema (regresion del fix de iter. 2,
	# donde meta.last_saved quedaba SIEMPRE vacio y la UI no tenia dato que mostrar)
	_ok_guardados[0] = 0
	_fail_guardados[0] = 0
	sm.request_save(SLOT_A, "tanda_fecha_now")
	var listo := await _esperar_guardado()
	_ok(listo and _ok_guardados[0] >= 1 and _fail_guardados[0] == 0, "request_save completo por la cola real")
	var ahora: Dictionary = _payload_en_disco(SLOT_A)
	var sello: String = String(ahora.get("meta", {}).get("last_saved", ""))
	_ok(sello.length() >= 19 and sello.contains(":"),
		"request_save sella meta.last_saved con la fecha del sistema ('%s')" % sello)
	_fin("1")

## L152: diario con 500+ entradas (huerfanas ignoradas = fallback) y fotos
## faltantes (referencias, no bytes) cargan sin romper nada.
func _b2_diario_500(sm) -> void:
	_abrir("2", "L152: diario 500+ entradas (huerfanas ignoradas) + fotos faltantes (fallback)")
	var d := root.get_node_or_null("/root/Diary")
	_ok(d != null, "autoload Diary presente")
	if d == null:
		return
	_ok(String(d.get_section_name()) == "diary", "seccion de guardado 'diary'")
	# ---- parte 1: roundtrip REAL del catalogo (44 entradas) por el riel real ----
	var texto := FileAccess.get_file_as_string("res://data/diario/diario_catalog.json")
	var parseado: Variant = JSON.parse_string(texto)
	_ok(typeof(parseado) == TYPE_DICTIONARY, "catalogo del diario parseado")
	if typeof(parseado) != TYPE_DICTIONARY:
		return
	var categorias: Array = parseado.get("categorias", [])
	var ids_validos: Array = []
	for c in categorias:
		var cat: Dictionary = c
		for e in cat.get("entradas", []):
			var ent: Dictionary = e
			ids_validos.append([String(cat.get("id", "")), String(ent.get("id", ""))])
	_ok(ids_validos.size() == 44, "catalogo con 44 entradas (dio %d)" % ids_validos.size())
	var registradas := 0
	for par in ids_validos:
		var p: Array = par
		if bool(d.registrar(String(p[1]), String(p[0]))):
			registradas += 1
	_ok(registradas == ids_validos.size(),
		"las 44 entradas del catalogo se registraron en el diario (dio %d)" % registradas)
	var primero: Array = ids_validos[0]
	d.alternar_favorito(String(primero[1]))
	_ok(bool(d.es_favorito(String(primero[1]))), "favorito marcado en '%s'" % String(primero[1]))
	d.set_ui_prefs(1, "personajes")
	_ok_guardados[0] = 0
	_fail_guardados[0] = 0
	sm.request_save(SLOT_A, "tanda_diario_real")
	var listo := await _esperar_guardado()
	_ok(listo and _ok_guardados[0] >= 1 and _fail_guardados[0] == 0, "slot guardado con el diario real (e2e)")
	var code: int = sm.load_slot(SLOT_A)
	_ok(code == SaveLoader.LoadResult.OK or code == SaveLoader.LoadResult.RECOVERED,
		"carga del slot OK/RECOVERED (dio %d)" % code)
	var dd: Dictionary = d.get_save_data()
	var entradas: Dictionary = dd.get("entradas", {})
	_ok(entradas.size() == 44, "las 44 entradas sobreviven la carga real (dio %d)" % entradas.size())
	var ui: Dictionary = dd.get("ui", {})
	_ok(int(ui.get("filtro", -1)) == 1 and String(ui.get("categoria", "")) == "personajes",
		"preferencias de UI del diario restauradas (filtro=%s, categoria='%s')" % [int(ui.get("filtro", -1)), String(ui.get("categoria", ""))])
	_ok(bool(d.es_favorito(String(primero[1]))), "el favorito sobrevive la carga real")
	# ---- parte 2: payload sintetico con 500+ entradas (44 validas + 456 huerfanas) ----
	var base: Dictionary = sm.snapshot.collect("slot_1")
	var sint: Dictionary = {}
	for par2 in ids_validos:
		var q: Array = par2
		sint[String(q[1])] = {"categoria": String(q[0]), "estado": 2, "favorito": false, "dia": 7}
	for i in range(456):
		sint["huerfana_s5_%03d" % i] = {"categoria": "personajes", "estado": 1, "favorito": false, "dia": 0}
	base["diary"] = {"schema_version": 1, "entradas": sint, "ui": {"filtro": 0, "categoria": "sellos"}}
	var escribio: bool = SaveWriter.write_atomic(SLOT_A, base)
	_ok(escribio, "write_atomic con 500 entradas de diario (44 validas + 456 huerfanas)")
	var code2: int = sm.load_slot(SLOT_A)
	_ok(code2 == SaveLoader.LoadResult.OK, "el save con 500+ entradas carga OK (dio %d)" % code2)
	var dd2: Dictionary = d.get_save_data()
	var ent2: Dictionary = dd2.get("entradas", {})
	_ok(ent2.size() == 44,
		"FALLBACK medido: las 456 huerfanas se ignoran y quedan las 44 validas (dio %d)" % ent2.size())
	_ok(not ent2.has("huerfana_s5_000") and not ent2.has("huerfana_s5_455"),
		"ninguna huerfana entra al estado del diario")
	var est2: Dictionary = ent2.get(String(primero[1]), {})
	_ok(int(est2.get("estado", -1)) == 2, "la entrada valida queda COMPLETADO tras la carga (dio %d)" % int(est2.get("estado", -1)))
	var ui2: Dictionary = dd2.get("ui", {})
	_ok(int(ui2.get("filtro", -1)) == 0 and String(ui2.get("categoria", "")) == "sellos",
		"las ui del payload sintetico se restauran (filtro=0, categoria='sellos')")
	# ---- parte 3: fotos faltantes (ids que no existen en user://fotos/) ----
	var fotos: Array = []
	for i in range(300):
		fotos.append("foto_s5_inexistente_%03d" % i)
	var base3: Dictionary = sm.snapshot.collect("slot_1")
	base3["photos"] = {"ids": fotos}
	var escribio3: bool = SaveWriter.write_atomic(SLOT_A, base3)
	_ok(escribio3, "write_atomic con 300 ids de foto")
	var code3: int = sm.load_slot(SLOT_A)
	_ok(code3 == SaveLoader.LoadResult.OK, "un save cuyas fotos NO existen en disco carga igual (dio %d)" % code3)
	var post3: Dictionary = _payload_en_disco(SLOT_A)
	var ids3: Array = post3.get("photos", {}).get("ids", [])
	_ok(ids3.size() == 300, "los 300 ids de foto se preservan en el payload (dio %d)" % ids3.size())
	var contenido: String = SaveWriter.read_document(SaveWriter.path_for(SLOT_A))
	_ok(contenido.length() < 122880,
		"el documento con 500 entradas de diario + 300 fotos ocupa %d B (< 120 KB: referencias, no bytes)" % contenido.length())
	_fin("2")

## L175: encolar no alloca Objects (nada para el GC) ni se acerca al frame budget.
func _b3_cola_sin_gc(sm) -> void:
	_abrir("3", "L175: encolar 1000 peticiones - 0 Objects, us por encolado, sin hitch")
	# resetear los contadores de guardado: el bloque mide SU propia ventana
	# (los e2e de los bloques 1-2 ya los incrementaron)
	_ok_guardados[0] = 0
	_fail_guardados[0] = 0
	var writing_previo: bool = sm._writing
	var cola_previa: int = sm._queue.size()
	sm._writing = true  # aislar el ENCOLADO (sin I/O de por medio)
	var objetos_antes: float = Performance.get_monitor(Performance.OBJECT_COUNT)
	var mem_antes: float = Performance.get_monitor(Performance.MEMORY_STATIC)
	var t_antes: int = Time.get_ticks_usec()
	for i in range(1000):
		sm.request_save(SLOT_A, "test_cola_s5")
	var t_despues: int = Time.get_ticks_usec()
	var objetos_despues: float = Performance.get_monitor(Performance.OBJECT_COUNT)
	var mem_despues: float = Performance.get_monitor(Performance.MEMORY_STATIC)
	var cola_despues: int = sm._queue.size()
	sm._queue.clear()
	sm._writing = writing_previo
	var elapsed_us: int = t_despues - t_antes
	_ok(cola_despues == cola_previa + 1000,
		"las 1000 peticiones quedaron en la cola (dio %d, previas %d)" % [cola_despues, cola_previa])
	_ok(objetos_despues == objetos_antes,
		"0 Objects allocados al encolar (GC de Godot no tiene nada que recolectar; delta %.0f)" % (objetos_despues - objetos_antes))
	_ok(elapsed_us < 16670,
		"1000 encolados en %d us (< 16670 us = 1 frame a 60 FPS: ningun hitch posible)" % elapsed_us)
	_ok(mem_despues - mem_antes < 1048576.0,
		"memoria estatica +%.0f B para 1000 peticiones (< 1 MB: solo los diccionarios del request)" % (mem_despues - mem_antes))
	_ok(_ok_guardados[0] == 0 and _fail_guardados[0] == 0,
		"encolar NO dispara ningun guardado (el I/O es del write, no del enqueue)")
	print("  [info] encolado: %d us total, %.2f us por peticion, %+d Objects, %+d B estaticos" % [
		elapsed_us, float(elapsed_us) / 1000.0, int(objetos_despues - objetos_antes), int(mem_despues - mem_antes)])
	_fin("3")

# ── orquestacion ─────────────────────────────────────────────────────────

func _run() -> void:
	var sm = root.get_node_or_null("/root/SaveManager")
	_ok(sm != null, "SaveManager autoload presente")
	if sm == null:
		_run_terminado = true
		return
	sm.save_completed.connect(func(_s, _r): _ok_guardados[0] += 1)
	sm.save_failed.connect(func(_s, _r): _fail_guardados[0] += 1)
	_backup()
	await _b1_fecha_distinta(sm)
	await _b2_diario_500(sm)
	await _b3_cola_sin_gc(sm)
	_restore()
	_run_terminado = true

## Corre en un call_deferred separado: si _run() aborta por un error de
## runtime, este resumen igual se ejecuta y delata los bloques sin cerrar.
func _summary() -> void:
	for i in 3000:
		if _run_terminado:
			break
		await process_frame
	print("=== RESUMEN M59 FECHA/DIARIO/COLA: %d checks, %d fallos, %d bloques cerrados ===" % [
		_checks, _fallos, _cerrados.size()])
	var abortado := false
	if not _abiertos.is_empty():
		abortado = true
		print("  BLOQUES QUE NO CERRARON (abortados por un error de runtime):")
		for clave in _abiertos.keys():
			print("    - [%s] %s" % [clave, _abiertos[clave]])
	if _checks < CHECKS_MINIMOS:
		abortado = true
		print("  PISO NO CUMPLIDO: %d checks < CHECKS_MINIMOS=%d (suite muerta o recortada)" % [
			_checks, CHECKS_MINIMOS])
	if abortado:
		print("RESULTADO: FALLO (suite incompleta)")
		quit(1)
		return
	if _fallos > 0:
		print("RESULTADO: FALLO (%d)" % _fallos)
		quit(1)
	else:
		print("RESULTADO: OK")
		quit(0)
