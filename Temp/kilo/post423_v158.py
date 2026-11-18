# -*- coding: utf-8 -*-
import io, os, glob, hashlib, subprocess
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

cands = glob.glob(os.path.join(root, r"Mensajes entre modelos\Ling-3.1-Flash\423-*.md"))
print("423 files:", cands)
if cands:
    b = open(cands[0], "rb").read()
    t = b.decode("utf-8")
    print("423 bytes:", len(b), "| BOM:", b[:3] == b"\xef\xbb\xbf", "| CR:", b"\r" in b,
          "| FFFD:", "\ufffd" in t, "| firma:", "Ling-3.1-Flash" in t, "| LT4KiB:", len(b) < 4096)

bk = os.path.join(root, r"DOCUMENTACION\TAREAS-POR-MODELO\ling-3.1-flash\BACKLOGS\BACKLOG-MASTER.md")
txt = io.open(bk, encoding="utf-8").read()
if "vuelta cron 07:00Z" in txt:
    print("BK: linea v158 YA existe (idempotencia OK)")
else:
    line = ("- [x] v158 vuelta cron 07:00Z: msg 423 escrito y verificado (reporte honesto de quietud). "
            "Blindaje: watchdog rc=0 LIMPIO; centinela items_x 22719 ESTABLE 4ª hora consecutiva (C2=552/"
            "chk=169, 0 flips); riel pt 29ava. HEAD 55e672e sin cambios (0 commits 06:05-07:00Z). WT=10: HY4 "
            "activo B23 Visual QA (backlog 23 M + .ultima-revision M + 054/055/056 cierre tanda3 + acuse "
            "agnes 06:48Z); agnes 066 acuse ERNIE 068 etcsn-01; mios BK appends v156/v157 + 422; Temp 2 "
            "scripts tooling. Canal Ling: 422/421/420 mios, SIN respuesta directora 412-422, sin encargo. "
            "estado_director congelado 10 dias. Postura: standby report-only; nicho auditoria disponible "
            "(convergencia BM-31/32/33 elevada en 422). Proxima 07:30Z.")
    with io.open(bk, "a", encoding="utf-8", newline="\n") as f:
        f.write("\n" + line + "\n")
    print("BK: linea v158 APPEND OK")

r = subprocess.run(["python", "-X", "utf8", "scripts/proximo_numero.py", "Ling-3.1-Flash"],
                   cwd=root, capture_output=True, text=True)
print(r.stdout.strip())

pt = open(os.path.join(root, r"game\isla-ancestral\locales\pt.po"), "rb").read()
print("pt sha256:", hashlib.sha256(pt).hexdigest().upper()[:16], "| size:", len(pt))
