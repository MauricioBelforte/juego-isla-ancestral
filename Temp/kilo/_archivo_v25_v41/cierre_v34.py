# -*- coding: utf-8 -*-
"""Cierre v34: (1) append §26 AUDITORIA; (2) insertar ESTADO v34 en 01-Backlog-Vueltas + header v14-v34.
Descubre NLOG via glob Logs/*-vuelta34-*.md (robusto a drift de pool). UTF-8 LF."""
import io
import glob

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

def rd(p):
    return io.open(p, encoding=u"utf-8", newline=u"").read()

def wr(p, s):
    with io.open(p, u"w", encoding=u"utf-8", newline=u"\n") as f:
        f.write(s)

logv34 = glob.glob(RAIZ + u"\\Logs\\*-vuelta34-*.md")
assert logv34, u"log vuelta34 no encontrado — correr ritual primero"
NLOG = logv34[0].split(u"\\")[-1].split(u"-")[0]
MSG = u"346-2026-11-06_02-17-08-de-ling-3.1-flash-a-agnes-3-flash-vuelta34-centinela-corregido-y-riel-vivo.md"

# ============ (1) §26 AUDITORIA append ============
AUD = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md"
SEC26 = u"""

## 26. Vuelta 34 (2026-11-06 02:07-02:20 local / 05:07-05:20Z) — CENTINELA: ALARMA FALSA RESUELTA (lección metodológica) + RIEL PT ÍNTEGRO + WATCHDOG LIMPIO + WIRING CI VERIFICADO

- **PASO 0 (estado_director.json, 391 claves SIN CAMBIO; snapshot Temp/kilo/estado_director_v34.json):** sin encargo nuevo para Ling. Campos leídos: `ling_342_acusado` (mi msg 342, G.3 687 literales, F.1 JSON-vs-.po no es bug), `agnes` (983 procesado; 985/986 RATIFICADOS; cron */40 reencendido por fundador; `ling_345_acusado` AÚN NO REGISTRADO → su cron :20/:40 lo procesará), `step_5` (186 RATIFICADO; M23 86/17/2; M33 revert 15 flips pendiente en Step-5), `deepseek_453_cableado` (test_diario_persist cableado en quality.yml, GATE VIVO 4/4 — verificado por mí en disco L679), `deepseek_489_tanda25` HC-06 (bug_156, DeepSeek #491), `hy3` (cross-QA M87 RATIFICADO 333: 131/136; pendientes_real 257), `m85_rebaseline` (directora YA ejecutó: 99/1/0→73/25/2; 24/26 restauración silenciosa cron-bulk + 2/26 Beam T246-85; ack), `m87_cerrado_m87` (140/0/0 candidato sello; deuda alcance 313 entidades GO fundador), `ling_design_docs.lote2_asignado` (**STALE**: lote2 CERRADO desde v29 — informe 259, Log 2177, 2026-10-24; evidencia 03-Backlog-Anexos-PT L656-660), `ling_rielp_pt_intacto` (**STALE**: cita 547d1f6/95ee/275 → hoy HEAD 13d2471, pt.po blob d2b567c48e88, 277 msgids). `gemelos_pendientes_saneo`: 256/248 (Ling) siguen para fundador (no renumbo a mano).
- **PASO 1:** canal sin novedad (último = mi 345; glob 35*.md vacío; sin 346 de agnes) → anti-loop → vuelta 34 propia. Numeración official: `proximo_numero.py Ling-3.1-Flash --consume` → **346** ("mensajes usados: 339, max: 345; pool cabeza 346→347"; huecos [63,156,157,232,233,234] intactos).
- **HALLAZGO v34-1 — CENTINELA: ALARMA FALSA + CORRECCIÓN METODOLÓGICA (write real de la vuelta):** censor inicial (sha1-crudo hashlib) reportó manager `BFDC83CC89` ≠ `047eab5ff111` (v32) → sospecha "alguien tocó mi riel PT". Verificación git: `git hash-object` WT = `047eab5ff111dffdc3f3b48f8241c787e104c0a5` == `git rev-parse HEAD:.../localization_manager.gd` = mismo valor → **INTACTO desde 071a2f9 (28oct, GO#4 PT)**; `git diff HEAD` sobre riel i18n = VACÍO. Causa raíz: comparé sha1-crudo (hashlib sobre bytes) contra git-blob-sha (SHA-1 sobre "blob <len>\\0"+contenido) — algoritmos distintos, mismo archivo. **FALSO POSITIVO MÍO.** pt.po: blob `d2b567c48e88cfa6d9d22d76eaf31804e1e9028c` WT==HEAD True (sha1-crudo 6E5C19683F; 277 msgids; 0 .mo). Centinela corregido: `Temp/kilo/censor_v34_gitsha.py` + `v34_censor_gitsha.txt` (método git canónico). **Lección para la flota (documentada en el censor): fingerprint git = git hash-object / rev-parse HEAD:path; hashlib crudo solo comparable consigo mismo.** Mi centinela SHA vivo (H1 v32) funciona — el defecto era el método de comparación, no el concepto.
- **HALLAZGO v34-2 — HEAD 0d750af→13d2471:** 4 commits Blender de HY4 (T-01a Barquita de Aurora, T-01b Globo del Viento, T-01c Perla Ancestral, T-01d Gran Vapor; M67/M68; 3 GLB + cierre administrativo c/u; Logs 2321-2325 de HY4). Nada toca i18n. WT `git status --porcelain` = 127 archivos (estable vs v33); 19.982 archivos trackeados (`git ls-files`).
- **HALLAZGO v34-3 — WIRING CI (I-09 actualizado):** `.github/workflows/quality.yml` L679: `suite --script scripts/diario/test_diario_persist.gd` **CABLEADO** (comentario L669: persistencia real M55; esto es el cableado DeepSeek #453, GATE VIVO) + L553 `test_persistencia_m64.gd`. `qa_dirty_item4` (suite muerta Familia C, BUG-152) **SIN cablear** — coherente con mi I-09 v33. Validación i18n NO en CI por diseño (es herramienta de agente; mi watchdog corre cada vuelta).
- **WATCHDOG I18N v34 (write real):** `scripts/validar_i18n_integridad.py` = **LIMPIO** — JSON 170/170/170 ES/EN/PT; paridad de claves 0/0/0; placeholders 0 discrepancias; cruzado 159/11/117 estable; 4 copias ES→PT informativas (SETTINGS.HORAS_1/HORAS_H/MIN_1/MIN_M = cognatos legítimos). Evidencia: `Temp/kilo/v34_validador_i18n.txt` (exit 0).
- **DETECTOR v8.1 6ª hora (Temp/kilo/v34_detector_delta.txt, 82.591 chars):** 168 checklists; [x]=22649 (v29: 23003; −354 = degradaciones legítimas de la flota + re-baselines P-100 + re-baseline M85 de la directora); A1-GRAVE=21 (v29: 29 ↓); R4-GRAVE=187 (v29: 239 ↓); A2=233; A3=4; C2=551; SOS=289; FP=4; FORMULA=77; GRIS=209; promovidos=2; A1∩R4=0. **INVARIANTES estables 6ª hora: GRIS 209, FP 4, A3 4, A1∩R4 0.** Muestra A1: 50-Vegetacion 6, 110-Debug-Menu 4, 94-Retencion 3, 04-Game-Engine 2, 73-Coleccionables 2, 76-Multijugador 2, 137-Prototipo 1, 61-Rendimiento 1.
- **Escrituras v34 (report-only, 0 flips, 0 código tocado, 0 commits):** msg **346** (`%s`, <4KiB, consumido official) · §26 · ESTADO v34 (01-Backlog header v14-v34) · **Log %s** ritual §6.1.a (pool Logs cabeza 2331→%s) · check_v34.py (19 checks). Scripts/evidencia: Temp/kilo/{correr_validador_i18n_v34, correr_detector_v34, censor_v34_gitsha, check_v34, cierre_v34, ritual_log_v34}.py + v34_{validador_i18n, detector_delta, censor_gitsha}.txt.
- **Pendientes vuelta 35 (~06:07Z):** standby monitoreo report-only; si agnes responde 345 (acuse de mi tanda/encargo nuevo) ejecutar; centinela ya corregido (git-blob); I-08 runtime ms sigue sin Godot MCP (proxy declarado); bug_156 propiedad DeepSeek #491 (HC-06); deuda alcance 313 entidades = GO fundador; R4 (187+313+37) y gemelos 256/248 = fundador/editor.
""" % (MSG, NLOG, str(int(NLOG) + 1))
t = rd(AUD)
if u"## 26." in t:
    print(u"AUDITORIA §26 YA existe (append previo OK) — skip")
else:
    wr(AUD, t + SEC26)
    print(u"AUDITORIA §26 append OK (Log %s): %d -> %d chars" % (NLOG, len(t), len(t) + len(SEC26)))

# ============ (2) ESTADO v34 en 01-Backlog-Vueltas ============
BK = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\01-Backlog-Vueltas-31oct.md"
t = rd(BK)
assert u"ESTADO v34" not in t, u"v34 ya existe"
HEADER_OLD = u"# Ling-3.1-Flash — ESTADO v14-v33 (cron loop 30-31oct + 06nov, report-only, blindaje riel PT)"
HEADER_NEW = u"# Ling-3.1-Flash — ESTADO v14-v34 (cron loop 30-31oct + 06nov, report-only, blindaje riel PT)"
assert HEADER_OLD in t, u"header v14-v33 no encontrado"
t = t.replace(HEADER_OLD, HEADER_NEW, 1)
V34 = u"""**ESTADO 2026-11-06 02:20 local (2026-11-06 05:20Z) — VUELTA 34 CIERRE (cron wku_1aee disparó 05:07Z; override 205; WRITE REAL = CENTINELA CORREGIDO + RIEL VERIFICADO + WATCHDOG LIMPIO, 0 flips):** PASO 0: estado_director **391 claves SIN CAMBIO** (snapshot Temp/kilo/estado_director_v34.json); sin encargo nuevo; `ling_345_acusado` AÚN NO REGISTRADO (cron */40 de agnes lo procesará). 2 campos STALE míos reportados: `ling_design_docs.lote2_asignado` (CERRADO v29: informe 259, Log 2177; evidencia 03-Backlog-Anexos-PT L656-660) y `ling_rielp_pt_intacto` (cita 547d1f6/95ee/275 obsoleta). PASO 1: canal sin novedad (último = mi 345; glob 35*.md vacío) → anti-loop → vuelta 34 propia. Helper consumió **346** official (pool canal cabeza 346→347; "mensajes usados: 339, max: 345"; huecos [63,156,157,232,233,234] intactos). **HALLAZGO v34-1 (CENTINELA — ALARMA FALSA + LECCIÓN):** censor inicial (sha1-crudo hashlib) reportó manager BFDC83CC89 ≠ 047eab5ff111 → sospecha de mutación de mi riel. Verificación git: hash-object WT = 047eab5ff111 == rev-parse HEAD:manager → **INTACTO desde 071a2f9 (28oct)**; git diff HEAD riel i18n VACÍO. Causa: comparé sha1-crudo vs git-blob-sha (algoritmos distintos) — FALSO POSITIVO MÍO. pt.po blob d2b567c48e88 WT==HEAD True (crudo 6E5C; 277 msgids; 0 .mo). Centinela CORREGIDO a método git canónico (Temp/kilo/censor_v34_gitsha.py + v34_censor_gitsha.txt). Lección flota: fingerprint git = git hash-object/rev-parse. **HALLAZGO v34-2:** HEAD 0d750af→13d2471 = 4 commits Blender HY4 (T-01a..d Barquita/Globo/Perla/Gran Vapor, M67/M68); nada toca i18n; WT status 127 (estable). **HALLAZGO v34-3 (I-09 wiring actualizado):** quality.yml L679 cablea test_diario_persist.gd (DeepSeek #453 GATE VIVO) + L553 test_persistencia_m64; qa_dirty_item4 (Familia C) SIN cablear; validación i18n NO en CI (herramienta de agente). **WATCHDOG v34:** validar_i18n_integridad.py **LIMPIO** (170/170/170; paridad 0/0/0; placeholders 0; cruzado 159/11/117; 4 copias ES→PT cognatos informativas). **DETECTOR 6ª hora** (82.591 chars): 168 checklists; [x]=22649 (v29: 23003; −354 degradaciones legítimas flota); A1=21 (v29: 29); R4=187 (v29: 239); A2=233; A3=4; C2=551; SOS=289; FP=4; FORMULA=77; GRIS=209; promovidos=2; A1∩R4=0; INVARIANTES estables (GRIS 209, FP 4, A3 4, A1∩R4 0). **Escrituras v34:** msg **346** (<4KiB) · §26 AUDITORIA · ESTADO v34 (header v14-v34) · **Log %s** ritual §6.1.a (pool Logs cabeza 2331→%s) · check_v34.py (19 checks). **0 flips. 0 código tocado. 0 commits.** Bloqueos vigentes: I-08 runtime ms (sin Godot MCP); gate-2 runtime PT + captura UI (no míos); bug_156 = DeepSeek #491 (HC-06; riel no afectado); R4 187+313+37 y gemelos 256/248 = fundador/editor; deuda 313 entidades = GO fundador. Pools post-v34: canal cabeza **347** · Logs cabeza **%s**. PRÓXIMA VUELTA 35 (~06:07Z): standby monitoreo report-only; si agnes responde 345 (acuse/encargo) ejecutar.

""" % (NLOG, str(int(NLOG) + 1), str(int(NLOG) + 1))
ANCHOR = u"**ESTADO 2026-11-06 01:19 local"
assert ANCHOR in t, u"ancla v33 no encontrada"
t = t.replace(ANCHOR, V34 + ANCHOR, 1)
wr(BK, t)
print(u"ESTADO v34 insertado OK; header v14-v34; total chars=%d" % len(t))
