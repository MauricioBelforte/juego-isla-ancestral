# Modelo: DS-V4.1-Flash-Opencode
# Plataforma: OpenCode
# Fecha: 2026-10-19
#
# M62: Memoria — Suite de contratación "bancos de audio por bioma (M42):
# cargados al entrar y descargados al salir de la región".
# Cierra por MEDICIÓN el ítem L149 de 62-Memoria plan-actual/05-Checklist:
#   "Bancos de audio por bioma (M42) cargados al entrar y descargados al salir
#    de la región [M]"
#
# Qué mide (headless, con el autoload REAL MemoryMonitor):
#   A. ENTRAR al bioma: el banco del bioma se pide y se reproduce
#      (pedir_banco_audio == "reproducir"); sin descargas ni diferidos.
#   B. SALIR de la región: el banco del bioma viejo se encola como candidato y
#      el cambio de región FUERZA su descarga (avisar_cambio_region == true);
#      prueba fuerte con WeakRef: el banco NO sobrevive (queda sin retención).
#   C. Banco EN CARGA: el cambio de región lo VETA (no corta la carga en
#      curso), queda en cola; al terminar la carga, el siguiente cambio lo
#      descarga. La salida de región no rompe el banco que suena.
#   D. Ciclo entrar/salir x3 (viajes): sin acumulación — la cola vuelve a 0,
#      las liberaciones forzadas se cuentan, los viajeros mueren (WeakRef) y
#      objetos_vivos no crece.
#   E. Orden de drenaje de bancos viajeros por lejanía (distancia desc) y peso
#      del banco en el lote (resumen_ultimo_lote).
#
# Alcance (honesto): mide el CONTRATO del mecanismo M62 con su autoload real;
# NO cubre al llamador de producción (M42 avisando entrar/salir de bioma desde
# set_bioma/ambiente_cambiado) — ese cableado pertenece a M42 (ver auditoría de
# cableado en 62-Memoria plan-actual/07-Resultados-Testings.md §12, 2026-10-17).
#
# Guardián anti-falso-verde de 3 capas (skill §2, trampas 11/28/61/63):
#   1. marcadores `_fin("X")` por bloque -> nombra el bloque que no corrió;
#   2. piso `CHECKS_MINIMOS` medido en verde -> caza el aborto en un helper;
#   3. `_summary()` en un `call_deferred` APARTE -> si `_run()` aborta por un
#      SCRIPT ERROR, la cola diferida sigue y el resumen igual se imprime.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_m62_audio_bioma.gd

extends SceneTree

const MODULO := "M62 audio bioma"
const BLOQUES: Array[String] = ["A", "B", "C", "D", "E"]
## Piso MEDIDO en verde (ver 07-Resultados-Testings.md / evidencia T67).
const CHECKS_MINIMOS := 45

const PESO_BANCO_MB := 48
const PESO_BANCO_COSTA_MB := 32
const PESO_BANCO_CHICO_MB := 16

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}

# Referencias del test (se sueltan para las pruebas WeakRef).
var _bancos: Array = []
var _debiles: Array[WeakRef] = []

# Deltas base capturados por bloque.
var _obj_base: int = -1
var _forz_a: int = -1
var _camb_a: int = -1
var _forz_b: int = -1
var _camb_b: int = -1
var _forz_c: int = -1
var _camb_c: int = -1
var _forz_d: int = -1

# Diagnóstico (se imprime en el resumen, para auditar sin re-correr).
var _obj_fin: int = -1
var _vivos_fin: int = -1


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	print("=== [M62] Bancos de audio por bioma: entran al bioma, salen de la región (L149) ===")
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


## ── A. Entrar al bioma: el banco se reproduce ─────────────────────────────
func _bloque_a() -> void:
	print("--- A. Entrar al bioma: el banco se reproduce ---")
	var mm := _mm()
	# Drenaje inicial: el arranque del juego puede haber dejado candidatos.
	mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	_check("la cola de descarga de M62 arranca drenada",
		mm.unload.candidatos_count() == 0, "n=%d" % mm.unload.candidatos_count())
	_obj_base = mm.objetos_vivos()
	# ENTRAR al bioma selva: la región queda registrada sin pendientes.
	var forzo: bool = mm.avisar_cambio_region("t67_selva")
	_check("entrar a la región sin pendientes no fuerza nada", forzo == false)
	_check("la región actual quedó registrada", mm.region_actual() == "t67_selva",
		"region=%s" % mm.region_actual())
	_check("el banco del bioma ENTRA reproducible (pedir_banco_audio)",
		mm.pedir_banco_audio("t67_selva") == "reproducir")
	_check("sin descarga declarada del banco", mm.descargando_audio("t67_selva") == false)
	_check("sin bancos diferidos al entrar", mm.audio_diferido_count() == 0)
	_check("entrar no deja candidatos de descarga", mm.unload.candidatos_count() == 0,
		"n=%d" % mm.unload.candidatos_count())
	# Snapshots POST-A (el aviso de ENTRAR ya contó su cambio de región).
	_forz_a = mm.liberaciones_forzadas()
	_camb_a = mm.cambios_region()
	_fin("A")


## ── B. Salir de la región: el banco del bioma viejo se descarga ───────────
func _bloque_b() -> void:
	print("--- B. Salir de la región: el banco del bioma viejo se descarga ---")
	var mm := _mm()
	var banco_selva := Resource.new()
	banco_selva.resource_name = "t67_selva/banco"
	_bancos.append(banco_selva)
	_debiles.append(weakref(banco_selva))
	# El banco que queda atrás se encola como candidato (viaje de bioma).
	mm.registrar_candidato_descarga(banco_selva, PESO_BANCO_MB, 3.0)
	_check("el banco que sale queda encolado como candidato",
		mm.unload.candidatos_count() == 1, "n=%d" % mm.unload.candidatos_count())
	# ENTRAR al bioma nuevo: su banco se reproduce.
	_check("el banco del bioma nuevo se reproduce (t67_costa)",
		mm.pedir_banco_audio("t67_costa") == "reproducir")
	# SALIR: el cambio de región fuerza el drenaje del viajero pendiente.
	var forzo: bool = mm.avisar_cambio_region("t67_costa")
	_check("salir de la región FUERZA la descarga del banco pendiente", forzo == true)
	_check("la cola quedó VACÍA (banco descargado)", mm.unload.candidatos_count() == 0,
		"n=%d" % mm.unload.candidatos_count())
	_check("la liberación forzada quedó contada",
		mm.liberaciones_forzadas() == _forz_a + 1,
		"f=%d base=%d" % [mm.liberaciones_forzadas(), _forz_a])
	_check("el cambio de región quedó contado",
		mm.cambios_region() == _camb_a + 1,
		"%d vs base+1=%d" % [mm.cambios_region(), _camb_a + 1])
	# Prueba fuerte del ítem L149: el banco viejo no sobrevive.
	# (Soltar TODO lo que lo retiene: la var local y el array del test.)
	banco_selva = null
	_bancos.clear()
	var vivos: int = _contar_vivos(_debiles)
	_debiles.clear()
	_vivos_fin = vivos
	_check("NINGÚN banco del bioma viejo sobrevive al salir (WeakRef) (L149)",
		vivos == 0, "vivos=%d" % vivos)
	_check("objetos_vivos() no creció con entrar+salir (fin <= base)",
		mm.objetos_vivos() <= _obj_base,
		"base=%d fin=%d" % [_obj_base, mm.objetos_vivos()])
	_forz_b = mm.liberaciones_forzadas()
	_camb_b = mm.cambios_region()
	_fin("B")


## ── C. Banco EN CARGA: el cambio de región NO lo corta ────────────────────
func _bloque_c() -> void:
	print("--- C. Banco en carga: el cambio no lo corta, drena al terminar ---")
	var mm := _mm()
	var banco_costa := Resource.new()
	banco_costa.resource_name = "t67_costa/banco"
	_bancos.append(banco_costa)
	_debiles.append(weakref(banco_costa))
	var desc_base: int = mm.descartes_por_carga()
	mm.avisar_carga_iniciada(banco_costa)
	_check("el banco en uso queda declarado EN CARGA",
		mm.recursos_en_carga() == 1, "n=%d" % mm.recursos_en_carga())
	mm.registrar_candidato_descarga(banco_costa, PESO_BANCO_COSTA_MB, 2.0)
	_check("el banco en carga quedó encolado (reposición pendiente)",
		mm.unload.candidatos_count() == 1, "n=%d" % mm.unload.candidatos_count())
	var forzo: bool = mm.avisar_cambio_region("t67_pradera")
	_check("en carga, el cambio de región NO descarga el banco (veto)", forzo == false)
	_check("el veto quedó contado (descartes_por_carga)",
		mm.descartes_por_carga() == desc_base + 1,
		"d=%d base=%d" % [mm.descartes_por_carga(), desc_base])
	_check("el candidato NO se pierde: sigue en cola",
		mm.unload.candidatos_count() == 1, "n=%d" % mm.unload.candidatos_count())
	_check("el cambio quedó contado igual",
		mm.cambios_region() == _camb_b + 1,
		"%d vs %d" % [mm.cambios_region(), _camb_b + 1])
	# La carga termina: el siguiente cambio sí lo descarga.
	mm.avisar_carga_terminada(banco_costa)
	_check("terminada la carga, ya no está en carga", mm.recursos_en_carga() == 0)
	var forzo2: bool = mm.avisar_cambio_region("t67_playa")
	_check("terminada la carga, el cambio sí lo descarga", forzo2 == true)
	_check("la cola quedó VACÍA", mm.unload.candidatos_count() == 0,
		"n=%d" % mm.unload.candidatos_count())
	_check("la forzada se contó", mm.liberaciones_forzadas() == _forz_b + 1,
		"f=%d base=%d" % [mm.liberaciones_forzadas(), _forz_b])
	_bancos.erase(banco_costa)
	banco_costa = null
	var vivos: int = _contar_vivos(_debiles)
	_debiles.clear()
	_check("el banco en carga tampoco sobrevive (WeakRef)", vivos == 0, "vivos=%d" % vivos)
	_forz_c = mm.liberaciones_forzadas()
	_camb_c = mm.cambios_region()
	_fin("C")


## ── D. Ciclo entrar/salir x3 (viajes): sin acumulación ────────────────────
func _bloque_d() -> void:
	print("--- D. Ciclo entrar/salir x3: sin acumulación de bancos ---")
	var mm := _mm()
	var forzo_entrar: bool = mm.avisar_cambio_region("t67_r0")
	_check("entrar a la primera región del viaje no fuerza nada", forzo_entrar == false)
	var bancos: Array = []
	for i in range(4):
		var banco := Resource.new()
		banco.resource_name = "t67_r%d/banco" % i
		bancos.append(banco)
		_bancos.append(banco)
		_debiles.append(weakref(banco))
	var todos_reproducen := true
	var todos_fuerzan := true
	for i in range(1, 4):
		# Se viaja: el banco de la región anterior queda atrás como candidato.
		mm.registrar_candidato_descarga(bancos[i - 1], PESO_BANCO_MB, float(i))
		# Y el nuevo bioma entra reproducible.
		if mm.pedir_banco_audio("t67_r%d" % i) != "reproducir":
			todos_reproducen = false
		# El cambio de región descarga el que quedó atrás.
		if mm.avisar_cambio_region("t67_r%d" % i) != true:
			todos_fuerzan = false
	_check("los 3 bancos nuevos hacen entrada reproducible", todos_reproducen)
	_check("los 3 viajes fuerzan la descarga del banco anterior", todos_fuerzan)
	_check("la cola volvió a 0 en el último viaje",
		mm.unload.candidatos_count() == 0, "n=%d" % mm.unload.candidatos_count())
	_check("3 liberaciones forzadas más", mm.liberaciones_forzadas() == _forz_c + 3,
		"f=%d base+3=%d" % [mm.liberaciones_forzadas(), _forz_c + 3])
	_check("4 cambios de región más (r0 sin pendientes + 3 viajes)",
		mm.cambios_region() == _camb_c + 4,
		"%d vs %d" % [mm.cambios_region(), _camb_c + 4])
	_check("el banco de la región actual sigue reproducible",
		mm.pedir_banco_audio("t67_r3") == "reproducir")
	bancos.clear()
	_bancos.clear()
	var vivos: int = _contar_vivos(_debiles)
	_debiles.clear()
	_check("ningún banco de los viajes sobrevive (WeakRef)", vivos == 0, "vivos=%d" % vivos)
	_check("objetos_vivos() estable tras 3 viajes (fin <= base)",
		mm.objetos_vivos() <= _obj_base,
		"base=%d fin=%d" % [_obj_base, mm.objetos_vivos()])
	_forz_d = mm.liberaciones_forzadas()
	_fin("D")


## ── E. Orden por lejanía y peso del banco en el lote ──────────────────────
func _bloque_e() -> void:
	print("--- E. Orden de drenaje por lejanía + peso en el lote ---")
	var mm := _mm()
	var pesos: Array[int] = [PESO_BANCO_MB, PESO_BANCO_COSTA_MB, PESO_BANCO_CHICO_MB]
	var dists: Array[float] = [5.0, 1.0, 3.0]
	for i in 3:
		var banco := Resource.new()
		banco.resource_name = "t67_fin%d/banco" % i
		_bancos.append(banco)
		_debiles.append(weakref(banco))
		mm.registrar_candidato_descarga(banco, pesos[i], dists[i])
	_check("los 3 bancos finales quedaron encolados",
		mm.unload.candidatos_count() == 3, "n=%d" % mm.unload.candidatos_count())
	var orden: Array = mm.unload.previsualizar_orden()
	var dists_orden: Array = []
	for o in orden:
		dists_orden.append(int(float(o.get("distancia", -1.0))))
	_check("el orden de drenaje es por lejanía (5,3,1)", dists_orden == [5, 3, 1],
		str(dists_orden))
	var forzo: bool = mm.avisar_cambio_region("t67_final")
	_check("el cambio final fuerza el drenaje de los 3", forzo == true)
	_check("la cola quedó VACÍA", mm.unload.candidatos_count() == 0,
		"n=%d" % mm.unload.candidatos_count())
	_check("los 3 bancos salieron en UN lote", mm.unload.ultimo_lote_count() == 3,
		"n=%d" % mm.unload.ultimo_lote_count())
	_check("el resumen del lote empieza por el banco más lejano (48 MB)",
		String(mm.unload.resumen_ultimo_lote()).begins_with("48 MB"),
		mm.unload.resumen_ultimo_lote())
	_check("una sola liberación forzada por el cambio (no una por banco)",
		mm.liberaciones_forzadas() == _forz_d + 1,
		"f=%d base+1=%d" % [mm.liberaciones_forzadas(), _forz_d + 1])
	_bancos.clear()
	var vivos: int = _contar_vivos(_debiles)
	_debiles.clear()
	_vivos_fin = vivos
	_check("ninguno de los 3 bancos finales sobrevive (WeakRef)", vivos == 0,
		"vivos=%d" % vivos)
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
	print("-- bancos que sobrevivieron al final: %d" % _vivos_fin)
	print("-- objetos_vivos: base=%d fin=%d (delta=%d)" % [_obj_base, _obj_fin, _obj_fin - _obj_base])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con código 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — los %d checks pasaron" % [MODULO, _checks])
		quit(0)
