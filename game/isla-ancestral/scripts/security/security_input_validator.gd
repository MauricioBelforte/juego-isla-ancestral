# Modelo: agnes-3-flash (Sapiens AI)
# Plataforma: Kilo Code
# Fecha: 2026-09-16
#
# M106: Seguridad — SecurityInputValidator (helper reutilizable, V0 + headless).
# Implementa los métodos "InputValidator" que el diseño de 05-Checklist.md dejó `[ ]`
# ("función de validación reutilizable" / InputValidator: validate_string/int/float/email
# + sanitize). Lógica pura (RefCounted, sin class_name → vía preload §9.52), sin tocar el
# autoload `security_manager.gd` (bajo riesgo). El proyecto trata warnings GDScript como
# errores → tipos explícitos, sin inferencia `Variant`.
#
# Reusable por UI (M53), M87 (i18n), validadores de datos, etc.

extends RefCounted

var _re_control := RegEx.new()
var _re_email := RegEx.new()


func _init() -> void:
	# Control C0 (excepto \t 0x09, \n 0x0A, \r 0x0D) + DEL 0x7F.
	_re_control.compile("[\\x00-\\x08\\x0B\\x0C\\x0E-\\x1F\\x7F]+")
	_re_email.compile("^[A-Za-z0-9._%+\\-]+@[A-Za-z0-9.\\-]+\\.[A-Za-z]{2,}$")


## Sanitiza: trunca a `max_len` y elimina caracteres de control (XSS/inyección).
func sanitizar(s: String, max_len: int = 200) -> String:
	var out: String = s
	if out.length() > max_len:
		out = out.substr(0, max_len)
	if out.length() > 0:
		out = _re_control.sub(out, "", true)
	return out


## Valida longitud de string (sobre la versión sanitizada) dentro de [min, max].
func validar_string(s: String, min_len: int = 1, max_len: int = 200) -> bool:
	var n: int = sanitizar(s, max_len).length()
	return n >= min_len and n <= max_len


## Valida un entero dentro de [min, max] (acepta int, float entero o string numérico).
func validar_int(v: Variant, min_v: int, max_v: int) -> bool:
	var n: int = 0
	if typeof(v) == TYPE_INT:
		n = int(v)
	elif typeof(v) == TYPE_FLOAT:
		if float(v) != floorf(float(v)):
			return false
		n = int(v)
	else:
		var s: String = String(v)
		if s.is_empty() or not s.is_valid_int():
			return false
		n = int(s)
	return n >= min_v and n <= max_v


## Valida un flotante dentro de [min, max] (acepta float, int o string numérico).
func validar_float(v: Variant, min_v: float, max_v: float) -> bool:
	var f: float = 0.0
	if typeof(v) == TYPE_FLOAT:
		f = float(v)
	elif typeof(v) == TYPE_INT:
		f = float(int(v))
	else:
		var s: String = String(v)
		if s.is_empty() or not s.is_valid_float():
			return false
		f = float(s)
	return f >= min_v and f <= max_v


## Valida un email (regla simple, suficiente para saneamiento de inputs cozy single-player).
func validar_email(s: String) -> bool:
	var limpio: String = s.strip_edges().to_lower()
	if limpio.length() > 254:
		return false
	return _re_email.search(limpio) != null


## Valida que un valor pertenece a una lista permitida (enumeración data-driven).
func validar_enumeracion(v: Variant, permitidos: Array) -> bool:
	for p in permitidos:
		if p == v:
			return true
	return false
