# Modelo: GLM-5.3
# Plataforma: Kilo Code
# Fecha: 2026-09-10
#
# M13 iter 4: ToolsSaveProvider — persistencia del hotbar de herramientas
# del jugador en M59 (ítem D.12 del 05-Checklist / T-019 del backlog).
# Serializa cada ToolData del hotbar con ToolData.serializar() (que ya existía
# desde la Fase 3) + índice activo. Restauración vía ToolData.deserializar().
#
# Diseño (AGENTS.md §15 — flujo separado, no toca player.gd más que el
# registro): el player crea ESTE provider y lo registra en SaveManager; el
# provider expone hotbar_ref (Array[ToolData] del player) e índice activo.
# Formato versionado (§O.4 patrón M15): {"version": 1, "activa": int,
# "herramientas": [{tipo, nivel, durabilidad, afilada, templada, potenciada}]}

class_name ToolsSaveProvider
extends RefCounted

const SECCION_SAVE := "herramientas_m13"

## Referencia al hotbar del player (Array[ToolData]). No tipado estricto
## para evitar dependencia de compilación con player.gd (duck-typing).
var hotbar_ref = null

## Función del player que devuelve el índice activo (callable: () -> int).
var get_indice_activo: Callable = Callable()

## Función del player que equipa un índice (callable: (int) -> void).
var set_indice_activo: Callable = Callable()

## Función del player que reemplaza el hotbar restaurado
## (callable: (Array[ToolData]) -> void).
var set_hotbar: Callable = Callable()

func _init(p_hotbar_ref = null, p_get_indice: Callable = Callable(), p_set_indice: Callable = Callable(), p_set_hotbar: Callable = Callable()) -> void:
	hotbar_ref = p_hotbar_ref
	get_indice_activo = p_get_indice
	set_indice_activo = p_set_indice
	set_hotbar = p_set_hotbar

func get_section_name() -> String:
	return SECCION_SAVE

func get_save_data() -> Dictionary:
	var herramientas: Array = []
	if hotbar_ref != null:
		for tool in hotbar_ref:
			if tool == null:
				herramientas.append({})
				continue
			herramientas.append(tool.serializar())
	var activa: int = 0
	if get_indice_activo.is_valid():
		activa = int(get_indice_activo.call())
	return {
		"version": 1,
		"activa": activa,
		"herramientas": herramientas,
	}

func restore_save_data(data: Dictionary) -> void:
	if int(data.get("version", 0)) < 1:
		return
	var herramientas: Array = data.get("herramientas", [])
	if herramientas.is_empty():
		return  # sin datos: no pisar el hotbar por defecto
	var restauradas: Array[ToolData] = []
	for hd in herramientas:
		if hd == null or hd.is_empty() or not hd is Dictionary:
			restauradas.append(null)
			continue
		restauradas.append(ToolData.deserializar(hd))
	if set_hotbar.is_valid():
		set_hotbar.call(restauradas)
		var activa: int = clampi(int(data.get("activa", 0)), 0, restauradas.size() - 1)
		if set_indice_activo.is_valid():
			set_indice_activo.call(activa)
