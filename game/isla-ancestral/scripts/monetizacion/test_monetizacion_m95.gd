# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M95: Monetización — Test headless
# Valida: EdicionCatalogo (3 ediciones, historia completa), DlcCatalogo
# (roadmap, DLC cosmético no toca progresión), ScannerAntip2w (detección),
# ScannerAntilootbox (detección de cajas de azar).
# Exit code != 0 si falla.

extends SceneTree

const _SC_EDICION := preload("res://scripts/monetizacion/edicion_catalogo.gd")
const _SC_DLC := preload("res://scripts/monetizacion/dlc_catalogo.gd")
const _SC_P2W := preload("res://scripts/monetizacion/scanner_antip2w.gd")
const _SC_LOOTBOX := preload("res://scripts/monetizacion/scanner_antilootbox.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M95] Test de Monetización ===")
	_test_ediciones()
	_test_dlc()
	_test_antip2w()
	_test_antilootbox()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_ediciones() -> void:
	print("--- Ediciones: Standard/Deluxe/Coleccionista ---")
	var e = _SC_EDICION.new()
	e.cargar()
	_check("3 ediciones", e.cantidad() == 3, "count=%d" % e.cantidad())
	_check("standard existe", not e.obtener("standard").is_empty())
	_check("deluxe existe", not e.obtener("deluxe").is_empty())
	_check("coleccionista existe", not e.obtener("coleccionista").is_empty())
	_check("standard historia completa", e.contiene_historia_completa("standard"))
	_check("deluxe historia completa", e.contiene_historia_completa("deluxe"))
	_check("coleccionista historia completa", e.contiene_historia_completa("coleccionista"))
	_check("inexistente -> {} y false", e.obtener("no_existe").is_empty() and not e.contiene_historia_completa("no_existe"))
	_check("standard precio 24.99", int(e.obtener("standard").get("precio_usd", 0) * 100) == 2499, "precio=%s" % e.obtener("standard").get("precio_usd", "?"))

func _test_dlc() -> void:
	print("--- DLC: roadmap expansión + cosmético ---")
	var d = _SC_DLC.new()
	d.cargar()
	_check("2 DLC planificados", d.cantidad() == 2, "count=%d" % d.cantidad())
	_check("DLC-1 expansión", d.obtener("dlc_expansion").get("tipo", "") == "expansion")
	_check("DLC-2 cosmético", d.obtener("dlc_cosmetico").get("tipo", "") == "cosmetico")
	_check("DLC-2 no es cosmético? no", d.es_cosmetico("dlc_cosmetico"))
	_check("DLC-1 no es cosmético (es expansión)", not d.es_cosmetico("dlc_expansion"))
	var ruta = d.roadmap()
	_check("roadmap ordenado (2 items)", ruta.size() == 2)
	_check("roadmap orden: expansión primero", String(ruta[0].get("id", "")) == "dlc_expansion")

func _test_antip2w() -> void:
	print("--- AntiP2W: detección de ítems que alteran progresión ---")
	var limpio = _SC_P2W.escanear([])
	_check("catálogo vacío -> OK", limpio.is_empty())
	var items = [
		{"id": "sombrero", "tipo": "cosmetico", "afecta_progresion": false},
		{"id": "acelerador", "tipo": "acelerador", "afecta_progresion": true},
		{"id": "pocion", "tipo": "ventaja", "afecta_progresion": false},
	]
	var violaciones = _SC_P2W.escanear(items)
	_check("acelerador detectado (P2W)", violaciones.size() >= 1 and str(violaciones).contains("acelerador"))
	_check("poción tipo ventaja detectada", str(violaciones).contains("pocion"))
	# acelerador = 2 violaciones (afecta_progresion + tipo), pocion = 1 => total 3
	_check("sombrero NO detectado (cosmético)", violaciones.size() == 3 and not str(violaciones).contains("sombrero"), "size=%d" % violaciones.size())
	var back_to_clean = _SC_P2W.escanear([{"id": "sombrero", "tipo": "cosmetico", "afecta_progresion": false}])
	_check("solo cosmético -> OK", back_to_clean.is_empty())
	_check("reporte OK cuando limpio", _SC_P2W.reporte([]).contains("OK"))

func _test_antilootbox() -> void:
	print("--- AntiLootbox: detección de cajas de azar ---")
	var limpio = _SC_LOOTBOX.escanear([])
	_check("sin sistemas -> OK", limpio.is_empty())
	var sistemas = [
		{"id": "cofre_pesca", "tipo": "pesca", "aleatorio": true, "requiere_pago": false, "unica_via": false},
		{"id": "caja_misteriosa", "tipo": "lootbox", "aleatorio": true, "requiere_pago": true, "unica_via": false},
		{"id": "regalo_azar", "tipo": "evento", "aleatorio": true, "requiere_pago": false, "unica_via": true},
	]
	var violaciones = _SC_LOOTBOX.escanear(sistemas)
	_check("caja_misteriosa detectada (pago+azar)", violaciones.size() >= 1 and str(violaciones).contains("caja_misteriosa"))
	_check("cofre de pesca NO detectado (azar sin pago)", not str(violaciones).contains("cofre_pesca"))
	_check("regalo_azar detectado (azar+exclusivo)", str(violaciones).contains("regalo_azar"))
	_check("reporte OK cuando limpio", _SC_LOOTBOX.reporte([]).contains("OK"))

func _summary() -> void:
	print("=== Resumen M95: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M95 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M95 OK — todos los checks pasaron")
		quit(0)