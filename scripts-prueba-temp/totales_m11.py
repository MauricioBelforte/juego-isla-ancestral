# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/11-Personaje-Del-Jugador/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    t = f.read()
antes = t
t = t.replace(
  "**Totales:** 123 items - Completados: 72 - Pendientes: 0 - No resueltos: 51.",
  "**Totales:** 123 items - Completados: 75 - Pendientes: 0 - No resueltos: 48. (Actualizado 2026-10-13 por step-5-kilocode: 3 items desactualizados reescritos con evidencia en disco y promovidos a [x] —sprint como FACTOR, equivalente M70 de InteractionService con rango 4 m, AnimationPlayer con 3 clips—; autorizado por director msg 500.)")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("Totales actualizado" if t != antes else "AVISO: no se encontro la linea")
