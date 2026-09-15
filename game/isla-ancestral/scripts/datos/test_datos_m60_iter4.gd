# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-15
#
# M60 iter. 4 — Suite de VERIFICACIÓN de los huecos que quedaron SIN evidencia
# de ejecución después de la auditoría del 2026-09-14 (que revirtió el módulo
# entero a 0/196, incluida la iter. 2/3 del propio autor, que sí tenía test
# headless). El objetivo NO es re-marcar por inspección: es convertir cada
# ítem discutible en un check ejecutable.
#
#   A. Motor de migración INYECTABLE (`Versionador.migrar_con_cadena`):
#      N saltos, cadena incompleta, migración que no avanza, v0 sin versión,
#      idempotencia, post-validación contra el contrato destino.
#   B. Patrones de migración: renombrar / eliminar / transformar + combinados.
#   C. Atomicidad, rotación de backups y tamaños (RN1/RN2/RN3).
#   D. Slots: meta.json regenerada, slot vacío, listar sin deserializar, borrado.
#   E. Catálogo estático: `validar_ids`, carga perezosa, IDs reales.
#   F. Log M103 (GameLogger REAL): guardado, carga, rechazos, detección temprana.
#   G. Integración: ServiceRegistry, SaveManager.collect(), orden de carga voxel.
#   H. Formato y determinismo (una sola serialización, sin BOM, pretty 2).
#
# ⚠️ Guardián anti-falso-verde: en GDScript un error de script ABORTA la función
# en silencio y la suite imprimiría "0 fallos" igual. Por eso cada bloque
# registra su cierre con `_fin()` y `_summary()` exige que estén los 8. Además
# hay un watchdog en `_process()` que corta con exit 1 si `_run()` no termina.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://scripts/datos/test_datos_m60_iter4.gd

extends SceneTree

const MODULO := "M60 iter. 4"
const TIMEOUT_FRAMES := 1800
const BLOQUES_ESPERADOS: Array[String] = ["A", "B", "C", "D", "E", "F", "G", "H"]

var _checks: int = 0
var _fallos: int = 0
var _bloque: String = ""
var _completados: Array[String] = []
var _checks_marca: int = 0
var _checks_por_bloque: Dictionary = {}
var _frames: int = 0
var _terminado: bool = false

var _ds: Node = null
var _gl: Node = null
var _config_original: PackedByteArray = PackedByteArray()
var _config_existia: bool = false

## Líneas capturadas del GameLogger, por la señal `line_emitted` (la vía fiable:
## captura exactamente lo que el logger emite en ESTE proceso, sin depender de
## leer el archivo). Nota: `log_buffer` de M103 es una variable MUERTA (nunca se
## escribe; sólo la recorre `_flush()` vacía) — eso es real, pero NO impide
## registrar: `_log()` emite y escribe a disco. Ver `07-Resultados-Testings.md` §8.
var _capturadas: Array[String] = []


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


# ── Migraciones de prueba (inyectadas; no tocan MIGRACIONES de producción) ──

func _mig_1a2(d: Dictionary) -> Dictionary:
	var r := d.duplicate(true)
	r["paso2"] = true
	r["version"] = 2
	return r


func _mig_2a3(d: Dictionary) -> Dictionary:
	var r := d.duplicate(true)
	r["paso3"] = true
	r["version"] = 3
	return r


func _mig_3a4(d: Dictionary) -> Dictionary:
	var r := d.duplicate(true)
	r["paso4"] = true
	r["version"] = 4
	return r


## Migración que NO sube la versión (defecto a detectar).
func _mig_estancada(d: Dictionary) -> Dictionary:
	return d.duplicate(true)


## Migración que devuelve un dict sin campo version (defecto a detectar).
func _mig_sin_version(d: Dictionary) -> Dictionary:
	var r := d.duplicate(true)
	r["algo"] = 1
	r.erase("version")
	return r


## Patrón "campo renombrado" (v1 -> v2).
func _mig_renombra(d: Dictionary) -> Dictionary:
	var r := Versionador.renombrar_campo(d, "energia", "energia_j")
	r["version"] = 2
	return r


## Patrón "campo eliminado" (v2 -> v3).
func _mig_elimina(d: Dictionary) -> Dictionary:
	var r := Versionador.eliminar_campo(d, "obsoleto")
	r["version"] = 3
	return r


## Patrón "transformación de valores" (v3 -> v4): kcal -> julios.
func _mig_transforma(d: Dictionary) -> Dictionary:
	var r := Versionador.transformar_valor(d, "energia_j", _kcal_a_julios)
	r["version"] = 4
	return r


func _kcal_a_julios(v: Variant) -> Variant:
	return float(v) * 4184.0


# ── Fixtures ────────────────────────────────────────────────────────────────

## Payload que SÍ cumple el contrato v1 (jugador/inventario/tiempo/voxel/meta).
func _payload_v1() -> Dictionary:
	return {
		"jugador": {"pos": [0.0, 1.5, 0.0], "rot": [0.0, 0.0, 0.0], "vida": 100.0, "energia": 80.0},
		"inventario": {"slots": [{"id": "wood", "n": 3}]},
		"tiempo": {"dia": 1, "hora": 8.0, "estacion": "primavera"},
		"mundo_voxel": {"semilla": 12345, "chunks_editados": 0, "chunks": []},
		"meta": {"nombre": "Aurora"},
	}


## Payload CON voxel (2 chunks) para probar el binario y su backup.
func _payload_con_voxel() -> Dictionary:
	var d := _payload_v1()
	var v1 := PackedInt32Array()
	for i in range(4):
		v1.append(i)
	d["mundo_voxel"] = {
		"semilla": 12345,
		"chunks_editados": 2,
		"chunks": [
			{"coord": Vector3i(0, 0, 0), "voxeles": v1},
			{"coord": Vector3i(-1, 0, 2), "voxeles": v1},
		],
	}
	return d


func _limpiar_saves() -> void:
	for i in range(1, GestorSlot.SLOT_COUNT + 1):
		GestorSlot.borrar_slot(i)
		var r := GestorSlot.rutas_slot(i)
		for extra in [".deflate", ".bak", ".bak.1", ".bak.2", ".bak.3", ".tmp"]:
			for base in [String(r["save"]), String(r["voxel"])]:
				var p: String = base + extra
				if FileAccess.file_exists(p):
					DirAccess.remove_absolute(p)


func _log_contiene(fragmento: String) -> bool:
	return "\n".join(PackedStringArray(_capturadas)).contains(fragmento)


func _on_line(_nivel: int, _categoria: int, line: String) -> void:
	_capturadas.append(line)


# ── Arranque ────────────────────────────────────────────────────────────────

func _run() -> void:
	print("=== [%s] huecos de verificación: migración inyectable, atomicidad, slots, log M103 ===" % MODULO)
	_ds = root.get_node_or_null("DataStore")
	_gl = root.get_node_or_null("GameLogger")
	if _gl != null:
		_gl.line_emitted.connect(_on_line)
		# El logger se usa TAL CUAL, sin forzar categorías.
		# Verificado con sonda aislada el 2026-09-15: `_load_config()` puebla
		# `categories_enabled` en `_ready()` (desde `logging_config.tres`, o TODAS
		# como fallback) y `_log()` escribe a disco línea a línea. El bloque F pasa
		# igual con o sin el forzado -> el forzado que hubo aquí era un no-op
		# basado en un diagnóstico erróneo (ver BUG-041, reclasificado a falso
		# positivo, y `07-Resultados-Testings.md` §8).

	# Preservar la config real del usuario (los tests la pisan a propósito).
	var ruta_cfg := GestorConfig.RUTA_CONFIG
	_config_existia = FileAccess.file_exists(ruta_cfg)
	if _config_existia:
		_config_original = FileAccess.get_file_as_bytes(ruta_cfg)

	_limpiar_saves()
	_bloque_a()
	_bloque_b()
	_bloque_c()
	_bloque_d()
	_bloque_e()
	_bloque_f()
	_bloque_g()
	_bloque_h()

	# Restaurar la config del usuario.
	if _config_existia:
		var f := FileAccess.open(ruta_cfg, FileAccess.WRITE)
		if f != null:
			f.store_buffer(_config_original)
			f.close()
	elif FileAccess.file_exists(ruta_cfg):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta_cfg))
	_limpiar_saves()

	_summary()


# ── A. Motor de migración inyectable ────────────────────────────────────────

func _bloque_a() -> void:
	_ini("A. migrar_con_cadena (motor inyectable)")

	var cadena: Array = [_mig_1a2, _mig_2a3, _mig_3a4]

	# 1 salto
	var r1: Dictionary = Versionador.migrar_con_cadena({"version": 1, "a": 1}, [_mig_1a2], 2)
	_check("1 salto: ok", bool(r1.get("ok", false)), str(r1))
	_check("1 salto: versión destino alcanzada", int((r1.get("datos", {}) as Dictionary).get("version", 0)) == 2, str(r1))
	_check("1 salto: el paso se aplicó", bool((r1.get("datos", {}) as Dictionary).get("paso2", false)))

	# N = 3 saltos
	var r3: Dictionary = Versionador.migrar_con_cadena({"version": 1, "a": 1}, cadena, 4)
	var d3: Dictionary = r3.get("datos", {})
	_check("3 saltos: ok", bool(r3.get("ok", false)), str(r3))
	_check("3 saltos: versión final = 4", int(d3.get("version", 0)) == 4, str(d3))
	_check("3 saltos: los 3 pasos se aplicaron",
		bool(d3.get("paso2", false)) and bool(d3.get("paso3", false)) and bool(d3.get("paso4", false)), str(d3))
	_check("3 saltos: el dato original sobrevive", int(d3.get("a", 0)) == 1)

	# No muta el original (deep)
	var origen := {"version": 1, "a": 1, "anidado": {"x": 1}}
	var antes := str(origen)
	Versionador.migrar_con_cadena(origen, cadena, 4)
	_check("no muta el original", str(origen) == antes, str(origen))
	_check("no muta el anidado", int((origen["anidado"] as Dictionary)["x"]) == 1)

	# Cadena incompleta
	var rinc: Dictionary = Versionador.migrar_con_cadena({"version": 2}, [_mig_1a2], 4)
	_check("cadena incompleta: ok=false", not bool(rinc.get("ok", true)), str(rinc))
	_check("cadena incompleta: el error nombra el salto que falta",
		String(rinc.get("error", "")).contains("v2 -> v3"), String(rinc.get("error", "")))

	# Migración que no avanza versión
	var rest: Dictionary = Versionador.migrar_con_cadena({"version": 1}, [_mig_estancada], 2)
	_check("migración estancada: ok=false", not bool(rest.get("ok", true)), str(rest))
	_check("migración estancada: el error nombra ambas versiones",
		String(rest.get("error", "")).contains("(1 -> 1)"), String(rest.get("error", "")))

	# Migración que devuelve dict sin version
	var rsv: Dictionary = Versionador.migrar_con_cadena({"version": 1}, [_mig_sin_version], 2)
	_check("migración sin version: ok=false", not bool(rsv.get("ok", true)), str(rsv))

	# v0 (save sin versión) -> se le asigna 1
	var rv0: Dictionary = Versionador.migrar_con_cadena({"a": 1}, [], 1)
	_check("v0 sin version: ok", bool(rv0.get("ok", false)), str(rv0))
	_check("v0 sin version: se le asigna 1", int((rv0.get("datos", {}) as Dictionary).get("version", 0)) == 1, str(rv0))

	# versión >= objetivo -> copia sin cambios (y NO es alias)
	var base := {"version": 5, "z": [1, 2]}
	var rge: Dictionary = Versionador.migrar_con_cadena(base, cadena, 4)
	_check("versión >= objetivo: ok", bool(rge.get("ok", false)), str(rge))
	var copia: Dictionary = rge.get("datos", {})
	copia["z"] = "MUTADO"
	_check("versión >= objetivo: devuelve copia, no alias", str(base["z"]) == "[1, 2]", str(base["z"]))

	# Idempotencia
	var una: Dictionary = Versionador.migrar_con_cadena({"version": 1, "a": 1}, cadena, 4)
	var dos: Dictionary = Versionador.migrar_con_cadena(una["datos"], cadena, 4)
	_check("idempotente: aplicar dos veces no cambia el resultado",
		Serializer.a_json_canonico(una["datos"]) == Serializer.a_json_canonico(dos["datos"]),
		Serializer.a_json_canonico(dos["datos"]))

	# Post-migración: el resultado valida contra el contrato de la versión destino
	var v0_completo := _payload_v1()
	var rmig: Dictionary = Versionador.migrar_con_cadena(v0_completo, [], 1)
	var errores_post: Array[String] = Validador.validar_contrato(rmig["datos"], 1)
	_check("post-migración: valida contra el contrato destino", errores_post.is_empty(), str(errores_post))
	_check("post-migración: el original sigue sin version", not v0_completo.has("version"))

	# `migrar()` de producción delega en el mismo motor
	var rprod: Dictionary = Versionador.migrar(_payload_v1())
	_check("migrar(): v1 con VERSION_ACTUAL=1 pasa sin cambios", bool(rprod.get("ok", false)), str(rprod))
	_check("migrar(): conserva la versión 1", int((rprod.get("datos", {}) as Dictionary).get("version", 0)) == 1)
	_check("migrar(): un save sin version sube a 1",
		int((Versionador.migrar({"x": 1}).get("datos", {}) as Dictionary).get("version", 0)) == 1)
	var futura := {"version": Versionador.VERSION_ACTUAL + 1}
	var rfut: Dictionary = Versionador.migrar(futura)
	_check("migrar(): una versión futura no se toca (ok, intacta)",
		bool(rfut.get("ok", false)) and int((rfut.get("datos", {}) as Dictionary).get("version", 0)) == Versionador.VERSION_ACTUAL + 1,
		str(rfut))
	_check("version_futura: detecta la v siguiente", Versionador.version_futura({"version": Versionador.VERSION_ACTUAL + 1}))
	_check("version_futura: no marca la actual", not Versionador.version_futura({"version": Versionador.VERSION_ACTUAL}))

	_fin("A. migrar_con_cadena (motor inyectable)")


# ── B. Patrones de migración ────────────────────────────────────────────────

func _bloque_b() -> void:
	_ini("B. patrones renombrar / eliminar / transformar")

	var src := {"version": 1, "energia": 100, "obsoleto": "x", "otro": 7}
	var antes := Serializer.a_json_canonico(src)

	var ren: Dictionary = Versionador.renombrar_campo(src, "energia", "energia_j")
	_check("renombrar: mueve el valor", int(ren.get("energia_j", 0)) == 100, str(ren))
	_check("renombrar: borra el nombre viejo", not ren.has("energia"), str(ren))
	_check("renombrar: no muta la entrada", Serializer.a_json_canonico(src) == antes)
	var ren_def: Dictionary = Versionador.renombrar_campo({"version": 1}, "energia", "energia_j", 50)
	_check("renombrar: aplica el default si falta el viejo", int(ren_def.get("energia_j", 0)) == 50, str(ren_def))
	var ren_ok: Dictionary = Versionador.renombrar_campo({"energia_j": 9}, "energia", "energia_j", 50)
	_check("renombrar: respeta el nombre nuevo si ya existe", int(ren_ok.get("energia_j", 0)) == 9, str(ren_ok))

	var del: Dictionary = Versionador.eliminar_campo(src, "obsoleto")
	_check("eliminar: quita el campo", not del.has("obsoleto"), str(del))
	_check("eliminar: deja el resto intacto", int(del.get("energia", 0)) == 100 and int(del.get("otro", 0)) == 7, str(del))
	_check("eliminar: no muta la entrada", Serializer.a_json_canonico(src) == antes)
	_check("eliminar: un campo inexistente no rompe", Versionador.eliminar_campo(src, "no_existe").size() == src.size())

	var trf: Dictionary = Versionador.transformar_valor({"energia_j": 100}, "energia_j", _kcal_a_julios)
	_check("transformar: aplica la función", float(trf.get("energia_j", 0.0)) == 418400.0, str(trf))
	var trf_nulo: Dictionary = Versionador.transformar_valor({"version": 1}, "energia_j", _kcal_a_julios)
	_check("transformar: no inventa el campo si no existe", not trf_nulo.has("energia_j"), str(trf_nulo))
	_check("transformar: no muta la entrada", int(src.get("energia", 0)) == 100)

	# Los tres patrones combinados en una cadena real de 3 saltos
	var combinada: Dictionary = Versionador.migrar_con_cadena(src, [_mig_renombra, _mig_elimina, _mig_transforma], 4)
	var dc: Dictionary = combinada.get("datos", {})
	_check("combinada: ok", bool(combinada.get("ok", false)), str(combinada))
	_check("combinada: termina en la versión objetivo", int(dc.get("version", 0)) == 4, str(dc))
	_check("combinada: el campo renombrado sobrevive con el valor transformado",
		float(dc.get("energia_j", 0.0)) == 418400.0, str(dc))
	_check("combinada: el campo obsoleto se eliminó", not dc.has("obsoleto"), str(dc))
	_check("combinada: el campo ajeno se conserva", int(dc.get("otro", 0)) == 7, str(dc))
	_check("combinada: no muta el original", Serializer.a_json_canonico(src) == antes, Serializer.a_json_canonico(src))

	_fin("B. patrones renombrar / eliminar / transformar")


# ── C. Atomicidad, backups y tamaños ────────────────────────────────────────

func _bloque_c() -> void:
	_ini("C. atomicidad, rotación de backups y tamaños RN")

	if _ds == null:
		_check("DataStore disponible", false)
		_fin("C. atomicidad, rotación de backups y tamaños RN")
		return

	# 1.er guardado: sin .bak
	_ds.guardar_partida(1, _payload_v1())
	var r1 := GestorSlot.rutas_slot(1)
	_check("1.er guardado: existe save.json", FileAccess.file_exists(r1["save"]))
	_check("1.er guardado: todavía no hay .bak", not FileAccess.file_exists(String(r1["save"]) + ".bak"))

	# 2.º guardado: crea .bak
	_ds.guardar_partida(1, _payload_v1())
	_check("2.º guardado: crea .bak", FileAccess.file_exists(String(r1["save"]) + ".bak"))
	_check("2.º guardado: el .bak es parseable",
		bool(WriterAtomico.parsear_documento(FileAccess.get_file_as_string(String(r1["save"]) + ".bak")).get("ok", false)))

	# 3.er guardado: crea .bak.1 (la ventana arranca a llenarse)
	_ds.guardar_partida(1, _payload_v1())
	_check("3.er guardado: crea .bak.1", FileAccess.file_exists(String(r1["save"]) + ".bak.1"))
	# 4.º guardado: la ventana queda llena (3 copias)
	_ds.guardar_partida(1, _payload_v1())
	_check("4.º guardado: crea .bak.2", FileAccess.file_exists(String(r1["save"]) + ".bak.2"))
	_check("la ventana de copias llega a 3", GestorBackups.contar(String(r1["save"])) == 3,
		str(GestorBackups.contar(String(r1["save"]))))
	# 5.º guardado: la ventana NO crece (política MAX_BACKUPS = 3)
	_ds.guardar_partida(1, _payload_v1())
	_check("5.º guardado: la ventana no crece más allá de 3", GestorBackups.contar(String(r1["save"])) == 3,
		str(GestorBackups.contar(String(r1["save"]))))
	_check("5.º guardado: no aparece .bak.3", not FileAccess.file_exists(String(r1["save"]) + ".bak.3"))

	# .tmp residual: no afecta la carga ni el contenido
	var tmp := String(r1["save"]) + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	f.store_string("basura que quedó de una escritura interrumpida")
	f.close()
	var cargado: Dictionary = _ds.cargar_partida(1)
	_check("un .tmp residual no impide cargar", bool(cargado.get("ok", false)), str(cargado.get("error", "")))
	_check("un .tmp residual no es el archivo leído",
		int((cargado.get("datos", {}) as Dictionary).get("jugador", {}).get("vida", 0)) == 100,
		str(cargado.get("datos", {}).get("jugador", {})))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(tmp))

	# Tamaños RN1/RN2
	var bytes_save := FileAccess.get_file_as_bytes(r1["save"]).size()
	var bytes_meta := FileAccess.get_file_as_bytes(r1["meta"]).size()
	_check("RN2: save.json < 1 MB", bytes_save < 1048576, "%d bytes" % bytes_save)
	_check("RN2: meta.json < 10 KB", bytes_meta < 10240, "%d bytes" % bytes_meta)
	_check("meta.json es más chica que el save", bytes_meta < bytes_save, "%d vs %d" % [bytes_meta, bytes_save])

	# Config: backup + escritura atómica + tamaño
	var cfg := GestorConfig.cargar_config()
	GestorConfig.guardar_config(cfg)
	_check("config: 1.er guardado OK", FileAccess.file_exists(GestorConfig.RUTA_CONFIG))
	GestorConfig.guardar_config(cfg)
	_check("config: 2.º guardado crea .bak", FileAccess.file_exists(GestorConfig.RUTA_CONFIG + ".bak"))
	var bytes_cfg := FileAccess.get_file_as_bytes(GestorConfig.RUTA_CONFIG).size()
	_check("RN2: config.cfg < 50 KB", bytes_cfg < 51200, "%d bytes" % bytes_cfg)
	_check("config: se relee con los mismos valores",
		absf(float(GestorConfig.cargar_config()["audio"]["volumen_maestro"]) - 0.8) < 0.0001)

	# Escritura imposible -> Error devuelto, sin crash (edge case 157: el disco
	# lleno no es reproducible headless, pero SÍ el camino de error del writer:
	# si no puede abrir/escribir el .tmp debe devolver Error, nunca lanzar).
	var ruta_imposible := GestorSlot.dir_slot(1) + "/sub_dir_inexistente/x.json"
	var err_imposible := WriterAtomico.escribir_atomicamente(ruta_imposible, "checksum\npayload")
	_check("escritura imposible: devuelve Error (no crashea)", err_imposible != OK, str(err_imposible))
	_check("escritura imposible: no deja un .tmp colgado",
		not FileAccess.file_exists(ruta_imposible + ".tmp"))
	# Edge case 158 (quit durante el guardado): el writer solo hace rename al
	# FINAL, así que una escritura cortada deja el save vigente intacto.
	var r1b := GestorSlot.rutas_slot(1)
	var ftmp := FileAccess.open(String(r1b["save"]) + ".tmp", FileAccess.WRITE)
	ftmp.store_string("escritura interrumpida a la mitad del payload")
	ftmp.close()
	var tras_corte: Dictionary = _ds.cargar_partida(1)
	_check("escritura interrumpida: el save vigente sigue cargando (atómico)",
		bool(tras_corte.get("ok", false)), str(tras_corte.get("error", "")))
	_check("escritura interrumpida: el contenido del save no se alteró",
		int((tras_corte.get("datos", {}) as Dictionary).get("jugador", {}).get("vida", 0)) == 100)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(String(r1b["save"]) + ".tmp"))

	# Config corrupta -> defaults sin crash
	var f2 := FileAccess.open(GestorConfig.RUTA_CONFIG, FileAccess.WRITE)
	f2.store_string("esto no es un documento con checksum")
	f2.close()
	var cfg_corrupta := GestorConfig.cargar_config()
	_check("config corrupta: no crashea y devuelve defaults",
		absf(float(cfg_corrupta["audio"]["volumen_maestro"]) - 0.8) < 0.0001, str(cfg_corrupta["audio"]))
	_check("config corrupta: las 4 secciones siguen ahí", cfg_corrupta.size() == GestorConfig.SECCIONES.size(),
		str(cfg_corrupta.keys()))
	# checksum roto (formato correcto, hash inválido)
	var f3 := FileAccess.open(GestorConfig.RUTA_CONFIG, FileAccess.WRITE)
	f3.store_string("deadbeef\n[audio]\nvolumen_maestro=0.1\n")
	f3.close()
	_check("config con checksum roto: vuelve a defaults",
		absf(float(GestorConfig.cargar_config()["audio"]["volumen_maestro"]) - 0.8) < 0.0001)

	_fin("C. atomicidad, rotación de backups y tamaños RN")


# ── D. Slots y meta ─────────────────────────────────────────────────────────

func _bloque_d() -> void:
	_ini("D. slots: meta regenerada, slot vacío, borrado")

	if _ds == null:
		_check("DataStore disponible", false)
		_fin("D. slots: meta regenerada, slot vacío, borrado")
		return

	# Slot vacío
	var r_vacio: Dictionary = _ds.cargar_partida(2)
	_check("slot vacío: ok=false", not bool(r_vacio.get("ok", false)), str(r_vacio))
	_check("slot vacío: error claro sin excepción",
		String(r_vacio.get("error", "")).contains("no existe"), String(r_vacio.get("error", "")))
	var r_rango: Dictionary = _ds.cargar_partida(9)
	_check("slot fuera de rango: ok=false", not bool(r_rango.get("ok", false)), str(r_rango))
	_check("borrar slot inexistente -> false", _ds.borrar_slot(2) == false)

	# Slot 3: guardar, borrar meta.json a mano, recargar
	_ds.guardar_partida(3, _payload_v1())
	var r3 := GestorSlot.rutas_slot(3)
	_check("slot 3: meta.json existe tras guardar", FileAccess.file_exists(r3["meta"]))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(String(r3["meta"])))
	_check("slot 3: meta.json eliminada", not FileAccess.file_exists(r3["meta"]))
	_check("slot 3: con la meta borrada, listar_slots ya no lo ve",
		_slots_contiene(3) == false)

	var re: Dictionary = _ds.cargar_partida(3)
	_check("slot 3: la carga sigue funcionando sin meta", bool(re.get("ok", false)), str(re.get("error", "")))
	_check("slot 3: la carga REGENERA meta.json", FileAccess.file_exists(r3["meta"]))
	_check("slot 3: la meta regenerada queda marcada",
		bool(GestorSlot.leer_meta(3).get("regenerada", false)), str(GestorSlot.leer_meta(3)))
	_check("slot 3: tras regenerar, listar_slots lo vuelve a ver", _slots_contiene(3))

	# La meta regenerada NO pisa una meta existente
	var meta_previa := GestorSlot.leer_meta(3)
	_ds.cargar_partida(3)
	_check("la meta existente no se pisa", GestorSlot.leer_meta(3) == meta_previa)

	# listar_slots devuelve sólo meta (sin deserializar el save)
	var lista: Array = _ds.listar_slots()
	var solo_meta := true
	for entrada in lista:
		var e: Dictionary = entrada
		if not e.has("meta") or e.has("datos"):
			solo_meta = false
	_check("listar_slots devuelve sólo la meta (no deserializa el save)", solo_meta, str(lista))

	# borrar_slot limpia TODO (incluido .deflate y las copias)
	var ruta_deflate := String(r3["voxel"]) + ".deflate"
	var fd := FileAccess.open(ruta_deflate, FileAccess.WRITE)
	fd.store_buffer(PackedByteArray([1, 2, 3]))
	fd.close()
	_check("borrar_slot: el .deflate existe antes de borrar", FileAccess.file_exists(ruta_deflate))
	var ok_borrado: bool = _ds.borrar_slot(3)
	_check("borrar_slot -> true", ok_borrado)
	_check("borrar_slot: el .deflate se borró", not FileAccess.file_exists(ruta_deflate))
	_check("borrar_slot: el directorio del slot se eliminó",
		not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(GestorSlot.dir_slot(3))))
	_check("tras borrar, existe_slot es false", not GestorSlot.existe_slot(3))

	_fin("D. slots: meta regenerada, slot vacío, borrado")


func _slots_contiene(slot: int) -> bool:
	for entrada in _ds.listar_slots():
		if int((entrada as Dictionary).get("slot", -1)) == slot:
			return true
	return false


# ── E. Catálogo estático ────────────────────────────────────────────────────

func _bloque_e() -> void:
	_ini("E. catálogo estático: validar_ids y carga perezosa")

	CatalogosEstaticos._reset_para_test()
	_check("catálogo: contar_items() > 100 (los .tres reales de M159)", CatalogosEstaticos.contar_items() > 100,
		str(CatalogosEstaticos.contar_items()))
	_check("catálogo: 0 Resources cargados tras indexar", CatalogosEstaticos.contar_cargados() == 0,
		str(CatalogosEstaticos.contar_cargados()))

	# tiene_item NO carga
	_check("catálogo: tiene_item('wood')", CatalogosEstaticos.tiene_item("wood"))
	_check("catálogo: tiene_item no cargó ningún Resource", CatalogosEstaticos.contar_cargados() == 0,
		str(CatalogosEstaticos.contar_cargados()))

	# obtener_item SÍ carga (y cachea)
	var item: Resource = CatalogosEstaticos.obtener_item("wood")
	_check("catálogo: obtener_item('wood') devuelve un Resource", item != null)
	_check("catálogo: cargó exactamente 1", CatalogosEstaticos.contar_cargados() == 1,
		str(CatalogosEstaticos.contar_cargados()))
	_check("catálogo: la 2.ª llamada usa la caché (no carga de nuevo)",
		CatalogosEstaticos.obtener_item("wood") == item and CatalogosEstaticos.contar_cargados() == 1)
	_check("catálogo: obtener_item de un id inexistente -> null",
		CatalogosEstaticos.obtener_item("no_existe_xyz") == null)

	# validar_ids
	var ids_reales: Array = ["wood", "dirt", "clay", "copper_ore"]
	_check("validar_ids: ids reales -> sin faltantes", CatalogosEstaticos.validar_ids(ids_reales).is_empty(),
		str(CatalogosEstaticos.validar_ids(ids_reales)))
	var mixtos: Array = ["wood", "fantasma_a", "clay", "fantasma_b"]
	var faltantes: Array[String] = CatalogosEstaticos.validar_ids(mixtos)
	_check("validar_ids: nombra los ids que faltan", faltantes.size() == 2, str(faltantes))
	_check("validar_ids: preserva el orden de los faltantes",
		faltantes[0] == "fantasma_a" and faltantes[1] == "fantasma_b", str(faltantes))
	_check("validar_ids: ignora los ids vacíos", CatalogosEstaticos.validar_ids(["", "wood", ""]).is_empty())
	_check("validar_ids: lista vacía -> sin faltantes", CatalogosEstaticos.validar_ids([]).is_empty())
	_check("validar_ids: no carga Resources", CatalogosEstaticos.contar_cargados() == 1,
		str(CatalogosEstaticos.contar_cargados()))
	_check("validar_ids: no confunde un id real cargado con faltante",
		CatalogosEstaticos.validar_ids(["wood"]).is_empty())

	_fin("E. catálogo estático: validar_ids y carga perezosa")


# ── F. Log M103 (GameLogger real) ───────────────────────────────────────────

func _bloque_f() -> void:
	_ini("F. log M103 (GameLogger real)")

	_check("GameLogger presente como autoload", _gl != null)
	if _gl == null:
		_fin("F. log M103 (GameLogger real)")
		return

	# guardar_partida registra
	_capturadas.clear()
	_ds.guardar_partida(1, _payload_v1())
	_check("guardar_partida registra un [M60] info", _log_contiene("[M60]"))
	_check("el registro del guardado nombra el slot", _log_contiene("slot 1"))

	# cargar_partida registra
	_capturadas.clear()
	_ds.cargar_partida(1)
	_check("cargar_partida registra un [M60] info", _log_contiene("[M60]"))
	_check("el registro de la carga nombra la versión", _log_contiene("versión"))

	# rechazo por versión futura -> error
	_capturadas.clear()
	# Ojo: `guardar_partida` fuerza version = VERSION_ACTUAL, así que un save
	# "del futuro" hay que escribirlo a mano para poder probar el rechazo.
	var r2 := GestorSlot.rutas_slot(2)
	GestorSlot.asegurar_directorio(2)
	var futuro := _payload_v1()
	futuro["version"] = Versionador.VERSION_ACTUAL + 5
	var contenido_futuro := WriterAtomico.construir_con_checksum(Serializer.a_json(Serializer.a_plano(futuro)))
	WriterAtomico.escribir_atomicamente(r2["save"], contenido_futuro)
	GestorSlot.escribir_meta(2, GestorSlot.meta_default(2))
	var rechazo: Dictionary = _ds.cargar_partida(2)
	_check("versión futura: la carga se rechaza", not bool(rechazo.get("ok", false)), str(rechazo))
	_check("versión futura: se registra el rechazo en el log",
		_log_contiene("rechazo") and _log_contiene("[M60]"), "\n".join(PackedStringArray(_capturadas)))

	# contrato inválido -> error con el detalle
	_capturadas.clear()
	var malo := _payload_v1()
	malo.erase("tiempo")
	_ds.guardar_partida(2, malo)
	var invalido: Dictionary = _ds.cargar_partida(2)
	_check("contrato inválido: la carga se rechaza", not bool(invalido.get("ok", false)), str(invalido))
	_check("contrato inválido: el log nombra el bloque que falta",
		_log_contiene("contrato inválido") and _log_contiene("tiempo"), "\n".join(PackedStringArray(_capturadas)))

	# detección temprana AL GUARDAR (ítem 66) — y es NO bloqueante
	_capturadas.clear()
	var res_malo: Dictionary = _ds.guardar_partida(2, malo)
	_check("detección temprana: avisa en el log al guardar un payload incompleto",
		_log_contiene("detección temprana"), "\n".join(PackedStringArray(_capturadas)))
	_check("detección temprana: NO bloquea el guardado (diagnóstico)", bool(res_malo.get("ok", false)),
		str(res_malo))

	_capturadas.clear()
	var res_bueno: Dictionary = _ds.guardar_partida(2, _payload_v1())
	_check("detección temprana: un payload válido NO genera aviso",
		not _log_contiene("detección temprana"), "\n".join(PackedStringArray(_capturadas)))
	_check("detección temprana: el guardado válido es ok", bool(res_bueno.get("ok", false)))

	# El helper del registro de migración (ítem 56) llega al log
	_capturadas.clear()
	_ds._log_m60("info", "save del slot 1 migrado v1 -> v2")
	_check("el registro de migración (origen -> destino) llega al log",
		_log_contiene("migrado v1 -> v2"), "\n".join(PackedStringArray(_capturadas)))
	_check("el salto de versión es alcanzable con una cadena registrada",
		int((Versionador.migrar_con_cadena({"version": 1}, [_mig_1a2], 2).get("datos", {}) as Dictionary).get("version", 0)) == 2)

	_capturadas.clear()

	_fin("F. log M103 (GameLogger real)")


# ── G. Integración ──────────────────────────────────────────────────────────

func _bloque_g() -> void:
	_ini("G. integración: ServiceRegistry, SaveManager, orden del voxel")

	var sr := root.get_node_or_null("ServiceRegistry")
	_check("ServiceRegistry (M07) presente", sr != null)
	if sr != null:
		_check("DataStore registrado como servicio 'datos'", sr.has("datos"))
		_check("ServiceRegistry.get_service('datos') es el DataStore", sr.get_service("datos") == _ds)

	var sm := root.get_node_or_null("SaveManager")
	_check("SaveManager (M59) presente", sm != null)
	if sm != null:
		var payload: Dictionary = sm.snapshot.collect("test_m60_iter4")
		_check("collect() incluye 'player'", payload.has("player"))
		_check("collect() incluye 'npc' (M19)", payload.has("npc"))
		_check("collect() incluye 'buildings' (M60)", payload.has("buildings"))
		_check("collect() reúne más de 30 secciones (44 providers registrados)", payload.size() > 30,
			"%d secciones" % payload.size())
		_check("la sección 'buildings' tiene la forma del schema",
			typeof(payload.get("buildings", null)) == TYPE_DICTIONARY and (payload["buildings"] as Dictionary).has("structures"),
			str(payload.get("buildings", null)))

	_check("el provider de buildings de M60 está registrado", _ds._provider_buildings != null)

	# Orden de carga del voxel: se adjunta DESPUÉS de validar el save
	_ds.guardar_partida(1, _payload_con_voxel())
	var r1 := GestorSlot.rutas_slot(1)
	_check("un guardado con voxel escribe mundo_voxel.bin", FileAccess.file_exists(r1["voxel"]))
	var bin: PackedByteArray = _ds.cargar_mundo_voxel(1)
	_check("cargar_mundo_voxel devuelve PackedByteArray", typeof(bin) == TYPE_PACKED_BYTE_ARRAY)
	_check("el payload del voxel no está vacío", bin.size() > 0, "%d bytes" % bin.size())
	var decod: Dictionary = Serializer.desde_binario_voxel(bin)
	_check("el payload decodifica IAVX1", not decod.is_empty(), str(decod.size()))
	_check("el binario trae los 2 chunks", int(decod.get("count", 0)) == 2, str(decod.get("count", -1)))
	var ok_voxel: Dictionary = _ds.cargar_partida(1)
	_check("la carga adjunta _voxel_payload", (ok_voxel.get("datos", {}) as Dictionary).has("_voxel_payload"))
	_check("_voxel_payload llega con bytes",
		((ok_voxel.get("datos", {}) as Dictionary)["_voxel_payload"] as PackedByteArray).size() > 0)

	# La semilla del mundo viaja y vuelve: es lo que M08/M10 usan para regenerar
	# el resto del terreno por procedimiento (RF4).
	var con_semilla := _payload_v1()
	(con_semilla["mundo_voxel"] as Dictionary)["semilla"] = 987654
	_ds.guardar_partida(3, con_semilla)
	var vuelto: Dictionary = _ds.cargar_partida(3)
	var mv: Dictionary = (vuelto.get("datos", {}) as Dictionary).get("mundo_voxel", {})
	_check("la semilla del mundo vuelve del save (M08/M10)", int(mv.get("semilla", 0)) == 987654, str(mv))
	_check("chunks_editados vuelve del save", int(mv.get("chunks_editados", -1)) == 0, str(mv))

	# Si el save está corrupto, el voxel NO se adjunta (se carga después del save)
	_ds.guardar_partida(2, _payload_v1())
	var r2 := GestorSlot.rutas_slot(2)
	var fbin := FileAccess.open(r2["voxel"], FileAccess.WRITE)
	fbin.store_buffer(bin)
	fbin.close()
	var fsave := FileAccess.open(r2["save"], FileAccess.WRITE)
	fsave.store_string("corrupto")
	fsave.close()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(String(r2["save"]) + ".bak"))
	var corrupto: Dictionary = _ds.cargar_partida(2)
	_check("save corrupto sin backup: la carga falla", not bool(corrupto.get("ok", false)), str(corrupto))
	_check("save corrupto: NO se adjunta el voxel (el orden es correcto)",
		not (corrupto.get("datos", {}) as Dictionary).has("_voxel_payload"))

	_fin("G. integración: ServiceRegistry, SaveManager, orden del voxel")


# ── H. Formato y determinismo ───────────────────────────────────────────────

func _bloque_h() -> void:
	_ini("H. formato, determinismo y una sola serialización")

	# pretty de 2 espacios
	var texto := Serializer.a_json({"a": 1, "b": {"c": 2}})
	_check("a_json usa pretty de 2 espacios", texto.contains("\n  \"a\""), texto)
	# canónico determinista (independiente del orden de inserción)
	var d1 := {"z": 1, "a": 2, "m": 3}
	var d2 := {"a": 2, "m": 3, "z": 1}
	_check("a_json_canonico es determinista", Serializer.a_json_canonico(d1) == Serializer.a_json_canonico(d2),
		Serializer.a_json_canonico(d1))
	_check("a_json_canonico ordena las claves", Serializer.a_json_canonico(d1).find("\"a\"") < Serializer.a_json_canonico(d1).find("\"z\""))

	# Una sola serialización: el checksum del archivo es el del payload_str devuelto
	# (el slot 3 se borró en el bloque D: hay que recrear su directorio)
	GestorSlot.asegurar_directorio(3)
	var escritura: Dictionary = _ds._escribir_save_con_payload(3, _payload_v1())
	_check("_escribir_save_con_payload devuelve el payload_str", bool(escritura.get("ok", false)) and String(escritura.get("payload_str", "")) != "")
	var r3 := GestorSlot.rutas_slot(3)
	var contenido := FileAccess.get_file_as_string(r3["save"])
	var salto := contenido.find("\n")
	_check("el archivo tiene el formato checksum\\npayload", salto > 0)
	var checksum_archivo := contenido.substr(0, salto)
	var payload_archivo := contenido.substr(salto + 1)
	_check("una sola serialización: el checksum del archivo es el del payload_str",
		checksum_archivo == Validador.crc32_hex(String(escritura["payload_str"])),
		"%s vs %s" % [checksum_archivo, Validador.crc32_hex(String(escritura["payload_str"]))])
	_check("el payload del archivo es exactamente el payload_str",
		payload_archivo == String(escritura["payload_str"]))
	_check("el checksum del archivo coincide con el recalculado sobre el payload",
		Validador.crc32_hex(payload_archivo) == checksum_archivo)

	# Sin BOM
	var bytes := FileAccess.get_file_as_bytes(r3["save"])
	_check("el save escrito NO lleva BOM", bytes.size() > 3 and not (bytes[0] == 0xEF and bytes[1] == 0xBB and bytes[2] == 0xBF))
	_check("el save escrito es UTF-8 válido (sin U+FFFD)",
		not bytes.get_string_from_utf8().contains("\uFFFD"))

	# El checksum excluye el campo checksum del cálculo
	var con := {"version": 1, "x": 1}
	var sin := {"version": 1, "x": 1, "checksum": 999}
	_check("calcular_crc32 excluye el campo checksum",
		Validador.calcular_crc32(con) == Validador.calcular_crc32(sin))

	# Carga perezosa sigue viva
	_check("el catálogo sigue con 1 Resource cargado (no se cargó de más)",
		CatalogosEstaticos.contar_cargados() == 1, str(CatalogosEstaticos.contar_cargados()))

	_fin("H. formato, determinismo y una sola serialización")


# ── Resumen ─────────────────────────────────────────────────────────────────

func _summary() -> void:
	var faltantes: Array[String] = []
	for b in BLOQUES_ESPERADOS:
		if not _completados.has(b):
			faltantes.append(b)
	var detalle: String = "" if faltantes.is_empty() else " — bloques que no terminaron: %s" % str(faltantes)
	_check("los %d bloques se completaron (sin abortos silenciosos)%s" % [BLOQUES_ESPERADOS.size(), detalle],
		faltantes.is_empty())
	_terminado = true
	print("-- checks por bloque: %s" % str(_checks_por_bloque))
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos == 0:
		print("TEST %s OK — todos los checks pasaron" % MODULO)
		quit(0)
	else:
		print("TEST %s FALLIDO — salida con código 1" % MODULO)
		quit(1)
