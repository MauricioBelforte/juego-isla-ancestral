# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M61: Rendimiento — ValidateBudget (validador de presupuestos).
# Seccion 3.2 del 03-Diseno: valida que la tabla de presupuestos este completa
# (RF28), que una medicion de bench scene no exceda el total con tolerancia,
# y que todas las categorias esten dentro de su presupuesto individual.
# Corre en editor y en CI (M116). Ejecutar:
#   Godot --headless --script res://scripts/performance/validate_budget.gd
# Exit code: 0 = OK, 1 = fallo.

extends SceneTree

const RUTA_BUDGETS := "res://data/performance/budgets.json"
## Tabla de MB por preset: la dueño M62 (memoria). M61 solo la LEE para validar RF8.
const RUTA_PRESETS := "res://data/rendimiento/budgets.json"

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_cargar_y_validar_tabla()
	print("=== VALIDATE BUDGET M61: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _cargar_y_validar_tabla() -> void:
	var f := FileAccess.open(RUTA_BUDGETS, FileAccess.READ)
	_check(f != null, "budgets.json abierto")
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	_check(parsed is Dictionary, "budgets.json es JSON valido")
	if not (parsed is Dictionary):
		return
	var data: Dictionary = parsed
	_check(float(data.get("presupuesto_total_ms", 0.0)) > 0.0, "presupuesto_total_ms > 0")
	_check(float(data.get("tolerancia_ci", 0.0)) > 0.0, "tolerancia_ci > 0")
	var cats: Dictionary = data.get("categorias", {})
	_check(cats.size() >= 7, "7 categorias declaradas (RF28): %d" % cats.size())
	# Cada categoria > 0 y suma coherente
	var suma: float = 0.0
	for clave in cats:
		var ms := float(cats[clave])
		_check(ms > 0.0, "categoria %s > 0 (%s)" % [clave, str(ms)])
		suma += ms
	var total := float(data.get("presupuesto_total_ms", 0.0))
	_check(suma <= total * 1.3, "suma categorias dentro del total con margen (%.1f <= %.1f)" % [suma, total])
	# Hardware declarado
	var hw: Dictionary = data.get("hardware", {})
	_check(hw.get("minimo", "") != "" and hw.get("recomendado", "") != "", "hardware min/recomendado declarado")
	# Validar una medicion de ejemplo dentro de tolerancia
	var medicion := {"gameplay_ms": 2.0, "mundo_voxel_ms": 3.5, "ia_npc_ms": 1.5, "particulas_ms": 0.8, "culling_ms": 0.4, "render_ms": 4.5, "ui_ms": 1.2}
	_check(_validar_medicion(data, medicion), "medicion dentro de presupuesto OK")
	# Medicion excedida -> debe detectarse
	var mala := {"gameplay_ms": 20.0, "mundo_voxel_ms": 20.0, "ia_npc_ms": 20.0, "particulas_ms": 20.0, "culling_ms": 20.0, "render_ms": 20.0, "ui_ms": 20.0}
	_check(not _validar_medicion(data, mala), "medicion excedida detectada")
	# iter. agnes (Log 943): dimension de limites de CANTIDAD (spec M61 sec.M + flag M52)
	_validar_limites(data)
	# iter. atria (Log 1755): dimension de NORMAS transversales (RF1/RF2/RF3/RF8/RF9/RF11/RF12/RF18/RF21)
	_validar_normas(data)
	# iter. minimax-m3-1-flash (Log 2068): dimensiones GPU (RF5) + MEMORIA (RF6/RF7)
	# + objetivo por preset de calidad (RF1/RF18) y paquete de datos (RF8).
	_validar_gpu(data)
	_validar_memoria(data)
	_validar_objetivo_por_preset(data)
	_validar_paquete_datos()
	# iter. minimax-m3-1-flash (Log 2071): carga (RF9) + chunks (RF10) + destruccion (RF11)
	_validar_carga(data)
	_validar_chunks(data)
	_validar_destruccion(data)
	# iter. minimax-m3-1-flash (Log 2073): tecnicas (RF12..RF26) — 13 bloques de norma
	_validar_tecnicas(data)

func _validar_medicion(data: Dictionary, medicion: Dictionary) -> bool:
	var cats: Dictionary = data.get("categorias", {})
	var tolerancia := float(data.get("tolerancia_ci", 0.1))
	# Chequeo individual: cada categoria medida dentro de su presupuesto + tolerancia
	var fallo_individual := false
	for clave in cats:
		if medicion.has(clave):
			var presupuesto := float(cats[clave])
			var medida := float(medicion[clave])
			if medida > presupuesto * (1.0 + tolerancia):
				fallo_individual = true
	# Chequeo total: suma <= total * (1+tolerancia)
	var suma: float = 0.0
	for clave in medicion:
		suma += float(medicion[clave])
	var total := float(data.get("presupuesto_total_ms", 0.0))
	return (not fallo_individual) and suma <= total * (1.0 + tolerancia)


## iter. agnes (Log 943): valida el bloque "limites" (cantidad) si existe.
## Tolera su ausencia (no rompe el gate temporal previo); si esta, exige bien formado
## + los 3 limites canonicos + particulas_simultaneas_max == 500 (spec M61 sec.M / RF13).
func _validar_limites(data: Dictionary) -> void:
	if not data.has("limites"):
		return
	var limites: Variant = data.get("limites", {})
	_check(limites is Dictionary, "bloque limitas es un Dictionary")
	if not (limites is Dictionary):
		return
	var limes: Dictionary = limites
	_check(limes.size() >= 3, "limites: >=3 limites declarados (%d)" % limes.size())
	for clave in limes:
		var valor: Variant = limes[clave]
		if clave == "nota":
			continue
		_check(typeof(valor) == TYPE_INT or typeof(valor) == TYPE_FLOAT,
			"limite %s es numerico" % clave)
		if (typeof(valor) == TYPE_INT or typeof(valor) == TYPE_FLOAT) and float(valor) <= 0.0:
			_check(false, "limite %s > 0 (%s)" % [clave, str(valor)])
	_check(int(limes.get("particulas_simultaneas_max", 0)) == 500,
		"particulas_simultaneas_max == 500 (spec M61 sec.M / flag M52)")
	_check(limes.has("draw_calls_max"), "draw_calls_max declarado")
	_check(limes.has("objetos_mundo_max"), "objetos_mundo_max declarado")
	# Lectura dentro de limites -> OK; excedida -> debe detectarse
	_check(_medicion_dentro_limites(limes, {"particulas_simultaneas": 480, "draw_calls": 390, "objetos_mundo": 900}),
		"medicion de cantidad dentro de limites OK")
	_check(not _medicion_dentro_limites(limes, {"particulas_simultaneas": 600, "draw_calls": 390, "objetos_mundo": 900}),
		"particulas excediendo 500 detectada")
	print("[M61] limites: %d limit(es) de cantidad validados (particulas_simultaneas_max=%s)" % [
		limes.size() - (1 if limes.has("nota") else 0),
		str(limes.get("particulas_simultaneas_max", "?")),
	])

## Devuelve true si cada clave de la medicion (si existe en limites) no excede su limite.
func _medicion_dentro_limites(limites: Dictionary, medicion: Dictionary) -> bool:
	for clave in medicion:
		var clave_s: String = String(clave)
		var clave_limite: String = clave_s + "_max"
		if limites.has(clave_limite):
			if float(medicion[clave_s]) > float(limites[clave_limite]):
				return false
	return true


## iter. atria (Log 1755): valida el bloque "normas" (umbrales transversales de
## RF1/RF2/RF3/RF8/RF9/RF11/RF12/RF18/RF21). Tolera su ausencia (no rompe el gate
## de ramas anteriores); si esta, exige bien formado + los valores canonicos de la
## spec M61 (01-Requerimientos y 03-Diseno).
func _validar_normas(data: Dictionary) -> void:
	if not data.has("normas"):
		return
	var normas: Variant = data.get("normas", {})
	_check(normas is Dictionary, "bloque normas es un Dictionary")
	if not (normas is Dictionary):
		return
	var n: Dictionary = normas
	_check(bool(n.get("vsync", false)), "vsync activado (RF1: sin tearing)")
	_check(int(n.get("fps_objetivo", 0)) == 60, "fps_objetivo == 60 (RF1)")
	_check(int(n.get("fps_minimo", 0)) == 30, "fps_minimo == 30 (RF1)")
	_check(int(n.get("fps_minimo", 0)) < int(n.get("fps_objetivo", 0)), "fps_minimo < fps_objetivo")
	_check(String(n.get("resolucion_base", "")) == "1080p", "resolucion_base 1080p (RF2)")
	# Distancia de dibujado: 4 presets ascendentes 300/600/1200/2500 m (RF18, presets M90)
	# CORRECCION 2026-10-21 (minimax-m3-1-flash, Log 2068): antes 3 presets 100/150/220 m,
	# que NO coincidian con el runtime real (M90 graphics_config.gd const DISTANCIA).
	var presets: Variant = n.get("distancia_dibujado_presets_m", [])
	_check(presets is Array and (presets as Array).size() == 4,
		"distancia_dibujado_presets_m: 4 presets (RF18)")
	if presets is Array and (presets as Array).size() == 4:
		var arr: Array = presets
		var ok_valores: bool = int(arr[0]) == 300 and int(arr[1]) == 600 \
			and int(arr[2]) == 1200 and int(arr[3]) == 2500
		_check(ok_valores, "presets == 300/600/1200/2500 m (RF18, = M90 DISTANCIA)")
		_check(int(arr[0]) < int(arr[1]) and int(arr[1]) < int(arr[2]) and int(arr[2]) < int(arr[3]),
			"presets de distancia ascendentes")
	# LOD: 3 niveles + transicion sin pop (RF21)
	_check(int(n.get("lod_niveles", 0)) == 3, "lod_niveles == 3 (RF21)")
	_check(float(n.get("lod_transicion_sin_pop_m", 0.0)) > 0.0, "lod_transicion_sin_pop_m > 0 (RF21)")
	# NPCs activos visibles (RF12)
	_check(int(n.get("npcs_activos_max", 0)) == 20, "npcs_activos_max == 20 (RF12)")
	# Remesh por bloque destruido (RF11)
	_check(float(n.get("remesh_bloque_ms_max", 0.0)) > 0.0 and float(n.get("remesh_bloque_ms_max", 99.0)) <= 2.0,
		"remesh_bloque_ms_max <= 2.0 ms (RF11)")
	# Cargas: fria <30 s, caliente <10 s, HDD no soportado (RF8/RF9)
	_check(float(n.get("carga_fria_s_max", 0.0)) > 0.0 and float(n.get("carga_fria_s_max", 99.0)) <= 30.0,
		"carga_fria_s_max <= 30 s (RF8)")
	_check(float(n.get("carga_caliente_s_max", 0.0)) > 0.0 and float(n.get("carga_caliente_s_max", 99.0)) <= 10.0,
		"carga_caliente_s_max <= 10 s (RF8)")
	_check(not bool(n.get("almacenamiento_hdd_soportado", true)),
		"almacenamiento_hdd_soportado == false (RF8: HDD no soportado)")
	print("[M61] normas: %d umbral(es) transversales validados (fps %d/%d, presets %s, LOD %d, NPCs %d)" % [
		n.size() - (1 if n.has("nota") else 0),
		int(n.get("fps_objetivo", 0)),
		int(n.get("fps_minimo", 0)),
		str(n.get("distancia_dibujado_presets_m", [])),
		int(n.get("lod_niveles", 0)),
		int(n.get("npcs_activos_max", 0)),
	])


## iter. minimax-m3-1-flash (Log 2068): dimension GPU (RF5) — draw calls, overdraw y
## coste de shaders. Tolera su ausencia (no rompe el gate de ramas anteriores);
## si esta, exige bien formado + coherencia con `limites.draw_calls_max`.
func _validar_gpu(data: Dictionary) -> void:
	if not data.has("gpu"):
		return
	var gpu: Variant = data.get("gpu", {})
	_check(gpu is Dictionary, "bloque gpu es un Dictionary")
	if not (gpu is Dictionary):
		return
	var g: Dictionary = gpu
	# Draw calls por escena: debe COINCIDIR con el limite de cantidad (una sola verdad)
	var objetivo := int(g.get("draw_calls_escena_objetivo", 0))
	_check(objetivo > 0, "gpu.draw_calls_escena_objetivo > 0 (RF5)")
	var limites: Dictionary = data.get("limites", {})
	if limites.has("draw_calls_max"):
		_check(objetivo == int(limites["draw_calls_max"]),
			"gpu.draw_calls_escena_objetivo == limites.draw_calls_max (%d)" % objetivo)
	# Limite por chunk
	_check(int(g.get("draw_calls_por_chunk_max", 0)) > 0, "gpu.draw_calls_por_chunk_max > 0 (RF5)")
	# Overdraw
	_check(float(g.get("overdraw_max", 0.0)) > 0.0, "gpu.overdraw_max > 0 (RF5)")
	# Coste de shader por material
	_check(float(g.get("shader_coste_material_max_ms", 0.0)) > 0.0,
		"gpu.shader_coste_material_max_ms > 0 (RF5)")
	# Medicion dentro de presupuesto -> OK; excedida -> debe detectarse
	var dentro := {
		"draw_calls": int(g.get("draw_calls_escena_objetivo", 400)) - 10,
		"overdraw": float(g.get("overdraw_max", 1.5)) - 0.1,
		"shader_coste_material_ms": float(g.get("shader_coste_material_max_ms", 0.5)) - 0.1,
	}
	_check(_medicion_dentro_umbrales_gpu(g, dentro), "medicion GPU dentro de umbrales OK")
	var excedida := {
		"draw_calls": int(g.get("draw_calls_escena_objetivo", 400)) + 1,
		"overdraw": float(g.get("overdraw_max", 1.5)) + 0.1,
		"shader_coste_material_ms": float(g.get("shader_coste_material_max_ms", 0.5)) + 0.1,
	}
	_check(not _medicion_dentro_umbrales_gpu(g, excedida), "medicion GPU excedida detectada")
	print("[M61] gpu: %d umbral(es) validados (draw calls %d/escena, %d/chunk, overdraw %.1f, shader %.2f ms)" % [
		g.size() - (1 if g.has("nota") else 0),
		objetivo,
		int(g.get("draw_calls_por_chunk_max", 0)),
		float(g.get("overdraw_max", 0.0)),
		float(g.get("shader_coste_material_max_ms", 0.0)),
	])


## Devuelve true si cada clave de la medicion respeta su umbral del bloque gpu.
func _medicion_dentro_umbrales_gpu(g: Dictionary, medicion: Dictionary) -> bool:
	var mapa := {
		"draw_calls": "draw_calls_escena_objetivo",
		"overdraw": "overdraw_max",
		"shader_coste_material_ms": "shader_coste_material_max_ms",
	}
	for clave in medicion:
		var umbral: String = String(mapa.get(clave, ""))
		if umbral == "" or not g.has(umbral):
			continue
		if float(medicion[clave]) > float(g[umbral]):
			return false
	return true


## iter. minimax-m3-1-flash (Log 2068): dimension MEMORIA (RF6/RF7) + coordinacion
## de pausas de GC con M62. Tolera su ausencia; si esta, exige bien formado.
func _validar_memoria(data: Dictionary) -> void:
	if not data.has("memoria"):
		return
	var mem: Variant = data.get("memoria", {})
	_check(mem is Dictionary, "bloque memoria es un Dictionary")
	if not (mem is Dictionary):
		return
	var m: Dictionary = mem
	# VRAM: presupuesto total >= presupuesto por escena
	var total := int(m.get("vram_presupuesto_mb", 0))
	var escena := int(m.get("vram_por_escena_mb", 0))
	_check(total > 0, "memoria.vram_presupuesto_mb > 0 (RF7)")
	_check(escena > 0, "memoria.vram_por_escena_mb > 0 (RF7)")
	_check(escena <= total, "vram_por_escena_mb <= vram_presupuesto_mb (%d <= %d)" % [escena, total])
	# Texturas: 4K comprimidas (RF7 literal)
	_check(String(m.get("textura_max_resolucion", "")) == "4K",
		"memoria.textura_max_resolucion == 4K (RF7)")
	_check(bool(m.get("texturas_comprimidas", false)),
		"memoria.texturas_comprimidas == true (RF7: texturas 4K COMPRIMIDAS)")
	# Atlas de UI (M53/M46): 2048x2048 y 16 MB por atlas
	_check(String(m.get("ui_atlas_textura", "")) == "2048x2048",
		"memoria.ui_atlas_textura == 2048x2048 (M53/M46)")
	_check(int(m.get("ui_atlas_max_mb", 0)) == 16,
		"memoria.ui_atlas_max_mb == 16 (2048*2048*4 bytes RGBA8)")
	# GC: pausa maxima por debajo del criterio de aceptacion 6 (50 ms), coordinado con M62
	_check(float(m.get("gc_pausa_max_ms", 0.0)) > 0.0 and float(m.get("gc_pausa_max_ms", 99.0)) <= 50.0,
		"memoria.gc_pausa_max_ms <= 50 (criterio de aceptacion 6, coordinado con M62)")
	# Compresion por plataforma: BC7 en escritorio, ASTC en movil
	var comp: Variant = m.get("compresion_por_plataforma", {})
	_check(comp is Dictionary, "memoria.compresion_por_plataforma es un Dictionary")
	if comp is Dictionary:
		var c: Dictionary = comp
		_check(c.has("windows") and c.has("android") and c.has("ios"),
			"compresion declarada para windows/android/ios")
		_check(String(c.get("windows", "")) == "BC7", "windows usa BC7")
		_check(String(c.get("android", "")).begins_with("ASTC"), "android usa ASTC")
		_check(String(c.get("ios", "")).begins_with("ASTC"), "ios usa ASTC")
	print("[M61] memoria: %d umbral(es) validados (VRAM %d MB total / %d MB por escena, atlas 16 MB, GC <= 50 ms)" % [
		m.size() - (1 if m.has("nota") else 0),
		total,
		escena,
	])


## iter. minimax-m3-1-flash (Log 2068): objetivo por preset de calidad (RF1/RF18).
## La norma declara el objetivo POR PRESET; el test M61 <-> M90 verifica ademas que
## estos valores coinciden con el runtime real de M90 (graphics_config.gd).
func _validar_objetivo_por_preset(data: Dictionary) -> void:
	var normas: Dictionary = data.get("normas", {})
	if not normas.has("objetivo_por_preset"):
		return
	var op: Variant = normas.get("objetivo_por_preset", {})
	_check(op is Dictionary, "normas.objetivo_por_preset es un Dictionary")
	if not (op is Dictionary):
		return
	var o: Dictionary = op
	var esperados: Array[String] = ["baja", "media", "alta", "ultra"]
	for nombre in esperados:
		_check(o.has(nombre), "preset %s declarado" % nombre)
	_check(o.size() == esperados.size(), "4 presets de calidad declarados (%d)" % o.size())
	var fps_min := int(normas.get("fps_minimo", 30))
	var fps_obj := int(normas.get("fps_objetivo", 60))
	var dist_previas := -1.0
	var part_previas := -1
	for nombre in esperados:
		if not o.has(nombre):
			continue
		var p: Dictionary = o[nombre]
		var fg := int(p.get("fps_garantizado", 0))
		_check(fg == fps_min or fg == fps_obj,
			"preset %s: fps_garantizado (%d) es el minimo (%d) o el objetivo (%d)" % [nombre, fg, fps_min, fps_obj])
		# fps_tope = 0 significa "ilimitado" (convencion de M90 FPS_OPCIONES)
		var tope := int(p.get("fps_tope", -1))
		_check(tope == 0 or tope >= fg, "preset %s: fps_tope >= fps_garantizado (0 = ilimitado)" % nombre)
		var dist := float(p.get("distancia_dibujado_m", 0.0))
		_check(dist > 0.0, "preset %s: distancia_dibujado_m > 0" % nombre)
		_check(dist > dist_previas, "preset %s: distancia ascendente" % nombre)
		dist_previas = dist
		var part := int(p.get("particulas_max", 0))
		_check(part > 0, "preset %s: particulas_max > 0" % nombre)
		_check(part > part_previas, "preset %s: particulas ascendente" % nombre)
		part_previas = part
		_check(int(p.get("sombras_cascadas", 0)) >= 1, "preset %s: sombras_cascadas >= 1" % nombre)
	print("[M61] objetivo_por_preset: %d preset(s) validados" % o.size())


## iter. minimax-m3-1-flash (Log 2068): RF8 — tamaño maximo del paquete de datos.
## La tabla de MB por preset la dueño M62 (data/rendimiento/budgets.json): este gate
## la LEE (no la modifica) y verifica que siga siendo coherente y ascendente.
func _validar_paquete_datos() -> void:
	var f := FileAccess.open(RUTA_PRESETS, FileAccess.READ)
	_check(f != null, "%s abierto" % RUTA_PRESETS)
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	_check(parsed is Dictionary, "%s es JSON valido" % RUTA_PRESETS)
	if not (parsed is Dictionary):
		return
	var datos: Dictionary = parsed
	var presets: Dictionary = datos.get("presets", {})
	_check(presets.has("baja") and presets.has("media") and presets.has("alta"),
		"paquete de datos: 3 presets declarados")
	var sumas: Array[int] = []
	for nombre in ["baja", "media", "alta"]:
		if not presets.has(nombre):
			continue
		var sistemas: Dictionary = presets[nombre]
		var s := 0
		for k in sistemas.keys():
			s += int(sistemas[k])
		sumas.append(s)
	_check(sumas.size() == 3, "paquete de datos: 3 sumas calculadas")
	if sumas.size() == 3:
		_check(sumas[0] < sumas[1] and sumas[1] < sumas[2],
			"paquete de datos: sizes ascendentes (baja %d < media %d < alta %d MB)" % [sumas[0], sumas[1], sumas[2]])
		_check(sumas[2] <= 3000,
			"paquete de datos: maximo por preset <= 3000 MB (medido %d MB)" % sumas[2])
	print("[M61] paquete de datos (M62): %d MB / %d MB / %d MB por preset" % [
		sumas[0] if sumas.size() > 0 else -1,
		sumas[1] if sumas.size() > 1 else -1,
		sumas[2] if sumas.size() > 2 else -1,
	])


## iter. minimax-m3-1-flash (Log 2071): dimension CARGA (RF9). Tolera su ausencia.
func _validar_carga(data: Dictionary) -> void:
	if not data.has("carga"):
		return
	var c: Variant = data.get("carga", {})
	_check(c is Dictionary, "bloque carga es un Dictionary")
	if not (c is Dictionary):
		return
	var cg: Dictionary = c
	# RF9 literal: la carga es asincrona y nunca bloquea el hilo principal
	_check(bool(cg.get("carga_asincrona_obligatoria", false)),
		"carga.carga_asincrona_obligatoria == true (RF9)")
	_check(float(cg.get("bloqueo_main_thread_max_ms", 1.0)) == 0.0,
		"carga.bloqueo_main_thread_max_ms == 0 (RF9: nunca bloquear el hilo principal)")
	# Progreso real: piso > 0 y tope < 1 (la barra no miente)
	var piso := float(cg.get("progreso_minimo_pct", 0.0))
	var tope := float(cg.get("progreso_maximo_pct", 1.0))
	_check(piso > 0.0, "carga.progreso_minimo_pct > 0 (la barra no arranca en 0)")
	_check(tope < 1.0, "carga.progreso_maximo_pct < 1 (la barra no llega a 100 antes de terminar)")
	_check(piso < tope, "carga: progreso_minimo_pct < progreso_maximo_pct")
	# Presupuesto de streaming por frame
	_check(float(cg.get("presupuesto_streaming_ms_por_frame", 0.0)) > 0.0,
		"carga.presupuesto_streaming_ms_por_frame > 0")
	# Precarga
	_check(bool(cg.get("precarga_escena_siguiente", false)),
		"carga.precarga_escena_siguiente == true")
	# Cola priorizada
	_check(int(cg.get("cola_prioridad_tipos", 0)) > 0, "carga.cola_prioridad_tipos > 0")
	print("[M61] carga: %d umbral(es) validados (progreso %.2f..%.2f, presupuesto %.0f ms/frame, %d tipos de cola)" % [
		cg.size() - (1 if cg.has("nota") else 0),
		piso,
		tope,
		float(cg.get("presupuesto_streaming_ms_por_frame", 0.0)),
		int(cg.get("cola_prioridad_tipos", 0)),
	])


## iter. minimax-m3-1-flash (Log 2071): dimension CHUNKS (RF10). Tolera su ausencia.
func _validar_chunks(data: Dictionary) -> void:
	if not data.has("chunks"):
		return
	var c: Variant = data.get("chunks", {})
	_check(c is Dictionary, "bloque chunks es un Dictionary")
	if not (c is Dictionary):
		return
	var ch: Dictionary = c
	_check(bool(ch.get("generacion_en_background_thread", false)),
		"chunks.generacion_en_background_thread == true (RF10)")
	_check(not bool(ch.get("trabajo_voxel_en_main_thread", true)),
		"chunks.trabajo_voxel_en_main_thread == false (RF10)")
	_check(float(ch.get("generacion_ms_por_frame_max", 0.0)) > 0.0
		and float(ch.get("generacion_ms_por_frame_max", 99.0)) <= 5.0,
		"chunks.generacion_ms_por_frame_max <= 5.0 ms (RF10)")
	_check(int(ch.get("cola_prioridad_tipos", 0)) > 0, "chunks.cola_prioridad_tipos > 0")
	_check(int(ch.get("chunks_activos_max", 0)) > 0, "chunks.chunks_activos_max > 0")
	_check(int(ch.get("frames_envejecido", 0)) > 0, "chunks.frames_envejecido > 0")
	print("[M61] chunks: %d umbral(es) validados (generacion <= %.1f ms/frame, %d chunks activos, %d tipos de cola)" % [
		ch.size() - (1 if ch.has("nota") else 0),
		float(ch.get("generacion_ms_por_frame_max", 0.0)),
		int(ch.get("chunks_activos_max", 0)),
		int(ch.get("cola_prioridad_tipos", 0)),
	])


## iter. minimax-m3-1-flash (Log 2071): dimension DESTRUCCION (RF11). Tolera su ausencia.
func _validar_destruccion(data: Dictionary) -> void:
	if not data.has("destruccion"):
		return
	var d: Variant = data.get("destruccion", {})
	_check(d is Dictionary, "bloque destruccion es un Dictionary")
	if not (d is Dictionary):
		return
	var ds: Dictionary = d
	_check(not bool(ds.get("gc_en_bucle_interaccion", true)),
		"destruccion.gc_en_bucle_interaccion == false (RF11: sin GC en el bucle del jugador)")
	_check(bool(ds.get("pooling_buffers_mesh", false)),
		"destruccion.pooling_buffers_mesh == true (RF11)")
	_check(bool(ds.get("remesh_en_background", false)),
		"destruccion.remesh_en_background == true (RF11/M07)")
	# El techo de remesh por bloque vive en `normas` (no se duplica): debe existir y ser <= 2 ms
	var normas: Dictionary = data.get("normas", {})
	_check(float(normas.get("remesh_bloque_ms_max", 99.0)) <= 2.0,
		"destruccion: el techo de remesh (normas.remesh_bloque_ms_max) <= 2 ms")
	print("[M61] destruccion: %d umbral(es) validados (sin GC en el bucle, pooling de buffers, remesh en background)" % [
		ds.size() - (1 if ds.has("nota") else 0),
	])

## ── Tecnicas (RF12..RF26) — tabla canonica de la norma ──
## Log 2073 (minimax-m3-1-flash, 2026-10-21). Congela los umbrales de los 13
## bloques de tecnicas: si alguien cambia un valor en budgets.json, el gate se
## pone en ROJO y hay que actualizar la tabla a proposito (y el log).
const TECNICAS_CANONICAS: Dictionary = {
	"npcs": {
		"burbujas_distancia_m": [30, 60, 100],
		"tick_interval_por_burbuja_s": [0.5, 1.0, 5.0],
		"max_con_ia_completa": 60,
		"pooling_instancias": true,
		"lod_niveles": 3,
	},
	"particulas": {
		"pooling_emisores": true,
		"max_emisores_pool": 32,
		"max_particulas_pool": 1200,
		"precalentamiento_emisores": 8,
		"gpu_particles_larga_vida": true,
		"max_emisores_por_evento": 1,
	},
	"sombras": {
		"dinamicas_solo_personajes_y_clave": true,
		"max_luces_con_sombra": 6,
		"max_luces_dinamicas": 20,
		"cascadas_por_preset": [1, 2, 4, 4],
		"res_sombra_por_preset": [512, 1024, 2048, 4096],
		"rango_cascada_limitado": true,
		"costo_sombra_max_fraccion_render": 0.5,
		"estaticas_sin_sombra_dinamica": true,
	},
	"iluminacion": {
		"gi_suave_sin_bounce_caro": true,
		"luz_horaria": "1 directional + sky",
		"max_luces_realtime": 20,
		"volumetrico_densidad_por_preset": {"baja": 0.0, "medio": 0.0, "alto": 0.1, "ultra": 0.2},
		"lightmap_baked_interiores": true,
	},
	"agua": {
		"plano_unico": true,
		"plano_lado_m": 4096,
		"normales_animadas_en_shader": true,
		"reflejos_solo_superficie": true,
		"probes_reflejos_max": 2,
		"transparencia_ordenada": true,
		"verts_por_chunk_max": 2000,
		"fases_onda": 3,
	},
	"vegetacion": {
		"gpu_instancing_obligatorio": true,
		"viento_en_vertex_shader": true,
		"culling_por_viento_occlusivo": true,
		"multiplicador_por_preset": {"baja": 0.2, "media": 0.45, "alta": 0.8, "ultra": 1.0},
		"densidad_max_por_bioma": 30,
		"instancias_por_chunk_max": 124,
	},
	"culling": {
		"usar_frustum_del_engine": true,
		"por_chunks": true,
		"por_distancia": true,
		"de_particulas": true,
	},
	"occlusion": {
		"por_celdas_de_chunks": true,
		"solo_en_cuevas_y_templos": true,
		"sin_occlusion_global_en_terreno_abierto": true,
		"coste_gpu_queries_acotado": true,
	},
	"lod": {
		"impostor_lejano": true,
		"radio_impostor_m": 2700.0,
		"paso_impostor_m": 64.0,
		"distancia_lod_objeto_m": 160.0,
		"niveles_lod": 4,
		"escalonado_por_distancia": true,
	},
	"batching": {
		"estaticos_por_bioma": true,
		"max_materiales_por_batch": 32,
		"ui_por_atlas": true,
	},
	"instancing": {
		"peces": true,
		"vegetacion": true,
		"rocas_y_fragmentos": true,
		"particulas_larga_vida": true,
	},
	"pooling": {
		"particulas": true,
		"fauna_y_peces": true,
		"efectos_de_herramientas": true,
		"buffers_de_remesh": true,
	},
	"allocations": {
		"reuso_de_arrays_y_variants": true,
		"gc_en_pausas_seguras": true,
	},
}


## Compara dos valores del JSON (numeros con tolerancia, arrays y dicts elemento a elemento).
func _mismo_valor(a: Variant, b: Variant) -> bool:
	if a is Array and b is Array:
		var aa: Array = a
		var bb: Array = b
		if aa.size() != bb.size():
			return false
		for i in aa.size():
			if not _mismo_valor(aa[i], bb[i]):
				return false
		return true
	if a is Dictionary and b is Dictionary:
		var ad: Dictionary = a
		var bd: Dictionary = b
		if ad.size() != bd.size():
			return false
		for k in ad.keys():
			if not bd.has(k) or not _mismo_valor(ad[k], bd[k]):
				return false
		return true
	if (a is float or a is int) and (b is float or b is int):
		return is_equal_approx(float(a), float(b))
	if a is bool or b is bool:
		return bool(a) == bool(b)
	return str(a) == str(b)


## Valida los 13 bloques de tecnicas contra la tabla canonica + las invariantes
## que los relacionan con el resto de la norma. Tolera si un bloque falta.
func _validar_tecnicas(data: Dictionary) -> void:
	var norma: Dictionary = data.get("normas", {})
	var limites: Dictionary = data.get("limites", {})
	for nombre in TECNICAS_CANONICAS.keys():
		if not data.has(nombre):
			continue
		var bloque: Variant = data.get(nombre, {})
		_check(bloque is Dictionary, "bloque %s es un Dictionary" % nombre)
		if not (bloque is Dictionary):
			continue
		var b: Dictionary = bloque
		var esperado: Dictionary = TECNICAS_CANONICAS[nombre]
		for clave in esperado.keys():
			_check(b.has(clave), "%s.%s declarado" % [nombre, clave])
			if not b.has(clave):
				continue
			_check(_mismo_valor(b[clave], esperado[clave]),
				"%s.%s == canonico" % [nombre, clave])
		# ── invariantes entre bloques ──
		if nombre == "npcs":
			_check(int(b.get("max_con_ia_completa", 0)) >= int(norma.get("npcs_activos_max", 0)),
				"npcs.max_con_ia_completa >= normas.npcs_activos_max (el runtime debe cubrir el tope de render)")
			_check((b.get("burbujas_distancia_m", []) as Array).size() == 3
				and (b.get("tick_interval_por_burbuja_s", []) as Array).size() == 3,
				"npcs: 3 burbujas de distancia con 3 intervalos de tick")
		if nombre == "particulas":
			_check(int(b.get("max_particulas_pool", 0)) >= int(limites.get("particulas_simultaneas_max", 0)),
				"particulas.max_particulas_pool >= limites.particulas_simultaneas_max")
		if nombre == "sombras":
			_check(int(b.get("max_luces_con_sombra", 0)) <= int(b.get("max_luces_dinamicas", 0)),
				"sombras: las luces con sombra son un subconjunto de las dinamicas")
		if nombre == "agua":
			_check(int(b.get("verts_por_chunk_max", 9999)) <= 2000, "agua.verts_por_chunk_max <= 2000 (M51)")
			_check(int(b.get("probes_reflejos_max", 99)) <= 2, "agua.probes_reflejos_max <= 2 (M51)")
		if nombre == "vegetacion":
			_check(int(b.get("densidad_max_por_bioma", 0)) <= int(b.get("instancias_por_chunk_max", 0)),
				"vegetacion: la densidad maxima por bioma cabe en el presupuesto de instancias por chunk")
		if nombre == "lod":
			_check(float(b.get("radio_impostor_m", 0.0)) > 1024.0,
				"lod.radio_impostor_m > 1024 m (debe cubrir la view distance del mundo)")
		if nombre == "batching":
			_check(int(b.get("max_materiales_por_batch", 0)) > 0
				and int(b.get("max_materiales_por_batch", 0)) <= 64,
				"batching.max_materiales_por_batch en 1..64")
		print("[M61] %s: %d umbral(es) tecnicos validados" % [nombre, b.size() - (1 if b.has("nota") else 0)])

