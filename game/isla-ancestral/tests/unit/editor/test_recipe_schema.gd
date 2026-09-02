extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

## M109 iter 1: tests del núcleo del Editor de Recetas (RecipeSchema).
## Regla: validar() (receta válida/inválida por campos) y roundtrip de costes.

const SCHEMA := preload("res://scripts/editor/support/recipe_schema.gd")

func test_receta_valida_pico_cobre() -> void:
	var receta := {
		"nombre": "Pico de cobre", "categoria": "herramientas", "nivel": 1,
		"estacion": "mesa_trabajo", "origen": "inicial",
		"coste_recursos": {"madera_roble": 3, "mineral_cobre": 4},
		"coste_ao": 0, "resultado": "pico_cobre", "resultado_cantidad": 1
	}
	var errores := SCHEMA.validar("rec_pico_cobre", receta)
	assert_that(errores).is_empty()

func test_receta_invalida_sin_costes() -> void:
	var receta := {
		"nombre": "Invalida", "categoria": "herramientas", "nivel": 1,
		"estacion": "mesa_trabajo", "coste_recursos": {},
		"resultado": "algo", "resultado_cantidad": 1
	}
	var errores := SCHEMA.validar("rec_invalida", receta)
	assert_that(errores).has_any_item("coste_recursos vacío o inválido")

func test_receta_invalida_campos() -> void:
	var errores := SCHEMA.validar("", {"nombre": ""})
	assert_that(errores).contains("id vacío")
	assert_that(errores).contains("receta vacía")

func test_receta_invalida_estacion_y_nivel() -> void:
	var receta := {
		"nombre": "R", "categoria": "puzzle", "nivel": 0,
		"estacion": "voladora", "coste_recursos": {"madera_roble": 1},
		"resultado": "x", "resultado_cantidad": 2
	}
	var errores := SCHEMA.validar("rec_r", receta)
	assert_that(errores).contains("nivel debe ser >= 1")
	assert_that(errores).contains("estacion inválida: voladora")

func test_costes_roundtrip() -> void:
	var costes := {"madera_roble": 3, "mineral_cobre": 4}
	var texto := SCHEMA.costes_a_texto(costes)
	var de_vuelta := SCHEMA.texto_a_costes(texto)
	assert_that(de_vuelta).is_equal(costes)

func test_texto_a_costes_invalido() -> void:
	assert_that(SCHEMA.texto_a_costes("madera_roble:3, mal")).is_empty()
	assert_that(SCHEMA.texto_a_costes("madera_roble:abc")).is_empty()
