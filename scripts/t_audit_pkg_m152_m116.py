# -*- coding: utf-8 -*-
import os, re
DOC = "DOCUMENTACION"
def find(rid):
    for d in os.listdir(DOC):
        if d.startswith(rid + "-"):
            return d
    raise SystemExit("no folder " + rid)

NOTES = {
 "152": ("M152 auditado", "Sustentado (0 degradaciones). MODULO DOCUMENTAL PURO: los 202 [x] son los principios inegociables documentados en el propio modulo (01-05). No hay codigo/asset a verificar. 0 [?] / 0 [ ]. Candidato a flip a ✅ (completitud total + 0 bloqueos). No tocar GLOBAL (flip = director)."),
 "116": ("M116 auditado", "Sustentado (0 degradaciones). Suites re-corridas POR AGNES: test_installer_m116 18/0 + test_instalador_m116 (build) 15/0, EXIT 0. 192 [x] en disco: scripts/installer/ (instalador_config) + scripts/build/ (build_config_manager, build_validator, validador_instalador) + data/installer + setup_windows.ps1 (fixtures m116). 0 [?]/0 [ ]. No tocar GLOBAL (flip = director)."),
}
for rid,(hdr,body) in NOTES.items():
    p = os.path.join(DOC, find(rid), "plan-actual", "05-Checklist.md")
    note = ("\n## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-07, paquete opción 1, bloque M152+M116)\n"
            "%s. %s\n" % (hdr, body))
    with open(p, "ab") as f:
        f.write(note.encode("utf-8"))
    c = open(p, "rb").read().decode("utf-8")
    mk = re.findall(r"(?m)^\s*[-*]\s*\[(x| |X|\?)\]", c)
    print("M%s (%s) nota appendida; [x]=%d [?]=%d [ ]=%d" % (rid, find(rid),
          sum(1 for m in mk if m in ("x","X")), sum(1 for m in mk if m == "?"), sum(1 for m in mk if m == " ")))
