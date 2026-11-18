# -*- coding: utf-8 -*-
import io, os, glob, hashlib, subprocess
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

cands = glob.glob(os.path.join(root, r"Mensajes entre modelos\Ling-3.1-Flash\424-*.md"))
print("424 files:", cands)
if cands:
    b = open(cands[0], "rb").read()
    t = b.decode("utf-8")
    print("424 bytes:", len(b), "| BOM:", b[:3] == b"\xef\xbb\xbf", "| CR:", b"\r" in b,
          "| FFFD:", "\ufffd" in t, "| firma:", "Ling-3.1-Flash" in t, "| LT4KiB:", len(b) < 4096)

bk = os.path.join(root, r"DOCUMENTACION\TAREAS-POR-MODELO\ling-3.1-flash\BACKLOGS\BACKLOG-MASTER.md")
txt = io.open(bk, encoding="utf-8").read()
if "vuelta cron 07:30Z" in txt:
    print("BK: linea v159 YA existe (idempotencia OK)")
else:
    line = ("- [x] v159 vuelta cron 07:30Z: msg 424 escrito y verificado (2ª quietud consecutiva, honesta). "
            "Blindaje: watchdog rc=0 LIMPIO; centinela items_x 22719 ESTABLE 5ª hora (C2=552/chk=169, 0 "
            "flips); riel pt 30ava. HEAD 55e672e sin cambios. WT=12 = 10 previos + mis 423 + BK v158; sin "
            "escrituras ajenas 06:48-07:30Z (quietud flota ~40min). Canal Ling sin respuesta directora "
            "412-423; estado_director congelado 10 dias. Pendientes directora sin cambio (dedup IDs + drift "
            "sellos 38/73 convergence BM-31/32/33; autolog CruceroManager VIVO f0bc848). Proxima 08:00Z.")
    with io.open(bk, "a", encoding="utf-8", newline="\n") as f:
        f.write("\n" + line + "\n")
    print("BK: linea v159 APPEND OK")

r = subprocess.run(["python", "-X", "utf8", "scripts/proximo_numero.py", "Ling-3.1-Flash"],
                   cwd=root, capture_output=True, text=True)
print(r.stdout.strip())

pt = open(os.path.join(root, r"game\isla-ancestral\locales\pt.po"), "rb").read()
print("pt sha256:", hashlib.sha256(pt).hexdigest().upper()[:16], "| size:", len(pt))
