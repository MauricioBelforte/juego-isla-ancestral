# Modelo: Atria-Dawn-Preview
# Plataforma: Kilo Code
# Fecha: 2026-09-18
#
# M164 (iter. 1 — parte data-driven): EnemyData — definicion de un enemigo
# de la Isla de Combate. Los 11 enemigos del diseno (03-Diseno.md §D) se
# instancian desde data/combat/enemy_catalog.tres. Sin mesh/animaciones
# (encaje C del agente — dueño M45/M64 para la parte visual).
class_name EnemyData
extends Resource

## Identificador estable (contrato con CombatIslandSystem / M164).
@export var id: String = ""
## Clave de localizacion (M87 — sin cadenas crudas en UI).
@export var display_name_key: String = ""
## Categoria de dificultad (define zona + recompensa en gemas).
enum Categoria { BASICO, MEDIO, FUERTE, JEFE }
@export var categoria: Categoria = Categoria.BASICO
## Vida maxima (combate cozy: el jugador no muere, pero el enemigo si).
@export var hp_max: int = 1
## Dano por ataque del enemigo.
@export var attack: int = 1
## Velocidad de movimiento (m/s) — la consume enemy_ai (M64, pendiente).
@export var speed: float = 1.0
## Gemas otorgadas al derrotar (moneda de acceso a zonas, ver GemCurrency).
@export var gem_reward: int = 0
## Tabla de botin: [{item_id: String, chance: float, min: int, max: int}].
@export var loot_table: Array[Dictionary] = []
## Tipo de IA (la consume M64): "melee", "ranged", "stationary".
@export var ai_type: String = "melee"
## Peso relativo en el spawner (mayor = mas frecuente).
@export var spawn_weight: float = 1.0

## Valida que la definicion sea utilizable (esquema data-driven, patron
## FaunaSchema de M36).
func es_valido() -> bool:
	return id != "" and display_name_key != "" and hp_max > 0 and attack > 0 \
		and speed > 0.0 and gem_reward >= 0

## Gemas por categoria segun la tabla del diseño (B.37-B.40):
## basico 1-2, medio 2-3, fuerte 3-5, jefe 5-15.
static func rango_gemas(categoria: Categoria) -> Vector2i:
	match categoria:
		Categoria.BASICO: return Vector2i(1, 2)
		Categoria.MEDIO: return Vector2i(2, 3)
		Categoria.FUERTE: return Vector2i(3, 5)
		Categoria.JEFE: return Vector2i(5, 15)
	return Vector2i(0, 0)
