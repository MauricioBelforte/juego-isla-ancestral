# Modelo: Step-5-WorkBuddy
# Fecha: 2026-10-23
#
# M59 tanda "save slots + autoguardado" (item 35 de la cola activa) — SUITE A:
# slots, perfiles y archivos con permisos de solo lectura.
#
# Items del 05-Checklist que cierra con evidencia:
#   L51  "Probar 3 perfiles sin mezcla y cambio de slot en plena sesion" [C]
#   L166 "Probar multiples perfiles sin cruzamiento" [C]
#   L167 "Probar archivos con permisos de solo lectura" [M]
#
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/saving/test_slots_perfiles_m59.gd
#
# Guardia anti-falso-verde de 3 capas (misma doctrina que test_slots_m59.gd):
#   1) _fin(clave) cierra cada bloque: un bloque que no cierra NO corrio.
#   2) CHECKS_MINIMOS: piso MEDIDO en la primera corrida VERDE (no estimado).
#   3) _summary() en call_deferred separado: sobrevive a un SCRIPT ERROR que
#      aborte _run() y decide el exit code.
#
# Comportamiento MEDIDO en el entorno (probe previo, 2026-10-23):
#   R1: con slot_N.save marcado solo-lectura (attrib +R), request_save()
#       COMPLETA el guardado: Windows permite rotar el archivo read-only a
#       .bak y el .save nuevo (archivo fresco) verifica. No hay corrupcion.
#   R2: con un DIRECTORIO ocupando la ruta del .tmp, la escritura falla
#       (save_failed), el .save previo queda recuperable desde .bak y
#       load_slot() devuelve RECOVERED.
# El bloque 4 asevera exactamente eso.

extends SceneTree

## Piso de checks. MEDIDO en la primera corrida VERDE (41, 2026-10-23).
const CHECKS_MINIMOS: int = 41

const SLOT_A: int = 1
const SLOT_B: int = 2
const SLOT_C: int = 3

## Items reales del catalogo (verificados en data/items/):
##   baya_roja.stack_max = 99 · iron_ore.stack_max = 99 · herramienta_basica.stack_max = 1
const ITEM_A: String = "baya_roja"
const ITEM_B: String = "iron_ore"
const ITEM_C: String = "herramienta_basica"

const PERFIL_A: String = "perfil_s5_A"
const PERFIL_B: String = "perfil_s5_B"
const PERFIL_C: String = "perfil_s5_C"

## Contenedor BOLSILLO (ContainerType.Id.BOLSILLO = 0).
const BOLSILLO: int = 0

var _checks: int = 0
var _fallos: int = 0
var _cerrados: Array[String] = []
var _abiertos: Dictionary = {}

var _ok_guardados := [0]
var _fail_guardados := [0]
var _ultimo_slot_fallado := [-1]

var _slot_previo: Dictionary = {}
var _bak_previo: Dictionary = {}
var _inv_previo: Array = []
var _perfil_previo: String = ""
## Bandera de fin de _run(): _summary() la espera antes de reportar (run usa
## awaits; sin esto el resumen corria en el primer frame y su quit() mataba el
## proceso a mitad de la suite — medido 2026-10-23).
var _run_terminado := false

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

# ── utilidades de reporte ────────────────────────────────────────────────

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

## True si la salida de `attrib <path>` muestra el flag R en la columna de
## atributos (lo que esta ANTES de la unidad "C:"). Buscar "R" en toda la
## linea daria siempre true: la ruta contiene "Roaming".
func _attrib_tiene_r(salida: Array) -> bool:
	if salida.is_empty():
		return false
	var linea: String = String(salida[0])
	var idx: int = linea.find(":")
	if idx < 0:
		return false
	return linea.substr(0, idx).contains("R")

# ── preservacion del estado real (no pisar saves de otras suites) ────────

func _backup() -> void:
	for slot in [SLOT_A, SLOT_B, SLOT_C]:
		var path: String = SaveWriter.path_for(slot)
		if FileAccess.file_exists(path):
			_slot_previo[slot] = FileAccess.get_file_as_string(path)
		var bak: String = SaveSchema.SAVE_DIR + "/slot_%d_r1.bak" % slot
		_bak_previo[slot] = FileAccess.file_exists(bak)
	var ds := root.get_node_or_null("/root/DataStore")
	if ds != null and ds.has_method("get_perfil_activo"):
		_perfil_previo = String(ds.get_perfil_activo())
	var inv := root.get_node_or_null("/root/Inventario")
	if inv != null and inv.contenedores.has(BOLSILLO):
		_inv_previo = inv.contenedores[BOLSILLO].serializar()

func _restore() -> void:
	# Desactivar el guardado de cierre: el manager escribe si current_slot >= 1.
	var sm = root.get_node_or_null("/root/SaveManager")
	if sm != null:
		sm.current_slot = -1
	for slot in [SLOT_A, SLOT_B, SLOT_C]:
		var path: String = SaveWriter.path_for(slot)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
		if bool(_slot_previo.get(slot, false)):
			var f := FileAccess.open(path, FileAccess.WRITE)
			if f != null:
				f.store_string(String(_slot_previo[slot]))
				f.close()
		SaveWriter.cleanup_orphan_tmp(slot)
		var bak: String = SaveSchema.SAVE_DIR + "/slot_%d_r1.bak" % slot
		if FileAccess.file_exists(bak) and not bool(_bak_previo.get(slot, false)):
			DirAccess.remove_absolute(bak)
	var ds := root.get_node_or_null("/root/DataStore")
	if ds != null and ds.has_method("set_perfil_activo"):
		ds.set_perfil_activo(_perfil_previo)
	var inv := root.get_node_or_null("/root/Inventario")
	if inv != null:
		inv.restore_save_data({str(BOLSILLO): _inv_previo})

## Espera a que la cola de guardado complete una peticion (senal).
func _esperar_guardado() -> bool:
	for i in 120:
		await process_frame
		if _ok_guardados[0] + _fail_guardados[0] > 0:
			return true
	return false

func _limpiar_bolsillo() -> void:
	var inv := root.get_node_or_null("/root/Inventario")
	if inv != null:
		inv.restore_save_data({str(BOLSILLO): []})

# ── bloques ──────────────────────────────────────────────────────────────

## L51 (parte 1): 3 perfiles, cada uno con su slot, SIN mezcla de contenidos.
func _b1_tres_perfiles(sm) -> void:
	_abrir("1", "3 perfiles sin mezcla: sello por slot y contenidos separados")
	var ds := root.get_node_or_null("/root/DataStore")
	_limpiar_bolsillo()
	# perfil A -> slot 1
	ds.set_perfil_activo(PERFIL_A)
	var inv := root.get_node_or_null("/root/Inventario")
	inv.add_item(ITEM_A, 5)
	_ok_guardados[0] = 0
	_fail_guardados[0] = 0
	sm.request_save(SLOT_A, "tanda_perfil_A")
	var listo_a := await _esperar_guardado()
	_ok(listo_a and _ok_guardados[0] >= 1 and _fail_guardados[0] == 0,
		"slot 1 guardado con perfil_A (senal save_completed)")
	var meta_a: Dictionary = sm.slot_metadata(SLOT_A)
	_ok(String(meta_a.get("profile_id", "")) == PERFIL_A,
		"sello profile_id == perfil_A en slot 1 (dio '%s')" % String(meta_a.get("profile_id", "")))
	_ok(String(meta_a.get("last_saved", "")) != "",
		"last_saved sellado por el manager en slot 1")
	# perfil B -> slot 2
	_limpiar_bolsillo()
	ds.set_perfil_activo(PERFIL_B)
	inv.add_item(ITEM_B, 7)
	_ok_guardados[0] = 0
	_fail_guardados[0] = 0
	sm.request_save(SLOT_B, "tanda_perfil_B")
	var listo_b := await _esperar_guardado()
	_ok(listo_b and _ok_guardados[0] >= 1,
		"slot 2 guardado con perfil_B (senal save_completed)")
	var meta_b: Dictionary = sm.slot_metadata(SLOT_B)
	_ok(String(meta_b.get("profile_id", "")) == PERFIL_B,
		"sello profile_id == perfil_B en slot 2 (dio '%s')" % String(meta_b.get("profile_id", "")))
	# perfil C -> slot 3
	_limpiar_bolsillo()
	ds.set_perfil_activo(PERFIL_C)
	inv.add_item(ITEM_C, 1)
	_ok_guardados[0] = 0
	_fail_guardados[0] = 0
	sm.request_save(SLOT_C, "tanda_perfil_C")
	var listo_c := await _esperar_guardado()
	_ok(listo_c and _ok_guardados[0] >= 1,
		"slot 3 guardado con perfil_C (senal save_completed)")
	var meta_c: Dictionary = sm.slot_metadata(SLOT_C)
	_ok(String(meta_c.get("profile_id", "")) == PERFIL_C,
		"sello profile_id == perfil_C en slot 3 (dio '%s')" % String(meta_c.get("profile_id", "")))
	# cargar el slot de A: solo deben venir los contenidos de A
	ds.set_perfil_activo(PERFIL_A)
	var codigos: Array = []
	var cb := func(slot: int, code: int) -> void:
		if slot == SLOT_A:
			codigos.append(code)
	sm.slot_loaded.connect(cb)
	var code: int = sm.load_slot(SLOT_A)
	sm.slot_loaded.disconnect(cb)
	_ok(code == SaveLoader.LoadResult.OK or code == SaveLoader.LoadResult.RECOVERED,
		"carga del slot 1 con perfil_A -> OK/RECOVERED (dio %d)" % code)
	_ok(codigos.has(SaveLoader.LoadResult.OK) or codigos.has(SaveLoader.LoadResult.RECOVERED),
		"la senal slot_loaded lleva el resultado de la carga")
	_ok(inv.count_item(ITEM_A) == 5, "bolsillo con los 5 %s de perfil_A (dio %d)" % [ITEM_A, inv.count_item(ITEM_A)])
	_ok(inv.count_item(ITEM_B) == 0, "SIN mezcla: 0 %s del perfil_B (dio %d)" % [ITEM_B, inv.count_item(ITEM_B)])
	_ok(inv.count_item(ITEM_C) == 0, "SIN mezcla: 0 %s del perfil_C (dio %d)" % [ITEM_C, inv.count_item(ITEM_C)])
	_fin("1")

## L51 (parte 2): cambio de slot en plena sesion (sin reiniciar el juego).
func _b2_cambio_slot(sm) -> void:
	_abrir("2", "cambio de slot en plena sesion: current_slot y contenidos siguen al slot")
	var ds := root.get_node_or_null("/root/DataStore")
	var inv := root.get_node_or_null("/root/Inventario")
	ds.set_perfil_activo(PERFIL_B)
	var code_b: int = sm.load_slot(SLOT_B)
	_ok(code_b == SaveLoader.LoadResult.OK or code_b == SaveLoader.LoadResult.RECOVERED,
		"carga del slot 2 en sesion -> OK/RECOVERED (dio %d)" % code_b)
	_ok(sm.current_slot == SLOT_B, "current_slot pasa a 2 (dio %d)" % sm.current_slot)
	_ok(String(ds.get_perfil_activo()) == PERFIL_B,
		"el perfil activo pasa a ser el del slot cargado (%s)" % String(ds.get_perfil_activo()))
	_ok(inv.count_item(ITEM_B) == 7, "bolsillo con los 7 %s del slot 2 (dio %d)" % [ITEM_B, inv.count_item(ITEM_B)])
	_ok(inv.count_item(ITEM_A) == 0, "SIN mezcla: el slot 1 deja de estar en el bolsillo (dio %d)" % inv.count_item(ITEM_A))
	ds.set_perfil_activo(PERFIL_C)
	var code_c: int = sm.load_slot(SLOT_C)
	_ok(code_c == SaveLoader.LoadResult.OK or code_c == SaveLoader.LoadResult.RECOVERED,
		"carga del slot 3 en sesion -> OK/RECOVERED (dio %d)" % code_c)
	_ok(sm.current_slot == SLOT_C, "current_slot pasa a 3 (dio %d)" % sm.current_slot)
	_ok(inv.count_item(ITEM_C) == 1, "bolsillo con el %s del slot 3 (dio %d)" % [ITEM_C, inv.count_item(ITEM_C)])
	_ok(inv.count_item(ITEM_B) == 0, "SIN mezcla: 0 %s tras el cambio (dio %d)" % [ITEM_B, inv.count_item(ITEM_B)])
	_fin("2")

## L166: multiples perfiles sin cruzamiento (rechazo sin restaurar nada).
func _b3_sin_cruzamiento(sm) -> void:
	_abrir("3", "sin cruzamiento: un perfil no carga el slot de otro")
	var ds := root.get_node_or_null("/root/DataStore")
	var inv := root.get_node_or_null("/root/Inventario")
	ds.set_perfil_activo(PERFIL_A)
	var codigos: Array = []
	var cb := func(slot: int, code: int) -> void:
		if slot == SLOT_B:
			codigos.append(code)
	sm.slot_loaded.connect(cb)
	var r1: int = sm.load_slot(SLOT_B)
	sm.slot_loaded.disconnect(cb)
	_ok(r1 == SaveLoader.LoadResult.PROFILE_MISMATCH,
		"perfil_A sobre el slot de perfil_B -> PROFILE_MISMATCH (dio %d)" % r1)
	_ok(codigos.has(SaveLoader.LoadResult.PROFILE_MISMATCH),
		"la senal slot_loaded avisa a la UI del rechazo")
	_ok(sm.current_slot == SLOT_C, "current_slot NO cambia tras el rechazo (sigue %d)" % sm.current_slot)
	_ok(inv.count_item(ITEM_C) == 1, "el rechazo NO restaura: el bolsillo queda del slot 3 (dio %d)" % inv.count_item(ITEM_C))
	ds.set_perfil_activo(PERFIL_C)
	var r2: int = sm.load_slot(SLOT_A)
	_ok(r2 == SaveLoader.LoadResult.PROFILE_MISMATCH,
		"perfil_C sobre el slot de perfil_A -> PROFILE_MISMATCH (dio %d)" % r2)
	var r3: int = sm.load_slot(SLOT_C)
	_ok(r3 == SaveLoader.LoadResult.OK or r3 == SaveLoader.LoadResult.RECOVERED,
		"el slot propio de perfil_C carga OK/RECOVERED (dio %d)" % r3)
	_fin("3")

## L167: archivos con permisos de solo lectura.
## R1 (medido): el flag read-only sobre el .save anterior NO impide el guardado
## (Windows permite rotarlo); el .save nuevo es fresco y verifica.
## R2 (medido): escritura realmente bloqueada -> fallo graceful + recuperacion.
func _b4_solo_lectura(sm) -> void:
	_abrir("4", "solo lectura: save anterior read-only y escritura bloqueada")
	var ds := root.get_node_or_null("/root/DataStore")
	var dir_abs: String = ProjectSettings.globalize_path(SaveSchema.SAVE_DIR)
	var save_abs: String = (dir_abs + "/slot_%d.save" % SLOT_A).replace("/", "\\")
	var tmp_abs: String = dir_abs + "/slot_%d.tmp" % SLOT_A
	var bak_abs: String = dir_abs + "/slot_%d_r1.bak" % SLOT_A
	var en_windows: bool = OS.get_name() == "Windows"

	# --- R1: .save marcado solo-lectura antes de guardar ---
	ds.set_perfil_activo(PERFIL_A)
	_ok_guardados[0] = 0
	_fail_guardados[0] = 0
	sm.request_save(SLOT_A, "tanda_ro_base")
	var listo_base := await _esperar_guardado()
	_ok(listo_base and _ok_guardados[0] >= 1, "R1: save base del slot 1 completo")
	var ro_aplicado := false
	var ro_estado_antes: Array = []
	if en_windows:
		# El flag se aplica con un .bat generado al vuelo: pasar "+R" como
		# argumento directo a attrib se mangla desde OS.execute (medido).
		var bat_path: String = ProjectSettings.globalize_path("user://_s5_setro.bat")
		var fb := FileAccess.open(bat_path, FileAccess.WRITE)
		if fb != null:
			fb.store_string("@attrib +R %1\r\n")
			fb.close()
		var out := []
		OS.execute("cmd", ["/c", bat_path, save_abs], out)
		OS.execute("cmd", ["/c", "attrib", save_abs], ro_estado_antes)
		ro_aplicado = _attrib_tiene_r(ro_estado_antes)
		print("  [info] R1 attrib antes: %s" % str(ro_estado_antes))
	if en_windows:
		_ok(ro_aplicado, "R1: flag de solo-lectura aplicado sobre el .save")
	else:
		print("  [info] R1 omitido: plataforma no-Windows")
	_ok_guardados[0] = 0
	_fail_guardados[0] = 0
	sm.request_save(SLOT_A, "tanda_ro")
	var listo_ro := await _esperar_guardado()
	if en_windows:
		_ok(listo_ro and _ok_guardados[0] >= 1 and _fail_guardados[0] == 0,
			"R1: el guardado COMPLETA pese al .save read-only (medido: Windows permite rotarlo)")
		var doc: Dictionary = SaveWriter.parse_document(FileAccess.get_file_as_string(SaveWriter.path_for(SLOT_A)))
		_ok(bool(doc.get("ok", false)), "R1: el .save nuevo verifica (checksum OK, sin corrupcion)")
		var ro_estado_despues: Array = []
		OS.execute("cmd", ["/c", "attrib", save_abs], ro_estado_despues)
		_ok(not _attrib_tiene_r(ro_estado_despues),
			"R1: el .save nuevo es un archivo fresco (sin flag heredado)")
		# limpieza del flag sobre .save y .bak (el .bak rotado lo hereda)
		var bat_off: String = ProjectSettings.globalize_path("user://_s5_unsetro.bat")
		var fb2 := FileAccess.open(bat_off, FileAccess.WRITE)
		if fb2 != null:
			fb2.store_string("@attrib -R %1\r\n")
			fb2.close()
		var o1 := []
		OS.execute("cmd", ["/c", bat_off, save_abs], o1)
		var o2 := []
		OS.execute("cmd", ["/c", bat_off, bak_abs], o2)

	# --- R2: escritura bloqueada (directorio en la ruta del .tmp) ---
	_ok_guardados[0] = 0
	_fail_guardados[0] = 0
	sm.request_save(SLOT_A, "tanda_ro_base2")
	var listo_base2 := await _esperar_guardado()
	_ok(listo_base2 and _ok_guardados[0] >= 1, "R2: save base del slot 1 completo")
	var d := DirAccess.open(dir_abs)
	var mk_ok: bool = d != null and d.make_dir_recursive("slot_%d.tmp" % SLOT_A) == OK
	_ok(mk_ok, "R2: bloqueo determinista creado (directorio en la ruta del .tmp)")
	_ok_guardados[0] = 0
	_fail_guardados[0] = 0
	_ultimo_slot_fallado[0] = -1
	var cb_fail := func(slot: int, _r: String) -> void:
		_ultimo_slot_fallado[0] = slot
	sm.save_failed.connect(cb_fail)
	sm.request_save(SLOT_A, "tanda_blocked")
	var fallo := await _esperar_guardado()
	sm.save_failed.disconnect(cb_fail)
	_ok(fallo and _fail_guardados[0] >= 1 and _ok_guardados[0] == 0,
		"R2: la escritura bloqueada FALLA sin excepcion (senal save_failed)")
	_ok(_ultimo_slot_fallado[0] == SLOT_A, "R2: save_failed nombra el slot 1")
	_ok(not SaveWriter.save_exists(SLOT_A),
		"R2: el .save quedo ausente (fue rotado a .bak antes del fallo, no hay save a medias)")
	var doc_bak: Dictionary = SaveWriter.parse_document(SaveWriter.read_document(bak_abs))
	_ok(bool(doc_bak.get("ok", false)), "R2: el .bak del save anterior verifica (checksum OK)")
	var code_rec: int = sm.load_slot(SLOT_A)
	_ok(code_rec == SaveLoader.LoadResult.RECOVERED or code_rec == SaveLoader.LoadResult.OK,
		"R2: load_slot recupera desde el .bak (dio %d, RECOVERED=3)" % code_rec)
	# limpieza OBLIGATORIA: un directorio en la ruta del .tmp romperia todo
	# guardado futuro del slot (cleanup_orphan_tmp solo borra archivos).
	var borrado := DirAccess.remove_absolute(tmp_abs) == OK
	var dir_tmp := DirAccess.open(dir_abs)
	var sigue := dir_tmp != null and dir_tmp.dir_exists("slot_%d.tmp" % SLOT_A)
	_ok(borrado and not sigue,
		"R2: el directorio bloqueante fue eliminado (el slot queda guardable)")
	_fin("4")

# ── orquestacion ─────────────────────────────────────────────────────────

func _run() -> void:
	var sm = root.get_node_or_null("/root/SaveManager")
	_ok(sm != null, "SaveManager autoload presente")
	if sm == null:
		return
	sm.save_completed.connect(func(_s, _r): _ok_guardados[0] += 1)
	sm.save_failed.connect(func(_s, _r): _fail_guardados[0] += 1)
	_backup()
	await _b1_tres_perfiles(sm)
	await _b2_cambio_slot(sm)
	await _b3_sin_cruzamiento(sm)
	await _b4_solo_lectura(sm)
	_restore()
	_run_terminado = true

## Corre en un call_deferred separado: si _run() aborta por un error de
## runtime, este resumen igual se ejecuta y delata los bloques sin cerrar.
## ESPERA a que _run() termine (run tiene awaits): si _run aborta, la bandera
## no se prende y el resumen sale tras el limite de frames con los bloques
## sin cerrar nombrados.
func _summary() -> void:
	for i in 3000:
		if _run_terminado:
			break
		await process_frame
	print("=== RESUMEN M59 SLOTS/PERFILES: %d checks, %d fallos, %d bloques cerrados ===" % [
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
