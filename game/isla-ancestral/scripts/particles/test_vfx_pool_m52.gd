# Modelo: DeepSeek-V4.1-Flash / WorkBuddy
# Plataforma: WorkBuddy
# Fecha: 2026-09-13
#
# M52 iter 5: Test de VfxPool + ruta de RUNTIME (antes sin probar).
# Cubre el encaje A8: pooling (T-027), precalentamiento (T-029), determinismo
# (T-093), límites de rendimiento y log VFX-SKIP (RF3).
# Bloques: A factory runtime · B determinismo · C pool · D límites · E director · F VFX-SKIP.
#
# Contexto: los 3 tests previos (catalog/factory/director) solo probaban
# funciones PURAS; `crear()` —la ruta que realmente instancia el VFX— nunca se
# ejecutó y estaba ROTA (`GPUParticles3D.mesh` no existe desde Godot 4.3).
# Este test sí instancia nodos.
#
# Anti-falso-verde: un SCRIPT ERROR aborta la función en silencio y el resumen
# imprimiría "0 fallos"; cada bloque cierra con _fin(marca) y _run() los verifica.

extends SceneTree

const FACTORY := preload("res://scripts/particles/vfx_factory.gd")
const POOL := preload("res://scripts/particles/vfx_pool.gd")
const DIRECTOR := preload("res://scripts/particles/vfx_director.gd")

const BLOQUES: Array[String] = ["A", "B", "C", "D", "E", "F"]

var _fallos: int = 0
var _checks: int = 0
var _marcas: Dictionary = {}

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M52] Test de VfxPool + runtime (iter. 5) ===")
	_test_factory_runtime()   # A
	_test_determinismo()      # B
	_test_pool()              # C
	_test_limites()           # D
	await _test_director()    # E
	await _test_skips()       # F
	for marca in BLOQUES:
		if not _marcas.has(marca):
			_check("bloque %s completó (marcador _fin)" % marca, false, "BLOQUE ABORTADO")
		else:
			_check("bloque %s completó (marcador _fin)" % marca, true)
	print("=== Resumen M52: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _fin(marca: String) -> void:
	_marcas[marca] = true

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s %s" % [nombre, detalle])

func _vfx(id: String, cantidad: int = 20, emision: float = 0.5) -> Dictionary:
	return {"id": id, "nombre": id, "color": "#FFFFFF", "cantidad": cantidad,
			"emision": emision, "tipo": "flotante", "evento": "ev_" + id}

## ── A. Ruta de runtime de la factory (antes ROTA) ──────────────────────

func _test_factory_runtime() -> void:
	print("--- A. VfxFactory: creación real de emisores ---")
	var raiz := Node3D.new()
	root.add_child(raiz)
	var vfx := _vfx("vfx_polen", 150, 1.0)

	# nuevo_emisor() debe devolver un nodo configurado
	var gp: GPUParticles3D = FACTORY.nuevo_emisor(vfx)
	_check("nuevo_emisor devuelve GPUParticles3D", gp != null)
	_check("amount aplicado (150)", gp.amount == 150)
	_check("one_shot", gp.one_shot)
	_check("explosiveness 1.0", is_equal_approx(gp.explosiveness, 1.0))
	_check("lifetime = emision", is_equal_approx(gp.lifetime, 1.0))
	_check("draw_pass_1 asignado (NO 'mesh')", gp.draw_pass_1 != null)
	_check("process_material asignado", gp.process_material != null)
	_check("'mesh' ya no existe en GPUParticles3D", not ("mesh" in gp))
	gp.free()

	# crear() — la función que antes abortaba en silencio y devolvía null
	var creado = FACTORY.crear(raiz, vfx, Vector3(1, 2, 3))
	_check("crear() devuelve un nodo (antes null)", creado != null)
	_check("crear() añade al contenedor", raiz.get_child_count() == 1)
	_check("crear() posiciona el emisor", creado != null and creado.position == Vector3(1, 2, 3))
	_check("crear() deja emitiendo", creado != null and creado.emitting)

	# color del hex
	var p: Dictionary = FACTORY.parametros({"color": "#F4E04D"})
	var c: Color = p["color"]
	_check("color #F4E04D parseado", absf(c.r - 0.9568) < 0.002 and absf(c.g - 0.8784) < 0.002)
	_check("hex inválido -> blanco", FACTORY.parametros({"color": "zzz"})["color"] == Color.WHITE)
	raiz.queue_free()
	_fin("A")

## ── B. Determinismo (T-093) ────────────────────────────────────────────

func _test_determinismo() -> void:
	print("--- B. Determinismo: semillas estables ---")
	var s1 := POOL.semilla_de("bloque_roto", 1)
	var s2 := POOL.semilla_de("bloque_roto", 1)
	_check("misma entrada -> misma semilla", s1 == s2, "%d vs %d" % [s1, s2])
	_check("semilla distinta por índice", POOL.semilla_de("bloque_roto", 2) != s1)
	_check("semilla distinta por evento", POOL.semilla_de("pesca_exito", 1) != s1)
	_check("semilla es int positivo", s1 > 0)
	# estabilidad frente a llamadas repetidas (no depende del azar del motor)
	var serie: Array = []
	for i in 5:
		serie.append(POOL.semilla_de("ev", i))
	var serie2: Array = []
	for i in 5:
		serie2.append(POOL.semilla_de("ev", i))
	_check("secuencia reproducible", serie == serie2)
	# validador
	_check("validador acepta secuencia buena", POOL.validar_semillas(serie) == "")
	_check("validador rechaza vacía", POOL.validar_semillas([]) != "")
	_check("validador rechaza repetidas consecutivas", POOL.validar_semillas([7, 7]) != "")
	_check("validador rechaza no-int", POOL.validar_semillas(["a"]) != "")
	_fin("B")

## ── C. Pool: prestar / liberar / reuso (T-027) ─────────────────────────

func _test_pool() -> void:
	print("--- C. VfxPool: préstamo, liberación y reuso ---")
	var pool = POOL.new()
	var vfx := _vfx("vfx_a", 10)
	_check("pool arranca vacío", pool.activos() == 0 and pool.libres() == 0 and pool.creados() == 0)

	# precalentamiento (T-029)
	var pre := pool.precalentar(vfx, 3)
	_check("precalentar crea 3 emisores", pre == 3, "creados=%d" % pre)
	_check("tras precalentar: 3 libres, 0 activos", pool.libres() == 3 and pool.activos() == 0)
	_check("precalentados NO emiten", not (pool.nodos()[0] as GPUParticles3D).emitting)

	# préstamo reutiliza (no allocar)
	var n1 = pool.prestar(vfx, Vector3.ZERO)
	_check("prestar devuelve un emisor", n1 != null)
	_check("reuso: creados sigue 3", pool.creados() == 3, "creados=%d" % pool.creados())
	_check("activos=1, libres=2", pool.activos() == 1 and pool.libres() == 2)
	_check("el emisor prestado emite", (n1 as GPUParticles3D).emitting)
	_check("semilla fijada (determinismo)", (n1 as GPUParticles3D).seed == POOL.semilla_de("vfx_a", 1))

	# liberar vuelve al pool
	_check("liberar devuelve true", pool.liberar(n1))
	_check("tras liberar: activos=0, libres=3", pool.activos() == 0 and pool.libres() == 3)
	_check("liberar dos veces devuelve false", not pool.liberar(n1))

	# ids distintos no se mezclan
	var otro := _vfx("vfx_b", 10)
	var n2 = pool.prestar(otro, Vector3.ZERO)
	_check("id distinto crea un emisor nuevo", pool.creados() == 4, "creados=%d" % pool.creados())
	_check("emisor de otro id", n2 != null and pool.activos() == 1)

	# contadores
	_check("emisiones contadas", pool.emisiones() == 2, "emisiones=%d" % pool.emisiones())
	_check("particulas activas", pool.particulas_activas() == 10, "p=%d" % pool.particulas_activas())
	var st: Dictionary = pool.stats()
	_check("stats coherentes", int(st["activos"]) == 1 and int(st["creados"]) == 4)
	_check("id vacío -> descarte", pool.prestar({"id": ""}, Vector3.ZERO) == null)
	_check("descarte contado", pool.descartes() == 1, "descartes=%d" % pool.descartes())
	_check("motivo del descarte registrado", pool.ultimo_descarte == POOL.MOTIVO_SIN_ID,
		pool.ultimo_descarte)
	for gp in pool.nodos():
		gp.free()
	_fin("C")

## ── D. Límites de rendimiento ──────────────────────────────────────────

func _test_limites() -> void:
	print("--- D. Límites: emisores y partículas ---")
	# max_emisores: al desbordar recicla el más antiguo
	var pool = POOL.new(2, 1000)
	var vfx := _vfx("v", 10)
	var a = pool.prestar(vfx, Vector3.ZERO)
	var b = pool.prestar(vfx, Vector3.ZERO)
	_check("2 activos con max 2", pool.activos() == 2)
	var c = pool.prestar(vfx, Vector3.ZERO)
	_check("3er préstamo sigue devolviendo emisor", c != null)
	_check("no se superan los 2 emisores", pool.activos() == 2 and pool.creados() == 2,
		"activos=%d creados=%d" % [pool.activos(), pool.creados()])
	_check("se recicló el más antiguo", pool.reciclados() >= 1, "reciclados=%d" % pool.reciclados())
	# El reciclado vuelve a _libres y se REUTILIZA en el mismo préstamo (óptimo):
	# el emisor más antiguo es el que se re-dispara, no se crea uno nuevo.
	_check("el reciclado se reutiliza (c == a)", c == a)
	_check("semilla determinista en el reuso", (c as GPUParticles3D).seed == POOL.semilla_de("v", 3),
		"%d vs %d" % [(c as GPUParticles3D).seed, POOL.semilla_de("v", 3)])
	for gp in pool.nodos():
		gp.free()

	# max_particulas: un VFX que solo ya no cabe -> descarte
	var pool2 = POOL.new(8, 100)
	var grande := _vfx("g", 150)
	_check("VFX que supera el tope -> null", pool2.prestar(grande, Vector3.ZERO) == null)
	_check("descartado y contado", pool2.descartes() == 1 and pool2.activos() == 0)

	# max_particulas: recicla activos para hacer hueco
	var pool3 = POOL.new(8, 30)
	var v10 := _vfx("v10", 10)
	pool3.prestar(v10, Vector3.ZERO)
	pool3.prestar(v10, Vector3.ZERO)
	pool3.prestar(v10, Vector3.ZERO)
	_check("3 activos (30 partículas)", pool3.particulas_activas() == 30)
	pool3.prestar(v10, Vector3.ZERO)
	_check("al pasarse recicla para no exceder el tope", pool3.particulas_activas() <= 30,
		"p=%d" % pool3.particulas_activas())
	_check("reciclajes contados", pool3.reciclados() >= 1)
	# tope alcanzado de verdad
	var pool4 = POOL.new(4, 20)
	var v20 := _vfx("v20", 20)
	pool4.prestar(v20, Vector3.ZERO)
	pool4.prestar(v20, Vector3.ZERO)
	_check("tope de partículas respetado", pool4.particulas_activas() <= 20,
		"p=%d" % pool4.particulas_activas())
	for gp in pool3.nodos():
		gp.free()
	for gp in pool4.nodos():
		gp.free()
	_fin("D")

## ── E. Director: ruta completa con pool ────────────────────────────────

func _test_director() -> void:
	print("--- E. VfxDirector: dispatch real con pool ---")
	var director = DIRECTOR.new()
	root.add_child(director)
	await process_frame
	_check("director conoce 30 eventos", director.eventos_registrados() == 30)

	var contenedor := Node3D.new()
	root.add_child(contenedor)
	director.set_container(contenedor)

	# disparo real: antes NO creaba nada
	var ok: bool = director.disparar("bloque_roto", Vector3(1, 2, 3))
	_check("disparar devuelve true", ok)
	_check("disparar CREA el emisor en el contenedor", contenedor.get_child_count() == 1,
		"hijos=%d" % contenedor.get_child_count())
	var nodo: GPUParticles3D = contenedor.get_child(0)
	_check("el emisor está en la posición pedida", nodo.position == Vector3(1, 2, 3))
	_check("el emisor emite", nodo.emitting)
	_check("draw_pass_1 presente (no 'mesh')", nodo.draw_pass_1 != null)
	_check("último disparo registrado", director.ultimo_disparo() == "bloque_roto")

	# precalentamiento desde el director (T-029)
	var pre: int = director.precalentar(1)
	_check("precalentar crea emisores", pre >= 8, "creados=%d" % pre)

	# evento inexistente
	_check("evento inexistente -> false", not director.disparar("no_existe", Vector3.ZERO))
	_check("fallos contados", director.fallos() == 1)

	# actualizar() devuelve los emisores agotados al pool
	var antes: int = director.get_pool().activos()
	var liberados: int = director.actualizar(10.0)
	_check("actualizar libera emisores agotados", liberados >= 1, "liberados=%d" % liberados)
	_check("ya no hay activos", director.get_pool().activos() == 0, "antes=%d" % antes)
	_check("stats del director", int(director.stats()["disparos"]) == 1)

	# finalizar() no debe dejar nodos huérfanos
	director.finalizar()
	_check("finalizar vacía el pool", director.get_pool().nodos().is_empty())
	director.free()
	contenedor.queue_free()
	_fin("E")

## ── F. Log VFX-SKIP: señal, motivos y wiring del director (RF3) ────────

func _test_skips() -> void:
	print("--- F. VFX-SKIP: señal, motivos y log ---")
	var pool = POOL.new(2, 30)
	var capturados: Array = []
	pool.emision_descartada.connect(func(id: String, motivo: String) -> void:
		capturados.append([id, motivo]))

	# (a) id vacío
	pool.prestar({"id": ""}, Vector3.ZERO)
	_check("motivo 'id vacío'", pool.ultimo_descarte == POOL.MOTIVO_SIN_ID, pool.ultimo_descarte)
	_check("señal emitida (1)", capturados.size() == 1)
	_check("señal lleva id y motivo", capturados.size() == 1 and capturados[0][1] == POOL.MOTIVO_SIN_ID)

	# (b) presupuesto de partículas: el VFX solo ya supera el tope
	pool.prestar(_vfx("g", 99), Vector3.ZERO)
	_check("motivo 'presupuesto de partículas'", pool.ultimo_descarte == POOL.MOTIVO_PARTICULAS,
		pool.ultimo_descarte)
	_check("señal lleva el id del VFX", capturados.size() == 2 and capturados[1][0] == "g")

	# (c) cupo de emisores agotado por OTRO id -> descarte (no se roba el ajeno)
	var pool5 = POOL.new(1, 1000)
	pool5.prestar(_vfx("a", 10), Vector3.ZERO)
	pool5.prestar(_vfx("b", 10), Vector3.ZERO)
	_check("motivo 'sin cupo de emisores'", pool5.ultimo_descarte == POOL.MOTIVO_EMISORES,
		pool5.ultimo_descarte)
	_check("no se excede el cupo", pool5.creados() <= 1 and pool5.particulas_activas() == 0)

	# (d) agregación y stats
	var m: Dictionary = pool.motivos()
	_check("motivos() agrega por causa",
		int(m.get(POOL.MOTIVO_SIN_ID, 0)) == 1 and int(m.get(POOL.MOTIVO_PARTICULAS, 0)) == 1,
		str(m))
	_check("stats incluye motivos y ultimo_descarte",
		pool.stats().has("motivos") and pool.stats().has("ultimo_descarte"))

	# (e) wiring del director: un pool diminuto fuerza un VFX-SKIP contado
	var director = DIRECTOR.new(POOL.new(2, 5))
	root.add_child(director)
	await process_frame
	_check("disparo rechazado por presupuesto -> false", not director.disparar("bloque_roto", Vector3.ZERO))
	_check("el director cuenta el skip (VFX-SKIP)", director.skips() == 1, "skips=%d" % director.skips())
	_check("el fallo también se cuenta", director.fallos() == 1)
	_check("stats del director expone skips", int(director.stats()["skips"]) == 1)
	director.finalizar()
	director.free()

	# (f) vaciar() resetea los contadores de descarte
	pool.vaciar()
	_check("vaciar resetea motivos", pool.motivos().is_empty() and pool.ultimo_descarte == "")

	for gp in pool.nodos():
		gp.free()
	for gp in pool5.nodos():
		gp.free()
	_fin("F")
