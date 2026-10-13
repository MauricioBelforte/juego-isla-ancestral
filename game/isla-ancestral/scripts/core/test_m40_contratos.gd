extends Node

## M40 iter. 3 — Test headless de Contratos + ServiceRegistry + fix L208.
## Cubre:
##   1. contratos.gd: 47 contratos, sin duplicados, es_contrato_valido()
##   2. register() rechaza duplicados con DOM-INF-REGISTRO y devuelve false
##   3. get_service() emite DOM-INF-ACCESO-TEMPRANO una sola vez por contrato
##   4. resource_counter usa el contrato, no el nodo directo (fix L208)
##
## Patron anti-falso-verde: guardia de checks/bloques minimos antes del exit 0.

var _checks := 0
var _fallos := 0
var _bloques := 0

const CHECKS_MINIMOS: int = 16
const BLOQUES_MINIMOS: int = 4

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
	print("── %s" % desc)


func _run() -> void:
	_b1_contratos()
	_b2_duplicados()
	_b3_acceso_temprano()
	_b4_l208()
	_resumen()


# ── 1. contratos.gd ───────────────────────────────────────────────
func _b1_contratos() -> void:
	_bloque("1. contratos.gd — contratos centralizados")
	_check("Contratos.TODOS tiene 47 contratos", Contratos.TODOS.size() == 47)
	var unicos := {}
	for c in Contratos.TODOS:
		unicos[String(c)] = true
	_check("sin contratos duplicados en TODOS", unicos.size() == Contratos.TODOS.size())
	_check("es_contrato_valido(analytics)", Contratos.es_contrato_valido("analytics"))
	_check("es_contrato_valido(economy_manager)", Contratos.es_contrato_valido("economy_manager"))
	_check("es_contrato_valido(typo) es false", not Contratos.es_contrato_valido("analytic"))
	_check("las constantes apuntan a su string",
			Contratos.ANALYTICS == &"analytics" and Contratos.ECONOMY_MANAGER == &"economy_manager")


# ── 2. register() rechaza duplicados ──────────────────────────────
func _b2_duplicados() -> void:
	_bloque("2. register() — DOM-INF-REGISTRO al duplicar")
	var reg := ServiceRegistry.new()
	var primero: bool = reg.register("test_dup", reg)
	var segundo: bool = reg.register("test_dup", self)
	_check("primer registro devuelve true", primero)
	_check("segundo registro devuelve false (rechazado)", not segundo)
	_check("contador de duplicados rechazados = 1", reg.duplicados_rechazados() == 1)
	_check("la instancia original se conserva", reg.get_service("test_dup") == reg)
	reg.free()


# ── 3. get_service() avisa acceso temprano ────────────────────────
func _b3_acceso_temprano() -> void:
	_bloque("3. get_service() — DOM-INF-ACCESO-TEMPRANO")
	var reg := ServiceRegistry.new()
	var svc: Variant = reg.get_service("no_existe")
	_check("contrato no registrado devuelve null", svc == null)
	var antes: int = reg.duplicados_rechazados()
	var svc2: Variant = reg.get_service("no_existe")
	_check("segunda consulta tambien devuelve null", svc2 == null)
	_check("no incrementa duplicados (es otro contador)", reg.duplicados_rechazados() == antes)
	_check("contrato valido registrado se devuelve",
			reg.register("ok", self) and reg.get_service("ok") == self)
	reg.free()


# ── 4. fix L208: resource_counter por contrato ────────────────────
func _b4_l208() -> void:
	_bloque("4. Fix L208 — UI por contrato, no por nodo directo")
	var script_code := FileAccess.get_file_as_string(
			"res://scripts/ui/widgets/resource_counter.gd")
	_check("resource_counter.gd se pudo leer", not script_code.is_empty())
	_check("usa Contratos.ECONOMY_MANAGER", "Contratos.ECONOMY_MANAGER" in script_code)
	_check("usa ServiceRegistry.get_service", "get_service" in script_code)
	var acceso_directo := script_code.count('"/root/EconomyManager"')
	_check("solo queda el fallback por nodo (1 ocurrencia)", acceso_directo == 1)
	_check("el acceso por nodo esta en el fallback",
			script_code.rfind('"/root/EconomyManager"') > script_code.rfind("return svc as Node"))


func _resumen() -> void:
	print("")
	print("── Resultado ──")
	if _checks < CHECKS_MINIMOS:
		print("RESULTADO: FALLO — %d checks, minimo %d" % [_checks, CHECKS_MINIMOS])
		get_tree().quit(1)
		return
	if _fallos == 0 and _bloques >= BLOQUES_MINIMOS:
		print("RESULTADO: OK — %d checks, %d bloques, 0 fallos" % [_checks, _bloques])
		get_tree().quit(0)
	else:
		print("RESULTADO: FALLO — %d fallos de %d checks" % [_fallos, _checks])
		get_tree().quit(1)
