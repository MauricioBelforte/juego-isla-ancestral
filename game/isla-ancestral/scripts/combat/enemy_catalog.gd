# Modelo: Atria-Dawn-Preview
# Plataforma: Kilo Code
# Fecha: 2026-09-18
#
# M164 (iter. 1): EnemyCatalog — catalogo data-driven de los 11 enemigos
# + 2 jefes del diseño (checklist §D). Resource con _init() (no .tres):
# patron de FaunaCatalog/M13 (data por codigo, .tres diferido a M159).
#
# Tabla canonica (D.1-D.11): HP, ataque, velocidad, gemas, categoria.
class_name EnemyCatalog
extends Resource

## id -> EnemyData
var _por_id: Dictionary = {}

func _init() -> void:
	_construir()

func _construir() -> void:
	# Costa (zona basica)
	_e("slime_verde", "M164.SLIME_VERDE", EnemyData.Categoria.BASICO, 3, 1, 0.8, 1, "melee", 1.0)
	_e("murcielago_noche", "M164.MURCIELAGO", EnemyData.Categoria.BASICO, 2, 1, 2.0, 1, "melee", 0.8)
	_e("cangrejo_roca", "M164.CANGREJO_ROCA", EnemyData.Categoria.BASICO, 4, 2, 1.2, 2, "melee", 1.0)
	# Bosque
	_e("lobo_sombra", "M164.LOBO_SOMBRA", EnemyData.Categoria.MEDIO, 6, 3, 1.8, 2, "melee", 1.0)
	_e("arbol_maldito", "M164.ARBOL_MALDITO", EnemyData.Categoria.MEDIO, 8, 2, 0.5, 3, "stationary", 0.6)
	_e("espiritu_bosque", "M164.ESPIRITU_BOSQUE", EnemyData.Categoria.MEDIO, 5, 2, 1.4, 2, "ranged", 0.7)
	# Montana
	_e("golem_piedra", "M164.GOLEM_PIEDRA", EnemyData.Categoria.FUERTE, 12, 4, 0.7, 3, "melee", 1.0)
	_e("dragon_montana", "M164.DRAGON_MONTANA", EnemyData.Categoria.FUERTE, 10, 3, 1.6, 4, "ranged", 0.5)
	_e("troll_montana", "M164.TROLL_MONTANA", EnemyData.Categoria.FUERTE, 15, 5, 0.9, 5, "melee", 0.9)
	# Jefes (D.10-D.11)
	_b("guardian_montana", "M164.GUARDIAN_MONTANA", 30, 4, 1.0, 8, 3, [0.66, 0.33], ["golpe_cargado", "invocar_escombros"])
	_b("senor_del_templo", "M164.SENOR_DEL_TEMPLO", 50, 6, 1.1, 15, 4, [0.75, 0.5, 0.25], ["rayo_cristal", "campo_repulsivo", "invocar_guardianes"])

func _e(p_id: String, p_key: String, p_cat: int, p_hp: int, p_atk: int,
		p_vel: float, p_gemas: int, p_ai: String, p_peso: float) -> void:
	var d := EnemyData.new()
	d.id = p_id
	d.display_name_key = p_key
	d.categoria = p_cat
	d.hp_max = p_hp
	d.attack = p_atk
	d.speed = p_vel
	d.gem_reward = p_gemas
	d.ai_type = p_ai
	d.spawn_weight = p_peso
	_por_id[p_id] = d

func _b(p_id: String, p_key: String, p_hp: int, p_atk: int, p_vel: float,
		p_gemas: int, p_fases: int, p_umbral: Array, p_hab: Array) -> void:
	var b := BossData.new()
	b.id = p_id
	b.display_name_key = p_key
	b.hp_max = p_hp
	b.attack = p_atk
	b.speed = p_vel
	b.gem_reward = p_gemas
	b.phases = p_fases
	b.phase_thresholds.assign(p_umbral)
	b.special_abilities.assign(p_hab)
	_por_id[p_id] = b

func obtener(p_id: String) -> EnemyData:
	return _por_id.get(p_id, null)

func obtener_todas() -> Array:
	return _por_id.values()

func cantidad() -> int:
	return _por_id.size()

## Todos los enemigos validos (guardian anti-falso-verde en tests).
func todas_validas() -> bool:
	for k in _por_id:
		var d: Variant = _por_id[k]
		var ok: bool = d.es_valido()
		if d is BossData:
			ok = ok and (d as BossData).es_valido_jefe()
		if not ok:
			return false
	return true
