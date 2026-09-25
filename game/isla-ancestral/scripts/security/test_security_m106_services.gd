# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-25
#
# M106: Seguridad — Test de los servicios offline (OutputValidator, TamperProtection,
# DuplicationPrevention, EconomyValidation, AuditLogger, APISecurity, SecurityConfig).
# Lógica pura + headless-safe. Guardián anti-falso-verde de 3 capas:
#   (1) marcadores `_fin("X")` por bloque + `_summary` que NOMBRA los bloques que faltaron;
#   (2) piso `CHECKS_MINIMOS` medido en verde;
#   (3) aserciones que pueden fallar (nada de `_check(true, …)`).
# Vector SHA-256 verificado contra el estándar y HMAC contra `hmac` de Python.

extends SceneTree

const _OUT := preload("res://scripts/security/security_output_validator.gd")
const _TAMPER := preload("res://scripts/security/security_tamper_protection.gd")
const _DUP := preload("res://scripts/security/security_duplication_prevention.gd")
const _ECO := preload("res://scripts/security/security_economy_validation.gd")
const _AUDIT := preload("res://scripts/security/security_audit_logger.gd")
const _API := preload("res://scripts/security/security_api_security.gd")
const _CFG := preload("res://scripts/security/security_config.gd")

const BLOQUES := ["A", "B", "C", "D", "E", "F", "G"]
const CHECKS_MINIMOS := 60

# Vectores de referencia (independientes del motor).
const SHA256_ABC := "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
const HMAC_KEY_MSG := "2d93cbc1be167bcb1637a4a23cbff01a7878f0c50ee833954ea5221bb1b8c628"

var _fallos: int = 0
var _checks: int = 0
var _vistos: Dictionary = {}
var _bloque: String = ""

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")   # si _run() aborta, la cola diferida sigue y esto CORRE igual

func _run() -> void:
	print("=== [M106] Test servicios offline ===")
	_bloque = "A"; _test_output()
	_bloque = "B"; _test_tamper()
	_bloque = "C"; _test_duplicacion()
	_bloque = "D"; _test_economia()
	_bloque = "E"; _test_audit()
	_bloque = "F"; _test_api()
	_bloque = "G"; _test_config()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _fin(nombre: String) -> void:
	_vistos[nombre] = true

## ── A. OutputValidator ───────────────────────────────────
func _test_output() -> void:
	print("--- A. OutputValidator (SHA-256 / checksum / firma / json) ---")
	var v = _OUT.new()
	_check("sha256('abc') = vector estandar", v.calcular_sha256("abc") == SHA256_ABC)
	_check("sha256('') = e3b0c442…", v.calcular_sha256("").begins_with("e3b0c442"))
	_check("checksum correcto -> true", v.validar_checksum("abc", SHA256_ABC))
	_check("checksum incorrecto -> false", not v.validar_checksum("abc", "00"))
	_check("checksum distinto dato -> false", not v.validar_checksum("abd", SHA256_ABC))
	_check("firma-digest correcta -> true", v.validar_firma("abc", SHA256_ABC, "pub"))
	_check("firma-digest incorrecta -> false", not v.validar_firma("abc", "malo", "pub"))
	var esq := {"a": TYPE_INT, "b": TYPE_STRING}
	_check("json schema ok", v.validar_json({"a": 1, "b": "x"}, esq))
	_check("json schema falta clave -> false", not v.validar_json({"a": 1}, esq))
	_check("json schema tipo malo -> false", not v.validar_json({"a": "1", "b": "x"}, esq))
	_fin("A")

## ── B. TamperProtection ──────────────────────────────────
func _test_tamper() -> void:
	print("--- B. TamperProtection (checksum / HMAC / savegame) ---")
	var t = _TAMPER.new()
	_check("calcular_checksum = sha256", t.calcular_checksum("abc") == SHA256_ABC)
	_check("HMAC vector Python (key,msg)", t.calcular_hmac("msg", "key") == HMAC_KEY_MSG)
	_check("HMAC clave larga (>64B) distinta", t.calcular_hmac("datos", "k".repeat(80)) == "cdce77410699bccbddbd9cf9c27d5ced18a5efcc02a4c74c1191b8c043e55f09")
	var save := {"nivel": 5, "oro": 100, "zona": "muelle"}
	var ck: String = t.calcular_checksum(t._canonico(save))
	_check("savegame checksum valido -> true", t.validar_savegame(save, ck))
	_check("savegame manipulado -> false", not t.validar_savegame({"nivel": 999, "oro": 100, "zona": "muelle"}, ck))
	var firma: String = t.calcular_hmac(t._canonico(save), "secreto")
	_check("firma HMAC valida -> true", t.validar_savegame_firma(save, firma, "secreto"))
	_check("firma HMAC con secreto malo -> false", not t.validar_savegame_firma(save, firma, "otro"))
	# el canónico es independiente del orden de inserción
	var save_reordenado := {"zona": "muelle", "oro": 100, "nivel": 5}
	_check("checksum independiente del orden", t.validar_savegame(save_reordenado, ck))
	_fin("B")

## ── C. DuplicationPrevention ─────────────────────────────
func _test_duplicacion() -> void:
	print("--- C. DuplicationPrevention (idempotencia / anti-replay) ---")
	var d = _DUP.new()
	var id1: String = d.generar_request_id()
	var id2: String = d.generar_request_id()
	_check("ids generados no vacios", not id1.is_empty() and not id2.is_empty())
	_check("ids unicos", id1 != id2)
	_check("no procesado al inicio", not d.ya_procesado(id1))
	_check("marcar 1ª vez -> true", d.marcar_procesado(id1, 1000))
	_check("ya procesado tras marcar", d.ya_procesado(id1))
	_check("marcar 2ª vez -> false (duplicado)", not d.marcar_procesado(id1, 1001))
	_check("cantidad = 1", d.cantidad_procesados() == 1)
	d.marcar_procesado(d.generar_request_id(), 1000)
	d.marcar_procesado(d.generar_request_id(), 1000)
	_check("cantidad = 3", d.cantidad_procesados() == 3)
	# limpieza: con ahora=1000+3601 las 3 expiran
	_check("limpiar_antiguos borra expirados", d.limpiar_antiguos(4601, 3600) == 3)
	_check("quedan 0", d.cantidad_procesados() == 0)
	# dentro de la ventana no borra
	d.marcar_procesado("x", 5000)
	_check("limpiar dentro de ventana no borra", d.limpiar_antiguos(5100, 3600) == 0)
	_fin("C")

## ── D. EconomyValidation ─────────────────────────────────
func _test_economia() -> void:
	print("--- D. EconomyValidation (limites + checksum) ---")
	var e = _ECO.new(1000, 99)
	_check("economia legitima -> true", e.validar_economia({"oro": 500, "inventario": [{"cantidad": 10}]}))
	_check("oro negativo -> false", not e.validar_economia({"oro": -1}))
	_check("oro sobre max -> false", not e.validar_economia({"oro": 1001}))
	_check("oro en el limite -> true", e.validar_economia({"oro": 1000}))
	_check("item sobre max -> false", not e.validar_economia({"oro": 0, "inventario": [{"cantidad": 100}]}))
	_check("item negativo -> false", not e.validar_economia({"oro": 0, "inventario": [{"cantidad": -5}]}))
	_check("sin campos -> true", e.validar_economia({}))
	# vocabulario del diseño (gold/inventory/quantity)
	_check("claves del diseño (gold/inventory)", e.validar_economia({"gold": 10, "inventory": [{"quantity": 2}]}))
	_check("gold sobre max -> false", not e.validar_economia({"gold": 5000}))
	# checksum
	var datos := {"oro": 42, "inventario": [{"cantidad": 1}]}
	var ck: String = e.calcular_checksum_economia(datos)
	_check("checksum economia valido -> true", e.validar_economia_checksum(datos, ck))
	_check("checksum economia manipulado -> false", not e.validar_economia_checksum({"oro": 43, "inventario": []}, ck))
	_fin("D")

## ── E. AuditLogger ───────────────────────────────────────
func _test_audit() -> void:
	print("--- E. AuditLogger (registro / formato / volcado) ---")
	var a = _AUDIT.new()
	var e1: Dictionary = a.registrar("jugador", "login", true, 1234.0)
	_check("registro devuelto con campos", e1.has("timestamp") and e1.get("usuario") == "jugador")
	_check("formato SUCCESS", "SUCCESS" in a.formatear(e1))
	var e2: Dictionary = a.registrar("jugador", "cambio_config", false, 1235.0)
	_check("formato FAILURE", "FAILURE" in a.formatear(e2))
	_check("cantidad = 2", a.cantidad() == 2)
	var ruta := "user://m106_audit_test/audit.json"
	_check("guardar -> true (crea dir)", a.guardar(ruta))
	_check("archivo existe", FileAccess.file_exists(ruta))
	var leido: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	var es_array: bool = typeof(leido) == TYPE_ARRAY
	var n_leidos: int = 0
	if es_array:
		var arr: Array = leido
		n_leidos = arr.size()
	_check("JSON parseable con 2 entradas", es_array and n_leidos == 2)
	a.limpiar()
	_check("limpiar deja 0", a.cantidad() == 0)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta))
	_fin("E")

## ── F. APISecurity ───────────────────────────────────────
func _test_api() -> void:
	print("--- F. APISecurity (auth + rate limit + señales) ---")
	var api = _API.new()
	var visto := {"auth": -1, "limite": 0}
	api.api_autenticada.connect(func(exito: bool) -> void: visto["auth"] = 1 if exito else 0)
	api.limite_tasa_excedido.connect(func() -> void: visto["limite"] += 1)
	_check("sin clave -> autenticar false (fail-closed)", not api.autenticar({"Authorization": "Bearer x"}))
	_check("señal auth emitida (false)", visto["auth"] == 0)
	_check("cargar_api_key -> true", api.cargar_api_key({"API_KEY": "secreta"}))
	_check("clave correcta -> true", api.autenticar({"Authorization": "Bearer secreta"}))
	_check("señal auth emitida (true)", visto["auth"] == 1)
	_check("clave incorrecta -> false", not api.autenticar({"Authorization": "Bearer otra"}))
	api.configurar_limite_tasa(60.0, 3)
	_check("3 permitidas", api.verificar_limite() and api.verificar_limite() and api.verificar_limite())
	_check("4ª rechazada", not api.verificar_limite())
	_check("señal limite_tasa_excedido emitida", visto["limite"] == 1)
	api.reiniciar_contador()
	_check("tras reset -> permitida", api.verificar_limite())
	_check("request_count = 1", api.request_count == 1)
	_check("rate_limit_timer = ventana", is_equal_approx(api.rate_limit_timer, 60.0))
	_fin("F")

## ── G. SecurityConfig ────────────────────────────────────
func _test_config() -> void:
	print("--- G. SecurityConfig (Resource) ---")
	var c = _CFG.new()
	_check("api_rate_limit default 100", c.api_rate_limit == 100)
	_check("max_gold default 1000000", c.max_gold == 1000000)
	_check("max_items default 9999", c.max_items == 9999)
	_check("enable_checksum_validation default true", c.enable_checksum_validation)
	_check("enable_economy_validation default true", c.enable_economy_validation)
	var d: Dictionary = c.como_diccionario()
	_check("como_diccionario tiene 8 claves", d.size() == 8)
	_check("como_diccionario expone max_gold", d.get("max_gold") == 1000000)
	c.max_gold = 500
	_check("mutacion de propiedad", c.como_diccionario().get("max_gold") == 500)
	_fin("G")

## Guardián de 3 capas: nombra bloques faltantes y exige el piso de checks.
func _summary() -> void:
	var faltantes: Array = []
	for n in BLOQUES:
		if not _vistos.has(n):
			faltantes.append(n)
	if not faltantes.is_empty():
		_fallos += 1
		print("[FAIL] bloques que NO se ejecutaron (posible SCRIPT ERROR): %s" % str(faltantes))
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M106-servicios: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M106-SERVICIOS FALLIDO — salida con codigo 1")
		quit(1)
	else:
		print("TEST M106-SERVICIOS OK — todos los checks pasaron")
		quit(0)
