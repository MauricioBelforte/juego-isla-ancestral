extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

## Unit tests para NPCVisualDatabase (M161)
## Verifica la funcionalidad del diseño visual de NPCs

func test_npc_visual_database_ready() -> void:
	var db = NPCVisualDatabase.new()
	add_child(db)
	await db.ready
	assert_that(db.visuals).is_not_null()
	print("[TEST] NPCVisualDatabase inicializado con %d diseños" % db.visuals.size())

func test_get_visual_existing() -> void:
	var db = NPCVisualDatabase.new()
	add_child(db)
	await db.ready

	var visual = db.get_visual("NPC-RIZ-002")
	assert_that(visual).is_not_null()
	assert_that(visual.npc_id).is_equal_to("NPC-RIZ-002")
	assert_that(visual.nombre).is_equal_to("Carpintero")

func test_get_visual_missing() -> void:
	var db = NPCVisualDatabase.new()
	add_child(db)
	await db.ready

	var visual = db.get_visual("NPC-INEXISTENTE")
	assert_that(visual).is_null()

func test_get_visuals_by_island() -> void:
	var db = NPCVisualDatabase.new()
	add_child(db)
	await db.ready

	var visuals_riz = db.get_visuals_by_island("RIZ")
	assert_that(visuals_riz).is_not_null()
	assert_that(visuals_riz.size()).is_greater_than(0)

func test_get_visuals_by_island_count() -> void:
	var db = NPCVisualDatabase.new()
	add_child(db)
	await db.ready

	var visuals_riz = db.get_visuals_by_island("RIZ")
	assert_that(visuals_riz.size()).is_equal_to(8)

func test_get_visuals_all_islands() -> void:
	var db = NPCVisualDatabase.new()
	add_child(db)
	await db.ready

	assert_that(db.get_visuals_by_island("RIZ").size()).is_equal_to(8)
	assert_that(db.get_visuals_by_island("COR").size()).is_equal_to(5)
	assert_that(db.get_visuals_by_island("CEN").size()).is_equal_to(5)
	assert_that(db.get_visuals_by_island("AUR").size()).is_equal_to(5)

func test_get_seasonal_variant_returns_base_when_empty() -> void:
	var db = NPCVisualDatabase.new()
	add_child(db)
	await db.ready

	var visual = db.get_visual("NPC-RIZ-002")
	if visual:
		var spring = visual.get_seasonal_variant("PRIMAVERA")
		assert_that(spring).is_not_null()
		assert_that(spring).is_equal(visual)

func test_npc_visual_data_fields() -> void:
	var data = NPCVisualData.new()
	data.npc_id = "NPC-TEST-001"
	data.nombre = "Test NPC"
	data.isla = "RIZ"
	data.piel = "SK-01"
	data.cabello = "HR-01"
	data.ojos = "EY-01"
	data.complexion = "MEDIA"

	assert_that(data.npc_id).is_equal_to("NPC-TEST-001")
	assert_that(data.piel).is_equal_to("SK-01")
	assert_that(data.cabello).is_equal_to("HR-01")

func test_ropa_data_fields() -> void:
	var ropa = RopaData.new()
	ropa.nombre = "Camisa de prueba"
	ropa.color_principal = "#FF0000"
	ropa.material = "Lino"

	assert_that(ropa.nombre).is_equal_to("Camisa de prueba")
	assert_that(ropa.color_principal).is_equal_to("#FF0000")

func test_accesorio_data_fields() -> void:
	var acc = AccesorioData.new()
	acc.nombre = "Anillo de prueba"
	acc.ubicacion = "manos"
	acc.color = "#00FF00"

	assert_that(acc.nombre).is_equal_to("Anillo de prueba")
	assert_that(acc.ubicacion).is_equal_to("manos")

func test_npc_visual_has_required_fields() -> void:
	var db = NPCVisualDatabase.new()
	add_child(db)
	await db.ready

	for npc_id in db.visuals.keys():
		var visual = db.get_visual(npc_id)
		assert_that(visual.npc_id).is_not_empty()
		assert_that(visual.nombre).is_not_empty()
		assert_that(visual.isla).is_not_empty()
		assert_that(visual.piel).is_not_empty()
		assert_that(visual.cabello).is_not_empty()
		assert_that(visual.ojos).is_not_empty()

func test_npc_visual_clothing_has_colors() -> void:
	var db = NPCVisualDatabase.new()
	add_child(db)
	await db.ready

	for npc_id in db.visuals.keys():
		var visual = db.get_visual(npc_id)
		assert_that(visual.sombrero).is_not_null()
		assert_that(visual.sombrero.color_principal).is_not_empty()
		assert_that(visual.torso).is_not_null()
		assert_that(visual.torso.color_principal).is_not_empty()

func test_npc_visual_hex_colors_valid() -> void:
	var db = NPCVisualDatabase.new()
	add_child(db)
	await db.ready

	var hex_regex = RegEx.new()
	hex_regex.compile("^#[0-9A-Fa-f]{6}$")

	for npc_id in db.visuals.keys():
		var visual = db.get_visual(npc_id)
		var fields = [visual.sombrero.color_principal, visual.sombrero.color_secundario, visual.torso.color_principal, visual.piernas.color_principal, visual.pies.color_principal]
		for color in fields:
			if color != "":
				assert_that(hex_regex.search(color)).is_not_null()

