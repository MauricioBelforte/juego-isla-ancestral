# Modelo: DeepSeek-V4.1-Flash (OpenCode)
# Plataforma: OpenCode
# Fecha: 2026-11-08
#
# Crítico de la evaluación Nemotron (Glyph Cluster) — M59:
#   "Guardado sin pre-validación de payload; proveedor fallido → save incompleto".
#
# Antes: SaveSnapshot.collect() empezaba con los DEFAULTS del schema y omitía con
# push_error la sección de un proveedor roto. El save se escribía igual y la UI
# emitía `save_completed`: el jugador veía "guardado OK" pero al recargar esa
# sección volvía a los defaults (progreso perdido EN SILENCIO).
#
# Ahora SaveSchema.validar_previo_a_guardar() combina:
#   1. validate() del payload completo,
#   2. las secciones que collect() tuvo que omitir (SaveSnapshot.ultimas_omitidas).
# Si una sección CRÍTICA se perdió, SaveManager NO rota ni escribe: emite
# `save_failed`, cuenta el rechazo y deja el save anterior intacto.
#
# Guardia anti-falso-verde: piso CHECKS_MINIMOS + watchdog.
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://scripts/saving/test_prevalidacion_payload_m59.gd

extends SceneTree

const TIMEOUT_SEG := 60.0
const CHECKS_MINIMOS := 18
const SLOT := 3

const SM_SCRIPT := preload("res://scripts/saving/save_manager.gd")

## Proveedor que devuelve null (viola el contrato Dictionary) sin lanzar.
class ProviderRoto:
	extends RefCounted
	var seccion: String
	func _init(s: String) -> void:
		seccion = s
	func get_section_name() -> String:
		return seccion
	func get_save_data():
		return null
	func restore_save_data(_d) -> void:
		pass

## Proveedor sano de una sección NO crítica (control de no-regresión).
class ProviderSano:
	extends RefCounted
	func get_section_name() -> String:
		return "probe_sano"
	func get_save_data() -> Dictionary:
		return {"v": 7}
	func restore_save_data(_d) -> void:
		pass

var _checks: int = 0
var _fallos: int = 0
var _detalles: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	create_timer(TIMEOUT_SEG, true).timeout.connect(_on_watchdog)
	print("=== M59: pre-validacion de payload antes de guardar ===")
	_limpiar_slot()
	_bloque_A_schema()
	_bloque_B_snapshot()
	await _bloque_C_manager()
	_limpiar_slot()
	_resumen()


func _on_watchdog() -> void:
	print("WATCHDOG: la suite no termino en %.0f s" % TIMEOUT_SEG)
	quit(1)


func _check(nombre: String, ok: bool, detalle: String = "") -> void:
	_checks += 1
	if ok:
		print("  [ok]   %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])
	else:
		_fallos += 1
		_detalles.append(nombre + ((" (" + detalle + ")") if detalle != "" else ""))
		print("  [FAIL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])


func _resumen() -> void:
	print("=== Resumen pre-validacion M59: %d checks, %d fallos (minimo %d) ===" % [
		_checks, _fallos, CHECKS_MINIMOS])
	if _fallos > 0:
		print("FALLOS:")
		for d in _detalles:
			print("  - " + d)
	if _checks < CHECKS_MINIMOS:
		print("INVALIDO: %d checks, minimo %d" % [_checks, CHECKS_MINIMOS])
		quit(2)
		return
	if _fallos > 0:
		print("TEST pre-validacion M59 FALLIDO")
		quit(1)
		return
	print("TEST pre-validacion M59 OK — un proveedor roto ya no produce un save incompleto silencioso")
	quit(0)


# ── A. Reglas puras del schema ────────────────────────────────────────
func _bloque_A_schema() -> void:
	print("-- A. SaveSchema.validar_previo_a_guardar --")
	var sano: Dictionary = SaveSchema.default_payload("")
	_check("A1 payload sano -> 0 problemas",
		SaveSchema.validar_previo_a_guardar(sano).is_empty(),
		str(SaveSchema.validar_previo_a_guardar(sano)))
	_check("A2 payload vacio -> rechazado",
		not SaveSchema.validar_previo_a_guardar({}).is_empty())
	_check("A3 payload vacio menciona 'vacio'",
		"vacio" in str(SaveSchema.validar_previo_a_guardar({})))
	var sin_player: Dictionary = SaveSchema.default_payload("")
	sin_player.erase("player")
	var errs_player: Array[String] = SaveSchema.validar_previo_a_guardar(sin_player)
	_check("A4 falta 'player' -> error explicito",
		not errs_player.is_empty() and "player" in str(errs_player), str(errs_player))
	_check("A5 omitida 'world' (critica) -> rechazado",
		not SaveSchema.validar_previo_a_guardar(sano, ["world"]).is_empty())
	_check("A6 omitida 'probe_badtype' (no critica) -> permitido",
		SaveSchema.validar_previo_a_guardar(sano, ["probe_badtype"]).is_empty())
	_check("A7 dos criticas omitidas -> 2 errores",
		SaveSchema.validar_previo_a_guardar(sano, ["inventory", "quests"]).size() == 2,
		str(SaveSchema.validar_previo_a_guardar(sano, ["inventory", "quests"])))
	_check("A8 SECCIONES_CRITICAS cubre world/player/inventory/buildings/quests",
		SaveSchema.SECCIONES_CRITICAS.has("world")
		and SaveSchema.SECCIONES_CRITICAS.has("player")
		and SaveSchema.SECCIONES_CRITICAS.has("inventory")
		and SaveSchema.SECCIONES_CRITICAS.has("buildings")
		and SaveSchema.SECCIONES_CRITICAS.has("quests"))


# ── B. SaveSnapshot reporta las secciones omitidas ────────────────────
func _bloque_B_snapshot() -> void:
	print("-- B. SaveSnapshot.ultimas_omitidas --")
	var snap := SaveSnapshot.new()
	var limpio: Dictionary = snap.collect("slot_%d" % SLOT)
	_check("B1 collect sano -> omitidas vacio", snap.ultimas_omitidas.is_empty(),
		str(snap.ultimas_omitidas))
	_check("B2 collect sano conserva las 14 secciones del schema",
		limpio.size() >= 14, str(limpio.size()))
	snap.register_provider(ProviderRoto.new("probe_roto"))
	var con_roto: Dictionary = snap.collect("slot_%d" % SLOT)
	_check("B3 proveedor roto -> queda en ultimas_omitidas",
		snap.ultimas_omitidas.has("probe_roto"), str(snap.ultimas_omitidas))
	_check("B4 el error del proveedor roto es explicito",
		snap.ultimos_errores.size() == 1 and "probe_roto" in snap.ultimos_errores[0],
		str(snap.ultimos_errores))
	_check("B5 la seccion rota NO se escribe en el payload", not con_roto.has("probe_roto"))
	_check("B6 el resto del payload sigue sano (14 secciones del schema)",
		con_roto.size() >= 14 and con_roto.has("world") and con_roto.has("player"))
	snap._providers.clear()
	snap.collect("slot_%d" % SLOT)
	_check("B7 un collect posterior limpia ultimas_omitidas", snap.ultimas_omitidas.is_empty(),
		str(snap.ultimas_omitidas))


# ── C. SaveManager no escribe un save incompleto ──────────────────────
func _bloque_C_manager() -> void:
	print("-- C. SaveManager: pre-validacion en _process_queue --")
	var sm = SM_SCRIPT.new()
	root.add_child(sm)
	await process_frame
	sm.snapshot._providers.clear()

	var eventos: Array[String] = []
	sm.save_completed.connect(func(_s: int, _r: String) -> void: eventos.append("completed"))
	sm.save_failed.connect(func(_s: int, _r: String) -> void: eventos.append("failed"))

	# C1-C4: proveedor SANO -> escribe y emite save_completed.
	sm.snapshot.register_provider(ProviderSano.new())
	sm.request_save(SLOT, "test_control_sano")
	_check("C1 payload sano -> save_completed", eventos.has("completed"), str(eventos))
	_check("C2 payload sano -> 0 rechazos", sm.guardados_rechazados() == 0,
		str(sm.guardados_rechazados()))
	_check("C3 el archivo del slot existe", FileAccess.file_exists(SaveWriter.path_for(SLOT)))
	_check("C4 sin errores pendientes", sm.errores_ultimo_guardado().is_empty(),
		str(sm.errores_ultimo_guardado()))

	# C5-C8: ahora un proveedor CRÍTICO roto -> no escribe, falla visible.
	var contenido_antes: String = FileAccess.get_file_as_string(SaveWriter.path_for(SLOT))
	sm.snapshot.register_provider(ProviderRoto.new("world"))
	eventos.clear()
	sm.request_save(SLOT, "test_proveedor_roto")
	_check("C5 proveedor critico roto -> save_failed", eventos.has("failed"), str(eventos))
	_check("C6 NO emite save_completed falso", not eventos.has("completed"), str(eventos))
	_check("C7 el rechazo se contabiliza", sm.guardados_rechazados() == 1,
		str(sm.guardados_rechazados()))
	_check("C8 el error nombra la seccion critica perdida",
		"world" in str(sm.errores_ultimo_guardado()), str(sm.errores_ultimo_guardado()))

	# C9: el save ANTERIOR queda intacto (no se rota ni se reescribe).
	var contenido_despues: String = FileAccess.get_file_as_string(SaveWriter.path_for(SLOT))
	_check("C9 el save anterior queda intacto", contenido_antes == contenido_despues)
	_check("C10 el archivo sigue existiendo", FileAccess.file_exists(SaveWriter.path_for(SLOT)))

	sm.queue_free()
	await process_frame


func _limpiar_slot() -> void:
	DirAccess.make_dir_recursive_absolute("user://saves")
	var base: String = SaveWriter.path_for(SLOT)
	for ruta in [base, base + ".tmp", base.replace(".save", "_r1.bak"),
			base.replace(".save", "_r2.bak"), base.replace(".save", "_r3.bak")]:
		if FileAccess.file_exists(ruta):
			DirAccess.remove_absolute(ruta)
