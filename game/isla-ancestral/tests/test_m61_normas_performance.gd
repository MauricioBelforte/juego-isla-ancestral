# Modelo: minimax-m3-1-flash
# Plataforma: MiniMax API / Kilo Code
# Fecha: 2026-10-21
#
# M61 / Log 2068 — Gate de coherencia de la NORMA de rendimiento contra el
# runtime real. La norma de M61 vive data-driven en
# `data/performance/budgets.json` (bloques `normas`, `gpu`, `memoria`) y la
# verifica `scripts/performance/validate_budget.gd`. Este suite agrega lo que
# el gate NO puede saber por si solo: que los umbrales de la norma COINCIDAN
# con la configuracion real de los modulos duenos.
#
#   M90 (graphics_config.gd) -> presets de calidad: distancia, particulas,
#                              sombras (cascadas) y tope de FPS.
#   M114 (hardware_profile.gd) -> VRAM recomendada y disco requerido.
#   M62  (data/rendimiento/budgets.json) -> MB por preset (paquete de datos).
#   M51  (validate_water.gd) -> techo de overdraw ya establecido en el proyecto.
#   M46  (pack_atlas.gd) -> limite de atlas 2048x2048.
#
# Si un dueno cambia un preset y la norma no se actualiza, esto se pone ROJO:
# es el contrato que evita que la norma se vuelva fiction.
#
# Ejecutar:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://tests/test_m61_normas_performance.gd
#
# Exit code: 0 = verde medido | 1 = fallos.

extends SceneTree

const MODULO := "M61 normas de rendimiento"
const RUTA_M61 := "res://data/performance/budgets.json"
const RUTA_M62 := "res://data/rendimiento/budgets.json"
const GC := preload("res://scripts/settings/graphics_config.gd")
const HP := preload("res://scripts/hardware/hardware_profile.gd")
const SM := preload("res://scripts/stream/stream_manager.gd")
const RUTA_ATLAS := "res://scripts/arte2d/pack_atlas.gd"
const RUTA_AGUA := "res://scripts/world/validate_water.gd"
const RUTA_STREAM := "res://scripts/stream/stream_manager.gd"
## Checks minimos MEDIDOS en verde (no estimados): el suite corre con
## CHECKS_MINIMOS = 30 y el minimo declarado es 24 para dejar margen.
const CHECKS_MINIMOS := 24

## Id de preset de M90 -> clave de calidad de M90.
const MAPA_PRESET := {"baja": "bajo", "media": "medio", "alta": "alto", "ultra": "ultra"}

var _checks := 0
var _fallos := 0


func _initialize() -> void:
	call_deferred("_correr")


func _check(nombre: String, ok: bool, detalle: String = "") -> void:
	_checks += 1
	if not ok:
		_fallos += 1
		print("  [FALL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])
	else:
		print("  [ok]   %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])


func _leer(ruta: String) -> Dictionary:
	if not FileAccess.file_exists(ruta):
		return {}
	var v: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	if typeof(v) != TYPE_DICTIONARY:
		return {}
	return v as Dictionary


func _correr() -> void:
	await process_frame
	print("=== %s ===" % MODULO)

	var m61 := _leer(RUTA_M61)
	_check("M61 %s existe y parsea" % RUTA_M61, not m61.is_empty())
	if m61.is_empty():
		_cerrar()
		return
	_check("M61 version == 2", int(m61.get("version", 0)) == 2)

	var gpu: Dictionary = m61.get("gpu", {})
	var mem: Dictionary = m61.get("memoria", {})
	var normas: Dictionary = m61.get("normas", {})
	var limites: Dictionary = m61.get("limites", {})
	_check("M61 declara bloque gpu", not gpu.is_empty())
	_check("M61 declara bloque memoria", not mem.is_empty())
	_check("M61 declara objetivo_por_preset", normas.has("objetivo_por_preset"))
	if gpu.is_empty() or mem.is_empty() or not normas.has("objetivo_por_preset"):
		_cerrar()
		return

	var objetivo: Dictionary = normas["objetivo_por_preset"]

	# ── M61 <-> M90: los 4 presets de calidad deben coincidir con el runtime ──
	var calidades: Array = GC.CALIDADES
	_check("M90 declara 4 calidades", calidades.size() == 4, str(calidades))
	_check("M61 declara los mismos 4 presets", objetivo.size() == 4, str(objetivo.keys()))
	for calidad in calidades:
		var c := String(calidad)
		if not objetivo.has(c):
			_check("M61 declara el preset %s" % c, false)
			continue
		var p: Dictionary = objetivo[c]
		var dist_m90 := float(GC.DISTANCIA[c])
		var dist_m61 := float(p.get("distancia_dibujado_m", 0.0))
		_check("%s: distancia de dibujado M61 == M90" % c, is_equal_approx(dist_m61, dist_m90),
			"M61=%s m / M90=%s m" % [str(dist_m61), str(dist_m90)])
		var part_m90 := int(GC.PARTICULAS[c])
		var part_m61 := int(p.get("particulas_max", 0))
		_check("%s: particulas_max M61 == M90" % c, part_m61 == part_m90,
			"M61=%d / M90=%d" % [part_m61, part_m90])
		var casc_m90 := int(GC.SOMBRAS[c]["cascadas"])
		var casc_m61 := int(p.get("sombras_cascadas", 0))
		_check("%s: sombras_cascadas M61 == M90" % c, casc_m61 == casc_m90,
			"M61=%d / M90=%d" % [casc_m61, casc_m90])
		# Tope de FPS: el de M61 debe ser el tope real del preset M90 (0 = ilimitado)
		var id_preset := String(MAPA_PRESET[c])
		var fps_m90 := int(GC.PRESETS[id_preset]["fps"])
		var fps_m61 := int(p.get("fps_tope", -1))
		_check("%s: fps_tope M61 == M90" % c, fps_m61 == fps_m90,
			"M61=%d / M90=%d" % [fps_m61, fps_m90])

	# fps garantizado: el minimo de la norma (30) o el objetivo (60)
	var fps_min := int(normas.get("fps_minimo", 30))
	var fps_obj := int(normas.get("fps_objetivo", 60))
	for calidad in calidades:
		var c := String(calidad)
		if not objetivo.has(c):
			continue
		var fg := int((objetivo[c] as Dictionary).get("fps_garantizado", 0))
		_check("%s: fps_garantizado es el minimo o el objetivo de la norma" % c,
			fg == fps_min or fg == fps_obj, "valor=%d" % fg)

	# ── M61 <-> M114: el presupuesto de VRAM es el recomendado por el dueno ──
	var hp = HP.new()
	var vram_rec := int(hp.recommended_gpu_vram_mb)
	_check("M61 vram_presupuesto_mb == M114 recommended_gpu_vram_mb",
		int(mem.get("vram_presupuesto_mb", 0)) == vram_rec,
		"M61=%d / M114=%d" % [int(mem.get("vram_presupuesto_mb", 0)), vram_rec])
	_check("M61 vram_por_escena_mb <= vram_presupuesto_mb",
		int(mem.get("vram_por_escena_mb", 0)) <= int(mem.get("vram_presupuesto_mb", 0)),
		"%d <= %d" % [int(mem.get("vram_por_escena_mb", 0)), int(mem.get("vram_presupuesto_mb", 0))])

	# ── M61 <-> M62: paquete de datos (MB) contra el disco recomendado (M114) ──
	var m62 := _leer(RUTA_M62)
	_check("M62 %s existe y parsea" % RUTA_M62, not m62.is_empty())
	if not m62.is_empty():
		var presets: Dictionary = m62.get("presets", {})
		var sumas: Array[int] = []
		for nombre in ["baja", "media", "alta"]:
			if not presets.has(nombre):
				continue
			var sistemas: Dictionary = presets[nombre]
			var s := 0
			for k in sistemas.keys():
				s += int(sistemas[k])
			sumas.append(s)
		_check("M62: 3 presets de paquete de datos", sumas.size() == 3, str(sumas))
		if sumas.size() == 3:
			_check("M62: paquete de datos ascendente (baja < media < alta)",
				sumas[0] < sumas[1] and sumas[1] < sumas[2],
				"%d < %d < %d MB" % [sumas[0], sumas[1], sumas[2]])
			_check("M61: paquete maximo (alta) <= disco recomendado por M114",
				sumas[2] <= int(hp.recommended_disk_mb),
				"%d MB <= %d MB" % [sumas[2], int(hp.recommended_disk_mb)])

	# ── M61 <-> M51: el techo de overdraw ya existe en el proyecto ──
	_check("M61 overdraw_max == el techo de M51 (validate_water.gd)",
		_file_contains(RUTA_AGUA, "overdraw<=1.5") and is_equal_approx(float(gpu.get("overdraw_max", 0.0)), 1.5),
		"M61=%s" % str(gpu.get("overdraw_max", 0.0)))

	# ── M61 <-> M46: el limite de atlas 2048x2048 ──
	_check("M61 ui_atlas_textura == 2048x2048 (limite de M46)",
		String(mem.get("ui_atlas_textura", "")) == "2048x2048" and _file_contains(RUTA_ATLAS, "2048"),
		str(mem.get("ui_atlas_textura", "")))

	# ── M61 interno: una sola fuente de verdad para los draw calls ──
	_check("M61 draw calls: gpu == limites (una sola verdad)",
		int(gpu.get("draw_calls_escena_objetivo", 0)) == int(limites.get("draw_calls_max", 0)),
		"gpu=%d / limites=%d" % [int(gpu.get("draw_calls_escena_objetivo", 0)), int(limites.get("draw_calls_max", 0))])

	# ── M61 interno: texturas 4K comprimidas (RF7 literal) ──
	_check("M61 textura_max_resolucion == 4K", String(mem.get("textura_max_resolucion", "")) == "4K")
	_check("M61 texturas_comprimidas == true", bool(mem.get("texturas_comprimidas", false)))
	var comp: Dictionary = mem.get("compresion_por_plataforma", {})
	_check("M61 compresion_por_plataforma cubre windows/android/ios",
		comp.has("windows") and comp.has("android") and comp.has("ios"), str(comp.keys()))

	# ── M61 <-> M63: carga (RF9) + chunks (RF10) + destruccion (RF11) ──
	var carga: Dictionary = m61.get("carga", {})
	var chunks: Dictionary = m61.get("chunks", {})
	var destr: Dictionary = m61.get("destruccion", {})
	_check("M61 declara bloque carga", not carga.is_empty())
	_check("M61 declara bloque chunks", not chunks.is_empty())
	_check("M61 declara bloque destruccion", not destr.is_empty())
	if not carga.is_empty():
		_check("carga: progreso_minimo_pct == M63 PISO_PROGRESO",
			is_equal_approx(float(carga.get("progreso_minimo_pct", 0.0)), float(SM.PISO_PROGRESO)),
			"M61=%s / M63=%s" % [str(carga.get("progreso_minimo_pct")), str(SM.PISO_PROGRESO)])
		_check("carga: progreso_maximo_pct == M63 TOPE_PROGRESO",
			is_equal_approx(float(carga.get("progreso_maximo_pct", 0.0)), float(SM.TOPE_PROGRESO)),
			"M61=%s / M63=%s" % [str(carga.get("progreso_maximo_pct")), str(SM.TOPE_PROGRESO)])
		_check("carga: presupuesto_streaming_ms_por_frame == M63 PRESUPUESTO_MS",
			is_equal_approx(float(carga.get("presupuesto_streaming_ms_por_frame", 0.0)), float(SM.PRESUPUESTO_MS)),
			"M61=%s / M63=%s" % [str(carga.get("presupuesto_streaming_ms_por_frame")), str(SM.PRESUPUESTO_MS)])
		_check("carga: cola_prioridad_tipos == cantidad de tipos de operacion de M63",
			int(carga.get("cola_prioridad_tipos", 0)) == SM.PESOS.size(),
			"M61=%d / M63=%d" % [int(carga.get("cola_prioridad_tipos", 0)), SM.PESOS.size()])
		_check("carga: M63 carga en background (load_threaded_request)",
			_file_contains(RUTA_STREAM, "load_threaded_request")
			and bool(carga.get("carga_asincrona_obligatoria", false)))
		_check("carga: bloqueo_main_thread_max_ms == 0 (RF9)",
			float(carga.get("bloqueo_main_thread_max_ms", 1.0)) == 0.0)
		_check("carga: precarga_escena_siguiente == true",
			bool(carga.get("precarga_escena_siguiente", false)))
	if not chunks.is_empty():
		_check("chunks: cola_prioridad_tipos == M63 PESOS.size()",
			int(chunks.get("cola_prioridad_tipos", 0)) == SM.PESOS.size(),
			"M61=%d / M63=%d" % [int(chunks.get("cola_prioridad_tipos", 0)), SM.PESOS.size()])
		_check("chunks: chunks_activos_max == M63 MAX_CHUNKS_DEFAULT",
			int(chunks.get("chunks_activos_max", 0)) == int(SM.MAX_CHUNKS_DEFAULT),
			"M61=%d / M63=%d" % [int(chunks.get("chunks_activos_max", 0)), int(SM.MAX_CHUNKS_DEFAULT)])
		_check("chunks: frames_envejecido == M63 FRAMES_ENVEJECIDO",
			int(chunks.get("frames_envejecido", 0)) == int(SM.FRAMES_ENVEJECIDO),
			"M61=%d / M63=%d" % [int(chunks.get("frames_envejecido", 0)), int(SM.FRAMES_ENVEJECIDO)])
		_check("chunks: generacion_ms_por_frame_max <= 5.0 (RF10)",
			float(chunks.get("generacion_ms_por_frame_max", 99.0)) <= 5.0)
		_check("chunks: generacion en background thread y sin voxel en main thread (RF10)",
			bool(chunks.get("generacion_en_background_thread", false))
			and not bool(chunks.get("trabajo_voxel_en_main_thread", true)))
	if not destr.is_empty():
		_check("destruccion: sin GC en el bucle de interaccion (RF11)",
			not bool(destr.get("gc_en_bucle_interaccion", true)))
		_check("destruccion: pooling de buffers de mesh (RF11)",
			bool(destr.get("pooling_buffers_mesh", false)))
		_check("destruccion: remesh en background (RF11/M07)",
			bool(destr.get("remesh_en_background", false)))
		_check("destruccion: el techo de remesh vive en `normas` (<= 2 ms)",
			float(normas.get("remesh_bloque_ms_max", 99.0)) <= 2.0)

	_cerrar()


func _file_contains(ruta: String, aguja: String) -> bool:
	if not FileAccess.file_exists(ruta):
		return false
	return FileAccess.get_file_as_string(ruta).contains(aguja)


func _cerrar() -> void:
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FALLO] solo %d checks (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con codigo 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — la norma coincide con el runtime real" % MODULO)
		quit(0)
