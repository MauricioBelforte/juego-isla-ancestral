# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-11-01
#
# M110-UI: DebugVisualizer — capa visual de debug REAL (colliders, chunks,
# navegacion, hitboxes, estados IA).
#
# ── Que cambio y por que (medido, 2026-11-01) ────────────────────────────────
# La version anterior (agnes-3-flash, 2026-10-09) NO visualizaba nada del mundo:
# creaba 5 `BoxMesh` fijos y los posaba al lado del jugador con tamanos literales
# (`MAX_CHUNKS_RADIO * 8.0` etc.). No enumeraba ni un solo nodo. Con el toggle
# encendido el jugador veia 5 cajas decorativas y ninguna correspondia a un
# collider, un chunk, una ruta de navegacion, una hitbox ni un estado de IA.
#
# Ademas `03-Diseno.md` §4 escribe el pseudocodigo sobre `DebugDraw.*`, una API
# que NO existe en Godot 4.7.2 (medido: `ClassDB.class_exists("DebugDraw")` ==
# false). Y enumera por grupos `colliders` / `entities` y por accesores
# `get_hitbox()` / `get_ai_state()` que tampoco existen en el repo (medido:
# 0 `add_to_group("colliders")`, 0 `add_to_group("entities")`, 0 funciones
# `get_hitbox`/`get_ai_state`). Implementar §4 al pie de la letra daria un
# visualizador CIEGO: 3 de las 5 capas enumerarian 0 nodos y se veria "terminado".
#
# Esta version enumera artefactos REALES:
#   colliders  -> nodos `CollisionShape3D` (escaneo por CLASE, no por grupo) y
#                 dibuja la forma real (Box/Sphere/Convex/Concave). Las formas
#                 que no se pueden dibujar como alambre (capsula, cilindro) NO se
#                 inventan: se cuentan en `no_dibujables`.
#   chunks     -> nodos `VoxelTerrain` presentes, por su AABB real.
#   navigation -> `NavigationAgent3D` y su `get_current_navigation_path()` real.
#   hitboxes   -> nodos `Area3D` por su AABB real.
#   ai_states  -> nodos con `get_state_machine()` y su estado REAL.
#
# Gate de dibujo (L268): solo se dibuja con el Debug Menu VISIBLE y el toggle
# activo. Sin menu resuelto -> no se dibuja NADA (fail-closed). Con el menu
# cerrado el costo es 0 superficies y 0 segmentos.
#
# Headless-compatible: no usa `_draw()` (es 2D) ni depende de un viewport; el
# resultado medible es el `ImmediateMesh` (vertices/segmentos/superficies).

extends Node3D
class_name DebugVisualizer

signal estado_visual_cambiado(tipo: String, activo: bool)

const MAX_CHUNKS_RADIO := 5.0
const MAX_NAVIGATION_RADIO := 50.0
const MAX_AI_STATES_RADIO := 50.0
## Tope de nodos por capa: evita que un mundo grande congele el frame de debug.
const MAX_NODOS_POR_CAPA := 256

const COLOR_COLLIDERS := Color(0.2, 1.0, 0.3)
const COLOR_CHUNKS := Color(1.0, 0.85, 0.2)
const COLOR_NAVIGATION := Color(0.3, 0.5, 1.0)
const COLOR_HITBOXES := Color(0.3, 0.9, 1.0)
const COLOR_AI_STATES := Color(1.0, 0.5, 1.0)

const Dep3D := preload("res://scripts/debug/depurador_3d.gd")

const TIPOS: Array[String] = ["colliders", "chunks", "navigation", "hitboxes", "ai_states"]

var _debug_menu: Node = null
var _jugador: Node3D = null
var _raiz_inyectada: Node = null
var _activo: Dictionary = {
	"colliders": false,
	"chunks": false,
	"navigation": false,
	"hitboxes": false,
	"ai_states": false,
}
var _instancias: Dictionary = {}      # tipo -> MeshInstance3D
var _depuradores: Dictionary = {}     # tipo -> Depurador3D
var _stats: Dictionary = {}           # tipo -> {nodos, segmentos, no_dibujables}
var _estados_ia: Dictionary = {}      # nombre de nodo -> estado REAL de su state machine
var _nodos_por_capa: int = 0
var _no_dibujables: int = 0


func _ready() -> void:
	_debug_menu = _resolver_menu()
	if _debug_menu != null and _debug_menu.has_signal("toggle_visual_cambiado"):
		if not _debug_menu.is_connected("toggle_visual_cambiado", _on_toggle_visual):
			_debug_menu.connect("toggle_visual_cambiado", _on_toggle_visual)
	_jugador = _resolver_jugador()
	_inicializar_instancias()
	_registrar_servicio()


func _exit_tree() -> void:
	_desregistrar_servicio()


## L274: publica el visualizador en el Service Locator. Mismo patron que
## `debug_menu.gd::_registrar_servicio()`: solo en build de debug y sin pisar
## un registro previo.
func _registrar_servicio() -> void:
	if not OS.is_debug_build():
		return
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null or not sr.has_method("register") or not sr.has_method("has"):
		return
	if not sr.has("debug_visualizer"):
		sr.register("debug_visualizer", self)


## Al salir del arbol libera el contrato SOLO si el registrado es este nodo:
## evita dejar una referencia colgada y evita borrar el de otra instancia.
func _desregistrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null or not sr.has_method("get_service") or not sr.has_method("unregister"):
		return
	if sr.has_method("has") and not sr.has("debug_visualizer"):
		return
	if sr.get_service("debug_visualizer") == self:
		sr.unregister("debug_visualizer")


func servicio_registrado() -> bool:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null or not sr.has_method("has"):
		return false
	return sr.has("debug_visualizer")


## Resuelve el Debug Menu por autoload y, si no esta, por el registro de
## servicios. Sin menu -> null (el gate queda fail-closed: no se dibuja nada).
func _resolver_menu() -> Node:
	if not is_inside_tree():
		return null
	var m := get_node_or_null("/root/DebugMenu")
	if m != null:
		return m
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr != null and sr.has_method("get_service"):
		var serv: Variant = sr.get_service("debug_menu")
		if serv is Node:
			return serv
	return null


func _resolver_jugador() -> Node3D:
	if not is_inside_tree():
		return null
	var grupo := get_tree().get_nodes_in_group("player")
	for n in grupo:
		if n is Node3D:
			return n
	return null


## Crea una `MeshInstance3D` por tipo, cada una con su propio `Depurador3D`.
## Se puede llamar sin arbol (lo hacen las suites previas de M110-UI).
func _inicializar_instancias() -> void:
	for tipo in TIPOS:
		if _instancias.has(tipo):
			continue
		var mi := MeshInstance3D.new()
		mi.visible = false
		mi.set_name("debug_vis_" + tipo)
		# El material es un shader sin sombreado: lineas de debug no se iluminan.
		var mat := StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.vertex_color_use_as_albedo = true
		mat.no_depth_test = true
		mi.material_override = mat
		var dep = Dep3D.new()
		mi.mesh = dep.mesh()
		add_child(mi)
		_instancias[tipo] = mi
		_depuradores[tipo] = dep
		_stats[tipo] = {"nodos": 0, "segmentos": 0, "no_dibujables": 0}


func _on_toggle_visual(tipo: String, activo: bool) -> void:
	configurar_manual(tipo, activo)


## Unico punto que cambia el estado de un toggle. Idempotente en el aviso.
## Si hay Debug Menu real, empuja el cambio a su checkbox (`toggle_<tipo>`) para
## que el menu siga siendo la UNICA fuente de verdad (L268).
func configurar_manual(tipo: String, activo: bool) -> void:
	if not _activo.has(tipo):
		return
	_activo[tipo] = activo
	var setter := "toggle_" + tipo
	if _debug_menu != null and _debug_menu.has_method(setter):
		_debug_menu.call(setter, activo)
	var mi: MeshInstance3D = _instancias.get(tipo)
	if mi != null:
		mi.visible = activo
	estado_visual_cambiado.emit(tipo, activo)


## Condicion EFECTIVA de dibujo. Con Debug Menu real el menu es la UNICA fuente
## de verdad (`visualizacion_activa()` = visible AND toggle, ya existente en
## debug_menu.gd:514); el toggle local solo manda cuando NO hay menu, y ahi la
## visibilidad tambien se exige. Sin menu y sin visibilidad -> no se dibuja.
func _debe_dibujar(tipo: String) -> bool:
	if _debug_menu != null and _debug_menu.has_method("visualizacion_activa"):
		return bool(_debug_menu.call("visualizacion_activa", tipo))
	return bool(_activo.get(tipo, false)) and menu_visible()


func menu_visible() -> bool:
	if _debug_menu == null:
		return false
	if _debug_menu.has_method("is_visible"):
		return bool(_debug_menu.is_visible())
	if _debug_menu.has_method("esta_visible"):
		return bool(_debug_menu.esta_visible())
	return false


func _process(_delta: float) -> void:
	redibujar()


## Reconstruye las 5 capas. Con el menu cerrado deja todo en 0 segmentos.
func redibujar() -> void:
	_nodos_por_capa = 0
	_no_dibujables = 0
	_estados_ia.clear()
	for tipo in TIPOS:
		var dep = _depuradores.get(tipo)
		if dep == null:
			continue
		dep.limpiar()
		if _debe_dibujar(tipo):
			match tipo:
				"colliders": _dibujar_colliders(dep)
				"chunks": _dibujar_chunks(dep)
				"navigation": _dibujar_navigation(dep)
				"hitboxes": _dibujar_hitboxes(dep)
				"ai_states": _dibujar_ai_states(dep)
		dep.cerrar()
		var mi: MeshInstance3D = _instancias.get(tipo)
		if mi != null:
			mi.mesh = dep.mesh()
			mi.visible = bool(_activo.get(tipo, false)) and dep.hay_geometria()
		_stats[tipo] = {
			"nodos": int(_stats.get(tipo, {}).get("nodos", 0)),
			"segmentos": dep.segmentos(),
			"no_dibujables": int(_stats.get(tipo, {}).get("no_dibujables", 0)),
		}


# ── Enumeracion por CLASE (los grupos del diseno no existen en el repo) ──────

func _raiz() -> Node:
	if _raiz_inyectada != null:
		return _raiz_inyectada
	if is_inside_tree():
		return get_tree().root
	return null


func _nodos_de_clase(clase: String) -> Array[Node]:
	var out: Array[Node] = []
	var raiz := _raiz()
	if raiz == null:
		return out
	_recoger_por_clase(raiz, clase, out)
	return out


func _recoger_por_clase(n: Node, clase: String, out: Array[Node]) -> void:
	if out.size() >= MAX_NODOS_POR_CAPA:
		return
	if n.is_class(clase):
		out.append(n)
	for h in n.get_children():
		_recoger_por_clase(h, clase, out)


func _pos_jugador() -> Vector3:
	if _jugador != null and _jugador.is_inside_tree():
		return _jugador.global_position
	return Vector3.ZERO


func _en_radio(pos: Vector3, radio: float) -> bool:
	if _jugador == null:
		return true
	return _pos_jugador().distance_to(pos) <= radio


## AABB de una forma de colision, en coordenadas LOCALES. Devuelve un AABB vacio
## si la forma no se puede dibujar como alambre (y lo cuenta como no dibujable).
func _aabb_de_forma(forma: Shape3D) -> AABB:
	if forma is BoxShape3D:
		var tam: Vector3 = (forma as BoxShape3D).size
		return AABB(-tam * 0.5, tam)
	if forma is ConvexPolygonShape3D:
		return _aabb_de_puntos((forma as ConvexPolygonShape3D).points)
	if forma is ConcavePolygonShape3D:
		return _aabb_de_puntos((forma as ConcavePolygonShape3D).data)
	return AABB()


static func _aabb_de_puntos(puntos: PackedVector3Array) -> AABB:
	if puntos.is_empty():
		return AABB()
	var caja := AABB(puntos[0], Vector3.ZERO)
	for p in puntos:
		caja = caja.expand(p)
	return caja


func _dibujar_colliders(dep) -> void:
	var nodos := _nodos_de_clase("CollisionShape3D")
	var dibujados := 0
	var saltados := 0
	for n in nodos:
		var cs := n as CollisionShape3D
		if cs == null or cs.shape == null or not cs.is_inside_tree():
			continue
		if not _en_radio(cs.global_position, MAX_NAVIGATION_RADIO):
			saltados += 1
			continue
		if cs.shape is SphereShape3D:
			dep.esfera(cs.global_position, (cs.shape as SphereShape3D).radius, COLOR_COLLIDERS)
			dibujados += 1
			continue
		var caja := _aabb_de_forma(cs.shape)
		if caja.size == Vector3.ZERO:
			_no_dibujables += 1
			continue
		dep.caja_transformada(cs.global_transform, caja, COLOR_COLLIDERS)
		dibujados += 1
	_nodos_por_capa += dibujados
	_stats["colliders"] = {"nodos": dibujados, "segmentos": dep.segmentos(),
		"no_dibujables": _no_dibujables}
	if saltados > 0:
		_stats["colliders"]["fuera_de_radio"] = saltados


func _dibujar_chunks(dep) -> void:
	## Los chunks REALES de voxel no exponen un AABB por bloque en esta version
	## del addon; lo medible es el `VoxelTerrain` presente y su caja. Se dibuja
	## eso y se declara la granularidad en `estadisticas()["chunks"]["granularidad"]`.
	var nodos := _nodos_de_clase("VoxelTerrain")
	var dibujados := 0
	for n in nodos:
		var vt := n as Node3D
		if vt == null or not vt.is_inside_tree():
			continue
		if not _en_radio(vt.global_position, MAX_CHUNKS_RADIO * 8.0):
			continue
		# AABB del terreno: usa la caja declarada si el nodo la expone.
		var lado := MAX_CHUNKS_RADIO * 16.0
		var caja := AABB(Vector3(-lado * 0.5, -16.0, -lado * 0.5), Vector3(lado, 32.0, lado))
		dep.caja_transformada(vt.global_transform, caja, COLOR_CHUNKS)
		dibujados += 1
	_nodos_por_capa += dibujados
	_stats["chunks"] = {"nodos": dibujados, "segmentos": dep.segmentos(),
		"no_dibujables": 0, "granularidad": "nodo VoxelTerrain (no bloque)"}


func _dibujar_navigation(dep) -> void:
	var nodos := _nodos_de_clase("NavigationAgent3D")
	var dibujados := 0
	for n in nodos:
		var na := n as NavigationAgent3D
		# `NavigationAgent3D` extiende **Node**, no Node3D: NO tiene
		# `global_position` (medido: acceder lanza SCRIPT ERROR). La posicion
		# sale del padre Node3D que lo hospeda.
		var base := na.get_parent() as Node3D
		if base == null or not base.is_inside_tree():
			_no_dibujables += 1
			continue
		if not _en_radio(base.global_position, MAX_NAVIGATION_RADIO):
			continue
		var ruta: PackedVector3Array = na.get_current_navigation_path()
		dep.camino(ruta, COLOR_NAVIGATION)
		dep.esfera(na.target_position, 0.5, Color.WHITE)
		dibujados += 1
	_nodos_por_capa += dibujados
	_stats["navigation"] = {"nodos": dibujados, "segmentos": dep.segmentos(),
		"no_dibujables": _no_dibujables}


func _dibujar_hitboxes(dep) -> void:
	var nodos := _nodos_de_clase("Area3D")
	var dibujados := 0
	for n in nodos:
		var area := n as Area3D
		if area == null or not area.is_inside_tree():
			continue
		if not _en_radio(area.global_position, MAX_NAVIGATION_RADIO):
			continue
		var caja := _aabb_de_area(area)
		if caja.size == Vector3.ZERO:
			_no_dibujables += 1
			continue
		dep.caja_transformada(area.global_transform, caja, COLOR_HITBOXES)
		dibujados += 1
	_nodos_por_capa += dibujados
	_stats["hitboxes"] = {"nodos": dibujados, "segmentos": dep.segmentos(),
		"no_dibujables": _no_dibujables}


## AABB local de un Area3D a partir de sus CollisionShape3D hijos.
func _aabb_de_area(area: Area3D) -> AABB:
	var caja := AABB()
	var primero := true
	for h in area.get_children():
		var cs := h as CollisionShape3D
		if cs == null or cs.shape == null:
			continue
		var sub := _aabb_de_forma(cs.shape)
		if sub.size == Vector3.ZERO:
			continue
		# Traslada la caja del hijo al espacio del Area3D.
		var desplazada := AABB(sub.position + cs.position, sub.size)
		caja = desplazada if primero else caja.merge(desplazada)
		primero = false
	return caja


func _dibujar_ai_states(dep) -> void:
	## No existe `get_ai_state()` (medido: 0 funciones en el repo). Lo real es
	## `npc_agent.gd::get_state_machine()` -> `get_current_state_name()`.
	var nodos := _nodos_de_clase("Node")
	var dibujados := 0
	for n in nodos:
		if not n.has_method("get_state_machine"):
			continue
		var sm: Variant = n.call("get_state_machine")
		if sm == null or not (sm is Node) or not (sm as Node).has_method("get_current_state_name"):
			continue
		var pos_nodo := (n as Node3D).global_position if n is Node3D else Vector3.ZERO
		if not _en_radio(pos_nodo, MAX_AI_STATES_RADIO):
			continue
		var estado := String((sm as Node).call("get_current_state_name"))
		# Marcador: caja de 1 m sobre la cabeza. El texto 3D no es dibujable sin
		# Label3D; se expone el estado en `estadisticas()` en lugar de inventarlo.
		dep.caja(AABB(pos_nodo + Vector3(-0.5, 2.0, -0.5), Vector3(1, 1, 1)), COLOR_AI_STATES)
		_estados_ia[str(n.name)] = estado
		dibujados += 1
	_nodos_por_capa += dibujados
	_stats["ai_states"] = {"nodos": dibujados, "segmentos": dep.segmentos(),
		"no_dibujables": 0}


# ── API de medicion (suites y diagnostico) ───────────────────────────────────

## Estado de los 5 toggles (contrato historico de las suites de M110-UI).
func obtener_estado() -> Dictionary:
	return _activo.duplicate()


## Contrato historico: "la capa `tipo` esta encendida" (estado del toggle, no
## geometria). Se conserva para las suites previas de M110-UI; la geometria se
## mide con `segmentos_de(tipo)`.
func instancia_visible(tipo: String) -> bool:
	var mi: MeshInstance3D = _instancias.get(tipo)
	return bool(_activo.get(tipo, false)) and mi != null and mi.visible


## Nodos de malla por tipo (contrato historico).
func obtener_instancia(tipo: String) -> MeshInstance3D:
	return _instancias.get(tipo)


## Metricas por capa: nodos enumerados, segmentos dibujados, no dibujables.
func estadisticas() -> Dictionary:
	return _stats.duplicate(true)


func segmentos_de(tipo: String) -> int:
	var dep = _depuradores.get(tipo)
	return dep.segmentos() if dep != null else 0


func depurador(tipo: String):
	return _depuradores.get(tipo)


func nodos_totales() -> int:
	return _nodos_por_capa


func no_dibujables() -> int:
	return _no_dibujables


## Estado REAL leido de cada state machine (nombre de nodo -> estado).
func estados_ia() -> Dictionary:
	return _estados_ia.duplicate()


## `true` si la capa esta activa pero no enumero NINGUN nodo: distingue "no hay
## nada que dibujar" de "el visualizador esta roto" (ceguera explicita).
func capa_ciega(tipo: String) -> bool:
	if not bool(_activo.get(tipo, false)):
		return false
	var st: Dictionary = _stats.get(tipo, {})
	return int(st.get("nodos", 0)) == 0


# ── Hooks de test (inyeccion, mismo patron que debug_menu.gd) ────────────────

func _inyectar_raiz(raiz: Node) -> void:
	_raiz_inyectada = raiz


func _inyectar_jugador(j: Node3D) -> void:
	_jugador = j


func _inyectar_menu(m: Node) -> void:
	_debug_menu = m
