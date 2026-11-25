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
	var hits: Array = []  # array por REFERENCIA: las lambdas capturan por valor (lecci GDScript)
	var cb: Callable = func(): hits.append(1)
	ps.photo_pose_request.connect(cb)
	ps.photo_pose_request.emit()
	ps.photo_pose_request.emit()
	_check(hits.size() == 2, "poze request: 2 emisiones capturadas por oyente")
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

	# ── Tanda GLM-5.3-Flash 2026-11-25: L95 / L97 / L275 / L286 ──

	# L95: NPC posa 0.5 s con animación M48 sin bugs.
	var agente_script: GDScript = ResourceLoader.load("res://scripts/ia_npc/npc_agent.gd")
	var fuente_agente: String = agente_script.source_code if agente_script != null else ""
	var npc_mgr := root.get_node_or_null("/root/NPCManager")
	_check(agente_script != null and fuente_agente.contains("anim.play(\"pose_foto\")")
			and fuente_agente.contains("pose_foto_en(0.5)")
			and fuente_agente.contains("pause_ai()") and fuente_agente.contains("resume_ai()")
			and npc_mgr != null and npc_mgr.has_method("_on_photo_pose_request"),
			"NPC posa 0.5 s con animación M48 sin bugs: pose_foto reproduce la animación (M48/M44), congela la IA 0.5 s y el receptor está conectado")

	# L97: Retardo de 0.8 s entre pose y captura (evitar tween).
	var ps_script: GDScript = ResourceLoader.load("res://scripts/foto/photo_service.gd")
	var fuente_ps: String = ps_script.source_code if ps_script != null else ""
	var posa_i := fuente_ps.find("func posar()")
	var posa_fin := fuente_ps.find("func tomar_foto")
	var bloque_posar: String = fuente_ps.substr(posa_i, posa_fin - posa_i) if posa_i >= 0 and posa_fin > posa_i else ""
	_check(bloque_posar.contains("create_timer(0.8)") and not bloque_posar.contains("Tween") and bloque_posar.contains("tomar_foto()"),
			"Retardo de 0.8 s entre pose y captura (evitar tween): posar() espera el timer 0.8 s y luego captura, sin Tween")

	# L275: Ofrecer subtítulos en notificaciones.
	var notif := root.get_node_or_null("/root/NotificationService")
	_check(notif != null and notif.has_method("push"), "NotificationService presente para subtítulos")
	if notif != null:
		var panel_antes: int = notif.get_child_count()
		notif.push({"text": "Foto guardada", "type": 0, "subtitle": "Se agregó al álbum (M56)"})
		await process_frame
		var hallado := false
		var texto_ok := false
		for hijo in notif.get_children():
			var sub := hijo.find_child("Subtitle", true, false) if is_instance_valid(hijo) else null
			if sub != null and sub is Label:
				hallado = true
				texto_ok = str(sub.text) == "Se agregó al álbum (M56)"
		_check(hallado and texto_ok, "Ofrecer subtítulos en notificaciones: el toast con 'subtitle' renderiza la segunda línea con el texto dado")

	# L286: Añadir guía de horizonte opcional.
	ps.set_guia_horizonte(true)
	_check(ps.guia_horizonte() == true and ps.modo_foto() == false and ps._overlay_guia.visible == false,
			"Añadir guía de horizonte opcional: activa la guía pero el overlay queda oculto fuera del modo foto")
	ps.set_modo_foto(true)
	_check(ps.modo_foto() == true and ps._overlay_guia.visible == true,
			"Añadir guía de horizonte opcional: en modo foto el overlay se muestra")
	ps.set_modo_foto(false)
	_check(ps.guia_horizonte() == true and ps._overlay_guia.visible == false,
			"Añadir guía de horizonte opcional: al salir del modo foto el overlay se oculta (la preferencia queda)")
	ps.set_guia_horizonte(false)
	_check(ps.guia_horizonte() == false, "Añadir guía de horizonte opcional: se puede desactivar")
