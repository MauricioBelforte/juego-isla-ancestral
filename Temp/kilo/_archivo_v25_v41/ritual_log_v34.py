# -*- coding: utf-8 -*-
"""Ritual §6.1 Log v34 (cabeza REAL del pool; anti-colisión assert).
Uso: python -X utf8 Temp/kilo/ritual_log_v34.py "<nombre-archivo-msg-346>"
(a) tomar cabeza pool Logs y BORRARLA; (b) escribir log; (c) linea aditiva BACKLOG-MASTER. UTF-8 LF."""
import io
import os
import sys
import glob
import datetime

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
NOMBRE_MSG = sys.argv[1] if len(sys.argv) > 1 else u"346-<timestamp>-de-ling-3.1-flash-a-agnes-3-flash-vuelta34.md"

def rd(p):
    return io.open(p, encoding=u"utf-8", newline=u"").read()

def wr(p, s):
    with io.open(p, u"w", encoding=u"utf-8", newline=u"\n") as f:
        f.write(s)

def app(p, s):
    with io.open(p, u"a", encoding=u"utf-8", newline=u"\n") as f:
        f.write(s)

POOL = RAIZ + u"\\Logs\\NUMEROS_DISPONIBLES.txt"

# ---- (a) número YA consumido del pool en intento 1 (2331; pool cabeza ahora 2332) ----
lines = rd(POOL).split(u"\n")
NUM = u"2331"
assert u"2331" not in lines, u"2331 sigue en el pool — el consumo del intento 1 no ocurrió"
assert not glob.glob(RAIZ + u"\\Logs\\" + NUM + u"-*.md"), u"log %s YA existe — colision" % NUM
print(u"pool Logs: 2331 ya consumido (intento 1); cabeza actual=%r" % (lines[0] if lines else u""))

# ---- (b) escribir log ----
ahora = datetime.datetime.now()
ts = ahora.strftime(u"%Y-%m-%d_%H-%M-%S")
LOGP = RAIZ + u"\\Logs\\" + NUM + u"-" + ts + u"-vuelta34-centinela-corregido-y-riel-vivo.md"
LOG = u"""# Log %s: Vuelta 34 — centinela corregido a git-blob-sha (alarma falsa resuelta), riel PT íntegro, watchdog LIMPIO

**Fecha:** 2026-11-06
**Hora:** %s
**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code

## Resumen
Vuelta 34 del cron wku_1aee (cierre 05:07Z, override 205 del fundador). Sin encargo nuevo del director (estado_director 391 claves sin cambio). Write real: investigué una alarma de mi propio centinela SHA (manager BFDC83CC89 vs 047eab5ff111) y resultó FALSO POSITIVO metodológico (sha1-crudo vs git-blob-sha); corregí el centinela a método git canónico y confirmé el riel PT íntegro. Watchdog oficial LIMPIO, detector 6ª hora, wiring CI verificado, HEAD nuevo = commits Blender HY4. 0 flips, 0 código tocado, 0 commits.

## Cambios Realizados
- CENTINELA CORREGIDO: censor v34 inicial (hashlib sha1-crudo) reportó manager BFDC83CC89 ≠ 047eab5ff111 (v32) → alarma "alguien tocó mi riel". Verificación git: hash-object WT = 047eab5ff111 == rev-parse HEAD:manager → INTACTO desde 071a2f9 (28oct); git diff HEAD riel i18n = VACÍO. Causa: comparé sha1-crudo contra git-blob-sha (algoritmos distintos). Centinela corregido usa git hash-object/rev-parse (Temp/kilo/censor_v34_gitsha.py + v34_censor_gitsha.txt). pt.po blob d2b567c48e88 WT==HEAD True (crudo 6E5C19683F; 277 msgids; 0 .mo). Lección documentada: fingerprint git = método git canónico.
- HEAD 0d750af → 13d2471 = 4 commits Blender HY4 (T-01a Barquita / T-01b Globo / T-01c Perla / T-01d Gran Vapor; M67/M68; 3 GLB + cierre administrativo c/u). Nada toca i18n. WT status = 127 archivos (estable vs v33); 19.982 trackeados.
- WIRING CI (I-09 actualizado): .github/workflows/quality.yml L679 cablea scripts/diario/test_diario_persist.gd (DeepSeek #453, GATE VIVO) + L553 test_persistencia_m64. qa_dirty_item4 (suite muerta Familia C) SIN cablear (coherente con I-09 v33). Validación i18n NO en CI por diseño (herramienta de agente).
- WATCHDOG I18N: scripts/validar_i18n_integridad.py = LIMPIO (JSON 170/170/170 ES/EN/PT; paridad 0/0/0; placeholders 0; cruzado 159/11/117; 4 copias ES→PT informativas SETTINGS.HORAS_1/H, MIN_1/M cognatos). Evidencia Temp/kilo/v34_validador_i18n.txt.
- DETECTOR v8.1 6ª hora (Temp/kilo/v34_detector_delta.txt, 82.591 chars): 168 checklists; [x]=22649 (v29: 23003; −354 degradaciones legítimas flota/re-baselines); A1=21 (v29: 29); R4=187 (v29: 239); A2=233; A3=4; C2=551; SOS=289; FP=4; FORMULA=77; GRIS=209; promovidos=2; A1∩R4=0. INVARIANTES estables: GRIS 209, FP 4, A3 4, A1∩R4 0.
- ESTADO-DIRECTOR: 391 claves SIN CAMBIO (snapshot Temp/kilo/estado_director_v34.json). 2 campos STALE míos reportados para update: ling_design_docs.lote2_asignado (CERRADO desde v29: informe 259, Log 2177; evidencia 03-Backlog-Anexos-PT L656-660) y ling_rielp_pt_intacto (cita 547d1f6/95ee/275 obsoleta → hoy HEAD 13d2471, pt.po blob d2b567c48e88, 277 msgids). bug_156 sigue DeepSeek #491 (mi riel no afectado). M85 re-baseline 73/25/2 por directora: ack.
- Numeración: msg 346 consumido official via proximo_numero.py --consume (pool canal cabeza 346→347; huecos históricos [63,156,157,232,233,234] intactos). Ritual Log %s: pool Logs cabeza %s→%s.

## Archivos Modificados/Creados
- Mensajes entre modelos/Ling-3.1-Flash/%s (creado, <4KiB)
- DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md (§26 append)
- DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOGS/01-Backlog-Vueltas-31oct.md (ESTADO v34 + header v14-v34)
- Temp/kilo/correr_validador_i18n_v34.py, correr_detector_v34.py, censor_v34_gitsha.py (scripts)
- Temp/kilo/v34_validador_i18n.txt, v34_detector_delta.txt, v34_censor_gitsha.txt (evidencia)
- Pools: canal 346 consumido official (cabeza 347) · Logs %s consumido ritual (cabeza %s)

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
""" % (NUM, ahora.strftime(u"%H:%M"), NUM, NUM, str(int(NUM) + 1), NOMBRE_MSG, NUM, str(int(NUM) + 1))
wr(LOGP, LOG)
print(u"log escrito: %s (%d bytes)" % (LOGP, len(LOG.encode(u"utf-8"))))

# ---- (c) linea aditiva BACKLOG-MASTER ----
BM = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\BACKLOG-MASTER.md"
if os.path.exists(BM):
    t = rd(BM)
    linea = u"\n- [x] Log creado: **%s** — Vuelta 34: centinela corregido a git-blob-sha (alarma falsa manager resuelta), riel PT íntegro (manager 047eab5ff111 / pt.po d2b567c48e88 WT==HEAD), watchdog i18n LIMPIO, wiring CI quality.yml L679 verificado, detector 6ª hora invariantes estables" % NUM
    if NUM not in t:
        app(BM, linea + u"\n")
        print(u"BACKLOG-MASTER: linea aditiva %s append OK" % NUM)
    else:
        print(u"BACKLOG-MASTER: ya contiene %s (no duplico)" % NUM)
else:
    print(u"BACKLOG-MASTER: NO EXISTE — pendiente")
