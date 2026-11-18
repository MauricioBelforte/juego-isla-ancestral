# -*- coding: utf-8 -*-
import io, os
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
bk = os.path.join(root, r"DOCUMENTACION\TAREAS-POR-MODELO\ling-3.1-flash\BACKLOGS\BACKLOG-MASTER.md")
txt = io.open(bk, encoding="utf-8").read()
if "vuelta cron 05:30Z" in txt:
    print("BK: linea v155-vuelta YA existe (idempotencia OK)")
else:
    line = ("- [x] v155 vuelta cron 05:30Z (post-reencendido wku_1ed0cb06): msg 420 escrito y verificado "
            "(3656B, noBOM, LF, firma). CORRECCION a 419: CruceroManager YA es autoload VIVO en project.godot "
            "(commit fundador f0bc848 05:18Z; ERNIE RIEL-4 15/15; Bloque 10 M169 completado en disco; mi 419 "
            "midio 05:05Z, f0bc848 landeo 05:18Z). Hallazgos Beam 05:21Z VERIFICADOS por Ling contra disco y "
            "elevados al director (report-only, 0 flips): B. IDs duplicados CHECKLIST-GLOBAL 48/115/127/139/148 "
            "(10 filas; varias restauradas msg 302; dedup = fundador/directora); C. drift 38-Economia global "
            "✅164/164 vs real 163[x]/1[?] (DoD §21.6 prohíbe ✅ con [?]) y 73-Coleccionables global ✅76/135 vs "
            "real 76[x]/3[ ]/56[?] (sello inflado §21.8.2.b), 139 cifras divergentes 138/142 vs 139/142, 148 "
            "115/117 ambas, 71 sin drift; A. 11 contadores no cubiertos (economy/price/coleccionables/"
            "player_profile/progression/barter) -> duenos M38/M73/M139, decision directora. estado_director "
            "congelado 2026-11-08 (403 claves; campo ling = T32 historico). Canal Ling sin respuesta directora "
            "(ultimos 3 = 418/419/420 mios). Centinela items_x 22719 estable (C2=552/chk=169, sin flips); "
            "watchdog i18n rc=0 LIMPIO (JSON 170/170/170, paridad 0); riel pt blob d2b567c 26ava, SHA256 "
            "FE9044E2C3317C26. Sin acuse directora 412-420. Helper prox 421.")
    with io.open(bk, "a", encoding="utf-8", newline="\n") as f:
        f.write("\n" + line + "\n")
    print("BK: linea v155-vuelta 05:30Z APPEND OK")
