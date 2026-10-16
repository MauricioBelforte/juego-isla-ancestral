# -*- coding: utf-8 -*-
import subprocess, sys
sys.stdout.reconfigure(encoding="utf-8")
pares = [
 ("Mensajes entre modelos/atria-dawn-s2/2027-2026-10-13_17-00-57-s2-a-s2-ronda6-agnes-m141-m15-m16-denegados-m139-ok-m35-sello-m117-sin-drift.md", "Mensajes entre modelos/atria-dawn-s2/376-2026-10-13_17-00-57-s2-a-s2-ronda6-agnes-m141-m15-m16-denegados-m139-ok-m35-sello-m117-sin-drift.md"),
 ("Mensajes entre modelos/atria-dawn-s2/2029-2026-10-13_17-29-47-s2-a-s2-m112-r3-6flips-verificados-sello-recomendado.md", "Mensajes entre modelos/atria-dawn-s2/377-2026-10-13_17-29-47-s2-a-s2-m112-r3-6flips-verificados-sello-recomendado.md"),
 ("Mensajes entre modelos/atria-dawn/200-2026-10-13_20-10-00-mimo-a-atria-luz-verde-commit-iter6-wb-standby.md", "Mensajes entre modelos/atria-dawn/89-2026-10-13_20-10-00-mimo-a-atria-luz-verde-commit-iter6-wb-standby.md"),
 ("Mensajes entre modelos/atria-dawn/200-2026-10-13_22-21-47-atria-a-atria-acuse-push-ok-standby.md", "Mensajes entre modelos/atria-dawn/92-2026-10-13_22-21-47-atria-a-atria-acuse-push-ok-standby.md"),
 ("Mensajes entre modelos/atria-dawn/2027-2026-10-13_16-52-55-atria-a-atria-commits-m04-iter45-m35-lote3-pusheados.md", "Mensajes entre modelos/atria-dawn/85-2026-10-13_16-52-55-atria-a-atria-commits-m04-iter45-m35-lote3-pusheados.md"),
 ("Mensajes entre modelos/atria-dawn/2029-2026-10-13_17-21-53-atria-a-atria-acuse-standby-liberado-commits.md", "Mensajes entre modelos/atria-dawn/86-2026-10-13_17-21-53-atria-a-atria-acuse-standby-liberado-commits.md"),
 ("Mensajes entre modelos/atria-dawn/2031-2026-10-13_17-48-27-atria-a-atria-m04-iter6-verificado-pido-luz-verde-commit.md", "Mensajes entre modelos/atria-dawn/87-2026-10-13_17-48-27-atria-a-atria-m04-iter6-verificado-pido-luz-verde-commit.md"),
 ("Mensajes entre modelos/atria-dawn/2032-2026-10-13_20-21-19-atria-a-atria-m04-iter6-commiteado-pusheado-31e6d94.md", "Mensajes entre modelos/atria-dawn/88-2026-10-13_20-21-19-atria-a-atria-m04-iter6-commiteado-pusheado-31e6d94.md"),
]
for viejo, nuevo in pares:
    r = subprocess.run(["git", "ls-files", "--", nuevo], capture_output=True, text=True)
    track = bool(r.stdout.strip())
    print("%-8s %s" % ("TRACK" if track else "untrack", nuevo.split("/")[-1][:60]))
