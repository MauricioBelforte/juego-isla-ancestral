# Modelo: deepseek-v4-flash (iter. 1) · DeepSeek-V4.1-Flash / WorkBuddy (iter. 2)
# Plataforma: Kilo Code (iter. 1) · WorkBuddy (iter. 2)
# Fecha: 2026-09-01 (iter. 1) · 2026-09-13 (iter. 2)
#
# M148: Lore Ambiental — Test headless (iter. 2, adversarial)
# Valida: carga del catálogo data-driven, lookup, cobertura por isla, grafo de
# pistas REAL (consumidores registrados), LoreAuditor (IDs únicos/canonRef/tipo/
# texto/cobertura), TerrenoLoreService, y PERSISTENCIA con LoreSaveProvider
# (marcado, no re-notificación, migración de saves sin el campo, 30 ciclos
# save/load sin pérdida). Exit code != 0 si falla.
#
# Anti-falso-verde: un error de script ABORTA la función en SILENCIO y el
# resumen imprimiría "0 fallos". Cada bloque cierra con _fin(marca) y _run()
# verifica que TODAS las marcas aparezcan; si falta una, se cuenta como fallo.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_CATALOGO := preload("res://scripts/lore/lore_catalogo.gd")
const _SC_AUDITOR := preload("res://scripts/lore/lore_auditor.gd")
const _SC_TERRENO := preload("res://scripts/lore/terreno_lore_service.gd")
const _SC_PIEZA := preload("res://scripts/lore/pieza_lore.gd")
const _SC_PROVIDER := preload("res://scripts/lore/lore_save_provider.gd")

const BLOQUES: Array[String] = ["A", "B", "C", "D", "E", "F", "G", "H"]

var _fallos: int = 0
var _checks: int = 0
var _marcas: Dictionary = {}

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M148] Test de Lore Ambiental (iter. 2) ===")
	_test_catalogo()          # A
	_test_auditor_ok()        # B
	_test_auditor_adversario()# C
	_test_grafo()             # D
	_test_terreno()           # E
	_test_persistencia()      # F
	_test_migracion()         # G
	_test_ciclos()            # H
	# Verificación anti-falso-verde: todas las marcas deben existir.
	for marca in BLOQUES:
		if not _marcas.has(marca):
			_check("bloque %s completó (marcador _fin)" % marca, false, "BLOQUE ABORTADO")
		else:
			_check("bloque %s completó (marcador _fin)" % marca, true)
	_summary()

func _fin(marca: String) -> void:
	_marcas[marca] = true

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

## Construye una pieza sintética (para escenarios adversarios).
func _pieza(id: String, canon: String, tipo: int, isla: String, consumidor: String = "") -> PiezaDeLore:
	var p = _SC_PIEZA.new()
	p.id = id
	p.canon_ref = canon
	p.tipo = tipo
	p.isla = isla
	p.titulo = "t"
	p.texto = "x"
	p.consumidor_id = consumidor
	return p

## ── A. Catálogo ────────────────────────────────────────────

func _test_catalogo() -> void:
	print("--- A. LoreCatalogo: carga y lookup ---")
	var catalogo = _SC_CATALOGO.new()
	catalogo.cargar()
	_check("catálogo cargado", catalogo.cantidad_total() > 0, "total=%d" % catalogo.cantidad_total())
	_check("cobertura total ≥ 48 (12×4 islas)", catalogo.cantidad_total() >= 48, "total=%d" % catalogo.cantidad_total())
	var pieza = catalogo.obtener_pieza("ruina_costa_1")
	_check("lookup por id", pieza != null and pieza.id == "ruina_costa_1")
	_check("canon_ref no vacío", pieza != null and not pieza.canon_ref.is_empty())
	for isla in ["raiz", "coral", "ceniza", "aurora"]:
		_check("cobertura %s ≥ 12" % isla, catalogo.por_isla(isla).size() >= 12, "size=%d" % catalogo.por_isla(isla).size())
	_check("murales ≥ 4 (1 por templo)", catalogo.por_tipo(_SC_PIEZA.Tipo.MURAL).size() >= 4)
	_check("lookup inexistente -> null", catalogo.obtener_pieza("no_existe") == null)
	_check("ids ordenados y estables", catalogo.todos_los_ids() == catalogo.todos_los_ids())
	_check("total de ids == cantidad_total", catalogo.todos_los_ids().size() == catalogo.cantidad_total())
	_fin("A")

## ── B. Auditor sobre catálogo real ──────────────────────────

func _test_auditor_ok() -> void:
	print("--- B. LoreAuditor: catálogo real ---")
	var catalogo = _SC_CATALOGO.new()
	catalogo.cargar()
	var errores: Array = _SC_AUDITOR.validar(catalogo)
	_check("catálogo real válido (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK cuando limpio", _SC_AUDITOR.reporte(errores).contains("OK"))
	var cob := _SC_AUDITOR.reporte_cobertura(catalogo)
	_check("reporte de cobertura menciona raiz", cob.contains("raiz"))
	_check("reporte de cobertura marca OK", cob.contains("[OK]"))
	_fin("B")

## ── C. Auditor adversario ───────────────────────────────────

func _test_auditor_adversario() -> void:
	print("--- C. LoreAuditor: escenarios adversarios ---")
	# ID duplicado: dos piezas con el mismo id bajo claves distintas
	var dup = _SC_CATALOGO.new()
	dup._piezas["k1"] = _pieza("dup", "canon:x", 0, "raiz")
	dup._piezas["k2"] = _pieza("dup", "canon:x", 0, "raiz")
	var e_dup: Array = _SC_AUDITOR.validar(dup)
	_check("ID duplicado detectado", str(e_dup).contains("duplicado"), str(e_dup))

	# canon_ref vacío
	var sin_canon = _SC_CATALOGO.new()
	sin_canon._piezas["k1"] = _pieza("c1", "", 0, "raiz")
	_check("canon_ref vacío detectado", str(_SC_AUDITOR.validar(sin_canon)).contains("canon_ref"))

	# tipo fuera de rango
	var tipo_malo = _SC_CATALOGO.new()
	tipo_malo._piezas["k1"] = _pieza("t1", "canon:x", 99, "raiz")
	_check("tipo fuera de rango detectado", str(_SC_AUDITOR.validar(tipo_malo)).contains("tipo fuera de rango"))

	# texto/título vacíos
	var sin_texto = _SC_CATALOGO.new()
	var p_vacia = _pieza("x1", "canon:x", 0, "raiz")
	p_vacia.texto = ""
	sin_texto._piezas["k1"] = p_vacia
	_check("texto vacío detectado", str(_SC_AUDITOR.validar(sin_texto)).contains("texto vacío"))

	# cobertura insuficiente (isla nueva con 1 pieza)
	var poca = _SC_CATALOGO.new()
	poca._piezas["k1"] = _pieza("p1", "canon:x", 0, "isla_nueva")
	_check("cobertura insuficiente detectada", str(_SC_AUDITOR.validar(poca)).contains("mínimo 12"))

	# pista sin consumidor
	var pista_muda = _SC_CATALOGO.new()
	pista_muda._piezas["k1"] = _pieza("m1", "canon:x", _SC_PIEZA.Tipo.MURAL, "raiz", "")
	_check("pista sin consumidor detectada", str(_SC_AUDITOR.validar(pista_muda)).contains("sin consumidor_id"))

	# pista con consumidor DESCONOCIDO (el auditor viejo no lo detectaba)
	var pista_falsa = _SC_CATALOGO.new()
	pista_falsa._piezas["k1"] = _pieza("m2", "canon:x", _SC_PIEZA.Tipo.MURAL, "raiz", "consumidor_inexistente")
	_check("consumidor desconocido detectado", str(_SC_AUDITOR.validar(pista_falsa)).contains("consumidor desconocido"))

	# un catálogo válido y completo NO debe dar errores (control positivo)
	var bueno = _SC_CATALOGO.new()
	for i in 12:
		bueno._piezas["b%d" % i] = _pieza("ok%d" % i, "canon:x", 0, "raiz")
	_check("catálogo sintético válido sin errores", _SC_AUDITOR.validar(bueno).is_empty(), str(_SC_AUDITOR.validar(bueno)))

	# Duplicado por la VÍA REAL (texto JSON -> cargar_desde_texto -> auditor).
	# Si el catálogo no detectara el duplicado al cargar, el Dictionary por id
	# lo colapsaría y el chequeo del auditor sería código muerto.
	var real = _SC_CATALOGO.new()
	var doc := '{"piezas":[' \
		+ '{"id":"d","canon_ref":"c","tipo":0,"isla":"raiz","titulo":"t","texto":"x"},' \
		+ '{"id":"d","canon_ref":"c","tipo":0,"isla":"raiz","titulo":"t","texto":"x"}]}'
	_check("cargar_desde_texto acepta documento válido", real.cargar_desde_texto(doc))
	_check("duplicado detectado en la carga real", real.ids_duplicados().has("d"), str(real.ids_duplicados()))
	_check("auditor reporta duplicado real", str(_SC_AUDITOR.validar(real)).contains("ID duplicado"))
	_check("colapso: 1 pieza tras cargar 2 con mismo id", real.cantidad_total() == 1, "total=%d" % real.cantidad_total())
	# entrada sin id -> contabilizada y reportada
	var sinid = _SC_CATALOGO.new()
	sinid.cargar_desde_texto('{"piezas":[{"canon_ref":"c","tipo":0,"isla":"raiz"}]}')
	_check("entrada sin id contabilizada", sinid.entradas_sin_id() == 1, "n=%d" % sinid.entradas_sin_id())
	_check("auditor reporta entrada sin id", str(_SC_AUDITOR.validar(sinid)).contains("sin id"))
	# documento inválido -> false y estado limpio
	var malo_doc = _SC_CATALOGO.new()
	_check("documento sin 'piezas' -> false", not malo_doc.cargar_desde_texto('{"otra":1}'))
	_check("documento inválido deja catálogo vacío", malo_doc.cantidad_total() == 0)
	_fin("C")

## ── D. Grafo de pistas ──────────────────────────────────────

func _test_grafo() -> void:
	print("--- D. Grafo de pistas (RF3) ---")
	var catalogo = _SC_CATALOGO.new()
	catalogo.cargar()
	_check("registro de consumidores cargado", catalogo.ids_consumidores().size() >= 10, "n=%d" % catalogo.ids_consumidores().size())
	_check("es_pista_valida() acepta consumidor registrado", catalogo.es_pista_valida("puzzle_templo_raiz"))
	_check("es_pista_valida() rechaza desconocido", not catalogo.es_pista_valida("no_existe"))
	_check("es_pista_valida() rechaza vacío", not catalogo.es_pista_valida(""))
	var pistas: Array = catalogo.pistas()
	_check("catálogo tiene pistas (≥ 16)", pistas.size() >= 16, "n=%d" % pistas.size())
	var errores: Array = _SC_AUDITOR.validar_grafo(catalogo)
	_check("grafo real consistente (0 errores)", errores.is_empty(), str(errores))
	# pista apuntando a consumidor inexistente -> grafo roto
	var roto = _SC_CATALOGO.new()
	roto._piezas["k1"] = _pieza("m9", "canon:x", _SC_PIEZA.Tipo.ESTATUA, "raiz", "sello_fantasma")
	_check("grafo detecta consumidor inexistente", not _SC_AUDITOR.validar_grafo(roto).is_empty())
	_fin("D")

## ── E. TerrenoLoreService ───────────────────────────────────

func _test_terreno() -> void:
	print("--- E. TerrenoLoreService: secretos por temporada ---")
	var terreno = _SC_TERRENO.new()
	terreno.cargar()
	var total := 0
	for t in ["primavera", "verano", "otono", "invierno"]:
		var s: Array = terreno.activar_temporada(t)
		_check("%s tiene secretos" % t, s.size() >= 1, "size=%d" % s.size())
		total += s.size()
	_check("4 temporadas con secretos", total >= 4, "total=%d" % total)
	_check("temporada desconocida -> vacío", terreno.activar_temporada("nada").size() == 0)
	# activar_temporada debe devolver COPIA: mutarla no debe alterar el servicio
	var copia: Array = terreno.activar_temporada("primavera")
	copia.append("intruso")
	_check("activar_temporada devuelve copia (no alias)", not terreno.activar_temporada("primavera").has("intruso"))
	_fin("E")

## ── F. Persistencia (LoreSaveProvider) ──────────────────────

func _test_persistencia() -> void:
	print("--- F. LoreSaveProvider: marcado y no re-notificación ---")
	var prov = _SC_PROVIDER.new()
	_check("sección == 'lore'", prov.get_section_name() == "lore")
	_check("estado inicial vacío", prov.total_explorado() == 0)
	_check("primera marca devuelve true (nueva)", prov.marcar_explorado("ruina_costa_1", "raiz"))
	_check("segunda marca devuelve false (ya vista)", not prov.marcar_explorado("ruina_costa_1", "raiz"))
	_check("ya_explorado true tras marcar", prov.ya_explorado("ruina_costa_1"))
	_check("ya_explorado false para desconocida", not prov.ya_explorado("otra"))
	_check("contador por isla", prov.contador_isla("raiz") == 1)
	prov.marcar_explorado("objeto_faro", "raiz")
	_check("contador acumula", prov.contador_isla("raiz") == 2)
	_check("id vacío no se marca", not prov.marcar_explorado(""))
	_check("total explorado", prov.total_explorado() == 2)
	var data: Dictionary = prov.get_save_data()
	_check("get_save_data trae version", int(data.get("version", 0)) == 1)
	_check("get_save_data trae explorado", (data.get("explorado", []) as Array).size() == 2)
	_check("get_save_data trae por_isla", int((data.get("por_isla", {}) as Dictionary).get("raiz", 0)) == 2)
	# restaurar en un provider nuevo
	var prov2 = _SC_PROVIDER.new()
	prov2.restore_save_data(data)
	_check("restore conserva explorados", prov2.total_explorado() == 2)
	_check("restore conserva contador", prov2.contador_isla("raiz") == 2)
	_check("restore: ya_explorado", prov2.ya_explorado("objeto_faro"))
	prov2.reset()
	_check("reset limpia", prov2.total_explorado() == 0)
	_fin("F")

## ── G. Migración de saves sin el campo ──────────────────────

func _test_migracion() -> void:
	print("--- G. Migración (saves sin campo 'lore') ---")
	# save antiguo SIN la sección lore -> estado vacío válido (no aborta)
	var prov = _SC_PROVIDER.new()
	prov.restore_save_data({})
	_check("restore de {} no rompe", prov.total_explorado() == 0)
	_check("sección migrada a version 1", _SC_PROVIDER.migrar({}).get("version", 0) == 1)
	# save con 'lore' parcial (sin version, sin por_isla)
	var parcial := {"explorado": ["a", "b"]}
	var m := _SC_PROVIDER.migrar(parcial, 0)
	_check("migrar parcial conserva explorado", (m["explorado"] as Array).size() == 2)
	_check("migrar parcial crea por_isla", typeof(m["por_isla"]) == TYPE_DICTIONARY)
	_check("migrar registra desde_version", int(m.get("_migrado_desde", -1)) == 0)
	# save con ids duplicados -> deduplicado
	var dup := {"explorado": ["a", "a", "b"]}
	_check("migrar deduplica ids", (_SC_PROVIDER.migrar(dup)["explorado"] as Array).size() == 2)
	# datos basura -> estado vacío válido (nunca aborta ni degrada)
	_check("migrar con basura -> vacío válido", (_SC_PROVIDER.migrar("no_es_dict")["explorado"] as Array).is_empty())
	var prov3 = _SC_PROVIDER.new()
	prov3.restore_save_data({"explorado": [1, 2, 3], "por_isla": {"raiz": "3"}})
	_check("restore coerciona ids numéricos a String", prov3.ya_explorado("1"))
	_check("restore coerciona contador a int", prov3.contador_isla("raiz") == 3)
	_fin("G")

## ── H. 30 ciclos save/load sin pérdida ──────────────────────

func _test_ciclos() -> void:
	print("--- H. 30 ciclos save/load (JSON round-trip) ---")
	var catalogo = _SC_CATALOGO.new()
	catalogo.cargar()
	var ids: Array = catalogo.todos_los_ids()
	_check("catálogo con piezas para el ciclo", ids.size() > 0)
	# Marcar la mitad de las piezas
	var prov = _SC_PROVIDER.new()
	var esperados := 0
	for i in ids.size():
		if i % 2 == 0:
			var p: PiezaDeLore = catalogo.obtener_pieza(ids[i])
			if prov.marcar_explorado(ids[i], p.isla):
				esperados += 1
	_check("mitad marcada", prov.total_explorado() == esperados, "%d/%d" % [prov.total_explorado(), esperados])
	# 30 ciclos: serializar a JSON y restaurar en un provider nuevo
	var actual = prov
	var ok := true
	var detalle := ""
	for ciclo in 30:
		var texto := JSON.stringify(actual.get_save_data())
		var parsed: Variant = JSON.parse_string(texto)
		if typeof(parsed) != TYPE_DICTIONARY:
			ok = false
			detalle = "ciclo %d: JSON no parseable" % ciclo
			break
		var nuevo = _SC_PROVIDER.new()
		nuevo.restore_save_data(parsed)
		if nuevo.total_explorado() != esperados:
			ok = false
			detalle = "ciclo %d: perdidos %d/%d" % [ciclo, nuevo.total_explorado(), esperados]
			break
		if nuevo.ids_explorados() != actual.ids_explorados():
			ok = false
			detalle = "ciclo %d: ids distintos" % ciclo
			break
		actual = nuevo
	_check("30 ciclos sin pérdida de lore", ok, detalle)
	_check("estado final == esperado", actual.total_explorado() == esperados)
	# El contador por isla sobrevive los ciclos
	var suma := 0
	for isla in ["raiz", "coral", "ceniza", "aurora"]:
		suma += actual.contador_isla(isla)
	_check("contadores por isla coherentes tras 30 ciclos", suma == esperados, "suma=%d esperado=%d" % [suma, esperados])
	_fin("H")

## ── Summary ──────────────────────────────────────────────

func _summary() -> void:
	print("=== Resumen M148: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M148 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M148 OK — todos los checks pasaron")
		quit(0)
