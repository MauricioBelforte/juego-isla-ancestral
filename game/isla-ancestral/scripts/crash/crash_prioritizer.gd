# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-25
#
# M122: Crash Reporting — CrashPrioritizer (priorización y filtros, helper headless).
# Cierra los ítems "Definir niveles de impacto", "Definir prioridades (CRÍTICA/ALTA/MEDIA/BAJA)",
# "Diseñar filtros por severidad/impacto", "Diseñar ordenamiento por prioridad" y los filtros del
# dashboard (versión, plataforma, escena) del checklist. Soporte de CrashDashboard
# (03-Diseno.md §7 y §13) sin depender de la UI.
# RefCounted sin `class_name` (preload). Lógica pura.
#
# ⚠️ Huecos de la matriz del diseño (03-Diseno.md §13), resueltos por INTERPOLACIÓN y marcados:
# la tabla no cubre "Media (1-5 %) + Algunos" ni "Baja (<1 %) + Todos". Decisión documentada
# (04-Codigo.md §15):  Media+Algunos -> MEDIA (la severidad no cambia el impacto) y
# Baja+Todos -> MEDIA (más impacto que Baja+Algunos, menos que Media+Algunos... no: se mantiene
# MEDIA si es crash y BAJA si es hang, porque a baja frecuencia el impacto no la promueve).

extends RefCounted

const CRITICA := "CRÍTICA"
const ALTA := "ALTA"
const MEDIA := "MEDIA"
const BAJA := "BAJA"

## Orden de severidad para ordenar (menor = más urgente).
const ORDEN := {CRITICA: 0, ALTA: 1, MEDIA: 2, BAJA: 3}

const UMBRAL_ALTA := 0.05
const UMBRAL_MEDIA := 0.01


## Matriz de prioridad del diseño (03-Diseno.md §13).
## `frecuencia` 0..1 · `severidad` "crash"|"hang" · `impacto` "todos"|"algunos".
func prioridad(frecuencia: float, severidad: String, impacto: String) -> String:
	var sev := severidad.to_lower()
	var imp := impacto.to_lower()
	if frecuencia > UMBRAL_ALTA:
		return CRITICA if imp == "todos" else ALTA
	if frecuencia >= UMBRAL_MEDIA:
		return ALTA if imp == "todos" else MEDIA
	return MEDIA if sev == "crash" else BAJA


## Prioridad de un crash (usa sus campos, con las dos vocabularios).
func prioridad_de(datos: Dictionary) -> String:
	return prioridad(
		float(datos.get("frequency", datos.get("frecuencia", 0.0))),
		str(datos.get("severity", datos.get("severidad", "crash"))),
		str(datos.get("impact", datos.get("impacto", "algunos")))
	)


## Filtra crashes. Claves soportadas (todas opcionales): version, platform/plataforma,
## scene/escena, severity/severidad, impact/impacto, priority/prioridad.
## Devuelve un Array nuevo (no muta la entrada).
func filtrar(crashes: Array, filtros: Dictionary) -> Array:
	var out: Array = []
	for item in crashes:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var d: Dictionary = item
		if _coincide(d, filtros):
			out.append(d)
	return out


## Ordena por prioridad (CRÍTICA -> BAJA) y, a igual prioridad, por frecuencia descendente.
func ordenar(crashes: Array) -> Array:
	var out: Array = []
	for item in crashes:
		if typeof(item) == TYPE_DICTIONARY:
			out.append(item)
	out.sort_custom(func(a, b):
		var pa: int = int(ORDEN.get(prioridad_de(a), 9))
		var pb: int = int(ORDEN.get(prioridad_de(b), 9))
		if pa != pb:
			return pa < pb
		return float(a.get("frequency", a.get("frecuencia", 0.0))) > float(b.get("frequency", b.get("frecuencia", 0.0)))
	)
	return out


func _coincide(datos: Dictionary, filtros: Dictionary) -> bool:
	for clave in filtros.keys():
		var esperado: Variant = filtros[clave]
		var k := str(clave)
		if k == "priority" or k == "prioridad":
			if prioridad_de(datos) != str(esperado):
				return false
		elif k == "severity" or k == "severidad":
			if str(datos.get("severity", datos.get("severidad", "crash"))).to_lower() != str(esperado).to_lower():
				return false
		elif k == "impact" or k == "impacto":
			if str(datos.get("impact", datos.get("impacto", "algunos"))).to_lower() != str(esperado).to_lower():
				return false
		else:
			var valor: Variant = datos.get(k, datos.get(_alias(k), null))
			if valor == null or str(valor) != str(esperado):
				return false
	return true


func _alias(clave: String) -> String:
	match clave:
		"version":
			return "game_version"
		"platform":
			return "plataforma"
		"scene":
			return "escena"
		_:
			return clave
