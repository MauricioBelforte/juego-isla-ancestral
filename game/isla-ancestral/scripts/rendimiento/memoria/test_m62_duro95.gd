# Modelo: DS-V4.1-Flash-Opencode
# Plataforma: OpenCode
# Fecha: 2026-10-18
#
# M62: Memoria — Suite del disparo DURO al 95% (pin del ítem L132 del 05-Checklist).
# Cierra por MEDICIÓN el ítem de reposición del backlog:
#   "Descarga dura al 95%: atlas fuera de pantalla y bancos de biomas viajeros [M]"
#
# Qué mide (headless, autoload REAL MemoryMonitor):
#   A. Disparo: umbrales del diseño §3 (80/90/95) DERIVADOS del presupuesto
#      VIVO del autoload (topes del preset + registros runtime: hoy 2000+32 de
#      `ia_npc`; con un tope hardcodeado el pin se rompía en falso), nivel 1 no
#      ejecuta, nivel 2 drena hasta el tope del preset e idempotente, nivel 3
#      RE-APLICA sin excepción (una sola fuente de verdad
#      `nivel_para` -> `_enforcement`).
#   B. Bancos de biomas viajeros: candidatos lejanos (viajeros) + locales + uno
#      vetado por el handshake con M63. El duro descarga primero a los viajeros
#      (orden distancia desc), respeta el veto (única excepción) y, al terminar
#      la carga del 63, también los drena.
#   C. Atlas fuera de pantalla: evicción LRU del wrapper `evictar_atlas` — las
#      de uso viejo (fuera de pantalla) primero y NUNCA por tamaño; señal
#      recurso_descargado("atlas", mb) por evicción útil; entradas sin mutar.
#   D. Audio viajero: banco pedido durante su descarga = diferido (nunca a
#      medias); patrón determinista del duro (mismo escenario -> mismos MB).
#
# Alcance (honesto): mide el mecanismo del 62 con el disparo DURO real. Los
# FEEDS de producción no existen hoy y son deuda de sus dueños: la tabla de
# atlas la aporta M09/M63 y el registro de bancos al viajar lo hace M42
# (ítem 112 del backlog, abierto). Esta suite pina el contrato: "si el recurso
# está registrado, el duro lo descarga; el atlas LRU evicta lo fuera de
# pantalla". Piezas ya cubiertas por otras suites (no re-contadas aquí): orden
# y tope del lote (test_enforcement_m62 C), veto del handshake
# (test_memoria_m62_iter5 A/B), evicción standalone (test_m62_texturas_region C).
#
# Guardián anti-falso-verde de 3 capas (skill §2, trampas 11/28/61/63):
#   1. marcadores `_fin("X")` por bloque -> nombra el bloque que no corrió;
#   2. piso `CHECKS_MINIMOS` medido en verde -> caza el aborto en un helper;
#   3. `_summary()` en un `call_deferred` APARTE -> si `_run()` aborta por un
#      SCRIPT ERROR, la cola diferida sigue y el resumen igual se imprime.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_m62_duro95.gd

extends SceneTree

const MODULO := "M62 duro95"
const BLOQUES: Array[String] = ["A", "B", "C", "D"]
## Piso MEDIDO en verde (ver 07-Resultados-Testings.md / evidencia Tanda 60).
const CHECKS_MINIMOS := 39

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}

# Recorder de la señal recurso_descargado (dos arrays tipados, sin Variant).
var _em_sist: Array[String] = []
var _em_mb: Array[int] = []

# Diagnóstico del resumen (para auditar sin re-correr).
var _lote_b1: int = -1
var _lote_b2: int = -1
var _atlas_evictadas: int = -1


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	print("=== [M62] Disparo duro al 95%: viajeros + atlas + audio (L132) ===")
	var mm := _mm()
	if mm == null:
		_check("autoload MemoryMonitor presente", false, "mm=null")
		return
	_check("autoload MemoryMonitor presente", true)
	mm.recurso_descargado.connect(_on_descarga)
	_bloque_a()
	_bloque_b()
	_bloque_c()
	_bloque_d()


## ── A. Disparo: umbrales y "sin excepción" ────────────────────────────────
func _bloque_a() -> void:
	print("--- A. Disparo duro: umbrales 80/90/95 y sin excepción ---")
	var mm := _mm()
	# Drenaje inicial defensivo: el arranque del juego pudo dejar candidatos.
	mm.unload.ejecutar_descarga(1 << 30, 1 << 20)
	_check("la cola de descarga arranca drenada",
		mm.unload.candidatos_count() == 0, "n=%d" % mm.unload.candidatos_count())
	var total: int = mm.presupuesto_total_mb()
	_check("presupuesto vivo del preset media (>0; incluye registros runtime)",
		total > 0, "total=%d" % total)
	var u_w: int = int(ceil(float(total) * 0.80))
	var u_c: int = int(ceil(float(total) * 0.90))
	var u_e: int = int(ceil(float(total) * 0.95))
	_check("nivel_para(%d) = 0 (un MB debajo del 80%%)" % (u_w - 1),
		mm.nivel_para(float(u_w - 1)) == 0)
	_check("nivel_para(%d) = 1 (warning exacto)" % u_w, mm.nivel_para(float(u_w)) == 1)
	_check("nivel_para(%d) = 2 (crítico exacto)" % u_c, mm.nivel_para(float(u_c)) == 2)
	_check("nivel_para(%d) = 3 (emergencia al 95%% exacto)" % u_e,
		mm.nivel_para(float(u_e)) == 3)

	# 15 chunks de peso 10: el nivel 1 no ejecuta.
	for i in 15:
		_cand(mm, 10, 15.0 - i)
	mm._enforcement(float(u_w), mm.nivel_para(float(u_w)))
	_check("nivel 1 NO descarga (cola intacta)",
		mm.unload.candidatos_count() == 15, "n=%d" % mm.unload.candidatos_count())

	# Nivel 2: descarga SUAVE hasta el tope del preset media (12) e idempotente.
	mm._enforcement(float(u_c), mm.nivel_para(float(u_c)))
	_check("nivel 2 drena el tope del preset media (12)",
		mm.unload.ultimo_lote_count() == 12, "lote=%d" % mm.unload.ultimo_lote_count())
	_check("quedan 3 candidatos tras el lote suave",
		mm.unload.candidatos_count() == 3, "n=%d" % mm.unload.candidatos_count())
	mm._enforcement(float(u_c + 10), 2)
	_check("nivel 2 repetido NO re-aplica (idempotente)",
		mm.unload.candidatos_count() == 3, "n=%d" % mm.unload.candidatos_count())

	# Nivel 3: re-aplica SIEMPRE y drena el resto sin excepción.
	var em_antes: int = _em_mb.size()
	mm._enforcement(float(u_e), mm.nivel_para(float(u_e)))
	_check("nivel 3 drena el resto y vacía la cola",
		mm.unload.candidatos_count() == 0, "n=%d" % mm.unload.candidatos_count())
	_check("nivel 3 volvió a emitir la señal (re-aplica sin excepción)",
		_em_mb.size() == em_antes + 1, "emisiones=%d" % _em_mb.size())
	_check("la emisión del duro = sistema 'enforcement_duro' y 30 MB",
		_em_sist.back() == "enforcement_duro" and _em_mb.back() == 30,
		"emision=%s/%d" % [_em_sist.back(), _em_mb.back()])
	_fin("A")


## ── B. Bancos viajeros: los más lejanos primero, sin excepción ────────────
func _bloque_b() -> void:
	print("--- B. Bancos de biomas viajeros en el duro ---")
	var mm := _mm()
	var u_e: int = int(ceil(float(mm.presupuesto_total_mb()) * 0.95))
	# 3 "bancos de bioma viajero" (lejanos y pesados) + 3 locales + 1 en carga.
	var dists: Array = [60.0, 50.0, 40.0]
	var pesos: Array = [60, 50, 40]
	for i in 3:
		_cand(mm, int(pesos[i]), float(dists[i]))
	_cand(mm, 7, 7.0)
	_cand(mm, 6, 6.0)
	_cand(mm, 5, 5.0)
	var en_carga: Resource = _cand(mm, 100, 10.0)
	_check("cola con 7 candidatos (3 viajeros + 3 locales + 1 en carga)",
		mm.unload.candidatos_count() == 7, "n=%d" % mm.unload.candidatos_count())

	var orden: Array = mm.unload.previsualizar_orden()
	var ds: Array = []
	for o in orden:
		ds.append(float(o.get("distancia", -1.0)))
	_check("orden por distancia descendente (viajeros primero): 60,50,40,10,7,6,5",
		ds == [60.0, 50.0, 40.0, 10.0, 7.0, 6.0, 5.0], "orden=%s" % str(ds))

	mm.avisar_carga_iniciada(en_carga)
	_check("el candidato en carga queda vetado por el handshake",
		mm.esta_en_carga(en_carga) == true)

	var descartes_antes: int = mm.descartes_por_carga()
	var em_antes: int = _em_mb.size()
	mm._enforcement(float(u_e), mm.nivel_para(float(u_e)))
	_lote_b1 = mm.unload.ultimo_lote_count()
	_check("el duro drena los 6 candidatos libres (viajeros incluidos)",
		_lote_b1 == 6, "lote=%d" % _lote_b1)
	_check("los MB liberados suman los pesos (168)",
		_em_mb.size() == em_antes + 1 and _em_mb.back() == 168,
		"emision=%s/%d" % [_em_sist.back(), _em_mb.back()])
	var resto: Array = mm.unload.previsualizar_orden()
	_check("el vetado SIGUE en cola y es el de distancia 10",
		resto.size() == 1 and float(resto[0].get("distancia", -1.0)) == 10.0,
		"resto=%s" % str(resto))
	_check("el veto quedó contado en la política (diferidos del lote)",
		mm.unload.diferidos_ultimo_lote() == 1,
		"d=%d" % mm.unload.diferidos_ultimo_lote())
	_check("el veto quedó contado en el monitor",
		mm.descartes_por_carga() == descartes_antes + 1,
		"d=%d base=%d" % [mm.descartes_por_carga(), descartes_antes])
	_check("el resumen del lote registra la distancia del viajero más lejano",
		mm.unload.resumen_ultimo_lote().contains("dist 60"),
		"resumen=%s" % mm.unload.resumen_ultimo_lote())

	# Al terminar la carga del 63, el próximo duro lo descarga: sin excepción.
	mm.avisar_carga_terminada(en_carga)
	mm._enforcement(float(u_e), mm.nivel_para(float(u_e)))
	_lote_b2 = mm.unload.ultimo_lote_count()
	_check("al terminar la carga, el duro lo descarga (1 objeto de 100 MB)",
		_lote_b2 == 1 and _em_mb.back() == 100,
		"lote=%d emision=%s/%d" % [_lote_b2, _em_sist.back(), _em_mb.back()])
	_check("cola vacía tras el segundo duro",
		mm.unload.candidatos_count() == 0, "n=%d" % mm.unload.candidatos_count())
	_fin("B")


## ── C. Atlas fuera de pantalla: LRU primero, nunca por tamaño ─────────────
func _bloque_c() -> void:
	print("--- C. Atlas fuera de pantalla (fuera de pantalla = uso viejo) ---")
	var mm := _mm()
	var entradas: Array = [
		{"nombre": "pantalla_90", "mb": 90, "ultimo_uso": 9000},
		{"nombre": "pantalla_80", "mb": 80, "ultimo_uso": 8000},
		{"nombre": "fuera_1", "mb": 10, "ultimo_uso": 100},
		{"nombre": "fuera_2", "mb": 20, "ultimo_uso": 200},
		{"nombre": "fuera_3", "mb": 30, "ultimo_uso": 300},
	]
	var em_antes: int = _em_mb.size()
	var ev: Array = mm.evictar_atlas(entradas, 50, 99)
	_atlas_evictadas = ev.size()
	var nombres: Array = []
	for e in ev:
		nombres.append(String((e as Dictionary).get("nombre", "")))
	_check("evicta 3 entradas (10+20+30 = 60 MB >= 50)",
		ev.size() == 3, "n=%d" % ev.size())
	_check("evicta SOLO las de fuera de pantalla",
		nombres == ["fuera_1", "fuera_2", "fuera_3"], "nombres=%s" % str(nombres))
	_check("la entrada de pantalla MÁS GRANDE (90 MB) no se toca (no decide el tamaño)",
		not nombres.has("pantalla_90"))
	_check("señal atlas con los MB sumados (60)",
		_em_mb.size() == em_antes + 1 and _em_sist.back() == "atlas"
			and _em_mb.back() == 60,
		"emision=%s/%d" % [_em_sist.back(), _em_mb.back()])
	# hasta_mb=0 = no-op sin señal.
	var em2: int = _em_mb.size()
	var ev0: Array = mm.evictar_atlas(entradas, 0, 99)
	_check("hasta_mb=0 es no-op (nada evictado, sin señal)",
		ev0.is_empty() and _em_mb.size() == em2, "n=%d" % ev0.size())
	# max_entradas manda sobre hasta_mb.
	var ev1: Array = mm.evictar_atlas(entradas, 9999, 1)
	_check("max_entradas=1 manda (evicta solo la más vieja)",
		ev1.size() == 1 and String((ev1[0] as Dictionary).get("nombre", "")) == "fuera_1",
		"n=%d" % ev1.size())
	_check("las entradas originales quedaron sin mutar",
		entradas.size() == 5
			and int((entradas[2] as Dictionary).get("ultimo_uso", -1)) == 100
			and int((entradas[0] as Dictionary).get("mb", -1)) == 90)
	_fin("C")


## ── D. Audio viajero diferido + determinismo del duro ─────────────────────
func _bloque_d() -> void:
	print("--- D. Audio viajero diferido + determinismo ---")
	var mm := _mm()
	var u_e: int = int(ceil(float(mm.presupuesto_total_mb()) * 0.95))
	mm.iniciar_descarga_audio("banco_bioma_selva")
	_check("el banco viajero queda marcado en descarga",
		mm.descargando_audio("banco_bioma_selva") == true)
	_check("pedirlo durante la descarga = diferido",
		mm.pedir_banco_audio("banco_bioma_selva") == "diferido")
	_check("queda listado en bancos_audio_diferidos()",
		mm.bancos_audio_diferidos().has("banco_bioma_selva")
			and mm.audio_diferido_count() == 1,
		"n=%d" % mm.audio_diferido_count())
	_check("otro banco no descargando = reproducir",
		mm.pedir_banco_audio("banco_bioma_playa") == "reproducir")
	mm.terminar_descarga_audio("banco_bioma_selva")
	_check("al terminar la descarga el banco ya no se difiere",
		mm.pedir_banco_audio("banco_bioma_selva") == "reproducir")

	# Determinismo: mismo escenario del bloque B -> mismos números.
	var dists: Array = [60.0, 50.0, 40.0]
	var pesos: Array = [60, 50, 40]
	for i in 3:
		_cand(mm, int(pesos[i]), float(dists[i]))
	_cand(mm, 7, 7.0)
	_cand(mm, 6, 6.0)
	_cand(mm, 5, 5.0)
	mm._enforcement(float(u_e), mm.nivel_para(float(u_e)))
	_check("segunda corrida del duro: mismos 6 objetos y 168 MB",
		mm.unload.ultimo_lote_count() == 6 and _em_mb.back() == 168,
		"lote=%d emision=%s/%d" % [mm.unload.ultimo_lote_count(),
			_em_sist.back(), _em_mb.back()])
	_check("cola drenada tras el determinismo",
		mm.unload.candidatos_count() == 0, "n=%d" % mm.unload.candidatos_count())
	_fin("D")


## ── Utilidades ───────────────────────────────────────────────────────────

func _mm() -> Node:
	return root.get_node_or_null("MemoryMonitor")


## Registra un candidato y devuelve la referencia (para el veto del handshake).
func _cand(mm: Node, peso: int, dist: float) -> Resource:
	var r := Resource.new()
	mm.registrar_candidato_descarga(r, peso, dist)
	return r


func _on_descarga(sistema: String, mb: int) -> void:
	_em_sist.append(sistema)
	_em_mb.append(mb)


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
	print("-- lote viajeros 1: %d objetos · lote 2 (post-carga): %d · atlas evictadas: %d"
		% [_lote_b1, _lote_b2, _atlas_evictadas])
	print("-- emisiones recurso_descargado: %d" % _em_mb.size())
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con código 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — los %d checks pasaron" % [MODULO, _checks])
		quit(0)
