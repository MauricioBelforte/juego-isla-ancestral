# -*- coding: utf-8 -*-
"""Cierre v42: §34 AUDITORIA + ESTADO v41->v42 en backlog 01 (anchor dinamico) + header v14-v41 -> v14-v42. Idempotente."""
import io, os, glob, re

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
AUD = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md"
BK = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\01-Backlog-Vueltas-31oct.md"

# discovery runtime
g = glob.glob(RAIZ + u"\\Logs\\*-vuelta42-*.md")
NLOG = int(re.match(r"(\d+)-", os.path.basename(g[0])).group(1)) if g else 0
assert NLOG >= 2351, u"NLOG runtime invalido: %d" % NLOG
mg = glob.glob(RAIZ + u"\\Mensajes entre modelos\\Ling-3.1-Flash\\354-*.md")
NMSG = u"354" if mg else u"?"

SECCION = u"""

## 34. VUELTA 42 (2026-11-06 22:15 local / 2026-11-07 01:15Z) — EVENTO RIEL (copias de trabajo eliminadas; riel canonico intacto) + crons v3 reactivados

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-06 22:15 local
**Mensaje:** %s (canal Ling-3.1-Flash) · **Log:** %d (ritual §6.1.a, pool cabeza 2351->2352 por race con Log 2351 ajeno "46-degradaciones-m72-3")

### Anti-loop
Canal sin 354+ (mi 353 ultimo numerado); `ling_345-351_acusado` AUN NO registrado en estado_director; sin respuesta a 352/353 -> vuelta propia (no insistir).

### EVENTO RIEL (hallazgo material)
Entre 21:12 y 22:07 local alguien elimino del disco copias de trabajo UNTRACKED de Ling: `game/isla-ancestral/translation/` (ruta IGNORADA por .gitignore; `git log --all -- translation/` = vacio, nunca trackeada) y `game/isla-ancestral/scripts/ling_i18n_manager.gd` (`git log --all -- *ling_i18n*` = vacio). **RIEL CANONICO INTACTO**: `game/isla-ancestral/locales/{es,en,pt}.po` 276 msgids c/u (sha es 954107e1948a / en a601d4f63b76 / pt d2b567c48e88 — el mismo sha pt que centinelaba v41; los 3 WT==HEAD), JSON `data/localizacion/strings_*.json` 170 claves x3, `scripts/localization/localization_manager.gd` (sha 047eab5ff111) WT==HEAD, watchdog oficial LIMPIO rc=0 (170/170/170 ES/EN/PT, paridad 0, 4 cognatos; divergencia po/json 159/11/117 = deuda historica msg 153, no rotura). CERO impacto en repo/proyecto. Centinela Ling v42 actualizado a rutas canonicas `locales/`. Pregunta al director: ¿limpieza oficial de archivos sueltos? (si si, no recrear copias de trabajo).

### Detector 15ª hora congelada
Detector real = `scripts/detectar_autocontradiccion.py` (el discovery invoco nombre errado "verificar_claims_md_detector.py"; corregido). rc=0, conteos IDENTICOS a v41: [x]=22649, A1=21, R4=187, A2=233, A3=4, C2=551, SOS=289, FP=4, F=77, GRIS=209, promovidos=2, A1∩R4=0, 168 checklists. Diff linea a linea v41->v42 = 0/0 -> **0 flips nuevos** (regla override 3: nada que verificar textualmente esta hora).

### estado_director 398 -> 399 claves
+`crons_v3_reactivados_7nov` (agnes, 7nov 00:57Z: ids A/B/C/D wku_1b38..., "fundador: activa los cronometros", flota Hy4+Hy3+DS-OC+Nemotron+Ling+GLM); `crons_apagados` true->false. Mi cron wku_1aee sigue vivo (3ª puntual consecutiva 00:07/01:07Z).

### Git: Cron C 6a8ab2f lleva 2 slots sin preservar (ESCALADO)
HEAD sigue 6a8ab2f (~3h estable). v40 (§32/ESTADO/Log 2348/msg 352) y v41 (§33/ESTADO/Log 2349/msg 353) SIGUEN EN WT (WT=33; docs trackeados "M"). Slots 00:17Z y 01:17Z pasaron sin commit — supera patron lag ~55min de v39. Observacion escalada al director (no bloqueante; 0 commits propios).

### Flota
Hy3/498 (21:30 local) cerro tanda 482: QA documental honesto (M59 118/130 liberado, M64 sello 14° confirmado, M17 diferido 135/175 NO liberado, M37 no sellable 141/7/0, M139 [?] sostenidos, M14 gamepad DISCREPANCIA con agnes 497: gamepad existe a nivel proyecto pero 0 hits en capa inventario inventory_layer.gd; Hy3 no lo flipo, va a flip director). Log 2350. agnes activa 22:02 (crons).

### Escrituras reales v42
msg %s (3.135B, pool canal 354->355) · Log %d (race pool: assert >=2351 tomo 2352; 2351 ajeno) · §34 (este) · ESTADO v42 + header v14-v42 · check_v42 (36 checks).

### Bloqueos (sin cambios)
I-08 runtime ms (sin Godot MCP); bug_156=DS#491; gate-2 runtime PT + captura UI M154 (no míos); R4/gemelos 256/248/deuda 313=fundador; saneo pools/huecos=fundador/directora.

### Proxima vuelta 43 (~02:07Z)
¿Cron C preservo v40/v41/v42? ¿agnes acusa 345-351 / responde 352-354? ¿Respuesta a pregunta limpieza archivos sueltos? ¿Hy3/DS-OC generan flips del detector?
""" % (NMSG, NLOG, NMSG, NLOG)

ESTADO = u"**ESTADO 2026-11-06 22:15 local (01:15Z) — VUELTA 42 CIERRE** (cron 01:07Z puntual, 3ª consecutiva; anti-loop: canal sin 354+, ling_345-351_acusado NO registrado, sin respuesta a 352/353 → vuelta propia). **EVENTO RIEL**: 21:12→22:07 local se eliminaron del disco copias de trabajo UNTRACKED de Ling (translation/ ignorada por .gitignore y nunca trackeada; scripts/ling_i18n_manager.gd nunca trackeada, git log --all vacío); **RIEL CANÓNICO ÍNTEGRITO**: locales/{es,en,pt}.po 276 msgids (sha pt d2b567c48e88 = el de v41, los 3 WT==HEAD), JSON 170 claves x3, localization_manager.gd canónico WT==HEAD, watchdog LIMPIO rc=0 (170/170/170, paridad 0, 4 cognatos, divergencia po/json 159/11/117 histórica msg 153); cero impacto repo; centinela Ling corregido a rutas canónicas; pregunta director ¿limpieza oficial? Detector 15ª hora congelada (rc=0, conteos idénticos v41: [x]=22649 A1=21 R4=187 A2=233 A3=4 C2=551 SOS=289 FP=4 F=77 GRIS=209 prom=2 A1∩R4=0, 168 checklists; diff 0/0, 0 flips). estado_director 398→**399 claves** (+crons_v3_reactivados_7nov agnes 00:57Z ids wku_1b38 A/B/C/D; crons_apagados=false). Git: HEAD 6a8ab2f ~3h estable; **Cron C lleva 2 slots sin preservar** (v40+v41 en WT, WT=33) — lag supera patrón 55min de v39, ESCALADO no bloqueante. Race pool Logs: ritual assert>=2351 tomó **2352** (2351 ajeno '46-degradaciones-m72-3', flota activa). Flota: Hy3/498 cerró tanda 482 QA honesto (M59 118/130 liberado, M64 sello 14°, M17 diferido 135/175, M37 no sellable 141/7/0, M139 [?] sostenidos, M14 gamepad discrepancia con 497→flip director); Log 2350; agnes activa 22:02. Escrituras reales: msg 354 (pool 354→355) · Log 2352 · §34 AUDITORIA · ESTADO v42 · check_v42. Pools: canal cabeza 355, Logs cabeza 2353. Bloqueos: I-08 runtime ms; bug_156=DS#491; gate-2 PT=Hy3; R4/gemelos/deuda313=fundador. Vuelta 43 ~02:07Z: ¿Cron C preservó v40-v42? ¿agnes acusa 345-351/responde? ¿respuesta limpieza archivos sueltos? ¿flips Hy3/DS-OC? Firmado: Ling-3.1-Flash (Kilo Code)."

# --- 1. AUDITORIA §34 ---
aud = io.open(AUD, encoding=u"utf-8").read()
if u"## 34." in aud:
    print(u"AUDITORIA: §34 YA EXISTE (skip append)")
else:
    with io.open(AUD, u"a", encoding=u"utf-8", newline=u"\n") as f:
        f.write(SECCION)
    print(u"AUDITORIA: §34 append OK")

# --- 2. BACKLOG 01: ESTADO v42 + header ---
bk = io.open(BK, encoding=u"utf-8").read()
if u"VUELTA 42 CIERRE" in bk:
    print(u"BACKLOG 01: ESTADO v42 YA EXISTE (skip)")
else:
    idxs = [m.start() for m in re.finditer(u"\\*\\*ESTADO 2026-", bk)]
    assert idxs, u"anchor ESTADO no encontrado"
    last = idxs[-1]
    nuevo = bk[:last] + ESTADO + u"\n" + bk[last:]
    io.open(BK, u"w", encoding=u"utf-8", newline=u"\n").write(nuevo)
    print(u"BACKLOG 01: ESTADO v42 insertado (anchor runtime ultimo '**ESTADO 2026-')")

if u"v14-v42" in bk:
    print(u"BACKLOG 01: header ya v14-v42 (skip)")
else:
    assert u"v14-v41" in bk, u"header v14-v41 no encontrado"
    bk2 = io.open(BK, encoding=u"utf-8").read()
    bk2 = bk2.replace(u"v14-v41", u"v14-v42", 1)
    io.open(BK, u"w", encoding=u"utf-8", newline=u"\n").write(bk2)
    print(u"BACKLOG 01: header v14-v41 -> v14-v42 OK")

print(u"CIERRE v42 COMPLETO | NMSG=%s NLOG=%d" % (NMSG, NLOG))
print(u"AUDITORIA:", len(io.open(AUD, encoding=u"utf-8").read()), u"chars")
print(u"BACKLOG 01:", len(io.open(BK, encoding=u"utf-8").read()), u"chars")
