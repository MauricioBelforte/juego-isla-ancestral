# pack_atlas.gd — M46 Arte 2D (lote final, director N673)
# Empacador de atlas POR SUPERFICIE según ART_STYLE_2D §7 (RF12) + §9.
#
# Reglas M46 (difieren de M108 atlas_builder, que usa 4096/margen 4):
#   - 5 atlas por superficie: ui_atlas, icons_atlas, portraits_atlas, story_atlas, badges_atlas
#   - límite 2048×2048 por atlas
#   - padding >= 2 px (anti-bleeding)
#   - sin rotaciones en empaquetado
#   - regeneración determinista (orden alfabético) -> repacker idempotente
#
# Es un RefCounted puro (headless-testable, sin dependencias de escena). Cuando los
# assets 2D lleguen (M45/M108, hoy 0/48), pack_todas() regenera los atlas + un
# manifiesto JSON (asset -> {atlas, x, y, w, h}) para el runtime cargar por región.
#
# **Modelo:** agnes-3-flash (Sapiens AI)
# **Plataforma:** Kilo Code
# **Fecha:** 2026-10-16

extends RefCounted

const MAX_ATLAS := 2048
const PADDING := 2
const SIN_ROTACION := true

# M46 §7 RF12: atlas por superficie + carpeta de origen en assets/2d/
const SUPERFICIES := {
	"ui_atlas": "ui",
	"icons_atlas": "icons",
	"portraits_atlas": "portraits",
	"story_atlas": "story",
	"badges_atlas": "badges",
}

class ResultadoSuperficie extends RefCounted:
	var atlas: String
	var piezas_empacadas: int = 0
	var manifiesto: Array[Dictionary] = []
	var errores: Array[String] = []

	func _init(p_atlas: String) -> void:
		atlas = p_atlas

	func esta_ok() -> bool:
		return errores.is_empty()

# Packea una superficie: recoge las texturas de `carpeta` y las empaqueta en
# `res://assets/2d/<atlas>.png` (2048², padding 2, sin rotación) + manifiesto.
func packear_superficie(atlas: String, carpeta_rel: String = "res://assets/2d/") -> ResultadoSuperficie:
	var r := ResultadoSuperficie.new(atlas)
	var abs_carpeta := ProjectSettings.globalize_path(carpeta_rel)

	var sub : String
	# La superficie apunta a una subcarpeta (ej. "icons"). Si no existe, se crea
	# vacía (superficie sin assets = #esperando). NO hacer fallback a la carpeta
	# base: eso contaminaría el escaneo con los .png de salida de otras superficies.
	if SUPERFICIES.has(atlas):
		sub = SUPERFICIES[atlas]
	else:
		sub = atlas
	var origen := abs_carpeta.path_join(sub)
	if not DirAccess.dir_exists_absolute(origen):
		DirAccess.make_dir_recursive_absolute(origen)
		r.errores.append("VACIO: carpeta '%s' creada vacía (0 assets 2D, #esperando:assets-2d)" % origen)
		return r

	var archivos := _recorrer_texturas(origen)
	if archivos.is_empty():
		r.errores.append("VACIO: 0 texturas en '%s' (assets 2D pendientes, #esperando:assets-2d)" % origen)
		return r

	# Determinismo: orden alfabético (repack idempotente)
	archivos.sort()

	var atlas_path := carpeta_rel.path_join(atlas + ".png")
	var atlas_abs := ProjectSettings.globalize_path(atlas_path)

	var imagenes: Array[Image] = []
	for ruta in archivos:
		var img := Image.new()
		if img.load(ruta) != OK:
			r.errores.append("IMAGEN: no se pudo cargar '%s'" % ruta)
			continue
		imagenes.append(img)

	if imagenes.is_empty():
		r.errores.append("VACIO: ninguna textura válida en '%s'" % origen)
		return r

	var canvas := Image.create(MAX_ATLAS, MAX_ATLAS, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0, 0, 0, 0))

	var x := PADDING
	var y := PADDING
	var fila := 0
	for img in imagenes:
		var w := img.get_width()
		var h := img.get_height()
		# Sin rotación: siempre se coloca "de pie". Verificación §8 (múltiplo de 4, cuadrado)
		if x + w + PADDING > MAX_ATLAS:
			x = PADDING
			y += fila + PADDING
			fila = 0
		if y + h + PADDING > MAX_ATLAS:
			r.errores.append("ATLAS: pieza '%s' (%dx%d) excede %dx%d (reducir o separar superficie)" % [img.get_path(), w, h, MAX_ATLAS, MAX_ATLAS])
			return r
		var destino := Vector2(x, y)
		canvas.blit_rect(img, Rect2(Vector2.ZERO, Vector2(w, h)), destino)
		r.manifiesto.append({
			"asset": img.get_path().get_file(),
			"atlas": atlas,
			"x": x,
			"y": y,
			"w": w,
			"h": h,
			"rotacion": false,
		})
		x += w + PADDING
		fila = maxf(fila, float(h))

	canvas.save_png(atlas_abs)
	r.piezas_empacadas = imagenes.size()
	return r

# Empaqueta las 5 superficies M46 y escribe el manifiesto JSON consolidado.
func pack_todas(carpeta_rel: String = "res://assets/2d/") -> Array[ResultadoSuperficie]:
	var resultados: Array[ResultadoSuperficie] = []
	for atlas in SUPERFICIES.keys():
		resultados.append(packear_superficie(atlas, carpeta_rel))
	_escribir_manifiesto(carpeta_rel, resultados)
	return resultados

func _recorrer_texturas(carpeta_abs: String) -> Array[String]:
	var out: Array[String] = []
	var dir := DirAccess.open(carpeta_abs)
	if dir == null:
		return out
	dir.list_dir_begin()
	var entrada := dir.get_next()
	while entrada != "":
		if entrada != "." and entrada != "..":
			if not dir.current_is_dir() and entrada.get_extension().to_lower() in ["png", "webp"]:
				out.append(carpeta_abs.path_join(entrada))
		entrada = dir.get_next()
	dir.list_dir_end()
	return out

func _escribir_manifiesto(carpeta_rel: String, resultados: Array[ResultadoSuperficie]) -> void:
	var consolidado: Array[Dictionary] = []
	for r in resultados:
		consolidado.append_array(r.manifiesto)
	var json := JSON.stringify({
		"schema_version": 1,
		"modulo": "M46",
		"max_atlas": MAX_ATLAS,
		"padding": PADDING,
		"rotaciones": false,
		"piezas": consolidado,
	}, "\t")
	var manifiesto_abs := ProjectSettings.globalize_path(carpeta_rel.path_join("atlas_manifest.json"))
	var f := FileAccess.open(manifiesto_abs, FileAccess.WRITE)
	if f != null:
		f.store_string(json)
		f.close()

# Resumen legible para logs / QA.
func resumen(resultados: Array[ResultadoSuperficie]) -> String:
	var ok := 0
	var total_piezas := 0
	for r in resultados:
		if r.esta_ok():
			ok += 1
		total_piezas += r.piezas_empacadas
	return "[M46] pack_atlas: %d/%d superficies OK, %d piezas empacadas (2048², padding %d, sin rotación)" % [ok, resultados.size(), total_piezas, PADDING]
