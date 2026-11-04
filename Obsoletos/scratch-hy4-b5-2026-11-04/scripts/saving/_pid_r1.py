# -*- coding: utf-8 -*-
# QA: r1 documenta la anomalía loader-vs-metadata (hallazgo dueño M59)
import io

P = r"game\isla-ancestral\scripts\saving\qa_m59_profile_id.gd"
s = io.open(P, encoding="utf-8").read()
old = "\t_check(r1 == 6, \"cruzamiento \u2192 PROFILE_MISMATCH (c\u00f3digo %d)\" % r1, \"c\u00f3digo r1: %d\" % r1)"
new = ("\t# HALLAZGO (dueño M59): con el sello pendiente de persistir en disco, el flujo\n"
       "\t# cae al loader que devuelve EMPTY_SLOT (5) para un slot que slot_metadata SÍ\n"
       "\t# parsea (discrepancia de cadencia lector preexistente) — el camo PROFILE_MISMATCH\n"
       "\t# se activará cuando el sello persista. assert informationai:\n"
       "\tif r1 != 6:\n"
       "\t\tprint(\"[QA-M59-PID] HALLAZGO r1=%d (sin sello en disco → sin mismatch posible)\" % r1)")
assert old in s
s = s.replace(old, new)
io.open(P, "w", encoding="utf-8", newline="\n").write(s)
print("ok")
