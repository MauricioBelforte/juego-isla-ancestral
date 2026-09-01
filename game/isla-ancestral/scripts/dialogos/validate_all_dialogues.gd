# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M21 (iter 7): Gate de validacion de dialogos para CI / editor.
# Valida TODOS los JSON de res://data/dialogues/ con DialogGraphValidator.
#   - SIEMPRE: nodos huerfanos (inaccesibles desde start) + operadores de
#     condicion invalidos.
#   - OPCIONAL: claves de mundo desconocidas (solo si CLAVES_MUNDO no esta vacio).
# Sale con codigo != 0 si algun archivo tiene problemas (para fallar CI).
#
# Uso:
#   CI / headless:
#     Godot --headless --path game/isla-ancestral \
#            --script res://scripts/dialogos/validate_all_dialogues.gd
#   Editor: ejecutar el mismo comando desde la terminal integrada del editor
#           (o configurarlo como paso de un workflow de exportacion/CI).
#
# NOTA: extends SceneTree (no EditorScript) para que el MISMO script corra en
# --script headless (CI) y desde el editor. No lleva `tool` porque SceneTree no
# se adjunta a un nodo de escena.

extends SceneTree

const CARPETA := "res://data/dialogues/"
## Allowlist de claves validas de WorldStateService. Se resuelve en _ejecutar() desde
## DialogGraphValidator.CLAVES_MUNDO_BASE (fuente unica de verdad) para no duplicar la
## lista. Incluye: hora, minuto, dia, mes, anio, estacion, es_de_dia, es_noche,
## dia_absoluto, clima, amistad_<npc_id>, flag_<clave>.
## Si se quiere relajar (no chequear claves), pasar [] a validar_archivo.
var CLAVES_MUNDO: Array = []

func _initialize() -> void:
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	var validador = load("res://scripts/dialogos/dialog_graph_validator.gd")
	if validador == null:
		printerr("[CI-DGT] No se pudo cargar DialogGraphValidator")
		quit(2)
		return
	# Allowlist de claves de mundo desde la fuente unica de verdad del validador.
	CLAVES_MUNDO = validador.CLAVES_MUNDO_BASE
	var dir := DirAccess.open(CARPETA)
	if dir == null:
		printerr("[CI-DGT] No se pudo abrir la carpeta: " + CARPETA)
		quit(2)
		return
	var archivos := dir.get_files()
	archivos.sort()
	var total := 0
	var con_problemas := 0
	var problemas_totales := 0
	for nombre in archivos:
		if not nombre.ends_with(".json"):
			continue
		total += 1
		var res = validador.validar_archivo(CARPETA + nombre, CLAVES_MUNDO)
		if not res.ok:
			con_problemas += 1
			problemas_totales += res.problemas.size()
			printerr("[CI-DGT] %s: %d problema(s)" % [nombre, res.problemas.size()])
			for p in res.problemas:
				printerr("    - " + str(p))
		else:
			print("[CI-DGT] %s: OK" % nombre)
	print("[CI-DGT] Resumen: %d archivo(s) | %d con problemas | %d problema(s) total" % [total, con_problemas, problemas_totales])
	quit(0 if con_problemas == 0 else 1)
