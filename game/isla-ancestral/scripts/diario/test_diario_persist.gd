# Modelo: mimo-v2.6-flash-free (autor original) | guardián: DeepSeek-V4.1-Flash (2026-10-29)
# Plataforma: opencode / WorkBuddy
# Fecha: 2026-10-05 (creación) / 2026-10-29 (guardián de 3 capas)
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
# GUARDIÁN DE 3 CAPAS (GO del director, msg 450 punto 3):
#   Antes esta suite imprimía `=== TEST M55 PERSISTENCIA: 0 fallo(s) ===` SIN
#   contador, sin piso y sin `_summary()`: un `SCRIPT ERROR` que abortara una
#   fase dejaba menos checks ejecutados y el proceso salía EXIT 0 con "0 fallo(s)"
#   (falso verde latente). Ahora:
#     1. `_checks` se incrementa en CADA `_check()` (no solo al fallar).
#     2. `CHECKS_MINIMOS_*` por fase, MEDIDO en verde (los dos procesos no miden
#        lo mismo: el padre tiene sus propios checks + los del hijo).
#     3. `_summary()` corre aunque `_run()` aborte (`_arrancar()` -> `await _run()`
#        -> `_summary()`; NO se difiere `_summary()` desde `_init()` porque con
#        `await` en `_run()` correría en el PRIMER await y declararía fallo).
#     4. Marcadores `_fin()` por fase: nombra la fase que no llegó a cerrar.
#     5. El HIJO deja su reporte de checks en un JSON (temp). Sin eso su
#        cobertura es INVISIBLE para el padre, que solo vería el exit code.
#     6. El slot 3 del usuario se restaura desde `_summary()` si una fase aborta
#        a mitad: antes, un aborto dejaba el save del usuario pisado.
#
# Ejecutar: Godot --headless --path game/isla-ancestral
#   --script res://scripts/diario/test_diario_persist.gd
extends SceneTree

const SLOT_PRUEBA: int = 3
const FASE_HIJO: String = "hijo"
const FASE_PADRE: String = "padre"
## Timeout de espera de señales M59 (frames del main loop)
const MAX_FRAMES: int = 180

## Piso de checks MEDIDO en verde, POR FASE (el padre y el hijo no miden lo mismo).
## Se re-mide cada vez que la suite crece. No se estima.
const CHECKS_MINIMOS_PADRE: int = 10
const CHECKS_MINIMOS_HIJO: int = 11

## Bloques esperados por fase (marcadores `_fin()`).
const BLOQUES_PADRE := ["padre"]
const BLOQUES_HIJO := ["hijo"]

## Reporte del hijo: sin esto, cuánto verificó el hijo es invisible para el padre.
const NOMBRE_REPORTE_HIJO: String = "isla_diario_persist_hijo.json"

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}
var _terminado: bool = false
var _cerrado: bool = false
var _fase: String = FASE_PADRE
var _listo_save: bool = false
var _listo_load: bool = false
## Backup del slot 3 del usuario. `_backup_capturado` distingue "no hay nada que
## restaurar" de "hay que restaurar un archivo que no existía" (borrarlo).
var _backup_capturado: bool = false
var _restaurado: bool = false
var _prev_save: Dictionary = {}
var _prev_bak: Dictionary = {}


func _init() -> void:
	call_deferred("_arrancar")


## `_run()` es CORRUTINA (usa `await`). Diferir `_summary()` desde `_init()`
## haría que corra en el PRIMER `await` de `_run()` —antes de terminar— y la
## declararía fallida. Secuencia correcta: arrancar -> await _run -> summary.
func _arrancar() -> void:
	call_deferred("_watchdog")
	await _run()
	_summary()


## Diagnóstico: si `_run()` muere sin reanudar, el resumen igual sale (pero con
## el fallo de piso/marcador). `quit()` desde `_process` NO mata el proceso, así
## que esto avisa; no es el terminador.
func _watchdog() -> void:
	await create_timer(90.0).timeout
	if not _terminado and not _cerrado:
		_fallos += 1
		print("[FAIL] watchdog 90 s: _run() no terminó (colgado o abortado)")
		_summary()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0 and String(args[0]) == FASE_HIJO:
		_fase = FASE_HIJO
		await _fase_hijo()
	else:
		_fase = FASE_PADRE
		await _fase_padre()
	_terminado = true


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)


func _fin(nombre: String) -> void:
	_vistos[nombre] = true
	print("[bloque %s] checks acumulados: %d" % [nombre, _checks])


func _summary() -> void:
	if _cerrado:
		return
	_cerrado = true
	# El slot del usuario se restaura SIEMPRE, aunque una fase aborte a mitad.
	_restaurar_slot_pendiente()
	if not _terminado:
		_fallos += 1
		print("[FAIL] _run() NO terminó (posible SCRIPT ERROR que abortó la función)")
	var bloques: Array = BLOQUES_HIJO if _fase == FASE_HIJO else BLOQUES_PADRE
	for n in bloques:
		if not _vistos.has(n):
			_fallos += 1
			print("[FAIL] el bloque %s NO se ejecutó (fase %s)" % [String(n), _fase])
	var piso: int = CHECKS_MINIMOS_HIJO if _fase == FASE_HIJO else CHECKS_MINIMOS_PADRE
	if _checks < piso:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados en la fase %s (mínimo medido %d)" % [_checks, _fase, piso])
	if _fase == FASE_HIJO:
		_escribir_reporte_hijo()
	print("=== Resumen M55 PERSISTENCIA (%s): %d checks, %d fallos ===" % [_fase, _checks, _fallos])
	quit(1 if _fallos > 0 else 0)


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
	_prev_save = {"existia": FileAccess.file_exists(path),
		"contenido": FileAccess.get_file_as_string(path)}
	_prev_bak = {"existia": FileAccess.file_exists(bak),
		"contenido": FileAccess.get_file_as_string(bak)}
	_backup_capturado = true

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
	var ruta_reporte := _ruta_reporte_hijo()
	if FileAccess.file_exists(ruta_reporte):
		DirAccess.remove_absolute(ruta_reporte)
	var args := [
		"--headless", "--path", ProjectSettings.globalize_path("res://"),
		"--script", "res://scripts/diario/test_diario_persist.gd",
		"--", FASE_HIJO,
	]
	var salida := OS.execute(OS.get_executable_path(), args)
	_check(int(salida) == 0, "hijo verificó la carga del save (exit=%d)" % int(salida))

	# El exit code del hijo no dice CUÁNTO verificó: se lee su reporte.
	var rep := _leer_reporte_hijo(ruta_reporte)
	_check(not rep.is_empty(), "el hijo dejó su reporte de checks (%s)" % ruta_reporte)
	_check(int(rep.get("fallos", -1)) == 0,
		"el hijo reporta 0 fallos (obtuvo %d)" % int(rep.get("fallos", -1)))
	_check(int(rep.get("checks", 0)) >= CHECKS_MINIMOS_HIJO,
		"el hijo ejecutó >= %d checks (obtuvo %d)" % [CHECKS_MINIMOS_HIJO, int(rep.get("checks", 0))])

	# Restaurar el slot previo y limpiar (no dejar rastro en el usuario)
	sm.current_slot = -1
	_restaurar_slot()
	_fin(FASE_PADRE)


## Restaura el slot 3 del usuario una sola vez (idempotente).
func _restaurar_slot() -> void:
	if not _backup_capturado or _restaurado:
		return
	_restaurado = true
	var path := SaveWriter.path_for(SLOT_PRUEBA)
	var bak := path.get_basename() + SaveBackup.BAK_SUFFIX
	_restaurar_archivo(path, _prev_save)
	_restaurar_archivo(bak, _prev_bak)
	SaveWriter.cleanup_orphan_tmp(SLOT_PRUEBA)


## Restaura el slot si una fase abortó a mitad (lo llama `_summary()`).
func _restaurar_slot_pendiente() -> void:
	if not _backup_capturado or _restaurado:
		return
	var sm := root.get_node_or_null("/root/SaveManager")
	if sm != null:
		sm.current_slot = -1
	_restaurar_slot()
	print("[M55] slot %d restaurado desde el guardián (fase abortada a mitad)" % SLOT_PRUEBA)


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
	_check(int(otra.get("schema_version", 0)) == 2
		and (otra.get("entradas", {}) as Dictionary).has("vecino_catalina_oso"),
		"carga: get_save_data re-serializa lo mismo (schema v2 con extras, tanda 25-nov)")
	sm.current_slot = -1
	_fin(FASE_HIJO)


## ── Reporte del hijo (cobertura observable por el padre) ───────────

func _ruta_reporte_hijo() -> String:
	return OS.get_temp_dir().path_join(NOMBRE_REPORTE_HIJO)


func _escribir_reporte_hijo() -> void:
	var f := FileAccess.open(_ruta_reporte_hijo(), FileAccess.WRITE)
	if f == null:
		print("[M55] no se pudo escribir el reporte del hijo")
		return
	f.store_string(JSON.stringify({
		"checks": _checks,
		"fallos": _fallos,
		"terminado": _terminado,
		"bloques": _vistos.keys(),
	}))
	f.close()


func _leer_reporte_hijo(ruta: String) -> Dictionary:
	if not FileAccess.file_exists(ruta):
		return {}
	var txt := FileAccess.get_file_as_string(ruta)
	var d: Variant = JSON.parse_string(txt)
	if typeof(d) != TYPE_DICTIONARY:
		return {}
	var out: Dictionary = d
	return out
