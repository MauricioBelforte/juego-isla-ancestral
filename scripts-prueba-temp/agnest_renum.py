# -*- coding: utf-8 -*-
import io, os, re, shutil

d = "Mensajes entre modelos/agnes-3-flash"
# (numero_viejo, numero_nuevo) en orden cronologico; 393 y 394 no cambian
MAPA = [(504,395),(395,396),(505,397),(396,398),(397,399),(500,400),(502,401),
        (507,402),(509,403),(511,404),(506,405),(501,406),(503,407),(508,408),
        (510,409),(512,410)]

# fase 1: a temporales
tmps = []
for viejo, nuevo in MAPA:
    arch = [f for f in os.listdir(d) if f.startswith("%d-" % viejo) and f.endswith(".md")]
    if len(arch) != 1:
        print("FALTA/AMBIGUO %d: %s" % (viejo, arch)); continue
    src = os.path.join(d, arch[0])
    tmp = os.path.join(d, "TMP%04d-%s" % (nuevo, arch[0].split("-", 1)[1]))
    os.rename(src, tmp)
    tmps.append((tmp, viejo, nuevo))
print("fase 1:", len(tmps), "a temporales")

# fase 2: a destino final
for tmp, viejo, nuevo in tmps:
    final = os.path.join(d, "%d-%s" % (nuevo, os.path.basename(tmp).split("-", 1)[1]))
    os.rename(tmp, final)
print("fase 2: ok")

# fase 3: headers internos
for tmp, viejo, nuevo in tmps:
    final = os.path.join(d, "%d-%s" % (nuevo, os.path.basename(tmp).split("-", 1)[1]))
    with io.open(final, encoding="utf-8") as f:
        t = f.read()
    t2 = re.sub(r"(?m)^# %d\b" % viejo, "# %d" % nuevo, t, count=1)
    if t2 != t:
        with io.open(final, "w", encoding="utf-8", newline="\n") as f:
            f.write(t2)
        print("  header %d -> %d" % (viejo, nuevo))
    else:
        print("  AVISO: header %d no encontrado en %s" % (viejo, os.path.basename(final)[:40]))
