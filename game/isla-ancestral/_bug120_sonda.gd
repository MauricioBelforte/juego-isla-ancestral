extends SceneTree

## Sonda unitaria del fix BUG-120 sobre _analizar_salida() (logica aislada).
## Se corre con --script res://_bug120_sonda.gd y se borra despues.

func _analizar_salida(texto: String, exit: int) -> Dictionary:
	var checks := 0
	var fallos := 0
	var motivos: Array[String] = []

	if texto.strip_edges().is_empty():
		motivos.append("salida VACIA (no se pudo capturar)")

	var m1 := RegEx.create_from_string("(\\d+)\\s+checks?,\\s*(\\d+)\\s+fallos").search(texto)
	if m1 != null:
		checks = int(m1.get_string(1))
		fallos = int(m1.get_string(2))
	else:
		var m2 := RegEx.create_from_string("(\\d+)\\s+OK\\s*/\\s*(\\d+)\\s+fallos").search(texto)
		if m2 != null:
			checks = int(m2.get_string(1))
			fallos = int(m2.get_string(2))
		else:
			var total := 0
			var encontrado := false
			for m in RegEx.create_from_string("\\(\\+(\\d+)\\s+checks?\\)").search_all(texto):
				total += int(m.get_string(1))
				encontrado = true
			if encontrado:
				checks = total
			else:
				var m4 := RegEx.create_from_string("passed=(\\d+)\\s+failed=(\\d+)").search(texto)
				if m4 != null:
					checks = int(m4.get_string(1))
					fallos = int(m4.get_string(2))

	if texto.contains("SCRIPT ERROR"):
		motivos.append("SCRIPT ERROR")
	if texto.contains("[FAIL]") and fallos == 0:
		fallos = 1
		motivos.append("[FAIL] en salida")
	if texto.contains("FALLO:") and fallos == 0:
		fallos = 1
		motivos.append("FALLO: en salida")
	var mf := RegEx.create_from_string("(\\d+)\\s+fallo\\(s\\)").search(texto)
	if mf != null and fallos == 0:
		fallos = int(mf.get_string(1))
		motivos.append("%s fallo(s) declarado(s)" % mf.get_string(1))
	if exit != 0 and fallos == 0:
		fallos = 1
		motivos.append("rc != 0")

	return {"ok": fallos == 0, "checks": checks, "motivo": " · ".join(motivos)}


func _assert(condicion: bool, nombre: String, extra: String = "") -> int:
	if condicion:
		print("  [SONDA-OK] %s" % nombre)
		return 0
	print("  [SONDA-FAIL] %s %s" % [nombre, extra])
	return 1


func _initialize() -> void:
	print("=== SONDA unitaria fix BUG-120 (_analizar_salida) ===")
	var fallos := 0

	# Caso 1: M111 en verde (formato passed=) — antes checks=0, ahora 62
	var r1 := _analizar_salida("M111-UTILS-P1: passed=62 failed=0\n", 0)
	fallos += _assert(r1["ok"] == true, "M111 verde: ok=true", str(r1))
	fallos += _assert(int(r1["checks"]) == 62, "M111 verde: checks=62", "obtuvo %d" % r1["checks"])
	fallos += _assert(int(r1["motivo"].length()) == 0 or " · " not in str(r1["motivo"]), "M111 verde: sin motivos", str(r1["motivo"]))

	# Caso 2: M111 en rojo (fallos inyectados + "FALLO:" sin corchetes) — antes CIEGO
	var r2 := _analizar_salida("M111-UTILS-P1: passed=61 failed=1\n  FALLO: sonda inyectada\n", 0)
	fallos += _assert(r2["ok"] == false, "M111 rojo: ok=false (ANTES ERA CIEGO)", str(r2))
	fallos += _assert(int(r2["checks"]) == 61, "M111 rojo: checks=61", "obtuvo %d" % r2["checks"])

	# Caso 3: inventory_unificado en verde — ok=true (checks=0, la suite no declara checks)
	var r3 := _analizar_salida("[OK] Test inventario unificado: 0 fallos\n", 0)
	fallos += _assert(r3["ok"] == true, "inv_unif verde: ok=true", str(r3))

	# Caso 4: inventory_unificado en rojo ("N fallo(s)") — antes solo lo cazaba el [FAIL] literal
	var r4 := _analizar_salida("[FAIL] Test inventario unificado: 3 fallo(s)\n", 0)
	fallos += _assert(r4["ok"] == false, "inv_unif rojo: ok=false", str(r4))

	# Caso 5: rc != 0 sin otro indicio — sigue cazando (regression del fix)
	var r5 := _analizar_salida("suite rara sin formato\n", 3)
	fallos += _assert(r5["ok"] == false, "rc != 0: ok=false", str(r5))

	# Caso 6: formato "[FIN] (+N checks)" sigue funcionando (regression)
	var r6 := _analizar_salida("[FIN] bloque A (+32 checks)\n[FIN] bloque B (+5 checks)\n", 0)
	fallos += _assert(r6["ok"] == true, "FIN bloque: ok=true", str(r6))
	fallos += _assert(int(r6["checks"]) == 37, "FIN bloque: checks=37", "obtuvo %d" % r6["checks"])

	# Caso 7: "N OK / M fallos" sigue funcionando (regression)
	var r7 := _analizar_salida("57 OK / 0 fallos\n", 0)
	fallos += _assert(r7["ok"] == true, "OK/fallos: ok=true", str(r7))
	fallos += _assert(int(r7["checks"]) == 57, "OK/fallos: checks=57", "obtuvo %d" % r7["checks"])

	print("\n=== SONDA: %d fallo(s) ===" % fallos)
	quit(fallos)
