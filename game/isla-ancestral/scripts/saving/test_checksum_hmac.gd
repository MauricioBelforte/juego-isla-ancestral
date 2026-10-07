# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-06
#
# Cola M59 / BUG-115: el token de integridad pasa de SHA-256 en claro a
# HMAC-SHA256 con clave por instalacion (`hmac256:<hex>`), RETROCOMPATIBLE con
# los saves previos (token sin prefijo = SHA-256 legado, se sigue aceptando).
# Ademas se endurece SaveSchema.validate(), que era VACUA: su unico chequeo de
# rango leia `time.day`, clave que el proveedor real de tiempo (M29) NUNCA
# emite (usa hora/minuto/dia/mes/anio/acumulador) -> codigo muerto.
#
# Guardia anti-falso-verde de 3 capas (misma doctrina que M59/M62):
#   1) _fin(clave) cierra cada bloque: un bloque que no cierra NO corrio.
#   2) CHECKS_MINIMOS: piso MEDIDO EN VERDE (no estimado, no copiado).
#   3) _summary() en call_deferred separado: sobrevive a un SCRIPT ERROR que
#      aborte _run() y decide el exit code. Sin esto, un abort daria "0 fallos".
#
# RED por inyeccion (probado antes de confiar en el guardian):
#   - hacer que verificar_checksum() devuelva siempre true -> fallan los checks
#     de tampering (bloques B/C/E) y el end-to-end de corrupcion.
#   - quitar los _validar_entero_* del dialecto real -> fallan los checks de
#     validate() con hora/minuto/dia/mes/anio fuera de rango (bloque H).
#
# No usa class_name: evita depender del cache de clases globales en headless.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/saving/test_checksum_hmac.gd

extends SceneTree

## Piso de checks. MEDIDO en la primera corrida VERDE (38) y fijado aqui. Si el
## conteo baja del piso, un bloque dejo de ejercitarse (regresion o suite
## recortada) y la suite falla aunque no haya un FALLO explicito.
const CHECKS_MINIMOS: int = 38

## Slot real usado para el end-to-end (dentro de SLOT_COUNT=3).
const SLOT_PRUEBA: int = 3

var _checks: int = 0
var _fallos: int = 0
var _cerrados: Array[String] = []
var _abiertos: Dictionary = {}

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

# ── utilidades de reporte ────────────────────────────────────────────────

func _ok(cond: bool, msg: String) -> void:
	_checks += 1
	if cond:
		print("  [ok] %s" % msg)
	else:
		_fallos += 1
		print("  FALLO: %s" % msg)

func _abrir(clave: String, desc: String) -> void:
	_abiertos[clave] = desc
	print("-- bloque %s: %s" % [clave, desc])

func _fin(clave: String) -> void:
	_abiertos.erase(clave)
	_cerrados.append(clave)
	print("-- fin bloque %s" % clave)

# ── helpers de construccion / mutacion de documentos ─────────────────────

func _payload_str() -> String:
	return SaveWriter.serialize_payload(SaveSchema.default_payload("perfil_hmac"))

## Documento NUEVO (HMAC) valido.
func _doc_hmac() -> String:
	return SaveWriter.build_file_content(_payload_str())

## Documento LEGADO (SHA-256 en claro) valido, como los previos al fix.
func _doc_legado() -> String:
	var p := _payload_str()
	return SaveWriter.sha256_hex_str(p) + "\n" + p

## Muta el PAYLOAD de un documento (deja la linea del token intacta).
func _mutar_payload(doc: String) -> String:
	var nl := doc.find("\n")
	if nl <= 0:
		return doc
	var token := doc.substr(0, nl)
	var payload := doc.substr(nl + 1)
	if not payload.contains("\"day\":1,"):
		return doc
	return token + "\n" + payload.replace("\"day\":1,", "\"day\":9,")

## Muta el TOKEN de un documento (deja el payload intacto).
func _mutar_token(doc: String) -> String:
	var nl := doc.find("\n")
	if nl <= 0:
		return doc
	var token := doc.substr(0, nl)
	var payload := doc.substr(nl + 1)
	var i := token.length() - 1
	var c := token.substr(i, 1)
	var nuevo := "0" if c != "0" else "1"
	return token.substr(0, i) + nuevo + "\n" + payload

func _limpiar_slot() -> void:
	var dir := DirAccess.open(SaveSchema.SAVE_DIR)
	if dir == null:
		return
	for f in dir.get_files():
		if f.begins_with("slot_%d" % SLOT_PRUEBA):
			var _e := dir.remove(f)
	# La clave HMAC NO se borra: vive fuera de SAVE_DIR (user:// raiz) a proposito.

# ── bloques ──────────────────────────────────────────────────────────────

func _run() -> void:
	print("=== [SAVE] BUG-115: HMAC + validacion no vacua ===")

	_b_a_formato()
	_b_b_tamper_payload()
	_b_c_tamper_token()
	_b_d_legado_aceptado()
	_b_e_legado_tamper()
	_b_f_end_to_end()
	_b_g_clave_persistente()
	_b_h_validate_no_vacua()

## A) El documento nuevo lleva el prefijo HMAC y verifica.
func _b_a_formato() -> void:
	_abrir("A", "formato del token: hmac256:<hex>")
	var doc := _doc_hmac()
	var nl := doc.find("\n")
	var token := doc.substr(0, nl) if nl > 0 else ""
	_ok(token.begins_with(SaveWriter.CHECKSUM_PREFIX),
		"el token empieza con '%s' (dio '%s')" % [SaveWriter.CHECKSUM_PREFIX, token.substr(0, 12)])
	_ok(token.length() == SaveWriter.CHECKSUM_PREFIX.length() + 64,
		"token = prefijo + 64 hex (largo %d)" % token.length())
	var hex := token.substr(SaveWriter.CHECKSUM_PREFIX.length())
	_ok(hex.is_valid_hex_number(false), "el resto del token es hex valido")
	var parsed := SaveWriter.parse_document(doc)
	_ok(parsed.get("ok", false), "un documento HMAC recien firmado parsea OK")
	_ok(parsed.get("legacy", true) == false, "no se marca como legado")
	_fin("A")

## B) Corromper el payload de un documento HMAC se detecta.
func _b_b_tamper_payload() -> void:
	_abrir("B", "tampering del payload detectado (HMAC)")
	var doc := _doc_hmac()
	var mutado := _mutar_payload(doc)
	_ok(mutado != doc, "la mutacion del payload efectivamente cambio el documento")
	_ok(not SaveWriter.parse_document(mutado).get("ok", false),
		"payload mutado SIN refirmar -> rechazado")
	_fin("B")

## C) Corromper el token se detecta.
func _b_c_tamper_token() -> void:
	_abrir("C", "tampering del token detectado")
	var doc := _doc_hmac()
	var mutado := _mutar_token(doc)
	_ok(mutado != doc, "la mutacion del token efectivamente cambio el documento")
	_ok(not SaveWriter.parse_document(mutado).get("ok", false),
		"token mutado -> rechazado")
	_fin("C")

## D) RETROCOMPATIBILIDAD: un documento legado (SHA-256 en claro) se acepta.
func _b_d_legado_aceptado() -> void:
	_abrir("D", "retrocompatibilidad: SHA-256 legado se acepta")
	var doc := _doc_legado()
	var parsed := SaveWriter.parse_document(doc)
	_ok(parsed.get("ok", false), "documento con token legado parsea OK")
	_ok(parsed.get("legacy", false) == true, "se marca como legado (observabilidad)")
	_ok(parsed.get("payload", {}).has("time"), "el payload legado se extrae (tiene 'time')")
	_fin("D")

## E) Un documento legado con payload mutado se detecta igual.
func _b_e_legado_tamper() -> void:
	_abrir("E", "tampering del payload legado detectado")
	var doc := _doc_legado()
	var mutado := _mutar_payload(doc)
	_ok(mutado != doc, "la mutacion efectivamente cambio el documento legado")
	_ok(not SaveWriter.parse_document(mutado).get("ok", false),
		"payload legado mutado SIN recalcular -> rechazado")
	_fin("E")

## F) End-to-end: write_atomic escribe HMAC y el loader lo carga OK.
func _b_f_end_to_end() -> void:
	_abrir("F", "end-to-end: write_atomic + SaveLoader")
	_limpiar_slot()
	var payload := SaveSchema.default_payload("perfil_e2e")
	payload["time"]["day"] = 7
	_ok(SaveWriter.write_atomic(SLOT_PRUEBA, payload), "write_atomic devuelve true")
	var raw := FileAccess.get_file_as_string(SaveWriter.path_for(SLOT_PRUEBA))
	var nl := raw.find("\n")
	_ok(nl > 0 and raw.substr(0, nl).begins_with(SaveWriter.CHECKSUM_PREFIX),
		"el archivo en disco lleva token HMAC")
	var loader := SaveLoader.new()
	var result := loader.load(SLOT_PRUEBA)
	_ok(int(result["result"]) == SaveLoader.LoadResult.OK,
		"SaveLoader.load() -> OK (dio %d)" % int(result["result"]))
	_ok(int(result["payload"].get("time", {}).get("day", -1)) == 7,
		"el payload cargado conserva el dia (7)")
	_limpiar_slot()
	_fin("F")

## G) La clave es estable (persistida) y tiene el largo esperado.
func _b_g_clave_persistente() -> void:
	_abrir("G", "clave HMAC persistida y estable")
	_ok(FileAccess.file_exists(SaveWriter.KEY_PATH),
		"existe el archivo de clave en %s" % SaveWriter.KEY_PATH)
	var hex := FileAccess.get_file_as_string(SaveWriter.KEY_PATH).strip_edges()
	_ok(hex.length() == SaveWriter.KEY_LEN * 2 and hex.is_valid_hex_number(false),
		"la clave es hex de %d bytes (largo %d)" % [SaveWriter.KEY_LEN, hex.length()])
	var f1 := SaveWriter.firmar_payload("mismo-texto")
	var f2 := SaveWriter.firmar_payload("mismo-texto")
	_ok(f1 == f2 and f1 != "", "firmar dos veces el mismo texto da el mismo token")
	var f3 := SaveWriter.firmar_payload("otro-texto")
	_ok(f1 != f3, "firmar textos distintos da tokens distintos")
	_ok(SaveWriter.verificar_checksum("mismo-texto", f1), "verificar_checksum acepta la firma correcta")
	_fin("G")

## H) validate() ya NO es vacua contra el dialecto REAL de M29.
func _b_h_validate_no_vacua() -> void:
	_abrir("H", "SaveSchema.validate() no vacua (dialecto real M29)")
	# Control 1: el dialecto del schema (default_payload) sigue siendo valido.
	_ok(SaveSchema.validate(SaveSchema.default_payload("p")).is_empty(),
		"default_payload (dialecto schema) sigue valido")
	# Control 2: un payload con el dialecto REAL de M29 es valido.
	var real := SaveSchema.default_payload("p")
	real["time"] = {"hora": 6, "minuto": 0, "dia": 1, "mes": 1, "anio": 1,
		"acumulador": 0.5, "eventos_visitados": [], "semilla_partida": 0}
	_ok(SaveSchema.validate(real).is_empty(),
		"payload con dialecto real (hora/minuto/dia/mes/anio/acumulador) valido")
	# NO-VACUIDAD: estos campos NO existen en el dialecto del schema (time.day),
	# asi que el chequeo viejo jamas los miraba -> validate() devolvia [] para
	# TODOS ellos. Ahora deben rechazarse.
	_ok(_rechaza("hora", 99), "hora fuera de rango (99) rechazado")
	_ok(_rechaza("minuto", 60), "minuto fuera de rango (60) rechazado")
	_ok(_rechaza("dia", 0), "dia invalido (0) rechazado")
	_ok(_rechaza("mes", 13), "mes fuera de rango (13) rechazado")
	_ok(_rechaza("anio", 0), "anio invalido (0) rechazado")
	_ok(_rechaza("acumulador", INF), "acumulador infinito rechazado")
	_ok(_rechaza("acumulador", -1.0), "acumulador negativo rechazado")
	_ok(_rechaza("acumulador", "x"), "acumulador no numerico rechazado")
	_ok(_rechaza("hora", "6"), "hora no entera (String) rechazada")
	# Tipos en campos no criticos.
	_ok(_rechaza_root("profile_id", 123), "profile_id no-String rechazado")
	_ok(_rechaza_meta("playtime_seconds", -5.0), "meta.playtime_seconds negativo rechazado")
	_ok(_rechaza_meta("playtime_seconds", "mucho"), "meta.playtime_seconds no numerico rechazado")
	_ok(_rechaza_meta("last_saved", 12345), "meta.last_saved no-String rechazado")
	_fin("H")

## Construye un payload con dialecto REAL y la clave `k` de `time` alterada.
func _con_time(k: String, v: Variant) -> Dictionary:
	var p := SaveSchema.default_payload("p")
	var t := {"hora": 6, "minuto": 0, "dia": 1, "mes": 1, "anio": 1, "acumulador": 0.5}
	t[k] = v
	p["time"] = t
	return p

## true si validate() RECHAZA un payload con dialecto real y time[k] = v.
func _rechaza(k: String, v: Variant) -> bool:
	return not SaveSchema.validate(_con_time(k, v)).is_empty()

func _rechaza_root(k: String, v: Variant) -> bool:
	var p := SaveSchema.default_payload("p")
	p[k] = v
	return not SaveSchema.validate(p).is_empty()

func _rechaza_meta(k: String, v: Variant) -> bool:
	var p := SaveSchema.default_payload("p")
	p["meta"][k] = v
	return not SaveSchema.validate(p).is_empty()

# ── resumen (call_deferred separado: sobrevive a un abort de _run) ───────

func _summary() -> void:
	var faltantes: Array[String] = []
	for k in _abiertos:
		faltantes.append(k)
	print("=== TEST CHECKSUM-HMAC: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	print("    bloques cerrados: %s" % str(_cerrados))
	if not faltantes.is_empty():
		print("    BLOQUES QUE NO CERRARON: %s" % str(faltantes))
		print("TEST CHECKSUM-HMAC FALLIDO - bloques sin _fin (abortaron en silencio)")
		quit(1)
		return
	if _checks < CHECKS_MINIMOS:
		print("TEST CHECKSUM-HMAC FALLIDO - solo %d checks (piso %d): un bloque aborto en silencio" % [_checks, CHECKS_MINIMOS])
		quit(1)
		return
	if _fallos > 0:
		print("TEST CHECKSUM-HMAC FALLIDO - %d fallo(s)" % _fallos)
		quit(1)
		return
	print("TEST CHECKSUM-HMAC OK")
	quit(0)
