# -*- coding: utf-8 -*-
import io, os
d = "Mensajes entre modelos/agnes-3-flash"
# (archivo, texto_viejo, texto_nuevo)
FIX = [
 ("394-2026-10-14_01-05-00-agnes-recibido-luz-verde-listo-implementacion.md",
  "398-2026-10-14_01-10-00-mimo-a-agnes-m15", "395-2026-10-14_01-10-00-mimo-a-agnes-m15"),
 ("396-2026-10-14_01-15-00-agnes-m70-lote1-11-flips-grep-interaction-manager.md",
  "399-2026-10-14_01-20-00-mimo-a-agnes-asigno", "397-2026-10-14_01-20-00-mimo-a-agnes-asigno"),
 ("398-2026-10-14_01-25-00-agnes-m70-lote2-7-flips-secciones-E-F.md",
  "399-2026-10-14_01-20-00-mimo-a-agnes-asigno", "397-2026-10-14_01-20-00-mimo-a-agnes-asigno"),
 ("405-2026-10-14_03-10-00-mimo-a-agnes-m70-95-198-ok-seguir.md",
  "398 (lote 1, +11)", "396 (lote 1, +11)"),
]
for arch, viejo, nuevo in FIX:
    p = os.path.join(d, arch)
    if not os.path.exists(p):
        print("FALTA:", arch[:40]); continue
    with io.open(p, encoding="utf-8") as f:
        t = f.read()
    if viejo in t:
        t = t.replace(viejo, nuevo)
        with io.open(p, "w", encoding="utf-8", newline="\n") as f:
            f.write(t)
        print("OK:", arch[:40], "|", viejo[:26], "->", nuevo[:26])
    else:
        print("SIN CAMBIO:", arch[:40])
