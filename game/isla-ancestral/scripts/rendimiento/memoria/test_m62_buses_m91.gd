# Modelo: DS-V4.1-Flash-Opencode
# Plataforma: OpenCode
# Fecha: 2026-10-20
#
# M62: Memoria — Suite de contratación "Los buses (M91) no retienen streams
# detenidos".
# Cierra por MEDICIÓN el ítem L153 de 62-Memoria plan-actual/05-Checklist:
#   "Los buses (M91) no retienen streams detenidos [S]"
#
# Qué mide (headless, con el AudioServer REAL y la topología de buses M91 del
# proyecto):
#   A. TOPOLOGÍA M91: los 7 buses existen (Master, Music, SFX, Ambient, Voice,
#      UI, Cinematic), bus_count == 7 y los 6 no-Master siguen enrutados a Master.
#   B. STREAM DETENIDO EN UN BUS: reproducir un AudioStream real en "Music",
#      stop() y stream = null -> el bus NO retiene el stream (WeakRef muere), el
#      bus sigue existiendo y su cantidad de efectos no cambia.
#   C. Ciclo x3 en buses distintos (Music/SFX/Ambient): cada stream muere tras
#      stop+null; bus_count y topología constantes (sin acumulación).
# 	D. EFECTOS DEL M91: un bus con efectos (compressor de Master, instalado por
#      el preparador si el layout no lo traía) tampoco retiene el stream
#      detenido; el efecto sigue montado y el stream muere.
#   E. PLAYER LIBERADO REPRODUCIENDO: free() del AudioStreamPlayer con stream
#      asignado -> el stream muere (el bus no lo retiene), bus_count no crece y
#      el árbol no queda con reproductores colgados.
#
# Stand-in declarado (honesto): el repo NO tiene archivos de audio (0
# .ogg/.wav/.mp3 en game/isla-ancestral). Se usa AudioStreamWAV generado en
# memoria — un AudioStream REAL del engine con la MISMA semántica RefCounted.
# Lo que se mide es la retención del stream por parte del bus, no el decoder.
#
# Nota de medición: `AudioServer` libera el playback interno en el frame
# siguiente (dummy driver en headless); los asertos usan `_esperar_muerte()`
# acotado. El criterio fuerte del ítem son los WeakRef (el stream muere) y la
# ausencia de reproductores colgados en el árbol (conteo LOCAL, no OBJECT_COUNT
# global, que deriva entre corridas por buffers del engine).
#
# Guardián anti-falso-verde de 3 capas (skill §2, trampas 11/28/61/63):
#   1. marcadores `_fin("X")` por bloque -> nombra el bloque que no corrió;
#   2. piso `CHECKS_MINIMOS` medido en verde -> caza el aborto en un helper;
#   3. `_summary()` en un `call_deferred` APARTE -> si `_run()` aborta por un
#      SCRIPT ERROR, la cola diferida sigue y el resumen igual se imprime.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_m62_buses_m91.gd

extends SceneTree

const MODULO := "M62 buses M91"
const BLOQUES: Array[String] = ["A", "B", "C", "D", "E"]
## Piso MEDIDO en verde (ver 07-Resultados-Testings.md / evidencia T70).
const CHECKS_MINIMOS := 40

const BUSES: Array[String] = ["Master", "Music", "SFX", "Ambient", "Voice", "UI", "Cinematic"]

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}

var _player: AudioStreamPlayer = null
var _terminado: bool = false


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	print("=== [M62] Los buses (M91) no retienen streams detenidos (L153) ===")
	_check(AudioServer != null, "AudioServer disponible")
	_bloque_a()
	await _bloque_b()
	await _bloque_c()
	await _bloque_d()
	await _bloque_e()
	print("=== FIN M62 buses M91 ===")
	_terminado = true


func _summary() -> void:
	# Espera a que `_run()` (coroutine por los await de los bloques) termine.
	# Si `_run()` aborta por un SCRIPT ERROR, `_terminado` nunca se pone y el
	# resumen igual se imprime al agotarse el margen (bloques faltantes = rojo).
	var espera := 0
	while not _terminado and espera < 600:
		espera += 1
		await process_frame
	for b in BLOQUES:
		if not _vistos.has(b):
			_check(false, "el bloque %s no se ejecutó" % b)
	var total := _checks
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, total, _fallos])
	if _fallos == 0 and total >= CHECKS_MINIMOS:
		print("TEST %s OK — los %d checks pasaron" % [MODULO, total])
		quit(0)
	else:
		if total < CHECKS_MINIMOS:
			print("[FALL] solo %d checks ejecutados (mínimo medido en verde: %d)" % [total, CHECKS_MINIMOS])
		print("TEST %s FALLIDO — salida con código 1" % MODULO)
		quit(1)


# ------------------------- helpers -------------------------

func _check(cond: bool, msg: String, det: String = "") -> void:
	_checks += 1
	if cond:
		print("  OK  %s" % msg)
	else:
		_fallos += 1
		var extra := ("" if det == "" else " [%s]" % det)
		print("  [FALL] %s%s" % [msg, extra])


func _fin(bloque: String) -> void:
	_vistos[bloque] = true
	print("-- fin bloque %s" % bloque)


## AudioStreamWAV real en memoria (stand-in declarado de cualquier AudioStream).
func _wav(seg: float = 0.1) -> AudioStreamWAV:
	var sr := 22050
	var n := int(sr * seg)
	var datos := PackedByteArray()
	datos.resize(n * 2)
	for i in n:
		var v := int(sin(TAU * 440.0 * float(i) / float(sr)) * 12000.0)
		datos.encode_s16(i * 2, v)
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = sr
	w.stereo = false
	w.data = datos
	return w


func _nuevo_player(bus: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = bus
	p.volume_db = -80.0
	get_root().add_child(p)
	return p


## El AudioServer libera el playback interno en el frame siguiente (dummy
## driver en headless); se espera acotado y se devuelve si el stream murió.
func _esperar_muerte(wr: WeakRef, frames: int = 120) -> bool:
	while frames > 0:
		if wr.get_ref() == null:
			return true
		await process_frame
		frames -= 1
	return wr.get_ref() == null


# ------------------------- bloques -------------------------

func _bloque_a() -> void:
	print("-- A: topología M91 (7 buses, enrutado a Master)")
	for b in BUSES:
		_check(AudioServer.get_bus_index(b) != -1, "bus '%s' existe" % b)
	_check(AudioServer.bus_count == 7, "bus_count == 7", "hay %d" % AudioServer.bus_count)
	for b in ["Music", "SFX", "Ambient", "Voice", "UI", "Cinematic"]:
		var idx := AudioServer.get_bus_index(b)
		_check(AudioServer.get_bus_send(idx) == "Master", "'%s' enrutado a Master" % b)
	_fin("A")


func _bloque_b() -> void:
	print("-- B: stream detenido en 'Music' no queda retenido por el bus")
	var bidx := AudioServer.get_bus_index("Music")
	_check(bidx != -1, "bus Music disponible")
	var ef_antes := AudioServer.get_bus_effect_count(bidx)
	var p := _nuevo_player("Music")
	_check(p.bus == "Music", "player en el bus Music")
	var w := _wav()
	var wr: WeakRef = weakref(w)
	_check(wr.get_ref() != null, "stream creado y referenciado")
	p.stream = w
	_check(p.stream == w, "stream asignado al player")
	p.play()
	_check(p.playing, "player reproduciendo")
	p.stop()
	_check(not p.playing, "player detenido")
	p.stream = null
	_check(p.stream == null, "stream soltado del player")
	w = null
	_check(await _esperar_muerte(wr), "el bus NO retiene el stream (WeakRef muere)")
	_check(AudioServer.bus_count == 7, "bus_count sigue en 7")
	_check(AudioServer.get_bus_effect_count(bidx) == ef_antes, "efectos de Music sin cambios")
	p.free()
	_fin("B")


func _bloque_c() -> void:
	print("-- C: ciclo x3 en buses distintos sin acumulación")
	var buses3 := ["Music", "SFX", "Ambient"]
	for b in buses3:
		var p := _nuevo_player(b)
		var w := _wav(0.05)
		var wr: WeakRef = weakref(w)
		p.stream = w
		p.play()
		p.stop()
		p.stream = null
		w = null
		_check(await _esperar_muerte(wr), "ciclo %s: stream muerto tras stop+null" % b)
		p.free()
	_check(AudioServer.bus_count == 7, "bus_count constante tras el ciclo")
	for b in buses3:
		_check(AudioServer.get_bus_index(b) != -1, "bus '%s' sigue existiendo" % b)
	_fin("C")


func _bloque_d() -> void:
	print("-- D: bus con efectos (compressor de Master) no retiene el stream detenido")
	var midx := AudioServer.get_bus_index("Master")
	_check(midx != -1, "bus Master disponible")
	var ef_antes := AudioServer.get_bus_effect_count(midx)
	var propio := false
	if ef_antes == 0:
		AudioServer.add_bus_effect(midx, AudioEffectCompressor.new(), 0)
		propio = true
	var ef_prep := AudioServer.get_bus_effect_count(midx)
	_check(ef_prep >= 1, "Master tiene al menos un efecto montado", "effects=%d" % ef_prep)
	var p := _nuevo_player("Master")
	var w := _wav()
	var wr: WeakRef = weakref(w)
	p.stream = w
	p.play()
	p.stop()
	p.stream = null
	w = null
	_check(await _esperar_muerte(wr), "con efectos montados, el stream igual muere")
	_check(AudioServer.get_bus_effect_count(midx) == ef_prep, "el efecto sigue montado", "effects=%d" % AudioServer.get_bus_effect_count(midx))
	p.free()
	if propio:
		AudioServer.remove_bus_effect(midx, 0)
		_check(AudioServer.get_bus_effect_count(midx) == ef_antes, "efecto temporal retirado")
	else:
		_check(AudioServer.get_bus_effect_count(midx) == ef_antes, "Master ya traía efectos (sin cambios)")
	_fin("D")


func _bloque_e() -> void:
	print("-- E: player liberado mientras reproduce no deja el stream retenido")
	var hijos_base := get_root().get_child_count()
	var p := _nuevo_player("SFX")
	var w := _wav()
	var wr: WeakRef = weakref(w)
	p.stream = w
	p.play()
	p.free()
	w = null
	p = null
	_check(await _esperar_muerte(wr), "free() del player libera el stream (WeakRef muere)")
	_check(AudioServer.bus_count == 7, "bus_count sigue en 7 tras free()")
	_check(get_root().get_child_count() == hijos_base, "sin reproductores colgados en el árbol", "%d->%d" % [hijos_base, get_root().get_child_count()])
	_fin("E")
