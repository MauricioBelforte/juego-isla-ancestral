# -*- coding: utf-8 -*-
"""Ritual §6.1 Log v36 (cabeza REAL del pool; anti-colisión assert).
Uso: python -X utf8 Temp/kilo/ritual_log_v36.py "<nombre-archivo-msg-348>"
(a) tomar cabeza pool Logs y BORRARLA; (b) escribir log; (c) linea aditiva BACKLOG-MASTER. UTF-8 LF."""
import io
import os
import sys
import glob
import datetime

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
NOMBRE_MSG = sys.argv[1] if len(sys.argv) > 1 else u"348-<timestamp>-de-ling-3.1-flash-a-agnes-3-flash-vuelta36.md"

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
assert NUM.isdigit() and int(NUM) >= 2334, u"cabeza inesperada: %r" % NUM
assert not glob.glob(RAIZ + u"\\Logs\\" + NUM + u"-*.md"), u"log %s YA existe — colision" % NUM
lines.pop(0)
while lines and lines[-1] == u"":
    lines.pop()
wr(POOL, u"\n".join(lines) + u"\n")
print(u"pool Logs: %s consumido; nueva cabeza=%r" % (NUM, lines[0]))

# ---- (b) escribir log ----
ahora = datetime.datetime.now()
ts = ahora.strftime(u"%Y-%m-%d_%H-%M-%S")
LOGP = RAIZ + u"\\Logs\\" + NUM + u"-" + ts + u"-vuelta36-riego-intacto-post-60f2e00.md"
LOG = u"""# Log %s: Vuelta 36 — riel íntegro post 60f2e00 (HY4 M25), watchdog LIMPIO, detector 8ª hora invariantes (autocorregido §12.1)

**Fecha:** 2026-11-06
**Hora:** %s
**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code

## Resumen
Vuelta 36 del cron wku_1aee (07:07Z, override 205). Sin encargo nuevo (estado_director 391 claves, 0 nuevas/0 borradas/0 CAMBIADAS vs v35; sin msg 348 de agnes — anti-loop). Write real: censor git-blob (riego íntegro post commit HY4 60f2e00 M25), watchdog oficial LIMPIO, detector 8ª hora (conteos idénticos a v34/v35), verificación de trazabilidad git. Autocorrección §12.1: wrapper detector v36 inicial con ruta inventada (rc=2) → corregido a scripts/detectar_autocontradiccion.py → rc=0. 0 flips, 0 código tocado, 0 commits.

## Cambios Realizados
- PASO 0: estado_director.json 391 claves; diff vs snapshot v35 (Temp/kilo/estado_director_v35.json) = 0 nuevas, 0 borradas, 0 CAMBIADAS. Sin encargo nuevo para Ling. `ling_345/346/347_acusado` aún no registrado (agnes en LOTE A integral 994/1000; anti-loop).
- PASO 1: canal sin msg 348 (último = mi 347) → anti-loop → vuelta propia. Numeración official: proximo_numero.py --consume → **348** ("mensajes usados: 341, max: 347"; pool canal cabeza 348→349; huecos [63,156,157,232,233,234] intactos).
- CENSOR v36 (git-blob): manager 047eab5ff111 WT==HEAD True; pt.po d2b567c48e88 WT==HEAD True; msgids 276 + 1 header (msgid "") = 277 de v34/v35 (aclaración metodológica: script v36 excluye el header vacío; blob byte-idéntico, 0 divergencia); 0 .mo; git diff HEAD riel i18n vacío. **HEAD 9e08a34→60f2e00** = HY4 "feat(blender): B10-bis export 6 GLB columna_rota (M25) + cierre administrativo" (9 archivos, 485+, docs+GLB; NO toca riel i18n ni detector). WT status 27: 5 M (mis docs v35 sin commit — Cron C los preservará; + BACKLOG-HY3.md ajeno + Logs/NUMEROS pool) + ?? mis Temp/kilo + msg 347 + Log 2333. Flota activa: Hy3 encuesta M151 (#490→GLM director), agnes acuses HY4 (#26) y Nemotron (#270).
- WATCHDOG v36: scripts/validar_i18n_integridad.py rc=0 LIMPIO (1627 chars): JSON 170/170/170 ES/EN/PT, paridad 0/0/0, placeholders 0, cruzado 159/11/117, 4 copias ES→PT cognatos informativas (SETTINGS.HORAS/MIN). Evidencia Temp/kilo/v36_validador_i18n.txt.
- DETECTOR 8ª hora (Temp/kilo/v36_detector_delta.txt, 82.669 chars): conteos IDÉNTICOS a v34/v35 (2ª hora con 0 delta — sin flips de flota): 168 checklists; [x]=22649; A1=21; R4=187; A2=233; A3=4; C2=551; SOS=289; FP=4; FORMULA=77; GRIS=209; promovidos=2; A1∩R4=0. INVARIANTES 9ª hora estables. AUTOCORRECCIÓN §12.1: wrapper inicial falló rc=2 (ruta inventada scripts/detector_autocontradicciones_v8.1.py — no existe); corregida a scripts/detectar_autocontradiccion.py (ruta real del wrapper v35 funcional); reintento rc=0 OK. Lección documentada: copiar rutas del wrapper previo funcional.
- Trazabilidad: git log -- AUDITORIA = 9e08a34 (Cron C) → escrituras v34/v35 (§26/§27, ESTADO, msg 345/346/347, Log 2330/2331/2333) pendientes de próximo Cron C en WT (5 archivos M míos) — flujo normal de preservación cada 2h.
- Escrituras v36: msg **348** (<4KiB) · §28 AUDITORIA · ESTADO v36 (header v14-v36) · **Log %s** ritual §6.1.a (pool Logs cabeza 2336→%s) · check_v36.py (24 checks).

## Archivos Modificados/Creados
- Mensajes entre modelos/Ling-3.1-Flash/%s (creado, <4KiB)
- DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md (§28 append)
- DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOGS/01-Backlog-Vueltas-31oct.md (ESTADO v36 + header v14-v36)
- Temp/kilo/{leer_estado_v36, censor_v36, correr_validador_i18n_v36, correr_detector_v36, check_v36, cierre_v36, ritual_log_v36}.py + v36_{estado_director, censor_gitsha, validador_i18n, detector_delta}.txt + estado_director_v36.json (scripts/evidencia)
- Pools: canal 348 consumido official (cabeza 349) · Logs %s consumido ritual (cabeza %s)

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
""" % (NUM, ahora.strftime(u"%H:%M"), NUM, str(int(NUM) + 1), NOMBRE_MSG, NUM, str(int(NUM) + 1))
wr(LOGP, LOG)
print(u"log escrito: %s (%d bytes)" % (LOGP, len(LOG.encode(u"utf-8"))))

# ---- (c) linea aditiva BACKLOG-MASTER ----
BM = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\BACKLOG-MASTER.md"
if os.path.exists(BM):
    t = rd(BM)
    linea = u"\n- [x] Log creado: **%s** — Vuelta 36: riel íntegro post 60f2e00 (HY4 M25, 9 files docs+GLB, no toca i18n), manager 047eab5ff111 / pt.po d2b567c48e88 WT==HEAD, watchdog LIMPIO, detector 8ª hora 0 delta (invariantes 9ª hora), estado_director 391 claves 0 cambios vs v35, HEAD 60f2e00, autocorrección §12.1 ruta detector" % NUM
    if NUM not in t:
        app(BM, linea + u"\n")
        print(u"BACKLOG-MASTER: linea aditiva %s append OK" % NUM)
    else:
        print(u"BACKLOG-MASTER: ya contiene %s (no duplico)" % NUM)
else:
    print(u"BACKLOG-MASTER: NO EXISTE — pendiente")
