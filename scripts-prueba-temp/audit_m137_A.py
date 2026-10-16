# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/137-Prototipo/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

# 1) degradar el [x] inflado de scenes/prototipo/
viejo = "- [x] Definir carpeta `scenes/prototipo/` para todos los scripts del hito [S]"
nuevo = ("- [ ] Definir carpeta `scenes/prototipo/` para todos los scripts del hito [S] — DEGRADADO 2026-10-14 "
         "(step-5-kilocode): verificado contra disco — la carpeta `game/isla-ancestral/scenes/prototipo/` NO "
         "existe (las carpetas de scenes/ son debug, museo, npc, player, terrain, terrenos, tests, ui). El "
         "script del hito tampoco existe. No inflado.")
if viejo in t:
    t = t.replace(viejo, nuevo, 1)
    print("[x] inflado degradado:", viejo[:60])

# 2) anotar los 4 pendientes de la seccion A
notas = [
 ("- [ ] Definir escena `prototipo_isla.tscn` como escena principal [M]",
  "PENDIENTE REAL 2026-10-14 (step-5-kilocode): verificado — no existe `prototipo_isla.tscn`; la escena principal en project.godot es `res://scenes/main_island.tscn`."),
 ("- [ ] Definir autoload `game_state_proto.gd` (M59) [M]",
  "PENDIENTE REAL 2026-10-14 (step-5-kilocode): verificado — no existe `game_state_proto.gd` (hay `GameState` y `save_*.gd` de producción, no el autoload del prototipo)."),
 ("- [ ] Definir autoload `world_seed.gd` con seed fija 20260819 [S]",
  "PENDIENTE REAL 2026-10-14 (step-5-kilocode): verificado — no existe `world_seed.gd` y hay 0 hits de la semilla fija 20260819 en scripts/."),
 ("- [ ] Definir carpeta `docs/prototipo/` para los reportes del hito [S]",
  "PENDIENTE REAL 2026-10-14 (step-5-kilocode): verificado — la carpeta `game/isla-ancestral/docs/prototipo/` no existe (docs/ tiene 1 archivo suelto)."),
]
for viejo_n, nota in notas:
    if viejo_n in t:
        t = t.replace(viejo_n, viejo_n.rstrip() + " \u2014 " + nota, 1)
        print("anotado:", viejo_n[:50])

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t))
print("conteos ahora: [x]=%d [ ]=%d" % (x, s))
