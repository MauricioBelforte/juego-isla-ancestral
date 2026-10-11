# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-09
# M18 Frente B: Test del catálogo de muebles (6 .tres).
extends SceneTree

var _fallos := 0
var _checks := 0
const CHECKS_MINIMOS := 12
const RUTAS := [
	"res://data/houses/cama_madera.tres",
	"res://data/houses/mesa_madera.tres",
	"res://data/houses/silla_madera.tres",
	"res://data/houses/cofre_madera.tres",
	"res://data/houses/lampara_pared.tres",
	"res://data/houses/estanteria.tres",
]

func _initialize() -> void:
	print("=== TEST M18 CATALOGO MUEBLES ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	var fd_script: Script = load("res://scripts/houses/furniture_data.gd")
	_check("FurnitureData.gd carga", fd_script != null)

	var cargados := 0
	for ruta in RUTAS:
		if FileAccess.file_exists(ruta):
			cargados += 1
			var res: Resource = load(ruta)
			_check("%s existe y carga" % ruta.get_file(), res != null)
			if res != null:
				_check("  nombre no vacío", String(res.nombre) != "")
				_check("  categoria válida", ["funcional", "decorativo", "almacenamiento"].has(res.categoria))
	_check("6 .tres presentes en disco", cargados == 6)

	# Verificar que el cofre es contenedor
	var cofre: Resource = load(RUTAS[3])
	if cofre != null:
		_check("cofre es_contenedor", cofre.es_contenedor())
		_check("cofre capacidad 30", int(cofre.capacidad_slots) == 30)

	# Verificar que la lámpara requiere pared
	var lampara: Resource = load(RUTAS[4])
	if lampara != null:
		_check("lampara requiere_pared", bool(lampara.requiere_pared))
		_check("lampara no requiere_superficie", not bool(lampara.requiere_superficie))

	# Verificar que la cama NO requiere pared
	var cama: Resource = load(RUTAS[0])
	if cama != null:
		_check("cama no requiere_pared", not bool(cama.requiere_pared))

	# Verificar volumen
	_check("cama volumen > 0", float(cama.obtener_volumen()) > 0.0)

	# Red de seguridad
	create_timer(0.3).timeout.connect(func(): _fin())

func _fin() -> void:
	_resumen()
	quit(1 if _fallos > 0 else 0)

func _resumen() -> void:
	print("=== Resumen M18-CAT: %d checks, %d fallos ===" % [_checks, _fallos])
	if _checks < CHECKS_MINIMOS:
		print("WARNING: solo %d checks (mínimo %d)" % [_checks, CHECKS_MINIMOS])

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)
