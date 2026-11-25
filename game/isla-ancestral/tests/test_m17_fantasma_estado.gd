extends SceneTree

# Modelo: minimax-m3-1-flash
# Plataforma: DeepAI Code (pi)
# Fecha: 2026-11-25
#
# M17 Construccion — estado VISUAL del fantasma (BuildGhost): que muestra y como.
#
# POR QUE EXISTE: tercer y ultimo tranche del barrido de la familia de defecto
# "el sistema muestra/reporta un estado que ya no es verdad" (L102 -> escritura
# atomica -> cache del fantasma -> aqui: el fantasma).
#
# DEFECTOS REALES CORREGIDOS (2026-11-25):
#   1. `MOTIVOS_OCULTAN` no incluia el motivo nuevo `TERRENO_NO_CARGADO`
#      (L102): el fantasma pintaba una CAJA ROJA flotando sobre una zona cuyo
#      chunk de terreno todavia no esta cargado (no hay referencia espacial).
#   2. `ocultar()` no reiniciaba la ANIMACION: si el fantasma se ocultaba a
#      media escala (0 < escala < 1) y se reutilizaba del pool, la caja
#      reaparecia a ESCALA PARCIAL y ya no cuadraba con la huella de la pieza
#      nueva (el jugador veia una caja mas pequeña que el sitio donde va).
#
# QUE MIDE (headless, BuildGhost real):
#   * el motivo TERRENO_NO_CARGADO ESCONDE el fantasma (como "sin terreno")
#   * los motivos de zona siguen escondiendolo (no se rompio nada)
#   * un resultado valido NO se esconde
#   * tras ocultar a media animacion, la escala vuelve a 1 (y la animacion se
#     cancela): el fantasma reutilizado del pool cuadra con la huella
#   * tras ocultar, no queda receta reportada (L192) ni celdas
#   * el LOD y el auto-ocultado siguen funcionando
#
# ANTI-FALSO-VERDE: MIN_CHECKS; checks nombrados con el texto literal del item.
#
# Uso: "Godot_v4.7.2-stable_win64_console.exe" --headless --path game/isla-ancestral \
#       --script res://tests/test_m17_fantasma_estado.gd
# Exit: 0 = verde | 1 = fallos

const MODULO := "M17 Construccion: estado visual del fantasma (BuildGhost)"
const TIPOS := preload("res://scripts/construccion/construccion_tipos.gd")
const CHECKS_MINIMOS := 12

var _checks := 0
var _fallos := 0
var _detalles: Array[String] = []


func _initialize() -> void:
	call_deferred("_correr")


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [ok]   %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])
	else:
		_fallos += 1
		_detalles.append(nombre + (" (" + detalle + ")" if detalle != "" else ""))
		print("  [FAIL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])


## Escala real del mesh del fantasma (la malla es hija 0 del BuildGhost).
func _escala_ghost(g: BuildGhost) -> Vector3:
	if g.get_child_count() == 0:
		return Vector3.ONE
	var m := g.get_child(0) as MeshInstance3D
	if m == null:
		return Vector3.ONE
	return m.scale


func _correr() -> void:
	await process_frame
	print("=== %s ===" % MODULO)

	var g := BuildGhost.new()
	g.name = "GhostPrueba"
	root.add_child(g)

	# ── A. El motivo TERRENO_NO_CARGADO esconde el fantasma ─────────────
	var res_no_cargado: Dictionary = {
		"ok": false,
		"motivos": [TIPOS.Motivo.TERRENO_NO_CARGADO],
		"celda": Vector3i(1, 1, 1),
		"celdas": [Vector3i(1, 1, 1)],
		"receta_id": &"pared_esquina",
	}
	_check("A1: debe_ocultarse = true con TERRENO_NO_CARGADO (no hay referencia espacial)",
		BuildGhost.debe_ocultarse(res_no_cargado))
	var vis1: bool = g.actualizar_visibilidad(res_no_cargado, true)
	_check("A2: con el terreno sin cargar el fantasma queda OCULTO",
		not vis1 and not g.esta_visible())
	_check("A3: sin terreno (terreno_cargado=false) el fantasma tambien se oculta",
		not g.actualizar_visibilidad({"ok": true, "motivos": []}, false))

	# ── B. Los motivos de zona SIGUEN escondiendolo (no se rompio) ─────
	for m in [TIPOS.Motivo.FUERA_DE_ZONA, TIPOS.Motivo.ZONA_PROTEGIDA,
			TIPOS.Motivo.ZONA_NARRATIVA, TIPOS.Motivo.AGUA_NO_PERMITIDA]:
		_check("B: el motivo %d sigue escondiendo el fantasma" % int(m),
			BuildGhost.debe_ocultarse({"ok": false, "motivos": [int(m)]}))
	_check("B2: un resultado VALIDO no se esconde",
		not BuildGhost.debe_ocultarse({"ok": true, "motivos": []}))

	# ── C. La caja no queda a media escala tras ocultarse ──────────────
	var receta := PlacementRule.new()
	receta.id = &"pared_esquina"
	receta.familia = &"estructura"
	receta.tamano = Vector2i(1, 1)
	receta.altura = 1.0
	receta.costo = {"madera": 2}
	receta.bloque = 3

	var res_ok: Dictionary = {
		"ok": true,
		"motivos": [],
		"celda": Vector3i(2, 1, 2),
		"celdas": [Vector3i(2, 1, 2)],
		"receta_id": &"pared_esquina",
		"rotacion": 0,
	}
	g.aplicar_resultado(res_ok, receta)
	_check("C0: tras aplicar un resultado valido el fantasma es visible", g.esta_visible())
	# Se "anima" a medias (como si el frame se cortara en mitad de la animacion).
	var mesh := g.get_child(0) as MeshInstance3D
	mesh.scale = Vector3(0.53, 0.53, 0.53)
	g.ocultar()
	_check("C1: al ocultar, la escala VUELVE a 1 (no queda a medias)",
		_escala_ghost(g) == Vector3.ONE, str(_escala_ghost(g)))
	# Reutilizacion desde el pool: el fantasma vuelve con la escala correcta.
	g.aplicar_resultado({"ok": false, "motivos": [], "celda": Vector3i(3, 1, 3),
		"celdas": [Vector3i(3, 1, 3)], "receta_id": &"otra"}, receta)
	_check("C2: el fantasma REUTILIZADO del pool aparece a escala 1 (cuadra con la huella)",
		_escala_ghost(g) == Vector3.ONE, str(_escala_ghost(g)))

	# ── D. Estado ocioso: no queda ni receta ni celdas (L192) ───────────
	g.ocultar()
	_check("D1: tras ocultar no queda receta reportada",
		g.receta_actual() == &"", str(g.receta_actual()))
	_check("D2: tras ocultar no quedan celdas reportadas",
		(g.celdas_actuales() as Array).is_empty())
	_check("D3: tras ocultar el fantasma no es visible", not g.esta_visible())

	# ── E. LOD y pool: siguen funcionando ──────────────────────────────
	g.aplicar_lod(10.0)
	_check("E1: a menos de 40 m no hay LOD", not g.en_lod())
	g.aplicar_lod(100.0)
	_check("E2: a mas de 40 m hay LOD", g.en_lod())
	var hijos_antes: int = g.hijos_creados()
	g.aplicar_resultado(res_ok, receta)
	_check("E3: aplicar un resultado NO crea nodos nuevos (pooling)",
		g.hijos_creados() == hijos_antes, "hijos=%d antes=%d" % [g.hijos_creados(), hijos_antes])
	g.devolver_al_pool()
	_check("E4: devolver al pool oculta el fantasma", not g.esta_visible())

	# ── F. El HUD dice "proba de nuevo" en los rechazos TEMPORALES ─────
	var res_temporal: Dictionary = ConstruccionTipos.resultado_fallo(
		[TIPOS.Motivo.TERRENO_NO_CARGADO], ["sin chunk"], [])
	_check("F1: un rechazo TEMPORAL (terreno no cargado) se marca como temporal",
		BuildHudModel.es_temporal(res_temporal))
	var linea_temporal: String = BuildHudModel.linea_estado(res_temporal, receta)
	_check("F2: la linea del HUD pide reintentar en un rechazo temporal",
		linea_temporal.contains("temporal") and linea_temporal.contains("proba de nuevo"),
		linea_temporal)
	# Resultado armado A MANO (sin la clave "temporal"): el HUD debe deducirlo
	# del motivo (si no, diria "RECHAZADO" sin invitation a reintentar).
	var res_mano: Dictionary = {"ok": false, "motivos": [TIPOS.Motivo.TERRENO_NO_CARGADO],
		"detalle": [], "celdas": [], "texto": "sin chunk"}
	_check("F3: un resultado sin la clave 'temporal' tambien se detecta como temporal (por el motivo)",
		BuildHudModel.es_temporal(res_mano))
	var res_perm: Dictionary = {"ok": false, "motivos": [TIPOS.Motivo.SIN_SOPORTE],
		"detalle": [], "celdas": [], "texto": "sin soporte"}
	_check("F4: un rechazo PERMANENTE (sin soporte) no se marca como temporal",
		not BuildHudModel.es_temporal(res_perm))
	_check("F5: la linea de un rechazo permanente NO pide reintentar",
		not BuildHudModel.linea_estado(res_perm, receta).contains("proba de nuevo"),
		BuildHudModel.linea_estado(res_perm, receta))

	# ── G. Anti-falso-verde ─────────────────────────────────────────────
	_check("G1: la suite ejecuta al menos %d checks (minimo anti-falso-verde)" % CHECKS_MINIMOS,
		_checks >= CHECKS_MINIMOS, "checks=%d" % _checks)

	print("--- %s: %d checks, %d fallos ---" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		for d in _detalles:
			print("  FALLO: %s" % d)
	quit(1 if _fallos > 0 else 0)
