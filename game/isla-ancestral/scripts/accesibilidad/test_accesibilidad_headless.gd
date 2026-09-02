# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M58: Test headless — config de accesibilidad + contraste WCAG de la UI real.
extends SceneTree

const SCHEMA := preload("res://scripts/accesibilidad/accesibilidad_schema.gd")

var _fallos := 0
var _checks := 0

func _init() -> void:
	call_deferred("_run")

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s" % nombre)

func _run() -> void:
	print("=== [M58] Test de accesibilidad ===")
	var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/accesibilidad/config.json"))
	_check("Config de accesibilidad válida", SCHEMA.validar(config).is_empty())
	_check("Tamaño de texto 'medio' (default)", String(config.get("tamano_texto", "")) == "medio")
	_check("Contraste 'alto' (default)", String(config.get("contraste", "")) == "alto")
	_check("Subtítulos habilitados", bool(config.get("subtitulos", false)))
	_check("Reducción de efectos OFF (default)", not bool(config.get("reducir_efectos", false)))
	# Contraste WCAG de la UI real (blanco sobre paneles oscuros del HUD)
	var contraste: float = SCHEMA.contraste_relativo(Color(1, 1, 1), Color(0.16, 0.14, 0.12))
	_check("Contraste blanco/fondo oscuro >= 7 (AAA) — %.2f" % contraste, contraste >= 7.0)
	var contraste_suave: float = SCHEMA.contraste_relativo(Color(0.33, 0.44, 0.12), Color(0.96, 0.94, 0.88))
	_check("Contraste pasto/arena visible (>= 3) — %.2f" % contraste_suave, contraste_suave >= 3.0)
	# Modo daltonismo inválido
	var roto: Dictionary = config.duplicate()
	roto["modo_daltonismo"] = "cielo"
	var errores: Array = SCHEMA.validar(roto)
	_check("Detecta modo daltonismo inválido", errores.has("modo_daltonismo inválido: cielo"))
	print("=== Resumen M58: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
