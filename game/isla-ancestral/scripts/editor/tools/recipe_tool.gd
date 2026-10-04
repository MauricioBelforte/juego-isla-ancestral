# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M109: RecipeTool — Editor de recetas del crafting (RF6/M93 crafting.json).
# Extiende EditorBase: lista de recetas, formulario con validación RecipeSchema
# y guardado con backup .bak. Registra en el plugin Herramientas internas.

@tool
extends "res://scripts/editor/tools/editor_base.gd"

const RUTA_DATOS := "res://data/balance/crafting.json"
const SRC_SCHEMA := preload("res://scripts/editor/support/recipe_schema.gd")
const CAMPOS := ["id", "nombre", "categoria", "nivel", "estacion", "origen", "coste_recursos", "coste_ao", "resultado", "resultado_cantidad"]

var _recetas: Dictionary = {}

func _ready() -> void:
	super._ready()
	configurar("EditorRecetas", RUTA_DATOS, Callable(self, "listar"), Callable(self, "campos_de"), Callable(self, "guardar"))
	_cargar_json()

func _cargar_json() -> void:
	_recetas = {}
	if not FileAccess.file_exists(RUTA_DATOS):
		return
	var f := FileAccess.open(RUTA_DATOS, FileAccess.READ)
	if f == null:
		return
	var texto := f.get_as_text()
	f.close()
	var json := JSON.new()
	if json.parse(texto) == OK:
		var doc: Variant = json.data
		if doc is Dictionary:
			_recetas = doc.get("recetas", {})

func listar() -> Array[String]:
	return Array(_recetas.keys(), TYPE_STRING, "", null)

func campos_de(item_id: String) -> Dictionary:
	var receta: Dictionary = _recetas.get(item_id, {})
	var editar := item_id != ""
	var out := {}
	out["id"] = [item_id, not editar]
	for campo in CAMPOS:
		if campo == "id":
			continue
		var valor: String = ""
		if campo == "coste_recursos":
			valor = SRC_SCHEMA.costes_a_texto(receta.get("coste_recursos", {}))
		else:
			valor = str(receta.get(campo, ""))
		out[campo] = [valor, editar]
	return out

func guardar(valores: Dictionary) -> String:
	var id: String = str(valores.get("id", "")).strip_edges()
	var costes: Dictionary = SRC_SCHEMA.texto_a_costes(str(valores.get("coste_recursos", "")))
	var receta := {}
	for campo in CAMPOS:
		if campo == "id" or campo == "coste_recursos":
			continue
		var v: Variant = valores.get(campo, "")
		if campo == "coste_ao":
			v = str(v).to_float()
		elif campo == "nivel" or campo == "resultado_cantidad":
			v = str(v).to_int()
		receta[campo] = v
	receta["coste_recursos"] = costes
	var errores: Array[String] = SRC_SCHEMA.validar(id, receta)
	if not errores.is_empty():
		return "⚠️ Receta inválida: " + ", ".join(errores)
	# guardar con backup .bak
	var f := FileAccess.open(RUTA_DATOS, FileAccess.READ)
	if f:
		var old := f.get_as_text()
		f.close()
		var bak := FileAccess.open(RUTA_DATOS + ".bak", FileAccess.WRITE)
		if bak:
			bak.store_string(old)
			bak.close()
	_recetas[id] = receta
	var doc := {"schema_version": 1, "recetas": _recetas}
	var ok := false
	var out := FileAccess.open(RUTA_DATOS, FileAccess.WRITE)
	if out:
		ok = true
		out.store_string(JSON.stringify(doc, "\t"))
		out.close()
	print("[M109] Receta guardada: %s → crafting.json (%s)" % [id, "OK" if ok else "FAIL"])
	return "Receta %s guardada con backup .bak" % id
