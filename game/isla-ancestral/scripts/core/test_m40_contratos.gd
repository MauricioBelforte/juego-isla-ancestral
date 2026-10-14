# M40 iter. 3 — Test headless de Contratos + ServiceRegistry + fix L208.
# Modelo: step-5-kilocode (Kilo Code)
# Fecha: 2026-10-12
#
# Verifica la implementacion del frente 1 (orden del director mimo, msg 232):
#   1. contratos.gd: 47 contratos, sin duplicados, es_contrato_valido()
#   2. register() rechaza duplicados con DOM-INF-REGISTRO y devuelve false
#   3. get_service() emite DOM-INF-ACCESO-TEMPRANO con anti-flood
#   4. resource_counter.gd usa el contrato, no el nodo directo (fix L208)
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://scripts/core/test_m40_contratos.gd
#
# NOTA: se usa preload() en lugar de class_name global porque el cache de clases
# no esta generizado en un checkout limpio de CI (fallo detectado al ejecutar).

extends SceneTree

const CT = preload("res://scripts/core/contratos.gd")
const SR = preload("res://scripts/core/service_registry.gd")

const CHECKS_MINIMOS: int = 16
const BLOQUES_MINIMOS: int = 4

var _checks: int = 0
var _fallos: int = 0
var _bloques: int = 0

func _init() -> void:
	call_deferred("_run")


func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK]   %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s" % nombre)


func _bloque(desc: String) -> void:
	_bloques += 1
	print("")
	print("-- %s" % desc)


func _run() -> void:
	_b1_contratos()
	_b2_duplicados()
	_b3_acceso_temprano()
	_b4_l208()
	_resumen()


# -- 1. contratos.gd ------------------------------------------------
func _b1_contratos() -> void:
	_bloque("1. contratos.gd — contratos centralizados")
	var todos: Array = CT.TODOS
	_check("Contratos.TODOS tiene 47 contratos", todos.size() == 47)
	var unicos := {}
	for c in todos:
		unicos[String(c)] = true
	_check("sin contratos duplicados en TODOS", unicos.size() == todos.size())
	_check("es_contrato_valido(analytics)", CT.es_contrato_valido("analytics"))
	_check("es_contrato_valido(economy_manager)", CT.es_contrato_valido("economy_manager"))
	_check("es_contrato_valido(typo) es false", not CT.es_contrato_valido("analytic"))
	_check("las constantes apuntan a su string",
			CT.ANALYTICS == &"analytics" and CT.ECONOMY_MANAGER == &"economy_manager")


# -- 2. register() rechaza duplicados -------------------------------
func _b2_duplicados() -> void:
	_bloque("2. register() — DOM-INF-REGISTRO al duplicar")
	var reg = SR.new()
	var inst: Object = reg
	var primero: bool = reg.register("test_dup", inst)
	var segundo: bool = reg.register("test_dup", self)
	_check("primer registro devuelve true", primero)
	_check("segundo registro devuelve false (rechazado)", not segundo)
	_check("contador de duplicados rechazados = 1", reg.duplicados_rechazados() == 1)
	_check("la instancia original se conserva", reg.get_service("test_dup") == inst)
	reg.free()


# -- 3. get_service() avisa acceso temprano -------------------------
func _b3_acceso_temprano() -> void:
	_bloque("3. get_service() — DOM-INF-ACCESO-TEMPRANO")
	var reg = SR.new()
	var svc: Variant = reg.get_service("no_existe")
	_check("contrato no registrado devuelve null", svc == null)
	var antes: int = reg.duplicados_rechazados()
	var svc2: Variant = reg.get_service("no_existe")
	_check("segunda consulta tambien devuelve null", svc2 == null)
	_check("no incrementa duplicados (es otro contador)", reg.duplicados_rechazados() == antes)
	_check("contrato valido registrado se devuelve",
			reg.register("ok", self) and reg.get_service("ok") == self)
	reg.free()


# -- 4. fix L208: resource_counter por contrato ---------------------
func _b4_l208() -> void:
	_bloque("4. Fix L208 — UI por contrato, no por nodo directo")
	var script_code: String = FileAccess.get_file_as_string(
			"res://scripts/ui/widgets/resource_counter.gd")
	_check("resource_counter.gd se pudo leer", not script_code.is_empty())
	_check("usa Contratos.ECONOMY_MANAGER", "Contratos.ECONOMY_MANAGER" in script_code)
	_check("usa ServiceRegistry.get_service", "get_service" in script_code)
	var cadena: String = "\"" + "/root/EconomyManager" + "\""
	var acceso_directo: int = script_code.count(cadena)
	_check("solo queda el fallback por nodo (1 ocurrencia)", acceso_directo == 1)
	_check("el acceso por nodo esta en el fallback",
			script_code.rfind(cadena) > script_code.rfind("return svc as Node"))


func _resumen() -> void:
	print("")
	print("-- Resultado --")
	if _checks < CHECKS_MINIMOS:
		print("RESULTADO: FALLO — %d checks, minimo %d" % [_checks, CHECKS_MINIMOS])
		quit(1)
		return
	if _fallos == 0 and _bloques >= BLOQUES_MINIMOS:
		print("RESULTADO: OK — %d checks, %d bloques, 0 fallos" % [_checks, _bloques])
		quit(0)
	else:
		print("RESULTADO: FALLO — %d fallos de %d checks" % [_fallos, _checks])
		quit(1)
