# -*- coding: utf-8 -*-
import os
B = r"D:/Escritorio/PORTFOLIO/Proyectos para GitHub/PROYECTOS OPENCODE/juego-isla-ancestral"
NOTES = {
 "91": ("M91 auditado", "Sustentado (0 degradaciones). Suite re-corrida POR AGNES: test_audio_effects_m91 82/0 + test_audio_config 136 checks (0/0 con M41 MusicDirector listo). 207 [x] en disco (scripts/audio/ + data/audio/). HALLAZGO menor: test_audio_config es FLAKY por orden de init M41/M91 — si M41 MusicDirector no está listo, 'default Music 0.7' da 2 FALLOS; con M41 listo = 0/0. No es falso-cierre, es race de init. [?] (1) = M154. No tocar GLOBAL (flip = director)."),
 "58": ("M58 auditado", "Sustentado (0 degradaciones). Suite re-corrida POR AGNES: test_accesibilidad_manager 0/0 (EXIT 0). 131 [x] en disco (scripts/accesibilidad/: manager/schema/aplicador). [?] (2) externos con dueño, [ ] (50) pendientes. No tocar GLOBAL (flip = director)."),
}
NAMES = {"91":"Configuracion-De-Audio","58":"Accesibilidad"}
for rid,(hdr,body) in NOTES.items():
    p = B + "/DOCUMENTACION/%s-%s/plan-actual/05-Checklist.md" % (rid, NAMES[rid])
    import os as _os
    assert _os.path.exists(p), p
    note = ("\n## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-07, paquete opción 1)\n"
            "%s. %s\n" % (hdr, body))
    with open(p,"ab") as f:
        f.write(note.encode("utf-8"))
    print("M%s note appendida" % rid)
