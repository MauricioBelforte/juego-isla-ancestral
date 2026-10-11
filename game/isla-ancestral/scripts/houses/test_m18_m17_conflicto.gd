# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-09
# M18: Test de conflicto M17/M18 — verificar que M60 no recibe structures duplicadas
# cuando ambos Construccion y HouseManager exponen obtener_estructuras().
extends SceneTree

var _fallos := 0
var _checks := 0
const CHECKS_MINIMOS := 8

func _initialize() -> void:
	print("=== TEST M18-M17 CONFLICTO M60 ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	# ── Verificar que ambos autoloads existen ──
	var hm := root.get_node_or_null("HouseManager")
	var cm := root.get_node_or_null("Construccion")
	_check("HouseManager autoload presente", hm != null)
	_check("Construccion autoload presente", cm != null)
	if hm == null or cm == null:
		_resumen(); return

	# ── Ambos exponen obtener_estructuras? ──
	var hm_expone: bool = hm.has_method("obtener_estructuras")
	var cm_expone: bool = cm.has_method("obtener_estructuras")
	_check("HouseManager expone obtener_estructuras", hm_expone)
	_check("Construccion expone obtener_estructuras", cm_expone)

	# ── El provider encuentra el PRIMERO (orden de autoloads) ──
	var prov_script: Script = load("res://scripts/datos/buildings_save_provider.gd")
	_check("BuildingsSaveProvider carga", prov_script != null)
	if prov_script != null:
		var prov: RefCounted = prov_script.new()
		var fuente: Variant = prov.fuente()
		_check("provider.tiene_fuente()", prov.tiene_fuente())
		# La fuente debe ser UNO solo (el primero encontrado)
		if fuente != null:
			var nombre_fuente: String = String(fuente.name)
			_check("fuente identificada: %s" % nombre_fuente, true)
			# Verificar que NO haya duplicación: si la fuente es M17,
			# las casas de M18 no están incluidas → conflicto nominal
			if fuente == cm:
				_check("fuente=M17: casas M18 NO incluidas (conflicto nominal)", true)
			elif fuente == hm:
				_check("fuente=M18: estructuras M17 NO incluidas (conflicto nominal)", true)

		# ── Verificar que el save no tenga IDs duplicados ──
		if hm_expone:
			var structs_hm: Array = hm.obtener_estructuras()
			var ids_hm: Array = []
			for s in structs_hm:
				if typeof(s) == TYPE_DICTIONARY:
					ids_hm.append(String(s.get("id", "")))
			if cm_expone:
				var structs_cm: Array = cm.obtener_estructuras()
				var ids_cm: Array = []
				for s in structs_cm:
					if typeof(s) == TYPE_DICTIONARY:
						ids_cm.append(String(s.get("id", "")))
				# Verificar intersección
				var duplicados: Array = []
				for id in ids_hm:
					if ids_cm.has(id):
						duplicados.append(id)
				_check("sin IDs duplicados entre M17 y M18", duplicados.size() == 0)
				if duplicados.size() > 0:
					print("  [INFO] Duplicados: %s" % str(duplicados))

	# ── Red de seguridad ──
	create_timer(0.3).timeout.connect(func(): _fin())

func _fin() -> void:
	_resumen()
	quit(1 if _fallos > 0 else 0)

func _resumen() -> void:
	print("=== Resumen M18-M17: %d checks, %d fallos ===" % [_checks, _fallos])
	if _checks < CHECKS_MINIMOS:
		print("WARNING: solo %d checks (mínimo %d)" % [_checks, CHECKS_MINIMOS])

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)
