# -*- coding: utf-8 -*-
"""Cierre v39 (reencauzado post-verificacion de disco): (1) append §31 AUDITORIA; (2) ESTADO v39 en backlog + header v14-v39.
Adaptado a hechos reales: doble ritual (Logs 2344+2345), Cron C 4091de8 preservó riel v35-v38, flota reactivada 19:06-19:12.
Descubre N1/N2/CHEAD/HEAD/CLAVES en runtime (flota activa — nada hardcodeado que pueda stalear). UTF-8 LF."""
import io
import glob
import json
import subprocess

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

def rd(p):
    return io.open(p, encoding=u"utf-8", newline=u"").read()

def wr(p, s):
    with io.open(p, u"w", encoding=u"utf-8", newline=u"\n") as f:
        f.write(s)

def git(*a):
    return subprocess.run([u"git", u"-C", RAIZ] + list(a), capture_output=True,
                          text=True, encoding=u"utf-8", errors=u"replace").stdout.strip()

# ---- descubrir hechos en disco ----
logv39 = sorted(glob.glob(RAIZ + u"\\Logs\\*-vuelta39-*.md"))
assert len(logv39) >= 1, u"sin logs vuelta39 — correr ritual primero"
N1 = logv39[0].split(u"\\")[-1].split(u"-")[0]
N2 = logv39[-1].split(u"\\")[-1].split(u"-")[0]
CHEAD = [x for x in rd(RAIZ + u"\\Logs\\NUMEROS_DISPONIBLES.txt").split(u"\n") if x.strip()][0]
HEAD = git(u"log", u"-1", u"--format=%h")
ED = json.loads(rd(RAIZ + u"\\Logs\\estado_director.json"))
CLAVES = len(ED)
MSG = u"351-2026-11-06_19-03-34-de-ling-3.1-flash-a-agnes-3-flash-vuelta39-gap-12h-flota-congelada-y-riel-intacto.md"
print(u"hechos disco: Logs v39=%s+%s | pool Logs cabeza=%s | HEAD=%s | estado_director=%d claves" % (N1, N2, CHEAD, HEAD, CLAVES))

# ============ (1) §31 AUDITORIA append ============
AUD = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md"
SEC31 = u"""

## 31. Vuelta 39 (2026-11-06 19:01-19:16 local / 22:01-22:16Z — CRON DISPARÓ 12H TARDE: due 10:07Z, real 21:58Z) — GAP 12H SESION DORMIDA + FLOTA CONGELADA 12.5h (MTIMES) + REACTIVACIÓN 19:06-19:12 (CRON C %s PRESERVÓ TODO MI RIEL v35-v38) + DOBLE RITUAL %s+%s + RIEL ÍNTEGRO + DETECTOR 12ª HORA INVARIANTES

- **PASO 0 (estado_director.json):** 391 claves en discovery (22:01Z), diff vs snapshot v38 = 0 (6ª vuelta estable v34→v39). Post-despertar: **%s claves** (+6, escritura de agnes 19:09 — flota viva). Sin encargo nuevo para Ling. `ling_345-350_acusado` **AÚN NO REGISTRADO** (campo `ling` sigue en estado T32/LOTE B del 29oct) — anti-loop: no insistir; su cron */40 procesa mi msg 351 + Logs.
- **PASO 1:** canal sin msg 351 (último = mi 350) → vuelta propia. Helper consumió **351** official ("mensajes usados: 344, max: 350"; pool canal 351→352).
- **GAP 12H (evidencia mtimes, scan robusto try/except):** últimos .md bajo `Mensajes entre modelos/` con mtime del día = 62, TODOS ≤ 06:22 local (mi 350 / HY4-29 06:20 / acuse agnes→Hy3 06:01). Desde 09:22Z: CERO writes en todos los canales, 0 commits (HEAD estable 390652a 12h+), ESTADO-PARALELO mtime 2026-10-25. Causa: máquina/sesión dormida (mi cron disparó 12h tarde; los de la flota igual). NO negligencia de nadie.
- **REACTIVACIÓN DE LA FLOTA (hora local):** 19:06 acuse agnes→HY4-30 · ~19:08-19:12 **CRON C %s** "Se preservaron avances de la jornada 6nov: acuses cron A/B/D (Hy3 491-493, Hy4 28-29, Nemotron 270-272)..." — **versionó MI RIEL v35-v38 COMPLETO**: AUDITORIA §29-30 (+52), 01-Backlog ESTADO v37-v38 + header v14-v38 (+9), BACKLOG-MASTER (+8), Logs 2333/2334/2336/2337/2339/2340/2341/2342/2343/951, msg Ling 347-351 (no quedan como `??` = versionados); + acuses Hy3 491-493, HY4 26-29, Nemotron 268-272, backlog HY4 M18bis-Mansion, Nemotron RESUMEN-FINAL. **WT 108→10.** 19:09 estado_director escritura (%s claves) · 19:12 Hy3-494 nueva tarea M64/M37 · Nemotron-273 desbloqueo · DS-OC-249 tarea M17/M129 (22:10-22:12Z). **Mi observación msg 351 §6 ("Cron C sin commit 12h") quedó obsoleta ~5 min después del discovery: la directora preservó al retomar, exactamente como predije.** Centinela post-commit: manager `047eab5ff111` / pt.po `d2b567c48e88` hash-object == canónicos en %s (el commit no tocó el riel).
- **CENSOR v39 (git-blob):** discovery (22:01Z, HEAD 390652a): manager WT==HEAD True, pt.po WT==HEAD True, 276 msgids (+header=277), 0 `.mo`, diff riel vacío. Re-verificado post-Cron C: blobs idénticos en %s. Evidencia Temp/kilo/v39_censor_gitsha.txt.
- **DOBLE RITUAL v39 (documentación honesta, sin editar logs históricos §4.1-b):** el turno del cron 22:07Z (absorbido por el resumen de contexto del harness) ejecutó discovery + ritual → **Log %s** (19:08:44); el turno visible re-ejecutó el mismo ritual → **Log %s** (19:11:11). Mismo slug, contenido idéntico salvo hora/N. Pool Logs cabeza 2344→%s. Ambos logs quedan (inmutabilidad). El Log %s imprime "cabeza 2344→%s" subdocumentando el paso intermedio 2344→2345 (ejecutado por la 1ª corrida) — se documenta aquí; NO se editan logs históricos. Lección: ante reanudación de turno post-resumen, VERIFICAR DISCO antes de re-ejecutar rituales (el glob anti-colisión evitó overwrite, pero el consumo consecutivo del pool es tolerado por diseño del protocolo §6.1).
- **WATCHDOG v39:** `scripts/validar_i18n_integridad.py` rc=0 LIMPIO (1627 chars): JSON 170/170/170, paridad 0/0/0, cruzado 159/11/117, 4 cognatos. Evidencia Temp/kilo/v39_validador_i18n.txt.
- **DETECTOR 12ª hora (Temp/kilo/v39_detector_delta.txt, 82.591 chars, exit 0):** conteos IDÉNTICOS v34-v39 — **[x]=22649 congelado 5ª hora** (flota sin flips en el gap): 168 checklists; A1=21, R4=187, A2=233, A3=4, C2=551, SOS=289, FP=4, FORMULA=77, GRIS=209, promovidos=2, A1∩R4=0.
- **CORRECCIÓN HONESTA v38:** el "hueco 2341" reportado fue RACE DE SEGUNDOS (Log 2341 HY4 M18BIS mansion 06:19:18 apareció post-glob v38). En la reactivación se confirma: pool Logs sin huecos reales. Huecos canal Ling: [63,156,157,210,212,232,233,234] (saneo fundador/directora).
- **AUTOCORRECCIÓN §12.1 (script propio):** primer scan de mtimes → FileNotFoundError (fantasma NTFS >260 MAX_PATH, canal agnes arch_0001-0100/…) → re-run con try/except OK. Lección: walks recursivos sobre `Mensajes entre modelos/` SIEMPRE con try/except por archivo.
- **Escrituras v39 (report-only, 0 flips, 0 código tocado, 0 commits míos):** msg **351** (`%s`, <4KiB, versionado por Cron C en %s) · §31 · ESTADO v39 (header v14-v39) · **Logs %s+%s** ritual §6.1.a (doble ejecución documentada) · check_v39.py (27 checks). Scripts/evidencia: Temp/kilo/{leer_estado_v39, censor_v39, correr_validador_i18n_v39, correr_detector_v39, check_v39, cierre_v39, ritual_log_v39}.py + v39_{estado_director, censor_gitsha, validador_i18n, detector_delta}.txt + estado_director_v3{8,9}.json.
- **Pendientes vuelta 40 (~23:07Z):** agnes procesa ling_345-351 (cron */40 + próximo Cron C preservará v39); centinela riel post-4091de8; flota reparte tareas (Hy3 M64/M37, DS-OC M17/M129, Nemotron desbloqueo); I-08 runtime ms (sin Godot MCP); bug_156 = DeepSeek #491; R4 (187+313+37) y gemelos 256/248 = fundador/editor; deuda 313 entidades = GO fundador; saneo pools/huecos = fundador/directora.
""" % (HEAD, N1, N2, CLAVES, HEAD, CLAVES, HEAD, HEAD, N1, N2, CHEAD, N2, CHEAD, MSG, HEAD, N1, N2)
t = rd(AUD)
if u"## 31." in t:
    print(u"AUDITORIA §31 YA existe — skip")
else:
    wr(AUD, t + SEC31)
    print(u"AUDITORIA §31 append OK (Logs %s+%s, HEAD %s): %d -> %d chars" % (N1, N2, HEAD, len(t), len(t) + len(SEC31)))

# ============ (2) ESTADO v39 en 01-Backlog-Vueltas ============
BK = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\01-Backlog-Vueltas-31oct.md"
t = rd(BK)
if u"ESTADO v39" in t:
    print(u"backlog ESTADO v39 YA existe — skip")
else:
    HEADER_OLD = u"# Ling-3.1-Flash — ESTADO v14-v38 (cron loop 30-31oct + 06nov, report-only, blindaje riel PT)"
    HEADER_NEW = u"# Ling-3.1-Flash — ESTADO v14-v39 (cron loop 30-31oct + 06nov, report-only, blindaje riel PT)"
    assert HEADER_OLD in t, u"header v14-v38 no encontrado"
    t = t.replace(HEADER_OLD, HEADER_NEW, 1)
    V39 = u"""**ESTADO 2026-11-06 19:16 local (22:16Z) — VUELTA 39 CIERRE (cron wku_1aee due 10:07Z disparó TARDE 21:58Z = sesión dormida ~12h; override 205; WRITE REAL = CENTINELA + WATCHDOG + DETECTOR 12ª HORA + DIAGNÓSTICO GAP/REACTIVACIÓN FLOTA, 0 flips):** PASO 0: estado_director 391 claves en discovery (diff v38=0, 6ª vuelta estable); post-despertar %s claves (agnes escribió 19:09); sin encargo nuevo; `ling_345-350_acusado` aún no registrado (anti-loop). **GAP 12H (mtimes):** último latido 06:22 local (mi 350); desde 09:22Z cero writes/commits — máquina/sesión dormida (mi cron disparó 12h tarde; los de la flota igual; NO negligencia). **REACTIVACIÓN 19:06-19:12:** acuse HY4-30 (19:06) · **CRON C %s** preservó MI RIEL v35-v38 COMPLETO (AUDITORIA §29-30, BACKLOG 01 v37-v38, BACKLOG-MASTER, Logs 2333-2343+951, msg 347-351; + acuses Hy3/HY4/Nemotron; WT 108→10) · estado_director 19:09 · Hy3-494 tarea M64/M37 · Nemotron-273 · DS-OC-249 M17/M129. PASO 1: canal sin 351 → vuelta propia; helper consumió **351** official (pool canal 351→352). **CENSOR v39:** manager 047eab5ff111 / pt.po d2b567c48e88 WT==HEAD (276 msgids; 0 .mo; diff vacío) — intactos en discovery (390652a) Y post-Cron C (%s). **CENTINELA post-Cron C: riel íntegro en %s** (commit no tocó riel). **DOBLE RITUAL v39 (documentado honestamente):** turno del cron 22:07Z (absorbido por resumen del harness) ejecutó ritual→**Log %s** (19:08:44); turno visible re-ejecutó→**Log %s** (19:11:11); pool Logs 2344→%s; ambos logs quedan (inmutabilidad §4.1-b); Log %s subdocumenta el paso 2344→2345 (1ª corrida) — aquí documentado, sin editar logs históricos. **WATCHDOG v39 LIMPIO rc=0** (170/170/170, paridad 0/0/0, cruzado 159/11/117, 4 cognatos). **DETECTOR 12ª hora (82.591 chars): conteos IDÉNTICOS v34-v39** — [x]=22649 congelado 5ª hora (flota sin flips en el gap): A1=21, R4=187, A2=233, A3=4, C2=551, SOS=289, FP=4, FORMULA=77, GRIS=209, promovidos=2, A1∩R4=0. **CORRECCIÓN HONESTA:** "hueco 2341" de v38 fue race de segundos (Log 2341 HY4 M18BIS 06:19:18 post-glob). **AUTOCORRECCIÓN §12.1:** scan mtimes falló con fantasma NTFS >260 MAX_PATH (arch_0001-0100 agnes) → re-run try/except OK. **Escrituras v39:** msg **351** (<4KiB, versionado en %s) · §31 AUDITORIA · ESTADO v39 (header v14-v39) · Logs %s+%s · check_v39.py (27 checks). 0 flips. 0 código tocado. 0 commits míos (Cron C de agnes versionó v35-v38; v39 queda en WT para próximo Cron C). Bloqueos vigentes: I-08 runtime ms (sin Godot MCP); gate-2 runtime PT + captura UI PT (no míos); bug_156 = DeepSeek #491; R4 (187+313+37) y gemelos 256/248 = fundador/editor; deuda 313 entidades = GO fundador; saneo pools/huecos = fundador/directora. Próxima vuelta 40 (~23:07Z): agnes procesa ling_345-351 (*/40); verificar acuse + próximo Cron C preservando v39; si la flota sigue activa, reporte report-only.
""" % (CLAVES, HEAD, HEAD, HEAD, N1, N2, CHEAD, N2, HEAD, N1, N2)
    ANCHOR = u"**ESTADO 2026-11-06 06:16 local"
    assert ANCHOR in t, u"ancla v38 no encontrada"
    t = t.replace(ANCHOR, V39 + ANCHOR, 1)
    wr(BK, t)
    print(u"ESTADO v39 insertado OK; header v14-v39; total chars=%d" % len(t))
