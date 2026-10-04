# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-04
#
# Unit tests DlcManager (M120) — T-D5, Log 1291
#
# Cubre la PARTE TECNICA del modulo:
#   - versionado SEMANTICO (comparar_versiones: "1.10.0" > "1.9.0", NO lexicografico)
#   - es_compatible() contra la version base
#   - activar/desactivar/esta_activo
#   - bundles (bundle / bundles_que_contienen)
#   - ISaveProvider (seccion "dlc"): get_save_data + roundtrip + reconciliacion
#     de DLCs que el save referencia pero NO estan instalados.
#
# Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS
# MEDIDO + _summary() en call_deferred SEPARADO + watchdog.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://tests/unit/dlc/test_dlc_manager.gd

extends SceneTree

const TIMEOUT_SEG := 60.0
## Piso MEDIDO en verde (T-D5, 2026-10-04: 39 checks).
const CHECKS_MINIMOS := 39
const BLOQUES_ESPERADOS: Array[String] = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L']

const DLC_SCRIPT := preload("res://scripts/dlc/dlc_manager.gd")

var _auto = null
var _fallos: int = 0
var _checks: int = 0
var _bloque: String = "(inicio)"
var _abortado: bool = false
var _completados: Array[String] = []
var _checks_por_bloque: Dictionary = {}
var _checks_marca: int = 0


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	create_timer(TIMEOUT_SEG, true).timeout.connect(_on_watchdog)
	_auto = root.get_node_or_null("DlcManager")
	print("=== Unit tests DlcManager (M120, headless) ===")
	_bloque_A()
	_bloque_B()
	_bloque_C()
	_bloque_D()
	_bloque_E()
	_bloque_F()
	_bloque_G()
	_bloque_H()
	_bloque_I()
	_bloque_J()
	_bloque_K()
	_bloque_L()


func _on_watchdog() -> void:
	_abortado = true
	print("WATCHDOG: la suite no termino en %.0f s (ultimo bloque: %s)" % [TIMEOUT_SEG, _bloque])
	quit(1)


func _ini(nombre: String) -> void:
	_bloque = nombre
	_checks_marca = _checks
	print("\n-- %s --" % nombre)


func _fin(nombre: String) -> void:
	var letra: String = nombre.substr(0, 1)
	if not _completados.has(letra):
		_completados.append(letra)
	var delta: int = _checks - _checks_marca
	_checks_por_bloque[letra] = int(_checks_por_bloque.get(letra, 0)) + delta
	_checks_marca = _checks
	print("[FIN] %s (+%d checks)" % [nombre, delta])


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])


func _summary() -> void:
	var faltantes: Array[String] = []
	for letra in BLOQUES_ESPERADOS:
		if not _completados.has(letra):
			faltantes.append(letra)
	_check("todos los bloques se completaron (sin abortos silenciosos)", faltantes.is_empty(),
		"bloques que no terminaron: %s" % str(faltantes))
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("Checks por bloque: %s" % str(_checks_por_bloque))
	print("\n=== Resumen DlcManager M120: %d checks, %d fallos ===" % [_checks, _fallos])
	if _abortado:
		quit(1)
	elif _fallos == 0:
		print("TEST OK — todos los checks pasaron")
		quit(0)
	else:
		print("TEST FALLO — %d checks fallaron" % _fallos)
		quit(1)


## Instancia limpia de DlcManager (sin _ready: no registra servicio/proveedor
## globales, para no ensuciar el autoload). Carga manifest+bundles a mano.
func _nueva_instancia():
	var d = DLC_SCRIPT.new()
	d._cargar_manifest()
	d._cargar_bundles()
	return d


# ==================== BLOQUES ====================

func _bloque_A() -> void:
	_ini("A. test_autoload_disponible")
	_check("_auto .is_not_null()", (_auto) != null)

	_fin("A. test_autoload_disponible")


func _bloque_B() -> void:
	_ini("B. test_manifest_cargado")
	if _auto == null:
		_fin("B. test_manifest_cargado")
		return
	_check("config tiene 'dlcs'", _auto.config.has("dlcs"))
	_check("dlcs no vacio", (_auto.config.get("dlcs", []).size()) > 0)
	_check("dlcs_ids() no vacio", (_auto.dlcs_ids().size()) > 0)

	_fin("B. test_manifest_cargado")


func _bloque_C() -> void:
	_ini("C. test_comparar_versiones_semantica")
	# El bug original: comparacion lexicografica -> "1.10.0" >= "1.9.0" daba FALSE.
	_check("comparar(1.10.0, 1.9.0) > 0", (DLC_SCRIPT.comparar_versiones("1.10.0", "1.9.0")) > 0)
	_check("comparar(1.9.0, 1.10.0) < 0", (DLC_SCRIPT.comparar_versiones("1.9.0", "1.10.0")) < 0)
	_check("comparar(2.0.0, 10.0.0) < 0", (DLC_SCRIPT.comparar_versiones("2.0.0", "10.0.0")) < 0)
	_check("comparar(1.0.0, 1.0.0) == 0", (DLC_SCRIPT.comparar_versiones("1.0.0", "1.0.0")) == 0)

	_fin("C. test_comparar_versiones_semantica")


func _bloque_D() -> void:
	_ini("D. test_comparar_versiones_tolerancias")
	_check("comparar(1.2, 1.2.0) == 0", (DLC_SCRIPT.comparar_versiones("1.2", "1.2.0")) == 0)
	_check("comparar(1.0.0-beta, 1.0.0) == 0", (DLC_SCRIPT.comparar_versiones("1.0.0-beta", "1.0.0")) == 0)
	_check("comparar(1.0.1, 1.0.0) > 0", (DLC_SCRIPT.comparar_versiones("1.0.1", "1.0.0")) > 0)
	_check("comparar(vacio, 0.0.0) == 0", (DLC_SCRIPT.comparar_versiones("", "0.0.0")) == 0)

	_fin("D. test_comparar_versiones_tolerancias")


func _bloque_E() -> void:
	_ini("E. test_es_compatible")
	if _auto == null:
		_fin("E. test_es_compatible")
		return
	var ids: Array = _auto.dlcs_ids()
	if ids.is_empty():
		_check("dlcs_ids no vacio", false)
		_fin("E. test_es_compatible")
		return
	var id := String(ids[0])
	_check("es_compatible(id, 99.0.0) .is_true()", (_auto.es_compatible(id, "99.0.0")) == true)
	_check("es_compatible(id, 0.0.1) .is_false()", (_auto.es_compatible(id, "0.0.1")) == false)
	_check("es_compatible(id inexistente) .is_false()", (_auto.es_compatible("__no_existe__", "99.0.0")) == false)

	_fin("E. test_es_compatible")


func _bloque_F() -> void:
	_ini("F. test_activar_desactivar")
	var inst = _nueva_instancia()
	_check("activar(isla_hielo) .is_true()", (inst.activar("isla_hielo")) == true)
	_check("esta_activo(isla_hielo) .is_true()", (inst.esta_activo("isla_hielo")) == true)
	inst.desactivar("isla_hielo")
	_check("esta_activo .is_false() tras desactivar", (inst.esta_activo("isla_hielo")) == false)
	_check("activar(id inexistente) .is_false()", (inst.activar("__no_existe__")) == false)
	inst.free()

	_fin("F. test_activar_desactivar")


func _bloque_G() -> void:
	_ini("G. test_bundles")
	var inst = _nueva_instancia()
	var b: Dictionary = inst.bundle("bundle_deluxe")
	_check("bundle(bundle_deluxe) no vacio", (not b.is_empty()) == true)
	var contiene: Array = inst.bundles_que_contienen("isla_hielo")
	_check("bundles_que_contienen(isla_hielo) incluye bundle_deluxe", ("bundle_deluxe" in contiene) == true)
	_check("bundle(id inexistente) vacio", (inst.bundle("__no_existe__").is_empty()) == true)
	inst.free()

	_fin("G. test_bundles")


func _bloque_H() -> void:
	_ini("H. test_seccion_guardado_integracion")
	if _auto != null:
		_check("get_section_name() == \"dlc\"", (_auto.get_section_name()) == "dlc")
	var sm = root.get_node_or_null("SaveManager")
	_check("SaveManager presente", (sm) != null)
	if sm != null:
		_check("SaveManager registra el proveedor \"dlc\"", (sm.snapshot._providers.has("dlc")) == true)

	_fin("H. test_seccion_guardado_integracion")


func _bloque_I() -> void:
	_ini("I. test_get_save_data")
	var inst = _nueva_instancia()
	inst.activar("isla_hielo")
	var data: Dictionary = inst.get_save_data()
	_check("data tiene 'activos'", (data.has("activos")) == true)
	_check("data tiene 'version_base'", (data.has("version_base")) == true)
	_check("activos incluye isla_hielo", ("isla_hielo" in data.get("activos", [])) == true)
	_check("version_base no vacia", (String(data.get("version_base", "")) != "") == true)
	inst.free()

	_fin("I. test_get_save_data")


func _bloque_J() -> void:
	_ini("J. test_roundtrip_persistencia")
	var src = _nueva_instancia()
	src.activar("isla_hielo")
	src.activar("pack_aurora")
	var data: Dictionary = src.get_save_data()
	var dst = _nueva_instancia()
	dst.restore_save_data(data)
	_check("roundtrip preserva isla_hielo", (dst.esta_activo("isla_hielo")) == true)
	_check("roundtrip preserva pack_aurora", (dst.esta_activo("pack_aurora")) == true)
	_check("roundtrip sin faltantes", (dst.dlcs_faltantes().size()) == 0)
	src.free()
	dst.free()

	_fin("J. test_roundtrip_persistencia")


func _bloque_K() -> void:
	_ini("K. test_reconciliacion_dlc_ausente")
	var dst = _nueva_instancia()
	dst.restore_save_data({"activos": ["isla_hielo", "__dlc_desinstalado__"], "version_base": "1.0.0"})
	_check("activa el DLC instalado", (dst.esta_activo("isla_hielo")) == true)
	_check("NO activa el DLC ausente", (dst.esta_activo("__dlc_desinstalado__")) == false)
	_check("registra el ausente en dlcs_faltantes", ("__dlc_desinstalado__" in dst.dlcs_faltantes()) == true)
	dst.free()

	_fin("K. test_reconciliacion_dlc_ausente")


func _bloque_L() -> void:
	_ini("L. test_version_guardada")
	var dst = _nueva_instancia()
	dst.restore_save_data({"activos": [], "version_base": "99.0.0"})
	_check("version_guardada() == 99.0.0", (dst.version_guardada()) == "99.0.0")
	_check("save_de_version_superior() .is_true()", (dst.save_de_version_superior()) == true)
	dst.restore_save_data({"activos": [], "version_base": "0.0.1"})
	_check("save_de_version_superior() .is_false() para version vieja", (dst.save_de_version_superior()) == false)
	dst.free()

	_fin("L. test_version_guardada")
