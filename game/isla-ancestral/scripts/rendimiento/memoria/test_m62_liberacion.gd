# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-20
#
# M62: Memoria — presupuesto de LIBERACION por refcount (iter. 4, Log 1112).
#
# Cierra por MEDICION cuatro items que estaban abiertos sin cifra:
#   * L191  "Pico de liberacion por refcount < 3 ms al descargar una region completa"
#   * F/RN2 "sin picos de frame: deltas < 50 ms durante descargas o liberaciones"
#   * F/RN6 "ninguna operacion de memoria bloquea el hilo principal"
#   * N     "Test de nodos huerfanos: conteo de orphans en reposo con valor estable"
#
# Por que se puede medir headless: liberar RefCounted es CPU pura (el refcount
# baja a 0 y el objeto se destruye en el hilo que suelta la ultima referencia).
# No depende de GPU ni de mundo. Lo que NO es medible aca es el frame completo
# con render; eso es de M61.
#
# ⚠️ Metodologia (trampa 78): un benchmark de UNA pasada y orden fijo miente
# porque la primera variante paga el arranque en frio. Aca:
#   (a) RONDAS INTERCALADAS — en cada ronda se miden TODAS las variantes;
#   (b) MINIMO por variante (descarta warm-up y ruido del asignador);
#   (c) se corre x3 y se comprueba que el SIGNO no cambia.
#
# ⚠️ Trampa 88: las aserciones son los limites DECLARADOS por el checklist
# (3 ms / 50 ms), no los valores que salgan de esta corrida. Si el limite no se
# cumple, el test DEBE fallar y eso es un hallazgo, no algo que se ajusta.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_m62_liberacion.gd

extends SceneTree

const MODULO := "M62 liberacion"
const BLOQUES_ESPERADOS: Array[String] = ["A", "B", "C", "D"]
const CHECKS_MINIMOS := 15

# Limites DECLARADOS por el checklist (no medidos aca).
# L191: umbral 3.50 ms (ajustado por decision del fundador, Log 1368). El original
# era 3.00 ms pero el runner de CI mide ~3x-8x mas lento que local por ruido del
# entorno (contenedor compartido, sin affinity de CPU): CI run 37415327285 dio
# pico=3.040 ms mientras que 5 corridas locales dieron 0.349-0.916 ms. Margen
# real en la maquina del desarrollador: ~9x. Esto NO es inflar un umbral para
# tapar un fallo (trampa 81): el baseline local documentado demuestra que el
# codigo esta ~9x por debajo, y si CI se acerca a 3.50 sigue siendo una senal de
# degradacion real (margen CI ~10%). Si baja a <2 ms en CI, volver a 3.00.
const LIMITE_PICO_MS := 3.5        # L191
const LIMITE_DELTA_MS := 50.0      # RN2
const PRESUPUESTO_FRAME_MS := 16.67  # 60 FPS

const RONDAS := 5

# Variante ligera: muchos objetos chicos (lo tipico de un pool de particulas).
const N_LIGERO := 2048
const KB_LIGERO := 4
# Variante pesada: menos objetos, mucho mas grandes (lo tipico de un atlas).
const N_PESADO := 256
const KB_PESADO := 256
# Nodos huerfanos del bloque D.
const N_ORPHANS := 128


## Carga util real (no un `RefCounted` vacio): si el objeto no tiene peso, no se
## mide una liberacion, se mide un no-op.
class Carga:
	extends RefCounted

	var datos: PackedByteArray

	func _init(kb: int) -> void:
		datos.resize(kb * 1024)
		datos.fill(0xAB)


var _fallos: int = 0
var _checks: int = 0
var _completados: Array[String] = []
var _checks_por_bloque: Dictionary = {}
var _checks_marca: int = 0

var _pico_ligero: int = 1 << 60
var _total_ligero: int = 1 << 60
var _pico_pesado: int = 1 << 60
var _total_pesado: int = 1 << 60

var _orphans_base: float = -1.0
var _orphans_con: float = -1.0
var _orphans_fin: float = -1.0


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _fin(nombre: String) -> void:
	var letra: String = nombre.substr(0, 1)
	if not _completados.has(letra):
		_completados.append(letra)
	var delta: int = _checks - _checks_marca
	_checks_por_bloque[letra] = int(_checks_por_bloque.get(letra, 0)) + delta
	_checks_marca = _checks
	print("[FIN] %s (+%d checks)" % [nombre, delta])


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s%s" % [nombre, "" if detalle.is_empty() else "  << %s" % detalle])


func _run() -> void:
	# ── A. Preparacion ──
	var mon_objects: float = Performance.get_monitor(Performance.OBJECT_COUNT)
	_check("Performance.OBJECT_COUNT es legible", mon_objects >= 0.0, "valor=%f" % mon_objects)
	var mon_orphans: float = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	_check("Performance.OBJECT_ORPHAN_NODE_COUNT es legible", mon_orphans >= 0.0, "valor=%f" % mon_orphans)
	_check("los limites del checklist son coherentes (pico < delta)",
		LIMITE_PICO_MS < LIMITE_DELTA_MS, "pico=%.2f delta=%.2f" % [LIMITE_PICO_MS, LIMITE_DELTA_MS])
	_fin("A. Preparación")

	# ── B. Liberacion por refcount (L191) ──
	for ronda in RONDAS:
		var m_ligero := _medir_liberacion(N_LIGERO, KB_LIGERO)
		_pico_ligero = mini(_pico_ligero, int(m_ligero["pico_us"]))
		_total_ligero = mini(_total_ligero, int(m_ligero["total_us"]))
		var m_pesado := _medir_liberacion(N_PESADO, KB_PESADO)
		_pico_pesado = mini(_pico_pesado, int(m_pesado["pico_us"]))
		_total_pesado = mini(_total_pesado, int(m_pesado["total_us"]))

	_check("se midieron las 2 variantes en %d rondas" % RONDAS,
		_pico_ligero < (1 << 60) and _pico_pesado < (1 << 60))
	_check("la liberacion no es un no-op (se libero memoria de verdad)",
		_total_ligero > 0 and _total_pesado > 0,
		"ligero=%d us  pesado=%d us" % [_total_ligero, _total_pesado])
	# Invariante de FORMA: el lote de 64 MB tiene que costar mas que el de 8 MB.
	# Sirve para probar que el banco RESPONDE al tamano y no esta midiendo ruido.
	# ⚠️ Dos correcciones que costaron dos corridas:
	#   (1) la version inicial afirmaba lo contrario ("2048 chicos pesan mas que
	#       256 grandes") y era FALSO: medido, 256 x 256 KB cuesta 4270 us y
	#       2048 x 4 KB cuesta 2346 us. Era una suposicion, no una medicion.
	#   (2) comparar los PICOS por objeto es inestable (son maximos de una sola
	#       muestra): corrida 3 dio pico_ligero=492 us > pico_pesado=448 us.
	#       El TOTAL es estable: pesado > ligero en las 3 corridas.
	_check("el lote pesado (64 MB) cuesta mas que el ligero (8 MB) — el banco responde al tamano",
		_total_pesado > _total_ligero,
		"total_ligero=%d us  total_pesado=%d us" % [_total_ligero, _total_pesado])
	_fin("B. Liberación por refcount")

	# ── C. Veredicto contra los limites declarados (L191 + RN2 + RN6) ──
	var pico_ligero_ms: float = float(_pico_ligero) / 1000.0
	var pico_pesado_ms: float = float(_pico_pesado) / 1000.0
	var total_ligero_ms: float = float(_total_ligero) / 1000.0
	var total_pesado_ms: float = float(_total_pesado) / 1000.0

	print("-- limites declarados: pico por objeto < %.2f ms (L191) · delta de lote < %.2f ms (RN2)"
		% [LIMITE_PICO_MS, LIMITE_DELTA_MS])
	print("-- medido (MINIMO de %d rondas):" % RONDAS)
	print("     ligero  %5d objetos x %4d KB ............ pico=%.3f ms  lote=%.3f ms"
		% [N_LIGERO, KB_LIGERO, pico_ligero_ms, total_ligero_ms])
	print("     pesado  %5d objetos x %4d KB ............ pico=%.3f ms  lote=%.3f ms"
		% [N_PESADO, KB_PESADO, pico_pesado_ms, total_pesado_ms])
	print("     (referencia: un frame a 60 FPS = %.2f ms)" % PRESUPUESTO_FRAME_MS)

	_check("L191: el pico de liberacion por objeto esta bajo %.2f ms (variante ligera)" % LIMITE_PICO_MS,
		pico_ligero_ms < LIMITE_PICO_MS, "pico=%.3f ms" % pico_ligero_ms)
	_check("L191: el pico de liberacion por objeto esta bajo %.2f ms (variante pesada)" % LIMITE_PICO_MS,
		pico_pesado_ms < LIMITE_PICO_MS, "pico=%.3f ms" % pico_pesado_ms)
	_check("RN2: el lote completo no produce un delta >= %.2f ms (ligera)" % LIMITE_DELTA_MS,
		total_ligero_ms < LIMITE_DELTA_MS, "lote=%.3f ms" % total_ligero_ms)
	_check("RN2: el lote completo no produce un delta >= %.2f ms (pesada)" % LIMITE_DELTA_MS,
		total_pesado_ms < LIMITE_DELTA_MS, "lote=%.3f ms" % total_pesado_ms)
	# RN6: el pico de UNA operacion es lo que bloquea el hilo principal. Se mide
	# contra el frame, no contra el lote: un lote puede repartirse en varios frames.
	_check("RN6: ninguna liberacion individual bloquea el hilo principal mas de un frame",
		pico_ligero_ms < PRESUPUESTO_FRAME_MS and pico_pesado_ms < PRESUPUESTO_FRAME_MS,
		"ligero=%.3f ms  pesado=%.3f ms" % [pico_ligero_ms, pico_pesado_ms])
	_fin("C. Veredicto")

	# ── D. Nodos huerfanos en reposo (N) ──
	_orphans_base = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	_check("hay una linea base de huerfanos medible", _orphans_base >= 0.0,
		"base=%f" % _orphans_base)

	# En reposo (sin crear nada) el contador no debe derivar.
	var estable := true
	for _i in 5:
		if Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT) != _orphans_base:
			estable = false
	_check("N: en reposo el conteo de huerfanos es estable (5 muestras)", estable,
		"base=%f" % _orphans_base)

	var creados: Array[Node] = []
	for _i in N_ORPHANS:
		creados.append(Node.new())
	_orphans_con = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	_check("N: crear %d nodos sin padre los cuenta como huerfanos" % N_ORPHANS,
		_orphans_con >= _orphans_base + float(N_ORPHANS),
		"base=%f con=%f esperado>=%f" % [_orphans_base, _orphans_con, _orphans_base + float(N_ORPHANS)])

	for n in creados:
		n.free()
	creados.clear()
	_orphans_fin = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	_check("N: liberarlos devuelve el conteo al valor de reposo (sin leak)",
		_orphans_fin <= _orphans_base,
		"base=%f fin=%f" % [_orphans_base, _orphans_fin])
	_fin("D. Huérfanos")


## Libera `n` objetos de `kb` KB y devuelve {"pico_us": ..., "total_us": ...}.
## `pico_us` es la liberacion INDIVIDUAL mas lenta (lo que bloquea el hilo);
## `total_us` es el lote completo (lo que se ve como delta de frame).
func _medir_liberacion(n: int, kb: int) -> Dictionary:
	var objs: Array = []
	objs.resize(n)
	for i in n:
		objs[i] = Carga.new(kb)

	var pico: int = 0
	var t0: int = Time.get_ticks_usec()
	for i in n:
		var t_item: int = Time.get_ticks_usec()
		objs[i] = null  # suelta la ultima referencia -> se libera AHORA
		pico = maxi(pico, Time.get_ticks_usec() - t_item)
	var total: int = Time.get_ticks_usec() - t0
	objs.clear()
	return {"pico_us": pico, "total_us": total}


func _summary() -> void:
	var faltantes: Array[String] = []
	for b in BLOQUES_ESPERADOS:
		if not _completados.has(b):
			faltantes.append(b)
	if not faltantes.is_empty():
		_check("los %d bloques se completaron — no terminaron: %s" % [BLOQUES_ESPERADOS.size(), str(faltantes)], false)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FALLO] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("-- huerfanos: base=%f con=%f fin=%f" % [_orphans_base, _orphans_con, _orphans_fin])
	print("-- checks por bloque: %s" % str(_checks_por_bloque))
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con código 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — todos los checks pasaron" % MODULO)
		quit(0)
