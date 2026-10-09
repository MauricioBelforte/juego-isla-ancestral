# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M147: Verificación del WorldBible (canon data-driven).
extends SceneTree

# --- Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
#     + _summary() diferido. Instrumentacion LOTE 2 (mis suites propias), 2026-10-08,
#     DeepSeek-V4.1-Flash (msg 100). Piso = checks reales MEDIDOS (Log 1490).
#     NO cambia logica ni aserciones; solo agrega contador + control de bloques.
const CHECKS_MINIMOS := 7
const _WB_BLOQUES: Array[String] = ["world_bible"]
var _checks: int = 0
var _wb_vistos: Dictionary = {}
var _wb_cerrado: bool = false
var _wb_terminado: bool = false

func _fin(nombre: String) -> void:
	_wb_vistos[nombre] = true


func _summary() -> void:
	if _wb_cerrado:
		return
	_wb_cerrado = true
	for b in _WB_BLOQUES:
		if not _wb_vistos.has(b):
			_fallos += 1
			print("[FAIL] bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M147: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)



var _fallos := 0

func _init() -> void:
	call_deferred("_run")
	call_deferred("_wb_armar_red")

## Red de seguridad (NO gira en bucle): si un SCRIPT ERROR aborta _run() antes
## de llegar a _summary(), el temporizador lo dispara. El camino feliz llama a
## _summary() al final de _run(); este timer solo actua en el caso de aborto.
func _wb_armar_red() -> void:
	if _wb_cerrado or _wb_terminado:
		return
	create_timer(180.0).timeout.connect(_summary)

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s" % nombre)

func _run() -> void:
	print("=== [M147] Verificación del WorldBible (canon) ===")
	var bible = load("res://scripts/world/world_bible.gd").new()
	root.add_child(bible)
	await process_frame
	_check("WorldBible instanciado", bible != null)
	var canon: Dictionary = bible.config if (bible.get("config") != null) else {}
	if canon.is_empty() and bible.get("canon") != null:
		canon = bible.get("canon")
	# leer el json directamente (si el servicio no expone)
	var datos: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/world_data.json"))
	_check("canon_version presente", float(datos.get("canon_version", 0)) >= 1.0)
	var personajes: Dictionary = datos.get("personajes", {})
	_check("6 personajes del canon", personajes.size() == 6)
	var lugares: Dictionary = datos.get("lugares", {})
	_check("8 lugares del canon", lugares.size() == 8)
	var simbolos: Dictionary = datos.get("simbolos", {})
	_check("4 símbolos del canon", simbolos.size() == 4)
	var capas: Dictionary = datos.get("capas_por_sello", {})
	_check("4 capas por sello", capas.size() == 4)
	var linea: Array = datos.get("linea_tiempo", [])
	_check("5 eventos de línea de tiempo", linea.size() == 5)
	_fin("world_bible")
	_wb_terminado = true
	bible.free()
	_summary()
