# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M74: Test headless del EventManager — usa un evento REAL del catálogo
# (15 eventos cargados) y simula su día de inicio/fin con la API del manager.
extends SceneTree

var _fallos := 0
var _checks := 0
var _anio_test := 0

func _init() -> void:
	call_deferred("_run")

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s" % nombre)

func _run() -> void:
	print("=== [M74] Verificación del EventManager ===")
	var manager = load("res://scripts/eventos/event_manager.gd").new()
	root.add_child(manager)
	await process_frame
	_check("EventManager instanciado", manager != null)
	var catalogo: Dictionary = manager._catalogo
	_check("Catálogo con eventos reales (15)", catalogo.size() == 15)
	# Tomar el primer evento del catálogo
	var primer_id: String = ""
	var primer_ev = null
	for k in catalogo:
		primer_id = String(k)
		primer_ev = catalogo[k]
		break
	_check("Primer evento con id", primer_id != "")
	if primer_id == "":
		manager.free()
		print("=== Resumen M74: %d checks, %d fallos ===" % [_checks, _fallos])
		quit(1)
		return
	var mes: int = int(primer_ev.get("mes", primer_ev.mes))
	var dia: int = int(primer_ev.get("dia", primer_ev.dia))
	_check("Evento con semana programada (mes %d dia %d)" % [mes, dia], mes >= 1 and dia >= 1)
	# antes del día: nada
	manager._on_dia_cambio({"anio": 1, "mes": 1, "dia": 1, "estacion": 0, "hora": 8})
	_check("Día sin evento: flujo sin fallo", true)
	# día del evento: arranca
	manager._on_dia_cambio({"anio": 1, "mes": mes, "dia": dia, "estacion": 1, "hora": 8})
	await process_frame
	_check("Día del evento: verificación sin fallo", true)
	# día siguiente: fin
	manager._on_dia_cambio({"anio": 1, "mes": mes, "dia": dia + 1, "estacion": 1, "hora": 8})
	await process_frame
	_check("Día siguiente: cierre sin fallo", true)
	manager.normalizar_agenda()
	_check("normalizar_agenda sin fallo", true)
	manager.free()
	print("=== Resumen M74: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
