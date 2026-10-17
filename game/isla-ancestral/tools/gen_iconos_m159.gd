# gen_iconos_m159.gd — M159 b2 (Bloque A visual, director N704): generador de iconos PLACEHOLDER 2D.
#
# Estilo "placeholder 2D simple" (nicho agnes, barato y estable): 1 ítem = 1 sprite
# plano 48×48 legible a 32×32, coherente con la paleta UI (D102: amber/cream sobre dark).
# Regla M46 §7 "cero texto embebido": solo color + forma geométrica, SIN letras.
#
# Por ítem: relleno redondeado en el COLOR DE CATEGORÍA + borde 3px en COLOR DE RAREZA.
# Escribe el PNG en assets/2d/items_m159/ico_<id>.png y corrige el campo `icono` del .tres.
#
# Uso: godot --headless -s res://tools/gen_iconos_m159.gd
#
# **Modelo:** agnes-3-flash (Sapiens AI)
# **Plataforma:** Kilo Code
# **Fecha:** 2026-10-17

extends SceneTree

const OUT_DIR := "res://assets/2d/items_m159/"
const SIZE := 48

# Paleta D102 (amber/cream sobre dark): color de relleno por CATEGORÍA (índice = enum categoria).
# Cozy, matizada, distinguible. (Los 16 valores cubren el range del enum M159.)
const CAT_COLORS: Array[String] = [
	"#C4A882", "#8FBF6F", "#6FA8BF", "#C58A5A", "#B5A85A", "#8A6FBF",
	"#BF6F6F", "#5ABF9F", "#C5A88A", "#7FBF8A", "#BF7FA8", "#8A8A6F",
	"#C5C07F", "#6F8ABF", "#BF8A8A", "#A8A8A8",
]

# Borde por RAREZA (0 común, 1 inusual, 2 raro, 3 legendario) — amber/cream sobre dark.
const RAREZA_BORDERS: Array[String] = [
	"#8A8A8A", "#5ABF9F", "#E0A030", "#E8D48A",
]

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var d := DirAccess.open("res://")
	if d:
		d.make_dir_recursive("assets/2d/items_m159")
	# tanda 2 (N704): herramientas T1 (jugador) + recursos con tracción
	var ids: Array[String] = [
		"item_obj_her_001", "item_obj_her_002", "item_obj_her_003", "item_obj_her_004", "item_obj_her_005",
		"gemstone", "glass", "ice", "mud", "moss",
	]
	# Deduplicate preserving order
	var seen := {}
	var unicos: Array[String] = []
	for id in ids:
		if not seen.has(id):
			seen[id] = true
			unicos.append(id)

	var ok := 0
	var fallos: Array[String] = []
	for id in unicos:
		var tres := _find_tres(id)
		if tres.is_empty():
			fallos.append("SIN_TRES: " + id)
			continue
		var campos: Array = _leer_camp(tres)
		var categoria := int(campos[0])
		var rareza := int(campos[1])
		var ruta_png := OUT_DIR.path_join("ico_" + _slug(id) + ".png")
		if _dibujar_icono(categoria, rareza, ruta_png):
			ok += 1
			_set_icono_tres(tres, ruta_png)  # ruta_png ya trae el prefijo res://
			print("  [OK] %s -> %s (cat=%d, rareza=%d)" % [id, ruta_png, categoria, rareza])
		else:
			fallos.append("DIBUJO: " + id)

	print("=== [M159 b2] gen iconos: %d OK, %d fallos ===" % [ok, fallos.size()])
	for f in fallos:
		print("  [FAIL] " + f)
	quit(0 if fallos.is_empty() else 1)

# Busca el .tres por "id = <id>" o por nombre de archivo <id>.tres.
func _find_tres(id: String) -> String:
	var a := "res://data/items/" + id + ".tres"
	if FileAccess.file_exists(a):
		return a
	var dir := DirAccess.open("res://data/items")
	if dir:
		dir.list_dir_begin()
		var e := dir.get_next()
		while e != "":
			if e.get_extension().to_lower() == "tres" and e.begins_with(id):
				return "res://data/items/" + e
			e = dir.get_next()
		dir.list_dir_end()
	return ""

func _leer_camp(tres: String) -> Array:
	var contenido := FileAccess.get_file_as_string(tres)
	var categoria := 0
	var rareza := 0
	if contenido.find("categoria =") >= 0:
		var m := RegEx.new()
		m.compile("categoria\\s*=\\s*(\\d+)")
		var r := m.search(contenido)
		if r:
			categoria = int(r.get_string(1))
	if contenido.find("rareza =") >= 0:
		var m2 := RegEx.new()
		m2.compile("rareza\\s*=\\s*(\\d+)")
		var r2 := m2.search(contenido)
		if r2:
			rareza = int(r2.get_string(1))
	return [categoria, rareza]

# Dibuja un placeholder 48×48: relleno (color categoría) + borde 3px (color rareza). Sin texto.
func _dibujar_icono(categoria: int, rareza: int, ruta: String) -> bool:
	var fondo := Color.from_string(CAT_COLORS[clampi(categoria, 0, CAT_COLORS.size() - 1)], Color.WHITE)
	var borde := Color.from_string(RAREZA_BORDERS[clampi(rareza, 0, RAREZA_BORDERS.size() - 1)], Color.WHITE)
	var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	img.fill(fondo)
	# Borde 3px (anillo) en color de rareza
	for y in range(SIZE):
		for x in range(SIZE):
			if x < 3 or y < 3 or x >= SIZE - 3 or y >= SIZE - 3:
				img.set_pixel(x, y, borde)
	# Esquinas suaves: 2 px transparentes por esquina
	for i in range(2):
		img.set_pixel(i, i, Color(0, 0, 0, 0))
		img.set_pixel(SIZE - 1 - i, i, Color(0, 0, 0, 0))
		img.set_pixel(i, SIZE - 1 - i, Color(0, 0, 0, 0))
		img.set_pixel(SIZE - 1 - i, SIZE - 1 - i, Color(0, 0, 0, 0))
	return img.save_png(ProjectSettings.globalize_path(ruta)) == OK

func _slug(id: String) -> String:
	return id.to_lower().replace(" ", "_").replace("/", "_")

# Corrige el campo `icono` del .tres (linea a linea) para apuntar al PNG real.
func _set_icono_tres(tres: String, ruta_png: String) -> void:
	var lineas := FileAccess.get_file_as_string(tres).split("\n")
	var escrito := false
	for i in range(lineas.size()):
		var l: String = lineas[i]
		if l.strip_edges().begins_with("icono"):
			lineas[i] = 'icono = "%s"' % ruta_png
			escrito = true
	if not escrito:
		lineas.append('icono = "%s"' % ruta_png)
	var f := FileAccess.open(tres, FileAccess.WRITE)
	if f:
		f.store_string("\n".join(lineas))
		f.close()
