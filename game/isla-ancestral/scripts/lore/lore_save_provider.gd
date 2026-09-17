# Modelo: DeepSeek-V4.1-Flash / WorkBuddy
# Plataforma: WorkBuddy
# Fecha: 2026-09-13
#
# M148: Lore Ambiental — LoreSaveProvider (sección "lore" del save)
# Persiste el estado de exploración de lore ambiental (RF8): qué piezas ya
# vio el jugador y cuántas por isla. Implementa el contrato ISaveProvider
# (get_section_name/get_save_data/restore_save_data) por duck-typing, igual
# que PlayerSaveProvider/BuildingsSaveProvider (M59, save_snapshot.gd).
#
# Registro (M59):  SaveManager.register_provider(LoreSaveProvider.new())
# La sección "lore" es ADITIVA: los saves antiguos que no la traen se
# restauran a estado vacío válido vía migrar() — nunca degradan el save.

class_name LoreSaveProvider
extends RefCounted

## Nombre de la sección dentro del payload del save.
const SECCION := "lore"

## Versión del formato de esta sección (migración solo hacia delante).
const VERSION_SECCION := 1

var _explorado: Dictionary = {}   # id (String) -> true
var _por_isla: Dictionary = {}    # isla (String) -> int (exploradas)

# ── Contrato ISaveProvider ────────────────────────────────────────────

func get_section_name() -> String:
	return SECCION

func get_save_data() -> Dictionary:
	return {
		"version": VERSION_SECCION,
		"explorado": ids_explorados(),
		"por_isla": _por_isla.duplicate(),
	}

func restore_save_data(data: Dictionary) -> void:
	reset()
	var normalizado := migrar(data, int(data.get("version", 0)))
	for id in normalizado["explorado"]:
		_explorado[str(id)] = true
	_por_isla = normalizado["por_isla"]

# ── Migración ─────────────────────────────────────────────────────────

## Normaliza una sección "lore" posiblemente ausente/parcial (saves v0/v1
## sin el campo) a la versión actual. NUNCA degrada: si no hay datos deja
## estado vacío válido. Devuelve {version, explorado, por_isla}.
static func migrar(data: Variant, desde_version: int = 0) -> Dictionary:
	var explorado: Array = []
	var por_isla: Dictionary = {}
	if typeof(data) == TYPE_DICTIONARY:
		var e: Variant = data.get("explorado", [])
		if typeof(e) == TYPE_ARRAY:
			for i in e:
				# str() y NO String(): String(int) no es un constructor válido
				# en Godot 4 y aborta la función en silencio (bug latente).
				var sid := str(i)
				if not sid.is_empty():
					explorado.append(sid)
		var p: Variant = data.get("por_isla", {})
		if typeof(p) == TYPE_DICTIONARY:
			for k in p:
				por_isla[str(k)] = int(p[k])
	# Deduplicar ids (un save corrupto con repetidos no debe inflar el estado)
	var unicos: Dictionary = {}
	for sid in explorado:
		unicos[sid] = true
	var lista: Array = unicos.keys()
	lista.sort()
	return {
		"version": VERSION_SECCION,
		"explorado": lista,
		"por_isla": por_isla,
		"_migrado_desde": desde_version,
	}

# ── API de juego ──────────────────────────────────────────────────────

## ¿Ya se exploró esta pieza? (no re-notificar, RF8)
func ya_explorado(id: String) -> bool:
	return _explorado.has(id)

## Marca una pieza como explorada. Devuelve true SOLO si es nueva, de modo
## que el llamador pueda decidir si notificar (evita re-notificación).
func marcar_explorado(id: String, isla: String = "") -> bool:
	if id.is_empty() or _explorado.has(id):
		return false
	_explorado[id] = true
	if not isla.is_empty():
		_por_isla[isla] = int(_por_isla.get(isla, 0)) + 1
	return true

func contador_isla(isla: String) -> int:
	return int(_por_isla.get(isla, 0))

func total_explorado() -> int:
	return _explorado.size()

func ids_explorados() -> Array:
	var out: Array = _explorado.keys()
	out.sort()
	return out

func reset() -> void:
	_explorado.clear()
	_por_isla.clear()
