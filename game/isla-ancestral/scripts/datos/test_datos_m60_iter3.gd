# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-11
#
# M60 iter. 3 — Test headless de los ítems cerrados en esta iteración:
#   T-018  RF3 construcciones y casas  -> EstructurasCodec + BuildingsSaveProvider
#   T-109  política de rotación/limpieza de .bak (M107)
#   T-145  compresión ZIP_DEFLATE opcional del voxel
#   T-164  progreso del guardado expuesto a la UI (M53)
#   T-200  compresión bajo demanda según tamaño
#   T-201  carga perezosa de catálogos
#   T-206  presupuestos RN1/RN2 medidos (Profiler no aplicable en headless:
#          se miden ticks reales y se comparan contra los presupuestos)
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/datos/test_datos_m60_iter3.gd
# Exit code != 0 si algún check falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0
var _progreso_async: Array = []


## Fuente de construcciones simulada para probar el provider sin M17.
## Implementa el contrato por duck-typing (mismos nombres de método).
class FuenteFake extends Node:
	var estructuras: Array = []
	var restauradas: Array = []
	var restaurar_disponible: bool = true

	func obtener_estructuras() -> Array:
		return estructuras

	func restaurar_estructuras(lista: Array) -> void:
		restauradas = lista

## Fuente que NO expone restaurar_estructuras (restore debe ser no-op gracioso).
class FuenteSoloLectura extends Node:
	func obtener_estructuras() -> Array:
		return [{"id": "solo_lectura", "tipo": "pared", "pos": [1, 0, 1], "rot_y": 0, "planta": 0, "variante": ""}]


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== [M60 iter. 3] RF3 buildings + backups + compresión + perezoso ===")
	_limpiar_saves()
	_test_estructuras_codec()
	_test_estructuras_validar()
	await _test_buildings_provider()
	_test_rf3_fauna_vecinos()
	_test_rotacion_backups()
	_test_compresion_voxel()
	_test_catalogos_perezosos()
	_test_presupuestos_rn()
	await _test_progreso_async()
	_summary()


## ── Helpers ─────────────────────────────────────────────

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])


func _limpiar_saves() -> void:
	for i in range(1, GestorSlot.SLOT_COUNT + 1):
		GestorSlot.borrar_slot(i)
		var r := GestorSlot.rutas_slot(i)
		for extra in [".deflate", ".bak", ".bak.1", ".bak.2", ".bak.3", ".bak.5", ".tmp"]:
			var p: String = String(r["save"]) + extra
			if FileAccess.file_exists(p):
				DirAccess.remove_absolute(p)
			var pv: String = String(r["voxel"]) + extra
			if FileAccess.file_exists(pv):
				DirAccess.remove_absolute(pv)


## ── T-018: EstructurasCodec ─────────────────────────────

func _test_estructuras_codec() -> void:
	print("--- EstructurasCodec: normalización ---")
	var crudo: Array = [
		{"id": "casa_02", "tipo": "casa", "pos": Vector3i(10, 0, -4), "rot_y": 450, "planta": 1, "variante": "tejado_paja"},
		{"id": "muro_01", "tipo": "muro", "pos": Vector3(3.4, 0.0, 2.6), "rot_y": -90, "planta": -5},
		{"id": "puerta_01", "tipo": "puerta", "pos": [1, 0, 1], "rot_y": 95},
	]
	var norm := EstructurasCodec.normalizar(crudo)
	_check("normaliza 3 estructuras", norm.size() == 3, "size=%d" % norm.size())
	_check("orden determinista por id",
		String(norm[0]["id"]) == "casa_02" and String(norm[1]["id"]) == "muro_01"
		and String(norm[2]["id"]) == "puerta_01",
		str([norm[0]["id"], norm[1]["id"], norm[2]["id"]]))
	_check("Vector3i -> int32", norm[0]["pos"] == [10, 0, -4], str(norm[0]["pos"]))
	_check("Vector3 -> redondeado int32", norm[1]["pos"] == [3, 0, 3], str(norm[1]["pos"]))
	_check("rot_y 450 -> 90", int(norm[0]["rot_y"]) == 90, str(norm[0]["rot_y"]))
	_check("rot_y -90 -> 270", int(norm[1]["rot_y"]) == 270, str(norm[1]["rot_y"]))
	_check("rot_y 95 -> 90 (múltiplo más cercano)", int(norm[2]["rot_y"]) == 90, str(norm[2]["rot_y"]))
	_check("planta negativa -> 0", int(norm[1]["planta"]) == 0, str(norm[1]["planta"]))
	_check("claves exactas de la estructura",
		norm[0].keys() == EstructurasCodec.CLAVES, str(norm[0].keys()))

	# Tolerancia a basura
	var sucio: Array = [42, "texto", {"sin_id": true}, {"id": "  "}, {"id": "ok", "pos": "basura"}]
	var norm2 := EstructurasCodec.normalizar(sucio)
	_check("descarta entradas inválidas", norm2.size() == 1, "size=%d" % norm2.size())
	_check("pos basura -> [0,0,0]", norm2[0]["pos"] == [0, 0, 0], str(norm2[0]["pos"]))
	_check("entrada no-Array -> []", EstructurasCodec.normalizar("x").is_empty())
	_check("null -> []", EstructurasCodec.normalizar(null).is_empty())

	# Determinismo (checksum estable) y sin aliasing
	var a := EstructurasCodec.normalizar(crudo)
	var b := EstructurasCodec.normalizar(crudo)
	_check("determinismo: mismo JSON canónico",
		Serializer.a_json_canonico({"s": a}) == Serializer.a_json_canonico({"s": b}))
	var c := EstructurasCodec.normalizar([crudo[2], crudo[1], crudo[0]])
	_check("mismo resultado con entrada en otro orden",
		Serializer.a_json_canonico({"s": c}) == Serializer.a_json_canonico({"s": a}))
	a[0]["id"] = "MUTADO"
	_check("sin aliasing con la entrada", String(crudo[0]["id"]) == "casa_02")

	# Sección
	var seccion := EstructurasCodec.a_seccion(crudo)
	_check("a_seccion tiene 'structures'", seccion.has("structures") and (seccion["structures"] as Array).size() == 3)
	_check("desde_seccion redondo", EstructurasCodec.desde_seccion(seccion).size() == 3)
	_check("desde_seccion tolerante (ausente)", EstructurasCodec.desde_seccion({}).is_empty())
	_check("desde_seccion tolerante (no dict)", EstructurasCodec.desde_seccion("x").is_empty())
	_check("contar()", EstructurasCodec.contar(crudo) == 3)
	_check("huella estable",
		EstructurasCodec.huella(crudo) == EstructurasCodec.huella([crudo[2], crudo[0], crudo[1]]))
	_check("huella cambia al cambiar datos",
		EstructurasCodec.huella(crudo) != EstructurasCodec.huella([{"id": "otra", "pos": [0, 0, 0]}]))


func _test_estructuras_validar() -> void:
	print("--- EstructurasCodec: validación ---")
	var bueno := EstructurasCodec.normalizar([
		{"id": "a", "tipo": "muro", "pos": Vector3i(1, 0, 1)},
		{"id": "b", "tipo": "muro", "pos": Vector3i(2, 0, 2)},
	])
	_check("lista válida -> 0 errores", EstructurasCodec.validar(bueno).is_empty(),
		str(EstructurasCodec.validar(bueno)))
	_check("id duplicado -> error",
		not EstructurasCodec.validar([bueno[0], bueno[0]]).is_empty())
	_check("sin id -> error", not EstructurasCodec.validar([{"id": ""}]).is_empty())
	_check("pos no-array -> error", not EstructurasCodec.validar([{"id": "x", "pos": "nope"}]).is_empty())
	_check("pos con float -> error", not EstructurasCodec.validar([{"id": "x", "pos": [1.5, 0, 0]}]).is_empty())
	_check("planta negativa -> error", not EstructurasCodec.validar([{"id": "x", "pos": [0, 0, 0], "planta": -1}]).is_empty())
	_check("entrada no-Dictionary -> error", not EstructurasCodec.validar([7]).is_empty())


## ── T-018: BuildingsSaveProvider ────────────────────────

func _test_buildings_provider() -> void:
	print("--- BuildingsSaveProvider: contrato ISaveProvider ---")
	var prov := BuildingsSaveProvider.new()
	_check("sección = buildings", prov.get_section_name() == "buildings", prov.get_section_name())
	_check("sin fuente: sección con default",
		prov.get_save_data() == {"structures": []}, str(prov.get_save_data()))
	_check("sin fuente: restore es no-op", not prov.tiene_fuente())
	prov.restore_save_data({"structures": [{"id": "x"}]})  # no debe crashear
	_check("restore sin fuente no crashea", true)

	var fake := FuenteFake.new()
	fake.estructuras = [
		{"id": "casa_02", "tipo": "casa", "pos": Vector3i(10, 0, -4), "rot_y": 450, "planta": 1},
		{"id": "muro_01", "tipo": "muro", "pos": [3, 0, 3], "rot_y": 0},
	]
	root.add_child(fake)
	_check("fuente detectada por duck-typing", prov.tiene_fuente())
	var guardado := prov.get_save_data()
	_check("get_save_data serializa la fuente",
		(guardado["structures"] as Array).size() == 2, str(guardado))
	_check("estructuras normalizadas en el save",
		(guardado["structures"] as Array)[0]["pos"] == [10, 0, -4]
		and int((guardado["structures"] as Array)[0]["rot_y"]) == 90,
		str(guardado["structures"][0]))
	# Sin aliasing: mutar el snapshot no toca la fuente ni el siguiente snapshot
	(guardado["structures"] as Array)[0]["id"] = "MUTADO"
	var guardado2 := prov.get_save_data()
	_check("sin aliasing con la fuente",
		String((guardado2["structures"] as Array)[0]["id"]) == "casa_02",
		String((guardado2["structures"] as Array)[0]["id"]))
	_check("mutar el snapshot no afecta al siguiente",
		(guardado2["structures"] as Array)[0]["pos"] == [10, 0, -4],
		str((guardado2["structures"] as Array)[0]))

	# Restore
	prov.restore_save_data({"structures": [
		{"id": "nueva", "tipo": "puente", "pos": Vector3i(-5, 1, 7), "rot_y": 180},
	]})
	_check("restore entrega la lista normalizada",
		fake.restauradas.size() == 1 and String(fake.restauradas[0]["id"]) == "nueva",
		str(fake.restauradas))
	_check("restore normaliza pos", fake.restauradas[0]["pos"] == [-5, 1, 7], str(fake.restauradas[0]["pos"]))

	# Fuente sin método de restauración: no-op gracioso
	fake.queue_free()
	await process_frame
	var solo_lectura := FuenteSoloLectura.new()
	root.add_child(solo_lectura)
	prov.restore_save_data({"structures": [{"id": "z", "pos": [0, 0, 0]}]})
	_check("fuente sin restaurar_estructuras: no-op sin crash", true)
	solo_lectura.queue_free()
	await process_frame


## ── T-019: RF3 fauna (M36) y vecinos (M19) ──────────────
##
## No es una brecha de implementación: los providers ya existen y están
## registrados (VillagerManager -> "npc", fauna_registry -> "fauna_registry").
## Este bloque lo VERIFICA por contrato, para poder marcar el ítem con
## evidencia en vez de por inspección.

func _test_rf3_fauna_vecinos() -> void:
	print("--- RF3 fauna y vecinos: providers ya operativos (verificación) ---")
	var vm := root.get_node_or_null("VillagerManager")
	_check("autoload VillagerManager (M19) presente", vm != null)
	if vm != null:
		_check("M19 implementa get_section_name", vm.has_method("get_section_name"))
		_check("M19 implementa get_save_data", vm.has_method("get_save_data"))
		_check("M19 implementa restore_save_data", vm.has_method("restore_save_data"))
		_check("M19 reclama la sección 'npc'", String(vm.get_section_name()) == "npc",
			String(vm.call("get_section_name")))
		var datos: Variant = vm.call("get_save_data")
		_check("M19 get_save_data devuelve Dictionary", typeof(datos) == TYPE_DICTIONARY)
		if typeof(datos) == TYPE_DICTIONARY:
			_check("M19 aporta contenido real en 'npc'", not (datos as Dictionary).is_empty(),
				str((datos as Dictionary).keys()))
			# CARACTERIZACIÓN (no un defecto de M60): M19 usa claves propias
			# (visitantes/hogares/memoria/...) distintas del default del schema
			# (npcs/dialogs_seen). Registrado en 11-BUGS.md como hallazgo
			# cross-módulo; el fix corresponde al dueño de M19.
			var claves_schema: Array = (SaveSchema.default_payload()["npc"] as Dictionary).keys()
			_check("caracterización: M19 usa claves propias ≠ default del schema",
				(datos as Dictionary).keys() != claves_schema,
				"provider=%s schema=%s" % [str((datos as Dictionary).keys()), str(claves_schema)])

	var fr := root.get_node_or_null("fauna_registry")
	_check("autoload fauna_registry (M36) presente", fr != null)
	if fr != null:
		_check("M36 implementa get_section_name", fr.has_method("get_section_name"))
		_check("M36 reclama una sección propia",
			String(fr.call("get_section_name")) == "fauna_registry",
			String(fr.call("get_section_name")))
		_check("M36 get_save_data devuelve Dictionary",
			typeof(fr.call("get_save_data")) == TYPE_DICTIONARY)

	# Registro real en el snapshot de M59: 'npc' y 'buildings' ya NO están
	# entre las secciones sin reclamar.
	var sm := root.get_node_or_null("SaveManager")
	_check("autoload SaveManager (M59) presente", sm != null)
	if sm != null:
		var sin_reclamar: Array = sm.snapshot.unclaimed_sections()
		_check("'npc' reclamada por M19", not sin_reclamar.has("npc"), str(sin_reclamar))
		_check("'player' reclamada", not sin_reclamar.has("player"), str(sin_reclamar))
		_check("'buildings' reclamada por M60 (iter. 3)", not sin_reclamar.has("buildings"),
			str(sin_reclamar))
		var payload: Dictionary = sm.snapshot.collect("test_m60_iter3")
		_check("collect() incluye la sección npc", payload.has("npc"))
		_check("collect() incluye la sección buildings", payload.has("buildings"))
		_check("buildings del collect tiene la forma del schema",
			typeof(payload.get("buildings", null)) == TYPE_DICTIONARY
			and (payload["buildings"] as Dictionary).has("structures"),
			str(payload.get("buildings")))


## ── T-109: rotación de .bak ─────────────────────────────

func _test_rotacion_backups() -> void:
	print("--- GestorBackups: ventana deslizante de copias ---")
	var ruta := "user://saves/_test_rotacion.json"
	for extra in ["", ".bak", ".bak.1", ".bak.2", ".bak.3", ".bak.5", ".tmp"]:
		if FileAccess.file_exists(ruta + extra):
			DirAccess.remove_absolute(ruta + extra)

	for v in ["v1", "v2", "v3", "v4"]:
		var err := WriterAtomico.escribir_atomicamente(ruta, WriterAtomico.construir_con_checksum("{\"v\":\"%s\"}" % v))
		_check("escritura %s OK" % v, err == OK, "err=%d" % err)

	_check("existe .bak (v3)", FileAccess.file_exists(ruta + ".bak"))
	_check("existe .bak.1 (v2)", FileAccess.file_exists(ruta + ".bak.1"))
	_check("existe .bak.2 (v1)", FileAccess.file_exists(ruta + ".bak.2"))
	_check("NO existe .bak.3 (ventana = 3)", not FileAccess.file_exists(ruta + ".bak.3"))

	var p_bak := WriterAtomico.parsear_documento(FileAccess.get_file_as_string(ruta + ".bak"))
	var p_1 := WriterAtomico.parsear_documento(FileAccess.get_file_as_string(ruta + ".bak.1"))
	var p_2 := WriterAtomico.parsear_documento(FileAccess.get_file_as_string(ruta + ".bak.2"))
	_check(".bak contiene v3", String(p_bak.get("payload_str", "")) == "{\"v\":\"v3\"}", str(p_bak.get("payload_str")))
	_check(".bak.1 contiene v2", String(p_1.get("payload_str", "")) == "{\"v\":\"v2\"}", str(p_1.get("payload_str")))
	_check(".bak.2 contiene v1", String(p_2.get("payload_str", "")) == "{\"v\":\"v1\"}", str(p_2.get("payload_str")))
	_check("listar() devuelve 3 copias", GestorBackups.listar(ruta).size() == 3,
		str(GestorBackups.listar(ruta)))
	_check("contar() = 3", GestorBackups.contar(ruta) == 3)
	_check("espacio_usado > 0", GestorBackups.espacio_usado(ruta) > 0)

	# Restauración por índice (M107)
	var err_restore := GestorBackups.restaurar(ruta, 1)
	var actual := WriterAtomico.parsear_documento(FileAccess.get_file_as_string(ruta))
	_check("restaurar(1) recupera v2", err_restore == OK and String(actual.get("payload_str", "")) == "{\"v\":\"v2\"}",
		"err=%d payload=%s" % [err_restore, str(actual.get("payload_str"))])
	_check("restaurar(9) -> ERR_FILE_NOT_FOUND", GestorBackups.restaurar(ruta, 9) == ERR_FILE_NOT_FOUND)

	# Limpieza de huérfanas fuera de la ventana
	var huerfana := ruta + ".bak.5"
	var f := FileAccess.open(huerfana, FileAccess.WRITE)
	f.store_string("viejo")
	f.close()
	_check("huérfana .bak.5 creada", FileAccess.file_exists(huerfana))
	var borrados := GestorBackups.limpiar_antiguos(ruta)
	_check("limpiar_antiguos borra la huérfana",
		borrados == 1 and not FileAccess.file_exists(huerfana), "borrados=%d" % borrados)

	# La API pública del DataStore delega
	var ds := root.get_node_or_null("DataStore")
	if ds != null:
		_check("DataStore.copias_backup delega", ds.copias_backup(1) is Array)
		_check("DataStore.restaurar_backup existe", ds.has_method("restaurar_backup"))
		_check("DataStore.mantener_backups existe", ds.has_method("mantener_backups"))
		_check("DataStore.progreso_guardado existe", ds.has_method("progreso_guardado"))

	for extra in ["", ".bak", ".bak.1", ".bak.2", ".bak.3", ".bak.5", ".tmp"]:
		if FileAccess.file_exists(ruta + extra):
			DirAccess.remove_absolute(ruta + extra)


## ── T-145 / T-200: compresión del voxel ─────────────────

func _test_compresion_voxel() -> void:
	print("--- Compresión ZIP_DEFLATE del voxel bajo criterio de tamaño ---")
	var ds := root.get_node_or_null("DataStore")
	if ds == null:
		_check("autoload DataStore presente", false)
		return
	_check("autoload DataStore presente", true)
	_check("umbral de compresión definido", ds.UMBRAL_COMPRESION_BYTES == 65536,
		str(ds.UMBRAL_COMPRESION_BYTES))

	var slot := 1
	var r := GestorSlot.rutas_slot(slot)
	GestorSlot.asegurar_directorio(slot)

	# Caso A: bajo el umbral -> no comprime
	var chico := PackedByteArray()
	chico.resize(1024)
	_escribir_bytes(r["voxel"], chico)
	var a: Dictionary = ds.comprimir_mundo_voxel(slot)
	_check("bajo el umbral: no comprime", not bool(a["comprimido"]), str(a))
	_check("bajo el umbral: motivo correcto", String(a.get("motivo", "")).contains("umbral"), str(a.get("motivo")))
	_check("bajo el umbral: el plano sigue", FileAccess.file_exists(r["voxel"]))

	# Caso B: sobre el umbral y comprimible -> comprime y borra el plano
	var grande := PackedByteArray()
	grande.resize(200000)
	for i in range(grande.size()):
		grande[i] = (i / 64) % 16  # patrón muy repetitivo
	_escribir_bytes(r["voxel"], grande)
	var b: Dictionary = ds.comprimir_mundo_voxel(slot)
	_check("sobre el umbral: comprime", bool(b["comprimido"]), str(b))
	_check("comprime de verdad", int(b["bytes_despues"]) < int(b["bytes_antes"]), str(b))
	_check("existe el .deflate", FileAccess.file_exists(String(r["voxel"]) + ".deflate"))
	_check("el plano se eliminó", not FileAccess.file_exists(r["voxel"]))
	var leido: PackedByteArray = ds.cargar_mundo_voxel(slot)
	_check("round-trip idéntico", leido == grande, "leido=%d esperado=%d" % [leido.size(), grande.size()])

	# Caso F: ya comprimido -> no re-comprime
	var f2: Dictionary = ds.comprimir_mundo_voxel(slot)
	_check("ya comprimido: no re-comprime", bool(f2["comprimido"]) and String(f2.get("motivo", "")) == "ya comprimido",
		str(f2))

	# Caso D: descompresión revierte
	var d: Dictionary = ds.descomprimir_mundo_voxel(slot)
	_check("descomprime OK", bool(d["ok"]), str(d))
	_check("el plano volvió", FileAccess.file_exists(r["voxel"]))
	_check("el .deflate se borró", not FileAccess.file_exists(String(r["voxel"]) + ".deflate"))
	_check("contenido intacto tras descomprimir", FileAccess.get_file_as_bytes(r["voxel"]) == grande)

	# Caso C: sobre el umbral pero incompresible -> no comprime
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	var ruido := PackedByteArray()
	ruido.resize(200000)
	for i in range(ruido.size()):
		ruido[i] = rng.randi() % 256
	_escribir_bytes(r["voxel"], ruido)
	var c: Dictionary = ds.comprimir_mundo_voxel(slot)
	_check("incompresible: no comprime", not bool(c["comprimido"]), str(c))
	_check("incompresible: motivo 'no reduce'", String(c.get("motivo", "")).contains("no reduce"),
		str(c.get("motivo")))
	_check("incompresible: el plano sigue y no hay .deflate",
		FileAccess.file_exists(r["voxel"]) and not FileAccess.file_exists(String(r["voxel"]) + ".deflate"))

	# Caso E: integración con guardar_partida (compresión automática)
	var voxeles := PackedInt32Array()
	for i in range(20000):
		voxeles.append(i % 8)
	var datos := {
		"jugador": {"pos": [1.0, 2.0, 3.0]},
		"inventario": {"items": []},
		"tiempo": {"dia": 1, "hora": 6},
		"mundo_voxel": {"chunks_editados": 1, "chunks": [{"coord": Vector3i(0, 0, 0), "voxeles": voxeles}]},
		"meta": {"playtime_seconds": 0.0},
	}
	var meta: Dictionary = ds.guardar_partida(slot, datos)
	_check("guardar_partida con voxel grande OK", bool(meta.get("ok", false)), str(meta))
	_check("guardar_partida comprimió el voxel automáticamente",
		FileAccess.file_exists(String(r["voxel"]) + ".deflate") and not FileAccess.file_exists(r["voxel"]),
		"deflate=%s plano=%s" % [str(FileAccess.file_exists(String(r["voxel"]) + ".deflate")),
			str(FileAccess.file_exists(r["voxel"]))])
	var cargado: Dictionary = ds.cargar_partida(slot)
	_check("cargar_partida con voxel comprimido OK", bool(cargado.get("ok", false)), str(cargado))
	var payload: PackedByteArray = cargado["datos"].get("_voxel_payload", PackedByteArray())
	var decod := Serializer.desde_binario_voxel(payload)
	_check("el payload descomprimido decodifica IAVX1",
		not decod.is_empty() and int(decod.get("count", 0)) == 1, str(decod.get("count", -1)))
	_check("los vóxeles sobreviven al ciclo",
		(decod["chunks"][0]["voxeles"] as PackedInt32Array).size() == 20000,
		str((decod["chunks"][0]["voxeles"] as PackedInt32Array).size()))


func _escribir_bytes(ruta: String, datos: PackedByteArray) -> void:
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	f.store_buffer(datos)
	f.close()


## ── T-201: carga perezosa de catálogos ──────────────────

func _test_catalogos_perezosos() -> void:
	print("--- CatalogosEstaticos: carga perezosa ---")
	CatalogosEstaticos._reset_para_test()
	CatalogosEstaticos.cargar()
	var disponibles := CatalogosEstaticos.contar_items()
	_check("índice armado sin cargar Resources", disponibles >= 100, "disponibles=%d" % disponibles)
	_check("0 Resources en memoria tras indexar", CatalogosEstaticos.contar_cargados() == 0,
		"cargados=%d" % CatalogosEstaticos.contar_cargados())
	_check("rutas_indexadas coincide con el índice",
		CatalogosEstaticos.rutas_indexadas().size() == disponibles)

	_check("tiene_item('dirt') sin cargarlo", CatalogosEstaticos.tiene_item("dirt"))
	_check("tiene_item NO cargó nada", CatalogosEstaticos.contar_cargados() == 0,
		"cargados=%d" % CatalogosEstaticos.contar_cargados())
	_check("tiene_item('inexistente') false", not CatalogosEstaticos.tiene_item("item_inexistente_xyz"))

	var madera := CatalogosEstaticos.obtener_item("wood")
	_check("obtener_item('wood') carga el .tres",
		madera != null and String(madera.get("nombre")) == "Madera")
	_check("se cargó exactamente 1", CatalogosEstaticos.contar_cargados() == 1,
		"cargados=%d" % CatalogosEstaticos.contar_cargados())
	_check("segunda llamada usa la caché",
		CatalogosEstaticos.obtener_item("wood") == madera
		and CatalogosEstaticos.contar_cargados() == 1)
	_check("obtener_item inexistente -> null", CatalogosEstaticos.obtener_item("item_inexistente_xyz") == null)

	var todos := CatalogosEstaticos.cargar_todos()
	_check("cargar_todos() carga el catálogo completo", todos == disponibles,
		"cargados=%d disponibles=%d" % [todos, disponibles])


## ── T-206: presupuestos RN medidos ──────────────────────

func _test_presupuestos_rn() -> void:
	print("--- Presupuestos RN1/RN2 (medición real headless) ---")
	var ds := root.get_node_or_null("DataStore")
	if ds == null:
		_check("autoload DataStore presente", false)
		return
	var slot := 3
	# Payload realista: 200 items de inventario + construcciones + progresión
	var inventario: Array = []
	for i in range(200):
		inventario.append({"id": "item_%03d" % i, "n": i})
	var estructuras: Array = []
	for i in range(50):
		estructuras.append({"id": "est_%03d" % i, "tipo": "muro", "pos": Vector3i(i, 0, i), "rot_y": 90, "planta": i % 3})
	var datos := {
		"jugador": {"pos": [12.5, 3.25, -40.75], "vida": 100, "energia": 80},
		"inventario": {"items": inventario},
		"buildings": EstructurasCodec.a_seccion(estructuras),
		"progresion": {"misiones": ["m1", "m2", "m3"], "desbloqueos": ["d1"]},
		"tiempo": {"dia": 12, "estacion": 2, "hora": 14, "minuto": 30},
		"mundo_voxel": {"chunks_editados": 0},
		"meta": {"playtime_seconds": 3600.0},
	}
	var t0 := Time.get_ticks_msec()
	var meta: Dictionary = ds.guardar_partida(slot, datos)
	var t_guardar := Time.get_ticks_msec() - t0
	_check("guardado OK", bool(meta.get("ok", false)), str(meta))
	_check("RN1: guardar < 300 ms", t_guardar < 300, "medido=%d ms" % t_guardar)
	_check("RN2: save < 1 MB", int(meta.get("bytes", 0)) < 1048576, "bytes=%d" % int(meta.get("bytes", 0)))

	var t1 := Time.get_ticks_msec()
	var cargado: Dictionary = ds.cargar_partida(slot)
	var t_cargar := Time.get_ticks_msec() - t1
	_check("carga OK", bool(cargado.get("ok", false)), str(cargado))
	_check("RN1: cargar+validar+migrar < 1 s", t_cargar < 1000, "medido=%d ms" % t_cargar)
	_check("integridad: el inventario vuelve completo",
		((cargado["datos"].get("inventario", {}) as Dictionary).get("items", []) as Array).size() == 200)
	_check("integridad: las construcciones vuelven completas",
		EstructurasCodec.desde_seccion(cargado["datos"].get("buildings", {})).size() == 50)
	print("  [MEDIDO] guardar=%d ms · cargar=%d ms · bytes=%d" % [t_guardar, t_cargar, int(meta.get("bytes", 0))])


## ── T-164: progreso del guardado asincrónico ────────────

func _test_progreso_async() -> void:
	print("--- Progreso del guardado asincrónico (T-164) ---")
	var ds := root.get_node_or_null("DataStore")
	if ds == null:
		_check("autoload DataStore presente", false)
		return
	_progreso_async = []
	ds.guardado_async_progreso.connect(_on_progreso)

	var inventario: Array = []
	for i in range(500):
		inventario.append({"id": "item_%03d" % i, "n": i})
	var datos := {
		"jugador": {"pos": [0.0, 0.0, 0.0]},
		"inventario": {"items": inventario},
		"buildings": EstructurasCodec.a_seccion([{"id": "e1", "pos": Vector3i(1, 0, 1)}]),
	}
	var t0 := Time.get_ticks_msec()
	var res: Dictionary = ds.guardar_partida_async(2, datos)
	var t_llamada := Time.get_ticks_msec() - t0
	_check("guardar_partida_async aceptado", bool(res.get("aceptado", false)), str(res))
	_check("no bloquea el frame (< 50 ms)", t_llamada < 50, "medido=%d ms" % t_llamada)
	_check("progreso inicial 0.0 emitido", _progreso_async.size() >= 1 and float(_progreso_async[0]) == 0.0,
		str(_progreso_async))

	var frames := 0
	while ds.guardado_en_curso() and frames < 900:
		await process_frame
		frames += 1
	_check("el guardado terminó", not ds.guardado_en_curso(), "frames=%d" % frames)
	_check("progreso final 1.0 emitido",
		_progreso_async.size() >= 2 and float(_progreso_async[_progreso_async.size() - 1]) == 1.0,
		str(_progreso_async))
	_check("progreso monotónico no decreciente", _es_monotonico(_progreso_async), str(_progreso_async))
	_check("progreso_guardado() = 1.0 al terminar", float(ds.progreso_guardado()) == 1.0,
		str(ds.progreso_guardado()))
	_check("la sección buildings llegó al save",
		EstructurasCodec.desde_seccion(
			WriterAtomico.parsear_documento(
				FileAccess.get_file_as_string(GestorSlot.rutas_slot(2)["save"])).get("payload", {})
			.get("buildings", {})).size() == 1)
	ds.guardado_async_progreso.disconnect(_on_progreso)


func _on_progreso(_slot: int, porcentaje: float) -> void:
	_progreso_async.append(porcentaje)


func _es_monotonico(vals: Array) -> bool:
	for i in range(1, vals.size()):
		if float(vals[i]) < float(vals[i - 1]):
			return false
	return true


## ── Summary ──────────────────────────────────────────────

func _summary() -> void:
	print("=== Resumen M60 iter. 3: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M60 iter. 3 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M60 iter. 3 OK — todos los checks pasaron")
		quit(0)
