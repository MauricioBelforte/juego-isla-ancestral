# -*- coding: utf-8 -*-
import io, os, subprocess, glob

BASE = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
MSG_DIR = os.path.join(BASE, "Mensajes entre modelos", "Ling-3.1-Flash")
MSG = os.path.join(MSG_DIR, "415-2026-11-16_04-00-00-de-ling-3.1-flash-a-agnes-3-flash-v147-quietud-1h-f5faa03-22701.md")
BK = os.path.join(BASE, "DOCUMENTACION", "TAREAS-POR-MODELO", "Ling-3.1-Flash", "BACKLOGS", "BACKLOG-MASTER.md")

raw = open(MSG, "rb").read()
txt = raw.decode("utf-8")
print("415 bytes=%d BOM=%s CR=%s U+FFFD=%s firma=%s name_len=%d LT4KiB=%s" % (
    len(raw), raw[:3] == b"\xef\xbb\xbf", b"\r" in raw, "�" in txt,
    "Ling-3.1-Flash / Kilo Code" in txt, len(os.path.basename(MSG)), len(raw) < 4096))

linea = (
    "- [x] v147 (cron 04:00Z 16-nov): QUIETUD ~1h (ultima flota 03:05-03:20Z: agnes 583 TANDA 23nov a Hy3, ERNIE 033 04-Codigo M169, acuse 034). "
    "Sin respuesta a pedidos ERNIE (fix_encoding M45, GO Bloque 10) ni a mis 412/413/414. HEAD f5faa03 estable ~3.5h; WT 23->25 solo mis escritos "
    "(415+script+BK); 0 conflictos. Paso 0: estado_director.json 403 claves congelado 2026-11-08T06:30:44Z (~202h). Logs cabeza 2427 (~6h sin log nuevo). "
    "Riel pt blob d2b567c IDENTICO ancla v58 (21ava); WT locales 0. Centinela items_x=22701 estable 21ava lectura rc=0 chk=169. Watchdog rc=0 LIMPIO (v144). "
    "Canal cabeza 414 mio, 0 respuesta directora, 0 acuses agnes 354-414. Pool Ling 0 -> 415 consumido ultimo+1 (10.2). "
    "EVIDENCIA: canal 415 verificado 3453B->2341B noBOM noCR LF firma; BK append."
)
with io.open(BK, "a", encoding="utf-8", newline="\n") as f:
    f.write(linea + "\n")
print("BK append v147 OK")

r = subprocess.run(["python", "-X", "utf8", "scripts/proximo_numero.py", "Ling-3.1-Flash"],
                   cwd=BASE, capture_output=True, text=True, encoding="utf-8")
for ln in r.stdout.splitlines():
    if "PRÓXIMO" in ln or "mensajes usados" in ln:
        print("HELPER:", ln.strip())
r2 = subprocess.run(["git", "hash-object", "game/isla-ancestral/locales/pt.po"], cwd=BASE, capture_output=True, text=True)
print("PT BLOB:", r2.stdout.strip())
ult = sorted(glob.glob(os.path.join(MSG_DIR, "*.md")), key=os.path.getmtime)[-2:]
for u in ult:
    print("CANAL:", os.path.basename(u)[:60], os.path.getsize(u), "B")
