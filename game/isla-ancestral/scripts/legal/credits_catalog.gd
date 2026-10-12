class_name CreditsCatalog
extends Resource

## M131 (ítem E.L58): catálogo tipado de créditos — alternativa Resource a
## `data/legal/creditos.json`, que sigue siendo la fuente canónica data-driven
## (`credits_manager.gd` lee el JSON; este Resource es el "Resource tipado
## además del JSON" que pide el ítem, y queda como alternativa no usada).
##
## Generado desde el JSON por `scripts/legal/generar_catalogo_tres_m131.gd`
## (SceneTree headless, ResourceSaver) y verificado en la misma corrida.

@export var secciones: Array[Dictionary] = []
@export var politicas: Dictionary = {}
@export var idiomas: Array[String] = []
@export var version: int = 2
