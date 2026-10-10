class_name CharacterSelector
extends RefCounted

## M11 - Seleccion de personaje (MODELO PURO).
##
## Implementa el diseno de `03-Diseno.md` seccion 3 y los items I de
## `05-Checklist.md` (8 items ya marcados [x] como DISENO):
##   - 6 personajes base, todos desbloqueados desde el inicio (cozy = sin locks).
##   - Seleccion PURAMENTE visual: todos comparten las mismas mecanicas
##     (no hay ventajas/desventajas por eleccion).
##   - Persistencia del personaje elegido (id) para M59/GameState.
##
## Alcance: modelo puro + contrato. La PANTALLA de seleccion (preview 360) es
## UI (M53) y NO se implementa aqui; este modelo es su fuente de datos y de
## persistencia. No esta cableado a `player.gd` (ver 04-Codigo.md seccion 9).

const ID_POR_DEFECTO := "char_01"

## Catalogo de personajes base (03-Diseno seccion 3.1). `bioma` es el bioma de
## origen (cosmetico). Sin campos de stats: la eleccion es solo visual.
const PERSONAJES: Array = [
	{"id": "char_01", "nombre": "Sol", "genero": "F", "rasgo": "Piel morena, cabello negro ondulado", "bioma": "playa"},
	{"id": "char_02", "nombre": "Kai", "genero": "M", "rasgo": "Piel triguena, cabello corto", "bioma": "bosque"},
	{"id": "char_03", "nombre": "Luna", "genero": "F", "rasgo": "Piel clara, pecas, cabello rojizo", "bioma": "montana"},
	{"id": "char_04", "nombre": "Tide", "genero": "M", "rasgo": "Piel oscura, cabello trenzas", "bioma": "ciudad"},
	{"id": "char_05", "nombre": "Sage", "genero": "NB", "rasgo": "Piel oliva, cabello corto plateado", "bioma": "ruinas"},
	{"id": "char_06", "nombre": "Ember", "genero": "F", "rasgo": "Piel bronceada, cabello largo", "bioma": "volcan"},
]

var _seleccionado: String = ID_POR_DEFECTO

func catalogo() -> Array:
	return PERSONAJES

func cantidad() -> int:
	return PERSONAJES.size()

func ids() -> PackedStringArray:
	var out := PackedStringArray()
	for p in PERSONAJES:
		out.append(str(p.get("id", "")))
	return out

func existe(id: String) -> bool:
	for p in PERSONAJES:
		if str(p.get("id", "")) == id:
			return true
	return false

func datos(id: String) -> Dictionary:
	for p in PERSONAJES:
		if str(p.get("id", "")) == id:
			return p
	return {}

## Selecciona un personaje. Devuelve false si el id no existe (no cambia nada).
func seleccionar(id: String) -> bool:
	if not existe(id):
		return false
	_seleccionado = id
	return true

func personaje_actual() -> String:
	return _seleccionado

func datos_actual() -> Dictionary:
	return datos(_seleccionado)

## Cozy: todos los personajes estan desbloqueados desde el inicio (sin locks).
func desbloqueados() -> PackedStringArray:
	return ids()

## La seleccion es puramente visual: el catalogo no declara ningun stat.
func todos_mismos_stats() -> bool:
	for p in PERSONAJES:
		for clave in p.keys():
			var k := str(clave)
			if k == "stat" or k.begins_with("stat_") or k == "bonus" or k == "velocidad":
				return false
	return true

## Persistencia: bloque serializable para M59/GameState.
func serializar() -> Dictionary:
	return {"character_id": _seleccionado}

func deserializar(data: Dictionary) -> bool:
	var id := str(data.get("character_id", ""))
	if id == "":
		return false
	if not existe(id):
		# Id desconocido (save de otra version): se conserva el actual y se
		# reporta false para que el llamador pueda decidir. No se degrada nada.
		return false
	_seleccionado = id
	return true
