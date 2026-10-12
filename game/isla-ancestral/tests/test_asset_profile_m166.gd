# Modelo: hy3 (WorkBuddy / Hunyuan)
# Plataforma: automatizacion Isla Ancestral
# Fecha: 2026-10-11
#
# M166 F1 — Test headless del autoload AssetProfile.
# Valida: deteccion (funciones puras + detectar_auto inyectable), ruta() y
# degradacion graceful.
# Uso: godot --headless -s res://tests/test_asset_profile_m166.gd
# Exit 0 = OK, 1 = fallo.

extends SceneTree

const _SC := preload("res://scripts/rendimiento/asset_profile.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M166] Test AssetProfile autoload (F1) + capa B (2 capas) ===")
	_test_puro()
	_test_deteccion()
	_test_ruta()
	_test_ruta_base()
	_test_degradacion()
	_test_variantes_pr()
	_test_fallback_gamesettings()
	_test_red_probe()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_puro() -> void:
	print("--- Funciones puras ---")
	var ap = _SC.new()
	_check("clasificar_vram 1.0 -> baja", ap.clasificar_vram(1.0) == "baja")
	_check("clasificar_vram 3.0 -> media", ap.clasificar_vram(3.0) == "media")
	_check("clasificar_vram 8.0 -> alta", ap.clasificar_vram(8.0) == "alta")
	_check("clasificar_vram -1.0 -> vacio", ap.clasificar_vram(-1.0) == "")
	_check("validar_perfil 'x' -> media", ap.validar_perfil("x") == "media")
	_check("validar_perfil 'alta' -> alta", ap.validar_perfil("alta") == "alta")
	_check("es_gpu_blacklist Intel HD 4000", ap.es_gpu_blacklist("Intel HD Graphics 4000"))
	_check("es_gpu_blacklist Mali-T860", ap.es_gpu_blacklist("Mali-T860"))
	_check("es_gpu_blacklist GPU buena -> false", not ap.es_gpu_blacklist("NVIDIA RTX 4060"))
	_check("perfil_mas_alto [media,baja] -> media", ap.perfil_mas_alto_disponible(["media", "baja"]) == "media")
	_check("perfil_mas_alto [alta,media,baja] -> alta", ap.perfil_mas_alto_disponible(["alta", "media", "baja"]) == "alta")
	_check("perfil_mas_alto [baja] -> baja", ap.perfil_mas_alto_disponible(["baja"]) == "baja")
	_check("perfil_mas_alto [] -> media", ap.perfil_mas_alto_disponible([]) == "media")

func _test_deteccion() -> void:
	print("--- detectar_auto (parametros inyectados) ---")
	var ap = _SC.new()
	# mobile -> baja
	_check("detectar_auto Android -> baja", ap.detectar_auto("ARM", "", "Android", -1.0) == "baja")
	# Apple M -> media
	_check("detectar_auto Apple M1 -> media", ap.detectar_auto("Apple M1 Pro", "", "macOS", -1.0) == "media")
	# GPU blacklist -> baja
	_check("detectar_auto GPU blacklist -> baja", ap.detectar_auto("Intel Core", "Intel HD Graphics 4000", "Windows", -1.0) == "baja")
	# VRAM <2 -> baja
	_check("detectar_auto VRAM 1GB -> baja", ap.detectar_auto("AMD Ryzen", "", "Windows", 1.0) == "baja")
	# VRAM 3GB -> media
	_check("detectar_auto VRAM 3GB -> media", ap.detectar_auto("AMD Ryzen", "", "Windows", 3.0) == "media")
	# VRAM 8GB -> alta
	_check("detectar_auto VRAM 8GB -> alta", ap.detectar_auto("AMD Ryzen", "", "Windows", 8.0) == "alta")
	# fallback: desktop decente, VRAM desconocida -> media
	_check("detectar_auto fallback -> media", ap.detectar_auto("AMD Ryzen", "", "Windows", -1.0) == "media")

func _test_ruta() -> void:
	print("--- ruta() ---")
	var ap = _SC.new()
	ap.perfil = "media"
	_check("ruta formato media", ap.ruta("25-Ruinas-Templos_cofre_ancestral") == "res://assets/3d/media/25-Ruinas-Templos_cofre_ancestral.glb",
		ap.ruta("25-Ruinas-Templos_cofre_ancestral"))
	ap.perfil = "alta"
	_check("ruta formato alta", ap.ruta("25-Ruinas-Templos_cofre_ancestral") == "res://assets/3d/alta/25-Ruinas-Templos_cofre_ancestral.glb",
		ap.ruta("25-Ruinas-Templos_cofre_ancestral"))

func _test_degradacion() -> void:
	print("--- degradacion por variantes_disponibles ---")
	var ap = _SC.new()
	# activo baja, solo alta disponible -> degrada a alta
	ap.perfil = "baja"
	var r1 := ap.ruta("15-Recursos_cristal_ancestral", ["alta"])
	_check("degrada baja->alta (solo alta)", r1 == "res://assets/3d/alta/15-Recursos_cristal_ancestral.glb", r1)
	# activo alta, solo baja disponible -> degrada a baja (mas alto disponible)
	ap.perfil = "alta"
	var r2 := ap.ruta("15-Recursos_monton_ramas", ["baja"])
	_check("degrada alta->baja (solo baja)", r2 == "res://assets/3d/baja/15-Recursos_monton_ramas.glb", r2)
	# activo alta, media+baja disponible -> degrada a media
	var r2b := ap.ruta("15-Recursos_monton_ramas", ["media", "baja"])
	_check("degrada alta->media (sin alta)", r2b == "res://assets/3d/media/15-Recursos_monton_ramas.glb", r2b)
	# disponible -> sin degradacion
	var r3 := ap.ruta("x", ["alta", "media", "baja"])
	_check("sin degradacion si disponible", r3 == "res://assets/3d/alta/x.glb", r3)

func _test_ruta_base() -> void:
	print("--- ruta() capa B: ruta base / .glb / legacy res:// ---")
	var ap = _SC.new()
	ap.perfil = "alta"
	# ruta base con extension .glb -> stem extraido y perfilado
	_check("ruta base .glb alta", ap.ruta("45-Arte3D_totem_isla.glb") == "res://assets/3d/alta/45-Arte3D_totem_isla.glb", ap.ruta("45-Arte3D_totem_isla.glb"))
	# ruta completa legacy se reprefila al perfil activo (el perfil embebido se ignora)
	ap.perfil = "media"
	_check("ruta legacy res:// reprefilada media", ap.ruta("res://assets/3d/alta/45-Arte3D_totem_isla.glb") == "res://assets/3d/media/45-Arte3D_totem_isla.glb", ap.ruta("res://assets/3d/alta/45-Arte3D_totem_isla.glb"))
	# stem puro sigue funcionando (retrocompatibilidad con consumidores existentes)
	ap.perfil = "alta"
	_check("ruta stem puro alta", ap.ruta("foo_bar") == "res://assets/3d/alta/foo_bar.glb", ap.ruta("foo_bar"))

func _test_variantes_pr() -> void:
	print("--- PlacementRule.variantes_disponibles (capa B) ---")
	var pr = PlacementRule.desde_dict({
		"id": "alfombra",
		"mesh_path": "18-Casas_alfombra.glb",
		"variantes_disponibles": ["alta", "media", "baja"],
	})
	_check("PR variantes round-trip alta", pr.variantes_disponibles.has("alta"))
	_check("PR variantes round-trip baja", pr.variantes_disponibles.has("baja"))
	_check("PR variantes 3 elementos", pr.variantes_disponibles.size() == 3, str(pr.variantes_disponibles.size()))
	var d := pr.a_dict()
	_check("PR a_dict incluye variantes", d.has("variantes_disponibles") and (d["variantes_disponibles"] as PackedStringArray).size() == 3)
	# sin variantes declaradas -> vacio (AssetProfile no degrada)
	var pr2 = PlacementRule.desde_dict({"id": "x", "mesh_path": "x.glb"})
	_check("PR sin variantes -> vacio", pr2.variantes_disponibles.is_empty())
	# AssetProfile.ruta usa las variantes de la receta (base .glb + degradacion)
	var ap = _SC.new()
	ap.perfil = "baja"
	# baja esta declarada en variantes -> NO degrada (queda baja)
	var r1 := ap.ruta(pr.mesh_path, pr.variantes_disponibles)
	_check("ruta PR base con variantes baja disponible", r1 == "res://assets/3d/baja/18-Casas_alfombra.glb", r1)
	# si falta baja, degrada al mas alto disponible (alta)
	ap.perfil = "baja"
	var r1b := ap.ruta(pr.mesh_path, ["media", "alta"])
	_check("ruta PR base degrada baja->alta", r1b == "res://assets/3d/alta/18-Casas_alfombra.glb", r1b)

func _test_fallback_gamesettings() -> void:
	print("--- fallback cuando GameSettings no existe / override ausente ---")
	var ap = _SC.new()
	# sin override y (en este test) sin GameSettings accesible -> debe caer a un perfil valido
	ap.recalcular("")
	_check("recalcular() sin override -> perfil valido", ["baja", "media", "alta"].has(ap.perfil), ap.perfil)
	# override explicito siempre gana y se normaliza
	ap.recalcular("alta")
	_check("recalcular override 'alta' -> alta", ap.perfil == "alta", ap.perfil)
	ap.recalcular("desconocido_xyz")
	_check("recalcular override invalido -> media", ap.perfil == "media", ap.perfil)

func _test_red_probe() -> void:
	print("--- SONDA ROJA: override invalido / ruta nunca vacia / degradacion real ---")
	var ap = _SC.new()
	ap.perfil = "media"
	# override invalido debe caer a media (validar_perfil)
	ap.recalcular("zzz")
	_check("recalcular override invalido -> media", ap.perfil == "media", ap.perfil)
	# perfil forzado invalido no debe producir ruta vacia
	ap.perfil = "baja"
	_check("ruta nunca vacia", not ap.ruta("x").is_empty())
	# degradacion con variantes validas pero activo ausente siempre resuelve algo
	ap.perfil = "alta"
	var r4 := ap.ruta("y", ["media"])
	_check("degrada alta->media (r4)", r4 == "res://assets/3d/media/y.glb", r4)
	# SONDA ROJA capa B: ruta base .glb + variante faltante -> degrada al mas alto
	ap.perfil = "baja"
	var r5 := ap.ruta("18-Casas_alfombra.glb", ["media", "alta"])
	_check("degrada base .glb baja->alta (r5)", r5 == "res://assets/3d/alta/18-Casas_alfombra.glb", r5)
	# SONDA ROJA: stem mal extraido detectaria extension pegada -> este check fallaria
	var r6 := ap.ruta("18-Casas_alfombra.glb", ["alta"])
	_check("stem sin .glb pegado (r6)", not r6.ends_with(".glb.glb"), r6)

func _summary() -> void:
	print("=== Resumen M166 F1: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M166 F1 FALLIDO — salida con codigo 1")
		quit(1)
	else:
		print("TEST M166 F1 OK — todos los checks pasaron")
		quit(0)
