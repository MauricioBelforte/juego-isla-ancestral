extends SceneTree

# Modelo: DS-V4.1-Flash-Opencode (DeepSeek V4.1 Flash)
# Plataforma: OpenCode
# Fecha: 2026-11-08
#
# M17 Construccion — CIRCULACION de la zona (L148) + APOYO de escalera (L143).
#
# POR QUE EXISTE: dos items del 05-Checklist que el validador no podia resolver:
#   * L148 "Las piezas no pueden bloquear la unica salida de la zona de construccion"
#     -> nuevo modelo puro `Circulacion` (BFS 4-direccional) + paso 9 del validador.
#   * L143 "Escalera exige apoyo en piso o pared y no bloquea la circulacion"
#     -> nuevo campo `PlacementRule.apoyo_alternativo` + helper del validador.
#
# QUE MIDE (nucleo real, sin escena ni VoxelTools):
#   A. Modelo `Circulacion.analizar` (16 checks): sin datos, salida tapada, dos
#      salidas que se desconectan, una salida que queda aislada, pieza fuera de la
#      zona, salida ya aislada ANTES por una pieza previa (no se culpa a la nueva),
#      componentes y celdas libres antes/despues, atajo `bloquea()` y determinismo.
#   B. Integracion con `ConstruccionValidator` (7 checks): sin `ctx["circulacion"]`
#      no bloquea (compatibilidad con contextos parciales), con circulacion que
#      bloquea devuelve el motivo `BLOQUEA_SALIDA`, con huella 2x1 se evalua la
#      huella COMPLETA (no solo el ancla) y un valor invalido se ignora sin romper.
#   C. Escalera / apoyo alternativo (12 checks): las dos recetas reales declaran
#      `["pared"]`, el validador acepta piso normal, acepta pared contigua sin
#      piso, rechaza sin piso ni pared, una receta SIN `apoyo_alternativo` NO usa
#      la pared como apoyo (regresion), round-trip `a_dict`/`desde_dict` y la
#      huella 2x1 busca apoyo junto a cualquiera de sus celdas.
#
# ANTI-FALSO-VERDE: cada check es falsable. El piso del runner (CHECKS_MINIMOS) es
# un piso declarado; si el conteo cae por debajo, el runner falla aunque no haya
# un solo check en rojo. Un fallo => exit 1.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://tests/test_m17_circulacion.gd
# Exit: 0 = verde medido | 1 = fallos

const MODULO := "M17 construccion: circulacion de zona + apoyo de escalera"
const CIRC := preload("res://scripts/construccion/circulacion.gd")
const VAL := preload("res://scripts/construccion/construccion_validator.gd")
const TIPOS := preload("res://scripts/construccion/construccion_tipos.gd")
const REGLA := preload("res://scripts/construccion/placement_rule.gd")
const CATALOGO := preload("res://scripts/construccion/build_catalog_db.gd")
const CHECKS_MINIMOS := 35

var _checks := 0
var _fallos := 0
var _detalles: Array[String] = []


func _initialize() -> void:
	var w := Timer.new()
	w.wait_time = 120.0
	w.one_shot = true
	w.timeout.connect(func() -> void:
		print("WATCHDOG: el suite excedio 120 s -> salida forzada con codigo 1")
		quit(1))
	root.add_child(w)
	w.start()
	call_deferred("_correr")


func _check(nombre: String, ok: bool, detalle: String = "") -> void:
	_checks += 1
	if ok:
		print("  [ok]   %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])
	else:
		_fallos += 1
		_detalles.append(nombre + (" (" + detalle + ")" if detalle != "" else ""))
		print("  [FAIL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])


## Pasillo recto de celdas en y/z fijos, x de `x0` a `x1` inclusive.
func _pasillo(x0: int, x1: int, y: int = 0, z: int = 0) -> Array:
	var out: Array = []
	for x in range(x0, x1 + 1):
		out.append(Vector3i(x, y, z))
	return out


## Contexto del validador. `pared` = celdas con superficie "pared"; `piso` = hay
## terreno debajo de y=0; `circ` = valor de `ctx["circulacion"]` (null = ausente).
func _ctx(pared: Array = [], piso: bool = true, circ: Variant = null) -> Dictionary:
	var sup := func(c: Vector3i) -> StringName:
		if piso and c.y < 0:
			return &"terreno"
		if pared.has(c):
			return &"pared"
		return &"aire"
	var ctx: Dictionary = VAL.contexto(
		func(_c): return false,
		sup,
		func(_c): return false,
		func(_c): return true,
		func(_c): return TIPOS.Permiso.EDIFICABLE)
	if circ != null:
		ctx["circulacion"] = circ
	return ctx


func _ok(res: Dictionary) -> bool:
	return bool(res.get("ok", false))


func _motivos(res: Dictionary) -> Array:
	return res.get("motivos", []) as Array


func _detalle_texto(res: Dictionary) -> String:
	var partes: Array = res.get("detalle", []) as Array
	var out: String = ""
	for p in partes:
		out += String(p) + " | "
	return out


func _correr() -> void:
	# ═══════════════════════════════════════════════════════════════════════
	# A. MODELO PURO DE CIRCULACION (L148)
	# ═══════════════════════════════════════════════════════════════════════
	print("── A. Circulacion: modelo puro ─────────────────────────────────")

	var sin_zona: Dictionary = CIRC.analizar([], [Vector3i(0, 0, 0)], [], [Vector3i(0, 0, 0)])
	_check("A1 zona vacia -> sin_datos y NO bloquea",
		bool(sin_zona.get("sin_datos", false)) and not bool(sin_zona.get("bloquea", true)),
		String(sin_zona.get("motivo", "")))

	var sin_salidas: Dictionary = CIRC.analizar(_pasillo(0, 4), [], [], [Vector3i(2, 0, 0)])
	_check("A2 sin salidas -> sin_datos y NO bloquea",
		bool(sin_salidas.get("sin_datos", false)) and not bool(sin_salidas.get("bloquea", true)),
		String(sin_salidas.get("motivo", "")))

	# Pasillo de 9 celdas con salida en cada extremo.
	var zona: Array = _pasillo(0, 8)
	var salidas: Array = [Vector3i(0, 0, 0), Vector3i(8, 0, 0)]

	var corte: Dictionary = CIRC.analizar(zona, salidas, [], [Vector3i(4, 0, 0)])
	_check("A3 pieza en el medio de un pasillo de 2 salidas -> BLOQUEA",
		bool(corte.get("bloquea", false)), String(corte.get("motivo", "")))
	_check("A4 el motivo de A3 habla de aislar salidas",
		String(corte.get("motivo", "")).contains("aisla"), String(corte.get("motivo", "")))
	_check("A5 A3 aisla las DOS salidas (0,0,0) y (8,0,0)",
		(corte.get("salidas_aisladas", []) as Array).size() == 2,
		str(corte.get("salidas_aisladas", [])))
	_check("A6 celdas libres 9 antes / 8 despues (solo se resta la pieza)",
		int(corte.get("celdas_libres_antes", -1)) == 9 and int(corte.get("celdas_libres_despues", -1)) == 8,
		"%s -> %s" % [str(corte.get("celdas_libres_antes")), str(corte.get("celdas_libres_despues"))])
	_check("A7 el corte parte la zona en 2 componentes",
		int(corte.get("componentes_antes", -1)) == 1 and int(corte.get("componentes_despues", -1)) == 2,
		"%s -> %s" % [str(corte.get("componentes_antes")), str(corte.get("componentes_despues"))])

	var tapada: Dictionary = CIRC.analizar(zona, salidas, [], [Vector3i(0, 0, 0)])
	_check("A8 pieza justo sobre una salida -> BLOQUEA",
		bool(tapada.get("bloquea", false)), String(tapada.get("motivo", "")))
	_check("A9 A8 reporta exactamente 1 salida tapada y es la pieza",
		(tapada.get("salidas_tapadas", []) as Array).size() == 1
			and (tapada.get("salidas_tapadas", []) as Array).has(Vector3i(0, 0, 0)),
		str(tapada.get("salidas_tapadas", [])))

	var fuera: Dictionary = CIRC.analizar(zona, salidas, [], [Vector3i(4, 0, 5)])
	_check("A10 pieza FUERA de la zona -> NO bloquea",
		not bool(fuera.get("bloquea", true)) and int(fuera.get("celdas_libres_despues", -1)) == 9,
		String(fuera.get("motivo", "")))

	var una: Array = [Vector3i(0, 0, 0)]
	var aislada: Dictionary = CIRC.analizar(zona, una, [], [Vector3i(1, 0, 0)])
	_check("A11 unica salida, pieza contigua -> la deja AISLADA y bloquea",
		bool(aislada.get("bloquea", false)) and (aislada.get("salidas_aisladas", []) as Array).has(Vector3i(0, 0, 0)),
		String(aislada.get("motivo", "")))

	var raja: Dictionary = CIRC.analizar(zona, una, [], [Vector3i(4, 0, 0)])
	_check("A12 unica salida, pieza lejos -> sigue conectada y NO bloquea",
		not bool(raja.get("bloquea", true)), String(raja.get("motivo", "")))

	var ya_aislada: Dictionary = CIRC.analizar(zona, salidas, [Vector3i(1, 0, 0)], [Vector3i(4, 0, 0)])
	_check("A13 salida ya aislada ANTES por otra pieza -> no se culpa a la nueva",
		not bool(ya_aislada.get("bloquea", true)), String(ya_aislada.get("motivo", "")))

	var cuadro: Array = []
	for x in range(3):
		for z in range(3):
			cuadro.append(Vector3i(x, 0, z))
	var esquinero: Dictionary = CIRC.analizar(cuadro, [Vector3i(0, 0, 0)], [], [Vector3i(2, 0, 2)])
	_check("A14 pieza en la esquina opuesta de un 3x3 -> NO bloquea",
		not bool(esquinero.get("bloquea", true)), String(esquinero.get("motivo", "")))

	var atajo_si: bool = CIRC.bloquea(zona, salidas, [], [Vector3i(4, 0, 0)])
	var atajo_no: bool = CIRC.bloquea(zona, salidas, [], [Vector3i(4, 0, 5)])
	_check("A15 el atajo bloquea() coincide con analizar()",
		atajo_si and not atajo_no, "si=%s no=%s" % [str(atajo_si), str(atajo_no)])

	var d1: Dictionary = CIRC.analizar(zona, salidas, [], [Vector3i(4, 0, 0)])
	var d2: Dictionary = CIRC.analizar(zona, salidas, [], [Vector3i(4, 0, 0)])
	_check("A16 dos llamadas identicas dan el mismo resultado (determinista)",
		String(d1.get("motivo", "")) == String(d2.get("motivo", ""))
			and (d1.get("salidas_aisladas", []) as Array).size() == (d2.get("salidas_aisladas", []) as Array).size()
			and int(d1.get("componentes_despues", -1)) == int(d2.get("componentes_despues", -1)),
		"%s vs %s" % [String(d1.get("motivo", "")), String(d2.get("motivo", ""))])

	# ═══════════════════════════════════════════════════════════════════════
	# B. INTEGRACION CON EL VALIDADOR (paso 9)
	# ═══════════════════════════════════════════════════════════════════════
	print("── B. Validador: paso de circulacion ───────────────────────────")

	var cat = CATALOGO.new()
	var n_cat: int = int(cat.cargar("res://data/construccion/piezas"))
	_check("B0 el catalogo real carga (>= 40 recetas)", n_cat >= 40, "recetas=%d" % n_cat)

	var r_pared = REGLA.desde_dict({
		"id": "test_circ_pared",
		"nombre": "Test pared circulacion",
		"familia": "pared",
		"superficie_ok": ["terreno", "piso", "techo"],
		"costo": {"planks": 1},
	})

	var sin_ctx: Dictionary = VAL.validar(r_pared, Vector3i(4, 0, 0), 0, _ctx())
	_check("B1 sin ctx[circulacion] el paso NO corre (compatibilidad)",
		_ok(sin_ctx) and not _motivos(sin_ctx).has(TIPOS.Motivo.BLOQUEA_SALIDA),
		_detalle_texto(sin_ctx))

	var cfg_corte: Dictionary = {"zona": zona, "salidas": salidas, "ocupadas": []}
	var con_ctx: Dictionary = VAL.validar(r_pared, Vector3i(4, 0, 0), 0, _ctx([], true, cfg_corte))
	_check("B2 con circulacion que bloquea devuelve el motivo BLOQUEA_SALIDA",
		not _ok(con_ctx) and _motivos(con_ctx).has(TIPOS.Motivo.BLOQUEA_SALIDA),
		_detalle_texto(con_ctx))
	_check("B3 el detalle nombra la circulacion y el motivo legible",
		_detalle_texto(con_ctx).contains("circulacion")
			and _detalle_texto(con_ctx).contains("aisla"),
		_detalle_texto(con_ctx))

	var cfg_libre: Dictionary = {"zona": cuadro, "salidas": [Vector3i(0, 0, 0)], "ocupadas": []}
	var libre: Dictionary = VAL.validar(r_pared, Vector3i(2, 0, 2), 0, _ctx([], true, cfg_libre))
	_check("B4 con circulacion que NO bloquea la colocacion sigue siendo ok",
		_ok(libre) and not _motivos(libre).has(TIPOS.Motivo.BLOQUEA_SALIDA),
		_detalle_texto(libre))

	# La huella 2x1 de la escalera doble tapa el pasillo en (3,0,0)+(4,0,0):
	# si el validador evaluara solo el ancla, el pasillo seguiria conectado por
	# la segunda celda y este check caeria en falso.
	var esc_doble = cat.receta(&"escalera_doble")
	var huella: Dictionary = VAL.validar(esc_doble, Vector3i(3, 0, 0), 0, _ctx([], true, cfg_corte))
	_check("B5 la huella 2x1 se evalua COMPLETA (tapa el pasillo y bloquea)",
		not _ok(huella) and _motivos(huella).has(TIPOS.Motivo.BLOQUEA_SALIDA),
		_detalle_texto(huella))

	_check("B6 el texto del motivo es el esperado para el jugador",
		TIPOS.texto(TIPOS.Motivo.BLOQUEA_SALIDA) == "taparia la unica salida de la zona",
		TIPOS.texto(TIPOS.Motivo.BLOQUEA_SALIDA))

	var basura: Dictionary = VAL.validar(r_pared, Vector3i(4, 0, 0), 0, _ctx([], true, "no-es-un-dict"))
	_check("B7 un ctx[circulacion] con tipo invalido se ignora sin romper",
		_ok(basura) and not _motivos(basura).has(TIPOS.Motivo.BLOQUEA_SALIDA),
		_detalle_texto(basura))

	# ═══════════════════════════════════════════════════════════════════════
	# C. ESCALERA: APOYO EN PISO O PARED (L143)
	# ═══════════════════════════════════════════════════════════════════════
	print("── C. Escalera: apoyo alternativo ──────────────────────────────")

	var r_recta = cat.receta(&"escalera_recta")
	_check("C1 escalera_recta declara apoyo_alternativo [pared]",
		r_recta != null and r_recta.apoyo_alternativo.size() == 1
			and r_recta.apoyo_alternativo.has(&"pared"),
		str(r_recta.apoyo_alternativo) if r_recta != null else "receta ausente")

	_check("C2 escalera_doble declara apoyo_alternativo [pared]",
		esc_doble != null and esc_doble.apoyo_alternativo.size() == 1
			and esc_doble.apoyo_alternativo.has(&"pared"),
		str(esc_doble.apoyo_alternativo) if esc_doble != null else "receta ausente")

	var con_piso: Dictionary = VAL.validar(r_recta, Vector3i(2, 0, 2), 0, _ctx([], true))
	_check("C3 escalera con piso debajo -> ok por soporte normal",
		_ok(con_piso) and not _motivos(con_piso).has(TIPOS.Motivo.SIN_SOPORTE),
		_detalle_texto(con_piso))

	var pared_vecina: Array = [Vector3i(3, 0, 2)]
	var con_pared: Dictionary = VAL.validar(r_recta, Vector3i(2, 0, 2), 0, _ctx(pared_vecina, false))
	_check("C4 escalera SIN piso pero con pared contigua -> ok por apoyo alternativo",
		_ok(con_pared) and not _motivos(con_pared).has(TIPOS.Motivo.SIN_SOPORTE),
		_detalle_texto(con_pared))

	var sin_nada: Dictionary = VAL.validar(r_recta, Vector3i(2, 0, 2), 0, _ctx([], false))
	_check("C5 escalera sin piso ni pared -> SIN_SOPORTE",
		not _ok(sin_nada) and _motivos(sin_nada).has(TIPOS.Motivo.SIN_SOPORTE),
		_detalle_texto(sin_nada))

	_check("C6 tiene_apoyo_alternativo() true con pared / false sin nada",
		VAL.tiene_apoyo_alternativo(r_recta, Vector3i(2, 0, 2), 0, _ctx(pared_vecina, false))
			and not VAL.tiene_apoyo_alternativo(r_recta, Vector3i(2, 0, 2), 0, _ctx([], false)),
		"")

	_check("C7 tiene_apoyo_alternativo() es false si el ctx no trae 'superficie'",
		not VAL.tiene_apoyo_alternativo(r_recta, Vector3i(2, 0, 2), 0, {}), "")

	var r_sin_alt = REGLA.desde_dict({
		"id": "test_sin_alternativo",
		"nombre": "Test piso sin alternativo",
		"familia": "piso",
		"superficie_ok": ["terreno", "piso"],
	})
	var regresion: Dictionary = VAL.validar(r_sin_alt, Vector3i(2, 0, 2), 0, _ctx(pared_vecina, false))
	_check("C8 una receta SIN apoyo_alternativo NO acepta pared como apoyo (regresion)",
		not _ok(regresion) and _motivos(regresion).has(TIPOS.Motivo.SIN_SOPORTE),
		_detalle_texto(regresion))

	var dict_rt: Dictionary = r_recta.a_dict()
	var clon = REGLA.desde_dict(dict_rt)
	_check("C9 round-trip a_dict -> desde_dict conserva apoyo_alternativo",
		clon != null and clon.apoyo_alternativo.size() == 1
			and clon.apoyo_alternativo.has(&"pared"),
		str(clon.apoyo_alternativo) if clon != null else "clon nulo")

	var r_dos = REGLA.desde_dict({
		"id": "test_dos_alternativos",
		"apoyo_alternativo": ["pared", "techo"],
	})
	_check("C10 desde_dict acepta varios apoyos alternativos",
		r_dos.apoyo_alternativo.size() == 2 and r_dos.apoyo_alternativo.has(&"pared")
			and r_dos.apoyo_alternativo.has(&"techo"),
		str(r_dos.apoyo_alternativo))

	var aad: Variant = dict_rt.get("apoyo_alternativo", null)
	_check("C11 a_dict serializa apoyo_alternativo como strings",
		aad is Array and (aad as Array).size() == 1 and String((aad as Array)[0]) == "pared",
		str(aad))

	# Huella 2x1: la pared esta junto a la SEGUNDA celda, no junto al ancla.
	var segunda_celda: Array = [Vector3i(6, 0, 1)]
	var apoyo_2x1: Dictionary = VAL.validar(esc_doble, Vector3i(5, 0, 0), 0, _ctx(segunda_celda, false))
	_check("C12 huella 2x1: el apoyo se busca junto a CUALQUIERA de sus celdas",
		_ok(apoyo_2x1) and not _motivos(apoyo_2x1).has(TIPOS.Motivo.SIN_SOPORTE),
		_detalle_texto(apoyo_2x1))

	# ═══════════════════════════════════════════════════════════════════════
	# Resumen
	# ═══════════════════════════════════════════════════════════════════════
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	for d in _detalles:
		print("  FALLO: " + d)
	if _fallos > 0 or _checks < CHECKS_MINIMOS:
		print("TEST %s FALLIDO (checks=%d, minimo=%d)" % [MODULO, _checks, CHECKS_MINIMOS])
		quit(1)
	else:
		print("TEST %s OK — la circulacion y el apoyo de escalera quedan medidos en headless" % MODULO)
		quit(0)
