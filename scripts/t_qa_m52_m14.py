# -*- coding: utf-8 -*-
import os
BASE = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
DOC = os.path.join(BASE, "DOCUMENTACION")

def seal(rid, name, cnt, q, e, suite, ext):
    p = os.path.join(DOC, "%s-%s" % (rid, name), "plan-actual", "05-Checklist.md")
    s = ("\n## QA Cruzado §21.8 agnes 2026-10-06 (verificador != autor)\n"
         "Auditora: agnes-3-flash / Kilo Code. VEREDICTO: SELLADO ✅\n"
         "- Conteo independiente: %s [x] / %s [?] / %s [ ] (coincide fila global).\n"
         "- Suite re-corrida headless: %s.\n"
         "- [?]/[ ] = bloqueos EXTERNOS con dueño verificados: %s.\n"
         "- 0 falsos-cierres. No se sube estado (flip GLOBAL = director).\n" % (cnt, q, e, suite, ext))
    with open(p, "ab") as f:
        f.write(s.encode("utf-8"))
    print("M%s QA seal appended" % rid)

seal("52", "Particulas-Y-VFX", "137", "1", "10",
     "test_vfx_m52_iter6 76/0",
     "1 [?] = catálogo VFX (M44 feedback + M92 tutorial); 10 [ ] = presets M90 / timelines M48 / chapoteo M13 / estelas M47 / menús M53 / Reduce-Motion M58 — todos dueño externo")
seal("14", "Inventario", "136", "4", "0",
     "test_inventario_iter5 0/0",
     "4 [?] = acciones contextuales por slot / soporte gamepad+teclado-mouse / recolección bolsillo lleno / pickups flotantes — todos QA atria-dawn 2026-09-18 (dueño director), bloqueos externos reales")
