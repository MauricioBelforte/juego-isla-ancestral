# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M94: Verificación del auditor anti-FOMO (retención sin presión).
extends SceneTree

const AUDITOR := preload("res://scripts/motivacion/antifomo_auditor.gd")

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
	print("=== [M94] Verificación del auditor anti-FOMO ===")
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/motivacion/objetivos.json"))
	var objetivos: Array = data.get("objetivos", [])
	_check("7 objetivos de retención cargados", objetivos.size() == 7)
	var violaciones: Array = AUDITOR.escanear(objetivos)
	_check("Auditoría sin violaciones (retención cozy)", violaciones.is_empty())
	# config con flags prohibidos (R1-R5 del diseño): deben detectarse
	var violaciones2: Array = AUDITOR.escanear([], {"penaliza_ausencia": true})
	_check("Detecta R3 (castigo por ausencia)", violaciones2.has("R3_no_castigo_ausencia"))
	var violaciones3: Array = AUDITOR.escanear([], {"usa_tiempo_real": true})
	_check("Detecta R5 (tiempo real penaliza)", violaciones3.has("R5_no_reloj_real"))
	var violaciones4: Array = AUDITOR.escanear([], {"permite_expiracion": true})
	_check("Detecta R2 (recompensas expiran)", violaciones4.has("R2_no_expiracion"))
	var reporte: String = AUDITOR.reporte(violaciones2)
	_check("Reporte generable", reporte.length() > 0)
	print("=== Resumen M94: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
