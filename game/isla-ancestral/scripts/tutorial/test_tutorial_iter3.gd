# Modelo: glm-5.3-flash
# Plataforma: Cline
# Fecha: 2026-09-15
#
# M92 iter. 3: suite de la segunda tanda — pistas (RF4/T-041/T-039/P14),
# interruptores (RF9/T-042/T-043/T-049), contexto (T-016), consejos (RF6/S9),
# skip (RF7/S5), re-play (RF8/S6), persistencia (P4/P15) y edge cases cozy
# (P2 sin castigo, P5 objetivo destruido, P6 mundo inactivo, P7 modal, P13 prioridad).
# Complementa test_tutorial.gd (núcleo Deepseek) y test_tutorial_triggers.gd (iter. 2).
# Ejecutar: Godot_console --headless --path game/isla-ancestral --script res://scripts/tutorial/test_tutorial_iter3.gd

extends SceneTree

var _fallos: int = 0
var _tut: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_tut = root.get_node_or_null("Tutorial")
	_check(_tut != null, "Tutorial autoload presente")
	if _tut == null:
		print("=== TEST M92 ITER3: 1 fallo(s) ===")
		quit(1)
		return
	_test_pistas_rf4_s8()
	_test_pistas_expiracion_p2()
	_test_interruptores_rf9()
	_test_dialogo_p7()
	_test_consejos_rf6_s9()
	_test_contexto_t016()
	_test_pasos_y_persistencia_p4()
	_test_skip_s5()
	_test_replay_s6()
	_test_objetivo_destruido_p5_mundo_p6()
	_test_feedback_rf24_p15()
	_test_icono_tecla_p8()
	print("=== TEST M92 ITER3: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

## Helper: cierra el capítulo activo residual (los tests comparten el autoload)
func _cerrar_capitulo_activo() -> void:
	if _tut.activo_actual != "" and _tut.capitulos.has(_tut.activo_actual):
		_tut.cumplir_meta(String(_tut.capitulos[_tut.activo_actual].get("meta", "")))

## Deja el manager en un estado neutro y previsible entre tests
func _reset() -> void:
	_cerrar_capitulo_activo()
	_tut.activo_actual = ""
	_tut.estado = 1  # Estado.ESPERANDO
	_tut._paso_pendiente.clear()
	_tut.descartar_pistas("reset_test")
	_tut.reprograma_delay_s = 0.0  # tests síncronos: sin timers de reintento

## S8/T-041/T-039/P13/P14: pistas vivas (máx. 2), ocultar con motivo, descarte limpio
func _test_pistas_rf4_s8() -> void:
	_reset()
	_tut.registrar_pista("p1", "cap_x", 30.0)
	_tut.registrar_pista("p2", "cap_x", 30.0)
	_check(_tut.pistas_vivas() == 2, "S8: 2 pistas vivas (cupo máximo)")
	# P13: la tercera se POSPONE (no se descarta) y avisa con motivo
	var pospuestas: Array = []
	var cb := func(cap: String, motivo: String) -> void:
		pospuestas.append(motivo)
	_tut.capitulo_pospuesto.connect(cb)
	var ok3: bool = _tut.registrar_pista("p3", "cap_y", 30.0)
	_check(ok3 == false, "P13: la 3ra pista no se registra (cupo lleno)")
	_check(pospuestas.has("prioridad"), "P13: señal capitulo_pospuesto('prioridad') emitida")
	_tut.capitulo_pospuesto.disconnect(cb)
	# T-039: ocultar con motivo deja cupo libre
	var motivos: Array = []
	var cb2 := func(m: String) -> void:
		motivos.append(m)
	_tut.pistas_ocultas.connect(cb2)
	_tut.ocultar_pista("p1", "cumplida")
	_check(_tut.pistas_vivas() == 1, "T-039: ocultar_pista libera el cupo")
	_check(motivos.has("cumplida"), "T-039: motivo de ocultado viaja en la señal")
	_check(_tut.registrar_pista("p3", "cap_y", 30.0) == true, "S8: con cupo libre se registra")
	# P14: fast-travel → descarte LIMPIO de todas
	_tut.descartar_pistas("fast_travel")
	_check(_tut.pistas_vivas() == 0, "P14: descartar_pistas limpia todo (fast-travel)")
	_check(motivos.has("fast_travel"), "P14: motivo 'fast_travel' emitido")
	_tut.pistas_ocultas.disconnect(cb2)

## P2 (cozy): la pista expira sin castigo — el capítulo queda pendiente
func _test_pistas_expiracion_p2() -> void:
	_reset()
	_tut.registrar_capitulo("cap_p2_expira", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.TEST_P2", "icono_tecla": ""}
	], "meta_p2_expira", false)
	_tut.desplegar_capitulo("cap_p2_expira")
	var expiradas: Array = []
	var cb := func(cap: String, motivo: String) -> void:
		expiradas.append(motivo)
	_tut.pista_expirada.connect(cb)
	_tut.registrar_pista("p_exp", "cap_p2_expira", 10.0)
	_tut._process(11.0)  # vence por reloj interno (sin leerse el reloj del SO)
	_check(expiradas.has("expirada"), "P2: pista_expirada emitida al vencer")
	_check(_tut.pistas_vivas() == 0, "P2: la pista vencida se retira del cupo")
	_check(not _tut.capitulo_estado("meta_p2_expira"), "P2: expirar NO completa el capítulo (sin castigo)")
	_tut.pista_expirada.disconnect(cb)

## RF9 (T-042/T-043/T-049): los 3 interruptores son INDEPENDIENTES entre sí
func _test_interruptores_rf9() -> void:
	_reset()
	_tut.registrar_capitulo("cap_guiado_rf9", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.TEST_RF9G", "icono_tecla": ""}
	], "meta_rf9_guiado", false, {"guiado": true})
	_tut.registrar_capitulo("cap_ctx_rf9", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.TEST_RF9C", "icono_tecla": ""}
	], "meta_rf9_ctx", false)
	_tut.registrar_capitulo("cap_ctx_rf9b", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.TEST_RF9C2", "icono_tecla": ""}
	], "meta_rf9_ctxb", false)
	_tut.registrar_capitulo("cap_guiado_rf9b", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.TEST_RF9G2", "icono_tecla": ""}
	], "meta_rf9_guiadob", false, {"guiado": true})
	var ocultas: Array = []
	var cb := func(m: String) -> void:
		ocultas.append(m)
	_tut.pistas_ocultas.connect(cb)
	# T-042: apagar "Pistas contextuales" oculta las vivas de inmediato (sin parpadeo)
	_tut.registrar_pista("p_rf9", "cap_ctx_rf9", 30.0)
	_tut.set_pistas_contextuales(false)
	_check(_tut.pistas_contextuales_on() == false, "RF9: set_pistas_contextuales(false) apaga el interruptor")
	_check(_tut.pistas_vivas() == 0, "T-042: apagar oculta las pistas vivas")
	_check(ocultas.has("interruptor"), "T-042: motivo 'interruptor' emitido para el fade")
	# ...pero NO afecta la secuencia guiada del prólogo (T-043)
	_tut.desplegar_capitulo("cap_ctx_rf9")
	_check(_tut.activo_actual != "cap_ctx_rf9", "T-042: capítulo contextual NO se despliega con pistas off")
	_tut.desplegar_capitulo("cap_guiado_rf9")
	_check(_tut.activo_actual == "cap_guiado_rf9", "T-043: el capítulo GUIADO sí se despliega (interruptor propio)")
	_cerrar_capitulo_activo()
	# T-043: y al revés — apagar el prólogo NO afecta los capítulos contextuales
	_tut.set_prologo_guiado(false)
	_tut.set_pistas_contextuales(true)
	_tut.desplegar_capitulo("cap_guiado_rf9b")
	_check(_tut.activo_actual != "cap_guiado_rf9b", "T-043: con el prólogo off el guiado no se despliega")
	_tut.desplegar_capitulo("cap_ctx_rf9b")
	_check(_tut.activo_actual == "cap_ctx_rf9b", "T-042: con pistas on el contextual se despliega igual")
	_cerrar_capitulo_activo()
	# T-049: interruptor "Consejos" (opciones de juego), independiente de los otros dos
	_tut.registrar_consejo("c_rf9", "TUTORIAL.C_RF9", "pausa")
	_tut.set_consejos(false)
	_check(_tut.consejos_on() == false, "RF9: set_consejos(false) apaga el interruptor")
	_check(_tut.intentar_mostrar_consejo("pausa") == false, "T-049: consejos off → no se muestra")
	_tut.set_consejos(true)
	_tut.set_prologo_guiado(true)
	_tut.pistas_ocultas.disconnect(cb)

## T-048/P7: un modal/diálogo duerme el tutorial y oculta las pistas SIN parpadeo;
## al cerrarse, las pistas vivas REAPARECEN (no se destruyen).
func _test_dialogo_p7() -> void:
	_reset()
	var ocultas: Array = []
	var cb := func(m: String) -> void:
		ocultas.append(m)
	var reanudadas: Array = []
	var cb2 := func(n: int) -> void:
		reanudadas.append(n)
	_tut.pistas_ocultas.connect(cb)
	_tut.pistas_reanudadas.connect(cb2)
	_tut.registrar_pista("p_dlg1", "cap_dlg", 60.0)
	_tut.registrar_pista("p_dlg2", "cap_dlg", 60.0)
	_check(_tut.pistas_vivas() == 2, "P7: 2 pistas vivas antes del modal")
	_tut.set_en_dialogo(true)
	_check(_tut.en_dialogo() == true, "T-048: en_dialogo() refleja el modal abierto")
	_check(_tut.estado == 5, "P7: el tutorial queda DORMIDO (Estado.DORMIDO == 5)")
	_check(_tut.pistas_visibles == false, "P7: las pistas se ocultan sin parpadeo")
	_check(ocultas.has("dormido"), "P7: motivo 'dormido' emitido para el fade")
	_check(_tut.intentar_mostrar_consejo("pausa") == false, "T-048: nunca hay consejos durante un diálogo")
	_tut.set_en_dialogo(false)
	_check(_tut.en_dialogo() == false, "P7: al cerrar el modal sale de DORMIDO")
	_check(_tut.estado == 1, "P7: el estado vuelve a ESPERANDO")
	_check(reanudadas.has(2), "P7: pistas_reanudadas(2) — reaparecen las mismas")
	_check(_tut.pistas_vivas() == 2, "P7: las 2 pistas siguen vivas (no se destruyeron)")
	_tut.descartar_pistas("reset_test")
	_tut.pistas_ocultas.disconnect(cb)
	_tut.pistas_reanudadas.disconnect(cb2)

## RF6/S9: consejos una sola vez (T-045), cooldown 90 s (T-047), contextos
## permitidos (T-046) y nunca durante diálogos/cutscenes (T-048).
func _test_consejos_rf6_s9() -> void:
	_reset()
	_tut.set_consejos(true)
	_tut.consejos.clear()
	_tut.consejos_vistos.clear()
	_tut._ahora_s = 1000.0  # reloj INTERNO del tutorial (nunca el reloj del SO)
	_tut._tiempo_ultimo_consejo = _tut._ahora_s - 100.0
	_tut.registrar_consejo("c_s9a", "TUTORIAL.S9A", "pausa")
	_tut.registrar_consejo("c_s9b", "TUTORIAL.S9B", "pausa")
	var mostrados: Array = []
	var cb := func(cid: String, txt: String) -> void:
		mostrados.append(cid)
	_tut.consejo_mostrado.connect(cb)
	# T-046: contexto NO permitido → jamás
	_check(_tut.intentar_mostrar_consejo("contexto_invalido") == false,
		"T-046: un contexto no permitido no muestra consejo")
	# T-044/S9: consejo del contexto permitido
	_check(_tut.intentar_mostrar_consejo("pausa") == true, "S9: muestra el consejo del contexto permitido")
	_check(mostrados.has("c_s9a"), "S9: señal consejo_mostrado con el id correcto")
	# T-045: el mismo consejo NUNCA se repite (aunque pase el cooldown)
	_tut._tiempo_ultimo_consejo = _tut._ahora_s - 100.0
	_check(_tut.intentar_mostrar_consejo("pausa") == true, "T-045: pasa al siguiente consejo no visto")
	_check(mostrados.has("c_s9b"), "T-045: el segundo consejo distinto sí se muestra")
	_tut._tiempo_ultimo_consejo = _tut._ahora_s - 100.0
	_check(_tut.intentar_mostrar_consejo("pausa") == false, "T-045: ninguno se repite (se muestran una sola vez)")
	# T-047: cooldown mínimo de 90 s
	_tut.registrar_consejo("c_s9c", "TUTORIAL.S9C", "carga_escena")
	_tut._tiempo_ultimo_consejo = _tut._ahora_s
	_check(_tut.intentar_mostrar_consejo("carga_escena") == false, "T-047: el cooldown impide el consejo inmediato")
	_tut._ahora_s += 91.0
	_check(_tut.intentar_mostrar_consejo("carga_escena") == true, "T-047: a los 91 s el cooldown ya no bloquea")
	# T-048: nunca durante un diálogo o cutscene
	_tut.registrar_consejo("c_s9d", "TUTORIAL.S9D", "caminata_larga")
	_tut._tiempo_ultimo_consejo = _tut._ahora_s - 100.0
	_tut.set_en_dialogo(true)
	_check(_tut.intentar_mostrar_consejo("caminata_larga") == false, "T-048: en diálogo no hay consejos")
	_tut.set_en_dialogo(false)
	_check(_tut.intentar_mostrar_consejo("caminata_larga") == true,
		"T-048: al cerrar el diálogo el consejo vuelve a permitirse")
	_tut.consejo_mostrado.disconnect(cb)

## T-016: contexto permitido (hora/día/zona). Sin datos del proveedor NO se
## bloquea (cozy) y el capítulo pospuesto NUNCA se pierde.
func _test_contexto_t016() -> void:
	_reset()
	_tut.registrar_capitulo("cap_ctx", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.TEST_CTX", "icono_tecla": ""}
	], "meta_ctx", false, {"requiere_contexto": {"hora_min": 8, "hora_max": 18}})
	var pospuestos: Array = []
	var cb := func(cap: String, motivo: String) -> void:
		pospuestos.append(motivo)
	_tut.capitulo_pospuesto.connect(cb)
	# Hora fuera de rango → pospuesto con motivo "contexto"
	_tut.establecer_contexto({"hora": 22})
	_check(int(_tut.contexto_actual().get("hora", -1)) == 22, "T-016: establecer_contexto() inyecta la hora")
	_tut.desplegar_capitulo("cap_ctx")
	_check(_tut.activo_actual != "cap_ctx", "T-016: hora fuera de rango → no despliega")
	_check(pospuestos.has("contexto"), "T-016: señal capitulo_pospuesto('contexto') emitida")
	# Hora en rango → despliega
	_tut.establecer_contexto({"hora": 12})
	_tut.desplegar_capitulo("cap_ctx")
	_check(_tut.activo_actual == "cap_ctx", "T-016: hora en rango → despliega")
	_cerrar_capitulo_activo()
	# Límites exactos (hora_min/hora_max inclusivos)
	_tut.registrar_capitulo("cap_ctx2", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.TEST_CTX2", "icono_tecla": ""}
	], "meta_ctx2", false, {"requiere_contexto": {"hora_min": 8, "hora_max": 18}})
	_tut.establecer_contexto({"hora": 8})
	_tut.desplegar_capitulo("cap_ctx2")
	_check(_tut.activo_actual == "cap_ctx2", "T-016: la hora mínima exacta es válida")
	_cerrar_capitulo_activo()
	# Zona: contexto distinto → pospuesto; zona correcta → despliega
	_tut.registrar_capitulo("cap_ctx3", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.TEST_CTX3", "icono_tecla": ""}
	], "meta_ctx3", false, {"requiere_contexto": {"zona": "playa"}})
	_tut.establecer_contexto({"zona": "jungla"})
	_tut.desplegar_capitulo("cap_ctx3")
	_check(_tut.activo_actual != "cap_ctx3", "T-016: zona distinta → no despliega")
	_tut.establecer_contexto({"zona": "playa"})
	_tut.desplegar_capitulo("cap_ctx3")
	_check(_tut.activo_actual == "cap_ctx3", "T-016: zona correcta → despliega")
	_cerrar_capitulo_activo()
	# Cozy: sin datos del proveedor (-1 / "") NO se bloquea
	_tut.registrar_capitulo("cap_ctx4", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.TEST_CTX4", "icono_tecla": ""}
	], "meta_ctx4", false, {"requiere_contexto": {"zona": "playa"}})
	_tut.establecer_contexto({"hora": -1, "zona": ""})
	_tut.desplegar_capitulo("cap_ctx4")
	_check(_tut.activo_actual == "cap_ctx4", "T-016: sin datos del proveedor NO se bloquea (cozy)")
	_cerrar_capitulo_activo()
	# Higiene: dejar el contexto neutro para los tests siguientes
	_tut._contexto = {"hora": -1, "dia": -1, "estacion": -1, "zona": ""}
	_tut.capitulo_pospuesto.disconnect(cb)

## P4: reinicio a mitad de capítulo → se retoma desde el paso pendiente; las
## preferencias del jugador (RF9) viajan en el guardado (liviano, < 1 KB).
func _test_pasos_y_persistencia_p4() -> void:
	_reset()
	_tut.registrar_capitulo("cap_p4", [
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.P4_A", "meta": "m_p4", "icono_tecla": ""},
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.P4_B", "meta": "m_p4", "icono_tecla": ""},
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.P4_C", "meta": "m_p4", "icono_tecla": ""}
	], "m_p4", false)
	# Guardado realista a mitad de capítulo: 1 paso ya mostrado
	_tut._paso_pendiente["cap_p4"] = 1
	var data: Dictionary = _tut.get_save_data()
	_check(data.get("paso_pendiente", {}).has("cap_p4"), "P4: el paso pendiente viaja en get_save_data()")
	_check(int(data["paso_pendiente"]["cap_p4"]) == 1, "P4: el progreso guardado es el correcto")
	# RF9: las 3 preferencias independientes también persisten
	_tut.set_pistas_contextuales(false)
	_tut.set_prologo_guiado(false)
	_tut.set_consejos(false)
	data = _tut.get_save_data()
	_check(data["pistas_on"] == false and data["prologo_on"] == false and data["consejos_on"] == false,
		"RF9: las 3 preferencias viajan en el guardado")
	# Simular reinicio del juego: estado en memoria limpio → restaurar
	_tut._paso_pendiente.clear()
	_tut.restore_save_data(data)
	_check(_tut.paso_pendiente("cap_p4") == 1, "P4: tras reiniciar se retoma desde el paso 1")
	_check(_tut.pistas_contextuales_on() == false and _tut.prologo_guiado_on() == false and _tut.consejos_on() == false,
		"RF9: las preferencias se restauran del guardado")
	_tut.set_pistas_contextuales(true)
	_tut.set_prologo_guiado(true)
	_tut.set_consejos(true)
	# Desplegar retoma desde el paso pendiente: NO repite el paso ya visto
	var mostrados: Array = []
	var cb := func(_cap: String, paso: Dictionary) -> void:
		mostrados.append(String(paso.get("texto_clave", "")))
	_tut.paso_mostrado.connect(cb)
	_tut.desplegar_capitulo("cap_p4")
	_check(mostrados.size() == 2, "P4: retoma mostrando solo los pasos restantes (2 de 3)")
	_check(not mostrados.has("TUTORIAL.P4_A"), "P4: el paso ya visto NO se repite")
	_check(mostrados.has("TUTORIAL.P4_B") and mostrados.has("TUTORIAL.P4_C"),
		"P4: se muestran los pasos restantes en orden")
	_tut.paso_mostrado.disconnect(cb)
	_cerrar_capitulo_activo()

## RF7/S5: skip por capítulo (NO lo marca completado) y skip global (SKIPPED);
## ambos persisten y las pistas se ocultan de inmediato y sin parpadeo.
func _test_skip_s5() -> void:
	_reset()
	_tut.registrar_capitulo("cap_skip", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.SKIP1", "icono_tecla": ""},
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.SKIP2", "meta": "m_skip", "icono_tecla": ""}
	], "m_skip", false)
	_tut.desplegar_capitulo("cap_skip")
	_check(_tut.activo_actual == "cap_skip", "S5: capítulo desplegado antes del skip")
	_tut.registrar_pista("p_skip", "cap_skip", 60.0)
	_check(_tut.pistas_vivas() == 1, "S5: hay 1 pista viva antes del skip")
	_tut.skip_capitulo("cap_skip")
	_check(_tut.activo_actual == "", "RF7: skip libera el guion actual")
	_check(_tut.estado == 1, "RF7: el estado vuelve a ESPERANDO")
	_check(not _tut.capitulo_estado("m_skip"), "RF7: el capítulo salteado NO se marca completado")
	_check(_tut.paso_pendiente("cap_skip") == 0, "RF7: el progreso del capítulo salteado se limpia")
	_check(_tut.pistas_vivas() == 0, "T-095: las pistas se ocultan de inmediato al saltear")
	# Skip GLOBAL: SKIPPED + persistido
	_tut.skip_todo()
	_check(_tut.estado == 4, "S5: skip_todo deja el estado en SKIPPED (4)")
	_check(bool(_tut.get_save_data().get("skip", false)) == true, "S5: el skip global se persiste")
	_tut.desplegar_capitulo("cap_skip")
	_check(_tut.activo_actual == "", "S5: con skip global ningún capítulo se despliega")
	# Cozy: reversible
	_tut.reanudar()
	_check(_tut.estado == 1, "S5: reanudar() vuelve a ESPERANDO")
	# El skip global también se restaura desde el guardado
	_tut.restore_save_data({"skip": true, "completados": [], "consejos_vistos": []})
	_check(_tut.estado == 4, "S5: skip global restaurado desde el guardado")
	_tut.reanudar()
	_tut.descartar_pistas("reset_test")

## RF8/S6: re-play con snapshot — muestra TODOS los pasos SIN contaminar la
## partida (no agrega completados ni pisa el estado en curso, RN11).
func _test_replay_s6() -> void:
	_reset()
	_tut.registrar_capitulo("cap_replay", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.RP1", "icono_tecla": ""},
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.RP2", "meta": "m_replay", "icono_tecla": ""}
	], "m_replay", false)
	# Jugador experto: ya dominó la meta en el pasado → despliegue silencioso
	_tut.cumplir_meta("m_replay")
	_tut.desplegar_capitulo("cap_replay")
	_check(_tut.capitulo_estado("cap_replay"), "S6: la revalidación completó el capítulo en silencio")
	var completados_antes: Array = _tut.capitulos_completados().duplicate()
	var mostrados: Array = []
	var cb := func(_cap: String, paso: Dictionary) -> void:
		mostrados.append(String(paso.get("texto_clave", "")))
	_tut.paso_mostrado.connect(cb)
	var snapshot: Dictionary = _tut.iniciar_replay("cap_replay")
	_check(not snapshot.is_empty(), "S6: iniciar_replay devuelve el snapshot del estado previo")
	_check(_tut.en_replay() == true, "S6: en_replay() refleja el modo re-play")
	_check(_tut.activo_actual == "cap_replay", "S6: el capítulo se activa en modo re-play")
	_check(mostrados.size() == 2, "T-100: el re-play muestra TODOS los pasos (sin revalidar)")
	_tut.terminar_replay()
	_check(_tut.en_replay() == false, "S6: terminar_replay cierra el modo")
	_check(_tut.activo_actual == "", "S6: el estado en curso se restaura (nada colgado)")
	_check(_tut.capitulos_completados() == completados_antes, "S6: la partida NO se contamina (mismos completados)")
	_tut.paso_mostrado.disconnect(cb)
## P5: el objeto de la lección fue destruido (árbol talado, parcela removida) →
## cuenta como intento; al agotar las re-programaciones → descarte seguro.
## P6: el nodo objetivo está fuera del mundo activo (M63) → el capítulo se PAUSA
## y se retoma cuando el mundo vuelve (nunca se pierde).
func _test_objetivo_destruido_p5_mundo_p6() -> void:
	_reset()
	_tut.registrar_capitulo("cap_p5", [
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.P5", "meta": "m_p5", "icono_tecla": ""}
	], "m_p5", false)
	var descartados: Array = []
	var cb := func(cap: String) -> void:
		descartados.append(cap)
	_tut.capitulo_descartado.connect(cb)
	_check(_tut.notificar_objetivo_destruido("cap_p5") == false, "P5: 1er objeto destruido NO descarta")
	_check(_tut.notificar_objetivo_destruido("cap_p5") == false, "P5: 2do objeto destruido NO descarta")
	_check(_tut.notificar_objetivo_destruido("cap_p5") == true, "P5: al 3er objeto destruido se descarta")
	_check(descartados.has("cap_p5"), "P5: señal capitulo_descartado emitida")
	_check(not _tut.capitulo_estado("m_p5"), "P5: el descarte NO completa el capítulo (sin castigo)")
	_check(not _tut.esta_activo(), "P5: sin bloqueo tras el descarte")
	# Cozy: re-activable (el jugador puede re-plantar el árbol)
	_tut.reactivar_descartado("cap_p5")
	_tut.desplegar_capitulo("cap_p5")
	_check(_tut.activo_actual == "cap_p5", "P5: reactivar_descartado permite retomarlo")
	# P6: mundo inactivo (M63) → pausa, sin perder el capítulo
	_tut.pausar_por_mundo_inactivo("cap_p5")
	_check(_tut.activo_actual == "", "P6: el capítulo se pausa (no queda activo)")
	_check(_tut.estado == 1, "P6: el estado vuelve a ESPERANDO")
	_check(not _tut.capitulo_estado("m_p5"), "P6: el capítulo pausado NO se pierde ni se completa")
	# Al volver el mundo activo, el capítulo se retoma
	_tut.desplegar_capitulo("cap_p5")
	_check(_tut.activo_actual == "cap_p5", "P6: al reactivarse el mundo el capítulo se retoma")
	_cerrar_capitulo_activo()
	_tut.capitulo_descartado.disconnect(cb)

## RF24 (T-033/T-034) + P15: feedback breve NO modal al completar, y el estado
## se PERSISTE ANTES del feedback (si el jugador cierra el juego en ese instante,
## el capítulo ya quedó registrado).
func _test_feedback_rf24_p15() -> void:
	_reset()
	_tut.registrar_capitulo("cap_fb", [
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.FB", "meta": "m_fb", "icono_tecla": ""}
	], "m_fb", false)
	var orden: Array = []
	var datos_fb: Array = []
	var persistido: Array = []
	var cb_comp := func(_cap: String) -> void:
		orden.append("completado")
	var cb_fb := func(_cap: String, datos: Dictionary) -> void:
		orden.append("feedback")
		datos_fb.append(datos)
		persistido.append("cap_fb" in _tut.get_save_data().get("completados", []))
	_tut.capitulo_completado.connect(cb_comp)
	_tut.feedback_capitulo.connect(cb_fb)
	_tut.desplegar_capitulo("cap_fb")
	_tut.cumplir_meta("m_fb")
	_check(orden == ["completado", "feedback"], "P15: el cierre del capítulo ocurre ANTES del feedback")
	_check(persistido.size() == 1 and persistido[0] == true,
		"P15: al llegar el feedback el capítulo YA está en el guardado")
	var d: Dictionary = datos_fb[0] if datos_fb.size() > 0 else {}
	_check(d.get("modal", true) == false, "T-034: el feedback NUNCA es modal")
	_check(absf(float(d.get("duracion_s", 0.0)) - 2.0) < 0.001, "RF24: el mensaje dura 2 s")
	_check(String(d.get("sonido", "")) == "exito", "RF24: sonido de éxito (M44)")
	_check(d.has("texto_clave"), "RF24: el texto viaja como clave de localización")
	_check(not _tut.esta_activo(), "T-034: el feedback no deja el tutorial bloqueado")
	_check(_tut.capitulo_estado("cap_fb"), "P15: el capítulo quedó completado")
	_tut.capitulo_completado.disconnect(cb_comp)
	_tut.feedback_capitulo.disconnect(cb_fb)

## P8/P9: el ícono de tecla se lee del InputMap EN VIVO (sin caché): remapear la
## tecla se refleja de inmediato. Acciones inexistentes devuelven "" sin romper.
func _test_icono_tecla_p8() -> void:
	_reset()
	_check(_tut.icono_tecla_dinamico("") == "", "T-037: acción vacía → sin ícono")
	_check(_tut.icono_tecla_dinamico("accion_que_no_existe_m92") == "",
		"T-037: acción inexistente → sin ícono (no rompe)")
	# Acción de prueba aislada (no toca el InputMap real del juego)
	InputMap.add_action("m92_test_accion")
	var k1 := InputEventKey.new()
	k1.keycode = KEY_A
	InputMap.action_add_event("m92_test_accion", k1)
	_check(_tut.icono_tecla_dinamico("m92_test_accion") == k1.as_text(),
		"P8: el ícono sale del InputMap")
	# P8: el jugador remapea la tecla → el ícono cambia en vivo
	InputMap.action_erase_events("m92_test_accion")
	var k2 := InputEventKey.new()
	k2.keycode = KEY_Z
	InputMap.action_add_event("m92_test_accion", k2)
	var nuevo: String = _tut.icono_tecla_dinamico("m92_test_accion")
	_check(nuevo == k2.as_text(), "P8: tras remapear, el ícono se actualiza en vivo")
	_check(nuevo != k1.as_text(), "P8: el ícono viejo ya no se sirve (no hay caché)")
	# Limpieza: no dejar contaminado el InputMap global
	InputMap.erase_action("m92_test_accion")
	_check(_tut.icono_tecla_dinamico("m92_test_accion") == "", "P8: la acción de prueba se elimina limpio")


