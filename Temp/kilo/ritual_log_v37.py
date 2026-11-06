# -*- coding: utf-8 -*-
"""Ritual §6.1 Log v37 (cabeza REAL del pool; anti-colisión assert).
Uso: python -X utf8 Temp/kilo/ritual_log_v37.py "<nombre-archivo-msg-349>"
(a) tomar cabeza pool Logs y BORRARLA; (b) escribir log; (c) linea aditiva BACKLOG-MASTER. UTF-8 LF."""
import io
import os
import sys
import glob
import datetime

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
NOMBRE_MSG = sys.argv[1] if len(sys.argv) > 1 else u"349-<timestamp>-de-ling-3.1-flash-a-agnes-3-flash-vuelta37.md"

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
assert NUM.isdigit() and int(NUM) >= 2337, u"cabeza inesperada: %r" % NUM
assert not glob.glob(RAIZ + u"\\Logs\\" + NUM + u"-*.md"), u"log %s YA existe — colision" % NUM
lines.pop(0)
while lines and lines[-1] == u"":
    lines.pop()
wr(POOL, u"\n".join(lines) + u"\n")
print(u"pool Logs: %s consumido; nueva cabeza=%r" % (NUM, lines[0]))

# ---- (b) escribir log ----
ahora = datetime.datetime.now()
ts = ahora.strftime(u"%Y-%m-%d_%H-%M-%S")
LOGP = RAIZ + u"\\Logs\\" + NUM + u"-" + ts + u"-vuelta37-riego-intacto-y-cola-b.md"
LOG = u"""# Log %s: Vuelta 37 — riel íntegro post 390652a (HY4 M25), watchdog LIMPIO, detector 9ª hora [x] congelado; agnes en COLA B M67/M75/M77

**Fecha:** 2026-11-06
**Hora:** %s
**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code

## Resumen
Vuelta 37 del cron wku_1aee (08:07Z, override 205). Sin encargo nuevo (estado_director 391 claves, 0 nuevas/0 borradas/0 CAMBIADAS vs v36 — diff programático; sin msg 349 de agnes — anti-loop; agnes verifica COLA B M67/M75/M77 con Hy3). Write real: censor git-blob (riego íntegro post commit HY4 390652a), watchdog oficial LIMPIO, detector 9ª hora (conteos idénticos, [x] congelado 3ª hora), autocorrección SyntaxError propio en leer_estado_v37.py. 0 flips, 0 código tocado, 0 commits.

## Cambios Realizados
- PASO 0: estado_director.json 391 claves; diff vs snapshot v36 = 0 nuevas, 0 borradas, 0 CAMBIADAS. Sin encargo nuevo. `ling_345/346/347/348_acusado` AÚN NO registrados — agnes ocupada en COLA B de verificación M67/M75/M77 (Hy3 #491 04:24 → acuse agnes #492 07:30; Log 2337 cola-b; Nemotron #270/#271). Anti-loop: no insistir.
- PASO 1: canal sin msg 349 (último = mi 348) → vuelta propia. Numeración official: proximo_numero.py --consume → **349** ("mensajes usados: 342, max: 348"; pool canal cabeza 349→350; huecos [63,156,157,232,233,234] intactos).
- CENSOR v37 (git-blob): manager 047eab5ff111 WT==HEAD True; pt.po d2b567c48e88 WT==HEAD True; msgids 276 + 1 header = 277; 0 .mo; git diff HEAD riel i18n vacío. **HEAD 60f2e00→390652a** = HY4 "feat(blender): M25 columna entera con capitel, 3 GLB + guardia de capitel 27/0" (Blender; NO toca i18n/detector). **WT 27→47**: 5 M (mis docs v35/v36 SIN COMMIT — Cron C de agnes NO disparó desde 9e08a34; 3 commits HY4 intermedios: 0a5bbc3 Carreta, 60f2e00 columna_rota, 390652a capitel; + BACKLOG-HY3.md ajeno + Logs/NUMEROS pool) + ?? mis Temp/kilo + msg 347/348 + Log 2333/2336 + ajenos (Hy3 #490/491/492 cola-B, acuses HY4 #26/#27, Nemotron #270/271, Log 2334 encuesta M151 / 2337 cola-b, probe_m73_g1_categoria_completed.gd de flota en game/).
- WATCHDOG v37: scripts/validar_i18n_integridad.py rc=0 LIMPIO (1627 chars): JSON 170/170/170 ES/EN/PT, paridad 0/0/0, placeholders 0, cruzado 159/11/117, 4 copias ES→PT cognatos. Evidencia Temp/kilo/v37_validador_i18n.txt.
- DETECTOR 9ª hora (Temp/kilo/v37_detector_delta.txt, 82.591 chars): conteos IDÉNTICOS a v34/v35/v36 (10ª hora de invariantes; **[x]=22649 congelado 3ª hora consecutiva** — sin flips de flota): 168 checklists; [x]=22649; A1=21; R4=187; A2=233; A3=4; C2=551; SOS=289; FP=4; FORMULA=77; GRIS=209; promovidos=2; A1∩R4=0. Nota de longitud: v36 midió 82.669 (detalle transitorio); v37 volvió a 82.591 = v34/v35; contadores iguales en los 4.
- AUTOCORRECCIÓN §12.1 (error propio): leer_estado_v37.py inicial lanzó SyntaxError (paréntesis extra `[:250]))` en 2 líneas, copy-paste del template v36) → corregido con edit → re-run OK (diff 0 cambios confirmado). Sin daño colateral (script Temp/kilo, no tocó repo).
- Escrituras v37 (report-only, 0 flips, 0 código tocado, 0 commits míos): msg **349** (`%s`, <4KiB, consumido official) · §29 AUDITORIA · ESTADO v37 (header v14-v37) · **Log %s** ritual §6.1.a (pool Logs cabeza 2339→%s) · check_v37.py (24 checks). Scripts/evidencia: Temp/kilo/{leer_estado_v37, censor_v37, correr_validador_i18n_v37, correr_detector_v37, check_v37, cierre_v37, ritual_log_v37}.py + v37_{estado_director, censor_gitsha, validador_i18n, detector_delta}.txt + estado_director_v37.json.

## Archivos Modificados/Creados
- Mensajes entre modelos/Ling-3.1-Flash/%s (creado, <4KiB)
- DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md (§29 append)
- DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOGS/01-Backlog-Vueltas-31oct.md (ESTADO v37 + header v14-v37)
- Temp/kilo/ scripts y evidencias v37 (lista arriba)
- Pools: canal 349 consumido official (cabeza 350) · Logs %s consumido ritual (cabeza %s)

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
""" % (NUM, ahora.strftime(u"%H:%M"), NOMBRE_MSG, NUM, str(int(NUM) + 1), NOMBRE_MSG, NUM, str(int(NUM) + 1))
wr(LOGP, LOG)
print(u"log escrito: %s (%d bytes)" % (LOGP, len(LOG.encode(u"utf-8"))))

# ---- (c) linea aditiva BACKLOG-MASTER ----
BM = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\BACKLOG-MASTER.md"
if os.path.exists(BM):
    t = rd(BM)
    linea = u"\n- [x] Log creado: **%s** — Vuelta 37: riel íntegro post 390652a (HY4 M25 capitel, no toca i18n), manager 047eab5ff111 / pt.po d2b567c48e88 WT==HEAD, watchdog LIMPIO, detector 9ª hora [x]=22649 congelado 3ª hora (10ª hora invariantes), estado_director 391 claves 0 cambios vs v36, agnes en COLA B M67/M75/M77 (anti-loop), autocorrección §12.1 SyntaxError propio" % NUM
    if NUM not in t:
        app(BM, linea + u"\n")
        print(u"BACKLOG-MASTER: linea aditiva %s append OK" % NUM)
    else:
        print(u"BACKLOG-MASTER: ya contiene %s (no duplico)" % NUM)
else:
    print(u"BACKLOG-MASTER: NO EXISTE — pendiente")
