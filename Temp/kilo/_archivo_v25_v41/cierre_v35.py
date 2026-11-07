# -*- coding: utf-8 -*-
"""Cierre v35: (1) append §27 AUDITORIA; (2) insertar ESTADO v35 en 01-Backlog-Vueltas + header v14-v35.
Descubre NLOG via glob Logs/*-vuelta35-*.md (correr DESPUÉS del ritual). UTF-8 LF."""
import io
import glob

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

def rd(p):
    return io.open(p, encoding=u"utf-8", newline=u"").read()

def wr(p, s):
    with io.open(p, u"w", encoding=u"utf-8", newline=u"\n") as f:
        f.write(s)

logv35 = glob.glob(RAIZ + u"\\Logs\\*-vuelta35-*.md")
assert logv35, u"log vuelta35 no encontrado — correr ritual primero"
NLOG = logv35[0].split(u"\\")[-1].split(u"-")[0]
MSG = u"347-2026-11-06_03-12-00-de-ling-3.1-flash-a-agnes-3-flash-vuelta35-riel-en-git-y-watchdog-limpio.md"

# ============ (1) §27 AUDITORIA append ============
AUD = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md"
SEC27 = u"""

## 27. Vuelta 35 (2026-11-06 03:07-03:15 local / 06:07-06:15Z) — ESCRITURAS v34 VERSIONADAS EN GIT (Cron C 9e08a34) + RIEL ÍNTEGRO + WATCHDOG LIMPIO + DETECTOR 7ª HORA 0 DELTA

- **PASO 0 (estado_director.json, 391 claves; 0 nuevas / 0 borradas vs snapshot v34 — diff verificado; snapshot Temp/kilo/estado_director_v35.json):** sin encargo nuevo para Ling. Campos relevantes: `ling_338/340/342_acusado` (mis v29/v30/v31 registrados); `ling_345/346_acusado` **AÚN NO REGISTRADOS** (procesamiento agnes pendiente — su cron */40); `ling_design_docs.lote2` **ACTUALIZADO POR LA DIRECTORA a "CERRADO"** (barrido 23/23, riela agotada, ack a mi cierre v29/informe 259/Log 2177) + nota "Gemelo 260 saneo" (histórico 26oct — verificado: canal 260-269 archivos únicos, sin duplicados; numeración actual limpia); `ling_rielp_pt_intacto` sigue STALE (cita 547d1f6/95ee/275; ciegos actuales: HEAD 9e08a34, pt.po blob d2b567c48e88, 277 msgids). Flota: `agnes` LOTE A integral (994/1000) de verificación de producción Beam; `hy3` M28/M27 RATIFICADO+COMMITIDO (331) + cross-QA M87 RATIFICADO (333); `nemotron` B-18 7/10 SOSTENIDO + G1 ciclo 22/36; `bug_156_i18n_json` DeepSeek #491 (abierto); `m85_rebaseline` ack; `go4_cerrado_bilateral` vigente; `gemelos_pendientes_saneo` 256/248 (Ling) + 209/210 (Step-5) = fundador.
- **PASO 1:** canal sin msg 347 (último = mi 346) → anti-loop → vuelta 35 propia. Numeración official: `proximo_numero.py Ling-3.1-Flash --consume` → **347** ("mensajes usados: 340, max: 346"; pool cabeza 347→348; huecos [63,156,157,232,233,234] intactos).
- **CENSOR v35 (método git-blob, corregido en v34):** manager `047eab5ff111` WT==HEAD **True** (intacto desde 071a2f9); pt.po `d2b567c48e88` WT==HEAD **True** (crudo 6E5C; 277 msgids; 0 .mo); `git diff HEAD` riel i18n = vacío. **HEAD 13d2471→9e08a34** en 1h (2 commits): `9e08a34` Cron C agnes — "Se preservaron avances de la jornada 5nov: reestructura BACKLOGS/ (8 modelos), 25+ acuses cron, estado_director, scripts parcheados (verificar_pool v2, censo_drift, renumerar_canal)"; `0a5bbc3` HY4 — feat(blender) T-02 Carreta Ancestral (M157/T04), 3 GLB + cierre PARCIAL. **WT status 127→4 archivos** (solo mis scripts Temp/kilo de sesión, untracked) — la flota commiteó todo el worktree.
- **TRAZABILIDAD CERRADA (hallazgo v35):** `git log --oneline -- AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md` = **9e08a34** → mis escrituras v34 (§26, ESTADO v33/v34, msg 345/346, Log 2330/2331, BACKLOG-MASTER) están **versionadas en git** por el Cron C de la directora. Mi ciclo report-only queda auditado en HEAD sin acción propia de commit (regla: 0 push, 0 commits míos).
- **WATCHDOG v35 (write real):** `scripts/validar_i18n_integridad.py` exit 0 **LIMPIO** (1520 chars, idéntico a v34): JSON 170/170/170 ES/EN/PT, paridad 0/0/0, placeholders 0, cruzado 159/11/117, 4 copias ES→PT informativas (SETTINGS.HORAS_1/HORAS_H/MIN_1/MIN_M cognatos). Evidencia Temp/kilo/v35_validador_i18n.txt.
- **DETECTOR v8.1 7ª hora (Temp/kilo/v35_detector_delta.txt):** 82.591 chars — **conteos IDÉNTICOS a v34 (0 delta en 1h: sin flips de flota esta hora)**: 168 checklists; [x]=22649; A1=21; R4=187; A2=233; A3=4; C2=551; SOS=289; FP=4; FORMULA=77; GRIS=209; promovidos=2; A1∩R4=0. **INVARIANTES estables 7ª hora: GRIS 209, FP 4, A3 4, A1∩R4 0** (v31→v35: A1 29→21, R4 239→187, SOS 313→289 — mejoras de la flota; invariantes congelados).
- **WIRING CI post-Cron C:** `.github/workflows/quality.yml` L679 `test_diario_persist.gd` + L553 `test_persistencia_m64.gd` intactos (DeepSeek #453 GATE VIVO). `qa_dirty_item4` (suite muerta Familia C, BUG-152) sin cablear. Validación i18n no en CI (herramienta de agente por diseño).
- **Escrituras v35 (report-only, 0 flips, 0 código tocado, 0 commits míos):** msg **347** (`%s`, <4KiB, consumido official) · §27 · ESTADO v35 (01-Backlog header v14-v35) · **Log %s** ritual §6.1.a (pool Logs cabeza 2333→%s) · check_v35.py (23 checks). Scripts/evidencia: Temp/kilo/{leer_estado_v35, censor_v35, correr_validador_i18n_v35, correr_detector_v35, check_v35, cierre_v35, ritual_log_v35}.py + v35_{estado_director, censor_gitsha, validador_i18n, detector_delta}.txt + estado_director_v35.json.
- **Pendientes vuelta 36 (~07:07Z):** standby monitoreo report-only; si agnes responde 345/346 (acuse de mi tanda/encargo nuevo) ejecutar; centinela git-blob activo; I-08 runtime ms sin Godot MCP (proxy declarado); bug_156 = DeepSeek #491 (HC-06); R4 (187+313+37) y gemelos 256/248 = fundador/editor; deuda alcance 313 entidades = GO fundador.
""" % (MSG, NLOG, str(int(NLOG) + 1))
t = rd(AUD)
if u"## 27." in t:
    print(u"AUDITORIA §27 YA existe — skip")
else:
    wr(AUD, t + SEC27)
    print(u"AUDITORIA §27 append OK (Log %s): %d -> %d chars" % (NLOG, len(t), len(t) + len(SEC27)))

# ============ (2) ESTADO v35 en 01-Backlog-Vueltas ============
BK = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\01-Backlog-Vueltas-31oct.md"
t = rd(BK)
if u"ESTADO v35" in t:
    print(u"backlog ESTADO v35 YA existe — skip")
else:
    HEADER_OLD = u"# Ling-3.1-Flash — ESTADO v14-v34 (cron loop 30-31oct + 06nov, report-only, blindaje riel PT)"
    HEADER_NEW = u"# Ling-3.1-Flash — ESTADO v14-v35 (cron loop 30-31oct + 06nov, report-only, blindaje riel PT)"
    assert HEADER_OLD in t, u"header v14-v34 no encontrado"
    t = t.replace(HEADER_OLD, HEADER_NEW, 1)
    V35 = u"""**ESTADO 2026-11-06 03:15 local (2026-11-06 06:15Z) — VUELTA 35 CIERRE (cron wku_1aee disparó 06:07Z; override 205; WRITE REAL = TRAZABILIDAD GIT CERRADA + CENTINELA + WATCHDOG + DETECTOR, 0 flips):** PASO 0: estado_director **391 claves, 0 nuevas/0 borradas vs v34** (diff verificado; snapshot Temp/kilo/estado_director_v35.json); sin encargo nuevo. ACK: directora actualizó `ling_design_docs.lote2` a CERRADO (mi cierre v29 reconocido); "Gemelo 260 saneo" = histórico 26oct (canal 260-269 único verificado); `ling_345/346_acusado` aún no registrado (agnes pendiente). PASO 1: canal sin 347 (último = mi 346) → anti-loop → vuelta propia. Helper consumió **347** official (pool canal 347→348; "mensajes usados: 340, max: 346"; huecos [63,156,157,232,233,234] intactos). **CENSOR v35 (git-blob):** manager 047eab5ff111 WT==HEAD True; pt.po d2b567c48e88 WT==HEAD True (crudo 6E5C; 277 msgids; 0 .mo); diff riel vacío. **HEAD 13d2471→9e08a34** (2 commits: 9e08a34 Cron C preservación 5nov — BACKLOGS 8 modelos, 25+ acuses, estado_director, scripts verificar_pool v2/censo_drift/renumerar_canal; 0a5bbc3 HY4 Carreta Ancestral M157/T04). **WT 127→4** (solo mis Temp/kilo untracked). **TRAZABILIDAD CERRADA:** git log -- AUDITORIA = 9e08a34 → escrituras v34 (§26, ESTADO v33/v34, msg 345/346, Log 2330/2331) VERSIONADAS EN GIT por Cron C. **WATCHDOG v35 LIMPIO** (exit 0): 170/170/170, paridad 0/0/0, cruzado 159/11/117, 4 copias ES→PT cognatos. **DETECTOR 7ª hora: 0 delta vs v34** (82.591 chars exactos — sin flips de flota esta hora): [x]=22649, A1=21, R4=187, A2=233, A3=4, C2=551, SOS=289, FP=4, FORMULA=77, GRIS=209, promovidos=2, A1∩R4=0; INVARIANTES estables (GRIS 209, FP 4, A3 4, A1∩R4 0); tendencia v31→v35: A1 29→21, R4 239→187, SOS 313→289. **WIRING CI post-Cron C:** quality.yml L679 test_diario_persist + L553 test_persistencia_m64 intactos (DeepSeek #453 GATE VIVO); qa_dirty_item4 sin cablear. **Escrituras v35:** msg **347** (<4KiB) · §27 AUDITORIA · ESTADO v35 (header v14-v35) · **Log %s** ritual §6.1.a (pool Logs cabeza 2333→%s) · check_v35.py (23 checks). **0 flips. 0 código tocado. 0 commits míos** (Cron C commiteó mis docs v34). Bloqueos vigentes: I-08 runtime ms (sin Godot MCP); gate-2 runtime PT + captura UI (no míos); bug_156 = DeepSeek #491; R4 187+313+37 y gemelos 256/248 = fundador/editor; deuda 313 entidades = GO fundador. Pools post-v35: canal cabeza **348** · Logs cabeza **%s**. PRÓXIMA VUELTA 36 (~07:07Z): standby monitoreo report-only; si agnes responde 345/346 ejecutar.

""" % (NLOG, str(int(NLOG) + 1), str(int(NLOG) + 1))
    ANCHOR = u"**ESTADO 2026-11-06 02:20 local"
    assert ANCHOR in t, u"ancla v34 no encontrada"
    t = t.replace(ANCHOR, V35 + ANCHOR, 1)
    wr(BK, t)
    print(u"ESTADO v35 insertado OK; header v14-v35; total chars=%d" % len(t))
