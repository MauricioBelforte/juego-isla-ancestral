# Modelo: DS-V4.1-Flash-Opencode
# Plataforma: OpenCode
# Fecha: 2026-10-20
#
# M62: Memoria — Suite de contratación "Streams .ogg liberados de caché cuando
# ningún reproductor los usa".
# Cierra por MEDICIÓN el ítem L152 de 62-Memoria plan-actual/05-Checklist:
#   "Streams `.ogg` liberados de caché cuando ningún reproductor los usa [M]"
#
# Qué mide (headless, con el autoload REAL MemoryMonitor y AudioStreamPlayer del
# engine):
#   A. CON REPRODUCTOR: un stream asignado a un AudioStreamPlayer VIVO del árbol
#      NO se libera aunque el 62 drene su candidato (el reproductor lo usa). Al
#      soltarlo (stream = null + stop) el stream SALE de caché: WeakRef muere sin
#      necesidad de otro drenaje.
#   B. SIN REPRODUCTOR: un stream que nadie usa se encola en el 62 (la cola lo
#      retiene mientras espera descarga, para poder descargarlo) y al drenar se
#      libera (WeakRef 0): el lote NO retiene el recurso.
#   C. Ciclo x3 de usar -> soltar -> drenar: sin acumulación (0 vivos, cola 0).
#   D. Dos streams en el MISMO lote: uno en uso por un reproductor (sobrevive) y
#      otro libre (muere); al soltar el primero, muere sin otro cambio de región.
#   E. Contrato del pool (PoolFactory 'audio_voz'): el reproductor nace SIN
#      stream (estacionado) y `_estacionar()` (limpieza del pool) lo deja SIN
#      stream: el pool no retiene streams entre usos.
#
# Stand-in declarado (honesto): el repo NO tiene ningún archivo de audio
# (0 .ogg/.wav/.mp3 en game/isla-ancestral). No se puede construir un
# AudioStreamOggVorbis real sin bytes ogg. La suite usa AudioStreamWAV generado
# en memoria — un AudioStream REAL del engine, con la MISMA semántica de
# retención/caché (RefCounted + propiedad `stream` del reproductor). Lo que se
# mide es la SEMÁNTICA del ítem (liberación cuando ningún reproductor lo usa),
# no el decoder ogg. Mismo criterio que T65 (`VoxelToolBuffer` no construible).
#
# Nota de medición: `objetos_vivos()` es OBJECT_COUNT global; el test crea un
# AudioStreamPlayer y el audio server crea playbacks internos, así que los
# asertos de conteo usan TOL_ENGINE (ruido/estructuras del engine, no recursos
# del test). El criterio fuerte del ítem son los WeakRef (el stream muere).
#
# Alcance (honesto): M41 (MusicDirector) y M44 (FeedbackDirector) son directores
# de LÓGICA sin AudioStreamPlayer propio ni llamadas al handshake del 62; el
# cableado de producción (asignar/soltar el stream real al cambiar de tema)
# pertenece a M41/M42/M44 (07-Resultados-Testings.md §12).
#
# Guardián anti-falso-verde de 3 capas (skill §2, trampas 11/28/61/63):
#   1. marcadores `_fin("X")` por bloque -> nombra el bloque que no corrió;
#   2. piso `CHECKS_MINIMOS` medido en verde -> caza el aborto en un helper;
#   3. `_summary()` en un `call_deferred` APARTE -> si `_run()` aborta por un
#      SCRIPT ERROR, la cola diferida sigue y el resumen igual se imprime.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_m62_ogg_cache.gd

extends SceneTree

const MODULO := "M62 ogg cache"
const BLOQUES: Array[String] = ["A", "B", "C", "D", "E"]
## Piso MEDIDO en verde (ver 07-Resultados-Testings.md / evidencia T69).
const CHECKS_MINIMOS := 46

const PESO_STREAM_MB := 48
const PESO_STREAM_B_MB := 12

## Ruido/estructuras internas del engine (player del test + playbacks de audio).
## El criterio del ítem son los WeakRef; este margen solo evita falsos rojos.
const TOL_ENGINE := 2

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}

# Reproductor real del test (se reusa entre bloques; vive en el árbol).
var _player: AudioStreamPlayer = null
# Referencias locales que el test debe soltar para las pruebas WeakRef.
var _refs: Array = []
var _debiles: Array[WeakRef] = []

# Deltas base capturados por bloque.
var _obj_base: int = -1
var _forz_a0: int = -1
var _camb_a0: int = -1
var _forz_b0: int = -1
var _camb_b0: int = -1
var _forz_c0: int = -1
var _camb_c0: int = -1
var _forz_d0: int = -1
var _camb_d0: int = -1
var _obj_fin: int = -1
var _vivos_fin: int = -1


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	print("=== [M62] Streams .ogg liberados de caché cuando ningún reproductor los usa (L152) ===")
	var mm := _mm()
	if mm == null:
		_check("autoload MemoryMonitor presente", false, "mm=%s" % mm)
		return
	_check("autoload MemoryMonitor presente", true)
	_bloque_a()
	_bloque_b()
	_bloque_c()
	_bloque_d()
	_bloque_e()
	if _player != null:
		_player.free()
		_player = null


## ── A. Con reproductor: el stream SOBREVIVE; al soltarlo sale de caché ───────
func _bloque_a() -> void:
	print("--- A. Con reproductor vivo: el stream en uso NO se libera; al soltarlo SÍ ---")
	var mm := _mm()
	mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	_check("la cola de descarga arranca drenada",
		mm.unload.candidatos_count() == 0, "n=%d" % mm.unload.candidatos_count())
	_preparar_player()
	_obj_base = mm.objetos_vivos()
	_forz_a0 = mm.liberaciones_forzadas()
	_camb_a0 = mm.cambios_region()
	var w := _wav(64, 0.11)
	_refs.append(w)
	var d: WeakRef = weakref(w)
	_player.stream = w
	w = null
	_refs.clear()
	_debiles.append(d)
	_check("el reproductor está en el árbol de la escena", _player.is_inside_tree())
	_check("con el stream asignado, el reproductor lo usa (WeakRef viva)",
		_contar_vivos(_debiles) == 1, "vivos=%d" % _contar_vivos(_debiles))
	mm.registrar_candidato_descarga(_player.stream, PESO_STREAM_MB, 9.0)
	_check("el stream queda encolado como candidato de descarga",
		mm.unload.candidatos_count() == 1, "n=%d" % mm.unload.candidatos_count())
	var forzo: bool = mm.avisar_cambio_region("t69_reg_a")
	_check("el cambio de región fuerza el drenaje del candidato", forzo == true)
	_check("la cola quedó VACÍA tras drenar", mm.unload.candidatos_count() == 0,
		"n=%d" % mm.unload.candidatos_count())
	_check("el lote reporta los 48 MB del stream",
		String(mm.unload.resumen_ultimo_lote()).begins_with("48 MB"),
		mm.unload.resumen_ultimo_lote())
	_check("CON reproductor, el stream SIGUE vivo tras el drenaje (el 62 no lo arranca)",
		_contar_vivos(_debiles) == 1, "vivos=%d" % _contar_vivos(_debiles))
	_player.stream = null
	_player.stop()
	_check("al soltarlo del reproductor, el stream SALE de caché (WeakRef muere)",
		_contar_vivos(_debiles) == 0, "vivos=%d" % _contar_vivos(_debiles))
	_check("una liberación forzada y un cambio de región contados",
		mm.liberaciones_forzadas() == _forz_a0 + 1 and mm.cambios_region() == _camb_a0 + 1,
		"f=%d c=%d" % [mm.liberaciones_forzadas(), mm.cambios_region()])
	_debiles.clear()
	_fin("A")


## ── B. Sin reproductor: la cola lo retiene mientras espera; al drenar muere ─
func _bloque_b() -> void:
	print("--- B. Sin reproductor: encolado vivo, tras drenar se libera ---")
	var mm := _mm()
	_forz_b0 = mm.liberaciones_forzadas()
	_camb_b0 = mm.cambios_region()
	var w := _wav(64, 0.23)
	_refs.append(w)
	_debiles.append(weakref(w))
	mm.registrar_candidato_descarga(w, PESO_STREAM_MB, 5.0)
	_check("el stream libre queda encolado (1 candidato)",
		mm.unload.candidatos_count() == 1, "n=%d" % mm.unload.candidatos_count())
	w = null
	_refs.clear()
	_check("el stream libre NO está asignado a ningún reproductor",
		_player == null or _player.stream == null)
	_check("con el candidato ENCOLADO el stream sigue vivo (la cola lo retiene para descargarlo)",
		_contar_vivos(_debiles) == 1, "vivos=%d" % _contar_vivos(_debiles))
	var forzo: bool = mm.avisar_cambio_region("t69_reg_b")
	_check("el cambio de región fuerza el drenaje del stream libre", forzo == true)
	_check("la cola quedó VACÍA", mm.unload.candidatos_count() == 0,
		"n=%d" % mm.unload.candidatos_count())
	_check("el stream salió en UN lote", mm.unload.ultimo_lote_count() == 1,
		"n=%d" % mm.unload.ultimo_lote_count())
	_check("el resumen del lote conserva el peso declarado (48 MB)",
		String(mm.unload.resumen_ultimo_lote()).begins_with("48 MB"),
		mm.unload.resumen_ultimo_lote())
	_check("SIN reproductor, tras drenar el stream MUERE (el lote no lo retiene)",
		_contar_vivos(_debiles) == 0, "vivos=%d" % _contar_vivos(_debiles))
	_check("la liberación forzada y el cambio quedaron contados",
		mm.liberaciones_forzadas() == _forz_b0 + 1 and mm.cambios_region() == _camb_b0 + 1,
		"f=%d c=%d" % [mm.liberaciones_forzadas(), mm.cambios_region()])
	_check("objetos_vivos dentro del margen del engine",
		mm.objetos_vivos() <= _obj_base + TOL_ENGINE,
		"base=%d fin=%d tol=%d" % [_obj_base, mm.objetos_vivos(), TOL_ENGINE])
	_debiles.clear()
	_fin("B")


## ── C. Ciclo x3 usar -> soltar -> drenar ───────────────────────────────────
func _bloque_c() -> void:
	print("--- C. Ciclo x3: usar en reproductor, soltar, drenar: sin acumulación ---")
	var mm := _mm()
	_forz_c0 = mm.liberaciones_forzadas()
	_camb_c0 = mm.cambios_region()
	_preparar_player()
	var usados := 0
	var soltados := 0
	for i in 3:
		var w := _wav(64, 0.31 + float(i) * 0.07)
		_refs.append(w)
		_debiles.append(weakref(w))
		_player.stream = w
		w = null
		_refs.clear()
		if _contar_vivos(_debiles) == 1:
			usados += 1
		mm.registrar_candidato_descarga(_player.stream, PESO_STREAM_MB, float(9 - i))
		_player.stream = null
		_player.stop()
		mm.avisar_cambio_region("t69_ciclo_%d" % i)
		if _contar_vivos(_debiles) == 0:
			soltados += 1
	_check("los 3 ciclos: stream vivo mientras el reproductor lo usa", usados == 3,
		"usados=%d/3" % usados)
	_check("los 3 ciclos: tras soltar y drenar, el stream muere", soltados == 3,
		"soltados=%d/3" % soltados)
	_check("la cola volvió a 0 tras el último ciclo",
		mm.unload.candidatos_count() == 0, "n=%d" % mm.unload.candidatos_count())
	_check("el último ciclo salió en UN lote",
		mm.unload.ultimo_lote_count() == 1, "n=%d" % mm.unload.ultimo_lote_count())
	_check("3 liberaciones forzadas más", mm.liberaciones_forzadas() == _forz_c0 + 3,
		"f=%d base+3=%d" % [mm.liberaciones_forzadas(), _forz_c0 + 3])
	_check("3 cambios de región más", mm.cambios_region() == _camb_c0 + 3,
		"%d vs %d" % [mm.cambios_region(), _camb_c0 + 3])
	_check("ningún stream del ciclo sobrevive (WeakRef)", _contar_vivos(_debiles) == 0,
		"vivos=%d" % _contar_vivos(_debiles))
	_debiles.clear()
	_check("objetos_vivos dentro del margen del engine tras 3 ciclos",
		mm.objetos_vivos() <= _obj_base + TOL_ENGINE,
		"base=%d fin=%d tol=%d" % [_obj_base, mm.objetos_vivos(), TOL_ENGINE])
	_fin("C")


## ── D. Dos streams en el MISMO lote: uno en uso, otro libre ─────────────────
func _bloque_d() -> void:
	print("--- D. Mismo lote: stream EN USO sobrevive, stream LIBRE muere ---")
	var mm := _mm()
	_forz_d0 = mm.liberaciones_forzadas()
	_camb_d0 = mm.cambios_region()
	_preparar_player()
	var a := _wav(64, 0.41)
	var b := _wav(32, 0.53)
	var d_a: WeakRef = weakref(a)
	var d_b: WeakRef = weakref(b)
	_player.stream = a
	mm.registrar_candidato_descarga(_player.stream, PESO_STREAM_MB, 9.0)
	mm.registrar_candidato_descarga(b, PESO_STREAM_B_MB, 5.0)
	a = null
	b = null
	_refs.clear()
	_debiles.append(d_a)
	_debiles.append(d_b)
	_check("los 2 streams (uno en uso, uno libre) están encolados",
		mm.unload.candidatos_count() == 2, "n=%d" % mm.unload.candidatos_count())
	var forzo: bool = mm.avisar_cambio_region("t69_reg_d")
	_check("el cambio de región fuerza un solo drenaje para ambos", forzo == true)
	_check("la cola quedó VACÍA", mm.unload.candidatos_count() == 0,
		"n=%d" % mm.unload.candidatos_count())
	_check("los 2 streams salieron en UN lote", mm.unload.ultimo_lote_count() == 2,
		"n=%d" % mm.unload.ultimo_lote_count())
	_check("el lote encabeza por el stream más pesado (48 MB)",
		String(mm.unload.resumen_ultimo_lote()).begins_with("48 MB"),
		mm.unload.resumen_ultimo_lote())
	_check("el stream LIBRE murió en el drenaje",
		(d_b as WeakRef).get_ref() == null)
	_check("el stream EN USO sobrevivió al mismo drenaje (el reproductor lo usa)",
		(d_a as WeakRef).get_ref() != null)
	_player.stream = null
	_player.stop()
	_check("al soltar el primer stream, muere sin otro cambio de región",
		(d_a as WeakRef).get_ref() == null)
	_check("una sola liberación forzada y un cambio por el lote",
		mm.liberaciones_forzadas() == _forz_d0 + 1 and mm.cambios_region() == _camb_d0 + 1,
		"f=%d c=%d" % [mm.liberaciones_forzadas(), mm.cambios_region()])
	_check("objetos_vivos dentro del margen del engine tras el lote mixto",
		mm.objetos_vivos() <= _obj_base + TOL_ENGINE,
		"base=%d fin=%d tol=%d" % [_obj_base, mm.objetos_vivos(), TOL_ENGINE])
	_debiles.clear()
	_fin("D")


## ── E. Contrato del pool: el reproductor no retiene streams ─────────────────
func _bloque_e() -> void:
	print("--- E. PoolFactory 'audio_voz': reproductor estacionado sin stream ---")
	var mm := _mm()
	var pf := PoolFactory.new()
	var p := pf.crear("audio_voz")
	_check("PoolFactory crea un AudioStreamPlayer de audio_voz", p is AudioStreamPlayer,
		str(p))
	if p == null:
		_fin("E")
		return
	root.add_child(p)
	_check("el reproductor del pool nace ESTACIONADO (sin stream)",
		(p as AudioStreamPlayer).stream == null)
	var w := _wav(64, 0.61)
	_refs.append(w)
	var d: WeakRef = weakref(w)
	_debiles.append(d)
	(p as AudioStreamPlayer).stream = w
	w = null
	_refs.clear()
	_check("con stream asignado, el pool lo usa (WeakRef viva)",
		_contar_vivos(_debiles) == 1, "vivos=%d" % _contar_vivos(_debiles))
	pf._estacionar(p)
	_check("_estacionar() (limpieza del pool) deja el reproductor SIN stream",
		(p as AudioStreamPlayer).stream == null)
	_check("al reciclarlo, el stream sale de caché (WeakRef muere)",
		_contar_vivos(_debiles) == 0, "vivos=%d" % _contar_vivos(_debiles))
	var w2 := _wav(64, 0.73)
	_refs.append(w2)
	var d2: WeakRef = weakref(w2)
	_debiles.append(d2)
	(p as AudioStreamPlayer).stream = w2
	w2 = null
	_refs.clear()
	p.free()
	p = null
	pf = null
	_check("al liberar el reproductor, su stream también muere (sin fugas)",
		(d2 as WeakRef).get_ref() == null)
	_debiles.clear()
	_obj_fin = mm.objetos_vivos()
	_check("objetos_vivos fin dentro del margen del engine",
		_obj_fin <= _obj_base + TOL_ENGINE,
		"base=%d fin=%d tol=%d" % [_obj_base, _obj_fin, TOL_ENGINE])
	_fin("E")


## ── Utilidades ───────────────────────────────────────────────────────────

func _mm() -> Node:
	return root.get_node_or_null("MemoryMonitor")


func _preparar_player() -> void:
	if _player == null or not is_instance_valid(_player):
		_player = AudioStreamPlayer.new()
		_player.name = "T69Player"
		root.add_child(_player)


## AudioStreamWAV real del engine (stand-in declarado del .ogg: el repo no tiene
## ningún asset de audio). Genera un seno corto para que el stream tenga datos.
func _wav(muestras: int, fase: float) -> AudioStreamWAV:
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = 22050
	w.stereo = false
	var data := PackedByteArray()
	data.resize(muestras * 2)
	for i in muestras:
		data.encode_s16(i * 2, int(3000.0 * sin(fase + float(i) * 0.2)))
	w.data = data
	return w


## Cuántos de los WeakRef siguen vivos (=> el objeto fue RETENIDO por alguien).
func _contar_vivos(debiles: Array) -> int:
	var vivos := 0
	for w in debiles:
		if (w as WeakRef).get_ref() != null:
			vivos += 1
	return vivos


func _fin(nombre: String) -> void:
	_vistos[nombre] = true


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALL] %s %s" % [nombre, detalle])


## Capa 3: corre SIEMPRE, aunque `_run()` haya abortado por un SCRIPT ERROR.
func _summary() -> void:
	for n in BLOQUES:
		if not _vistos.has(n):
			_checks += 1
			_fallos += 1
			print("[FALL] el bloque %s NO se ejecutó (posible SCRIPT ERROR que abortó la función)" % n)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FALL] solo %d checks ejecutados (mínimo medido en verde: %d)" % [_checks, CHECKS_MINIMOS])
	print("-- streams que sobrevivieron al final: %d" % _vivos_fin)
	print("-- objetos_vivos: base=%d fin=%d (delta=%d, tol=%d)" % [_obj_base, _obj_fin, _obj_fin - _obj_base, TOL_ENGINE])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con código 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — los %d checks pasaron" % [MODULO, _checks])
		quit(0)
