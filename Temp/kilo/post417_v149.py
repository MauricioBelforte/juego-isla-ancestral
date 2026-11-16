# -*- coding: utf-8 -*-
import io, os, subprocess, glob

BASE = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
MSG_DIR = os.path.join(BASE, "Mensajes entre modelos", "Ling-3.1-Flash")
MSG = os.path.join(MSG_DIR, "417-2026-11-16_05-00-00-de-ling-3.1-flash-a-agnes-3-flash-v149-quietud-45min-f5faa03-22701.md")
BK = os.path.join(BASE, "DOCUMENTACION", "TAREAS-POR-MODELO", "Ling-3.1-Flash", "BACKLOGS", "BACKLOG-MASTER.md")

raw = open(MSG, "rb").read()
txt = raw.decode("utf-8")
print("417 bytes=%d BOM=%s CR=%s U+FFFD=%s firma=%s name_len=%d LT4KiB=%s" % (
    len(raw), raw[:3] == b"\xef\xbb\xbf", b"\r" in raw, "�" in txt,
    "Ling-3.1-Flash / Kilo Code" in txt, len(os.path.basename(MSG)), len(raw) < 4096))

linea = (
    "- [x] v149 (cron 05:00Z 16-nov): QUIETUD ~45min (ultima flota 04:05-04:15Z: ERNIE 035 datos M169 pasajes+camarotes validados; agnes 036 acuse). "
    "Sin respuesta a pedidos ERNIE (fix_encoding M45, GO/autoload Bloque 10 M169) ni a mis 412-416. HEAD f5faa03 estable ~4.5h; WT 30->32 solo mis escritos "
    "(417+script+BK); 0 conflictos. Paso 0: estado_director.json 403 claves congelado 2026-11-08T06:30:44Z (~203h). Logs cabeza 2427 (~7h sin log nuevo). "
    "Riel pt blob d2b567c IDENTICO ancla v58 (23ava); WT locales 0. Centinela items_x=22701 estable 23ava lectura rc=0 chk=169. Watchdog rc=0 LIMPIO (v144). "
    "Canal cabeza 416 mio, 0 respuesta directora, 0 acuses agnes 354-416. Pool Ling 0 -> 417 consumido ultimo+1 (10.2); huecos intactos. "
    "EVIDENCIA: canal 417 verificado noBOM noCR LF firma <4KiB; BK append."
)
with io.open(BK, "a", encoding="utf-8", newline="\n") as f:
    f.write(linea + "\n")
print("BK append v149 OK")

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
