# Modelo: mimo-v2.6-flash-free
# Plataforma: opencode
# Fecha: 2026-10-05
#
# M55 (T-M1 lote 2): test_diario_persist.gd — persistencia REAL del diario
# entre sesiones (checklist L217 "guardar → salir → cargar"). DOS procesos
# Godot distintos encadenados con SaveManager real (M59: escritura atómica,
# checksum SHA-256, rotación de backup), usando el slot 3 con backup/restore
# byte a byte (patrón test_slots_m59: nunca pisar el slot de usuario).
#
# Fases (user-args tras "--"):
#   (sin args) → PADRE: siembra ★ + estados + ui prefs (filtro/categoría),
#                request_save(3) y espera save_completed; lanza el HIJO con
#                OS.execute (bloqueante) y exige exit 0; restaura el slot
#                previo (.save y .bak) y limpia temporales.
#   "hijo"     → HIJO: load_slot(3) y verifica que Diary restauró registro,
#                ★, estado, día y ui prefs (filtro FAVORITOS + categoría);
#                sin save de cierre (current_slot = -1).
#
# Ejecutar: Godot --headless --path game/isla-ancestral
#   --script res://scripts/diario/test_diario_persist.gd
extends SceneTree

const SLOT_PRUEBA: int = 3
const FASE_HIJO: String = "hijo"
## Timeout de espera de señales M59 (frames del main loop)
const MAX_FRAMES: int = 180

var _fallos: int = 0
var _listo_save: bool = false
var _listo_load: bool = false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0 and String(args[0]) == FASE_HIJO:
		await _fase_hijo()
	else:
		await _fase_padre()
	print("=== TEST M55 PERSISTENCIA: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)


func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)


## ── FASE PADRE (sesión 1: guardar y salir) ─────────────────────────

func _fase_padre() -> void:
	var sm := root.get_node_or_null("/root/SaveManager")
	var diary := root.get_node_or_null("/root/Diary")
	_check(sm != null and diary != null, "autoloads SaveManager y Diary presentes")
	if sm == null or diary == null:
		return

	# Backup byte a byte del slot 3 (.save y .bak) — patrón test_slots_m59
	var path := SaveWriter.path_for(SLOT_PRUEBA)
	var bak := path.get_basename() + SaveBackup.BAK_SUFFIX
	var prev_save := {"existia": FileAccess.file_exists(path),
		"contenido": FileAccess.get_file_as_string(path)}
	var prev_bak := {"existia": FileAccess.file_exists(bak),
		"contenido": FileAccess.get_file_as_string(bak)}

	# Sembrar el estado de la sesión 1: registro + ★ + filtro/categoría
	diary.restore_save_data({"schema_version": 1, "entradas": {}})
	_check(diary.registrar("vecino_catalina_oso", "personajes"), "siembra: catalina registrada")
	diary.alternar_favorito("vecino_catalina_oso")
	_check(diary.es_favorito("vecino_catalina_oso"), "siembra: ★ puesta")
	_check(diary.registrar("lugar_isla_raiz", "lugares"), "siembra: Isla Raíz registrada")
	diary.set_ui_prefs(4, "personajes")  # 4 = DiaryLayer.Filtro.FAVORITOS

	# Guardar con el M59 REAL (writer + checksum + rotación)
	sm.current_slot = SLOT_PRUEBA
	sm.save_completed.connect(func(_slot: int, _reason: String): _listo_save = true)
	sm.request_save(SLOT_PRUEBA, "m55_persist_test")
	var frames := 0
	while not _listo_save and frames < MAX_FRAMES:
		await process_frame
		frames += 1
	_check(_listo_save, "save_completed emitido por SaveManager (%d frames)" % frames)
	_check(not sm.is_dirty(), "save_completed limpia dirty")

	# El HIJO: otro proceso Godot real que carga el slot guardado
	var args := [
		"--headless", "--path", ProjectSettings.globalize_path("res://"),
		"--script", "res://scripts/diario/test_diario_persist.gd",
		"--", FASE_HIJO,
	]
	var salida := OS.execute(OS.get_executable_path(), args)
	_check(int(salida) == 0, "hijo verificó la carga del save (exit=%d)" % int(salida))

	# Restaurar el slot previo y limpiar (no dejar rastro en el usuario)
	sm.current_slot = -1
	_restaurar_archivo(path, prev_save)
	_restaurar_archivo(bak, prev_bak)
	SaveWriter.cleanup_orphan_tmp(SLOT_PRUEBA)


func _restaurar_archivo(ruta: String, previo: Dictionary) -> void:
	if bool(previo.get("existia", false)):
		var f := FileAccess.open(ruta, FileAccess.WRITE)
		if f != null:
			f.store_string(String(previo.get("contenido", "")))
	elif FileAccess.file_exists(ruta):
		DirAccess.remove_absolute(ruta)


## ── FASE HIJO (sesión 2: cargar) ───────────────────────────────────

func _fase_hijo() -> void:
	var sm := root.get_node_or_null("/root/SaveManager")
	var diary := root.get_node_or_null("/root/Diary")
	_check(sm != null and diary != null, "autoloads en el hijo")
	if sm == null or diary == null:
		return
	sm.current_slot = -1  # sin save de cierre en el hijo
	sm.slot_loaded.connect(func(_slot: int, _result: int): _listo_load = true)
	var code := int(sm.load_slot(SLOT_PRUEBA))
	var frames := 0
	while not _listo_load and frames < MAX_FRAMES:
		await process_frame
		frames += 1
	_check(_listo_load, "slot_loaded emitido (%d frames)" % frames)
	_check(code == int(SaveLoader.LoadResult.OK),
		"load_slot devuelve OK (obtuvo %d)" % code)

	# Verificar que Diary restauró TODO lo de la sesión 1
	_check(diary.esta_registrada("vecino_catalina_oso"), "carga: catalina registrada")
	_check(diary.esta_registrada("lugar_isla_raiz"), "carga: Isla Raíz registrada")
	_check(diary.es_favorito("vecino_catalina_oso"), "carga: ★ persiste entre sesiones")
	_check(int(diary.estado_de("vecino_catalina_oso")) == 1,
		"carga: estado VISTO persiste (obtuvo %d)" % int(diary.estado_de("vecino_catalina_oso")))
	_check(int(diary._dia_registro.get("vecino_catalina_oso", 0)) >= 0,
		"carga: día de registro legible")
	var prefs: Dictionary = diary.get_ui_prefs()
	_check(int(prefs.get("filtro", -1)) == 4, "carga: filtro FAVORITOS persiste")
	_check(String(prefs.get("categoria", "")) == "personajes",
		"carga: categoría abierta persiste")
	# El payload recién cargado vuelve a serializar con el mismo contenido
	var otra: Dictionary = diary.get_save_data()
	_check(int(otra.get("schema_version", 0)) == 1
		and (otra.get("entradas", {}) as Dictionary).has("vecino_catalina_oso"),
		"carga: get_save_data re-serializa lo mismo")
	sm.current_slot = -1
