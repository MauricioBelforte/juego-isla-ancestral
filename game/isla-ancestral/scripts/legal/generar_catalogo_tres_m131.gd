extends SceneTree

## M131 (ítem E.L58): genera `data/legal/catalogo_creditos.tres` desde
## `data/legal/creditos.json` (fuente canónica) y verifica que el
## Resource tipado cargue con la estructura esperada (7 secciones).
## Corrida headless: godot472.exe --headless --path game/isla-ancestral
##   --script res://scripts/legal/generar_catalogo_tres_m131.gd
## Nota: preload explícito (no class_name global) para que el script sea
## autocontenido en corridas headless --script sin escaneo de editor.

const CreditsCatalog := preload("res://scripts/legal/credits_catalog.gd")

func _init() -> void:
	var f := FileAccess.open("res://data/legal/creditos.json", FileAccess.READ)
	if f == null:
		printerr("[M131] no se pudo abrir data/legal/creditos.json")
		quit(1)
		return
	var json := JSON.new()
	var err := json.parse(f.get_as_text())
	f.close()
	if err != OK:
		printerr("[M131] JSON inválido: ", json.get_error_message())
		quit(1)
		return
	var datos: Dictionary = json.data
	var catalogo = CreditsCatalog.new()
	var secciones: Array[Dictionary] = []
	for s in datos.get("secciones", []):
		secciones.append(s)
	catalogo.secciones = secciones
	catalogo.politicas = datos.get("politicas", {})
	var idiomas: Array[String] = []
	for i in datos.get("idiomas", []):
		idiomas.append(i)
	catalogo.idiomas = idiomas
	catalogo.version = int(datos.get("version", 2))
	var save_err := ResourceSaver.save(catalogo, "res://data/legal/catalogo_creditos.tres")
	if save_err != OK:
		printerr("[M131] ResourceSaver.save falló: ", save_err)
		quit(1)
		return
	var recargado = load("res://data/legal/catalogo_creditos.tres")
	if recargado == null or not (recargado is CreditsCatalog):
		printerr("[M131] el .tres generado no carga como CreditsCatalog")
		quit(1)
		return
	if recargado.secciones.size() != 7:
		printerr("[M131] secciones esperadas: 7, obtenidas: ", recargado.secciones.size())
		quit(1)
		return
	if recargado.idiomas.size() != 2:
		printerr("[M131] idiomas esperados: 2, obtenidos: ", recargado.idiomas.size())
		quit(1)
		return
	print("[M131] catalogo_creditos.tres generado y verificado: ", recargado.secciones.size(), " secciones, ", recargado.idiomas.size(), " idiomas, version ", recargado.version)
	quit(0)
