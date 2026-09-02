## Catálogo maestro de prendas de vestimenta (M155).
## Se carga como .tres y contiene un Dictionary de items.
class_name EquipmentCatalog
extends Resource

## Diccionario de items: { item_id: { name, slot, terrain_bonuses, comfort_penalty, description, rarity } }
@export var items: Dictionary = {}
