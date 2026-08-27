extends Node
class_name EventBus_
## Bus de eventos global tipado para Isla Ancestral
##
## Patrón: Signal Up, Call Down
## - Los scripts de dominio EMITEN eventos aquí
## - Los consumidores SE SUSCRIBEN aquí
## - EventBus NO importa ningún dominio (solo define tipos)
##
## Uso:
##   EventBus.world.block_placed.emit(pos, block_type)
##   EventBus.world.block_placed.connect(_on_block_placed)

## ── Dominio: WORLD ──────────────────────────────────────
var world := WorldEvents.new()
## ── Dominio: ECONOMY ────────────────────────────────────
var economy := EconomyEvents.new()
## ── Dominio: INVENTORY ───────────────────────────────────
var inventory := InventoryEvents.new()
## ── Dominio: QUEST ───────────────────────────────────────
var quest := QuestEvents.new()
## ── Dominio: NPC ─────────────────────────────────────────
var npc := NPCEvents.new()
## ── Dominio: CALENDAR ────────────────────────────────────
var calendar := CalendarEvents.new()
## ── Dominio: TRAVEL ──────────────────────────────────────
var travel := TravelEvents.new()
## ── Dominio: UI ──────────────────────────────────────────
var ui := UIEvents.new()
## ── Dominio: PLAYER ──────────────────────────────────────
var player := PlayerEvents.new()


## ── Clases de eventos por dominio ───────────────────────

class WorldEvents:
	## Se emite cuando un bloque es colocado en el mundo
	signal block_placed(pos: Vector3i, block_type: int)
	## Se emite cuando un bloque es removido del mundo
	signal block_removed(pos: Vector3i, block_type: int)
	## Se emite cuando se modifica un chunk
	signal chunk_modified(chunk_pos: Vector3i)
	## Se emite cuando el jugador entra a un nuevo bioma
	signal biome_changed(old_biome: String, new_biome: String)

class EconomyEvents:
	## Se emite cuando cambia la moneda del jugador (gemas)
	signal currency_changed(old_amount: int, new_amount: int)
	## Se emite cuando se realiza una compra
	signal purchase_done(item_id: String, cost: int)
	## Se emite cuando se paga una deuda
	signal debt_paid(amount: int, creditor: String)

class InventoryEvents:
	## Se emite cuando se agrega un item al inventario
	signal item_added(item_id: String, quantity: int)
	## Se emite cuando se remueve un item del inventario
	signal item_removed(item_id: String, quantity: int)
	## Se emite cuando se selecciona un slot del hotbar
	signal hotbar_selected(slot_index: int)

class QuestEvents:
	## Se emite cuando inicia una misión
	signal quest_started(quest_id: String)
	## Se emite cuando se actualiza el progreso de una misión
	signal quest_updated(quest_id: String, objective: String, progress: int)
	## Se emite cuando se completa una misión
	signal quest_completed(quest_id: String)
	## Se emite cuando se cumple un prerequisito (sello)
	signal prereq_met(seal_id: String)

class NPCEvents:
	## Se emite cuando un NPC se muda a una isla
	signal npc_moved_in(npc_id: String, island: String)
	## Se emite cuando sube el nivel de amistad
	signal friendship_level_up(npc_id: String, new_level: int)
	## Se emite cuando se le da un regalo a un NPC
	signal gift_given(npc_id: String, item_id: String, liked: bool)

class CalendarEvents:
	## Se emite cuando empieza un nuevo día
	signal day_started(day: int, season: String)
	## Se emite cuando cambia la estación
	signal season_changed(old_season: String, new_season: String)
	## Se emite cuando llega un barco/vessel
	signal vessel_arrived(island: String, cargo: Array)

class TravelEvents:
	## Se emite cuando inicia un viaje entre islas
	signal travel_started(from_island: String, to_island: String)
	## Se emite cuando se carga una isla
	signal island_loaded(island: String)

class UIEvents:
	## UI solicita mostrar el HUD
	signal hud_request(visible: bool)
	## UI solicita abrir un diálogo
	signal dialog_requested(npc_id: String, dialog_data: Dictionary)

class PlayerEvents:
	## Se emite cuando el jugador muere (cozy: respawn, no game over)
	signal player_died(spawn_point: Vector3)
	## Se emite cuando el jugador sube de nivel
	signal level_up(new_level: int)
	## Se emite cuando el jugador recibe daño
	signal damage_taken(amount: int, source: String)
