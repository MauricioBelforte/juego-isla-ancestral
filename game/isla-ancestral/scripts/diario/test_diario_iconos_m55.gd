# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-27
#
# M55 (Diario del Jugador) - suite de la ICONOGRAFIA de entradas.
# Cubre los items L93 (iconos de minerales/gemas), L117 (iconografia de Sellos,
# M46) y L203 (icono faltante con fallback).
#
# NO cubre L77/L85 (siluetas de bestiario y hojas): ningun bloque de esta suite
# tiene asercion especifica de siluetas. Esa validacion vive en
# `validate_diary._validar_iconos()`, que exige id de icono derivable para TODA
# entrada (criaturas y plantas incluidas). El encabezado anterior atribuia esa
# cobertura a esta suite; era un overstatement, corregido 2026-10-29 (Log 2240).
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral \
#     --script res://scripts/diario/test_diario_iconos_m55.gd
#
# Guardas anti-falso-verde (3 capas, ver skill isla-ancestral-ciclo-modulo):
#   1. `_fin(bloque)` al FINAL del cuerpo de cada bloque (no en el runner).
#   2. `CHECKS_MINIMOS` = piso MEDIDO en verde (no estimado).
#   3. `_summary()` en un `call_deferred` SEPARADO: si `_run()` aborta por un
#      SCRIPT ERROR, el resumen corre igual, nombra los bloques faltantes y
#      sale con EXIT 1 en vez de colgarse.
#
# Las aserciones son de CONTRATO y de ARITMETICA, no de cifras de contenido:
# el catalogo puede crecer sin poner la suite en rojo por un número viejo.

extends SceneTree

const MODULO := "M55"
const ICONOS := preload("res://scripts/diario/iconos_diario.gd")
const RUTA_CATALOGO := "res://data/diario/diario_catalog.json"
const RUTA_LAYER := "res://scripts/ui/layers/diary_layer.gd"
const RUTA_SERVICE := "res://scripts/diario/diary_service.gd"
const RUTA_INVENTARIO := "res://data/arte2d/inventario_2d.json"

## Bloques esperados (los nombres que usa `_fin`)
const BLOQUES: Array[String] = ["A", "B", "C", "D", "E"]

## Piso MEDIDO en verde: 56 checks (bloques A 14 + B 17 + C 10 + D 11 + E 4).
## Re-medir si la suite crece; nunca estimar.
const CHECKS_MINIMOS: int = 56

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}
var _catalogo: Dictionary = {}


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")  # corre aunque _run() aborte (SCRIPT ERROR)


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("[FALLO] " + msg)


func _fin(bloque: String) -> void:
	_vistos[bloque] = true
	print("[FIN] bloque %s (+%d checks)" % [bloque, _checks])


func _summary() -> void:
	for b in BLOQUES:
		if not _vistos.has(b):
			_checks += 1
			_fallos += 1
			print("[FALLO] el bloque %s NO se ejecutó (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_checks += 1
		_fallos += 1
		print("[FALLO] solo %d checks ejecutados (mínimo medido %d)"
			% [_checks - 1, CHECKS_MINIMOS])
	print("=== Resumen %s iconos: %d checks, %d fallo(s) ===" % [MODULO, _checks, _fallos])
	quit(1 if _fallos > 0 else 0)


func _run() -> void:
	var txt := FileAccess.get_file_as_string(RUTA_CATALOGO)
	_check(not txt.is_empty(), "catálogo legible: " + RUTA_CATALOGO)
	var parseado: Variant = JSON.parse_string(txt)
	_check(typeof(parseado) == TYPE_DICTIONARY, "catálogo parsea como Dictionary")
	if typeof(parseado) == TYPE_DICTIONARY:
		_catalogo = parseado
	_bloque_a()
	_bloque_b()
	_bloque_c()
	_bloque_d()
	_bloque_e()


## ── A: derivación del id de icono (contrato con las convenciones M46) ──
func _bloque_a() -> void:
	# Objeto -> ico_ (y el doble prefijo del catálogo se quita UNA vez)
	_check(ICONOS.id_derivado("minerales", "mineral_mineral_cobre") == "ico_mineral_cobre",
		"A: mineral_mineral_cobre -> ico_mineral_cobre (llegó '%s')"
		% ICONOS.id_derivado("minerales", "mineral_mineral_cobre"))
	_check(ICONOS.id_derivado("plantas", "planta_baya_roja") == "ico_baya_roja",
		"A: planta_baya_roja -> ico_baya_roja")
	# Símbolo -> sym_
	_check(ICONOS.id_derivado("sellos", "sello_sello_ceniza_sala1") == "sym_sello_ceniza_sala1",
		"A: sello_sello_ceniza_sala1 -> sym_sello_ceniza_sala1")
	# Retrato -> pt_, ilustración -> illus_
	_check(ICONOS.id_derivado("personajes", "vecino_catalina_oso") == "pt_catalina_oso",
		"A: vecino_catalina_oso -> pt_catalina_oso")
	_check(ICONOS.id_derivado("lugares", "lugar_isla_raiz") == "illus_isla_raiz",
		"A: lugar_isla_raiz -> illus_isla_raiz")
	# Categorías sin familia declarada en M46 -> "" (no se inventa prefijo)
	for cat in ["misiones", "eventos", "cartas", "pistas"]:
		_check(ICONOS.id_derivado(cat, cat + "_x") == "",
			"A: categoría sin familia '%s' no deriva id" % cat)
	# Id que YA no lleva el prefijo de la categoría: no se mutila
	_check(ICONOS.id_derivado("minerales", "cobre") == "ico_cobre",
		"A: id sin prefijo de categoría deriva igual (llegó '%s')"
		% ICONOS.id_derivado("minerales", "cobre"))
	# Id vacío / solo prefijo -> ""
	_check(ICONOS.id_derivado("minerales", "mineral_") == "",
		"A: id que queda vacío tras quitar el prefijo no deriva")
	_check(ICONOS.id_derivado("minerales", "") == "", "A: id vacío no deriva")
	_fin("A")


## ── B: resolución en 3 niveles + fallback genérico (L203) ──
func _bloque_b() -> void:
	ICONOS._reset_usos_fallback()
	var r: Dictionary = ICONOS.resolver("minerales", "mineral_mineral_cobre")
	_check(r.get("textura", null) != null, "B: resolver SIEMPRE devuelve textura")
	_check(String(r.get("id", "")) == "ico_mineral_cobre", "B: id derivado en el resultado")
	_check(bool(r.get("en_inventario", false)), "B: ico_mineral_cobre está en el inventario M46")
	_check(not bool(r.get("asset_en_disco", false)),
		"B: ico_mineral_cobre NO tiene archivo (deuda de arte M46, medido)")
	# Sin arte -> fallback, pero el id se CONSERVA (para poder medir la deuda)
	_check(String(r.get("fuente", "")) == "fallback", "B: sin archivo -> fuente fallback")
	# Categoría sin familia -> fallback con id vacío
	var r2: Dictionary = ICONOS.resolver("misiones", "mision_prologo")
	_check(r2.get("textura", null) != null, "B: fallback también sin id derivable")
	_check(String(r2.get("id", "")) == "", "B: sin familia el id resuelto es vacío")
	# Nivel 1 (declarado): un id declarado manda sobre el derivado
	var r3: Dictionary = ICONOS.resolver("minerales", "mineral_mineral_cobre", "ico_piedra_caliza")
	_check(String(r3.get("id", "")) == "ico_piedra_caliza",
		"B: el icono DECLARADO manda sobre el derivado (llegó '%s')" % r3.get("id", ""))
	# La textura de fallback es UNA sola instancia (no se filtra VRAM por entrada)
	var t1: Texture2D = ICONOS.textura_fallback()
	var t2: Texture2D = ICONOS.textura_fallback()
	_check(t1 == t2, "B: el fallback está cacheado (misma instancia)")
	_check(t1 != null and t1.get_size() == Vector2(16, 16),
		"B: fallback 16x16 (llegó %s)" % str(t1.get_size() if t1 != null else "null"))
	_check(ICONOS.usos_fallback() >= 2, "B: el contador de fallback es observable")
	# Ruta convencional por familia
	_check(ICONOS.carpeta_de("ico_x") == "res://assets/2d/iconos/",
		"B: ico_ -> assets/2d/iconos/")
	_check(ICONOS.carpeta_de("sym_x") == "res://assets/2d/simbolos/",
		"B: sym_ -> assets/2d/simbolos/")
	_check(ICONOS.carpeta_de("zzz_x") == "", "B: familia desconocida sin carpeta")
	# El icono no rompe el alto de la fila (28 px del layer): 16 px de fallback
	var b := Button.new()
	b.icon = r.get("textura", null)
	b.expand_icon = false
	b.add_theme_constant_override("icon_max_width", 16)
	_check(b.icon != null, "B: Button.icon acepta la textura del resolutor")
	_check(b.get_theme_constant("icon_max_width") == 16,
		"B: icon_max_width es constante de TEMA (no propiedad) y se aplica")
	_check(b.get_combined_minimum_size().y <= 64.0,
		"B: el icono no infla el mínimo de la fila (%.1f px)"
		% b.get_combined_minimum_size().y)
	b.free()
	_fin("B")


## ── C: inventario medido del catálogo (aritmética, no cifras de contenido) ──
func _bloque_c() -> void:
	_check(not _catalogo.is_empty(), "C: catálogo cargado para medir")
	if _catalogo.is_empty():
		_fin("C")
		return
	_check(ICONOS.inventario_disponible(), "C: inventario M46 disponible (guarda de ceguera)")
	var inf: Dictionary = ICONOS.inventario_iconos(_catalogo)
	var entradas := int(inf["entradas"])
	var derivables := int(inf["con_id_derivado"])
	var sin_fam := int(inf["sin_familia"])
	var en_inv := int(inf["en_inventario"])
	var con_asset := int(inf["con_asset"])
	print("[C] entradas=%d derivables=%d sin_familia=%d en_inventario=%d con_asset=%d"
		% [entradas, derivables, sin_fam, en_inv, con_asset])
	_check(entradas > 0, "C: el catálogo tiene entradas")
	# INVARIANTE: toda entrada o deriva id o queda sin familia (no hay tercera vía)
	_check(derivables + sin_fam == entradas,
		"C: derivables(%d) + sin_familia(%d) == entradas(%d)"
		% [derivables, sin_fam, entradas])
	_check(en_inv <= derivables, "C: en_inventario(%d) <= derivables(%d)" % [en_inv, derivables])
	_check(con_asset <= en_inv,
		"C: con_asset(%d) <= en_inventario(%d) (un asset exige id en el inventario)"
		% [con_asset, en_inv])
	# CONTRATO con M46: minerales y plantas ya tienen su icono en el inventario
	var faltan: Array[String] = []
	for c in (_catalogo.get("categorias", []) as Array):
		var cat := String((c as Dictionary).get("id", ""))
		if cat != "minerales" and cat != "plantas":
			continue
		for e in ((c as Dictionary).get("entradas", []) as Array):
			var id := ICONOS.id_derivado(cat, String((e as Dictionary).get("id", "")))
			if not ICONOS.inventario_m46().has(id):
				faltan.append(id)
	_check(faltan.is_empty(),
		"C: minerales y plantas resuelven en el inventario M46 (faltan %s)" % str(faltan))
	# Los ausentes son exactamente los derivables que NO están en el inventario
	var aus: Array[String] = ICONOS.iconos_ausentes(_catalogo)
	_check(aus.size() == derivables - en_inv,
		"C: iconos_ausentes(%d) == derivables - en_inventario(%d)"
		% [aus.size(), derivables - en_inv])
	# Sin duplicados en la lista de ausentes
	var unicos: Dictionary = {}
	for id in aus:
		unicos[id] = true
	_check(unicos.size() == aus.size(), "C: iconos_ausentes sin duplicados")
	# El inventario M46 declara TODOS sus ids con un prefijo de familia conocido
	var sin_prefijo: Array[String] = []
	for id in ICONOS.inventario_m46().keys():
		if ICONOS.carpeta_de(String(id)).is_empty():
			sin_prefijo.append(String(id))
	_check(sin_prefijo.is_empty(),
		"C: todo id del inventario M46 tiene familia con carpeta (%s)" % str(sin_prefijo))
	# Deuda MEDIDA (se imprime, no se asevera contra el contenido)
	var fam: Array = inf["familia_disponible"]
	print("[C] ids sin id exacto con símbolo de familia disponible: %d %s"
		% [fam.size(), str(fam)])
	print("[C] DEUDA: %d/%d entradas con id en el inventario, %d con asset en disco"
		% [en_inv, entradas, con_asset])
	_fin("C")


## ── D: el layer y el servicio consumen el resolutor (integración por fuente) ──
func _bloque_d() -> void:
	var layer := FileAccess.get_file_as_string(RUTA_LAYER)
	_check(not layer.is_empty(), "D: diary_layer.gd legible")
	_check(layer.contains("preload(\"res://scripts/diario/iconos_diario.gd\")"),
		"D: el layer precarga el resolutor de iconos")
	_check(layer.contains("ICONOS.resolver("), "D: el layer llama a ICONOS.resolver")
	_check(layer.contains("b.icon = "), "D: la fila de la lista asigna el icono")
	_check(layer.contains("add_theme_constant_override(\"icon_max_width\", ICONO_FILA)"),
		"D: el icono de la fila está acotado con la constante de tema icon_max_width")
	_check(layer.contains("_icono_detalle.texture = "),
		"D: el detalle asigna la textura del icono")
	_check(layer.contains("_icono_detalle.texture = null  # anti-spoiler"),
		"D: una entrada secreta no muestra icono (anti-spoiler §3.2)")
	var svc := FileAccess.get_file_as_string(RUTA_SERVICE)
	_check(not svc.is_empty(), "D: diary_service.gd legible")
	# El campo declarado tiene que LLEGAR a la UI o el nivel 1 es rama muerta
	_check(svc.contains("\"icono\": String(e.get(\"icono\", \"\"))"),
		"D: entradas_de/detalle_entrada exponen el campo opcional 'icono'")
	# El validador tiene el bloque de iconografía y un piso de checks
	var val := FileAccess.get_file_as_string("res://scripts/diario/validate_diary.gd")
	_check(val.contains("_validar_iconos(parseado)"),
		"D: validate_diary corre el bloque de iconografía")
	# El piso se PARSEA: fijarlo como literal hace que la suite se ponga roja
	# cada vez que validate_diary crece (pasó en la iter. 7: 387 -> 391). Lo que
	# se afirma es que EXISTE y que no baja del mínimo histórico medido.
	var re_piso := RegEx.new()
	re_piso.compile("CHECKS_MINIMOS: int = (\\d+)")
	var m_piso := re_piso.search(val)
	var piso := int(m_piso.get_string(1)) if m_piso != null else 0
	_check(piso >= 387,
		"D: validate_diary tiene piso de checks medido (>=387; hoy %d)" % piso)
	_fin("D")


## ── E: guardián de la propia suite (el piso y los bloques se ven a sí mismos) ──
func _bloque_e() -> void:
	_check(CHECKS_MINIMOS > 0, "E: el piso de esta suite está declarado")
	# El inventario M46 declara 48 ids: si el archivo se rompe, esto lo delata
	var n: int = ICONOS.inventario_m46().size()
	_check(n >= 40, "E: inventario M46 con %d ids (esperado >= 40)" % n)
	var raw := FileAccess.get_file_as_string(RUTA_INVENTARIO)
	_check(not raw.is_empty(), "E: " + RUTA_INVENTARIO + " legible")
	# Cada id del inventario declara estado y familia (forma del catálogo M46)
	var malformados: Array[String] = []
	for id in ICONOS.inventario_m46().keys():
		var a: Dictionary = ICONOS.inventario_m46()[id]
		if String(a.get("estado", "")).is_empty() or String(a.get("familia", "")).is_empty():
			malformados.append(String(id))
	_check(malformados.is_empty(),
		"E: todo id del inventario declara estado y familia (%s)" % str(malformados))
	_fin("E")
