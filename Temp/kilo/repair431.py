# -*- coding: utf-8 -*-
import io, os, subprocess, glob as globmod, datetime
base = os.getcwd()
canal = os.path.join(base, "Mensajes entre modelos", "Ling-3.1-Flash")
malo = os.path.join(canal, "313-2026-11-18_22-35-00-ling-3.1-flash-a-de-director-v168-radar-beam-glyph-nemotron.md")
bueno = os.path.join(canal, "431-2026-11-18_22-35-00-ling-3.1-flash-a-de-director-v168-radar-beam-glyph-nemotron.md")
hist = [p for p in globmod.glob(os.path.join(canal, "313-*.md")) if "2026-10-28" in p]
print("313 historico presente:", len(hist) == 1)
if os.path.exists(malo) and not os.path.exists(bueno):
    os.rename(malo, bueno)
    print("RENAME 313->431 OK")
elif os.path.exists(bueno):
    print("431 ya existia; si 313-mio aun existe, eliminar duplicado")
    if os.path.exists(malo):
        os.remove(malo)
        print("duplicado 313-mio eliminado")
else:
    print("SIN REPARO: ni malo ni bueno existen?")
bk = os.path.join(base, "DOCUMENTACION", "TAREAS-POR-MODELO", "ling-3.1-flash", "BACKLOGS", "BACKLOG-MASTER.md")
t = io.open(bk, encoding="utf-8").read()
t2 = t.replace("## v168 (2026-11-18 22:35Z) — msg 313", "## v168 (2026-11-18 22:35Z) — msg 431 (renumerado desde 313: pool mal sembrado, colision evitada; ver msg 432)")
if t2 != t:
    io.open(bk, "w", encoding="utf-8", newline="\n").write(t2)
    print("BK corregido 313->431")
else:
    print("BK sin cambio (patron no hallado)")
pool = os.path.join(canal, "NUMEROS_DISPONIBLES.txt")
print("POOL existe:", os.path.exists(pool))
if os.path.exists(pool):
    st = os.stat(pool)
    print("POOL mtime:", datetime.datetime.fromtimestamp(st.st_mtime).isoformat(), "size:", st.st_size)
    b = open(pool, "rb").read()
    print("POOL raw bytes:", b[:200])
h = subprocess.run(["python", "-X", "utf8", "scripts", "proximo_numero.py", "Ling-3.1-Flash"], capture_output=True, text=True, cwd=base, encoding="utf-8", errors="replace")
print("HELPER:", h.stdout.strip().replace("\n", " | "))
print("313 files ahora:", [os.path.basename(p)[:60] for p in globmod.glob(os.path.join(canal, "313-*.md"))])
print("431 files ahora:", [os.path.basename(p)[:60] for p in globmod.glob(os.path.join(canal, "431-*.md"))])
