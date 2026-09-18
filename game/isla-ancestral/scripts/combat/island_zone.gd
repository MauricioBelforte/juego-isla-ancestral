# Modelo: Atria-Dawn-Preview
# Plataforma: Kilo Code
# Fecha: 2026-09-18
#
# M164 (iter. 1 — parte data-driven): IslandZone — una de las 4 zonas de la
# Isla de Combate (Costa, Bosque, Montana, Templo). El acceso cuesta gemas
# (moneda de acceso); el desbloqueo es permanente y se persiste en M59.
class_name IslandZone
extends Resource

@export var id: String = ""
@export var display_name_key: String = ""
## Coste en gemas para desbloquear (Costa = 0, acceso gratis).
@export var gem_cost: int = 0
## Enemigos que spawnean aqui (ids de EnemyData; M64 arma el spawner).
@export var enemy_ids: Array[String] = []
## Recursos raros de la zona (ids de ItemData M159; M46/M15 los generan).
@export var rare_resources: Array[String] = []
## Tienda de la zona (id de M39; vacio = sin tienda).
@export var shop_id: String = ""
## Musica ambiente (dueño M43/M65).
@export var music_track: AudioStream = null

func es_valido() -> bool:
	return id != "" and display_name_key != "" and gem_cost >= 0 \
		and not enemy_ids.is_empty()

## Orden de las zonas por coste (el jugador avanza Costa -> Templo).
static func orden_por_coste(a: IslandZone, b: IslandZone) -> bool:
	return a.gem_cost < b.gem_cost
