# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M148: Lore Ambiental — Test headless
# Valida: carga del catálogo data-driven, lookup por id, por isla (cobertura
# ≥ 12), por tipo, LoreAuditor (IDs únicos/canonRef/cobertura/grafo de
# pistas), TerrenoLoreService (secretos por temporada), persistencia de
# exploración. Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_CATALOGO := preload("res://scripts/lore/lore_catalogo.gd")
const _SC_AUDITOR := preload("res://scripts/lore/lore_auditor.gd")
const _SC_TERRENO := preload("res://scripts/lore/terreno_lore_service.gd")
const _SC_PIEZA := preload("res://scripts/lore/pieza_lore.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M148] Test de Lore Ambiental ===")
	_test_catalogo()
	_test_auditor()
	_test_terreno()
	_test_persistencia()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

## ── Catálogo ────────────────────────────────────────────

func _test_catalogo() -> void:
	print("--- LoreCatalogo: carga y lookup ---")
	var catalogo = _SC_CATALOGO.new()
	catalogo.cargar()
	_check("catálogo cargado", catalogo.cantidad_total() > 0, "total=%d" % catalogo.cantidad_total())
	_check("cobertura total ≥ 48 (12×4 islas)", catalogo.cantidad_total() >= 48, "total=%d" % catalogo.cantidad_total())
	var pieza = catalogo.obtener_pieza("ruina_costa_1")
	_check("lookup por id", pieza != null and pieza.id == "ruina_costa_1")
	_check("canon_ref no vacío", pieza != null and not pieza.canon_ref.is_empty(), "canon=%s" % (pieza.canon_ref if pieza else "?"))
	var raiz = catalogo.por_isla("raiz")
	var coral = catalogo.por_isla("coral")
	var ceniza = catalogo.por_isla("ceniza")
	var aurora = catalogo.por_isla("aurora")
	_check("cobertura raiz ≥ 12", raiz.size() >= 12, "size=%d" % raiz.size())
	_check("cobertura coral ≥ 12", coral.size() >= 12, "size=%d" % coral.size())
	_check("cobertura ceniza ≥ 12", ceniza.size() >= 12, "size=%d" % ceniza.size())
	_check("cobertura aurora ≥ 12", aurora.size() >= 12, "size=%d" % aurora.size())
	var murales = catalogo.por_tipo(_SC_PIEZA.Tipo.MURAL)
	_check("murales con pistas (4 islas)", murales.size() >= 4, "size=%d" % murales.size())
	var inexistente = catalogo.obtener_pieza("no_existe")
	_check("lookup inexistente -> null", inexistente == null)

## ── Auditor ─────────────────────────────────────────────

func _test_auditor() -> void:
	print("--- LoreAuditor: validación del catálogo ---")
	var catalogo = _SC_CATALOGO.new()
	catalogo.cargar()
	var errores = _SC_AUDITOR.validar(catalogo)
	_check("catálogo válido (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	var reporte := _SC_AUDITOR.reporte(errores)
	_check("reporte OK cuando limpio", reporte.contains("OK"))
	# catálogo con error a propósito (ID duplicado) -> detectado
	var malo = _SC_CATALOGO.new()
	var p1 = _SC_PIEZA.new()
	p1.id = "a"; p1.canon_ref = "x"; p1.tipo = 0; p1.isla = "raiz"
	var p2 = _SC_PIEZA.new()
	p2.id = "a"; p2.canon_ref = ""; p2.tipo = 0; p2.isla = "raiz"
	# Insertar dos piezas con el MISMO id directamente en el dict interno
	# (el _desde_dict sobrescribiría; el auditor debe detectar el duplicado real)
	malo._piezas["a"] = p1
	malo._piezas["a_dup"] = p2
	# Forzar que el auditor las vea como duplicadas: crear un diccionario donde
	# dos claves distintas apunten a piezas con el mismo id
	malo._piezas.erase("a_dup")
	malo._piezas["a2"] = p2
	p2.id = "a"  # ahora a y a2 tienen el mismo id "a"
	var errores_malos = _SC_AUDITOR.validar(malo)
	_check("ID duplicado detectado", errores_malos.size() >= 1 and str(errores_malos).contains("duplicado"))
	_check("canonRef vacío detectado", str(errores_malos).contains("canon_ref"))

## ── TerrenoLoreService ──────────────────────────────────

func _test_terreno() -> void:
	print("--- TerrenoLoreService: secretos por temporada ---")
	var terreno = _SC_TERRENO.new()
	terreno.cargar()
	var primavera = terreno.activar_temporada("primavera")
	var verano = terreno.activar_temporada("verano")
	var otono = terreno.activar_temporada("otono")
	var invierno = terreno.activar_temporada("invierno")
	_check("primavera tiene secretos", primavera.size() >= 1, "size=%d" % primavera.size())
	_check("verano tiene secretos", verano.size() >= 1)
	_check("otoño tiene secretos", otono.size() >= 1)
	_check("invierno tiene secretos", invierno.size() >= 1)
	_check("4 temporadas con al menos 1 secreto (3+ ubicaciones diseño)", primavera.size() + verano.size() + otono.size() + invierno.size() >= 4)
	_check("temporada desconocida -> vacío", terreno.activar_temporada("nada").size() == 0)

## ── Persistencia de exploración ─────────────────────────

func _test_persistencia() -> void:
	print("--- Persistencia de exploración (RF8) ---")
	var catalogo = _SC_CATALOGO.new()
	catalogo.cargar()
	var ids = catalogo.a_estado_exploracion()
	_check("estado exploración = todos los ids", ids.size() == catalogo.cantidad_total())
	var estado = _SC_CATALOGO.desde_estado_exploracion(ids)
	_check("estado como dict", estado.size() == catalogo.cantidad_total())
	_check("un id específico marcado", estado.has("ruina_costa_1"))

## ── Summary ──────────────────────────────────────────────

func _summary() -> void:
	print("=== Resumen M148: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M148 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M148 OK — todos los checks pasaron")
		quit(0)