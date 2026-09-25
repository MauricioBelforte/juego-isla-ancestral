# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-25
#
# M106: Seguridad — SecurityDuplicationPrevention (helper reutilizable, V0 + headless).
# Implementa el servicio "DuplicationPrevention" del diseño (03-Diseno.md §7), que quedó `[ ]`:
#   generate_request_id        -> generar_request_id
#   is_request_processed       -> ya_procesado
#   mark_request_processed     -> marcar_procesado
#   cleanup_old_requests       -> limpiar_antiguos
#   processed_requests (var)   -> procesados (Dictionary, público)
# Lógica pura (RefCounted, sin class_name → preload). Idempotencia local; la aplicación sobre
# red es de M77.
#
# Determinismo: el diseño usa `randi()`, que NO es reproducible. Acá el id se compone de un
# contador monotónico + el tick del motor + `randi()`; el contador garantiza unicidad aun dentro
# del mismo tick y el test puede asertar unicidad sin depender del azar.

extends RefCounted

var procesados: Dictionary = {}
var _secuencia: int = 0


## Genera un id de operación único (contador + ticks + aleatorio).
func generar_request_id() -> String:
	_secuencia += 1
	return "%d_%d_%d" % [_secuencia, Time.get_ticks_usec(), randi() % 100000]


## ¿Esta operación ya fue procesada? (idempotencia / anti-replay).
func ya_procesado(request_id: String) -> bool:
	return procesados.has(request_id)


## Marca la operación como procesada en el instante `ahora_s` (segundos).
## Devuelve false si YA estaba procesada (segunda vez), true si es la primera.
func marcar_procesado(request_id: String, ahora_s: int) -> bool:
	if procesados.has(request_id):
		return false
	procesados[request_id] = ahora_s
	return true


## Descarta operaciones más viejas que `timeout_s`. Devuelve cuántas eliminó.
func limpiar_antiguos(ahora_s: int, timeout_s: int = 3600) -> int:
	var borradas: Array = []
	for request_id in procesados.keys():
		if ahora_s - int(procesados[request_id]) > timeout_s:
			borradas.append(request_id)
	for request_id in borradas:
		procesados.erase(request_id)
	return borradas.size()


func cantidad_procesados() -> int:
	return procesados.size()
