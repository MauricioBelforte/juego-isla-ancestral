# Modelo: kimi-k3 (Moonshot AI)
# Plataforma: Kilo Code
# Fecha: 2026-09-19
#
# M106 T-006: Seguridad — Escáner de secrets hardcodeados en código fuente (RF2).
# Regla: NINGÚN secret (API key, token, password) debe estar en el código fuente.
# Este escáner recorre los .gd/.cfg/.json/.tscn/.tres bajo res:// y detecta patrones típicos
# de claves hardcodeadas. Headless-safe, lógica pura, reutilizable en CI (security_check).
# ⚠️ Sin class_name (pitfall §9.41): vía preload.

extends RefCounted

## Patrones por defecto (asignaciones de secrets a literales). Inyectables por `patrones_custom`.
const PATRONES_DEFAULT: Array = [
	"(?i)(api[_-]?key|secret|token|password|passwd|pwd)\\s*[:=]+\\s*[\"'][^\"']{6,}[\"']",
	"(?i)(aws|gcp|azure)[_-]?(access|secret)[_-]?key\\s*[:=]+\\s*[\"'][^\"']+[\"']",
	"AKIA[0-9A-Z]{16}",                              # AWS access key id
	"-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----",  # clave privada PEM
	"(?i)bearer\\s+[A-Za-z0-9\\-._~+/]{10,}",        # bearer token
]

var _regexes: Array = []

## patrones_custom: Array de strings regex para sumar/reemplazar los default (testeable).
func _init(patrones_custom: Array = []) -> void:
	var patrones: Array = patrones_custom if not patrones_custom.is_empty() else PATRONES_DEFAULT
	for p in patrones:
		var re := RegEx.new()
		if re.compile(str(p)) == OK:
			_regexes.append(re)

## Escanea un texto fuente y devuelve Array de hallazgos:
## [{"linea": int, "patron": int, "fragmento": String}] (fragmento truncado, sin el secret).
func escanear_texto(contenido: String) -> Array:
	var hallazgos: Array = []
	var lineas := contenido.split("\n")
	for i in lineas.size():
		var linea: String = lineas[i]
		# ignorar comentarios de GDScript puros y placeholders explícitos
		var limpia := linea.strip_edges()
		if limpia.begins_with("#"):
			continue
		if _es_placeholder(linea):
			continue
		for pi in _regexes.size():
			var re: RegEx = _regexes[pi]
			var m := re.search(linea)
			if m != null:
				hallazgos.append({
					"linea": i + 1,
					"patron": pi,
					"fragmento": _fragmento_seguro(linea),
				})
	return hallazgos

## Escanea un archivo. Devuelve [] si no existe o no hay hallazgos.
func escanear_archivo(ruta: String) -> Array:
	if not FileAccess.file_exists(ruta):
		return []
	return escanear_texto(FileAccess.get_file_as_string(ruta))

## Escanea recursivamente un directorio (extensiones de código/config). Devuelve
## Dictionary {ruta: Array[hallazgos]} solo para archivos CON hallazgos.
func escanear_directorio(dir_raiz: String) -> Dictionary:
	var resultado: Dictionary = {}
	_escanear_dir_rec(dir_raiz, resultado)
	return resultado

func _escanear_dir_rec(ruta_dir: String, resultado: Dictionary) -> void:
	var dir := _abrir_dir(ruta_dir)
	if dir == null:
		return
	dir.list_dir_begin()
	var nombre := dir.get_next()
	while nombre != "":
		if nombre == "." or nombre == ".." or nombre.begins_with("."):
			nombre = dir.get_next()
			continue
		var ruta := "%s/%s" % [ruta_dir, nombre]
		if dir.current_is_dir():
			_escanear_dir_rec(ruta, resultado)
		elif _es_escaneable(nombre):
			var hallazgos := escanear_archivo(ruta)
			if not hallazgos.is_empty():
				resultado[ruta] = hallazgos
		nombre = dir.get_next()
	dir.list_dir_end()

## Apertura TOLERANTE de directorio (pitfall §9.6 / trampa 6): en headless con `--path` relativo,
## `DirAccess.open("user://…")` devuelve null EN SILENCIO. Reintenta con la ruta globalizada.
## (Fix P-36/DeepSeek: sin esto, `escanear_directorio("user://…")` devolvía {} y el test
## `directorio reporta solo archivo malo` quedaba en rojo.)
func _abrir_dir(ruta: String) -> DirAccess:
	var dir := DirAccess.open(ruta)
	if dir != null:
		return dir
	var abs := ProjectSettings.globalize_path(ruta)
	if not abs.is_absolute_path():
		abs = ProjectSettings.globalize_path("res://").path_join(abs.trim_prefix("./"))
	return DirAccess.open(abs)

func _es_escaneable(nombre: String) -> bool:
	var ext := nombre.get_extension().to_lower()
	return ext in ["gd", "cfg", "json", "tscn", "tres", "cs", "py", "env"]

## Placeholders legítimos que NO son secrets (valores de ejemplo/plantilla).
func _es_placeholder(linea: String) -> bool:
	var l := linea.to_lower()
	return l.contains("your_") or l.contains("changeme") or l.contains("example") \
		or l.contains("placeholder") or l.contains("xxx") or l.contains("todo") \
		or l.contains("<") or l.contains("env.") or l.contains("getenv") \
		or l.contains("os.get_environment") or l.contains("environment")

## Fragmento seguro para el log: la línea truncada SIN exponer el valor del secret.
func _fragmento_seguro(linea: String) -> String:
	var s := linea.strip_edges()
	# cortar antes del valor tras ':' o '=' para no exponer el secret
	var corte := s.length()
	var idx_eq := s.find("=")
	var idx_dp := s.find(":")
	if idx_eq > 0:
		corte = mini(corte, idx_eq + 1)
	if idx_dp > 0:
		corte = mini(corte, idx_dp + 1)
	var prefijo := s.substr(0, mini(corte, 40))
	return prefijo + "***REDACTED***"

## Resumen legible para logs/CI.
func resumen(resultado: Dictionary) -> String:
	var total: int = 0
	for ruta in resultado:
		total += resultado[ruta].size()
	return "%d archivo(s) con secrets, %d hallazgo(s)" % [resultado.size(), total]
