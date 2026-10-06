# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-06
#
# Cola M59 / BUG-110: la recuperacion debe probar TODAS las rotaciones (r1, r2...).
#
# Antes, read_latest_backup() leia SOLO r1 y _try_recover() lo llamaba una sola
# vez: r2 era un backup MUERTO (se conservaba en disco pero ningun camino lo
# consultaba). Si r1 estaba corrupto y r2 integro, se reportaba CORRUPTED pese a
# existir un backup valido.
#
# Fix: _try_recover() itera for rotation in range(1, SaveBackup.MAX_ROTATIONS + 1)
# probando cada rotacion en orden de frescura hasta una que pase parse + validate.
#
# RED por inyeccion: si el bucle se limita a r1 (range(1, 2)), los casos B y C
# (que dependen de r2) fallan.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/saving/test_backup_rotations.gd

extends SceneTree

## Piso MEDIDO en verde (7 checks).
const CHECKS_MINIMOS := 6

## Slot de prueba aislado (no usado por el juego ni por otras suites).
const SLOT := 97

var _fallos: int = 0
var _checks: int = 0
var _ultimo: Dictionary = {}

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if not DirAccess.dir_exists_absolute("user://saves"):
		DirAccess.make_dir_recursive_absolute("user://saves")
	var loader := SaveLoader.new()
	_check(loader != null, "SaveLoader instanciable")

	# --- Caso A (control): r1 valido -> se recupera desde r1 ---
	_limpiar()
	_escribir_bak(1, _doc_valido("R1"))
	_check(_cargar(loader) == SaveLoader.LoadResult.RECOVERED, "control: r1 valido -> RECOVERED")
	_check(_marca() == "R1", "control: se recupero la marca de r1")

	# --- Caso B (BUG-110): r1 corrupto + r2 valido -> se recupera desde r2 ---
	_limpiar()
	_escribir_bak(1, "basura sin checksum")
	_escribir_bak(2, _doc_valido("R2"))
	_check(_cargar(loader) == SaveLoader.LoadResult.RECOVERED,
		"r1 corrupto + r2 valido -> RECOVERED (BUG-110)")
	_check(_marca() == "R2", "se recupero la marca de r2 (no la de r1)")

	# --- Caso C: solo r2 (r1 ausente) -> se recupera desde r2 ---
	_limpiar()
	_escribir_bak(2, _doc_valido("R2only"))
	_check(_cargar(loader) == SaveLoader.LoadResult.RECOVERED,
		"solo r2 presente -> RECOVERED")

	# --- Caso D: ambas rotaciones corruptas -> CORRUPTED ---
	_limpiar()
	_escribir_bak(1, "x")
	_escribir_bak(2, "y")
	_check(_cargar(loader) == SaveLoader.LoadResult.CORRUPTED,
		"r1 y r2 corruptos -> CORRUPTED")

	_limpiar()
	_resumen()

## Carga el slot de prueba y devuelve el codigo de resultado (guarda el dict).
func _cargar(loader: SaveLoader) -> int:
	_ultimo = loader.load(SLOT)
	return int(_ultimo.get("result", -1))

## Marca de la ultima recuperacion (meta.last_saved del payload recuperado).
func _marca() -> String:
	var p: Variant = _ultimo.get("payload", {})
	if typeof(p) != TYPE_DICTIONARY:
		return ""
	var meta: Variant = (p as Dictionary).get("meta", {})
	if typeof(meta) != TYPE_DICTIONARY:
		return ""
	return String((meta as Dictionary).get("last_saved", ""))

## Documento de save VALIDO (pasa checksum + validate) con una marca distinguible.
func _doc_valido(marca: String) -> String:
	var payload := SaveSchema.default_payload("slot_%d" % SLOT)
	payload["meta"]["last_saved"] = marca
	return SaveWriter.build_file_content(SaveWriter.serialize_payload(payload))

func _escribir_bak(rotation: int, content: String) -> void:
	var f := FileAccess.open("user://saves/slot_%d_r%d.bak" % [SLOT, rotation], FileAccess.WRITE)
	if f != null:
		f.store_string(content)
		f.close()

func _limpiar() -> void:
	var paths: Array[String] = ["user://saves/slot_%d.save" % SLOT]
	for r in [1, 2]:
		paths.append("user://saves/slot_%d_r%d.bak" % [SLOT, r])
	for p in paths:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _resumen() -> void:
	print("=== TEST BACKUP-ROTATIONS: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	if _checks < CHECKS_MINIMOS:
		print("TEST BACKUP-ROTATIONS FALLIDO - solo %d checks (piso %d): un bloque aborto en silencio" % [_checks, CHECKS_MINIMOS])
		quit(1)
		return
	quit(1 if _fallos > 0 else 0)
