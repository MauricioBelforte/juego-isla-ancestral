# -*- coding: utf-8 -*-
"""Verificacion v26 Ling (PASO 2): encoding UTF-8 sin BOM + LF de los writes de la vuelta,
tamaño msg 335 < 4KiB, consumo de pools (canal cabeza 336 / Logs 2275), existencia de Log 2274.
Sale 0 si todo OK."""
import io, os, glob

d = os.path.dirname(os.path.abspath(__file__))
while d and not os.path.isdir(os.path.join(d, ".git")):
    d = os.path.dirname(d)
ROOT = d

ARCHIVOS = [
    "DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md",
    "DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOG-MASTER.md",
    "Mensajes entre modelos/Ling-3.1-Flash/335-2026-10-31_04-06-00-de-ling-3.1-flash-a-glm-5.3-flash-director-delta-v26-detector-flota-saldo-A1A3.md",
    "Logs/2274-Ling-v26-delta-detector-flota-saldo-A1A3-2026-10-31_04-06-00.md",
    "Temp/kilo/delta_v26.py",
    "Temp/kilo/v26_delta_analysis.txt",
    "Temp/kilo/v26_detector_delta.txt",
]

ok = True
for rel in ARCHIVOS:
    p = os.path.join(ROOT, rel)
    if not os.path.isfile(p):
        print("FALTA: %s" % rel)
        ok = False
        continue
    raw = open(p, "rb").read()
    bom = raw[:3] == b"\xef\xbb\xbf"
    crlf = b"\r\n" in raw
    try:
        raw.decode("utf-8", errors="strict")
        dec = "utf8-ok"
    except UnicodeDecodeError as e:
        dec = "utf8-FAIL:%s" % e
        ok = False
    status = "OK" if (not bom and not crlf and dec == "utf8-ok") else "PROBLEMA"
    if status != "OK":
        ok = False
    print("%-8s bom=%d crlf=%d %s | %s (%d bytes)" % (status, bom, crlf, dec, rel, len(raw)))

msg = ARCHIVOS[2]
sz = os.path.getsize(os.path.join(ROOT, msg))
print("msg335 tamanio=%d bytes (<4096: %s)" % (sz, sz < 4096))
if sz >= 4096:
    ok = False

# pools
canal_pool = io.open(os.path.join(ROOT, "Mensajes entre modelos/Ling-3.1-Flash/NUMEROS_DISPONIBLES.txt"), encoding="utf-8").read().splitlines()
logs_pool = io.open(os.path.join(ROOT, "Logs/NUMEROS_DISPONIBLES.txt"), encoding="utf-8").read().splitlines()
print("pool canal: primeros=%s (esperado 336...)" % canal_pool[:2])
print("pool logs:  primeros=%s (esperado 2275...)" % logs_pool[:2])
if canal_pool[0] != "336" or logs_pool[0] != "2275":
    ok = False
if "335" in canal_pool or "2274" in logs_pool:
    print("ERROR: numero consumido aun en pool")
    ok = False

logs2274 = glob.glob(os.path.join(ROOT, "Logs/2274-*"))
print("Logs/2274-* -> %s" % [os.path.basename(x) for x in logs2274])
if len(logs2274) != 1:
    ok = False

print("RESULTADO:", "TODO OK" if ok else "FALLOS DETECTADOS")
raise SystemExit(0 if ok else 1)
