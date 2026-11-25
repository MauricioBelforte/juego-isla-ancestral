# Modelo: GLM-5.3-Flash
# Plataforma: Kilo Code
# Fecha: 2026-11-25
#
# M56: QA headless de la galeria (item L161 "No duplicar texturas en memoria
# al abrir la galeria"). Invariante central: la galeria crea UN TextureRect
# POR FOTO (en orden, layout estable) y NUNCA re-crea nodos al scrollear;
# las texturas viven solo en el rango visible (presupuesto M61 <= 24).
#
# Ejecutar: Godot --headless --path game/isla-ancestral
#           --script res://scripts/foto/qa_m56_galeria.gd
# Exit: 0 = verde | 1 = fallos

extends SceneTree

const GALLERY_SCRIPT := preload("res://scripts/foto/photo_gallery.gd")
const CARPETA := "user://fotos/"
const N_FOTOS := 30

var _checks: int = 0
var _fallos: int = 0
var _fotos_prueba: Array[String] = []

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)

func _summary() -> void:
	print("=== Resumen QA galeria M56 (L161): %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _crear_foto_prueba(i: int) -> String:
	var img := Image.create(640, 360, false, Image.FORMAT_RGB8)
	img.fill(Color(float(i) / float(N_FOTOS), 0.5, 0.5))
	var ruta := CARPETA + "qa_m161_%02d.png" % i
	img.save_png(ProjectSettings.globalize_path(ruta))
	return ruta

func _cleanup() -> void:
	for ruta in _fotos_prueba:
		if FileAccess.file_exists(ruta):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta))

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	await process_frame
	# Preparar album de prueba (archivos nombrados qa_m161_*; se borran al final).
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CARPETA))
	for i in range(N_FOTOS):
		_fotos_prueba.append(_crear_foto_prueba(i))
	var gal: Control = GALLERY_SCRIPT.new()
	gal.name = "GalleryQA"
	root.add_child(gal)
	await process_frame
	await process_frame

	# Invariante 1: UN nodo por foto, ninguno duplicado.
	var nodos: int = gal._grid.get_child_count()
	var total: int = gal._lista_fotos.size()
	_check("No duplicar texturas en memoria al abrir la galería: un TextureRect por foto (%d nodos = %d fotos del álbum, sin duplicados)" % [nodos, total],
		nodos == total and gal._nodos_fotos.size() == total)

	# Invariante 2: cargar una miniatura de una foto ya cargada no agrega nodos
	# (recarga por scroll con el mismo rango).
	gal._actualizar_visibles()
	gal._actualizar_visibles()
	_check("No duplicar texturas en memoria al abrir la galería: re-consultas del rango visible no crean nodos nuevos (%d nodos estables)" % gal._grid.get_child_count(),
		gal._grid.get_child_count() == total)
	var con_textura: int = 0
	for tr in gal._nodos_fotos.values():
		if is_instance_valid(tr) and tr.texture != null:
			con_textura += 1
	_check("No duplicar texturas en memoria al abrir la galería: presupuesto de texturas respetado (%d cargadas <= %d)" % [con_textura, gal.MAX_MINIATURAS_CARGADAS],
		con_textura <= gal.MAX_MINIATURAS_CARGADAS)

	# Invariante 3: scrollear lejos NO crea nodos nuevos y libera las texturas
	# fuera del rango visible.
	gal._scroll.size = Vector2(800, 600)
	var primera_ruta: String = str(gal._lista_fotos[0])
	var primera_tr: TextureRect = gal._nodos_fotos[primera_ruta] as TextureRect
	gal._actualizar_visibles()
	var tenia_textura: bool = primera_tr.texture != null
	# Scroll al fondo del album (filas lejanas -> miniaturas lejanas).
	gal._scroll.scroll_vertical = 10000
	gal._on_scroll_changed(10000)
	await process_frame
	_check("No duplicar texturas en memoria al abrir la galería: scrollear lejos no crea nodos nuevos (%d nodos estables)" % gal._grid.get_child_count(),
		gal._grid.get_child_count() == total)
	# Ventana chica (viewport 100 px => ~2 filas visibles): lo que quede fuera
	# del rango debe estar sin textura y el total debe respetar el presupuesto.
	gal._scroll.scroll_vertical = 0
	gal._scroll.size = Vector2(800, 100)
	await process_frame
	gal._actualizar_visibles()
	await process_frame
	var filas_f: int = int(gal._scroll.size.y / (gal.TAMANO_MINIATURA.y + 8)) + 2
	var cols_f: int = gal._grid.columns
	var fuera_con_textura: int = 0
	for ruta_f in gal._nodos_fotos:
		var tr_f: TextureRect = gal._nodos_fotos[ruta_f]
		if not is_instance_valid(tr_f):
			continue
		var idx_f: int = int(tr_f.get_meta("idx"))
		if tr_f.texture != null and idx_f >= filas_f * cols_f:
			fuera_con_textura += 1
	_check("No duplicar texturas en memoria al abrir la galería: la textura fuera del rango visible se libera (nodo lejano con textura: %d)" % fuera_con_textura,
		fuera_con_textura == 0)
	var con_textura_fin: int = 0
	for ruta_f in gal._nodos_fotos:
		var tr_f2: TextureRect = gal._nodos_fotos[ruta_f]
		if is_instance_valid(tr_f2) and tr_f2.texture != null:
			con_textura_fin += 1
	_check("No duplicar texturas en memoria al abrir la galería: texturas solo en rango visible y bajo presupuesto (%d cargadas <= %d)" % [con_textura_fin, gal.MAX_MINIATURAS_CARGADAS],
		con_textura_fin <= gal.MAX_MINIATURAS_CARGADAS)

	# Invariante 4: recargar vuelve a un estado consistente sin duplicar nodos.
	gal.recargar()
	await process_frame
	_check("No duplicar texturas en memoria al abrir la galería: recargar reconstruye exactamente %d nodos (sin duplicados)" % total,
		gal._grid.get_child_count() == total and gal._nodos_fotos.size() == total)

	gal.queue_free()
	_cleanup()
	_summary()
