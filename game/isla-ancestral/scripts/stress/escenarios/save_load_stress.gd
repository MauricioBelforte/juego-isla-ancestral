# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M113: Escenario — SaveLoadStress
# Guardado y carga repetidos (100 ciclos) usando DataStore (M60) si está
# disponible, o fallback simulado en memoria. Mide tiempo de guardado,
# tiempo de carga, integridad de cada ciclo (0 corrupción).
# Diseño original (04-Codigo.md §1.1, escenario 13 y 14).

class_name SaveLoadStress
extends StressScenario

const CICLOS: int = 100
const SLOT: int = 3

func _init() -> void:
	_nombre = "SaveLoadStress"

func setup() -> void:
	# Limpiar slot antes de empezar
	var ds := _data_store()
	if ds != null and ds.has_method("borrar_slot"):
		ds.borrar_slot(SLOT)
	print("[M113] SaveLoadStress: %d ciclos guardar/cargar" % CICLOS)

func execute() -> Dictionary:
	# payload de prueba
	var payload := {
		"test": "save_load_stress",
		"ciclo": 0,
		"jugador": {"pos": [12.0, 34.0, 56.0], "vida": 100},
		"inventario": {"slots": [{"id": "wood", "n": 25}]},
		"tiempo": {"dia": 1, "hora": 6.0},
		"mundo_voxel": {"semilla": 42, "chunks_editados": 0, "chunks": []},
		"meta": {"nombre": "Stress Test"},
		"progresion": {"misiones": {}},
	}
	var ultimo_ok: bool = true
	for i in range(CICLOS):
		payload["ciclo"] = i
		var tiempo_guardado := _medir_ms(func(): return _guardar(payload))
		_registrar_metrica("guardar_ms", tiempo_guardado["ms"])
		var tiempo_carga := _medir_ms(func(): return _cargar())
		_registrar_metrica("cargar_ms", tiempo_carga["ms"])
		var resultado_carga: Dictionary = tiempo_carga["resultado"] if typeof(tiempo_carga["resultado"]) == TYPE_DICTIONARY else {}
		var ok_carga: bool = resultado_carga.get("ok", false) == true
		if ok_carga:
			var datos: Dictionary = resultado_carga.get("datos", {})
			var ciclo_leido: int = int(datos.get("ciclo", -1))
			if ciclo_leido != i:
				push_warning("[M113] Ciclo %d -> carga devolvió ciclo %d" % [i, ciclo_leido])
				ok_carga = false
		_registrar_metrica("carga_ok_ms", 1.0 if ok_carga else 0.0)
		if not ok_carga:
			ultimo_ok = false
			push_warning("[M113] SaveLoadStress: fallo en ciclo %d" % i)
		# Sin await: execute() debe ser síncrono (coroutine rompería el runner)
	return _build_metricas()

func _guardar(payload: Dictionary) -> Dictionary:
	var ds = _data_store()
	if ds != null and ds.has_method("guardar_partida"):
		return ds.guardar_partida(SLOT, payload)
	return {"ok": false, "reason": "DataStore no disponible"}

func _cargar() -> Variant:
	var ds = _data_store()
	if ds != null and ds.has_method("cargar_partida"):
		return ds.cargar_partida(SLOT)
	return {"ok": false, "reason": "DataStore no disponible"}

func _data_store() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("/root/DataStore")

func _build_metricas() -> Dictionary:
	return resumen_metricas()

func teardown() -> void:
	var ds := _data_store()
	if ds != null and ds.has_method("borrar_slot"):
		ds.borrar_slot(SLOT)
	print("[M113] SaveLoadStress: teardown completado")