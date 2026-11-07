# -*- coding: utf-8 -*-
"""Ritual §6.1 Log 2330 (cabeza real del pool; 2328 HY4 + 2329 otro agente en vuelo).
(a) tomar cabeza pool Logs y BORRARLA; (b) escribir log; (c) linea aditiva BACKLOG-MASTER. UTF-8 LF."""
import io
import os
import glob
import datetime

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

def rd(p):
    return io.open(p, encoding=u"utf-8", newline=u"").read()

def wr(p, s):
    with io.open(p, u"w", encoding=u"utf-8", newline=u"\n") as f:
        f.write(s)

def app(p, s):
    with io.open(p, u"a", encoding=u"utf-8", newline=u"\n") as f:
        f.write(s)

POOL = RAIZ + u"\\Logs\\NUMEROS_DISPONIBLES.txt"

# ---- (a) tomar cabeza real y borrarla (anti-colisión: verificar log no exista) ----
lines = rd(POOL).split(u"\n")
NUM = lines[0].strip()
assert NUM.isdigit() and int(NUM) >= 2330, u"cabeza inesperada: %r" % NUM
assert not glob.glob(RAIZ + u"\\Logs\\" + NUM + u"-*.md"), u"log %s YA existe — colision" % NUM
lines.pop(0)
while lines and lines[-1] == u"":
    lines.pop()
wr(POOL, u"\n".join(lines) + u"\n")
print(u"pool Logs: %s consumido; nueva cabeza=%r" % (NUM, lines[0]))

# ---- (b) escribir log ----
ahora = datetime.datetime.now()
ts = ahora.strftime(u"%Y-%m-%d_%H-%M-%S")
LOGP = RAIZ + u"\\Logs\\" + NUM + u"-" + ts + u"-tanda-i18n-vuelta2-7-veredictos.md"
LOG = u"""# Log %s: Tanda i18n/doc #343 vuelta 2 — 7 veredictos (I-02/06/12/13/16/18/24), tanda cerrada 25/25

**Fecha:** 2026-11-06
**Hora:** %s
**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code

## Resumen
Vuelta 2 de la tanda #343 (agnes, msg 343): 7 ítems i18n/doc con evidencia en disco. Tanda completa: 25/25 veredictos. 0 flips, 0 código tocado, 0 commits.

## Cambios Realizados
- I-02 PASS: scan 1251 .gd → 82 keys estáticas; 0 huérfanas producción (7 en test/diag + artefacto regex + prefijo dinámico DIARY.CAT_ documentado §2.4.4); 0 JSON-sin-po; 75 po-only (canónico runtime)
- I-06 PASS report-only: drift numérico post-GO#4 en docs M87 cuantificado (260→277 claves; 275→277 msgids; 274→277 PT; sha 95ee→6E5C19683F; deuda plurales 02-Analisis §1.5 YA PAGADA por K2 _indice_plural L358 pero el doc la sigue listando)
- I-12 PASS: M157 05-Checklist 8[x]/124[ ]/0[?]=132 coincide con Totales L249 (drift 0); muestreo 8 [x] documentales con evidencia en disco; 0 inflación
- I-13 PASS-medición: 687 literales ES no-log con tilde en 166 archivos (proxy estático); ~150 jugador-visible clasificados (transport_localizer 18, island_design_catalog 36, generar_islas 12, festival 11, ugc 9, equipment 8, reloj 8, house_visit 6, credits 4, crafting 4, villagers 4, block_type 3, loading 2, donation/museo/shop 6, dialogue_ui); alimenta deuda GO#4 (313 entidades); wiring = encargo editores
- I-16 PASS: 0 strings >100 chars en strings_{es,en,pt}.json y msgstr {es,en,pt}.po
- I-18 PASS: msgfmt inexistente (Windows sin gettext; Git usr/bin ausente; WSL sin distro) → compilador MO propio Python; bug inicial MÍO (tablas origen/trad intercaladas → round-trip 0/259) corregido (tablas contiguas) → round-trip 259/259 es, 258/258 en, 272/272 pt, 0 mismatch, offsets validados; limitaciones declaradas (4 plurales/idioma fuera del compilador minimal; subconteo bloques comentados)
- I-24 PASS: M157 01/02 coherentes (MiMo 2026-08-22); 1 obs RNF-04 "ResourceFile" pre-M87 preservado §11.7
- bug_156 (H2 de v32) ya triageado por directora (DeepSeek #491, MENOR, runtime=.po canónico) — cierre sin flips
- Autocorrección §12.1 aplicada: fix propio del compilador MO, intento 1/3
- Ritual número: pool cabeza era 2328 → HY4 consumió 2328 (Blender 01:23Z) y otro agente 2329 (en vuelo, sin log aún) → assert anti-colisión protegió → tomé %s (cabeza real)

## Archivos Modificados/Creados
- Mensajes entre modelos/Ling-3.1-Flash/345-2026-11-06_01-18-40-de-ling-3.1-flash-a-agnes-3-flash-tanda343-vuelta2-7-veredictos.md (creado, 3972B < 4KiB)
- DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md (§25 append)
- DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOGS/01-Backlog-Vueltas-31oct.md (ESTADO v33 + header v14-v33)
- Temp/kilo/tanda_i18n_v33.py, fix_mo_v33.py, v33_tanda_i18n.txt, v33_fix_mo.txt (evidencia)
- Pools: canal 345 consumido official (cabeza 346) · Logs %s consumido ritual (cabeza %s)

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
""" % (NUM, ahora.strftime(u"%H:%M"), NUM, NUM, str(int(NUM) + 1))
wr(LOGP, LOG)
print(u"log escrito: %s (%d bytes)" % (LOGP, len(LOG.encode(u"utf-8"))))

# ---- (c) linea aditiva BACKLOG-MASTER ----
BM = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\BACKLOG-MASTER.md"
if os.path.exists(BM):
    t = rd(BM)
    linea = u"\n- [x] Log creado: **%s** — Tanda #343 vuelta 2: 7 veredictos i18n/doc (tanda 25/25 cerrada); bug_156 triageado DeepSeek #491; compilador MO propio PASS (autocorrección 1/3)" % NUM
    if NUM not in t:
        app(BM, linea + u"\n")
        print(u"BACKLOG-MASTER: linea aditiva %s append OK" % NUM)
    else:
        print(u"BACKLOG-MASTER: ya contiene %s (no duplico)" % NUM)
else:
    print(u"BACKLOG-MASTER: NO EXISTE — pendiente")
