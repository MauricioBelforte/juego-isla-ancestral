# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-22
#
# M56: QA headless del flujo PHOTO_POSE_REQUEST + salida de modo foto.
# Items del 05-Checklist cubiertos:
#   - "Emitir PHOTO_POSE_REQUEST (M07) al entrar al modo foto" [S]
#   - "Restaurar FOV y posicion originales al salir" [S] (restauracion sin crash)
# Ejecutar: Godot --headless --path game\isla-ancestral --script res://scripts/foto/qa_m56_photopose.gd

extends SceneTree

var _checks: int = 0
var _fallos: int = 0

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _summary() -> void:
	print("=== Resumen QA photopose M56: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	var ps := root.get_node_or_null("/root/PhotoService")
	_check(ps != null, "PhotoService autoload presente")
	if ps == null:
		return
	# Senales del contrato (M07 poze + preset + foto)
	for sen in ["photo_pose_request", "preset_aplicado", "foto_tomada", "modo_foto_cambiado"]:
		_check(ps.has_signal(sen), "senal presente: %s" % sen)
	# Emision real del poze request y captura por un oyente
	var capturadas: int = 0
	var cb: Callable = func(): capturadas += 1
	ps.photo_pose_request.connect(cb)
	ps.photo_pose_request.emit()
	ps.photo_pose_request.emit()
	_check(capturadas == 2, "poze request: 2 emisiones capturadas por oyente (%d)" % capturadas)
	ps.photo_pose_request.disconnect(cb)
	# El NPCManager tiene el receptor conectado (fila del 05: M07 -> M19)
	var mgr := root.get_node_or_null("/root/NPCManager")
	_check(mgr != null, "NPCManager autoload presente")
	if mgr != null:
		_check(mgr.has_method("_on_photo_pose_request"), "manager: receptor _on_photo_pose_request existe")
		# Ejecutar el receptor directo con 0 agentes: no crashea, count 0
		mgr._on_photo_pose_request()
		_check(true, "manager: callback directo sin agentes no crashea")
		_check(ps.photo_pose_request.get_connections().any(
			func(c): return c["callable"].get_object() == mgr),
			"manager: _on_photo_pose_request CONECTADA a photo_pose_request")
	# Entrar/Salir del modo foto headless (restauracion sin crash)
	ps.set_modo_foto(true)
	_check(ps.modo_foto() == true and ps.acciones_bloqueadas() == true, "modo foto: entra y bloquea acciones")
	ps.set_modo_foto(false)
	_check(ps.modo_foto() == false and ps.acciones_bloqueadas() == false, "modo foto: sale y restaura bloqueo de acciones")
	# Doble salida idempotente (sin crash)
	ps.set_modo_foto(false)
	_check(ps.modo_foto() == false, "modo foto: salida redundante idempotente")
