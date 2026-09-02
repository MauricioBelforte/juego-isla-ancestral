extends SceneTree

func _init() -> void:
	var reg := ContextualDialogueManager._cargar_registry()
	print("REG vacio?: ", reg.is_empty())
	print("entries: ", reg.get("entries", []).size())
	print("npcs keys sample: ", reg.get("npcs", {}).keys().slice(0, 3))
	var slug := ContextualDialogueManager._slug_de(reg, "NPC-RIZ-001")
	print("slug NPC-RIZ-001 => ", slug)
	var slug2 := ContextualDialogueManager._slug_de(reg, "NPC-AUR-005")
	print("slug NPC-AUR-005 => ", slug2)
	var slug3 := ContextualDialogueManager._slug_de(reg, "NPC-COR-001")
	print("slug NPC-COR-001 => ", slug3)

	var ctx_prim := {"flag_capitulo": 0, "flag_riz_001_visitado": false, "estacion": "PRIMAVERA"}
	var r1 := ContextualDialogueManager.seleccionar("NPC-RIZ-001", "SALUDO", ctx_prim)
	print("R1 ok=", r1.ok, " err=", r1.get("error",""), " id=", r1.entry.get("id",""), " prio=", r1.entry.get("prioridad", -1), " graph=", r1.entry.get("graph",""))

	var ctx_verano := {"flag_capitulo": 0, "flag_riz_001_visitado": false, "estacion": "VERANO"}
	var r2 := ContextualDialogueManager.seleccionar("NPC-RIZ-001", "SALUDO", ctx_verano)
	print("R2 ok=", r2.ok, " id=", r2.entry.get("id",""), " prio=", r2.entry.get("prioridad", -1))

	var ctx_repeat := {"flag_capitulo": 0, "flag_riz_001_visitado": true}
	var r3 := ContextualDialogueManager.seleccionar("NPC-RIZ-001", "SALUDO", ctx_repeat)
	print("R3 ok=", r3.ok, " id=", r3.entry.get("id",""), " prio=", r3.entry.get("prioridad", -1))

	var r4 := ContextualDialogueManager.seleccionar("NPC-AUR-005", "SALUDO", {"flag_capitulo": 0, "es_noche": true})
	print("R4 ok=", r4.ok, " id=", r4.entry.get("id",""), " prio=", r4.entry.get("prioridad", -1), " err=", r4.get("error",""))

	var r5 := ContextualDialogueManager.seleccionar("NPC-COR-001", "HISTORIA", {"flag_capitulo": 0})
	print("R5 ok=", r5.ok, " id=", r5.entry.get("id",""), " prio=", r5.entry.get("prioridad", -1), " err=", r5.get("error",""))

	quit(0)
