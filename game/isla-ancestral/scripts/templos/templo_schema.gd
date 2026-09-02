# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M26: TemploSchema — validación de layout de templo subterráneo (salas
# conectadas con salida única, puzzles con emisor/receptor, checkpoints).
class_name TemploSchema
extends RefCounted

## Devuelve Array[String] con los problemas del layout (vacío si es válido).
static func validar_layout(templo: Dictionary) -> Array[String]:
	var errores: Array[String] = []
	if String(templo.get("id", "")).is_empty():
		errores.append("templo sin id")
	var salas: Variant = templo.get("salas", [])
	var puzzles: Variant = templo.get("puzzles", [])
	if typeof(salas) != TYPE_ARRAY or salas.is_empty():
		return ["salas vacío o inválido"]
	# ids únicos de salas y puzzles
	var ids_salas := {}
	var ids_puzzles := {}
	for sala in salas:
		var sid := String(sala.get("id", ""))
		if sid.is_empty():
			errores.append("sala sin id")
		elif ids_salas.has(sid):
			errores.append("sala duplicada: %s" % sid)
		else:
			ids_salas[sid] = true
		var salida := String(sala.get("salida_a", ""))
		if salida != "" and not ids_salas.has(salida) and salida != sid:
			# salida puede ser a una sala aún no vista: validar al final
			pass
	for puzzle in puzzles:
		var pid := String(puzzle.get("id", ""))
		if pid.is_empty():
			errores.append("puzzle sin id")
		elif ids_puzzles.has(pid):
			errores.append("puzzle duplicado: %s" % pid)
		else:
			ids_puzzles[pid] = true
		for campo in ["emisor", "receptor"]:
			if String(puzzle.get(campo, "")).is_empty():
				errores.append("puzzle %s sin %s" % [pid, campo])
	# 2da pasada: salidas referencian salas existentes
	for sala in salas:
		var sid := String(sala.get("id", ""))
		var salida := String(sala.get("salida_a", ""))
		if salida != "" and not ids_salas.has(salida):
			errores.append("sala %s sale a sala inexistente: %s" % [sid, salida])
	# Checkpoint en el sello final (regla de diseño: último checkpoint antes del guardián)
	var tiene_checkpoint_final := false
	for sala in salas:
		if String(sala.get("salida_a", "")).is_empty() and bool(sala.get("checkpoint", false)):
			tiene_checkpoint_final = true
	if not tiene_checkpoint_final:
		errores.append("la sala final debe tener checkpoint")
	# Guardián opcional pero si existe debe estar en una sala válida
	var guardian: Variant = templo.get("guardian", {})
	if typeof(guardian) == TYPE_DICTIONARY and not guardian.is_empty():
		if not ids_salas.has(String(guardian.get("sala", ""))):
			errores.append("guardián en sala inexistente: %s" % guardian.get("sala", ""))
	# Recompensa: al menos un puzzle con recompensa
	var alguna_recompensa := false
	for puzzle in puzzles:
		if not String(puzzle.get("recompensa", "")).is_empty():
			alguna_recompensa = true
	if not alguna_recompensa:
		errores.append("ningún puzzle con recompensa")
	return errores
