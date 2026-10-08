# -*- coding: utf-8 -*-
import os, re
BASE = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
g = os.path.join(BASE, "DOCUMENTACION", "156-Terrenos-Y-Movimiento", "plan-actual", "05-Checklist.md")
d = open(g, "rb").read()
absent = [b"particulas_agua.gd", b"particulas_arena.gd", b"particulas_barro.gd",
          b"particulas_nieve.gd", b"particulas_rocas.gd", b"player_movement.gd",
          b"terrain_footstep_audio.gd", b"test_terrain_provider.gd", b"test_terrain_detector.gd"]
note = ("  [Auditoria T-agnes blq-M156 2026-10-06: el archivo nombrado AUSENTE en disco; la funcionalidad "
        "real es data-driven en data/terrenos/terrenos.json (7 tipos, testeado) y/o cubierta por test_terrenos.gd 0/0]").encode("utf-8")
lines = d.split(b"\n")
out = []
n = 0
for L in lines:
    if b"[x]" in L and any(a in L for a in absent):
        L2 = L.replace(b"[x]", b"[?]", 1)
        L2 = L2.rstrip() + note
        out.append(L2)
        n += 1
    else:
        out.append(L)
open(g, "wb").write(b"\n".join(out))
c = open(g, "rb").read().decode("utf-8")
mk = re.findall(r"(?m)^\s*[-*]\s*\[(x| |X|\?)\]", c)
print("M156 degradados:", n, "| ahora [x]=", sum(1 for m in mk if m in ("x", "X")),
      "[?]=", sum(1 for m in mk if m == "?"), "[ ]=", sum(1 for m in mk if m == " "))
