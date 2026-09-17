#!/usr/bin/env python3
"""
auditar_checklist.py — Auditoria cruzada CHECKLIST-OBJETOS-BLENDER.md vs disco.

Cruza los ~290 items del checklist maestro de assets Blender contra los artefactos
REALES del repo, para detectar las dos inconsistencias que desorientan a los demas
agentes:

  A) FALSO PENDIENTE: item marcado `- [ ]` pero cuyo script + .blend + GLB ya existen.
  B) FALSO COMPLETO: item marcado `- [x]` pero al que le falta el script, el .blend
     o el GLB (o directamente el .scn importado en Godot).

Tambien reporta:
  C) Scripts huerfanos: .py de creacion que existen en disco pero NO figuran en el
     checklist (trabajo hecho y no anotado).

Uso:
    python auditar_checklist.py            # reporte por stdout
    python auditar_checklist.py --json     # salida maquina

Criterio de "completo" (el del propio checklist, ver su encabezado):
  script existe AND .blend existe AND GLB alta existe.
El .scn de Godot se reporta aparte porque depende de que se haya corrido el import.
"""
import os
import re
import sys
import json

ROOT = os.path.dirname(os.path.abspath(__file__))          # .../blender-mcp


def raiz_repo():
    """Sube hasta encontrar AGENTS.md (evita contar '..' a mano — E-101)."""
    d = ROOT
    for _ in range(8):
        if os.path.isfile(os.path.join(d, 'AGENTS.md')):
            return d
        p = os.path.dirname(d)
        if p == d:
            break
        d = p
    raise SystemExit('No encontre AGENTS.md subiendo desde %s' % ROOT)


PROY = raiz_repo()
CHK = os.path.join(ROOT, 'CHECKLIST-OBJETOS-BLENDER.md')
GODOT_3D = os.path.join(PROY, 'game', 'isla-ancestral', 'assets', '3d')

RE_ITEM = re.compile(r'^- \[([ x?])\] (.+)$')
RE_SCRIPT = re.compile(r'`(crear_[A-Za-z0-9_]+\.py)`')


def indexar():
    """Mapas de lo que hay realmente en disco."""
    scripts = {}
    for dirpath, _dirs, files in os.walk(ROOT):
        for f in files:
            if f.startswith('crear_') and f.endswith('.py'):
                scripts.setdefault(f, []).append(
                    os.path.relpath(os.path.join(dirpath, f), ROOT))

    blends = {}
    for dirpath, _dirs, files in os.walk(ROOT):
        for f in files:
            if f.endswith('.blend') and not f.endswith('.blend1'):
                # clave = stem sin sufijos. Orden: quitar variante y despues
                # calidad.  cristal_ancestral_lowpoly_media.blend
                #   -> cristal_ancestral_lowpoly -> cristal_ancestral
                # E-102: si solo se quitan _media/_baja queda '..._lowpoly' y
                # TODO el catalogo de .blend parece ausente.
                base = f[:-len('.blend')]
                for suf in ('_media', '_baja', '_alta', '_lowpoly'):
                    if base.endswith(suf):
                        base = base[:-len(suf)]
                        break
                blends.setdefault(base, []).append(
                    os.path.relpath(os.path.join(dirpath, f), ROOT))

    glbs = {'alta': set(), 'media': set(), 'baja': set()}
    for var in glbs:
        d = os.path.join(GODOT_3D, var)
        if not os.path.isdir(d):
            continue
        for f in os.listdir(d):
            if f.endswith('.glb'):
                glbs[var].add(f[:-len('.glb')])

    scns = set()
    imp = os.path.join(PROY, 'game', 'isla-ancestral', '.godot', 'imported')
    if os.path.isdir(imp):
        for f in os.listdir(imp):
            if f.endswith('.scn'):
                scns.add(f)

    # E-103: sidecar .glb.import cuyo .glb NO existe. Godot queda apuntando a
    # un recurso inexistente y el checklist sigue diciendo "completo".
    huerf = []
    for var in ('alta', 'media', 'baja'):
        d = os.path.join(GODOT_3D, var)
        if not os.path.isdir(d):
            continue
        for f in os.listdir(d):
            if not f.endswith('.glb.import'):
                continue
            glb = os.path.join(d, f[:-len('.import')])
            if not os.path.exists(glb):
                huerf.append('%s/%s' % (var, f[:-len('.import')]))

    return scripts, blends, glbs, scns, sorted(huerf)


def main():
    as_json = '--json' in sys.argv
    scripts, blends, glbs, scns, huerf_import = indexar()

    lineas = open(CHK, encoding='utf-8').read().split('\n')

    items = []
    modulo = '(sin modulo)'
    for i, ln in enumerate(lineas, 1):
        if ln.startswith('## '):
            modulo = ln[3:].strip()
            continue
        m = RE_ITEM.match(ln)
        if not m:
            continue
        marca, texto = m.group(1), m.group(2)
        sm = RE_SCRIPT.search(texto)
        script = sm.group(1) if sm else None
        items.append({
            'linea': i, 'modulo': modulo, 'marca': marca,
            'texto': texto, 'script': script,
        })

    # --- clasificar ---
    falsos_pend, falsos_comp, sin_script = [], [], []
    for it in items:
        s = it['script']
        if not s:
            sin_script.append(it)
            continue
        # asset deducido del nombre del script: crear_X_lowpoly.py -> X
        asset = s[len('crear_'):-len('.py')]
        asset = re.sub(r'_lowpoly$', '', asset)

        hay_script = s in scripts
        hay_blend = asset in blends
        # el GLB se nombra {Modulo}_{asset}.glb -> basta con que termine en _{asset}
        suf = '_' + asset
        hay_glb = any(n.endswith(suf) for n in glbs['alta'])
        hay_scn = any(asset in n for n in scns)

        it.update(asset=asset, hay_script=hay_script, hay_blend=hay_blend,
                  hay_glb=hay_glb, hay_scn=hay_scn,
                  ruta_script=(scripts.get(s) or [None])[0],
                  ruta_blend=(blends.get(asset) or [None])[0])

        completo = hay_script and hay_blend and hay_glb
        if it['marca'] == ' ' and completo:
            falsos_pend.append(it)
        elif it['marca'] == 'x' and not completo:
            falsos_comp.append(it)

    # --- scripts huerfanos (en disco, no en el checklist) ---
    en_chk = {it['script'] for it in items if it['script']}
    huerfanos = sorted(s for s in scripts if s not in en_chk
                       and not s.endswith(('_batch.py', '_util.py', '_headless.py')))

    if as_json:
        print(json.dumps({
            'total_items': len(items),
            'falsos_pendientes': falsos_pend,
            'falsos_completos': falsos_comp,
            'sin_script': sin_script,
            'huerfanos': huerfanos,
        }, ensure_ascii=False, indent=2))
        return

    n_x = sum(1 for it in items if it['marca'] == 'x')
    n_p = sum(1 for it in items if it['marca'] == ' ')
    n_q = sum(1 for it in items if it['marca'] == '?')

    print('=' * 74)
    print('AUDITORIA CRUZADA — CHECKLIST-OBJETOS-BLENDER.md vs disco')
    print('=' * 74)
    print('Items parseados      : %d  ([x]=%d  [ ]=%d  [?]=%d)' % (len(items), n_x, n_p, n_q))
    print('Scripts crear_*.py   : %d en disco' % len(scripts))
    print('GLB ALTA en Godot    : %d' % len(glbs['alta']))
    print('.scn importados      : %d' % len(scns))
    print()

    print('--- A) FALSO PENDIENTE: [ ] pero script+blend+GLB existen (%d) ---'
          % len(falsos_pend))
    for it in falsos_pend:
        print('  L%-4d %-46s %s' % (it['linea'], it['asset'], it['modulo'][:26]))
    print()

    print('--- B) FALSO COMPLETO: [x] pero le falta algo (%d) ---' % len(falsos_comp))
    for it in falsos_comp:
        falta = [k for k, v in (('script', it['hay_script']),
                                ('blend', it['hay_blend']),
                                ('glb', it['hay_glb'])) if not v]
        print('  L%-4d %-40s falta: %-22s %s'
              % (it['linea'], it['asset'], ','.join(falta), it['modulo'][:22]))
    print()

    print('--- C) Items sin script referenciado (%d) ---' % len(sin_script))
    for it in sin_script[:20]:
        print('  L%-4d %s' % (it['linea'], it['texto'][:70]))
    if len(sin_script) > 20:
        print('  ... y %d mas' % (len(sin_script) - 20))
    print()

    print('--- D) Scripts huerfanos: en disco, NO en el checklist (%d) ---' % len(huerfanos))
    for s in huerfanos:
        print('  %-46s %s' % (s, scripts[s][0]))
    print()

    print('--- E) Sidecar .glb.import SIN su .glb (E-103) (%d) ---' % len(huerf_import))
    for h in huerf_import:
        print('  %s' % h)
    print()
    print('=' * 74)


if __name__ == '__main__':
    main()
