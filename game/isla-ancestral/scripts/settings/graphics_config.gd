# M90: GraphicsConfig — núcleo de configuración gráfica.
# Modelo: step-5-kilocode (Kilo Code)
# Fecha: 2026-10-12
#
# Implementa el diseño de 03-Diseno.md §1 (Pantalla / Performance / Calidad /
# Anti-aliasing / Post-processing / Presets / Detección) como NÚCLEO PURO:
# datos + validación + aplicación, sin nodos de UI. La UI (M53) consume este
# núcleo; losvalores ajustados valores se aplican al motor en `aplicar()`.
#
# Sin class_name: se accede por ruta (pitfall GUIA-GODOT/09 §9.17).
# Núcleo puro: testeable en headless sin ventana real.

extends RefCounted

## ── Resoluciones (§1 Pantalla) ───────────────────────────────────────────
## id -> {ancho, alto, etiqueta}. "nativa" se resuelve en runtime contra el
## monitor (DisplayServer.screen_get_size()).
const RESOLUCIONES: Array[Dictionary] = [
	{"id": "720p", "ancho": 1280, "alto": 720, "etiqueta": "1280x720 (720p)"},
	{"id": "1080p", "ancho": 1920, "alto": 1080, "etiqueta": "1920x1080 (1080p)"},
	{"id": "1440p", "ancho": 2560, "alto": 1440, "etiqueta": "2560x1440 (1440p)"},
	{"id": "4k", "ancho": 3840, "alto": 2160, "etiqueta": "3840x2160 (4K)"},
	{"id": "nativa", "ancho": 0, "alto": 0, "etiqueta": "Nativa (del monitor)"},
]

## Aspect ratio soportados (§1).
const ASPECT_RATIOS: Array[Dictionary] = [
	{"id": "16:9", "valor": 16.0 / 9.0},
	{"id": "16:10", "valor": 16.0 / 10.0},
	{"id": "21:9", "valor": 21.0 / 9.0},
]

## ── Modos de pantalla (§1) ───────────────────────────────────────────────
const MODO_VENTANA := "ventana"
const MODO_PANTALLA_COMPLETA := "pantalla_completa"
const MODO_BORDERLESS := "borderless"
const MODOS: Array[String] = [MODO_VENTANA, MODO_PANTALLA_COMPLETA, MODO_BORDERLESS]

## ── Calidades (§1) ───────────────────────────────────────────────────────
const CALIDAD_BAJA := "baja"
const CALIDAD_MEDIA := "media"
const CALIDAD_ALTA := "alta"
const CALIDAD_ULTRA := "ultra"
const CALIDADES: Array[String] = [CALIDAD_BAJA, CALIDAD_MEDIA, CALIDAD_ALTA, CALIDAD_ULTRA]

## Sombras por calidad (cascadas, mapas, resolución, soft).
const SOMBRAS: Dictionary = {
	"baja": {"cascadas": 1, "mapas": 1, "res": 512, "soft": false, "tecnica": "simple"},
	"media": {"cascadas": 2, "mapas": 2, "res": 1024, "soft": false, "tecnica": "suave"},
	"alta": {"cascadas": 4, "mapas": 4, "res": 2048, "soft": true, "tecnica": "PCSS"},
	"ultra": {"cascadas": 4, "mapas": 4, "res": 4096, "soft": true, "tecnica": "soft"},
}

## Texturas por calidad (escala de render, mipmap, filtrado, aniso).
const TEXTURAS: Dictionary = {
	"baja": {"escala": 0.5, "mipmap": 0, "filtrado": "bilinear", "aniso": 2},
	"media": {"escala": 1.0, "mipmap": 1, "filtrado": "trilinear", "aniso": 4},
	"alta": {"escala": 2.0, "mipmap": 2, "filtrado": "trilinear", "aniso": 8},
	"ultra": {"escala": 4.0, "mipmap": 3, "filtrado": "trilinear", "aniso": 16},
}

## Distancia de dibujado por calidad (metros).
const DISTANCIA: Dictionary = {
	"baja": 300.0, "media": 600.0, "alta": 1200.0, "ultra": 2500.0,
}

## Efectos / vegetación / agua / partículas por calidad (multiplicador 0..1).
const EFECTOS: Dictionary = {"baja": 0.25, "media": 0.5, "alta": 0.85, "ultra": 1.0}
const VEGETACION: Dictionary = {"baja": 0.2, "media": 0.45, "alta": 0.8, "ultra": 1.0}
const AGUA: Dictionary = {"baja": 0.25, "media": 0.5, "alta": 0.85, "ultra": 1.0}

## Partículas por calidad (máximo por sistema, §1).
const PARTICULAS: Dictionary = {"baja": 100, "media": 500, "alta": 1000, "ultra": 2000}

## ── Culling y LOD (§1 rendimiento) ───────────────────────────────────────
## Frustum culling + cull por distancia (desactiva objetos fuera de rango).
const CULLING: Dictionary = {"frustum": true, "por_distancia": true}

## LOD por objeto lejano (complemento al LOD de terreno de main_island).
## La implementación del LOD por OBJETO depende de M50 (vegetación/objetos);
## aquí se define el DISEÑO (flags + distancia + niveles) para el render.
const LOD: Dictionary = {"habilitado": true, "distancia": 160.0, "niveles": 4}

## ── Debug / profiling (§1, opcional en modo debug M110) ─────────────────
## Flags de monitoreo en debug (opcionales). El display real lo pinta M110.
const DEBUG_FLAGS: Dictionary = {
	"fps_counter": false,
	"profiling_gpu": false,
	"monitoreo_gpu_ram": false,
}

## ── Iluminación volumétrica (§1, por calidad) ────────────────────────────
## baja/media: off, alta: on (densidad media), ultra: alta calidad (densidad+alcance).
const VOLUMETRICO: Dictionary = {
	"baja": {"habilitado": false, "densidad": 0.0, "calidad": "baja"},
	"medio": {"habilitado": false, "densidad": 0.0, "calidad": "baja"},
	"alto": {"habilitado": true, "densidad": 0.1, "calidad": "media"},
	"ultra": {"habilitado": true, "densidad": 0.2, "calidad": "alta"},
}

## ── Anti-aliasing (§1) ───────────────────────────────────────────────────
const AA_OFF := "off"
const AA_FXAA := "fxaa"
const AA_MSAA_2X := "msaa_2x"
const AA_MSAA_4X := "msaa_4x"
const AA_TAA := "taa"
const AA_OPCIONES: Array[String] = [AA_OFF, AA_FXAA, AA_MSAA_2X, AA_MSAA_4X, AA_TAA]

## ── Upscaling (§1) ───────────────────────────────────────────────────────
const UP_OFF := "off"
const UP_FSR1 := "fsr_1_0"
const UP_FSR2 := "fsr_2_0"
const UP_DLSS := "dlss"
const UP_XESS := "xess"
const UPSCALING: Array[String] = [UP_OFF, UP_FSR1, UP_FSR2, UP_DLSS, UP_XESS]

## Escala de resolución válida (§1).
const ESCALAS: Array[float] = [0.5, 0.75, 1.0, 1.25, 1.5]

## ── VSync y FPS (§1) ─────────────────────────────────────────────────────
const VSYNC_OPCIONES: Array[int] = [0, 1, 2]
const FPS_OPCIONES: Array[int] = [30, 60, 120, 0]  # 0 = ilimitado

## ── Presets (§1) ─────────────────────────────────────────────────────────
## Cada preset define el juego completo de valores (diseño 03-Diseno.md §1).
const PRESETS: Dictionary = {
	"bajo": {
		"resolucion": "720p", "modo": MODO_PANTALLA_COMPLETA, "vsync": 0, "fps": 30,
		"escala": 0.5, "upscaling": UP_FSR1, "sombras": "baja", "texturas": "baja",
		"distancia": "baja", "efectos": "baja", "vegetacion": "baja", "agua": "baja",
		"particulas": "baja", "aa": AA_OFF, "aniso": 2, "post": false, "bloom": false,
		"motion_blur": false, "dof": false,
	},
	"medio": {
		"resolucion": "1080p", "modo": MODO_VENTANA, "vsync": 1, "fps": 60,
		"escala": 0.75, "upscaling": UP_FSR2, "sombras": "media", "texturas": "media",
		"distancia": "media", "efectos": "media", "vegetacion": "media", "agua": "media",
		"particulas": "media", "aa": AA_FXAA, "aniso": 4, "post": true, "bloom": true,
		"motion_blur": false, "dof": false,
	},
	"alto": {
		"resolucion": "1440p", "modo": MODO_VENTANA, "vsync": 2, "fps": 120,
		"escala": 1.0, "upscaling": UP_DLSS, "sombras": "alta", "texturas": "alta",
		"distancia": "alta", "efectos": "alta", "vegetacion": "alta", "agua": "alta",
		"particulas": "alta", "aa": AA_MSAA_2X, "aniso": 8, "post": true, "bloom": true,
		"motion_blur": false, "dof": false,
	},
	"ultra": {
		"resolucion": "4k", "modo": MODO_VENTANA, "vsync": 2, "fps": 0,
		"escala": 1.0, "upscaling": UP_XESS, "sombras": "ultra", "texturas": "ultra",
		"distancia": "ultra", "efectos": "ultra", "vegetacion": "ultra", "agua": "ultra",
		"particulas": "ultra", "aa": AA_TAA, "aniso": 16, "post": true, "bloom": true,
		"motion_blur": true, "dof": true,
	},
}

## ── Detección de hardware (§1) ───────────────────────────────────────────
## Umbrales para clasificar GPU/RAM/CPU en baja/media/alta/ultra.
const UMBRAL_RAM_GB: Dictionary = {"baja": 4, "media": 8, "alta": 16, "ultra": 32}
const UMBRAL_CPU_NUCLEOS: Dictionary = {"baja": 2, "media": 4, "alta": 8, "ultra": 16}

var _valores: Dictionary = {}
var _accesibilidad: Dictionary = {}
var _debug: Dictionary = {}
var _calidad: String = "media"

func _init() -> void:
	_valores = PRESETS["medio"].duplicate(true)
	_accesibilidad = ACCESIBILIDAD_DEFAULT.duplicate(true)
	_debug = DEBUG_FLAGS.duplicate(true)
	_calidad = "medio"

## Aplica un preset por id. Devuelve false si no existe.
func aplicar_preset(id: String) -> bool:
	if not PRESETS.has(id):
		return false
	_valores = (PRESETS[id] as Dictionary).duplicate(true)
	_calidad = id
	return true

## Preset activo: coincide con uno conocido o "personalizado".
func preset_actual() -> String:
	for id in PRESETS.keys():
		if _igual(_valores, PRESETS[id]):
			return String(id)
	return "personalizado"

## Valor actual de una clave (con fallback).
## No se llama get(): Object ya define get(StringName, Variant) y pisarlo
## rompe el contrato nativo (pitfall detectado al compilar).
func obtener(clave: String, fallback = null):
	return _valores.get(clave, fallback)

## Fija un valor. Devuelve false si la clave no existe en el preset base.
## No se llama set() por el mismo motivo que obtener().
func fijar(clave: String, valor) -> bool:
	if not PRESETS["medio"].has(clave):
		return false
	_valores[clave] = valor
	return true

## Todos los valores actuales (copia).
func valores() -> Dictionary:
	return _valores.duplicate(true)

## ── Cálculos derivados (§1) ──────────────────────────────────────────────

## Píxeles de sombra por calidad (mapas x resolución²).
static func pixeles_sombra(calidad: String) -> int:
	var s: Dictionary = SOMBRAS.get(calidad, SOMBRAS["media"])
	return int(s["mapas"]) * int(s["res"]) * int(s["res"])

## Multiplicador de distancia para la calidad dada.
static func distancia_metros(calidad: String) -> float:
	return float(DISTANCIA.get(calidad, DISTANCIA["media"]))

## Máximo de partículas por sistema para la calidad dada.
static func max_particulas(calidad: String) -> int:
	return int(PARTICULAS.get(calidad, PARTICULAS["media"]))

## Tamaño de ventana para una resolución (0,0 = nativa, se resuelve en runtime).
static func tamano_resolucion(id: String) -> Vector2i:
	for r in RESOLUCIONES:
		if String(r["id"]) == id:
			return Vector2i(int(r["ancho"]), int(r["alto"]))
	return Vector2i(1920, 1080)

## Relación de aspecto de la resolución (para letterbox/barras).
static func aspect_de_resolucion(id: String) -> float:
	var t: Vector2i = tamano_resolucion(id)
	if t.x <= 0 or t.y <= 0:
		return 16.0 / 9.0
	return float(t.x) / float(t.y)

## Resolución más cercana soportada a un tamaño dado.
static func resolucion_mas_cercana(ancho: int, alto: int) -> String:
	var mejor: String = "1080p"
	var mejor_d: float = 1e12
	for r in RESOLUCIONES:
		if int(r["ancho"]) <= 0:
			continue
		var d: float = absf(float(r["ancho"]) - float(ancho)) + absf(float(r["alto"]) - float(alto))
		if d < mejor_d:
			mejor_d = d
			mejor = String(r["id"])
	return mejor

## ── Recomendación por hardware (§1 Detección) ────────────────────────────

## Clasifica un valor de RAM (GB) en el vocabulario de calidad.
static func clasificar_ram(gb: float) -> String:
	if gb >= UMBRAL_RAM_GB["ultra"]:
		return "ultra"
	if gb >= UMBRAL_RAM_GB["alta"]:
		return "alta"
	if gb >= UMBRAL_RAM_GB["media"]:
		return "media"
	return "baja"

## Clasifica un número de núcleos de CPU.
static func clasificar_cpu(nucleos: int) -> String:
	if nucleos >= UMBRAL_CPU_NUCLEOS["ultra"]:
		return "ultra"
	if nucleos >= UMBRAL_CPU_NUCLEOS["alta"]:
		return "alta"
	if nucleos >= UMBRAL_CPU_NUCLEOS["media"]:
		return "media"
	return "baja"

## Recomienda preset desde (nombre_gpu, ram_gb, nucleos_cpu).
## Regla §1: gana la más baja de las tres (nunca recomendar más de lo que el
## hardware puede sostener). El nombre de GPU se clasifica por palabras clave.
static func recomendar_preset(gpu: String, ram_gb: float, nucleos: int) -> String:
	var por_gpu: String = _clasificar_gpu(gpu)
	var por_ram: String = clasificar_ram(ram_gb)
	var por_cpu: String = clasificar_cpu(nucleos)
	var orden: Array[String] = ["baja", "media", "alta", "ultra"]
	# Regla §1: gana la clasificacion MAS BAJA de las tres (mini, no maxi):
	# nunca se recomienda mas de lo que el hardware puede sostener. Con maxi una
	# GPU ultra con 4 GB de RAM recomendaba "ultra" y el juego no arrancaba.
	var peor: int = orden.size() - 1
	for c in [por_gpu, por_ram, por_cpu]:
		peor = mini(peor, orden.find(c))
	if peor < 0:
		peor = 0
	return orden[peor]

static func _clasificar_gpu(gpu: String) -> String:
	var g := gpu.to_lower()
	# Orden: de la gama más alta a la más baja, sin solaparse.
	if g.contains("rtx 40") or g.contains("rtx 50") or g.contains("rx 7") or g.contains("arc a"):
		return "ultra"
	if g.contains("rtx 30") or g.contains("rtx 20") or g.contains("rx 6") or g.contains("gtx 16") or g.contains("gtx 16"):
		return "alta"
	if g.contains("gtx 10") or g.contains("gtx 9") or g.contains("rx 5") or g.contains("rx 4") or g.contains("iris") or g.contains("vega"):
		return "media"
	return "baja"

## ── Persistencia (§1) ────────────────────────────────────────────────────

## Serializa a Dictionary JSON-safe (para settings de M46/M59).
func to_dict() -> Dictionary:
	return _valores.duplicate(true)

## Carga desde Dictionary. Los valores desconocidos se ignoran y los que falten
## toman el default del preset medio (migración suave).
func from_dict(d: Dictionary) -> void:
	var base: Dictionary = PRESETS["medio"].duplicate(true)
	for k in base.keys():
		if d.has(k):
			base[k] = d[k]
	_valores = base

## JSON de texto -> valores. Devuelve false si el JSON no parsea.
func from_json(txt: String) -> bool:
	var p: Variant = JSON.parse_string(txt)
	if not (p is Dictionary):
		return false
	from_dict(p as Dictionary)
	return true

## ── Sliders de post-processing (§1 intensidades) ─────────────────────────
## Rango [min, max] de cada slider para clamps de la UI.
const RANGOS_SLIDERS: Dictionary = {
	"bloom_intensidad": [0.0, 1.0],
	"bloom_threshold": [0.0, 1.0],
	"bloom_radius": [0.0, 1.0],
	"motion_blur_intensidad": [0.0, 1.0],
	"motion_blur_sample_count": [4, 16],
	"dof_distancia": [0.0, 100.0],
	"dof_apertura": [0.0, 1.0],
	"dof_intensidad": [0.0, 1.0],
	"fuente_escala": [0.5, 2.0],
	"distancia_dibujado": [300.0, 2500.0],
}

## Valores por defecto de cada slider (para presets que no los definen).
const SLIDERS_DEFAULT: Dictionary = {
	"bloom_intensidad": 0.5, "bloom_threshold": 0.7, "bloom_radius": 0.3,
	"motion_blur_intensidad": 0.5, "motion_blur_sample_count": 8,
	"dof_distancia": 10.0, "dof_apertura": 0.5, "dof_intensidad": 0.5,
	"fuente_escala": 1.0, "distancia_dibujado": 600.0,
}

## ── Accesibilidad (§1 Diseño) ────────────────────────────────────────────
## Opciones de accesibilidad (alto contraste, reducir mareo/distracción,
## escala de fuente). Valores por defecto.
const ACCESIBILIDAD_DEFAULT: Dictionary = {
	"alto_contraste": false,
	"reducir_motion": false,
	"reducir_bloom": false,
	"fuente_escala": 1.0,
}

## Devuelve los rangos [min, max] de cada slider.
func rangos_sliders() -> Dictionary:
	return RANGOS_SLIDERS


## Clamps un valor de slider al rango válido de su clave.
## Si la clave no existe en RANGOS_SLIDERS, usa el default.
func validar_slider(clave: String, valor: float) -> float:
	if RANGOS_SLIDERS.has(clave):
		var r: Array = RANGOS_SLIDERS[clave]
		return clampf(valor, float(r[0]), float(r[1]))
	return float(SLIDERS_DEFAULT.get(clave, valor))


## ── Aplicación de post-processing (M90 §1 toggles/activación) ───────────

## Mapeo LÓGICO de los toggles de post-processing (headless, sin RenderingServer).
## M90 §1: post=false apaga todo; si post=true, cada efecto se habilita solo si su
## toggle individual está activo. Devuelve un Dictionary con el estado efectivo.
func mapeo_post() -> Dictionary:
	var post: bool = bool(obtener("post", false))
	return {
		"post": post,
		"glow": bool(obtener("bloom", false)) and post,
		"motion_blur": bool(obtener("motion_blur", false)) and post,
		"dof": bool(obtener("dof", false)) and post,
		"tonemapping": post,
		"aa": obtener("aa", AA_OFF),
	}

## Mapeo LÓGICO de culling (frustum + por distancia). headless, sin nodos.
func mapeo_culling() -> Dictionary:
	return {
		"frustum": bool(CULLING["frustum"]),
		"por_distancia": bool(CULLING["por_distancia"]),
		"cull_distance_metros": distancia_metros(String(obtener("distancia", "media"))),
	}

## Mapeo LÓGICO de los flags de debug/profiling (M110). headless.
func mapeo_debug() -> Dictionary:
	return _debug.duplicate(true)


## Fija un flag de debug. Devuelve false si la clave no es válida.
func fijar_debug(clave: String, valor: bool) -> bool:
	if not DEBUG_FLAGS.has(clave):
		return false
	_debug[clave] = valor
	return true


## Aplica el límite de FPS al motor (Engine.max_fps). Devuelve el cap aplicado.
## Si el valor del config no es una opción válida de FPS_OPCIONES, usa 60.
func apply_fps_cap() -> int:
	var cap: int = int(obtener("fps", 60))
	if not FPS_OPCIONES.has(cap):
		cap = 60
	Engine.max_fps = cap
	return cap


## Mapeo LÓGICO de upscaling (headless). Devuelve el upscaler efectivo + escala de
func mapeo_upscaling() -> Dictionary:
	var up: String = String(obtener("upscaling", UP_OFF))
	var escala: float = validar_slider("escala_render", float(obtener("escala", 1.0)))
	return {
		"upscaler": up,
		"escala_render": escala,
		"es_valido": UPSCALING.has(up),
	}

## Aplica el upscaler + escala de render a un Viewport. Null-safe (no-op si vp==null).
## Devuelve el mapeo. El set REAL de `render_scale`/upscaler depende del pipeline
## M90/M53 en runtime (SubViewport detached no setea render_scale en headless);
## este método expone el mapeo para el caller.
func aplicar_upscaling(vp) -> Dictionary:
	var m: Dictionary = mapeo_upscaling()
	if vp == null:
		return m
	# El set real (Viewport.render_scale + upscaler global) lo hace el pipeline M90/M53
	# al arrancar; aquí solo exponemos el mapeo. _set_upscaler_proyecto setea el flag.
	_set_upscaler_proyecto(String(m["upscaler"]))
	return m


## Mapea el upscaler a las ProjectSettings de upscaling de Godot 4.
func _set_upscaler_proyecto(up: String) -> void:
	var clave_base := "rendering/anti_aliasing/upscaling"
	match up:
		UP_OFF:
			ProjectSettings.set_setting(clave_base + "/enabled", false)
		UP_FSR1, UP_FSR2:
			ProjectSettings.set_setting(clave_base + "/enabled", true)
			ProjectSettings.set_setting(clave_base + "/fsr/quality", 1 if up == UP_FSR2 else 2)
		UP_DLSS, UP_XESS:
			# Requieren el plugin del vendor; dejo el flag on + la selección (el set real es del pipeline).
			ProjectSettings.set_setting(clave_base + "/enabled", true)


## Resolución como objeto {x, y} (píxeles), según el preset + escala de render.
## Usado por "Incluir resolución como objeto {x,y}" (M90).
func resolucion_vec2() -> Vector2i:
	var px: Dictionary = {
		"1080p": Vector2i(1920, 1080), "1440p": Vector2i(2560, 1440),
		"4k": Vector2i(3840, 2160), "720p": Vector2i(1280, 720),
	}
	var base: Vector2i = px.get(String(obtener("resolucion", "1080p")), Vector2i(1920, 1080))
	var escala: float = mapeo_upscaling()["escala_render"]
	return Vector2i(int(base.x * escala), int(base.y * escala))


## Mapeo LÓGICO de iluminación volumétrica según la calidad actual (§1).
## Baja/media: off; alta: on (densidad 0.1); ultra: alta calidad (densidad 0.2).
func mapeo_volumetrico() -> Dictionary:
	var calidad: String = _calidad
	var v: Dictionary = VOLUMETRICO.get(calidad, VOLUMETRICO["medio"])
	return {
		"habilitado": bool(v["habilitado"]),
		"densidad": float(v["densidad"]),
		"calidad": String(v["calidad"]),
	}

## Aplica la iluminación volumétrica a un Environment (WorldEnvironment). Null-safe
## (headless no-op si entorno==null). Usa `mapeo_volumetrico()` (lógica por calidad).
func aplicar_volumetrico(entorno) -> void:
	if entorno == null:
		return
	var v: Dictionary = mapeo_volumetrico()
	entorno.volumetric_fog_enabled = bool(v["habilitado"])
	if bool(v["habilitado"]):
		entorno.volumetric_fog_density = float(v["densidad"])


## Mapeo LÓGICO de LOD por objeto lejano. headless. La IMPL. depende de M50.
func mapeo_lod() -> Dictionary:
	var hab: bool = bool(LOD["habilitado"])
	return {
		"habilitado": hab,
		"distancia": float(LOD["distancia"]),
		"niveles": int(LOD["niveles"]),
		"depende_m50": hab,  # el LOD por objeto se resuelve con M50 (vegetación/objetos)
	}

## Mapeo LÓGICO de accesibilidad (§1 Diseño): estado efectivo de las opciones de
## accesibilidad + su interacción con post-processing. REDUCIR_MOTION/BLOOM apagan
## el efecto aunque el preset lo tenga activo (opción anti-mareo / anti-distracción).
func mapeo_accesibilidad() -> Dictionary:
	var m: Dictionary = mapeo_post()
	var alto_contraste: bool = bool(_accesibilidad.get("alto_contraste", false))
	var reducir_motion: bool = bool(_accesibilidad.get("reducir_motion", false))
	var reducir_bloom: bool = bool(_accesibilidad.get("reducir_bloom", false))
	var fuente_escala: float = validar_slider("fuente_escala", float(_accesibilidad.get("fuente_escala", SLIDERS_DEFAULT["fuente_escala"])))
	return {
		"alto_contraste": alto_contraste,
		"motion_blur": bool(m["motion_blur"]) and not reducir_motion,
		"glow": bool(m["glow"]) and not reducir_bloom,
		"fuente_escala": fuente_escala,
	}

## Devuelve una copia de los valores de accesibilidad actuales.
func acceder_accesibilidad() -> Dictionary:
	return _accesibilidad.duplicate(true)


## Fija un valor de accesibilidad. Devuelve false si la clave no es válida.
func fijar_accesibilidad(clave: String, valor) -> bool:
	if not ACCESIBILIDAD_DEFAULT.has(clave):
		return false
	_accesibilidad[clave] = valor
	return true


## Aplica los toggles de post-processing a un Environment (del WorldEnvironment).
## NULL-SAFE para headless: si `entorno` es null, no-op (no hay RenderingServer).
## Aplica lo que Godot 4 permite vía propiedades de Environment (glow); el resto
## (motion blur / DoF / tonemapping / AA) se expone vía `mapeo_post()` para la capa
## de render/UI (M53) y el RenderingServer en runtime.
func aplicar_env(entorno) -> void:
	if entorno == null:
		return
	var m: Dictionary = mapeo_post()
	# Glow (bloom). glow_bloom = intensidad. El threshold va vía `mapeo_post` para la UI.
	entorno.glow_enabled = bool(m["glow"])
	if bool(m["glow"]):
		entorno.glow_bloom = validar_slider("bloom_intensidad", float(obtener("bloom_intensidad", SLIDERS_DEFAULT["bloom_intensidad"])))


func _igual(a: Dictionary, b: Dictionary) -> bool:
	if a.size() != b.size():
		return false
	for k in a.keys():
		if not b.has(k):
			return false
		if typeof(a[k]) != typeof(b[k]):
			return false
		if a[k] is Dictionary:
			if not _igual(a[k], b[k]):
				return false
		elif a[k] != b[k]:
			return false
	return true
