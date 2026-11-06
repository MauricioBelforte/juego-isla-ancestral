# -*- coding: utf-8 -*-
"""check_v30.py — verificacion mecanica de los entregables de la vuelta 30 (08:00Z)."""
import glob
import io
import json
import os

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
ok = True


def verificar(nombre, cond, detalle=""):
    global ok
    if not cond:
        ok = False
    print("[%s] %s %s" % ("OK" if cond else "FALLO", nombre, detalle))


def leer(ruta):
    return io.open(ruta, encoding="utf-8").read()


def sin_bom_crlf(ruta):
    crudo = open(ruta, "rb").read()
    return (not crudo.startswith(b"\xef\xbb\xbf")) and (b"\r\n" not in crudo)


padre = os.path.join(RAIZ, "DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md")
backlog = os.path.join(RAIZ, "DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOG-MASTER.md")

t = leer(padre)
verificar("doc padre: §22 presente", "## 22. Vuelta 30" in t)
verificar("doc padre: §22 acuse 339", "ACUSE oficial de mi 338" in t)
verificar("doc padre: §22 watchdog LIMPIO", "EXIT 0" in t and "170/170/170" in t)
verificar("doc padre: §22 detector 4ª hora", "INVARIANTES 4ª hora" in t)
verificar("doc padre: §22 mini-stale CHECKS_MINIMOS", "CHECKS_MINIMOS=4" in t and "bug152_go_aplicar" in t)
verificar("doc padre: §22 numeracion 340/2278", "340" in t and "2278" in t and "cabeza **341**" in t)

b = leer(backlog)
verificar("backlog: ESTADO v30", "VUELTA 30 CIERRE" in b)
verificar("backlog: v30 ANTES de v29", b.find("VUELTA 30 CIERRE") < b.find("VUELTA 29 CIERRE"))
verificar("backlog: v30 watchdog propio", "WATCHDOG i18n PROPIO" in b and "170/170/170" in b)
verificar("backlog: v30 mini-stale", "CHECKS_MINIMOS=4 vs disco 6" in b)

msgs = glob.glob(os.path.join(RAIZ, "Mensajes entre modelos/Ling-3.1-Flash/340-*.md"))
verificar("msg 340: existe (exactamente 1)", len(msgs) == 1, str(msgs))
if msgs:
    m = leer(msgs[0])
    verificar("msg 340: <4KiB", len(m.encode("utf-8")) < 4096, "%d bytes" % len(m.encode("utf-8")))
    verificar("msg 340: campos obligatorios", all(k in m for k in ("**Modelo:**", "**Plataforma:**", "**Fecha:**", "**Responde a:**")))
    verificar("msg 340: responde a 339", "339-2026-10-31_07-20-00" in m)
    verificar("msg 340: firma Ling", "Ling-3.1-Flash" in m)

logs = glob.glob(os.path.join(RAIZ, "Logs/2278-*.md"))
verificar("Log 2278: existe (exactamente 1)", len(logs) == 1, str(logs))
if logs:
    l = leer(logs[0])
    verificar("Log 2278: header", l.startswith("# Log 2278:"))
    verificar("Log 2278: campos §6.2", all(k in l for k in ("**Fecha:**", "**Hora:**", "**Modelo:**", "**Plataforma:**", "## Resumen", "## Cambios Realizados", "## Archivos Modificados/Creados")))

for ruta in [padre, backlog] + msgs + logs:
    verificar("UTF-8/LF: %s" % os.path.basename(ruta), sin_bom_crlf(ruta))

pool_canal = leer(os.path.join(RAIZ, "Mensajes entre modelos/Ling-3.1-Flash/NUMEROS_DISPONIBLES.txt")).splitlines()
pool_logs = leer(os.path.join(RAIZ, "Logs/NUMEROS_DISPONIBLES.txt")).splitlines()
verificar("pool canal: cabeza 341", pool_canal[0] == "341", pool_canal[0])
verificar("pool Logs: cabeza 2279", pool_logs[0] == "2279", pool_logs[0])
verificar("pools: 340/2278 consumidos", "340" not in pool_canal and "2278" not in pool_logs)

det = leer(os.path.join(RAIZ, "Temp/kilo/v30_detector_delta.txt"))
linea_json = next((ln for ln in det.splitlines() if ln.startswith("JSON:")), "")
if linea_json:
    d = json.loads(linea_json[5:])
    inv = (d["checklists"] == 168 and d["items_x"] == 23003 and d["A1"] == 29 and d["A2"] == 242
           and d["A3"] == 4 and d["C2"] == 554 and d["R4"] == 239 and d["SOS"] == 313
           and d["FP"] == 4 and d["formula_ok"] == 80 and d["gris_diseno"] == 209
           and d["promovidos_vecinos"] == 2 and d["A1_R4_cruce"] == 0)
    verificar("detector v30: INVARIANTES", inv, json.dumps({k: d[k] for k in ("checklists", "items_x", "A1", "A2", "A3", "C2", "R4", "SOS", "FP", "formula_ok", "gris_diseno", "promovidos_vecinos", "A1_R4_cruce")}))
else:
    verificar("detector v30: linea JSON", False)

val = leer(os.path.join(RAIZ, "Temp/kilo/v30_validador_i18n.txt"))
verificar("validador i18n: LIMPIO 170x3", "LIMPIO" in val and "[ES] 170 claves" in val and "[PT] 170 claves" in val)
verificar("validador i18n: paridad 0", "0 solo-es, 0 solo-en" in val and "discrepancias: 0" in val)

sonda = leer(os.path.join(RAIZ, "Temp/kilo/v30_sonda_movida.txt"))
verificar("sonda v30: 14 archivos", "archivos game/+scripts/ modificados vs HEAD: 14" in sonda)
verificar("sonda v30: gaps vacios", "gaps es.po: []" in sonda and "gaps pt.po: []" in sonda)
verificar("sonda v30: sha pt canónico", "sha1 pt.po: 95ee2ce0d1 (canonico 95ee2ce0d1)" in sonda)

print("\nRESULTADO:", "ALL OK" if ok else "FALLOS PRESENTES")
