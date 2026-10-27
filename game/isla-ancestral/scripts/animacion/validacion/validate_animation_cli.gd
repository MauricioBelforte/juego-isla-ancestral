# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-27
#
# M48: Gate headless del validador de animaciones (RF12 / 04-Codigo sec 2.5).
# Corre como --script (M118), NO como plugin de import:
#   Godot --headless --path game/isla-ancestral \
#     --script res://scripts/animacion/validacion/validate_animation_cli.gd
#
# Codigos de salida (convencion del proyecto, no se colapsan):
#   0 = limpio (0 errores; puede haber avisos y NV)
#   1 = hallazgos (>=1 error E#)
#   2 = uso invalido
#   3 = DETECTOR CIEGO (leyo 0 librerias) -> NO es un aprobado
#
# Este gate NO se cablea en quality.yml (archivo NO TOCAR para este agente):
# queda listo para que el director o M118 lo cableen.

extends SceneTree

const VALIDADOR := preload("res://scripts/animacion/validacion/animation_validator.gd")
const DIR_LIBRERIAS := "res://scripts/animacion/libraries"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var v = VALIDADOR.new()

	var dir: DirAccess = DirAccess.open(DIR_LIBRERIAS)
	if dir == null:
		print("[CIEGO] no se pudo abrir %s" % DIR_LIBRERIAS)
		quit(3)
		return

	var archivos: PackedStringArray = dir.get_files()
	var leidas: int = 0
	var total_errores: int = 0
	var total_avisos: int = 0
	var total_nv: int = 0
	var total_clips: int = 0

	print("=== validate_animation (M48) — %s ===" % DIR_LIBRERIAS)
	for f in archivos:
		var nombre_archivo: String = str(f)
		if not nombre_archivo.ends_with(".tres"):
			continue
		var ruta: String = DIR_LIBRERIAS.path_join(nombre_archivo)
		var recurso: Resource = load(ruta)
		if recurso == null or not (recurso is AnimationLibrary):
			print("[ERROR] %s no es una AnimationLibrary" % nombre_archivo)
			total_errores += 1
			continue
		var lib: AnimationLibrary = recurso
		var informe: Dictionary = v.validar_libreria(lib, "")
		leidas += 1
		total_clips += int(informe["clips"])
		var errores: Array = informe["errores"]
		var avisos: Array = informe["avisos"]
		var nv: Array = informe["no_verificable"]
		total_errores += errores.size()
		total_avisos += avisos.size()
		total_nv += nv.size()
		print("-- %s : %d clip(s) | E=%d A=%d NV=%d" % [nombre_archivo, int(informe["clips"]), errores.size(), avisos.size(), nv.size()])
		for e in errores:
			print("   E  %s" % str(e))
		for a in avisos:
			print("   A  %s" % str(a))
		for n in nv:
			print("   NV %s" % str(n))

	if leidas == 0:
		print("[CIEGO] 0 librerias leidas en %s: el gate no midio nada (exit 3)" % DIR_LIBRERIAS)
		quit(3)
		return

	print("=== RESUMEN M48: librerias=%d clips=%d errores=%d avisos=%d no_verificable=%d ===" % [leidas, total_clips, total_errores, total_avisos, total_nv])
	quit(1 if total_errores > 0 else 0)
