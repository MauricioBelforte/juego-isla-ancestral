# -*- coding: utf-8 -*-
"""b62 refined evidence: exact tokens, source only (no .godot cache)."""
import os, re, io

GAME = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral"
EXTS = (".gd", ".json", ".tres", ".tscn", ".md", ".cfg", ".csv")

def files(roots):
    out = []
    for root in roots:
        p = os.path.join(GAME, root) if not os.path.isabs(root) else root
        if os.path.isfile(p):
            out.append(p); continue
        for dp, dns, fns in os.walk(p):
            dns[:] = [d for d in dns if d not in (".godot", "imported", "exported")]
            for fn in fns:
                if fn.lower().endswith(EXTS):
                    out.append(os.path.join(dp, fn))
    return out

def grep(pattern, roots, limit=12):
    rx = re.compile(pattern, re.I)
    nf = nh = 0
    samples = []
    for p in files(roots):
        try: txt = io.open(p, encoding="utf-8", errors="replace").read()
        except Exception: continue
        n = 0; first = None
        for i, line in enumerate(txt.splitlines(), 1):
            if rx.search(line):
                n += 1
                if first is None: first = (i, line.strip()[:180])
        if n:
            nf += 1; nh += n
            if len(samples) < limit:
                samples.append("%s:%d %s" % (os.path.relpath(p, GAME).replace("\\", "/"), first[0], first[1]))
    return nf, nh, samples

def show(label, pat, roots):
    f, h, s = grep(pat, roots)
    print("%s | files=%d hits=%d" % (label, f, h))
    for x in s: print("   " + x)

SRC, DATA, SCENES = "scripts", "data", "scenes"
print("== exact level names (L30) ==")
show("L30 exact words", r"\b(Conocido|Confidente|Mejor amigo|Amigo)\b", [SRC, DATA])
show("L30 table keys", r"(nombre_nivel|nombres_nivel|level_name|nombre.*nivel|nivel.*nombre)", [SRC, DATA])

print("\n== L32 event min level ==")
show("L32 whole source", r"(nivel[_ ]m[ií]nimo|min[_ ]?level|requiere[_ ]nivel|nivel[_ ]requerido|requisitos?.*nivel)", [SRC, DATA])
show("L32 event_definition fields", r"(nivel|requisito|condicion)", ["scripts/eventos/event_definition.gd", "scripts/eventos/condicion_evento.gd"])

print("\n== L33 friendship-gated stories ==")
show("L33 amistad60/90 data files", r"amistad(60|90)", [DATA])
show("L33 gate in code", r"(amistad[_ ]?(60|90)|desbloquead|requiere.*amistad|amistad.*requiere|nivel.*amistad|amistad.*nivel)", [SRC])
show("L33 historia+nivel same line", r"(historia|story).*(nivel|level)|(nivel|level).*(historia|story)", ["scripts/friendship", "scripts/historias", DATA])

print("\n== L38 level-up feedback ==")
show("L38 VFX catalog entry", r"friendship_level_up", ["data/vfx/vfx_catalog.json"])
show("L38 dialogue level-up", r"_on_level_up|dialogo.*nivel|nivel.*dialogo", ["scripts/dialogos", "scripts/ui", SCENES])
show("L38 unlock list", r"desbloqueos|lista.*desbloque|_unlocks", ["scripts/friendship", "scripts/ui", SCENES])

print("\n== L191-L193 ==")
show("L191 farewell by level", r"(despedida|farewell).*(nivel|level)|(nivel|level).*(despedida|farewell)", [SRC, DATA])
show("L192 spoken memories", r"get_recuerdos|recuerdos.*(dialogo|linea|habl)", ["scripts/dialogos", "scripts/friendship", DATA])
show("L193 return gift implementation", r"adjunto_retorno|agregar_items", ["scripts/friendship/friendship_service.gd", "data/amistad/cartas.json"])

print("\n== M39 infrastructure (real source only) ==")
show("M39 infra code/dataset", r"(infraestructura|muelle|faro|plaza|puente|farola|pozo)", ["scripts/islas", "scripts/world", "scripts/construccion", DATA, SCENES])
