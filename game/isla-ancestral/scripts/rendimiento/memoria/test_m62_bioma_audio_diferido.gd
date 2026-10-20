# Modelo: DS-V4.1-Flash-Opencode
# Plataforma: OpenCode
# Fecha: 2026-10-20
#
# M62: Memoria — Suite de contratación "cambio de bioma de audio: descarga del
# banco anterior diferida 1 frame (no corta transiciones)".
# Cierra por MEDICIÓN el ítem L154 de 62-Memoria plan-actual/05-Checklist.
#
# Qué mide (headless, con el autoload REAL MemoryMonitor):
#   A. Primer banco: entrar a un bioma deja el banco ACTUAL sin pendiente.
#   B. Cambio a→b: el banco anterior queda PENDIENTE y sigue vivo durante el
#      frame del cambio; recién con un frame completo de margen se suelta
#      (WeakRef muere) y se cuenta la liberación diferida.
#   C. Mismo banco: no-op (no duplica pendientes ni liberaciones).
#   D. Dos cambios en el MISMO frame: el banco intermedio se suelta YA (nunca
#      sonó un frame completo); el nuevo anterior queda pendiente.
#   E. RefCounted puro (no Resource): el mecanismo no exige Resource y el
#      ciclo tampoco acumula.
#
# Alcance (honesto): mide el CONTRATO del mecanismo M62 con el autoload real.
# NO cubre al llamador de producción (M42 llamando avisar_cambio_bioma_audio
# desde set_bioma) — ese cableado es deuda de M42 (07-Resultados §12).
#
# Guardián anti-falso-verde de 3 capas (skill §2, trampas 11/28/61/63):
#   1. marcadores `_fin("X")` por bloque -> nombra el bloque que no corrió;
#   2. piso `CHECKS_MINIMOS` medido en verde -> caza el aborto en un helper;
#   3. `_summary()` en un `call_deferred` APARTE, con espera acotada, -> si
#      `_run()` aborta por un SCRIPT ERROR, el resumen igual se imprime.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_m62_bioma_audio_diferido.gd

extends SceneTree

const MODULO := "M62 audio bioma diferido"
const BLOQUES: Array[String] = ["A", "B", "C", "D", "E"]
## Piso MEDIDO en verde (ver 07-Resultados-Testings.md / evidencia T71).
const CHECKS_MINIMOS := 47

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}
var _terminado: bool = false


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	print("=== [M62] Cambio de bioma de audio: banco anterior diferido 1 frame (L154) ===")
	var mm := _mm()
	if mm == null:
		_check("autoload MemoryMonitor presente", false, "mm=null")
		_terminado = true
		return
	_check("autoload MemoryMonitor presente", true)
	_bloque_a(mm)
	await _bloque_b(mm)
	_bloque_c(mm)
	await _bloque_d(mm)
	await _bloque_e(mm)
	_terminado = true


## ── A. Primer banco: sin anterior que diferir ─────────────────────────────
func _bloque_a(mm: Node) -> void:
	print("--- A. Primer banco: actual sin pendiente ---")
	var a := Resource.new()
	a.resource_name = "bioma_a"
	_check("entrar al primer bioma devuelve true",
		mm.avisar_cambio_bioma_audio(a) == true)
	_check("el banco quedó como ACTUAL", mm.audio_banco_actual() == a)
	_check("sin banco PENDIENTE en la primera entrada",
		mm.audio_banco_pendiente() == null)
	_check("sin liberaciones diferidas todavía",
		mm.audio_liberaciones_diferidas() == 0)
	_check("sin último liberado todavía", mm.audio_ultimo_liberado() == "")
	_check("el banco actual es un Resource nombrado",
		a is Resource and (a as Resource).resource_name == "bioma_a")
	_fin("A")


## ── B. Cambio a→b: el anterior sobrevive el frame y muere después ─────────
func _bloque_b(mm: Node) -> void:
	print("--- B. Cambio a->b: el anterior sobrevive el frame y muere después ---")
	var wa: WeakRef = weakref(mm.audio_banco_actual())
	var b := Resource.new()
	b.resource_name = "bioma_b"
	_check("cambiar de bioma devuelve true",
		mm.avisar_cambio_bioma_audio(b) == true)
	_check("el banco nuevo quedó como ACTUAL", mm.audio_banco_actual() == b)
	_check("el banco anterior quedó PENDIENTE", _pendiente_es(mm, wa))
	_check("el banco anterior sigue VIVO en el frame del cambio", _vivo(wa))
	_check("la liberación NO se contó todavía",
		mm.audio_liberaciones_diferidas() == 0)
	_check("no hay último liberado todavía", mm.audio_ultimo_liberado() == "")
	await _esperar(1)
	_check("tras 1 límite de frame el anterior sigue VIVO", _vivo(wa))
	var solto: bool = await _esperar_hasta(mm, 8)
	_check("el banco anterior se soltó con el frame de margen", solto)
	_check("tras el margen, el anterior MURIÓ (WeakRef)", not _vivo(wa))
	_check("la liberación diferida se contó", mm.audio_liberaciones_diferidas() == 1)
	_check("ya no queda banco PENDIENTE", mm.audio_banco_pendiente() == null)
	_check("el último liberado es el banco anterior",
		mm.audio_ultimo_liberado() == "bioma_a")
	_check("el ACTUAL sigue siendo el banco nuevo", mm.audio_banco_actual() == b)
	b = null
	_fin("B")


## ── C. Mismo banco: no-op ─────────────────────────────────────────────────
func _bloque_c(mm: Node) -> void:
	print("--- C. Mismo banco: no-op ---")
	_check("repetir el mismo banco devuelve false",
		mm.avisar_cambio_bioma_audio(mm.audio_banco_actual()) == false)
	_check("no apareció un PENDIENTE espurio", mm.audio_banco_pendiente() == null)
	_check("no se contó una liberación espuria",
		mm.audio_liberaciones_diferidas() == 1)
	_fin("C")


## ── D. Dos cambios en el mismo frame: el intermedio no se acumula ─────────
func _bloque_d(mm: Node) -> void:
	print("--- D. Dos cambios en el mismo frame: el intermedio se suelta YA ---")
	var wb: WeakRef = weakref(mm.audio_banco_actual())
	var c := Resource.new()
	c.resource_name = "bioma_c"
	var wc: WeakRef = weakref(c)
	var d := Resource.new()
	d.resource_name = "bioma_d"
	_check("primer cambio del frame devuelve true",
		mm.avisar_cambio_bioma_audio(c) == true)
	_check("el anterior inmediato quedó PENDIENTE", _pendiente_es(mm, wb))
	_check("ese anterior sigue VIVO tras el primer cambio", _vivo(wb))
	_check("segundo cambio del frame devuelve true",
		mm.avisar_cambio_bioma_audio(d) == true)
	_check("el intermedio se soltó YA (2 liberaciones)",
		mm.audio_liberaciones_diferidas() == 2)
	_check("el banco del primer cambio MURIÓ al segundo cambio", not _vivo(wb))
	_check("el segundo banco quedó PENDIENTE", _pendiente_es(mm, wc))
	_check("el ACTUAL es el tercer banco", mm.audio_banco_actual() == d)
	c = null
	var solto_c: bool = await _esperar_hasta(mm, 8)
	_check("el segundo banco se soltó con el frame de margen", solto_c)
	_check("tras el margen, el segundo banco MURIÓ (WeakRef)", not _vivo(wc))
	_check("la liberación diferida se contó (3)",
		mm.audio_liberaciones_diferidas() == 3)
	_check("no queda banco PENDIENTE", mm.audio_banco_pendiente() == null)
	_check("el ACTUAL sigue siendo el tercer banco", mm.audio_banco_actual() == d)
	d = null
	_fin("D")


## ── E. RefCounted puro: no exige Resource y no acumula ────────────────────
func _bloque_e(mm: Node) -> void:
	print("--- E. RefCounted puro: ciclo sin acumulación ---")
	var wd: WeakRef = weakref(mm.audio_banco_actual())
	var e := RefCounted.new()
	var we: WeakRef = weakref(e)
	var f := RefCounted.new()
	_check("acepta un RefCounted puro (no Resource)",
		mm.avisar_cambio_bioma_audio(e) == true)
	_check("el anterior quedó PENDIENTE", _pendiente_es(mm, wd))
	_check("segundo cambio con RefCounted puro devuelve true",
		mm.avisar_cambio_bioma_audio(f) == true)
	_check("el anterior se soltó YA (4 liberaciones)",
		mm.audio_liberaciones_diferidas() == 4)
	_check("el banco anterior MURIÓ al segundo cambio", not _vivo(wd))
	_check("el RefCounted intermedio quedó PENDIENTE", _pendiente_es(mm, we))
	e = null
	var solto_e: bool = await _esperar_hasta(mm, 8)
	_check("el RefCounted intermedio se soltó con el frame de margen", solto_e)
	_check("tras el margen, el RefCounted intermedio MURIÓ", not _vivo(we))
	_check("la liberación diferida se contó (5)",
		mm.audio_liberaciones_diferidas() == 5)
	_check("no queda banco PENDIENTE", mm.audio_banco_pendiente() == null)
	_check("el ACTUAL es el último RefCounted", mm.audio_banco_actual() == f)
	f = null
	_fin("E")


## ── Utilidades ───────────────────────────────────────────────────────────

func _mm() -> Node:
	return root.get_node_or_null("MemoryMonitor")


func _esperar(n: int) -> void:
	for i in range(n):
		await process_frame


## Espera acotada hasta que no quede banco pendiente (máx `max_frames`).
func _esperar_hasta(mm: Node, max_frames: int) -> bool:
	for i in range(max_frames):
		if mm.audio_banco_pendiente() == null:
			return true
		await process_frame
	return mm.audio_banco_pendiente() == null


func _vivo(w: WeakRef) -> bool:
	var r: RefCounted = w.get_ref()
	return r != null


func _pendiente_es(mm: Node, w: WeakRef) -> bool:
	var r: RefCounted = w.get_ref()
	return r != null and mm.audio_banco_pendiente() == r


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
	var espera := 0
	while not _terminado and espera < 600:
		await process_frame
		espera += 1
	if not _terminado:
		_checks += 1
		_fallos += 1
		print("[FALL] _run() no terminó (posible SCRIPT ERROR o deadlock)")
	for n in BLOQUES:
		if not _vistos.has(n):
			_checks += 1
			_fallos += 1
			print("[FALL] el bloque %s NO se ejecutó (posible SCRIPT ERROR que abortó la función)" % n)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FALL] solo %d checks ejecutados (mínimo medido en verde: %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con código 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — los %d checks pasaron" % [MODULO, _checks])
		quit(0)
