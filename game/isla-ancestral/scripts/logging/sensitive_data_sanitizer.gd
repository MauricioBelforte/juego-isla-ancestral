# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-29
#
# M103: Logging — SensitiveDataSanitizer (privacidad RFC14/RNF4).
# Mascara rutas absolutas del usuario (c:\Users\<nombre> → %USERPROFILE%),
# IPs privadas/públicas (mascara todos los octetos menos el 1º),
# y rastros de tokens/claves (patrones tipo token=..., apikey=...).
# Godot 4.7.

class_name SensitiveDataSanitizer
extends Object

const REDACTED := "[REDACTED]"

## Sanitiza un string: máscara de IPs, tokens, claves y rutas de usuario.
static func sanitize_string(input: String) -> String:
	if input.is_empty():
		return input
	var out := input
	out = _sanitize_ip(out)
	out = _sanitize_tokens(out)
	out = _sanitize_userpath(out)
	return out

## Sanitiza un Dictionary de contexto (claves y valores sensibles).
static func sanitize_context(ctx: Dictionary) -> Dictionary:
	var out := {}
	for k in ctx:
		var key := str(k)
		var lk := key.to_lower()
		if _es_sensible(lk):
			out[k] = REDACTED
		else:
			var v = ctx[k]
			if typeof(v) == TYPE_DICTIONARY:
				out[k] = sanitize_context(v)
			elif typeof(v) == TYPE_STRING:
				out[k] = sanitize_string(v)
			else:
				out[k] = v
	return out

## Claves de contexto que se consideran sensibles.
static func _es_sensible(lkey: String) -> bool:
	return lkey.contains("password") or lkey.contains("pass") \
		or lkey.contains("token") or lkey.contains("secret") \
		or lkey.contains("apikey") or lkey.contains("api_key") \
		or lkey.contains("auth") or lkey.contains("credential")

## Máscara IP: deja el primer octeto, redacta el resto. Soporta IPv4 e IPv6 simple.
static func _sanitize_ip(s: String) -> String:
	var out := s
	# IPv4: nnn.nnn.nnn.nnn (con o sin puerto)
	var r := RegEx.new()
	r.compile("(\\d{1,3})\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}(?:\\s*:\\s*\\d+)?")
	out = r.sub(out, "$1." + REDACTED.repeat(2) + REDACTED, true)
	# IPv6 heuristico (grupos hex) — simple.
	var r6 := RegEx.new()
	r6.compile("([0-9a-fA-F]{1,4}:){2,}[0-9a-fA-F]{0,4}")
	out = r6.sub(out, REDACTED, true)
	return out

## Máscara tokens/claves: detecta `clave=valor` para claves conocidas y `bearer <x>`.
static func _sanitize_tokens(s: String) -> String:
	var out := s
	var r := RegEx.new()
	r.compile("(?i)(token|apikey|api_key|password|passwd|secret|access[_-]?token)\\s*[=:]\\s*[^\\s\\]},]+")
	out = r.sub(out, "$1=" + REDACTED, true)
	var rb := RegEx.new()
	rb.compile("(?i)bearer\\s+[A-Za-z0-9._:\\-]+")
	out = rb.sub(out, "Bearer " + REDACTED, true)
	return out

## Redacta rutas del usuario (Windows: C:\Users\<nombre>) y del home.
static func _sanitize_userpath(s: String) -> String:
	var out := s
	var r := RegEx.new()
	r.compile("(?i)[a-z]:\\\\users\\\\[a-z0-9._\\-]+")
	out = r.sub(out, "%USERPROFILE%", true)
	var r2 := RegEx.new()
	r2.compile("(?i)home/[a-z0-9._\\-]+")
	out = r2.sub(out, "~/", true)
	return out