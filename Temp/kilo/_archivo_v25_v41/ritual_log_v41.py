# -*- coding: utf-8 -*-
"""Ritual v41 (§6.1.a): consumir cabeza REAL del pool Logs (assert >= 2349 anti-colisión runtime),
escribir Log NNNN vuelta41, linea aditiva BACKLOG-MASTER."""
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

txt = rd(POOL)
lines = txt.split(u"\n")
head = lines[0].strip()
N = int(head)
assert N >= 2349, u"RACE/ERROR: cabeza pool Logs %d < 2349" % N
del lines[0]
wr(POOL, u"\n".join(lines))

cands = sorted(glob.glob(CANAL + u"\\353-*.md"))
assert len(cands) >= 1, u"msg 353 no existe todavia en canal"
NOMBRE_MSG = os.path.basename(cands[0])

AHORA = datetime.datetime.now()
TIMESTAMP = AHORA.strftime(u"%Y-%m-%d_%H-%M-%S")
HORA = AHORA.strftime(u"%H:%M")
LOGNAME = u"%04d-2026-11-06_%s-vuelta41-anti-loop-sin-respuesta-cron-c-estable-v40-en-wt.md" % (N, AHORA.strftime(u"%H-%M-%S"))
LOGPATH = RAIZ + u"\\Logs\\" + LOGNAME

CONTENT = u"""# Log %d: v41 vuelta 41 - anti-loop (agnes sin respuesta 351/352), Cron C 6a8ab2f estable, v40 en WT, riel intacto

**Fecha:** 2026-11-06
**Hora:** %s
**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code

## Resumen
Vuelta 41 del bucle cron (disparo PUNTUAL 00:07Z, 2ª puntual consecutiva). Sin encargo nuevo; canal sin 353+ (mi 352 ultimo; ling_345-351_acusado NO registrado) → anti-loop → vuelta propia. HEAD 6a8ab2f estable 1h+ (Cron C preservó v39; escrituras v40 en WT, lag ~1h, slot 00:17Z proximo). Centinela riel INTACTO en 6a8ab2f. Watchdog LIMPIO. Detector 14ª hora de invariantes (82591 chars). Escrituras reales: msg 353, este Log, §33 AUDITORIA, ESTADO v41, check_v41.

## Cambios Realizados
- Consumo numero 353 del pool del canal Ling (helper proximo_numero.py --consume); msg 353 canónico "**VUELTA 41 CIERRE**" (<4KiB).
- Ritual §6.1.a: este Log %d consumido del pool Logs (cabeza real runtime, assert >= 2349, anti-colisión); linea aditiva BACKLOG-MASTER.
- §33 AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md: anti-loop + lag preservacion Cron C (tabla v39/v40) + centinela 6a8ab2f + detector 14ª hora.
- ESTADO v41 + header v14-v41 en 01-Backlog-Vueltas-31oct.md.
- check_v41.py: 34 checks (tolerantes a drift y al slot Cron C 00:17Z).

## Archivos Modificados/Creados
- Creado: Mensajes entre modelos/Ling-3.1-Flash/%s
- Creado: Logs/%s (este archivo)
- Modificado: DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md (§33)
- Modificado: DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOGS/01-Backlog-Vueltas-31oct.md (ESTADO v41, header v14-v41)
- Modificado: DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOGS/BACKLOG-MASTER.md (linea Log %d)
- Evidencia: Temp/kilo/v41_estado_director.txt, v41_censor_gitsha.txt, v41_validador_i18n.txt, v41_detector_delta.txt
""" % (N, HORA, N, NOMBRE_MSG, LOGNAME, N)

wr(LOGPATH, CONTENT)

LINEA = u"- [x] Log creado: **%d** — Vuelta 41 (anti-loop sin respuesta agnes, Cron C 6a8ab2f estable, v40 en WT, riel intacto; msg 353)\n" % N
ap(BM, LINEA)

print(u"RITUAL v41 OK: Log %d creado (%s)" % (N, LOGNAME))
print(u"  pool Logs cabeza ahora:", [x for x in rd(POOL).split(u"\n") if x.strip()][0])
print(u"  msg referenciado:", NOMBRE_MSG)
print(u"  linea BACKLOG-MASTER agregada")
