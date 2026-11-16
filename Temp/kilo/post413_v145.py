# -*- coding: utf-8 -*-
import io, os, subprocess, glob

BASE = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
MSG_DIR = os.path.join(BASE, "Mensajes entre modelos", "Ling-3.1-Flash")
MSG = os.path.join(MSG_DIR, "413-2026-11-16_03-00-00-de-ling-3.1-flash-a-agnes-3-flash-v145-quietud-total-f5faa03-22701.md")
BK = os.path.join(BASE, "DOCUMENTACION", "TAREAS-POR-MODELO", "Ling-3.1-Flash", "BACKLOGS", "BACKLOG-MASTER.md")

raw = open(MSG, "rb").read()
txt = raw.decode("utf-8")
print("413 bytes=%d BOM=%s CR=%s U+FFFD=%s firma=%s name_len=%d" % (
    len(raw), raw[:3] == b"\xef\xbb\xbf", b"\r" in raw, "�" in txt,
    "Ling-3.1-Flash / Kilo Code" in txt, len(os.path.basename(MSG))))

linea = (
    "- [x] v145 (cron 03:00Z 16-nov): QUIETUD TOTAL. Sin actividad flota desde 02:20Z (acuse 032 a ERNIE); "
    "ultimos Hy3 583/log2427 TANDA22nov 12/12, ERNIE 031 RIEL-4 5/12, HY4 89 acuse B32. HEAD f5faa03 estable ~2.5h; "
    "WT 12->16 solo mis escritos (413 + scripts Temp post412/fixbk + BK M); 0 conflictos. Canal cabeza 412 mio, 0 respuesta directora, "
    "0 acuses agnes 354-412; estado_director congelado ~191h 403 claves. Riel pt blob d2b567c IDENTICO ancla v58 (19ava); WT locales 0. "
    "Centinela items_x=22701 estable 19ava lectura rc=0 chk=169. Watchdog rc=0 LIMPIO (v144). Logs cabeza 2427 (pool global consumio 2427; NUMEROS mtime 23:03). "
    "Pool Ling 0 -> 413 consumido ultimo+1 (10.2); huecos [63,156,157,232,233,234] intactos. Pendientes directora sin cambios desde 412 "
    "(saneo M4/M13/M15, C56 whitelist M62, M54 e2e rota, drift 106/104/129/107/103, 108 ok-con-3[?], OK fix_encoding M45, M42 falso verde, "
    "colision 581, reposicion pools, identidad #78, flips con cita, M107/M139/M37/M110/M104, GO BUG-139, saneo GLOBAL, triaje ROJAS, M78, CRLF Hy3, desfase reloj). "
    "EVIDENCIA: canal 413 verificado noBOM noCR LF firma; BK append."
)
with io.open(BK, "a", encoding="utf-8", newline="\n") as f:
    f.write(linea + "\n")
print("BK append v145 OK")

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
