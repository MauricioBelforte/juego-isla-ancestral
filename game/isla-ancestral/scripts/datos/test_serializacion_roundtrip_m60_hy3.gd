# Modelo: Hy3 (verificador §21.8 tercero)
# Plataforma: WorkBuddy
# Fecha: 2026-10-21
#
# Bloque C #53 — M60 Datos-Y-Serializacion: serialización round-trip COMPLETA.
#
# Alcance (independiente del autor DeepSeek-V4.1-Flash, §21.8): ejercita el
# núcleo puro de serialización de M60 — la clase `Serializer` (RefCounted, sólo
# métodos estáticos, SIN autoload) — en ida-y-vuelta real con Godot headless:
#   A. JSON  (a_json <-> desde_json) fidelidad total + órden de claves
#   B. binario voxel IAVX1 (a_binario_voxel <-> desde_binario_voxel) + oráculo
#      independiente byte-a-byte (NO usa encode_s32)
#   C. a_plano (Vector/Color/float -> arrays) y su round-trip por JSON
#   D. rutas de error/defensa (magic roto, truncado, count fuera de rango)
#   E. JSON canónico determinista (claves ordenadas recursivamente)
#   F. checksum de WriterAtomico en memoria (construir <-> parsear, integridad)
#
# NO se toca el disco del jugador (user://): los checks de F son 100% en
# memoria (string -> parsear). El round-trip de disco queda diferido (ver
# directiva del director en el mensaje 310).
#
# ⚠️ Guardián anti-falso-verde (3 capas, ver memoria del proyecto):
#   1) Watchdog en _process: si _run() aborta por SCRIPT ERROR (y por tanto
#      nunca llama _summary), se fuerza EXIT 1 tras TIMEOUT_FRAMES.
#   2) _fin() por bloque + _summary() exige que los 6 bloques terminen.
#   3) PISO de checks medido en verde (CHECKS_MINIMOS): si corren menos checks
#      que el piso, la suite falla (detecta bloques que no se ejecutaron).
#   _summary() está en call_deferred aparte para no heredar un abort del _run.
#
# 🔴 AUTOTEST DEL GUARDIAN EN ROJO: si en la línea de comando aparece el token
#    "RED_INJECT", el bloque B inyecta un SCRIPT ERROR real (llamar método sobre
#    instancia null) que aborta la función. Sin guardián, la suite imprimiría
#    "0 fallos / OK"; CON guardián el watchdog la saca con EXIT 1 + "WATCHDOG".
#    Esto prueba que el falso-verde no pasa. Se usa solo para demostración y el
#    archivo queda en modo verde por defecto.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://scripts/datos/test_serializacion_roundtrip_m60_hy3.gd
#   (modo rojo): ... --script res://.../test_serializacion_roundtrip_m60_hy3.gd RED_INJECT

extends SceneTree

const MODULO := "M60 round-trip #53 (Hy3)"
const TIMEOUT_FRAMES := 600
## 🔴 PISO MEDIDO EN VERDE (corrida 2026-10-21, Godot 4.7.2 headless real):
## 47 checks = 45 de los 6 bloques + 2 del resumen (bloques completos + piso).
const CHECKS_MINIMOS := 47
const BLOQUES_ESPERADOS: Array[String] = ["A", "B", "C", "D", "E", "F"]

var _checks: int = 0
var _fallos: int = 0
var _bloque: String = ""
var _completados: Array[String] = []
var _checks_marca: int = 0
var _checks_por_bloque: Dictionary = {}
var _frames: int = 0
var _terminado: bool = false
var _red: bool = false


func _init() -> void:
	for a in OS.get_cmdline_args():
		if String(a) == "RED_INJECT":
			_red = true
	call_deferred("_run")


func _process(_delta: float) -> bool:
	_frames += 1
	if not _terminado and _frames > TIMEOUT_FRAMES:
		_terminado = true
		_checks += 1
		_fallos += 1
		print("!! WATCHDOG: _run() no terminó en %d frames (SCRIPT ERROR abortó la función -> falso verde evitado)" % TIMEOUT_FRAMES)
		print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
		quit(1)
	return false


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s%s" % [nombre, "" if detalle.is_empty() else "  << %s" % detalle])


func _ini(nombre: String) -> void:
	_bloque = nombre
	_checks_marca = _checks
	print("-- %s" % nombre)


func _fin(nombre: String) -> void:
	var letra: String = nombre.substr(0, 1)
	if not _completados.has(letra):
		_completados.append(letra)
	var delta: int = _checks - _checks_marca
	_checks_por_bloque[letra] = int(_checks_por_bloque.get(letra, 0)) + delta
	_checks_marca = _checks
	print("[FIN] %s (+%d checks)" % [nombre, delta])


## Compara dos arrays elemento a elemento con coercón int↔float (la round-trip
## JSON de Godot devuelve enteros como float). Devuelve true si misma longitud
## y cada par es numéricamente igual.
func _arr_eq_num(a: Variant, b: Variant) -> bool:
	var va: Array = a if typeof(a) == TYPE_ARRAY else []
	var vb: Array = b if typeof(b) == TYPE_ARRAY else []
	if va.size() != vb.size():
		return false
	for i in va.size():
		if int(va[i]) != int(vb[i]):
			return false
	return true


## ── Oráculo independiente del binario IAVX1 (byte a byte, sin encode_s32) ──

func _oraculo_int32(b: PackedByteArray, v: int) -> void:
	var u: int = v
	if u < 0:
		u += 4294967296
	for i in 4:
		b.append((u >> (8 * i)) & 0xFF)


func _oraculo_voxel(chunks: Array) -> PackedByteArray:
	var b := PackedByteArray()
	for c in "IAVX1".to_ascii_buffer():
		b.append(c)
	_oraculo_int32(b, chunks.size())
	for ch in chunks:
		var coord: Vector3i = ch.get("coord", Vector3i.ZERO)
		var vox: PackedInt32Array = ch.get("voxeles", PackedInt32Array())
		_oraculo_int32(b, coord.x)
		_oraculo_int32(b, coord.y)
		_oraculo_int32(b, coord.z)
		_oraculo_int32(b, vox.size())
		for v in vox:
			_oraculo_int32(b, v)
	return b


# ── Datos de prueba ────────────────────────────────────────────────────────

func _chunks(n: int, vox_por_chunk: int, sal: int = 0) -> Array:
	var chunks: Array = []
	for c in n:
		var vox := PackedInt32Array()
		for v in vox_por_chunk:
			vox.append((c * 1000 + v * 7 + sal) - 50)
		chunks.append({"coord": Vector3i(c - 3, c * 2, -c), "voxeles": vox})
	return chunks


# ── Suite ──────────────────────────────────────────────────────────────────

func _run() -> void:
	print("=== %s ===" % MODULO)
	if _red:
		print("🔴 MODO ROJO: se inyecta un SCRIPT ERROR REAL e INLINE en _run para probar el guardián anti-falso-verde (debe dar EXIT 1 + WATCHDOG, NO '0 fallos').")
		# 🔴 Inline (no en helper): Godot 4.7.2 sólo aborta la función donde
		# ocurre el error; si estuviera en un helper, el llamador continuaría y
		# enmascararía el fallo. Aquí aborta _run -> _summary nunca corre ->
		# el watchdog debe capturarlo y salir con EXIT 1.
		var _n = null
		_n.get_name()
	_bloque_a_json()
	_bloque_b_voxel()
	_bloque_c_plano()
	_bloque_d_errores()
	_bloque_e_canonico()
	_bloque_f_checksum()
	call_deferred("_summary")


func _bloque_a_json() -> void:
	_ini("A. JSON ida y vuelta (fidelidad total + órden de claves)")
	var datos := {
		"version": 1,
		"jugador": {"pos": [1.5, 2.0, 3.0], "vida": 100, "activo": true},
		"inventario": {"slots": [{"id": "wood", "n": 25}, {"id": "stone", "n": 10}]},
		"notas": null,
		"semilla": 12345,
	}
	var texto := Serializer.a_json(datos)
	_check("a_json produce un string que empieza por '{'", typeof(texto) == TYPE_STRING and texto.begins_with("{"))
	var parsed := Serializer.desde_json(texto)
	# Nota: Godot JSON.parse_string convierte enteros JSON en float (1 -> 1.0).
	# M60 lo mitiga con int() al consumir; comparamos con coercón numérica.
	_check("ida y vuelta: version entera (coercion) == 1", int(parsed.get("version", -1)) == 1)
	_check("ida y vuelta: jugador.vida entera (coercion) == 100", int(parsed.get("jugador", {}).get("vida", -1)) == 100)
	_check("ida y vuelta: semilla entera (coercion) == 12345", int(parsed.get("semilla", -1)) == 12345)
	_check("array anidado ida y vuelta (slots[0].id)", String(parsed.get("inventario", {}).get("slots", [])[0]["id"]) == "wood")
	_check("bool ida y vuelta (jugador.activo)", bool(parsed.get("jugador", {}).get("activo", false)) == true)
	_check("null ida y vuelta (notas)", parsed.get("notas", "x") == null)
	_check("float ida y vuelta (1.5)", abs(float(parsed.get("jugador", {}).get("pos", [])[0]) - 1.5) < 0.0001)
	# órden de claves: el JSON no garantiza orden, pero el dict resultante es igual
	var d1 := {"a": 1, "b": 2, "c": 3}
	var d2 := {"c": 3, "a": 1, "b": 2}
	_check("desde_json es inmune al órden de claves (igualdad)",
		Serializer.desde_json(Serializer.a_json(d1)) == Serializer.desde_json(Serializer.a_json(d2)))
	var malo := Serializer.desde_json("{ no es json")
	_check("JSON inválido -> {}", malo.is_empty())
	var vacio := Serializer.desde_json("")
	_check("string vacío -> {}", vacio.is_empty())
	_fin("A. JSON ida y vuelta (fidelidad total + órden de claves)")


func _bloque_b_voxel() -> void:
	_ini("B. binario voxel IAVX1 ida y vuelta + oráculo independiente")
	var chunks := _chunks(4, 6, 21)
	var bin := Serializer.a_binario_voxel(chunks)
	var vuelta := Serializer.desde_binario_voxel(bin)
	_check("desde_binario_voxel reconoce el magic (no vacío)", not vuelta.is_empty())
	_check("count devuelto == 4", int(vuelta.get("count", -1)) == 4)
	var leidos: Array = vuelta.get("chunks", [])
	_check("se leyeron 4 chunks", leidos.size() == 4)
	var coords_ok := true
	var vox_ok := true
	for i in leidos.size():
		if leidos[i]["coord"] != chunks[i]["coord"]:
			coords_ok = false
		if leidos[i]["voxeles"] != chunks[i]["voxeles"]:
			vox_ok = false
	_check("coords vuelven idénticas (incl. negativos)", coords_ok)
	_check("voxeles vuelven idénticos", vox_ok)
	_check("re-encodear lo leído reproduce el MISMO binario (round-trip byte-exacto)",
		Serializer.a_binario_voxel(leidos) == bin)
	_check("magic IAVX1 intacto en el offset 0", bin.slice(0, 5).get_string_from_ascii() == "IAVX1")
	var esp := _oraculo_voxel(chunks)
	_check("producción == oráculo independiente byte a byte", bin == esp)
	# chunk vacío (sin voxeles) -> binario válido count 0, NO {} 
	var vacio := Serializer.a_binario_voxel([])
	var r_vacio := Serializer.desde_binario_voxel(vacio)
	_check("chunks vacíos -> count 0 y chunks vacíos (no {})",
		int(r_vacio.get("count", -1)) == 0 and (r_vacio.get("chunks", []) as Array).is_empty())
	# chunk único: tamaño exacto = 9 + (12 coord + 4 num + 0 vox)
	var uno := Serializer.a_binario_voxel([{"coord": Vector3i(1, 2, 3)}])
	_check("chunk único sin voxeles -> 9 + 16 bytes", uno.size() == 9 + 16)
	_fin("B. binario voxel IAVX1 ida y vuelta + oráculo independiente")


func _bloque_c_plano() -> void:
	_ini("C. a_plano (Vector/Color/float -> arrays) y su round-trip por JSON")
	var datos := {
		"pos": Vector3i(4, -2, 8),
		"dir": Vector3(1.23456789, 2.0, -3.5),
		"color": Color(1, 0, 0, 1),
		"alt": 1.23456789,
		"sub": {"p": Vector2i(9, 7), "f": 0.11111111},
	}
	var plano := Serializer.a_plano(datos)
	_check("Vector3i -> Array de 3", plano["pos"] is Array and plano["pos"][0] == 4 and plano["pos"][2] == 8)
	_check("Vector3 -> Array de 3", plano["dir"] is Array and (plano["dir"] as Array).size() == 3)
	_check("Color -> Array de 4", plano["color"] is Array and (plano["color"] as Array).size() == 4)
	_check("float normalizado a 4 decimales (1.2346)", abs(float(plano["alt"]) - 1.2346) < 0.0001)
	# round-trip del plano por JSON (el plano ya es serializable nativo).
	# Los Vector*i se codifican como ints en a_plano; JSON los devuelve como
	# floats (coercion de Godot), así que comparamos con coercón numérica.
	var de_vuelta := Serializer.desde_json(Serializer.a_json(plano))
	_check("a_plano es estable por un ciclo JSON (pos/sub.p numéricos)",
		_arr_eq_num(de_vuelta.get("pos", []), plano.get("pos", []))
		and _arr_eq_num(de_vuelta.get("sub", {}).get("p", []), plano.get("sub", {}).get("p", []))
		and abs(float(de_vuelta.get("alt", -9.0)) - float(plano.get("alt", -9.0))) < 0.0001)
	_check("a_plano es idempotente (a_plano(a_plano(x)) == a_plano(x))",
		Serializer.a_plano(plano) == plano)
	_check("a_plano es determinista (dos llamadas iguales)",
		Serializer.a_plano(datos) == Serializer.a_plano(datos))
	var v3i := Serializer.vector3i_a_array(Vector3i(1, -2, 3))
	_check("vector3i_a_array(1,-2,3) == [1,-2,3]", v3i == [1, -2, 3])
	_fin("C. a_plano (Vector/Color/float -> arrays) y su round-trip por JSON")


func _bloque_d_errores() -> void:
	_ini("D. rutas de error/defensa del deserializador")
	var tiny := Serializer.desde_binario_voxel(PackedByteArray([1, 2, 3]))
	_check("binario < 9 bytes -> {}", tiny.is_empty())
	var magic_roto := PackedByteArray()
	magic_roto.append_array("XXXX".to_ascii_buffer())
	magic_roto.append_array(PackedInt32Array([1]).to_byte_array())
	_check("magic IAVX1 roto -> {}", Serializer.desde_binario_voxel(magic_roto).is_empty())
	# count fuera de rango (5000) con tamaño insuficiente -> {}
	var count_grande := PackedByteArray()
	count_grande.append_array("IAVX1".to_ascii_buffer())
	count_grande.append_array(PackedInt32Array([5000]).to_byte_array())
	_check("count fuera de rango (5000) -> {}", Serializer.desde_binario_voxel(count_grande).is_empty())
	# truncado: magic + count válido pero faltan bytes -> NO crashea (devuelve dict)
	var trunc := PackedByteArray()
	trunc.append_array("IAVX1".to_ascii_buffer())
	trunc.append_array(PackedInt32Array([1]).to_byte_array())
	trunc.append_array(PackedInt32Array([1, 2, 3]).to_byte_array())  # incompleto
	var r_trunc := Serializer.desde_binario_voxel(trunc)
	_check("truncado NO crashea (devuelve Dictionary)", typeof(r_trunc) == TYPE_DICTIONARY)
	var malo := Serializer.desde_json("{ no es json")
	_check("desde_json inválido -> {}", malo.is_empty())
	_check("normalizar_float es idempotente",
		Serializer.normalizar_float(0.12345) == Serializer.normalizar_float(Serializer.normalizar_float(0.12345)))
	_check("normalizar_float(0.12345) == 0.1235", abs(Serializer.normalizar_float(0.12345) - 0.1235) < 0.0001)
	_fin("D. rutas de error/defensa del deserializador")


func _bloque_e_canonico() -> void:
	_ini("E. JSON canónico determinista (claves ordenadas recursivamente)")
	# 🔎 El canónico opera sobre datos YA PLANOS (sin Vector: a_json de un
	# Vector3i produce la string "(x, y, z)", no un array). Usamos arrays.
	var d := {"z": 1, "a": {"m": [3, 2, 1], "n": [1, 2, 3]}, "k": 2.5}
	var canon1 := Serializer.a_json_canonico(d)
	var canon2 := Serializer.a_json_canonico(d)
	_check("a_json_canonico es determinista (dos llamadas iguales)", canon1 == canon2)
	var d_rev := {"k": 2.5, "a": {"n": [1, 2, 3], "m": [3, 2, 1]}, "z": 1}
	_check("a_json_canonico colapsa el órden de claves (reordenado == original)",
		Serializer.a_json_canonico(d_rev) == canon1)
	_check("a_json BRUTO difiere del canónico cuando las claves no están ordenadas",
		Serializer.a_json(d) != canon1)
	var parse_canon := Serializer.desde_json(canon1)
	_check("el canónico parsea a un dict con la clave 'z' presente",
		typeof(parse_canon) == TYPE_DICTIONARY and parse_canon.has("z"))
	_fin("E. JSON canónico determinista (claves ordenadas recursivamente)")


func _bloque_f_checksum() -> void:
	_ini("F. checksum de WriterAtomico en memoria (construir <-> parsear, integridad)")
	var payload := {"version": 1, "_hy3_rt_marker": 12345, "x": [1, 2, 3]}
	var contenido := WriterAtomico.construir_con_checksum(Serializer.a_json(payload))
	_check("construir_con_checksum añade contenido (distinto del payload crudo)",
		contenido != Serializer.a_json(payload))
	var doc := WriterAtomico.parsear_documento(contenido)
	_check("parsear_documento(ok) -> ok == true", doc.get("ok", false) == true)
	# Los enteros del payload vuelven como float (coercion Godot); comparamos
	# con coercón numérica, igual que hace M60 al consumirlos con int().
	var pld: Dictionary = doc.get("payload", {}) as Dictionary
	_check("payload ida y vuelta íntegro (enteros vía coercón)",
		int(pld.get("version", -1)) == 1
		and int(pld.get("_hy3_rt_marker", -1)) == 12345
		and _arr_eq_num(pld.get("x", []), payload.get("x", [])))
	# 🔴 integridad: manipular el payload ROMPE el checksum
	var manipulado := contenido.replace("12345", "12399")
	var doc_malo := WriterAtomico.parsear_documento(manipulado)
	_check("tamper del payload -> ok == false (integridad detectada)", doc_malo.get("ok", true) == false)
	# basura total -> ok == false (sin crash)
	var doc_basura := WriterAtomico.parsear_documento("esto no es un documento firmado")
	_check("basura total -> ok == false", doc_basura.get("ok", true) == false)
	_fin("F. checksum de WriterAtomico en memoria (construir <-> parsear, integridad)")


func _summary() -> void:
	var faltantes: Array[String] = []
	for b in BLOQUES_ESPERADOS:
		if not _completados.has(b):
			faltantes.append(b)
	var detalle: String = "" if faltantes.is_empty() else " — bloques que no terminaron: %s" % str(faltantes)
	_check("los %d bloques se completaron (sin abortos silenciosos)%s" % [BLOQUES_ESPERADOS.size(), detalle],
		faltantes.is_empty())
	# +1: el propio check de piso aún no está contado cuando se evalúa.
	_check("se superó el piso de checks (%d >= %d)" % [_checks + 1, CHECKS_MINIMOS],
		(_checks + 1) >= CHECKS_MINIMOS, "sólo %d checks" % (_checks + 1))
	_terminado = true
	print("-- checks por bloque: %s" % str(_checks_por_bloque))
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos == 0:
		print("TEST %s OK — todos los checks pasaron" % MODULO)
		quit(0)
	else:
		print("TEST %s FALLIDO — salida con código 1" % MODULO)
		quit(1)
