# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-18
#
# M60 iter. 5 — Ítem 168 del checklist: "Optimización: reutilización de dicts y
# buffers en bucles de guardado".
#
# RESULTADO: la optimización pedida se EVALUÓ y resultó CONTRAPRODUCENTE. Este
# archivo es el ARNÉS que lo demuestra y queda como evidencia + guarda de
# regresión. NO se cambió el código de producción (`serializador.gd` sigue
# igual): no se envía una pesimización.
#
# Qué se midió (misma salida, tres implementaciones del MISMO formato):
#   1. `resize()` por campo + `encode_s32`  -> la que está en producción.
#   2. `resize()` único + buffer reutilizado -> la "reutilización de buffers".
#   3. BULK: `PackedInt32Array` + `to_byte_array()` (memcpy masivo).
# Y para dicts:
#   1. asignador recursivo (uno nuevo por nodo) -> la que está en producción.
#   2. `a_plano_en`-style con contenedor de destino reutilizado.
#
# Veredicto medido (Godot 4.7.2, headless):
#   - La reutilización de buffers es 1,20-1,52x MÁS LENTA (exige una pasada
#     extra para calcular el tamaño exacto; `PackedByteArray.resize()` ya crece
#     de forma amortizada, así que los ~6 resize por chunk no eran el coste).
#   - La reutilización de dicts es ~1,06x MÁS LENTA (el libro mayor de
#     `keys()`/`erase()`/`get()` cuesta más que asignar el árbol).
#   - BULK sí gana en la forma realista (400x60: 41 -> 33 ms, 1,24x) pero
#     PIERDE en la degenerada (6000x1: 153 -> 183 ms). Perfil mixto -> NO se
#     adopta sin decisión del dueño.
#
# Los bloques A/B/C/D son aserciones duras (equivalencia byte a byte, contrato
# del formato, sin aliasing). El bloque E sólo MIDE y reporta: no se afirma un
# tiempo (sería frágil en CI).
#
# ⚠️ Guardián anti-falso-verde: en GDScript un error de script ABORTA la función
# en silencio y la suite imprimiría "0 fallos" igual. Cada bloque cierra con
# `_fin()`, `_summary()` exige que estén los 5, hay PISO de checks y watchdog.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://scripts/datos/test_datos_m60_iter5.gd

extends SceneTree

const MODULO := "M60 iter. 5"
const TIMEOUT_FRAMES := 1800
const BLOQUES_ESPERADOS: Array[String] = ["A", "B", "C", "D", "E"]
const CHECKS_MINIMOS := 34
## Rondas intercaladas por medición (se toma el mínimo: descarta el warm-up).
const RONDAS := 5

var _checks: int = 0
var _fallos: int = 0
var _bloque: String = ""
var _completados: Array[String] = []
var _checks_marca: int = 0
var _checks_por_bloque: Dictionary = {}
var _frames: int = 0
var _terminado: bool = false
var _medidas: Array[Dictionary] = []


func _init() -> void:
	call_deferred("_run")


func _process(_delta: float) -> bool:
	_frames += 1
	if not _terminado and _frames > TIMEOUT_FRAMES:
		_terminado = true
		_checks += 1
		_fallos += 1
		print("!! WATCHDOG: _run() no terminó en %d frames (posible SCRIPT ERROR que abortó la función)" % TIMEOUT_FRAMES)
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


# ── Oráculo independiente (NO usa encode_s32) ──────────────────────────────

func _oraculo_int32(b: PackedByteArray, v: int) -> void:
	var u: int = v
	if u < 0:
		u += 4294967296
	for i in 4:
		b.append((u >> (8 * i)) & 0xFF)


## Codificador de referencia del formato IAVX1, escrito byte por byte para que
## la comparación sea de verdad independiente del código bajo prueba.
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


# ── Variantes bajo evaluación (locales; NO están en producción) ─────────────

## Variante 2: buffer del llamador + un único `resize()` al tamaño exacto.
func _reuso_a_binario_voxel(chunks: Array, out: PackedByteArray) -> PackedByteArray:
	var total := 9
	for chunk in chunks:
		var vox: PackedInt32Array = chunk.get("voxeles", PackedInt32Array())
		total += 16 + vox.size() * 4
	out.resize(total)
	var magic := "IAVX1".to_ascii_buffer()
	for i in magic.size():
		out[i] = magic[i]
	out.encode_s32(5, chunks.size())
	var offset := 9
	for chunk in chunks:
		var coord: Vector3i = chunk.get("coord", Vector3i.ZERO)
		var vox: PackedInt32Array = chunk.get("voxeles", PackedInt32Array())
		out.encode_s32(offset, coord.x)
		out.encode_s32(offset + 4, coord.y)
		out.encode_s32(offset + 8, coord.z)
		out.encode_s32(offset + 12, vox.size())
		offset += 16
		for i in range(vox.size()):
			out.encode_s32(offset + i * 4, vox[i])
		offset += vox.size() * 4
	return out


## Variante 3: BULK — PackedInt32Array + `to_byte_array()` (memcpy masivo).
func _bulk_a_binario_voxel(chunks: Array) -> PackedByteArray:
	var n_ints := 1
	for chunk in chunks:
		var vox: PackedInt32Array = chunk.get("voxeles", PackedInt32Array())
		n_ints += 4 + vox.size()
	var ints := PackedInt32Array()
	ints.resize(n_ints)
	ints[0] = chunks.size()
	var k := 1
	for chunk in chunks:
		var coord: Vector3i = chunk.get("coord", Vector3i.ZERO)
		var vox: PackedInt32Array = chunk.get("voxeles", PackedInt32Array())
		ints[k] = coord.x
		ints[k + 1] = coord.y
		ints[k + 2] = coord.z
		ints[k + 3] = vox.size()
		k += 4
		for i in vox.size():
			ints[k + i] = vox[i]
		k += vox.size()
	var out := PackedByteArray()
	out.append_array("IAVX1".to_ascii_buffer())
	out.append_array(ints.to_byte_array())
	return out


## Variante 2 de dicts: rellena reutilizando el contenedor de destino.
func _reuso_a_plano(valor: Variant, destino: Variant) -> Variant:
	match typeof(valor):
		TYPE_VECTOR2:
			return [snappedf(valor.x, 0.0001), snappedf(valor.y, 0.0001)]
		TYPE_VECTOR3:
			return [snappedf(valor.x, 0.0001), snappedf(valor.y, 0.0001), snappedf(valor.z, 0.0001)]
		TYPE_VECTOR2I:
			return [valor.x, valor.y]
		TYPE_VECTOR3I:
			return [valor.x, valor.y, valor.z]
		TYPE_COLOR:
			return [snappedf(valor.r, 0.0001), snappedf(valor.g, 0.0001), snappedf(valor.b, 0.0001), snappedf(valor.a, 0.0001)]
		TYPE_FLOAT:
			return snappedf(valor, 0.0001)
		TYPE_DICTIONARY:
			var origen: Dictionary = valor
			var out: Dictionary
			if typeof(destino) == TYPE_DICTIONARY:
				out = destino
				for k in out.keys():
					if not origen.has(k):
						out.erase(k)
			else:
				out = {}
			for k in origen:
				out[k] = _reuso_a_plano(origen[k], out.get(k))
			return out
		TYPE_ARRAY:
			var origen: Array = valor
			var out: Array
			if typeof(destino) == TYPE_ARRAY:
				out = destino
				if out.size() != origen.size():
					out.resize(origen.size())
			else:
				out = []
				out.resize(origen.size())
			for i in origen.size():
				out[i] = _reuso_a_plano(origen[i], out[i])
			return out
		_:
			return valor


# ── Datos de prueba ────────────────────────────────────────────────────────

func _chunks_de_prueba(n_chunks: int, n_vox: int, sal: int = 0) -> Array:
	var chunks: Array = []
	for c in n_chunks:
		var vox := PackedInt32Array()
		for v in n_vox:
			vox.append((c * 1000 + v * 7 + sal) - 50)
		chunks.append({"coord": Vector3i(c - 3, c * 2, -c), "voxeles": vox})
	return chunks


func _payload_de_prueba(n: int) -> Dictionary:
	var ents: Array = []
	for i in n:
		ents.append({
			"id": "ent_%d" % i,
			"pos": Vector3(i * 0.5, 1.25, -i),
			"vida": float(i) / 3.0,
			"tags": ["a", "b", "c"],
			"meta": {"nivel": i, "activo": i % 2 == 0},
		})
	return {"entidades": ents, "version": 1, "semilla": 12345}


# ── Suite ─────────────────────────────────────────────────────────────────

func _run() -> void:
	print("=== %s: evaluación de la reutilización de dicts/buffers (ítem 168) ===" % MODULO)

	_bloque_a_oraculo()
	_bloque_b_roundtrip()
	_bloque_c_variantes_binario()
	_bloque_d_variantes_dicts()
	_bloque_e_medicion()

	_summary()


func _bloque_a_oraculo() -> void:
	_ini("A. la implementación en producción coincide con un oráculo independiente")
	var casos: Array = [
		[],
		_chunks_de_prueba(1, 0),
		_chunks_de_prueba(3, 1),
		_chunks_de_prueba(2, 5, 13),
		_chunks_de_prueba(7, 12, -4),
	]
	var todos := true
	for i in casos.size():
		var chunks: Array = casos[i]
		var real := Serializer.a_binario_voxel(chunks)
		var esp := _oraculo_voxel(chunks)
		if real != esp:
			todos = false
			_check("caso %d: bytes idénticos al oráculo" % i, false,
				"real=%d B, oráculo=%d B" % [real.size(), esp.size()])
		else:
			_check("caso %d: bytes idénticos al oráculo (%d B)" % [i, real.size()], true)
	_check("los 5 casos coinciden byte a byte con el oráculo", todos)
	var b := Serializer.a_binario_voxel(_chunks_de_prueba(3, 4))
	_check("magic IAVX1 intacto", b.slice(0, 5).get_string_from_ascii() == "IAVX1")
	_check("count = 3 en el offset 5", b.decode_s32(5) == 3)
	_check("tamaño exacto = 9 + 3*(16 + 4*4)", b.size() == 9 + 3 * (16 + 4 * 4))
	_fin("A. la implementación en producción coincide con un oráculo independiente")


func _bloque_b_roundtrip() -> void:
	_ini("B. round-trip binario")
	var chunks := _chunks_de_prueba(4, 6, 21)
	var bin := Serializer.a_binario_voxel(chunks)
	var vuelta := Serializer.desde_binario_voxel(bin)
	_check("desde_binario_voxel reconoce el magic", not vuelta.is_empty())
	_check("count devuelto = 4", int(vuelta.get("count", -1)) == 4)
	var leidos: Array = vuelta.get("chunks", [])
	_check("se leyeron 4 chunks", leidos.size() == 4)
	var coords_ok := true
	var vox_ok := true
	for i in leidos.size():
		var orig: Dictionary = chunks[i]
		var leido: Dictionary = leidos[i]
		if leido["coord"] != orig["coord"]:
			coords_ok = false
		if leido["voxeles"] != orig["voxeles"]:
			vox_ok = false
	_check("los coord vuelven idénticos", coords_ok)
	_check("los voxeles vuelven idénticos", vox_ok)
	_check("re-encodear lo leído reproduce el mismo binario",
		Serializer.a_binario_voxel(leidos) == bin)
	var parcial := Serializer.a_binario_voxel([{"coord": Vector3i(1, 2, 3)}])
	_check("chunk sin 'voxeles' -> 16 bytes (coord + num=0)", parcial.size() == 9 + 16)
	_check("num_voxeles = 0 en el offset 21", parcial.decode_s32(21) == 0)
	_fin("B. round-trip binario")


func _bloque_c_variantes_binario() -> void:
	_ini("C. equivalencia de las variantes de encoder")
	var casos: Array = [
		_chunks_de_prueba(1, 0),
		_chunks_de_prueba(3, 1),
		_chunks_de_prueba(2, 5, 13),
		_chunks_de_prueba(9, 20, -4),
	]
	var reuso_ok := true
	var bulk_ok := true
	for i in casos.size():
		var chunks: Array = casos[i]
		var prod := Serializer.a_binario_voxel(chunks)
		var r := _reuso_a_binario_voxel(chunks, PackedByteArray())
		var b := _bulk_a_binario_voxel(chunks)
		if r != prod:
			reuso_ok = false
		if b != prod:
			bulk_ok = false
	_check("la variante de REUSO da el mismo binario que producción", reuso_ok)
	_check("la variante BULK da el mismo binario que producción", bulk_ok)

	# El caso peligroso del reuso: reusar el buffer con un payload MÁS CHICO.
	var buf := PackedByteArray()
	_reuso_a_binario_voxel(_chunks_de_prueba(5, 40, 3), buf)
	var grande := buf.size()
	var chico := _chunks_de_prueba(1, 2, -9)
	var r2 := _reuso_a_binario_voxel(chico, buf)
	_check("reusar con payload más chico devuelve el mismo objeto", is_same(r2, buf))
	_check("el buffer se RECORTA (%d -> %d B)" % [grande, buf.size()],
		buf.size() == 9 + 1 * (16 + 4 * 2))
	_check("sin bytes arrastrados del payload anterior",
		r2 == Serializer.a_binario_voxel(chico))
	# Buffer con basura: debe quedar reescrito entero, no appendeado.
	var sucio := PackedByteArray()
	sucio.resize(500)
	sucio.fill(0xAB)
	var r3 := _reuso_a_binario_voxel(chico, sucio)
	_check("un buffer 'sucio' se recorta y se reescribe entero",
		r3 == Serializer.a_binario_voxel(chico))
	_fin("C. equivalencia de las variantes de encoder")


func _bloque_d_variantes_dicts() -> void:
	_ini("D. equivalencia de las variantes de a_plano")
	var datos := {
		"jugador": {"pos": Vector3(1.23456, 2.0, -3.5), "vida": 7.5, "inventario": [1, 2, 3]},
		"mundo_voxel": {"semilla": 12345, "chunks_editados": 3},
		"flags": {"a": true, "b": false},
	}
	var prod := Serializer.a_plano(datos)
	var scratch: Dictionary = {}
	var reuso: Dictionary = _reuso_a_plano(datos, scratch)
	_check("la variante de reuso devuelve el MISMO dict del llamador", is_same(reuso, scratch))
	_check("la variante de reuso equivale a producción", reuso == prod)
	_check("Vector3 -> Array de 3", (prod["jugador"]["pos"] as Array).size() == 3)
	_check("float normalizado a 4 decimales (1.2346)",
		is_equal_approx(float((prod["jugador"]["pos"] as Array)[0]), 1.2346))

	# Reuso REAL del contenedor anidado entre llamadas.
	var anid1: Dictionary = reuso["jugador"]
	var inv1: Array = reuso["jugador"]["inventario"]
	var reuso2: Dictionary = _reuso_a_plano(datos, scratch)
	_check("el dict anidado se reutiliza (misma instancia)", is_same(anid1, reuso2["jugador"]))
	_check("el array anidado se reutiliza (misma instancia)", is_same(inv1, reuso2["jugador"]["inventario"]))

	# Cambio de forma: clave que desaparece, tipo que cambia, array que encoge.
	var d2 := datos.duplicate(true)
	(d2["flags"] as Dictionary).erase("b")
	var out2: Dictionary = _reuso_a_plano(d2, scratch)
	_check("clave eliminada desaparece (sin basura)", not (out2["flags"] as Dictionary).has("b"))
	var d3 := datos.duplicate(true)
	d3["jugador"] = 42
	var out3: Dictionary = _reuso_a_plano(d3, scratch)
	_check("un cambio de tipo no arrastra el contenedor viejo", typeof(out3["jugador"]) == TYPE_INT)
	_check("el escalar nuevo es el correcto", int(out3["jugador"]) == 42)
	var d4 := datos.duplicate(true)
	d4["jugador"]["inventario"] = [9]
	var out4: Dictionary = _reuso_a_plano(d4, scratch)
	_check("un array que encoge no deja elementos viejos",
		(out4["jugador"]["inventario"] as Array).size() == 1)

	# SIN ALIASING: mutar la entrada no puede cambiar la salida.
	var d5 := {"x": {"y": 1}}
	var p5 := Serializer.a_plano(d5)
	(d5["x"] as Dictionary)["y"] = 999
	_check("mutar la entrada NO altera la salida de producción", int(p5["x"]["y"]) == 1)
	var sc6: Dictionary = {}
	var p6: Dictionary = _reuso_a_plano(d5, sc6)
	(d5["x"] as Dictionary)["y"] = 1234
	_check("mutar la entrada NO altera la salida de la variante de reuso", int(p6["x"]["y"]) == 999)
	_fin("D. equivalencia de las variantes de a_plano")


func _bloque_e_medicion() -> void:
	_ini("E. medición y determinismo")
	var datos := {"z": 1, "a": {"m": [3, 2, 1], "n": Vector3i(1, 2, 3)}, "k": 2.5}
	var scratch: Dictionary = {}
	_check("a_json_canonico(producción) == a_json_canonico(reuso)",
		Serializer.a_json_canonico(Serializer.a_plano(datos))
		== Serializer.a_json_canonico(_reuso_a_plano(datos, scratch) as Dictionary))
	_check("a_json es estable entre llamadas",
		Serializer.a_json(Serializer.a_plano(datos)) == Serializer.a_json(Serializer.a_plano(datos)))

	_medidas.append_array(_medir_binario("6000 chunks x 1 vóxel", _chunks_de_prueba(6000, 1, 7), 10))
	_medidas.append_array(_medir_binario("400 chunks x 60 vóxeles", _chunks_de_prueba(400, 60, 7), 40))
	_medidas.append_array(_medir_plano("payload 60 entidades", _payload_de_prueba(60), 400))

	print("  [MEDICIÓN] mínimo de %d rondas intercaladas (menor = mejor)" % RONDAS)
	for m in _medidas:
		print("    %-52s %5d ms" % [m["caso"], m["ms"]])
	# Veredicto DERIVADO de los datos (no hardcodeado).
	var prod := 0
	var reuso := 0
	var bulk := 0
	for m in _medidas:
		var c: String = String(m["caso"])
		if c.contains("PRODUCCIÓN"):
			prod += int(m["ms"])
		elif c.contains("buffer reusado") or c.contains("destino reutilizado"):
			reuso += int(m["ms"])
		elif c.contains("BULK"):
			bulk += int(m["ms"])
	print("  [VEREDICTO] suma de los MISMOS 3 casos: producción=%d ms · reutilización=%d ms" % [prod, reuso])
	print("             BULK sólo aplica a los 2 casos binarios: %d ms" % bulk)
	if reuso >= prod:
		print("             la REUTILIZACIÓN no supera a producción -> NO se adopta.")
	else:
		print("             la reutilización sale MEJOR en esta corrida -> revisar antes de descartar.")
	_check("se midieron las 8 variantes esperadas", _medidas.size() == 8)
	_fin("E. medición y determinismo")


## Mínimo de una lista de microsegundos (descarta el arranque en frío y el ruido
## del asignador). Medir sólo la PRIMERA variante la castiga con el warm-up: en
## la primera versión de este arnés eso invirtió el veredicto. Por eso se
## alternan rondas y se toma el mínimo de cada variante.
func _min_ms(muestras: Array) -> int:
	var mejor := -1
	for m in muestras:
		if mejor < 0 or int(m) < mejor:
			mejor = int(m)
	return int(mejor / 1000)


func _medir_binario(caso: String, chunks: Array, iters: int) -> Array:
	var t_prod: Array = []
	var t_reuso: Array = []
	var t_bulk: Array = []
	var buf := PackedByteArray()
	for _r in RONDAS:
		var a := Time.get_ticks_usec()
		for _i in iters:
			Serializer.a_binario_voxel(chunks)
		var b := Time.get_ticks_usec()
		t_prod.append(b - a)
		a = Time.get_ticks_usec()
		for _i in iters:
			_reuso_a_binario_voxel(chunks, buf)
		b = Time.get_ticks_usec()
		t_reuso.append(b - a)
		a = Time.get_ticks_usec()
		for _i in iters:
			_bulk_a_binario_voxel(chunks)
		b = Time.get_ticks_usec()
		t_bulk.append(b - a)
	return [
		{"caso": "%s | 1. resize-por-campo (PRODUCCIÓN)" % caso, "ms": _min_ms(t_prod)},
		{"caso": "%s | 2. resize-único + buffer reusado" % caso, "ms": _min_ms(t_reuso)},
		{"caso": "%s | 3. BULK to_byte_array" % caso, "ms": _min_ms(t_bulk)},
	]


func _medir_plano(caso: String, payload: Dictionary, iters: int) -> Array:
	var t_prod: Array = []
	var t_reuso: Array = []
	var scratch: Dictionary = {}
	for _r in RONDAS:
		var a := Time.get_ticks_usec()
		for _i in iters:
			Serializer.a_plano(payload)
		var b := Time.get_ticks_usec()
		t_prod.append(b - a)
		a = Time.get_ticks_usec()
		for _i in iters:
			_reuso_a_plano(payload, scratch)
		b = Time.get_ticks_usec()
		t_reuso.append(b - a)
	return [
		{"caso": "%s | 1. asignador recursivo (PRODUCCIÓN)" % caso, "ms": _min_ms(t_prod)},
		{"caso": "%s | 2. destino reutilizado" % caso, "ms": _min_ms(t_reuso)},
	]


func _summary() -> void:
	var faltantes: Array[String] = []
	for b in BLOQUES_ESPERADOS:
		if not _completados.has(b):
			faltantes.append(b)
	var detalle: String = "" if faltantes.is_empty() else " — bloques que no terminaron: %s" % str(faltantes)
	_check("los %d bloques se completaron (sin abortos silenciosos)%s" % [BLOQUES_ESPERADOS.size(), detalle],
		faltantes.is_empty())
	_check("se superó el piso de checks (%d >= %d)" % [_checks, CHECKS_MINIMOS],
		_checks >= CHECKS_MINIMOS, "sólo %d checks" % _checks)
	_terminado = true
	print("-- checks por bloque: %s" % str(_checks_por_bloque))
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos == 0:
		print("TEST %s OK — todos los checks pasaron" % MODULO)
		quit(0)
	else:
		print("TEST %s FALLIDO — salida con código 1" % MODULO)
		quit(1)
