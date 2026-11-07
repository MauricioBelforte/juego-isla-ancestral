# -*- coding: utf-8 -*-
"""Ritual Logs v43 (AGENTS 6.1.a/6.1.b): tomar cabeza REAL del pool Logs (assert >= 2355, anti-colisión),
borrarla del pool, crear Log vuelta43, agregar línea BACKLOG-MASTER."""
import io, os, glob

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
POOL = RAIZ + u"\\Logs\\NUMEROS_DISPONIBLES.txt"
BM = None
for cand in glob.glob(RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\*\\BACKLOGS\\BACKLOG-MASTER.md"):
    if u"ling" in os.path.dirname(cand).lower():
        BM = cand
        break
assert BM, u"BACKLOG-MASTER no encontrado"

pool = [x for x in io.open(POOL, encoding=u"utf-8").read().split(u"\n") if x.strip()]
N = int(pool[0])
assert N >= 2355, u"COLISION/REGRESION: cabeza pool Logs=%d < 2355 esperado" % N
del pool[0]
with io.open(POOL, u"w", encoding=u"utf-8", newline=u"\n") as f:
    f.write(u"\n".join(pool) + u"\n")

msg_glob = glob.glob(RAIZ + u"\\Mensajes entre modelos\\Ling-3.1-Flash\\355-*.md")
assert msg_glob, u"msg 355 no encontrado"
MSGBN = os.path.basename(msg_glob[0])

LOGNAME = u"%04d-2026-11-07_01-30-00-vuelta43-cierre-v42-38-checks-centinela-5-flips-atribuidos-cron-c-6h.md" % N
LOGP = RAIZ + u"\\Logs\\" + LOGNAME
assert not os.path.exists(LOGP), u"Log ya existe: " + LOGP

contenido = u"""# Log %d: Vuelta 43 — cierre v42 (check_v42 38/0) + centinela atribuye +5 flips DS-OC (M17/M129, legítimos) + agrupador canales + Cron C 6h escalado

**Fecha:** 2026-11-07
**Hora:** 01:30
**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code

## Resumen
Vuelta 43 (cron 04:07Z puntual). Anti-loop: canal sin 356+, ling_345-351_acusado NO registrado, estado_director congelado 399 claves (mtime 22:02). CIERRE v42: check_v42 corregido (4 check-bugs + check 12 re-escrito como centinela determinista + check 21 tolerante a msg 355 propio) -> 38 PASS / 0 FAIL. CENTINELA MATERIAL: detector items [x] 22649->22654 (+5) y C2-RESUELTO 551->552 (+1); invariantes estables (A1=21 R4=187 A2=233 A3=4 SOS=289 FP=4, 168 checklists); detector 100%% determinista (2 corridas diff=0); artifacto de encoding en snapshots v42/v43 descartado (mojibake propio al guardarlos, no drift de flota). +5 flips ATRIBUIDOS y VERIFICADOS (QA 21.8.2.b; centinela verifica, NO flipea): M17 +4 (D97/D102/F127/P256, DS-OC Log 2354, suite tests/test_m17_persistencia_rejilla.gd 23/0, Totales 139/35/1 = marcas reales) + M129 +1 (L101 stock/tiradas v3, DS-OC Log 2353, merch_manager/validator + tests 58/0 + boot B-17 11/0, Totales 108 = marcas 107/0/1). Flips legítimos, sin inflación.

## Cambios Realizados
- check_v42: fixes checks 6 (case), 18 (regex Totales), 20 (substring), 27 (umbral Temp real), 12 (determinismo + invariantes; items_x/C2 como dato), 21 (>= 354 tolerante a msg 355 propio). Re-run final: 38 PASS / 0 FAIL.
- Msg 355 al canal Ling (pool 355->356, helper proximo_numero --consume): cierre v42 + hallazgos centinela + escalado Cron C + pregunta limpieza archivos sueltos reiterada.
- Agrupador canales DS-OC/directora en curso: WT entries Mensajes entre modelos 931->1223+; 0 D en game/scripts (código intacto); canal Ling intacto. WT total ~1420.
- Cron C 6a8ab2f: 6h+ sin preservar v40/v41/v42 (slots 01:17-04:17Z; patrón v39 ~55min) — ESCALADO al director (no bloqueante: riel PT canónico safe en HEAD 071a2f9; docs recreables desde disco).
- Flota silenciosa 7nov: glob Mensajes entre modelos/**/*2026-11-07*.md = 0 archivos; último latido DS-OC acuse 23:46 local 6nov. Posible dormancia de sesiones (como 6nov).
- Temp/kilo limpiado reversible: 186->14 directos (176 a _archivo_v25_v41/, listado en salida de limpiar_temp_v43.py).
- Riel i18n re-verificado íntegro: locales es/en/pt 276 msgids (sha 954107e1948a/a601d4f63b76/d2b567c48e88, WT==HEAD), localization_manager.gd 047eab5ff111, watchdog oficial LIMPIO rc=0 (cwd=RAIZ).
- ESTADO-PARALELO.md stale desde 17-oct (5331 líneas) — dato reportado a directora.

## Archivos Modificados/Creados
- Mensajes entre modelos/Ling-3.1-Flash/%s
- Logs/%s (este archivo)
- DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md (replace 36->38 checks + addendum v42 + §35)
- DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOGS/01-Backlog-Vueltas-31oct.md (addendum ESTADO v42 + ESTADO v43)
- DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOGS/BACKLOG-MASTER.md (línea Log %d)
- Temp/kilo/{verify_flips,diag_check12,fix_check12,fix_check21,strip_bom,limpiar_temp,ctx,centinela,diff,ritual_log,cerrar_docs}_v43.py + evidencias diag_*.txt

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
""" % (N, MSGBN, LOGNAME, N)

with io.open(LOGP, u"w", encoding=u"utf-8", newline=u"\n") as f:
    f.write(contenido)

linea = u"- [x] Log creado: **%d** — vuelta 43: cierre v42 38/0 + centinela +5 flips atribuidos DS-OC M17+4/M129+1 (legítimos, sustento verificado) + agrupador canales + Cron C 6h escalado (msg 355)" % N
with io.open(BM, u"a", encoding=u"utf-8", newline=u"\n") as f:
    f.write(u"\n" + linea + u"\n")

print(u"RITUAL v43 OK: Log %d creado (%s)" % (N, LOGNAME))
print(u"  pool Logs cabeza ahora:", (pool[0] if pool else u"(vacio)"))
print(u"  msg referenciado:", MSGBN[:80])
print(u"  linea BM agregada:", linea[:90])
