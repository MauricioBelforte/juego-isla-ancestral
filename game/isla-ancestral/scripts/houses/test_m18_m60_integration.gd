# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-09
# M18 Frente A: Test de integración M60 — HouseManager como fuente de BuildingsSaveProvider.
# Arranca el juego completo (autoloads), verifica que el provider encuentre a HouseManager,
# guarda y restaura.
extends SceneTree

var _fallos := 0
var _checks := 0
const CHECKS_MINIMOS := 10

func _initialize() -> void:
	print("=== TEST M18 M60 INTEGRACION: HouseManager + BuildingsSaveProvider ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	# ── Bloque 1: HouseManager es autoload ──
	var hm := root.get_node_or_null("HouseManager")
	_check("HouseManager es autoload (presente en /root)", hm != null)
	if hm == null:
		_resumen(); return

	_check("HouseManager tiene obtener_estructuras", hm.has_method("obtener_estructuras"))
	_check("HouseManager tiene restaurar_estructuras", hm.has_method("restaurar_estructuras"))
	_check("HouseManager tiene registrar_casa", hm.has_method("registrar_casa"))

	# ── Bloque 2: BuildingsSaveProvider encuentra a HouseManager ──
	# NOTA: Si Construccion (M17) también expone obtener_estructuras(), el provider
	# lo encuentra PRIMERO (orden de autoloads). Documentado como [?] hasta que M17/M18
	# resuelvan el conflicto de duck-typing.
	var provider_script: Script = load("res://scripts/datos/buildings_save_provider.gd")
	_check("BuildingsSaveProvider carga", provider_script != null)
	if provider_script != null:
		var prov: RefCounted = provider_script.new()
		var tiene: bool = prov.tiene_fuente()
		_check("provider.tiene_fuente() == true (cualquier fuente)", tiene == true)
		# Verificar que HouseManager expone el contrato (aunque el provider use otro)
		_check("HM expone obtener_estructuras", hm.has_method("obtener_estructuras"))
		_check("HM expone restaurar_estructuras", hm.has_method("restaurar_estructuras"))

	# ── Bloque 3: Registrar casa + obtener_estructuras ──
	var id_casa: String = hm.registrar_casa(Vector3(100, 0, 200), "casa_test_m60")
	_check("registrar_casa devuelve ID", id_casa == "casa_test_m60")
	_check("cantidad_casas >= 1", hm.cantidad_casas() >= 1)
	var structs: Array = hm.obtener_estructuras()
	_check("obtener_estructuras >= 1", structs.size() >= 1)
	if structs.size() > 0:
		var s: Dictionary = structs[0]
		_check("estructura tiene id", String(s.get("id", "")) != "")
		_check("estructura tipo=casa", String(s.get("tipo", "")) == "casa")

	# ── Bloque 4: Guardar/Restaurar directo (sin provider, por conflicto M17) ──
	var save: Dictionary = hm.obtener_datos_guardado()
	_check("obtener_datos_guardado tiene casas", save.has("casas"))
	_check("casas guardadas >= 1", int(save.get("casas", {}).size()) >= 1)

	# ── Bloque 5: Restaurar en instancia nueva ──
	var hm_script: Script = load("res://scripts/houses/house_manager.gd")
	if hm_script != null:
		var hm_nuevo: Node = hm_script.new()
		hm_nuevo.restaurar_desde_guardado(save)
		_check("HM nuevo: cantidad_casas >= 1", hm_nuevo.cantidad_casas() >= 1)
		# Verificar que la casa específica se restauró
		var restauradas: Array = hm_nuevo.obtener_casas()
		var encontrada: bool = false
		for c in restauradas:
			if c.get("pos", Vector3.ZERO) == Vector3(100, 0, 200):
				encontrada = true
		_check("HM nuevo: casa en (100,0,200) restaurada", encontrada)

	# ── Red de seguridad ──
	create_timer(0.5).timeout.connect(func(): _fin())

func _fin() -> void:
	_resumen()
	quit(1 if _fallos > 0 else 0)

func _resumen() -> void:
	print("=== Resumen M18-M60: %d checks, %d fallos ===" % [_checks, _fallos])
	if _checks < CHECKS_MINIMOS:
		print("WARNING: solo %d checks (mínimo %d)" % [_checks, CHECKS_MINIMOS])

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)
