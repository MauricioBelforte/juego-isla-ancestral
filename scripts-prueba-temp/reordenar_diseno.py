# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

# separar en bloques por encabezado de nivel 2 o 3
bloques = []  # (nivel, titulo, [lineas])
cur_t, cur_n, cur = None, None, []
for l in lines:
    m = re.match(r"^(#{2,3}) (.+)$", l)
    if m:
        if cur_t is not None:
            bloques.append((cur_t, cur_n, cur))
        cur_t, cur_n, cur = len(m.group(1)), m.group(2), [l]
    else:
        if cur_t is None:
            bloques.append((0, "pre", [l]))
            cur_t, cur_n, cur = 0, "pre", []
        else:
            cur.append(l)
if cur_t is not None:
    bloques.append((cur_t, cur_n, cur))

por_titulo = {}
for nivel, titulo, cont in bloques:
    por_titulo[titulo.strip()] = (nivel, cont)

def get(prefijo):
    for t, (n, c) in por_titulo.items():
        if t.startswith(prefijo):
            return c
    return []

nueva = []
nueva += por_titulo.get("1. Arquitectura de la fase", (0, [""]))[1]
nueva.append("")
nueva += por_titulo.get("2. Dise\u00f1o del mundo Pre-Alpha", (0, [""]))[1]
nueva.append("")
for sub in ["2.1 Aurora", "2.1.1", "2.2 Enclave", "2.3 Elenco", "2.3.1", "2.3.2", "2.3.3",
            "2.4 Templo", "2.5 Econom", "2.5.1", "2.6 Construcci", "2.7 Guardado", "2.8 Audio"]:
    c = get(sub)
    if c:
        nueva += c
        nueva.append("")
for t in ["3. Pipeline de assets", "4. M\u00e9tricas y telemetr\u00eda", "5. Hits de Pre-Alpha"]:
    c = get(t)
    if c:
        nueva += c
        nueva.append("")

# limpiar lineas vacias al final
while nueva and nueva[-1].strip() == "":
    nueva.pop()

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(nueva) + "\n")
print("documento reordenado")
