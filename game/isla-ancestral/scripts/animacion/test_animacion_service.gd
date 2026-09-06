# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M48: Test headless del AnimationService.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/animacion/test_animacion_service.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var svc := root.get_node_or_null("AnimationService")
	_check(svc != null, "AnimationService autoload presente")
	if svc == null:
		print("=== TEST M48: 1 fallo(s) ===")
		quit(1)
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
	print("=== TEST M48: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
