# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy AI
# Fecha: 2026-11-02
# M110-UI: DiagnosticExporter — extraido de debug_menu.gd.
#
# Items del 05-Checklist que este archivo cierra:
#   L142 "Integracion DiagnosticExporter"   -> antes embebido en debug_menu.gd
#   L176 "DiagnosticExporter.gd"            -> el archivo no existia (grep 0)
#   L275 "Registrar DiagnosticExporter"     -> embebido, sin punto de registro
#   L287 "scripts/debug/diagnostic_exporter.gd" -> el archivo no existia
#
# El codigo es el MISMO que estaba en debug_menu.gd:1352-1438
# (`_export_diagnostic_zip` + `_do_export_diagnostic`); no se reescribio logica,
# solo se movio y se le dio una firma sin estado. `debug_menu.gd` conserva sus
# dos funciones como delegados de una linea para no romper a sus llamadores
# (`ejecutar_comando("exportar")`, `_export_diag()`, `test_debug_menu_headless`).
#
# Sin `class_name` a proposito: M110 ya sufrio colisiones de `class_name`
# globales en este arbol (BUG-091, `TerrainData`). Se consume por `preload`.
#
# Todo el modulo es ESTATICO: no guarda estado. Recibe la metadata ya armada,
# las lineas de consola y el viewport, y devuelve {ok, path, txt_path, error}.
# Fail-closed: cualquier fallo devuelve `ok=false` con `error` poblado; nunca
# lanza y nunca deja un ZIP a medio escribir como si fuera bueno.
extends RefCounted

## Carpeta destino dentro de `user://` (el build exportado no es escribible).
const DIR_DIAG := "user://diagnostics"
## Cola maxima de `output.txt` que se embebe en el ZIP.
const MAX_LINEAS_LOG := 200
## Nombre del PNG temporal del screenshot (se borra tras embeberlo).
const NOMBRE_PNG := "_diag_screenshot.png"


## Exporta un diagnostico completo: ZIP (metadata.json + logs.txt +
## screenshot.png si hay render) y ademas un .txt legible plano.
## Devuelve {"ok": bool, "path": String, "txt_path": String, "error": String}.
static func exportar(meta: Dictionary, lineas_consola: Array, vp: Viewport) -> Dictionary:
	var result := {"ok": false, "path": "", "txt_path": "", "error": ""}
	var zip_path := _ruta_zip()
	var dir := DirAccess.open(ProjectSettings.globalize_path("user://"))
	if dir == null:
		result["error"] = "no se puede abrir user://"
		return result
	if not dir.dir_exists("diagnostics"):
		dir.make_dir("diagnostics")

	var zip := ZIPPacker.new()
	var err := zip.open(zip_path)
	if err != OK:
		result["error"] = "no se pudo crear ZIP: error %d" % err
		return result

	zip.start_file("metadata.json")
	zip.write_file(JSON.stringify(meta, "  ").to_utf8_buffer())
	## (Godot 4.7: close() finaliza las entradas; finish_file() fue removido)

	zip.start_file("logs.txt")
	zip.write_file(_cola_de_logs().to_utf8_buffer())
	## (Godot 4.7: close() finaliza las entradas; finish_file() fue removido)

	var png := _capturar_png(vp)
	if not png.is_empty():
		zip.start_file("screenshot.png")
		zip.write_file(png)
		## (Godot 4.7: close() finaliza las entradas; finish_file() fue removido)

	zip.close()
	result["ok"] = true
	result["path"] = zip_path

	var txt_path := _escribir_txt(zip_path, meta, lineas_consola)
	result["txt_path"] = txt_path
	if txt_path.is_empty():
		print("[M110] RF20 diag exportado (solo ZIP, .txt fallo): %s" % zip_path)
	else:
		print("[M110] RF20 diag exportado: %s + %s" % [zip_path, txt_path])
	return result


## Ruta absoluta del ZIP a crear. `user://` se globaliza porque en headless con
## `--path` relativo `DirAccess.open("user://")` devuelve null (medido, igual
## que en M107): ZIPPacker necesita la ruta real del sistema.
static func _ruta_zip() -> String:
	var timestamp := Time.get_datetime_string_from_system().replace(":", "").replace("-", "").replace(" ", "_")
	return ProjectSettings.globalize_path(DIR_DIAG + "/diag_%s.zip" % timestamp)


## Ultimas MAX_LINEAS_LOG lineas de `user://output.txt`, o un aviso si no hay.
static func _cola_de_logs() -> String:
	var log_path := "user://output.txt"
	if not FileAccess.file_exists(log_path):
		return "[M110] No output.txt disponible\n"
	var log_lines := FileAccess.get_file_as_string(log_path).split("\n")
	return "".join(log_lines.slice(-MAX_LINEAS_LOG))


## PNG del viewport, o Array vacio si no hay render (headless). El temporal se
## borra siempre, incluso si la lectura falla.
static func _capturar_png(vp: Viewport) -> PackedByteArray:
	if vp == null:
		return PackedByteArray()
	var textura := vp.get_texture()
	if textura == null:
		return PackedByteArray()
	var img := textura.get_image()
	# En headless no hay render: `get_image()` es null. Se omite el screenshot.
	if img == null:
		return PackedByteArray()
	var png_path := ProjectSettings.globalize_path(DIR_DIAG + "/" + NOMBRE_PNG)
	if img.save_png(png_path) != OK:
		return PackedByteArray()
	var datos := FileAccess.get_file_as_bytes(png_path)
	DirAccess.remove_absolute(png_path)
	return datos


## Version plana y legible del diagnostico. Devuelve "" si no se pudo escribir.
static func _escribir_txt(zip_path: String, meta: Dictionary, lineas_consola: Array) -> String:
	var txt_path := zip_path.replace(".zip", ".txt")
	var txt := "DIAGNOSTICO Isla Ancestral\n"
	txt += "Fecha: %s\n" % Time.get_datetime_string_from_system()
	txt += "Plataforma: %s\n" % OS.get_name()
	for k in meta:
		txt += "%s: %s\n" % [k, str(meta[k])]
	txt += "\n--- Console (%d lineas) ---\n" % lineas_consola.size()
	var planas: PackedStringArray = PackedStringArray()
	for l in lineas_consola:
		planas.append(String(l))
	txt += "\n".join(planas)
	# FIX (iter. atria-dawn): FileAccess.open puede devolver null si el
	# directorio se invalido entre la creacion del ZIP y esta escritura.
	var f := FileAccess.open(txt_path, FileAccess.WRITE)
	if f == null:
		return ""
	f.store_string(txt)
	f.close()
	return txt_path
