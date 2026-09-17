# Modelo: atria-dawn
# Plataforma: Kilo Code
# Fecha: 2026-09-17
#
# M10 QA (log 945): test de GENERACION que no existia. Cubre el contrato de
# determinismo de 04-Codigo.md §3 ("regen de 3 chunks en órdenes distintos ->
# mismos bytes"), sensibilidad a la semilla, la banda de agua pisable
# (SHALLOW_WATER) y el bug de inalcanzabilidad del bioma "snow".
#
# Ejecutar:
# Godot --headless --path game/isla-ancestral --script res://scripts/world/test_generacion_m10_atria.gd

extends SceneTree

const RADIO: int = 2560
const SEMILLA: int = 42
const MUESTRAS: int = 300

var _fallos: int = 0
var _gen: RefCounted = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_gen = IslandGenerator.new(null, SEMILLA)
	_gen.island_radius = RADIO
	_gen.max_height = 40
	_gen.max_height_boost = 1.0
	_check(_gen != null, "IslandGenerator instanciable (catalog null, semilla)")
	if _gen == null:
		_fin()
		return
	_test_determinismo_orden()
	_test_sensibilidad_semilla()
	_test_banda_agua_pisable()
	_test_bioma_novible_alcanzable()
	_test_rango_alturas()
	_fin()

func _fin() -> void:
	print("=== TEST M10 GENERACION (atria): %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

## Posiciones de muestreo deterministicas (espiral amortiguada dentro de la isla).
func _posiciones(n: int) -> Array:
	var out: Array = []
	var ang: float = 0.0
	for i in range(n):
		var r: float = RADIO * (0.05 + 0.90 * float(i) / float(n))
		ang += 2.39996323  # áurea
		var x: int = int(RADIO + cos(ang) * r)
		var z: int = int(RADIO + sin(ang) * r)
		out.append(Vector2i(x, z))
	return out

## Contrato 04-Codigo §3: misma semilla -> mismos bloques sin importar el orden
## de evaluacion (simula regenerar chunks en distinto orden).
func _test_determinismo_orden() -> void:
	var pos := _posiciones(MUESTRAS)
	var a: Dictionary = {}
	for p in pos:
		var h: int = _gen.get_height(p.x, p.y)
		var b: int = _gen.get_block_at(p.x, h, p.y)
		a[p] = [h, b]
	# Orden inverso (otros chunks primero)
	var b2: Dictionary = {}
	pos.reverse()
	for p in pos:
		var h: int = _gen.get_height(p.x, p.y)
		var b: int = _gen.get_block_at(p.x, h, p.y)
		b2[p] = [h, b]
	var diffs: int = 0
	for key in a.keys():
		if a[key] != b2.get(key):
			diffs += 1
	_check(diffs == 0, "determinismo: misma semilla da mismos bloques en orden distinto (%d diffs de %d)" % [diffs, MUESTRAS])

## Semillas distintas deben producir terreno distinto (no un generador constante).
func _test_sensibilidad_semilla() -> void:
	var pos := _posiciones(60)
	var otro := IslandGenerator.new(null, SEMILLA + 7)
	otro.island_radius = RADIO
	otro.max_height = 40
	var distintos: int = 0
	for p in pos:
		if _gen.get_height(p.x, p.y) != otro.get_height(p.x, p.y):
			distintos += 1
	_check(distintos > 10, "sensibilidad a la semilla: otra semilla cambia el terreno (%d/60 distintas)" % distintos)

## Banda 0.94-1.03: debe generar SHALLOW_WATER (bloque 30) pisable sobre el fondo.
func _test_banda_agua_pisable() -> void:
	var hallados: int = 0
	var ang: float = 0.0
	for i in range(120):
		ang += 2.39996323
		var d: float = RADIO * 0.97  # dentro de la banda 0.94-1.03
		var x: int = int(RADIO + cos(ang) * d)
		var z: int = int(RADIO + sin(ang) * d)
		var h: int = _gen.get_height(x, z)
		var b: int = _gen.get_block_at(x, h + 1, z)
		if b == 30:  # BlockType.SHALLOW_WATER
			hallados += 1
	_check(hallados > 0, "banda agua pisable: SHALLOW_WATER (30) generado en el anillo 0.97 (%d/120)" % hallados)

## BUG documentado: el bioma "snow" es INALCANZABLE. _get_biome comprueba
## mountain (h > 0.65*max = 26) ANTES que snow (h > 0.8*max = 32) => toda altura
## alta vuelve "mountain". El muestreo lo confirma: hay posiciones con h > 32
## (max real ~38) que deberian ser snow y se clasifican como mountain. SNOW existe
## en BlockType y en la library de main_island.gd pero el generador nunca lo
## produce. Debe fallar hasta reordenar los checks en island_generator.gd.
## No se fixea en esta iter de QA: el perfil del terreno (max_height 40, boost 1.0)
## fue restaurado por el usuario (Log 791) y tocar la generacion es decision visual.
func _test_bioma_novible_alcanzable() -> void:
	var snow: int = 0
	var mountain: int = 0
	var total: int = 0
	var max_h: int = -1
	var ang: float = 0.0
	for i in range(2000):
		ang += 2.39996323
		var r: float = RADIO * (0.02 + 0.55 * float(i) / 2000.0)
		var x: int = int(RADIO + cos(ang) * r)
		var z: int = int(RADIO + sin(ang) * r)
		var b: String = _gen.call("_get_biome", x, z)
		total += 1
		var h: int = _gen.get_height(x, z)
		max_h = maxi(max_h, h)
		if b == "snow":
			snow += 1
		elif b == "mountain":
			mountain += 1
	var umbral_mountain: int = int(_gen.max_height * 0.65)
	var umbral_snow: int = int(_gen.max_height * 0.8)
	print("  biomas: %d muestras (mountain=%d snow=%d); altura max real=%d; umbrales mountain=%d snow=%d" % [total, mountain, snow, max_h, umbral_mountain, umbral_snow])
	var detalle: String = ""
	if max_h > umbral_snow:
		detalle = "causa unica: el check de mountain (%d) va ANTES que el de snow (%d) en island_generator.gd:198-203 — hay posiciones con h>%d (max %d), asi que reordenar los checks bastaria para que snow aparezca" % [umbral_mountain, umbral_snow, umbral_snow, max_h]
	else:
		detalle = "causa 1: check mountain (%d) va antes que snow (%d); causa 2: altura max real %d < umbral snow %d (boost 1.0, max_height %d nominal)" % [umbral_mountain, umbral_snow, max_h, umbral_snow, _gen.max_height]
	_check(snow > 0, "bioma snow alcanzable: snow=0/%d — %s" % [total, detalle])

## Las alturas deben ser no negativas y acotadas (perfil en capas).
func _test_rango_alturas() -> void:
	var pos := _posiciones(200)
	var max_h: int = -1
	var min_h: int = 99999
	for p in pos:
		var h: int = _gen.get_height(p.x, p.y)
		max_h = maxi(max_h, h)
		min_h = mini(min_h, h)
	_check(min_h >= 0, "rango de alturas: get_height >= 0 (min=%d)" % min_h)
	_check(max_h <= 80, "rango de alturas: get_height acotado (max=%d, max_height=40, boost=1.0)" % max_h)
	print("  alturas: min=%d max=%d" % [min_h, max_h])
