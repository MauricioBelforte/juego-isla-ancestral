extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== DEBUG HY3 ===")

	# 1) Coerción int/float en JSON
	var arr_orig: Array = [1.5, 2.0, 3.0]
	var s1: String = JSON.stringify(arr_orig)
	var arr_back: Array = JSON.parse_string(s1) as Array
	print("1a) JSON.stringify([1.5,2.0,3.0]) = ", s1)
	print("1b) parse back = ", arr_back)
	print("1c) [1.5,2.0,3.0] == parse = ", arr_orig == arr_back, " (typeof elems: ", typeof(arr_back[1]), " vs ", typeof(arr_orig[1]), ")")

	var dict_orig: Dictionary = {"pos": [1.5, 2.0, 3.0], "vida": 100}
	var s2: String = Serializer.a_json(dict_orig)
	var dict_back: Dictionary = Serializer.desde_json(s2)
	print("2a) a_json(dict) = ", s2)
	print("2b) desde_json = ", dict_back)
	print("2c) dict == back = ", dict_orig == dict_back)

	# 2) a_json_canonico con Vector3i dentro
	var d_con_v3i: Dictionary = {"z": 1, "a": {"m": [3, 2, 1], "n": Vector3i(1, 2, 3)}, "k": 2.5}
	var canon_v3i: String = Serializer.a_json_canonico(d_con_v3i)
	print("3a) canon con Vector3i = ", canon_v3i)
	var parse_canon: Variant = Serializer.desde_json(canon_v3i)
	print("3b) parse canon = ", parse_canon, " (ok=", typeof(parse_canon) == TYPE_DICTIONARY, ")")

	# 3) WriterAtomico payload round-trip
	var payload: Dictionary = {"version": 1, "_hy3_rt_marker": 12345, "x": [1, 2, 3]}
	var contenido: String = WriterAtomico.construir_con_checksum(Serializer.a_json(payload))
	print("4a) contenido = ", contenido)
	var doc: Dictionary = WriterAtomico.parsear_documento(contenido)
	print("4b) doc.ok = ", doc.get("ok"), " payload = ", doc.get("payload"))
	print("4c) payload == original = ", (doc.get("payload", {}) as Dictionary) == payload)

	quit(0)
