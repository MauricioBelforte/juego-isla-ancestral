## Condición de desbloqueo para prendas (M155).
class_name UnlockCondition
extends Resource

## Tipo de condición: "chapter", "flag", "item", "level", "none"
@export var tipo: String = "none"

## Valor requerido (capítulo, flag, item_id, nivel).
@export var valor: String = ""

## Descripción legible para UI.
@export var descripcion: String = ""

## Verifica si la condición se cumple para el jugador.
func is_unlocked(player_state: Dictionary) -> bool:
    match tipo:
        "none":
            return true
        "chapter":
            return player_state.get("capitulo_actual", 0) >= int(valor)
        "flag":
            return player_state.get("flags", {}).has(valor)
        "item":
            return player_state.get("inventario", {}).has(valor)
        "level":
            return player_state.get("nivel", 0) >= int(valor)
        _:
            return true
