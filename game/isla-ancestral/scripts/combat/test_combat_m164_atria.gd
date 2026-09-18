# Modelo: Atria-Dawn-Preview
# Plataforma: Kilo Code
# Fecha: 2026-09-18
#
# M164 (iter. 1 — parte data-driven): test headless del nucleo de la Isla
# de Combate. Cubre GemCurrency (seccion B), catalogo de enemigos (D),
# zonas y desbloqueo (C), recompensas (F) y persistencia (H).
# Guardian anti-falso-verde: marcador _fin por bloque + aserciones con
# cotas min Y max (leccion del doble-entrega de drops de M15).
#
# Ejecutar: Godot --headless --path game/isla-ancestral \
#   --script res://scripts/combat/test_combat_m164_atria.gd
extends SceneTree

var _fallos: int = 0
var _fin: Dictionary = {}   # bloque -> bool (guardian: cada bloque debe llegar al final)

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_gem_currency()
	_test_catalogo_enemigos()
	_test_zonas_desbloqueo()
	_test_recompensas_persistencia()
	_verificar_guardian()
	print("=== TEST M164 COMBAT: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, mensaje: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: %s" % mensaje)

func _bloque_fin(nombre: String) -> void:
	_fin[nombre] = true

func _verificar_guardian() -> void:
	# Si algun bloque no marco su _fin, el test es falso-verde (se salto).
	for b in ["gemas", "catalogo", "zonas", "recompensas"]:
		_check(_fin.get(b, false), "guardian: bloque %s no completo" % b)

# ── B. Sistema de gemas ──────────────────────────────────────────────

func _test_gem_currency() -> void:
	var g := GemCurrency.new()
	# B.27-B.30: API basica
	_check(g.get_gems() == 0, "gemas inician en 0")
	_check(g.has_gems(0), "has_gems(0) true en 0")
	_check(not g.has_gems(1), "has_gems(1) false en 0")
	g.add_gems(10, "combate")
	_check(g.get_gems() == 10, "add_gems(10) -> 10")
	_check(g.has_gems(10), "has_gems(10) true")
	_check(not g.has_gems(11), "has_gems(11) false")
	# spend con saldo insuficiente NO gasta
	_check(not g.spend_gems(11, "test"), "spend_gems(11) rechazado")
	_check(g.get_gems() == 10, "saldo intacto tras gasto rechazado")
	_check(g.spend_gems(3, "desbloqueo"), "spend_gems(3) aceptado")
	_check(g.get_gems() == 7, "7 gemas tras gasto")
	# add_gems negativo o 0 no cambia
	g.add_gems(-5)
	_check(g.get_gems() == 7, "add_gems(-5) ignorado")
	g.add_gems(0)
	_check(g.get_gems() == 7, "add_gems(0) ignorado")
	# B.44/B.45: nunca negativo
	g.spend_gems(7)
	_check(g.get_gems() == 0, "gasto total -> 0")
	g.spend_gems(1)
	_check(g.get_gems() == 0, "gasto con 0 saldo -> sigue 0 (nunca negativo)")
	# B.33-B.36: valor de cambio por tier
	_check(GemCurrency.valor_cambio_por_tier(1) == 1, "tier 1 -> 1 gema")
	_check(GemCurrency.valor_cambio_por_tier(2) == 2, "tier 2 -> 2 gemas")
	_check(GemCurrency.valor_cambio_por_tier(3) == 3, "tier 3 -> 3 gemas")
	_check(GemCurrency.valor_cambio_por_tier(4) == 5, "tier 4 -> 5 gemas")
	_check(GemCurrency.valor_cambio_por_tier(99) == 0, "tier invalido -> 0")
	# B.37-B.40: rangos por categoria
	var r0 := GemCurrency.rango_gemas_categoria(0)
	_check(r0.x == 1 and r0.y == 2, "basico 1-2")
	var r3 := GemCurrency.rango_gemas_categoria(3)
	_check(r3.x == 5 and r3.y == 15, "jefe 5-15")
	# Persistencia round-trip (H)
	var datos := g.get_save_data()
	var g2 := GemCurrency.new()
	g2.restore_save_data(datos)
	_check(g2.get_gems() == 0, "restore round-trip")
	# version antigua no sobreescribe
	var g3 := GemCurrency.new()
	g3.add_gems(5)
	g3.restore_save_data({"version": 0, "gemas": 999})
	_check(g3.get_gems() == 5, "version 0 ignorada (no sobreescribe)")
	_bloque_fin("gemas")

# ── D. Catalogo de enemigos ──────────────────────────────────────────

func _test_catalogo_enemigos() -> void:
	var cat := EnemyCatalog.new()
	_check(cat.cantidad() == 11, "catalogo tiene 11 enemigos (9 + 2 jefes)")
	_check(cat.todas_validas(), "todos los EnemyData validos (bosses con fases coherentes)")
	# D.1-D.3 Costa
	_check(cat.obtener("slime_verde") != null, "slime_verde existe")
	_check(cat.obtener("slime_verde").hp_max == 3, "slime 3 HP")
	_check(cat.obtener("cangrejo_roca").gem_reward == 2, "cangrejo 2 gemas")
	# D.4-D.6 Bosque
	_check(cat.obtener("arbol_maldito").attack == 2, "arbol 2 ataque")
	_check(cat.obtener("lobo_sombra").hp_max == 6, "lobo 6 HP")
	# D.7-D.9 Montana
	_check(cat.obtener("troll_montana").hp_max == 15, "troll 15 HP")
	_check(cat.obtener("golem_piedra").attack == 4, "golem 4 ataque")
	# D.10-D.11 Jefes
	var guardian := cat.obtener("guardian_montana") as BossData
	_check(guardian != null, "guardian_montana existe")
	_check(guardian.phases == 3, "guardian 3 fases")
	_check(guardian.gem_reward == 8, "guardian 8 gemas")
	var senor := cat.obtener("senor_del_templo") as BossData
	_check(senor != null, "senor_del_templo existe")
	_check(senor.phases == 4, "senor 4 fases")
	_check(senor.hp_max == 50, "senor 50 HP")
	_check(senor.phase_thresholds.size() == 3, "senor 3 umbrales")
	_check(senor.es_valido_jefe(), "senor esquema jefe valido")
	# id inexistente
	_check(cat.obtener("no_existe") == null, "id inexistente -> null")
	# verificacion de categoria vs rango de gemas (consistencia B<->D)
	var d := cat.obtener("slime_verde")
	var rng := GemCurrency.rango_gemas_categoria(int(d.categoria))
	_check(d.gem_reward >= rng.x and d.gem_reward <= rng.y, "slime: gema en rango de su categoria")
	_bloque_fin("catalogo")

# ── C. Zonas y desbloqueo ────────────────────────────────────────────

func _test_zonas_desbloqueo() -> void:
	var s := CombatIslandSystem.new()
	# El test instancia sin arbol -> _ready no corre; cargar catalogo a mano.
	s.cargar_catalogo_para_test()
	# C.1: costa acceso gratis
	_check(s.can_access_zone("costa"), "costa accesible gratis")
	_check(not s.can_access_zone("templo"), "templo NO accesible al inicio")
	# desbloqueo sin gemas falla
	_check(not s.unlock_zone("templo"), "unlock templo sin gemas -> false")
	# gemas: usar el autoload real del arbol si existe (unlock_zone lo
	# busca ahi); si no, colgar el nuestro (patron M13/M36 duck-typed).
	var root := get_root()
	var gc = root.get_node_or_null("gem_currency")
	if gc == null:
		gc = GemCurrency.new()
		gc.name = "gem_currency"
		root.add_child(gc)
	# snapshot para restaurar al final (no dejar basura en el autoload)
	var gemas_antes: int = gc.get_gems()
	gc.add_gems(10)
	_check(s.unlock_zone("bosque"), "unlock bosque con 10 gemas")
	_check(s.can_access_zone("bosque"), "bosque accesible tras unlock")
	_check(gc.get_gems() == gemas_antes, "10 gemas gastadas en bosque")
	# C.13: permanente (re-unlock no cobra)
	_check(s.unlock_zone("bosque"), "re-unlock bosque ok")
	_check(gc.get_gems() == gemas_antes, "re-unlock NO cobra de nuevo (permanente)")
	# zona inexistente
	_check(not s.unlock_zone("no_existe"), "zona inexistente -> false")
	# zonas ordenadas por coste
	var orden := s.zonas_ordenadas()
	_check(orden.size() == 4, "4 zonas en el catalogo")
	var coste_ok := true
	for i in range(1, orden.size()):
		if orden[i - 1].gem_cost > orden[i].gem_cost:
			coste_ok = false
	_check(coste_ok, "zonas ordenadas por coste asc")
	_check(s.zona_obtenida("montana").gem_cost == 25, "montana cuesta 25")
	_check(s.zona_obtenida("templo").gem_cost == 50, "templo cuesta 50")
	# restaurar el saldo del autoload (no liberar el global)
	if gemas_antes == 0:
		gc.spend_gems(gc.get_gems())
	_bloque_fin("zonas")

# ── F/H. Recompensas y persistencia ──────────────────────────────────

func _test_recompensas_persistencia() -> void:
	var s := CombatIslandSystem.new()
	s.cargar_catalogo_para_test()
	# H.1-H.3: conteo de derrotas
	s.registrar_derrota("slime_verde")
	s.registrar_derrota("slime_verde")
	_check(s.total_derrotas("slime_verde") == 2, "2 slimes derrotados")
	_check(s.total_enemigos_derrotados() == 2, "total 2 derrotas")
	s.registrar_derrota("guardian_montana")
	_check(s.jefe_derrotado("guardian_montana"), "jefe marcado como derrotado")
	_check(s.total_enemigos_derrotados() == 3, "total 3 derrotas")
	# F: recompensas cosméticas
	_check(not s.tiene_recompensa("skin_guerrero_ancestral"), "skin no obtenida al inicio")
	s.otorgar_recompensa("skin_guerrero_ancestral")
	_check(s.tiene_recompensa("skin_guerrero_ancestral"), "skin obtenida")
	_check(s.recompensas_obtenidas().size() == 1, "1 recompensa en lista")
	# F.3: titulo a los 100 enemigos (hitos M71)
	for i in 100:
		s.registrar_derrota("murcielago_noche")
	_check(s.tiene_recompensa("titulo_cazador_de_cristal"), "titulo tras 100 derrotas")
	# H: persistencia round-trip
	var datos := s.get_save_data()
	var s2 := CombatIslandSystem.new()
	s2.restore_save_data(datos)
	_check(s2.can_access_zone("bosque") == s.can_access_zone("bosque"), "restore: zonas")
	_check(s2.total_derrotas("guardian_montana") == 1, "restore: derrotas jefe")
	_check(s2.tiene_recompensa("titulo_cazador_de_cristal"), "restore: recompensas")
	# version antigua ignorada
	var s3 := CombatIslandSystem.new()
	s3.otorgar_recompensa("skin_senor_del_templo")
	s3.restore_save_data({"version": 0})
	_check(s3.tiene_recompensa("skin_senor_del_templo"), "version 0 no sobreescribe recompensas")
	# porcentaje
	var pct := s.porcentaje_completado()
	_check(pct >= 0.0 and pct <= 1.0, "porcentaje en rango 0-1")
	# recompensas por defecto (F.1-F.6)
	var recs := CombatReward.recompensas_por_defecto()
	_check(recs.size() == 6, "6 recompensas exclusivas")
	for r in recs:
		_check(r.es_valido(), "recompensa %s valida" % r.id)
	_check(recs[0].tipo == CombatReward.Tipo.SKIN, "primera recompensa es skin")
	_check(recs[2].tipo == CombatReward.Tipo.TITULO, "tercera es titulo")
	_bloque_fin("recompensas")
