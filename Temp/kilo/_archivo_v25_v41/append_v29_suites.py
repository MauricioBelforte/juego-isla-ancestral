# -*- coding: utf-8 -*-
"""Append v29 al punto 4 de §9 de AUDITORIA-SUITES-FRAGILES-1NOV.md (io.open, UTF-8/LF)."""
import io

p = "DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-SUITES-FRAGILES-1NOV.md"
txt = io.open(p, encoding="utf-8").read()
ancla = "cableado CI (#452 autorizado).**"
n = txt.count(ancla)
print("ocurrencias ancla:", n)
print("[re-verify v29] ya presente:", "[re-verify v29 07:00Z]" in txt)
add = (" **[re-verify v29 07:00Z]** El [x] está verificado en disco: 11-BUGS.md L4935 = «[x] RESUELTO "
       "(DeepSeek TANDA 5 #464, GO agnes #463, Log 2262): parche v3 … CHECKS_MINIMOS=6 medido + watchdog 30s … "
       "sonda reinyección EXIT 1 en 37s»; L5371 = «bloque F 15/15, suite 152/0 ×3»; disco corrobora "
       "`qa_dirty_item4.gd:16` `const CHECKS_MINIMOS: int = 6`.")
if n == 1 and "[re-verify v29 07:00Z]" not in txt:
    txt = txt.replace(ancla, ancla + add)
    io.open(p, "w", encoding="utf-8", newline="\n").write(txt)
    print("APPEND OK")
else:
    print("SIN CAMBIOS (ancla != 1 o ya presente)")
