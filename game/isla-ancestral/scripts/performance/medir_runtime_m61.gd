# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-28
#
# M61 (Rendimiento) — SONDA DE MEDICION DE RUNTIME (headless).
#
# POR QUE EXISTE
# -------------
# `validate_budget.gd` valida una `medicion` contra `data/performance/budgets.json`, pero
# NO existia ningun productor de esa medicion en el repo: el unico llamador era el propio
# validador con un diccionario escrito a mano. Y el `[?]` L221 del 05-Checklist declara
# "no medible en headless" sin haberlo probado metrica por metrica.
#
# Esta sonda arranca la escena real, muestrea N frames y produce una `medicion` con las
# claves que SI se pueden medir headless, declarando explicitamente las que no. No
# aprueba el modulo: informa cobertura y veredicto del subconjunto medible.
#
# CALIBRACION (anti-falso-verde, medida en la propia corrida)
# -----------------------------------------------------------
# Antes de agregar la escena se leen los contadores; despues de N frames se vuelven a
# leer. Si el conteo de nodos CRECIO y `draw_calls` siguio en 0, queda PROBADO en esta
# corrida que el contador de render esta muerto headless: la sonda lo declara CIEGO en
# lugar de reportar un 0 que parece "sin draw calls".
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://scripts/performance/medir_runtime_m61.gd
#
# Exit: 0 = subconjunto medible dentro de limites (cobertura informada)
#       1 = una clave medible excede su limite
#       3 = CIEGO (no se midio nada / no se pudo arrancar la escena)

extends SceneTree

const MedicionM61 = preload("res://scripts/performance/medicion_runtime_m61.gd")

const RUTA_BUDGETS := "res://data/performance/budgets.json"
const ESCENA := "res://scenes/main_island.tscn"
const RUTA_SALIDA := "res://out/medicion_m61.json"

## Frames a muestrear y tope de reloj (watchdog anti-cuelgue).
const MAX_FRAMES: int = 90
const TOPE_RELOJ_MS: int = 30000
## Cada cuantos frames se toma muestra (1 = todos).
const CADA_FRAMES: int = 1

var _frames: int = 0
var _max_nodos: float = 0.0
var _max_objetos: float = 0.0
var _max_particulas: int = 0
var _max_emisores: int = 0
var _max_emitiendo: int = 0
var _max_draw_calls: float = 0.0
var _max_primitivas: float = 0.0
var _max_memoria_mb: float = 0.0
var _max_frame_ms: float = 0.0
var _muestras: int = 0

var _nodos_antes: float = 0.0
var _draw_antes: float = 0.0


func _initialize() -> void:
	call_deferred("_correr")


## Suma de particulas vivas (CPU + GPU) del subarbol, ponderada por `amount_ratio`.
## Devuelve {"particulas": int, "emisores": int, "emitiendo": int}. Los dos ultimos
## hacen INTERPRETABLE un 0: "0 particulas con 0 emisores en el arbol" es un contador
## ciego, no una escena limpia.
func _particulas_de(nodo: Node) -> Dictionary:
	var particulas := 0
	var emisores := 0
	var emitiendo := 0
	if nodo is CPUParticles3D:
		var cpu: CPUParticles3D = nodo
		emisores += 1
		if cpu.emitting and cpu.is_visible_in_tree():
			emitiendo += 1
			particulas += int(round(float(cpu.amount) * clampf(cpu.amount_ratio, 0.0, 1.0)))
	elif nodo is GPUParticles3D:
		var gpu: GPUParticles3D = nodo
		emisores += 1
		if gpu.emitting and gpu.is_visible_in_tree():
			emitiendo += 1
			particulas += int(round(float(gpu.amount) * clampf(gpu.amount_ratio, 0.0, 1.0)))
	for hijo in nodo.get_children():
		var sub: Dictionary = _particulas_de(hijo)
		particulas += int(sub["particulas"])
		emisores += int(sub["emisores"])
		emitiendo += int(sub["emitiendo"])
	return {"particulas": particulas, "emisores": emisores, "emitiendo": emitiendo}


func _contar_nodos3d(nodo: Node) -> int:
	var n := 1 if nodo is Node3D else 0
	for hijo in nodo.get_children():
		n += _contar_nodos3d(hijo)
	return n


func _muestrear(escena: Node) -> void:
	_max_nodos = maxf(_max_nodos, Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	_max_objetos = maxf(_max_objetos, Performance.get_monitor(Performance.OBJECT_COUNT))
	_max_draw_calls = maxf(_max_draw_calls, Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	_max_primitivas = maxf(_max_primitivas, Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
	_max_memoria_mb = maxf(_max_memoria_mb, Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0)
	_max_frame_ms = maxf(_max_frame_ms, Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0)
	var part: Dictionary = _particulas_de(escena)
	_max_particulas = maxi(_max_particulas, int(part["particulas"]))
	_max_emisores = maxi(_max_emisores, int(part["emisores"]))
	_max_emitiendo = maxi(_max_emitiendo, int(part["emitiendo"]))
	_muestras += 1


func _leer_limites() -> Dictionary:
	var f := FileAccess.open(RUTA_BUDGETS, FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if not (parsed is Dictionary):
		return {}
	var data: Dictionary = parsed
	var l: Variant = data.get("limites", {})
	if not (l is Dictionary):
		return {}
	return l


func _escribir_json(medicion: Dictionary, extra: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://out"))
	var payload: Dictionary = {
		"version": 1,
		"fecha": Time.get_datetime_string_from_system(),
		"escena": ESCENA,
		"frames_muestreados": _muestras,
		"medicion": medicion,
	}
	for k in extra:
		payload[String(k)] = extra[k]
	var f := FileAccess.open(RUTA_SALIDA, FileAccess.WRITE)
	if f == null:
		print("[PROBE] AVISO: no se pudo escribir %s" % RUTA_SALIDA)
		return
	f.store_string(JSON.stringify(payload, "  ", true) + "\n")
	f.close()
	print("[PROBE] medicion escrita en %s" % RUTA_SALIDA)


func _correr() -> void:
	print("=== PROBE RUNTIME M61 (rendimiento, headless) ===")
	var cls = MedicionM61.new()
	var limites := _leer_limites()
	if limites.is_empty():
		print("[PROBE] CIEGO: no se pudo leer `limites` de %s" % RUTA_BUDGETS)
		quit(3)
		return

	# ── calibracion ANTES de agregar la escena ──
	_nodos_antes = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	_draw_antes = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)

	var ps: Resource = load(ESCENA)
	if ps == null:
		print("[PROBE] CIEGO: no se pudo cargar %s" % ESCENA)
		quit(3)
		return
	var escena: Node = (ps as PackedScene).instantiate()
	if escena == null:
		print("[PROBE] CIEGO: la escena no instancio")
		quit(3)
		return
	root.add_child(escena)
	print("[PROBE] escena arrancada: %s" % ESCENA)

	var t0 := Time.get_ticks_msec()
	while _frames < MAX_FRAMES:
		await process_frame
		_frames += 1
		if _frames % CADA_FRAMES == 0:
			_muestrear(escena)
		if Time.get_ticks_msec() - t0 > TOPE_RELOJ_MS:
			print("[PROBE] watchdog: corte a los %d ms (%d frames)" % [TOPE_RELOJ_MS, _frames])
			break

	var nodos_final: float = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	var draw_final: float = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var nodos3d := _contar_nodos3d(escena)
	print("[PROBE] frames=%d muestras=%d | nodos: %.0f -> %.0f (delta %.0f) | nodos3d en escena: %d"
		% [_frames, _muestras, _nodos_antes, nodos_final, nodos_final - _nodos_antes, nodos3d])
	print("[PROBE] draw_calls: %.0f -> %.0f | primitivas: %.0f"
		% [_draw_antes, draw_final, _max_primitivas])

	# ── veredicto de calibracion del contador de render ──
	var contador_render_vivo := _max_draw_calls > 0.0
	print("[PROBE] calibracion: contador de draw_calls VIVO en headless = %s"
		% ("SI" if contador_render_vivo else "NO (renderer dummy)"))

	# ── medicion: solo claves que el mapa declara medibles ──
	# `objetos_mundo_max` (1000) es un limite de OBJETOS DEL MUNDO, no de nodos del engine.
	# MEDIDO en la 1.a corrida (Log 2232): usar `OBJECT_NODE_COUNT` (2417, incluye UI y
	# autoloads) daba un VIOLA FALSO contra 1000; el arbol de la escena del mundo tiene
	# 541 Node3D. Se usa ese proxy y se DECLARA en el informe.
	var medicion: Dictionary = {
		"objetos_mundo": nodos3d,
		"nodos": int(round(_max_nodos)),
		"particulas_simultaneas": _max_particulas,
	}
	print("[PROBE] proxy declarado: objetos_mundo = Node3D del arbol de la escena (%d); "
		% nodos3d + "nodos = OBJECT_NODE_COUNT del engine (%d, incluye UI y autoloads)"
		% int(round(_max_nodos)))
	print("[PROBE] emisores de particulas: %d detectados, %d emitiendo, %d particulas"
		% [_max_emisores, _max_emitiendo, _max_particulas])
	# `draw_calls` se incluye SIEMPRE, pero el clasificador lo marca CIEGO_HEADLESS:
	# asi el informe muestra el 0 medido como ciego, no como "cero draw calls".
	medicion["draw_calls"] = int(round(_max_draw_calls))

	print("[PROBE] medicion: %s" % JSON.stringify(medicion))
	print(cls.informe(limites, medicion))

	var veredicto: int = cls.veredicto(limites, medicion)
	if veredicto == 3:
		print("[PROBE] CIEGO: la medicion quedo vacia (nada medible con valor != 0)")
	elif veredicto == 1:
		print("[PROBE] VIOLA: una clave medible excede su limite")
	else:
		print("[PROBE] OK PARCIAL: el subconjunto MEDIBLE esta dentro de limites "
			+ "(cobertura %.0f%%; NO cierra el gate M61)" % (cls.cobertura(medicion) * 100.0))

	_escribir_json(medicion, {
		"cobertura": cls.cobertura(medicion),
		"veredicto": veredicto,
		"contador_render_vivo_headless": contador_render_vivo,
		"nodos3d_escena": nodos3d,
		"nodos_engine_total": int(round(_max_nodos)),
		"emisores_detectados": _max_emisores,
		"emisores_emitiendo": _max_emitiendo,
		"frame_ms_headless_dato": snappedf(_max_frame_ms, 0.001),
		"ciegas_headless": cls.claves_en(cls.CIEGO_HEADLESS),
		"ciegas_sin_instrumentar": cls.claves_en(cls.CIEGO_SIN_INSTRUMENTAR),
	})
	print("=== FIN PROBE M61: exit %d ===" % veredicto)
	quit(veredicto)
