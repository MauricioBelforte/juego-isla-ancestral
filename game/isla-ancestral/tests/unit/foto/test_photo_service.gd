extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

## M56 iter 1: tests del núcleo fotográfico (PhotoService + FotoSchema).
## Presets válidos de foto_presets.json, activación de modo y preset inexistente.

const SCHEMA := preload("res://scripts/foto/foto_schema.gd")
const SERVICE := preload("res://scripts/foto/photo_service.gd")

func test_foto_schema_valida_ok() -> void:
	var preset := {"nombre": "Cálido", "saturacion": 1.08, "contraste": 1.05,
		"temperatura": 0.12, "vineta": 0.08, "dof": 0.0}
	assert_that(SCHEMA.validar_preset("calido", preset)).is_empty()

func test_foto_schema_rechaza() -> void:
	var mal := {"nombre": "", "saturacion": 0.0}
	var errores := SCHEMA.validar_preset("mal", mal)
	assert_that(errores).contains("nombre ausente")
	assert_that(errores).contains("campo ausente: contraste")
	assert_that(errores).contains("saturacion debe ser > 0")

func test_photo_service_presets_cargados() -> void:
	var service := SERVICE.new()
	add_child(service)
	await service.ready
	assert_that(service.presets().size()).is_equal(6)
	assert_that(service.presets()).contains("crepusculo_rojo")
	service.free()

func test_photo_service_modo_y_preset() -> void:
	var service := SERVICE.new()
	add_child(service)
	await service.ready
	var senal := false
	service.modo_foto_cambiado.connect(func(a): senal = a)
	service.set_modo_foto(true)
	assert_that(service.modo_foto()).is_true()
	assert_that(senal).is_true()
	var preset := service.aplicar_preset("calido_playa")
	assert_that(float(preset["temperatura"])).is_equal(0.12)
	service.free()

func test_photo_service_preset_inexistente_vuelve_natural() -> void:
	var service := SERVICE.new()
	add_child(service)
	await service.ready
	var preset := service.aplicar_preset("no_existe")
	assert_that(preset.has("nombre")).is_true()
	service.free()
