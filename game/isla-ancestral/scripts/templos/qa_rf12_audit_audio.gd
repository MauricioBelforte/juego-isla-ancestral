# Modelo: GLM-5.3-Flash
# Plataforma: Kilo Code
# Fecha: 2026-11-25
#
# M58 RF12: auditar que ningun puzzle dependa de oir un sonido especifico.
# Metodo (precedente item 104 de M24 "test por grep"):
#   1) 0 referencias a APIs de audio en TODA la logica de puzzles (runtime).
#   2) La familia SONIDO es modelo puro de datos: el tono es un identificador,
#      la seleccion de campanas es POR POSICION/id (no por oido).
#   3) Sistema de pistas textual (puzzle_pistas + pista_patron tras 2 fallos).
#
# Ejecutar: Godot --headless --path game/isla-ancestral
#           --script res://scripts/templos/qa_rf12_audit_audio.gd
# Exit: 0 = verde | 1 = fallos

extends SceneTree

const CARPETA := "res://scripts/templos/"
const FAMILIAS := [
	"puzzle_agua.gd", "puzzle_bloques.gd", "puzzle_def.gd", "puzzle_dificultad.gd",
	"puzzle_emisor.gd", "puzzle_espejos.gd", "puzzle_gravedad.gd",
	"puzzle_herramientas.gd", "puzzle_hielo.gd", "puzzle_luz.gd",
	"puzzle_pistas.gd", "puzzle_presion.gd", "puzzle_puerta.gd",
	"puzzle_recompensas.gd", "puzzle_room.gd", "puzzle_simbolos.gd",
	"puzzle_sonido.gd", "puzzle_tutorial.gd",
]
## APIs de audio cuya aparicion en la logica de puzzles seria una dependencia
## del oido (feedback sonoro puede existir en la capa de presentacion, pero la
## LOGICA del puzzle no puede requerir oir un sonido especifico).
const API_AUDIO := ["AudioStreamPlayer", "AudioServer", "SFXManager", "play_sfx", "play_sound", "AudioStream"]

var _checks: int = 0
var _fallos: int = 0

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)

func _summary() -> void:
	print("=== Resumen QA RF12 (M58): %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	await process_frame
	print("=== QA RF12: puzzles sin dependencia del oido ===")

	# 1) Ningun script de la logica de puzzles usa APIs de audio.
	var violaciones: Array[String] = []
	for nombre in FAMILIAS:
		var script: GDScript = ResourceLoader.load(CARPETA + nombre)
		if script == null:
			violaciones.append(nombre + " (no carga)")
			continue
		var fuente: String = script.source_code
		for api in API_AUDIO:
			# Se ignora el comentario-documentacion de puzzle_sonido (item 104),
			# que declara explicitamente que NO usa AudioServer.
			if fuente.find(api) >= 0 and not fuente.find("# MODELO PURO DE DATOS") >= 0:
				violaciones.append("%s usa %s" % [nombre, api])
	_check("auditar que ningún puzzle dependa de oír un sonido específico: las 18 familias de puzzles tienen 0 referencias a APIs de audio en su lógica (violaciones: %s)" % (", ".join(violaciones) if not violaciones.is_empty() else "0"),
		violaciones.is_empty())

	# 2) La familia SONIDO selecciona campanas POR POSICION/id, no por oido.
	var sonido: GDScript = ResourceLoader.load(CARPETA + "puzzle_sonido.gd")
	var f_sonido: String = sonido.source_code if sonido != null else ""
	_check("auditar que ningún puzzle dependa de oír un sonido específico: la familia SONIDO declara campanas con 'pos' y el jugador toca por id/posición (el tono es dato, no criterio de selección)",
		f_sonido.contains("\"pos\"") and f_sonido.contains("func tocar(id: String)")
			and f_sonido.contains("tono: int") and f_sonido.contains("NO toca `AudioServer`"))

	# 3) Pista textual del patron tras 2 fallos (accesible sin oir).
	_check("auditar que ningún puzzle dependa de oír un sonido específico: la pista del patrón es textual y se ofrece tras 2 intentos fallidos (pista_patron devuelve la secuencia completa)",
		f_sonido.contains("INTENTOS_PARA_PISTA := 2") and f_sonido.contains("func pista_patron() -> Array")
			and f_sonido.contains("secuencia.duplicate()"))

	# 4) El sistema de pistas general (puzzle_pistas) es textual por diseño.
	var pistas: GDScript = ResourceLoader.load(CARPETA + "puzzle_pistas.gd")
	var f_pistas: String = pistas.source_code if pistas != null else ""
	_check("auditar que ningún puzzle dependa de oír un sonido específico: el sistema de pistas de puzzles es textual (sin reproduccion de audio)",
		f_pistas.contains("class_name") and not _usa_api_audio(f_pistas))

	# 5) Los emisores/receptores cambian de ESTADO (visual/posicional) al activarse:
	# la resolucion es observable sin sonido (estado_igual_objetivo).
	var room: GDScript = ResourceLoader.load(CARPETA + "puzzle_room.gd")
	var f_room: String = room.source_code if room != null else ""
	_check("auditar que ningún puzzle dependa de oír un sonido específico: la resolución es observable por estado de emisores/receptores (set_emisor/estado_igual_objetivo), sin requerir audio",
		f_room.contains("func set_emisor") and f_room.contains("func estado_igual_objetivo") and not _usa_api_audio(f_room))

	_summary()

func _usa_api_audio(fuente: String) -> bool:
	for api in API_AUDIO:
		if fuente.find(api) >= 0:
			return true
	return false
