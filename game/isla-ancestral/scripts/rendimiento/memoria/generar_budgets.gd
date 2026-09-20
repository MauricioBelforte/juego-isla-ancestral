# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-19
#
# M62: Memoria — Generador VALIDANTE de budgets.json (RF2, diseño §2).
#
# Patrón obligatorio del proyecto (skill isla-ancestral-ciclo-modulo §3):
# construir -> validar CADA preset -> ABORTAR sin guardar si alguno es
# inválido -> guardar -> informar. Nunca editar el dataset a mano.
#
# La tabla del diseño (plan-actual/03-Diseno.md §2) es el CONTRATO: los 8
# sistemas y la suma fija por preset (1500 / 2000 / 2500 MB). El dataset que
# había en disco NO coincidía en ninguno de los 8 sistemas y sus totales daban
# 1624 / 2080 / 2540 — ver Log 1094.
#
# Uso:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/generar_budgets.gd            # escribe
#   ... --script res://scripts/rendimiento/memoria/generar_budgets.gd -- --check # sólo valida
#
# --check es la puerta de CI: sale 0 sólo si el dataset en disco es idéntico al
# diseño (mismos 8 sistemas, mismos topes y mismo total por preset).

extends SceneTree

const RUTA := "res://data/rendimiento/budgets.json"

## Orden canónico de los 8 sistemas (diseño §2). El dataset debe tener
## EXACTAMENTE estas claves: ni una más, ni una menos.
const SISTEMAS: Array[String] = [
	"voxel", "texturas", "audio", "escenas", "pools", "ui", "shaders", "reserva",
]

## Presupuestos por sistema y total declarado, tal cual el diseño §2.
const PRESETS: Dictionary = {
	"baja": {
		"total": 1500,
		"sistemas": {
			"voxel": 500, "texturas": 250, "audio": 150, "escenas": 220,
			"pools": 120, "ui": 70, "shaders": 60, "reserva": 130,
		},
	},
	"media": {
		"total": 2000,
		"sistemas": {
			"voxel": 650, "texturas": 320, "audio": 200, "escenas": 280,
			"pools": 160, "ui": 85, "shaders": 80, "reserva": 225,
		},
	},
	"alta": {
		"total": 2500,
		"sistemas": {
			"voxel": 800, "texturas": 400, "audio": 250, "escenas": 350,
			"pools": 200, "ui": 100, "shaders": 100, "reserva": 300,
		},
	},
}

const PRESET_POR_DEFECTO := "media"

var _errores: Array[String] = []
var _checks: int = 0
var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var solo_check := _arg_check()
	print("=== [M62] Generador validante de budgets.json (%s) ===" % ("--check" if solo_check else "escritura"))

	_validar_tabla_del_diseno()
	if solo_check:
		_validar_dataset_en_disco()
	else:
		_escribir()

	_resumen(solo_check)
	quit(1 if _fallos > 0 else 0)

## ── 1. La tabla del diseño se valida a sí misma ──────────────────────────
## Si alguien edita las constantes y rompe la suma, el generador no escribe.
func _validar_tabla_del_diseno() -> void:
	print("--- A. Coherencia de la tabla del diseño (8 sistemas, suma fija) ---")
	for preset in PRESETS:
		var bloque: Dictionary = PRESETS[preset]
		var sistemas: Dictionary = bloque["sistemas"]
		var total_declarado: int = int(bloque["total"])

		_check(sistemas.size() == SISTEMAS.size(),
			"preset '%s': tiene %d sistemas (esperado %d)" % [preset, sistemas.size(), SISTEMAS.size()])

		var faltantes: Array[String] = []
		for s in SISTEMAS:
			if not sistemas.has(s):
				faltantes.append(s)
		_check(faltantes.is_empty(), "preset '%s': sin sistemas faltantes (faltan %s)" % [preset, str(faltantes)])

		var suma := 0
		var no_positivos: Array[String] = []
		for s in sistemas:
			var v := int(sistemas[s])
			suma += v
			if v <= 0:
				no_positivos.append("%s=%d" % [s, v])
		_check(no_positivos.is_empty(), "preset '%s': todos los topes > 0 (malos: %s)" % [preset, str(no_positivos)])
		_check(suma == total_declarado,
			"preset '%s': la suma (%d) es igual al total declarado (%d)" % [preset, suma, total_declarado])

## ── 2. El dataset en disco debe ser idéntico al diseño ───────────────────
func _validar_dataset_en_disco() -> void:
	print("--- B. El dataset en disco coincide con el diseño ---")
	var datos := _leer_json(RUTA)
	if datos.is_empty():
		_fallos += 1
		print("  [FAIL] no se pudo leer/parsear %s" % RUTA)
		return
	var presets: Dictionary = datos.get("presets", {})
	_check(presets.size() == PRESETS.size(),
		"el dataset tiene %d presets (esperado %d)" % [presets.size(), PRESETS.size()])
	for preset in PRESETS:
		if not presets.has(preset):
			_fallos += 1
			print("  [FAIL] falta el preset '%s' en el dataset" % preset)
			continue
		var en_disco: Dictionary = presets[preset]
		var del_diseno: Dictionary = PRESETS[preset]["sistemas"]
		var discrepancias: Array[String] = []
		for s in SISTEMAS:
			var a := int(en_disco.get(s, -1))
			var b := int(del_diseno[s])
			if a != b:
				discrepancias.append("%s: disco=%d diseño=%d" % [s, a, b])
		var extra: Array[String] = []
		for s in en_disco:
			if not (String(s) in SISTEMAS):
				extra.append(String(s))
		_check(discrepancias.is_empty() and extra.is_empty(),
			"preset '%s': los 8 topes coinciden con el diseño%s%s"
				% [preset, "" if discrepancias.is_empty() else " (dif: %s)" % str(discrepancias),
				   "" if extra.is_empty() else " (sobran: %s)" % str(extra)])
		var suma := 0
		for s in en_disco:
			suma += int(en_disco[s])
		_check(suma == int(PRESETS[preset]["total"]),
			"preset '%s': la suma en disco (%d) es el total del diseño (%d)"
				% [preset, suma, int(PRESETS[preset]["total"])])
	var activo := String(datos.get("preset_activo", ""))
	_check(PRESETS.has(activo), "preset_activo '%s' existe entre los presets" % activo)

## ── 3. Escritura (sólo si la tabla del diseño pasó) ──────────────────────
func _escribir() -> void:
	print("--- C. Escritura del dataset ---")
	if _fallos > 0:
		print("  ABORTADO: la tabla del diseño tiene %d error(es); NO se escribe nada." % _fallos)
		return
	# Preservar el preset activo que ya estuviera en disco (lo define M90).
	var activo := PRESET_POR_DEFECTO
	if FileAccess.file_exists(RUTA):
		var previo := _leer_json(RUTA)
		var p := String(previo.get("preset_activo", ""))
		if PRESETS.has(p):
			activo = p
	var presets: Dictionary = {}
	for preset in PRESETS:
		presets[preset] = (PRESETS[preset]["sistemas"] as Dictionary).duplicate()
	var payload: Dictionary = {
		"version": 2,
		"preset_activo": activo,
		"presets": presets,
	}
	var texto := JSON.stringify(payload, "  ", false) + "\n"
	var f := FileAccess.open(RUTA, FileAccess.WRITE)
	if f == null:
		_fallos += 1
		print("  [FAIL] no se pudo abrir %s para escritura" % RUTA)
		return
	f.store_string(texto)
	f.close()
	print("  [OK] escrito %s (%d bytes, preset_activo=%s)" % [RUTA, texto.length(), activo])
	# Re-leer y re-validar: escribir no prueba nada, re-leer sí.
	_validar_dataset_en_disco()

func _resumen(solo_check: bool) -> void:
	print("=== Resumen generador budgets: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("BUDGETS INVALIDO — salida con codigo 1")
	else:
		print("BUDGETS OK — %s" % ("el dataset en disco coincide con el diseño §2" if solo_check
			else "dataset regenerado y re-validado contra el diseño §2"))

func _check(cond: bool, nombre: String) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)

func _leer_json(ruta: String) -> Dictionary:
	if not FileAccess.file_exists(ruta):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed as Dictionary

func _arg_check() -> bool:
	for a in OS.get_cmdline_user_args():
		if a == "--check":
			return true
	for a in OS.get_cmdline_args():
		if a == "--check":
			return true
	return false
