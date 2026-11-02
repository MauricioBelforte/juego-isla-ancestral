# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-11-01
#
# M110 (Debug Menu) - suite de la CAPA VISUAL REAL (DebugVisualizer + Depurador3D).
#
# Contexto medido: la version anterior del visualizer creaba 5 `BoxMesh` fijos al
# lado del jugador y no enumeraba NINGUN nodo del mundo; `03-Diseno.md` §4 pide
# `DebugDraw.*`, una API que no existe en Godot 4.7.2, y enumera por grupos
# (`colliders`, `entities`) y accesores (`get_hitbox`, `get_ai_state`) que el repo
# no tiene. Esta suite prueba que la capa nueva dibuja artefactos REALES y que
# respeta el gate de visibilidad (L268).
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral \
#     --script res://scripts/debug/test_debug_visualizer_real_m110.gd
#
# Guardas anti-falso-verde (3 capas, skill isla-ancestral-ciclo-modulo):
#   1. `_fin(bloque)` al FINAL del cuerpo de cada bloque (NO en el runner).
#   2. `CHECKS_MINIMOS` = piso MEDIDO en verde (nunca estimado).
#   3. `_summary()` en un `call_deferred` SEPARADO: si `_run()` aborta por un
#      SCRIPT ERROR, el resumen corre igual, nombra los bloques faltantes y
#      sale con EXIT 1 en vez de colgarse.

extends SceneTree

const MODULO := "M110"
const VIS := preload("res://scripts/debug/debug_visualizer.gd")
const DEP := preload("res://scripts/debug/depurador_3d.gd")
const RUTA_VIS := "res://scripts/debug/debug_visualizer.gd"
const RUTA_DEP := "res://scripts/debug/depurador_3d.gd"

## Bloques esperados (los nombres que usa `_fin`)
const BLOQUES: Array[String] = ["A", "B", "C", "D", "E", "F", "G", "H"]

## Piso MEDIDO en verde. Re-medir si la suite crece; nunca estimar.
const CHECKS_MINIMOS: int = 66

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}
var _raiz: Node3D = null
var _vis: Node3D = null
var _menu: Node = null
var _texto_vis: String = ""
var _texto_dep: String = ""


## Menu falso con el MISMO contrato que `debug_menu.gd` para la capa visual:
## `is_visible()` + `toggle_<tipo>()` + `visualizacion_activa(id)`.
class FakeMenu extends Node:
	var visible := false
	var toggles: Dictionary = {
		"colliders": false, "chunks": false, "navigation": false,
		"hitboxes": false, "ai_states": false,
	}

	func is_visible() -> bool:
		return visible

	func esta_visible() -> bool:
		return visible

	func toggle_colliders(v: bool) -> void:
		toggles["colliders"] = v

	func toggle_chunks(v: bool) -> void:
		toggles["chunks"] = v

	func toggle_navigation(v: bool) -> void:
		toggles["navigation"] = v

	func toggle_hitboxes(v: bool) -> void:
		toggles["hitboxes"] = v

	func toggle_ai_states(v: bool) -> void:
		toggles["ai_states"] = v

	func visualizacion_activa(id: String) -> bool:
		return visible and bool(toggles.get(id, false))


## NPC falso con el accesor REAL que usa el proyecto (`npc_agent.gd`).
class FakeNpc extends Node3D:
	var estado: StringName = &"idle"
	var _sm: Node = null

	func get_state_machine() -> Node:
		if _sm == null:
			_sm = FakeSM.new()
			_sm.estado = estado
		return _sm


class FakeSM extends Node:
	var estado: StringName = &"idle"

	func get_current_state_name() -> StringName:
		return estado


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")  # corre aunque _run() aborte (SCRIPT ERROR)


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("[FALLO] " + msg)


func _fin(bloque: String) -> void:
	_vistos[bloque] = true
	print("[FIN] bloque %s (acumulado %d checks)" % [bloque, _checks])


func _summary() -> void:
	for b in BLOQUES:
		if not _vistos.has(b):
			_checks += 1
			_fallos += 1
			print("[FALLO] el bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_checks += 1
		_fallos += 1
		print("[FALLO] solo %d checks ejecutados (minimo medido %d)"
			% [_checks - 1, CHECKS_MINIMOS])
	print("=== Resumen %s visualizer-real: %d checks, %d fallo(s) ==="
		% [MODULO, _checks, _fallos])
	quit(1 if _fallos > 0 else 0)


func _run() -> void:
	_texto_vis = FileAccess.get_file_as_string(RUTA_VIS)
	_texto_dep = FileAccess.get_file_as_string(RUTA_DEP)
	_raiz = Node3D.new()
	_raiz.name = "RaizSonda"
	get_root().add_child(_raiz)
	_bloque_a()
	_bloque_b()
	_bloque_c()
	_bloque_d()
	_bloque_e()
	_bloque_f()
	_bloque_g()
	_bloque_h()
	if _vis != null:
		_vis.free()
		_vis = null
	if _raiz != null:
		_raiz.free()
		_raiz = null


# ── Helpers ──────────────────────────────────────────────────────────────────

func _nuevo_visualizer(con_menu: bool) -> Node3D:
	if _vis != null:
		_vis.free()
		_vis = null
	var v: Node3D = VIS.new()
	_raiz.add_child(v)
	v._inyectar_raiz(_raiz)
	if con_menu:
		if _menu == null:
			_menu = FakeMenu.new()
			get_root().add_child(_menu)
		v._inyectar_menu(_menu)
	return v


func _caja_colision(padre: Node3D, pos: Vector3, tam: Vector3) -> CollisionShape3D:
	var cs := CollisionShape3D.new()
	var forma := BoxShape3D.new()
	forma.size = tam
	cs.shape = forma
	padre.add_child(cs)
	cs.global_position = pos
	return cs


func _esfera_colision(padre: Node3D, pos: Vector3, radio: float) -> CollisionShape3D:
	var cs := CollisionShape3D.new()
	var forma := SphereShape3D.new()
	forma.radius = radio
	cs.shape = forma
	padre.add_child(cs)
	cs.global_position = pos
	return cs


func _limpia_raiz() -> void:
	for h in _raiz.get_children():
		if h != _vis:
			h.free()


func _menciona(texto: String, frag: String) -> bool:
	for linea in texto.split("\n"):
		var l := linea.strip_edges()
		if l.begins_with("#"):
			continue
		if l.contains(frag):
			return true
	return false


# ── Bloque A: Depurador3D (el pincel) ────────────────────────────────────────

func _bloque_a() -> void:
	var d = DEP.new()
	_check(d.superficies() == 0, "A1 depurador vacio: 0 superficies")
	_check(d.segmentos() == 0, "A2 depurador vacio: 0 segmentos")
	d.cerrar()
	_check(d.superficies() == 0, "A3 cerrar() sin geometria no crea superficie")

	d.linea(Vector3.ZERO, Vector3(1, 0, 0))
	d.cerrar()
	_check(d.segmentos() == 1, "A4 una linea = 1 segmento")
	_check(d.vertices() == 2, "A5 una linea = 2 vertices")
	_check(d.superficies() == 1, "A6 una linea = 1 superficie")
	var arr: Array = d.mesh().surface_get_arrays(0)
	var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	_check(verts.size() == 2, "A7 ARRAY_VERTEX real tiene 2 vertices")
	_check(arr[Mesh.ARRAY_COLOR] != null, "A8 la superficie lleva color por vertice")

	d.limpiar()
	_check(d.superficies() == 0 and d.segmentos() == 0, "A9 limpiar() deja el mesh vacio")
	d.caja(AABB(Vector3(-0.5, -0.5, -0.5), Vector3(1, 1, 1)))
	d.cerrar()
	_check(d.segmentos() == 12, "A10 caja = 12 aristas")
	_check(d.vertices() == 24, "A11 caja = 24 vertices")

	d.limpiar()
	d.esfera(Vector3.ZERO, 2.0)
	d.cerrar()
	_check(d.segmentos() == 36, "A12 esfera (3 aros x 12) = 36 segmentos")
	_check(d.vertices() == 72, "A13 esfera = 72 vertices")

	d.limpiar()
	var camino := PackedVector3Array([Vector3.ZERO, Vector3(1, 0, 0), Vector3(1, 0, 1)])
	_check(d.camino(camino) == 2, "A14 camino de 3 puntos = 2 segmentos")
	_check(d.camino(PackedVector3Array([Vector3.ZERO])) == 0, "A15 camino de 1 punto = 0")
	_check(d.camino(PackedVector3Array()) == 0, "A16 camino vacio = 0")

	d.limpiar()
	var nan_ok: bool = d.linea(Vector3(NAN, 0, 0), Vector3.ONE)
	var inf_ok: bool = d.linea(Vector3.ZERO, Vector3(0, INF, 0))
	d.cerrar()
	_check(not nan_ok, "A17 NaN rechazado (ImmediateMesh lo acepta en silencio)")
	_check(not inf_ok, "A18 INF rechazado")
	_check(d.rechazados() == 2, "A19 los 2 rechazos se cuentan")
	_check(d.superficies() == 0, "A20 sin vertices validos no hay superficie")
	_check(d.esfera(Vector3.ZERO, 0.0) == 0, "A21 esfera de radio 0 no dibuja")
	_fin("A")


# ── Bloque B: gate L268 (solo con el menu VISIBLE) ───────────────────────────

func _bloque_b() -> void:
	# B1: sin menu resuelto -> fail-closed, nada de geometria aunque el toggle
	# este encendido.
	_vis = _nuevo_visualizer(false)
	_caja_colision(_raiz, Vector3.ZERO, Vector3.ONE)
	_vis.configurar_manual("colliders", true)
	_vis.redibujar()
	_check(_vis.segmentos_de("colliders") == 0, "B1 sin menu no se dibuja (fail-closed)")
	_check(not _vis.menu_visible(), "B2 menu_visible() false sin menu")

	# B3: con menu pero CERRADO -> tampoco.
	_vis = _nuevo_visualizer(true)
	_menu.visible = false
	_vis.configurar_manual("colliders", true)
	_vis.redibujar()
	_check(_vis.segmentos_de("colliders") == 0, "B3 menu cerrado no dibuja")

	# B4: menu ABIERTO pero toggle del MENU apagado -> tampoco (el menu manda).
	_menu.visible = true
	_menu.toggles["colliders"] = false
	_vis.redibujar()
	_check(_vis.segmentos_de("colliders") == 0, "B4 toggle apagado en el menu no dibuja")

	# B5: menu abierto + toggle encendido -> SI dibuja.
	_menu.toggles["colliders"] = true
	_vis.redibujar()
	_check(_vis.segmentos_de("colliders") > 0, "B5 menu abierto + toggle = dibuja")
	_check(_vis.menu_visible(), "B6 menu_visible() true con el menu abierto")

	# B7: cerrar el menu limpia la geometria en el siguiente frame.
	_menu.visible = false
	_vis.redibujar()
	_check(_vis.segmentos_de("colliders") == 0, "B7 cerrar el menu limpia la geometria")

	# B8: configurar_manual empuja el toggle al menu real (fuente de verdad).
	_menu.visible = true
	_menu.toggles["colliders"] = false
	_vis.configurar_manual("colliders", true)
	_check(bool(_menu.toggles.get("colliders", false)),
		"B8 configurar_manual sincroniza el checkbox del menu")
	_limpia_raiz()
	_fin("B")


# ── Bloque C: colliders REALES (por clase, no por grupo) ─────────────────────

func _bloque_c() -> void:
	_vis = _nuevo_visualizer(true)
	_menu.visible = true
	_vis.configurar_manual("colliders", true)
	var cuerpo := StaticBody3D.new()
	_raiz.add_child(cuerpo)
	_caja_colision(cuerpo, Vector3.ZERO, Vector3(1, 1, 1))
	_caja_colision(cuerpo, Vector3(3, 0, 0), Vector3(2, 2, 2))
	_esfera_colision(cuerpo, Vector3(-3, 0, 0), 1.0)
	_vis.redibujar()
	# 2 cajas x 12 + 1 esfera x 36 = 60
	_check(_vis.segmentos_de("colliders") == 60,
		"C1 2 cajas + 1 esfera = 60 segmentos (12+12+36)")
	var st: Dictionary = _vis.estadisticas().get("colliders", {})
	_check(int(st.get("nodos", 0)) == 3, "C2 enumera 3 CollisionShape3D reales")
	_check(not _vis.capa_ciega("colliders"), "C3 la capa NO esta ciega con nodos reales")

	# C4: una forma no dibujable (capsula) se CUENTA, no se inventa.
	var cap := CollisionShape3D.new()
	var forma_cap := CapsuleShape3D.new()
	forma_cap.radius = 0.5
	forma_cap.height = 2.0
	cap.shape = forma_cap
	cuerpo.add_child(cap)
	cap.global_position = Vector3(0, 5, 0)
	_vis.redibujar()
	_check(_vis.no_dibujables() == 1, "C4 capsula contada como no dibujable")
	_check(_vis.segmentos_de("colliders") == 60,
		"C5 la capsula no agrega segmentos inventados")

	# C6: sin nodos, la capa se declara CIEGA en vez de "todo bien".
	_limpia_raiz()
	_vis.redibujar()
	_check(_vis.capa_ciega("colliders"), "C6 sin nodos la capa se declara ciega")
	_limpia_raiz()
	_fin("C")


# ── Bloque D: hitboxes REALES (Area3D) ───────────────────────────────────────

func _bloque_d() -> void:
	_vis = _nuevo_visualizer(true)
	_menu.visible = true
	_vis.configurar_manual("hitboxes", true)
	var area := Area3D.new()
	_raiz.add_child(area)
	var cs := CollisionShape3D.new()
	var forma := BoxShape3D.new()
	forma.size = Vector3(1, 2, 1)
	cs.shape = forma
	area.add_child(cs)
	_vis.redibujar()
	_check(_vis.segmentos_de("hitboxes") == 12, "D1 Area3D con caja = 12 segmentos")
	_check(int(_vis.estadisticas().get("hitboxes", {}).get("nodos", 0)) == 1,
		"D2 enumera 1 Area3D real")
	# D3: Area3D sin forma no dibuja y se cuenta.
	var area_vacia := Area3D.new()
	_raiz.add_child(area_vacia)
	_vis.redibujar()
	_check(_vis.segmentos_de("hitboxes") == 12, "D3 Area3D sin forma no agrega segmentos")
	_check(_vis.no_dibujables() >= 1, "D4 Area3D sin forma se cuenta como no dibujable")
	_limpia_raiz()
	_fin("D")


# ── Bloque E: navegacion REAL (NavigationAgent3D) ────────────────────────────

func _bloque_e() -> void:
	_vis = _nuevo_visualizer(true)
	_menu.visible = true
	_vis.configurar_manual("navigation", true)
	var npc := Node3D.new()
	_raiz.add_child(npc)
	var agente := NavigationAgent3D.new()
	npc.add_child(agente)
	agente.target_position = Vector3(5, 0, 5)
	_vis.redibujar()
	# Sin mapa de navegacion el path esta vacio: 0 segmentos de camino, pero el
	# marcador del objetivo (esfera de 3 aros x 12) SI se dibuja = 36.
	_check(_vis.segmentos_de("navigation") == 36,
		"E1 agente sin path: solo el marcador del objetivo (36)")
	_check(int(_vis.estadisticas().get("navigation", {}).get("nodos", 0)) == 1,
		"E2 enumera 1 NavigationAgent3D real")
	_check(agente.get_current_navigation_path().size() == 0,
		"E3 el path real esta vacio (no se inventa una ruta)")
	_limpia_raiz()
	_fin("E")


# ── Bloque F: estados IA REALES (get_state_machine) ──────────────────────────

func _bloque_f() -> void:
	_vis = _nuevo_visualizer(true)
	_menu.visible = true
	_vis.configurar_manual("ai_states", true)
	var npc := FakeNpc.new()
	npc.name = "npc_sonda"
	npc.estado = &"caminando"
	_raiz.add_child(npc)
	npc.global_position = Vector3(1, 0, 1)
	_vis.redibujar()
	_check(_vis.segmentos_de("ai_states") == 12, "F1 marcador de estado = 12 segmentos")
	var estados: Dictionary = _vis.estados_ia()
	_check(estados.get("npc_sonda", "") == "caminando",
		"F2 el estado se lee de la state machine REAL")
	_check(int(_vis.estadisticas().get("ai_states", {}).get("nodos", 0)) == 1,
		"F3 enumera 1 nodo con get_state_machine")
	# F4: un nodo SIN state machine no cuenta.
	var tonto := Node3D.new()
	_raiz.add_child(tonto)
	_vis.redibujar()
	_check(int(_vis.estadisticas().get("ai_states", {}).get("nodos", 0)) == 1,
		"F4 un Node3D sin get_state_machine no se enumera")
	_limpia_raiz()
	_fin("F")


# ── Bloque G: limites y contadores ──────────────────────────────────────────

func _bloque_g() -> void:
	var d = DEP.new()
	d.limpiar()
	d.caja_transformada(Transform3D(Basis.IDENTITY, Vector3(100, 0, 0)),
		AABB(Vector3.ZERO, Vector3.ONE))
	d.cerrar()
	_check(d.segmentos() == 12, "G1 caja_transformada dibuja 12 aristas en su traslacion")
	var arr: Array = d.mesh().surface_get_arrays(0)
	var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var max_x := -1e9
	for v in verts:
		max_x = max(max_x, v.x)
	_check(max_x >= 100.0, "G2 la caja respeta la transformacion (x >= 100)")

	_check(VIS.MAX_NODOS_POR_CAPA == 256, "G3 tope de nodos por capa declarado")
	_check(VIS.MAX_CHUNKS_RADIO == 5.0, "G4 limite de chunks (radio 5)")
	_check(VIS.MAX_NAVIGATION_RADIO == 50.0, "G5 limite de navegacion (radio 50)")
	_check(VIS.MAX_AI_STATES_RADIO == 50.0, "G6 limite de estados IA (radio 50)")
	_fin("G")


# ── Bloque H: cableado (no se re-introduce la API inexistente) ──────────────

func _bloque_h() -> void:
	_check(not _texto_vis.is_empty(), "H1 el visualizer es legible")
	_check(not _texto_dep.is_empty(), "H2 el depurador es legible")
	_check(not _menciona(_texto_vis, "DebugDraw."),
		"H3 el visualizer NO usa DebugDraw (API inexistente en 4.7.2)")
	_check(not _menciona(_texto_dep, "DebugDraw."),
		"H4 el depurador NO usa DebugDraw")
	_check(_menciona(_texto_vis, "ImmediateMesh") or _menciona(_texto_dep, "ImmediateMesh"),
		"H5 se usa ImmediateMesh (equivalente nativo)")
	_check(not _menciona(_texto_vis, "get_ai_state"),
		"H6 no se usa get_ai_state (no existe en el repo)")
	_check(not _menciona(_texto_vis, "get_hitbox"),
		"H7 no se usa get_hitbox (no existe en el repo)")
	_check(_menciona(_texto_vis, "get_state_machine"),
		"H8 se usa el accesor REAL get_state_machine")
	_check(_menciona(_texto_vis, "visualizacion_activa"),
		"H9 el gate delega en visualizacion_activa() del Debug Menu")
	_check(_menciona(_texto_vis, "get_current_navigation_path"),
		"H10 la navegacion usa get_current_navigation_path() real")
	_check(ClassDB.class_exists("ImmediateMesh"), "H11 ImmediateMesh existe en el motor")
	_check(not ClassDB.class_exists("DebugDraw"), "H12 DebugDraw NO existe en el motor")
	_check(_menciona(_texto_vis, "_registrar_servicio"),
		"H13 el visualizer publica el contrato (L274)")
	_check(_vis.servicio_registrado(),
		"H14 el contrato debug_visualizer queda registrado en el Service Locator")
	_fin("H")
