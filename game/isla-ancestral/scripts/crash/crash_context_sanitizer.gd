# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-25
#
# M122: Crash Reporting — ContextSanitizer (helper reutilizable, offline/headless).
# Implementa el servicio "ContextSanitizer" del diseño (03-Diseno.md §4), que quedó `[ ]`:
#   sanitize        -> sanitizar
#   _is_unsafe_key  -> es_clave_insegura
#   unsafe_keys     -> CLAVES_INSEGURAS
# RefCounted sin `class_name` (preload). Lógica pura: no toca el árbol ni el autoload.
#
# Mejora sobre el diseño (documentada en 04-Codigo.md §15): la sanitización es RECURSIVA.
# El diseño era superficial — un sub-diccionario `{"player": {"email": "..."}}` pasaba entero
# porque la clave `player` no es insegura. Con recursión, el `email` anidado también se elimina.
#
# Contrato de `es_clave_insegura`: comparación por SUBCADENA en minúsculas (igual que el diseño),
# así `user_email`, `EMAIL` o `ip_address` caen todos.

extends RefCounted

## Claves NO seguras (diseño 03-Diseno.md §4). Se comparan por subcadena, case-insensitive.
const CLAVES_INSEGURAS: Array[String] = [
	"username", "ip", "email", "phone", "address", "inventory", "chat", "api_key", "token",
]


## Quita las claves inseguras del contexto, recursivamente. Devuelve un diccionario NUEVO
## (no muta la entrada).
func sanitizar(contexto: Dictionary) -> Dictionary:
	var salida: Dictionary = {}
	for clave in contexto.keys():
		var k := str(clave)
		if es_clave_insegura(k):
			continue
		var valor: Variant = contexto[clave]
		if typeof(valor) == TYPE_DICTIONARY:
			var sub: Dictionary = valor
			salida[clave] = sanitizar(sub)
		elif typeof(valor) == TYPE_ARRAY:
			salida[clave] = _sanitizar_array(valor)
		else:
			salida[clave] = valor
	return salida


## ¿La clave es insegura? Subcadena en minúsculas.
func es_clave_insegura(clave: String) -> bool:
	var k := clave.to_lower()
	for insegura in CLAVES_INSEGURAS:
		if k.contains(insegura):
			return true
	return false


## Rutas de las claves removidas (auditoría y test de opt-out). Formato `padre.hijo`.
func claves_removidas(contexto: Dictionary, prefijo: String = "") -> Array[String]:
	var out: Array[String] = []
	for clave in contexto.keys():
		var k := str(clave)
		var ruta := k if prefijo.is_empty() else "%s.%s" % [prefijo, k]
		if es_clave_insegura(k):
			out.append(ruta)
			continue
		var valor: Variant = contexto[clave]
		if typeof(valor) == TYPE_DICTIONARY:
			var sub: Dictionary = valor
			out.append_array(claves_removidas(sub, ruta))
	return out


## ¿El contexto está limpio (no tiene ninguna clave insegura, ni anidada)?
func es_contexto_seguro(contexto: Dictionary) -> bool:
	return claves_removidas(contexto).is_empty()


func _sanitizar_array(valor: Variant) -> Array:
	var out: Array = []
	var arr: Array = valor
	for item in arr:
		if typeof(item) == TYPE_DICTIONARY:
			var sub: Dictionary = item
			out.append(sanitizar(sub))
		else:
			out.append(item)
	return out
