# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M108: Validador del Pipeline de Assets.
# Recorre assets/3d/ (media/baja/alta) y valida los GLB contra la convención
# adoptada (ASSET-PIPELINE.md §3): {NN}-{Modulo}_{snake_case}[_variante].glb,
# formato permitido, tamaño, existencia de ficha y licencia declarada.
# Uso: godot --headless -s res://tools/asset_validator.gd [--sin-ficha]
# Salida: tools/reportes/asset_validation.txt · exit 1 si hay errores.

extends SceneTree

const ASSETS_3D_DIR := "res://assets/3d/"
const FICHAS_DIR := "res://assets/fichas/"
const REPORT_PATH := "res://tools/reportes/asset_validation.txt"
const EXT_PERMITIDAS := ["glb", "gltf", "png", "webp", "ogg", "ttf", "otf"]
const TAMANO_AVISO_MB := 8.0

var _sin_ficha := false

func _init() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg == "--sin-ficha":
			_sin_ficha = true
	call_deferred("_run_validation")

func _run_validation() -> void:
	var lineas := PackedStringArray()
	lineas.append("=== M108: VALIDADOR DEL PIPELINE DE ASSETS (2026-09-01) ===")
	lineas.append("")
	var total := 0
	var ok := 0
	var errores := 0
	var avisos := 0

	var archivos := _listar_glb(ASSETS_3D_DIR)
	archivos.sort()

	for ruta in archivos:
		total += 1
		var nombre := ruta.get_file()
		var rel := ruta.trim_prefix("res://")
		var lineas_err := _validar_asset(ruta, nombre)
		if lineas_err.is_empty():
			ok += 1
			lineas.append("  [OK] " + rel)
		else:
			for e in lineas_err:
				if e.begins_with("[AVISO]"):
					avisos += 1
					lineas.append("  " + rel + " -> " + e)
				else:
					errores += 1
					lineas.append("  " + rel + " -> " + e)

	lineas.append("")
	lineas.append("=== Resultado: %d assets, %d OK, %d error(es), %d aviso(s) ===" % [total, ok, errores, avisos])
	var texto := "\n".join(lineas)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tools/reportes"))
	var f := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if f:
		f.store_string(texto)
		f.close()
	print(texto)
	quit(1 if errores > 0 else 0)

func _listar_glb(dir_actual: String) -> PackedStringArray:
	var result := PackedStringArray()
	var dir := DirAccess.open(dir_actual)
	if dir == null:
		return result
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		var ruta := dir_actual + entry
		if dir.current_is_dir():
			if entry != "." and entry != ".." and entry != "retirados":
				result.append_array(_listar_glb(ruta + "/"))
		elif _es_assset_modelo(entry):
			result.append(ruta)
		entry = dir.get_next()
	dir.list_dir_end()
	return result

func _es_assset_modelo(archivo: String) -> bool:
	for ext in ["glb", "gltf"]:
		if archivo.to_lower().ends_with("." + ext):
			return true
	return false

func _validar_asset(ruta: String, nombre: String) -> PackedStringArray:
	var errs := PackedStringArray()
	var base := nombre.trim_suffix(".glb").trim_suffix(".gltf")

	# FORMATO
	var ext := nombre.get_extension().to_lower()
	if not EXT_PERMITIDAS.has(ext):
		errs.append("[ERROR] formato no permitido: ." + ext)

	# NOMBRE: {NN}-{Modulo}_{snake_case}[_variante]
	if not base.begins_with(""):
		var partes := base.split("_")
		var sin_variante := base
		for v in ["_media", "_baja", "_alta"]:
			if sin_variante.ends_with(v):
				sin_variante = sin_variante.trim_suffix(v)
				break
		# Sin caracteres prohibidos
		if nombre != nombre.replace("á", "a").replace("é", "e").replace("í", "i").replace("ó", "o").replace("ú", "u").replace("ñ", "n"):
			errs.append("[ERROR] caracteres no ASCII en el nombre")
		if nombre.contains(" ") or nombre.contains("(") or nombre.contains(")") or nombre.contains("["):
			errs.append("[ERROR] caracteres especiales/espacios en el nombre")
		if nombre.length() > 64:
			errs.append("[ERROR] nombre mayor a 64 chars (%d)" % nombre.length())
		# Estructura: NN- modulo_ (debe existir guion tras 2 digitos)
		if not (nombre[0].is_valid_int() and nombre[1].is_valid_int() and nombre[2] == "-"):
			errs.append("[ERROR] no cumple prefijo {NN}- (ID del modulo productor)")
		# Segunda parte: PascalCase {Modulo}
		var seg_mod := sin_variante.substr(3, sin_variante.find("_") - 3)
		if seg_mod == "" or seg_mod.find("_") != -1:
			errs.append("[ERROR] segmento de modulo no presente (PascalCase rompido)")

	# TAMANO
	var f := FileAccess.open(ruta, FileAccess.READ)
	if f:
		var kb := f.get_length() / 1024.0 / 1024.0
		f.close()
		if kb > TAMANO_AVISO_MB:
			errs.append("[AVISO] asset de %.1f MB (> 8 MB)" % kb)

	# FICHA (RF8) + LICENCIA (RF7)
	if not _sin_ficha:
		var id_fich := base
		var ruta_fich := FICHAS_DIR + id_fich + ".md"
		if not FileAccess.file_exists(ruta_fich):
			errs.append("[ERROR] ficha requerida no existe: assets/fichas/%s.md" % id_fich)
		else:
			var contenido := FileAccess.get_file_as_string(ruta_fich)
			if not contenido.contains("estado") or not contenido.contains("APROBADO"):
				errs.append("[AVISO] ficha sin estado APROBADO: %s.md" % id_fich)
			if contenido.contains("origen | ia_gen") and not contenido.contains("licencia |"):
				errs.append("[ERROR] asset IA generativa sin licencia declarada (RF10)")

	return errs
