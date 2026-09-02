# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M151: ControlFinalSchema — puerta del control final de release (7 gates).
# Ref: M101 (DoD QA), M61 (rendimiento), M122 (crash), M118 (CI), M87 (textos).
class_name ControlFinalSchema
extends RefCounted

const GATES := [
	"suite_tests_verde",
	"smoke_aprobado",
	"zero_criticos_abiertos",
	"crash_rate_cero",
	"ci_gates_verdes",
	"textos_localizados",
	"backup_configurado",
]

## Devuelve Array[String] con los gates no cumplidos (vacío si todo OK).
static func verificar_gates(resultados: Dictionary) -> Array[String]:
	var pendientes: Array[String] = []
	for gate in GATES:
		if not bool(resultados.get(gate, false)):
			pendientes.append(gate)
	return pendientes

## Devuelve el veredicto : 0 = RELEASE OK, 1 = bloqueado.
static func veredicto(resultados: Dictionary) -> int:
	return 0 if verificar_gates(resultados).is_empty() else 1
