# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-09
#
# M24 iter. 6: checkpoints, reinicio y RECOMPENSAS.
# Cierra los items 157, 162, 163 y 164 del checklist:
#   157 checkpoint atomico (tmp + rename + .bak)
#   162 recompensas unicas no duplicables (cofre con M66)
#   163 recompensas alineadas al lore del templo
#   164 documentacion en el plan-actual (03-Diseno.md)
#
# Composicion, no duplicacion:
#   - El guardado ATOMICO ya existe en `scripts/templos/templo_checkpoint.gd`
#     (patron tmp -> .bak del anterior -> rename; con las trampas headless ya
#     resueltas: solo funciones `*_absolute()`). Esta clase lo COMPONE.
#   - Las recompensas unicas usan el contrato real de M66
#     (`scripts/core/recovery/cofre_recuperacion.gd`): 1 copia inmutable por
#     clave, jamas duplicable (`depositar` + `entregar`; `fue_entregada`).

class_name PuzzleRecompensas
extends RefCounted

var def: Dictionary = {}
var sala: PuzzleRoom = null
var recompensas: Array = []
var cofre_config: Dictionary = {}
var lore_templo: Array = []
var checkpoint_config: Dictionary = {}
var checkpoint: TemploCheckpoint = null

# --- Carga ---------------------------------------------------------------

static func cargar(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("[M24] PuzzleRecompensas.cargar: no existe %s" % path)
		return {}
	var crudo: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(crudo) != TYPE_DICTIONARY:
		push_warning("[M24] PuzzleRecompensas.cargar: %s no es un objeto JSON" % path)
		return {}
	return crudo as Dictionary

static func desde_def(d: Dictionary) -> PuzzleRecompensas:
	var pr := PuzzleRecompensas.new()
	pr._construir(d)
	return pr

func _construir(d: Dictionary) -> void:
	def = d
	sala = PuzzleDef.a_puzzle_room(d)
	recompensas = []
	cofre_config = {}
	lore_templo = []
	checkpoint_config = {}
	var rz: Variant = d.get("recompensas", {})
	var r: Dictionary = (rz as Dictionary) if typeof(rz) == TYPE_DICTIONARY else {}
	var lz: Variant = r.get("lista", [])
	if typeof(lz) == TYPE_ARRAY:
		recompensas = (lz as Array).duplicate(true)
	var cz: Variant = r.get("cofre_m66", {})
	cofre_config = (cz as Dictionary) if typeof(cz) == TYPE_DICTIONARY else {}
	var ltz: Variant = r.get("lore_templo", [])
	if typeof(ltz) == TYPE_ARRAY:
		lore_templo = (ltz as Array).duplicate()
	var cpz: Variant = r.get("checkpoint", {})
	checkpoint_config = (cpz as Dictionary) if typeof(cpz) == TYPE_DICTIONARY else {}
	checkpoint = TemploCheckpoint.new()

## Redirige el directorio de checkpoints (para pruebas / aislar `user://`).
func usar_directorio_checkpoint(dir_base: String) -> void:
	if checkpoint == null:
		checkpoint = TemploCheckpoint.new(dir_base)
	else:
		checkpoint.dir = dir_base

# --- Item 157: checkpoint atomico ----------------------------------------

## El patron atomico esta declarado (tmp + .bak + rename) en los datos.
func patron_atomico() -> bool:
	return bool(checkpoint_config.get("tmp", false)) \
		and bool(checkpoint_config.get("bak", false)) \
		and bool(checkpoint_config.get("rename", false)) \
		and str(checkpoint_config.get("patron", "")) == "atomico"

## Guarda el estado del puzzle de forma atomica (delega en TemploCheckpoint).
func guardar_checkpoint(cp_id: String, estado: Dictionary) -> bool:
	if checkpoint == null:
		return false
	return checkpoint.guardar(cp_id, estado)

func cargar_checkpoint(cp_id: String) -> Dictionary:
	if checkpoint == null:
		return {}
	return checkpoint.cargar(cp_id)

func respaldo_existe(cp_id: String) -> bool:
	if checkpoint == null:
		return false
	return checkpoint.respaldo_existe(cp_id)

# --- Item 162 + 163: recompensas unicas y alineadas al lore --------------

func recompensa(id: String) -> Dictionary:
	for r in recompensas:
		if typeof(r) == TYPE_DICTIONARY and str((r as Dictionary).get("id", "")) == id:
			return r as Dictionary
	return {}

func ids_recompensas() -> Array:
	var out: Array = []
	for r in recompensas:
		if typeof(r) == TYPE_DICTIONARY:
			out.append(str((r as Dictionary).get("id", "")))
	return out

func es_unica(id: String) -> bool:
	return bool(recompensa(id).get("unica", false))

func item_de(id: String) -> String:
	return str(recompensa(id).get("item", ""))

## Clave inmutable en el cofre M66 (una por recompensa).
func clave_de(id: String) -> String:
	return "recompensa:%s" % id

func es_inmutable() -> bool:
	return bool(cofre_config.get("inmutable", false))

func cofre_id() -> String:
	return str(cofre_config.get("id", ""))

## Otorga la recompensa. Si es UNICA, usa el cofre M66: la primera vez la
## entrega; las siguientes devuelven false (jamas duplica). Si no es unica, se
## concede siempre (true).
func otorgar(id: String, cofre: Object) -> bool:
	if recompensa(id).is_empty():
		return false
	if not es_unica(id):
		return true
	if cofre == null or not cofre.has_method("fue_entregada") \
			or not cofre.has_method("depositar") or not cofre.has_method("entregar"):
		return false
	var clave: String = clave_de(id)
	if bool(cofre.call("fue_entregada", clave)):
		return false
	if not bool(cofre.call("depositar", clave, item_de(id))):
		return false
	return bool(cofre.call("entregar", clave))

func ya_otorgada(id: String, cofre: Object) -> bool:
	if not es_unica(id):
		return false
	if cofre == null or not cofre.has_method("fue_entregada"):
		return false
	return bool(cofre.call("fue_entregada", clave_de(id)))

# --- Item 163: alineacion al lore del templo -----------------------------

func lore_de(id: String) -> String:
	return str(recompensa(id).get("lore", ""))

func alineada_al_lore(id: String) -> bool:
	var l: String = lore_de(id)
	return not l.is_empty() and lore_templo.has(l)

func todas_alineadas() -> bool:
	for id in ids_recompensas():
		if not alineada_al_lore(str(id)):
			return false
	return recompensas.size() > 0

func lores_usados() -> Array:
	var out: Array = []
	for r in recompensas:
		if typeof(r) != TYPE_DICTIONARY:
			continue
		var l: String = str((r as Dictionary).get("lore", ""))
		if not l.is_empty() and not out.has(l):
			out.append(l)
	return out

# --- Validacion -----------------------------------------------------------

## Valida el framework + la capa de recompensas. Devuelve [] si es coherente.
func validar() -> Array:
	var errores: Array = []
	errores.append_array(PuzzleDef.validar_def(def))
	if recompensas.is_empty():
		errores.append("la familia de recompensas no declara recompensas")
	if not es_inmutable():
		errores.append("el cofre M66 no esta declarado inmutable (item 162)")
	if cofre_id().is_empty():
		errores.append("el cofre M66 no declara id")
	if lore_templo.is_empty():
		errores.append("no se declara el lore del templo (item 163)")
	var declarados: Array = PuzzleDef.ids_emisores(def)
	for r in recompensas:
		if typeof(r) != TYPE_DICTIONARY:
			errores.append("recompensa no es un objeto")
			continue
		var rd: Dictionary = r as Dictionary
		var rid: String = str(rd.get("id", ""))
		if rid.is_empty():
			errores.append("recompensa sin id")
		if str(rd.get("tipo", "")).is_empty():
			errores.append("la recompensa '%s' no declara tipo" % rid)
		if str(rd.get("lore", "")).is_empty():
			errores.append("la recompensa '%s' no esta alineada al lore" % rid)
		elif not lore_templo.has(str(rd.get("lore", ""))):
			errores.append("la recompensa '%s' usa un lore no declarado '%s'" % [rid, str(rd.get("lore", ""))])
		if not rd.has("unica"):
			errores.append("la recompensa '%s' no declara si es unica" % rid)
		var e: int = int(rd.get("emisor", -1))
		if not declarados.has(e):
			errores.append("la recompensa '%s' usa emisor inexistente %d" % [rid, e])
	if not patron_atomico():
		errores.append("el checkpoint no declara el patron atomico (tmp + bak + rename)")
	return errores
