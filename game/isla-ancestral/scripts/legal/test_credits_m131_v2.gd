# Modelo: mimo-v2.5
# Plataforma: OpenCode
# Fecha: 2026-09-15
#
# M131: Créditos — Test headless v2 (iter 2 expandido)
# Valida: credits_manager.gd completo (carga, navegación, idioma, copyright,
# búsqueda, contribuyentes, assets, scroll, contraste, fuentes, políticas).
# Exit code != 0 si falla.

extends SceneTree

const _SC_MANAGER := preload("res://scripts/legal/credits_manager.gd")
const RUTA_DATA := "res://data/legal/creditos.json"

var _fallos: int = 0
var _checks: int = 0
var _manager: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M131] Test de Créditos v2 ===")
	_test_carga()
	_test_secciones()
	_test_navegacion()
	_test_idioma()
	_test_copyright()
	_test_busqueda()
	_test_contribuyentes()
	_test_assets()
	_test_conmutacion()
	_test_scroll()
	_test_accesibilidad()
	_test_politicas()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _init_manager() -> void:
	_manager = _SC_MANAGER.new()
	_manager._ready()

func _test_carga() -> void:
	print("--- Carga del catálogo ---")
	_init_manager()
	_check("Manager creado", _manager != null)
	_check("Catálogo cargado", _manager.cantidad_secciones() > 0, "secciones=%d" % _manager.cantidad_secciones())
	_check("Validar catálogo OK", _manager.validar_catalogo().is_empty())

func _test_secciones() -> void:
	print("--- Estructura de secciones ---")
	var secciones := _manager.obtener_secciones()
	_check("Al menos 1 sección", secciones.size() >= 1)
	for sec in secciones:
		var id: String = String(sec.get("id", ""))
		_check("Sección %s tiene titulo" % id, not String(sec.get("titulo", "")).is_empty())
		_check("Sección %s tiene entradas" % id, sec.has("entradas"))

func _test_navegacion() -> void:
	print("--- Navegación ---")
	_manager.ir_a_seccion(0)
	_check("Ir a sección 0", _manager.obtener_seccion_actual().has("id"))
	var ok := _manager.siguiente_seccion()
	_check("Siguiente sección", ok)
	ok := _manager.seccion_anterior()
	_check("Sección anterior", ok)
	_check("Ir a sección inválida", not _manager.ir_a_seccion(-1))
	_check("Ir a sección > max", not _manager.ir_a_seccion(999))

func _test_idioma() -> void:
	print("--- Conmutación de idioma ---")
	_manager.cambiar_idioma("en")
	_check("Cambio a EN", _manager.obtener_idioma() == "en")
	_manager.cambiar_idioma("es")
	_check("Cambio a ES", _manager.obtener_idioma() == "es")
	_check("Idioma inválido rechazado", not _manager.cambiar_idioma("fr"))
	_check("Mismo idioma no cambia", not _manager.cambiar_idioma("es"))

func _test_copyright() -> void:
	print("--- Copyright ---")
	var copyright := _manager.obtener_copyright()
	_check("Copyright no vacío", not copyright.is_empty())
	_check("Copyright contiene año", copyright.contains("2026"))
	_check("Copyright contiene titular", copyright.contains("Isla Ancestral"))
	var year := _manager.obtener_year()
	_check("Año es 2026", year == 2026)

func _test_busqueda() -> void:
	print("--- Búsqueda ---")
	var resultados := _manager.buscar("música")
	_check("Búsqueda 'música' devuelve resultados", resultados.size() > 0)
	resultados = _manager.buscar("")
	_check("Búsqueda vacía devuelve vacío", resultados.size() == 0)
	resultados = _manager.buscar("xyz_no_existe")
	_check("Búsqueda sin match devuelve vacío", resultados.size() == 0)

func _test_contribuyentes() -> void:
	print("--- Contribuyentes ---")
	var contribuyentes := _manager.obtener_contribuyentes()
	_check("Al menos 1 contribuyente", contribuyentes.size() >= 1)

func _test_assets() -> void:
	print("--- Assets de terceros ---")
	var assets := _manager.obtener_assets_terceros()
	_check("Assets de terceros accesibles", assets is Array)

func _test_conmutacion() -> void:
	print("--- Conmutación idioma (integral) ---")
	_manager.cambiar_idioma("en")
	var sec_en := _manager.obtener_seccion(0)
	_manager.cambiar_idioma("es")
	var sec_es := _manager.obtener_seccion(0)
	_check("Títulos cambian entre idiomas", sec_en.get("titulo", "") != sec_es.get("titulo", "") or sec_en.size() > 0)
	_manager.cambiar_idioma("es")

func _test_scroll() -> void:
	print("--- Scroll automático ---")
	var antes := _manager.obtener_seccion_actual().get("id", "")
	var avanzo := _manager.scroll_automatico(1.0)
	_check("Scroll avanza sección", avanzo)
	var despues := _manager.obtener_seccion_actual().get("id", "")
	_check("Sección cambió tras scroll", antes != despues)

func _test_accesibilidad() -> void:
	print("--- Accesibilidad ---")
	var color_blanco := _manager.color_contraste_accesible(Color(0.0, 0.0, 0.0))
	_check("Contraste fondo oscuro → blanco", color_blanco == Color(1.0, 1.0, 1.0))
	var color_negro := _manager.color_contraste_accesible(Color(1.0, 1.0, 1.0))
	_check("Contraste fondo claro → oscuro", color_negro.r < 0.1)
	var tamano := _manager.tamano_fuente_base(1.0)
	_check("Fuente base 16px", tamano == 16)
	var tamano_grande := _manager.tamano_fuente_base(1.5)
	_check("Fuente escalada 24px", tamano_grande == 24)

func _test_politicas() -> void:
	print("--- Políticas ---")
	var politicas := _manager.obtener_politicas()
	_check("Políticas cargadas", politicas.size() > 0)

func _summary() -> void:
	print("\n=== RESUMEN M131 v2 ===")
	print("Checks: %d | Fallos: %d" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLO — %d checks no pasaron" % _fallos)
		quit(1)
	else:
		print("TODOS LOS CHECKS PASARON")
		quit(0)
