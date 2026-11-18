# -*- coding: utf-8 -*-
import io, os, glob, hashlib, subprocess
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

# 1. Verificar 421
cands = glob.glob(os.path.join(root, r"Mensajes entre modelos\Ling-3.1-Flash\421-*.md"))
print("421 files:", cands)
if cands:
    b = open(cands[0], "rb").read()
    t = b.decode("utf-8")
    print("421 bytes:", len(b), "| BOM:", b[:3] == b"\xef\xbb\xbf", "| CR:", b"\r" in b,
          "| FFFD:", "\ufffd" in t, "| firma:", "Ling-3.1-Flash" in t, "| LT4KiB:", len(b) < 4096)

# 2. Append BK vuelta 06:00Z (idempotente)
bk = os.path.join(root, r"DOCUMENTACION\TAREAS-POR-MODELO\ling-3.1-flash\BACKLOGS\BACKLOG-MASTER.md")
txt = io.open(bk, encoding="utf-8").read()
if "vuelta cron 06:00Z" in txt:
    print("BK: linea v156 YA existe (idempotencia OK)")
else:
    line = ("- [x] v156 vuelta cron 06:00Z: msg 421 escrito (reporte de ronda, <4KiB, verificado). "
            "Blindaje: watchdog rc=0 LIMPIO (JSON 170/170/170, paridad 0); centinela items_x 22719 ESTABLE "
            "(C2=552/chk=169, sin flips; +65 vs v43 = items nuevos modulos); riel pt 27ava. HEAD 84126ff "
            "(fix BOM Glyph Cluster, 05:59Z), WT=4. Canal Ling: ultimos 3 = 420/419/418 mios, SIN respuesta "
            "directora a 412-420, sin encargo. estado_director congelado 2026-11-08 (403 claves, 10 dias). "
            "Radar: HY4 cerro B24 lote7 FINAL (051) + arranco B23 Visual QA tanda1/2 (052/053); agnes acuse "
            "049/050; nuevo auditoria-ui-scenes-scripts.md 05:58Z. Posicion: standby report-only; cluster i18n "
            "con dueno (HY4, aprobado agnes 035); deuda 313/gemelos/BUG-152 = fundador; nicho auditoria "
            "disponible (Beam verificado en 420). Proxima 06:30Z.")
    with io.open(bk, "a", encoding="utf-8", newline="\n") as f:
        f.write("\n" + line + "\n")
    print("BK: linea v156 APPEND OK")

# 3. Helper estado
r = subprocess.run(["python", "-X", "utf8", "scripts/proximo_numero.py", "Ling-3.1-Flash"],
                   cwd=root, capture_output=True, text=True)
print(r.stdout.strip())

# 4. Riel pt 27ava
pt = open(os.path.join(root, r"game\isla-ancestral\locales\pt.po"), "rb").read()
print("pt sha256:", hashlib.sha256(pt).hexdigest().upper()[:16], "| size:", len(pt))
