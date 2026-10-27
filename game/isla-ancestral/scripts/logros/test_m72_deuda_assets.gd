extends SceneTree
## M72 — deuda de dependencias externas (residuo, 2026-10-26, DeepSeek-V4.1-Flash)
##
## Mide dos hallazgos que estaban INVISIBLES en el catalogo de logros:
##   1. los 18 `icono` apuntan a `res://assets/ui/logros/` (directorio inexistente:
##      el repo no tiene NINGUN PNG de UI, solo `.gitkeep` en assets/2d/ui).
##   2. las 36 claves `LOGROS.*` (nombre_i18n/descripcion_i18n) no estan en
##      `locales/es.po` ni en `locales/en.po`.
##
## La suite NO fija los numeros: los CRUZA contra el disco y contra el .po por un
## camino independiente del que usa el servicio. Si el arte o las claves llegan,
## la suite sigue verde con numeros mas bajos; si el API miente, se pone roja.
## Ejecutar: godot --headless --path game/isla-ancestral -s res://scripts/logros/test_m72_deuda_assets.gd

const CHECKS_MINIMOS := 9
const BLOQUES := ["iconos", "i18n", "po_parser", "rf14_intacto"]

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}
var _ach: Node = null

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	_ach = root.get_node_or_null("Achievements")
	_check(_ach != null, "Achievements autoload presente")
	if _ach == null:
		return
	_test_iconos()
	_test_i18n()
	_test_po_parser()
	_test_rf14_intacto()

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if cond:
		print("  [OK] " + msg)
	else:
		_fallos += 1
		print("  [FALLO] " + msg)

func _fin(bloque: String) -> void:
	_vistos[bloque] = true

func _summary() -> void:
	var faltan: Array = []
	for b in BLOQUES:
		if not _vistos.has(b):
			faltan.append(b)
	if not faltan.is_empty():
		_fallos += 1
		print("[FAIL] bloques que NO se ejecutaron: %s" % str(faltan))
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== M72 deuda assets: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

## Bloque A: el API de iconos coincide EXACTAMENTE con el disco, en las dos
## direcciones (un icono que existe no puede figurar como ausente y viceversa).
func _test_iconos() -> void:
	var ausentes: Array = _ach.iconos_ausentes()
	var mal: Array = []
	var con_icono := 0
	for l in _ach.get_todos():
		var ruta := String(l.get("icono", ""))
		if ruta.is_empty():
			continue
		con_icono += 1
		var en_disco: bool = FileAccess.file_exists(ruta)
		var en_api: bool = ausentes.has(String(l.get("id", "")))
		if en_disco == en_api:
			mal.append("%s(disco=%s,api_ausente=%s)" % [String(l.get("id", "")), str(en_disco), str(en_api)])
	_check(con_icono == 18, "los 18 logros declaran icono (%d)" % con_icono)
	_check(mal.is_empty(), "iconos_ausentes() coincide con el disco en las 2 direcciones (desalineados=%s)" % str(mal))
	print("  [MEDIDO] iconos ausentes: %d de %d" % [ausentes.size(), con_icono])
	_fin("iconos")

## Bloque B: cada clave que el API reporta como ausente NO esta en el texto del
## .po (busqueda literal, camino independiente del parser), y ninguna clave que
## SI esta aparece en la lista.
func _test_i18n() -> void:
	var claves: Array = _ach.claves_i18n_ausentes()
	var texto := FileAccess.get_file_as_string("res://locales/es.po")
	_check(not texto.is_empty(), "locales/es.po legible (%d bytes)" % texto.length())
	var falsos: Array = []
	for clave in claves:
		if texto.contains("msgid \"%s\"" % String(clave)):
			falsos.append(String(clave))
	_check(falsos.is_empty(), "ninguna clave reportada ausente esta en el .po (falsos=%s)" % str(falsos))
	# Direccion inversa: toda clave declarada por el catalogo se clasifica bien.
	var mal: Array = []
	for l in _ach.get_todos():
		for campo in ["nombre_i18n", "descripcion_i18n"]:
			var clave := String(l.get(campo, ""))
			if clave.is_empty():
				continue
			var en_po: bool = texto.contains("msgid \"%s\"" % clave)
			var en_api: bool = claves.has(clave)
			if en_po == en_api:
				mal.append(clave)
	_check(mal.is_empty(), "clasificacion i18n completa (desalineadas=%s)" % str(mal))
	print("  [MEDIDO] claves i18n ausentes: %d" % claves.size())
	_fin("i18n")

## Bloque C: guarda de CEGUERA del parser de .po. Un parser roto devuelve {} y
## entonces TODAS las claves parecen ausentes: el numero sube y parece correcto.
func _test_po_parser() -> void:
	var msgids: Dictionary = _ach._msgids_po("res://locales/es.po")
	_check(msgids.size() > 50, "parser .po NO ciego: %d msgid leidos" % msgids.size())
	_check(msgids.has("MAIN_MENU.PLAY"), "parser .po reconoce una clave conocida (MAIN_MENU.PLAY)")
	_fin("po_parser")

## Bloque D: la deuda NO contamina el contrato de forma de RF14.
func _test_rf14_intacto() -> void:
	_check(int(_ach.validar_catalogo()) == 0, "validar_catalogo() sigue en 0 problemas (la deuda no es un defecto de forma)")
	_fin("rf14_intacto")
