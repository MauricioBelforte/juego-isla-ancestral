# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M160: Generador de seeds .tres de ubicaciones para COR/CEN/AUR
# (patrón _save_riz de world_locations.gd; los lugares provienen del canon
# M147: laguna/templo coral, volcan/templo ceniza, cielo/templo aurora).
# Uso: godot --headless --path game/isla-ancestral -s res://scripts/data/generar_seeds_islas.gd

extends SceneTree

const LD_PATH := "res://scripts/data/location_data.gd"
const LR_PATH := "res://scripts/data/location_requirements.gd"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var LD = load(LD_PATH)
	var LR = load(LR_PATH)
	if not LD or not LR:
		print("[M160] ERROR: clases de datos no encontradas")
		quit(1)
		return
	var seeds := [
		{"location_id": "LOC-COR-SEL-001", "nombre": "Laguna Coral", "tipo": 10, "isla": 1,
		 "descripcion": "Laguna turquesa de la Isla Coral. Casa del sello coral.", "tags": ["isla_coral", "sello"], "conexiones": ["LOC-COR-TEM-001"]},
		{"location_id": "LOC-COR-TEM-001", "nombre": "Templo Coral", "tipo": 11, "isla": 1,
		 "descripcion": "Templo ancestral del arrecife. Guiado por el sacerdote del coral.", "tags": ["templo", "sello"], "conexiones": ["LOC-COR-SEL-001"]},
		{"location_id": "LOC-CEN-MON-001", "nombre": "Volcan de la Ceniza", "tipo": 9, "isla": 2,
		 "descripcion": "Volcan activo que domina la Isla Ceniza. Casa del sello ceniza.", "tags": ["isla_ceniza", "sello"], "conexiones": ["LOC-CEN-TEM-001"]},
		{"location_id": "LOC-CEN-TEM-001", "nombre": "Templo de la Ceniza", "tipo": 11, "isla": 2,
		 "descripcion": "Templo tallado en la roca volcanica. Guardián de hilos de piedra.", "tags": ["templo", "sello"], "conexiones": ["LOC-CEN-MON-001"]},
		{"location_id": "LOC-AUR-PUER-001", "nombre": "Cielo de la Aurora", "tipo": 8, "isla": 3,
		 "descripcion": "Puerto celestial al borde de las auroras. Casa del sello aurora.", "tags": ["isla_aurora", "sello"], "conexiones": ["LOC-AUR-TEM-001"]},
		{"location_id": "LOC-AUR-TEM-001", "nombre": "Templo de la Aurora", "tipo": 11, "isla": 3,
		 "descripcion": "Templo flotante rodeado de luces ancestrales. Final del viaje.", "tags": ["templo", "sello"], "conexiones": ["LOC-AUR-PUER-001"]},
	]
	var guardados := 0
	for data in seeds:
		var loc = LD.new()
		loc.location_id = data.location_id
		loc.nombre = data.nombre
		loc.tipo = data.tipo
		loc.isla = data.isla
		loc.descripcion = data.descripcion
		loc.ampliable = false
		loc.tags = data.tags
		loc.npcs = []
		loc.conexiones = data.conexiones
		loc.objetos = []
		var req = LR.new()
		req.herramienta_minima = ""
		req.costo_entrada = 0
		req.items_requeridos = []
		req.npcs_requeridos = []
		req.descripcion_requisitos = "Viaje desbloqueado (M28)"
		var dir_path := "res://data/locations/" + String(data.location_id.split("-")[1]) + "/"
		var dir := DirAccess.open(dir_path)
		if not dir:
			DirAccess.make_dir_recursive_absolute(dir_path)
		var path = dir_path + data.location_id + ".tres"
		var err := ResourceSaver.save(loc, path)
		if err == OK:
			guardados += 1
			print("[M160] seed: %s -> %s" % [data.location_id, path])
		else:
			print("[M160] ERROR guardando %s (err %d)" % [data.location_id, err])
	print("[M160] Seeds generados: %d" % guardados)
	quit(0 if guardados == seeds.size() else 1)
