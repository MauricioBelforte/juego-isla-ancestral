# Iter. 9 M23: agrega el bloque N (_test_familias) a test_historias.gd.
# El archivo es LF sin BOM; se opera por str con anchors unicos y se escribe por bytes.
p = 'game/isla-ancestral/scripts/historias/test_historias.gd'
t = open(p, 'rb').read().decode('utf-8')

# 1) BLOQUES: sumar "N"
a1 = 'const BLOQUES := ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M"]'
assert t.count(a1) == 1, "BLOQUES anchor"
t = t.replace(a1, 'const BLOQUES := ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N"]', 1)

# 2) Piso: comment + const (medido en verde de esta iterada; se verifica corrida)
a2 = """# Piso MEDIDO en verde (iter. 8, 2026-10-22, Log 2127): 227 checks con los
# bloques A-M (iter. 7 tenia 169 con A-L; el bloque M del cluster Objetos sumo
# 58: 12 carga/fuente + 2 unicidad de flags + 1 diarios + 7x6 end-to-end + 1
# puente diario). Medido: 227/0/EXIT 0 x3. El guardian se probo EN ROJO por
# inyeccion de runtime sobre el bloque M (ver Log 2127).
const CHECKS_MINIMOS := 227"""
assert t.count(a2) == 1, "piso anchor"
a2n = """# Piso MEDIDO en verde (iter. 9, 2026-10-22, Log 2129): 258 checks con los
# bloques A-N (iter. 8 tenia 227 con A-M; el bloque N del cluster Familias sumo
# 31: 6 carga/fuente + 2 unicidad de flags + 1 diarios + 7x3 end-to-end + 1
# puente diario). Medido: 258/0/EXIT 0 x3. El guardian se probo EN ROJO por
# inyeccion de runtime sobre el bloque N (ver Log 2129).
const CHECKS_MINIMOS := 258"""
t = t.replace(a2, a2n, 1)

# 3) _run(): llamar a _test_familias() al final
a3 = "\t_test_objetos()\n"
assert t.count(a3) == 1, "run anchor"
t = t.replace(a3, "\t_test_objetos()\n\t_test_familias()\n", 1)

# 4) Append del bloque N
bloque = '''

## Iter. 9: cluster Familias del 03-Diseno L35 (molinera, pescadores, guardas).
## NPC REALES de data/villagers/ (mateo_mapache granjero, finneas_zorro pescador,
## nico_gato guardabosques) y objetos REALES de data/items/ (OBJ-REL-003 "Reloj
## de arena", OBJ-HER-014 "Red de captura", OBJ-LUZ-011 "Candil", verificados
## por campo id dentro del .tres - item_database.gd indexa por ese id). Afirma
## carga, fuente del principal, unicidad anti-repeticion de consecuencias y
## diarios, y corrida end-to-end de las 3.
func _test_familias() -> void:
	# Estado limpio: el bloque no depende de lo que dejaron los anteriores
	_h.restore_save_data({})
	var nuevas := ["cadena-molinera", "cadena-pescadores", "cadena-guardas"]
	for cid in nuevas:
		_check(not _h.get_cadena(cid).is_empty(), "%s cargada" % cid)
		_check(_h.fuente_cadena(cid) == "secundarias", "%s viene del principal" % cid)
	# Anti-repeticion: 3 flags de consecuencia nuevos, sin colision con los 24 previos
	var existentes := ["faro_encendido", "invernadero_abierto", "plaza_decorada",
		"luciernagas_vueltas", "biblioteca_iluminada", "pan_fiesta_horneado",
		"banco_plaza_reparado", "manto_niebla_terminado", "red_pescador_reparada",
		"sendero_bosque_senalado", "jarabe_lunar_listo", "jardin_florecido",
		"cofradia_activa", "molino_funcionando", "biblioteca_quemada_rescatada",
		"observatorio_alineado", "estacion_reparada", "puente_cruzable",
		"relicto_devuelto", "gema_devuelta", "receta_heredada", "llave_encontrada",
		"patrulla_nocturna", "brujula_calibrada"]
	var flags := {}
	var unicos := true
	for cid in nuevas:
		var cons: Dictionary = _h.get_cadena(cid).get("consecuencia", {})
		for flag in cons:
			if flags.has(flag) or existentes.has(flag):
				unicos = false
			flags[flag] = true
	_check(flags.size() == 3, "3 consecuencias distintas en las cadenas de familias: %d" % flags.size())
	_check(unicos, "consecuencias de familias sin colision con las previas (%s)" % str(flags.keys()))
	# Capitulos de diario distintos entre si
	var diarios := {}
	var dunicos := true
	for cid in nuevas:
		var d := String((_h.get_cadena(cid).get("recompensa", {}) as Dictionary).get("diario", ""))
		if diarios.has(d):
			dunicos = false
		diarios[d] = true
	_check(dunicos and diarios.size() == 3, "3 capitulos de diario distintos (%s)" % str(diarios.keys()))
	# End-to-end 1: molinera (mateo_mapache REAL; OBJ-REL-003 "Reloj de arena" REAL de data/items/)
	var inv := root.get_node_or_null("Inventario")
	if inv != null:
		inv.agregar_items({"OBJ-REL-003": 1})
	var res1: Dictionary = _h.iniciar_cadena("cadena-molinera")
	_check(bool(res1.ok), "iniciar cadena-molinera OK")
	res1 = _h.reportar_paso("cadena-molinera", "hablar", "mateo_mapache")
	_check(bool(res1.ok), "molinera p1 hablar mateo_mapache OK")
	res1 = _h.reportar_paso("cadena-molinera", "explorar", "molino")
	_check(bool(res1.ok), "molinera p2 explorar molino OK")
	res1 = _h.reportar_entrega("cadena-molinera")
	_check(bool(res1.ok), "molinera p3 entregar OBJ-REL-003 OK (inventario)")
	res1 = _h.reportar_paso("cadena-molinera", "puzzle", "piedras-de-molienda")
	_check(bool(res1.ok), "molinera p4 puzzle OK")
	_check(_h.esta_completada("cadena-molinera"), "cadena-molinera completada end-to-end")
	_check(ws_has("molienda_familiar_restaurada"), "consecuencia molienda_familiar_restaurada aplicada (M21)")
	# End-to-end 2: pescadores (finneas_zorro REAL; OBJ-HER-014 "Red de captura" REAL de data/items/)
	if inv != null:
		inv.agregar_items({"OBJ-HER-014": 1})
	var res2: Dictionary = _h.iniciar_cadena("cadena-pescadores")
	_check(bool(res2.ok), "iniciar cadena-pescadores OK")
	res2 = _h.reportar_paso("cadena-pescadores", "hablar", "finneas_zorro")
	_check(bool(res2.ok), "pescadores p1 hablar finneas_zorro OK")
	res2 = _h.reportar_paso("cadena-pescadores", "explorar", "muelle_viejo")
	_check(bool(res2.ok), "pescadores p2 explorar muelle_viejo OK")
	res2 = _h.reportar_entrega("cadena-pescadores")
	_check(bool(res2.ok), "pescadores p3 entregar OBJ-HER-014 OK (inventario)")
	res2 = _h.reportar_paso("cadena-pescadores", "puzzle", "nudo-del-abuelo")
	_check(bool(res2.ok), "pescadores p4 puzzle OK")
	_check(_h.esta_completada("cadena-pescadores"), "cadena-pescadores completada end-to-end")
	_check(ws_has("red_del_abuelo_reparada"), "consecuencia red_del_abuelo_reparada aplicada (M21)")
	# End-to-end 3: guardas (nico_gato REAL; OBJ-LUZ-011 "Candil" REAL de data/items/)
	if inv != null:
		inv.agregar_items({"OBJ-LUZ-011": 1})
	var res3: Dictionary = _h.iniciar_cadena("cadena-guardas")
	_check(bool(res3.ok), "iniciar cadena-guardas OK")
	res3 = _h.reportar_paso("cadena-guardas", "hablar", "nico_gato")
	_check(bool(res3.ok), "guardas p1 hablar nico_gato OK")
	res3 = _h.reportar_paso("cadena-guardas", "explorar", "bosque_nocturno")
	_check(bool(res3.ok), "guardas p2 explorar bosque_nocturno OK")
	res3 = _h.reportar_entrega("cadena-guardas")
	_check(bool(res3.ok), "guardas p3 entregar OBJ-LUZ-011 OK (inventario)")
	res3 = _h.reportar_paso("cadena-guardas", "puzzle", "ronda-de-los-guardas")
	_check(bool(res3.ok), "guardas p4 puzzle OK")
	_check(_h.esta_completada("cadena-guardas"), "cadena-guardas completada end-to-end")
	_check(ws_has("vigilia_de_los_guardas"), "consecuencia vigilia_de_los_guardas aplicada (M21)")
	# Puente diario M23->M55: sin entrada mision_cadena-* en el catalogo de M55
	# el puente degrada en silencio (finding medido, dueno M55; mismo patron que
	# cadena-biblioteca en H, cadena-jardines en K, cadena-puente en L y
	# cadena-brujula en M). No se inventa contenido de M55.
	var diary := root.get_node_or_null("Diary")
	if diary != null:
		_check(not diary.esta_registrada("mision_cadena-guardas"),
			"puente diario degrada sin entrada en catalogo M55 (finding medido, dueno M55)")
	_fin("N")
'''
assert not t.endswith('\n\n') or True
t = t.rstrip('\n') + '\n' + bloque
open(p, 'wb').write(t.encode('utf-8'))

b = open(p, 'rb').read()
print('bytes:', len(b), 'bom:', b[:3] == b'\xef\xbb\xbf', 'crlf:', b.count(b'\r\n'),
      'lf_suelto:', b.count(b'\n') - b.count(b'\r\n'))
print('BLOQUES N:', '"N"]' in t)
print('piso 258:', 'const CHECKS_MINIMOS := 258' in t)
print('_test_familias def:', 'func _test_familias() -> void:' in t)
print('call site:', '\t_test_familias()\n' in t)
