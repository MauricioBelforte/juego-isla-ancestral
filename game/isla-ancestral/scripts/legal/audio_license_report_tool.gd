# Modelo: Ling 3.1 Flash
# Plataforma: Kilo Code
# Fecha: 2026-10-11
#
# M84: Música y Audio Legal — AudioLicenseReportTool (L117)
# Tool de editor/build (NO runtime): genera el reporte de licencias de
# audio por build. Escanea los assets de audio usados, los cruza contra
# el inventario de data/legal/audio_licenses.json y escribe
# Builds/<plataforma>/LICENCIAS-AUDIO.md.
#
# Regla clave (encargo mimo-v2.6, msg 22 del canal Ling-3.1-Flash):
# TODO asset de audio del build aparece en el reporte. Si NO está en el
# inventario, se marca "SIN LICENCIA REGISTRADA" (nunca se omite) y se
# loguea push_warning en la consola del editor.
#
# @tool + class_name: invocable desde el editor (audio_license_report_editor.gd),
# desde el pipeline de build (M117) y headless (test_audio_license_report_m84.gd).
# Sin class_name que colisione con autoloads (GUIA-GODOT/INDICE.md 9.17/9.41).

@tool
class_name AudioLicenseReportTool
extends RefCounted

## Extensiones de audio escaneadas (música, SFX, ambiente).
const EXTENSIONES_AUDIO := [".ogg", ".wav", ".mp3", ".opus", ".flac", ".mid", ".it", ".xm"]

## Nombre del reporte dentro de la carpeta de build.
const NOMBRE_REPORTE := "LICENCIAS-AUDIO.md"


## --- Escaneo de assets ---


## Escanea recursivamente las raíces y devuelve las rutas de archivos de audio.
## Las raíces inexistentes se ignoran (no es error: el build puede no tener
## assets de audio todavía — el proyecto aún no los tiene en disco).
static func escanear_assets_audio(raices: Array[String]) -> Array[String]:
	var encontrados: Array[String] = []
	for raiz in raices:
		var ruta_abs := _absolutizar(raiz)
		if not DirAccess.dir_exists_absolute(ruta_abs):
			continue
		_encolar_audio_recursivo(ruta_abs, encontrados)
	encontrados.sort()
	return encontrados


static func _encolar_audio_recursivo(dir_path: String, salida: Array[String]) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	dir.list_dir_begin()
	var nombre := dir.get_next()
	while nombre != "":
		if nombre == "." or nombre == "..":
			nombre = dir.get_next()
			continue
		var ruta := dir_path.path_join(nombre)
		if dir.current_is_dir():
			_encolar_audio_recursivo(ruta, salida)
		elif _es_audio(nombre):
			salida.append(ruta)
		nombre = dir.get_next()
	dir.list_dir_end()


static func _es_audio(nombre_archivo: String) -> bool:
	var minusculas := nombre_archivo.to_lower()
	for ext in EXTENSIONES_AUDIO:
		if minusculas.ends_with(ext):
			return true
	return false


## "res://..." / "user://..." → ruta absoluta del sistema (DirAccess absoluto).
static func _absolutizar(ruta: String) -> String:
	if ruta.begins_with("res://") or ruta.begins_with("user://"):
		return ProjectSettings.globalize_path(ruta)
	return ruta


## --- Inventario ---


## Carga el inventario JSON (solo lectura — no se modifica).
## Devuelve {"tracks": [...], "error": ""}.
static func cargar_inventario(ruta_json: String) -> Dictionary:
	var resultado := {"tracks": [], "error": ""}
	var ruta_abs := _absolutizar(ruta_json)
	if not FileAccess.file_exists(ruta_abs):
		resultado["error"] = "Inventario no encontrado: %s" % ruta_json
		return resultado
	var texto := FileAccess.get_file_as_string(ruta_abs)
	var parsed: Variant = JSON.parse_string(texto)
	if typeof(parsed) != TYPE_DICTIONARY:
		resultado["error"] = "JSON de inventario inválido: %s" % ruta_json
		return resultado
	resultado["tracks"] = parsed.get("tracks", [])
	return resultado


## Índice por track_id (minúsculas) para matching O(1).
static func construir_indice(inventario: Dictionary) -> Dictionary:
	var indice := {}
	for t in inventario.get("tracks", []):
		var id_track := String(t.get("id", "")).to_lower()
		if not id_track.is_empty():
			indice[id_track] = t
	return indice


## --- Matching ---


## Busca el track del inventario para un archivo de audio.
## Estrategia (documentada): el stem del archivo (sin extensión, minúsculas)
## debe coincidir exactamente con el "id" del track en el inventario.
## Devuelve {} si no hay registro (→ SIN LICENCIA REGISTRADA).
static func buscar_track(archivo_ruta: String, indice: Dictionary) -> Dictionary:
	var stem := archivo_ruta.get_basename().get_file().to_lower()
	if indice.has(stem):
		return indice[stem]
	return {}


## --- Formato del reporte ---


## Tipo de licencia en la taxonomía del encargo:
## CC0 / CC-BY / CC-BY-SA / PROPIA / MIT / CC-BY-NC / OTRO.
static func formatear_tipo_licencia(licencia_str: String) -> String:
	match licencia_str.to_lower():
		"cc0": return "CC0 (dominio público)"
		"cc-by": return "CC-BY (atribución)"
		"cc-by-sa": return "CC-BY-SA (atribución-compartir igual)"
		"cc-by-nc": return "CC-BY-NC (NO COMERCIAL — RECHAZADA para builds comerciales)"
		"mit": return "MIT"
		"propia": return "PROPIA (del estudio)"
		_: return "OTRO (verificar)"


## Fuente derivada del inventario (el JSON no tiene campo "fuente" propio:
## para "propia" es el estudio; para stock/libre, el campo "autor" es la fuente).
static func _formatear_fuente(track: Dictionary) -> String:
	var licencia := String(track.get("licencia", "propia")).to_lower()
	if licencia == "propia":
		return "Composición original del estudio"
	var autor := String(track.get("autor", ""))
	return autor if not autor.is_empty() else "No registrada en el inventario"


## URL de origen derivada del campo "attribution" del inventario.
static func _formatear_url(track: Dictionary) -> String:
	var attribution := String(track.get("attribution", ""))
	return attribution if not attribution.is_empty() else "No registrada en el inventario"


## Genera el markdown del reporte (una sección por asset: nombre de archivo,
## tipo de licencia, autor, fuente y URL de origen — formato del encargo).
static func generar_reporte(assets: Array[String], indice: Dictionary, plataforma: String, ruta_inventario: String) -> String:
	var text := "# Reporte de Licencias de Audio — Build %s\n\n" % plataforma
	text += "Generado: %s\n" % Time.get_datetime_string_from_system()
	text += "Inventario fuente: `%s`\n" % ruta_inventario
	text += "Assets de audio en el build: %d\n\n" % assets.size()

	var con_licencia := 0
	var sin_licencia := 0
	for archivo in assets:
		var nombre := archivo.get_file()
		var track := buscar_track(archivo, indice)
		text += "## %s\n" % nombre
		if track.is_empty():
			sin_licencia += 1
			text += "- **Tipo de licencia:** SIN LICENCIA REGISTRADA\n"
			text += "- **Autor:** —\n"
			text += "- **Fuente:** —\n"
			text += "- **URL de origen:** —\n"
			text += "- **Estado:** ⚠️ asset de audio usado en el build SIN registro en el inventario de M84 — registrar en `data/legal/audio_licenses.json` antes del release\n"
		else:
			con_licencia += 1
			var licencia_str := String(track.get("licencia", "OTRO"))
			text += "- **Tipo de licencia:** %s\n" % formatear_tipo_licencia(licencia_str)
			text += "- **Autor:** %s\n" % String(track.get("autor", "—"))
			text += "- **Fuente:** %s\n" % _formatear_fuente(track)
			text += "- **URL de origen:** %s\n" % _formatear_url(track)
			var uso := String(track.get("uso", ""))
			if not uso.is_empty():
				text += "- **Uso:** %s\n" % uso
		text += "\n"

	text += "---\n\n"
	text += "**Resumen:** %d assets — %d con licencia registrada, %d SIN LICENCIA REGISTRADA.\n" % [assets.size(), con_licencia, sin_licencia]
	if sin_licencia > 0:
		text += "\n> ⚠️ **Este build contiene audio sin licencia registrada.** Corregir antes del release (política `registro_licencias_obligatorio` del inventario).\n"
	return text


## --- Orquestador (hook de build) ---


## Genera el reporte completo para un build: escanea → cruza → escribe
## `LICENCIAS-AUDIO.md` en `dir_salida` → push_warning por asset sin licencia.
## Devuelve resumen {"total", "con_licencia", "sin_licencia",
## "archivos_sin_licencia", "ruta_reporte", "error"}.
static func generar_reporte_build(plataforma: String, dir_salida: String, ruta_inventario: String, raices_audio: Array[String]) -> Dictionary:
	var resumen := {
		"total": 0, "con_licencia": 0, "sin_licencia": 0,
		"archivos_sin_licencia": [], "ruta_reporte": "", "error": "",
	}
	var inventario := cargar_inventario(ruta_inventario)
	if not String(inventario["error"]).is_empty():
		resumen["error"] = String(inventario["error"])
		return resumen
	var indice := construir_indice(inventario)
	var assets := escanear_assets_audio(raices_audio)
	var markdown := generar_reporte(assets, indice, plataforma, ruta_inventario)

	var dir_salida_abs := _absolutizar(dir_salida)
	DirAccess.make_dir_recursive_absolute(dir_salida_abs)
	var ruta_salida := dir_salida_abs.path_join(NOMBRE_REPORTE)
	var file := FileAccess.open(ruta_salida, FileAccess.WRITE)
	if file == null:
		resumen["error"] = "No se pudo escribir el reporte: %s" % ruta_salida
		return resumen
	file.store_string(markdown)
	file.close()
	resumen["ruta_reporte"] = ruta_salida

	# Conteos + warnings en consola del editor (requisito del encargo:
	# los assets sin licencia se loguean como warning, además del reporte).
	for archivo in assets:
		if buscar_track(archivo, indice).is_empty():
			resumen["sin_licencia"] += 1
			resumen["archivos_sin_licencia"].append(archivo.get_file())
			push_warning("[M84] SIN LICENCIA REGISTRADA: '%s' — asset de audio del build sin registro en %s" % [archivo.get_file(), ruta_inventario])
		else:
			resumen["con_licencia"] += 1
	resumen["total"] = assets.size()
	return resumen
