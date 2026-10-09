# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M48: Test headless del AnimationService.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/animacion/test_animacion_service.gd

extends SceneTree

# --- Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
#     + _summary() diferido. Instrumentacion LOTE 2 (mis suites propias), 2026-10-08,
#     DeepSeek-V4.1-Flash (msg 100). Piso = checks reales MEDIDOS (Log 1490).
#     NO cambia logica ni aserciones; solo agrega contador + control de bloques.
const CHECKS_MINIMOS := 8
const _WB_BLOQUES: Array[String] = ["animacion_service"]
var _checks: int = 0
var _wb_vistos: Dictionary = {}
var _wb_cerrado: bool = false

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
	print("=== Resumen M48: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)



var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	var svc := root.get_node_or_null("AnimationService")
	_check(svc != null, "AnimationService autoload presente")
	if svc == null:
		print("=== TEST M48: 1 fallo(s) ===")
		_summary()
		return
	# Registrar entidad
	svc.registrar_entidad("jabali_01", {
		"idle": {"anim": "idle", "loop": true},
		"walk": {"anim": "walk", "loop": true},
		"eat": {"anim": "eat", "loop": false},
	})
	_check(svc.entidades_count() >= 1, "entidad registrada")
	# Estado inicial = primer estado
	_check(svc.estado_actual("jabali_01") == "idle", "estado inicial = idle")
	# Cambiar estado
	var ok: bool = svc.cambiar_estado("jabali_01", "walk")
	_check(ok, "cambiar a walk")
	_check(svc.estado_actual("jabali_01") == "walk", "estado actual = walk")
	# Cambiar al mismo estado (no transición)
	_check(not svc.cambiar_estado("jabali_01", "walk"), "mismo estado = sin transición")
	# Estado inexistente
	_check(not svc.cambiar_estado("jabali_01", "fly"), "estado inexistente rechazado")
	# Desregistrar
	svc.desregistrar_entidad("jabali_01")
	_check(svc.estado_actual("jabali_01") == "", "entidad desregistrada")
	_fin("animacion_service")
	_summary()

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
