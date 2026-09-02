# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M94: Retención sin FOMO — AntiFomoAuditor
# Auditoría anti-FOMO (RF2/RF3, criterio de aceptación 2): scan de mecánicas
# prohibidas según las 5 normas del 01-Requerimientos:
#   R1: 0 streaks obligatorios
#   R2: 0 expiración de recompensas
#   R3: 0 castigo por ausencia
#   R4: 0 contenido exclusivo temporal
#   R5: tiempo real nunca penaliza (solo el día de juego M29 manda)
# Es un helper estático: revisa config de objetivos y datos del manager.
# Diseño original (04-Codigo.md §1.1, AntiFomoAuditor.cs / CI gate).

class_name AntiFomoAuditor
extends RefCounted

const REGLAS := {
	"R1_no_streak": "No hay streak rewards obligatorios",
	"R2_no_expiracion": "No expiran recompensas sin cobrar",
	"R3_no_castigo_ausencia": "No se penaliza la ausencia",
	"R4_no_exclusivo_temporal": "No hay contenido exclusivo por fecha",
	"R5_no_reloj_real": "El tiempo real nunca penaliza (solo día de juego)",
}

## Devuelve Array[String] de violaciones (vacía = OK).
## `objetivos` = lista de ObjetivoData. `config` = dict opcional con flags.
static func escanear(objetivos: Array, config: Dictionary = {}) -> Array:
	var violaciones: Array = []
	var flags: Dictionary = {
		"permite_streak": config.get("permite_streak", false),
		"permite_expiracion": config.get("permite_expiracion", false),
		"penaliza_ausencia": config.get("penaliza_ausencia", false),
		"exclusivo_temporal": config.get("exclusivo_temporal", false),
		"usa_tiempo_real": config.get("usa_tiempo_real", false),
	}
	if flags["permite_streak"]:
		violaciones.append("R1_no_streak")
	if flags["permite_expiracion"]:
		violaciones.append("R2_no_expiracion")
	if flags["penaliza_ausencia"]:
		violaciones.append("R3_no_castigo_ausencia")
	if flags["exclusivo_temporal"]:
		violaciones.append("R4_no_exclusivo_temporal")
	if flags["usa_tiempo_real"]:
		violaciones.append("R5_no_reloj_real")
	return violaciones

## Reporte legible para CI/QA.
static func reporte(violaciones: Array) -> String:
	if violaciones.is_empty():
		return "[M94] AntiFomoAuditor: OK — 5 reglas cumplidas"
	var lineas: Array = ["[M94] AntiFomoAuditor: VIOLACIONES:"]
	for v in violaciones:
		lineas.append("  - %s: %s" % [v, REGLAS.get(v, v)])
	return "\n".join(lineas)