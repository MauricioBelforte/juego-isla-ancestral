# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M118 iter. 2/3 — Test headless: gates automáticos (data_valid +
# assets_existen) y artefactos (semver, SHA256, firma HMAC, fallback manual).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/ci/test_gates_m118.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var m118 := root.get_node_or_null("CiCdManager")
	_check(m118 != null, "CiCdManager autoload presente")
	if m118 == null:
		print("=== TEST M118 ITER2: 1 fallo(s) ===")
		quit(1)
		return
	# Gate data_valid: todos los .json de data/ parsean sin error (retorna bool)
	var r_data: bool = m118.gate_data_valid()
	_check(r_data, "gate_data_valid OK (0 errores)")
	# Gate assets_existen: GLBs en media/ no vacíos
	var r_assets: bool = m118.gate_assets_existen()
	_check(r_assets, "gate_assets_existen OK")
	# Ejecutar todos los gates automáticos
	var res: Dictionary = m118.ejecutar_gates_automaticos()
	_check(res.has("data_valid"), "ejecutar_gates_automaticos incluye data_valid")
	_check(res.has("assets_existen"), "ejecutar_gates_automaticos incluye assets_existen")
	# ═══ Iter. 3: artefactos ═══
	# Validación de tag semver
	var t_ok: Dictionary = m118.validar_tag_semver("v1.2.3")
	_check(bool(t_ok.get("ok", false)), "validar_tag_semver acepta v1.2.3")
	_check(int(t_ok.get("major", 0)) == 1 and int(t_ok.get("minor", 0)) == 2 and int(t_ok.get("patch", 0)) == 3, "componentes semver correctos (1.2.3)")
	var t_bad: Dictionary = m118.validar_tag_semver("release-1")
	_check(not bool(t_bad.get("ok", true)), "validar_tag_semver rechaza formato inválido")
	_check(not bool(m118.validar_tag_semver("v01.2.3").get("ok", true)), "validar_tag_semver rechaza ceros a la izquierda")
	# Gate de calidad (M111): sin requisitos registrados debe fallar
	_check(not m118.gate_calidad_codigo(), "gate_calidad falla sin requisitos")
	m118.registrar_resultado("lint_ok", true)
	m118.registrar_resultado("tests_ok", true)
	m118.registrar_resultado("analisis_estatico_ok", true)
	_check(m118.gate_calidad_codigo(), "gate_calidad OK con requisitos registrados")
	# Fallback manual tras 3 fallos consecutivos
	_check(not m118.registrar_fallo_pipeline(), "fallo 1 no activa fallback")
	_check(not m118.registrar_fallo_pipeline(), "fallo 2 no activa fallback")
	_check(m118.registrar_fallo_pipeline(), "fallo 3 activa fallback manual")
	m118.registrar_exito_pipeline()
	_check(not bool(m118.resultados.get("fallback_manual_activo", true)), "registrar_exito resetea fallback")
	# Artefacto ZIP con SHA256 interno
	var ruta_test := "res://data/ci/ci_gates.json"
	var art: Dictionary = m118.generar_artefacto("test_m118", [ruta_test], "v0.0.0-test")
	_check(bool(art.get("ok", false)), "generar_artefacto crea ZIP")
	_check(String(art.get("sha256", "")).length() == 64, "SHA256 del artefacto tiene 64 hex")
	_check(FileAccess.file_exists(String(art.get("ruta", ""))), "ZIP existe en user://artefactos")
	_check(not bool(m118.generar_artefacto("test_m118", ["res://no/existe.json"], "v0.0.0-test").get("ok", true)), "generar_artefacto falla con archivo faltante")
	# Firma digital HMAC-SHA256 + verificación
	var firma: Dictionary = m118.firmar_artefacto(String(art.get("sha256", "")))
	_check(bool(firma.get("ok", false)), "firmar_artefacto firma el SHA256")
	var firma_hex := String(firma.get("firma", ""))
	_check(firma_hex.length() == 64, "firma HMAC tiene 64 hex")
	_check(m118.verificar_firma(String(art.get("sha256", "")), firma_hex), "verificar_firma acepta firma válida")
	_check(not m118.verificar_firma("sha_falso", firma_hex), "verificar_firma rechaza contenido alterado")
	# Limpieza de artefactos (retención): no debe eliminar el ZIP recién creado
	var limp: Dictionary = m118.limpiar_artefactos(30)
	_check(bool(limp.get("ok", false)), "limpiar_artefactos ejecuta sin errores")
	_check(FileAccess.file_exists(String(art.get("ruta", ""))), "ZIP reciente sobrevive a la limpieza")
	print("=== TEST M118 ITER2: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
