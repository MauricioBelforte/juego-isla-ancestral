# -*- coding: utf-8 -*-
import os
BASE = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
DOC = os.path.join(BASE, "DOCUMENTACION")

def seal(rid, name, cnt, q, e, suite, detail):
    p = os.path.join(DOC, "%s-%s" % (rid, name), "plan-actual", "05-Checklist.md")
    s = ("\n## QA Cruzado §21.8 agnes 2026-10-06 (verificador != autor)\n"
         "Auditora: agnes-3-flash / Kilo Code. VEREDICTO: %s\n"
         "- Conteo independiente: %s [x] / %s [?] / %s [ ] (%s).\n"
         "- Suites re-corridas headless: %s.\n"
         "- Los [?]/[ ] = bloqueos EXTERNOS con dueño verificados: %s.\n"
         "- No se sube estado (regla §21.8; el flip de GLOBAL lo hace el director).\n" % (
             "SELLADO ✅" if "SUS" in suite else "VÉDICTO: " + suite,
             cnt, q, e, "coincide fila global", detail, suite))
    with open(p, "ab") as f:
        f.write(s.encode("utf-8"))
    print("M%s QA seal appended" % rid)

seal("106", "Seguridad", "194", "12", "0",
     "43/0 (test_security_m106)",
     "SUS (12 [?] = M77 server-side / M111-CI / M104/M105/M107, todos bloqueos externos con dueño; M77 bloqueado single-player v1)")
seal("60", "Datos-Y-Serializacion", "189", "4", "3",
     "40/0 (test_datos_m60_iter5)",
     "SUS (4 [?] + 3 [ ] = M08 procedural, M62 UI, M63 <2s, M15/16/33 .tres, Profiler/hardware; todos con dueño externo)")
