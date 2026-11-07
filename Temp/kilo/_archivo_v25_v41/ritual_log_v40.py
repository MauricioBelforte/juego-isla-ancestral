# -*- coding: utf-8 -*-
"""Ritual v40 (metodologia §6.1.a): consumir cabeza REAL del pool Logs, escribir Log NNNN vuelta40,
agregar linea aditiva en BACKLOG-MASTER. Anti-colisión: assert cabeza >= 2347; N descubierto en runtime."""
import io
import os
import glob
import datetime

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
CANAL = RAIZ + u"\\Mensajes entre modelos\\Ling-3.1-Flash"
POOL = RAIZ + u"\\Logs\\NUMEROS_DISPONIBLES.txt"
BM = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\BACKLOG-MASTER.md"

def rd(p):
    return io.open(p, encoding=u"utf-8", errors=u"replace").read()

def wr(p, s):
    with io.open(p, u"w", encoding=u"utf-8", newline=u"\n") as f:
        f.write(s)

def ap(p, s):
    with io.open(p, u"a", encoding=u"utf-8", newline=u"\n") as f:
        f.write(s)

# 1. cabeza real del pool
txt = rd(POOL)
lines = txt.split(u"\n")
head = lines[0].strip()
N = int(head)
assert N >= 2347, u"RACE/ERROR: cabeza pool Logs %d < 2347" % N
del lines[0]
wr(POOL, u"\n".join(lines))

# 2. descubrir nombre del msg 352 (canal)
cands = sorted(glob.glob(CANAL + u"\\352-*.md"))
assert len(cands) >= 1, u"msg 352 no existe todavia en canal"
NOMBRE_MSG = os.path.basename(cands[0])

# 3. timestamp y nombre del log
AHORA = datetime.datetime.now()
TIMESTAMP = AHORA.strftime(u"%Y-%m-%d_%H-%M-%S")
HORA = AHORA.strftime(u"%H:%M")
LOGNAME = u"%04d-2026-11-06_%s-vuelta40-dormancia-crons-confirmada-flotas-activas-riel-intacto.md" % (N, AHORA.strftime(u"%H-%M-%S"))
LOGPATH = RAIZ + u"\\Logs\\" + LOGNAME

CONTENT = u"""# Log %d: v40 vuelta 40 - dormancia crons confirmada por directora, flota activa, riel intacto

**Fecha:** 2026-11-06
**Hora:** %s
**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code

## Resumen
Vuelta 40 del bucle cron (disparo PUNTUAL 23:07Z, sesion viva). Sin encargo nuevo; canal sin 352 (anti-loop -> vuelta propia). La directora CONFIRMO OFICIALMENTE en estado_director (391->397 claves, +6 nuevas) la dormancia de crons del 6nov 22:05 y la reactivacion de la flota (Ling reactivado; Step-5 fuera; Nemotron desbloqueado). Centinela riel INTACTO en HEAD 4091de8. Watchdog LIMPIO. Detector 13ª hora de invariantes (82591 chars). Escrituras reales: msg 352, este Log, §32 AUDITORIA, ESTADO v40, check_v40.

## Cambios Realizados
- Consumo numero 352 del pool del canal Ling (helper proximo_numero.py --consume); msg 352 canónico "**VUELTA 40 CIERRE**" (<4KiB).
- Ritual §6.1.a: este Log %d consumido del pool Logs (cabeza real, assert >= 2347, anti-colisión); linea aditiva en BACKLOG-MASTER.
- §32 AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md: confirmacion dormancia (6 claves textuales), centinela 4091de8, flota activa (Hy3 494/495 + Log 2346, Nemotron 273, DS-OC 249, HY4-30), Cron C pendiente de preservar v39-v40.
- ESTADO v40 + header v14-v40 en 01-Backlog-Vueltas-31oct.md.
- check_v40.py: 29 checks (tolerantes a drift de flota activa).

## Archivos Modificados/Creados
- Creado: Mensajes entre modelos/Ling-3.1-Flash/%s
- Creado: Logs/%s (este archivo)
- Modificado: DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md (§32)
- Modificado: DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOGS/01-Backlog-Vueltas-31oct.md (ESTADO v40, header v14-v40)
- Modificado: DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOGS/BACKLOG-MASTER.md (linea Log %d)
- Evidencia: Temp/kilo/v40_estado_director.txt, v40_censor_gitsha.txt, v40_validador_i18n.txt, v40_detector_delta.txt
""" % (N, HORA, N, NOMBRE_MSG, LOGNAME, N)

wr(LOGPATH, CONTENT)

# 4. linea aditiva BACKLOG-MASTER
LINEA = u"- [x] Log creado: **%d** — Vuelta 40 (dormancia crons confirmada por directora, flota activa, riel intacto; msg 352)\n" % N
ap(BM, LINEA)

print(u"RITUAL v40 OK: Log %d creado (%s)" % (N, LOGNAME))
print(u"  pool Logs cabeza ahora:", [x for x in rd(POOL).split(u"\n") if x.strip()][0])
print(u"  msg referenciado:", NOMBRE_MSG)
print(u"  linea BACKLOG-MASTER agregada")
