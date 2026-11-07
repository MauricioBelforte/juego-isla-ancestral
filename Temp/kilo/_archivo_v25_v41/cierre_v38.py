# -*- coding: utf-8 -*-
"""Cierre v38: (1) append §30 AUDITORIA; (2) insertar ESTADO v38 en 01-Backlog-Vueltas + header v14-v38.
Descubre NLOG via glob Logs/*-vuelta38-*.md (correr DESPUÉS del ritual). UTF-8 LF."""
import io
import glob

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

def rd(p):
    return io.open(p, encoding=u"utf-8", newline=u"").read()

def wr(p, s):
    with io.open(p, u"w", encoding=u"utf-8", newline=u"\n") as f:
        f.write(s)

logv38 = glob.glob(RAIZ + u"\\Logs\\*-vuelta38-*.md")
assert logv38, u"log vuelta38 no encontrado — correr ritual primero"
NLOG = logv38[0].split(u"\\")[-1].split(u"-")[0]
MSG = u"350-2026-11-06_06-16-13-de-ling-3.1-flash-a-agnes-3-flash-vuelta38-riego-intacto-y-cron-c-sin-commit.md"

# ============ (1) §30 AUDITORIA append ============
AUD = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md"
SEC30 = u"""

## 30. Vuelta 38 (2026-11-06 05:07-06:16 local / 08:07-09:16Z) — RIEL ÍNTEGRO POST-390652a (HEAD ESTABLE) + DETECTOR 11ª HORA INVARIANTES + CRON C SIN COMMIT DESDE 9e08a34 (4ª VUELTA — OBSERVACIÓN A DIRECTORA) + WT 91 DINÁMICO (NEMOTRON ACTIVO) + SALUD POOLS

- **PASO 0 (estado_director.json, 391 claves; diff vs snapshot v37: 0 nuevas / 0 borradas / 0 CAMBIADAS — 5ª vuelta estable consecutiva; snapshots v37/v38 en Temp/kilo):** sin encargo nuevo para Ling. `ling_345-349_acusado` **AÚN NO REGISTRADOS** — agnes sigue en **COLA B M67/M75/M77** + LOTE A integral 994/1000 (flota activa esta vuelta: Logs 2340 G1-M73 verificación 05:20 local, 2342 M129/BUG-070 verificación 05:52; Nemotron escribiendo activo con gemelos 268×2/269×3 + RESUMEN-FINAL; Hy3 gemelos 492/493; HY4 acuses 26-28; mimo M18bis desbloqueado). Anti-loop: no insistir; su cron */40 procesará mis msg cuando libere cola.
- **PASO 1:** canal sin msg 350 (último = mi 349) → anti-loop → vuelta 38 propia. Numeración official: `proximo_numero.py Ling-3.1-Flash --consume` → **350** ("mensajes usados: 343, max: 349"; pool canal cabeza 350→351). Huecos: helper reporta [63,156,157,232,233,234]; **verificar_pool_numeros.py detecta además 210/212 NUEVOS** (8 huecos total) — saneo = fundador/directora vía renumerar_canal.py (§4.1-b); yo no renombro nada; reportado en msg 350 §7.
- **CENSOR v38 (git-blob):** manager `047eab5ff111` WT==HEAD **True**; pt.po `d2b567c48e88` WT==HEAD **True**; msgids 276 (+1 header = 277); 0 `.mo`; `git diff HEAD` riel i18n = vacío. **HEAD SIGUE 390652a613d9** — **CRON C DE AGNES SIN COMMIT DESDE 9e08a34** (03:16Z): slots 04:17/06:17/08:17Z transcurridos sin mutar HEAD (4ª vuelta consecutiva; 3 commits HY4 Blender intermedios: 0a5bbc3 Carreta → 60f2e00 columna_rota → 390652a capitel). Mis docs v35-v37 en WT sin commit, **verificables en disco** (check_v37 24/24 PASS; check_v38 idem). **WT 47→91 (dinámico — Nemotron escribiendo activo durante la vuelta):** 7 M = mis 3 docs (AUDITORIA §27-29 / BACKLOG-01 ESTADO v35-v37 / BACKLOG-MASTER líneas Logs) + Hy3 ajenos (BACKLOG-HY3.md + 06-Backlog-Tanda-4nov.md) + Logs/NUMEROS_DISPONIBLES pool compartido + Hy3/.ultima-revision-hy3.txt; 84 ?? = mis msg 347/348/349 + Logs 2333/2336/2339 míos + Temp/kilo scripts/evidencias v35-v38 + ajenos (Nemotron RESUMEN-FINAL ×2 + rescatado_launch_game.bat + gemelos 268×2/269×3 + 270/271/272; Hy3 gemelos 492/493 + 490/491; HY4 acuses 26/27/28; Logs 2334/2337/2340/2342 + 951-Hy3-M14-rescatado-de-fantasma; `game/isla-ancestral/scripts/coleccionables/probe_m73_g1_categoria_completed.gd` de flota — NO MÍO, no tocar).
- **WATCHDOG v38 (write real):** `scripts/validar_i18n_integridad.py` **rc=0 LIMPIO** (1627 chars, idéntico v34-v37): JSON 170/170/170 ES/EN/PT, paridad 0/0/0, placeholders 0, cruzado 159/11/117, 4 copias ES→PT informativas (SETTINGS.HORAS/MIN cognatos). Evidencia Temp/kilo/v38_validador_i18n.txt.
- **DETECTOR 11ª hora (Temp/kilo/v38_detector_delta.txt, 82.591 chars, exit 0):** conteos **IDÉNTICOS v34-v38** — **[x]=22649 congelado 4ª hora consecutiva** (sin flips de flota): 168 checklists; [x]=22649; A1=21; R4=187; A2=233; A3=4; C2=551; SOS=289; FP=4; FORMULA=77; GRIS=209; promovidos=2; A1∩R4=0.
- **SALUD POOLS (scripts/verificar_pool_numeros.py — 1ª vez en el ciclo, §4.1-b):** pool Logs 658 libres, cabeza 2343 ✓ (2246 logs en disco, último 2342); **fallos pool-vs-disco TODOS AJENOS** (patrón "directora/agentes escriben sin consumir helper": DS-OC 248; HY4 5-28 = 24 números sobredimensionados; Hy3 483-492; Nemotron 269-272; atria-s2 386; atria-s3 273) — reportado en msg 350 §7; saneo = dueños de canal/directora, yo no renombro nada.
- **Trazabilidad git:** `git log -- AUDITORIA` = 9e08a34 (Cron C agnes, 03:16Z) → escrituras v34 versionadas; **v35/v36/v37/v38 en WT sin commit** — Cron C sin disparo en 4 vueltas (≈14h sin preservación de mis writes; flujo normal cuando la directora está en verificación pesada COLA B; no commiteo yo — regla 0 push/0 commits). **Observación elevada a la directora en msg 350 §5** (no bloqueante: checks contra disco PASS; si su cron excluye writes de Ling, puedo seguir indefinidamente sin riesgo; si espera otro trigger, quedo a disposición).
- **Escrituras v38 (report-only, 0 flips, 0 código tocado, 0 commits míos):** msg **350** (`%s`, <4KiB, consumido official) · §30 · ESTADO v38 (01-Backlog header v14-v38) · **Log %s** ritual §6.1.a (pool Logs cabeza 2343→%s) · check_v38.py (24 checks). Scripts/evidencia: Temp/kilo/{leer_estado_v38, censor_v38, correr_validador_i18n_v38, correr_detector_v38, check_v38, cierre_v38, ritual_log_v38}.py + v38_{estado_director, censor_gitsha, validador_i18n, detector_delta}.txt + estado_director_v38.json.
- **Pendientes vuelta 39 (~10:07Z):** standby monitoreo report-only; si agnes acusa/encarga (345-349) ejecutar; centinela git-blob activo; observar Cron C slot 10:17Z (5ª vuelta sin preservación → mantener observación en informe; NO editar estado_director — es de la directora); I-08 runtime ms sin Godot MCP; bug_156 = DeepSeek #491; R4 (187+313+37) y gemelos 256/248 = fundador/editor; deuda 313 entidades = GO fundador; saneo pools/huecos Ling (210/212) = fundador/directora.
""" % (MSG, NLOG, str(int(NLOG) + 1))
t = rd(AUD)
if u"## 30." in t:
    print(u"AUDITORIA §30 YA existe — skip")
else:
    wr(AUD, t + SEC30)
    print(u"AUDITORIA §30 append OK (Log %s): %d -> %d chars" % (NLOG, len(t), len(t) + len(SEC30)))

# ============ (2) ESTADO v38 en 01-Backlog-Vueltas ============
BK = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\01-Backlog-Vueltas-31oct.md"
t = rd(BK)
if u"ESTADO v38" in t:
    print(u"backlog ESTADO v38 YA existe — skip")
else:
    HEADER_OLD = u"# Ling-3.1-Flash — ESTADO v14-v37 (cron loop 30-31oct + 06nov, report-only, blindaje riel PT)"
    HEADER_NEW = u"# Ling-3.1-Flash — ESTADO v14-v38 (cron loop 30-31oct + 06nov, report-only, blindaje riel PT)"
    assert HEADER_OLD in t, u"header v14-v37 no encontrado"
    t = t.replace(HEADER_OLD, HEADER_NEW, 1)
    V38 = u"""**ESTADO 2026-11-06 06:16 local (2026-11-06 09:16Z) — VUELTA 38 CIERRE (cron wku_1aee disparó 09:07Z; override 205; WRITE REAL = CENTINELA POST-390652a (HEAD ESTABLE) + WATCHDOG + DETECTOR 11ª HORA + SALUD POOLS + OBSERVACIÓN CRON C, 0 flips):** PASO 0: estado_director **391 claves, 0 nuevas/0 borradas/0 CAMBIADAS vs v37** (diff programático; 5ª vuelta estable; snapshot Temp/kilo/estado_director_v38.json); sin encargo nuevo; `ling_345-349_acusado` aún no registrado — agnes sigue en COLA B M67/M75/M77 + LOTE A 994/1000 (flota activa: Logs 2340 G1-M73 / 2342 M129-BUG070; Nemotron gemelos 268×2/269×3 + RESUMEN-FINAL; Hy3 gemelos 492/493; HY4 acuses 26-28; mimo M18bis desbloqueado). PASO 1: canal sin 350 (último = mi 349) → vuelta propia. Helper consumió **350** official (pool canal 350→351; "mensajes usados: 343, max: 349"; huecos helper [63,156,157,232,233,234] + verificador_pool detecta 210/212 NUEVOS — saneo fundador/directora). **CENSOR v38 (git-blob):** manager 047eab5ff111 WT==HEAD True; pt.po d2b567c48e88 WT==HEAD True (276 msgids + header = 277); 0 .mo; diff riel vacío. **HEAD SIGUE 390652a613d9 — CRON C SIN COMMIT DESDE 9e08a34** (slots 04:17/06:17/08:17Z; 4ª vuelta; mis docs v35-v37 en WT sin commit, verificables en disco; observación elevada a directora en msg 350 §5 — no bloqueante; yo mantengo 0 commits/0 push). **WT 47→91** (dinámico — Nemotron activo): 7 M (mis 3 docs AUDITORIA/BACKLOG-01/BACKLOG-MASTER + Hy3 ajenos ×2 + pool Logs + .ultima-revision-Hy3) + 84 ?? (mis msg 347-349 + Logs 2333/2336/2339 + Temp/kilo v35-v38 + flota: Nemotron RESUMEN-FINAL/gemelos 268-269/270-272, Hy3 gemelos 492/493, HY4 26-28, Logs 2334/2337/2340/2342/951, probe_m73 flota). **WATCHDOG v38 LIMPIO rc=0** (1627 chars): 170/170/170, paridad 0/0/0, cruzado 159/11/117, 4 cognatos. **DETECTOR 11ª hora exit 0 (82.591 chars): conteos IDÉNTICOS v34-v38** — [x]=22649 congelado 4ª hora: A1=21, R4=187, A2=233, A3=4, C2=551, SOS=289, FP=4, FORMULA=77, GRIS=209, promovidos=2, A1∩R4=0. **SALUD POOLS (verificar_pool_numeros.py, 1ª vez):** Logs 658 libres cabeza 2343 ✓; fallos pool-vs-disco TODOS AJENOS (Hy3 483-492, Nemotron 269-272, HY4 5-28, DS-OC 248, atria 386/273 — patrón "escriben sin consumir helper"); huecos Ling 210/212 nuevos reportados (saneo fundador). **Escrituras v38:** msg **350** (<4KiB) · §30 AUDITORIA · ESTADO v38 (header v14-v38) · **Log %s** ritual §6.1.a (pool Logs cabeza 2343→%s) · check_v38.py (24 checks). 0 flips. 0 código tocado. 0 commits míos. Bloqueos vigentes: I-08 runtime ms (sin Godot MCP); gate-2 runtime PT + captura UI PT (no míos); bug_156 = DeepSeek #491; R4 (187+313+37) y gemelos 256/248 = fundador/editor; deuda 313 entidades = GO fundador; saneo pools/huecos = fundador/directora. Próxima vuelta 39 (~10:07Z): standby report-only; si agnes acusa 345-349 o encarga, ejecuto; observar Cron C slot 10:17Z.
""" % (NLOG, str(int(NLOG) + 1))
    ANCHOR = u"**ESTADO 2026-11-06 05:10 local"
    assert ANCHOR in t, u"ancla v37 no encontrada"
    t = t.replace(ANCHOR, V38 + ANCHOR, 1)
    wr(BK, t)
    print(u"ESTADO v38 insertado OK; header v14-v38; total chars=%d" % len(t))
