# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-22
#
# M19/M56: QA de CONTRATO de pose_foto (deuda 229). Limitacion honesta
# documentada en el 05: el flujo completo con NPCAgent real (manager+needs+
# rutina) cuelga en SceneTree headless aislado (ver BUG-145, mismo sintoma
# en tests del rial M18) — este QA verifica el CONTRATO EN CODIGO en disco;
# la ejecucion visual de la animacion real queda para entorno NPC completo
# (juego con manager) o sigue pendiente M48/M44 asset.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/ia_npc/qa_m19_pose_foto.gd

extends SceneTree

const CHECKS_MINIMOS := 6
var _checks: int = 0
var _fallos: int = 0

func _summary() -> void:
	print("=== Resumen QA pose_foto M19/M56: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	var ruta := "res://scripts/ia_npc/npc_agent.gd"
	var t := FileAccess.get_file_as_string(ruta)
	_check(t != "", "contrato: npc_agent.gd legible desde disco")
	# Firmas del deudor resuelto
	_check(t.contains("func pose_foto() -> void:"), "contrato: pose_foto() sin args (NPCManager L133 sigue valido)")
	_check(t.contains("func pose_foto_en(duracion: float) -> void:"), "contrato: pose_foto_en(duracion) extraido (nucleo async)")
	_check(t.contains("func _animacion_de_pose() -> Object:"), "contrato: _animacion_de_pose() con duck-typing play/stop")
	# El contrato M48/M44: la anim "pose_foto" se reproduce si hay AnimationPlayer
	_check(t.contains('anim.play("pose_foto")') and t.contains("anim.stop()"),
		"contrato M48/M44: play/stop de la anim pose_foto via AnimationPlayer hijo")
	# El nucleo congela IA (pause_ai/resume_ai) y protege re-entrada
	_check(t.contains("_posando_foto") and t.contains("pause_ai()") and t.contains("resume_ai()"),
		"contrato: pausa/resume de IA + bandera _posando_foto (re-entrada protegida)")
	# El NPCManager sigue llamando pose_foto() sin args (no rompimos al llamador)
	var m := FileAccess.get_file_as_string("res://scripts/ia_npc/npc_manager.gd")
	_check(m.contains('agent.pose_foto()'), "contrato manager: npc_manager.gd sigue invocando pose_foto()")
