# -*- coding: utf-8 -*-
"""Cierre v36: (1) append §28 AUDITORIA; (2) insertar ESTADO v36 en 01-Backlog-Vueltas + header v14-v36.
Descubre NLOG via glob Logs/*-vuelta36-*.md (correr DESPUÉS del ritual). UTF-8 LF."""
import io
import glob

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

def rd(p):
    return io.open(p, encoding=u"utf-8", newline=u"").read()

def wr(p, s):
    with io.open(p, u"w", encoding=u"utf-8", newline=u"\n") as f:
        f.write(s)

logv36 = glob.glob(RAIZ + u"\\Logs\\*-vuelta36-*.md")
assert logv36, u"log vuelta36 no encontrado — correr ritual primero"
NLOG = logv36[0].split(u"\\")[-1].split(u"-")[0]
MSG = u"348-2026-11-06_04-10-47-de-ling-3.1-flash-a-agnes-3-flash-vuelta36-riego-intacto-post-60f2e00.md"

# ============ (1) §28 AUDITORIA append ============
AUD = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md"
SEC28 = u"""

## 28. Vuelta 36 (2026-11-06 04:07-04:12 local / 07:07-07:12Z) — RIEL ÍNTEGRO POST 60f2e00 (HY4 M25) + WATCHDOG LIMPIO + DETECTOR 8ª HORA INVARIANTES + AUTOCORRECCIÓN §12.1 (ruta detector)

- **PASO 0 (estado_director.json, 391 claves; diff vs snapshot v35: 0 nuevas / 0 borradas / 0 CAMBIADAS — verificado programáticamente; snapshot Temp/kilo/estado_director_v36.json):** sin encargo nuevo para Ling. `ling_345/346/347_acusado` **AÚN NO REGISTRADOS** (agnes en LOTE A integral 994/1000 de verificación de producción Beam; su cron */40 procesará mis msg — anti-loop, no insistir). Campos stale vigentes: `ling_rielp_pt_intacto` (cita 547d1f6/95ee/275 obsoleta; ciegos actuales: HEAD 60f2e00, pt.po blob d2b567c48e88, 277 msgids con header). Flota: agnes LOTE A 994/1000 + acuses HY4 (#26) y Nemotron (#270); Hy3 encuesta M151 control (#490→GLM director) + BACKLOG-HY3.md modificado en WT; HY4 commit 60f2e00 (M25 columna rota, 6 GLB); Nemotron B-18 7/10 SOSTENIDO + G1 ciclo 22; bug_156 = DeepSeek #491; go4_cerrado_bilateral y m85_nuevo_hallazgo (GO re-baseline 73/25/2) vigentes.
- **PASO 1:** canal sin msg 348 (último = mi 347) → anti-loop → vuelta 36 propia. Numeración official: `proximo_numero.py Ling-3.1-Flash --consume` → **348** ("mensajes usados: 341, max: 347"; pool canal cabeza 348→349; huecos [63,156,157,232,233,234] intactos).
- **CENSOR v36 (git-blob):** manager `047eab5ff111` WT==HEAD **True**; pt.po `d2b567c48e88` WT==HEAD **True**; msgids 276 + 1 header (`msgid ""`) = 277 de v34/v35 — **aclaración metodológica**: el script v36 excluye el header vacío del conteo (v34/v35 lo incluían); el blob es byte-idéntico al de v35, **0 divergencia real**. 0 `.mo`; `git diff HEAD` riel i18n = vacío. **HEAD 9e08a34→60f2e00** = HY4 "feat(blender): B10-bis export 6 GLB columna_rota (M25) + cierre administrativo" (9 archivos, 485 insertions: backlog doc + msg acuse + 6 GLB alta/baja/media) — **NO toca riel i18n ni detector**. WT status 27: 5 M (mis docs v35 sin commit — Cron C los preservará como hizo con v34 en 9e08a34; + BACKLOG-HY3.md ajeno + Logs/NUMEROS_DISPONIBLES pool compartido) + ?? mis Temp/kilo + msg 347 + Log 2333.
- **WATCHDOG v36 (write real):** `scripts/validar_i18n_integridad.py` **rc=0 LIMPIO** (1627 chars): JSON 170/170/170 ES/EN/PT, paridad 0/0/0, placeholders 0, cruzado 159/11/117, 4 copias ES→PT informativas (SETTINGS.HORAS_1/HORAS_H/MIN_1/MIN_M cognatos). Evidencia Temp/kilo/v36_validador_i18n.txt.
- **DETECTOR 8ª hora (Temp/kilo/v36_detector_delta.txt, 82.669 chars):** conteos **IDÉNTICOS a v34/v35** (2ª hora consecutiva con 0 delta — sin flips de flota): 168 checklists; [x]=22649; A1=21; R4=187; A2=233; A3=4; C2=551; SOS=289; FP=4; FORMULA=77; GRIS=209; promovidos=2; A1∩R4=0. **INVARIANTES 9ª hora estables: GRIS 209, FP 4, A3 4, A1∩R4 0** (tendencia v31→v36: A1 29→21, R4 239→187, SOS 313→289 — mejoras de la flota; [x] 22649 congelado desde v34).
- **AUTOCORRECCIÓN §12.1 (error propio v36, corregido y documentado):** wrapper `correr_detector_v36.py` inicial invocó ruta INVENTADA `scripts/detector_autocontradicciones_v8.1.py` (no existe) → rc=2, salida vacía. Diagnóstico: read del wrapper v35 funcional → ruta real `scripts/detectar_autocontradiccion.py` (glob scripts/**/*detector* = 0 hits; la fuente de verdad fue el wrapper previo). Corrección aplicada → reintento **rc=0, 82.669 chars**. Lección: copiar rutas del wrapper previo funcional, no reconstruir de memoria.
- **Trazabilidad git:** `git log -- AUDITORIA` = 9e08a34 (Cron C agnes) → escrituras v34/v35 versionadas; escrituras v35 (§27, ESTADO v35, msg 347, Log 2333, BACKLOG-MASTER 2333) + v36 en WT esperando próximo Cron C (flujo normal de preservación cada 2h; no commiteo yo — regla 0 push/0 commits).
- **Escrituras v36 (report-only, 0 flips, 0 código tocado, 0 commits míos):** msg **348** (`%s`, <4KiB, consumido official) · §28 · ESTADO v36 (01-Backlog header v14-v36) · **Log %s** ritual §6.1.a (pool Logs cabeza 2336→%s) · check_v36.py (24 checks). Scripts/evidencia: Temp/kilo/{leer_estado_v36, censor_v36, correr_validador_i18n_v36, correr_detector_v36, check_v36, cierre_v36, ritual_log_v36}.py + v36_{estado_director, censor_gitsha, validador_i18n, detector_delta}.txt + estado_director_v36.json.
- **Pendientes vuelta 37 (~08:07Z):** standby monitoreo report-only; si agnes responde 345/346/347 (acuse/encargo) ejecutar; centinela git-blob activo; I-08 runtime ms sin Godot MCP (proxy declarado); bug_156 = DeepSeek #491; R4 (187+313+37) y gemelos 256/248 = fundador/editor; deuda alcance 313 entidades = GO fundador.
""" % (MSG, NLOG, str(int(NLOG) + 1))
t = rd(AUD)
if u"## 28." in t:
    print(u"AUDITORIA §28 YA existe — skip")
else:
    wr(AUD, t + SEC28)
    print(u"AUDITORIA §28 append OK (Log %s): %d -> %d chars" % (NLOG, len(t), len(t) + len(SEC28)))

# ============ (2) ESTADO v36 en 01-Backlog-Vueltas ============
BK = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\01-Backlog-Vueltas-31oct.md"
t = rd(BK)
if u"ESTADO v36" in t:
    print(u"backlog ESTADO v36 YA existe — skip")
else:
    HEADER_OLD = u"# Ling-3.1-Flash — ESTADO v14-v35 (cron loop 30-31oct + 06nov, report-only, blindaje riel PT)"
    HEADER_NEW = u"# Ling-3.1-Flash — ESTADO v14-v36 (cron loop 30-31oct + 06nov, report-only, blindaje riel PT)"
    assert HEADER_OLD in t, u"header v14-v35 no encontrado"
    t = t.replace(HEADER_OLD, HEADER_NEW, 1)
    V36 = u"""**ESTADO 2026-11-06 04:12 local (2026-11-06 07:12Z) — VUELTA 36 CIERRE (cron wku_1aee disparó 07:07Z; override 205; WRITE REAL = CENTINELA POST-60f2e00 + WATCHDOG + DETECTOR 8ª HORA + AUTOCORRECCIÓN §12.1, 0 flips):** PASO 0: estado_director **391 claves, 0 nuevas/0 borradas/0 CAMBIADAS vs v35** (diff programático; snapshot Temp/kilo/estado_director_v36.json); sin encargo nuevo; `ling_345/346/347_acusado` aún no registrado (agnes LOTE A 994/1000; anti-loop). PASO 1: canal sin 348 (último = mi 347) → vuelta propia. Helper consumió **348** official (pool canal 348→349; "mensajes usados: 341, max: 347"; huecos [63,156,157,232,233,234] intactos). **CENSOR v36 (git-blob):** manager 047eab5ff111 WT==HEAD True; pt.po d2b567c48e88 WT==HEAD True (276 msgids + 1 header = 277 — script v36 excluye header; blob byte-idéntico, 0 divergencia); 0 .mo; diff riel vacío. **HEAD 9e08a34→60f2e00** = HY4 M25 "B10-bis export 6 GLB columna_rota" (9 files, 485+, docs+GLB; NO toca i18n/detector). WT 27: 5 M (mis docs v35 sin commit — Cron C preservará; + BACKLOG-HY3 ajeno + pool Logs) + ?? mis Temp/kilo + msg 347/Log 2333. **WATCHDOG v36 LIMPIO rc=0** (1627 chars): 170/170/170, paridad 0/0/0, cruzado 159/11/117, 4 cognatos. **DETECTOR 8ª hora rc=0 (82.669 chars): conteos IDÉNTICOS a v34/v35** (2ª hora 0 delta; 9ª hora invariantes): [x]=22649, A1=21, R4=187, A2=233, A3=4, C2=551, SOS=289, FP=4, FORMULA=77, GRIS=209, promovidos=2, A1∩R4=0. **AUTOCORRECCIÓN §12.1:** wrapper detector inicial rc=2 (ruta inventada `detector_autocontradicciones_v8.1.py`); corregida a `scripts/detectar_autocontradiccion.py` (ruta real del wrapper v35); reintento OK. Lección: copiar rutas del wrapper previo funcional. **Escrituras v36:** msg **348** (2567→medir; <4KiB) · §28 AUDITORIA · ESTADO v36 (header v14-v36) · **Log %s** ritual §6.1.a (pool Logs cabeza 2336→%s) · check_v36.py (24 checks). **0 flips. 0 código tocado. 0 commits míos.** Bloqueos vigentes: I-08 runtime ms (sin Godot MCP); gate-2 runtime PT + captura UI (no míos); bug_156 = DeepSeek #491; R4 187+313+37 y gemelos 256/248 = fundador/editor; deuda 313 entidades = GO fundador. Pools post-v36: canal cabeza **349** · Logs cabeza **%s**. PRÓXIMA VUELTA 37 (~08:07Z): standby report-only; si agnes acusa/encarga (345/346/347) ejecutar.

""" % (NLOG, str(int(NLOG) + 1), str(int(NLOG) + 1))
    ANCHOR = u"**ESTADO 2026-11-06 03:15 local"
    assert ANCHOR in t, u"ancla v35 no encontrada"
    t = t.replace(ANCHOR, V36 + ANCHOR, 1)
    wr(BK, t)
    print(u"ESTADO v36 insertado OK; header v14-v36; total chars=%d" % len(t))
