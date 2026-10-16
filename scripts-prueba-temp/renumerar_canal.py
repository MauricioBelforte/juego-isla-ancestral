# -*- coding: utf-8 -*-
import io, os, re

d = "Mensajes entre modelos/step-5-kilocode"
MAPA = [
  ("499-2026-10-14_01-15-00-mimo-a-step5-285-aceptado-m11-flipado-asigno-m139.md", 499, 286),
  ("286-2026-10-14_01-45-00-step-5-kilocode-a-step-5-kilocode-m139-lote1-arquitectura-13-142.md", 286, 287),
  ("498-2026-10-14_01-55-00-mimo-a-step5-m139-lote1-ok-recrear-informes-autorizado.md", 498, 288),
  ("287-2026-10-14_02-20-00-step-5-kilocode-a-step-5-kilocode-m139-lote2-aurora-22-142.md", 287, 289),
  ("292-2026-10-14_02-30-00-mimo-a-step5-lote2-ok-recrear-ya-autorizado.md", 292, 290),
  ("288-2026-10-14_02-40-00-step-5-kilocode-a-step-5-kilocode-m27-auditada-completa-recreado-log1819.md", 288, 291),
  ("289-2026-10-14_02-45-00-step-5-kilocode-a-step-5-kilocode-m74-auditada-completa-recreado-log1821.md", 289, 292),
  ("290-2026-10-14_02-50-00-step-5-kilocode-a-step-5-kilocode-m34-auditada-completa-recreado-log1823.md", 290, 293),
  ("291-2026-10-14_02-55-00-step-5-kilocode-a-step-5-kilocode-m11-auditada-completa-recreado-log1824.md", 291, 294),
]

# fase 1: a temporales
tmp = []
for nombre, viejo, nuevo in MAPA:
    p = os.path.join(d, nombre)
    if not os.path.exists(p):
        print("FALTA:", nombre); continue
    t = os.path.join(d, "TMP%04d-%s" % (nuevo, nombre.split("-", 1)[1]))
    os.rename(p, t)
    tmp.append((t, viejo, nuevo))
print("fase 1 (a temporales):", len(tmp), "archivos")

# fase 2: a finales
for t, viejo, nuevo in tmp:
    final = os.path.join(d, "%d-%s" % (nuevo, os.path.basename(t).split("-", 1)[1]))
    os.rename(t, final)
print("fase 2 (a numeros finales): ok")

# fase 3: headers internos
for t, viejo, nuevo in tmp:
    final = os.path.join(d, "%d-%s" % (nuevo, os.path.basename(t).split("-", 1)[1]))
    with io.open(final, encoding="utf-8") as f:
        c = f.read()
    c2 = re.sub(r"(?m)^# %d\b" % viejo, "# %d" % nuevo, c, count=1)
    c2 = c2.replace("# %d \u2014" % viejo, "# %d \u2014" % nuevo)
    if c2 != c:
        with io.open(final, "w", encoding="utf-8", newline="\n") as f:
            f.write(c2)
        print("  header %d -> %d en %s" % (viejo, nuevo, os.path.basename(final)[:40]))
