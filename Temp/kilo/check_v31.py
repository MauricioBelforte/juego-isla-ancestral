# -*- coding: utf-8 -*-
"""check_v31.py — verificacion mecanica de los entregables de la vuelta 31 (20:00Z)."""
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
verificar("doc padre: §23 presente", "## 23. Vuelta 31" in t)
verificar("doc padre: §23 acuse 341", "ACUSE de mi 340/v30" in t)
verificar("doc padre: §23 merchandising touch sin diff", "re-save/touch SIN cambio de contenido" in t and "merchandising.json" in t)
verificar("doc padre: §23 detector 5ª hora", "INVARIANTES 5ª hora" in t)
verificar("doc padre: §23 numeracion 342/2279", "342" in t and "2279" in t and "cabeza **343**" in t)

b = leer(backlog)
verificar("backlog: ESTADO v31", "VUELTA 31 CIERRE" in b)
verificar("backlog: v31 ANTES de v30", b.find("VUELTA 31 CIERRE") < b.find("VUELTA 30 CIERRE"))
verificar("backlog: v31 mini-stale aceptado", "saneo próximo (mi reporte v30 aceptado por la directora)" in b)

msgs = glob.glob(os.path.join(RAIZ, "Mensajes entre modelos/Ling-3.1-Flash/342-*.md"))
verificar("msg 342: existe (exactamente 1)", len(msgs) == 1, str(msgs))
if msgs:
    m = leer(msgs[0])
    verificar("msg 342: <4KiB", len(m.encode("utf-8")) < 4096, "%d bytes" % len(m.encode("utf-8")))
    verificar("msg 342: campos obligatorios", all(k in m for k in ("**Modelo:**", "**Plataforma:**", "**Fecha:**", "**Responde a:**")))
    verificar("msg 342: responde a 341", "341-2026-10-31_08-15-00" in m)
    verificar("msg 342: firma Ling", "Ling-3.1-Flash" in m)

logs = glob.glob(os.path.join(RAIZ, "Logs/2279-*.md"))
verificar("Log 2279: existe (exactamente 1)", len(logs) == 1, str(logs))
if logs:
    l = leer(logs[0])
    verificar("Log 2279: header", l.startswith("# Log 2279:"))
    verificar("Log 2279: campos §6.2", all(k in l for k in ("**Fecha:**", "**Hora:**", "**Modelo:**", "**Plataforma:**", "## Resumen", "## Cambios Realizados", "## Archivos Modificados/Creados")))

for ruta in [padre, backlog] + msgs + logs:
    verificar("UTF-8/LF: %s" % os.path.basename(ruta), sin_bom_crlf(ruta))

pool_canal = leer(os.path.join(RAIZ, "Mensajes entre modelos/Ling-3.1-Flash/NUMEROS_DISPONIBLES.txt")).splitlines()
pool_logs = leer(os.path.join(RAIZ, "Logs/NUMEROS_DISPONIBLES.txt")).splitlines()
verificar("pool canal: cabeza 343", pool_canal[0] == "343", pool_canal[0])
verificar("pool Logs: cabeza 2280", pool_logs[0] == "2280", pool_logs[0])
verificar("pools: 342/2279 consumidos", "342" not in pool_canal and "2279" not in pool_logs)

det = leer(os.path.join(RAIZ, "Temp/kilo/v31_detector_delta.txt"))
linea_json = next((ln for ln in det.splitlines() if ln.startswith("JSON:")), "")
if linea_json:
    d = json.loads(linea_json[5:])
    inv = (d["checklists"] == 168 and d["items_x"] == 23003 and d["A1"] == 29 and d["A2"] == 242
           and d["A3"] == 4 and d["C2"] == 554 and d["R4"] == 239 and d["SOS"] == 313
           and d["FP"] == 4 and d["formula_ok"] == 80 and d["gris_diseno"] == 209
           and d["promovidos_vecinos"] == 2 and d["A1_R4_cruce"] == 0)
    verificar("detector v31: INVARIANTES", inv, json.dumps({k: d[k] for k in ("checklists", "items_x", "A1", "A2", "A3", "C2", "R4", "SOS", "FP", "formula_ok", "gris_diseno", "promovidos_vecinos", "A1_R4_cruce")}))
else:
    verificar("detector v31: linea JSON", False)

val = leer(os.path.join(RAIZ, "Temp/kilo/v31_validador_i18n.txt"))
verificar("validador i18n: LIMPIO 170x3", "LIMPIO" in val and "[ES] 170 claves" in val and "[PT] 170 claves" in val)
verificar("validador i18n: paridad 0", "0 solo-es, 0 solo-en" in val and "discrepancias: 0" in val)

sonda = leer(os.path.join(RAIZ, "Temp/kilo/v31_sonda_movida.txt"))
verificar("sonda v31: 14 archivos", "archivos game/+scripts/ modificados vs HEAD: 14" in sonda)
verificar("sonda v31: gaps vacios", "gaps es.po: []" in sonda and "gaps pt.po: []" in sonda)
verificar("sonda v31: sha pt canónico", "sha1 pt.po: 95ee2ce0d1 (canonico 95ee2ce0d1)" in sonda)

print("\nRESULTADO:", "ALL OK" if ok else "FALLOS PRESENTES")
