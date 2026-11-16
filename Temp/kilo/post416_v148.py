# -*- coding: utf-8 -*-
import io, os, subprocess, glob

BASE = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
MSG_DIR = os.path.join(BASE, "Mensajes entre modelos", "Ling-3.1-Flash")
MSG = os.path.join(MSG_DIR, "416-2026-11-16_04-30-00-de-ling-3.1-flash-a-agnes-3-flash-v148-ernie-datos-m169-412-415-pendientes.md")
BK = os.path.join(BASE, "DOCUMENTACION", "TAREAS-POR-MODELO", "Ling-3.1-Flash", "BACKLOGS", "BACKLOG-MASTER.md")

raw = open(MSG, "rb").read()
txt = raw.decode("utf-8")
print("416 bytes=%d BOM=%s CR=%s U+FFFD=%s firma=%s name_len=%d LT4KiB=%s" % (
    len(raw), raw[:3] == b"\xef\xbb\xbf", b"\r" in raw, "�" in txt,
    "Ling-3.1-Flash / Kilo Code" in txt, len(os.path.basename(MSG)), len(raw) < 4096))

linea = (
    "- [x] v148 (cron 04:30Z 16-nov): ERNIE 035 datos M169 creados+validados json.loads: data/crucero/pasajes.json "
    "(Tercera 30 interno cub 1-3, Segunda 70 exterior 1-4, Primera 140 suite 1-4+casino+puente; recargo temp x1.25; cancelacion 50% coherente M28) "
    "y camarotes.json (6 tipos+tripulacion, medidas modelo 3D: interno 8.3, exterior 9.5, balcon 10.8+2.4, familiar 14.4+3.4, suite 23+6.1, duplex 37 2 niveles; _meta). "
    "DISCIPLINA ERNIE: NO toco project.godot autoload CruceroManager (espera OK directora) y NO escribio crucero_manager.gd (clarificado: estado, senales, buy_ticket via M68, persistencia via M59); "
    "next: crucero_manager.gd + crucero_pasaje.gd Resource + crucero_interior.gd + 4 interiores. agnes 036 acuse 035 (canal ERNIE). "
    "Desglose WT 30: mis 412/413/414/415 ?? 4 msgs pendientes absorcion fundador (405-411 SI absorbidos); flota ERNIE 031-036 + data/crucero/ + 04-Codigo M + scripts blender; "
    "Hy3 backlog 24 ?? + 583 duplicado persistente sin saneo; HY4 89; Logs 2427 ??. HEAD f5faa03 estable ~4h. Paso 0: estado 403 claves congelado ~202.5h. "
    "Riel pt blob d2b567c IDENTICO ancla v58 (22ava); WT locales 0. Centinela items_x=22701 estable 22ava rc=0 chk=169. Watchdog rc=0 (v144). Logs cabeza 2427. "
    "Canal cabeza 415 mio, 0 respuesta directora, 0 acuses agnes 354-415. Pool Ling 0 -> 416 consumido ultimo+1 (10.2). "
    "EVIDENCIA: canal 416 verificado noBOM noCR LF firma <4KiB; BK append."
)
with io.open(BK, "a", encoding="utf-8", newline="\n") as f:
    f.write(linea + "\n")
print("BK append v148 OK")

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
