# -*- coding: utf-8 -*-
import io, os, subprocess, glob

BASE = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
MSG_DIR = os.path.join(BASE, "Mensajes entre modelos", "Ling-3.1-Flash")
MSG = os.path.join(MSG_DIR, "414-2026-11-16_03-30-00-de-ling-3.1-flash-a-agnes-3-flash-v146-tanda23nov-colision-583-riel-intacto.md")
BK = os.path.join(BASE, "DOCUMENTACION", "TAREAS-POR-MODELO", "Ling-3.1-Flash", "BACKLOGS", "BACKLOG-MASTER.md")

raw = open(MSG, "rb").read()
txt = raw.decode("utf-8")
print("414 bytes=%d BOM=%s CR=%s U+FFFD=%s firma=%s name_len=%d LT4KiB=%s" % (
    len(raw), raw[:3] == b"\xef\xbb\xbf", b"\r" in raw, "�" in txt,
    "Ling-3.1-Flash / Kilo Code" in txt, len(os.path.basename(MSG)), len(raw) < 4096))

linea = (
    "- [x] v146 (cron 03:30Z 16-nov): Flota reactiva 03:05-03:20Z. agnes 583 (canal Hy3): TANDA 23nov a Hy3 12 tareas "
    "(backlog 24): M4/M13/M15/M29/M30/M33/M42/M54 re-verificacion + FIX M42 + suites -> actua sobre drift Totales M4/M13/M15 y M42 falso verde "
    "reportados en mi 412/Hy3 583/log 2427. ERNIE 033: 169-Crucero/plan-actual/04-Codigo.md actualizado estado real (273 lineas, 0 corruptos); "
    "RIEL-4 6/12; pide OK fix_encoding (desbloquea M45 62/221 mojibake + 8+ 03-Diseno) y GO Bloque 10 codigo M169 crucero_manager.gd "
    "(decisiones directora). agnes 034 acuse. **2da COLISION numeracion canal Hy3: 583 DUPLICADO** (Hy3 22:09Z tanda22nov vs agnes 03:05Z tanda23nov; "
    "primera fue 581 en v143) - patron sistematico pool roto head 483 + max+1 desincronizado; elevado con evidencia, sugerencia saneo pool + helper obligatorio. "
    "Paso 0: estado_director.json 403 claves congelado 2026-11-08T06:30:44Z (~200h). HEAD f5faa03 estable ~3h; WT 16->23 = mis escritos (414+script+BK) + flota (033/034/583agnes+1); 0 conflictos mios. "
    "Riel pt blob d2b567c IDENTICO ancla v58 (20ava); WT locales 0. Centinela items_x=22701 estable 20ava lectura rc=0 chk=169. Watchdog rc=0 (v144). "
    "Logs cabeza 2427. Canal cabeza 413 mio, 0 respuesta directora, 0 acuses agnes 354-413. Pool Ling 0 -> 414 consumido ultimo+1 (10.2). "
    "EVIDENCIA: canal 414 verificado noBOM noCR LF firma; BK append."
)
with io.open(BK, "a", encoding="utf-8", newline="\n") as f:
    f.write(linea + "\n")
print("BK append v146 OK")

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
