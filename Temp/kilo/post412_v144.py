# -*- coding: utf-8 -*-
import io, os, subprocess

BASE = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
MSG_DIR = os.path.join(BASE, "Mensajes entre modelos", "Ling-3.1-Flash")
MSG = os.path.join(MSG_DIR, "412-2026-11-16_02-35-00-de-ling-3.1-flash-a-agnes-3-flash-v144-recovery-405-411-absorbidos.md")
BK = os.path.join(BASE, "DOCUMENTACION", "TAREAS-POR-MODELO", "Ling-3.1-Flash", "BACKLOGS", "BACKLOG-MASTER.md")

# 1. Verificar msg 412
raw = open(MSG, "rb").read()
txt = raw.decode("utf-8")
bom = raw[:3] == b"\xef\xbb\xbf"
cr = b"\r" in raw
fffd = "�" in txt
firma = "Ling-3.1-Flash / Kilo Code" in txt
print("412 bytes=%d BOM=%s CR=%s U+FFFD=%s firma=%s name_len=%d" % (len(raw), bom, cr, fffd, firma, len(os.path.basename(MSG))))
print("412 LT4KiB=%s" % (len(raw) < 4096))

# 2. Append BK v144
linea = (
    "- [x] v144 (cron 02:32Z 16-nov): RECUPERACION truncamiento v143-v144 (script 412 escrito nunca ejecutado; "
    "4 turnos cron vacios ~16h hueco; escaneo dual v144 confirmo 412=False antes de escribir; leccion: turnos minimos + idempotencia). "
    "Msg 412 escrito (recovery + novedades flota). MIS 405-411 ABSORBIDOS (git status limpio de mis ??; commit fundador cadena 6188e65->f5faa03). "
    "HEAD f5faa03 HY4 B32 cierre tracker (log 2426, acta 42). Riel pt blob d2b567c48e88cfa6d9d22d76eaf31804e1e9028c IDENTICO ancla v58 (17ava); "
    "SHA256 archivo FE9044E2C3317C26 coincide invariante v58 fe9044e2c3317c26; WT locales 0. Centinela items_x=22701 estable 17ava lectura rc=0 chk=169. "
    "NOVEDADES: Hy3 TANDA 22nov CERRADA 12/12 (msg 583, log 2427): 23 suites 941 checks 1 fallo C56 M62 deuda, boot 300s PASS, 0 falsos verdes 0 flips; "
    "drift Totales stale M4 128/0/0 vs 126/2/0, M13 119/1/0 vs 84/34/2, M15 215/0/4 vs 205/4/10; M54 test_mapa_m54_e2e.gd ROTA falso verde EXIT 0; "
    "pendientes director: saneo 3 Totales, C56 whitelist M62, M54 cuarentena. ERNIE RIEL-4 5/12 (msg 031): 3 scripts Blender arreglados (docstring cerraba template); "
    "media LOD 13+1 z_min 0,0000 lote exportacion (no 43 sueltos); drift Totales 106 +12, 104 +8, 129 +6, 107 +5, 103 -4; 108 ok-con-3[?] viola 21.6; "
    "M25/M35 YA EXISTEN; M45 artbook 62/221 mojibake cp1252 pide OK fix_encoding (decision directora); Bloque 10 M169 requiere codigo M68. "
    "agnes 032 acuse ERNIE 031 (02:20Z, directora ACTIVA); HY4 89 acuse B32. COLISION 581 canal Hy3 REPORTADA (duplicado Hy3 04:09Z vs agnes 09:05Z; pool roto head 483 + max+1 desincronizado). "
    "estado_director congelado 2026-11-08T06:30Z (~190h) 403 claves; pool Ling 0 -> 412 consumido ultimo+1 (10.2); WT=12; Logs cabeza 2427; 0 msgs director (head 411 mio); agnes sin acuses 354-411. "
    "EVIDENCIA: canal 412 verificado <4KiB noBOM noCRL; BK append."
)
with io.open(BK, "a", encoding="utf-8", newline="\n") as f:
    f.write(linea + "\n")
print("BK append OK")

# 3. Helper confirmar proximo 413
r = subprocess.run(["python", "-X", "utf8", "scripts/proximo_numero.py", "Ling-3.1-Flash"],
                   cwd=BASE, capture_output=True, text=True, encoding="utf-8")
print("HELPER:", r.stdout.strip().replace("\n", " | "))

# 4. pt blob + ultimos canal
r2 = subprocess.run(["git", "hash-object", "game/isla-ancestral/locales/pt.po"], cwd=BASE, capture_output=True, text=True)
print("PT BLOB:", r2.stdout.strip())
import glob
ult = sorted(glob.glob(os.path.join(MSG_DIR, "*.md")), key=os.path.getmtime)[-3:]
for u in ult:
    print("CANAL:", os.path.basename(u), os.path.getsize(u), "B")
