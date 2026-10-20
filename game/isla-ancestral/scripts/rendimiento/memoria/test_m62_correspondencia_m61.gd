# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-19
#
# M62 / M61: ITEM 13 de la COLA V3 (Log 2021).
#   "Leer los presupuestos definitivos de M61 antes de fijar los topes duros del 62"
#
# El Log 2019 midio que los dos archivos existen y que sus unidades son
# distintas (ms vs MB), pero dejo abierto que **no habia artefacto que los
# enlace**: la correspondencia vivia en el reporte, no en el repo. Este gate la
# convierte en verificable: si M61 cambia un limite que el 62 deberia respetar,
# o si un preset del 62 deja de sumar su tope declarado, esto falla.
#
# ⚠️ No compara ms contra MB (seria una comparacion falsa): lo que verifica es
#   (a) que cada archivo sea internamente coherente,
#   (b) que los topes declarados del 62 sigan siendo 1500/2000/2500,
#   (c) que el unico limite de M61 que PODRIA restringir al 62
#       (`remesh_bloque_ms_max`) no este siendo consumido por el 62 en silencio.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_m62_correspondencia_m61.gd

extends SceneTree

const MODULO := "M62 correspondencia M61"
const RUTA_M61 := "res://data/performance/budgets.json"
const RUTA_M62 := "res://data/rendimiento/budgets.json"
const TOPES_DECLARADOS := {"baja": 1500, "media": 2000, "alta": 2500}
## Archivos del 62 que podrian consumir un limite de M61.
const FUENTES_M62: Array[String] = [
	"res://scripts/rendimiento/memoria/memory_monitor.gd",
	"res://scripts/rendimiento/memoria/budget_registry.gd",
	"res://scripts/rendimiento/memoria/unload_policy.gd",
	"res://scripts/rendimiento/memoria/global_pool.gd",
]
const CLAVE_M61 := "remesh_bloque_ms_max"
const CHECKS_MINIMOS := 12   # MEDIDO en verde (12 checks x3), no estimado

var _checks := 0
var _fallos := 0


func _initialize() -> void:
	call_deferred("_correr")


func _check(nombre: String, ok: bool, detalle: String = "") -> void:
	_checks += 1
	if not ok:
		_fallos += 1
		print("  [FALL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])
	else:
		print("  [ok]   %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])


func _leer(ruta: String) -> Dictionary:
	if not FileAccess.file_exists(ruta):
		return {}
	var v: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	if typeof(v) != TYPE_DICTIONARY:
		return {}
	return v as Dictionary


## Busca una clave en un diccionario anidado y devuelve su valor (o null).
func _buscar(d: Dictionary, clave: String) -> Variant:
	if d.has(clave):
		return d[clave]
	for k in d.keys():
		var v: Variant = d[k]
		if typeof(v) == TYPE_DICTIONARY:
			var hit: Variant = _buscar(v as Dictionary, clave)
			if hit != null:
				return hit
	return null


func _correr() -> void:
	await process_frame
	print("=== %s ===" % MODULO)

	var m61 := _leer(RUTA_M61)
	# Override SOLO para probar el gate EN ROJO sobre una copia temporal, sin
	# tocar el archivo real (worktree compartido). El run normal no lo usa.
	var ruta_m62 := RUTA_M62
	if OS.get_environment("M62_BUDGETS_M62") != "":
		ruta_m62 = OS.get_environment("M62_BUDGETS_M62")
	var m62 := _leer(ruta_m62)
	_check("M61 %s existe y parsea" % RUTA_M61, not m61.is_empty())
	_check("M62 %s existe y parsea" % ruta_m62, not m62.is_empty())
	if m61.is_empty() or m62.is_empty():
		_cerrar()
		return

	# ── Coherencia interna de M61 (ms) ──
	_check("M61 v2 (presupuestos definitivos)", int(m61.get("version", 0)) == 2,
		"version=%s" % str(m61.get("version")))
	var total_ms := float(m61.get("presupuesto_total_ms", 0.0))
	var tol := float(m61.get("tolerancia_ci", 0.0))
	var cats: Dictionary = m61.get("categorias", {})
	var suma_ms := 0.0
	for k in cats.keys():
		suma_ms += float(cats[k])
	_check("M61: la suma de categorias NO supera el total declarado",
		suma_ms <= total_ms + tol,
		"suma=%.2f ms / total=%.2f ms" % [suma_ms, total_ms])
	_check("M61: unidades de tiempo (ms), no de memoria",
		total_ms > 0.0 and total_ms < 100.0, "total=%.2f" % total_ms)

	# ── Coherencia interna de M62 (MB) ──
	_check("M62 v2 (presets de memoria)", int(m62.get("version", 0)) == 2,
		"version=%s" % str(m62.get("version")))
	var presets: Dictionary = m62.get("presets", {})
	_check("M62: los 3 presets declarados existen",
		presets.has("baja") and presets.has("media") and presets.has("alta"),
		"presets=%s" % str(presets.keys()))
	var activo := String(m62.get("preset_activo", ""))
	_check("M62: el preset activo existe en la tabla", presets.has(activo), "activo=%s" % activo)

	var sumas: Array[String] = []
	var topes_ok := true
	for nombre in TOPES_DECLARADOS.keys():
		if not presets.has(nombre):
			topes_ok = false
			continue
		var sistemas: Dictionary = presets[nombre]
		var s := 0
		for k in sistemas.keys():
			s += int(sistemas[k])
		sumas.append("%s=%d" % [nombre, s])
		if s != int(TOPES_DECLARADOS[nombre]):
			topes_ok = false
	_check("M62: cada preset suma su tope declarado (1500/2000/2500)",
		topes_ok, str(sumas))
	var suma_alta := 0
	if presets.has("alta"):
		var alta: Dictionary = presets["alta"]
		for k in alta.keys():
			suma_alta += int(alta[k])
	_check("M62: escala de memoria (MB, total > 100) vs M61 (ms, total < 100)",
		suma_alta > 100 and total_ms < 100,
		"M62 alta=%d MB / M61 total=%.1f ms" % [suma_alta, total_ms])

	# ── Correspondencia: el limite de M61 que podria restringir al 62 ──
	var remesh: Variant = _buscar(m61, CLAVE_M61)
	_check("M61 expone %s" % CLAVE_M61, remesh != null,
		"valor=%s" % str(remesh))
	var apariciones := 0
	var archivos_con_la_clave: Array[String] = []
	for ruta in FUENTES_M62:
		if not FileAccess.file_exists(ruta):
			continue
		var texto := FileAccess.get_file_as_string(ruta)
		if texto.contains(CLAVE_M61):
			apariciones += texto.count(CLAVE_M61)
			archivos_con_la_clave.append(ruta.get_file())
	_check("M62 NO consume %s (0 apariciones en sus 4 fuentes)" % CLAVE_M61,
		apariciones == 0, "apariciones=%d en %s" % [apariciones, str(archivos_con_la_clave)])

	# ── Tabla de correspondencia (evidencia legible en el log) ──
	print("-- tabla de correspondencia M61 <-> M62")
	print("   M61 %s: total %.1f ms, %d categorias (suma %.1f ms)" % [
		RUTA_M61, total_ms, cats.size(), suma_ms])
	print("   M61 %s = %s ms (no consumido por el 62)" % [CLAVE_M61, str(remesh)])
	print("   M62 %s: presets %s" % [RUTA_M62, str(sumas)])
	print("   unidades distintas (ms vs MB) -> NO se comparan entre si")
	_cerrar()


func _cerrar() -> void:
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FALLO] solo %d checks (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con codigo 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — correspondencia verificada" % MODULO)
		quit(0)
