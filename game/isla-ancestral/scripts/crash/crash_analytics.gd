# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-25
#
# M122: Crash Reporting — CrashAnalytics (agrupación y frecuencia, helper headless).
# Cierra el ítem "Diseñar algoritmo de hashing de stack trace" del checklist y da soporte a
# CrashDashboard/CrashViewer del diseño (03-Diseno.md §1 y §7) sin depender de la UI.
# RefCounted sin `class_name` (preload). Lógica pura.
#
# Normalización ANTES de hashear (mejora propia, no está en el diseño): un mismo bug agrupa
# aunque cambien las direcciones de memoria o los números de línea entre builds. Se quitan
#   - tokens hexadecimales con prefijo `0x` (direcciones de memoria)
#   - el sufijo `:NNN` de número de línea
#   - líneas vacías y espacios sobrantes
# La huella es SHA-256 (`String.sha256_text()`, verificado contra el vector estándar "abc").
#
# ⚠️ Alcance: agrupa y cuenta. La frecuencia RELATIVA (0..1) se calcula sobre la muestra que se le
# pasa; el porcentaje real de usuarios afectados necesita el backend (M104/M118), no este helper.

extends RefCounted


## Huella estable del stack (SHA-256 hex del stack normalizado).
func huella_stack(stack: Variant) -> String:
	return normalizar_stack(stack).sha256_text()


## Stack normalizado (una línea por frame, sin direcciones ni números de línea).
func normalizar_stack(stack: Variant) -> String:
	var lineas := PackedStringArray()
	for item in _a_array(stack):
		var s := str(item).strip_edges()
		if s.is_empty():
			continue
		s = _sin_direcciones(s)
		s = _sin_numero_de_linea(s)
		s = s.strip_edges()
		if not s.is_empty():
			lineas.append(s)
	return "\n".join(lineas)


## Agrupa crashes por huella. Devuelve {huella: {huella, cantidad, crashes}}.
func agrupar(crashes: Array) -> Dictionary:
	var grupos: Dictionary = {}
	for item in crashes:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var d: Dictionary = item
		var h := huella_stack(d.get("stack", d.get("stack_trace", [])))
		if not grupos.has(h):
			grupos[h] = {"huella": h, "cantidad": 0, "crashes": []}
		var g: Dictionary = grupos[h]
		g["cantidad"] = int(g["cantidad"]) + 1
		var lista: Array = g["crashes"]
		lista.append(d)
	return grupos


## Frecuencia relativa (0..1) por huella, sobre el total de crashes de la muestra.
func frecuencias(crashes: Array) -> Dictionary:
	var grupos := agrupar(crashes)
	var total: int = 0
	for h in grupos.keys():
		var g: Dictionary = grupos[h]
		total += int(g["cantidad"])
	var out: Dictionary = {}
	for h in grupos.keys():
		var g: Dictionary = grupos[h]
		var cant := int(g["cantidad"])
		out[h] = 0.0 if total == 0 else float(cant) / float(total)
	return out


## Top-N grupos por cantidad (desc). Cada elemento: {huella, cantidad, frecuencia, crashes}.
func top(crashes: Array, n: int = 10) -> Array:
	var frecs := frecuencias(crashes)
	var grupos := agrupar(crashes)
	var lista: Array = []
	for h in grupos.keys():
		var g: Dictionary = grupos[h]
		lista.append({
			"huella": h,
			"cantidad": int(g["cantidad"]),
			"frecuencia": float(frecs.get(h, 0.0)),
			"crashes": g["crashes"],
		})
	lista.sort_custom(func(a, b): return int(a["cantidad"]) > int(b["cantidad"]))
	if n >= 0 and lista.size() > n:
		lista.resize(n)
	return lista


## Huellas de la muestra que NO están en `huellas_conocidas` (crashes nuevas).
func nuevas(crashes: Array, huellas_conocidas: Array) -> Array[String]:
	var conocidas: Dictionary = {}
	for h in huellas_conocidas:
		conocidas[str(h)] = true
	var out: Array[String] = []
	for h in agrupar(crashes).keys():
		if not conocidas.has(str(h)):
			out.append(str(h))
	return out


func _sin_direcciones(linea: String) -> String:
	var partes := PackedStringArray()
	for token in linea.split(" ", false):
		if token.begins_with("0x") or token.begins_with("0X"):
			continue
		partes.append(token)
	return " ".join(partes)


func _sin_numero_de_linea(linea: String) -> String:
	var idx := linea.rfind(":")
	if idx < 0 or idx == linea.length() - 1:
		return linea
	var sufijo := linea.substr(idx + 1)
	if sufijo.is_valid_int():
		return linea.substr(0, idx)
	return linea


func _a_array(stack: Variant) -> Array:
	if typeof(stack) == TYPE_ARRAY:
		var arr: Array = stack
		return arr
	if typeof(stack) == TYPE_STRING:
		return [stack]
	return []
