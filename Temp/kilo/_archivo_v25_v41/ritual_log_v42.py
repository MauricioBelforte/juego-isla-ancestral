# -*- coding: utf-8 -*-
"""Ritual Logs v42 (§6.1.a/6.1.b): tomar cabeza REAL del pool Logs (assert >= 2351, anti-colisión),
borrarla del pool, crear Log vuelta42, agregar línea BACKLOG-MASTER."""
import io, os, glob, re

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
POOL = RAIZ + u"\\Logs\\NUMEROS_DISPONIBLES.txt"
BM = None
for cand in glob.glob(RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\*\\BACKLOGS\\BACKLOG-MASTER.md"):
    if u"ling" in os.path.dirname(cand).lower():
        BM = cand
        break

pool = [x for x in io.open(POOL, encoding=u"utf-8").read().split(u"\n") if x.strip()]
N = int(pool[0])
assert N >= 2351, u"COLISION/REGRESION: cabeza pool Logs=%d < 2351 esperado" % N
del pool[0]
with io.open(POOL, u"w", encoding=u"utf-8", newline=u"\n") as f:
    f.write(u"\n".join(pool) + u"\n")

cuerpo = pool[0] if pool else u""

msg_glob = glob.glob(RAIZ + u"\\Mensajes entre modelos\\Ling-3.1-Flash\\354-*.md")
assert msg_glob, u"msg 354 no encontrado"
MSGBN = os.path.basename(msg_glob[0])

LOGNAME = u"%04d-2026-11-06_22-15-00-vuelta42-evento-riel-copias-eliminadas-riel-canonico-intacto.md" % N
LOGP = RAIZ + u"\\Logs\\" + LOGNAME
assert not os.path.exists(LOGP), u"Log ya existe: " + LOGP

contenido = u"""# Log %d: Vuelta 42 — evento riel (copias de trabajo Ling eliminadas del disco; riel canonico intacto) + crons v3 reactivados

**Fecha:** 2026-11-06
**Hora:** 22:15
**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code

## Resumen
Vuelta 42 (cron 01:07Z puntual, 3ª consecutiva). Anti-loop: canal sin 354+, ling_345-351_acusado no registrado. EVENTO MATERIAL: entre 21:12 y 22:07 local se eliminaron del disco copias de trabajo UNTRACKED de Ling (game/isla-ancestral/translation/ — ignorada por .gitignore, nunca trackeada; scripts/ling_i18n_manager.gd — nunca trackeada, git log --all vacio). Riel canonico INTEGRITO: locales/{es,en,pt}.po 276 msgids (sha pt d2b567c48e88, los 3 WT==HEAD), JSON data/localizacion 170 claves x3, localization_manager.gd can WT==HEAD, watchdog LIMPIO rc=0. Detector 15ª hora congelada (conteos identicos v41, diff 0/0, 0 flips). Agnes reactivo crons v3 (399 claves). Cron C 6a8ab2f: 2 slots sin preservar (v40+v41 en WT).

## Cambios Realizados
- Centinela Ling corregido a rutas canonicas: game/isla-ancestral/locales/*.po (276 msgids; sha es 954107e1948a / en a601d4f63b76 / pt d2b567c48e88; WT==HEAD x3) + data/localizacion/strings_{es,en,pt}.json + scripts/localization/localization_manager.gd (sha 047eab5ff111, WT==HEAD).
- Watchdog oficial re-verificado desde cwd correcto (RAIZ): LIMPIO rc=0, 170 claves ES/EN/PT, paridad 0, 4 cognatos, divergencia po/json 159/11/117 (deuda historica msg 153).
- Detector real scripts/detectar_autocontradiccion.py rc=0: conteos congelados ([x]=22649, A1=21, R4=187, A2=233, A3=4, C2=551, SOS=289, FP=4, F=77, GRIS=209, promovidos=2, A1∩R4=0, 168 checklists); diff linea a linea v41->v42 = 0/0 (sin flips).
- Descubierto: translation/ y scripts/ling_i18n_manager.gd eliminados del disco (untracked; .gitignore ignora translation/); sin impacto en repo ni riel. Pregunta al director: ¿limpieza oficial de archivos sueltos?
- estado_director: 398->399 claves (+crons_v3_reactivados_7nov por agnes 7nov 00:57Z, ids wku_1b38...; crons_apagados true->false).
- Flota: Hy3/498 cierra tanda 482 (QA documental honesto: M59 118/130 liberado, M64 sello 14°, M17 diferido 135/175, M37 no sellable 141/7/0, M139 [?] sostenidos, M14 gamepad discrepancia con agnes 497 -> flip director). Log 2350.
- Cron C 6a8ab2f estable ~3h: v40+v41 SIGUEN EN WT (2 slots 00:17Z/01:17Z sin commit; lag v39 fue ~55min; observacion ESCALADA, no bloqueante).

## Archivos Modificados/Creados
- Mensajes entre modelos/Ling-3.1-Flash/%s
- Logs/%s (este archivo)
- DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md (§34)
- DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOGS/01-Backlog-Vueltas-31oct.md (ESTADO v42 + header v14-v42)
- Temp/kilo/{descubrir,investigar,investigar2,investigar3,centinela}_v42.py + evidencias v42_*.txt + estado_director_v42.json

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
""" % (N, MSGBN, LOGNAME)

with io.open(LOGP, u"w", encoding=u"utf-8", newline=u"\n") as f:
    f.write(contenido)

linea = u"- [x] Log creado: **%d** — vuelta 42: evento riel (copias trabajo Ling eliminadas; riel canonico intacto) + crons v3 reactivados + Cron C 2 slots sin preservar (msg 354)" % N
with io.open(BM, u"a", encoding=u"utf-8", newline=u"\n") as f:
    f.write(u"\n" + linea + u"\n")

print(u"RITUAL v42 OK: Log %d creado (%s)" % (N, LOGNAME))
print(u"  pool Logs cabeza ahora:", (pool[0] if pool else u"(vacio)"))
print(u"  msg referenciado:", MSGBN[:80])
print(u"  BACKLOG-MASTER:", BM.replace(RAIZ + u"\\", u""))
print(u"  linea agregada:", linea)
