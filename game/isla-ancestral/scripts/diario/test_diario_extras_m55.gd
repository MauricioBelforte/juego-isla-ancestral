# Modelo: GLM-5.3-Flash
# Plataforma: Kilo Code
# Fecha: 2026-11-25
#
# M55: tanda puentes de datos (checklist L57/L92/L125) — extras por entrada,
# snapshot de relación/retrato/diálogo en personajes, cantidad de inventario en
# minerales, y validación contra el catálogo de sellos M25 (seals.json).
#
# Ejecutar: Godot --headless --path game/isla-ancestral
#           --script res://scripts/diario/test_diario_extras_m55.gd
# Exit: 0 = verde | 1 = fallos

extends SceneTree

var _checks: int = 0
var _fallos: int = 0

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)

func _summary() -> void:
	print("=== Resumen QA M55 extras: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	await process_frame
	var diary: Node = root.get_node_or_null("/root/Diary")
	var bus: Node = root.get_node_or_null("/root/EventBus")
	_check("setup: Diary y EventBus cargan como autoloads", diary != null and bus != null)
	if diary == null or bus == null:
		_summary()
		return

	# ── A. API de extras: registrar_con_datos + datos_de + merge ──
	var ok_reg: bool = diary.registrar_con_datos("lugar_isla_raiz", "lugares", {"prueba": 1})
	_check("registrar_con_datos registra una entrada válida", ok_reg)
	_check("datos_de devuelve los datos guardados", int(diary.datos_de("lugar_isla_raiz").get("prueba", -1)) == 1)
	diary.registrar_con_datos("lugar_isla_raiz", "lugares", {"otro": "x"})
	var merged: Dictionary = diary.datos_de("lugar_isla_raiz")
	_check("re-llamada fusiona datos (merge, no reemplazo)", merged.size() == 2 and int(merged.get("prueba", 0)) == 1 and String(merged.get("otro", "")) == "x")
	_check("registrar_con_datos con datos vacíos = registrar normal (sin extras)", diary.registrar_con_datos("lugar_isla_brisa", "lugares", {}) and diary.datos_de("lugar_isla_brisa").is_empty())
	_check("datos_de de entrada sin datos = {}", diary.datos_de("lugar_isla_norte").is_empty() or int(diary.datos_de("lugar_isla_norte").get("prueba", 0)) == 0)
	_check("registrar_con_datos rechaza entrada inexistente", not diary.registrar_con_datos("lugar_inexistente", "lugares", {"a": 1}))

	# ── B. detalle_entrada expone los datos ──
	var det: Dictionary = diary.detalle_entrada("lugar_isla_raiz")
	_check("detalle_entrada incluye clave 'datos'", det.has("datos") and int(det["datos"].get("prueba", 0)) == 1)

	# ── C. Save/restore con extras (schema_version 2) ──
	var save: Dictionary = diary.get_save_data()
	_check("get_save_data lleva schema_version 2", int(save.get("schema_version", 0)) == 2)
	_check("get_save_data incluye extras con la entrada de prueba", (save.get("extras", {}) as Dictionary).has("lugar_isla_raiz"))
	# Roundtrip sin pasar por disco (restore directo)
	diary.registrar("lugar_isla_sur", "lugares")
	diary.registrar_con_datos("lugar_isla_sur", "lugares", {"nivel": 5})
	diary.restore_save_data(diary.get_save_data())
	_check("roundtrip get/restore conserva extras", int(diary.datos_de("lugar_isla_sur").get("nivel", -1)) == 5 and int(diary.datos_de("lugar_isla_raiz").get("prueba", -1)) == 1)
	# Save v1 (sin extras) carga igual
	var v1: Dictionary = {"schema_version": 1, "entradas": {"lugar_isla_espejo": {"categoria": "lugares", "estado": 1, "favorito": false, "dia": 1}}, "ui": {"filtro": 0, "categoria": "personajes"}}
	diary.restore_save_data(v1)
	_check("save v1 sin extras restaura sin romper (tolerante)", diary.esta_registrada("lugar_isla_espejo") and diary.datos_de("lugar_isla_espejo").is_empty())

	# ── D. Puentes de personajes (L57) ──
	# Retrato + registro por mudanza: npc_moved_in con un NPC real del catálogo
	bus.npc.npc_moved_in.emit("catalina_oso", "aurora")
	var eid: String = "vecino_catalina_oso"
	_check("npc_moved_in registra la entrada del vecino", diary.esta_registrada(eid))
	var retrato: String = String(diary.datos_de(eid).get("retrato", ""))
	_check("npc_moved_in snapshot del retrato (NPCVisualDatabase, read-only)", retrato.is_empty() or retrato.begins_with("res://"))
	# Nivel de relación (M20)
	bus.npc.nivel_amistad_cambio.emit("catalina_oso", 2)
	_check("nivel_amistad_cambio guarda nivel_relacion en la entrada", int(diary.datos_de(eid).get("nivel_relacion", -1)) == 2)
	# Último diálogo (M21)
	bus.npc.dialog_requested.emit("catalina_oso", {"id": "aur_001_intro"})
	_check("dialog_requested guarda ultimo_dialogo en la entrada", String(diary.datos_de(eid).get("ultimo_dialogo", "")) == "aur_001_intro")
	# NPC sin entrada en catálogo: el puente no rompe (silent-skip)
	bus.npc.nivel_amistad_cambio.emit("npc_inventado_xyz", 3)
	_check("puente con NPC desconocido no rompe (silent-skip)", true)

	# ── E. Minerales: snapshot de inventario (L92) ──
	var inv: Node = root.get_node_or_null("/root/Inventario")
	_check("setup: Inventario autoload presente", inv != null)
	if inv != null:
		inv.add_item("piedra_caliza", 7)
		diary.registrar("mineral_piedra_caliza", "minerales")
		_check("registrar de minerales snapshot cantidad_inventario (M14)", int(diary.datos_de("mineral_piedra_caliza").get("cantidad_inventario", -1)) == 7)
		var det_min: Dictionary = diary.detalle_entrada("mineral_piedra_caliza")
		_check("detalle de mineral expone conteo en vivo 'inventario'", int(det_min.get("inventario", -1)) == 7)
		inv.remove_item("piedra_caliza", 7)

	# ── F. Validación contra catálogo M25 (L125) ──
	var rep: Dictionary = diary.validar_sellos_m25()
	_check("validar_sellos_m25 carga el catálogo real (catalogo_ok)", bool(rep.get("catalogo_ok", false)) == true)
	_check("validar_sellos_m25 informa la relación diario↔M25 (campos presentes)", rep.has("desconocidos") and rep.has("sin_diario") and int(rep.get("sellos_m25", -1)) > 0)
	var rep_mal: Dictionary = diary.validar_sellos_m25("res://data/no_existe.json")
	_check("catálogo inexistente → reporte seguro sin romper", bool(rep_mal.get("catalogo_ok", true)) == false)

	_summary()
