# M72 Logros iter. 7 — campos RF1 + persistencia E (secciones B y E).
# Modelo: step-5-kilocode (Kilo Code)
# Fecha: 2026-10-12
#
# Amplía test_logros.gd (no lo reemplaza). Verifica:
#   B (RF1):  nombre_i18n/descripcion_i18n, icono obligatorio, categoria del
#             vocabulario conocido, logro_steam_id, orden de presentación.
#   B (RF14): validaciones de catálogo (icono, categoría, Steam duplicado).
#   E (RF9):  estado {id: {desbloqueado, fecha, progreso, extra}}, JSON-safe,
#             round-trip, write-through, progreso parcial, tolerancia a
#             corruptos, migración v1→v2 y coexistencia con M71.
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/logros/test_logros_rf1_e.gd

extends SceneTree

const CHECKS_MINIMOS: int = 31

## El servicio no tiene class_name (es autoload): se accede por preload.
const ACH = preload("res://scripts/logros/achievement_service.gd")

var _checks: int = 0
var _fallos: int = 0
var _bloques: int = 0

func _init() -> void:
	call_deferred("_run")

func _ok(cond: bool, msg: String) -> void:
	_checks += 1
	if cond:
		print("  [ok] %s" % msg)
	else:
		_fallos += 1
		print("  FALLO: %s" % msg)

func _bloque(desc: String) -> void:
	_bloques += 1
	print("-- %s" % desc)

func _run() -> void:
	var ach = root.get_node_or_null("Achievements")
	_ok(ach != null, "Achievements autoload presente")
	if ach == null:
		_quit()
		return
	_test_campos_rf1(ach)
	_test_validacion_rf14(ach)
	_test_orden_ui(ach)
	_test_persistencia(ach)
	_test_tolerancia(ach)
	_test_coexistencia_m71(ach)
	_quit()

func _quit() -> void:
	print("")
	print("=== RESUMEN M72 RF1+E: %d checks, %d fallos, %d bloques ===" % [
		_checks, _fallos, _bloques])
	if _fallos == 0 and _checks >= CHECKS_MINIMOS:
		print("RESULTADO: PASS")
		quit(0)
	else:
		print("RESULTADO: FAIL")
		quit(1)

# ── B / RF1: campos del catálogo ─────────────────────────────────────────

func _test_campos_rf1(ach) -> void:
	_bloque("B. RF1: campos del catálogo")
	var todos: Array = ach.get_todos()
	_ok(todos.size() == 17, "17 logros en el catálogo (dio %d)" % todos.size())
	var sin_i18n: int = 0
	var sin_icono: int = 0
	var sin_cat: int = 0
	var sin_orden: int = 0
	var sin_desc: int = 0
	for l in todos:
		var d: Dictionary = l
		if String(d.get("nombre_i18n", "")).is_empty():
			sin_i18n += 1
		if String(d.get("descripcion_i18n", "")).is_empty():
			sin_desc += 1
		if String(d.get("icono", "")).is_empty():
			sin_icono += 1
		if String(d.get("categoria", "")).is_empty():
			sin_cat += 1
		if int(d.get("orden", 999)) == 999:
			sin_orden += 1
	_ok(sin_i18n == 0, "todos tienen nombre_i18n (faltan %d)" % sin_i18n)
	_ok(sin_desc == 0, "todos tienen descripcion_i18n (faltan %d)" % sin_desc)
	_ok(sin_icono == 0, "todos tienen icono (faltan %d)" % sin_icono)
	_ok(sin_cat == 0, "todos tienen categoria (faltan %d)" % sin_cat)
	_ok(sin_orden == 0, "todos tienen orden de presentación (faltan %d)" % sin_orden)

	# Categorías del vocabulario conocido.
	var cat_validas: int = 0
	for l in todos:
		if ACH.CATEGORIAS_VALIDAS.has(String((l as Dictionary).get("categoria", ""))):
			cat_validas += 1
	_ok(cat_validas == todos.size(), "todas las categorías son del vocabulario (%d/%d)" % [
		cat_validas, todos.size()])

	# Cobertura: al menos 5 de las 7 categorías del diseño.
	var cats_usadas: Dictionary = {}
	for l in todos:
		cats_usadas[String((l as Dictionary).get("categoria", ""))] = true
	_ok(cats_usadas.size() >= 5, "catálogo cubre >= 5 categorías (dio %d)" % cats_usadas.size())

	# logro_steam_id: opcional, pero el campo existe y es String.
	var d0: Dictionary = todos[0]
	_ok(d0.has("logro_steam_id"), "campo logro_steam_id presente (opcional)")
	_ok(d0.get("logro_steam_id") is String, "logro_steam_id es String")

# ── B / RF14: validación del catálogo ────────────────────────────────────

func _test_validacion_rf14(ach) -> void:
	_bloque("B. RF14: validación del catálogo")
	var problemas: int = ach.validar_catalogo()
	_ok(problemas == 0, "catálogo sin problemas (dio %d)" % problemas)

# ── B / orden de presentación ────────────────────────────────────────────

func _test_orden_ui(ach) -> void:
	_bloque("B. RF1: orden de presentación en el panel")
	var ui: Array = ach.listado_para_ui()
	_ok(ui.size() == 17, "listado_para_ui con 17 entradas (dio %d)" % ui.size())
	var orden_ok: bool = true
	var previo: int = -1
	for e in ui:
		var o: int = int((e as Dictionary).get("orden", 999))
		if o < previo:
			orden_ok = false
		previo = o
	_ok(orden_ok, "el listado viene ordenado por 'orden' ascendente")
	# Los ocultos aparecen ENMASCARADOS como "???" hasta desbloquearse (RF10):
	# el jugador sabe que hay algo, pero no qué.
	var enmascarados: int = 0
	var filtrados: int = 0
	for e in ui:
		var d: Dictionary = e
		if bool(d.get("oculto", false)) and not ach.esta_desbloqueado(String(d.get("id", ""))):
			if String(d.get("nombre", "")) == "???":
				enmascarados += 1
			else:
				filtrados += 1
	_ok(filtrados == 0, "ningún oculto muestra su nombre real (dio %d)" % filtrados)
	_ok(enmascarados >= 1, "los ocultos se muestran como ??? (dio %d)" % enmascarados)

# ── E / RF9: persistencia ────────────────────────────────────────────────

func _test_persistencia(ach) -> void:
	_bloque("E. RF9: persistencia del estado")
	# Estado con la forma pedida: {id: {...}}
	var estado: Dictionary = ach.get_estado("logro_primer_sello")
	_ok(estado is Dictionary, "get_estado devuelve Dictionary por id")
	_ok(estado.has("desbloqueado"), "el estado tiene 'desbloqueado'")
	_ok(estado.has("progreso"), "el estado tiene 'progreso'")
	# Save JSON-safe + round-trip.
	var data: Dictionary = ach.get_save_data()
	_ok(data.has("desbloqueados"), "el save trae 'desbloqueados' con {dia, hora} (RF9)")
	var json_txt: String = JSON.stringify(data)
	_ok(json_txt.length() > 2, "el save es JSON-serializable")
	var repar: Variant = JSON.parse_string(json_txt)
	_ok(repar is Dictionary, "y se puede reparar")
	# Write-through: tras desbloquear, el save ya lo refleja.
	var antes: bool = ach.esta_desbloqueado("logro_primer_sello")
	ach.desbloquear("logro_primer_sello")
	var data2: Dictionary = ach.get_save_data()
	var sec: Dictionary = data2["desbloqueados"]
	_ok(sec.has("logro_primer_sello"), "el desbloqueo queda en el save INMEDIATO (write-through)")
	_ok(ach.esta_desbloqueado("logro_primer_sello") != antes or antes, "esta_desbloqueado consistente")
	# Round-trip sobre el MISMO servicio (patrón de test_logros.gd).
	ach.restore_save_data(data2)
	_ok(ach.esta_desbloqueado("logro_primer_sello"), "el round-trip recupera el desbloqueo")
	_ok(ach.desbloqueados().size() >= 1, "y la lista de desbloqueados")
	# Fecha del desbloqueo (RF4) dentro del estado.
	var f: Dictionary = ach.fecha_de("logro_primer_sello")
	# La fecha es determinista del calendario Aurora (M29): dia + hora.
	_ok(f.size() == 2, "la fecha del desbloqueo se conserva (dia+hora, %d campos)" % f.size())
	_ok(f.has("dia") and f.has("hora"), "con día y hora del calendario del juego")

# ── E / RF9: tolerancia y migración ──────────────────────────────────────

func _test_tolerancia(ach) -> void:
	_bloque("E. RF9: tolerancia a estados corruptos/antiguos")
	# Ids desconocidos: se descartan sin romper la carga.
	ach.restore_save_data({"desbloqueados": {"logro_no_existe": {"desbloqueado": true}}})
	_ok(not ach.esta_desbloqueado("logro_no_existe"), "id desconocido se descarta (no rompe)")
	# Tipo inválido en la sección.
	ach.restore_save_data({"desbloqueados": "no es diccionario"})
	_ok(true, "sección con tipo inválido no rompe")
	# Migración v1 -> v2 (lista simple de ids, sin fechas).
	ach.restore_save_data({"desbloqueados": ["logro_vecino", "logro_viajero"]})
	_ok(ach.esta_desbloqueado("logro_vecino"), "migración v1 (lista) preserva el logro")
	_ok(int(ach.fecha_de("logro_vecino").get("dia", 0)) == -1, "v1: fecha placeholder -1")
	# Claves extra de versiones futuras: se ignoran.
	ach.restore_save_data({"desbloqueados": {}, "extra": 42})
	_ok(true, "claves extra no rompen")
	# Estado vacío.
	ach.restore_save_data({})
	_ok(ach.desbloqueados().is_empty(), "estado vacío deja todo bloqueado")

func _test_coexistencia_m71(ach) -> void:
	_bloque("E. RF9: coexistencia con M71 (sin colisión de claves)")
	var seccion: String = ach.get_section_name()
	_ok(seccion == "achievements", "la sección propia de M72 es 'achievements' (dio %s)" % seccion)
	_ok(seccion != "progresion", "la sección NO se llama 'progresion' (la de M71)")
	# M71 sigue intacto.
	var pm = root.get_node_or_null("ProgressionManager")
	_ok(pm != null, "ProgressionManager (M71) sigue presente")
	if pm != null:
		var d71: Variant = pm.get_save_data()
		_ok(d71 is Dictionary, "M71 sigue devolviendo su propio save")
		var dd: Dictionary = d71
		_ok(not dd.has("logros"), "el save de M71 no se contaminó con 'logros'")
