# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
# Editado por: atria-dawn-s2 / Kilo Code, 2026-10-05 — soporte de PENDIENTE
#   (directiva del fundador: un gate sin dato medible no bloquea; queda visible).
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

## Un gate puede tomar tres formas en `estado_release.json`:
##   - `true` / `false` (bool): cumplido o no cumplido.
##   - Diccionario `{"estado": "PENDIENTE", "duenio": ..., "fecha": ..., "desc": ...}`:
##     no hay dato medible aun. **No bloquea** (directiva del fundador: no se puede
##     penalizar lo que nadie puede medir todavia), pero queda visible para el acta.
## Cualquier otra cosa (string, numero) se evalua con `bool()`, como antes.

static func es_pendiente(valor: Variant) -> bool:
	return typeof(valor) == TYPE_DICTIONARY and str(valor.get("estado", "")).to_upper() == "PENDIENTE"

## Devuelve Array[String] con los gates NO cumplidos (vacio si todo OK).
## Un gate PENDIENTE no entra aqui: no bloquea el release.
static func verificar_gates(resultados: Dictionary) -> Array[String]:
	var pendientes: Array[String] = []
	for gate in GATES:
		var valor: Variant = resultados.get(gate, false)
		if es_pendiente(valor):
			continue
		if not bool(valor):
			pendientes.append(gate)
	return pendientes

## Devuelve Array[String] con los gates en estado PENDIENTE (sin dato medible).
## No bloquean, pero el acta los gestiona con dueno/fecha.
static func gates_pendientes(resultados: Dictionary) -> Array[String]:
	var pendientes: Array[String] = []
	for gate in GATES:
		if es_pendiente(resultados.get(gate, false)):
			pendientes.append(gate)
	return pendientes

## Devuelve el veredicto : 0 = RELEASE OK, 1 = bloqueado.
static func veredicto(resultados: Dictionary) -> int:
	return 0 if verificar_gates(resultados).is_empty() else 1
