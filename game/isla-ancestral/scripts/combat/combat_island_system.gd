# Modelo: Atria-Dawn-Preview
# Plataforma: Kilo Code
# Fecha: 2026-09-18
#
# M164 (iter. 1 — parte data-driven): CombatIslandSystem — sistema central
# de la Isla de Combate. Autoload "combat_island". Gestiona:
#  - Desbloqueo permanente de zonas por gemas (C.13) + persistencia M59.
#  - Conteo de enemigos/jefes derrotados (H.1-H.3) para hitos M71/M72.
#  - Recompensas obtenidas (H.4) — todas cosméticas (F.7).
#  - Acceso: can_access_zone / unlock_zone (contrato 04-Codigo.md §2).
#
# NO gestiona (fuera de alcance iter. 1, encaje C/dependencias):
#  - IA, spawner y meshes de enemigos (M64/M45 — items D marcados [?]).
#  - Combate real y vida del jugador (M11/M64 — seccion E [?]).
#  - UI visual (M53 — combat_island_ui.gd pendiente).
class_name CombatIslandSystem
extends Node

const VERSION_SAVE := 1
const SECCION_SAVE := "isla_combate_m164"

## Zonas del catalogo (data/combat/zone_catalog.tres).
var _zonas: Dictionary = {}          # id -> IslandZone
## Zonas desbloqueadas (permanente, C.13).
var _desbloqueadas: Dictionary = {}   # id -> bool
## Conteo de derrotas por enemy_id (H.1-H.3, M71/M72).
var _derrotas: Dictionary = {}        # enemy_id -> int
## Recompensas obtenidas por id (H.4).
var _recompensas: Dictionary = {}     # reward_id -> bool

signal zona_desbloqueada(zone_id: String)
signal enemigo_derrotado(enemy_id: String, total: int)
static var instancia: CombatIslandSystem = null

func _ready() -> void:
	instancia = self
	_cargar_catalogo()
	_registrar_provider()

## ── Catalogo data-driven ───────────────────────────────────────────

## Carga el catalogo de zonas. Publico para que los tests headless puedan
## instanciar el sistema fuera del arbol de escena (patron FaunaManager).
func cargar_catalogo_para_test() -> void:
	_cargar_catalogo()

func _cargar_catalogo() -> void:
	var path := "res://data/combat/zone_catalog.tres"
	if ResourceLoader.exists(path):
		var cat = load(path)
		if cat != null and cat.has_method("obtener_todas"):
			for z in cat.obtener_todas():
				if z is IslandZone and z.es_valido():
					_zonas[z.id] = z
	if _zonas.is_empty():
		_zonas = _zonas_por_defecto()
	# La zona inicial (costa, gem_cost=0) siempre esta desbloqueada.
	for zid in _zonas:
		if _zonas[zid].gem_cost <= 0:
			_desbloqueadas[zid] = true

## Zonas canonicas del diseño (C.1-C.12) en ausencia del .tres.
func _zonas_por_defecto() -> Dictionary:
	var out := {}
	_nueva_zona(out, "costa", "M164.ZONA_COSTA", 0,
		["slime_verde", "murcielago_noche", "cangrejo_roca"], [], "tienda_basica")
	_nueva_zona(out, "bosque", "M164.ZONA_BOSQUE", 10,
		["lobo_sombra", "arbol_maldito", "espiritu_bosque"], ["recurso_raro_bosque"], "")
	_nueva_zona(out, "montana", "M164.ZONA_MONTANA", 25,
		["golem_piedra", "dragon_montana", "troll_montana"], ["recurso_raro_montana"], "")
	_nueva_zona(out, "templo", "M164.ZONA_TEMPLO", 50,
		["guardian_montana", "senor_del_templo"], ["recurso_raro_templo"], "")
	return out

static func _nueva_zona(dic: Dictionary, p_id: String, p_key: String,
		p_cost: int, p_enemigos: Array, p_recursos: Array, p_tienda: String) -> void:
	var z := IslandZone.new()
	z.id = p_id
	z.display_name_key = p_key
	z.gem_cost = p_cost
	var enem: Array[String] = []
	for e in p_enemigos:
		enem.append(String(e))
	z.enemy_ids = enem
	var rec: Array[String] = []
	for r in p_recursos:
		rec.append(String(r))
	z.rare_resources = rec
	z.shop_id = p_tienda
	dic[p_id] = z

## ── Contrato publico (04-Codigo.md §2) ─────────────────────────────

func can_access_zone(zone_id: String) -> bool:
	return _desbloqueadas.get(zone_id, false)

func unlock_zone(zone_id: String) -> bool:
	if not _zonas.has(zone_id):
		return false
	if _desbloqueadas.get(zone_id, false):
		return true
	var zona: IslandZone = _zonas[zone_id]
	if zona.gem_cost <= 0:
		_desbloqueadas[zone_id] = true
		zona_desbloqueada.emit(zone_id)
		return true
	var gc = Engine.get_main_loop().root.get_node_or_null("gem_currency")
	if gc == null:
		return false
	if not gc.spend_gems(zona.gem_cost, "desbloqueo_zona_" + zone_id):
		return false
	_desbloqueadas[zone_id] = true
	zona_desbloqueada.emit(zone_id)
	return true

func zona_obtenida(zone_id: String) -> IslandZone:
	return _zonas.get(zone_id, null)

func zonas_ordenadas() -> Array:
	var arr := _zonas.values()
	arr.sort_custom(IslandZone.orden_por_coste)
	return arr

## ── Derrotas y recompensas (M71/M72 consumen) ──────────────────────

func registrar_derrota(enemy_id: String) -> void:
	var total: int = int(_derrotas.get(enemy_id, 0)) + 1
	_derrotas[enemy_id] = total
	enemigo_derrotado.emit(enemy_id, total)
	_evaluar_recompensas()

func total_derrotas(enemy_id: String) -> int:
	return int(_derrotas.get(enemy_id, 0))

func total_enemigos_derrotados() -> int:
	var suma: int = 0
	for k in _derrotas:
		suma += int(_derrotas[k])
	return suma

func jefe_derrotado(boss_id: String) -> bool:
	return total_derrotas(boss_id) > 0

## Evalua condiciones de recompensas (F.1-F.6). Las skins de jefes se
## otorgan al registrar la derrota; el titulo y el estandarte, por hitos.
func _evaluar_recompensas() -> void:
	if not tiene_recompensa("titulo_cazador_de_cristal") \
			and total_enemigos_derrotados() >= 100:
		otorgar_recompensa("titulo_cazador_de_cristal")

func otorgar_recompensa(reward_id: String) -> void:
	if _recompensas.has(reward_id):
		return
	_recompensas[reward_id] = true

func tiene_recompensa(reward_id: String) -> bool:
	return _recompensas.get(reward_id, false)

func recompensas_obtenidas() -> Array:
	var out: Array = []
	for k in _recompensas:
		if _recompensas[k]:
			out.append(k)
	return out

## Porcentaje de isla completada (M71 hito "completar isla 100%").
func porcentaje_completado() -> float:
	var total_zonas: int = _zonas.size()
	if total_zonas == 0:
		return 0.0
	var desbloqueadas: int = 0
	for k in _zonas:
		if _desbloqueadas.get(k, false):
			desbloqueadas += 1
	return float(desbloqueadas) / float(total_zonas)

## ── Persistencia M59 (ISaveProvider duck-typed) ────────────────────

func _registrar_provider() -> void:
	var sm = Engine.get_main_loop().root.get_node_or_null("SaveManager")
	if sm != null and sm.has_method("register_provider"):
		var prov := CombatIslandSaveProvider.new(self)
		sm.register_provider(prov)

func get_section_name() -> String:
	return SECCION_SAVE

func get_save_data() -> Dictionary:
	return {
		"version": VERSION_SAVE,
		"desbloqueadas": _desbloqueadas.duplicate(true),
		"derrotas": _derrotas.duplicate(true),
		"recompensas": _recompensas.duplicate(true),
	}

func restore_save_data(data: Dictionary) -> void:
	if data.is_empty():
		return
	if int(data.get("version", 0)) < VERSION_SAVE:
		return
	var d = data.get("desbloqueadas", {})
	if d is Dictionary:
		for k in d:
			_desbloqueadas[k] = bool(d[k])
	var dr = data.get("derrotas", {})
	if dr is Dictionary:
		for k in dr:
			_derrotas[k] = int(dr[k])
	var r = data.get("recompensas", {})
	if r is Dictionary:
		for k in r:
			_recompensas[k] = bool(r[k])
