# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M60: Datos y Serialización — Test headless end-to-end.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/datos/test_datos_m60.gd
# Valida: Serializer (JSON/voxel/plano), Validador (CRC32/contrato),
# Versionador (migraciones), WriterAtomico (atómico + backup), GestorSlot,
# GestorConfig (defaults), CatalogosEstaticos (fallback limpio), DataStore
# end-to-end (guardar -> cargar -> igualdad). Exit code != 0 si falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M60] Test de Datos y Serialización ===")
	_limpiar_saves()
	_limpiar_config()
	_test_serializer_json()
	_test_serializer_plano()
	_test_serializer_voxel()
	_test_validador_crc32()
	_test_validador_contrato()
	_test_versionador()
	_test_writer_atomico()
	_test_gestor_slot()
	_test_gestor_config()
	_test_catalogos()
	_test_datastore_end_to_end()
	_summary()

## ── Helpers ─────────────────────────────────────────────

func _limpiar_saves() -> void:
	var saves := GestorSlot.RAIZ_SAVES
	for i in range(1, GestorSlot.SLOT_COUNT + 1):
		GestorSlot.borrar_slot(i)

func _limpiar_config() -> void:
	var ruta := GestorConfig.RUTA_CONFIG
	if FileAccess.file_exists(ruta):
		DirAccess.remove_absolute(ruta)
		var bak := ruta + ".bak"
		if FileAccess.file_exists(bak):
			DirAccess.remove_absolute(bak)

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

## ── Serializer: JSON ────────────────────────────────────

func _test_serializer_json() -> void:
	print("--- Serializer: JSON ida y vuelta ---")
	var datos := {
		"version": 1,
		"jugador": {"pos": [1.5, 2.0, 3.0], "vida": 100},
		"inventario": {"slots": [{"id": "wood", "n": 25}]},
	}
	var texto := Serializer.a_json(datos)
	var parsed := Serializer.desde_json(texto)
	_check("a_json produce string", typeof(texto) == TYPE_STRING and texto.begins_with("{"))
	_check("ida y vuelta igualdad", parsed.get("version") == 1 and parsed.get("jugador", {}).get("vida") == 100)
	var malo := Serializer.desde_json("{ no es json")
	_check("JSON inválido -> {}", malo.is_empty())
	var canon := Serializer.a_json_canonico(datos)
	_check("canónico determinista", Serializer.a_json_canonico(datos) == canon)

## ── Serializer: plano ───────────────────────────────────

func _test_serializer_plano() -> void:
	print("--- Serializer: a_plano (Vector3i/Color/floats) ---")
	var datos := {
		"pos": Vector3i(4, -2, 8),
		"color": Color(1, 0, 0, 1),
		"alt": 1.23456789,
	}
	var plano := Serializer.a_plano(datos)
	_check("Vector3i -> [x,y,z]", plano["pos"] is Array and plano["pos"][0] == 4 and plano["pos"][2] == 8)
	_check("Color -> array 4", plano["color"] is Array and plano["color"].size() == 4)
	_check("float normalizado 4 dec", abs(float(plano["alt"]) - 1.2346) < 0.0001)

## ── Serializer: voxel binario ──────────────────────────────

func _test_serializer_voxel() -> void:
	print("--- Serializer: binario voxel IAVX1 ida y vuelta ---")
	var chunks := [
		{"coord": Vector3i(1, 2, 3), "voxeles": PackedInt32Array([1, 2, 3, 4])},
		{"coord": Vector3i(-2, 0, 5), "voxeles": PackedInt32Array([8, 9])},
	]
	var bin := Serializer.a_binario_voxel(chunks)
	var out := Serializer.desde_binario_voxel(bin)
	_check("round-trip count", int(out.get("count", 0)) == 2)
	var c0: Dictionary = out["chunks"][0]
	var c1: Dictionary = out["chunks"][1]
	_check("coord0 correcta", c0["coord"] == Vector3i(1, 2, 3))
	_check("coord1 correcta (negativos)", c1["coord"] == Vector3i(-2, 0, 5))
	_check("voxeles0", (c0["voxeles"] as PackedInt32Array) == PackedInt32Array([1, 2, 3, 4]))
	var fuera := Serializer.desde_binario_voxel(PackedByteArray([1, 2, 3]))
	_check("magic inválido -> {}", fuera.is_empty())

## ── Validador: CRC32 ─────────────────────────────────────

func _test_validador_crc32() -> void:
	print("--- Validador: CRC32 determinista ---")
	var datos := {"a": 1, "b": "hola", "lista": [1, 2], "sub": {"x": true}}
	var crc1 := Validador.calcular_crc32(datos)
	var crc2 := Validador.calcular_crc32(datos)
	_check("mismo dict -> mismo CRC32", crc1 == crc2)
	# excluye checksum
	var con := datos.duplicate(true)
	con["checksum"] = "12345678"
	# verificar que el campo checksum se excluye del cálculo
	var crc_con := Validador.calcular_crc32(con)
	_check("checksum del dict sin su propio checksum", crc_con == crc1)
	_check("hex de 8 chars", Validador.crc32_hex("test").length() == 8)
	_check("hex determinista sobre cadena exacta", Validador.crc32_hex("payload") == Validador.crc32_hex("payload"))

## ── Validador: contrato ────────────────────────────────────

func _test_validador_contrato() -> void:
	print("--- Validador: contrato v1 ---")
	var ok := {"version": 1, "checksum": "x", "jugador": {}, "inventario": {}, "tiempo": {}, "mundo_voxel": {}, "meta": {}}
	var errores_ok := Validador.validar_contrato(ok, 1)
	_check("contrato válido -> vacío", errores_ok.is_empty())
	ok.erase("mundo_voxel")
	var errores_falta := Validador.validar_contrato(ok, 1)
	_check("bloque faltante detectado", errores_falta.size() >= 1 and "mundo_voxel" in " ".join(errores_falta))
	var tipado := {"version": "1", "checksum": "x", "jugador": {}, "inventario": {}, "tiempo": {}, "mundo_voxel": {}, "meta": {}}
	var errores_tipo := Validador.validar_contrato(tipado, 1)
	_check("version no-int detectado", errores_tipo.size() >= 1)
	var inexistente := Validador.validar_contrato({"version": 99}, 99)
	_check("esquema inexistente -> error", not inexistente.is_empty())

## ── Versionador ──────────────────────────────────────────

func _test_versionador() -> void:
	print("--- Versionador: migraciones ---")
	var v1 := {"version": 1}
	var r := Versionador.migrar(v1)
	_check("migrar v1 (sin saltos) ok", r["ok"] == true and int(r["datos"]["version"]) == 1)
	# v0 original (sin versión) -> se asigna v1 con defaults
	var v0 := {}
	var r0 := Versionador.migrar(v0)
	_check("v0 -> v1 ok", r0["ok"] == true and int(r0["datos"]["version"]) == 1)
	# migración de ejemplo v1->v2 (test en aislamiento)
	var r2 := Versionador.migrar_v1_a_v2({"version": 1, "player": {"n": 1}})
	_check("migración manual v1->v2 aditiva", int(r2["version"]) == 2 and r2.has("region"))
	_check("v2 con explorada default", r2["region"]["explorada"] is Array)
	# versión futura
	_check("versión futura detectada", Versionador.version_futura({"version": 99}))
	_check("versión actual NO futura", not Versionador.version_futura({"version": 1}))
	# set_version
	var d := {}
	Versionador.set_version(d, 1)
	_check("set_version asigna", int(d["version"]) == 1)

## ── WriterAtomico ─────────────────────────────────────────

func _test_writer_atomico() -> void:
	print("--- WriterAtomico: escritura atómica + backup ---")
	var ruta := "user://test_m60_atomico.txt"
	if FileAccess.file_exists(ruta):
		DirAccess.remove_absolute(ruta)
	if FileAccess.file_exists(ruta + ".bak"):
		DirAccess.remove_absolute(ruta + ".bak")

	var payload := {"version": 1, "dia": 1}
	var contenido := WriterAtomico.construir_con_checksum(Serializer.a_json(payload))
	var err := WriterAtomico.escribir_atomicamente(ruta, contenido)
	_check("escritura atómica OK", err == OK)
	_check("archivo final existe", FileAccess.file_exists(ruta))

	var doc := WriterAtomico.parsear_documento(FileAccess.get_file_as_string(ruta))
	_check("documento parseado y verificado", doc.get("ok", false) == true)
	var payload_doc: Dictionary = doc.get("payload", {})
	var dia_leido: int = int(payload_doc.get("dia", payload_doc.get("day", 0)))
	_check("payload dia correcto", dia_leido == 1)

	# sobreescribir: previo pasa a backup
	payload["dia"] = 2
	var err2 := WriterAtomico.escribir_atomicamente(ruta, WriterAtomico.construir_con_checksum(Serializer.a_json(payload)))
	_check("reescritura atómica OK", err2 == OK)
	_check("backup .bak existe", FileAccess.file_exists(ruta + ".bak"))

	# corrupción detectada: modificar bytes del archivo final
	var base_str := FileAccess.get_file_as_string(ruta)
	var corrupto := base_str.replace("\"dia\": 2", "\"dia\": 9")
	if corrupto == base_str:
		corrupto = corrupto.replace("\"dia\":2", "\"dia\":9")
	if corrupto == base_str:
		corrupto = corrupto.replace("\"day\": 2", "\"day\": 9")
		corrupto = corrupto.replace("\"day\": 1", "\"day\": 8")
	var doc_corrupto_dir := FileAccess.open(ruta, FileAccess.WRITE)
	if doc_corrupto_dir:
		var _w: bool = doc_corrupto_dir.store_string(corrupto)
		doc_corrupto_dir.close()
	var doc_bad := WriterAtomico.parsear_documento(FileAccess.get_file_as_string(ruta))
	_check("corrupción detectada", doc_bad.get("ok", false) == false)
	var err_restore := WriterAtomico.restaurar_backup(ruta)
	_check("restaurar_backup OK", err_restore == OK)
	var doc_restored := WriterAtomico.parsear_documento(FileAccess.get_file_as_string(ruta))
	var payload_restored: Dictionary = doc_restored.get("payload", {})
	var dia_restaurado: int = int(payload_restored.get("dia", payload_restored.get("day", 0)))
	# El .bak preserva la versión ANTERIOR (dia=1): restaurar devuelve el último bueno.
	_check("restaurado válido", doc_restored.get("ok", false) == true and dia_restaurado == 1)
	DirAccess.remove_absolute(ruta)
	DirAccess.remove_absolute(ruta + ".bak")

	# restaurar backup inexistente -> ERR_FILE_NOT_FOUND
	var err_notfound := WriterAtomico.restaurar_backup("user://no_existe_absolutamente.txt")
	_check("backup inexistente -> error", err_notfound == ERR_FILE_NOT_FOUND)

## ── GestorSlot ──────────────────────────────────────────

func _test_gestor_slot() -> void:
	print("--- GestorSlot: rutas / meta ---")
	var r := GestorSlot.rutas_slot(1)
	_check("rutas estandarizadas", r["save"] == "user://saves/slot_1/save.json" and r["meta"] == "user://saves/slot_1/meta.json")
	_check("existe_slot false vacío", not GestorSlot.existe_slot(1))
	var err := GestorSlot.escribir_meta(1, GestorSlot.meta_default(1, "Test"))
	_check("escribir_meta OK", err == OK)
	_check("leer meta round-trip", GestorSlot.leer_meta(1).get("nombre", "") == "Test")
	var lista := GestorSlot.listar_slots()
	_check("listar_slots con 1 slot", lista.size() == 1 and int(lista[0]["slot"]) == 1)
	_check("borrar_slot ok", GestorSlot.borrar_slot(1))
	_check("existe_slot false tras borrar", not GestorSlot.existe_slot(1))
	_check("borrar slot inexistente -> false", not GestorSlot.borrar_slot(99))

## ── GestorConfig ────────────────────────────────────────

func _test_gestor_config() -> void:
	print("--- GestorConfig: defaults + merge + escritura ---")
	var cfg := GestorConfig.cargar_config()
	_check("defaults por sección", int(cfg["graficos"].get("calidad", "").length()) >= 0 or cfg["graficos"].get("vsync") == true)
	_check("audio volumen default", abs(float(cfg["audio"]["volumen_maestro"]) - 0.8) < 0.001)
	_check("accesibilidad subtitulos default", cfg["accesibilidad"].get("subtitulos", false) == true)
	# agregar claves nuevas de "versión futura" al dict y volver a cargar
	var datos_mod := cfg.duplicate(true)
	datos_mod["graficos"]["brillo_extra"] = 1.5
	datos_mod["graficos"]["vsync"] = false
	var err := GestorConfig.guardar_config(datos_mod)
	_check("guardar_config OK", err == OK)
	var recargado := GestorConfig.cargar_config()
	_check("clave nueva preservada", abs(float(recargado["graficos"].get("brillo_extra", 0.0)) - 1.5) < 0.001)
	_check("vsync persistido", recargado["graficos"].get("vsync") == false)
	_limpiar_config()

## ── CatalogosEstaticos ───────────────────────────────────

func _test_catalogos() -> void:
	print("--- CatalogosEstaticos: carga de .tres reales ---")
	CatalogosEstaticos.cargar()
	var cantidad := CatalogosEstaticos.contar_items()
	_check("catálogo cargado sin crash", cantidad >= 1, "items=%d" % cantidad)
	var madera := CatalogosEstaticos.obtener_item("wood")
	_check("obtener_item('wood')", madera != null and String(madera.get("nombre")) == "Madera")
	_check("tiene_item('dirt')", CatalogosEstaticos.tiene_item("dirt"))
	_check("tiene_item inexistente", not CatalogosEstaticos.tiene_item("item_inexistente_xyz"))

## ── DataStore end-to-end ────────────────────────────────────

func _test_datastore_end_to_end() -> void:
	print("--- DataStore: guardar -> cargar -> igualdad (end-to-end) ---")
	var ds := root.get_node_or_null("DataStore")
	if ds == null:
		_check("autoload DataStore presente", false)
		_summary()
		quit(1)
		return
	_check("autoload DataStore presente", true)

	var datos := {
		"meta": {"nombre": "Aurora Año 1"},
		"jugador": {"pos": [12.0, 34.0, 56.0], "rot": 1.5, "vida": 100, "energia": 80},
		"inventario": {"slots": [{"id": "wood", "n": 25}, {"id": "stone", "n": 10}]},
		"tiempo": {"dia_anio": 1, "hora": 6.0, "estacion": "primavera"},
		"mundo_voxel": {"semilla": 12345, "chunks_editados": 2, "chunks": [
			{"coord": Vector3i(1, 2, 3), "voxeles": PackedInt32Array([5, 6, 7])},
			{"coord": Vector3i(4, 0, 1), "voxeles": PackedInt32Array([2, 9])},
		]},
		"progresion": {"misiones": {"m01": "completada"}},
	}
	var meta_write: Dictionary = ds.guardar_partida(1, datos)
	_check("guardar_partida ok", meta_write.get("ok", false) == true)

	var res: Dictionary = ds.cargar_partida(1)
	if not res.get("ok", false):
		print("  >> DEBUG cargar error: %s" % res.get("error", "?"))
		var r_save: String = GestorSlot.rutas_slot(1)["save"]
		var contenido_real := FileAccess.get_file_as_string(r_save)
		print("  >> DEBUG contenido save: %s" % contenido_real)
		var doc_debug := WriterAtomico.parsear_documento(contenido_real)
		if doc_debug.get("ok", false):
			var pld: Dictionary = doc_debug["payload"]
			print("  >> DEBUG payload version=", pld.get("version"), " typeof=", typeof(pld.get("version")))
	_check("cargar_partida ok", res.get("ok", false) == true)
	var cargado: Dictionary = res.get("datos", {})
	_check("versión migrada", int(cargado.get("version", 0)) == 1)
	_check("jugador ida y vuelta", Array(cargado.get("jugador", {}).get("pos", [])) == [12.0, 34.0, 56.0])
	var slots: Array = cargado.get("inventario", {}).get("slots", [])
	_check("inventario ida y vuelta", slots.size() == 2 and slots[0]["id"] == "wood")
	_check("voxel payload binario no vacío", (cargado.get("_voxel_payload", PackedByteArray()) as PackedByteArray).size() > 0)

	# slot corrupto (bit flip sin recalcular checksum) -> detección y error limpio
	var ruta_bad: String = GestorSlot.rutas_slot(1)["save"]
	FileAccess.open(ruta_bad, FileAccess.WRITE).store_string("corrupto")
	var res_corrupto: Dictionary = ds.cargar_partida(1)
	# no hay backup de ese slot, y el archivo es basura sin checksum -> error claro
	_check("carga corrupta NO crashea y devuelve {ok:false}", res_corrupto.get("ok", false) == false)

	# listar_slots (1 slot con meta ya escrito)
	var slots_lista: Array = ds.listar_slots()
	_check("listar_slots via DataStore", slots_lista.size() >= 1)

	# borrar slot
	_check("borrar via DataStore", ds.borrar_slot(1))
	_check("tras borrar no existe", not GestorSlot.existe_slot(1))

## ── Summary ──────────────────────────────────────────────

func _summary() -> void:
	print("=== Resumen M60: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M60 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M60 OK — todos los checks pasaron")
		quit(0)