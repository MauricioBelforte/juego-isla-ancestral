#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Sonda de CALIBRACION B28: decodifica el BIN real de los 3 GLB de
`columna_entera` y replica sobre TRIANGULOS las mediciones de forma que la
guardia bpy (`verificar_columna_entera.py`) hace sobre los `.blend`.

NO es un test: es medicion previa. Reutiliza el decoder AUTOCONTENIDO de
`verificar_columna_rota.py` (B27). La guardia B28 sera independiente.

OJO: en GLB cada quad del .blend se TRIANGULA en 2 triangulos, asi que los
umbrales de "caras laterales completas" de la guardia bpy (4 / 4 / 16)
deben MEDIRSE de nuevo aqui, no heredarse.

Ejes glTF Y-up: p[0]=X, p[1]=ALTURA, p[2]=LATERAL.
"""
import json
import math
import os
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
SCRIPTS = os.path.join(REPO, 'tools', 'mcp', 'blender-mcp',
                       '25-Ruinas-Templos', 'scripts')
sys.path.insert(0, SCRIPTS)
from verificar_columna_rota import (  # noqa: E402
    cargar, recorrer, leer_vec, aplicar, sha12,
)

GODOT = os.path.join(REPO, 'game', 'isla-ancestral', 'assets', '3d')
BASE = '25-Ruinas-Templos_columna_entera.glb'
LODS = ('alta', 'media', 'baja')

Z_APOYO, H = 0.045, 3.00
Z_ABACO_0, Z_ABACO_1 = 2.78, 2.92
Z_REMATE_0, Z_REMATE_1 = 2.92, 3.00
BANDA_LO, BANDA_HI = 2.79, 2.91
MATS = {'MAT_ColEnt_Piedra', 'MAT_ColEnt_PiedraOsc',
        'MAT_ColEnt_Tallado', 'MAT_ColEnt_Musgo'}


def normal_z(a, b, c):
    """Componente Z de la normal (sin normalizar) del triangulo a,b,c."""
    ux, uy, uz = (b[i] - a[i] for i in range(3))
    vx, vy, vz = (c[i] - a[i] for i in range(3))
    nx, ny, nz = uy * vz - uz * vy, uz * vx - ux * vz, ux * vy - uy * vx
    mod = math.sqrt(nx * nx + ny * ny + nz * nz)
    return abs(nz) / mod if mod > 1e-12 else 0.0


def medir(path):
    raw, doc, bin_, ok = cargar(path)
    assert ok, 'GLB ilegible: %s' % path
    alcanzables, instancias = recorrer(doc)
    nombre_por_mesh = {}
    for i, n in enumerate(doc['nodes']):
        if 'mesh' in n:
            nombre_por_mesh.setdefault(n['mesh'], []).append(n.get('name', ''))

    puntos, triangulos = [], []
    tris = 0
    for mi, m in instancias:
        for pr in doc['meshes'][mi].get('primitives', []):
            pos, e = leer_vec(doc, bin_, pr['attributes']['POSITION'], 'f', 3)
            assert not e and pos, 'POSITION ilegible: %s' % e
            wpos = [aplicar(m, q) for q in pos]
            puntos.extend(wpos)
            ai = pr.get('indices')
            if ai is None:
                idx = list(range(len(pos)))
                count = len(pos)
            else:
                fmt = {5121: 'B', 5123: 'H', 5125: 'I'}.get(
                    doc['accessors'][ai]['componentType'], 'H')
                vals, e2 = leer_vec(doc, bin_, ai, fmt, 1)
                assert not e2
                idx = [v[0] for v in vals]
                count = doc['accessors'][ai]['count']
            tris += count // 3
            for k in range(0, count - 2, 3):
                triangulos.append((wpos[idx[k]], wpos[idx[k + 1]],
                                   wpos[idx[k + 2]]))

    xs = [p[0] for p in puntos]
    alt = [p[1] for p in puntos]
    lat = [p[2] for p in puntos]
    lalt = sorted({round(v, 4) for v in alt})

    va = [p for p in puntos if abs(p[1] - Z_APOYO) < 1e-4]
    apoyo = {(round(p[0], 4), round(p[2], 4)) for p in va}
    fx = (max(p[0] for p in va) - min(p[0] for p in va)) if va else -1.0
    fy = (max(p[2] for p in va) - min(p[2] for p in va)) if va else -1.0

    # Replica de caras_losa() / caras_equino() de la guardia bpy, pero sobre
    # TRIANGULOS del BIN (cada quad del .blend son 2 triangulos aqui).
    n_abaco = n_remate = n_equino = 0
    for a, b, c in triangulos:
        zs = [p[1] for p in (a, b, c)]
        nz = normal_z(a, b, c)
        for z0, z1, nombre in ((Z_ABACO_0, Z_ABACO_1, 'abaco'),
                               (Z_REMATE_0, Z_REMATE_1, 'remate')):
            if (min(zs) < z0 - 1e-3 or max(zs) > z1 + 1e-3):
                continue
            if abs(min(zs) - z0) > 1e-3 or abs(max(zs) - z1) > 1e-3:
                continue
            if any(abs(z - z0) > 1e-3 and abs(z - z1) > 1e-3 for z in zs):
                continue
            if nz < 0.5:
                if nombre == 'abaco':
                    n_abaco += 1
                else:
                    n_remate += 1
        cz = sum(zs) / 3.0
        if 2.55 < cz < 2.77 and nz < 0.9:
            n_equino += 1

    banda = sorted(v for v in lalt if BANDA_LO < v < BANDA_HI)
    verts_media = sum(1 for p in puntos if BANDA_LO < p[1] < BANDA_HI)

    mats = {m.get('name', '') for m in doc.get('materials', [])}

    return {
        'bytes': len(raw), 'tris': tris, 'mats': len(mats),
        'mallas': len(doc['meshes']), 'nodos': len(alcanzables),
        'verts': len(puntos), 'triangulos': len(triangulos),
        'x': [round(min(xs), 4), round(max(xs), 4)],
        'alt': [round(min(alt), 4), round(max(alt), 4)],
        'lat': [round(min(lat), 4), round(max(lat), 4)],
        'huella_apoyo': [round(fx, 4), round(fy, 4)],
        'apoyo_pares': len(apoyo), 'apoyo_verts': len(va),
        'caras_abaco': n_abaco, 'caras_remate': n_remate,
        'caras_equino': n_equino,
        'banda_espuria': banda, 'verts_media_losa': verts_media,
        'niveles_alt': lalt,
        'materiales': sorted(mats),
        'nodos_sm': sorted({n.get('name', '') for n in doc['nodes']
                            if n.get('name', '').startswith('SM_')}),
        'sha': sha12(path),
    }


def main():
    out = {}
    for lod in LODS:
        d = medir(os.path.join(GODOT, lod, BASE))
        out[lod] = d
        print('%-5s tris=%-4d triangulos=%-4d mats=%d mallas=%-2d nodos=%-2d '
              'verts=%-4d alt=[%.4f..%.4f] sha=%s'
              % (lod, d['tris'], d['triangulos'], d['mats'], d['mallas'],
                 d['nodos'], d['verts'], d['alt'][0], d['alt'][1], d['sha']))
        print('   huella_apoyo=%s pares=%d verts=%d | caras ABACO=%d '
              'REMATE=%d EQUINO=%d'
              % (d['huella_apoyo'], d['apoyo_pares'], d['apoyo_verts'],
                 d['caras_abaco'], d['caras_remate'], d['caras_equino']))
        print('   banda_espuria(2.79,2.91)=%s verts_media_losa=%d'
              % (d['banda_espuria'], d['verts_media_losa']))
        print('   niveles_alt=%s' % d['niveles_alt'])
        print('   materiales=%s' % d['materiales'])
        print('   nodos_sm=%s' % d['nodos_sm'])
    print('=== CONSISTENCIA ENTRE LOD ===')
    print('tris=%d/%d/%d caras_abaco=%d/%d/%d verts_media=%d/%d/%d'
          % (out['alta']['tris'], out['media']['tris'], out['baja']['tris'],
             out['alta']['caras_abaco'], out['media']['caras_abaco'],
             out['baja']['caras_abaco'],
             out['alta']['verts_media_losa'], out['media']['verts_media_losa'],
             out['baja']['verts_media_losa']))
    ruta = os.path.join(REPO, 'Temp', 'hy4_b28_glb_probe_20261113.json')
    with open(ruta, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(out, f, ensure_ascii=False, indent=2, sort_keys=True)
        f.write('\n')
    print('PROBE_JSON %s' % ruta)


if __name__ == '__main__':
    main()
