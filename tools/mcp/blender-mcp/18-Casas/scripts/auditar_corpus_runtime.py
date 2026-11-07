#!/usr/bin/env python3
"""Audita el presupuesto M166 sobre el GLB DE RUNTIME para el corpus Hy4.

Origen (B13-corpus, 2026-11-07): B12 demostro que chk_asset.py mide el .blend
SIN validar la malla y puede sobrecontar triangulos. El acta 23 afirmo que el
fenomeno aparecia "solo tras el decimate sobre mallas mergeadas". Esta auditoria
de corpus REFUTA esa parte: carreta_ancestral ALTA (sin merge ni decimate) tiene
+88 tris en el .blend por poligonos invalidos en SM_Carreta_Aros / _Ruedas, y
su re-export es byte-identico al GLB publicado.

Regla que se aplica: la cifra de presupuesto se mide SOBRE EL GLB. Las cifras
del .blend se aceptan con --declarado y se publican como DATO, nunca como check:
un numero documental viejo no debe hacer fallar la guardia ni consagrarse.

Uso:
  python auditar_corpus_runtime.py --piso 0        # mide el piso de checks
  python auditar_corpus_runtime.py                 # VERDE (30 GLB)
  python auditar_corpus_runtime.py --declarado <json>   # publica derivas
  python auditar_corpus_runtime.py --inyectar        # ROJO C4 (exit 1)
  python auditar_corpus_runtime.py --inyectar-mats   # ROJO C10, check NUEVO (exit 1)
  python auditar_corpus_runtime.py --solo <base>     # CIEGO (exit 3)

Python puro, sin bpy. Reutiliza el decodificador de verificar_triangulos_runtime.py.
"""
import importlib.util
import json
import os
import struct
import sys

AQUI = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(AQUI, '..', '..', '..', '..', '..'))
GODOT = os.path.join(REPO, 'game', 'isla-ancestral', 'assets', '3d')
TEMP = os.path.join(REPO, 'Temp')

spec = importlib.util.spec_from_file_location(
    'vtr', os.path.join(AQUI, 'verificar_triangulos_runtime.py'))
vtr = importlib.util.module_from_spec(spec)
spec.loader.exec_module(vtr)

# 10 bases x 3 LOD = 30 GLB. Medido en disco el 2026-11-07: los 30 existen.
BASES = [
    '67-Vehiculos_barquita_aurora',
    '67-Vehiculos_globo_del_viento',
    '67-Vehiculos_perla_ancestral',
    '67-Vehiculos_gran_vapor',
    '157-Medios-De-Transporte_carreta_ancestral',
    '25-Ruinas-Templos_columna_rota_alta',
    '25-Ruinas-Templos_columna_rota_baja',
    '25-Ruinas-Templos_columna_entera',
    '18-Casas_casa_mansion',
    '18-Casas_casa_vecino',
]
LODS = ('alta', 'media', 'baja')

# M166 §3.3 (03-Backlog-Convenciones.md L27-L29).
PERFIL_OBJ = {'alta': 16, 'media': 8, 'baja': 6}
PERFIL_MAT = {'alta': 12, 'media': 8, 'baja': 4}
# Excepcion documentada §6.1 L30-L31: casas grandes pueden exceder el nominal
# de MEDIA/BAJA. Se aplica el techo de sub-grupo (16 SM_), NO se omite el check.
CASAS_GRANDES = '18-Casas_casa_'

CHECKS_MINIMOS = 330      # MEDIDO en verde con --piso 0 el 2026-11-07 (330/330/0)
BASES_MINIMAS = len(BASES)


def ruta(base, lod):
    return os.path.join(GODOT, lod, base + '.glb')


def inyectar_materiales(src, dst, n=5):
    """ROJO semantico para C10: agrega n materiales al JSON del GLB.

    No toca vertices ni indices: C1..C9 y C11..C13 deben seguir en verde, de
    modo que el unico fallo sea el techo de materiales del check NUEVO.
    """
    raw = open(src, 'rb').read()
    jlen = struct.unpack_from('<I', raw, 12)[0]
    doc = json.loads(raw[20:20 + jlen].decode('utf-8'))
    mats = doc.setdefault('materials', [])
    for k in range(n):
        mats.append({'name': 'HY4_INYECTADO_%d' % k})
    chunk = json.dumps(doc, separators=(',', ':')).encode('utf-8')
    chunk += b' ' * ((4 - len(chunk) % 4) % 4)
    off = 20 + jlen
    blen, btipo = struct.unpack_from('<II', raw, off)
    bin_ = raw[off + 8:off + 8 + blen]
    total = 12 + 8 + len(chunk) + 8 + len(bin_)
    salida = (struct.pack('<III', 0x46546C67, 2, total) +
              struct.pack('<II', len(chunk), 0x4E4F534A) + chunk +
              struct.pack('<II', len(bin_), btipo) + bin_)
    open(dst, 'wb').write(salida)
    return dst


def main(argv):
    piso = CHECKS_MINIMOS
    solo = None
    declarado = {}
    inyectar_rojo = False
    inyectar_mats = False
    i = 0
    while i < len(argv):
        a = argv[i]
        if a == '--piso':
            i += 1
            piso = int(argv[i])
        elif a == '--solo':
            i += 1
            solo = argv[i]
        elif a == '--declarado':
            i += 1
            declarado = json.load(open(argv[i], encoding='utf-8'))
        elif a == '--inyectar':
            inyectar_rojo = True
        elif a == '--inyectar-mats':
            inyectar_mats = True
        i += 1

    bases = [solo] if solo else list(BASES)
    paths = {}
    for base in bases:
        for lod in LODS:
            paths[(base, lod)] = ruta(base, lod)

    if inyectar_rojo:
        clave = (bases[-1], 'baja')
        dst = os.path.join(TEMP, 'hy4_corpus_rojo_20261107.glb')
        vtr.inyectar(paths[clave], dst)
        paths[clave] = dst
    if inyectar_mats:
        clave = (bases[-1], 'alta')
        dst = os.path.join(TEMP, 'hy4_corpus_rojo_mats_20261107.glb')
        inyectar_materiales(paths[clave], dst, 5)
        paths[clave] = dst

    todos, datos, presentes = [], {}, {}
    print('=== PRESUPUESTO M166 SOBRE GLB DE RUNTIME (no .blend) ===')
    for base in bases:
        for lod in LODS:
            p = paths[(base, lod)]
            presentes[(base, lod)] = os.path.isfile(p)
            if not presentes[(base, lod)]:
                continue
            checks, d = vtr.analizar(p, piso, lod)
            todos.extend(checks)
            datos[(base, lod)] = d

            excepcion = base.startswith(CASAS_GRANDES) and lod != 'alta'
            techo_obj = 16 if excepcion else PERFIL_OBJ[lod]
            todos.append(('C9', d['mesh_count'] <= techo_obj,
                          '%s/%s objetos=%d <= %d%s' %
                          (base, lod, d['mesh_count'], techo_obj,
                           ' (excepcion casas grandes §6.1)' if excepcion else '')))
            todos.append(('C10', d['materiales'] <= PERFIL_MAT[lod],
                          '%s/%s mats=%d <= %d' %
                          (base, lod, d['materiales'], PERFIL_MAT[lod])))

    # Checks de cobertura y coherencia entre LOD: un bloque por base.
    for base in bases:
        ok_triple = all(presentes.get((base, l), False) for l in LODS)
        todos.append(('C13', ok_triple,
                      '%s triple LOD alta/media/baja presente=%s' %
                      (base, ok_triple)))
        if ok_triple:
            ts = [datos[(base, l)]['tris'] for l in LODS]
            ms = [datos[(base, l)]['materiales'] for l in LODS]
            todos.append(('C11', ts[0] >= ts[1] >= ts[2],
                          '%s tris %d>=%d>=%d' % (base, ts[0], ts[1], ts[2])))
            todos.append(('C12', ms[0] >= ms[1] >= ms[2],
                          '%s mats %d>=%d>=%d' % (base, ms[0], ms[1], ms[2])))
        else:
            todos.append(('C11', False, '%s: falta un LOD, no se mide' % base))
            todos.append(('C12', False, '%s: falta un LOD, no se mide' % base))

    print()
    print('%-42s %-5s %7s %7s %8s %5s %5s %6s' %
          ('base', 'lod', 'runtime', 'blend', 'deriva', 'obj', 'mats', 'y_min'))
    print('-' * 88)
    derivas = []
    for clave in sorted(datos):
        base, lod = clave
        d = datos[clave]
        decl = declarado.get('%s|%s' % (base, lod))
        deriva = (decl - d['tris']) if decl is not None else None
        if deriva is not None and deriva != 0:
            derivas.append((base, lod, decl, d['tris'], deriva))
        print('%-42s %-5s %7d %7s %8s %5d %5d %6.4f' %
              (base, lod, d['tris'], '-' if decl is None else decl,
               '-' if deriva is None else '%+d' % deriva,
               d['mesh_count'], d['materiales'], d['y_min']))
    print('-' * 88)
    print('Derivas .blend -> GLB: %d de %d pares (suma |deriva|=%d). DATO, no check.' %
          (len(derivas), len(datos), sum(abs(x[4]) for x in derivas)))
    for base, lod, decl, rt, dv in derivas:
        print('   %-42s %-5s %d -> %d  %+d' % (base, lod, decl, rt, dv))
    print()

    pasados = sum(1 for _, ok, _ in todos if ok)
    fallos = len(todos) - pasados
    bloques = len(datos)
    for codigo, ok, detalle in todos:
        if not ok:
            print('   FAIL %s %s' % (codigo, detalle))
    print('CHECKS=%d PASADOS=%d FALLOS=%d BLOQUES=%d BASES=%d PISO=%d' %
          (len(todos), pasados, fallos, bloques, len(bases), piso))

    ciego = bloques < len(BASES) * len(LODS) or len(bases) < BASES_MINIMAS or len(todos) < piso
    if ciego:
        print('CIEGO: faltan bloques, bases o checks ejecutados (%d/%d bloques, %d/%d bases, %d/%d checks)' %
              (bloques, len(BASES) * len(LODS), len(bases), BASES_MINIMAS,
               len(todos), piso))
        return 3
    if fallos:
        print('ROJO')
        return 1
    print('VERDE')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
