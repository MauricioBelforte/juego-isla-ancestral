# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M131: Créditos - Test headless iter 2 (minimax-m3).
# Cubre CreditsManager: carga catalogo, secciones, navegacion,
# conmutacion de idioma, copyright/year, validacion, senales.

extends SceneTree

const RUTA_DATA := "res://data/legal/creditos.json"

var _fallos: int = 0
var _checks: int = 0
var _mgr: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M131] Test iter 2: CreditsManager ===")
	_mgr = root.get_node_or_null("credits_manager")
	_check(_mgr != null, "credits_manager autoload presente (iter 2)")
	if _mgr == null:
		_summary()
		quit(1 if _fallos > 0 else 0)
		return
	_test_carga()
	_test_cantidad()
	_test_seccion_por_indice()
	_test_seccion_traducida()
	_test_navegacion_siguiente_anterior()
	_test_conmutar_idioma()
	_test_copyright_year()
	_test_validacion()
	_test_senales()
	_test_busqueda()
	_test_scroll_automatico()
	_test_accesibilidad()
	_test_traducir_titulo()
	_summary()

func _check(cond: bool, nombre: String, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_carga() -> void:
	var secs: Array = _mgr.obtener_secciones()
	var ok: bool = secs.size() >= 5
	_check(ok, ">=5 secciones cargadas (got %d)" % secs.size())

func _test_cantidad() -> void:
	var ok: bool = _mgr.cantidad_secciones() >= 5
	_check(ok, "cantidad_secciones() >= 5 (got %d)" % _mgr.cantidad_secciones())

func _test_seccion_por_indice() -> void:
	var sec0: Dictionary = _mgr.obtener_seccion(0)
	_check(sec0.has("id"), "seccion 0 tiene 'id'")
	_check(sec0.has("titulo"), "seccion 0 tiene 'titulo'")
	_check(sec0.has("entradas"), "seccion 0 tiene 'entradas'")
	# Fuera de rango
	var sec_fuera: Dictionary = _mgr.obtener_seccion(999)
	_check(sec_fuera.is_empty(), "seccion 999 -> {}")

func _test_seccion_traducida() -> void:
	# Es (default)
	var sec_es: Dictionary = _mgr.obtener_seccion(0)
	var titulo_es: String = String(sec_es.get("titulo", ""))
	_check(titulo_es == "Desarrollo", "seccion 0 en es = 'Desarrollo'")
	# Cambiar a en
	_mgr.cambiar_idioma("en")
	var sec_en: Dictionary = _mgr.obtener_seccion(0)
	var titulo_en: String = String(sec_en.get("titulo", ""))
	_check(titulo_en == "Development", "seccion 0 en en = 'Development'")
	# Cambiar musica en en
	var sec_mus: Dictionary = _mgr.obtener_seccion(1)
	var titulo_mus: String = String(sec_mus.get("titulo", ""))
	_check(titulo_mus == "Music and Sound", "musica en en = 'Music and Sound'")
	# Volver a es
	_mgr.cambiar_idioma("es")

func _test_navegacion_siguiente_anterior() -> void:
	_mgr.ir_a_seccion(0)
	var ok_id: bool = String(_mgr.obtener_seccion_actual().get("id", "")) == "desarrollo"
	_check(ok_id, "seccion actual = desarrollo")
	var ok_sig: bool = _mgr.siguiente_seccion()
	_check(ok_sig, "siguiente_seccion() retorno true")
	var ok_musica: bool = String(_mgr.obtener_seccion_actual().get("id", "")) == "musica"
	_check(ok_musica, "seccion actual = musica")
	var ok_ant: bool = _mgr.seccion_anterior()
	_check(ok_ant, "seccion_anterior() retorno true")
	var ok_vuelta: bool = String(_mgr.obtener_seccion_actual().get("id", "")) == "desarrollo"
	_check(ok_vuelta, "seccion actual = desarrollo (vuelta)")

func _test_conmutar_idioma() -> void:
	_check(_mgr.obtener_idioma() == "es", "idioma default = es")
	var ok_en: bool = _mgr.cambiar_idioma("en")
	_check(ok_en, "cambiar_idioma('en') = true")
	_check(_mgr.obtener_idioma() == "en", "idioma actual = en")
	var ok_dup: bool = not _mgr.cambiar_idioma("en")
	_check(ok_dup, "cambiar_idioma('en') otra vez = false (no cambio)")
	var ok_fr: bool = not _mgr.cambiar_idioma("fr")
	_check(ok_fr, "cambiar_idioma('fr') = false (no soportado)")
	_mgr.cambiar_idioma("es")  # reset

func _test_copyright_year() -> void:
	var cr: String = _mgr.obtener_copyright()
	_check(cr.contains("Isla Ancestral"), "copyright contiene 'Isla Ancestral'")
	_check(cr.contains("©"), "copyright contiene '©'")
	# Year debe ser razonable (>= 2024 y <= 2030)
	var year: int = _mgr.obtener_year()
	_check(year >= 2024 and year <= 2030, "year en rango razonable (got %d)" % year)

func _test_validacion() -> void:
	var errores: Array = _mgr.validar_catalogo()
	_check(errores.is_empty(), "validar_catalogo() = 0 errores (got %d)" % errores.size())

func _test_senales() -> void:
	var n_cambios_seccion: Array = [0]
	var n_cambios_idioma: Array = [0]
	_mgr.seccion_cambiada.connect(func(_id, _idx): n_cambios_seccion[0] += 1)
	_mgr.idioma_cambiado.connect(func(_n): n_cambios_idioma[0] += 1)
	_mgr.ir_a_seccion(0)
	_mgr.siguiente_seccion()
	_mgr.siguiente_seccion()
	_mgr.cambiar_idioma("en")
	_mgr.cambiar_idioma("es")
	_check(n_cambios_seccion[0] >= 2, "seccion_cambiada emitida >= 2 veces (got %d)" % n_cambios_seccion[0])
	_check(n_cambios_idioma[0] >= 2, "idioma_cambiado emitida >= 2 veces (got %d)" % n_cambios_idioma[0])

## ── Tests M131 iter 2 (minimax-m3) ─────────────────────────

func _test_busqueda() -> void:
	# Busqueda vacia: 0 matches
	_check(_mgr.buscar("").size() == 0, "buscar('') = 0 matches")
	# Busqueda por entrada: "Desarrollo" en seccion desarrollo
	var matches_d: Array = _mgr.buscar("desarrollo")
	_check(matches_d.size() > 0, "buscar('desarrollo') encuentra matches (got %d)" % matches_d.size())
	# El primer match tiene seccion_id = 'desarrollo'
	if matches_d.size() > 0:
		_check(String(matches_d[0].get("seccion_id", "")) == "desarrollo", "primer match = 'desarrollo'")
	# Busqueda por titulo: "musica" matchea seccion musica
	var matches_m: Array = _mgr.buscar("musica")
	_check(matches_m.size() > 0, "buscar('musica') encuentra matches (got %d)" % matches_m.size())
	# Busqueda case-insensitive
	var matches_caps: Array = _mgr.buscar("QA")
	_check(matches_caps.size() > 0, "buscar('QA') case-insensitive encuentra matches")
	# Sin matches
	var matches_none: Array = _mgr.buscar("xyznoexiste123")
	_check(matches_none.size() == 0, "buscar('xyznoexiste123') = 0 matches")
	# Matches ordenados por score
	if matches_d.size() >= 2:
		var first_score: int = int(matches_d[0].get("matches", 0))
		var last_score: int = int(matches_d[-1].get("matches", 0))
		_check(first_score >= last_score, "resultados ordenados por score (primero %d >= ultimo %d)" % [first_score, last_score])

func _test_scroll_automatico() -> void:
	_mgr.ir_a_seccion(0)
	# Velocidad > 0 y no estamos al final
	var ok: bool = _mgr.scroll_automatico(1.0)
	_check(ok, "scroll_automatico(1.0) retorna true")
	_check(_mgr.obtener_seccion_actual().get("id", "") == "musica", "scroll avanzo a 'musica' (got '%s')" % String(_mgr.obtener_seccion_actual().get("id", "")))
	# Velocidad <= 0: false
	var no_ok: bool = not _mgr.scroll_automatico(0.0)
	_check(no_ok, "scroll_automatico(0.0) = false")

func _test_accesibilidad() -> void:
	# color_contraste_accesible: fondo oscuro -> texto blanco
	var c_oscuro: Color = _mgr.color_contraste_accesible(Color(0.1, 0.1, 0.1))
	_check(c_oscuro.r > 0.8, "fondo oscuro: texto claro (r=%.2f)" % c_oscuro.r)
	# Fondo claro -> texto oscuro
	var c_claro: Color = _mgr.color_contraste_accesible(Color(0.9, 0.9, 0.9))
	_check(c_claro.r < 0.2, "fondo claro: texto oscuro (r=%.2f)" % c_claro.r)
	# Tamano de fuente base: minimo 12
	_check(_mgr.tamano_fuente_base(1.0) >= 12, "tamano_fuente_base(1.0) >= 12")
	_check(_mgr.tamano_fuente_base(1.5) == 24, "tamano_fuente_base(1.5) = 24 (got %d)" % _mgr.tamano_fuente_base(1.5))
	# Minimo 12 incluso con escala baja
	_check(_mgr.tamano_fuente_base(0.5) >= 12, "tamano_fuente_base(0.5) >= 12 (minimo)")

func _test_traducir_titulo() -> void:
	# Helper interno (pero accesible)
	var titulo_es: String = _mgr._traducir_titulo("desarrollo")
	_check(titulo_es == "Desarrollo", "_traducir_titulo('desarrollo') en es = 'Desarrollo'")
	_mgr.cambiar_idioma("en")
	var titulo_en: String = _mgr._traducir_titulo("desarrollo")
	_check(titulo_en == "Development", "_traducir_titulo('desarrollo') en en = 'Development'")
	_mgr.cambiar_idioma("es")
	# ID no existente: fallback
	var titulo_fallback: String = _mgr._traducir_titulo("id_inexistente")
	_check(titulo_fallback == "", "_traducir_titulo('id_inexistente') = vacio")

func _summary() -> void:
	print("=== Resumen M131 iter 2: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M131 iter 2 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M131 iter 2 OK — todos los checks pasaron")
		quit(0)
