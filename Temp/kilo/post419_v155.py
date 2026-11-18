# -*- coding: utf-8 -*-
import os, glob, hashlib, subprocess
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

# 1. Verificar 419 en disco
cands = glob.glob(os.path.join(root, r"Mensajes entre modelos\Ling-3.1-Flash\419-*.md"))
print("419 files:", cands)
if cands:
    b = open(cands[0], "rb").read()
    t = b.decode("utf-8")
    print("419 bytes:", len(b), "| BOM:", b[:3] == b"\xef\xbb\xbf", "| CR:", b"\r" in b,
          "| FFFD:", "\ufffd" in t, "| firma:", "Ling-3.1-Flash" in t, "| LT4KiB:", len(b) < 4096)

# 2. Append BK v150-v155 (idempotente)
bk = os.path.join(root, r"DOCUMENTACION\TAREAS-POR-MODELO\Ling-3.1-Flash\BACKLOGS\BACKLOG-MASTER.md")
txt = open(bk, encoding="utf-8").read()
if "v150-v155" in txt:
    print("BK: linea v150-v155 YA existe (idempotencia OK)")
else:
    line = ("- [x] v150-v155 (2026-11-18 05:23Z): cierre deuda truncada. v150: ERNIE 037 RIEL-4 7/12 "
            "(manager 241L + datos M169; sin godot 4.7 -> estatico; autoload pendie OK agnes); 418 escrito "
            "y verificado 3480B. v151-v154: TRUNCAMIENTO recurrente (4 turnos vacios, 0 writes; "
            "post418_v150.py y BK v150-v154 nunca ejecutados). v152 recovery disco: 418 OK, HEAD 600fa01. "
            "Fundador pregunto cron -> cron_list VACIO (wku_1c26a732 murio con compaccion); orden fundador "
            "reencender 30 min. v155: cron REENCENDIDO wku_1ed0cb060001A0WsikTA2YWn97 (*/30, prox 05:30Z); "
            "escaneo ~47h: HEAD d164742 (HY4 551 tareas/~1850), pt integro 25avas, Logs cabeza 2427 "
            "(~47h sin logs), centinela items_x 22719 (+18, C2/chk estables sin flips), estado 403 claves "
            "congelado ~214h; HY4 035 LEIDO: i18n APROBADO agnes (106/106 claves reales ambos .po, 4/4 nichos "
            "HY4); msg 419 escrito (informe combinado <4KiB). Sin acuse directora 412-418.")
    with open(bk, "a", encoding="utf-8", newline="\n") as f:
        f.write("\n" + line + "\n")
    print("BK: linea v150-v155 APPEND OK")

# 3. Helper proximo numero (estado, sin consumir)
r = subprocess.run(["python", "-X", "utf8", "scripts/proximo_numero.py", "Ling-3.1-Flash"],
                   cwd=root, capture_output=True, text=True)
print(r.stdout.strip())

# 4. Riel pt
pt = open(os.path.join(root, r"game\isla-ancestral\locales\pt.po"), "rb").read()
print("pt sha256:", hashlib.sha256(pt).hexdigest().upper()[:16], "| size:", len(pt))
