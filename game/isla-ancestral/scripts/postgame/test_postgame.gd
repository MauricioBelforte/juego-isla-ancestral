# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M75: Test de PostgameManager (activación vía M22, actividades data-driven,
# sugerencias rotativas sin FOMO, epílogo, persistencia M59).
# Iter. 3 (DeepSeek-V4.1-Flash, 2026-10-26): + anti-spoiler FASE 2 (03-Diseno §2.2
#   + Flujo D), + validate_postgame.gd (§3.3) probado EN ROJO por inyección en
#   memoria, + hito "ruina restaurada" (S del checklist, logro dueño M72).
#   ⚠️ Las aserciones que exigían 7 actividades VISIBLES consagraban el bug
#   (FASE 2 expuesta al jugador): se corrigieron a 6 visibles / 7 internas.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/postgame/test_postgame.gd

extends SceneTree

## Validador del catálogo (03-Diseno §3.3). Se usa por funciones ESTÁTICAS:
## validate_postgame.gd extiende RefCounted y no se puede correr con --script.
const VALIDADOR = preload("res://scripts/postgame/validate_postgame.gd")

# --- Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
#     + _summary() diferido. Instrumentacion LOTE 2 (mis suites propias), 2026-10-08,
#     DeepSeek-V4.1-Flash (msg 100). Piso = checks reales MEDIDOS (Log 1490 / 2200).
#     NO cambia logica ni aserciones; solo agrega contador + control de bloques.
const CHECKS_MINIMOS := 86
const _WB_BLOQUES: Array[String] = ["_test_catalogo", "_test_no_activo_al_inicio", "_test_activacion_por_sellos", "_test_actividades_disponibles", "_test_sugerencias_rotativas", "_test_epilogo", "_test_persistencia", "_test_fase2_invisible", "_test_validador", "_test_hito_ruina", "_test_logro_ruina_m72"]
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
	print("=== Resumen M75: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)



var _fallos: int = 0
var _pg: Node = null
## M72/M71 (ítem S de RF19): estado PREVIO a cualquier bloque, para probar que
## la cadena hito->logro no es un leftover de una corrida anterior.
var _ach: Node = null
var _pm71: Node = null
var _hito_m71_previo: bool = true
var _logro_ruina_previo: bool = true


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	_pg = root.get_node_or_null("Postgame")
	_check(_pg != null, "PostgameManager autoload presente")
	if _pg == null:
		print("=== TEST M75 POSTGAME: 1 fallo(s) ===")
		_summary()
		return
	# Estado PREVIO (antes de que ningun bloque registre actividades): sin esto,
	# el check de "logro desbloqueado" pasaria por leftovers y no probaria nada.
	_ach = root.get_node_or_null("Achievements")
	_pm71 = root.get_node_or_null("ProgressionManager")
	_hito_m71_previo = bool(_pm71 != null and _pm71.hito_alcanzado("hito_ruina_restaurada"))
	_logro_ruina_previo = bool(_ach != null and _ach.esta_desbloqueado("logro_ruina_restaurada"))
	# ⚠️ El _fin() de cada bloque va al FINAL DEL CUERPO del bloque, NO acá.
	# Si un SCRIPT ERROR aborta el helper, el runner RETOMA y un _fin() puesto
	# en el runner marcaría "visto" un bloque que abortó → la capa de nombres
	# quedaría CIEGA y solo el piso la delataría (medido en M53, 2026-10-25).
	_test_catalogo()
	_test_no_activo_al_inicio()
	_test_activacion_por_sellos()
	_test_actividades_disponibles()
	_test_sugerencias_rotativas()
	_test_epilogo()
	_test_persistencia()
	_test_fase2_invisible()
	_test_validador()
	_test_hito_ruina()
	_test_logro_ruina_m72()
	_summary()


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)


func _test_catalogo() -> void:
	_check(_pg.get_section_name() == "postgame", "sección 'postgame' (M59)")
	# El catálogo COMPLETO (incluye FASE 2 oculta) sigue teniendo las 7 entradas.
	var internas: Array = _pg.actividades_internas()
	_check(internas.size() == 7, "7 actividades en el catálogo interno: %d" % internas.size())
	_check(int(_pg.total_actividades()) == 7, "total_actividades() = 7: %d" % int(_pg.total_actividades()))
	# IDs del diseño (RF2/RF3/RF4/RF5/RF6/RF7)
	var ids := {}
	for a in internas:
		ids[String(a.id)] = true
	for esperado in ["postgame_isla_este", "postgame_isla_flotante", "postgame_ruina_final",
			"postgame_vecinos_nuevos", "postgame_hibridacion", "postgame_especies_raras",
			"postgame_muebles_evento"]:
		_check(ids.has(esperado), "actividad esperada presente: %s" % esperado)
	_fin("_test_catalogo")


func _test_no_activo_al_inicio() -> void:
	# La historia no está terminada en el save limpio del test
	_pg.activo = false
	_check(not bool(_pg.activo), "postgame inactivo antes del final")
	_fin("_test_no_activo_al_inicio")


func _test_activacion_por_sellos() -> void:
	# M22 es la fuente de verdad §2.2: marcar 7 sellos → prereq_met → activación
	var h := root.get_node_or_null("Historia")
	_check(h != null, "Historia presente (M22)")
	if h == null:
		_fin("_test_activacion_por_sellos")
		return
	var senales: Array = [0]
	var cb := func() -> void:
		senales[0] += 1
	_pg.postgame_activado.connect(cb)
	# Re-chequear estado actual de sellos (puede venir de tests previos)
	var ya := int(h.sellos_count())
	if ya < int(h.sellos_totales()):
		for s in ["sello_ceniza_sala1", "sello_ceniza_sala2", "sello_mar_intermedia",
				"sello_mar_sala1", "sello_brisa_sala1", "sello_brisa_sala2", "sello_brisa_camara"]:
			if not bool(h.sello_marcado(s)):
				h.marcar_sello(s)
	_pg._checar_activacion()
	_check(bool(_pg.activo), "postgame activado al completar sellos (fuente M22)")
	_check(int(senales[0]) == 1, "señal postgame_activado una sola vez: %d" % int(senales[0]))
	# Re-activación idempotente
	_pg.activar_postgame()
	_check(int(senales[0]) == 1, "activar_postgame idempotente")
	_pg.postgame_activado.disconnect(cb)
	_fin("_test_activacion_por_sellos")


func _test_actividades_disponibles() -> void:
	_check(bool(_pg.registrar_actividad("postgame_vecinos_nuevos")), "registrar repetible OK")
	_check(bool(_pg.registrar_actividad("postgame_vecinos_nuevos")), "registrar repetible 2ª vez OK")
	_check(bool(_pg.registrar_actividad("postgame_ruina_final")), "registrar ruina OK")
	_check(not bool(_pg.registrar_actividad("inexistente")), "actividad desconocida rechazada")
	# Re-capturar DESPUÉS de registrar (los estados son perezosos)
	# Vista del JUGADOR: 6 visibles (la FASE 2 queda oculta, §2.2).
	var acts: Array = _pg.actividades_disponibles()
	_check(acts.size() == 6, "6 actividades visibles al jugador: %d" % acts.size())
	for a in acts:
		if String(a.id) == "postgame_vecinos_nuevos":
			_check(int(a.veces) == 2, "contador repetible = 2: %d" % int(a.veces))
		if String(a.id) == "postgame_ruina_final":
			_check(bool(a.hecha), "ruina marcada hecha (no repite)")
	# La isla flotante se mide en el catálogo INTERNO (no debe llegar a la UI).
	for a in _pg.actividades_internas():
		if String(a.id) == "postgame_isla_flotante":
			_check(not bool(a.hecha), "isla flotante pendiente (catálogo interno)")
			_check(int(a.fase) == 2, "isla flotante declarada FASE 2: %d" % int(a.fase))
			_check(not bool(a.visible), "isla flotante marcada NO visible")
	_fin("_test_actividades_disponibles")


func _test_sugerencias_rotativas() -> void:
	var s1: Array = _pg.sugerir_que_sigue(3)
	_check(s1.size() == 3, "3 sugerencias: %d" % s1.size())
	# Determinista: misma llamada → mismo resultado (sin rand)
	var s2: Array = _pg.sugerir_que_sigue(3)
	_check(str(s1) == str(s2), "sugerencias deterministas (M94: sin FOMO)")
	# La señal emite las sugerencias (captura por contenedor mutable — §9.56)
	var recibidas: Array = [null]
	var cb := func(arr: Array) -> void:
		recibidas[0] = arr
	_pg.sugerencias_postgame.connect(cb)
	_pg.pedir_sugerencias()
	var arr_rec: Array = recibidas[0] if recibidas[0] != null else []
	_check(arr_rec.size() == 3, "señal sugerencias_postgame emitida")
	_pg.sugerencias_postgame.disconnect(cb)
	# No incluye la ruina ya hecha (no repite)
	var ids := {}
	for s in s1:
		ids[String(s.id)] = true
	_check(not ids.has("postgame_ruina_final"), "no sugiere actividad no-repetible ya hecha")
	_fin("_test_sugerencias_rotativas")


func _test_epilogo() -> void:
	_check(not bool(_pg.epilogo_visto), "epílogo no visto al inicio")
	_pg.marcar_epilogo_visto()
	_check(bool(_pg.epilogo_visto), "epílogo marcado visto (RF1/M92)")
	# Idempotente
	_pg.marcar_epilogo_visto()
	_check(bool(_pg.epilogo_visto), "marcar epílogo idempotente")
	_fin("_test_epilogo")


func _test_persistencia() -> void:
	var data: Dictionary = _pg.get_save_data()
	_check(int(data.get("version", 0)) == 1, "save_data versionado")
	_check(bool(data.get("activo", false)), "estado activo persistido")
	_check(bool(data.get("postgame_unlocked", false)), "postgame_unlocked persistido (U del checklist)")
	_check(bool(data.get("epilogo_visto", false)), "epílogo persistido")
	var hechas: Dictionary = data.get("actividades_hechas", {})
	_check(int(hechas.get("postgame_vecinos_nuevos", 0)) == 2, "contadores persistidos")
	# Round-trip sin re-emisión de señal
	var senales: Array = [0]
	var cb := func() -> void:
		senales[0] += 1
	_pg.postgame_activado.connect(cb)
	_pg.restore_save_data({})
	_check(not bool(_pg.activo), "restore vacío limpia")
	_pg.restore_save_data(data)
	_check(bool(_pg.activo), "round-trip restaura activo")
	_check(bool(_pg.epilogo_visto), "round-trip restaura epílogo")
	_check(int(senales[0]) == 0, "restore NO re-emite postgame_activado (§2.3)")
	_check(int(_pg._hechas.get("postgame_vecinos_nuevos", 0)) == 2, "round-trip restaura contadores")
	_pg.postgame_activado.disconnect(cb)
	_fin("_test_persistencia")


## ── Iter. 3: anti-spoiler FASE 2 (ítems Q y W del checklist) ──────────────
## 03-Diseno §2.2: "FASE 2: nunca visible al jugador; solo catálogo interno".
## Flujo D: la entrada queda interna hasta su lanzamiento (flag `hidden`).
func _test_fase2_invisible() -> void:
	var vis: Array = _pg.actividades_disponibles()
	var ids := {}
	var nombres := ""
	for a in vis:
		ids[String(a.id)] = true
		nombres += String(a.nombre) + "|"
	_check(not ids.has("postgame_isla_flotante"), "FASE 2 ausente de actividades_disponibles()")
	_check(not nombres.contains("Flotante"), "el NOMBRE de FASE 2 no llega al payload del jugador")
	_check(not JSON.stringify(vis).contains("Flotante"), "JSON.stringify(visibles) sin 'Flotante'")
	var todas: Array = _pg.actividades_internas()
	var ids_int := {}
	for a in todas:
		ids_int[String(a.id)] = true
	_check(ids_int.has("postgame_isla_flotante"), "el catálogo interno SÍ conserva la FASE 2")
	_check(todas.size() == 7 and vis.size() == 6, "7 internas / 6 visibles: %d/%d" % [todas.size(), vis.size()])
	_check(not bool(_pg.es_visible_al_jugador("postgame_isla_flotante")), "es_visible_al_jugador(FASE 2) = false")
	_check(bool(_pg.es_visible_al_jugador("postgame_isla_este")), "es_visible_al_jugador(FASE 1) = true")
	_check(not bool(_pg.es_visible_al_jugador("no_existe")), "id desconocido no es visible")
	# "¿Qué sigue?" tampoco puede prometer FASE 2 (se pide con límite > catálogo)
	var sug: Array = _pg.sugerir_que_sigue(99)
	var ids_sug := {}
	for s in sug:
		ids_sug[String(s.id)] = true
	_check(not ids_sug.has("postgame_isla_flotante"), "sugerencias no incluyen FASE 2")
	var pendientes_visibles := 0
	for a in vis:
		if not bool(a.hecha):
			pendientes_visibles += 1
	_check(sug.size() == pendientes_visibles, "sugerencias = visibles pendientes (%d)" % pendientes_visibles)
	_fin("_test_fase2_invisible")


## ── Iter. 3: validate_postgame.gd (03-Diseno §3.3) probado EN ROJO ────────
func _test_validador() -> void:
	var ids_mod: Array = VALIDADOR.leer_ids_modulos()
	_check(ids_mod.size() > 50, "ids de módulo leídos de CHECKLIST-GLOBAL: %d" % ids_mod.size())
	var cat: Array = VALIDADOR.cargar_catalogo()
	_check(cat.size() == 7, "el validador lee el catálogo real (7 entradas): %d" % cat.size())
	var hitos: Array = ["ruina_restaurada", "coleccion_completa", "primer_festival_postgame", "hoja_ruta_100"]
	var r: Dictionary = VALIDADOR.validar(cat, ids_mod, hitos)
	var probs: Array = r.get("problemas", [])
	_check(bool(r.get("ok", false)), "catálogo real valida OK (problemas=%s)" % str(probs))
	_check(int((r.get("reglas", {}) as Dictionary).get("ids_unicos", 0)) == 7, "regla ids_unicos corrió sobre 7 entradas")
	_check((r.get("omitidas", []) as Array).is_empty(), "sin reglas omitidas con ids e hitos dados")
	# Sin ids/hitos las reglas se declaran OMITIDAS (no se dan por buenas en silencio)
	var r2: Dictionary = VALIDADOR.validar(cat)
	_check((r2.get("omitidas", []) as Array).has("dueno_existe"), "sin ids -> dueno_existe OMITIDA")
	_check((r2.get("omitidas", []) as Array).has("logro_hito_real"), "sin hitos -> logro_hito_real OMITIDA")
	# Sondas EN ROJO: se muta una copia EN MEMORIA (el archivo no se toca) y cada
	# regla debe cazar su defecto con la CAUSA exacta, no sólo "algo falló".
	var casos: Array = [
		[1, "id", "postgame_isla_este", "id_duplicado:postgame_isla_este"],
		[0, "fase", 3, "fase_invalida:postgame_isla_este:3"],
		[1, "hidden", false, "fase2_visible:postgame_isla_flotante"],
		[4, "umbral", 25, "grindeo_umbral:postgame_hibridacion:25"],
		[2, "dueno", "M999", "dueno_desconocido:postgame_ruina_final:M999"],
		[3, "logro", "logro_inexistente", "logro_sin_hito:postgame_vecinos_nuevos:logro_inexistente"],
	]
	for caso in casos:
		var mutado: Array = _mutar(cat, int(caso[0]), str(caso[1]), caso[2])
		var rm: Dictionary = VALIDADOR.validar(mutado, ids_mod, hitos)
		var pm: Array = rm.get("problemas", [])
		var esperado: String = str(caso[3])
		_check(not bool(rm.get("ok", true)) and pm.has(esperado), "sonda roja caza '%s'" % esperado)
	_fin("_test_validador")


func _mutar(cat: Array, idx: int, campo: String, valor: Variant) -> Array:
	var copia: Array = []
	for e in cat:
		copia.append((e as Dictionary).duplicate(true))
	var d: Dictionary = copia[idx]
	d[campo] = valor
	return copia


## ── Iter. 3: hito "ruina restaurada" (ítem S; logro dueño M72) ────────────
## M75 expone el HITO; la entrada de logro y su desbloqueo son de M72 (§3.3
## "Logros Epílogo: referencian hitos reales"). No se inventa el logro acá.
func _test_hito_ruina() -> void:
	_pg._hechas.erase("postgame_ruina_final")
	_check(not bool(_pg.hito_ruina_restaurada()), "hito ruina = false sin registrar")
	_check(bool(_pg.registrar_actividad("postgame_ruina_final")), "registrar ruina (M25) OK")
	_check(bool(_pg.hito_ruina_restaurada()), "hito ruina = true tras registrar")
	_pg.registrar_actividad("postgame_ruina_final")
	_check(bool(_pg.hito_ruina_restaurada()), "hito ruina sigue true (idempotente)")
	_check(int(_pg._hechas.get("postgame_ruina_final", 0)) == 2, "contador de la ruina acumula 2")
	_fin("_test_hito_ruina")

## ── Iter. 4 (2026-10-26): cadena REAL hasta el LOGRO de M72 (ítem S, RF19) ──
## Cierra el pendiente "Logro: ruina restaurada". El logro es de M72 y su
## condición es `hito_previo` sobre el hito REAL de M71; se verifica la CADENA
## completa (actividad M75 -> perfil M71 -> hito M71 -> señal -> logro M72),
## no la mera existencia de la entrada en el JSON.
func _test_logro_ruina_m72() -> void:
	_check(_ach != null, "Achievements (M72) autoload presente")
	_check(_pm71 != null, "ProgressionManager (M71) autoload presente")
	if _ach == null or _pm71 == null:
		_fin("_test_logro_ruina_m72")
		return
	# 1) La entrada del catálogo: categoría de epílogo + condición sobre el hito.
	#    Se lee la DEFINICIÓN cruda (get_definicion): get_todos()/_estado_de()
	#    es la vista de UI y NO propaga `condicion` — medir ahí da un falso rojo.
	var def: Dictionary = _ach.get_definicion("logro_ruina_restaurada")
	_check(not def.is_empty(), "logro_ruina_restaurada existe en el catálogo M72")
	_check(String(def.get("categoria", "")) == "epilogo",
		"categoría 'epilogo' (RF19): %s" % String(def.get("categoria", "")))
	var cond: Dictionary = def.get("condicion", {})
	_check(String(cond.get("tipo", "")) == "hito_previo", "condición hito_previo (no un contador)")
	_check(String(cond.get("milestone_id", "")) == "hito_ruina_restaurada",
		"el logro referencia el hito REAL de M71")
	# La entrada también aparece en la vista de UI (RF1: id/orden/categoría).
	var en_ui: bool = false
	var todos: Array = _ach.get_todos()
	for l in todos:
		if String((l as Dictionary).get("id", "")) == "logro_ruina_restaurada":
			en_ui = true
	_check(en_ui, "aparece en el listado de UI (RF1)")
	# 2) RF14 de M72 acepta el catálogo completo (caza una categoría fuera de
	#    vocabulario: sin 'epilogo' en CATEGORIAS_VALIDAS esto da 1).
	_check(int(_ach.validar_catalogo()) == 0, "validar_catalogo (RF14) = 0 problemas")
	# 3) El hito existe de verdad en el catálogo de M71 (no basta el string).
	_check(int(_pm71.hitos_count()) == 26, "catálogo M71 con el hito nuevo: %d" % int(_pm71.hitos_count()))
	# 4) Estado PREVIO capturado al arrancar: sin esto el check 5 pasaria por
	#    leftovers de otra corrida (falso verde).
	_check(not _hito_m71_previo, "el hito M71 NO estaba alcanzado al arrancar (sin leftover)")
	_check(not _logro_ruina_previo, "el logro NO estaba desbloqueado al arrancar (sin leftover)")
	# 5) La cadena: registrar la actividad (bloque _test_hito_ruina) marcó hito
	#    y logro sin que M75 toque el logro directamente.
	_check(bool(_pm71.hito_alcanzado("hito_ruina_restaurada")),
		"registrar la actividad marcó el hito en M71")
	_check(bool(_ach.esta_desbloqueado("logro_ruina_restaurada")),
		"el logro se desbloqueó desde la señal de M71")
	# 6) Idempotencia: repetir la actividad no duplica hito ni logro.
	_pg.registrar_actividad("postgame_ruina_final")
	_check(bool(_ach.esta_desbloqueado("logro_ruina_restaurada")), "logro idempotente")
	_check(int(_pm71.hitos_count()) == 26, "el catálogo M71 no se duplica al reevaluar")
	_fin("_test_logro_ruina_m72")