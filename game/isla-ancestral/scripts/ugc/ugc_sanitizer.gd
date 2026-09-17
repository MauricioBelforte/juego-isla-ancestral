# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-15
#
# M124: Contenido Generado por Usuarios — UgcSanitizer
# Prepara el UGC antes de subirlo, sin depender de render (headless-safe):
#   - Fotos: redimensión 4K -> 2K con Image.resize() (CPU, no necesita viewport)
#            y verificación de formato soportado (jpg/webp).
#   - Blueprints: quita del *sobre* (metadatos) las claves que filtran el save
#            del jugador (coords, slot, ids de plataforma, email...).
#   - Compresión JSON (ZSTD) para blueprints/construcciones.
#
# ⚠️ Decisión de diseño (documentada y testeada): las claves de CONTENIDO
# (`piezas`, `bloques`, `partes`...) se copian TAL CUAL. Las posiciones de las
# piezas son relativas al blueprint y SON el contenido; las "coords del save" que
# hay que eliminar son las del sobre (dónde está el jugador / qué slot se usó).

class_name UgcSanitizer
extends RefCounted

# Claves del sobre que NUNCA deben viajar al servicio (exactas, case-insensitive).
const CLAVES_PROHIBIDAS := [
	"coords", "coordenadas", "posicion", "position", "posicion_jugador",
	"player_pos", "global_pos", "world_pos", "world_coords",
	"save_id", "save_slot", "slot", "partida",
	"uuid", "device_id", "platform_id", "steam_id", "cuenta",
	"email", "ip", "ip_address",
]

# Subcadenas: atrapan variantes (coords_jugador, world_coords_2, my_steam_id...).
const SUBCADENAS_PROHIBIDAS := [
	"coord", "posicion_jugador", "player_pos", "global_pos", "world_pos",
	"save_id", "steam_id", "platform_id", "device_id",
]

# Claves cuyo subárbol es CONTENIDO: se copia sin tocar (ver nota de arriba).
const CLAVES_CONTENIDO := [
	"piezas", "pieces", "bloques", "bloques_colocados", "partes", "items", "contenido",
]

const LADO_MAX_DEFECTO := 2048

# ---------------------------------------------------------------- Fotos

static func necesita_redimension(tam: Vector2i, lado_max: int = LADO_MAX_DEFECTO) -> bool:
	return maxi(tam.x, tam.y) > lado_max

static func factor_escala(tam: Vector2i, lado_max: int = LADO_MAX_DEFECTO) -> float:
	var lado := maxi(tam.x, tam.y)
	if lado <= 0 or lado <= lado_max:
		return 1.0
	return float(lado_max) / float(lado)

static func tamano_escalado(tam: Vector2i, lado_max: int = LADO_MAX_DEFECTO) -> Vector2i:
	var f := factor_escala(tam, lado_max)
	if f >= 1.0:
		return tam
	return Vector2i(maxi(1, int(round(float(tam.x) * f))), maxi(1, int(round(float(tam.y) * f))))

# Devuelve una Image nueva (no muta la original) ya acotada a `lado_max`.
static func redimensionar(img: Image, lado_max: int = LADO_MAX_DEFECTO) -> Image:
	if img == null:
		return null
	var nuevo := tamano_escalado(img.get_size(), lado_max)
	if nuevo == img.get_size():
		return img
	var copia := img.duplicate()
	copia.resize(nuevo.x, nuevo.y, Image.INTERPOLATE_LANCZOS)
	return copia

static func preparar_foto(img: Image, lado_max: int = LADO_MAX_DEFECTO) -> Dictionary:
	if img == null:
		return {"ok": false, "motivo": "imagen_nula", "imagen": null,
			"tamano_original": Vector2i.ZERO, "tamano_final": Vector2i.ZERO, "redimensionada": false}
	var original := img.get_size()
	var salida := redimensionar(img, lado_max)
	return {
		"ok": true,
		"motivo": "ok",
		"imagen": salida,
		"tamano_original": original,
		"tamano_final": salida.get_size(),
		"redimensionada": salida.get_size() != original,
	}

static func formato_de_ruta(ruta: String) -> String:
	var ext := ruta.get_extension().to_lower()
	return ext

# ---------------------------------------------------------------- Blueprints

static func _es_prohibida(clave: String) -> bool:
	var k := clave.strip_edges().to_lower()
	if CLAVES_PROHIBIDAS.has(k):
		return true
	for sub in SUBCADENAS_PROHIBIDAS:
		if k.contains(sub):
			return true
	return false

# Escanea SOLO el sobre (no entra en las claves de contenido).
static func claves_prohibidas_presentes(bp: Dictionary) -> Array:
	var encontradas: Array = []
	for k in bp.keys():
		var clave := str(k)
		var valor: Variant = bp[k]
		if CLAVES_CONTENIDO.has(clave.to_lower()):
			continue
		if _es_prohibida(clave):
			encontradas.append(clave)
			continue
		if typeof(valor) == TYPE_DICTIONARY:
			for sub in (valor as Dictionary).keys():
				if _es_prohibida(str(sub)):
					encontradas.append("%s.%s" % [clave, str(sub)])
	encontradas.sort()
	return encontradas

# `sanitizar_blueprint` devuelve {datos, eliminadas, limpio}. `limpio == true`
# significa que el sobre ya venía sin claves prohibidas.
static func sanitizar_blueprint(bp: Dictionary) -> Dictionary:
	var eliminadas: Array = []
	var limpio: Variant = _limpiar(bp, eliminadas, "")
	eliminadas.sort()
	return {"datos": limpio, "eliminadas": eliminadas, "limpio": eliminadas.is_empty()}

static func _limpiar(nodo: Variant, eliminadas: Array, prefijo: String) -> Variant:
	if typeof(nodo) == TYPE_DICTIONARY:
		var salida := {}
		for k in (nodo as Dictionary).keys():
			var clave := str(k)
			var camino := clave if prefijo.is_empty() else "%s.%s" % [prefijo, clave]
			if CLAVES_CONTENIDO.has(clave.to_lower()):
				salida[clave] = _copiar((nodo as Dictionary)[k])  # contenido: intacto
				continue
			if _es_prohibida(clave):
				eliminadas.append(camino)
				continue
			salida[clave] = _limpiar((nodo as Dictionary)[k], eliminadas, camino)
		return salida
	if typeof(nodo) == TYPE_ARRAY:
		var salida_a := []
		var i := 0
		for x in (nodo as Array):
			salida_a.append(_limpiar(x, eliminadas, "%s[%d]" % [prefijo, i]))
			i += 1
		return salida_a
	return nodo

static func _copiar(nodo: Variant) -> Variant:
	if typeof(nodo) == TYPE_DICTIONARY:
		return (nodo as Dictionary).duplicate(true)
	if typeof(nodo) == TYPE_ARRAY:
		return (nodo as Array).duplicate(true)
	return nodo

# ---------------------------------------------------------------- Compresión
# ⚠️ MEDIDO en Godot 4.7.2 (sonda, 2026-09-15): `PackedByteArray.compress()` +
# `.decompress()` NO cierran el ciclo. Con 33 B de JSON:
#   compress(ZSTD)    -> 42 B   y  decompress(true)        -> 1 B
#   compress(DEFLATE) -> 41 B   y  decompress(false, 33)   -> 0 B
#   compress()        -> 35 B   y  decompress(true)        -> 1 B
# y el motor tira `func_PackedByteArray_decompress (core/variant/variant_call.cpp)`.
# Además `decompress()` EXIGE el primer argumento (dynamic_size): sin él es un
# Parse Error, no un default.
# La vía que SÍ funciona (roundtrip verificado) es FileAccess.open_compressed
# con COMPRESSION_ZSTD. Todo el "comprimir" del módulo va por ahí.

static func json_compacto(datos: Dictionary) -> String:
	return JSON.stringify(datos)

static func bytes_de_json(datos: Dictionary) -> int:
	return json_compacto(datos).to_utf8_buffer().size()

static func comprimir_a_archivo(datos: Dictionary, ruta: String) -> bool:
	var f := FileAccess.open_compressed(ruta, FileAccess.WRITE, FileAccess.COMPRESSION_ZSTD)
	if f == null:
		return false
	f.store_string(json_compacto(datos))
	f.close()
	return true

static func leer_de_archivo(ruta: String) -> Dictionary:
	if not FileAccess.file_exists(ruta):
		return {}
	var g := FileAccess.open_compressed(ruta, FileAccess.READ, FileAccess.COMPRESSION_ZSTD)
	if g == null:
		return {}
	var txt := g.get_as_text()
	g.close()
	var parsed: Variant = JSON.parse_string(txt)
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed as Dictionary
	return {}

# Comprime a `ruta`, mide y borra. Devuelve -1 si no se pudo comprimir.
static func peso_archivo_comprimido(datos: Dictionary, ruta: String) -> int:
	if not comprimir_a_archivo(datos, ruta):
		return -1
	var n := FileAccess.get_file_as_bytes(ruta).size()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta))
	return n

static func descripcion() -> String:
	return "[M124] UgcSanitizer: fotos a %d px máx · sobre sin %d claves prohibidas · JSON ZSTD (FileAccess)" % [
		LADO_MAX_DEFECTO, CLAVES_PROHIBIDAS.size()]
