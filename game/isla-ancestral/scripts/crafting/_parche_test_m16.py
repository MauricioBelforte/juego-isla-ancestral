# -*- coding: utf-8 -*-
# test_crafting.gd: cada seteo directo de _mes ahora emite estacion_cambio
# (contrato del item 4: la season se propaga por señal; G-5.3-Flash-Agente)
import io

P = r"game\isla-ancestral\scripts\crafting\test_crafting.gd"
s = io.open(P, encoding="utf-8").read()

EDITS = [
    ("\t\tgt._mes = 9\n", "\t\tgt._mes = 9\n\t\tgt.emit_signal(\"estacion_cambio\", 2)\n"),
    ("\t\tgt._mes = 1\n", "\t\tgt._mes = 1\n\t\tgt.emit_signal(\"estacion_cambio\", 0)\n"),
    ("\tgt._mes = 9\n", "\tgt._mes = 9\n\tgt.emit_signal(\"estacion_cambio\", 2)\n"),
    ("\tgt._mes = 4\n", "\tgt._mes = 4\n\tgt.emit_signal(\"estacion_cambio\", 1)\n"),
    ("\tgt._mes = 11\n", "\tgt._mes = 11\n\tgt.emit_signal(\"estacion_cambio\", 3)\n"),
]
# Ojo: "\tgt._mes = 1\n" también es prefijo propio de L186; se maneja al final
# con reemplazo exacto sobre el bloque de reset (último del archivo).
old_reset = "\t# Reset estación\n\tgt._mes = 1\n"
new_reset = "\t# Reset estación\n\tgt._mes = 1\n\tgt.emit_signal(\"estacion_cambio\", 0)\n"

for old, new in EDITS[:2]:
    assert s.count(old) == 1, "no unico: " + repr(old)
    s = s.replace(old, new)
for old, new in EDITS[2:5]:
    assert s.count(old) == 1, "no unico: " + repr(old)
    s = s.replace(old, new)
assert s.count(old_reset) == 1, "reset no unico"
s = s.replace(old_reset, new_reset)

io.open(P, "w", encoding="utf-8", newline="\n").write(s)
print("emits agregados")
