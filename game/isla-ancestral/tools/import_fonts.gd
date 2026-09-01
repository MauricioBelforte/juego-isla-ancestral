@tool
extends SceneTree

## Script para importar fuentes TTF/OTF al proyecto.
## Ejecutar con: godot --headless -s tools/import_fonts.gd

func _init() -> void:
	var fonts := [
		"res://assets/fonts/Nunito-Regular.ttf",
		"res://assets/fonts/Nunito-Bold.ttf",
		"res://assets/fonts/FredokaOne-Regular.ttf",
	]
	
	for path in fonts:
		print("Importando: ", path)
		var font := load(path) as Font
		if font:
			print("  OK: ", path, " → ", font)
		else:
			print("  FALLO: ", path)
	
	print("=== Importación completada ===")
	quit()
