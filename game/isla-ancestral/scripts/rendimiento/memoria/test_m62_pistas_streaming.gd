# Modelo: DS-V4.1-Flash-Opencode
# Plataforma: OpenCode
# Fecha: 2026-10-19
#
# M62: Memoria — Suite de contratación "pistas largas (música M41, ASMR M44)
# reproducidas por streaming, no en RAM completa".
# Cierra por MEDICIÓN el ítem L150 de 62-Memoria plan-actual/05-Checklist:
#   "Pistas largas (música M41, ASMR M44) reproducidas por streaming, no en
#    RAM completa [C]"
#
# Qué mide (headless, con el autoload REAL MemoryMonitor):
#   A. STREAMING de una pista larga (M41): mientras la pista está EN descarga
#      (streaming), pedirla se DIFIERE ("no se reproduce a medias"); al
#      terminar la descarga se reproduce. Pedirla varias veces durante la
#      descarga NO duplica el registro (idempotente por nombre).
#   B. NO EN RAM COMPLETA: la pista larga (60 MB) se encola como candidata de
#      descarga y el cambio de región la libera: WeakRef 0 vivos y el lote
#      reporta su peso SIN retener el recurso (el lote es solo {peso,dist,edad}).
#   C. Música + ASMR (M41+M44) en streaming SIMULTÁNEO: ambas se difieren;
#      terminar una la vuelve reproducible SIN afectar a la otra; al salir de
#      la región las dos se descargan en un solo lote.
#   D. Ciclo x3 de regiones con pistas largas: sin acumulación — la cola vuelve
#      a 0, las forzadas se cuentan, las pistas mueren (WeakRef) y
#      objetos_vivos no crece.
#   E. Orden de drenaje por lejanía (9,5,2) y pesos en el lote (60 MB primero).
#
# Alcance (honesto): mide el CONTRATO del mecanismo M62 con su autoload real;
# NO cubre a los reproductores de producción de M41 (MusicDirector) ni M44
# (FeedbackDirector): hoy son directores de LÓGICA (matriz de temas / recetas de
# feedback) sin AudioStreamPlayer propio y sin llamar al handshake de audio del
# 62 — ese cableado pertenece a M41/M44 (ver auditoría de cableado en
# 62-Memoria plan-actual/07-Resultados-Testings.md §12). Mismo criterio que los
# cierres previos de M62 (L137/139/140/141/142/143/149).
#
# Guardián anti-falso-verde de 3 capas (skill §2, trampas 11/28/61/63):
#   1. marcadores `_fin("X")` por bloque -> nombra el bloque que no corrió;
#   2. piso `CHECKS_MINIMOS` medido en verde -> caza el aborto en un helper;
#   3. `_summary()` en un `call_deferred` APARTE -> si `_run()` aborta por un
#      SCRIPT ERROR, la cola diferida sigue y el resumen igual se imprime.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_m62_pistas_streaming.gd

extends SceneTree

const MODULO := "M62 pistas streaming"
const BLOQUES: Array[String] = ["A", "B", "C", "D", "E"]
## Piso MEDIDO en verde (ver 07-Resultados-Testings.md / evidencia T68).
const CHECKS_MINIMOS := 57

const PESO_MUSICA_MB := 60
const PESO_ASMR_MB := 24
const PESO_AMBIENTE_MB := 12

const PISTA_MUSICA := "t68_musica_larga"
const PISTA_OTRA := "t68_sfx_corto"
const PISTA_MUSICA_C := "t68_musica"
const PISTA_ASMR := "t68_asmr"

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}

# Referencias del test (se sueltan para las pruebas WeakRef).
var _pistas: Array = []
var _debiles: Array[WeakRef] = []

# Deltas base capturados por bloque.
var _obj_base: int = -1
var _forz_b0: int = -1
var _camb_b0: int = -1
var _forz_c0: int = -1
var _camb_c0: int = -1
var _dif_c0: int = -1
var _forz_d0: int = -1
var _camb_d0: int = -1
var _dif_d0: int = -1
var _forz_e0: int = -1

# Diagnóstico (se imprime en el resumen, para auditar sin re-correr).
var _obj_fin: int = -1
var _vivos_fin: int = -1


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	print("=== [M62] Pistas largas (música M41, ASMR M44) por streaming, no en RAM completa (L150) ===")
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


## ── A. Pista larga en streaming: diferida mientras descarga ────────────────
func _bloque_a() -> void:
	print("--- A. Pista larga (M41) en streaming: diferida mientras descarga, reproducible después ---")
	var mm := _mm()
	# Drenaje inicial: el arranque del juego puede haber dejado candidatos.
	mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	_check("la cola de descarga de M62 arranca drenada",
		mm.unload.candidatos_count() == 0, "n=%d" % mm.unload.candidatos_count())
	_obj_base = mm.objetos_vivos()
	# La pista larga ENTRA EN STREAMING (descarga en curso).
	mm.iniciar_descarga_audio(PISTA_MUSICA)
	_check("la pista larga queda EN descarga mientras se estaciona",
		mm.descargando_audio(PISTA_MUSICA) == true)
	_check("pedir la pista durante la descarga se DIFIERE (no se reproduce a medias)",
		mm.pedir_banco_audio(PISTA_MUSICA) == "diferido")
	_check("el diferido quedó contado", mm.audio_diferido_count() == 1,
		"n=%d" % mm.audio_diferido_count())
	_check("el diferido quedó registrado con su nombre",
		mm.bancos_audio_diferidos() == [PISTA_MUSICA], str(mm.bancos_audio_diferidos()))
	_check("pedirla de nuevo durante la descarga sigue diferido",
		mm.pedir_banco_audio(PISTA_MUSICA) == "diferido")
	_check("el diferido NO se duplica por nombre (contador sigue 1)",
		mm.audio_diferido_count() == 1, "n=%d" % mm.audio_diferido_count())
	mm.terminar_descarga_audio(PISTA_MUSICA)
	_check("terminada la descarga, la pista ya no está en descarga",
		mm.descargando_audio(PISTA_MUSICA) == false)
	_check("terminada la descarga, la pista se REPRODUCE (stream listo)",
		mm.pedir_banco_audio(PISTA_MUSICA) == "reproducir")
	_check("una pista sin descarga se reproduce directo",
		mm.pedir_banco_audio(PISTA_OTRA) == "reproducir")
	_fin("A")


## ── B. No en RAM completa: la pista larga se descarga ──────────────────────
func _bloque_b() -> void:
	print("--- B. No en RAM completa: la pista larga se descarga con su peso ---")
	var mm := _mm()
	_forz_b0 = mm.liberaciones_forzadas()
	_camb_b0 = mm.cambios_region()
	var pista := Resource.new()
	pista.resource_name = PISTA_MUSICA + "/banco"
	_pistas.append(pista)
	_debiles.append(weakref(pista))
	mm.registrar_candidato_descarga(pista, PESO_MUSICA_MB, 8.0)
	_check("la pista larga queda encolada con su peso",
		mm.unload.candidatos_count() == 1, "n=%d" % mm.unload.candidatos_count())
	var orden: Array = mm.unload.previsualizar_orden()
	var o0: Dictionary = orden[0] if orden.size() > 0 else {}
	_check("peso y distancia de la pista en la cola",
		int(o0.get("peso", -1)) == PESO_MUSICA_MB and float(o0.get("distancia", -1.0)) == 8.0,
		str(o0))
	var forzo: bool = mm.avisar_cambio_region("t68_reg_b")
	_check("salir de la región FUERZA la descarga de la pista", forzo == true)
	_check("la pista dejó de estar en cola", mm.unload.candidatos_count() == 0,
		"n=%d" % mm.unload.candidatos_count())
	_check("la pista salió en UN lote", mm.unload.ultimo_lote_count() == 1,
		"n=%d" % mm.unload.ultimo_lote_count())
	_check("el lote reporta los 60 MB de la pista",
		String(mm.unload.resumen_ultimo_lote()).begins_with("60 MB"),
		mm.unload.resumen_ultimo_lote())
	_check("la liberación forzada quedó contada",
		mm.liberaciones_forzadas() == _forz_b0 + 1,
		"f=%d base=%d" % [mm.liberaciones_forzadas(), _forz_b0])
	_check("el cambio de región quedó contado",
		mm.cambios_region() == _camb_b0 + 1,
		"%d vs base+1=%d" % [mm.cambios_region(), _camb_b0 + 1])
	# Prueba fuerte del ítem L150: la pista no queda retenida en RAM.
	pista = null
	_pistas.clear()
	var vivos: int = _contar_vivos(_debiles)
	_debiles.clear()
	_check("la pista NO sobrevive al drenaje (WeakRef; el lote no la retiene)",
		vivos == 0, "vivos=%d" % vivos)
	_check("objetos_vivos estable tras descargar la pista",
		mm.objetos_vivos() <= _obj_base, "base=%d fin=%d" % [_obj_base, mm.objetos_vivos()])
	_fin("B")


## ── C. Música + ASMR simultáneas en streaming ─────────────────────────────
func _bloque_c() -> void:
	print("--- C. Música (M41) y ASMR (M44) simultáneas: cada una termina por su lado ---")
	var mm := _mm()
	_forz_c0 = mm.liberaciones_forzadas()
	_camb_c0 = mm.cambios_region()
	_dif_c0 = mm.audio_diferido_count()
	mm.iniciar_descarga_audio(PISTA_MUSICA_C)
	mm.iniciar_descarga_audio(PISTA_ASMR)
	_check("música queda EN descarga", mm.descargando_audio(PISTA_MUSICA_C) == true)
	_check("ASMR queda EN descarga", mm.descargando_audio(PISTA_ASMR) == true)
	_check("pedir música durante su descarga -> diferido",
		mm.pedir_banco_audio(PISTA_MUSICA_C) == "diferido")
	_check("pedir ASMR durante su descarga -> diferido",
		mm.pedir_banco_audio(PISTA_ASMR) == "diferido")
	_check("los 2 diferidos se suman al registro",
		mm.audio_diferido_count() == _dif_c0 + 2,
		"n=%d base+2=%d" % [mm.audio_diferido_count(), _dif_c0 + 2])
	mm.terminar_descarga_audio(PISTA_MUSICA_C)
	_check("música ya no está en descarga", mm.descargando_audio(PISTA_MUSICA_C) == false)
	_check("música se REPRODUCE al terminar su descarga",
		mm.pedir_banco_audio(PISTA_MUSICA_C) == "reproducir")
	_check("ASMR SIGUE diferido (su descarga no terminó)",
		mm.pedir_banco_audio(PISTA_ASMR) == "diferido")
	mm.terminar_descarga_audio(PISTA_ASMR)
	_check("ASMR ya no está en descarga", mm.descargando_audio(PISTA_ASMR) == false)
	_check("ASMR se REPRODUCE al terminar su descarga",
		mm.pedir_banco_audio(PISTA_ASMR) == "reproducir")
	# Salir de la región: ambas pistas quedan atrás como candidatas.
	var p_musica := Resource.new()
	p_musica.resource_name = PISTA_MUSICA_C + "/banco"
	var p_asmr := Resource.new()
	p_asmr.resource_name = PISTA_ASMR + "/banco"
	_pistas.append(p_musica)
	_pistas.append(p_asmr)
	_debiles.append(weakref(p_musica))
	_debiles.append(weakref(p_asmr))
	mm.registrar_candidato_descarga(p_musica, PESO_MUSICA_MB, 6.0)
	mm.registrar_candidato_descarga(p_asmr, PESO_ASMR_MB, 2.0)
	_check("música y ASMR quedan encoladas como candidatas",
		mm.unload.candidatos_count() == 2, "n=%d" % mm.unload.candidatos_count())
	var forzo: bool = mm.avisar_cambio_region("t68_reg_c")
	_check("el cambio de región FUERZA el drenaje de ambas", forzo == true)
	_check("la cola quedó VACÍA", mm.unload.candidatos_count() == 0,
		"n=%d" % mm.unload.candidatos_count())
	_check("las 2 pistas salieron en UN lote", mm.unload.ultimo_lote_count() == 2,
		"n=%d" % mm.unload.ultimo_lote_count())
	_check("el resumen empieza por la pista más lejana (60 MB)",
		String(mm.unload.resumen_ultimo_lote()).begins_with("60 MB"),
		mm.unload.resumen_ultimo_lote())
	_check("una sola liberación forzada por el cambio (no una por pista)",
		mm.liberaciones_forzadas() == _forz_c0 + 1,
		"f=%d base+1=%d" % [mm.liberaciones_forzadas(), _forz_c0 + 1])
	p_musica = null
	p_asmr = null
	_pistas.clear()
	var vivos: int = _contar_vivos(_debiles)
	_debiles.clear()
	_check("ninguna pista de música/ASMR sobrevive (WeakRef)", vivos == 0,
		"vivos=%d" % vivos)
	_fin("C")


## ── D. Ciclo x3 de regiones con pistas largas ─────────────────────────────
func _bloque_d() -> void:
	print("--- D. Ciclo x3 de regiones con pistas largas: sin acumulación ---")
	var mm := _mm()
	_forz_d0 = mm.liberaciones_forzadas()
	_camb_d0 = mm.cambios_region()
	_dif_d0 = mm.audio_diferido_count()
	var todas_dif := true
	var todas_rep := true
	var todos_forz := true
	for i in 3:
		var nombre := "t68_viaje_%d" % i
		var p := Resource.new()
		p.resource_name = nombre + "/pista"
		_pistas.append(p)
		_debiles.append(weakref(p))
		# Streaming de la pista del viaje (M41/M44 estacionando el tema).
		mm.iniciar_descarga_audio(nombre)
		if mm.pedir_banco_audio(nombre) != "diferido":
			todas_dif = false
		mm.terminar_descarga_audio(nombre)
		if mm.pedir_banco_audio(nombre) != "reproducir":
			todas_rep = false
		# Al dejar la región, la pista queda como candidata y el viaje la descarga.
		mm.registrar_candidato_descarga(p, PESO_MUSICA_MB, float(10 - i))
		if mm.avisar_cambio_region(nombre) != true:
			todos_forz = false
		p = null
	_check("las 3 pistas se difieren durante su descarga", todas_dif)
	_check("las 3 pistas se reproducen al terminar su descarga", todas_rep)
	_check("los 3 viajes fuerzan la descarga de la pista anterior", todos_forz)
	_check("la cola volvió a 0 en el último viaje",
		mm.unload.candidatos_count() == 0, "n=%d" % mm.unload.candidatos_count())
	_check("3 liberaciones forzadas más", mm.liberaciones_forzadas() == _forz_d0 + 3,
		"f=%d base+3=%d" % [mm.liberaciones_forzadas(), _forz_d0 + 3])
	_check("3 cambios de región más", mm.cambios_region() == _camb_d0 + 3,
		"%d vs %d" % [mm.cambios_region(), _camb_d0 + 3])
	_check("el registro de diferidos suma las 3 pistas del ciclo (no se pierde)",
		mm.audio_diferido_count() == _dif_d0 + 3,
		"n=%d base+3=%d" % [mm.audio_diferido_count(), _dif_d0 + 3])
	_check("la pista de la región actual sigue reproducible",
		mm.pedir_banco_audio("t68_viaje_2") == "reproducir")
	_pistas.clear()
	var vivos: int = _contar_vivos(_debiles)
	_debiles.clear()
	_check("ninguna pista de los viajes sobrevive (WeakRef)", vivos == 0,
		"vivos=%d" % vivos)
	_check("objetos_vivos() estable tras 3 viajes (fin <= base)",
		mm.objetos_vivos() <= _obj_base,
		"base=%d fin=%d" % [_obj_base, mm.objetos_vivos()])
	_fin("D")


## ── E. Orden por lejanía y pesos de pistas en el lote ──────────────────────
func _bloque_e() -> void:
	print("--- E. Orden de drenaje por lejanía + pesos en el lote ---")
	var mm := _mm()
	_forz_e0 = mm.liberaciones_forzadas()
	var pesos: Array[int] = [PESO_MUSICA_MB, PESO_AMBIENTE_MB, PESO_ASMR_MB]
	var dists: Array[float] = [9.0, 5.0, 2.0]
	for i in 3:
		var pista := Resource.new()
		pista.resource_name = "t68_fin%d/pista" % i
		_pistas.append(pista)
		_debiles.append(weakref(pista))
		mm.registrar_candidato_descarga(pista, pesos[i], dists[i])
	_check("las 3 pistas finales quedaron encoladas",
		mm.unload.candidatos_count() == 3, "n=%d" % mm.unload.candidatos_count())
	var orden: Array = mm.unload.previsualizar_orden()
	var dists_orden: Array = []
	for o in orden:
		dists_orden.append(int(float(o.get("distancia", -1.0))))
	_check("el orden de drenaje es por lejanía (9,5,2)", dists_orden == [9, 5, 2],
		str(dists_orden))
	var forzo: bool = mm.avisar_cambio_region("t68_final")
	_check("el cambio final fuerza el drenaje de las 3", forzo == true)
	_check("la cola quedó VACÍA", mm.unload.candidatos_count() == 0,
		"n=%d" % mm.unload.candidatos_count())
	_check("las 3 pistas salieron en UN lote", mm.unload.ultimo_lote_count() == 3,
		"n=%d" % mm.unload.ultimo_lote_count())
	_check("el resumen empieza por la pista más lejana (60 MB)",
		String(mm.unload.resumen_ultimo_lote()).begins_with("60 MB"),
		mm.unload.resumen_ultimo_lote())
	_check("una sola liberación forzada por el cambio (no una por pista)",
		mm.liberaciones_forzadas() == _forz_e0 + 1,
		"f=%d base+1=%d" % [mm.liberaciones_forzadas(), _forz_e0 + 1])
	_pistas.clear()
	var vivos: int = _contar_vivos(_debiles)
	_debiles.clear()
	_vivos_fin = vivos
	_check("ninguna de las 3 pistas finales sobrevive (WeakRef) con el lote reportado",
		vivos == 0, "vivos=%d" % vivos)
	_obj_fin = mm.objetos_vivos()
	_check("objetos_vivos() fin <= base en el cierre total",
		_obj_fin <= _obj_base,
		"base=%d fin=%d delta=%d" % [_obj_base, _obj_fin, _obj_fin - _obj_base])
	_fin("E")


## ── Utilidades ───────────────────────────────────────────────────────────

func _mm() -> Node:
	return root.get_node_or_null("MemoryMonitor")


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
	print("-- pistas que sobrevivieron al final: %d" % _vivos_fin)
	print("-- objetos_vivos: base=%d fin=%d (delta=%d)" % [_obj_base, _obj_fin, _obj_fin - _obj_base])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con código 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — los %d checks pasaron" % [MODULO, _checks])
		quit(0)
