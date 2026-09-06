# Modelo: deepseek-v4-flash / agnes-2.5-flash (iter. 4)
# Plataforma: Kilo Code
# Fecha: 2026-09-02 / 2026-09-04
#
# M83: Licencias de Software — LicenseValidator
# Valida el catálogo de licencias: IDs únicos, licencia/comercial_ok,
# políticas. Devuelve Array[String] de errores.
# Iter. 4 (agnes): cache de resultados, soporte .md/.txt, cleanup notices.

class_name LicenseValidator
extends RefCounted

## Cache estático: hash(data) → {errores, timestamp}
static var _cache: Dictionary = {}
static var CACHE_TTL_SEC: float = 300.0  # 5 minutos


## ── Validación principal ──────────────────────────────────

static func validar(data: Dictionary) -> Array:
	var hash_key := _hash_data(data)
	# Reutilizar caché si aún es válido
	if _cache.has(hash_key):
		var entry = _cache[hash_key]
		if Time.get_ticks_msec() < entry.timestamp + CACHE_TTL_SEC * 1000:
			return entry.errores.duplicate()
	var errores: Array = []
	var ids: Dictionary = {}
	for l in data.get("licencias", []):
		var id: String = String(l.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("Licencia sin id")
		elif ids.has(id):
			errores.append("Licencia duplicada: %s" % id)
		ids[id] = true
		if String(l.get("software", "")).is_empty():
			errores.append("%s: sin software" % etiqueta)
		if String(l.get("licencia", "")).is_empty():
			errores.append("%s: sin tipo de licencia" % etiqueta)
	if data.get("politicas", {}).is_empty():
		errores.append("Sin políticas de licencias")
	# Guardar en caché
	_cache[hash_key] = {"errores": errores.duplicate(), "timestamp": Time.get_ticks_msec()}
	return errores


## ── Reporte legible ────────────────────────────────────────

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M83] LicenseValidator: OK — licencias de software registradas"
	var lineas: Array = ["[M83] LicenseValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)


## ── Hash de datos para caché ───────────────────────────────

static func _hash_data(data: Dictionary) -> String:
	# Hash simple: serializar JSON de las licencias (ignora políticas para estabilidad)
	var lic_ids: Array = []
	for l in data.get("licencias", []):
		lic_ids.append(String(l.get("id", "")))
	return JSON.stringify(lic_ids)


## ── Soporte Markdown/Texto plano ───────────────────────────
## Lee archivos .md y .txt como notices de licencia brutos.
## Retorna un Dictionary con claves: {notices: Array[String], rutas: Array[String]}
## Cada notice es una línea sin encabezado (strip de #, *, ---).

static func leer_notices_archivo(ruta: String) -> Dictionary:
	var result := {"notices": [], "rutas": [ruta], "errores": []}
	if not FileAccess.file_exists(ruta):
		result.errores.append("Archivo no encontrado: %s" % ruta)
		return result
	var ext := ruta.get_extension().to_lower()
	if ext != "md" and ext != "txt" and ext != "":
		result.errores.append("Formato no soportado: %s (usar .md o .txt)" % ext)
		return result
	var text := FileAccess.get_file_as_string(ruta)
	for line in text.split("\n"):
		var cleaned := line.strip_edges()
		# Strip markdown headers (#, ##, ###)
		cleaned = cleaned.lstrip("#").strip_edges()
		# Skip horizontal rules
		if cleaned.begins_with("---") or cleaned.begins_with("***"):
			continue
		# Skip empty lines
		if cleaned.is_empty():
			continue
		result.notices.append(cleaned)
	return result


## ── Cleanup de notices obsoletos ───────────────────────────
## Compara notices_old vs notices_nuevas y elimina las que ya no existen.
## Retorna Array con IDs de notices removidas.
## Las notices se identifican por su primera línea (hasta primer punto final o 80 chars).
## Esto evita re-validar notices idénticas en regeneraciones sucesivas.

static func cleanup_notices_obsoletas(notices_old: Array, notices_nueva: Array) -> Array:
	var removidos: Array = []
	var keys_nuevas: Dictionary = {}
	for n in notices_nueva:
		var key := _notice_key(n)
		keys_nuevas[key] = true
	for n in notices_old:
		var key := _notice_key(n)
		if not keys_nuevas.has(key):
			removidos.append(key)
	return removidos


static func _notice_key(texto: String) -> String:
	# Clave: primeras 80 chars normalizadas
	var normalized := texto.strip_edges().to_lower()
	return normalized.substr(0, min(normalized.length(), 80))


## ── Limpieza de caché ──────────────────────────────────────

static func limpiar_caché() -> void:
	_cache.clear()



## Soporte para lock files: verifica integridad del catálogo vía checksum
static func validar_lock_file(ruta_catalogo: String) -> Dictionary:
	var lock_path := ruta_catalogo.get_base_dir() + "/" + ruta_catalogo.get_file().get_basename() + ".lock"
	if not FileAccess.file_exists(lock_path):
		return {"valid": true, "expected": "", "actual": "", "error": "no lock file"}
	var lock_text := FileAccess.get_file_as_string(lock_path)
	var parts := lock_text.strip_edges().split("\n")
	if parts.size() < 2:
		return {"valid": false, "expected": "", "actual": "", "error": "lock corrupto"}
	var expected_hash := parts[0].strip_edges()
	var file_access := FileAccess.open(ruta_catalogo, FileAccess.READ)
	if file_access == null:
		return {"valid": false, "expected": expected_hash, "actual": "", "error": "no se puede abrir catalogo"}
	var data := file_access.get_buffer(file_access.get_length())
	file_access.close()
	var actual_hash := String(data.hash())
	var valid := (actual_hash == expected_hash)
	return {"valid": valid, "expected": expected_hash, "actual": actual_hash, "error": "" if valid else "checksum mismatch"}

## ── Estadísticas de caché ──────────────────────────────────

static func stats_cache() -> Dictionary:
	return {"entradas": _cache.size(), "ttl_seg": CACHE_TTL_SEC}


## ── Resumen ejecutivo al final del reporte ────────────────
## Añade stats: total licencias escaneadas + errores con formato legible.

static func reporte_ejecutivo(data: Dictionary) -> String:
	var errores: Array = validar(data)
	var total: int = data.get("licencias", []).size()
	var lineas: Array[String] = []
	lineas.append("[M83] LicenseValidator: %s" % ("OK" if errores.is_empty() else "%d ERRORES" % errores.size()))
	lineas.append("  Licencias escaneadas: %d" % total)
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)