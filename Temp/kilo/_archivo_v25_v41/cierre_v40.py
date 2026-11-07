# -*- coding: utf-8 -*-
"""Cierre v40: §32 AUDITORIA + ESTADO v40 (anchor real: antes de línea ESTADO v39) + header v14-v40.
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

cands = sorted(glob.glob(CANAL + u"\\352-*.md"))
assert len(cands) >= 1, u"msg 352 no existe"
NMSG = os.path.basename(cands[0])
logs40 = sorted(glob.glob(RAIZ + u"\\Logs\\*-vuelta40-*.md"))
assert len(logs40) >= 1, u"Log vuelta40 no existe (correr ritual primero)"
m = re.search(r"# Log (\d+)", rd(logs40[0]))
NLOG = m.group(1) if m else os.path.basename(logs40[0])[:4]
print(u"NMSG:", NMSG, u"| NLOG:", NLOG)

# ---------- §32 AUDITORIA ----------
t = rd(AUD)
if u"## 32." in t:
    print(u"AUDITORIA: §32 ya presente (idempotente) — skip")
else:
    S32 = u"""

## 32. VUELTA 40 — 2026-11-06 (cron PUNTUAL 23:07Z; directora CONFIRMA dormancia; flota activa; v39 aún en WT)

**Modelo:** Ling-3.1-Flash / Kilo Code · msg 352 (`%s`) · Log %s

### Descubrimiento
- Cron disparó PUNTUAL 23:07Z (sesión viva; contraste v39: 12h de dormancia). Canal sin 352 (mi 351 seguía último) → anti-loop → vuelta propia. Sin encargo (campo `ling` sin cambios; último acuse `ling_342_acusado`).
- **estado_director 391→397 claves (+6 NUEVAS, agnes 19:09-19:14; 0 borradas, 0 cambiadas) — REGISTRO OFICIAL de la dormancia del 6nov:**
  - `crons_apagados` = true
  - `crons_apagados_6nov`: {"cuando":"6nov 22:05","quien":"agnes-3-flash (Sapiens AI) / Kilo Code","fundador":"termina lo que estas haciendo y apaga tus cronometros hasta nuevo aviso","ids_borrados":{A:wku_1ae5989e3001zjeK6jhySTVVZB, B:wku_1ae59c521001muuNyf5r2q0G2W, C:wku_1ae5a06f6001co7twLwrFp4n2G, D:wku_1ae5a3de3001PboQDq9whsXoay},"estado":"APAGADOS. No disparar mas hasta orden del fundador."}
  - `flota_6nov_actual`: ["agnes","Hy3","Hy4","DS-OC","Nemotron","GLM","Ling (reactivado)"]
  - `fuera_flota`: ["Step-5","MiMo","kimi-k3","DeepSeek-WB","ox-alpha"]
  - `nemotron_desbloqueado`: {"cuando":"6nov 22:10","asignaciones":{"M64":"Hy3 (gate-2)","M37":"Hy3 (QA, 7 items)","M17":"DS-OC (codigo)","M129":"Hy4 (3D) + DS-OC (codigo+boot)","mouse_filter_bug":"Hy3 (gate-2 runtime)"},"mensajes":["Nem 273","Hy3 494","DS-OC 249"]}
  - `step5_fuera`: {"cuando":"6nov 22:12","quien":"fundador","nota":"Step-5 no disponible. M17/M129 codigo reasignados a DS-OC"}
  - **Mi hipótesis v39 (sesión/máquina dormida → gap 12h) queda RATIFICADA por la directora con registro oficial.** Mi cron `wku_1aee03563001ICgn4VnMuHwt9i` NO está en ids_borrados → siguió vivo (v39 disparó 12h tarde; v40 puntual).
- Centinela v40 (`Temp/kilo/v40_censor_gitsha.txt`): HEAD **4091de8 ESTABLE 1h+**; blobs INTACTOS WT==HEAD (manager `047eab5ff111`, pt.po `d2b567c48e88`); msgids 276; 0 `.mo`; diff riel vacío. `git log -3 -- Logs/DOC ling` = 4091de8 → **Cron C NO ha preservado v39 aún** (§31/ESTADO v39/Logs 2344-2345/BACKLOG-MASTER en WT; slots :17Z sin commit nuevo; próximo 00:17Z). Observación persiste (no bloqueante).
- Watchdog v40 (`v40_validador_i18n.txt`): rc=0 LIMPIO (170/170/170; paridad 0; cruzado 159/11/117; 4 cognatos SETTINGS.HORAS/MIN).
- Detector v40 (`v40_detector_delta.txt`): rc=0, **82.591 chars — 13ª hora de invariantes** ([x]=22649 congelado; A1=21, R4=187, A2=233, A3=4, C2=551, SOS=289, FP=4, F=77, GRIS=209, promovidos=2, A1∩R4=0). La flota despertó SIN flips de checklists.
- Flota activa post-v39 (evidencia): Hy3 494→495 + Log 2346 (M37 QA 7 items + M64 + mouse_filter gate-2); Nemotron 273 (desbloqueo); DS-OC 249 (M17/M129); HY4-30 acuse. WT 20:11: 7 M + 21 ?? (míos v39 + flota; `Logs/NUMEROS_DISPONIBLES.txt` M = consumo de 2346 por Hy3, race atómico esperado).
- **RACE POOL LOGS (anti-colisión funcionó):** entre discovery (cabeza 2347) y ritual (20:18 local), otro agente consumió **2347** (Log 2347 = "Reconciliacion de conteo M107 + verificacion backup (G3-01/G3-02)"). Mi ritual tomó la cabeza REAL **2348** (assert >= 2347 en runtime, no hardcode). Pool Logs 2347→2349.

### Escrituras v40 (reales)
- helper consumió 352 (pool canal 352→353; pool ampliado 353-382 §10.2 punto 4); msg 352 (`%s`, 2495B <4KiB, canónico `**VUELTA 40 CIERRE**`).
- Ritual §6.1.a: Log %s (cabeza runtime 2348); línea aditiva BACKLOG-MASTER.
- §32 AUDITORIA (este bloque); ESTADO v40 + header v14-v40 en 01-Backlog; check_v40.py 31 checks.

### Próxima vuelta 41 (~00:07Z)
¿Cron C preserva v39-v40? ¿agnes registra `ling_345-351_acusado`? ¿respuesta a 352? Anti-loop intacto.
""" % (NMSG, NLOG, NMSG, NLOG)
    t = t + S32
    wr(AUD, t)
    print(u"AUDITORIA: §32 append OK —", len(t), u"chars")

# ---------- ESTADO v40 + header ----------
b = rd(BK)
if u"VUELTA 40 CIERRE" in b:
    print(u"BACKLOG 01: ESTADO v40 ya presente (idempotente) — skip")
else:
    ANCHOR = u"**ESTADO 2026-11-06 19:16 local"
    assert ANCHOR in b, u"anchor ESTADO v39 no encontrado"
    V40 = u"**ESTADO 2026-11-06 20:14 local (23:14Z) — VUELTA 40 CIERRE (cron wku_1aee PUNTUAL 23:07Z; override 205; WRITE REAL = CONFIRMACION DIRECTORA DORMANCIA 6nov + CENTINELA 4091de8 + WATCHDOG + DETECTOR 13ª HORA + FLOTA ACTIVA + RACE POOL 2347, 0 flips):** PASO 0: estado_director 391→397 claves (+6 NUEVAS, agnes 19:09-19:14) que CONFIRMAN OFICIALMENTE la dormancia de crons 6nov 22:05 (fundador: \"termina lo que estas haciendo y apaga tus cronometros hasta nuevo aviso\"; ids A/B/C/D borrados; fuera_flota Step-5/MiMo/kimi-k3/DeepSeek-WB/ox-alpha; nemotron_desbloqueado: M64/M37 Hy3 gate-2 + M17 DS-OC + M129 Hy4+DS-OC + mouse Hy3; Ling \"reactivado\"). Mi hipotesis v39 RATIFICADA por la directora. Mi cron wku_1aee03563001ICgn4VnMuHwt9i NO esta en ids_borrados → siguio vivo (v39 disparó 12h tarde; v40 puntual). Canal sin 352 → anti-loop vuelta propia; sin encargo (ling sin cambios; último acuse ling_342_acusado). **CENSOR v40:** HEAD 4091de8 ESTABLE 1h+; blobs INTACTOS WT==HEAD (manager 047eab5ff111, pt.po d2b567c48e88; 276 msgids; 0 .mo; diff vacio). **Cron C NO ha preservado v39 aun** (§31/ESTADO v39/Logs 2344-2345 en WT; slots :17Z sin commit; próximo 00:17Z) — observacion persiste (no bloqueante). **WATCHDOG v40 LIMPIO rc=0** (170/170/170; cruzado 159/11/117; 4 cognatos). **DETECTOR 13ª hora (82.591 chars): conteos IDENTICOS v34-v40** — [x]=22649 congelado; A1=21, R4=187, A2=233, A3=4, C2=551, SOS=289, FP=4, F=77, GRIS=209, prom=2, A1∩R4=0. Flota desperto SIN flips de checklists. **FLOTA ACTIVA:** Hy3 494→495 + Log 2346 (M37 QA 7 items + M64 + mouse gate-2); Nemotron 273 (desbloqueo); DS-OC 249 (M17/M129); HY4-30 acuse; **Log 2347 = reconciliacion M107 de OTRO agente — RACE legítimo: mi ritual tomó 2348 por assert anti-colisión runtime** (pool Logs 2347→2349). WT 20:11: 7 M + 21 ?? (flota + mis v39). **Escrituras v40:** msg **352** (2495B; pool canal 352→353, ampliado 353-382 §10.2.4) · Log **2348** ritual §6.1.a · §32 AUDITORIA · ESTADO v40 (header v14-v40) · check_v40 31 checks. Bloqueos: I-08 runtime (sin MCP); bug_156=DS#491; gate-2 PT=Hy3; R4/gemelos/deuda313=fundador; saneo pools=fundador/directora. Próxima vuelta 41 (~00:07Z): ¿Cron C preserva v39-v40? ¿acuse ling_345-351? ¿respuesta a 352?\n\n"
    b = b.replace(ANCHOR, V40 + ANCHOR, 1)
    if u"v14-v39" in b:
        b = b.replace(u"v14-v39", u"v14-v40", 1)
    wr(BK, b)
    print(u"BACKLOG 01: ESTADO v40 insertado (anchor pre-v39) + header v14-v40 —", len(b), u"chars")

print(u"CIERRE v40 COMPLETO")
