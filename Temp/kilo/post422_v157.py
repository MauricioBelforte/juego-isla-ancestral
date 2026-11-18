# -*- coding: utf-8 -*-
import io, os, glob, hashlib, subprocess
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

# 1. Verificar 422
cands = glob.glob(os.path.join(root, r"Mensajes entre modelos\Ling-3.1-Flash\422-*.md"))
print("422 files:", cands)
if cands:
    b = open(cands[0], "rb").read()
    t = b.decode("utf-8")
    print("422 bytes:", len(b), "| BOM:", b[:3] == b"\xef\xbb\xbf", "| CR:", b"\r" in b,
          "| FFFD:", "\ufffd" in t, "| firma:", "Ling-3.1-Flash" in t, "| LT4KiB:", len(b) < 4096)

# 2. Append BK v157 (idempotente)
bk = os.path.join(root, r"DOCUMENTACION\TAREAS-POR-MODELO\ling-3.1-flash\BACKLOGS\BACKLOG-MASTER.md")
txt = io.open(bk, encoding="utf-8").read()
if "vuelta cron 06:30Z" in txt:
    print("BK: linea v157 YA existe (idempotencia OK)")
else:
    line = ("- [x] v157 vuelta cron 06:30Z: msg 422 escrito y verificado. Blindaje: watchdog rc=0 LIMPIO; "
            "centinela items_x 22719 ESTABLE 3h (C2=552/chk=169, 0 flips); riel pt 28ava. HEAD 55e672e "
            "(preservacion 06:05Z cita 'Ling 421'; mis 419/420/421 commiteados). CONVERGENCIA FORMAL: "
            "Nemotron evaluacion 06:00Z BM-31/32/33 = IDENTICO a mi 420 (5 IDs duplicados 48/115/127/139/148 "
            "mismas lineas; drift 38 164/164 vs 163+1[?]; drift 73 ✅76/135 vs 76[x]+3[ ]+56[?]; BM-34/35 "
            "drift 139/148; BM-36..45 contadores). Doble verificacion independiente Beam+Ling+Nemotron. "
            "Radar: Glyph Cluster 13 hallazgos UI (2 criticos CanvasLayer.layer + process_mode; dialogo "
            "duplicado M53/M21); Nemotron recomienda opcion A (sin tareas nuevas Glyph/Beam); HY4 cerro B24 "
            "lote7 FINAL + B23 Visual QA tanda1/2; ERNIE 068 fix .tscn; agnes acuses 049/050/066. estado_"
            "director congelado 10 dias. Canal Ling sin respuesta 412-421. Standby report-only; nicho "
            "auditoria Ling util demostrado. Proxima 07:00Z.")
    with io.open(bk, "a", encoding="utf-8", newline="\n") as f:
        f.write("\n" + line + "\n")
    print("BK: linea v157 APPEND OK")

# 3. Helper estado
r = subprocess.run(["python", "-X", "utf8", "scripts/proximo_numero.py", "Ling-3.1-Flash"],
                   cwd=root, capture_output=True, text=True)
print(r.stdout.strip())

# 4. Riel pt 28ava
pt = open(os.path.join(root, r"game\isla-ancestral\locales\pt.po"), "rb").read()
print("pt sha256:", hashlib.sha256(pt).hexdigest().upper()[:16], "| size:", len(pt))
