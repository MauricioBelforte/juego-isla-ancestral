# -*- coding: utf-8 -*-
"""Cierre v41: §33 AUDITORIA + ESTADO v41 (anchor real: antes de línea ESTADO v40) + header v14-v41.
Idempotente (guards). Descubre NMSG/NLOG en runtime. UTF-8 LF."""
import io
import os
import glob
import re

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
AUD = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md"
BK = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\01-Backlog-Vueltas-31oct.md"
CANAL = RAIZ + u"\\Mensajes entre modelos\\Ling-3.1-Flash"

def rd(p):
    return io.open(p, encoding=u"utf-8", errors=u"replace").read()

def wr(p, s):
    with io.open(p, u"w", encoding=u"utf-8", newline=u"\n") as f:
        f.write(s)

cands = sorted(glob.glob(CANAL + u"\\353-*.md"))
assert len(cands) >= 1, u"msg 353 no existe"
NMSG = os.path.basename(cands[0])
logs41 = sorted(glob.glob(RAIZ + u"\\Logs\\*-vuelta41-*.md"))
assert len(logs41) >= 1, u"Log vuelta41 no existe (correr ritual primero)"
m = re.search(r"# Log (\d+)", rd(logs41[0]))
NLOG = m.group(1) if m else os.path.basename(logs41[0])[:4]
print(u"NMSG:", NMSG, u"| NLOG:", NLOG)

# ---------- §33 AUDITORIA ----------
t = rd(AUD)
if u"## 33." in t:
    print(u"AUDITORIA: §33 ya presente (idempotente) — skip")
else:
    S33 = u"""

## 33. VUELTA 41 — 2026-11-06 21:09 local (cron PUNTUAL 00:07Z; anti-loop; Cron C 6a8ab2f estable; v40 en WT)

**Modelo:** Ling-3.1-Flash / Kilo Code · msg 353 (`%s`) · Log %s

### Descubrimiento
- Cron disparó PUNTUAL 00:07Z (2ª puntual consecutiva; v39 fue 12h tarde por dormancia). **Canal sin 353+** (mi 352 sigue último; 0 mensajes nuevos) → anti-loop → vuelta propia. Sin encargo (campo `ling` sin cambios; último acuse `ling_342_acusado`).
- **estado_director 398 claves = snapshot v40 post-20:12** (diff: nuevas `sello_14_m64` + cambiada `sellos_218` — ya documentadas en v40; mtime 20:12 ESTABLE 1h — agnes procesando sin escribir). `ling_345-351_acusado` AÚN NO registrado — anti-loop correcto, NO insistir por canal (mi 352 ya reportó todo; su cron */40 + próximo Cron C lo procesarán).
- **Cron C `6a8ab2f` ESTABLE 1h+** (selló M64 109/119; reasignaciones M64/M37 Hy3, M17/M129 DS-OC; Step-5/MiMo/Kimi fuera). **Preservó v39** (git show HEAD: AUDITORIA contiene "## 31.", backlog contiene "VUELTA 39 CIERRE") **pero MIS ESCRITURAS v40 (§32, ESTADO v40, Log 2348, msg 352) SIGUEN EN WT**.
- **TABLA DE LAG DE PRESERVACIÓN (Cron C)**: v39 escrito 19:11-19:16 → versionado en 6a8ab2f ~20:12 = **lag ~55 min**; v40 escrito 20:14-20:18 → pendiente (slot 00:17Z próximo, en ~9 min al cierre de esta vuelta). Patrón: Cron C preserva con lag ~1h, no inmediato. Observación persiste 1 vuelta más (no bloqueante; yo mantengo 0 commits/0 push).
- Centinela v41 (`Temp/kilo/v41_censor_gitsha.txt`): blobs INTACTOS WT==HEAD en 6a8ab2f (manager `047eab5ff111`, pt.po `d2b567c48e88`); msgids 276; 0 `.mo`; diff riel vacío.
- Watchdog v41 (`v41_validador_i18n.txt`): rc=0 LIMPIO (170/170/170; paridad 0; cruzado 159/11/117; 4 cognatos).
- Detector v41 (`v41_detector_delta.txt`): rc=0, **82.591 chars — 14ª hora de invariantes** ([x]=22649 congelado; A1=21, R4=187, A2=233, A3=4, C2=551, SOS=289, FP=4, F=77, GRIS=209, promovidos=2, A1∩R4=0). Hy3/DS-OC trabajando M37/M64/M17/M129 SIN flips de checklists.
- Flota tranquila esta hora: único latido Hy3/497 (20:27, acuse de agnes "tanda restante" post-496). Log 2347 = reconciliación M107 (otro agente; race v40 documentado). WT 21:08: 18 (dinámico).

### Escrituras v41 (reales)
- helper consumió 353 (pool canal 353→354; pool tiene 354-382); msg 353 (`%s`, <4KiB, canónico `**VUELTA 41 CIERRE**`).
- Ritual §6.1.a: Log %s (cabeza REAL runtime, assert >= 2349 anti-colisión); línea aditiva BACKLOG-MASTER.
- §33 AUDITORIA (este bloque); ESTADO v41 + header v14-v41 en 01-Backlog; check_v41.py 34 checks.

### Próxima vuelta 42 (~01:07Z)
¿Cron C 00:17Z preservó v40 (§32/ESTADO v40/Log 2348/msg 352 versionados)? ¿agnes registra `ling_345-351_acusado` o responde a 352/353? ¿Hy3/DS-OC avanzan M37/M17 (flips del detector)? Anti-loop intacto.
""" % (NMSG, NLOG, NMSG, NLOG)
    t = t + S33
    wr(AUD, t)
    print(u"AUDITORIA: §33 append OK —", len(t), u"chars")

# ---------- ESTADO v41 + header ----------
b = rd(BK)
if u"VUELTA 41 CIERRE" in b:
    print(u"BACKLOG 01: ESTADO v41 ya presente (idempotente) — skip")
else:
    ANCHOR = u"**ESTADO 2026-11-06 20:14 local"
    assert ANCHOR in b, u"anchor ESTADO v40 no encontrado"
    V41 = u"**ESTADO 2026-11-06 21:09 local (2026-11-07 00:09Z) — VUELTA 41 CIERRE (cron wku_1aee PUNTUAL 00:07Z; override 205; WRITE REAL = ANTI-LOOP + CRON C 6a8ab2f ESTABLE + CENTINELA + WATCHDOG + DETECTOR 14ª HORA, 0 flips):** PASO 0: estado_director 398 claves (= snapshot v40 post-20:12; sello_14_m64/sellos_218 ya documentadas; mtime 20:12 estable 1h — agnes procesando). `ling_345-351_acusado` AÚN NO registrado; campo ling sin cambios; sin encargo. PASO 1: canal sin 353+ (mi 352 último) → anti-loop vuelta propia. Helper consumió **353** official (pool canal 353→354). **CENSOR v41:** HEAD 6a8ab2f ESTABLE 1h+; blobs INTACTOS WT==HEAD (manager 047eab5ff111, pt.po d2b567c48e88; 276 msgids; 0 .mo; diff vacío). **Cron C 6a8ab2f preservó v39** (git show HEAD: §31 + VUELTA 39 CIERRE versionados) **pero v40 sigue en WT** (§32/ESTADO v40/Log 2348/msg 352; lag medido ~55min en v39; slot 00:17Z próximo). **WATCHDOG v41 LIMPIO rc=0** (170/170/170; cruzado 159/11/117; 4 cognatos). **DETECTOR 14ª hora (82.591 chars): conteos IDÉNTICOS v34-v41** — [x]=22649 congelado; A1=21, R4=187, A2=233, A3=4, C2=551, SOS=289, FP=4, F=77, GRIS=209, prom=2, A1∩R4=0. Flota tranquila: único latido Hy3/497 (20:27, acuse agnes tanda restante post-496); M64 sellado (sello 14° en 6a8ab2f). WT 18 (dinámico). **Escrituras v41:** msg **353** (2,4KB) · Log **%s** ritual §6.1.a (assert runtime anti-colisión) · §33 AUDITORIA · ESTADO v41 (header v14-v41) · check_v41 34 PASS/0 FAIL. Bloqueos: I-08 runtime (sin MCP); bug_156=DS#491; gate-2 PT=Hy3; R4/gemelos/deuda313=fundador; saneo pools=fundador/directora. Próxima vuelta 42 (~01:07Z): ¿Cron C 00:17Z preservó v40? ¿acuse ling_345-351? ¿respuesta a 352/353? ¿flips detector (Hy3 M37/DS-OC M17)?\n\n"
    b = b.replace(ANCHOR, V41 + ANCHOR, 1)
    if u"v14-v40" in b:
        b = b.replace(u"v14-v40", u"v14-v41", 1)
    wr(BK, b)
    print(u"BACKLOG 01: ESTADO v41 insertado (anchor pre-v40) + header v14-v41 —", len(b), u"chars")

print(u"CIERRE v41 COMPLETO")
