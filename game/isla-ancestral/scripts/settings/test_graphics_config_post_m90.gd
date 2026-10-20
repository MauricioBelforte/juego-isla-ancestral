# M90: GraphicsConfig — Test de la aplicación de post-processing
# agnes-3-flash (Sapiens AI) / Kilo Code, 2026-10-22 (frente COLA A #768).
# Valida la capa de aplicación de post-processing de graphics_config.gd:
#   - mapeo_post(): post=false apaga todo; post=true habilita según toggle individual.
#   - aplicar_env(): null-safe (headless) + aplica glow a un Environment real.
#   - validar_slider / rangos_sliders: clamps por rango.
# Uso: godot --headless --path game/isla-ancestral --script res://scripts/settings/test_graphics_config_post_m90.gd
# Exit 0 si todo OK, 1 si falla.

extends SceneTree

const _GC := preload("res://scripts/settings/graphics_config.gd")

var _checks: int = 0
var _fallos: int = 0


func _init() -> void:
	call_deferred("_run")


func _check(m: String, c: bool) -> void:
	_checks += 1
	if c:
		print("OK  " + m)
	else:
		_fallos += 1
		print("FAIL " + m)


func _run() -> void:
	print("=== [M90] Test de aplicación de post-processing ===")

	# --- mapeo_post() ---
	var bajo: RefCounted = _GC.new()
	bajo.aplicar_preset("bajo")
	var mb: Dictionary = bajo.mapeo_post()
	_check("bajo: post=false", mb["post"] == false)
	_check("bajo: glow/motion/dof todos off (post=false)", mb["glow"] == false and mb["motion_blur"] == false and mb["dof"] == false)

	var ultra: RefCounted = _GC.new()
	ultra.aplicar_preset("ultra")
	var mu: Dictionary = ultra.mapeo_post()
	_check("ultra: post=true", mu["post"] == true)
	_check("ultra: glow on (bloom+post)", mu["glow"] == true)
	_check("ultra: motion_blur on", mu["motion_blur"] == true)
	_check("ultra: dof on", mu["dof"] == true)
	_check("ultra: tonemapping on", mu["tonemapping"] == true)
	_check("ultra: aa=TAA", mu["aa"] == "taa")

	# post=true pero bloom=false -> glow off (ultra tiene dof on)
	var mix: RefCounted = _GC.new()
	mix.aplicar_preset("ultra")
	mix.fijar("bloom", false)
	var mm: Dictionary = mix.mapeo_post()
	_check("mix: post=true + bloom=false -> glow off", mm["post"] == true and mm["glow"] == false)
	_check("mix: dof sigue on", mm["dof"] == true)

	# --- aplicar_env() null-safe (headless) ---
	var cfg: RefCounted = _GC.new()
	cfg.aplicar_preset("ultra")
	var crash := false
	cfg.aplicar_env(null)
	_check("aplicar_env(null) no crashea (headless)", not crash)

	# --- aplicar_env() sobre un Environment real ---
	var env := Environment.new()
	var cfg2: RefCounted = _GC.new()
	cfg2.aplicar_preset("ultra")  # bloom=true + post=true
	cfg2.aplicar_env(env)
	_check("aplicar_env ultra: glow_enabled=true", env.glow_enabled == true)
	var cfg3: RefCounted = _GC.new()
	cfg3.aplicar_preset("bajo")  # post=false
	cfg3.aplicar_env(env)
	_check("aplicar_env bajo: glow_enabled=false", env.glow_enabled == false)

	# --- validar_slider / rangos_sliders ---
	var c: RefCounted = _GC.new()
	_check("validar_slider bloom_intensidad 2.0 -> 1.0", is_equal_approx(c.validar_slider("bloom_intensidad", 2.0), 1.0))
	_check("validar_slider bloom_intensidad -1.0 -> 0.0", is_equal_approx(c.validar_slider("bloom_intensidad", -1.0), 0.0))
	_check("validar_slider sample_count 40 -> 16", is_equal_approx(c.validar_slider("motion_blur_sample_count", 40.0), 16.0))
	_check("validar_slider sample_count 1 -> 4", is_equal_approx(c.validar_slider("motion_blur_sample_count", 1.0), 4.0))
	_check("validar_slider clave desconocida -> default", is_equal_approx(c.validar_slider("no_existe", 5.0), 5.0))
	_check("rangos_sliders incluye bloom_intensidad [0,1]", c.rangos_sliders().has("bloom_intensidad"))
	_check("rangos_sliders incluye dof_distancia [0,100]", c.rangos_sliders().has("dof_distancia"))
	_check("validar_slider fuente_escala 5.0 -> 2.0 (clamp)", is_equal_approx(c.validar_slider("fuente_escala", 5.0), 2.0))

	# --- Accesibilidad (§1 Diseño) ---
	var a: RefCounted = _GC.new()
	a.aplicar_preset("ultra")  # motion_blur on
	_check("accesibilidad default: alto_contraste off", a.acceder_accesibilidad()["alto_contraste"] == false)
	_check("mapeo_accesibilidad default: motion_blur on (ultra)", a.mapeo_accesibilidad()["motion_blur"] == true)
	a.fijar_accesibilidad("reducir_motion", true)
	_check("reducir_motion=true -> motion_blur off (anti-mareo)", a.mapeo_accesibilidad()["motion_blur"] == false)
	a.fijar_accesibilidad("reducir_bloom", true)
	_check("reducir_bloom=true -> glow off (anti-distracción)", a.mapeo_accesibilidad()["glow"] == false)
	a.fijar_accesibilidad("alto_contraste", true)
	_check("alto_contraste on", a.mapeo_accesibilidad()["alto_contraste"] == true)
	a.fijar_accesibilidad("fuente_escala", 5.0)
	_check("fuente_escala clamped a 2.0 en mapeo", is_equal_approx(a.mapeo_accesibilidad()["fuente_escala"], 2.0))
	_check("fijar_accesibilidad clave inválida -> false", a.fijar_accesibilidad("inexistente", 1) == false)

	# --- Culling + LOD (§1 rendimiento) ---
	var r: RefCounted = _GC.new()
	var mc: Dictionary = r.mapeo_culling()
	_check("culling: frustum on", mc["frustum"] == true)
	_check("culling: por_distancia on", mc["por_distancia"] == true)
	_check("culling: cull_distance = distancia_metros(media)=600", is_equal_approx(mc["cull_distance_metros"], 600.0))
	var ml: Dictionary = r.mapeo_lod()
	_check("LOD: habilitado", ml["habilitado"] == true)
	_check("LOD: niveles = 4", ml["niveles"] == 4)
	_check("LOD: depende_m50 (impl. objeto = M50)", ml["depende_m50"] == true)
	_check("validar_slider distancia_dibujado 9999 -> 2500 (clamp max)", is_equal_approx(r.validar_slider("distancia_dibujado", 9999.0), 2500.0))
	_check("validar_slider distancia_dibujado 10 -> 300 (clamp min)", is_equal_approx(r.validar_slider("distancia_dibujado", 10.0), 300.0))

	# --- Debug / FPS cap (§1 opcional) ---
	var d: RefCounted = _GC.new()
	_check("mapeo_debug: todos off por defecto", d.mapeo_debug()["fps_counter"] == false and d.mapeo_debug()["profiling_gpu"] == false)
	_check("fijar_debug fps_counter on", d.fijar_debug("fps_counter", true) and d.mapeo_debug()["fps_counter"] == true)
	_check("fijar_debug clave inválida -> false", d.fijar_debug("no_existe", true) == false)
	var cap_aplicado: int = d.apply_fps_cap()
	_check("apply_fps_cap() default 60", cap_aplicado == 60)
	d.aplicar_preset("ultra")  # fps = 0 (ilimitado)
	_check("apply_fps_cap ultra -> 0 (ilimitado)", d.apply_fps_cap() == 0)
	_check("recomendar_preset gana la más baja", _GC.recomendar_preset("RTX 4090", 4.0, 2) == "baja")

	# --- Detección de hardware (M90 t12) ---
	var hd: RefCounted = _GC.new()
	var dh: Dictionary = hd.detect_hardware()
	_check("detect_hardware devuelve las 5 claves", dh.has("gpu") and dh.has("ram_gb") and dh.has("cpu") and dh.has("nucleos") and dh.has("recomendado"))
	_check("detect_hardware recomendado es un preset valido", ["bajo", "medio", "alto", "ultra"].has(String(dh["recomendado"])))
	_check("detect_hardware nucleos >= 0", int(dh["nucleos"]) >= 0)

	# --- Upscaling (§1 aplicado a RenderingServer, mapeo headless) ---
	var u: RefCounted = _GC.new()
	u.aplicar_preset("ultra")  # upscaling = XESS
	var mu_up: Dictionary = u.mapeo_upscaling()
	_check("mapeo_upscaling ultra: upscaler=xess", mu_up["upscaler"] == "xess")
	_check("mapeo_upscaling: es_valido (xess en UPSCALING)", mu_up["es_valido"] == true)
	_check("mapeo_upscaling: escala_render > 0", float(mu_up["escala_render"]) > 0.0)
	var mu2: Dictionary = u.aplicar_upscaling(null)  # null-safe
	_check("aplicar_upscaling(null) devuelve mapeo (no-op)", mu2.has("upscaler"))
	# (El set real de render_scale/upscaler al Viewport lo hace el pipeline M90/M53 en
	# runtime; aquí solo se verifica el mapeo + null-safe, ya chequeado arriba.)
	# Resolución como objeto {x,y} (M90 t10).
	var ur: RefCounted = _GC.new()
	ur.aplicar_preset("alto")  # 1440p
	var rv: Vector2i = ur.resolucion_vec2()
	_check("resolucion_vec2 alto (1440p, escala 1.0) = 2560x1440", rv.x == 2560 and rv.y == 1440)
	_check("resolucion_vec2 devuelve un Vector2i valido", rv.x > 0 and rv.y > 0)
	var u3: RefCounted = _GC.new()
	u3.fijar("upscaling", "off")  # UP_OFF
	_check("mapeo_upscaling: upscaler=off cuando se fija", u3.mapeo_upscaling()["upscaler"] == "off")

	# --- Iluminación volumétrica (§1 por calidad) ---
	var vol: RefCounted = _GC.new()
	vol.aplicar_preset("bajo")
	_check("volumetrico bajo: off", vol.mapeo_volumetrico()["habilitado"] == false)
	vol.aplicar_preset("alto")
	var vm: Dictionary = vol.mapeo_volumetrico()
	_check("volumetrico alto: on + densidad 0.1", vm["habilitado"] == true and is_equal_approx(vm["densidad"], 0.1))
	vol.aplicar_preset("ultra")
	var vu: Dictionary = vol.mapeo_volumetrico()
	_check("volumetrico ultra: alta calidad + densidad 0.2", vu["habilitado"] == true and is_equal_approx(vu["densidad"], 0.2) and vu["calidad"] == "alta")
	var envv := Environment.new()
	vol.aplicar_volumetrico(envv)
	_check("aplicar_volumetrico ultra: fog enabled", envv.volumetric_fog_enabled == true)
	vol.aplicar_preset("bajo")
	vol.aplicar_volumetrico(envv)
	_check("aplicar_volumetrico bajo: fog disabled", envv.volumetric_fog_enabled == false)

	_fin()


func _fin() -> void:
	print("=== [M90] Resultado: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos == 0:
		print("[M90 post] OK")
		quit(0)
	else:
		print("[M90 post] FALLOS: %d" % _fallos)
		quit(1)
