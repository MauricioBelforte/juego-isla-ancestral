#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# =============================================================================
# detectar_autocontradiccion.py — Detector repo-wide de autocontradiccion
# marca <-> nota en los 05-Checklist.md de plan-actual (Ling-3.1-Flash, 2026-10-30).
#
# ORIGEN: hallazgo BUG-070 Familia A (M85, Log 2265) + adoption de agnes-3-flash
# como patron "grep_repowide_autocontradictorio" (estado_director.json) + rec 7
# del mapa AUDITORIA-SUITES-FRAGILES-1NOV.md (msg 331 / Log 2266).
#
# USO:
#   python -X utf8 scripts/detectar_autocontradiccion.py            # scan completo
#   python -X utf8 scripts/detectar_autocontradiccion.py --modulo 50-Vegetacion
#   python -X utf8 scripts/detectar_autocontradiccion.py --out informe.txt
#
# METODO (dos pasadas; un item "- [x]" cae EN UNA SOLICA bucket):
#   Pasada 1 — clasificacion por el TEXTO PROPIO de la linea (sin vecinos):
#     FP   Falso positivo textual: frases conocidas de negacion del requisito
#          ("conteo inflado", "sin precio inflado", "el .po NO esta inflado",
#          "fue revertido/omitido en iter") o narrativa historica del fix.
#     R4   GRAVE — re-flip de Reflection-Beam-1.0 del 2026-10-26: linea con
#          "FLIP 2026-10-26 (Reflection-Beam-1.0" que NO es la formula legitima
#          ("Flipado tras verificacion de artefacto en disco") Y que ademas
#          contiene evidencia contraria EN LA PROPIA LINEA (no existe / 0 hits /
#          inexistente / sin implementar / no verificable / degradado / ...).
#          La mera cita de spec ("spec en 03-Diseno.md") SIN evidencia contraria
#          en la linea NO basta para R4 — esas son SOS (sospecha, requiere disco).
#     A1   GRAVE — flip/degradacion declarada en la nota pero la marca NO se
#          aplico: "queda [ ] honesto", "estado honesto: [ ]", "se deja [ ]",
#          "[?]->[ ]", "[x]->[?]", "[ ] honesto", "[?] degradado",
#          "DEGRADADO de [x] a [?]", "DEGRADADO por el director",
#          "revertido:", "-- [?]", "DEGRADADO 2026-10-1x" — y la propia linea
#          NO contiene evidencia de resolucion (ver RESUELTO_LINEA).
#     A3   Patron "PENDIENTE REAL ... No inflado" (autodescarga step-5 14oct):
#          formato confuso, deuda anotada honestamente, marca discutible.
#     A2   Deuda viva sin flip declarado (palabras contrarias: no existe,
#          inexistente, 0 hits, stub, sin datos, ...) sin resolucion.
#     C2   Resuelto textual: la linea misma trae evidencia de resolucion
#          (flip-back aplicado, normalizado a [x], restaurado, re-verificado
#          con Log, test ... EXIT 0, creado y verificado, [ ]->[x]).
#     SOS  Sostenido Beam-26oct: FLIP 2026-10-26 sin evidencia contraria ni
#          formula legitima (limite del detector — requeriria disco).
#   Pasada 2 — promocion por VECINOS (+-4, excluyendo la linea del hit):
#     A1/A2 cuyos vecinos contienen resolucion FUERTE (flip-back, normalizado
#     a [x], restaurado, re-verificado con Log, test EXIT 0) se promueven a C2.
#     Esto evita el hambre de buckets: C2 nunca se evalua antes que las
#     familias graves (orden exclusivo FP->R4->A1->A3->A2->C2->SOS).
#
# GRIS (contado aparte, sin bucket): lineas "COMPLETADO 2026-10-14
# (step-5-kilocode)" de definicion de diseno (139/140) — el entregable ES la
# seccion de 03-Diseno.md; no son autocontradiccion pero ameritan revision
# Definir-vs-Implementar (ver informe AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md).
#
# CALIBRACION (modulos sanos = 0 hits A1/R4): M85 post-fix, M14, M22, M34,
#   M59, M26, M36, M87, M160, M151, M45, M51, M58, M70, M79, M33, M118, M52.
# LIMITES: regex sobre texto (no semantica); vecinos +-4; solo items "- [x]"
#   (ancla inicio de linea — excluye headers/blockquotes/totales tachados);
#   un item puede ser A1 Y R4 a la vez (se reporta el cruce aparte).
#
# Salida: stdout (conteos + top por modulo + detalle) + opcional --out.
# Report-only: no modifica ningun archivo del repo. Exit 0 siempre.
# =============================================================================
import io, os, glob, re, argparse, json
from collections import Counter

ROOT_DEFAULT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOC_DEFAULT = os.path.join(ROOT_DEFAULT, "DOCUMENTACION")

# ---- Patrones ----------------------------------------------------------------
FP_TEXTO = re.compile(
    r'conteo inflado|honestidad de lo no implementado|sin precio inflado|'
    r'no disparar capitulos de sistemas no implementados|'
    r'el .po NO esta inflado|fue revertido/omitido en iter|'
    r'revertido/omitido en iter', re.I)

RESUELTO_LINEA = re.compile(
    r'\bRESUELTO\b|\bCORREGIDO\b|\bCERRADO\b|\bCERRADA\b|FLIP-BACK|flip[- ]?back|'
    r'restaurado|re-verificado|reverificado|re-medido|des-inflado|'
    r'artefacto creado|al dia|implementado 2026|testeado, exit|'
    r'creado y verificado|creados y verificados|test_fixtures_smoke|'
    r'verificada hoy 2026-10-1[0-9].*Log \d{4}|cierra la degradacion|'
    r'IMPLEMENTADO —|IMPLEMENTADO\b.*Log \d{4}|\[ \]->\[x\]|\[ \]→\[x\]|'
    r'normalizado a \[x\]|sustancia verificada|gemela can[oó]nica|'
    r'(?<!sin )respaldo (?:real )?en disco|verificado end-to-end', re.I)

VECINO_RESUELTO_FUERTE = re.compile(
    r'flip[- ]?back|normalizado a \[x\]|restaurado|re-?verificado.*log \d{4}|'
    r'test[_ ].*exit 0|creado y verificado|\[\?\]->\[x\]|\[ \]->\[x\]|'
    r'\[\?\]→\[x\]|\[ \]→\[x\]', re.I)

CONFLICTO_MARCA = re.compile(
    r'queda \[ \] honesto|estado honesto: \[ \]|se deja \[ \]|\[\?\]->\[ \]|'
    r'\[x\]\s*(?:→|->|a)\s*\[\?\]|\[ \] honesto|\[\?\] degradado|\[x\]→\[\?\]|'
    r'\[\?\]\s*degradado|DEGRADADO de \[x\] a \[\?\]|DEGRADADO por el director|'
    r'\brevertido:|\brevertido \(|— revertido|\(revertido|-- \[\?\]|'
    r'DEGRADADO 2026-10-1[0-9]', re.I)

FLIP26 = re.compile(r'FLIP 2026-10-26 \(Reflection-Beam-1\.0')
FORMULA_OK = re.compile(r'Flipado tras verificacion de artefacto en disco', re.I)
SPEC_CITA = re.compile(r'spec en 03-diseno|spec de 03-diseno|03-diseno\.md', re.I)
CONTRARIA = re.compile(
    r'no existe|0 hits|inexistente|sin implementar|no implementado|no est[áa] implementado|'
    r'no verificable|degradado|sin datos|no tiene datos|no hay|no existia|'
    r'ausente|sin respaldo|sin evidencia|sin artefacto|no construido|sin construir', re.I)
PEND_REAL = re.compile(r'pendiente real|no inflado', re.I)
CONTRARIOS_A2 = [
    r'inflado', r'\brevertido', r'\brevertida', r'pendiente real', r'no existe en disco',
    r'archivo no existe', r'artefacto (?:in)?existente', r'sin.codigo.en.disco', r'no implementado',
    r'\[x\]\s*(?:→|->|a)\s*\[\?\]', r'\b0 hits\b', r'no hay check', r'no existe tal test',
    r'no existe la constante', r'no existe test', r'no existe log', r'canvas visual no existe',
    r'\bstub\b', r'no existe rol', r'no tiene datos', r'AUSENTE en disco', r'entregable padre no existe',
    r'no existe MultiMesh', r'no existe plugin', r'\[ \] honesto', r'no existe', r'inexistente',
    r'pendiente aprobacion']

# Autodeclaraciones presentes: la linea misma declara el flip pendiente AHORA
# ("queda [ ] honesto", "se deja [ ]"). La resolucion en vecinos NO puede
# promoverlas a C2 — el flip declarado sigue sin aplicarse a la marca.
PRESENTE_AUTODECL = re.compile(
    r'queda \[ \] honesto|se deja \[ \]|\[ \] honesto|estado honesto: \[ \]|'
    r'se mantiene la primera', re.I)

GRIS_DISENO = re.compile(r'COMPLETADO 2026-10-14 \(step-5', re.I)


def vecinos_texto(ls, i):
    partes = []
    for j in range(max(0, i - 4), min(len(ls), i + 5)):
        if j == i:
            continue
        partes.append(ls[j])
    return '\n'.join(partes)


def escanear(ruta_doc, solo_modulo=None):
    paths = sorted(glob.glob(os.path.join(ruta_doc, '*', 'plan-actual', '05-Checklist.md')))
    buckets = {k: [] for k in ('A1', 'R4', 'A3', 'A2', 'C2', 'FP', 'SOS')}
    tot_x = 0
    formula_ok = 0
    gris = 0
    promovidos = 0
    for p in paths:
        mod = p.split(os.sep)[-3]
        if solo_modulo and solo_modulo.lower() not in mod.lower():
            continue
        ls = io.open(p, encoding='utf-8', errors='strict').read().splitlines()
        for i, linea in enumerate(ls):
            s = linea.strip()
            if not s.startswith('- [x]'):
                continue
            tot_x += 1
            low = s.lower()
            if FORMULA_OK.search(s):
                formula_ok += 1
            if GRIS_DISENO.search(s):
                gris += 1
            # ---- Pasada 1: texto propio de la linea ----
            if FP_TEXTO.search(low):
                buckets['FP'].append((mod, i + 1, s)); continue
            if FLIP26.search(s) and not FORMULA_OK.search(s) and CONTRARIA.search(s):
                buckets['R4'].append((mod, i + 1, s)); continue
            if CONFLICTO_MARCA.search(s) and not RESUELTO_LINEA.search(low):
                buckets['A1'].append((mod, i + 1, s)); continue
            if PEND_REAL.search(low):
                buckets['A3'].append((mod, i + 1, s)); continue
            if any(re.search(rx, low) for rx in CONTRARIOS_A2) and not RESUELTO_LINEA.search(low):
                buckets['A2'].append((mod, i + 1, s)); continue
            if RESUELTO_LINEA.search(low):
                buckets['C2'].append((mod, i + 1, s)); continue
            if FLIP26.search(s):
                buckets['SOS'].append((mod, i + 1, s)); continue
            # linea limpia (sin senales de autocontradiccion): sin bucket.
    # Segunda pasada sobre A1/A2 ya clasificados
    for clave in ('A1', 'A2'):
        fijos = []
        for mod, ln, s in buckets[clave]:
            # buscar la linea original por numero de linea dentro de su modulo
            p = os.path.join(ruta_doc, mod, 'plan-actual', '05-Checklist.md')
            if not os.path.isfile(p):
                fijos.append((mod, ln, s)); continue
            ls2 = io.open(p, encoding='utf-8', errors='strict').read().splitlines()
            vec = vecinos_texto(ls2, ln - 1)
            if PRESENTE_AUTODECL.search(s):
                fijos.append((mod, ln, s))
            elif VECINO_RESUELTO_FUERTE.search(vec):
                buckets['C2'].append((mod, ln, s)); promovidos += 1
            else:
                fijos.append((mod, ln, s))
        buckets[clave] = fijos
    return buckets, tot_x, formula_ok, gris, promovidos, len(paths)


def por_modulo(lista):
    c = Counter(m for m, _, _ in lista)
    return dict(sorted(c.items(), key=lambda kv: -kv[1]))


def main():
    ap = argparse.ArgumentParser(description='Detector repo-wide de autocontradiccion marca<->nota')
    ap.add_argument('--doc', default=DOC_DEFAULT)
    ap.add_argument('--modulo', default=None)
    ap.add_argument('--out', default=None)
    args = ap.parse_args()

    buckets, tot_x, formula_ok, gris, promovidos, n_checklists = escanear(args.doc, args.modulo)
    a1, r4, a3, a2, c2, fp, sos = (buckets[k] for k in ('A1', 'R4', 'A3', 'A2', 'C2', 'FP', 'SOS'))
    cruce = set((m, l) for m, l, _ in a1) & set((m, l) for m, l, _ in r4)

    linea = []
    linea.append(f'checklists escaneados: {n_checklists} | items [x]: {tot_x} | FORMULA legitimos: {formula_ok} | GRIS diseno step-5 14oct: {gris}')
    linea.append(f'A1-GRAVE flip declarado no aplicado: {len(a1)} (promovidos a C2 por vecinos: {promovidos})')
    linea.append(f'R4-GRAVE re-flip Beam-26oct spec sobre disco: {len(r4)}')
    linea.append(f'A1∩R4 (ambas familias): {len(cruce)}')
    linea.append(f'A3-PENDIENTE-REAL/autodescarga step-5 14oct: {len(a3)}')
    linea.append(f'A2-DEUDA viva: {len(a2)}')
    linea.append(f'C2-RESUELTO textual: {len(c2)} | SOS sostenidos Beam26: {len(sos)} | FP: {len(fp)}')
    linea.append('')
    for k in ('A1', 'R4', 'A3', 'A2', 'SOS'):
        linea.append(f'### {k} por modulo: ' + str(por_modulo(buckets[k])))
    linea.append('')
    linea.append('===== A1 detalle =====')
    for m, ln, s in a1:
        linea.append(f'[A1] {m} L{ln}: {s}')
    linea.append('===== R4 detalle (muestra 60) =====')
    for m, ln, s in r4[:60]:
        linea.append(f'[R4] {m} L{ln}: {s}')
    linea.append('===== A3 detalle =====')
    for m, ln, s in a3:
        linea.append(f'[A3] {m} L{ln}: {s}')
    linea.append('===== A2 detalle (muestra 80) =====')
    for m, ln, s in a2[:80]:
        linea.append(f'[A2] {m} L{ln}: {s}')
    linea.append('===== SOS detalle (muestra 40) =====')
    for m, ln, s in sos[:40]:
        linea.append(f'[SOS] {m} L{ln}: {s}')
    salida = '\n'.join(linea)
    print(salida)
    if args.out:
        with io.open(args.out, 'w', encoding='utf-8') as f:
            f.write(salida)
        print(f'\nPersistido: {args.out}')
    resumen = {
        'checklists': n_checklists, 'items_x': tot_x, 'formula_ok': formula_ok,
        'gris_diseno': gris, 'promovidos_vecinos': promovidos,
        'A1': len(a1), 'R4': len(r4), 'A1_R4_cruce': len(cruce),
        'A3': len(a3), 'A2': len(a2), 'C2': len(c2), 'SOS': len(sos), 'FP': len(fp),
        'A1_por_modulo': por_modulo(a1), 'R4_por_modulo': por_modulo(r4),
        'A3_por_modulo': por_modulo(a3), 'A2_por_modulo': por_modulo(a2),
    }
    print('\nJSON:' + json.dumps(resumen, ensure_ascii=False))


if __name__ == '__main__':
    main()
