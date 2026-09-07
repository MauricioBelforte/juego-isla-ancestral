# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M50 iter 4: VegetationSpawner — instancia los GLB de vegetación del plan
# determinista (VegetationPlan) sobre el mundo real (snap con TerrainLocator).
# Autoload autocontenido: espera 2 frames (terreno listo), genera el plan y
# crea las instancias (variante media) en las posiciones del plan.

extends Node

const PLAN = preload("res://scripts/vegetacion/vegetation_plan.gd")

var _frames_espera: int = 0

var _poblado := false

func _ready() -> void:
	set_process(true)

func _process(_delta: float) -> void:
	if _poblado:
		return
	_frames_espera += 1
	if _frames_espera >= 2:
		set_process(false)
		_poblado = true
		_poblar()

## Genera el plan de la Isla Raíz (semilla 42, centro real M09 iter.) e instancia los GLB.
func _poblar() -> void:
	print("[M50] VegetationSpawner: poblando isla...")
	# M09 iter.: centro real de la isla (mundo 5120², radio interior 1800) —
	# antes (256,256) r=256, la esquina playa del mundo.
	var mundo = get_node_or_null("/root/MundoRaiz")
	var centro: Vector2 = Vector2(mundo.SPAWN_CONTENIDO.x, mundo.SPAWN_CONTENIDO.z) if mundo else Vector2(256, 256)
	var radio: float = 1200.0
	var plan: Array = PLAN.generar_plan(centro, radio, 42)
	print("[M50] Plan generado: %d items" % plan.size())
	var instanciadas: int = 0
	var omitidas: int = 0
	var sin_archivo: int = 0
	var en_agua: int = 0
	var locator := get_node_or_null("/root/TerrainLocator")
	print("[M50] TerrainLocator: %s" % ("found" if locator != null else "NOT FOUND"))
	for item in plan:
		var tipo: String = String(item["tipo"])
		var ruta := "res://assets/3d/media/%s.glb" % tipo
		if not FileAccess.file_exists(ruta):
			sin_archivo += 1
			omitidas += 1
			continue
		var res = load(ruta)
		if res == null:
			omitidas += 1
			continue
		var inst = res.instantiate()
		var x: float = item["posicion"]["x"]
		var z: float = item["posicion"]["z"]
		var h := -1
		if locator and locator.has_method("get_height"):
			h = locator.get_height(int(x), int(z))
		# BUG-022 (2026-09-02): no plantar sobre agua — solo tierra firme
		# (h>=3 = arena/playa real; h<3 = banda de agua clara o profunda).
		if h < 3:
			en_agua += 1
			omitidas += 1
			continue
		var y := float(h) + 0.1
		inst.position = Vector3(x, y, z)
		if inst is Node3D and inst.get("rotation_y") != null:
			pass
		# rotación del ítem
		if inst.has_method("set_rotation") or inst is Node3D:
			(inst as Node3D).rotation_degrees = Vector3(0, float(item["rotacion_y"]) * 57.2958, 0)
		# Escala por TIPO
		if inst is Node3D:
			var esc: float = _escala_de(String(item["tipo"]))
			(inst as Node3D).scale = Vector3(esc, esc, esc)
		get_tree().current_scene.add_child(inst)
		instanciadas += 1
	print("[M50] VegetationSpawner: %d instanciadas, %d omitidas (%d sin archivo, %d en agua)" % [instanciadas, omitidas, sin_archivo, en_agua])


## Tabla de escalas por familia de objeto (5-FUTURAS-MEJORAS "Estandarizar
## tamaños"): altura objetivo en metros ÷ altura GLB (~1m) = multiplicador.
## Ajustar con capturas visuales iterando (pattern M154: capturar→analizar→ajustar).

## Escala por tipo vía autoload EscalasGlobales (5-FUTURAS-MEJORAS).
func _escala_de(tipo: String) -> float:
	var eg := get_node_or_null("/root/EscalasGlobales")
	if eg != null and eg.has_method("escala_de"):
		return float(eg.escala_de(tipo))
	return 3.0
