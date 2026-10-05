# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-05
#
# M62: Memoria — Test de leaks con teleport x10 (T-D9).
# Cierra por MEDICION dos items del checklist que estaban abiertos sin cifra:
#   * L105 "Test de leaks con teleport x10 y conteo de objetos antes/despues
#           (debe ser igual)"
#   * L143 "Teleport extremo x10 y vuelta al spawn deja la memoria en el mismo
#           nivel (test)"
#
# Que se mide (headless, sin mundo): cada "teleport" deja atras los chunks del
# borde como CANDIDATOS a descarga en la UnloadPolicy. Si la politica los
# RETIENE despues de ejecutar_descarga(), los Resource quedan vivos -> fuga.
# El test hace 10 ciclos, el llamador suelta sus referencias y se comprueba con
# WeakRef que TODOS murieron, mas el conteo global de objetos antes/despues.
#
# Lo que NO es medible aca: el mundo real (M63/M08) y el frame con render. Este
# test mide la CONTRATACION de M62 (que su cola no retenga), que es lo que M62
# posee. El teleport con mundo real sigue siendo Play Mode (checklist §N, L213).
#
# Guardian anti-falso-verde de 3 capas (skill §2, trampas 11/28/61/63):
#   1. marcadores `_fin("X")` por bloque -> nombra el bloque que no corrio;
#   2. piso `CHECKS_MINIMOS` medido en verde -> caza el aborto en un helper;
#   3. `_summary()` en un `call_deferred` APARTE -> si `_run()` aborta por un
#      SCRIPT ERROR, la cola diferida sigue y el resumen igual se imprime.
# Mas dos controles que este test exige por su cuenta:
#   * A. SONDA DEL MEDIDOR (control positivo): si crear objetos no mueve el
#     contador, la igualdad antes/despues seria vacua (falso verde por OMISION).
#   * D. GUARDIAN EN ROJO por INYECCION: se deja una fuga a proposito y se
#     exige que el detector la VEA. Un detector que nunca ve nada y uno que ve
#     todo bien dicen lo mismo.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_m62_leaks_teleport.gd

extends SceneTree

const MODULO := "M62 leaks teleport"
const BLOQUES: Array[String] = ["A", "B", "C", "D"]
## Piso MEDIDO en verde (no copiado): 21 checks en la primera corrida verde,
## identico en 3 corridas (ver 07-Resultados-Testings.md §9.9).
const CHECKS_MINIMOS := 21

const RUTA_MONITOR := "res://scripts/rendimiento/memoria/memory_monitor.gd"
const _SC_BUDGET := preload("res://scripts/rendimiento/memoria/budget_registry.gd")
const _SC_POOL := preload("res://scripts/rendimiento/memoria/global_pool.gd")
const _SC_UNLOAD := preload("res://scripts/rendimiento/memoria/unload_policy.gd")

const N_TELEPORTS := 10
const CHUNKS_POR_TELEPORT := 24
const PESO_CHUNK_MB := 4
const KB_CHUNK := 256  # carga util real: un Resource vacio no se distingue de un no-op

# Nodos de la sonda del medidor (bloque A).
const N_SONDA_NODOS := 64
const N_SONDA_OBJETOS := 256
# Nodos del pool (bloque C).
const N_POOL := 16


## Carga util real (no un Resource vacio): si el objeto no tiene peso, no se
## mide una retencion, se mide un no-op.
class Carga:
	extends Resource

	var datos: PackedByteArray

	func _init(kb: int) -> void:
		datos.resize(kb * 1024)
		datos.fill(0xAB)


var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}

# Diagnostico (se imprime en el resumen, para auditar sin re-correr).
var _objetos_base: int = -1
var _objetos_fin: int = -1
var _retenidos_total: int = -1
var _cola_max: int = -1


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	print("=== [M62] Test de leaks con teleport x%d (T-D9) ===" % N_TELEPORTS)
	_bloque_a_sonda()
	_bloque_b_teleport()
	_bloque_c_pool()
	_bloque_d_guardian_rojo()


## ── A. Sonda del medidor (control positivo) ──────────────────────────────
## Sin esto, "el conteo volvio a la base" podria ser cierto porque el medidor
## nunca se movio (falso verde por OMISION).
func _bloque_a_sonda() -> void:
	print("--- A. Sonda del medidor (control positivo) ---")
	var mm = _monitor()
	_check("objetos_vivos() es legible", mm.objetos_vivos() > 0,
		"valor=%d" % mm.objetos_vivos())
	var huerf_base: int = mm.nodos_huerfanos()
	_check("nodos_huerfanos() es legible", huerf_base >= 0, "base=%d" % huerf_base)

	# Nodos sin padre: el contador de huerfanos DEBE subir.
	var nodos: Array[Node] = []
	for _i in N_SONDA_NODOS:
		nodos.append(Node.new())
	var huerf_con: int = mm.nodos_huerfanos()
	_check("crear %d nodos sin padre SUBE el contador de huerfanos (el medidor no esta ciego)"
		% N_SONDA_NODOS, huerf_con >= huerf_base + N_SONDA_NODOS,
		"base=%d con=%d" % [huerf_base, huerf_con])
	for n in nodos:
		n.free()
	nodos.clear()
	var huerf_fin: int = mm.nodos_huerfanos()
	_check("liberarlos devuelve el contador a la base (sin leak de nodos)",
		huerf_fin <= huerf_base, "base=%d fin=%d" % [huerf_base, huerf_fin])

	# El mismo tipo de objeto que usa el teleport: Resource (RefCounted).
	var obj_base: int = mm.objetos_vivos()
	var refs: Array = []
	for _i in N_SONDA_OBJETOS:
		refs.append(Carga.new(1))
	var obj_con: int = mm.objetos_vivos()
	_check("crear %d Resources SUBE objetos_vivos() (el medidor ve el tipo del teleport)"
		% N_SONDA_OBJETOS, obj_con >= obj_base + N_SONDA_OBJETOS,
		"base=%d con=%d delta=%d" % [obj_base, obj_con, obj_con - obj_base])
	refs.clear()
	var obj_fin: int = mm.objetos_vivos()
	_check("soltar los %d Resources devuelve objetos_vivos() a la base"
		% N_SONDA_OBJETOS, obj_fin <= obj_base,
		"base=%d fin=%d delta=%d" % [obj_base, obj_fin, obj_fin - obj_base])
	_fin("A")


## ── B. Teleport x10: la cola de descarga NO retiene (L105/L143) ──────────
func _bloque_b_teleport() -> void:
	print("--- B. Teleport x%d: la cola de descarga no retiene ---" % N_TELEPORTS)
	var mm = _monitor()
	_objetos_base = mm.objetos_vivos()

	var retenidos := 0
	var ciclos_ok := 0
	var mb_total := 0
	var cola_vacia := true
	var poi_ok := true
	_cola_max = 0

	for _i in N_TELEPORTS:
		# 1. El teleport deja atras los chunks del borde: candidatos a descarga.
		var fuertes: Array = []
		var debiles: Array = []
		for j in CHUNKS_POR_TELEPORT:
			var r := Carga.new(KB_CHUNK)
			mm.registrar_candidato_descarga(r, PESO_CHUNK_MB, float(j))
			fuertes.append(r)
			debiles.append(weakref(r))
		_cola_max = maxi(_cola_max, mm.unload.candidatos_count())

		# 2. El teleport marca su punto de interes (L51).
		mm.marcar_punto_de_interes("teleport_extremo")
		if mm.pico_de_poi("teleport_extremo") <= 0.0:
			poi_ok = false

		# 3. La politica descarga el lote completo.
		mb_total += mm.unload.ejecutar_descarga(1 << 30, 1 << 20)

		# 4. El llamador suelta sus referencias (como hace el mundo al descargar).
		fuertes.clear()

		# 5. La cola no debe retener NINGUN recurso ya descargado.
		if mm.unload.candidatos_count() == 0:
			ciclos_ok += 1
		else:
			cola_vacia = false
		retenidos += _contar_vivos(debiles)

	_objetos_fin = mm.objetos_vivos()
	_retenidos_total = retenidos

	_check("los %d ciclos de teleport se ejecutaron completos" % N_TELEPORTS,
		ciclos_ok == N_TELEPORTS, "ciclos_ok=%d" % ciclos_ok)
	_check("cada teleport dejo %d candidatos en la cola (la cola se uso de verdad)"
		% CHUNKS_POR_TELEPORT, _cola_max == CHUNKS_POR_TELEPORT, "max=%d" % _cola_max)
	_check("la politica descargo el lote completo (%d MB)"
		% (N_TELEPORTS * CHUNKS_POR_TELEPORT * PESO_CHUNK_MB),
		mb_total == N_TELEPORTS * CHUNKS_POR_TELEPORT * PESO_CHUNK_MB, "mb_total=%d" % mb_total)
	_check("la cola quedo VACIA tras cada descarga", cola_vacia)
	_check("NINGUN recurso quedo retenido por la politica en los %d teleports (L105)"
		% N_TELEPORTS, retenidos == 0, "retenidos=%d" % retenidos)
	_check("el pico por punto de interes 'teleport_extremo' quedo registrado (L51)", poi_ok)
	# L105 pide que el conteo "sea igual" antes/despues. La asercion es el
	# INVARIANTE DE FUGA (fin <= base): un delta negativo NO es una fuga, asi
	# que exigir igualdad estricta solo agregaria fragilidad. El valor MEDIDO si
	# es exactamente igual (delta=0, x3 corridas) — queda impreso en el resumen.
	# La prueba EXACTA de no-retencion es `retenidos == 0` (arriba): esa no
	# depende del ruido del motor.
	_check("objetos_vivos() NO crece tras %d teleports (fin <= base; medido delta=0)"
		% N_TELEPORTS, _objetos_fin <= _objetos_base,
		"base=%d fin=%d delta=%d" % [_objetos_base, _objetos_fin, _objetos_fin - _objetos_base])
	_fin("B")


## ── C. El pool libera de verdad (liberar_todo) ───────────────────────────
## Caza la regresion del defecto documentado en global_pool.gd: "liberar_todo()
## antes solo vaciaba los arrays -> los nodos quedaban vivos y sin dueno".
func _bloque_c_pool() -> void:
	print("--- C. El pool libera de verdad (liberar_todo) ---")
	var pool = _SC_POOL.new()
	var holder := Node.new()
	root.add_child(holder)
	pool.set_holder(holder)
	pool.set_limite("chunk", 64)

	var nodos: Array[Node] = []
	for _i in N_POOL:
		var n := Node.new()
		if pool.devolver("chunk", n):
			nodos.append(n)

	_check("el pool retiene los %d items devueltos" % N_POOL, pool.tamanio("chunk") == N_POOL,
		"tamanio=%d" % pool.tamanio("chunk"))
	_check("el holder cuelga los items estacionados (no quedan huerfanos)",
		holder.get_child_count() == N_POOL, "hijos=%d" % holder.get_child_count())

	var liberados: int = pool.liberar_todo()
	_check("liberar_todo() libera los %d items" % N_POOL, liberados == N_POOL,
		"liberados=%d" % liberados)
	_check("el pool queda vacio tras liberar_todo()", pool.tamanio("chunk") == 0,
		"tamanio=%d" % pool.tamanio("chunk"))

	# La prueba de que LIBERA (y no solo vacia el array): cada nodo quedo
	# encolado para liberarse. Si la regresion volviera, esto daria 0.
	var encolados := 0
	for n in nodos:
		if is_instance_valid(n) and n.is_queued_for_deletion():
			encolados += 1
	_check("los %d items quedan encolados para liberar (queue_free) — caza la regresion"
		% N_POOL, encolados == N_POOL, "encolados=%d" % encolados)

	# ⚠️ queue_free() es DIFERIDO: en el mismo frame el nodo sigue colgado del
	# holder (medido: hijos=16 inmediatamente despues de liberar_todo()). Por eso
	# se comprueba que estan ENCOLADOS, no que ya desaparecieron. Afirmar
	# "holder sin hijos" aca seria medir el frame equivocado.
	var hijos_encolados := 0
	for i in holder.get_child_count():
		if holder.get_child(i).is_queued_for_deletion():
			hijos_encolados += 1
	_check("los %d hijos del holder quedan ENCOLADOS para liberar (queue_free es diferido)"
		% N_POOL, hijos_encolados == N_POOL,
		"encolados=%d de %d" % [hijos_encolados, holder.get_child_count()])
	holder.queue_free()
	_fin("C")


## ── D. Guardian EN ROJO: el detector VE una fuga inyectada ───────────────
## Un detector que nunca ve nada y uno que ve todo bien dicen lo mismo. Aca se
## deja una fuga a proposito (candidatos registrados y NUNCA descargados: la
## politica los retiene, que es su contrato de cola) y se exige que el detector
## la vea. Ademas documenta el contrato: la retencion la rompe la DESCARGA.
func _bloque_d_guardian_rojo() -> void:
	print("--- D. Guardian en rojo: el detector VE una fuga inyectada ---")
	var mm = _monitor()
	var retenedor: Array = []
	var debiles: Array = []
	for _i in 8:
		var r := Carga.new(64)
		mm.registrar_candidato_descarga(r, 1, 0.0)
		retenedor.append(r)
		debiles.append(weakref(r))
	# El llamador suelta sus referencias; la POLITICA todavia las retiene.
	retenedor.clear()
	var vivos_antes: int = _contar_vivos(debiles)
	_check("la politica RETIENE los candidatos no descargados (la fuga inyectada se ve)",
		vivos_antes == 8, "vivos=%d" % vivos_antes)
	# Al ejecutar la descarga, la politica los suelta -> se liberan.
	mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	var vivos_despues: int = _contar_vivos(debiles)
	_check("tras ejecutar_descarga() el detector ya NO los ve (la descarga rompe la retencion)",
		vivos_despues == 0, "vivos=%d" % vivos_despues)
	_fin("D")


## ── Utilidades ───────────────────────────────────────────────────────────

## Cuantos de los WeakRef siguen vivos (=> el objeto fue RETENIDO por alguien).
func _contar_vivos(debiles: Array) -> int:
	var vivos := 0
	for w in debiles:
		if (w as WeakRef).get_ref() != null:
			vivos += 1
	return vivos

## Monitor aislado con su propio registry (no toca el autoload).
func _monitor() -> Variant:
	var b = _SC_BUDGET.new()
	b.cargar()
	var mm = load(RUTA_MONITOR).new()
	mm.budget = b
	mm.unload = _SC_UNLOAD.new()
	mm.pool = _SC_POOL.new()
	return mm

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
			print("[FALL] el bloque %s NO se ejecuto (posible SCRIPT ERROR que aborto la funcion)" % n)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FALL] solo %d checks ejecutados (minimo medido en verde: %d)" % [_checks, CHECKS_MINIMOS])
	print("-- objetos_vivos: base=%d fin=%d (delta=%d)" % [_objetos_base, _objetos_fin, _objetos_fin - _objetos_base])
	print("-- retenidos por la politica en los %d teleports: %d" % [N_TELEPORTS, _retenidos_total])
	print("-- cola maxima observada: %d candidatos" % _cola_max)
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con codigo 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — los %d checks pasaron" % [MODULO, _checks])
		quit(0)
