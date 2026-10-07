# M163 - Sistema de Encantamientos (iter. 2, seccion C: Incienso)
# IncenseCultivation — Resource con datos y estado de UN cultivo de incienso.
#  - Tiempo de cultivo: 3 dias de juego (C4)
#  - Rendimiento: 2-4 unidades por cosecha (C5)
#  - Renewable: tras cosechar se puede volver a plantar (C11)
# El ciclo se mide en dias absolutos (GameTime.dia_absoluto(), M29) — nunca en
# get_fecha().dia, porque ese salta cada 28 dias (leccion documentada en M29).
class_name IncenseCultivation
extends Resource

## Dias de juego necesarios para que el cultivo este listo.
const DIAS_COSECHA: int = 3
## Rendimiento minimo por cosecha.
const RENDIMIENTO_MIN: int = 2
## Rendimiento maximo por cosecha.
const RENDIMIENTO_MAX: int = 4
## Namespace determinista para el RNG del dia (GameTime.rng_diario).
const NS_RNG: String = "m163_incienso"

var plantado: bool = false
var dia_siembra: int = -1

## Siembra el cultivo en `dia_ahora`. Devuelve false si ya hay un cultivo activo
## (no hay espacio en este lote).
func plantar(dia_ahora: int) -> bool:
	if plantado:
		return false
	plantado = true
	dia_siembra = dia_ahora
	return true

## Dias transcurridos desde la siembra (-1 si no hay cultivo).
func dias_transcurridos(dia_ahora: int) -> int:
	if not plantado:
		return -1
	return maxi(0, dia_ahora - dia_siembra)

## true cuando el cultivo cumplio DIAS_COSECHA.
func listo(dia_ahora: int) -> bool:
	return plantado and dias_transcurridos(dia_ahora) >= DIAS_COSECHA

## Dias restantes hasta la cosecha (0 si ya esta listo; -1 sin cultivo).
func dias_restantes(dia_ahora: int) -> int:
	if not plantado:
		return -1
	return maxi(0, DIAS_COSECHA - dias_transcurridos(dia_ahora))

## Cosecha el cultivo. Devuelve 0 si cosecho antes de tiempo (guard C4) o si no
## hay cultivo. Si esta listo, devuelve 2-4 unidades y limpia el lote (renewable).
## `rng` es inyectable para tests deterministas; si es null usa el RNG diario
## del reloj de juego (misma partida + mismo dia -> misma cosecha).
func cosechar(dia_ahora: int, rng: RandomNumberGenerator = null) -> int:
	if not listo(dia_ahora):
		return 0
	var r := rng
	if r == null:
		r = _rng_del_dia()
	var cantidad: int = r.randi_range(RENDIMIENTO_MIN, RENDIMIENTO_MAX)
	plantado = false
	dia_siembra = -1
	return cantidad

## RNG determinista del dia actual via GameTime (M29); fallback a rng libre
## cuando el reloj no existe (corridas aisladas del Resource).
func _rng_del_dia() -> RandomNumberGenerator:
	var gt = Engine.get_main_loop().root.get_node_or_null("GameTime") if Engine.get_main_loop() else null
	if gt != null and gt.has_method("rng_diario"):
		return gt.rng_diario(NS_RNG)
	var libre := RandomNumberGenerator.new()
	libre.randomize()
	return libre
