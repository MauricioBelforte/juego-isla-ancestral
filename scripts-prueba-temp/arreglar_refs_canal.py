# -*- coding: utf-8 -*-
import io, os, re

d = "Mensajes entre modelos/step-5-kilocode"
# referencias: numero viejo -> nuevo (solo para referencias, no nombres de archivo ya renombrados)
REFS = [
  (499, 286), (498, 288), (292, 290), (288, 291), (289, 292), (290, 293), (291, 294),
  (286, 287), (287, 289),
]
# aplicar en orden inverso para no encadenar mal: primero los altos
orden = sorted(REFS, key=lambda x: -x[0])

archivos = [f for f in os.listdir(d) if f.endswith(".md")]
total = 0
for f in archivos:
    p = os.path.join(d, f)
    with io.open(p, encoding="utf-8") as fh:
        t = fh.read()
    orig = t
    for viejo, nuevo in orden:
        # referencia a nombre de archivo: "NNN-2026-"
        t = t.replace("%d-2026-" % viejo, "%d-2026-" % nuevo)
        # "msg NNN" / "mensaje NNN" / "informe NNN" / "encargo NNN"
        t = re.sub(r"(?i)\b(msg|mensaje|informe|encargo)\s+%d\b" % viejo,
                   lambda m, n=nuevo: "%s %d" % (m.group(1), n), t)
    if t != orig:
        with io.open(p, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(t)
        total += 1
        print("  refs actualizadas en", f[:50])

# sacar del pool 286..294
pp = os.path.join(d, "NUMEROS_DISPONIBLES.txt")
with io.open(pp, encoding="utf-8") as fh:
    nums = [l.strip() for l in fh.read().split("\n") if l.strip()]
sacar = {str(n) for n in range(286, 295)}
quedan = [n for n in nums if n not in sacar]
with io.open(pp, "w", encoding="utf-8", newline="\n") as fh:
    fh.write("\n".join(quedan) + "\n")
print("archivos con refs actualizadas:", total)
print("pool: %d -> %d, siguiente %s" % (len(nums), len(quedan), quedan[0]))
