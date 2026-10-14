# M90 Configuración Gráfica iter. 1 — núcleo GraphicsConfig.
# Modelo: step-5-kilocode (Kilo Code)
# Fecha: 2026-10-12
#
# Verifica el diseño de 03-Diseno.md §1 como núcleo puro:
#   Pantalla (resoluciones, aspect ratios, modos), Calidad (sombras, texturas,
#   distancia, efectos, vegetación, agua, partículas), Anti-aliasing, Upscaling,
#   Escala, VSync/FPS, Presets (bajo/medio/alto/ultra/personalizado) y
#   Detección de hardware con recomendación.
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/settings/test_graphics_config.gd

extends SceneTree

const CHECKS_MINIMOS: int = 80  # bajado de 85 a 80 el 2026-10-12 por orden del
# director mimo (msg 221): el test tiene ~86 checks reales (83 estaticos + 1 dentro
# de un bucle de 4), y un minimo de 85 dejaba margen de solo 1 check.
## Ademas del piso de checks, la suite debe cerrar sus 6 bloques:
## un abort a mitad de camino no puede pasar por verde.
const BLOQUES_MINIMOS: int = 6

const GC = preload("res://scripts/settings/graphics_config.gd")

var _checks: int = 0
var _fallos: int = 0
var _bloques: int = 0

func _init() -> void:
	call_deferred("_run")

func _ok(cond: bool, msg: String) -> void:
	_checks += 1
	if cond:
		print("  [ok] %s" % msg)
	else:
		_fallos += 1
		print("  FALLO: %s" % msg)

func _bloque(desc: String) -> void:
	_bloques += 1
	print("-- %s" % desc)

func _run() -> void:
	var cfg = GC.new()
	_ok(cfg != null, "GraphicsConfig instanciado")
	if cfg == null:
		_salir()
		return
	_test_pantalla(cfg)
	_test_calidad(cfg)
	_test_aa_upscaling(cfg)
	_test_presets(cfg)
	_test_deteccion(cfg)
	_test_persistencia(cfg)
	_salir()

func _salir() -> void:
	print("")
	print("=== RESUMEN M90 GRAPHICS: %d checks, %d fallos, %d bloques ===" % [_checks, _fallos, _bloques])
	if _fallos == 0 and _checks >= CHECKS_MINIMOS and _bloques >= BLOQUES_MINIMOS:
		print("RESULTADO: PASS (%d checks, %d bloques)" % [_checks, _bloques])
		quit(0)
		return  # FIX 2026-10-12 (step-5-kilocode): sin este return la ejecucion
		       # seguia y caia en el quit(1) de abajo, dejando EXIT 1 con 0 fallos.
	print("RESULTADO: FAIL (%d checks de %d, %d bloques de %d, %d fallos)" % [
		_checks, CHECKS_MINIMOS, _bloques, BLOQUES_MINIMOS, _fallos])
	quit(1)

# ── Pantalla (§1) ────────────────────────────────────────────────────────

func _test_pantalla(cfg) -> void:
	_bloque("1. Pantalla: resoluciones y modos")
	_ok(GC.RESOLUCIONES.size() == 5, "5 resoluciones definidas (dio %d)" % GC.RESOLUCIONES.size())
	var t720: Vector2i = GC.tamano_resolucion("720p")
	_ok(t720 == Vector2i(1280, 720), "720p = 1280x720 (dio %s)" % str(t720))
	_ok(GC.tamano_resolucion("1080p") == Vector2i(1920, 1080), "1080p = 1920x1080")
	_ok(GC.tamano_resolucion("1440p") == Vector2i(2560, 1440), "1440p = 2560x1440")
	_ok(GC.tamano_resolucion("4k") == Vector2i(3840, 2160), "4K = 3840x2160")
	_ok(GC.tamano_resolucion("nativa") == Vector2i(0, 0), "nativa = 0x0 (se resuelve en runtime)")
	# Aspect ratios soportados.
	_ok(GC.ASPECT_RATIOS.size() == 3, "3 aspect ratios: 16:9, 16:10, 21:9")
	_ok(absf(GC.aspect_de_resolucion("1080p") - 16.0 / 9.0) < 0.001, "1080p es 16:9")
	# Modos de pantalla.
	_ok(GC.MODOS.size() == 3, "3 modos: ventana, pantalla completa, borderless")
	_ok(GC.MODOS.has(GC.MODO_VENTANA) and GC.MODOS.has(GC.MODO_PANTALLA_COMPLETA) and GC.MODOS.has(GC.MODO_BORDERLESS),
		"los tres modos del diseño están")
	# Resolución más cercana (para monitores raros).
	_ok(GC.resolucion_mas_cercana(1920, 1080) == "1080p", "1920x1080 -> 1080p")
	_ok(GC.resolucion_mas_cercana(1366, 768) == "720p", "1366x768 -> 720p (la más cercana)")

# ── Calidad (§1) ─────────────────────────────────────────────────────────

func _test_calidad(cfg) -> void:
	_bloque("2. Calidad: sombras, texturas, distancia, partículas")
	# Sombras por calidad (cascadas/mapas/res/soft).
	_ok(GC.SOMBRAS["baja"]["cascadas"] == 1, "sombras baja: 1 cascada")
	_ok(GC.SOMBRAS["media"]["mapas"] == 2, "sombras media: 2 mapas")
	_ok(GC.SOMBRAS["alta"]["res"] == 2048, "sombras alta: 2048x2048")
	_ok(GC.SOMBRAS["ultra"]["res"] == 4096, "sombras ultra: 4096x4096")
	_ok(bool(GC.SOMBRAS["baja"]["soft"]) == false, "baja sin soft shadows")
	_ok(bool(GC.SOMBRAS["alta"]["soft"]) == true, "alta con soft shadows")
	_ok(bool(GC.SOMBRAS["ultra"]["soft"]) == true, "ultra con soft shadows")
	# Píxeles de sombra derivados.
	_ok(GC.pixeles_sombra("baja") == 512 * 512, "baja = 1x512² = 262144 px")
	_ok(GC.pixeles_sombra("alta") == 4 * 2048 * 2048, "alta = 4x2048² px")
	# Texturas (escala/mipmap/filtrado/aniso).
	_ok(GC.TEXTURAS["baja"]["escala"] == 0.5, "texturas baja: 0.5x")
	_ok(GC.TEXTURAS["baja"]["mipmap"] == 0, "baja sin mipmap")
	_ok(GC.TEXTURAS["media"]["mipmap"] == 1, "media mipmap 1")
	_ok(GC.TEXTURAS["ultra"]["mipmap"] == 3, "ultra mipmap 3")
	_ok(GC.TEXTURAS["media"]["filtrado"] == "trilinear", "filtrado trilinear")
	_ok(GC.TEXTURAS["baja"]["aniso"] == 2 and GC.TEXTURAS["ultra"]["aniso"] == 16,
		"anisotrópico 2x (baja) a 16x (ultra)")
	# Distancia.
	_ok(GC.distancia_metros("baja") == 300.0, "distancia baja 300 m")
	_ok(GC.distancia_metros("ultra") == 2500.0, "distancia ultra 2500 m")
	# Partículas.
	_ok(GC.max_particulas("baja") == 100, "partículas baja: 100")
	_ok(GC.max_particulas("media") == 500, "partículas media: 500")
	_ok(GC.max_particulas("alta") == 1000, "partículas alta: 1000")
	_ok(GC.max_particulas("ultra") == 2000, "partículas ultra: 2000")
	# Efectos/vegetación/agua: monótonos crecientes.
	_ok(float(GC.EFECTOS["baja"]) < float(GC.EFECTOS["ultra"]), "efectos crece con la calidad")
	_ok(float(GC.VEGETACION["media"]) < float(GC.VEGETACION["alta"]), "vegetación crece")

# ── AA / Upscaling / Escala / VSync / FPS ────────────────────────────────

func _test_aa_upscaling(cfg) -> void:
	_bloque("3. Anti-aliasing, upscaling, escala, VSync/FPS")
	_ok(GC.AA_OPCIONES.size() == 5, "5 opciones de AA (off/FXAA/MSAA 2x/MSAA 4x/TAA)")
	_ok(GC.UPSCALING.size() == 5, "5 opciones de upscaling (off/FSR 1.0/FSR 2.0/DLSS/XeSS)")
	_ok(GC.ESCALAS.size() == 5, "5 escalas: 50/75/100/125/150 %")
	_ok(GC.ESCALAS.has(0.5) and GC.ESCALAS.has(1.5), "escala mínima 50 % y máxima 150 %")
	_ok(GC.VSYNC_OPCIONES == [0, 1, 2], "VSync 0/1/2")
	_ok(GC.FPS_OPCIONES.size() == 4, "FPS: 30/60/120/ilimitado")
	_ok(GC.FPS_OPCIONES.has(0), "0 = ilimitado")

# ── Presets (§1) ─────────────────────────────────────────────────────────

func _test_presets(cfg) -> void:
	_bloque("4. Presets: bajo/medio/alto/ultra/personalizado")
	_ok(GC.PRESETS.size() == 4, "4 presets definidos")
	for id in ["bajo", "medio", "alto", "ultra"]:
		_ok(GC.PRESETS.has(id), "preset '%s' existe" % id)
	# Cada preset trae TODAS las claves.
	var base: Dictionary = GC.PRESETS["medio"]
	var completos: bool = true
	for id in GC.PRESETS.keys():
		for k in base.keys():
			if not (GC.PRESETS[id] as Dictionary).has(k):
				completos = false
	_ok(completos, "todos los presets traen el juego completo de claves")
	# Valores del diseño.
	_ok(GC.PRESETS["bajo"]["resolucion"] == "720p", "bajo: 720p")
	_ok(GC.PRESETS["bajo"]["vsync"] == 0, "bajo: VSync 0")
	_ok(GC.PRESETS["bajo"]["fps"] == 30, "bajo: 30 FPS")
	_ok(GC.PRESETS["bajo"]["escala"] == 0.5, "bajo: escala 50 %")
	_ok(GC.PRESETS["medio"]["resolucion"] == "1080p", "medio: 1080p")
	_ok(GC.PRESETS["medio"]["fps"] == 60, "medio: 60 FPS")
	_ok(GC.PRESETS["alto"]["resolucion"] == "1440p", "alto: 1440p")
	_ok(GC.PRESETS["alto"]["fps"] == 120, "alto: 120 FPS")
	_ok(GC.PRESETS["ultra"]["resolucion"] == "4k", "ultra: 4K")
	_ok(GC.PRESETS["ultra"]["fps"] == 0, "ultra: FPS ilimitado")
	# Aplicar y detectar.
	_ok(cfg.aplicar_preset("alto"), "aplicar_preset('alto') ok")
	_ok(cfg.preset_actual() == "alto", "preset_actual() = alto")
	_ok(cfg.obtener("resolucion") == "1440p", "el valor aplicado es 1440p")
	_ok(not cfg.aplicar_preset("no_existe"), "preset inexistente devuelve false")
	# Al cambiar un valor pasa a "personalizado".
	cfg.aplicar_preset("medio")
	cfg.fijar("fps", 45)
	_ok(cfg.preset_actual() == "personalizado", "un valor propio -> personalizado")
	# Clave inexistente se rechaza.
	_ok(not cfg.fijar("clave_inventada", 1), "fijar() con clave inexistente devuelve false")

# ── Detección de hardware (§1) ───────────────────────────────────────────

func _test_deteccion(cfg) -> void:
	_bloque("5. Detección de hardware y recomendación")
	_ok(GC.clasificar_ram(2.0) == "baja", "2 GB RAM -> baja")
	_ok(GC.clasificar_ram(8.0) == "media", "8 GB RAM -> media")
	_ok(GC.clasificar_ram(16.0) == "alta", "16 GB RAM -> alta")
	_ok(GC.clasificar_ram(64.0) == "ultra", "64 GB RAM -> ultra")
	_ok(GC.clasificar_cpu(2) == "baja", "2 núcleos -> baja")
	_ok(GC.clasificar_cpu(8) == "alta", "8 núcleos -> alta")
	# La recomendación usa la más baja de las tres (nunca sobre-recomienda).
	_ok(GC.recomendar_preset("RTX 4090", 64.0, 16) == "ultra", "hardware ultra -> ultra")
	_ok(GC.recomendar_preset("RTX 4090", 4.0, 16) == "baja", "GPU ultra + 4 GB RAM -> baja (manda la RAM)")
	_ok(GC.recomendar_preset("Intel HD Graphics", 32.0, 16) == "baja", "GPU débil manda aunque haya RAM")
	_ok(GC.recomendar_preset("GTX 1660", 16.0, 8) == "alta", "GTX 1660 + 16 GB + 8 núcleos -> alta")
	# Regla §1: gana la mas baja de las tres. GPU desconocida = baja, asi que
	# aunque haya 8 GB y 4 nucleos (media) la recomendacion es baja.
	_ok(GC.recomendar_preset("GPU desconocida", 8.0, 4) == "baja",
		"GPU desconocida manda: recomendacion baja (nunca sobre-recomendar)")

# ── Persistencia (§1) ────────────────────────────────────────────────────

func _test_persistencia(cfg) -> void:
	_bloque("6. Persistencia y migración suave")
	cfg.aplicar_preset("alto")
	cfg.fijar("fps", 90)  # personalizado
	var txt: String = JSON.stringify(cfg.to_dict())
	_ok(txt.length() > 10, "to_dict() serializa a JSON")
	var otro = GC.new()
	_ok(otro.from_json(txt), "from_json() ok")
	_ok(otro.preset_actual() == "personalizado", "el estado personalizado se conserva")
	_ok(otro.obtener("fps") == 90, "y el valor propio (90 FPS)")
	# Migración suave: JSON incompleto toma los defaults del preset medio.
	var par = GC.new()
	par.from_dict({"fps": 144})
	_ok(par.obtener("fps") == 144, "la clave presente se respeta")
	_ok(par.obtener("resolucion") == "1080p", "las claves que faltan toman el default (medio)")
	_ok(par.obtener("sombras") == "media", "default de sombras = media")
	# JSON inválido no rompe.
	_ok(not par.from_json("esto no es json"), "JSON inválido devuelve false")
	_ok(not par.from_json("[1,2,3]"), "un array tampoco es configuración válida")
