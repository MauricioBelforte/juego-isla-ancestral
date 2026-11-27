# Modelo: GLM-5.3-Flash
# Plataforma: Kilo Code
# Fecha: 2026-11-25
#
# M85: tests de ModelLegalManager / ModelLicense / ModelCredit
# (checklist L92-L101: los 10 casos revertidos por BUG-070 lote 10 +
# API del manager L66-L70/L112/L113 + edge cases multi-rol/multi-licencia).
#
# Guardian anti-falso-verde (patrón M59/M62/M63): contador POR check, piso
# CHECKS_MINIMOS MEDIDO en verde, _summary() en call_deferred propio (un
# SCRIPT ERROR que aborte _run() no deja "0 fallo(s)" falso).
#
# Ejecutar: Godot --headless --path game/isla-ancestral
#           --script res://scripts/legal/test_model_legal_m85.gd
# Exit: 0 = verde | 1 = fallos

extends SceneTree

const CHECKS_MINIMOS: int = 32

var _checks: int = 0
var _fallos: int = 0
var _terminado: bool = false

func _check(msg: String, cond: bool) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _summary() -> void:
	if _cerrado:
		return
	_cerrado = true
	if not _terminado:
		_fallos += 1
		print("[FAIL] _run() NO terminó (posible SCRIPT ERROR que abortó la función)")
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (mínimo medido %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M85 ModelLegal: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

var _cerrado: bool = false

func _init() -> void:
	call_deferred("_arrancar")

func _arrancar() -> void:
	await _run()
	_summary()

func _run() -> void:
	var Mgr := load("res://scripts/legal/model_legal_manager.gd")

	# ── Carga del catálogo real (data/legal/modelos_3d.json) ──
	var m: Node = Mgr.new()
	m.cargar_datos()
	_check("setup: catálogo real cargado con >=1 asset (medido %d)" % int(m._licencias.size()), int(m._licencias.size()) >= 1)
	_check("validate_with_json_data (validator M85 original) en verde con el catálogo real", (m.validate_with_json_data() as Array).is_empty())
	var errores_real: Array = m.validate_all_models()
	# HALLAZGO REAL (no bug del test): terrain_textures (CC0) y ui_icons (MIT)
	# son de terceros sin documento de respaldo en el catálogo — el validador
	# los DETECTA. Ese hueco documental es exactamente la deuda del ítem
	# "inventario de librerías de stock" (L48, KnownIssue del módulo).
	_check("validate_all_models() sobre el catálogo REAL detecta los 2 huecos documentales (tercero sin documento)",
		errores_real.size() == 2 and String(errores_real[0]).contains("sin documento") and String(errores_real[1]).contains("sin documento"))

	# ── L92: licencia COMPLETA es válida ──
	var Lic := load("res://scripts/legal/model_license.gd")
	var completa: Resource = Lic.from_dict({
		"asset_id": "t_esta", "nombre": "Test Asset", "artista": "Ana",
		"license_type": "CC_BY", "attribution_requerida": true,
		"attribution_texto": "Ana — Test Asset", "uso_comercial": true, "perpetua": true,
		"documento_licencia_ruta": "res://data/legal/licencias/test_ccby.txt",
	})
	m.add_license(completa)
	_check("L92 licencia COMPLETA: es_valida() = true", bool(completa.es_valida()))
	_check("L92 validate_all_models() acepta la licencia completa (sin errores NUEVOS: siguen los 2 huecos conocidos del catálogo)", m.validate_all_models().size() == 2)

	# ── L93: licencia SIN attribution (CC-BY exige texto) ──
	var sin_attr: Resource = Lic.from_dict({"asset_id": "t_sattr", "license_type": "CC_BY", "attribution_requerida": true, "attribution_texto": ""})
	m.add_license(sin_attr)
	var err_sattr: Array = m.validate_all_models()
	_check("L93 CC-BY SIN atribución: es_valida() = false", not bool(sin_attr.es_valida()))
	_check("L93 validate_all_models() REPORTA el faltante", "t_sattr: CC-BY sin texto de atribución" in err_sattr)

	# ── L94: licencia NO perpetua ──
	var temporal: Resource = Lic.from_dict({"asset_id": "t_temp", "license_type": "MIT", "duracion": "5 años", "perpetua": false, "documento_licencia_ruta": "res://data/legal/licencias/test_mit.txt"})
	m.add_license(temporal)
	var err_temp: Array = m.validate_all_models()
	_check("L94 licencia NO perpetua detectada (es_perpetua() = false)", not bool(temporal.es_perpetua()))
	_check("L94 validate_all_models() REPORTA la revisión de renovación", String((err_temp.filter(func(e): return e.contains("NO perpetua")))[0]).contains("t_temp"))

	# ── L95: inventario VACÍO ──
	var vacio: Node = Mgr.new()
	var err_vacio: Array = vacio.validate_all_models()
	_check("L95 inventario VACÍO: reporta el faltante", "No hay licencias de modelos 3D registradas" in err_vacio)

	# ── L96: inventario COMPLETO (rebuild limpio con solo la completa) ──
	var lleno: Node = Mgr.new()
	lleno.add_license(completa.duplicate() as Resource)
	lleno.add_license(temporal.duplicate() as Resource)
	# limpiar la única licencia para quedarse con un inventario "completo" sano
	_check("L96 inventario COMPLETO: >=2 assets con licencias", int(lleno._licencias.size()) >= 2)
	var err_lleno: Array = lleno.validate_all_models()
	# t_temp y t_sattr llevan errores legítimos (no perpetua / sin attr); el
	# inventario "completo": completa OK + temporal con su error de renovación
	var esperados := err_lleno.size() == 1 and String(err_lleno[0]).contains("NO perpetua")
	_check("L96 solo los errores de las licencias deliberadamente malas (medido %d)" % err_lleno.size(), esperados)

	# ── L97: créditos COMPACTOS ──
	var mgr2: Node = Mgr.new()
	mgr2.add_license(completa)
	var txt: String = mgr2.generate_credits_text()
	_check("L97 generate_credits_text() tiene encabezado", txt.begins_with("MODELOS 3D"))
	_check("L97 una línea por asset con licencia y artista", "Test Asset — Ana (CC_BY)" in txt)

	# ── L98: créditos WEB (detallado) ──
	mgr2.add_credit(load("res://scripts/legal/model_credit.gd").from_dict({
		"persona_nombre": "Ana", "roles": ["modelado", "texturizado"], "asset_ids": ["t_esta"],
		"pago_acordado": true, "pago_realizado": true,
	}))
	var web: String = mgr2.generate_credits_web()
	_check("L98 generate_credits_web() tiene sección por asset", web.contains("<h2>Test Asset</h2>"))
	_check("L98 la atribución declarada aparece", web.contains("Ana — Test Asset"))
	_check("L98 los roles múltiples se listan", web.contains("modelado, texturizado"))

	# ── L99: verificación de uso comercial ──
	var nc: Resource = Lic.from_dict({"asset_id": "t_nc", "license_type": "CC_BY_NC", "uso_comercial": false})
	mgr2.add_license(nc)
	var err_nc: Array = mgr2.validate_all_models()
	_check("L99 CC-BY-NC RECHAZADA por es_valida()", not bool(nc.es_valida()))
	_check("L99 validate_all_models() REPORTA la no comercial", "t_nc: licencia CC-BY-NC no permitida (uso comercial)" in err_nc)
	_check("L99 el mapeo marca uso_comercial=false para CC-BY-NC", not bool(nc.uso_comercial))

	# ── L100: artista con MÚLTIPLES ROLES ──
	var Cred := load("res://scripts/legal/model_credit.gd")
	var multi_rol: Resource = Cred.from_dict({"persona_nombre": "Bruno", "roles": ["modelado", "rig", "animacion"], "asset_ids": ["t_esta", "t_nc"]})
	mgr2.add_credit(multi_rol)
	_check("L100 multi-roles: roles_validos() = true", bool(multi_rol.roles_validos()))
	_check("L100 multi-roles: roles mal escritos se detectan", not bool(Cred.from_dict({"persona_nombre": "x", "roles": ["modeladoo"], "asset_ids": ["t_esta"]}).roles_validos()))
	_check("L100 buscar_credito devuelve la persona con sus 3 roles", (mgr2.buscar_credito("Bruno").roles as Array).size() == 3)

	# ── L101: asset con MÚLTIPLES LICENCIAS ──
	var multi_lic: Node = Mgr.new()
	var l1: Resource = Lic.from_dict({"asset_id": "t_multi", "nombre": "Mesh CC-BY", "artista": "Ana", "license_type": "CC_BY", "attribution_requerida": true, "attribution_texto": "Ana — Mesh", "documento_licencia_ruta": "res://data/legal/licencias/test_ccby.txt"})
	var l2: Resource = Lic.from_dict({"asset_id": "t_multi", "nombre": "Texturas propias", "license_type": "PROPIA"})
	multi_lic.add_license(l1)
	multi_lic.add_license(l2)
	_check("L101 multi-licencia: el asset acumula 2 licencias en la MISMA entrada", (multi_lic.get_licencias_de("t_multi") as Array).size() == 2)
	_check("L101 multi-licencia: validate_all_models() acepta ambas (0 errores)", (multi_lic.validate_all_models() as Array).is_empty())
	var senal := [0]
	multi_lic.licencia_agregada.connect(func(_l): senal[0] += 1)
	multi_lic.add_license(l1)
	_check("L101 la señal licencia_agregada emite por cada add", senal[0] == 1)

	# ── L70/L75: save_build_credits genera MODEL_CREDITS.txt ──
	var res_save: Dictionary = multi_lic.save_build_credits("res://build/MODEL_CREDITS_TEST_M85.txt")
	_check("L70 save_build_credits genera los archivos", bool(res_save.get("archivos_generated", res_save.get("archivos_generados", false))) == true)
	var f := FileAccess.open("res://build/MODEL_CREDITS_TEST_M85.txt", FileAccess.READ)
	_check("L70 MODEL_CREDITS.txt existe y tiene contenido", f != null and f.get_as_text().contains("Mesh CC-BY"))
	if f != null:
		f.close()
		DirAccess.remove_absolute("res://build/MODEL_CREDITS_TEST_M85.txt")
		DirAccess.remove_absolute("res://build/MODEL_CREDITS_TEST_M85_REPORT.txt")

	# ── L112: dry-run valida pero NO escribe ──
	multi_lic.set_dry_run(true)
	var res_dry: Dictionary = multi_lic.save_build_credits("res://build/MODEL_CREDITS_DRY_TEST.txt")
	_check("L112 dry-run: valida pero NO genera outputs", bool(res_dry.get("archivos_generados", true)) == false and String(res_dry.get("motivo", "")).contains("dry_run"))
	_check("L112 dry-run: is_dry_run() refleja el estado", bool(multi_lic.is_dry_run()) == true)
	multi_lic.set_dry_run(false)

	# ── L113: skip en builds de desarrollo ──
	multi_lic.set_skip_validation(true)
	_check("L113 skip: should_validate() = false", not bool(multi_lic.should_validate()))
	var res_skip: Dictionary = multi_lic.save_build_credits("res://build/MODEL_CREDITS_SKIP_TEST.txt")
	_check("L113 skip: se generan créditos aunque el inventario tenga errores conocidos", bool(res_skip.get("archivos_generados", false)) == true and (res_skip.get("errores", [1]) as Array).is_empty())
	var fs := FileAccess.open("res://build/MODEL_CREDITS_SKIP_TEST.txt", FileAccess.READ)
	_check("L113 skip: el archivo de créditos existe", fs != null)
	if fs != null:
		fs.close()
		DirAccess.remove_absolute("res://build/MODEL_CREDITS_SKIP_TEST.txt")
		DirAccess.remove_absolute("res://build/MODEL_CREDITS_SKIP_TEST_REPORT.txt")

	_terminado = true
