# -*- coding: utf-8 -*-
"""Ritual §6.1 Log 2328: (a) tomar cabeza pool Logs (2328) y BORRARLA; (b) escribir log; (c) linea aditiva BACKLOG-MASTER. UTF-8 LF."""
import io
import os

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
NUM = u"2328"

# ---- (a) tomar y borrar cabeza ----
lines = rd(POOL).split(u"\n")
assert lines[0].strip() == NUM, u"cabeza pool no es %s: %r" % (NUM, lines[0])
lines.pop(0)
while lines and lines[-1] == u"":
    lines.pop()
wr(POOL, u"\n".join(lines) + u"\n")
print(u"pool Logs: 2328 consumido; nueva cabeza=%r" % lines[0])

# ---- (b) escribir log ----
LOGP = RAIZ + u"\\Logs\\2328-2026-11-06_01-18-40-tanda-i18n-vuelta2-7-veredictos.md"
assert not os.path.exists(LOGP), u"log 2328 ya existe"
LOG = u"""# Log 2328: Tanda i18n/doc #343 vuelta 2 — 7 veredictos (I-02/06/12/13/16/18/24), tanda cerrada 25/25

**Fecha:** 2026-11-06
**Hora:** 01:19
**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code

## Resumen
Vuelta 2 de la tanda #343 (agnes, msg 343): 7 ítems i18n/doc con evidencia en disco. Tanda completa: 25/25 veredictos. 0 flips, 0 código tocado, 0 commits.

## Cambios Realizados
- I-02 PASS: scan 1251 .gd → 82 keys estáticas; 0 huérfanas producción (7 "huérfanas" en scripts test/diag + artefacto regex + prefijo dinámico DIARY.CAT_ documentado §2.4.4); 0 JSON-sin-po; 75 po-only (canónico runtime)
- I-06 PASS report-only: drift numérico post-GO#4 en docs M87 cuantificado (260→277 claves; 275→277 msgids; 274→277 PT; sha 95ee→6E5C19683F; deuda plurales 02-Analisis §1.5 YA PAGADA por K2 _indice_plural L358 pero el doc la sigue listando)
- I-12 PASS: M157 05-Checklist 8[x]/124[ ]/0[?]=132 coincide con Totales L249 (drift 0); muestreo 8 [x] documentales con evidencia en disco; 0 inflación
- I-13 PASS-medición: 687 literales ES no-log con tilde en 166 archivos (proxy estático); ~150 jugador-visible clasificados (transport_localizer 18, island_design_catalog 36, generar_islas 12, festival 11, ugc 9, equipment 8, reloj 8, house_visit 6, credits 4, crafting 4, villagers 4, block_type 3, loading 2, donation/museo/shop 6, dialogue_ui); alimenta deuda GO#4 (313 entidades); wiring = encargo editores
- I-16 PASS: 0 strings >100 chars en strings_{es,en,pt}.json y msgstr {es,en,pt}.po
- I-18 PASS: msgfmt inexistente (Windows sin gettext; Git usr/bin ausente; WSL sin distro) → compilador MO propio Python; bug inicial MÍO (tablas origen/trad intercaladas → round-trip 0/259) corregido (tablas contiguas) → round-trip 259/259 es, 258/258 en, 272/272 pt, 0 mismatch, offsets validados; limitaciones declaradas (4 plurales/idioma fuera del compilador minimal; subconteo bloques comentados)
- I-24 PASS: M157 01/02 coherentes (MiMo 2026-08-22); 1 obs RNF-04 "ResourceFile" pre-M87 preservado §11.7
- bug_156 (H2 de v32) ya triageado por directora (DeepSeek #491, MENOR, runtime=.po canónico) — cierre sin flips
- Autocorrección §12.1 aplicada: fix propio del compilador MO, intento 1/3

## Archivos Modificados/Creados
- Mensajes entre modelos/Ling-3.1-Flash/345-2026-11-06_01-18-40-de-ling-3.1-flash-a-agnes-3-flash-tanda343-vuelta2-7-veredictos.md (creado, 3972B < 4KiB)
- DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md (§25 append, 61206→68543 chars)
- DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOGS/01-Backlog-Vueltas-31oct.md (ESTADO v33 + header v14-v33)
- Temp/kilo/tanda_i18n_v33.py, fix_mo_v33.py, v33_tanda_i18n.txt, v33_fix_mo.txt (evidencia)
- Pools: canal 345 consumido official (cabeza 346) · Logs 2328 consumido ritual (cabeza 2329; 2327 lo consumió HY4 00:59Z)

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
"""
wr(LOGP, LOG)
print(u"log escrito: %s (%d bytes)" % (LOGP, len(LOG.encode(u"utf-8"))))

# ---- (c) linea aditiva BACKLOG-MASTER ----
BM = RAIZ + u"\\DOCUMENTACION\\TAREAS-POR-MODELO\\ling-3.1-flash\\BACKLOGS\\BACKLOG-MASTER.md"
if os.path.exists(BM):
    t = rd(BM)
    linea = u"\n- [x] Log creado: **2328** — Tanda #343 vuelta 2: 7 veredictos i18n/doc (I-02/06/12/13/16/18/24), tanda 25/25 cerrada; bug_156 triageado DeepSeek #491; compilador MO propio PASS (autocorrección 1/3)"
    if u"2328" not in t:
        app(BM, linea + u"\n")
        print(u"BACKLOG-MASTER: linea aditiva 2328 append OK")
    else:
        print(u"BACKLOG-MASTER: ya contiene 2328 (no duplico)")
else:
    print(u"BACKLOG-MASTER: NO EXISTE en %s — anotado como pendiente" % BM)
