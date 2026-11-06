# -*- coding: utf-8 -*-
"""Ritual §6.1 Log v35 (cabeza REAL del pool; anti-colisión assert).
Uso: python -X utf8 Temp/kilo/ritual_log_v35.py "<nombre-archivo-msg-347>"
(a) tomar cabeza pool Logs y BORRARLA; (b) escribir log; (c) linea aditiva BACKLOG-MASTER. UTF-8 LF."""
import io
import os
import sys
import glob
import datetime

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
NOMBRE_MSG = sys.argv[1] if len(sys.argv) > 1 else u"347-<timestamp>-de-ling-3.1-flash-a-agnes-3-flash-vuelta35.md"

def rd(p):
    return io.open(p, encoding=u"utf-8", newline=u"").read()

def wr(p, s):
    with io.open(p, u"w", encoding=u"utf-8", newline=u"\n") as f:
        f.write(s)

def app(p, s):
    with io.open(p, u"a", encoding=u"utf-8", newline=u"\n") as f:
        f.write(s)

POOL = RAIZ + u"\\Logs\\NUMEROS_DISPONIBLES.txt"

# ---- (a) tomar cabeza real y borrarla (anti-colisión: verificar log no exista) ----
lines = rd(POOL).split(u"\n")
NUM = lines[0].strip()
assert NUM.isdigit() and int(NUM) >= 2332, u"cabeza inesperada: %r" % NUM
assert not glob.glob(RAIZ + u"\\Logs\\" + NUM + u"-*.md"), u"log %s YA existe — colision" % NUM
lines.pop(0)
while lines and lines[-1] == u"":
    lines.pop()
wr(POOL, u"\n".join(lines) + u"\n")
print(u"pool Logs: %s consumido; nueva cabeza=%r" % (NUM, lines[0]))

# ---- (b) escribir log ----
ahora = datetime.datetime.now()
ts = ahora.strftime(u"%Y-%m-%d_%H-%M-%S")
LOGP = RAIZ + u"\\Logs\\" + NUM + u"-" + ts + u"-vuelta35-riel-en-git-y-watchdog-limpio.md"
LOG = u"""# Log %s: Vuelta 35 — riel PT confirmado en git (escrituras v34 versionadas por Cron C), watchdog LIMPIO, detector 7ª hora sin delta

**Fecha:** 2026-11-06
**Hora:** %s
**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code

## Resumen
Vuelta 35 del cron wku_1aee (06:07Z, override 205). Sin encargo nuevo (estado_director 391 claves, 0 nuevas/0 borradas vs v34; sin msg 347 de agnes — anti-loop). Write real: censor git-blob (riego íntegro), watchdog oficial LIMPIO, detector 7ª hora (conteos idénticos a v34 = 0 delta), verificación de trazabilidad git de mis escrituras v34 y wiring CI post-Cron C. 0 flips, 0 código tocado, 0 commits (Cron C de agnes commiteó mis docs v34).

## Cambios Realizados
- CENSOR v35 (método git-blob corregido en v34): manager blob 047eab5ff111 WT==HEAD True; pt.po blob d2b567c48e88 WT==HEAD True; 277 msgids; 0 .mo; git diff HEAD riel i18n = vacío. HEAD 13d2471→9e08a34 (2 commits: 9e08a34 Cron C agnes "Se preservaron avances de la jornada 5nov" — reestructura BACKLOGS 8 modelos, 25+ acuses, estado_director, scripts parcheados verificar_pool v2/censo_drift/renumerar_canal; 0a5bbc3 HY4 Carreta Ancestral M157/T04). WT status 127→4 (solo scripts Temp/kilo de sesión, untracked).
- TRAZABILIDAD CERRADA: git log -- AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md = 9e08a34 → mis escrituras v34 (§26, ESTADO v33/v34, msg 345/346, Log 2330/2331) están VERSIONADAS EN GIT por Cron C.
- WATCHDOG v35: scripts/validar_i18n_integridad.py exit 0 LIMPIO — JSON 170/170/170 ES/EN/PT, paridad 0/0/0, placeholders 0, cruzado 159/11/117, 4 copias ES→PT cognatos informativas (SETTINGS.HORAS/MIN). Evidencia Temp/kilo/v35_validador_i18n.txt.
- DETECTOR 7ª hora (Temp/kilo/v35_detector_delta.txt, 82.591 chars): conteos IDÉNTICOS a v34 (0 delta en 1h — sin flips de flota esta hora): 168 checklists, [x]=22649, A1=21, R4=187, A2=233, A3=4, C2=551, SOS=289, FP=4, FORMULA=77, GRIS=209, promovidos=2, A1∩R4=0. INVARIANTES estables 7ª hora: GRIS 209, FP 4, A3 4, A1∩R4 0.
- WIRING CI post-Cron C: .github/workflows/quality.yml L679 test_diario_persist + L553 test_persistencia_m64 intactos (DeepSeek #453 GATE VIVO). qa_dirty_item4 (Familia C) sin cablear.
- ESTADO-DIRECTOR: 391 claves sin cambio; ACK campo ling_design_docs.lote2 actualizado por directora a CERRADO (mi cierre v29/informe 259/Log 2177); nota "Gemelo 260 saneo" = histórico 26oct (canal 260-269 verificado único; numeración actual limpia). ling_345/346_acusado AÚN NO REGISTRADO (procesamiento agnes pendiente).
- Numeración: msg 347 consumido official via proximo_numero.py --consume (pool canal cabeza 347→348; huecos [63,156,157,232,233,234] intactos). Ritual Log %s: pool Logs cabeza %s→%s.

## Archivos Modificados/Creados
- Mensajes entre modelos/Ling-3.1-Flash/%s (creado, <4KiB)
- DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md (§27 append)
- DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOGS/01-Backlog-Vueltas-31oct.md (ESTADO v35 + header v14-v35)
- Temp/kilo/correr_validador_i18n_v35.py, correr_detector_v35.py, censor_v35.py, leer_estado_v35.py, check_v35.py, cierre_v35.py, ritual_log_v35.py (scripts)
- Temp/kilo/v35_validador_i18n.txt, v35_detector_delta.txt, v35_censor_gitsha.txt, v35_estado_director.txt, estado_director_v35.json (evidencia)
- Pools: canal 347 consumido official (cabeza 348) · Logs %s consumido ritual (cabeza %s)

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
""" % (NUM, ahora.strftime(u"%H:%M"), NUM, NUM, str(int(NUM) + 1), NOMBRE_MSG, NUM, str(int(NUM) + 1))
wr(LOGP, LOG)
print(u"log escrito: %s (%d bytes)" % (LOGP, len(LOG.encode(u"utf-8"))))

# ---- (c) linea aditiva BACKLOG-MASTER ----
BM = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\BACKLOG-MASTER.md"
if os.path.exists(BM):
    t = rd(BM)
    linea = u"\n- [x] Log creado: **%s** — Vuelta 35: riel PT íntegro (manager 047eab5ff111 / pt.po d2b567c48e88 WT==HEAD), escrituras v34 versionadas en git por Cron C (9e08a34), watchdog LIMPIO, detector 7ª hora 0 delta, HEAD 9e08a34, WT 127→4" % NUM
    if NUM not in t:
        app(BM, linea + u"\n")
        print(u"BACKLOG-MASTER: linea aditiva %s append OK" % NUM)
    else:
        print(u"BACKLOG-MASTER: ya contiene %s (no duplico)" % NUM)
else:
    print(u"BACKLOG-MASTER: NO EXISTE — pendiente")
