# -*- coding: utf-8 -*-
"""Cierre v37: (1) append §29 AUDITORIA; (2) insertar ESTADO v37 en 01-Backlog-Vueltas + header v14-v37.
Descubre NLOG via glob Logs/*-vuelta37-*.md (correr DESPUÉS del ritual). UTF-8 LF."""
import io
import glob

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

def rd(p):
    return io.open(p, encoding=u"utf-8", newline=u"").read()

def wr(p, s):
    with io.open(p, u"w", encoding=u"utf-8", newline=u"\n") as f:
        f.write(s)

logv37 = glob.glob(RAIZ + u"\\Logs\\*-vuelta37-*.md")
assert logv37, u"log vuelta37 no encontrado — correr ritual primero"
NLOG = logv37[0].split(u"\\")[-1].split(u"-")[0]
MSG = u"349-2026-11-06_05-09-55-de-ling-3.1-flash-a-agnes-3-flash-vuelta37-riego-intacto-y-cola-b.md"

# ============ (1) §29 AUDITORIA append ============
AUD = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md"
SEC29 = u"""

## 29. Vuelta 37 (2026-11-06 04:47-05:10 local / 07:07-08:10Z) — RIEL ÍNTEGRO POST 390652a (HY4 M25) + WATCHDOG LIMPIO + DETECTOR 9ª HORA [x] CONGELADO + AGNES EN COLA B M67/M75/M77 + AUTOCORRECCIÓN §12.1 (SyntaxError propio)

- **PASO 0 (estado_director.json, 391 claves; diff vs snapshot v36: 0 nuevas / 0 borradas / 0 CAMBIADAS — verificado programáticamente tras corregir SyntaxError del script; snapshots v36/v37 en Temp/kilo):** sin encargo nuevo para Ling. `ling_345/346/347/348_acusado` **AÚNO NO REGISTRADOS** — **agnes está verificando COLA B M67/M75/M77** (evidencia en WT: Hy3 #491 04:24 "cola-b-m67-m75-m77-verificacion" → acuse agnes #492 07:30; Hy3 #490 encuesta M151 control → GLM; Log 2337 cola-b; Nemotron #270 acuse / #271 clarificación flota activa; agnes #26 acuse HY4). Anti-loop: no insistir; su cron */40 procesará mis msg cuando libere cola. Campos stale vigentes: `ling_rielp_pt_intacto` (cita 547d1f6/95ee/275 obsoleta; ciegos: HEAD 390652a, pt.po blob d2b567c48e88, 277 msgids con header).
- **PASO 1:** canal sin msg 349 (último = mi 348) → anti-loop → vuelta 37 propia. Numeración official: `proximo_numero.py Ling-3.1-Flash --consume` → **349** ("mensajes usados: 342, max: 348"; pool canal cabeza 349→350; huecos [63,156,157,232,233,234] intactos).
- **CENSOR v37 (git-blob):** manager `047eab5ff111` WT==HEAD **True**; pt.po `d2b567c48e88` WT==HEAD **True**; msgids 276 + 1 header (`msgid ""`) = 277; 0 `.mo`; `git diff HEAD` riel i18n = vacío. **HEAD 60f2e00→390652a** = HY4 "feat(blender): M25 columna entera con capitel, 3 GLB + guardia de capitel 27/0" (Blender; **NO toca riel i18n ni detector** — 3er commit Blender consecutivo: 0a5bbc3 Carreta M157/T04 → 60f2e00 columna_rota → 390652a capitel). **WT 27→47** (desglose): 5 M (mis docs v35/v36 **SIN COMMIT — Cron C de agnes NO disparó desde 9e08a34** (03:16Z); + BACKLOG-HY3.md ajeno + Logs/NUMEROS_DISPONIBLES pool compartido) + ?? mis Temp/kilo (scripts/evidencias v35-v37) + msg 347/348 + Log 2333/2336 + ajenos (Hy3 #490/491/492, acuses HY4 #26/#27, Nemotron #270/271, Log 2334 encuesta-M151 / 2337 cola-b, `game/isla-ancestral/scripts/coleccionables/probe_m73_g1_categoria_completed.gd` de flota — NO MÍO, no tocar).
- **WATCHDOG v37 (write real):** `scripts/validar_i18n_integridad.py` **rc=0 LIMPIO** (1627 chars, idéntico a v34-v36): JSON 170/170/170 ES/EN/PT, paridad 0/0/0, placeholders 0, cruzado 159/11/117, 4 copias ES→PT informativas (SETTINGS.HORAS/MIN cognatos). Evidencia Temp/kilo/v37_validador_i18n.txt.
- **DETECTOR 9ª hora (Temp/kilo/v37_detector_delta.txt, 82.591 chars, exit 0):** conteos **IDÉNTICOS a v34/v35/v36** — **10ª hora de invariantes estables; [x]=22649 congelado 3ª hora consecutiva** (sin flips de flota): 168 checklists; [x]=22649; A1=21; R4=187; A2=233; A3=4; C2=551; SOS=289; FP=4; FORMULA=77; GRIS=209; promovidos=2; A1∩R4=0. Nota de longitud: v36 midió 82.669 chars (detalle transitorio en listados); v37 volvió a 82.591 (= v34/v35); **los contadores son iguales en los 4** — la variación de longitud es del detalle dinámico (SOS/módulos), no de los invariantes.
- **AUTOCORRECCIÓN §12.1 (error propio v37, corregido y documentado):** `leer_estado_v37.py` inicial lanzó SyntaxError — paréntesis extra `[:250]))` en 2 líneas (copy-paste del template v36 con typo). Diagnóstico: SyntaxError al vuelo (sin efectos colaterales — script Temp/kilo, no tocó repo). Corrección via edit (replaceAll `[:250]))` → `[:250])`) → re-run OK: 391 claves, 0 nuevas/0 borradas/0 cambiadas vs v36. Lección: al copiar templates de scripts, verificar paréntesis línea por línea (tercera autocorrección propia del ciclo: v34 ritual/cierre formato, v36 ruta detector, v37 syntax script).
- **Trazabilidad git:** `git log -- AUDITORIA` = 9e08a34 (Cron C agnes, 03:16Z) → escrituras v34 versionadas; **v35/v36/v37 en WT sin commit** (5 archivos M míos + ?? msg 347/348 + Log 2333/2336 + pools) — Cron C no disparó en 3 vueltas (19:07Z→08:07Z ≈ 5h sin preservación; flujo normal cuando la directora está en verificación pesada cola B; no commiteo yo — regla 0 push/0 commits). Riesgo aceptado: mis escrituras están en disco y son verificables (check_v37 PASS).
- **Escrituras v37 (report-only, 0 flips, 0 código tocado, 0 commits míos):** msg **349** (`%s`, <4KiB, consumido official) · §29 · ESTADO v37 (01-Backlog header v14-v37) · **Log %s** ritual §6.1.a (pool Logs cabeza 2339→%s) · check_v37.py (24 checks). Scripts/evidencia: Temp/kilo/{leer_estado_v37, censor_v37, correr_validador_i18n_v37, correr_detector_v37, check_v37, cierre_v37, ritual_log_v37}.py + v37_{estado_director, censor_gitsha, validador_i18n, detector_delta}.txt + estado_director_v37.json.
- **Pendientes vuelta 38 (~09:07Z):** standby monitoreo report-only; si agnes acusa/encarga (345-348) ejecutar; centinela git-blob activo; observar próximo Cron C (preservación mis docs v35-v37 — si no dispara en 2 vueltas más, avisar a agnes via estado_director campo observación, NO via canal para no saturar); I-08 runtime ms sin Godot MCP; bug_156 = DeepSeek #491; R4 (187+313+37) y gemelos 256/248 = fundador/editor; deuda 313 entidades = GO fundador.
""" % (MSG, NLOG, str(int(NLOG) + 1))
t = rd(AUD)
if u"## 29." in t:
    print(u"AUDITORIA §29 YA existe — skip")
else:
    wr(AUD, t + SEC29)
    print(u"AUDITORIA §29 append OK (Log %s): %d -> %d chars" % (NLOG, len(t), len(t) + len(SEC29)))

# ============ (2) ESTADO v37 en 01-Backlog-Vueltas ============
BK = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\01-Backlog-Vueltas-31oct.md"
t = rd(BK)
if u"ESTADO v37" in t:
    print(u"backlog ESTADO v37 YA existe — skip")
else:
    HEADER_OLD = u"# Ling-3.1-Flash — ESTADO v14-v36 (cron loop 30-31oct + 06nov, report-only, blindaje riel PT)"
    HEADER_NEW = u"# Ling-3.1-Flash — ESTADO v14-v37 (cron loop 30-31oct + 06nov, report-only, blindaje riel PT)"
    assert HEADER_OLD in t, u"header v14-v36 no encontrado"
    t = t.replace(HEADER_OLD, HEADER_NEW, 1)
    V37 = u"""**ESTADO 2026-11-06 05:10 local (2026-11-06 08:10Z) — VUELTA 37 CIERRE (cron wku_1aee disparó 08:07Z; override 205; WRITE REAL = CENTINELA POST-390652a + WATCHDOG + DETECTOR 9ª HORA + AUTOCORRECCIÓN §12.1, 0 flips):** PASO 0: estado_director **391 claves, 0 nuevas/0 borradas/0 CAMBIADAS vs v36** (diff programático tras corregir SyntaxError propio del script; snapshot Temp/kilo/estado_director_v37.json); sin encargo nuevo; `ling_345-348_acusado` aún no registrado — **agnes en COLA B M67/M75/M77** (Hy3 #491→agnes, acuse agnes #492 07:30, Log 2337; Nemotron #270/271; anti-loop, no insisto). PASO 1: canal sin 349 (último = mi 348) → vuelta propia. Helper consumió **349** official (pool canal 349→350; "mensajes usados: 342, max: 348"; huecos [63,156,157,232,233,234] intactos). **CENSOR v37 (git-blob):** manager 047eab5ff111 WT==HEAD True; pt.po d2b567c48e88 WT==HEAD True (276 msgids + header = 277); 0 .mo; diff riel vacío. **HEAD 60f2e00→390652a** = HY4 M25 "columna entera con capitel, 3 GLB + guardia 27/0" (3er commit Blender consecutivo; NO toca i18n/detector). **WT 27→47**: 5 M (mis docs v35/v36 SIN COMMIT — **Cron C NO disparó desde 9e08a34**; + BACKLOG-HY3 ajeno + pool Logs) + ?? mis Temp/kilo + msg 347/348 + Log 2333/2336 + ajenos (Hy3 #490/491/492 cola-B, acuses HY4 #26/#27, Nemotron #270/271, Log 2334/2337, probe_m73_g1 de flota en game/). **WATCHDOG v37 LIMPIO rc=0** (1627 chars): 170/170/170, paridad 0/0/0, cruzado 159/11/117, 4 cognatos. **DETECTOR 9ª hora exit 0 (82.591 chars): conteos IDÉNTICOS** — 10ª hora de invariantes; **[x]=22649 congelado 3ª hora** (sin flips flota): A1=21, R4=187, A2=233, A3=4, C2=551, SOS=289, FP=4, FORMULA=77, GRIS=209, promovidos=2, A1∩R4=0. **AUTOCORRECCIÓN §12.1:** SyntaxError propio en leer_estado_v37.py (`[:250]))` ×2 líneas, copy-paste) → edit corregido → re-run OK (diff 0). 3ª autocorrección propia del ciclo (v34 formato ritual/cierre, v36 ruta detector, v37 syntax script). **Escrituras v37:** msg **349** (<4KiB) · §29 AUDITORIA · ESTADO v37 (header v14-v37) · **Log %s** ritual §6.1.a (pool Logs cabeza 2339→%s) · check_v37.py (24 checks). **0 flips. 0 código tocado. 0 commits míos.** Escrituras v35-v37 en WT esperando próximo Cron C (observar; si no dispara en 2 vueltas más, notar en estado_director vía campo observación — NO saturar canal). Bloqueos vigentes: I-08 runtime ms (sin Godot MCP); gate-2 runtime PT + captura UI (no míos); bug_156 = DeepSeek #491; R4 187+313+37 y gemelos 256/248 = fundador/editor; deuda 313 entidades = GO fundador. Pools post-v37: canal cabeza **350** · Logs cabeza **%s**. PRÓXIMA VUELTA 38 (~09:07Z): standby report-only; si agnes acusa/encarga (345-348) ejecutar.

""" % (NLOG, str(int(NLOG) + 1), str(int(NLOG) + 1))
    ANCHOR = u"**ESTADO 2026-11-06 04:12 local"
    assert ANCHOR in t, u"ancla v36 no encontrada"
    t = t.replace(ANCHOR, V37 + ANCHOR, 1)
    wr(BK, t)
    print(u"ESTADO v37 insertado OK; header v14-v37; total chars=%d" % len(t))
