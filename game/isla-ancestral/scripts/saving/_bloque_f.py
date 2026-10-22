# -*- coding: utf-8 -*-
# Bloque F: clamp D8 de max_craftable a 30
import io

P = r"game\isla-ancestral\scripts\crafting\test_crafting.gd"
s = io.open(P, encoding="utf-8").read()

old = "\t_bloque_E()\n"
assert s.count(old) == 1
s = s.replace(old, old.replace("\t_bloque_E()", "\t_bloque_E()\n\t_bloque_F()"))

bloques = "\t_bloque_E()\n"
s = s.replace("\t_bloque_E()\n\n", "\t_bloque_E()\n\t_bloque_F()\n\n")

funcion = '\n' + '''## D8 (G-5.3, 2026-10-21): max_craftable clamps a 30 (tope QoL de lote).
func _bloque_F() -> void:
	_ini("F. D8 clamp max_craftable a 30")
	_inv.agregar_items({"madera_roble": 300, "mineral_cobre": 400})
	var max_n: int = _craft.max_craftable("rec_pico_cobre")
	_check("max_craftable clamps a 30 (materiales para mas)", max_n == 30, "max=%d" % max_n)
	_fin("F. D8 clamp max_craftable a 30")
'''
# insertar la función después del último } de _bloque_E... más fácil: append al final si el final es el bloque E; usar replace del cierre del archivo
# test_crafting termina con la definición de _bloque_E (o algo después). Buscar el final de _bloque_E:
import re
m = re.search(r"func _bloque_E\(\) -> void:\n(?:.|\n)*?(?=\n\nfunc |\Z)", s)
assert m, "bloque E no"
s = s[:m.end()] + funcion + s[m.end():]

# actualizar constantes
s = s.replace("\t_bloque_E()\n\n", "\t_bloque_E()\n\t_bloque_F()\n\n")
s = s.replace("const BLOQUES_ESPERADOS: Array[String] = ['A', 'B', 'C', 'D', 'E']",
              "const BLOQUES_ESPERADOS: Array[String] = ['A', 'B', 'C', 'D', 'E', 'F']")

# el _bloque_F añade ~3 checks; el CHECKS_MINIMOS = 20 tenia margen — no tomo riesgo: subir a 22
s = s.replace("const CHECKS_MINIMOS := 20", "const CHECKS_MINIMOS := 22")

io.open(P, "w", encoding="utf-8", newline="\n").write(s)
print("bloque F ok")
